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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Station List"
        frDBref2 = FIRDatabase.database().reference()
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
        
        //custome marker
        let loadedView = Bundle.main.loadNibNamed("StationMarker", owner: self, options: nil)
        if loadedView?.count == 0{
            markerView = nil
        }else{
            markerView = loadedView?.first as? CustomeStationMarkerView
            markerView?.shapeImage.alpha = 0.9
            
            markerView?.delegate = self
        }
        
        //stationTableView.tableFooterView = UIView()
        stationTableView.rowHeight = UITableViewAutomaticDimension
        stationTableView.estimatedRowHeight = 300.0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        minY = stationMapView.frame.minY - 0.1
        maxY = stationMapView.frame.maxY + 0.1 - 60.0
    }
    
    
    func fetchStations(){
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
                
                self.showNearbyBusStation(coordinate: self.currentLocation)
                
            }
        })
        
    }
    
    
    func showNearbyBusStation(coordinate: CLLocationCoordinate2D, delta: Double = 0.01){
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
        //display marker
        for i in 0..<(filteredStation.count) {
            let temp = filteredStation[i]
            temp.mapMarker.userData = i
            temp.mapMarker.icon = UIImage(named: "maker30")
            temp.mapMarker.map = stationMapView
            
        }
        
        centermarker.isTappable = false
        centermarker.position = coordinate
        centermarker.icon = GMSMarker.markerImage(with: UIColor.orange)
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
        markerView.distanceLabel.text = marker.snippet
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
        
        
        //move map
        var point = stationMapView.projection.point(for: marker.position)
        let center = stationMapView.center
        point.y -= center.y / 2
        let newLoc = stationMapView.projection.coordinate(for: point)
        stationMapView.animate(toLocation: newLoc)

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
        
        //centermarker.position = position.target
        
        //centermarker.map = stationMapView
        
        //custome info window (move with map)
        markerView?.center = mapView.projection.point(for: tappedMarker.position)
        markerView?.center.y -= 120
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //custome info window
        markerView?.removeFromSuperview()

    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
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
        
        
        let loadedView = Bundle.main.loadNibNamed("StationTableHeader", owner: self, options: nil)
        if loadedView?.count == 0{
            return UIView()
        }else{
            let headerView = loadedView?.first as? StationTableHeaderView
            headerView?.delegate = self
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            headerView?.addGestureRecognizer(panGesture)
            
            return headerView
        }
    }
    
    
    @IBAction func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            
            let translation = gestureRecognizer.translation(in: stationTableView)
            // note: 'view' is optional and need to be unwrapped
//            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            
            //print(translation)
            let rect = stationTableView.frame
            
            var y = rect.origin.y
            
            print ("\(y)  \(maxY)   \(minY)")
            
            if y <= maxY && y >= minY - 0.1 {
                
            y += translation.y
            y = max(minY, y)
            y = min(maxY, y)
                
            let x = rect.origin.x

            let width = rect.size.width
            let height = rect.size.height - translation.y

            let newRect = CGRect(x: x, y: y, width: width, height: height)
            
            stationTableView.frame = newRect
                
//            let mapRect = stationMapView.frame
//            let mapOrigin = mapRect.origin
//            let mapWidth = mapRect.width
//            let mapHeight = mapRect.height
//            let mapSize = CGSize(width: mapWidth, height: mapHeight + translation.y)
//            stationMapView.frame = CGRect(origin: mapOrigin, size: mapSize)
                
            
                //move map
                
                
                //var point = stationMapView.projection.point(for: marker.position)
                var center = stationMapView.center
                
                print("center")
                print(center)
                print("\(stationMapView.projection.coordinate(for: center))")
                
                //point.y -= center.y / 2
                center.y += translation.y
                
                let newLoc = stationMapView.projection.coordinate(for: center)
                
                print("new center")
                print(center)
                print("\(stationMapView.projection.coordinate(for: center))")
                
                print("translation")
                print(translation.y)
                print("")
                
                stationMapView.animate(toLocation: newLoc)
                
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: stationTableView)
        }
        
//        else if gestureRecognizer.state == .ended {
//            
//            var heightConstraint = NSLayoutConstraint()
//            for constraint in stationTableView.constraints {
//                if (constraint.identifier == "TableHeight") {
//                    heightConstraint = constraint;
//                    break
//                }
//            }
//            let height = max(60,stationTableView.frame.size.height)
//            
//            heightConstraint.constant = height
//            
//            //centermarker.position = position.target
//            //centermarker.map = stationMapView
//            
//            //custome info window (move when map resize)
//            markerView?.center = stationMapView.projection.point(for: tappedMarker.position)
//            markerView?.center.y -= 120
//            
//        }
        
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
    
}

extension StationViewController : StationTableHeaderDelegate{
    func tableHeaderButtonPressed() {
    print ("tapped")
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
