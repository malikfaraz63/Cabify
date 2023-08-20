//
//  CKLocationAnnotation.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 25/07/2023.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class CKLocationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func getView() -> MKAnnotationView {
        let annotationView = MKAnnotationView(annotation: self, reuseIdentifier: "LocationAnnotation")
        annotationView.isUserInteractionEnabled = false

        annotationView.tintColor = .systemBlue
        annotationView.image = UIImage(named: "location")!

        annotationView.frame.size = CGSize(width: 30, height: 30)
        annotationView.clipsToBounds = true

        return annotationView
    }
}
