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
        if kind != .destination {
            self.title = kind.rawValue
        } else {
            self.title = nil
        }
        self.kind = kind
    }
    
    func getView() -> MKMarkerAnnotationView {
        let annotationView = MKMarkerAnnotationView(annotation: self, reuseIdentifier: CheckpointAnnotation.identifier)
        annotationView.animatesWhenAdded = true
        if kind == .pickup {
            annotationView.glyphImage = UIImage(systemName: "arrow.up")
        } else if kind == .dropoff {
            annotationView.glyphImage = UIImage(systemName: "arrow.down")
        } else {
            annotationView.glyphImage = UIImage(systemName: "flag.checkered.2.crossed")
        }
        annotationView.markerTintColor = .darkGray
        annotationView.glyphTintColor = .white
        
        print("--DID GET CHECKPOINT VIEW--")
        
        return annotationView
    }
    
    enum Kind: String {
        case pickup
        case dropoff
        case destination
    }
}
