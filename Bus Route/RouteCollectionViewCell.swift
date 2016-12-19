//
//  RouteCollectionViewCell.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/19/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class RouteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        backgroundColor = UIColor.dodgerBlue
        layer.cornerRadius = 10.0
    }
    
}
