//
//  RouteSelectionCell.swift
//  CabifyRider
//
//  Created by Faraz Malik on 13/08/2023.
//

import UIKit

class RouteSelectionCell: UITableViewCell {
    static let identifier = "RouteSelectionCell"

    @IBOutlet weak var primaryLocationLabel: UILabel!
    @IBOutlet weak var secondaryLocationLabel: UILabel!
    
    @IBOutlet weak var locationTypeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
