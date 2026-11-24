//
//  UIView+Layers.swift
//  phr
//
//  Created by Sankar Saravanan on 09/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

extension UIView
{
    
//    https://www.appcoda.com/rounded-corners-uiview/
    
//    layerMaxXMaxYCorner – lower right corner
//    layerMinXMaxYCorner – lower left corner
//    layerMaxXMinYCorner – top right corner
//    layerMinXMinYCorner – top left corner
//    [.layerMaxXMinYCorner , .layerMinXMinYCorner] - top
//    [.layerMaxXMaxYCorner , .layerMinXMaxYCorner] - bottom
    
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }

}
