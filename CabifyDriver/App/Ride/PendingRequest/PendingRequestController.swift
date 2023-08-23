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
    var wasCalled: Bool = false
    var request: PendingRequest?
    var countdownAnimator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        countdownProgressView.progress = 1.0
        self.view.layoutIfNeeded()
        super.viewDidLoad()
    }
    
    private func printState(_ state: UIViewAnimatingState) {
        switch state {
        case .active:
            print("active")
        case .inactive:
            print("inactive")
        case .stopped:
            print("stopped")
        default:
            print("unknown")
        }
    }
    
    private func printPosition(_ position: UIViewAnimatingPosition) {
        switch position {
        case .current:
            print("current")
        case .start:
            print("start")
        case .end:
            print("end")
        default:
            print("unknown")
        }
    }
    
    func resetAnimations() {
        if let countdownAnimator = countdownAnimator {
            countdownAnimator.stopAnimation(true)
            countdownAnimator.finishAnimation(at: .start)
        }
        
        countdownAnimator = UIViewPropertyAnimator(duration: 8.0, curve: .linear) {
            self.countdownProgressView.setProgress(0.0, animated: true)
        }
        countdownAnimator!.addCompletion(requestTimedOutCompletion)

    }
    
    func showRequest(fromCurrentLocation currentLocation: GeoPoint, request: PendingRequest) {
        print("Showing request")
        self.request = request
        
        triedToAccept = false
        
        rideCostLabel.text = String(format: "£%.2f", request.cost)
        riderRatingLabel.text = String(format: "%.1f", request.riderRating)
        
        CKRouteSummaryClient.getRouteSummary(fromOrigin: currentLocation, destination: request.origin.coordinate, units: .imperial) { summary in
            self.pickupLocationLabel.text = String(summary.destinationAddress.split(separator: ",").first!)
            self.pickupSummaryLabel.text = "\(summary.duration.text) (\(summary.distance.text)) away"
        }
        CKRouteSummaryClient.getRouteSummary(fromOrigin: request.origin.coordinate, destination: request.destination, units: .imperial) { summary in
            self.dropoffLocationLabel.text = String(summary.destinationAddress.split(separator: ",").first!)
            self.dropoffSummaryLabel.text = "\(summary.duration.text) (\(summary.distance.text)) trip"
        }
        
        resetAnimations()
        self.countdownAnimator!.startAnimation()
    }
    
    func requestTimedOutCompletion(_ position: UIViewAnimatingPosition) {
        print("Timed out")
        printState(countdownAnimator!.state)
        
        countdownAnimator = nil
        if let request = request {
            // do this first, otherwise a back to back request will ensure the 2nd request comes before
            // clearView() is called, hence timing out instantly
            clearView()
            delegate?.requestTimedOut(request, completion: {})
        }
    }
    
    func clearView() {
        self.countdownProgressView.progress = 1.0
        print("current progress: \(countdownProgressView.progress)")
        self.view.layoutIfNeeded()
    }
    
    @IBAction func acceptRequest() {
        print("Accepted request")
        if triedToAccept { return }
        triedToAccept = true
        if let countdownAnimator = countdownAnimator {
            countdownAnimator.pauseAnimation()
        }
        
        guard let request = request else { return }
        delegate?.didTryToAcceptRequest(request, completion: clearView)
    }
}
