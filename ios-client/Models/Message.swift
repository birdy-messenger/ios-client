//
//  Message.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 20/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import Foundation

class Message: NSObject {
    let fromID: String
    let toID: String
    let text: String
    let time: Int
    
    init(fromID: String, toID: String, text: String, time: Int) {
        self.fromID = fromID
        self.toID = toID
        self.text = text
        self.time = time
    }
}

