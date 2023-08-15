//
//  RideViewController.swift
//  CabifyRider
//
//  Created by Faraz Malik on 13/08/2023.
//

import UIKit
import MapKit

class RideViewController: UIViewController, MKMapViewDelegate, RouteSelectionDelegate {
    
    @IBOutlet weak var routeSelectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var routeSelectionHeight: NSLayoutConstraint!
    var routeSelectionController: RouteSelectionController?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pinSelectorImage: UIImageView!
    @IBOutlet weak var pinSelectorLaser: UIView!
    @IBOutlet weak var pinSelectorImageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pinSelectorConstraint: NSLayoutConstraint!
    @IBOutlet weak var pinSelectorConfirmButton: UIButton!
    @IBOutlet weak var pinSelectorTypeLabel: UILabel!
    @IBOutlet weak var pinSelectorDescriptionLabel: UILabel!
    
    private var pickupLocation: CKCoordinate?
    private var dropoffLocation: CKCoordinate?
    private var riderStatus: RiderStatus = .previewingSelectedRoute
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinSelectorLaser.layer.cornerRadius = pinSelectorLaser.frame.height / 2
        pinSelectorLaser.transform = .init(scaleX: 1, y: 0.7)
        
        mapView.delegate = self
    }
    
    // MARK: View Management
    
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
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        showPinSelectorImage()
        mapView(mapView, regionDidChangeAnimated: false)
    }
    func hidePinSelectorView() {
        if riderStatus != .pinSelectingPickup(locationDescription: nil) && riderStatus != .pinSelectingDropoff(locationDescription: nil) {
            return
        }
        pinSelectorConstraint.constant = -250
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
        pinSelectorImageConstraint.constant = pinSelectorImageConstraint.constant + 5
        pinSelectorLaser.alpha = 1.0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    func hidePinSelectorLaser() {
        pinSelectorImageConstraint.constant = pinSelectorImageConstraint.constant - 5
        pinSelectorLaser.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateViewForRiderStatus() {
        switch riderStatus {
        case .usingRouteSelector:
            showRouteSelector()
        case .pinSelectingPickup:
            hideRouteSelector()
            showPinSelectorView()
        case .pinSelectingDropoff:
            hideRouteSelector()
            showPinSelectorView()
        case .previewingSelectedRoute:
            hidePinSelectorView()
            hideRouteSelector()
            // show preview
        }
    }
    
    // MARK: Route Selection Delegate
    
    
    func didSelectLocation(ofType type: SelectionType, location: CKCoordinate) {
        if riderStatus != .usingRouteSelector && riderStatus != .pinSelectingPickup(locationDescription: nil) && riderStatus != .pinSelectingDropoff(locationDescription: nil) {
            return
        }
        
        if type == .pickup {
            pickupLocation = location
        } else {
            dropoffLocation = location
        }
        
        if let pickupLocation = pickupLocation, let dropoffLocation = dropoffLocation {
            
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
        if riderStatus == .pinSelectingPickup(locationDescription: nil) || riderStatus == .pinSelectingDropoff(locationDescription: nil) {
            showPinSelectorLaser()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if riderStatus == .pinSelectingPickup(locationDescription: nil) || riderStatus == .pinSelectingDropoff(locationDescription: nil) {
            hidePinSelectorLaser()
            
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
    
    @IBAction func searchPinSelection() {
        if riderStatus != .pinSelectingPickup(locationDescription: nil) && riderStatus != .pinSelectingDropoff(locationDescription: nil) {
            return
        }
        guard let routeSelectionController = routeSelectionController else { return }
        
        switch riderStatus {
        case .pinSelectingPickup(let locationDescription):
            guard let description = locationDescription else { return }
            routeSelectionController.pinDidSelectLocation(withDescription: description, type: .pickup)
            hidePinSelectorView()
            showRouteSelector()
        case .pinSelectingDropoff(let locationDescription):
            guard let description = locationDescription else { return }
            routeSelectionController.pinDidSelectLocation(withDescription: description, type: .dropoff)
            hidePinSelectorView()
            showRouteSelector()
        default:
            fatalError()
        }
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
    
    // MARK: Map View Delegate
    
    
    
    
    // MARK: Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueTag.embedRouteSelection.rawValue {
            guard let routeSelectionController = segue.destination as? RouteSelectionController else { return }
            
            self.routeSelectionController = routeSelectionController
            routeSelectionController.delegate = self
        }
    }
}
