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
    
    let cellID = "Cell"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
        fetchUser()
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as! String, ID: snapshot.key)
                self.users.append(user)
                                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        self.delegate?.showChatView(with: self.users[indexPath.row])
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
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImage)
        
        return cell
    }
}

class UserCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}
