//
//  StationViewController.swift
//  BusRoute
//
//  Created by ALLAN CHAI on 28/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GoogleMaps

class StationViewController: UIViewController {

    let currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(3.1349378, 101.6299155)
    
    
    @IBOutlet weak var stationMapView: GMSMapView!{
        didSet{
            stationMapView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        stationMapView.isMyLocationEnabled = true
        stationMapView.animate(toLocation: currentLocation)
        stationMapView.animate(toZoom: 15.0)
        
        // Do any additional setup after loading the view.
    }

    
}

extension StationViewController : GMSMapViewDelegate{
    
}
