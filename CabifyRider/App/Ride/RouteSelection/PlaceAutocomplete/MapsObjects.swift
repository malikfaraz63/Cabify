//
//  MapsObjects.swift
//  CabifyRider
//
//  Created by Faraz Malik on 14/08/2023.
//

import Foundation

struct PredictionsWrapper: Codable {
    let predictions: [LocationPrediction]
}

struct LocationPrediction: Codable {
    let description: String
    let structuredFormatting: DescriptionBreakdown
    let placeId: String
}

struct DescriptionBreakdown: Codable {
    let mainText: String
    let secondaryText: String
}

struct DetailWrapper: Codable {
    let result: GeometryWrapper
}

struct GeometryWrapper: Codable {
    let geometry: Geometry
}

struct Geometry: Codable {
    let location: LocationDetail
}

struct LocationDetail: Codable, CKCoordinate {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}

struct DescriptionWrapper: Codable {
    let results: [LocationDescription]
}

struct LocationDescription: Codable {
    let formattedAddress: String
}
