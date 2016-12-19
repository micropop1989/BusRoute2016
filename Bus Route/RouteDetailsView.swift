//
//  RouteDetailsView.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/19/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class RouteDetailsView: UIView{
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var arrivedLabel: UILabel!
    
    var delegate : RouteDetailsViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func goButtonPressed(_ sender: Any) {
        delegate?.PressedGoButton()
    }
    
}


protocol RouteDetailsViewDelegate {
    func PressedGoButton()
}
