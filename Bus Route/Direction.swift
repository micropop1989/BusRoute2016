//
//  Path.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/2/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleMaps

class Path{
    
    
    var overviewPolyline : String = ""
    var overlay = GMSPolyline()
    var northeast = CLLocationCoordinate2D()
    var southwest = CLLocationCoordinate2D()
    var copyrights = ""
    
    var arrivedTime = ""
    var departure_time = ""
    var duration = ""
    var distance = ""
    var steps : [Step] = []
    
    init(json : JSON){
        
        //bound
        northeast = CLLocationCoordinate2DMake(json["bounds"]["northeast"]["lat"].doubleValue, json["bounds"]["northeast"]["lng"].doubleValue)
        southwest = CLLocationCoordinate2DMake(json["bounds"]["southwest"]["lat"].doubleValue, json["bounds"]["southwest"]["lng"].doubleValue)
        
        copyrights = json["copyrights"].stringValue
        
        overviewPolyline = json["overview_polyline"]["points"].stringValue
        
        //overlay
        DispatchQueue.main.async {
            let path = GMSPath(fromEncodedPath: self.overviewPolyline)
            self.overlay = GMSPolyline(path: path)
            //overlay.title = "Step \(i)"
            self.overlay.strokeWidth = 3.0
            self.overlay.geodesic = true
            self.overlay.strokeColor = UIColor.randonColor().withAlphaComponent(0.4)
            self.overlay.isTappable = true
        }
        

        guard let temp = json["legs"].first?.1
            else {return}
        
        
        arrivedTime = temp["arrival_time"]["text"].stringValue
        departure_time = temp["departure_time"]["text"].stringValue
        duration = temp["duration"]["text"].stringValue
        distance = temp["distance"]["text"].stringValue
        
        for stepJson in temp["steps"]{
            let step = Step(json: stepJson.1)
            steps.append(step)
        }
        
        
        
    }
    
}

class Step{
    var distance = ""
    var duration = ""
    var instruction = ""
    var polylineString = ""
    var overlay = GMSPolyline()
    
    var substeps : [SubStep]?
    var travelMode = ""
    var transitDetails : TransitDetails?
    var isTransit = false
    
    init(json : JSON) {
        distance = json["distance"]["text"].stringValue
        duration = json["duration"]["text"].stringValue
        
        instruction = json["html_instructions"].stringValue
        polylineString = json["polyline"]["points"].stringValue
        //overlay
        DispatchQueue.main.async {
        let path = GMSPath(fromEncodedPath: self.polylineString)
            self.overlay = GMSPolyline(path: path)
            //overlay.title = "Step \(i)"
            self.overlay.strokeWidth = 3.0
            self.overlay.geodesic = true
            self.overlay.strokeColor = UIColor.randonColor().withAlphaComponent(0.4)
            self.overlay.isTappable = true
        }
        
        
        travelMode = json["travel_mode"].stringValue
        
        if json["steps"].exists() {
            substeps = []
            for smallstep in json["steps"]{
                let tempSubstep = SubStep(json: smallstep.1)
                substeps?.append(tempSubstep)
            }
            
        } else if json["transit_details"].exists() {
            isTransit = true
            transitDetails = TransitDetails(json : json["transit_details"])
            
        }
    }
    
}

class SubStep {
    var distance = ""
    var duration = ""
    var instruction = ""
    var polylineString = ""
    var overlay = GMSPolyline()
    
    var travelMode = ""
    var maneuver : String?
    
    init(json : JSON) {
        distance = json["distance"]["text"].stringValue
        duration = json["duration"]["text"].stringValue
        
        instruction = json["html_instructions"].stringValue
        polylineString = json["polyline"]["points"].stringValue
        //overlay
        DispatchQueue.main.async {
            let path = GMSPath(fromEncodedPath: self.polylineString)
            self.overlay = GMSPolyline(path: path)
            //overlay.title = "Step \(i)"
            self.overlay.strokeWidth = 3.0
            self.overlay.geodesic = true
            self.overlay.strokeColor = UIColor.randonColor().withAlphaComponent(0.4)
            self.overlay.isTappable = true
        }
        travelMode = json["travel_mode"].stringValue
        
        if json["maneuver"].exists() {
            maneuver = json["maneuver"].stringValue
        }
    }

}

class TransitDetails {
    var departStop : BusStop
    var arrivalStop : BusStop
    var numStops = 0
    var agency = ""
    var name = ""
//    var hexColor = ""
    var shortName = ""
//    var text_color = ""
    var type = ""
    
    init (json : JSON){
        
        departStop = BusStop(json["departure_stop"])
        arrivalStop = BusStop(json["arrival_stop"])
        
        
        numStops = json["num_stops"].intValue

        agency = json["line"]["agencies"][0]["name"].stringValue
        
        name = json["line"]["name"].stringValue
        shortName = json["line"]["short_name"].stringValue
        type = json["line"]["vehicle"]["type"].stringValue
    }
        
    //num_stops
    //line -> agencies -> name
    //line -> color
    //line -> short_name
    //line -> text_color
    //line -> vehicle -> name / type
}

class BusStop {
    var  coordinate : CLLocationCoordinate2D
    var name : String
    
    init(_ json : JSON){
        let lat = json["location"]["lat"].doubleValue
        let lng = json["location"]["lng"].doubleValue
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        name = json["name"].stringValue
    }
}

