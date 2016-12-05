//
//  Station.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 30/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import Foundation

class Station {
    var stationID : String? = ""
    var address : String? = ""
    var lat : Double? = 0.00
    var long : Double? = 0.00
    var route : [String : AnyObject] = ["" : "" as AnyObject]
    var buses : [Bus] = []
    
    init(dict: [String:AnyObject]){
        address = dict["address"] as? String
        lat = dict["lat"] as? Double
        long = dict["lng"] as? Double
        guard let routes = dict["route"] as? [String:String]
            else { return }
        for (routeKey, routeValue) in routes{
            let lineDirection = routeValue.components(separatedBy: ":")
            let newBus = Bus(id: routeKey, number: lineDirection[0], title: lineDirection[1])
            buses.append(newBus)
        }
    }
}
