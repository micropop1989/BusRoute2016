//
//  RouteStationCollectionViewCell.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/7/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class RouteStationCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var dotImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        nameLabel.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2) - 0.1)
    }
    
    
}
