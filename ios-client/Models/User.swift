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
    
    init(name: String, email: String) {
        self.email = email
        self.name = name
        profileImage = "https://firebasestorage.googleapis.com/v0/b/birdy-de1c1.appspot.com/o/birb.png?alt=media&token=86225bef-2918-430d-89b5-460a3be33e79"
    }
}
