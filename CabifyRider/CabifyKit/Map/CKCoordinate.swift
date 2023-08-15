//
//  CKCoordinate.swift
//  CabifyKit
//
//  Created by Faraz Malik on 12/08/2023.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift


public protocol CKCoordinate {
    var latitude: Double { get }
    var longitude: Double { get }
}

struct Location: Codable { 
    let coordinate: GeoPoint
    let hash: String
}

extension GeoPoint: CKCoordinate {}
extension CLLocationCoordinate2D: CKCoordinate {}

extension CLLocationCoordinate2D {
    init(from location: CKCoordinate) {
        self.init()
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
}
