//
//  UIView+Animation.swift
//  phr
//
//  Created by Sankar Saravanan on 25/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation


extension UIView
{
//    func performClickAnimation()
//    {
//        UIView.animate(withDuration: 0.3) {
//            self.alpha = 0.5
//            self.alpha =  1
//        }
//    }
    
    
}



extension UIView {
    func shake() {
        let duration = 0.5
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}
