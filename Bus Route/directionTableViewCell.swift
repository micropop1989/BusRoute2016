//
//  directionTableViewCell.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 07/12/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class directionTableViewCell: UITableViewCell {
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var arrivedLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
