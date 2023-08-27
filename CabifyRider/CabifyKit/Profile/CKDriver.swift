//
//  Driver.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 27/07/2023.
//

import Foundation

struct CKDriver: Codable {
    let driverId: String
    let name: String
    let email: String
    let isOnline: Bool
    let photoURL: String?
    let phone: String
    let accountCreated: Date
    let earnings: Double
    let averageRating: Double
    let ridesCount: Int
    let location: Location?
    let lastUpdated: Date?
}
