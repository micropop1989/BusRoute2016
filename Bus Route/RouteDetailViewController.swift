//
//  RouteDetailViewController.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 29/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RouteDetailViewController: UIViewController {
    var bus : Bus?
    var stations : [Station] = []
    var frDBref : FIRDatabaseReference!
    
    @IBOutlet weak var routeTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\((bus?.busNumber)!)"
       routeTableView.delegate = self
        routeTableView.dataSource = self
        
        frDBref = FIRDatabase.database().reference()
        
        
        routeTableView.tableFooterView = UIView()
        routeTableView.rowHeight = UITableViewAutomaticDimension
        routeTableView.estimatedRowHeight = 99.0
        
        
        fetchRoute()
    }
    
    func fetchRoute() {
        
        
        guard let routeID = bus?.routeID
            else{ return}
       // let routeID = "route0232"
    frDBref.child("routes").child(routeID).child("orderedStations").observe(.value, with: { (routeSnapshot) in
            
            guard let routeDictionary = routeSnapshot.value as? [String]
                else {
                    
                    return
            }
            
            for station in routeDictionary {
                
                self.frDBref.child("stations").child(station).observe(.value, with: { (stationSnapshot) in
                    let newStation = Station()
                    guard let stationDictionary = stationSnapshot.value as? [String : AnyObject]
                        else {
                            return
                    }
                    newStation.stationID = station
                    
                    newStation.address = stationDictionary["address"] as? String
                    self.stations.append(newStation)
                    self.routeTableView.reloadData()
                    
                    })
        
                }

    })
    }
}

extension RouteDetailViewController: UITableViewDelegate {
    
}

extension RouteDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.row == 0 {
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "RouteDetailTitleCell",
                                                     for: indexPath) as! RouteTitleCell
              titleCell.busTitleLabel.text = bus?.busTitle
            return titleCell
            } else  {
            
            let routeCell = tableView.dequeueReusableCell(withIdentifier: "RouteCell",
                                                          for: indexPath) as! RouteTableViewCell
            let station = stations[indexPath.row-1]
            routeCell.IDLabel.text = station.stationID
            routeCell.routeLabel.text = station.address
            return routeCell
            
        }
    }
}
