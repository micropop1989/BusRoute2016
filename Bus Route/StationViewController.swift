//
//  StationViewController.swift
//  BusRoute
//
//  Created by ALLAN CHAI on 28/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase
import SwiftyJSON

class StationViewController: UIViewController {
    
    let currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(3.1349378, 101.6299155)
    var frDBref2 : FIRDatabaseReference!
    
    @IBOutlet weak var stationMapView: GMSMapView!{
        didSet{
            stationMapView.delegate = self
        }
    }
    
    var allStation : [Station] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frDBref2 = FIRDatabase.database().reference()
        fetchStations()
        
        stationMapView.isMyLocationEnabled = true
        stationMapView.animate(toLocation: currentLocation)
        stationMapView.animate(toZoom: 15.0)
        
        // Do any additional setup after loading the view.
    }
    
    func fetchStations(){
         frDBref2.child("stations").observeSingleEvent(of: .value, with: { (stationSnapshot) in
            
            
            let enumerator = stationSnapshot.children
            while let singleStationSnapshot = enumerator.nextObject() as? FIRDataSnapshot {
                let stationsId = singleStationSnapshot.key
                let info = singleStationSnapshot.value as! [String:AnyObject]
                
                
                
                let newStation = Station(dict: info)
                newStation.stationID = stationsId
                self.allStation.append(newStation)
                
            }
            
            //main tread , sort
            DispatchQueue.main.async {
                
            }
        })
        
    }
    
    
    func sortBusStation(){
        allStation.sort(by: {$0.lat < $1.lat})
    }
}

extension StationViewController : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        print("Idle")
        print(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print(position.target)
    }
}
