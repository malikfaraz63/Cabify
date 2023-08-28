//
//  PastJourneyCell.swift
//  CabifyRider
//
//  Created by Faraz Malik on 27/08/2023.
//

import UIKit

class PastJourneyCell: UITableViewCell {
    static let identifier = "PastJourneyCell"
    
    @IBOutlet weak var dropoffLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var rideCostLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
