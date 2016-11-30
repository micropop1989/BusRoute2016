//
//  StationTableViewController.swift
//  
//
//  Created by ALLAN CHAI on 30/11/2016.
//
//

import UIKit
import Firebase
import FirebaseDatabase


class StationTableViewController: UIViewController {
    @IBOutlet weak var stationTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        stationTable.delegate = self
        stationTable.dataSource = self

        
    }

}

extension StationTableViewController: UITableViewDelegate {
    
}

extension StationTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stationCell : StationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath) as? StationTableViewCell else {
            return UITableViewCell()
            
        }
        
        return stationCell
    

    }
}
