//
//  StationDetailViewController.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 30/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class StationDetailViewController: UIViewController {

    @IBOutlet weak var stationDetailTable: UITableView!
    var frDBref : FIRDatabaseReference!
    var buses : [Bus] = []
    var stationID = "ChIJDYS7S8BJzDER9sEkA4CN5tk"
    var station : Station?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      stationDetailTable.delegate = self
      stationDetailTable.dataSource = self
      frDBref = FIRDatabase.database().reference()
        
        stationDetailTable.tableFooterView = UIView()
        stationDetailTable.rowHeight = UITableViewAutomaticDimension
        stationDetailTable.estimatedRowHeight = 99.0
        
        stationDetailTable.separatorColor = .blue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let id = station?.stationID
            else{ return }
        
        stationID = id

        fetchRoute()
        
    }

    func fetchRoute() {

        frDBref.child("stations").child(stationID).child("route").observeSingleEvent(of: .value, with: { (routeSnapshot) in
            
            guard let routeDictionary = routeSnapshot.value as? [String: AnyObject]
                else {
                    
                    return
            }
            
            

            for (routeKey, routeValue) in routeDictionary {
                
                //go to route and fetch line:station
                self.frDBref.child("routes").child(routeKey).observeSingleEvent(of:.value, with: {
                    (busSnapshot) in
                    let newBus = Bus()
                    guard let busDictionary = busSnapshot.value as? [String : AnyObject]
                        else {
                            return
                    }
                    newBus.busNumber = busDictionary["line"] as? String
                    newBus.busTitle = busDictionary["direction"] as? String
                    self.buses.append(newBus)
                    self.stationDetailTable.reloadData()
                    
                    
                })
                
                //read from station -> route -> line:direction
                
                
            }
          
            
            
            
        })
        
    }
}


extension StationDetailViewController: UITableViewDelegate {
    
}

extension StationDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buses.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "stationCell",
                                                          for: indexPath) as! StationTableViewCell
            if let stat = station {
                
                titleCell.stationLabel.text = "Station Name: \(stat.address!)"
            }
            
            return titleCell
        } else  {
            
            let busCell = tableView.dequeueReusableCell(withIdentifier: "busCell",
                                                          for: indexPath) as! StationDetailTableViewCell
            let bus = buses[indexPath.row-1]
            busCell.busNumberLabel.text = bus.busNumber
            busCell.busTitleLabel.text = bus.busTitle
            return busCell
            
        }

    }
}
