//
//  JourneyManager.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 25/07/2023.
//

import Foundation
import MapKit
import CoreLocation

class JourneyManager: NSObject, CLLocationManagerDelegate {
    private var currentRoute: MKRoute?
    private var routeCoordinates: [CLLocationCoordinate2D]?
    
    private var completedSteps: Int
    private var isNavigating: Bool
    private var isFollowingCurrentLocation: Bool
    var delegate: JourneyDelegate?

    let locationManager: CLLocationManager
    
    private final let mapViewManager: MapViewManager
    
    private var origin: CLLocationCoordinate2D?
    private var destination: CLLocationCoordinate2D?
    private var currentLocation: CLLocationCoordinate2D?
    
    typealias SetRouteCompletion = () -> Void
    typealias UpdateRouteCompletion = () -> Void
    
    init(mapViewManager: MapViewManager, locationManager: CLLocationManager) {
        self.mapViewManager = mapViewManager
        self.completedSteps = 0
        self.isNavigating = false
        self.isFollowingCurrentLocation = true
        self.locationManager = locationManager
    }
    
    func setRoute(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, completion: SetRouteCompletion?) {
        self.origin = origin
        self.destination = destination
        
        updateRoute(isCurrentLocationOrigin: false, completion: completion)
    }
    
    func showRoutePreview() {
        isFollowingCurrentLocation = false
        guard let origin = origin, let destination = destination else { return }
        
        guard let routeCoordinates = routeCoordinates else { return }
        mapViewManager.removeCheckpointAnnotations()
        mapViewManager.showCheckpointAnnotation(origin, kind: .pickup)
        mapViewManager.showCheckpointAnnotation(destination, kind: .dropoff)
        mapViewManager.drawCoordinates(routeCoordinates, animated: true)
        
        let latitude = (origin.latitude + destination.latitude) / 2 - MapUtility.getDegreesBetweenCoordinates(origin, destination) / 2
        let longitude = (origin.longitude + destination.longitude) / 2
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        mapViewManager.centerToLocation(location, regionRadius: MapUtility.getDistanceBetweenCoordinates(origin, destination))
    }
    
    private func updateRoute(isCurrentLocationOrigin: Bool, completion: UpdateRouteCompletion?) {
        guard let destination = destination else { return }
        
        let request = MKDirections.Request()
        
        if isCurrentLocationOrigin {
            guard let currentLocation = currentLocation else { return }
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation))
        } else {
            guard let origin = origin else { return }
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        }
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let response = response else { return }
            guard let retrievedRoute = response.routes.first else { return }
            
            let points = retrievedRoute.polyline.points()
            self.currentRoute = retrievedRoute
            self.routeCoordinates = []
            for i in 0..<retrievedRoute.polyline.pointCount {
                let point: MKMapPoint = points[i]
                self.routeCoordinates!.append(point.coordinate)
            }
            completion?()
        }
    }
    
    func beginNavigation() {
        if destination == nil {
            fatalError()
        }
        isNavigating = true
        completedSteps = 0
        updateRoute(isCurrentLocationOrigin: true) { [unowned self] in
            guard let routeCoordinates = routeCoordinates else { return }
            mapViewManager.drawCoordinates(routeCoordinates, animated: false)
        }
        
        startFollowingCurrentLocation()
    }
    
    func startFollowingCurrentLocation() {
        isFollowingCurrentLocation = true
    }
    func stopFollowingCurrentLocation() {
        isFollowingCurrentLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        self.currentLocation = currentLocation.coordinate
        mapViewManager.updateCurrentLocation(self.currentLocation!)
        if isFollowingCurrentLocation {
            mapViewManager.centerToLocation(currentLocation, regionRadius: 300)
        }
        
        if isNavigating {
            guard let previousLocation = locations.first else { return }
            guard let routeCoordinates = routeCoordinates else { return }
            if routeCoordinates.count < 2 { return }
            
            if completedSteps == (routeCoordinates.count - 1) {
                isNavigating = false
                
                delegate?.journeyDidCompleteAtDestination(destination!)
                return
            }
            
            let stepOrigin = routeCoordinates[completedSteps - 1]
            let stepDestination = routeCoordinates[completedSteps]
            
            if MapUtility.getDistanceBetweenCoordinates(stepDestination, currentLocation.coordinate) < 25 {
                completedSteps += 1
                mapViewManager.drawCoordinates(Array(routeCoordinates[completedSteps..<routeCoordinates.count]), animated: false)
                return
            }
            
            let stepOriginDelta = MapUtility.getDistanceBetweenCoordinates(currentLocation.coordinate, stepOrigin)
                - MapUtility.getDistanceBetweenCoordinates(previousLocation.coordinate, stepOrigin)
            let stepDestinationDelta = MapUtility.getDistanceBetweenCoordinates(currentLocation.coordinate, stepDestination)
                - MapUtility.getDistanceBetweenCoordinates(previousLocation.coordinate, stepDestination)
            
            if stepOriginDelta > 0 && stepDestinationDelta < 0 {
                // we're in the right direction...?
            }
        }
    }
}
