//
//  DriverAnnotation.swift
//  CabifyRider
//
//  Created by Faraz Malik on 17/08/2023.
//

import Foundation
import MapKit

class CKDriverAnnotation: NSObject, MKAnnotation {
    static let identifier = "DriverAnnotation"
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func getView() -> MKAnnotationView {
        print("getting view...")
        let annotationView = MKMarkerAnnotationView(annotation: self, reuseIdentifier: CKDriverAnnotation.identifier)
        annotationView.animatesWhenAdded = true
        annotationView.glyphImage = UIImage(systemName: "car.fill")
        annotationView.markerTintColor = .black
        annotationView.glyphTintColor = .white
        
        return annotationView
    }
}
