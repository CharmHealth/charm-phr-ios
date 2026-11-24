//
//  LabResultView.swift
//  phr
//
//  Created by Sankar Saravanan on 29/05/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class LabResultView: UIView {
    
    let nameLabel = UILabel()
    let valueLabel = UILabel()
    let referenceValueLabel = UILabel()
    let interpretationValueLabel = UILabel()

    init() {
        super.init(frame: .zero)
        createSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSubViews()
    }
    
    func createSubViews()
    {
        nameLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        nameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        self.addSubview(nameLabel)
        
        valueLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        self.addSubview(valueLabel)
        
        let referenceLabel = UILabel()
        referenceLabel.text = getString(key: "com.charmphr.labsResults.reference")
        referenceLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        referenceLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        self.addSubview(referenceLabel)
        
        referenceValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        referenceValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        self.addSubview(referenceValueLabel)

//        let interpretationLabel = UILabel()
//        interpretationLabel.text = NSLocalizedString("com.charmphr.labsResults.interpretation", comment: "")
//        interpretationLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
//        interpretationLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR)
//        self.addSubview(interpretationLabel)
        
        interpretationValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        interpretationValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        self.addSubview(interpretationValueLabel)
        
        
        nameLabel.setTop(offSet: 8)
        nameLabel.setLeft(offSet: 10)
        nameLabel.setRight(offSet: -10)
        nameLabel.setBottomRelatedToView(offSet: -3, relatedView: valueLabel, relatedAttribute: .top)
        
        valueLabel.setLeft(offSet: 10)
        valueLabel.setRight(offSet: -10)
        valueLabel.setBottomRelatedToView(offSet: -3, relatedView: referenceLabel, relatedAttribute: .top)
        
        referenceLabel.setLeft(offSet: 10)
        referenceLabel.setBottom(offSet: -5)
        referenceLabel.setRightRelatedToView(offSet: -5, relatedView: referenceValueLabel, relatedAttribute: .left)
        
        referenceValueLabel.setBottom(offSet: -5)
        
        let referenceValueLabelRightConstraint = NSLayoutConstraint(item: referenceValueLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: interpretationValueLabel, attribute: .left, multiplier: 1, constant: -5)
        self.addConstraint(referenceValueLabelRightConstraint)
        
        interpretationValueLabel.setRight(offSet: -10)
        interpretationValueLabel.setBottom(offSet: -5)
        
        
        referenceLabel.setWidth(constant:referenceLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width)
    }

}
