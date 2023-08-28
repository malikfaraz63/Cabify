//
//  PastJourneyDetailController.swift
//  CabifyRider
//
//  Created by Faraz Malik on 27/08/2023.
//

import UIKit
import MapKit

class PastJourneyDetailController: UIViewController, RatingViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var rideCostLabel: UILabel!
    
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var dropoffLabel: UILabel!
    
    @IBOutlet weak var riderPhotoView: UIImageView!
    @IBOutlet weak var ratingDescriptionLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    
    @IBOutlet weak var showRatingViewButton: UIButton!
    
    var ride: Ride?
    var driver: CKDriver?
    
    let profileClient = CKProfileClient()
    let ratingClient = CKRatingClient()
    
    var mapViewManager: CKMapViewManager?
    var journeyManager: CKJourneyManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapViewManager = CKMapViewManager(mapView: mapView)
        journeyManager = CKJourneyManager(mapViewManager: mapViewManager!, locationManager: CLLocationManager())
        
        mapView.delegate = mapViewManager
    }
    
    func setupView() {
        guard let ride = ride else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy, H:mm a"
        arrivalTimeLabel.text = dateFormatter.string(from: ride.timeCompleted ?? ride.timeRiderArrived ?? ride.timeDriverArrived)
        
        rideCostLabel.text = String(format: "£%.2f", ride.cost)
        
        CKPlacesClient.getDescription(forCoordinate: ride.origin) { description in
            self.pickupLabel.text = description.formattedAddress
        }
        CKPlacesClient.getDescription(forCoordinate: ride.destination) { description in
            self.dropoffLabel.text = description.formattedAddress
        }
        
        profileClient.getDriver(withDriverId: ride.driverId) { [unowned self] driver in
            self.driver = driver
            
            if let photoURL = driver.photoURL {
                riderPhotoView.load(url: URL(string: photoURL)!)
            } else {
                riderPhotoView.image = UIImage(systemName: "person.circle")
            }
            ratingClient.getRating(forUserId: driver.driverId, userType: .drivers, rideId: ride.rideId) { rating in
                if let rating = rating {
                    self.ratingDescriptionLabel.text = "You have rated \(driver.name)"
                    self.setupStarsView(rating.stars)
                } else {
                    self.ratingDescriptionLabel.text = "You haven't rated \(driver.name)"
                    self.showRatingViewButton.isEnabled = true
                }
            }
        }
        
        let origin = CLLocationCoordinate2D(from: ride.origin)
        let destination = CLLocationCoordinate2D(from: ride.destination)
        journeyManager!.setRoute(origin: origin, destination: destination) {
            self.journeyManager!.showPreview(ofType: .pastJourneyPreview, hasVerticalOffset: false, animated: false)
        }
    }
    
    func setupStarsView(_ stars: Int) {
        guard let ratingStars = ratingStackView.subviews as? [UIImageView] else { return }
        ratingStars.forEach {
            $0.image = UIImage(systemName: "star")
            $0.tintColor = .label
        }
        ratingStars[0..<stars].forEach {
            $0.image = UIImage(systemName: "star.fill")
        }
    }
    
    // MARK: Rating View Delegate
    
    func didSetRating(_ rating: CKRating) {
        setupStarsView(rating.stars)
        ratingDescriptionLabel.text = "You have rated \(driver?.name ?? "")"
    }
    
    // MARK: Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueTag.showRiderRating.rawValue {
            guard let ratingViewController = segue.destination as? RatingViewController else { return }
            ratingViewController.driver = driver
            ratingViewController.rideId = ride?.rideId
            ratingViewController.delegate = self
        }
    }
}
