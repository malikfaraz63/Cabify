//
//  RequestClient.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 30/07/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

class RequestClient {
    private var declinedCurrentRequest: Bool
    private var declinedRequestIds: Set<String>

    private var requestListener: ListenerRegistration?
    private var lastLocationHash: String
    private var locationHashFilters: [Filter]
    
    private var riderMessagesListener: ListenerRegistration?
    private var driverMessagesListener: ListenerRegistration?
    private var unreadRiderMessageIds: [String]
    
    private let db = Firestore.firestore()
    
    typealias PendingRequestsLoadCompletion = ([PendingRequest]) -> Void
    typealias ActiveRequestChangedCompletion = (ActiveRequest) -> Void
    typealias UpdateCompletion = (Bool) -> Void
    typealias RequestAcceptedCompletion = (Bool) -> Void
    typealias MessagesLoadCompletion = ([RequestMessage]) -> Void
    
    init() {
        self.declinedCurrentRequest = false
        self.lastLocationHash = ""
        self.declinedRequestIds = []
        self.locationHashFilters = []
        self.unreadRiderMessageIds = []
    }
    
    public func didViewRequest(_ requestId: String) {
        print("--didViewRequest--")
        print("  requestId: \(requestId)")
        declinedRequestIds.insert(requestId)
        declinedCurrentRequest = true
    }
    
    // MARK: Pending Requests
    
    
    public func removePendingRequestsListener() {
        if let requestListener = requestListener {
            requestListener.remove()
        }
        requestListener = nil
    }
    
    public func setPendingRequestsListener(atLocation location: Coordinate, triggerCompletion: @escaping PendingRequestsLoadCompletion) {
        print("--setPendingRequestsListener")
        let newLocationHash = MapUtility.generateHashForCoordinate(location)
        
        if newLocationHash != lastLocationHash {
            lastLocationHash = newLocationHash
            reloadHashFilters()
        } else if !declinedCurrentRequest {
            return
        }

        declinedCurrentRequest = false
        
        if let requestListener = requestListener {
            requestListener.remove()
        }
        
        print("  setting listener")
        
        requestListener = db
            .collection("requests")
            .whereField("status", isEqualTo: RequestStatus.pending.rawValue)
            .whereField("timeCreated", isGreaterThanOrEqualTo: Date(timeIntervalSinceNow: -3600))
            .whereFilter(Filter.orFilter(locationHashFilters))
            .order(by: "timeCreated", descending: true)
            .order(by: "driverViews")
            .limit(to: 5)
            .addSnapshotListener { querySnapshot, error in
                if let snapshot = querySnapshot {
                    print("  listener called with \(snapshot.documents.count) documents")
                    var pendingRequests: [PendingRequest] = []
                    do {
                        try pendingRequests.append(contentsOf: snapshot.documents.map { document in
                            var request = try document.data(as: PendingRequest.self)
                            request.documentID = document.documentID
                            
                            return request
                        })
                    } catch let error {
                        print(error)
                    }
                    
                    let sortedRequests = pendingRequests
                        .filter { !self.declinedRequestIds.contains($0.documentID!) }
                        .sorted { $0.driverViews < $1.driverViews }
                    triggerCompletion(sortedRequests)
                } else if let error = error {
                    print("somehow")
                    print(error)
                }
            }
    }
    
    public func incrementDriverViewsForRequestId(_ requestId: String) {
        updateRequest(withRequestId: requestId) { (request: PendingRequest) in
            return ["driverViews": request.driverViews + 1]
        }
    }
    
    // MARK: Active Requests
    
    
    public func tryAcceptRequest(withRequestId requestId: String, driverId: String, completion: @escaping RequestAcceptedCompletion) {
        self.updateRequest(withRequestId: requestId, updateHandler: { (request: PendingRequest) in
            if request.status == .pending {
                return [
                    "status": RequestStatus.active.rawValue,
                    "driverId": driverId,
                    "driverUnread": 0,
                    "riderUnread": 0
                ]
            } else {
                completion(false)
                return [:]
            }
        }, completion: completion)
        
        let requestRef = db
            .collection("requests")
            .document(requestId)
        
        requestRef
            .getDocument(as: PendingRequest.self) { result in
                switch result {
                case .success(let request):
                    if request.status == .pending {
                        requestRef
                            .updateData([
                                "status": RequestStatus.active.rawValue,
                                "driverId": driverId,
                                "driverUnread": 0,
                                "riderUnread": 0
                            ]) { error in
                                if let error = error {
                                    completion(false)
                                } else {
                                    completion(true)
                                }
                            }
                    } else {
                        completion(false)
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
    }
    
    public func setActiveRequestListener(withRequestId requestId: String, location: GeoPoint, completion: @escaping ActiveRequestChangedCompletion) {
        updateRequestDriverLocation(withLocation: location, requestId: requestId)
        
        db
            .collection("requests")
            .document(requestId)
            .addSnapshotListener { documentSnapshot, error in
                if let documentSnapshot = documentSnapshot {
                    do {
                        var activeRequest = try documentSnapshot.data(as: ActiveRequest.self)
                        activeRequest.documentID = documentSnapshot.documentID
                        completion(activeRequest)
                    } catch let error {
                        print(error)
                    }
                } else if let error = error {
                    print(error)
                }
            }
    }
    
    public func updateRequestDriverLocation(withLocation location: GeoPoint, requestId: String)  {
        let driverLocationData: [String: Any] = [
            "driverLocation": location,
            "driverLastUpdated": Date()
        ]
        
        db
            .collection("requests")
            .document(requestId)
            .updateData(driverLocationData)
    }
    
    // MARK: Messages
    
    
    public func setRequestMessagesListener(forRequestId requestId: String, messageSource: RequestMessageSource, completion: @escaping MessagesLoadCompletion) {
        let messagesListener = db
            .collection("requests")
            .document(requestId)
            .collection(messageSource.rawValue)
            .addSnapshotListener { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    var requestMessages: [RequestMessage] = []
                    do {
                        try requestMessages.append(contentsOf: querySnapshot.documents.map { try $0.data(as: RequestMessage.self) })
                    } catch let error {
                        print(error)
                    }
                    
                    if messageSource == .riderMessages {
                        self.unreadRiderMessageIds = querySnapshot.documents
                            .filter { !($0.data()["read"] as! Bool) }
                            .map { $0.documentID }
                    }
                    
                    completion(requestMessages)
                }
            }
        
        if messageSource == .riderMessages {
            if let riderMessagesListener = riderMessagesListener {
                riderMessagesListener.remove()
            }
            riderMessagesListener = messagesListener
        } else {
            if let driverMessagesListener = driverMessagesListener {
                driverMessagesListener.remove()
            }
            driverMessagesListener = messagesListener
        }
    }
    
    public func incrementDriverUnreadForRequestId(_ requestId: String) {
        updateRequest(withRequestId: requestId) { (request: ActiveRequest) in
            return ["driverUnread": request.driverUnread + 1]
        }
    }
    
    public func sendMessage(forRequestId requestId: String, message: RequestMessage) {
        let requestDriverMessagesRef = db
            .collection("requests")
            .document(requestId)
            .collection(RequestMessageSource.driverMessages.rawValue)
        
        do {
            try requestDriverMessagesRef
                .document()
                .setData(from: message)
        } catch let error {
            print(error)
        }
    }
    
    public func markRiderMessagesReadForRequestId(_ requestId: String) {
        updateRequest(withRequestId: requestId) { (request: ActiveRequest) in
            return ["riderUnread": 0]
        }
        
        let requestRiderMessagesRef = db
            .collection("requests")
            .document(requestId)
            .collection(RequestMessageSource.riderMessages.rawValue)
        
        for messageId in unreadRiderMessageIds {
            requestRiderMessagesRef
                .document(messageId)
                .setData(["read": true])
        }
        
        unreadRiderMessageIds.removeAll()
    }
    
    // MARK: Miscellaneous
    
    
    private func updateRequest<T: Codable>(withRequestId requestId: String, updateHandler: @escaping (T) -> [String: Any], completion: UpdateCompletion? = nil) {
        let requestRef = db
            .collection("requests")
            .document(requestId)
        
        requestRef.getDocument(as: T.self) { result in
            switch result {
            case .success(let request):
                let data = updateHandler(request)
                if !data.isEmpty {
                    requestRef.updateData(data) { error in
                        completion?(error == nil)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func reloadHashFilters() {
        let hashes = MapUtility.getNeighbouringHashes(lastLocationHash)
        
        locationHashFilters.removeAll()
        
        for hash in hashes {
            locationHashFilters.append(Filter.whereField("origin.hash", isEqualTo: hash))
        }
    }
}

enum RequestMessageSource: String {
    case driverMessages
    case riderMessages
}
