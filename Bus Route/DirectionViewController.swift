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
    
//    //tableView
//    @IBOutlet weak var tableView: UITableView!{
//        didSet{
//            tableView.delegate = self
//            tableView.dataSource = self
//        }
//    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
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
    
    var routeBound = GMSCoordinateBounds()
    
    var heightConstraint = NSLayoutConstraint()
    
    let padding = UIEdgeInsets(top: 30, left: 10, bottom: 100, right: 10)
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var routeDetailsLabel: UILabel!
    
    
    let destinationMarker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.tableFooterView = UIView()
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 99.0
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.view.alpha = 0.95
        
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        searchController?.searchBar.placeholder = "Where do you want to go?"

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
        //loadNibFile()
    }
    
    @IBOutlet weak var RouteView: UIView! {
        didSet{
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            RouteView?.addGestureRecognizer(panGesture)
        }
    }
    
    func loadNibFile() -> RouteDetailsView?{
        //custome marker
        let loadedView = Bundle.main.loadNibNamed("RouteDetailsView", owner: self, options: nil)
        if loadedView?.count == 0{
            return nil
        }else{
            return loadedView?.first as? RouteDetailsView
        }
    }

    
    var allowPanGesture = true
    
    @IBAction func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: RouteView)
            
            if allowPanGesture {
            if translation.x < -25 && selectedIndex < navi.count - 1 {
                selectNewPath(newIndex: selectedIndex+1)
                allowPanGesture = false
            }else if translation.x > 25 && selectedIndex > 0 {
                selectNewPath(newIndex: selectedIndex-1)
                allowPanGesture = false
            }
                
                
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: RouteView)

        }
        else if gestureRecognizer.state == .ended {
            allowPanGesture = true
        }
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for constraint in RouteView.constraints {
            if (constraint.identifier == "heightConstraint") {
                heightConstraint = constraint
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNaviDetails" {
            let vc = segue.destination as! NaviDetailsViewController
            vc.path = navi[selectedIndex]
        }
    }
//    var routeDetailsView : RouteDetailsView?
    
//    func loadNibFile(){
//        //custome marker
//        let loadedView = Bundle.main.loadNibNamed("RouteDetailsView", owner: self, options: nil)
//        if loadedView?.count == 0{
//            routeDetailsView = nil
//        }else{
//            routeDetailsView = loadedView?.first as? RouteDetailsView
//            routeDetailsView?.delegate = self
//        }
//    }

    @IBAction func goButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showNaviDetails", sender: self)
    }
    
    func GoToLocation(location : CLLocationCoordinate2D){
        
    }
    
    func GoToLocation(placeId : String){
        
        let key = "AIzaSyAk9kdX63lh_xDBw36P5edBiAcduVe4J4A"
        let mode = "transit"
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "place_id:\(placeId)"
        let url = URL(string:"https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&alternatives=true&mode=\(mode)&transit_mode=bus&key=\(key)")
        
        //print(url)
        
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
        currentLocationMarker.icon = UIImage(named: "currentPosition")   //GMSMarker.markerImage(with: UIColor.black)
        currentLocationMarker.map = mapView
        
        //mapView.selectedMarker = currentLocationMarker
    }
    
    func setDestinationMarker(location : CLLocationCoordinate2D){
        destinationMarker.position = location
        destinationMarker.icon = UIImage(named: "start")  //GMSMarker.markerImage(with: UIColor.orange)
        destinationMarker.map = mapView
    }
    
    func showPath(){
        routeBound = GMSCoordinateBounds()
        
        var x : CGFloat = 0
        
        for i in navi{
            let path = GMSPath(fromEncodedPath: i.overviewPolyline)
            
            let polyline = GMSPolyline(path: path)
            polyline.title = "route \(i)"
            polyline.strokeWidth = 5.0
            polyline.geodesic = true
            polyline.strokeColor = UIColor.deepSkyBlue.withAlphaComponent(0.5)
            polyline.isTappable = true
            polyline.map = mapView
            
            allPolylines.append(polyline)
            
            
            routeBound = routeBound.includingCoordinate(i.southwest)
            routeBound = routeBound.includingCoordinate(i.northeast)
        }

        
       // print("paths found : \(allPolylines.count)")
      //  tableView.reloadData()
        
        heightConstraint.constant = 190.0
        
        if navi.count > 0 {
            selectNewPath(newIndex: 0)
        }
        
        collectionView.reloadData()
        
        
        
    }
    
    func selectNewPath(newIndex : Int){
        
        //deselect
        let previousIndexPath = IndexPath(row: selectedIndex, section: 0)
        let deselectedPolyline = allPolylines[selectedIndex]
        deselectedPolyline.map = nil
        deselectedPolyline.strokeColor = UIColor.deepSkyBlue.withAlphaComponent(0.5)//deselectedPolyline.strokeColor.withAlphaComponent(0.4)
        deselectedPolyline.map = mapView
        
        //collectionView.deselectItem(at: previousIndexPath, animated: true)
        let deselectedCell = collectionView.cellForItem(at: previousIndexPath) as? RouteCollectionViewCell
        deselectedCell?.backgroundColor = UIColor.deepSkyBlue.withAlphaComponent(0.5)    
        //select
        let newIndexPath = IndexPath(row: newIndex, section: 0)
        let selectedPolyline = allPolylines[newIndex]
        selectedPolyline.map = nil
        selectedPolyline.strokeColor = UIColor.dodgerBlue //.withAlphaComponent(0.4) //deselectedPolyline.strokeColor.withAlphaComponent(1.0)
        selectedPolyline.map = mapView
        
        //collectionView.selectItem(at: newIndexPath, animated: true, scrollPosition: .middle)

        //        let path = navi[selectedIndex]
        //        let bound = GMSCoordinateBounds(coordinate: path.southwest, coordinate: path.northeast)
        
        let selectedCell = collectionView.cellForItem(at: newIndexPath) as? RouteCollectionViewCell
        selectedCell?.backgroundColor = UIColor.dodgerBlue

        
        let update = GMSCameraUpdate.fit(routeBound, with: padding)
        
        mapView.moveCamera(update)
        
        
        
        selectedIndex = newIndex
        
        updateDetailsView(index: selectedIndex)
    }
    
    func updateDetailsView(index : Int){
        let temp = navi[index]
        durationLabel.text =  temp.duration
        distanceLabel.text = temp.distance
        
        var str2 = ""
        
        for sv in routeDetailsLabel.subviews{
            sv.removeFromSuperview()
        }
        
        let numOfSlot = Int(view.frame.size.width / 100)
        
        for i in 0..<min(numOfSlot,temp.steps.count){
            let step = temp.steps[i]
            str2 += ("\(step.travelMode) \(step.distance) ->")
            let routeDetailView = loadNibFile()
            routeDetailView?.typeImageView.image = UIImage(named: step.travelMode)
            routeDetailView?.timeLabel.text = step.duration

            if i == temp.steps.count - 1{
                routeDetailView?.nextImageView.image = nil
            }
            else if i == numOfSlot-1{
                if (temp.steps.count <= numOfSlot){
                    routeDetailView?.nextImageView.image = nil
                }
                else{
                    routeDetailView?.nextImageView.image = UIImage(named: "more")
                }
            }else{
                routeDetailView?.nextImageView.image = UIImage(named: "next")
            }
            
            let rect = CGRect(x: 100 * i, y: 0, width: 100, height: 55)
            routeDetailView?.frame = rect
            routeDetailsLabel.addSubview(routeDetailView!)
        }
        
        //routeDetailsLabel.text = str2
        
        
        
        
    }
}

// Handle the user's selection.
extension DirectionViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
//        print("Place coordinate: \(place.coordinate)")
        
        //reset map
        selectedIndex = 0
        mapView.clear()
        setCurrentLocationMarker()
        let bound = GMSCoordinateBounds(coordinate: currentLocation, coordinate: place.coordinate)
        //let update = GMSCameraUpdate.fit(bound, withPadding: 30.0)
        setDestinationMarker(location: place.coordinate)
        
        let update = GMSCameraUpdate.fit(bound, with: padding)
        mapView.moveCamera(update)
        allPolylines = []
        navi = []
        //tableView.reloadData()
        collectionView.reloadData()
        
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
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.animate(toLocation: currentLocation)
        return true
    }
}


//extension DirectionViewController : UITableViewDataSource , UITableViewDelegate{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return navi.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell : directionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? directionTableViewCell
//            else { return UITableViewCell() }
//        
//        let temp = navi[indexPath.row]
//        let str = "Distance : \(temp.distance) arrived in: \(temp.duration)"
//        var str2 = ""
//        for step in temp.steps{
//            str2 += ("\(step.travelMode) \(step.distance) ->")
//        }
//        // cell.textLabel?.text = str
//        cell.distanceLabel.text = temp.distance
//        cell.arrivedLabel.text = temp.duration
//        cell.tempLabel.text = str2
//        // cell.detailTextLabel?.text = str2
//        
//        cell.selectionStyle = .gray
//        
//        return cell
//    }
//    
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.selectNewPath(newIndex: indexPath.row)
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        
//        if tableView.numberOfRows(inSection: section) == 0 {
//            return nil
//        }
//        
//        let frameSize = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
//        let footerView = UIView(frame: frameSize)
//        
//        let button = UIButton(frame: frameSize)
//        
//        if tableView.numberOfRows(inSection: section) > 0 {
//            
//            button.setTitle("GO", for: .normal)
//            button.backgroundColor = UIColor.green
//            button.addTarget(self, action: #selector(self.goPressed), for: .touchUpInside)
//        }
////        }else{
////            button.setTitle("Search...", for: .normal)
////            button.backgroundColor = UIColor.red
////            button.addTarget(self, action: #selector(self.searchPressed), for: .touchUpInside)
////        }
//        
//        button.layer.borderWidth = 2.0
//        button.layer.borderColor = UIColor.black.cgColor
//        
//        button.titleLabel?.font = button.titleLabel?.font.withSize(30.0)
//        
//        
//        footerView.addSubview(button)
//        
//        return footerView
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 40.0
//    }
//    
//    
//    func searchPressed(){
//        print("search")
//    }
//    
//    func goPressed(){
//        print("Go")
//        performSegue(withIdentifier: "showNaviDetails", sender: self)
//        
//    }
//    
//}

extension DirectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return navi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteCollectionViewCell", for: indexPath) as! RouteCollectionViewCell
        
        let temp = navi[indexPath.row]
        
        cell.distanceLabel.text = temp.distance
        cell.timeLabel.text = temp.duration
        
        if indexPath.row == selectedIndex{
            cell.backgroundColor = UIColor.dodgerBlue
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectNewPath(newIndex: indexPath.row)
    }
}

