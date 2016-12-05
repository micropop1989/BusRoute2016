//
//  Bus.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 28/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import Foundation

class Bus {
    var busNumber : String? = ""
    var busTitle : String? = ""
    var routeID : String? = ""
    
    
    init(){
        
    }
    
    init(id : String, number: String, title: String){
        routeID = id
        busNumber = number
        busTitle = title
        
    }
}
