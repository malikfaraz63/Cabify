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
    
    typealias RideChangedCompletion = (Ride) -> Void
    
    // MARK: Rides
    
    public func setRideListener(withRideId rideId: String, completion: @escaping RideChangedCompletion) {
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
