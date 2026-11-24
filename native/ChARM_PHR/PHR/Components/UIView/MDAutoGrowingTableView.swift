//
//  MDAutoGrowingTableView.swift
//  phr
//
//  Created by Sankar Saravanan on 02/12/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

class MDAutoGrowingTableView: UITableView{  //TableViewWithIndicator {

    var minHeight : CGFloat = 0
    var maxHeight : CGFloat?
    var heightConstraint : NSLayoutConstraint!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if maxHeight == nil
        {
            if ( self.contentSize.height > self.minHeight )
            {
                self.heightConstraint.constant = self.contentSize.height;
            }
            else
            {
                self.heightConstraint.constant = self.minHeight;
            }
        }else
        {
            if ( self.contentSize.height > self.minHeight && self.contentSize.height <= maxHeight! )
            {
                self.heightConstraint.constant = self.contentSize.height;
            }
            else if(self.contentSize.height >= maxHeight!)
            {
                self.heightConstraint.constant = maxHeight!
            }
            else
            {
                self.heightConstraint.constant = minHeight;
            }
        }
    }
}

class MDAutoGrowingCollectionView: UICollectionView {

    var minHeight : CGFloat = 0
    var maxHeight : CGFloat?
    var heightConstraint : NSLayoutConstraint!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if maxHeight == nil
        {
            if ( self.contentSize.height > self.minHeight )
            {
                self.heightConstraint.constant = self.contentSize.height;
            }
            else
            {
                self.heightConstraint.constant = self.minHeight;
            }
        }else
        {
            if ( self.contentSize.height > self.minHeight && self.contentSize.height <= maxHeight! )
            {
                self.heightConstraint.constant = self.contentSize.height;
            }
            else if(self.contentSize.height >= maxHeight!)
            {
                self.heightConstraint.constant = maxHeight!
            }
            else
            {
                self.heightConstraint.constant = minHeight;
            }
        }
    }
}
