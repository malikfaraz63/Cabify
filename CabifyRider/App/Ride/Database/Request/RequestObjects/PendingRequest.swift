//
//  PendingRequest.swift
//  CabifyRider
//
//  Created by Faraz Malik on 17/08/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PendingRequest: Codable {
    let cost: Double
    let destination: GeoPoint
    let driverViews: Int
    let origin: Location
    let riderId: String
    var requestId: String
    let riderRating: Double
    let status: CKRequestStatus
    let timeCreated: Date
    
    static let nilRequest = PendingRequest(cost: 0, destination: GeoPoint(latitude: 0, longitude: 0), driverViews: 0, origin: Location(coordinate: GeoPoint(latitude: 0, longitude: 0), hash: ""), riderId: "", requestId: "", riderRating: 0, status: .unknown, timeCreated: Date())
}
