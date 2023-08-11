//
//  RideLocation.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 07/08/2023.
//

import Foundation
import FirebaseFirestore

struct RideLocation: Codable {
    let coordinate: GeoPoint
    let time: Date
}
