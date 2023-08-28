//
//  CKRider.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 08/08/2023.
//

import Foundation

struct CKRider: Codable {
    let riderId: String
    let name: String
    let email: String
    let photoURL: String?
    let phone: String
    let funds: Double
    let ridesCount: Int
    let ratings: CKRatingSummary
    let accountCreated: Date
}
