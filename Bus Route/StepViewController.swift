//
//  StepViewController.swift
//  Bus Route
//
//  Created by CKHui on 17/12/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class StepViewController: UIViewController {

    @IBOutlet weak var naviDetailTableView: UITableView!{
        didSet{
            naviDetailTableView.dataSource = self
            naviDetailTableView.delegate = self
        }
    }
    var path : Path?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviDetailTableView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension StepViewController : UITableViewDataSource ,UITableViewDelegate{
    
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
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
        
        print(indexPath)
        
        
    }
    
}

