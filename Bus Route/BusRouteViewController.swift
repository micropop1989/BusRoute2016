//
//  BusRouteViewController.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 29/11/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit
import GoogleMaps

class BusRouteViewController: UIViewController {

    @IBOutlet weak var destinationTilteLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    @IBOutlet weak var routeMapView: GMSMapView!
    var bus : Bus?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "\((bus?.busNumber)!)"
        destinationLabel.text = bus?.busTitle
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customUI().customLabel(label: destinationLabel)
        customUI().customLabel(label: destinationTilteLabel)
        customUI().customButton(button: seeRouteDetailButton)
        customUI().customButton(button: changeRouteButton)
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
        
        }
    }
    
    

    
}
