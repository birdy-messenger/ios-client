//
//  ViewController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 05/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(ViewController.handleLogin))
        
        if Auth.auth().currentUser == nil {
            perform(#selector(handleLogin))
        }
    }
    
    @objc func handleLogin() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let login = LoginViewController()
        present(login, animated: true, completion: nil)
    }
}

