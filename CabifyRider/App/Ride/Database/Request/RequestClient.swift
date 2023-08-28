//
//  RequestClient.swift
//  CabifyRider
//
//  Created by Faraz Malik on 17/08/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class RequestClient {
    private let db = Firestore.firestore()
    
    private var nearbyDriverListeners: [String: ListenerRegistration]
    private var lastLocationHash: String
    private var locationHashFilters: [Filter]
    private var unreadDriverMessageIds: [String]
    
    private var requestListener: ListenerRegistration?
    private var riderMessagesListener: ListenerRegistration?
    private var driverMessagesListener: ListenerRegistration?
    
    typealias DriverChangedCompletion = (CKDriver) -> Void
    typealias RatingFetchCompletion = (Double) -> Void
    typealias PendingRequestCompletion = (PendingRequest) -> Void
    typealias RequestChangedCompletion = (DocumentSnapshot) -> Void
    
    typealias UpdateCompletion = (Bool) -> Void
    typealias MessagesLoadCompletion = ([CKRequestMessage]) -> Void
    
    init() {
        self.nearbyDriverListeners = [:]
        self.lastLocationHash = ""
        self.locationHashFilters = []
        self.unreadDriverMessageIds = []
    }
    
    // MARK: User Details
    
    private func getRiderRating(withRiderId riderId: String, completion: @escaping RatingFetchCompletion) {
        db
            .collection("riders")
            .document(riderId)
            .getDocument(as: CKRider.self) { result in
                switch result {
                case .success(let rider):
                    completion(rider.ratings.average)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    // MARK: Nearby Drivers
    
    public func setNearbyDriverListeners(atLocation location: CKCoordinate, changeCompletion: @escaping DriverChangedCompletion, offlineCompletion: @escaping DriverChangedCompletion) {
        print("setting listener")
        let newLocationHash = CKMapUtility.generateHashForCoordinate(location)
        
        if newLocationHash != lastLocationHash {
            lastLocationHash = newLocationHash
            reloadHashFilters()
        }
        
        clearNearbyDriverListeners()
        
        db
            .collection("drivers")
            .whereField("isOnline", isEqualTo: true)
            .whereFilter(Filter.orFilter(locationHashFilters))
            .limit(to: 10)
            .getDocuments { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    print("snapshot count: \(querySnapshot.documents.count)")
                    for document in querySnapshot.documents {
                        self.setNearbyDriverListener(document.documentID, changeCompletion: changeCompletion, offlineCompletion: offlineCompletion)
                    }
                } else if let error = error {
                    print(error)
                }
            }
    }
    
    private func setNearbyDriverListener(_ driverId: String, changeCompletion: @escaping DriverChangedCompletion, offlineCompletion: @escaping DriverChangedCompletion) {
        let driverListener = db
            .collection("drivers")
            .document(driverId)
            .addSnapshotListener { documentSnapshot, error in
                print(" - snapshot listener fired")
                if let documentSnapshot = documentSnapshot {
                    do {
                        let driver = try documentSnapshot.data(as: CKDriver.self)
                        
                        if driver.isOnline {
                            changeCompletion(driver)
                        } else {
                            offlineCompletion(driver)
                            self.removeNearbyDriverListener(driverId)
                        }
                    } catch let error {
                        print(error)
                    }
                } else if let error = error {
                    print(error)
                }
            }
        
        nearbyDriverListeners[driverId] = driverListener
    }
    
    public func clearNearbyDriverListeners() {
        if nearbyDriverListeners.isEmpty { return }
        for listener in nearbyDriverListeners.values {
            listener.remove()
        }
        nearbyDriverListeners.removeAll()
    }
    
    public func removeNearbyDriverListener(_ driverId: String) {
        if nearbyDriverListeners[driverId] != nil {
            nearbyDriverListeners[driverId]!.remove()
            nearbyDriverListeners.removeValue(forKey: driverId)
        }
    }
    
    // MARK: Requests
    
    public func getPendingRequest(withRequestId requestId: String, completion: @escaping PendingRequestCompletion) {
        db
            .collection("requests").document(requestId)
            .getDocument(as: PendingRequest.self) { result in
                switch result {
                case .success(let request):
                    completion(request)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    public func createRequest(withRiderId riderId: String, pickup: CKCoordinate, dropoff: CKCoordinate, cost: Double, completion: @escaping PendingRequestCompletion) {
        let origin = Location(
            coordinate: GeoPoint(latitude: pickup.latitude, longitude: pickup.longitude),
            hash: CKMapUtility.generateHashForCoordinate(pickup)
        )
        let destination = GeoPoint(latitude: dropoff.latitude, longitude: dropoff.longitude)
        
        let completion: RatingFetchCompletion = { rating in
            var request = PendingRequest(cost: cost, destination: destination, driverViews: 0, origin: origin, riderId: riderId, requestId: "TEMP", riderRating: rating, status: .pending, timeCreated: Date())
            
            do {
                var ref: DocumentReference?
                ref = try self.db
                    .collection("requests")
                    .addDocument(from: request) { error in
                        if let error = error {
                            print(error)
                            return
                        }
                        ref!.updateData(["requestId": ref!.documentID]) { error in
                            if let error = error {
                                print(error)
                                return
                            }
                            request.requestId = ref!.documentID
                            completion(request)
                        }
                    }
            } catch let error {
                print(error)
            }
        }
        
        getRiderRating(withRiderId: riderId, completion: completion)
    }
    
    public func setRequestListener(withRequestId requestId: String, completion: @escaping RequestChangedCompletion) {
        if let requestListener = requestListener { requestListener.remove() }
        
        requestListener = db
            .collection("requests")
            .document(requestId)
            .addSnapshotListener { documentSnapshot, error in
                if let snapshot = documentSnapshot {
                    completion(snapshot)
                } else if let error = error {
                    print(error)
                }
            }
    }
    
    public func removeRequestListener() {
        if let requestListener = requestListener { requestListener.remove() }
        requestListener = nil
    }
    
    // MARK: Messages
    
    
    public func removeRequestMessagesListeners() {
        if let riderMessagesListener = riderMessagesListener {
            riderMessagesListener.remove()
        }
        if let driverMessagesListener = driverMessagesListener {
            driverMessagesListener.remove()
        }
        riderMessagesListener = nil
        driverMessagesListener = nil
    }
    
    public func setRequestMessagesListener(forRequestId requestId: String, messageSource: RequestMessageSource, completion: @escaping MessagesLoadCompletion) {
        let messagesListener = db
            .collection("requests")
            .document(requestId)
            .collection(messageSource.rawValue)
            .addSnapshotListener { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    var requestMessages: [CKRequestMessage] = []
                    do {
                        try requestMessages.append(contentsOf: querySnapshot.documents.map { try $0.data(as: CKRequestMessage.self) })
                    } catch let error {
                        print(error)
                    }
                    
                    if messageSource == .driverMessages {
                        self.unreadDriverMessageIds = querySnapshot.documents
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
    
    public func incrementRiderUnreadForRequestId(_ requestId: String) {
        updateRequest(withRequestId: requestId) { (request: ActiveRequest) in
            return ["riderUnread": request.riderUnread + 1]
        }
    }
    
    public func sendMessage(forRequestId requestId: String, message: CKRequestMessage) {
        let requestDriverMessagesRef = db
            .collection("requests")
            .document(requestId)
            .collection(RequestMessageSource.riderMessages.rawValue)
        
        do {
            try requestDriverMessagesRef
                .document()
                .setData(from: message)
        } catch let error {
            print(error)
        }
    }
    
    public func markDriverMessagesReadForRequestId(_ requestId: String) {
        updateRequest(withRequestId: requestId) { (request: ActiveRequest) in
            return ["driverUnread": 0]
        }
        
        let requestRiderMessagesRef = db
            .collection("requests")
            .document(requestId)
            .collection(RequestMessageSource.driverMessages.rawValue)
        
        for messageId in unreadDriverMessageIds {
            requestRiderMessagesRef
                .document(messageId)
                .updateData(["read": true])
        }
        
        unreadDriverMessageIds.removeAll()
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
                completion?(false)
            }
        }
    }

    private func reloadHashFilters() {
        let hashes = CKMapUtility.getNeighbouringHashes(lastLocationHash)
        locationHashFilters.removeAll()
        
        for hash in hashes {
            locationHashFilters.append(Filter.whereField("location.hash", isEqualTo: hash))
        }
    }
}

enum RequestMessageSource: String {
    case driverMessages
    case riderMessages
}
