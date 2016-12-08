//
//  StnTableViewCell.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 07/12/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class StnTableViewCell: UITableViewCell {

    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var busNumberLabel: UILabel!
    var delegate: StnTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var infoButton: UIButton! {
        didSet {
            infoButton.addTarget(self, action: #selector(onInfoButtonPressed), for: .touchUpInside)
        }
    }
    
    func onInfoButtonPressed(button: UIButton) {
        delegate?.StnTableViewCellOnInfoButtonPressed(cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol StnTableViewCellDelegate {
    func StnTableViewCellOnInfoButtonPressed(cell : StnTableViewCell)
}
