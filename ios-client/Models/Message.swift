//
//  Message.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 20/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import Foundation
import FirebaseAuth

class Message: NSObject {
    let fromID: String
    let toID: String
    let text: String
    let time: Double
    var isRead = false
    
    init(fromID: String, toID: String, text: String, time: Double, isRead: Bool) {
        self.fromID = fromID
        self.toID = toID
        self.text = text
        self.time = time
        self.isRead = isRead
    }
    
    func getChatPartnerID() -> String {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
}

