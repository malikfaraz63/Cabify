//
//  DriverAnnotationsManager.swift
//  CabifyRider
//
//  Created by Faraz Malik on 17/08/2023.
//

import Foundation
import MapKit

class DriverAnnotationsManager {
    private weak var mapView: MKMapView?
    var driverAnnotations: [String: CKDriverAnnotation]
    
    init(mapView: MKMapView) {
        self.driverAnnotations = [:]
        self.mapView = mapView
    }
    
    public func updateDriverLocation(withDriverId driverId: String, location: CKCoordinate) {
        guard let mapView = mapView else { return }

        if driverAnnotations[driverId] == nil {
            let annotation = CKDriverAnnotation(coordinate: CLLocationCoordinate2D(from: location))
            driverAnnotations[driverId] = annotation
            mapView.addAnnotation(annotation)
        } else {
            UIView.animate(withDuration: 1.0) {
                self.driverAnnotations[driverId]!.coordinate = CLLocationCoordinate2D(from: location)
            }
        }
    }
    
    public func updateDriverLocation(_ driver: CKDriver) {
        guard let driverLocation = driver.location?.coordinate else { return }
        updateDriverLocation(withDriverId: driver.driverId, location: driverLocation)
    }
    
    public func removeAllDrivers() {
        print("--DriverAnnotationsManager.removeAllDrivers--")
        guard let mapView = mapView else { return }
        for (driverId, driverAnnotation) in driverAnnotations {
            print("called for \(driverId)")
            mapView.removeAnnotation(driverAnnotation)
        }
        driverAnnotations.removeAll()
    }
    
    public func removeDriver(_ driverId: String) {
        if driverAnnotations[driverId] == nil { return }
        
        guard let mapView = mapView else { return }
        mapView.removeAnnotation(driverAnnotations[driverId]!)
        driverAnnotations.removeValue(forKey: driverId)
    }
    
    public func removeDriver(_ driver: CKDriver) {
        removeDriver(driver.driverId)
    }
}
