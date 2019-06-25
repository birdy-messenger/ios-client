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

class ChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var correspondingUser: User
    
    var messages = [Message]()
    
    init(with user: User) {
        self.correspondingUser = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        observeMessages()
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let toID = correspondingUser.id
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toID)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message(fromID: dictionary["fromID"] as! String, toID: dictionary["toID"] as! String, text: dictionary["text"] as! String, time: dictionary["time"] as! Double, isRead: dictionary["messageIsRead"] as! Bool)
                
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        setupCell(cell, with: message)
        
        return cell
    }
    
    private func setupCell(_ cell: MessageCell, with message: Message) {
        cell.profileImageView.loadImageUsingCache(with: correspondingUser.profileImage)
        
        if message.fromID == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = .customPink
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        cell.bubbleWidthAnchor?.constant = estimateFrame(for: message.text).width + 72
        cell.textView.text = message.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        cell.timeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: message.time))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = messages[indexPath.row]
        let height = estimateFrame(for: message.text).height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrame(for text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter message", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)])
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.customRed
        
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
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.keyboardDismissMode = .interactive
        
        setupNameBar()
        setupKeyboardObservers()
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
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
