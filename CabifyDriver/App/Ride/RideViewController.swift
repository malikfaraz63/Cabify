//
//  RideViewController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 24/07/2023.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class RideViewController: UIViewController, CLLocationManagerDelegate, JourneyDelegate, PendingRequestDelegate {
    
    @IBOutlet weak var goOnlineConstraint: NSLayoutConstraint!
    @IBOutlet weak var goOnlineButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var pendingRequestContainer: UIView!
    @IBOutlet weak var pendingRequestConstraint: NSLayoutConstraint!
    @IBOutlet weak var followLocationConstraint: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    let requestClient = RequestClient()
    var locationManager = CLLocationManager()

    var journeyManager: JourneyManager?
    var mapViewManager: MapViewManager?
    var pendingRequestController: PendingRequestController?
    
    var previousUserId: String?
    
    var rideViewStatus = RideViewStatus.offline
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goOnlineButton.isEnabled = false
        
        mapViewManager = MapViewManager(mapView: mapView)
        mapViewManager!.centerToLocation(CLLocation(latitude: 51.5154, longitude: -0.1411), animated: false)
        journeyManager = JourneyManager(mapViewManager: mapViewManager!, locationManager: locationManager)
        journeyManager?.delegate = self
        checkLocationAuthorizationStatus()
        locationManager.delegate = self
                
        goOnlineButton.clipsToBounds = true
        goOnlineButton.layer.cornerRadius = goOnlineButton.layer.frame.width / 2
        
        pendingRequestContainer.isHidden = true
        pendingRequestContainer.clipsToBounds = true
        pendingRequestContainer.layer.cornerRadius = 10
        
        let blurEffect: UIBlurEffect
        if traitCollection.userInterfaceStyle == .light {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        } else {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = statusView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        statusView.addSubview(blurEffectView)
        statusView.sendSubviewToBack(blurEffectView)
        
        print("Hash: \(MapUtility.generateHashForCoordinate(GeoPoint(latitude: 51.5686, longitude: 0.08484)))")

        viewDidAppear(true)
    }
    
    @IBAction func startFollowingCurrentLocation() {
        guard let journeyManager = journeyManager else { return }
        journeyManager.startFollowingCurrentLocation()
    }
    
    func showSettingsAlert() {
        let alertController = UIAlertController(title: "Location Services Denied", message: "Allow location access to receive local ride requests and use navigation.", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl) { success in
                    // do success...?
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        goOnlineButton.isEnabled = false
        
        switch locationManager.authorizationStatus {
        case .denied:
            showSettingsAlert()
            statusLabel.text = "Location Services Denied"
            return
        default:
            // dunno...
            print("Not sure...shouldn't have happened")
        }
        
        if DriverSettingsManager.hasUser() {
            if let previousUserId = previousUserId {
                if previousUserId == DriverSettingsManager.getUserID() {
                    goOnlineButton.isEnabled = true
                } else {
                    setupForDriver()
                }
            } else {
                setupForDriver()
            }
        } else {
            statusLabel.text = "User not found"
        }
    }
    
    func setupForDriver() {
        previousUserId = DriverSettingsManager.getUserID()
        
        statusLabel.text = "You're offline"
        goOnlineButton.isEnabled = true
    }
    
    func checkLocationAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("Authorization required")
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            goOnlineButton.isEnabled = true
        default:
            print("Dunno...")
        }
    }
    
    func hideRequestContainer() {
        pendingRequestConstraint.constant = -400
        followLocationConstraint.constant = 30
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showRequestContainer(_ pendingRequest: PendingRequest) {
        pendingRequestContainer.isHidden = false
        pendingRequestConstraint.constant = 30
        followLocationConstraint.constant = pendingRequestConstraint.constant + 16 + pendingRequestContainer.frame.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        guard let location = locationManager.location?.coordinate else { return }
        let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        
        guard let pendingRequestController = pendingRequestController else { return }
        pendingRequestController.showRequest(fromCurrentLocation: geoPoint, request: pendingRequest)
    }
    
    func hideGoOnlineButton() {
        goOnlineButton.isEnabled = false
        goOnlineConstraint.constant = -250
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showGoOnlineButton() {
        goOnlineButton.isEnabled = true
        goOnlineConstraint.constant = 30
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func driverDidGoOnline() {
        rideViewStatus = .online
        statusLabel.text = "You're online"
        hideGoOnlineButton()
    }
    
    @IBAction func goOnline() {
        guard let uid = DriverSettingsManager.getUserID() else { return }
        goOnlineButton.isEnabled = false

        let data: [String: Any] = ["isOnline": true]
        
        db
            .collection("drivers")
            .document(uid)
            .updateData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.driverDidGoOnline()
                }
            }
    }
    
    // MARK: Journey Delegate
    
    func journeyDidCompleteAtDestination(_ destination: CLLocationCoordinate2D) {
        
    }
    
    // MARK: Location Delegate
    
    func handlePendingRequests(_ pendingRequests: [PendingRequest]) {
        print("ok... at handlePendingRequests")
        if rideViewStatus == .viewingPendingRequest { return }
        print("status was online")
        if pendingRequests.isEmpty { return }
        print("pending requests weren't empty")
        guard let journeyManager = journeyManager else { return }
        print("made pase null checks")
        
        let request = pendingRequests.first!
        
        
        rideViewStatus = .viewingPendingRequest
        
        journeyManager.setRoute(origin: CLLocationCoordinate2D(from: request.origin.coordinate), destination: CLLocationCoordinate2D(from: request.destination)) {
            journeyManager.showRoutePreview()
            self.showRequestContainer(request)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let journeyManager = journeyManager else { return }
        journeyManager.stopFollowingCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let journeyManager = journeyManager else { return }
        journeyManager.locationManager(manager, didUpdateLocations: locations)
        
        if rideViewStatus == .offline { return }
        
        guard let uid = DriverSettingsManager.getUserID() else { return }
        guard locations.count > 0 else { return }
        let newLocation = locations.last!
        
        let hash = MapUtility.generateHashForCoordinate(GeoPoint(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude))
        
        let data: [String: Any] = [
            "location.coordinate": GeoPoint(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude),
            "location.hash": hash,
            "lastUpdated": newLocation.timestamp
        ]
        db
            .collection("drivers")
            .document(uid)
            .updateData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        
        requestClient.setRequestListener(atLocation: newLocation.coordinate, radius: 2500, whenTriggered: handlePendingRequests)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            print("Authorization required")
        default:
            print("Dunno")
        }
    }
    
    // MARK: Request Delegate
    
    func didTryToAcceptRequest(_ request: PendingRequest) {
        print("\n-------\ntried to accept")
    }
    
    func requestTimedOut(_ request: PendingRequest) {
        rideViewStatus = .online
        guard let pendingRequestController = pendingRequestController else { return }
        pendingRequestController.clearView()
        hideRequestContainer()
        
        guard let mapViewManager = mapViewManager else { return }
        mapViewManager.clearMapView()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueTag.embedPendingRequest.rawValue {
            guard let pendingRequestController = segue.destination as? PendingRequestController else { return }
            pendingRequestController.delegate = self
            self.pendingRequestController = pendingRequestController
        }
    }
}

enum RideViewStatus {
    case offline
    case online
    case viewingPendingRequest
    case travellingToPickup
    case waitingAtPickup
    case travellingToDropoff
}
