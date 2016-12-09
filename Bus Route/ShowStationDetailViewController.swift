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
    @IBOutlet weak var temp2Label: UILabel!
    
    var frDBref : FIRDatabaseReference!
     var numberOfpreviousStation = 0
    var numberOfnextStation = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frDBref = FIRDatabase.database().reference()
        fetchData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    func fetchData() {
    let routesID = "route0049"
    let stationID = "ChIJG38s6Nw1zDERcPotrSj5sVY"
   
        
        frDBref.child("routes").child(routesID).child("orderedStations").observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let stationArray = snapshot.value as? [String]
                else {
                    
                    return
            }
            
            
            let index = stationArray.index(of: stationID)
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
            self.temp2Label.text = "\(self.numberOfnextStation)"
    
    })
    }

}
