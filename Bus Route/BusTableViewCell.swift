//
//  BusTableViewCell.swift
//  BusRoute
//
//  Created by ALLAN CHAI on 28/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class BusTableViewCell: UITableViewCell {

    @IBOutlet weak var busDestinationLabel: UILabel!
    @IBOutlet weak var busNumberLabel: UILabel!
   
    @IBOutlet weak var busImage: UIImageView!
    @IBOutlet weak var busNumberView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

   
}
