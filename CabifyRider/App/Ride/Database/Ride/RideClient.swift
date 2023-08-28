//
//  RideClient.swift
//  CabifyRider
//
//  Created by Faraz Malik on 21/08/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class RideClient {
    private let db = Firestore.firestore()
    
    private var rideListener: ListenerRegistration?
    
    typealias RideCompletion = (Ride) -> Void
    
    // MARK: Rides
    
    public func getRide(withRideId rideId: String, completion: @escaping RideCompletion) {
        db
            .collection("rides")
            .document(rideId)
            .getDocument(as: Ride.self) { result in
                switch result {
                case .success(let ride):
                    completion(ride)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    public func setRideListener(withRideId rideId: String, completion: @escaping RideCompletion) {
        if let rideListener = rideListener { rideListener.remove() }
        
        rideListener = db
            .collection("rides")
            .document(rideId)
            .addSnapshotListener { documentSnapshot, error in
                if let documentSnapshot = documentSnapshot {
                    do {
                        let ride = try documentSnapshot.data(as: Ride.self)
                        completion(ride)
                    } catch let error {
                        print(error)
                    }
                } else if let error = error {
                    print(error)
                }
            }
    }
    
    public func removeRideListener() {
        if let rideListener = rideListener { rideListener.remove() }
        rideListener = nil
    }
}
