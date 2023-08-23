//
//  RideViewController.swift
//  CabifyRider
//
//  Created by Faraz Malik on 13/08/2023.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift

class RideViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, RouteSelectionDelegate {
    
    @IBOutlet weak var routeSelectionContainer: UIView!
    @IBOutlet weak var routeSelectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var routeSelectionHeight: NSLayoutConstraint!
    @IBOutlet weak var editSelectedRouteButton: UIRoundedButton!
    var routeSelectionController: RouteSelectionController?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pinSelectorView: UIView!
    @IBOutlet weak var pinSelectorImage: UIImageView!
    @IBOutlet weak var pinSelectorLaser: UIView!
    private var pinIsRaised = false
    @IBOutlet weak var pinSelectorImageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pinSelectorConstraint: NSLayoutConstraint!
    @IBOutlet weak var pinSelectorConfirmButton: UIButton!
    @IBOutlet weak var pinSelectorTypeLabel: UILabel!
    @IBOutlet weak var pinSelectorDescriptionLabel: UILabel!
    
    @IBOutlet weak var rideConfirmationView: UIView!
    @IBOutlet weak var rideConfirmationConstraint: NSLayoutConstraint!
    @IBOutlet weak var rideConfirmationCostLabel: UILabel!
    @IBOutlet weak var rideConfirmationArrivalLabel: UILabel!
    
    @IBOutlet weak var requestConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var activeDriverRequestView: UIView!
    @IBOutlet weak var activeDriverPickupLabel: UILabel!
    @IBOutlet weak var activeDriverArrivalLabel: UILabel!
    @IBOutlet weak var activeDriverNameLabel: UILabel!
    @IBOutlet weak var activeDriverRatingLabel: UILabel!
    @IBOutlet weak var activeDriverMessagesBadge: UILabel!
    @IBOutlet weak var activeDriverImageView: UIImageView!
    
    @IBOutlet weak var riderCountdownTimerLabel: UILabel!
    @IBOutlet weak var riderCountdownStackView: UIStackView!
    
    
    
    @IBOutlet weak var notificationStack: UIStackView!
    @IBOutlet weak var notificationConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationLabel: UILabel!
    
    private var pickupLocation: CKCoordinate?
    private var pickupDescription: String?
    private var dropoffLocation: CKCoordinate?
    private var dropoffDescription: String?
    
    
    @IBOutlet weak var navigateWithOverviewConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigateWithOverviewButton: UIButton!
    
    @IBOutlet weak var followLocationConstraint: NSLayoutConstraint!
    @IBOutlet weak var followLocationButton: UIButton!
    var isFollowingCurrentLocation = true
    
    let locationManager = CLLocationManager()
    var journeyManager: CKJourneyManager?
    var mapViewManager: CKMapViewManager?
    var driverAnnotationsManager: DriverAnnotationsManager?
    
    var previousUnread = 0
    let requestClient = RequestClient()
    let rideClient = RideClient()
    
    var previousUserId: String?
    
    private var riderStatus: RiderStatus = .usingRouteSelector
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: TEMP ONLY
        RiderSettingsManager.setUserID(to: "NLrmkbN13DdDIRAud0SSmQKht6H2")
        
        activeDriverMessagesBadge.layer.cornerRadius = activeDriverMessagesBadge.frame.height / 2
        activeDriverMessagesBadge.clipsToBounds = true
        activeDriverMessagesBadge.isHidden = true
        
        routeSelectionContainer.layer.cornerRadius = 10
        routeSelectionContainer.layer.masksToBounds = true
        
        pinSelectorView.layer.cornerRadius = 10
        pinSelectorView.layer.masksToBounds = true
        
        pinSelectorLaser.layer.cornerRadius = pinSelectorLaser.frame.height / 2
        pinSelectorLaser.transform = .init(scaleX: 1, y: 0.7)
        
        mapViewManager = CKMapViewManager(mapView: mapView)
        mapViewManager!.centerToLocation(CLLocation(latitude: 51.517651, longitude: -0.102968), regionRadius: 10000, animated: false)
        driverAnnotationsManager = DriverAnnotationsManager(mapView: mapView)
        
        journeyManager = CKJourneyManager(mapViewManager: mapViewManager!, locationManager: locationManager, navigateWithOverview: true)

        locationManager.delegate = self
        checkLocationAuthorizationStatus()
        mapView.delegate = self
        
        viewDidAppear(true)
    }
    
    func showSettingsAlert() {
        let alertController = UIAlertController(title: "Location Services Denied", message: "Allow location access to make ride requests and use navigation.", preferredStyle: .alert)

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
        switch locationManager.authorizationStatus {
        case .denied:
            showSettingsAlert()
            return
        default:
            break
        }
        
        if RiderSettingsManager.hasUser() {
            if let previousUserId = previousUserId {
                if previousUserId == RiderSettingsManager.getUserID() {
                    
                } else {
                    setupForRider()
                }
            } else {
                setupForRider()
            }
        } else {
            
        }
    }
    
    func setupForRider() {
        previousUserId = RiderSettingsManager.getUserID()
        updateViewForRiderStatus()
    }
    
    func checkLocationAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    // MARK: View Management
    
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
    
    func showRouteSelector() {
        routeSelectionConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func hideRouteSelector() {
        hideRouteSelectionTable()
        routeSelectionConstraint.constant = -200
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func showRouteSelectionTable() {
        routeSelectionHeight.constant = 450
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func hideRouteSelectionTable() {
        routeSelectionHeight.constant = 190
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func getAttributedString(_ string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .medium), range: NSMakeRange(0, string.count))
        return attributedString
    }
    
    func showPinSelectorView() {
        if riderStatus == .pinSelectingPickup(locationDescription: nil) {
            pinSelectorTypeLabel.text = "Confirm your pickup location"
            pinSelectorConfirmButton.setAttributedTitle(getAttributedString("Confirm pickup"), for: .normal)
        } else if riderStatus == .pinSelectingDropoff(locationDescription: nil) {
            pinSelectorTypeLabel.text = "Confirm your dropoff location"
            pinSelectorConfirmButton.setAttributedTitle(getAttributedString("Confirm dropoff"), for: .normal)
        } else {
            return
        }
        
        pinSelectorConstraint.constant = -20
        followLocationConstraint.constant = 30 + pinSelectorView.frame.height
        navigateWithOverviewConstraint.constant = 30 + pinSelectorView.frame.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        showPinSelectorImage()
        mapView(mapView, regionDidChangeAnimated: false)
    }
    func hidePinSelectorView() {
        pinSelectorConstraint.constant = -250
        followLocationConstraint.constant = 30
        navigateWithOverviewConstraint.constant = 30
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        hidePinSelectorImage()
    }
    
    func hidePinSelectorImage() {
        pinSelectorImage.isHidden = true
    }
    func showPinSelectorImage() {
        pinSelectorImage.isHidden = false
    }
    
    func showPinSelectorLaser() {
        print("--RideViewController.showPinSelectorLaser()--")
        pinSelectorImageConstraint.constant = pinSelectorImageConstraint.constant + 5
        pinSelectorLaser.alpha = 1.0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    func hidePinSelectorLaser() {
        print("--RideViewController.hidePinSelectorLaser()--")
        pinSelectorImageConstraint.constant = pinSelectorImageConstraint.constant - 5
        pinSelectorLaser.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showRideConfirmationView() {
        rideConfirmationConstraint.constant = 0
        followLocationConstraint.constant = 30 + rideConfirmationView.frame.height
        navigateWithOverviewConstraint.constant = 30 + rideConfirmationView.frame.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func hideRideConfirmationView() {
        rideConfirmationCostLabel.text = "£-.--"
        rideConfirmationArrivalLabel.text = ""
        rideConfirmationConstraint.constant = -220
        followLocationConstraint.constant = 30
        navigateWithOverviewConstraint.constant = 30
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showRequestView() {
        requestConstraint.constant = 0
        followLocationConstraint.constant = 30 + requestView.frame.height
        navigateWithOverviewConstraint.constant = 30 + requestView.frame.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func hideRequestView() {
        requestConstraint.constant = -200
        followLocationConstraint.constant = 30
        navigateWithOverviewConstraint.constant = 30
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Rider Status
        
    func updateViewForRiderStatus() {
        print("updating view for rider status")
        switch riderStatus {
        case .usingRouteSelector:
            navigateWithOverviewButton.isHidden = true
            editSelectedRouteButton.isHidden = true
            hideRideConfirmationView()
            hidePinSelectorView()
            showRouteSelector()
        case .pinSelectingPickup:
            hideRouteSelector()
            showPinSelectorView()
        case .pinSelectingDropoff:
            hideRouteSelector()
            showPinSelectorView()
        case .previewingSelectedRoute:
            navigateWithOverviewButton.isHidden = false
            hidePinSelectorView()
            hideRouteSelector()
            editSelectedRouteButton.isHidden = false
            showRideConfirmationView()
        case .awaitingRequestAcceptance:
            navigateWithOverviewButton.isHidden = true
            editSelectedRouteButton.isHidden = true
            hideRideConfirmationView()
            activeDriverRequestView.isHidden = true
            showRequestView()
        case .awaitingDriverArrival:
            navigateWithOverviewButton.isHidden = false
            riderCountdownStackView.isHidden = true
            activeDriverRequestView.isHidden = false
        case .awaitingRideActivation:
            navigateWithOverviewButton.isHidden = true
            riderCountdownStackView.isHidden = false
            activeDriverPickupLabel.text = ""
        case .awaitingDropoff:
            navigateWithOverviewButton.isHidden = false
            riderCountdownStackView.isHidden = true
            riderCountdownStackView.isHidden = true
            hideRequestView()
        }
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
    
    
    // MARK: Route Selection Delegate
    
    func nearbyDriverWentOffline(_ driver: Driver) {
        requestClient.removeNearbyDriverListener(driver.driverId)
        
        guard let driverAnnotationsManager = driverAnnotationsManager else { return }
        driverAnnotationsManager.removeDriver(driver)
    }
    func nearbyDriverChanged(_ driver: Driver) {
        print("--RideViewController.nearbyDriverChanged--")
        guard let driverAnnotationsManager = driverAnnotationsManager else { return }
        driverAnnotationsManager.updateDriverLocation(driver)
    }
    
    func didSelectLocation(ofType type: SelectionType, location: CKCoordinate) {
        print("--RideViewController.didSelectLocation--")
        print(riderStatus)
        if riderStatus != .usingRouteSelector && riderStatus != .pinSelectingPickup(locationDescription: nil) && riderStatus != .pinSelectingDropoff(locationDescription: nil) {
            return
        }
        print(" - entered")
        guard let mapViewManager = mapViewManager else { return }
        if type == .pickup {
            pickupLocation = location
            mapViewManager.removeCheckpointAnnotations(ofKind: .pickup)
            mapViewManager.addCheckpointAnnotation(CLLocationCoordinate2D(from: location), kind: .pickup)
        } else {
            dropoffLocation = location
            mapViewManager.removeCheckpointAnnotations(ofKind: .dropoff)
            mapViewManager.addCheckpointAnnotation(CLLocationCoordinate2D(from: location), kind: .dropoff)
        }
        
        if let pickupLocation = pickupLocation, let dropoffLocation = dropoffLocation {
            setPinSelectionDescription()
            guard let journeyManager = journeyManager else { return }
            let cost = RideFareClient.getCostForJourney(pickup: pickupLocation, dropoff: dropoffLocation)
            riderStatus = .previewingSelectedRoute(rideCost: cost)
            updateViewForRiderStatus()
            journeyManager.setRoute(origin: CLLocationCoordinate2D(from: pickupLocation), destination: CLLocationCoordinate2D(from: dropoffLocation)) {
                journeyManager.showPreview(ofType: .requestPreview, hasVerticalOffset: false)
            }
            requestClient.setNearbyDriverListeners(atLocation: pickupLocation, changeCompletion: nearbyDriverChanged, offlineCompletion: nearbyDriverWentOffline)
            self.setupRideConfirmView()
        } else {
            searchPinSelection()
            let coordinate = CLLocation(latitude: location.latitude, longitude: location.longitude)
            mapViewManager.centerToLocation(coordinate, animated: true)
        }
    }
    
    func beginPinSelection(forType type: SelectionType) {
        if type == .pickup {
            riderStatus = .pinSelectingPickup(locationDescription: nil)
        } else {
            riderStatus = .pinSelectingDropoff(locationDescription: nil)
        }
        updateViewForRiderStatus()
    }
    
    // MARK: Pin Selector
    
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("--mapView:regionWillChangeAnimated--")
        if riderStatus == .pinSelectingPickup(locationDescription: nil) || riderStatus == .pinSelectingDropoff(locationDescription: nil) {
            if !pinIsRaised {
                showPinSelectorLaser()
                pinIsRaised = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("--mapView:regionDidChangeAnimated--")
        if riderStatus == .pinSelectingPickup(locationDescription: nil) || riderStatus == .pinSelectingDropoff(locationDescription: nil) {
            if pinIsRaised {
                hidePinSelectorLaser()
                pinIsRaised = false
            }
            
            PlacesClient.getDescription(forCoordinate: mapView.centerCoordinate) { [unowned self] description in
                if riderStatus == .pinSelectingPickup(locationDescription: nil) {
                    riderStatus = .pinSelectingPickup(locationDescription: description.formattedAddress)
                } else {
                    riderStatus = .pinSelectingDropoff(locationDescription: description.formattedAddress)
                }
                
                pinSelectorDescriptionLabel.text = String(description.formattedAddress.split(separator: ",").first!)
            }
        }
    }
    
    func setPinSelectionDescription() {
        if riderStatus != .pinSelectingPickup(locationDescription: nil) && riderStatus != .pinSelectingDropoff(locationDescription: nil) {
            return
        }
        
        guard let routeSelectionController = routeSelectionController else { return }
        switch riderStatus {
        case .pinSelectingPickup(let locationDescription):
            guard let description = locationDescription else { return }
            routeSelectionController.pinDidSelectLocation(withDescription: description, type: .pickup)
        case .pinSelectingDropoff(let locationDescription):
            guard let description = locationDescription else { return }
            routeSelectionController.pinDidSelectLocation(withDescription: description, type: .dropoff)
        default: break
        }
    }
    
    @IBAction func searchPinSelection() {
        if riderStatus != .pinSelectingPickup(locationDescription: nil) && riderStatus != .pinSelectingDropoff(locationDescription: nil) {
            return
        }
        setPinSelectionDescription()
        
        riderStatus = .usingRouteSelector
        updateViewForRiderStatus()
    }
    
    @IBAction func confirmPinSelection() {
        if riderStatus != .pinSelectingPickup(locationDescription: nil) && riderStatus != .pinSelectingDropoff(locationDescription: nil) {
            return
        }
        
        if riderStatus == .pinSelectingPickup(locationDescription: nil) {
            didSelectLocation(ofType: .pickup, location: mapView.centerCoordinate)
        } else {
            didSelectLocation(ofType: .dropoff, location: mapView.centerCoordinate)
        }
    }
    
    @IBAction func editRouteSelection() {
        print("--RideViewController.editRouteSelection--")
        if riderStatus != .previewingSelectedRoute(rideCost: -1) {
            return
        }
        
        requestClient.clearNearbyDriverListeners()
        guard let driverAnnotationsManager = driverAnnotationsManager else { return }
        driverAnnotationsManager.removeAllDrivers()
        guard let mapViewManager = mapViewManager else { return }
        mapViewManager.clearMapView(removesAnnotations: false)
        riderStatus = .usingRouteSelector
        updateViewForRiderStatus()
    }
    
    // MARK: Ride Confirmation
    
    
    func setupRideConfirmView() {
        if riderStatus != .previewingSelectedRoute(rideCost: -1) {
            return
        }
        let cost: Double
        switch riderStatus {
        case .previewingSelectedRoute(let rideCost):
            cost = rideCost
        default:
            return
        }
        
        rideConfirmationCostLabel.text = String(format: "£%.2f", cost)
        guard let pickupLocation = pickupLocation, let dropoffLocation = dropoffLocation else { return }
        
        self.rideConfirmationArrivalLabel.text = ""
        CKRouteSummaryClient.getRouteSummary(fromOrigin: pickupLocation, destination: dropoffLocation, units: .imperial) { summary in
            self.rideConfirmationArrivalLabel.text = "\(summary.duration.text) • \(summary.distance.text)"
            self.activeDriverArrivalLabel.text = "\(summary.duration.value / 60)"
            self.activeDriverPickupLabel.text = String(summary.originAddress.split(separator: ",").first!)
        }
    }
    
    @IBAction func confirmRide() {
        print("--RideViewController.confirmRide--")
        if riderStatus != .previewingSelectedRoute(rideCost: -1) {
            return
        }
        
        guard let riderId = RiderSettingsManager.getUserID() else { return }
        guard let pickup = pickupLocation, let dropoff = dropoffLocation else { return }
        let cost = RideFareClient.getCostForJourney(pickup: pickup, dropoff: dropoff)
        print(" - has pickup, rider andcost annd dropoff...")
        
        requestClient.createRequest(withRiderId: riderId, pickup: pickup, dropoff: dropoff, cost: cost) { [unowned self] request in
            showNotification(ofType: .info, message: "Searching for driver...", isPersistent: false)
            
            requestClient.clearNearbyDriverListeners()
            
            guard let driverAnnotationsManager = driverAnnotationsManager else { return }
            driverAnnotationsManager.removeAllDrivers()
            
            riderStatus = .awaitingRequestAcceptance(request: request)
            updateViewForRiderStatus()
            
            requestClient.setRequestListener(withRequestId: request.requestId, completion: requestChanged)
        }
    }
    
    // MARK: Request
    
    
    func requestChanged(_ snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else { return }
        guard let statusString = data["status"] as? String else { return }
        let status = CKRequestStatus(rawValue: statusString)
        switch status {
        case .pending:
            guard let mapViewManager = mapViewManager else { return }
            guard let pickupLocation = pickupLocation else { return }
            
            let newCentre = CLLocation(latitude: pickupLocation.latitude, longitude: pickupLocation.longitude)
            mapViewManager.centerToLocation(newCentre)
            
            
            do {
                let pendingRequest = try snapshot.data(as: PendingRequest.self)
                // driver might have cancelled on the way...
            } catch let error {
                print(error)
            }
        case .active:
            do {
                let request = try snapshot.data(as: ActiveRequest.self)
                
                if request.driverUnread > 0 {
                    activeDriverMessagesBadge.text = "\(request.driverUnread)"
                    activeDriverMessagesBadge.isHidden = false
                    if previousUnread != request.driverUnread && previousUnread == 0 {
                        showNotification(ofType: .info, message: "Message received from driver!", isPersistent: false)
                    }
                } else {
                    activeDriverMessagesBadge.isHidden = true
                }
                previousUnread = request.driverUnread
                
                if riderStatus == .awaitingRequestAcceptance(request: PendingRequest.nilRequest) {
                    requestClient.getDriver(withDriverId: request.driverId) { [unowned self] driver in
                        showNotification(ofType: .success, message: "Driver found!", isPersistent: false)
                        if let urlString = driver.photoURL, let url = URL(string: urlString) {
                            activeDriverImageView.load(url: url)
                        }
                        activeDriverNameLabel.text = driver.name
                        activeDriverRatingLabel.text = String(format: "%.1f", driver.averageRating)
                        riderStatus = .awaitingDriverArrival(request: request)
                        updateViewForRiderStatus()
                        
                        guard let journeyManager = journeyManager else { return }
                        guard let driverLocation = driver.location else { return }
                        let origin = CLLocationCoordinate2D(from: driverLocation.coordinate)
                        
                        guard let pickupLocation = pickupLocation else { return }
                        let destination = CLLocationCoordinate2D(from: pickupLocation)
                        journeyManager.setRoute(origin: origin, destination: destination) {
                            journeyManager.beginNavigation()
                        }
                    }
                }
                
                guard let driverAnnotationsManager = driverAnnotationsManager else { return }
                driverAnnotationsManager.updateDriverLocation(withDriverId: request.driverId, location: request.driverLocation)
                
                let driverLocation = CLLocation(latitude: request.driverLocation.latitude, longitude: request.driverLocation.longitude)
                guard let journeyManager = journeyManager else { return }
                journeyManager.locationManager(locationManager, didUpdateLocations: [driverLocation])
                
                riderStatus = .awaitingDriverArrival(request: request)
            } catch let error {
                print(error)
            }
        case .cancelled:
            requestClient.removeRequestListener()
        case .completed:
            guard let requestId = data["requestId"] as? String else { return }
            rideClient.setRideListener(withRideId: requestId, completion: rideChanged)
            
            guard let driverUnread = data["driverUnread"] as? Int else { return }
            if driverUnread > 0 {
                activeDriverMessagesBadge.text = "\(driverUnread)"
                activeDriverMessagesBadge.isHidden = false
                if previousUnread != driverUnread && previousUnread == 0 {
                    showNotification(ofType: .info, message: "Message received from driver!", isPersistent: false)
                }
            } else {
                activeDriverMessagesBadge.isHidden = true
            }
            previousUnread = driverUnread
        default:
            requestClient.removeRequestListener()
        }
    }
    
    // MARK: Ride
    
    func rideChanged(_ ride: Ride) {
        switch ride.status {
        case .waiting:
            if riderStatus == .awaitingDriverArrival(request: ActiveRequest.nilRequest) {
                showNotification(ofType: .info, message: "Driver has arrived!", isPersistent: false)
                riderStatus = .awaitingRideActivation(ride: ride)
                beginWaitingCountdown()
                updateViewForRiderStatus()
            }
            
            riderStatus = .awaitingRideActivation(ride: ride)
        case .active:
            if riderStatus == .awaitingRideActivation(ride: Ride.nilRide) {
                requestClient.removeRequestListener()
                requestClient.removeRequestMessagesListeners()
                showNotification(ofType: .info, message: "Travelling to dropoff!", isPersistent: false)
                
                riderStatus = .awaitingDropoff(ride: ride)
                updateViewForRiderStatus()
                
                guard let driverAnnotationsManager = driverAnnotationsManager else { return }
                driverAnnotationsManager.removeDriver(ride.driverId)
                
                guard let journeyManager = journeyManager else { return }
                
                let origin = CLLocationCoordinate2D(from: ride.origin)
                let destination = CLLocationCoordinate2D(from: ride.destination)
                journeyManager.setRoute(origin: origin, destination: destination) {
                    journeyManager.beginNavigation()
                }
            }
            
            riderStatus = .awaitingDropoff(ride: ride)
        case .completed:
            if riderStatus == .awaitingDropoff(ride: Ride.nilRide) {
                let costString = String(format: "£%.2f", ride.cost)
                showNotification(ofType: .success, message: "Ride completed, transferred \(costString)!", isPersistent: false)
                riderStatus = .usingRouteSelector
                updateViewForRiderStatus()
            }
            
            riderStatus = .usingRouteSelector
            rideClient.removeRideListener()
        case .unknown:
            rideClient.removeRideListener()
        }
    }
    
    func getTextForTimeInterval(_ timeInterval: TimeInterval) -> String {
        let countdownInt = Int(timeInterval.magnitude)
        return String(format: "%d:%02d", (countdownInt / 60), (countdownInt % 60))
    }
    
    func beginWaitingCountdown() {
        riderCountdownTimerLabel.text = "2:00"
        riderCountdownTimerLabel.textColor = .label
        var countdown: TimeInterval = 120.0
        riderCountdownTimerLabel.text = getTextForTimeInterval(countdown)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: riderStatus == .awaitingRideActivation(ride: Ride.nilRide)) { [unowned self] timer in
            if riderStatus == .awaitingRideActivation(ride: Ride.nilRide) {
                countdown -= 1.0
                let countdownInt = Int(countdown.magnitude)
                if countdown == 0 {
                    riderCountdownTimerLabel.textColor = .systemRed
                }
                riderCountdownTimerLabel.text = getTextForTimeInterval(countdown)
            }
        }
    }
    
    // MARK: Location Manager Delegate
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isFollowingCurrentLocation = false
        
        guard let journeyManager = journeyManager else { return }
        journeyManager.stopNavigatingWithOverview()
        
        UIView.animate(withDuration: 0.5) {
            self.followLocationButton.alpha = 1.0
            self.navigateWithOverviewButton.alpha = 1.0
        }
    }
    
    @IBAction func navigateWithOverview() {
        guard let journeyManager = journeyManager else { return }
        journeyManager.startNavigatingWithOverview(hasVerticalOffset: false)
        UIView.animate(withDuration: 0.5) {
            self.navigateWithOverviewButton.alpha = 0.0
        }
    }
    
    @IBAction func followLocation() {
        isFollowingCurrentLocation = true
        UIView.animate(withDuration: 0.5) {
            self.followLocationButton.alpha = 0.0
        }
        
        guard let mapViewManager = mapViewManager else { return }
        guard let location = locationManager.location else { return }
        mapViewManager.centerToLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count > 0 else { return }
        guard let mapViewManager = mapViewManager else { return }
        if isFollowingCurrentLocation {
            mapViewManager.centerToLocation(locations.last!)
        }
        
        switch riderStatus {
        case .awaitingDropoff:
            guard let journeyManager = journeyManager else { return }
            journeyManager.locationManager(manager, didUpdateLocations: locations)
        default: break
        }
    }
    
    // MARK: Map View Delegate
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapViewManager?.mapView(mapView, viewFor: annotation)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let mapViewManager = mapViewManager else { return MKOverlayRenderer() }
        return mapViewManager.mapView(mapView, rendererFor: overlay)
    }
    
    // MARK: Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueTag.embedRouteSelection.rawValue {
            guard let routeSelectionController = segue.destination as? RouteSelectionController else { return }
            
            self.routeSelectionController = routeSelectionController
            routeSelectionController.delegate = self
        } else if segue.identifier == SegueTag.showRequestMessages.rawValue {
            guard let requestMessagesController = segue.destination as? RequestMessagesController else { return }
            requestMessagesController.requestClient = requestClient
            switch riderStatus {
            case .awaitingDriverArrival(let request):
                requestMessagesController.requestId = request.requestId
            case .awaitingRideActivation(let ride):
                requestMessagesController.requestId = ride.rideId
            default:
                break
            }
            requestMessagesController.driverName = activeDriverNameLabel.text
        }
    }
}
