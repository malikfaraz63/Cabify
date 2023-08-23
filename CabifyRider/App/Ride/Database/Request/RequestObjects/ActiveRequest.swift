//
//  ActiveRequest.swift
//  CabifyRider
//
//  Created by Faraz Malik on 19/08/2023.
//

import Foundation
import FirebaseFirestore

struct ActiveRequest: Codable {
    let requestId: String
    let origin: Location
    let destination: GeoPoint
    let timeCreated: Date
    let cost: Double
    let driverViews: Int
    let riderId: String
    let riderRating: Double
    let driverId: String
    let driverLocation: GeoPoint
    let driverLastUpdated: Date
    let status: CKRequestStatus
    
    let driverUnread: Int
    let riderUnread: Int
    
    static let nilRequest = ActiveRequest(requestId: "", origin: Location(coordinate: GeoPoint(latitude: 0, longitude: 0), hash: ""), destination: GeoPoint(latitude: 0, longitude: 0), timeCreated: Date(), cost: 0, driverViews: 0, riderId: "", riderRating: 0, driverId: "", driverLocation: GeoPoint(latitude: 0, longitude: 0), driverLastUpdated: Date(), status: .unknown, driverUnread: 0, riderUnread: 0)
}
