//
//  CollectionViewTitleLabelSectionHeader.swift
//  phr
//
//  Created by Dhanuprasanya P on 22/06/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import Foundation

class CollectionViewTitleLabelSectionHeader: UICollectionReusableView {
     var label: UILabel = {
         let label: UILabel = UILabel()
         label.textColor = .black
         label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
         label.sizeToFit()
         return label
     }()

     override init(frame: CGRect) {
         super.init(frame: frame)

         addSubview(label)
        
        label.backgroundColor = UIColor.red
        
        self.backgroundColor = UIColor.yellow

         label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[label]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["label":label]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-X_SPACE-[label]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["label":label]))
        
         
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
