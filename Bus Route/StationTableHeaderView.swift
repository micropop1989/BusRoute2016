//
//  StationTableHeaderView.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/14/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class StationTableHeaderView: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var headerButton: UIButton!
    
    var delegate : StationTableHeaderDelegate?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        headerButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    func buttonTapped(){
        delegate?.tableHeaderButtonPressed(button : headerButton)
    }

    @IBAction func refreashButtonTapped(_ sender: Any) {
        delegate?.refreashButtonPressed()
    }
}

protocol StationTableHeaderDelegate {
    func tableHeaderButtonPressed(button : UIButton)
    func refreashButtonPressed()
}
