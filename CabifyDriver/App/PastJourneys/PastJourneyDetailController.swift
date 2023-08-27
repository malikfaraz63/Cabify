//
//  PastJourneyDetailController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 24/08/2023.
//

import UIKit
import MapKit

class PastJourneyDetailController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var rideCostLabel: UILabel!
    
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var dropoffLabel: UILabel!
    
    @IBOutlet weak var riderPhotoView: UIImageView!
    @IBOutlet weak var ratingDescriptionLabel: UILabel!
    
    var ride: Ride?
    
    let profileClient = CKProfileClient()
    
    var mapViewManager: CKMapViewManager?
    var journeyManager: CKJourneyManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewManager = CKMapViewManager(mapView: mapView)
        journeyManager = CKJourneyManager(mapViewManager: mapViewManager!, locationManager: CLLocationManager())
        
        mapView.delegate = mapViewManager!
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
        
        profileClient.getRider(withRiderId: ride.riderId) { rider in
            self.riderPhotoView.load(url: URL(string: rider.photoURL)!)
            self.ratingDescriptionLabel.text = "You haven't rated \(rider.name)"
        }
        
        let origin = CLLocationCoordinate2D(from: ride.origin)
        let destination = CLLocationCoordinate2D(from: ride.destination)
        journeyManager!.setRoute(origin: origin, destination: destination) {
            self.journeyManager!.showPreview(ofType: .pastJourneyPreview)
        }
    }
}
