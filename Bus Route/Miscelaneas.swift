//
//  Miscelaneas.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/2/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    static func randonColor() -> UIColor{
        let col = CGFloat(50 + arc4random_uniform(155)) / 255.0
        //return UIColor(red: col, green: col, blue: col, alpha: 0.8)
        return UIColor(hue: col, saturation: col, brightness: col, alpha: 1)
    }
}
