//
//  PreviewStepCell.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 11/08/2023.
//

import UIKit

class PreviewStepCell: UITableViewCell {
    static let identifier = "PreviewStepCell"
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
