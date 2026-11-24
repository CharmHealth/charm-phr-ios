//
//  KeyAndValueLabelView.swift
//  phr
//
//  Created by Sankar Saravanan on 13/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class KeyAndValueLabelView: UIView {
    
    let keyLabel = UILabel()
    let valueLabel = UILabel()
    
    var keyLabelTopConstraint : NSLayoutConstraint!
    var valueLabelBottomConstraint : NSLayoutConstraint!
    var keyAndValueLabelInbetweenConstraint : NSLayoutConstraint!
    
    init() {
        super.init(frame:.zero)
        
        self.backgroundColor = .clear
        
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.backgroundColor = .clear
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUM_LIGHT)
        self.addSubview(keyLabel)
        
        valueLabel.font = .systemFont(ofSize: FONT_SIZE_VALUE_LABEL, Weight: .regular)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.numberOfLines = 0
        valueLabel.backgroundColor = .clear
        self.addSubview(valueLabel)
                
        keyLabelTopConstraint = NSLayoutConstraint(item: keyLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        self.addConstraint(keyLabelTopConstraint)
        keyLabel.setLeft(offSet: 0)
        keyLabel.setRight(offSet: 0)
        keyAndValueLabelInbetweenConstraint = NSLayoutConstraint(item: keyLabel, attribute: .bottom, relatedBy: .equal, toItem: valueLabel, attribute: .top, multiplier: 1, constant: 0)
        self.addConstraint(keyAndValueLabelInbetweenConstraint)
        valueLabel.setLeft(offSet: 0)
        valueLabel.setRight(offSet: 0)
        valueLabelBottomConstraint = NSLayoutConstraint(item: valueLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        self.addConstraint(valueLabelBottomConstraint)
    }
    
    func layoutChange()
    {
        self.superview?.layoutIfNeeded()
        if isNilOrEmpty(string: valueLabel.text)
        {
            keyLabelTopConstraint.constant = 0
            valueLabelBottomConstraint.constant = 0
            keyAndValueLabelInbetweenConstraint.constant = 0
        }else
        {
            keyAndValueLabelInbetweenConstraint.constant = -4
            keyLabelTopConstraint.constant = 5
            valueLabelBottomConstraint.constant = -5
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
