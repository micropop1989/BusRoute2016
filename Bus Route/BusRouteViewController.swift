//
//  BusRouteViewController.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 29/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase

class BusRouteViewController: UIViewController {

    @IBOutlet weak var destinationTilteLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    @IBOutlet weak var routeMapView: GMSMapView!
    var bus : Bus?
    
    //fetchdata
    var stations : [Station] = []
    var frDBref : FIRDatabaseReference!
    var routeID : String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "\((bus?.busNumber)!)"
        destinationLabel.text = bus?.busTitle
        
        //fetchdata
        frDBref = FIRDatabase.database().reference()
        fetchRoute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customUI().customLabel(label: destinationLabel)
        customUI().customLabel(label: destinationTilteLabel)
        customUI().customButton(button: seeRouteDetailButton)
        customUI().customButton(button: changeRouteButton)
    }
    
    
    //fetchdata
    func fetchRoute() {
        guard let routeID = bus?.routeID
            else{ return}
        self.routeID = routeID
        
        // let routeID = "route0232"
        frDBref.child("routes").child(routeID).child("orderedStations").observeSingleEvent(of: .value, with: { (routeSnapshot) in
            guard let routeDictionary = routeSnapshot.value as? [String]
                else { return }
            let dispatchGp = DispatchGroup()
            
            for station in routeDictionary {
                
                dispatchGp.enter()
                
                self.frDBref.child("stations").child(station).observeSingleEvent(of: .value, with: { (stationSnapshot) in
                    
                    
                    guard let stationDictionary = stationSnapshot.value as? [String : AnyObject]
                        else { return }
                    
                    let newStation = Station(dict: stationDictionary)
                    newStation.stationID = station
                    //newStation.address = stationDictionary["address"] as? String
                    self.stations.append(newStation)
                    
                    dispatchGp.leave()
                })
                
            }
            dispatchGp.notify(queue: DispatchQueue.main, execute: {
                print("Doen fetch data")
                self.showStationOnMap()
            })
        })
    }
    
    func showStationOnMap(){
        let path = GMSMutablePath()
        
        routeMapView.animate(toLocation: stations[0].mapMarker.position)
        routeMapView.animate(toZoom: 12.5)
        for i in stations{
            i.mapMarker.icon = GMSMarker.markerImage(with: UIColor.green)
            i.mapMarker.map = routeMapView
            
            path.add(i.mapMarker.position)
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.geodesic = true
        polyline.map = routeMapView
        polyline.strokeColor = UIColor.red
    }
    
    

    @IBOutlet weak var seeRouteDetailButton: UIButton!
    {
        didSet {
            seeRouteDetailButton.addTarget(self, action: #selector(onSeeRouteDetailPressed), for: .touchUpInside)
        }
    }
    
    func onSeeRouteDetailPressed(button: UIButton) {
       self.performSegue(withIdentifier: "seeRouteDetailSegue", sender: self)
    }
   
    @IBOutlet weak var changeRouteButton: UIButton!
        {
        didSet {
            changeRouteButton.addTarget(self, action: #selector(onChangeRouteButtonPressed), for: .touchUpInside)
        }
    }
    
    func onChangeRouteButtonPressed(button: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seeRouteDetailSegue") {
                let destination = segue.destination as! RouteDetailViewController
                destination.bus = bus
                destination.stations = stations
        }
    }
}


