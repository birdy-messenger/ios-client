//
//  MessageViewController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 09/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(MessageViewController.handleLogout))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        navigationController?.navigationBar.isTranslucent = false
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(MessageViewController.handleNewMessage))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            perform(#selector(handleLogout))
        } else {
            fetchUser()
        }
    }
    
    func fetchUser() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as! String)
                self.setupNavBar(with: user)
            }
        })
    }
    
    func setupNavBar(with user: User) {
        let titleView = UIView()
        titleView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 115, height: 40))
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 23)
        titleLabel.textAlignment = .right
        titleLabel.text = user.name
        titleView.addSubview(titleLabel)
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImage)
        titleView.addSubview(profileImageView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(MessageViewController.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        self.navigationItem.titleView = titleView
        
        profileImageView.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        titleLabel.adjustsFontSizeToFitWidth = true
    }
    
    @objc private func titleWasTapped() {
        let profile = ProfileViewController()
        present(profile, animated: true, completion: nil)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let login = LoginViewController()
        present(login, animated: true, completion: nil)
    }
    
}

