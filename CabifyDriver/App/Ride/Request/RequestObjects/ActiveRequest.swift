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
//    
//    init(fromRequest request: PendingRequest, driverId: String, location: GeoPoint) {
//        self.documentID = request.documentID
//        self.origin = request.origin
//        self.destination = request.destination
//        self.timeCreated = request.timeCreated
//        self.cost = request.cost
//        self.driverViews = request.driverViews
//        self.riderId = request.riderId
//        self.riderRating = request.riderRating
//        self.driverId = driverId
//        self.driverLocation = location
//        self.driverLastUpdated = Date()
//        self.status = .active
//        self.driverUnread = 0
//        self.riderUnread = 0
//    }
}

