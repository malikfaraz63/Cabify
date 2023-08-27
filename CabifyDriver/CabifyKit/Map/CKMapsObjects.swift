//
//  CKMapsObjects.swift
//  CabifyKit
//
//  Created by Faraz Malik on 14/08/2023.
//

import Foundation

struct CKPredictionsWrapper: Codable {
    let predictions: [CKLocationPrediction]
}

struct CKLocationPrediction: Codable {
    let description: String
    let structuredFormatting: CKDescriptionBreakdown
    let placeId: String
}

struct CKDescriptionBreakdown: Codable {
    let mainText: String
    let secondaryText: String
}

struct CKDetailWrapper: Codable {
    let result: CKGeometryWrapper
}

struct CKGeometryWrapper: Codable {
    let geometry: CKGeometry
}

struct CKGeometry: Codable {
    let location: CKLocationDetail
}

struct CKLocationDetail: Codable, CKCoordinate {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}

struct CKDescriptionWrapper: Codable {
    let results: [CKLocationDescription]
}

struct CKLocationDescription: Codable {
    let formattedAddress: String
}
