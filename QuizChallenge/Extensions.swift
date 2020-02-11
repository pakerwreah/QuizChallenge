//
//  Extensions.swift
//  QuizChallenge
//
//  Created by Carlos on 11/02/20.
//  Copyright © 2020 ArcTouch. All rights reserved.
//

import UIKit

@IBDesignable extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
        get {
            return layer.cornerRadius
        }
    }

}
