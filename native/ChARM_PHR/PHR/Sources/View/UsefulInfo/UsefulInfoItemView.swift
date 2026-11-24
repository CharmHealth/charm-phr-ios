//
//  UsefulInfiItemView.swift
//  phr
//
//  Created by prathi-13964 on 20/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class UsefulInfoItemView: UIView{
    
    let verticalStackView = UIStackView()
    let dateLabel = UILabel()
    let categoryLabel = UILabel()
    let fromLabel = UILabel()
    let facilityListLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(categoryLabel)
        verticalStackView.addArrangedSubview(fromLabel)
        verticalStackView.addArrangedSubview(facilityListLabel)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setRight(offSet: -CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        
        dateLabel.setLeft(offSet: 0)
        dateLabel.setRight(offSet: 0)
        
        categoryLabel.setLeft(offSet: 0)
        categoryLabel.setRight(offSet: 0)
        
        fromLabel.setLeft(offSet: 0)
        fromLabel.setRight(offSet: 0)
        
        facilityListLabel.setLeft(offSet: 0)
        facilityListLabel.setRight(offSet: 0)
    }
    
    private func addProperties(){
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.spacing = ITEM_VERTICAL_MARGIN
        
        setLabelProperties(uiLabel: dateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold)
        setLabelProperties(uiLabel: categoryLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        fromLabel.text = getString(key: "com.charmphr.allergies.itemView.from.title")
        setLabelProperties(uiLabel: fromLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        fromLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
        
        setLabelProperties(uiLabel: facilityListLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
    }
    
    private func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textAlignment = .left
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
