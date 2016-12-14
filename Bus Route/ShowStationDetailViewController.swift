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
    
    @IBOutlet weak var nextStationLabel: UILabel!
   
    var routesID : String?
    var stationID = "ChIJG38s6Nw1zDERcPotrSj5sVY"
    
    
    @IBOutlet weak var stationCollectionView: UICollectionView! {
        didSet {
            stationCollectionView.dataSource = self
            stationCollectionView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//stationID = id!
//        routesID = (bus?.routeID)!
        
        frDBref = FIRDatabase.database().reference()
        nextStationLabel.textColor = UIColor.dodgerBlue
      //  fetchData()
        fetchStation()
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
            
            
            //print("Hi \(self.numberOfpreviousStation)")
            self.temp1Label.textColor = UIColor.dodgerBlue
            self.temp1Label.text = "This Station are \(index!+1)th stations"
            
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
                    self.stationCollectionView.reloadData()
                
                
                    //dispatchGp.leave()
                })
            }
            
        })
    }
    
}

extension ShowStationDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : RouteStationCollectionViewCell
        
        
        if let dequeueCell = collectionView.cellForItem(at: indexPath) as? RouteStationCollectionViewCell{
            cell = dequeueCell
        }
        else{
            guard let dequeueCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? RouteStationCollectionViewCell
                else{ return UICollectionViewCell() }
            cell = dequeueCell
        }
        
        let stop = stations[indexPath.row]
        
        cell.nameLabel.text = stop.address
        //cell.nameLabel.text = stop.stationID
        cell.leftImage.isHidden = false
        cell.rightImage.isHidden = false
        
        if indexPath.row == 0 {
            cell.leftImage.isHidden = true
        }
        if indexPath.row == stations.count - 1 {
            cell.rightImage.isHidden = true
        }
        
        cell.dotImage.image = UIImage(named: "dotWithScp")
        if cell.isSelected {
            cell.dotImage.image = UIImage(named: "dot")
        }
        
        return cell
    }
    
    

}

extension ShowStationDetailViewController: UICollectionViewDelegate {
    
}
