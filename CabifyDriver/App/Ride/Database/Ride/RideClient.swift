//
//  RideClient.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 07/08/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

class RideClient {
    typealias RideCompletion = (Ride) -> Void
    typealias RideUpdateCompletion = (Bool) -> Void
    typealias TransferCompletion = () -> Void
    typealias UpdateCompletion = (Bool) -> Void
    
    private let db = Firestore.firestore()
    
    public func createRide(fromRequest request: ActiveRequest, completion: @escaping RideCompletion) {
        guard let requestId = request.documentID else { return }
        
        let ride = Ride(rideId: requestId, origin: request.origin.coordinate, destination: request.destination, timeDriverArrived: Date(), timeRiderArrived: nil, timeCompleted: nil, riderId: request.riderId, driverId: request.driverId, cost: request.cost, status: .waiting)
        
        do {
            try db
                .collection("rides")
                .document(requestId)
                .setData(from: ride) { error in
                    if let error = error {
                        print(error)
                    } else {
                        completion(ride)
                    }
                }
        } catch let error {
            print(error)
        }
    }
    
    public func updateRideDriverLocation(withLocation location: GeoPoint, rideId: String) {
        let location = RideLocation(coordinate: location, time: Date())
        
        do {
            try db
                .collection("rides")
                .document(rideId)
                .collection("locations")
                .document()
                .setData(from: location)
        } catch let error {
            print(error)
        }
    }
    
    public func setRideListener(withRideId rideId: String, completion: @escaping RideCompletion) {
        db
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
    
    // MARK: Ride status
    
    
    public func updateRideAsActive(withRideId rideId: String, completion: @escaping UpdateCompletion) {
        updateRide(withRideId: rideId, updateHandler: { (request: Ride) in
            return [
                "status": RideStatus.active.rawValue,
                "timeRiderArrived": Date()
            ]
        }, completion: completion)
    }
    
    public func updateRideAsCompleted(withRideId rideId: String, completion: @escaping UpdateCompletion) {
        updateRide(withRideId: rideId, updateHandler: { (request: Ride) in
            return [
                "status": RideStatus.completed.rawValue,
                "timeCompleted": Date()
            ]
        }, completion: completion)
    }
    
    public func transferMoney(forCompletedRideId rideId: String, completion: TransferCompletion? = nil) {
        db
            .collection("rides")
            .document(rideId)
            .getDocument(as: Ride.self) { result in
                switch result {
                case .success(let ride):
                    self.transferMoney(forCompletedRide: ride, completion: completion)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func transferMoney(forCompletedRide ride: Ride, completion: TransferCompletion?) {
        if ride.status != .completed {
            return
        }
        
        guard let timeRiderArrived = ride.timeRiderArrived else { return }
        
        let riderRef = db.collection("riders").document(ride.riderId)
        let driverRef = db.collection("drivers").document(ride.driverId)
        let completedRideRefD = driverRef.collection("completedRides").document(ride.rideId)
        let completedRideRefR = riderRef.collection("completedRides").document(ride.rideId)
        
        db.runTransaction({(transaction, errorPointer) -> Any? in
            let rider: Rider
            let driver: Driver
            do {
                rider = try transaction.getDocument(riderRef).data(as: Rider.self)
                driver = try transaction.getDocument(driverRef).data(as: Driver.self)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let countdownDuration = 120.0
            let rate = 0.25
            let waitingFees: Double
            let timeInterval = timeRiderArrived.timeIntervalSince(ride.timeDriverArrived)
            if timeInterval > countdownDuration {
                waitingFees = Double(Int(timeInterval - countdownDuration) / 60) * rate
            } else {
                waitingFees = 0
            }
            
            let transactionAmount = ride.cost + waitingFees
            
            transaction.updateData(["funds": rider.funds - transactionAmount], forDocument: riderRef)
            transaction.updateData(["earnings": driver.earnings + transactionAmount], forDocument: driverRef)
            
            var data: [String: Any] = [
                "rideId": ride.rideId,
                "cost": ride.cost,
                "timeCompleted": ride.timeCompleted!
            ]
            if waitingFees > 0 {
                data["waitingFees"] = waitingFees
            }
            
            transaction.updateData(["ridesCount": driver.ridesCount + 1], forDocument: driverRef)
            transaction.setData(data, forDocument: completedRideRefD)
            transaction.setData(data, forDocument: completedRideRefR)
            return nil
        }) { object, error in
            if let error = error {
                print(error)
            } else {
                completion?()
            }
        }
    }
    
    // MARK: Miscellaneous
    
    
    private func updateRide<T: Codable>(withRideId rideId: String, updateHandler: @escaping (T) -> [String: Any], completion: UpdateCompletion? = nil) {
        let rideRef = db
            .collection("rides")
            .document(rideId)
        
        rideRef.getDocument(as: T.self) { result in
            switch result {
            case .success(let request):
                let data = updateHandler(request)
                if !data.isEmpty {
                    rideRef.updateData(data) { error in
                        completion?(error == nil)
                    }
                }
            case .failure(let error):
                print(error)
                completion?(false)
            }
        }
    }
}
