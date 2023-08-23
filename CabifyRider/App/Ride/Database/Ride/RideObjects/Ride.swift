//
//  Ride.swift
//  CabifyRider
//
//  Created by Faraz Malik on 21/08/2023.
//

import Foundation
import FirebaseFirestore

struct Ride: Codable {
    let rideId: String
    let origin: GeoPoint
    let destination: GeoPoint
    let timeDriverArrived: Date
    let timeRiderArrived: Date?
    let timeCompleted: Date?
    let riderId: String
    let driverId: String
    let driverLocation: GeoPoint
    let driverLastUpdated: Date
    let cost: Double
    let status: CKRideStatus
    
    static let nilRide = Ride(rideId: "", origin: GeoPoint(latitude: 0, longitude: 0), destination: GeoPoint(latitude: 0, longitude: 0), timeDriverArrived: Date(), timeRiderArrived: nil, timeCompleted: nil, riderId: "", driverId: "", driverLocation: GeoPoint(latitude: 0, longitude: 0), driverLastUpdated: Date(), cost: 0, status: .unknown)
}
