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
}
