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
    private(set) var currentRoute: MKRoute?
    private var routeCoordinates: [CLLocationCoordinate2D]?
    
    private var completedCoordinates: Int
    private var currentStep: Int
    private var stepsIndex: [Int]
    private var isNavigating: Bool
    private var isFollowingCurrentLocation: Bool
    var delegate: JourneyDelegate?

    let locationManager: CLLocationManager
    
    private final let mapViewManager: MapViewManager
    
    private(set) var origin: CLLocationCoordinate2D?
    private(set) var destination: CLLocationCoordinate2D?
    private var lastLocation: CLLocationCoordinate2D?
    
    typealias SetRouteCompletion = () -> Void
    typealias UpdateRouteCompletion = () -> Void
    
    init(mapViewManager: MapViewManager, locationManager: CLLocationManager) {
        self.mapViewManager = mapViewManager
        self.completedCoordinates = 0
        self.currentStep = 0
        self.stepsIndex = []
        self.isNavigating = false
        self.isFollowingCurrentLocation = true
        self.locationManager = locationManager
    }
    
    func setRoute(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, completion: SetRouteCompletion?) {
        self.origin = origin
        self.destination = destination
        print("updated origin and destination")
        print("origin: \(self.origin!)")
        updateRoute(isCurrentLocationOrigin: false, completion: completion)
    }
    
    func launchAppleMapsWithCurrentRoute(kind: CheckpointAnnotation.Kind) {
        guard let destination = destination else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        mapItem.name = "Approx. \(kind.rawValue.capitalized) Location"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    enum PreviewType {
        case requestPreview
        case travelPreview
    }
    
    func showRoutePreview(ofType previewType: PreviewType) {
        isFollowingCurrentLocation = false
        guard let origin = origin, let destination = destination else { return }
        
        guard let routeCoordinates = routeCoordinates else { return }
        mapViewManager.removeCheckpointAnnotations()
        
        if previewType == .requestPreview {
            mapViewManager.addCheckpointAnnotation(origin, kind: .pickup)
            mapViewManager.addCheckpointAnnotation(destination, kind: .dropoff)
        } else {
            mapViewManager.addCheckpointAnnotation(destination, kind: .destination)
        }
        
        mapViewManager.drawCoordinates(routeCoordinates, animated: true)
        
        var latitude = (origin.latitude + destination.latitude) / 2
        if previewType == .requestPreview {
            latitude -= MapUtility.getDegreesBetweenCoordinates(origin, destination) / 2
        }
        let longitude = (origin.longitude + destination.longitude) / 2
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        mapViewManager.centerToLocation(location, regionRadius: MapUtility.getDistanceBetweenCoordinates(origin, destination))
    }
    
    private func updateRoute(isCurrentLocationOrigin: Bool, completion: UpdateRouteCompletion?) {
        guard let destination = destination else { return }
        
        let request = MKDirections.Request()
        
        if isCurrentLocationOrigin {
            guard let currentLocation = lastLocation else { return }
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation))
        } else {
            guard let origin = origin else { return }
            print("Xrigin: \(origin)")
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
            self.stepsIndex = []
            for i in 0..<retrievedRoute.polyline.pointCount {
                let point: MKMapPoint = points[i]
                self.routeCoordinates!.append(point.coordinate)
            }
            
            let _ = retrievedRoute
                .steps
                .map { $0.polyline.pointCount - 1 }
                .publisher
                .scan(0) { a, b in a + b }
                .sink { self.stepsIndex.append($0) }
            
            completion?()
        }
    }
    
    func beginNavigation(shouldFollowCurrentLocation: Bool = true) {
        if destination == nil {
            fatalError()
        }
        isNavigating = true
        completedCoordinates = 1
        currentStep = 1
        
        updateRoute(isCurrentLocationOrigin: true) { [unowned self] in
            guard let routeCoordinates = routeCoordinates else { return }
            mapViewManager.drawCoordinates(routeCoordinates, animated: false)
            
            if let currentRoute = currentRoute {
                delegate?.journeyDidBeginStep(currentRoute.steps[currentStep])
            }
        }
        
        if shouldFollowCurrentLocation {
            startFollowingCurrentLocation()
        }
    }
    
    func startFollowingCurrentLocation() {
        isFollowingCurrentLocation = true
        guard let currentLocation = locationManager.location else { return }
        mapViewManager.centerToLocation(currentLocation)
    }
    func stopFollowingCurrentLocation() {
        isFollowingCurrentLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("--locationManager: didUpdateLocations--")
        guard let currentLocation = locations.last else { return }
        mapViewManager.updateCurrentLocation(currentLocation.coordinate)
        
        if isFollowingCurrentLocation {
            mapViewManager.centerToLocation(currentLocation)
        }
        
        guard let previousLocation = self.lastLocation else {
            self.lastLocation = currentLocation.coordinate
            return
        }
        
        self.lastLocation = currentLocation.coordinate
        
        if isNavigating {
            print("---navigation step---")
            print("  completedSteps: \(completedCoordinates)")
            guard let routeCoordinates = routeCoordinates else { return }
            if routeCoordinates.count < 2 { return }
            
            func redrawFromCurrentStep() {
                var newArray = Array(routeCoordinates[completedCoordinates..<routeCoordinates.count])
                newArray.insert(currentLocation.coordinate, at: 0)
                mapViewManager.drawCoordinates(newArray, animated: false)
            }
            
            let stepOrigin = routeCoordinates[completedCoordinates - 1]
            let stepDestination = routeCoordinates[completedCoordinates]
            
            if MapUtility.getDistanceBetweenCoordinates(stepDestination, currentLocation.coordinate) < 25 {
                print("  arrived at next checkpoint")
                completedCoordinates += 1
                
                if completedCoordinates == routeCoordinates.count {
                    print("  arrived at destination")
                    isNavigating = false
                    mapViewManager.clearMapView()
                    delegate?.journeyDidCompleteAtDestination(destination!)
                    return
                }
                
                if completedCoordinates >= stepsIndex[currentStep] {
                    currentStep += 1
                    if let step = currentRoute?.steps[currentStep] {
                        delegate?.journeyDidBeginStep(step)
                    }
                }
                
                redrawFromCurrentStep()
                return
            }
            
            let stepOriginDelta = MapUtility.getDistanceBetweenCoordinates(currentLocation.coordinate, stepOrigin)
                - MapUtility.getDistanceBetweenCoordinates(previousLocation, stepOrigin)
            let stepDestinationDelta = MapUtility.getDistanceBetweenCoordinates(currentLocation.coordinate, stepDestination)
                - MapUtility.getDistanceBetweenCoordinates(previousLocation, stepDestination)
            print("  Δ origin: \(stepOriginDelta)")
            print("  Δ destin: \(stepDestinationDelta)")
            
            if stepDestinationDelta < 0 {
                print("  headed in the right direction")
                // headed in the right direction
                redrawFromCurrentStep()
            } else if stepDestinationDelta > 0 || stepOriginDelta < 0 {
                print("  headed in the wrong direction")
                beginNavigation(shouldFollowCurrentLocation: false)
            }
        }
    }
}
