//
//  Station.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 30/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import Foundation
import GoogleMaps

class Station {
    var stationID : String? = ""
    var address : String? = ""
    var lat : Double? = 0.00
    var long : Double? = 0.00
    var route : [String : AnyObject] = ["" : "" as AnyObject]
    var buses : [Bus] = []
    var mapMarker = GMSMarker()
    
    init(dict: [String:AnyObject]){
        address = dict["address"] as? String
        lat = dict["lat"]?.doubleValue
        long = dict["lng"]?.doubleValue
        /*
         address = dict["address"] as! String
         lat = dict["lat"]!.doubleValue!
         long = dict["lat"]!.doubleValue!
         */
        guard let routes = dict["route"] as? [String:String]
            else { return }
        for (routeKey, routeValue) in routes{
            let lineDirection = routeValue.components(separatedBy: ":")
            let newBus = Bus(id: routeKey, number: lineDirection[0], title: lineDirection[1])
            buses.append(newBus)
        }
        
        
        
        if let latitude = lat,
            let longtitude = long {
        let location = CLLocationCoordinate2DMake(latitude, longtitude)
        mapMarker.position = location
        mapMarker.title = address
        mapMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        mapMarker.snippet = stationID
        mapMarker.tracksInfoWindowChanges = true
        }
        

        
    }
}
