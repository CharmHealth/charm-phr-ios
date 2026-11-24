//
//  UIView+SafeAreaLayout.swift
//  phr
//
//  Created by Sankar Saravanan on 09/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    
    //Set left end constraint for a view with safe area layout
    func setSafeAreaLeft(offset:CGFloat)
    {
        self.initForView()

        let leftConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: self.superview!.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: offset)
                
        self.superview?.addConstraint(leftConstraint)
    }
    
    //Set right end constraint for a view with safe area layout
    func setSafeAreaRight(offset:CGFloat)
    {
        self.initForView()
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: self.superview!.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: offset)
        
        self.superview?.addConstraint(rightConstraint)
    }
    
    //Set top end constraint for a view with safe area layout
    func setSafeAreaTop(offset:CGFloat)
    {
        self.initForView()
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview!.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: offset)
        
        self.superview?.addConstraint(topConstraint)
    }
    
    //Set bottom end constraint for a view with safe area layout
    func setSafeAreaBottom(offset:CGFloat)
    {
        self.initForView()
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview!.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: offset)
        
        self.superview?.addConstraint(bottomConstraint)
    }
    
}
