//
//  StationDetailTableViewCell.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 30/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class StationDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var busTitleLabel: UILabel!
   
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var numberView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberView.layer.borderWidth = 1
        numberView.layer.borderColor = UIColor.dodgerBlue.cgColor
        numberView.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if (selected) {
            self.backgroundColor = UIColor.dodgerBlue
            self.reloadInputViews()
            
        } else {
            self.backgroundColor = UIColor.white
            self.reloadInputViews()
        }
    }

}
