//
//  CKRatingSummary.swift
//  CabifyRider
//
//  Created by Faraz Malik on 28/08/2023.
//

import Foundation

struct CKRatingSummary: Codable {
    let average: Double
    let count: Int
}

struct CKRatingsWrapper: Codable {
    let ratings: CKRatingSummary
}
