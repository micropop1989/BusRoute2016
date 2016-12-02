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
    var substeps : [Step]?
    var travelMode = ""
    
    init(json : JSON) {
        distance = json["distance"]["text"].stringValue
        duration = json["duration"]["text"].stringValue
        
        instruction = json["html_instructions"].stringValue
        polylineString = json["polyline"]["points"].stringValue
        travelMode = json["travel_mode"].stringValue
        
        if json["steps"].exists() {
            
            for smallstep in json["steps"]{
                let tempSubstep = Step(json: smallstep.1)
                substeps?.append(tempSubstep)
            }
            
        }
    }
    
}

