//
//  Ride.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 07/08/2023.
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
    let cost: Double
    let status: RideStatus
}
