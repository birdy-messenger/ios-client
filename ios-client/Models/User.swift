//
//  User.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 09/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String
    var name: String
    var profileImage: String
    var id: String
    
    init(name: String, email: String, profileImageUrl: String, ID: String) {
        self.email = email
        self.name = name
        self.profileImage = profileImageUrl
        self.id = ID
    }
}
