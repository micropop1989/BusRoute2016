//
//  BusViewController.swift
//  BusRoute
//
//  Created by ALLAN CHAI on 28/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class BusViewController: UIViewController {

    @IBOutlet weak var busTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var buses : [Bus] = []
    var filterBuses : [Bus] = []
    var frDBref : FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frDBref = FIRDatabase.database().reference()
        
        busTableView.delegate = self
        busTableView.dataSource = self
        
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.definesPresentationContext = true
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        navigationItem.titleView = searchController.searchBar
        
        
        busTableView.tableFooterView = UIView()
        busTableView.rowHeight = UITableViewAutomaticDimension
        busTableView.estimatedRowHeight = 99.0
        
        fetchBus()
     
        //frDBref.observe(.childAdded, with: {(snapshot) in
        //})

        
    }

    
    func filterContentForSearchText(searchText: String)
    {
        filterBuses = []
        
        if searchText == ""{
            filterBuses = buses
        }
        else{
            filterBuses = buses.filter ({ bus in
               
                return (bus.busNumber!.lowercased().contains(searchText.lowercased())) || (bus.busTitle!.lowercased().contains(searchText.lowercased()))
                
            })
        }
        
        self.busTableView.reloadData()
        
    }
    
    func fetchBus() {
        
        frDBref.child("routes").observe(.childAdded, with: {(snapshot) in
            let newBus = Bus()
            guard let busId = snapshot.key as? String
                else {
                    return
            }
            guard let busDictionary = snapshot.value as? [String : AnyObject]
                else
            {
                return
            }
           
            let busUid = busId
            newBus.routeID = busUid
            newBus.busNumber = busDictionary["line"] as? String
            newBus.busTitle = busDictionary["direction"] as? String
            
            self.buses.append(newBus)
            
            self.busTableView.reloadData()
            
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "busRouteSegue") {
            guard let selectedIndexPath : IndexPath = busTableView.indexPathForSelectedRow else {
                return
            }
            
            let seletedBus : Bus
            
            if searchController.isActive && searchController.searchBar.text != ""
            {
                seletedBus = filterBuses[selectedIndexPath.row]
            }
            else
            {
                seletedBus = buses[selectedIndexPath.row]
            }

            let destination = segue.destination as! BusRouteViewController
            destination.bus = seletedBus
        }
    }
}


extension BusViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "busRouteSegue", sender: self)
    }
}


extension BusViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""
        {
            return filterBuses.count
        }
        else
        {
            return buses.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let busCell : BusTableViewCell = tableView.dequeueReusableCell(withIdentifier: "busCell", for: indexPath) as? BusTableViewCell else {
            return UITableViewCell()
            
        }
        
        let bus: Bus
        if searchController.isActive && searchController.searchBar.text != ""
        {
            bus = filterBuses[indexPath.row]
        }
        else
        {
            bus = buses[indexPath.row]
        }
       // let bus = buses[indexPath.row]
        busCell.busNumberLabel.text = bus.busNumber!
        busCell.busDestinationLabel.text = bus.busTitle!
        print(bus.busNumber!)
        return busCell
    }
    
}

extension BusViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar)
    {
        filterContentForSearchText(searchText: searchBar.text!)
    }
    
    
}

extension BusViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchText: searchController.searchBar.text!)
}
}
