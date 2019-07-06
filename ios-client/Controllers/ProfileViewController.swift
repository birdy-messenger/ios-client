//
//  ProfileViewController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 09/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

protocol LogOutDelegate: class {
    func handleLogout()
}

class ProfileViewController: UIViewController {
    
    weak var delegate: LogOutDelegate?
    
    internal lazy var profileImageView: UIImageView = {
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
    
    private let backgroundProfileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customRed
        view.layer.cornerRadius = 152
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customPink
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let upperView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customPink
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.customRed
        label.backgroundColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 50)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.customRed
        label.backgroundColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private let logOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.setTitle("Log out", for: .normal)
        btn.setTitleColor(.customRed, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        btn.addTarget(self, action: #selector(logOutButtonPressed), for: .touchUpInside)
        
        return btn
    }()
    
    @objc func logOutButtonPressed() {
        self.delegate?.handleLogout()
        tabBarController?.selectedIndex = 1
    }
    
    private let upperSplitView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSplitView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tabBarItem.selectedImage = tabBarItem.selectedImage?.withRenderingMode(.alwaysOriginal)
        
        fetchUserInfo()
        
        view.addSubview(bottomView)
        setupBottomViewConstraints()
        
        view.addSubview(upperView)
        setupUpperViewConstraints()
        
        view.addSubview(nameLabel)
        setupNameLabelConstraints()
        
        view.addSubview(emailLabel)
        setupEmailLabelConstraints()
        
        addSplitViewsForNameLabels()
        
        view.addSubview(backgroundProfileImageView)
        setupBackroundProfileImageViewConstraints()
        
        view.addSubview(profileImageView)
        setupProfileImageViewConstraints()
        
        view.addSubview(logOutButton)
        view.addSubview(upperSplitView)
        view.addSubview(bottomSplitView)
        
        setupLogoutButtonConstraints()
        setupSplitViewsConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Profile"
        self.tabBarController?.navigationItem.titleView = nil
    }
    
    private func fetchUserInfo() {
        let userID = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.nameLabel.text = dictionary["name"] as? String
                self.emailLabel.text = dictionary["email"] as? String
                if let profileImageURL = dictionary["profileImageUrl"] as? String {
                    self.profileImageView.loadImageUsingCache(with: profileImageURL)
                }
            }
        })
    }
    
    private func setupBottomViewConstraints() {
        bottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupUpperViewConstraints() {
        upperView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        upperView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        upperView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        upperView.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
    }
    
    private func setupNameLabelConstraints() {
        nameLabel.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
    }
    
    private func setupEmailLabelConstraints() {
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        emailLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
    }
    
    private func addSplitViewsForNameLabels() {
        let upperSplitView = UIView()
        upperSplitView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        upperSplitView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomSplitView = UIView()
        bottomSplitView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        bottomSplitView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(upperSplitView)
        view.addSubview(bottomSplitView)
        
        upperSplitView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        upperSplitView.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        upperSplitView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        upperSplitView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        bottomSplitView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomSplitView.bottomAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        bottomSplitView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bottomSplitView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupBackroundProfileImageViewConstraints() {
        backgroundProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundProfileImageView.widthAnchor.constraint(equalToConstant: 304).isActive = true
        backgroundProfileImageView.heightAnchor.constraint(equalToConstant: 304).isActive = true
        backgroundProfileImageView.centerYAnchor.constraint(equalTo: upperView.centerYAnchor).isActive = true
    }
    
    private func setupProfileImageViewConstraints() {
        profileImageView.centerXAnchor.constraint(equalTo: backgroundProfileImageView.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: backgroundProfileImageView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    private func setupLogoutButtonConstraints() {
        logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logOutButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        logOutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 50).isActive = true
        logOutButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupSplitViewsConstraints() {
        upperSplitView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        upperSplitView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        upperSplitView.bottomAnchor.constraint(equalTo: logOutButton.topAnchor).isActive = true
        upperSplitView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        bottomSplitView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomSplitView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bottomSplitView.topAnchor.constraint(equalTo: logOutButton.bottomAnchor).isActive = true
        bottomSplitView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
