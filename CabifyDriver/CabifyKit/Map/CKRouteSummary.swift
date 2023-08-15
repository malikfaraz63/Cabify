//
//  CKRouteSummary.swift
//  CabifyKit
//
//  Created by Faraz Malik on 12/08/2023.
//

import Foundation

public struct CKRouteSummary {
    let originAddress: String
    let destinationAddress: String
    let distance: CKObject
    let duration: CKObject
}

public struct CKRouteSummaryWrapper: Codable {
    let originAddresses: [String]
    let destinationAddresses: [String]
    let rows: [CKElement]
}

public struct CKElement: Codable {
    let elements: [CKSummary]
}

public struct CKSummary: Codable {
    let distance: CKObject
    let duration: CKObject
}

public struct CKObject: Codable {
    let text: String
    let value: Int
}
