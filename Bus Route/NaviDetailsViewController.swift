
//
//  NaviDetailsViewController.swift
//  Bus Route
//
//  Created by NEXTAcademy on 12/9/16.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class NaviDetailsViewController: UIViewController {
    
    @IBOutlet weak var naviDetailTableView: UITableView!{
        didSet{
            naviDetailTableView.dataSource = self
            naviDetailTableView.delegate = self
        }
    }
    
    
    var path : Path?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if path != nil {
            naviDetailTableView.reloadData()
        }
        
        // Do any additional setup after loading the view.
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
            }
            
            
        }else{
            //walking
            if let substep = step.substeps?[indexPath.row] {
                if let maneuver = substep.maneuver {
                    cell.imageView?.image = UIImage(named: maneuver)
                } else {
                    cell.imageView?.image = UIImage()
                }
                cell.textLabel?.text = substep.instruction
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
    
    
}
