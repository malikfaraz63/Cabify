//
//  PendingRequestController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 26/07/2023.
//

import UIKit
import FirebaseFirestore

class PendingRequestController: UIViewController {
    
    @IBOutlet weak var countdownProgressView: CountdownProgressView!
    @IBOutlet weak var rideCostLabel: UILabel!
    @IBOutlet weak var riderRatingLabel: UILabel!
    
    @IBOutlet weak var pickupSummaryLabel: UILabel!
    @IBOutlet weak var pickupLocationLabel: UILabel!
    
    @IBOutlet weak var dropoffSummaryLabel: UILabel!
    @IBOutlet weak var dropoffLocationLabel: UILabel!

    var delegate: PendingRequestDelegate?
    
    var triedToAccept: Bool = false
    var request: PendingRequest?
    var countdownAnimation: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        countdownProgressView.setProgress(1.0, animated: false)
        // Do any additional setup after loading the view.
    }
    
    func showRequest(fromCurrentLocation currentLocation: GeoPoint, request: PendingRequest) {
        countdownProgressView.setProgress(1.0, animated: false)
        triedToAccept = false
        
        self.request = request
        
        rideCostLabel.text = String(format: "£%.2f", request.cost)
        riderRatingLabel.text = String(format: "%.1f", request.riderRating)
        
        RouteSummaryClient.getRouteSummary(fromOrigin: currentLocation, destination: request.origin.coordinate, units: .imperial) { summary in
            self.pickupLocationLabel.text = String(summary.destinationAddress.split(separator: ",").first!)
            self.pickupSummaryLabel.text = "\(summary.duration.text) (\(summary.distance.text)) away"
        }
        RouteSummaryClient.getRouteSummary(fromOrigin: request.origin.coordinate, destination: request.destination, units: .imperial) { summary in
            self.dropoffLocationLabel.text = String(summary.destinationAddress.split(separator: ",").first!)
            self.dropoffSummaryLabel.text = "\(summary.duration.text) (\(summary.distance.text)) trip"
        }
        
        countdownAnimation = UIViewPropertyAnimator(duration: 10.0, curve: .linear) {
            self.countdownProgressView.setProgress(0.0, animated: true)
        }
        countdownAnimation!.addCompletion { _ in
            if let request = self.request {
                self.delegate?.requestTimedOut(request)
            }
        }
        countdownAnimation!.startAnimation(afterDelay: 2.0)
    }
    
    func clearView() {
        rideCostLabel.text = "£--.--"
        riderRatingLabel.text = "--"
        pickupLocationLabel.text = "Pickup"
        dropoffLocationLabel.text = "Dropoff"
        pickupSummaryLabel.text = "-- mins (-- mi) away"
        dropoffSummaryLabel.text = "-- mins (-- mi) trip"
    }
    
    @IBAction func acceptRequest() {
        if triedToAccept { return }
        triedToAccept = true
        if let countdownAnimation = countdownAnimation {
            countdownAnimation.pauseAnimation()
        }
        
        guard let request = request else { return }
        delegate?.didTryToAcceptRequest(request)
    }
}
