//
//  MapViewManager.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 24/07/2023.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class CKMapViewManager: NSObject, MKMapViewDelegate {
    private weak var mapView: MKMapView?
    
    init(mapView: MKMapView) {
        self.mapView = mapView
        super.init()
    }
        
    func drawCoordinates(_ coordinates: [CLLocationCoordinate2D], animated: Bool) {
        if coordinates.count < 2 { return }
        
        guard let mapView = mapView else { return }
        mapView.removeOverlays(mapView.overlays)
        
        if !animated {
            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: coordinates.count))
            return
        }
        
        let animationDuration = 0.5
        var totalDistance: Double = 0
        var distances: [Double] = []
        let totalSteps = coordinates.count - 1

        for i in 0..<totalSteps {
            distances.append(CKMapUtility.getDistanceBetweenCoordinates(coordinates[i], coordinates[i + 1]))
            totalDistance += distances[i]
        }
        
        let stepTimeIntervals = distances
            .map { distance in
            return animationDuration * distance / totalDistance
        }
        
        var counter = 0
        var currentTime: Double = 0
        var nextTime: Double = stepTimeIntervals[counter]
        let timeInterval = 0.005
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: counter < totalSteps) { timer in
            if counter == totalSteps {
                timer.invalidate()
            } else {
                if (currentTime >= nextTime) {
                    let subCoordinates = [coordinates[counter], coordinates[counter + 1]]
                    mapView.addOverlay(MKPolyline(coordinates: subCoordinates, count: 2))
                    counter += 1
                    if counter < totalSteps {
                        nextTime += stepTimeIntervals[counter]
                    }
                }
                currentTime += timeInterval
            }
        }
    }
    
    func drawPolyline(_ polyline: MKPolyline) {
        guard let mapView = mapView else { return }
        mapView.addOverlay(polyline)
    }
    
    func clearMapView() {
        guard let mapView = mapView else { return }
        mapView.removeOverlays(mapView.overlays)
        removeCheckpointAnnotations()
    }
    
    func removeCheckpointAnnotations() {
        guard let mapView = mapView else { return }
        mapView.removeAnnotations(mapView.annotations.filter { $0 is CKCheckpointAnnotation })
    }
    
    func addCheckpointAnnotation(_ coordinate: CLLocationCoordinate2D, kind: CKCheckpointAnnotation.Kind) {
        guard let mapView = mapView else { return }
        mapView.addAnnotation(CKCheckpointAnnotation(coordinate: coordinate, kind: kind))
    }

    func centerToLocation(_ location: CLLocation, regionRadius: Double = 400, animated: Bool = true) {
        guard let mapView = mapView else { return }
        
        let coordinateRegion = MKCoordinateRegion(
          center: location.coordinate,
          latitudinalMeters: regionRadius,
          longitudinalMeters: regionRadius
        )
        
        mapView.setRegion(coordinateRegion, animated: animated)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is CKLocationAnnotation {
            guard let locationAnnotation = annotation as? CKLocationAnnotation else { fatalError() }
            
            return locationAnnotation.getView()
        } else if annotation is CKCheckpointAnnotation {
            guard let checkpointAnnotation = annotation as? CKCheckpointAnnotation else { fatalError() }
            
            return checkpointAnnotation.getView()
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 142/255.0, green: 126/255.0, blue: 255/255.0, alpha: 1)
        renderer.lineWidth = 10.0
        
        return renderer
    }
}
