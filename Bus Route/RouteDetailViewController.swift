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
    
    
    var routeID : String?
    

    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var routeTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\((bus?.busNumber)!)"
        destinationLabel.text = "\((bus?.busTitle)!)"
        routeTableView.delegate = self
        routeTableView.dataSource = self
        
        frDBref = FIRDatabase.database().reference()
        
        
        routeTableView.tableFooterView = UIView()
        routeTableView.rowHeight = UITableViewAutomaticDimension
        routeTableView.estimatedRowHeight = 99.0
        
        
        fetchRoute()
    }
    
   
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        if sender.title == "Edit" {
            sender.title = "Save"
            routeTableView.setEditing(true, animated: true)
            
        } else if sender.title == "Save" {
            
            let message: String = "Are you sure you want save route?"
             let alertController = UIAlertController(title: "Save Comfirmation", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                action in
                self.stations = []
                self.fetchRoute()
            })
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                action in
                var stationDictionary : [String] = []
                for station in self.stations {
                    
                    stationDictionary.append(station.stationID!)
                    
                }
                
                self.frDBref.child("routes").child(self.routeID!).child("orderedStations").setValue(stationDictionary)
                
                print(stationDictionary)
                self.routeTableView.setEditing(false, animated: true)
                sender.title = "Edit"
                //stationDictionary = []
                })
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            present(alertController, animated: true, completion: nil)
            
            
            
            
        }
    
    
    }
    
    
    
    
    func fetchRoute() {
        
        
        guard let routeID = bus?.routeID
            else{ return}
        self.routeID = routeID
    
       // let routeID = "route0232"
        frDBref.child("routes").child(routeID).child("orderedStations").observeSingleEvent(of: .value, with: { (routeSnapshot) in
            
            guard let routeDictionary = routeSnapshot.value as? [String]
                else {
                    
                    return
            }
        
        
        
            for station in routeDictionary {
                
                self.frDBref.child("stations").child(station).observeSingleEvent(of: .value, with: { (stationSnapshot) in
                    
                    
                    guard let stationDictionary = stationSnapshot.value as? [String : AnyObject]
                        else {
                            return
                    }
                    
                    let newStation = Station(dict: stationDictionary)
                    newStation.stationID = station
                    //newStation.address = stationDictionary["address"] as? String
                    self.stations.append(newStation)
                    self.routeTableView.reloadData()
                    
                    })
        
                }

    })
    }
}

extension RouteDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}

extension RouteDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
            
            let routeCell = tableView.dequeueReusableCell(withIdentifier: "RouteCell",
                                                          for: indexPath) as! RouteTableViewCell
            let station = stations[indexPath.row]
            routeCell.IDLabel.text = station.stationID
            routeCell.routeLabel.text = station.address
            return routeCell
            
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
        

    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let station : Station = stations[sourceIndexPath.row]
        stations.remove(at: sourceIndexPath.row)
        stations.insert(station, at: destinationIndexPath.row)
        
        
    }
    
    
    
    
}
