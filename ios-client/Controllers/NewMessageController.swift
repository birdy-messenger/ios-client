//
//  NewMessageController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 09/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

protocol NewMessageDelegate: class {
    func showChatView(with user: User)
}

class NewMessageController: UITableViewController {
    
    weak var delegate: NewMessageDelegate?
    
    private let cellID = "Cell"
    private var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)

        fetchUser()
    }
    
    var freshLaunch = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Medium", size: 21)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        self.tabBarController?.navigationItem.title = "Birdy Users"
        self.tabBarController?.navigationItem.titleView = nil
        
        if freshLaunch {
            self.tabBarController?.selectedIndex = 1
            freshLaunch = false
        }
    }
    
    private func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as! String, ID: snapshot.key)
                self.users.append(user)
                self.users.sort(by: { (user1, user2) -> Bool in
                    return user1.name < user2.name
                })
                                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.showChatView(with: self.users[indexPath.row])
        tabBarController?.selectedIndex = 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserCell(style: .subtitle, reuseIdentifier: cellID)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.profileImageView.loadImageUsingCache(with: user.profileImage)
        
        return cell
    }
    
}
