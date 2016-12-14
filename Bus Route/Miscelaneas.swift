//
//  Miscelaneas.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/2/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension UIColor{
    static func randonColor() -> UIColor{
        let col = CGFloat(50 + arc4random_uniform(155)) / 255.0
        //return UIColor(red: col, green: col, blue: col, alpha: 0.8)
        return UIColor(hue: col, saturation: col, brightness: col, alpha: 1)
    }
}


extension String {
    var html2AttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    var getTargetedRoad : String {
        return self.components(separatedBy: "<b>").last?.components(separatedBy: "</b>").first ?? self
    }
}



func calculateHeading(form point1 : CLLocationCoordinate2D ,to point2 : CLLocationCoordinate2D) -> Double {
    
    let lat1 = degreesToRadians(point1.latitude)
    let lon1 = degreesToRadians(point1.longitude)
    
    let lat2 = degreesToRadians(point2.latitude)
    let lon2 = degreesToRadians(point2.longitude)
    
    let dLon = lon2 - lon1
    
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)
    
    return radiansToDegrees(radiansBearing)
}

func degreesToRadians(_ degrees: Double) -> Double { return degrees * M_PI / 180.0 }
func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / M_PI }


