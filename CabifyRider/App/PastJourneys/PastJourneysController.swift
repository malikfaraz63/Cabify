//
//  PastJourneysController.swift
//  CabifyRider
//
//  Created by Faraz Malik on 27/08/2023.
//

import UIKit

class PastJourneysController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pastJourneysTable: UITableView!
    
    let pastJourneysClient = CKPastJourneysClient()
    let rideClient = RideClient()
    
    var pastJourneys: [PastJourney] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pastJourneysTable.delegate = self
        pastJourneysTable.dataSource = self
        
        viewDidAppear(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let riderId = RiderSettingsManager.getUserID() else { return }
        
        pastJourneys = []
        pastJourneysTable.reloadData()
        
        progressIndicator.startAnimating()
        
        pastJourneysClient.getPastJourneys(forUserId: riderId, type: .riders) { pastJourneys in
            self.pastJourneys = pastJourneys
            self.pastJourneysTable.reloadData()
            self.progressIndicator.stopAnimating()
        }
    }

    // MARK: Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastJourneys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pastJourneyCell = tableView.dequeueReusableCell(withIdentifier: PastJourneyCell.identifier) as? PastJourneyCell else { fatalError() }
        
        let pastJourney = pastJourneys[indexPath.row]
        pastJourneyCell.rideCostLabel.text = String(format: "£%.2f", pastJourney.cost)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM • H:mm a"
        pastJourneyCell.arrivalTimeLabel.text = dateFormatter.string(from: pastJourney.timeCompleted)
        
        CKPlacesClient.getDescription(forCoordinate: pastJourney.destination) { descriptionDetail in
            pastJourneyCell.dropoffLabel.text = String(descriptionDetail.formattedAddress.split(separator: ",").first!)
        }
        
        return pastJourneyCell
    }
    
    // MARK: Delegate
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    // MARK: Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueTag.showPastJourneyDetail.rawValue {
            guard let journeyDetailController = segue.destination as? PastJourneyDetailController else { return }
            guard let selectedPath = pastJourneysTable.indexPathForSelectedRow else { return }
            
            let pastJourney = pastJourneys[selectedPath.row]
            rideClient.getRide(withRideId: pastJourney.rideId) { ride in
                journeyDetailController.ride = ride
                journeyDetailController.setupView()
            }
        }
    }

}
