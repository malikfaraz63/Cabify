//
//  ActiveRequest.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 01/08/2023.
//

import Foundation
import FirebaseFirestore

struct ActiveRequest: Codable {
    var documentID: String?
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
    let status: RequestStatus
    
    let driverUnread: Int
    let riderUnread: Int
}
