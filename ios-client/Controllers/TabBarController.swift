//
//  TabBarController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 01/07/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarList()
        setupNavigationBarAppearance()
        
        tabBarController?.selectedIndex = 1
    }
    
    private func setupTabBarList() {
        let usersViewController = NewMessageController()
        usersViewController.tabBarItem = UITabBarItem(title: "Users", image: UIImage(named: "users"), tag: 0)
        
        let messageViewController = MessageViewController()
        messageViewController.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(named: "inbox"), tag: 1)
        usersViewController.delegate = messageViewController
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "birb"), tag: 2)
        profileViewController.delegate = messageViewController
        
        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings"), tag: 3)
        
        let tabBarLists = [usersViewController, messageViewController, profileViewController, settingsViewController]
        
        viewControllers = tabBarLists
    }
    
    private func setupNavigationBarAppearance() {
        let backButtonImage = UIImage(named: "arrow_back_icon")
        navigationController?.navigationBar.backIndicatorImage = backButtonImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }

}
