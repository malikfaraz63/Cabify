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
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class RideViewController: UIViewController, CLLocationManagerDelegate, CKJourneyDelegate, PendingRequestDelegate, JourneyPreviewDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var goOnlineConstraint: NSLayoutConstraint!
    @IBOutlet weak var launchNavigationConstraint: NSLayoutConstraint!
    @IBOutlet weak var followLocationConstraint: NSLayoutConstraint!
    @IBOutlet weak var journeyViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var requestMessagesBadge: UILabel!
    @IBOutlet weak var showRequestMessagesButton: UIButton!
    @IBOutlet weak var goOnlineButton: UIButton!
    @IBOutlet weak var followLocationButton: UIButton!
    @IBOutlet weak var launchNavigationButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var journeyView: UIView!
    
    @IBOutlet weak var journeyPreviewView: UIView!
    @IBOutlet weak var journeyPreviewSummaryLabel: UILabel!
    @IBOutlet weak var journeyPreviewTimeLabel: UILabel!
    @IBOutlet weak var journeyPreviewDistanceLabel: UILabel!
    
    @IBOutlet weak var journeyOngoingView: UIView!
    @IBOutlet weak var journeyStepSummaryLabel: UILabel!
    @IBOutlet weak var journeyStepDistanceLabel: UILabel!
    @IBOutlet weak var journeyStepNoticeStack: UIStackView!
    @IBOutlet weak var journeyStepNoticeLabel: UILabel!
    
    @IBOutlet weak var riderCountdownView: UIView!
    @IBOutlet weak var riderCountdownTimerLabel: UILabel!
    @IBOutlet weak var riderCountdownUpdateLabel: UILabel!
    
    @IBOutlet weak var notificationStack: UIStackView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var rideStatusView: UIView!
    @IBOutlet weak var rideStatusButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var pendingRequestContainer: UIView!
    @IBOutlet weak var pendingRequestConstraint: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    let requestClient = RequestClient()
    let rideClient = RideClient()
    let locationManager = CLLocationManager()
    var previousUnread = 0

    var journeyManager: CKJourneyManager?
    var mapViewManager: CKMapViewManager?
    var pendingRequestController: PendingRequestController?
    
    var previousUserId: String?
    
    var driverStatus = DriverStatus.offline
    
    override func viewDidLoad() {
        if Auth.auth().currentUser?.uid == nil {
            print("\n\n----USER LOGGED OUT----\n\n")
        }
        
        super.viewDidLoad()
        goOnlineButton.isEnabled = false
        
        mapViewManager = CKMapViewManager(mapView: mapView)
        mapViewManager!.centerToLocation(CLLocation(latitude: 51.517651, longitude: -0.102968), regionRadius: 3000, animated: false)
        journeyManager = CKJourneyManager(mapViewManager: mapViewManager!, locationManager: locationManager)
        mapView.delegate = mapViewManager
        journeyManager?.delegate = self
        checkLocationAuthorizationStatus()
        locationManager.delegate = self
        
        pendingRequestContainer.isHidden = true
        pendingRequestContainer.layer.cornerRadius = 10
        pendingRequestContainer.clipsToBounds = true
        
        requestMessagesBadge.layer.cornerRadius = requestMessagesBadge.frame.height / 2
        requestMessagesBadge.clipsToBounds = true
        requestMessagesBadge.isHidden = true
        
        showRequestMessagesButton.isHidden = true
        journeyView.layer.cornerRadius = 20
        journeyView.clipsToBounds = true
        
        
        let blurEffect: UIBlurEffect
        if traitCollection.userInterfaceStyle == .light {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        } else {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = statusStackView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        statusStackView.addSubview(blurEffectView)
        statusStackView.sendSubviewToBack(blurEffectView)
        
        hideDefaultNavigateButton()
        
        tryRejoiningPreviousSession { rejoinWasSuccessful in
            if !rejoinWasSuccessful {
                self.viewDidAppear(true)
            }
        }
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
    
    @IBAction func startFollowingCurrentLocation() {
        guard let journeyManager = journeyManager else { return }
        journeyManager.startFollowingCurrentLocation()
        UIView.animate(withDuration: 0.5) {
            self.followLocationButton.alpha = 0.0
        }
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
    
    // MARK: View Maintenance
    
    func showNotificationView() {
        notificationConstraint.constant = 70
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func hideNotificationView() {
        notificationConstraint.constant = -100
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showDefaultNavigateButton() {
        launchNavigationButton.isEnabled = true
        launchNavigationConstraint.constant = 30
        followLocationConstraint.constant = 90
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideDefaultNavigateButton() {
        launchNavigationConstraint.constant = -250
        followLocationConstraint.constant = 30
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideRequestContainer(_ completion: (() -> Void)? = nil) {
        pendingRequestConstraint.constant = -500
        followLocationConstraint.constant = 30
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { isComplete in
            if isComplete {
                completion?()
            }
        }
    }
    
    func showRequestContainer(withRequest request: PendingRequest, completion: (() -> Void)? = nil) {
        pendingRequestContainer.isHidden = false
        
        pendingRequestConstraint.constant = 30
        followLocationConstraint.constant = 30 + 16 + self.pendingRequestContainer.frame.height
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
        guard let location = locationManager.location?.coordinate else { return }
        let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        
        guard let pendingRequestController = pendingRequestController else { return }
        pendingRequestController.showRequest(fromCurrentLocation: geoPoint, request: request)
    }
    
    func hideRideStatusButton() {
        rideStatusView.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showRideStatusButton() {
        rideStatusView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideGoOnlineButton() {
        goOnlineConstraint.constant = -300
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
    
    func hideJourneyView() {
        journeyViewConstraint.constant = -300
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showJourneyView() {
        journeyViewConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showJourneyPreview() {
        if driverStatus != .previewingPickup(request: nil) && driverStatus != .previewingDropoff(ride: nil) { return }
        
        guard let journeyManager = journeyManager else { return }
        guard let currentRoute = journeyManager.currentRoute else { return }
        CKRouteSummaryClient.getRouteSummary(fromOrigin: journeyManager.origin!, destination: journeyManager.destination!, units: .imperial) { summary in
            let string = String(summary.destinationAddress.split(separator: ",").first!)
            if self.driverStatus == .previewingPickup(request: nil) {
                self.journeyPreviewSummaryLabel.text = "Pickup: " + string
            } else {
                self.journeyPreviewSummaryLabel.text = "Dropoff: " + string
            }
        }
        var travelTime = Int(currentRoute.expectedTravelTime)
        var travelString = ""
        if (travelTime / 3600) > 0 {
            travelString += "\(travelTime / 3600) h "
            travelTime = travelTime % 3600
        }
        travelString += "\(travelTime / 60) min"
        journeyPreviewTimeLabel.text = travelString
        
        
        if currentRoute.distance < 300 {
            journeyPreviewDistanceLabel.text = "\(currentRoute.distance) m"
        } else {
            journeyPreviewDistanceLabel.text = String(format: "%.1f mi", Double(currentRoute.distance) / 1600)
        }
        
        journeyPreviewView.isHidden = false
        journeyOngoingView.isHidden = true
    }
    
    func showJourneyOngoing() {
        journeyOngoingView.isHidden = false
        journeyPreviewView.isHidden = true
    }
    
    // MARK: Driver Status
    
    func updateViewForDriverStatusChange() {
        switch driverStatus {
        case .offline:
            showRequestMessagesButton.isHidden = true
            riderCountdownView.isHidden = true
            hideJourneyView()
            statusLabel.isHidden = false
            statusLabel.text = "You're offline"
            showGoOnlineButton()
        case .ready:
            showRequestMessagesButton.isHidden = true
            riderCountdownView.isHidden = true
            hideJourneyView()
            statusLabel.text = "Ready"
            hideGoOnlineButton()
            hideDefaultNavigateButton()
        case .viewingPendingRequest:
            requestClient.removePendingRequestsListener()
            riderCountdownView.isHidden = true
            showRequestMessagesButton.isHidden = true
            hideJourneyView()
            statusLabel.text = "Ride detected"
        case .previewingPickup:
            hideGoOnlineButton()
            showRequestMessagesButton.isHidden = false
            showJourneyPreview()
            showJourneyView()
            showDefaultNavigateButton()
            statusLabel.text = "Ride accepted"
        case .travellingToPickup:
            statusLabel.text = "Travelling to pickup"
            showJourneyOngoing()
        case .waitingAtPickup:
            hideGoOnlineButton()
            riderCountdownView.isHidden = false
            statusLabel.isHidden = true
            hideJourneyView()
            hideDefaultNavigateButton()
            showRideStatusButton()
        case .previewingDropoff:
            hideGoOnlineButton()
            showRequestMessagesButton.isHidden = true
            riderCountdownView.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "Previewing dropoff"
            showJourneyPreview()
            showDefaultNavigateButton()
            showJourneyView()
            hideRideStatusButton()
            break
        case .travellingToDropoff:
            statusLabel.text = "Travelling to dropoff"
            showJourneyOngoing()
            break
        }
    }
    
    func driverDidGoOnline() {
        showNotification(ofType: .info, message: "Successfully went online!", isPersistent: false)
        driverStatus = .ready
        updateViewForDriverStatusChange()
    }
    
    @IBAction func goOnline() {
        print("--RideViewController.goOnline--")
        guard let uid = DriverSettingsManager.getUserID() else { return }
        print(" - got uid")
        let data: [String: Any] = ["isOnline": true]
        
        db
            .collection("drivers")
            .document(uid)
            .updateData(data) { error in
                print(" - callback called")
                if let error = error {
                    print(" - error")
                    print(error.localizedDescription)
                } else {
                    print(" - going online...")
                    self.driverDidGoOnline()
                }
            }
    }
    
    @IBAction func launchNavigation() {
        let kind: CKCheckpointAnnotation.Kind
        switch driverStatus {
        case .previewingPickup(_):
            kind = .pickup
        case .travellingToPickup(_):
            kind = .pickup
        case .previewingDropoff:
            kind = .dropoff
        case .travellingToDropoff:
            kind = .dropoff
        default:
            return
        }
        
        guard let journeyManager = journeyManager else { return }
        journeyManager.launchAppleMapsWithCurrentRoute(kind: kind)
    }
    
    @IBAction func beginNavigation() {
        switch driverStatus {
        case .previewingPickup(let request):
            driverStatus = .travellingToPickup(request: request)
        case .previewingDropoff(let ride):
            driverStatus = .travellingToDropoff(ride: ride)
        default:
            return
        }
        updateViewForDriverStatusChange()
        
        guard let journeyManager = journeyManager else { return }
        journeyManager.beginNavigation()
    }
    
    // MARK: Notification
    
    enum NotificationType {
        case success
        case warning
        case info
        case error
    }
    func showNotification(ofType type: NotificationType, message: String, isPersistent: Bool) {
        switch type {
        case .success:
            notificationStack.backgroundColor = .systemGreen
        case .warning:
            notificationStack.backgroundColor = .systemOrange
        case .info:
            notificationStack.backgroundColor = .systemTeal
        case .error:
            notificationStack.backgroundColor = .systemRed
        }
        notificationLabel.text = message

        showNotificationView()
        
        if isPersistent {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.hideNotificationView()
        }
    }
    
    @IBAction func dismissNotification() {
        hideNotificationView()
    }

    
    // MARK: Journey Delegate
    
    func journeyDidBeginStep(_ step: MKRoute.Step) {
        print("--journeyDidCompleteStep--")
        print("  " + step.instructions)
        if let notice = step.notice {
            journeyStepNoticeStack.isHidden = false
            journeyStepNoticeLabel.text = notice
        } else {
            journeyStepNoticeStack.isHidden = true
        }
        
        journeyStepSummaryLabel.text = step.instructions
        
        if step.distance < 300 {
            journeyStepDistanceLabel.text = "\(Int(step.distance)) m"
        } else {
            journeyStepDistanceLabel.text = String(format: "%.1f mi", Double(step.distance) / 1600)
        }
    }
    
    func journeyDidCompleteAtDestination(_ destination: CLLocationCoordinate2D) {
        if driverStatus != .travellingToPickup(request: nil) && driverStatus != .travellingToDropoff(ride: nil) {
            return
        }
        
        showDefaultNavigateButton()
        
        switch driverStatus {
        case .travellingToPickup(let request):
            guard let request = request, let requestId = request.documentID else { return }
            requestClient.updateRequestAsCompleted(withRequestId: requestId) { [unowned self] requestWasUpdated in
                if requestWasUpdated {
                    rideClient.createRide(fromRequest: request) { ride in
                        self.showNotification(ofType: .info, message: "Arrived at pickup!", isPersistent: false)
                        self.didArriveAtPickup(ride)
                    }
                }
            }
        case .travellingToDropoff(let ride):
            guard let rideId = ride?.rideId else { return }
            guard let cost = ride?.cost else { return }
            let costString = String(format: "£%.2f", cost)
            rideClient.updateRideAsCompleted(withRideId: rideId) { [unowned self] updateWasSuccessful in
                if updateWasSuccessful {
                    showNotification(ofType: .success, message: "Ride completed, earned \(costString)!", isPersistent: false)
                    rideClient.transferMoney(forCompletedRideId: rideId)
                    driverStatus = .ready
                    updateViewForDriverStatusChange()
                }
            }
        default: break
        }
    }
    
    // MARK: Journey Preview Delegate
    
    
    func journeyPreviewDidSelectStep(_ step: MKRoute.Step) {
        guard let journeyManager = journeyManager else { return }
        journeyManager.showPreview(ofType: .stepPreview(step: step))
    }
    
    func journeyPreviewDidDismiss() {
        showJourneyView()
        guard let journeyManager = journeyManager else { return }
        journeyManager.showPreview(ofType: .travelPreview)
    }
    
    // MARK: Location Delegate
    
    
    func handlePendingRequests(_ pendingRequests: [PendingRequest]) {
        if driverStatus != .ready { return }
        if pendingRequests.isEmpty { return }
        guard let journeyManager = journeyManager else { return }
        
        let request = pendingRequests.first!
        
        showNotification(ofType: .info, message: "Ride found!", isPersistent: false)
        driverStatus = .viewingPendingRequest(request: request)
        updateViewForDriverStatusChange()
        
        journeyManager.setRoute(origin: CLLocationCoordinate2D(from: request.origin.coordinate), destination: CLLocationCoordinate2D(from: request.destination)) {
            journeyManager.showPreview(ofType: .requestPreview)
            self.showRequestContainer(withRequest: request)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let journeyManager = journeyManager else { return }
        UIView.animate(withDuration: 0.5) {
            self.followLocationButton.alpha = 1.0
        }
        journeyManager.stopFollowingCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let journeyManager = journeyManager else { return }
        journeyManager.locationManager(manager, didUpdateLocations: locations)
        
        if driverStatus == .offline { return }
        
        guard let uid = DriverSettingsManager.getUserID() else { return }
        guard locations.count > 0 else { return }
        let newLocation = locations.last!
        let geoPoint = GeoPoint(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        
        let hash = CKMapUtility.generateHashForCoordinate(geoPoint)
        
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
        
        switch driverStatus {
        case .ready:
            requestClient.setPendingRequestsListener(atLocation: newLocation.coordinate, triggerCompletion: handlePendingRequests)
        case .previewingPickup(let request):
            guard let requestId = request?.documentID else { return }
            requestClient.updateRequestDriverLocation(withLocation: geoPoint, requestId: requestId)
        case .travellingToPickup(let request):
            guard let requestId = request?.documentID else { return }
            requestClient.updateRequestDriverLocation(withLocation: geoPoint, requestId: requestId)
        case .waitingAtPickup(let ride):
            guard let rideId = ride?.rideId else { return }
            rideClient.updateRideDriverLocation(withLocation: geoPoint, rideId: rideId)
        case .previewingDropoff(let ride):
            guard let rideId = ride?.rideId else { return }
            rideClient.updateRideDriverLocation(withLocation: geoPoint, rideId: rideId)
        case .travellingToDropoff(let ride):
            guard let rideId = ride?.rideId else { return }
            rideClient.updateRideDriverLocation(withLocation: geoPoint, rideId: rideId)
        default:
            break
        }
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
    
    // MARK: Rejoin Session
    
    
    typealias RejoinCompletion = (Bool) -> Void
    func tryRejoiningPreviousSession(completion: @escaping RejoinCompletion) {
        guard let driverId = DriverSettingsManager.getUserID() else {
            completion(false); return
        }
        
        let userClient = CKProfileClient()
        userClient.tryFetchSession(forDriverId: driverId) { [unowned self] requestFetch, rideFetch in
            if let requestFetch = requestFetch {
                showNotification(ofType: .info, message: "Resuming travelling to pickup.", isPersistent: false)
                requestClient.getPendingRequest(withRequestId: requestFetch.requestId) { request in
                    self.didAcceptRequest(request)
                }
                completion(true)
            } else if let rideFetch = rideFetch {
                switch rideFetch.status {
                case .waiting:
                    showNotification(ofType: .info, message: "Resuming waiting for rider.", isPersistent: false)
                    rideClient.getRide(withRideId: rideFetch.rideId) { ride in
                        self.didArriveAtPickup(ride)
                    }
                case .active:
                    showNotification(ofType: .info, message: "Resuming travelling to dropoff.", isPersistent: false)
                    rideClient.getRide(withRideId: rideFetch.rideId) { ride in
                        self.didPickupDriver(ride: ride)
                    }
                default:
                    completion(false); return
                }
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: Pending Requests
    
    
    func clearViewAfterRequest(_ completion: @escaping () -> Void) {
        hideRequestContainer(completion)
        
        guard let mapViewManager = mapViewManager else { return }
        mapViewManager.clearMapView()
    }
    
    func didAcceptRequest(_ request: PendingRequest) {
        guard let currentLocation = locationManager.location?.coordinate else { return }
        let location = GeoPoint(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        
        driverStatus = .previewingPickup(request: nil)
        requestClient.setActiveRequestListener(withRequestId: request.requestId, location: location, completion: activeRequestChanged)
        
        guard let journeyManager = journeyManager else { return }
        journeyManager.setRoute(origin: currentLocation, destination: CLLocationCoordinate2D(from: request.origin.coordinate)) {
            journeyManager.showPreview(ofType: .travelPreview)
            self.updateViewForDriverStatusChange()
        }
    }
    
    func didTryToAcceptRequest(_ request: PendingRequest, completion: @escaping () -> Void) {
        guard let driverId = previousUserId else { return }
        
        requestClient.didViewRequest(request.requestId)
        requestClient.incrementDriverViewsForRequestId(request.requestId)
        
        clearViewAfterRequest(completion)
        
        requestClient.tryAcceptRequest(withRequestId: request.requestId, driverId: driverId) { [unowned self] requestWasAccepted in
            if requestWasAccepted {
                showNotification(ofType: .success, message: "Ride was accepted!", isPersistent: false)
                didAcceptRequest(request)
            } else {
                showNotification(ofType: .info, message: "Ride could not be accepted.", isPersistent: false)
                driverStatus = .ready
                updateViewForDriverStatusChange()
            }
        }
    }
    
    func requestTimedOut(_ request: PendingRequest, completion: @escaping () -> Void) {
        if driverStatus != .viewingPendingRequest(request: request) {
            return
        }
        
        driverStatus = .ready
        updateViewForDriverStatusChange()
        
        
        requestClient.didViewRequest(request.requestId)
        requestClient.incrementDriverViewsForRequestId(request.requestId)
        
        clearViewAfterRequest(completion)
    }
    
    // MARK: Active Requests
    
    
    func activeRequestChanged(_ request: ActiveRequest) {
        if driverStatus == .previewingPickup(request: nil) {
            driverStatus = .previewingPickup(request: request)
        } else if driverStatus == .travellingToPickup(request: nil) {
            driverStatus = .travellingToPickup(request: request)
        }
        updateViewForDriverStatusChange()
        
        if request.riderUnread > 0 {
            requestMessagesBadge.text = "\(request.riderUnread)"
            requestMessagesBadge.isHidden = false
            if previousUnread != request.riderUnread && previousUnread == 0 {
                showNotification(ofType: .info, message: "Message received from rider!", isPersistent: false)
            }
        } else {
            requestMessagesBadge.isHidden = true
        }
        previousUnread = request.riderUnread
    }
    
    func didPickupDriver(ride: Ride) {
        driverStatus = .previewingDropoff(ride: ride)
        guard let journeyManager = journeyManager else { return }
        guard let currentLocation = locationManager.location?.coordinate else { return }
        journeyManager.setRoute(origin: currentLocation, destination: CLLocationCoordinate2D(from: ride.destination)) {
            journeyManager.showPreview(ofType: .travelPreview)
            self.updateViewForDriverStatusChange()
        }
    }
    
    @IBAction func beginRide() {
        if driverStatus != .waitingAtPickup(ride: nil) {
            return
        }
        
        switch driverStatus {
        case .waitingAtPickup(let ride):
            requestClient.removeRequestMessagesListeners()
            guard let ride = ride else { return }
            rideClient.updateRideAsActive(withRideId: ride.rideId) { [unowned self] requestWasUpdated in
                if requestWasUpdated {
                    showNotification(ofType: .info, message: "Travelling to dropoff!", isPersistent: false)
                    didPickupDriver(ride: ride)
                }
            }
        default: break
        }
    }
    
    // MARK: Waiting Rides
    
    func didArriveAtPickup(_ ride: Ride) {
        self.driverStatus = .waitingAtPickup(ride: ride)
        self.beginWaitingCountdown(timeDriverArrived: ride.timeDriverArrived)
        self.updateViewForDriverStatusChange()
    }
    
    func getTextForTimeInterval(_ timeInterval: TimeInterval) -> String {
        let countdownInt = Int(timeInterval.magnitude)
        return String(format: "%d:%02d", (countdownInt / 60), (countdownInt % 60))
    }

    
    func beginWaitingCountdown(timeDriverArrived: Date) {
        riderCountdownTimerLabel.textColor = .label
        var countdown: TimeInterval = 120.0 + timeDriverArrived.timeIntervalSinceNow
        riderCountdownTimerLabel.text = getTextForTimeInterval(countdown)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: driverStatus == .waitingAtPickup(ride: nil)) { [unowned self] timer in
            if driverStatus == .waitingAtPickup(ride: nil) {
                countdown -= 1.0
                let countdownInt = Int(countdown.magnitude)
                if countdown <= 0 {
                    riderCountdownTimerLabel.textColor = .systemGreen
                    riderCountdownUpdateLabel.text = "Rider charged"
                } else if countdown > 0 {
                    if countdownInt % 5 == 0 {
                        let text = riderCountdownUpdateLabel.text ?? "Rider notified"
                        if text == "Rider notified" {
                            riderCountdownUpdateLabel.text = "Counting down"
                        } else {
                            riderCountdownUpdateLabel.text = "Rider notified"
                        }
                    }
                }
                riderCountdownTimerLabel.text = getTextForTimeInterval(countdown)
            }
        }
    }
    
    
    // MARK: Segue Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueTag.embedPendingRequest.rawValue {
            guard let pendingRequestController = segue.destination as? PendingRequestController else { return }
            pendingRequestController.delegate = self
            self.pendingRequestController = pendingRequestController
        } else if segue.identifier == SegueTag.showRequestMessages.rawValue {
            guard let requestMessagesController = segue.destination as? RequestMessagesController else { return }
            requestMessagesController.requestClient = requestClient
            switch driverStatus {
            case .previewingPickup(let request):
                guard let requestId = request?.documentID else { return }
                requestMessagesController.requestId = requestId
            case .travellingToPickup(let request):
                guard let requestId = request?.documentID else { return }
                requestMessagesController.requestId = requestId
            case .waitingAtPickup(let ride):
                guard let requestId = ride?.rideId else { return }
                requestMessagesController.requestId = requestId
            default:
                break
            }
            requestMessagesController.riderName = "Placeholder name"
        } else if segue.identifier == SegueTag.showJourneyPreview.rawValue {
            guard let journeyManager = journeyManager, let currentRoute = journeyManager.currentRoute else { return }
            guard let journeyPreviewController = segue.destination as? JourneyPreviewController else { return }
            journeyPreviewController.previewSteps = Array(currentRoute.steps[1...])
            
            journeyPreviewController.delegate = self
            journeyPreviewController.transitioningDelegate = self
            hideJourneyView()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SegueTag.showRequestMessages.rawValue {
            return driverStatus == .previewingPickup(request: nil) || driverStatus == .travellingToPickup(request: nil) || driverStatus == .waitingAtPickup(ride: nil)
        } else if identifier == SegueTag.showJourneyPreview.rawValue {
            return driverStatus == .previewingPickup(request: nil) || driverStatus == .previewingDropoff(ride: nil)
        }
        
        return true
    }
}
