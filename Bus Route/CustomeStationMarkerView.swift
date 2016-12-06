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

    

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var buslineLabel: UILabel!
    @IBOutlet weak var paraView: GMSPanoramaView!
    
    var station : Station?
    
    var delegate: StationMarkerDelegate?
    
    
    override func draw(_ rect: CGRect) {
        //paraView.transform = CGAffineTransform(rotationAngle: -0.09)
        paraView.layer.borderWidth = 1.0
        paraView.layer.borderColor = UIColor.orange.cgColor
    }
    
    @IBAction func showDetailsButtonTapped(_ sender: AnyObject) {
        delegate?.showStationDetails()
    }

}

protocol StationMarkerDelegate {
    func showStationDetails()
}
