//
//  CheckpointAnnotation.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 25/07/2023.
//

import Foundation
import MapKit

class CheckpointAnnotation: NSObject, MKAnnotation {
    static let identifier = "CheckpointAnnotation"
    let coordinate: CLLocationCoordinate2D
    let title: String?
    private let kind: Kind
    
    init(coordinate: CLLocationCoordinate2D, kind: Kind) {
        self.coordinate = coordinate
        self.title = kind.rawValue
        self.kind = kind
    }
    
    func getView() -> MKMarkerAnnotationView {
        let annotationView = MKMarkerAnnotationView(annotation: self, reuseIdentifier: CheckpointAnnotation.identifier)
        annotationView.animatesWhenAdded = true
        if kind == .pickup {
            annotationView.glyphImage = UIImage(systemName: "arrow.up")
        } else {
            annotationView.glyphImage = UIImage(systemName: "arrow.down")
        }
        annotationView.markerTintColor = .darkGray
        annotationView.glyphTintColor = .white
        
        
        return annotationView
    }
    
    enum Kind: String {
        case pickup
        case dropoff
    }
}
