//
//  DirectionViewController.swift
//  BusRoute
//
//  Created by ALLAN CHAI on 28/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import SwiftyJSON

class DirectionViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!{
        didSet{
            mapView.delegate = self
        }
    }
    
    //tableView
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    let currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(3.1349378, 101.6299155)
    let currentLocationMarker = GMSMarker()
    
    
    var navi : [Path] = []
    var allPolylines = [GMSPolyline]()
    var selectedIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 99.0
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        //filter
        let bound = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(2.88, 101.50), coordinate: CLLocationCoordinate2DMake(3.26, 101.90))
        
        resultsViewController?.autocompleteBounds = bound
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = "my"
        
        resultsViewController?.autocompleteFilter = filter
        
        //added
        navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .top
        
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
        
        
        //map and marker, current location
        let camera = GMSCameraPosition.camera(withTarget: currentLocation , zoom: 15.0)
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        
        setCurrentLocationMarker()
        
        
        //mapView.accessibilityElementsHidden = false
        //mapView.isMyLocationEnabled = true
        //mapView.mapType = kGMSTypeHybrid
    }
    
    func GoToLocation(location : CLLocationCoordinate2D){
        
    }
    
    func GoToLocation(placeId : String){
        
        let key = "AIzaSyAk9kdX63lh_xDBw36P5edBiAcduVe4J4A"
        let mode = "transit"
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "place_id:\(placeId)"
        let url = URL(string:"https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&alternatives=true&mode=\(mode)&transit_mode=bus&key=\(key)")
        
        print(url)
        
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
                let json = JSON(data: data)
                
                if json["status"].stringValue != "OK" {
                    // "ZERO_RESULTS"
                    return
                }
                let routes = json["routes"]
                
                self.allPolylines = []
                for route in routes{
                    
                    let newPath = Path(json: route.1)
                    
                    self.navi.append(newPath)
                }
                
                DispatchQueue.main.async {
                    self.showPath()
                }
                
                
            } catch let error as NSError {
                print(error)
            }
            
            
        }).resume()
        
        
    }
    
    func setCurrentLocationMarker(){
        currentLocationMarker.position = currentLocation
        currentLocationMarker.title = "You Are Here"
        currentLocationMarker.icon = GMSMarker.markerImage(with: UIColor.black)
        currentLocationMarker.map = mapView
        
        //mapView.selectedMarker = currentLocationMarker
    }
    
    func showPath(){
        for i in navi{
            let path = GMSPath(fromEncodedPath: i.overviewPolyline)
            
            let polyline = GMSPolyline(path: path)
            polyline.title = "route \(i)"
            polyline.strokeWidth = 5.0
            polyline.geodesic = true
            polyline.strokeColor = UIColor.randonColor().withAlphaComponent(0.4)
            polyline.isTappable = true
            polyline.map = mapView
            
            allPolylines.append(polyline)
            
        }
        
        print("paths found : \(allPolylines.count)")
        
        tableView.reloadData()
    }
    
    func selectNewPath(newIndex : Int){
        
        //deselect
        let previousIndexPath = IndexPath(row: selectedIndex, section: 0)
        let deselectedPolyline = allPolylines[selectedIndex]
        deselectedPolyline.map = nil
        deselectedPolyline.strokeColor = deselectedPolyline.strokeColor.withAlphaComponent(0.4)
        deselectedPolyline.map = mapView
        
        tableView.deselectRow(at: previousIndexPath, animated: true)
        
        //select
        let newIndexPath = IndexPath(row: newIndex, section: 0)
        let selectedPolyline = allPolylines[newIndex]
        selectedPolyline.map = nil
        selectedPolyline.strokeColor = deselectedPolyline.strokeColor.withAlphaComponent(1.0)
        selectedPolyline.map = mapView
        
        tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .middle)
        
        let path = navi[selectedIndex]
        let bound = GMSCoordinateBounds(coordinate: path.southwest, coordinate: path.northeast)
        let update = GMSCameraUpdate.fit(bound, withPadding: 20.0)
        mapView.moveCamera(update)
        
        
        
        selectedIndex = newIndex
        
    }
}

// Handle the user's selection.
extension DirectionViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place coordinate: \(place.coordinate)")
        
        //reset map
        selectedIndex = 0
        mapView.clear()
        setCurrentLocationMarker()
        let bound = GMSCoordinateBounds(coordinate: currentLocation, coordinate: place.coordinate)
        let update = GMSCameraUpdate.fit(bound, withPadding: 20.0)
        mapView.moveCamera(update)
        allPolylines = []
        navi = []
        tableView.reloadData()
        
        GoToLocation(placeId: place.placeID)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}

extension DirectionViewController : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        print(overlay.title)
        
        if let poly = overlay as? GMSPolyline{
            
            if let index = allPolylines.index(of: poly){
                selectNewPath(newIndex: index)
            }
        }
    }
    
}


extension DirectionViewController : UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPolylines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            else { return UITableViewCell() }
        
        let temp = navi[indexPath.row]
        let str = "Distance : \(temp.distance) arrived in: \(temp.duration)"
        var str2 = ""
        for step in temp.steps{
            str2 += ("\(step.travelMode) \(step.distance) ->")
        }
        cell.textLabel?.text = str
        cell.detailTextLabel?.text = str2
        
        cell.selectionStyle = .gray
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectNewPath(newIndex: indexPath.row)
    }
    
    
}

