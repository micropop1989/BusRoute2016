//
//  BusRouteViewController.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 29/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase

class BusRouteViewController: UIViewController {
    
    @IBOutlet weak var destinationTilteLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    @IBOutlet weak var routeMapView: GMSMapView!
    var bus : Bus?
    
    //fetchdata
    var stations : [Station] = []
    var frDBref : FIRDatabaseReference!
    var routeID : String?
    var selectedIndexPath = IndexPath(item: 0, section: 0)

    
    
    @IBOutlet weak var stationCollectionView: UICollectionView! {
        didSet{
            stationCollectionView.dataSource = self
            stationCollectionView.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "🚍\((bus?.busNumber)!)"
        destinationLabel.text = bus?.busTitle
        
        routeMapView.delegate = self
        
        //fetchdata
        frDBref = FIRDatabase.database().reference()
        //fetchRoute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customUI().customLabel(label: destinationLabel)
        customUI().customLabel(label: destinationTilteLabel)
        customUI().customButton(button: seeRouteDetailButton)
        customUI().customButton(button: changeRouteButton)
        
        fetchRoute()
        
        
        
        //        . gradient = CAGradientLayer(layer: stationCollectionView)
        //
        //        gradient.frame = stationCollectionView.bounds
        //        gradient.colors = [UIColor.white.withAlphaComponent(0), UIColor.white, UIColor.white.withAlphaComponent(0)]
        //        // Here, percentage would be the percentage of the collection view
        //        // you wish to blur from the top. This depends on the relative sizes
        //        // of your collection view and the header.
        //        gradient.locations = [0.0, 0.5, 1.0]
        //        gradient.isOpaque = false
        //        gradient.opacity = 0.5
        //        //stationCollectionView.layer.mask = gradient
        //        //stationCollectionView.layer.addSublayer(gradient)
        //        //stationCollectionView.layerWillDraw(gradient)
        //        stationCollectionView.layer.mask = gradient
        //        //stationCollectionView.mask? = gradient
    }
    
    
    //fetchdata
    func fetchRoute() {
        stations = []
        guard let routeID = bus?.routeID
            else{ return}
        self.routeID = routeID
        
        // let routeID = "route0232"
        frDBref.child("routes").child(routeID).child("orderedStations").observeSingleEvent(of: .value, with: { (routeSnapshot) in
            guard let routeDictionary = routeSnapshot.value as? [String]
                else { return }
            let dispatchGp = DispatchGroup()
            
            for station in routeDictionary {
                
                dispatchGp.enter()
                
                self.frDBref.child("stations").child(station).observeSingleEvent(of: .value, with: { (stationSnapshot) in
                    
                    
                    guard let stationDictionary = stationSnapshot.value as? [String : AnyObject]
                        else { return }
                    
                    let newStation = Station(dict: stationDictionary)
                    newStation.stationID = station
                    //newStation.address = stationDictionary["address"] as? String
                    self.stations.append(newStation)
                    
                    dispatchGp.leave()
                })
                
            }
            dispatchGp.notify(queue: DispatchQueue.main, execute: {
                print("Doen fetch data")
                self.showStationOnMap()
                self.stationCollectionView.reloadData()
            })
        })
    }
    
    func showStationOnMap(){
        let path = GMSMutablePath()
        
        
        let camera = GMSCameraPosition.camera(withTarget: stations[0].mapMarker.position , zoom: 12.5)
        
        routeMapView.camera = camera
        
        //routeMapView.animate(toLocation: stations[0].mapMarker.position)
        //        routeMapView.animate(toZoom: 12.5)
        
        let icon = UIImage(named: "maker30")
        
        for i in 0..<(stations.count) {
            let tempStat = stations[i]
            tempStat.mapMarker.icon = icon
            tempStat.mapMarker.opacity = 0.3
            tempStat.mapMarker.map = routeMapView
            tempStat.mapMarker.userData = i
            
            path.add(tempStat.mapMarker.position)
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.geodesic = true
        polyline.map = routeMapView
        polyline.strokeColor = UIColor.red
    }
    
    
    
    @IBOutlet weak var seeRouteDetailButton: UIButton!
        {
        didSet {
            seeRouteDetailButton.addTarget(self, action: #selector(onSeeRouteDetailPressed), for: .touchUpInside)
        }
    }
    
    func onSeeRouteDetailPressed(button: UIButton) {
        self.performSegue(withIdentifier: "seeRouteDetailSegue", sender: self)
    }
    
    @IBOutlet weak var changeRouteButton: UIButton!
        {
        didSet {
            changeRouteButton.addTarget(self, action: #selector(onChangeRouteButtonPressed), for: .touchUpInside)
        }
    }
    
    func onChangeRouteButtonPressed(button: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seeRouteDetailSegue") {
            let destination = segue.destination as! RouteDetailViewController
            destination.bus = bus
            destination.stations = stations
        }
    }
}


extension BusRouteViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        
        cell.leftImage.isHidden = false
        cell.rightImage.isHidden = false
        
        if indexPath.row == 0 {
            cell.leftImage.isHidden = true
        }
        if indexPath.row == stations.count - 1 {
            cell.rightImage.isHidden = true
        }
        
        cell.dotImage.image = UIImage(named: "dotWithScp")
        if indexPath == selectedIndexPath {
            cell.dotImage.image = UIImage(named: "dot")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let CellWidth : CGFloat = 50.0
        let collectionViewWidth = collectionView.frame.size.width
        let inset = collectionViewWidth / 2.0 - CellWidth / 2.0
        
        return UIEdgeInsetsMake(0, inset, 0, inset)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        actionDeselectCell(at: selectedIndexPath, from: collectionView)
        actionSelectCell(at: indexPath, from: collectionView)
    }
    

    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    //        print("move")
    //    }
    
    func actionSelectCell(at indexPath : IndexPath,from cv : UICollectionView?){
        
        let collectionView : UICollectionView
        
        if cv != nil {
            collectionView = cv!
        }
        else {
            collectionView = stationCollectionView
        }
        
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as? RouteStationCollectionViewCell
        selectedCell?.dotImage.image = UIImage(named: "dot")
        
        let selectedStation = stations[indexPath.row]
 
        routeMapView.animate(toLocation: selectedStation.mapMarker.position )
        routeMapView.animate(toZoom: 14.0)
    
        selectedStation.mapMarker.opacity = 1.0
        
        selectedIndexPath = indexPath
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    func actionDeselectCell(at indexPath : IndexPath,from cv : UICollectionView?){
        
        let collectionView : UICollectionView
        
        if cv != nil {
            collectionView = cv!
        }
        else {
            collectionView = stationCollectionView
        }
        
        let deselectedCell = collectionView.cellForItem(at: indexPath) as? RouteStationCollectionViewCell
        deselectedCell?.dotImage.image = UIImage(named: "dotWithScp")
        
        let deselectedStation = stations[indexPath.row]
        deselectedStation.mapMarker.opacity = 0.3
        
    }
}


extension BusRouteViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let index = marker.userData as? Int
        let indexPath = IndexPath(item: index!, section: 0)
        
        
        
        actionDeselectCell(at: selectedIndexPath, from: stationCollectionView)
        actionSelectCell(at: indexPath, from: stationCollectionView)
        
        
        return true
    }
}
