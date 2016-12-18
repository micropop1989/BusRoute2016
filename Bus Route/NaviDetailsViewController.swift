
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
        }
    }
    
    @IBOutlet weak var naviMapView: GMSMapView!
    
    var path : Path?
    var selectedOverlay = GMSPolyline()
    var viewController = StepViewController()
    
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
        
//        
//        // Load Storyboard
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        
//        // Instantiate View Controller
//        viewController = storyboard.instantiateViewController(withIdentifier: "StepViewController") as! StepViewController
//        
//        viewController.path = path
//        // Configure Child View
//        let x = view.frame.origin.x
//        let y = view.frame.origin.y
//        let w = view.frame.width
//        let h = view.frame.height
//        
//        let rect = CGRect(x: x, y: y, width: w / 2.0, height: h / 2.0)
//        
//        showNaviStepTableView(at: rect)
//        // Do any additional setup after loading the view.
    
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
    
    
    /*
 
 
     let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
     headerView?.addGestureRecognizer(panGesture)
     
     */
//    
//    @IBAction func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
//        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
//            
//            let translation = gestureRecognizer.translation(in: naviDetailTableView)
//            let rect = naviDetailTableView.frame
//            
//            var y = rect.origin.y
//            let oriHeight = rect.size.height
//            s
//            print ("\(y)  \(maxY)   \(minY), \(oriHeight)")
//            
//            if y <= maxY + 0.11 && y >= minY - 0.11 {
//                
//                y += translation.y
//                y = max(minY, y)
//                y = min(maxY, y)
//                
//                let x = rect.origin.x
//                
//                let width = rect.size.width
//                let height = 60.0 + maxY - y
//                let newRect = CGRect(x: x, y: y, width: width, height: height)
//                
//                stationTableView.frame = newRect
//            }
//        }
//    }
//    
    func showNaviStepTableView(at frame : CGRect){
        
        
        addChildViewController(viewController)
        
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        
        UIView.animate(withDuration: 3.0, animations: {
        self.viewController.view.frame = frame //view.bounds
        self.viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        })
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)

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
        
        
        if step.isTransit {
            if let transitInfo = step.transitDetails {
                cell.textLabel?.text = transitInfo.name
                cell.detailTextLabel?.text = "\(transitInfo.type) \(transitInfo.agency) \(transitInfo.shortName) stop:\(transitInfo.numStops)"
                
                //bus icon accordingly
                cell.imageView?.image = UIImage()
            }
            
            
        }else{
            //walking
            if let substep = step.substeps?[indexPath.row] {
                if let maneuver = substep.maneuver {
                    cell.imageView?.image = UIImage(named: maneuver)
                } else {
                    cell.imageView?.image = UIImage()
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
        
        naviMapView.animate(toLocation: (selectedOverlay.path?.coordinate(at: 0))!)
        naviMapView.animate(toZoom: 15.0)
        
    }
    
}



