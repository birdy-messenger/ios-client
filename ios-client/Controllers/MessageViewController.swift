//
//  MessageViewController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 09/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UITableViewController, NewMessageDelegate {
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    let cellID = "Cell"
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        observeUserMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
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
                let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as! String, ID: snapshot.key)
                self.setupNavigationBarTitle(with: user)
            }
        })
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                self.fetchMessage(with: messageID)
            })
            
        })
    }
        
    private func fetchMessage(with messageID: String) {
        let messageReference = Database.database().reference().child("messages").child(messageID)
        messageReference.observeSingleEvent(of: .value) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(fromID: dictionary["fromID"] as! String, toID: dictionary["toID"] as! String, text: dictionary["text"] as! String, time: dictionary["time"] as! Double, isRead: dictionary["messageIsRead"] as! Bool)
                
                self.messagesDictionary[message.getChatPartnerID()] = message
                
                self.attemptReloadOfTable()
            }
            
        }
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.time > message2.time
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    /*
     functions that show other view controllers
     */
    func showChatView(with user: User) {
        let chatViewController = ChatViewController(with: user)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.delegate = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
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
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        let login = LoginViewController()
        present(login, animated: true, completion: nil)
    }
    
    /*
    functions to override table view properties
    */
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserCell(style: .subtitle, reuseIdentifier: cellID)
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        let chatPartnerID = message.getChatPartnerID()
        
        let ref = Database.database().reference().child("users").child(chatPartnerID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let dictionary = snapshot.value as! [String: AnyObject]
            
            let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as! String, ID: chatPartnerID)
            
            self.showChatView(with: user)
        }
    }
    
    /*
    functions that set up the view
    */
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(MessageViewController.handleLogout))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.white
        
        let backButtonImage = UIImage(named: "arrow_back_icon")
        navigationController?.navigationBar.backIndicatorImage = backButtonImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)

        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(MessageViewController.handleNewMessage))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    func setupNavigationBarTitle(with user: User) {
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
        profileImageView.loadImageUsingCache(with: user.profileImage)
        titleView.addSubview(profileImageView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(MessageViewController.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        self.navigationItem.titleView = titleView
        
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        
        titleLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        titleLabel.adjustsFontSizeToFitWidth = true
    }
    
}

