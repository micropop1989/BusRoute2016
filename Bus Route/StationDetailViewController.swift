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
import GoogleMaps

class StationDetailViewController: UIViewController {

    @IBOutlet weak var stationDetailTable: UITableView!
    var frDBref : FIRDatabaseReference!
    var buses : [Bus] = []
    var stationID = "ChIJDYS7S8BJzDER9sEkA4CN5tk"
    var station : Station?
   
    @IBOutlet weak var streetView: GMSPanoramaView! {
        didSet{
            streetView.delegate = self
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
      stationDetailTable.delegate = self
      stationDetailTable.dataSource = self
      
  //    ShowStationDetailViewController.delegate = self
   frDBref = FIRDatabase.database().reference()
        
        stationDetailTable.tableFooterView = UIView()
        stationDetailTable.rowHeight = UITableViewAutomaticDimension
        stationDetailTable.estimatedRowHeight = 99.0
        
        stationDetailTable.separatorColor = .blue
        
        streetView.moveNearCoordinate((station?.mapMarker.position)!, radius: 100)
        station?.mapMarker.panoramaView = streetView
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        guard let id = station?.stationID
            else{ return }
        
        stationID = id

        fetchRoute()
        
    }

    func fetchRoute() {
            buses = []
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
                    newBus.routeID = routeKey as? String
                    self.buses.append(newBus)
                    self.stationDetailTable.reloadData()
                    
                    
                })
                
                //read from station -> route -> line:direction
                
                
            }
          
            
            
            
        })
        
    }
}


extension StationDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        let controller = storyboard?.instantiateViewController(withIdentifier: "ShowStationDetailViewController") as! ShowStationDetailViewController
        
        if indexPath.row == 0 {
            
        } else {
        
        
        controller.stationID = stationID
        controller.routesID = buses[indexPath.row-1].routeID
        controller.delegate = self
        
        
        
        addChildViewController(controller)
        let height : CGFloat = self.view.frame.height * 0.5
        //controller.view.frame = CGRect(x: 0, y: height-150, width: self.view.frame.width, height: height)
        controller.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
        view.addSubview((controller.view)!)
        controller.didMove(toParentViewController: self)
        }
       
    }
    
    
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
                
                titleCell.stationLabel.text = "\(stat.address!)"
                titleCell.selectionStyle = UITableViewCellSelectionStyle.none
            }
            
            return titleCell
        } else  {
            
            let busCell = tableView.dequeueReusableCell(withIdentifier: "busCell",
                                                          for: indexPath) as! StationDetailTableViewCell
            let bus = buses[indexPath.row-1]
            busCell.busNumberLabel.text = bus.busNumber
            busCell.busTitleLabel.text = bus.busTitle
            //busCell.selectionStyle = UITableViewCellSelectionStyle.default
            return busCell
            
        }

    }
}

extension StationDetailViewController: ShowStationDetailViewControllerDelegate {
    func close(viewController: ShowStationDetailViewController) {
     viewController.willMove(toParentViewController: nil)
     viewController.view.removeFromSuperview()
     viewController.removeFromParentViewController()
    }
}


extension StationDetailViewController : GMSPanoramaViewDelegate {
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama, nearCoordinate coordinate: CLLocationCoordinate2D) {
        
        let heading = calculateHeading(form: panorama.coordinate, to: coordinate)
        view.camera = GMSPanoramaCamera(heading: heading, pitch: 0, zoom: 0)
    }
}
