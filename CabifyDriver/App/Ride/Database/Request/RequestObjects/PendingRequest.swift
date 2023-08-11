//
//  PendingRequest.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 26/07/2023.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct PendingRequest: Codable {
    var documentID: String?
    let origin: Location
    let destination: GeoPoint
    let timeCreated: Date
    let cost: Double
    let driverViews: Int
    let riderId: String
    let riderRating: Double
    let status: RequestStatus
}
