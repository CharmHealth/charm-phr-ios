//
//  UIView+AutoLayout.swift
//  phr
//
//  Created by Sankar Saravanan on 09/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func initForView()
    {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func equalsTheContainerView(constant: CGFloat = 0)
    {
        self.setLeft(offSet: constant)
        self.setTop(offSet: constant)
        self.setRight(offSet: -constant)
        self.setBottom(offSet: -constant)
    }
    
    //MARK: - height
    func setHeight(constant : CGFloat ,relatedBy : NSLayoutConstraint.Relation )
    {
        self.initForView()
        let htConst = NSLayoutConstraint(item: self, attribute: .height, relatedBy: relatedBy, toItem: nil, attribute: .height, multiplier: 1, constant: constant)
       
        self.superview?.addConstraint(htConst)
    }
    
    func setHeight(constant : CGFloat )
    {
        self.setHeight(constant: constant, relatedBy: .equal)
    }
    
    func wrapHeight(maxHeight: CGFloat, maxWidth: CGFloat = applicationFrame.width, extraSpacing: CGFloat = 0){
        setHeight(constant: sizeThatFits(CGSize(width: maxWidth, height: maxHeight)).height + extraSpacing)
    }
    
    func setAndReturnHeight(constant : CGFloat ) -> NSLayoutConstraint
    {
        self.initForView()
        let htConst = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: constant)
       
        self.superview?.addConstraint(htConst)
        
        return htConst
    }

    func setRelativeHeight()
    {
        self.setRelativeHeight(multiplier: 1, constant: 1)
    }

    func setRelativeHeight(multiplier : CGFloat)
    {
        self.setRelativeHeight(multiplier: multiplier, constant: 0)
    }

    func setRelativeHeight(multiplier : CGFloat, constant : CGFloat)
    {
        self.initForView()
        let htConst = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self.superview, attribute: .height, multiplier: multiplier, constant: constant)
        self.superview?.addConstraint(htConst)
    }
    

    //MARK: - Width
    
    func setWidth(constant : CGFloat, relatedView : UIView )
    {
        self.initForView()
        let widthConst = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: relatedView, attribute: .width, multiplier: 1, constant: constant)
        self.superview?.addConstraint(widthConst)
    }
    
    func setWidth(constant : CGFloat)
    {
        self.initForView()
        let widthConst = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: constant)
        self.superview?.addConstraint(widthConst)
    }
    
    func setAndReturnWidth(constant : CGFloat) -> NSLayoutConstraint
    {
        self.initForView()
        let widthConst = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: constant)
        self.superview?.addConstraint(widthConst)
        return widthConst
    }
    
    @objc func wrapWidth(maxWidth: CGFloat, maxHeight: CGFloat = 40, extraSpacing: CGFloat = 0){
        
        var width = sizeThatFits(CGSize(width: maxWidth, height: maxHeight)).width + extraSpacing
        
        if width > maxWidth {
            width = maxWidth
        }
        
        if let constraint = getConstraint(attribute: .width) {
            constraint.constant = width
        }
        else{
            setWidth(constant: width)
        }
        
    }

    func setRelativeWidth()
    {
        self.setRelativeHeight(multiplier: 1, constant: 1)
    }

    func setRelativeWidth(multiplier : CGFloat)
    {
        self.setRelativeHeight(multiplier: multiplier, constant: 0)
    }

    func setRelativeWidth(multiplier : CGFloat, constant : CGFloat)
    {
        self.initForView()
        let widthConst = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self.superview, attribute: .width, multiplier: multiplier, constant: constant)
        self.superview?.addConstraint(widthConst)
    }
    
    func setViewSize(sz:CGSize)
    {
        self.setWidth(constant: sz.width)
        self.setHeight(constant: sz.height)
    }
    
    //MARK: - top
    func setTop(offSet : CGFloat)
    {
        self.setTopRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: 1, relatedAttribute: .top)
    }

    func setRelativeTop(offSet : CGFloat , multiplier : CGFloat)
    {
        self.setTopRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: multiplier, relatedAttribute: .top)
    }

    func setTopRelatedToView(offSet : CGFloat , relatedView : UIView)
    {
        self.setTopRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: .top)
    }

    func setTopRelatedToView(offSet : CGFloat , relatedView : UIView , relatedAttribute : NSLayoutConstraint.Attribute)
    {
        self.setTopRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: relatedAttribute)
    }
    
    func setAndReturnTopRelatedToView(offSet : CGFloat , relatedView : UIView , relatedAttribute : NSLayoutConstraint.Attribute)-> NSLayoutConstraint
    {
        self.initForView()
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: relatedView, attribute: relatedAttribute, multiplier: 1, constant: offSet)
        self.superview?.addConstraint(topConstraint)
        return topConstraint
    }

    func setTopRelatedToView(offSet : CGFloat , relatedView : UIView , multiplier : CGFloat , relatedAttribute : NSLayoutConstraint.Attribute)
    {
        self.setTopRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: multiplier, relatedAttribute: relatedAttribute, relatedBy: .equal)
    }
    
    func setTopRelatedToView(offSet : CGFloat , relatedView : UIView , multiplier : CGFloat , relatedAttribute : NSLayoutConstraint.Attribute,relatedBy : NSLayoutConstraint.Relation)
    {
        self.initForView()
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: relatedBy, toItem: relatedView, attribute: relatedAttribute, multiplier: multiplier, constant: offSet)
        self.superview?.addConstraint(topConstraint)
    }
    
    func setAndReturnTop(offSet : CGFloat) -> NSLayoutConstraint
    {
        self.initForView()
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview, attribute: .top, multiplier: 1, constant: offSet)
        self.superview?.addConstraint(topConstraint)
        return topConstraint
        
    }
    
    //MARK: - Bottom
    func setBottom(offSet : CGFloat)
    {
        self.setBottomRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: 1, relatedAttribute: .bottom)
    }

    func setRelativeBottom(offSet : CGFloat , multiplier : CGFloat)
    {
        self.setBottomRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: multiplier, relatedAttribute: .bottom)
    }

    func setBottomRelatedToView(offSet : CGFloat , relatedView : UIView)
    {
        self.setBottomRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: .bottom)
    }

    func setBottomRelatedToView(offSet : CGFloat , relatedView : UIView , relatedAttribute : NSLayoutConstraint.Attribute)
    {
        self.setBottomRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: relatedAttribute)
    }

    func setBottomRelatedToView(offSet : CGFloat , relatedView : UIView , multiplier : CGFloat , relatedAttribute : NSLayoutConstraint.Attribute)
    {
        self.initForView()
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: relatedView, attribute: relatedAttribute, multiplier: multiplier, constant: offSet)
        self.superview?.addConstraint(bottomConstraint)
    }
    func setAndReturnBottom(offSet : CGFloat) -> NSLayoutConstraint
    {
        self.initForView()
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1, constant: offSet)
        
        self.superview?.addConstraint(bottomConstraint)
        return bottomConstraint
        
    }
    
    func setAndReturnBottomRelatedToView(offSet : CGFloat , relatedView : UIView , relatedAttribute : NSLayoutConstraint.Attribute) -> NSLayoutConstraint
    {
        self.initForView()
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: relatedView, attribute: relatedAttribute, multiplier: 1, constant: offSet)
        
        self.superview?.addConstraint(bottomConstraint)
        return bottomConstraint
    }
    //MARK: -  Left
    func setLeft(offSet : CGFloat)
    {
        self.setLeftRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: 1, relatedAttribute: .left, relatedBy: .equal)
    }
    
    func setLeft(offSet : CGFloat ,relatedBy : NSLayoutConstraint.Relation )
    {
        self.setLeftRelatedToView(offSet : offSet , relatedView : self.superview! , multiplier : 1 , relatedAttribute : .left , relatedBy :relatedBy )
    }

    func setRelativeLeft(offSet : CGFloat , multiplier : CGFloat)
    {
        self.setLeftRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: multiplier, relatedAttribute: .left, relatedBy: .equal)
    }

    func setLeftRelatedToView(offSet : CGFloat , relatedView : UIView)
    {
        self.setLeftRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: .left, relatedBy: .equal)
    }

    func setLeftRelatedToView(offSet : CGFloat , relatedView : UIView , relatedAttribute : NSLayoutConstraint.Attribute)
    {
        self.setLeftRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: relatedAttribute, relatedBy: .equal)
    }

    func setAndReturnLeftRelatedToView(offSet : CGFloat , relatedView : UIView , relatedAttribute : NSLayoutConstraint.Attribute)-> NSLayoutConstraint
    {
        self.initForView()
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: relatedView, attribute: relatedAttribute, multiplier: 1, constant: offSet)
        self.superview?.addConstraint(leftConstraint)
        return leftConstraint
    }
    
    func setLeftRelatedToView(offSet : CGFloat , relatedView : UIView , multiplier : CGFloat , relatedAttribute : NSLayoutConstraint.Attribute , relatedBy : NSLayoutConstraint.Relation )
    {
        self.initForView()
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: relatedBy, toItem: relatedView, attribute: relatedAttribute, multiplier: multiplier, constant: offSet)
        self.superview?.addConstraint(leftConstraint)
    }
    func setAndReturnLeft(offSet : CGFloat) -> NSLayoutConstraint
    {
        self.initForView()
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: self.superview, attribute: .left, multiplier: 1, constant: offSet)
        self.superview?.addConstraint(leftConstraint)
        return leftConstraint
        
    }

    //MARK: - Right
    func setRight(offSet : CGFloat)
    {
        self.setRightRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: 1, relatedAttribute: .right, relatedBy: .equal)
    }

    func setRight(offSet : CGFloat ,relatedBy : NSLayoutConstraint.Relation )
    {
        setRightRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: 1, relatedAttribute: .right, relatedBy: relatedBy)
    }
    
    func setRelativeRight(offSet : CGFloat , multiplier : CGFloat)
    {
        self.setRightRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: multiplier, relatedAttribute: .right, relatedBy: .equal)
    }

    func setRightRelatedToView(offSet : CGFloat , relatedView : UIView)
    {
        self.setRightRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: .right, relatedBy: .equal)
    }

    func setRightRelatedToView(offSet : CGFloat , relatedView : UIView , relatedAttribute : NSLayoutConstraint.Attribute)
    {
        self.setRightRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: relatedAttribute, relatedBy: .equal)
    }

    func setRightRelatedToView(offSet : CGFloat , relatedView : UIView , multiplier : CGFloat , relatedAttribute : NSLayoutConstraint.Attribute ,relatedBy : NSLayoutConstraint.Relation )
    {
        self.initForView()
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy:relatedBy, toItem: relatedView, attribute: relatedAttribute, multiplier: multiplier, constant: offSet)
        self.superview?.addConstraint(rightConstraint)
    }
    
    //MARK: - leading
    func setLeading(offSet : CGFloat)
    {
        self.setLeadingRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: 1, relatedAttribute: .leading)
    }

    func setRelativeLeading(offSet : CGFloat , multiplier : CGFloat)
    {
        self.setLeadingRelatedToView(offSet: offSet, relatedView: self.superview!, multiplier: multiplier, relatedAttribute: .leading)
    }

    func setLeadingRelatedToView(offSet : CGFloat , relatedView : UIView)
    {
        self.setLeadingRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: .leading)
    }

    func setLeadingRelatedToView(offSet : CGFloat , relatedView : UIView , relatedAttribute : NSLayoutConstraint.Attribute)
    {
        self.setLeadingRelatedToView(offSet: offSet, relatedView: relatedView, multiplier: 1, relatedAttribute: relatedAttribute)
    }

    func setLeadingRelatedToView(offSet : CGFloat , relatedView : UIView , multiplier : CGFloat , relatedAttribute : NSLayoutConstraint.Attribute)
    {
        self.initForView()
        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: relatedView, attribute: relatedAttribute, multiplier: multiplier, constant: offSet)
        self.superview?.addConstraint(leadingConstraint)
    }
    
    //MARK: - center X
    func setCenterX()
    {
        self.setCenterXWithOffset(offset: 0, view: self.superview!)
    }
    
    func setCenterX(view : UIView)
    {
        self.setCenterXWithOffset(offset: 0, view: view)
    }

    func setCenterXWithOffset(offset:CGFloat , view : UIView)
    {
        self.initForView()
        let centerXConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: offset)
        self.superview?.addConstraint(centerXConstraint)
    }
    
    //MARK: - center Y
    func setCenterY()
    {
        self.setCenterYWithOffset(offset: 0, view: self.superview!)
    }
    
    func setCenterY(view : UIView)
    {
        self.setCenterYWithOffset(offset: 0, view: view)
    }
    
    func setAndReturnCenterYWithOffset( view : UIView) -> NSLayoutConstraint
    {
        self.initForView()
        let centerYConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        self.superview?.addConstraint(centerYConstraint)
        
        return centerYConstraint
    }

    func setCenterYWithOffset(offset:CGFloat, view : UIView)
    {
        self.initForView()
        let centerYConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: offset)
        self.superview?.addConstraint(centerYConstraint)
    }
    
    func getWidth() -> CGFloat {
        return getConstraint(attribute: .width)?.constant ?? 0
    }
    func getHeight() -> CGFloat {
        return getConstraint(attribute: .height)?.constant ?? 0
    }
    
    func setHorizontal(offSet: CGFloat = 0){
        setLeft(offSet: offSet)
        setRight(offSet: -offSet)
    }
    
    func getConstraint(attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint?{
        
       if let constraints =  self.superview?.constraints.filter({constraint in
            if let item = (constraint.firstItem as? UIView) {
                return item == self && constraint.firstAttribute == attribute
            }
            return false
       }){
           return constraints.firstOrNil()
       }
        
        return nil
    }
    
    func removeConstraints(){
        
       if let constraints =  self.superview?.constraints.filter({constraint in
            if let item = (constraint.firstItem as? UIView) {
                return item == self
            }
            return false
       }){
           self.superview?.removeConstraints(constraints)
       }
    }
    
    func removeConstraint(attribute: NSLayoutConstraint.Attribute){
        
       if let constraints =  self.superview?.constraints.filter({constraint in
            if let item = (constraint.firstItem as? UIView) {
                return item == self && constraint.firstAttribute == attribute
            }
            return false
       }){
           self.superview?.removeConstraints(constraints)
       }
    }
    
    func addBottomBorder(color: UIColor = .black, margins: CGFloat = 0, borderLineSize: CGFloat = 1) {
            let border = UIView()
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(border)
        
        border.setHeight(constant: 1)
        border.setBottom(offSet: 0)
        border.setLeft(offSet: 0)
        border.setRight(offSet: 0)
//            border.addConstraint(NSLayoutConstraint(item: border,
//                                                    attribute: .height,
//                                                    relatedBy: .equal,
//                                                    toItem: nil,
//                                                    attribute: .height,
//                                                    multiplier: 1, constant: borderLineSize))
//            self.addConstraint(NSLayoutConstraint(item: border,
//                                                  attribute: .bottom,
//                                                  relatedBy: .equal,
//                                                  toItem: self,
//                                                  attribute: .bottom,
//                                                  multiplier: 1, constant: 0))
//            self.addConstraint(NSLayoutConstraint(item: border,
//                                                  attribute: .leading,
//                                                  relatedBy: .equal,
//                                                  toItem: self,
//                                                  attribute: .leading,
//                                                  multiplier: 1, constant: margins))
//            self.addConstraint(NSLayoutConstraint(item: border,
//                                                  attribute: .trailing,
//                                                  relatedBy: .equal,
//                                                  toItem: self,
//                                                  attribute: .trailing,
//                                                  multiplier: 1, constant: margins))
        }
    
}
