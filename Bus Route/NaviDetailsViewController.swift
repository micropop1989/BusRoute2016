
//
//  NaviDetailsViewController.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/9/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GoogleMaps

class NaviDetailsViewController: UIViewController {
    
    @IBOutlet weak var naviDetailTableView: UITableView!{
        didSet{
            naviDetailTableView.dataSource = self
            naviDetailTableView.delegate = self
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            panGesture.delegate = self
            naviDetailTableView.addGestureRecognizer(panGesture)
            
        }
    }
    
    
    @IBOutlet weak var naviMapView: GMSMapView!
    
    var path : Path?
    var selectedOverlay = GMSPolyline()
    
    var widthConstraint = NSLayoutConstraint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if path != nil {
            naviDetailTableView.reloadData()
            
            let bound = GMSCoordinateBounds(coordinate: (path?.southwest)!, coordinate: (path?.northeast)!)
        
            let update = GMSCameraUpdate.fit(bound, withPadding: 10.0)
            naviMapView.moveCamera(update)
            
            for i : Step in (path?.steps)! {
                if i.isTransit {
                    i.overlay.map = naviMapView
                }
                else{
                    for j : SubStep in i.substeps! {
                        j.overlay.map = naviMapView
                    }
                }

            }
            
        }
        

    
    }
    
    
    @IBAction func edgeGestureAction(_ sender: Any) {
        print("edge")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gettableWidthConstraint()
    }
    
    func gettableWidthConstraint(){
        for constraint in naviDetailTableView.constraints {
            if (constraint.identifier == "StepTableWidth") {
                widthConstraint = constraint
                return
            }
        }
    }
    
    let maxWidth : CGFloat = 200.0
    
        @IBAction func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
    
                let translation = gestureRecognizer.translation(in: naviDetailTableView)
                let rect = naviDetailTableView.frame
    
                var width = rect.width
    
                if width < maxWidth + 1 {
    
                    width -= translation.x
                    width = max(0, width)
                    width = min(maxWidth, width)
    
                    let x = self.view.frame.width - width
                    let y = rect.origin.y
                    let height = rect.height
                    
                    let newRect = CGRect(x: x, y: y, width: width, height: height)
    
                    naviDetailTableView.frame = newRect
                }
            } else if gestureRecognizer.state == .ended {
                
                var width = naviDetailTableView.frame.size.width
                
                if width < maxWidth / 2.0 {
                    width = 10
                }else {
                    width = maxWidth
                }
                
                
                let y = naviDetailTableView.frame.origin.y
                let x = self.view.frame.width - width
                let height = naviDetailTableView.frame.size.height
                
                let newRect = CGRect(x: x, y: y, width: width, height: height)
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.naviDetailTableView.frame = newRect
                    self.widthConstraint.constant = width
                    self.naviDetailTableView.layoutIfNeeded()
                })

            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}


extension NaviDetailsViewController : UITableViewDataSource ,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return path?.steps.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let step = path?.steps[section]
            else{ return 0 }
        
        if step.isTransit {
            return 1
        }
        
        return step.substeps?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let step = path?.steps[indexPath.section]
            else{ return UITableViewCell()}
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "naviDetailCell")
            else { return UITableViewCell() }
        
        cell.imageView?.contentMode = .scaleAspectFill
        
        if step.isTransit {
            if let transitInfo = step.transitDetails {
                cell.textLabel?.text = transitInfo.name
                cell.detailTextLabel?.text = "\(transitInfo.type) \(transitInfo.agency) \(transitInfo.shortName) stop:\(transitInfo.numStops)"
                
                //bus icon accordingly
                cell.imageView?.image = UIImage(named: "bus2")
            }
            
            
        }else{
            //walking
            if let substep = step.substeps?[indexPath.row] {
                if let maneuver = substep.maneuver {
                    cell.imageView?.image = UIImage(named: maneuver)
                } else {
                    cell.imageView?.image = UIImage(named: "WALKING")
                }
                cell.textLabel?.text = substep.instruction.getTargetedRoad
                
                print(substep.instruction)
                
                cell.detailTextLabel?.text = "\(substep.distance)  \(substep.duration) \(substep.travelMode)"
            }
            
        }
        
        return cell
        
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        <#code#>
    //    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return path?.steps[section].instruction
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectSubPath(at: indexPath)
        

    }
    
    func selectSubPath(at indexPath : IndexPath){
        guard let step = path?.steps[indexPath.section]
            else{ return }
        let tempOverlay : GMSPolyline
        
        if step.isTransit {
            tempOverlay = step.overlay
            tempOverlay.strokeColor = step.overlay.strokeColor.withAlphaComponent(0.8)
        }
        else {
            let substep : SubStep = step.substeps![indexPath.row]
            tempOverlay = substep.overlay
            tempOverlay.strokeColor = step.overlay.strokeColor.withAlphaComponent(0.8)
        }
        
        selectedOverlay.strokeColor = step.overlay.strokeColor.withAlphaComponent(0.4)
        selectedOverlay = tempOverlay
        
//        naviMapView.animate(toLocation: (selectedOverlay.path?.coordinate(at: 0))!)
//        naviMapView.animate(toZoom: 15.0)
        
        
        
        let coord = (selectedOverlay.path?.coordinate(at: 0))!
        var point = naviMapView.projection.point(for: coord)
        point.x += naviDetailTableView.frame.width / 2.0
        let newCoord = naviMapView.projection.coordinate(for: point)
//        naviMapView.animate(toLocation: newCoord)
        
        let camera = GMSCameraPosition.camera(withTarget: newCoord, zoom: 15.0, bearing: 10, viewingAngle: 0)
        naviMapView.animate(to: camera)
    }
    
    
    
    
}

extension NaviDetailsViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

