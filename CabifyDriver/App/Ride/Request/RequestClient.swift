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
    public private(set) var isListening: Bool
    private var requestListener: ListenerRegistration?
    private var previousLocationHash: String
    
    private let db = Firestore.firestore()
    
    typealias RequestLoadCompletion = ([PendingRequest]) -> Void
    
    init() {
        self.isListening = false
        self.previousLocationHash = ""
    }
    
    public func setRequestListener(atLocation location: Coordinate, radius: Double, whenTriggered triggerCompletion: @escaping RequestLoadCompletion) {
        let newLocationHash = MapUtility.generateHashForCoordinate(location)
        
        if newLocationHash == previousLocationHash {
            return
        } else {
            previousLocationHash = newLocationHash
        }
        
        if isListening {
            requestListener?.remove()
        } else {
            isListening = true
        }
                
        let hashes = MapUtility.getNeighbouringHashes(newLocationHash)
        
        var hashFilters: [Filter] = []
        
        for hash in hashes {
            print("Hash: " + hash)
            hashFilters.append(Filter.whereField("origin.hash", isEqualTo: hash))
        }
        requestListener = db
            .collection("requests")
            .whereField("status", isEqualTo: RequestStatus.pending.rawValue)
            .whereFilter(Filter.orFilter(hashFilters))
            .order(by: "timeCreated", descending: true)
            .order(by: "driverViews")
            .limit(to: 3)
            .addSnapshotListener { querySnapshot, error in
                if let snapshot = querySnapshot {
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
                                        
                    let result = pendingRequests.filter {
                        print(MapUtility.getDistanceBetweenCoordinates(location, $0.origin.coordinate))
                        return true
                    }
                    print("Event listener completed")
                    triggerCompletion(result)
                } else if let error = error {
                    print(error)
                }
            }
    }
}
