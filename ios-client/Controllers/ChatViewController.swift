//
//  ChatViewController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 17/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ChatCell"

class ChatViewController: UICollectionViewController, UITextFieldDelegate {
    
    var correspondingUser: User
    
    init(with user: User) {
        self.correspondingUser = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter message", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)])
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white
        
        setupNameBar()
        setupInputComponents()
        hideKeyboard()
    }
    
    func setupNameBar() {
        let titleView = UIView()
        titleView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 115, height: 40))
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 23)
        nameLabel.textAlignment = .center
        nameLabel.text = correspondingUser.name
        titleView.addSubview(nameLabel)
        
        nameLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: titleView.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.customRed
        view.addSubview(containerView)
        
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.tintColor = .white
        sendButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    }
    
    @objc func handleSend() {
        guard inputTextField.text! != "" else {
            return
        }
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromID = Auth.auth().currentUser?.uid
        let toID = correspondingUser.id
        let time = Int(Date().timeIntervalSince1970)
        let values = ["text": inputTextField.text!, "fromID": fromID!, "toID": toID, "time": time, "messageIsRead": false] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromID!).child(toID)
            
            let messageID = childRef.key!
            userMessageRef.updateChildValues([messageID: 0])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID).child(fromID!)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
            
            self.inputTextField.text = nil
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }

}
