//
//  PastJourney.swift
//  CabifyRider
//
//  Created by Faraz Malik on 27/08/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PastJourney: Codable {
    let cost: Double
    let rideId: String
    let destination: GeoPoint
    let timeCompleted: Date
}
