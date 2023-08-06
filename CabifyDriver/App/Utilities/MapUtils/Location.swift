//
//  Location.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 29/07/2023.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct Location: Codable {
    let coordinate: GeoPoint
    let hash: String
}

protocol Coordinate {
    var latitude: Double { get }
    var longitude: Double { get }
}

extension GeoPoint: Coordinate {}
extension CLLocationCoordinate2D: Coordinate {}

extension CLLocationCoordinate2D {
    init(from location: Coordinate) {
        self.init()
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
}


