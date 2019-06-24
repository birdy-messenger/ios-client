//
//  UserCell.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 22/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var messageFromCurrentUser: Bool?
    
    var message: Message? {
        didSet {
            if message!.fromID == Auth.auth().currentUser?.uid {
                messageFromCurrentUser = true
                setProfileImageViewForUser(imageView: smallProfileImageView, userID: message!.fromID)
            } else {
                messageFromCurrentUser = false
            }
            
            if let uid = message?.getChatPartnerID() {
                setProfileImageViewForUser(imageView: profileImageView, userID: uid)
            }
            
            detailTextLabel?.text = message!.text
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            timeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: message!.time))
        }
    }
    
    func setProfileImageViewForUser(imageView: UIImageView, userID: String) {
        let ref = Database.database().reference().child("users").child(userID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.textLabel?.text = dictionary["name"] as? String
                
                if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                    imageView.loadImageUsingCache(with: profileImageUrl)
                }
            }
            
        })
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let smallProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let redDot: Dot = {
        let dot = Dot()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.masksToBounds = true
        dot.backgroundColor = UIColor.customRed
        dot.contentMode = .scaleAspectFill
        return dot
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        let xPosForDetailedLabel: Double
        var yPosForDetailedLabel = detailTextLabel!.frame.origin.y + 2
        if let messageFromUser = messageFromCurrentUser {
            if messageFromUser {
                xPosForDetailedLabel = 64 + 26
                yPosForDetailedLabel = yPosForDetailedLabel + 2
                addSubview(smallProfileImageView)
                
                smallProfileImageView.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y, width: 20, height: 20)
            } else {
                xPosForDetailedLabel = 64
            }
        } else {
            xPosForDetailedLabel = 64
        }
        
        var widthForDetailedTextLabel = detailTextLabel!.frame.width
        let maxWidthForDetailedTextLabel = self.frame.width - 130
        widthForDetailedTextLabel = widthForDetailedTextLabel > maxWidthForDetailedTextLabel ? maxWidthForDetailedTextLabel : widthForDetailedTextLabel
        
        detailTextLabel?.frame = CGRect(x: CGFloat(xPosForDetailedLabel), y: yPosForDetailedLabel, width: widthForDetailedTextLabel, height: detailTextLabel!.frame.height)
        
        customizeMessage()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 82).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    func customizeMessage() {
        guard messageFromCurrentUser != nil else {
            return
        }
        
        if messageFromCurrentUser! {
            if !message!.isRead {
                redDot.frame = CGRect(x: self.frame.width - 40, y: 45, width: 10, height: 10)
                addSubview(redDot)
            }
        } else {
            if !message!.isRead {
                backgroundColor = UIColor.customPink
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

