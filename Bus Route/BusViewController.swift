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
    
    var container  = UIView()
    var loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // activityIndicator.startAnimating()
        showActivityIndicatory(uiView: self.view)
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
        
        
        //container.isHidden = true
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
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.container.removeFromSuperview()
            
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
    
    
    func showActivityIndicatory(uiView: UIView) {
        container  = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.3)
        //container.isHidden = false
      
        
        loadingView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.dodgerBlue
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator = UIActivityIndicatorView()
       // activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
      
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
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
       
        busCell.busNumberView.layer.borderWidth = 1
        busCell.busNumberView.layer.borderColor = UIColor.dodgerBlue.cgColor
        busCell.busNumberView.layer.cornerRadius = 8.0
        
       
        //print(bus.busNumber!)
        //print(indexPath.row)
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
