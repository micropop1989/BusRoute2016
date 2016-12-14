//
//  customUI.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 05/12/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import Foundation
import UIKit


class customUI {
    private var gradientLayer: CAGradientLayer?
    
    func setGradientBackgroundColor(view: UIView, firstColor: UIColor, secondColor: UIColor) {
        gradientLayer = CAGradientLayer()
        
        gradientLayer?.frame = view.bounds
        
        gradientLayer?.colors = [firstColor.cgColor, secondColor.cgColor]
        
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    
    func customLabel(label: UILabel) {
        label.textColor = UIColor.dodgerBlue
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize(width: 0, height: 0)
        
    }
    
    func titleView(view: UIView) {
        view.backgroundColor = UIColor.customBlue
        view.layer.cornerRadius = view.frame.width/20.0
    }
    
    func customButton(button: UIButton) {
        
        button.layer.borderColor = UIColor.dodgerBlue.cgColor
        button.layer.borderWidth = 2.0
        button.setTitleShadowColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.dodgerBlue
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.cornerRadius = button.frame.width/16;
        button.layer.shadowOffset = CGSize(width: 1, height: 1)

    }
}


extension UIColor {
    @nonobjc static let indigo  = UIColor(red: 0.365, green: 0.463, blue: 0.796, alpha: 1.0)
    
    @nonobjc static let violet = UIColor(red: 0.451, green: 0.400, blue: 0.741 , alpha: 1.0)
    
    @nonobjc static let pink = UIColor(red:1.00, green:0.75, blue:0.80, alpha:1.0)
    
    @nonobjc static let midNightBlue = UIColor(red:25.0/255, green:25.0/255, blue:112.0/255, alpha:1.0)
    
    @nonobjc static let lightBlue = UIColor(red:173.0/255, green:216.0/255, blue:230.0/255, alpha:1.0)
    @nonobjc static let gold = UIColor(red:255.0/255, green:215.0/255, blue:0.0/255, alpha:1.0)
    
    @nonobjc static let deepSkyBlue = UIColor(red:0.0/255, green:191.0/255, blue:255.0/255, alpha:1.0)
    
    @nonobjc static let dodgerBlue = UIColor(red:68.0/255, green:163.0/255, blue:211.0/255, alpha:1.0)
    
    @nonobjc static let lawnGreen = UIColor(red:124.0/255, green:252.0/255, blue:0.0/255, alpha:1.0)
    
    @nonobjc static let customBlue = UIColor(red: 28.0/255, green: 87.0/255, blue: 187.0/255, alpha:1.0)
}
