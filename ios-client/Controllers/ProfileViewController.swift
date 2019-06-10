//
//  ProfileViewController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 09/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 150
        imageView.layer.masksToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backgroundUserContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let barView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Profile"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 23)
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.customRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 50)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.customRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let doneButtonView: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.backgroundColor = UIColor.customRed
        
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        return button
    }()

    @objc func doneButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        fetchUserInfo()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(bottomView)
        setupBottomViewConstraints()
        
        view.addSubview(barView)
        view.addSubview(titleLabel)
        setupBarViewConstraints()
        
        view.addSubview(backgroundUserContainerView)
        setupBackgroundUserContainerViewConstraints()

        view.addSubview(doneButtonView)
        setupDoneButtonViewConstraints()
        
        view.addSubview(nameLabel)
        setupNameLabelConstraints()
        
        view.addSubview(emailLabel)
        setupEmailLabelConstraints()
        
        view.addSubview(profileImageView)
        setupProfileImageViewConstraints()
        
        view.backgroundColor = .white
        
    }
    
    func fetchUserInfo() {
        let userID = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.nameLabel.text = dictionary["name"] as? String
                self.emailLabel.text = dictionary["email"] as? String
                if let profileImageURL = dictionary["profileImageUrl"] as? String {
                    self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                }
            }
        })
    }
    
    func setupBottomViewConstraints() {
        bottomView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupDoneButtonViewConstraints() {
        doneButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doneButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        doneButtonView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        doneButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    func setupBackgroundUserContainerViewConstraints() {
        backgroundUserContainerView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        backgroundUserContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundUserContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        backgroundUserContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
    }
    
    func setupBarViewConstraints() {
        barView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        barView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        barView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        barView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/12).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: barView.centerXAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: barView.bottomAnchor, constant: -10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    func setupNameLabelConstraints() {
        nameLabel.topAnchor.constraint(equalTo: backgroundUserContainerView.topAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: backgroundUserContainerView.widthAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: backgroundUserContainerView.centerXAnchor).isActive = true
    }
    
    func setupEmailLabelConstraints() {
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: backgroundUserContainerView.widthAnchor).isActive = true
        emailLabel.centerXAnchor.constraint(equalTo: backgroundUserContainerView.centerXAnchor).isActive = true
    }
    
    func setupProfileImageViewConstraints() {
        profileImageView.bottomAnchor.constraint(equalTo: backgroundUserContainerView.topAnchor, constant: -50).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
}
