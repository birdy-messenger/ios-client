//
//  SettingsViewController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 02/07/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .customPink
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Settings"
        self.tabBarController?.navigationItem.titleView = nil
    }

}
