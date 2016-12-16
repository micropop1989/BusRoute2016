//
//  CustomeStationMarkerView.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/5/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GoogleMaps

class CustomeStationMarkerView: UIView {

    

    @IBOutlet weak var shapeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var buslineLabel: UILabel!
    @IBOutlet weak var paraView: GMSPanoramaView!
    
    var station : Station?
    
    var delegate: StationMarkerDelegate?
    
    
    override func draw(_ rect: CGRect) {
        
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 2
        //paraView.transform = CGAffineTransform(rotationAngle: -0.09)
        paraView.layer.borderWidth = 1.0
        paraView.layer.borderColor = UIColor.orange.cgColor
        paraView.navigationLinksHidden = true
        
    }
    
    @IBAction func showDetailsButtonTapped(_ sender: AnyObject) {
        delegate?.showStationDetails()
    }

}

protocol StationMarkerDelegate {
    func showStationDetails()
}
