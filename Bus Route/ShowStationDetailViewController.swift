//
//  ShowStationDetailViewController.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 09/12/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ShowStationDetailViewController: UIViewController {

    @IBOutlet weak var temp1Label: UILabel!
   // @IBOutlet weak var temp2Label: UILabel!
    
    var frDBref : FIRDatabaseReference!
     var numberOfpreviousStation = 0
    var numberOfnextStation = 0
    var stations : [Station] = []
    var bus : Bus?
    var id : String?
    var delegate: ShowStationDetailViewControllerDelegate?
    
   // @IBOutlet weak var nextStationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.addTarget(self, action: #selector(onCloseButtonPressed), for: .touchUpInside)
        }
    }
    
    func handleTap(tapGesture: UITapGestureRecognizer) {
        delegate?.close(viewController: self)
    }
    
    func onCloseButtonPressed(button: UIButton) {
        delegate?.close(viewController: self)
    }
    
    @IBOutlet weak var nextStationtitleLabel: UILabel!
   
    var routesID : String?
    var stationID = "ChIJG38s6Nw1zDERcPotrSj5sVY"
    
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//stationID = id!
//        routesID = (bus?.routeID)!
        setTitleLable()
       // setCloseButton()
        
        frDBref = FIRDatabase.database().reference()
        nextStationtitleLabel.textColor = UIColor.dodgerBlue
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 99.0
      //  fetchData()
        fetchStation()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

   /* func fetchData() {
        frDBref.child("routes").child(routesID).child("orderedStations").observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let stationArray = snapshot.value as? [String]
                else {
                    
                    return
            }
            
            
            let index = stationArray.index(of: self.stationID)
            let lastindex = stationArray.count
            let stationBefore : String
            let stationAfter  : String
            
            if (index == 0) {
                stationAfter = stationArray[index! + 1]
            }
            else if (index == lastindex) {
                stationBefore = stationArray[index! - 1]
            } else {
                stationBefore = stationArray[index! - 1]
                stationAfter = stationArray[index! + 1]
            }
            
            
            
            
            self.numberOfnextStation = stationArray.count-index!-1
            
            
            print("Hi \(self.numberOfpreviousStation)")
            self.temp1Label.text = "This Station are \(index!+1)th stations"
           // self.temp2Label.text = "\(self.numberOfnextStation)"
    
    })
    } */
    
    func fetchStation() {
        frDBref.child("routes").child(routesID!).child("orderedStations").observeSingleEvent(of: .value, with: { (routeSnapshot) in
            guard let stationArray = routeSnapshot.value as? [String]
                else {
                    
                    return
            }
            
            let index = stationArray.index(of: self.stationID)
            let lastindex = stationArray.count
          //  let stationBefore : String
            //let stationAfter  : String
            
          /*  if (index == 0) {
                stationAfter = stationArray[index! + 1]
            }
            else if (index == lastindex) {
                stationBefore = stationArray[index! - 1]
            } else {
                stationBefore = stationArray[index! - 1]
                stationAfter = stationArray[index! + 1]
            }
            
            
            */
            
            self.numberOfnextStation = stationArray.count-index!-1
            
            
            //print("Hi \(self.numberOfpreviousStation)")
            self.temp1Label.textColor = UIColor.dodgerBlue
            if index == lastindex-1 {
                self.temp1Label.text = "This Station is LAST station"
                self.nextStationtitleLabel.text = "No station will Display"
            } else if index == 0  {
                self.temp1Label.text = "This Station is 1st station"
                self.nextStationtitleLabel.text = "Next Station :"
            } else if index == 1 || index == 2{
                self.temp1Label.text = "This Station is \(index!+1)nd stations"
                self.nextStationtitleLabel.text = "Next Station :"
            } else {
            self.temp1Label.text = "This Station is \(index!+1)th stations"
                self.nextStationtitleLabel.text = "Next Station :"
            }
            
            for station in  stationArray {
                
              //  dispatchGp.enter()
                
                self.frDBref.child("stations").child(station).observeSingleEvent(of: .value, with: { (stationSnapshot) in
                    
                    
                    guard let stationDictionary = stationSnapshot.value as? [String : AnyObject]
                        else {
                           
                            return
                    
                    }
                    
                    let newStation = Station(dict: stationDictionary)
                    if stationArray.index(of: station)! > index! {
                        
                         newStation.stationID = station
                    //newStation.address = stationDictionary["address"] as? String
                         self.stations.append(newStation)
                        
                    }
                    self.tableView.reloadData()
                
                
                    //dispatchGp.leave()
                })
            }
            
        })
    }
    
    
    func fetchtime() {
        frDBref.child("time").child(routesID!).child("orderedStations").observeSingleEvent(of: .value, with: { (timeSnapshot) in
            
            guard let stationArray = timeSnapshot.value as? [String]
                else {
                    
                    return
            }
            
            let index = stationArray.index(of: self.stationID)
            let lastindex = stationArray.count
            
            for station in  stationArray {
                
                //  dispatchGp.enter()
                
                        if stationArray.index(of: station)! > index! {
                      //  newStation.stationID = station
                        //newStation.address = stationDictionary["address"] as? String
                       // self.stations.append(newStation)
                    }
                    self.tableView.reloadData()
                    
                    
                    //dispatchGp.leave()
               
            
            
        }
        })
    }
}



extension ShowStationDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : RouteTableViewCell
        
        if let dequeueCell = tableView.cellForRow(at: indexPath) as?
            RouteTableViewCell {
            cell = dequeueCell
        }
        
        
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as! RouteTableViewCell
        }
        
        let station = stations[indexPath.row]
        // routeCell.IDLabel.text = station.stationID
        
        cell.routeLabel.text = station.address
        cell.selectionStyle = .none
        
        cell.upperRouteImage.isHidden = false
        cell.lowerRouteImage.isHidden = false
        
        if indexPath.row == 0 {
            cell.upperRouteImage.isHidden = true
        }
        if indexPath.row == self.stations.count-1 {
            cell.lowerRouteImage.isHidden = true
        }
        
        cell.dotImage.image = UIImage(named: "dotWithScp")!
       // if indexPath == selectedIndexPath {
         //   cell.dotImage.image = UIImage(named: "dot")!
        
        
        return cell

    }
    
    
    
    func setTitleLable() {
        titleLabel.backgroundColor = UIColor.dodgerBlue
        titleLabel.textColor = UIColor.white
        
    }
    
    func setCloseButton() {
        closeButton.layer.borderColor = UIColor.dodgerBlue.cgColor
        closeButton.layer.borderWidth = 2
        closeButton.tintColor = UIColor.dodgerBlue
        closeButton.layer.cornerRadius =    5
    }

}

extension ShowStationDetailViewController: UITableViewDelegate {
    
}


protocol ShowStationDetailViewControllerDelegate {
    func close(viewController: ShowStationDetailViewController)
}
