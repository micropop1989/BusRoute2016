//
//  CustomViewController.swift
//  Bus Route
//
//  Created by ALLAN CHAI on 05/12/2016.
//  Copyright © 2016 Wherevership. All rights reserved.
//

import UIKit

class CustomViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBar.barTintColor = UIColor.dodgerBlue
    }
}
