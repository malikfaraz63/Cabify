//
//  RouteSummary.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 30/07/2023.
//

import Foundation

struct RouteSummary {
    let originAddress: String
    let destinationAddress: String
    let distance: Object
    let duration: Object
}

struct RouteSummaryWrapper: Codable {
    let originAddresses: [String]
    let destinationAddresses: [String]
    let rows: [Element]
}

struct Element: Codable {
    let elements: [Summary]
}

struct Summary: Codable {
    let distance: Object
    let duration: Object
}

struct Object: Codable {
    let text: String
    let value: Int
}
