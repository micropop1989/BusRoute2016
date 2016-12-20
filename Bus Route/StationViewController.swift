//
//  StationViewController.swift
//  BusRoute
//
//  Created by ALLAN CHAI on 28/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase
import SwiftyJSON

class StationViewController: UIViewController {
    
    let currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(3.1349378, 101.6299155)
    let currentLocationMarker = GMSMarker()
    
    var filteredStation : [Station] = []
    var mapViewCoordinate = CLLocationCoordinate2D()
    let centermarker = GMSMarker()
    
    var searchNearby = false
    
    var tappedMarker = GMSMarker()
    
    var frDBref2 : FIRDatabaseReference!
    
    var indexToSend = -1
    
    @IBOutlet weak var stationMapView: GMSMapView!{
        didSet{
            stationMapView.delegate = self
        }
    }
    @IBOutlet weak var stationTableView: UITableView!{
        didSet{
            stationTableView.dataSource = self
            stationTableView.delegate = self
            stationTableView.allowsMultipleSelection = false
        }
    }
    
    var markerView : CustomeStationMarkerView?
    
    var allStation : [Station] = []
    
    var minY : CGFloat = 0.0
    var maxY : CGFloat = 0.0
    var headerView : StationTableHeaderView?
    var heightConstraint = NSLayoutConstraint()
    
    var moveDirection : moveTo = .none
    
    
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager  = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        
        self.title = "Station List"
        frDBref2 = FIRDatabase.database().reference()
        loadNibFile()
        
        //stationTableView.tableFooterView = UIView()
        stationTableView.rowHeight = UITableViewAutomaticDimension
        stationTableView.estimatedRowHeight = 300.0
        stationTableView.reloadData()
        
        
        fetchStations()
        
        stationMapView.isMyLocationEnabled = true
        stationMapView.animate(toLocation: currentLocation)
        stationMapView.animate(toZoom: 15.0)
        
        mapViewCoordinate = currentLocation
        
        //marker
        currentLocationMarker.position = currentLocation
        currentLocationMarker.title = "You Are Here"
        currentLocationMarker.icon = GMSMarker.markerImage(with: UIColor.black)
        
        currentLocationMarker.tracksInfoWindowChanges = true
        currentLocationMarker.map = stationMapView
        
        stationMapView.selectedMarker = currentLocationMarker
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        minY = stationMapView.frame.minY
        maxY = stationMapView.frame.maxY - 60.0
        
        getStationTVHeightConstraint()
    }
    
    func loadNibFile(){
        //custome marker
        let loadedView = Bundle.main.loadNibNamed("StationMarker", owner: self, options: nil)
        if loadedView?.count == 0{
            markerView = nil
        }else{
            markerView = loadedView?.first as? CustomeStationMarkerView
            markerView?.shapeImage.alpha = 0.9
            
            markerView?.delegate = self
        }
        
        let loadedView2 = Bundle.main.loadNibNamed("StationTableHeader", owner: self, options: nil)
        if loadedView2?.count == 0{
            headerView = nil
        }else{
            headerView = loadedView2?.first as? StationTableHeaderView
            headerView?.delegate = self
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            headerView?.addGestureRecognizer(panGesture)
        }

    }
    
    func fetchStations(){
        
            self.headerView?.headerLabel.text = "Loading Station data..."
        frDBref2.child("stations").observeSingleEvent(of: .value, with: { (stationSnapshot) in
            
            let enumerator = stationSnapshot.children
            while let singleStationSnapshot = enumerator.nextObject() as? FIRDataSnapshot {
                let stationsId = singleStationSnapshot.key
                let info = singleStationSnapshot.value as! [String:AnyObject]
                
                
                
                let newStation = Station(dict: info)
                newStation.stationID = stationsId
                self.allStation.append(newStation)
                
            }
            
            
            //main tread , sort
            DispatchQueue.main.async {
                self.searchNearby = true
                self.showNearbyBusStation(coordinate: self.currentLocation)
                
            }
        })
        
    }
    
    
    func showNearbyBusStation(coordinate: CLLocationCoordinate2D, delta: Double = 0.01){
        headerView?.headerLabel.text = "Searching for nearby station"
        
        //allStation.sort(by: {$0.lat! > $1.lat!})
        filteredStation = []
        
        filteredStation = allStation.filter { (station) -> Bool in
            guard let lat = station.lat,
                let lng = station.long
                else{return false}
            
            if lat < Double(coordinate.latitude - delta) || lat > Double(coordinate.latitude + delta){
                return false
            }
            else if lng < Double(coordinate.longitude - delta) || lng > Double(coordinate.longitude + delta){
                return false
            }
            
            return true
        }
        
        //print(filteredStation.count)
        stationMapView.clear()
        
        if filteredStation.count == 0
        {
            if delta > 0.01 {
                headerView?.headerLabel.text = "No station found"
                return
            }
            
            showNearbyBusStation(coordinate: coordinate, delta: 0.02)
            return
        }
        //display marker
        for i in 0..<(filteredStation.count) {
            let temp = filteredStation[i]
            temp.mapMarker.userData = i
            temp.mapMarker.icon = UIImage(named: "maker30")
            temp.mapMarker.map = stationMapView
            
        }
        
        centermarker.title = "radar"
        centermarker.isTappable = true
        centermarker.position = coordinate
        //centermarker.icon = GMSMarker.markerImage(with: UIColor.orange)
        let img = UIImage(named: "search")
        let newWidth : CGFloat = 30.0
        let newHeight : CGFloat = 30.0
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        img?.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        centermarker.icon = newImage
        
        
//        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//        view.image = img
//        view.contentMode = .scaleAspectFit
//        UIView.animate(withDuration: 1.0, delay: 0.0, options: .autoreverse, animations: {
//            view.alpha = 0.3
//        }, completion: nil)
//        
//        centermarker.iconView = view
        
        centermarker.map = stationMapView
        
        
        
        currentLocationMarker.map = stationMapView
        
        stationTableView.reloadData()
    }
    
    func selectMarker(at index: Int, marker: GMSMarker){
        //custume marker infowindow
        //superimpose on top
        guard let markerView = markerView
            else { return }
        
  
        
        tappedMarker.panoramaView = nil
        
        
        marker.panoramaView = markerView.paraView
        
        
        markerView.station = filteredStation[index]
        markerView.nameLabel.text = marker.title
       // markerView.distanceLabel.text = marker.snippet
        markerView.paraView.delegate = self
        //markerView.paraView.moveNearCoordinate(marker.position)
        markerView.paraView.moveNearCoordinate(marker.position, radius: 100)
//        //markerView.paraView.panorama?.coordinate
//        markerView.paraView.camera = GMSPanoramaCamera(heading: 180, pitch: 0, zoom: 0)
        //marker.infoWindowAnchor.y = 0.3
        
        //save marker

        
        let location = marker.position
        
        tappedMarker = marker
        
        
        markerView.removeFromSuperview()
        //markerView = mapMarkerInfoWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        markerView.center = stationMapView.projection.point(for: location)
        markerView.center.y -= 120

        markerView.translatesAutoresizingMaskIntoConstraints = true
        stationMapView.addSubview(markerView)
        searchNearby = false
        
        //move map
//        var point = stationMapView.projection.point(for: marker.position)
//        let center = stationMapView.center
//        point.y -= center.y / 2
//        let newLoc = stationMapView.projection.coordinate(for: point)
//        stationMapView.animate(toLocation: newLoc)
        stationMapView.animate(toLocation: marker.position)

    }
    
    
    
    func getStationTVHeightConstraint(){
        for constraint in stationTableView.constraints {
            if (constraint.identifier == "TableHeight") {
                heightConstraint = constraint
                return
            }
        }
    }
}

extension StationViewController : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
//        print("Idle")
//        print(position.target)
        mapViewCoordinate = position.target
        
        if searchNearby {
            showNearbyBusStation(coordinate: mapViewCoordinate)
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //print(position.target)
        
        centermarker.position = position.target
        
        //centermarker.map = stationMapView
        
        //custome info window (move with map)
        markerView?.center = mapView.projection.point(for: tappedMarker.position)
        markerView?.center.y -= 120
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //custome info window
        markerView?.removeFromSuperview()
        searchNearby = true


    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if marker.title == "radar" {
            searchNearby = true
            markerView?.removeFromSuperview()
            showNearbyBusStation(coordinate: marker.position)
            
            return false
        }
        
        stationMapView.selectedMarker = marker
        
        if let data = marker.userData,
            let index = data as? Int {
            let indexPath = IndexPath(row: index, section: 0)
            stationTableView.selectRow(at: indexPath , animated: true, scrollPosition: .middle)
            
            selectMarker(at: index, marker: marker)
        }
        return false
    }
    
    
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        
        //        if let data = marker.userData,
        //            let index = data as? Int {
        //            markerView?.station = filteredStation[index]
        //        }
        //
        //        //return UII
        //
        //        markerView?.nameLabel.text = marker.title
        //        markerView?.distanceLabel.text = marker.snippet
        //        markerView?.paraView.moveNearCoordinate(marker.position)
        //        markerView?.paraView.camera = GMSPanoramaCamera(heading: 180, pitch: 0, zoom: 0.2)
        //        marker.infoWindowAnchor.y = 0.3
        //        return markerView
        
        return UIView()
    }
    
    
    //    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    //
    //    }
}

extension StationViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell : StnTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? StnTableViewCell else {
            return UITableViewCell()
            
        }
        let temp : Station = filteredStation[indexPath.row]
        
        //  cell.textLabel?.text = temp.address
        cell.stationLabel.text = temp.address
        
        let a = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        
        let b = CLLocation(latitude: temp.lat!, longitude: temp.long!)
        
        
        let dist = a.distance(from: b)
        
        var subtitleStr = ""
        if dist < 1000 {
            subtitleStr = "\(String(format: "%0.f00", dist/100))m away"
        }
        else{
            
            subtitleStr = "\(String(format: "%0.1f", dist/1000))km away"
        }
        
        cell.distanceLabel.text = "\(subtitleStr)"
        cell.busNumberLabel.text = "\(temp.buses.count)"
        
        //passesby bus icon
        let width = cell.busIconView.frame.size.width
        //let height = cell.busIconView.frame.size.height
        
        let busView = cell.busIconView
        busView?.subviews.forEach({ $0.removeFromSuperview()})
        
        
        let slotWidth : CGFloat = 60.0
        let slotSpacing : CGFloat = 5.0
        let numberOfSlot = Int((width + slotSpacing) / (slotWidth + slotSpacing))
        
        let num = temp.buses.count
        
        let maxNumberofSlot = min(num,numberOfSlot)
        
        var row  = 0
        
        for index in 0..<maxNumberofSlot {
            
            let col = index % numberOfSlot
            row = index / numberOfSlot
            
            let x =  CGFloat(col) * (slotWidth + slotSpacing)
            let y =  CGFloat(row) * 35.0
            
            let rect = CGRect(x: x , y: y, width: slotWidth, height: 30)
            let lable : UILabel = UILabel(frame: rect)
            
            
            if index == numberOfSlot - 1 && num > numberOfSlot {
                let more = num - numberOfSlot
                lable.text = "\(more + 1) more..."
            }
            else{
                let bus = temp.buses[index]
                lable.text = bus.busNumber
            }
            
            
            lable.textColor = UIColor.dodgerBlue
            lable.layer.borderWidth = 2.5
            lable.layer.borderColor = UIColor.dodgerBlue.cgColor
            lable.layer.cornerRadius = 8.0
            lable.textAlignment = .center
            lable.font = lable.font.withSize(15)
            lable.adjustsFontSizeToFitWidth = true
        
            busView?.addSubview(lable)
            busView?.sizeToFit()
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStation = filteredStation[indexPath.row]
        //stationMapView.selectedMarker = selectedStation.mapMarker

        //stationMapView.animate(toLocation: selectedStation.mapMarker.position)
        
//        var point = stationMapView.projection.point(for: selectedStation.mapMarker.position)
//        
//        let center = stationMapView.center
//        point.y -= center.y / 2
//        
//        let newLoc = stationMapView.projection.coordinate(for: point)
//        stationMapView.animate(toLocation: newLoc)
        
        selectMarker(at: indexPath.row, marker: selectedStation.mapMarker)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            
            if filteredStation.count != 0 {
                headerView?.headerLabel.text = "\(filteredStation.count) station(s) found"
            }
            
            return headerView
        
    }
    
    enum moveTo {
        case top
        case bottom
        case none
    }
    
    
    @IBAction func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            
            let translation = gestureRecognizer.translation(in: stationTableView)
            // note: 'view' is optional and need to be unwrapped
//            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            
            //print(translation)
            let rect = stationTableView.frame
            
            var y = rect.origin.y
            let oriHeight = rect.size.height
            
            print ("\(y)  \(maxY)   \(minY), \(oriHeight)")
            
            if y <= maxY + 0.11 && y >= minY - 0.11 {
                
            y += translation.y
            y = max(minY, y)
            y = min(maxY, y)
                
            let x = rect.origin.x

            let width = rect.size.width
            let height = 60.0 + maxY - y
            let newRect = CGRect(x: x, y: y, width: width, height: height)
            
            stationTableView.frame = newRect
               
                if translation.y < -30 {
                    moveDirection = .top
                }else if translation.y > 30 {
                    moveDirection = .bottom
                }
//            let mapRect = stationMapView.frame
//            let mapOrigin = mapRect.origin
//            let mapWidth = mapRect.width
//            let mapHeight = mapRect.height
//            let mapSize = CGSize(width: mapWidth, height: mapHeight + translation.y)
//            stationMapView.frame = CGRect(origin: mapOrigin, size: mapSize)
                
            
                //move map
                
                
                //var point = stationMapView.projection.point(for: marker.position)
//                let heightDelta = height - oriHeight
//                
//                print(heightDelta)
//                var center = stationMapView.center
//                print(center.y)
//                //center.y = center.y + heightDelta/2
//                print(center.y)
//                let newLoc = stationMapView.projection.coordinate(for: center)
//                
////                stationMapView.animate(toLocation: newLoc)
//                let cam = GMSCameraUpdate.setTarget(newLoc)
//                stationMapView.moveCamera(cam)
                
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: stationTableView)
        }
        
        else if gestureRecognizer.state == .ended {
            
            var height = stationTableView.frame.size.height
            
            switch moveDirection {
            case .top:
                height = maxY - 5.0
                headerView?.headerButton.setTitle("down", for: .normal)
                break
            case .bottom:
                height = 60
                headerView?.headerButton.setTitle("up", for: .normal)
                break
            case .none:
                if height < ((60.0 + maxY)/4) {
                    height = 60
                    headerView?.headerButton.setTitle("up", for: .normal)
                }else if height < ((60.0 + maxY)*3/4) {
                    height = maxY/2
                }else {
                    height = maxY - 5.0
                    
                    headerView?.headerButton.setTitle("down", for: .normal)
                }
                break
            }
            
            moveDirection = .none
            
            let y = 60.0 + maxY - height
            let x = stationTableView.frame.origin.x
            let width = stationTableView.frame.size.width
            let newRect = CGRect(x: x, y: y, width: width, height: height)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.stationTableView.frame = newRect
                self.heightConstraint.constant = height
                self.stationTableView.layoutIfNeeded()
            })
            
            
            
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
}

extension StationViewController : StationMarkerDelegate{
    func showStationDetails() {
        performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"{
            
            let vc = segue.destination as! StationDetailViewController
            vc.station = markerView?.station
            
        } else if segue.identifier == "infoSegue" {
            let vc = segue.destination as! StationDetailViewController
            vc.station = filteredStation[indexToSend]
        }
        
    }
    
    func closeInfoWindowTapped() {
        markerView?.removeFromSuperview()
        searchNearby = true
    }
    
}

extension StationViewController : StationTableHeaderDelegate{
    func tableHeaderButtonPressed(button : UIButton) {
    print ("tapped")
        var height = stationTableView.frame.size.height
        
        if (button.currentTitle! == "down") {
            height = 60
            headerView?.headerButton.setTitle("up", for: .normal)
        } else if (button.currentTitle! == "up"){
            height = maxY - 5.0
            headerView?.headerButton.setTitle("down", for: .normal)
        }else{
            print("error : button error")
        }
        
        
        let y = 60.0 + maxY - height
        let x = stationTableView.frame.origin.x
        let width = stationTableView.frame.size.width
        let newRect = CGRect(x: x, y: y, width: width, height: height)
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .allowAnimatedContent , animations: {
            self.stationTableView.frame = newRect
            self.heightConstraint.constant = height
            self.stationTableView.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func refreashButtonPressed() {
        searchNearby = true
        showNearbyBusStation(coordinate: currentLocation)
    }
}

extension StationViewController : StnTableViewCellDelegate {
    func StnTableViewCellOnInfoButtonPressed(cell: StnTableViewCell) {
        guard let indexPath = stationTableView.indexPath(for: cell)
            else { return }
        indexToSend = indexPath.row
        //let selectedStation = filteredStation[indexPath.row]
        
        
        performSegue(withIdentifier: "infoSegue", sender: self)
        
        
    }
}

extension StationViewController : GMSPanoramaViewDelegate {
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama, nearCoordinate coordinate: CLLocationCoordinate2D) {
        
        let heading = calculateHeading(form: panorama.coordinate, to: coordinate)
        view.camera = GMSPanoramaCamera(heading: heading, pitch: 0, zoom: 0)
    }
}


extension StationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading.magneticHeading)
        
    }
}
