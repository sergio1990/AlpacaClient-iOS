//
//  UIView + Extension.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 19.02.2023.
//

import Foundation
import UIKit

private let rotate360DegreesAnimationKey = "rotate360Degrees"

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 3) {
        stopRotate360Degrees()
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        layer.add(rotateAnimation, forKey: rotate360DegreesAnimationKey)
    }
    
    func stopRotate360Degrees() {
        layer.removeAnimation(forKey: rotate360DegreesAnimationKey)
    }
}
