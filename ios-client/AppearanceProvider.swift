//
//  AppearanceProvider.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 08/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit

extension UIColor {
    open class var sandy: UIColor {
        return UIColor(red: 203/255, green: 185/255, blue: 118/255, alpha: 1.0)
    }
    open class var customRed: UIColor {
        return UIColor(red: 203/255, green: 29/255, blue: 30/255, alpha: 1.0)
    }
    open class var customPink: UIColor {
        return UIColor(red: 255/255, green: 238/255, blue: 238/255, alpha: 1.0)
    }
}

class UIDot: UIView {
    override func layoutSubviews() {
        layer.cornerRadius = bounds.size.width/2
    }
}
