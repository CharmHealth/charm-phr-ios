//
//  UIView+BorderLayer.swift
//  phr
//
//  Created by Sankar Saravanan on 28/05/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

extension UIView
{
    
    func addBorder()
    {
        self.addLeftBorder()
        self.addRightBorder()
        self.addTopBorder()
        self.addBottomBorder()
    }
    
    func addBorder(color : UIColor)
    {
        self.addLeftBorder(color:color)
        self.addRightBorder(color:color)
        self.addTopBorder(color:color)
        self.addBottomBorder(color:color)
    }
    
    func addBorder(borderWidth : CGFloat)
    {
        self.addLeftBorder(borderWidth: borderWidth)
        self.addRightBorder(borderWidth: borderWidth)
        self.addTopBorder(borderWidth: borderWidth)
        self.addBottomBorder(borderWidth: borderWidth)
    }
    
    func addBorder(color : UIColor ,borderWidth : CGFloat)
    {
        self.addLeftBorder(color: color, borderWidth: borderWidth)
        self.addRightBorder(color: color, borderWidth: borderWidth)
        self.addTopBorder(color: color, borderWidth: borderWidth)
        self.addBottomBorder(color: color, borderWidth: borderWidth)
    }
    
    
    //BOTTOM
    func addBottomBorder()
    {
        self.addBottomBorder(color: DEFAULT_BORDER_COLOR, borderWidth: DEFAULT_BORDER_WIDTH)
    }
    
    func addBottomBorder(color : UIColor)
    {
        self.addBottomBorder(color: color, borderWidth: DEFAULT_BORDER_WIDTH)
    }
    
    func addBottomBorder(borderWidth : CGFloat)
    {
        self.addBottomBorder(color: DEFAULT_BORDER_COLOR, borderWidth: borderWidth)
    }
    
    func addBottomBorder(color : UIColor , borderWidth : CGFloat)
    {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth,.flexibleTopMargin]
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width:  self.frame.size.width, height: borderWidth)
        self.addSubview(border)
    }
    
    
    //TOP
    func addTopBorder()
    {
        self.addTopBorder(color: DEFAULT_BORDER_COLOR, borderWidth: DEFAULT_BORDER_WIDTH)
    }
    
    func addTopBorder(color : UIColor)
    {
        self.addTopBorder(color: color, borderWidth: DEFAULT_BORDER_WIDTH)
    }
    
    func addTopBorder(borderWidth : CGFloat)
    {
        self.addTopBorder(color: DEFAULT_BORDER_COLOR, borderWidth: borderWidth)
    }
    
    func addTopBorder(color : UIColor , borderWidth : CGFloat)
    {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth,.flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: borderWidth)
        self.addSubview(border)
    }
    
    func addAndReturnTopBorder(color : UIColor , borderWidth : CGFloat) -> UIView{
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth,.flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: borderWidth)
        self.addSubview(border)
        
        return border
    }
    
    //LEFT
    func addLeftBorder()
    {
        self.addLeftBorder(color: DEFAULT_BORDER_COLOR, borderWidth: DEFAULT_BORDER_WIDTH)
    }
    
    func addLeftBorder(color : UIColor)
    {
        self.addLeftBorder(color: color, borderWidth: DEFAULT_BORDER_WIDTH)
    }
    
    func addLeftBorder(borderWidth : CGFloat)
    {
        self.addLeftBorder(color: DEFAULT_BORDER_COLOR, borderWidth: borderWidth)
    }
    
    func addLeftBorder(color : UIColor , borderWidth : CGFloat)
    {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight,.flexibleRightMargin]
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: self.frame.size.height)
        self.addSubview(border)
    }
    
    
    //RIGHT
    func addRightBorder()
    {
        self.addRightBorder(color: DEFAULT_BORDER_COLOR, borderWidth: DEFAULT_BORDER_WIDTH)
    }
    
    func addRightBorder(color : UIColor)
    {
        self.addRightBorder(color: color, borderWidth: DEFAULT_BORDER_WIDTH)
    }
    
    func addRightBorder(borderWidth : CGFloat)
    {
        self.addRightBorder(color: DEFAULT_BORDER_COLOR, borderWidth: borderWidth)
    }
    
    func addRightBorder(color : UIColor , borderWidth : CGFloat)
    {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight,.flexibleLeftMargin]
        border.frame = CGRect(x: self.frame.size.width - borderWidth, y: 0, width: borderWidth, height: self.frame.size.height)
        self.addSubview(border)
    }
}
