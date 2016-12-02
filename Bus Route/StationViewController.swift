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
        //        frDBref.child("routes").observe(.childAdded, with: {(snapshot) in
        //            let newBus = Bus()
        //            guard let busId = snapshot.key as? String
        //                else {
        //                    return
        //            }
        //            guard let busDictionary = snapshot.value as? [String : AnyObject]
        //                else
        //            {
        //                return
        //            }
        //
        //            let busUid = busId
        //            newBus.routeID = busUid
        //            newBus.busNumber = busDictionary["line"] as? String
        //            newBus.busTitle = busDictionary["direction"] as? String
        //
        //            self.buses.append(newBus)
        //
        //            self.busTableView.reloadData()
        //
        //        })
        //
        
//        frDBref2.child("stations").observeSingleEvent(of: .value, with: { (stationSnapshot) in
//            
//            //            guard let stationsId = stationSnapshot.key
//            //                else {
//            //                    return
//            //            }
//            guard let stationsDictionary = stationSnapshot.value as? [String : JSON]
//                else
//            {
//                return
//            }
//            
//            let stationsId = stationSnapshot.key
//            let newStation = Station()
//            
//            newStation.stationID = stationsId
        
            //newStation.address = stationDictionary["address"] as? String
            //self.stations.append(newStation)
            //self.routeTableView.reloadData()
            
            
//        })
        
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
