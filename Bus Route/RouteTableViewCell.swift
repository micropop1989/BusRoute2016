//
//  RouteTableViewCell.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 29/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {
    @IBOutlet weak var routeLabel: UILabel!

    @IBOutlet weak var upperRouteImage: UIImageView!
   
    @IBOutlet weak var lowerRouteImage: UIImageView!
    @IBOutlet weak var dotImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    /*
     if routeCell.isSelected {
     routeCell.dotImage.image = UIImage(named: "dot")!
     }else{
     routeCell.dotImage.image = UIImage(named: "dotWithScp")!
     }
     
 */
    
    

}
