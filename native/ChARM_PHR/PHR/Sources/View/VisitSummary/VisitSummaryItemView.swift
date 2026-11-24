//
//  VisitSummaryItemView.swift
//  phr
//
//  Created by prathi-13964 on 20/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class VisitSummaryItemView: UIView{
    
    let verticalStackView = UIStackView()
    let dateLabel = UILabel()
    let facilityAndProviderLabel = UILabel()
    let reasonView = UIView()
    let reasonLabel = UILabel()
    let reasonValueLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        setSubviews()
    }
    
    private func setSubviews(){
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(facilityAndProviderLabel)
        verticalStackView.addArrangedSubview(reasonView)
        reasonView.addSubview(reasonLabel)
        reasonView.addSubview(reasonValueLabel)
        
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
        
        facilityAndProviderLabel.setLeft(offSet: 0)
        facilityAndProviderLabel.setRight(offSet: 0)
        
        reasonView.setLeft(offSet: 0)
        reasonView.setRight(offSet: 0)
        
        reasonLabel.setLeft(offSet: 0)
        reasonLabel.setTop(offSet: 0)
        reasonLabel.setBottom(offSet: 0)
        reasonLabel.setWidth(constant: reasonLabel.sizeThatFits(CGSize(width: 400, height: 50)).width)
        
        reasonValueLabel.setLeftRelatedToView(offSet: 0, relatedView: reasonLabel, relatedAttribute: .right)
        reasonValueLabel.setTop(offSet: 0)
        reasonValueLabel.setBottom(offSet: 0)
        reasonValueLabel.setRight(offSet: 0)
        
    }
    private func addProperties(){
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.spacing = ITEM_VERTICAL_MARGIN
        
        setLabelProperties(uiLabel: dateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold)
        setLabelProperties(uiLabel: facilityAndProviderLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        reasonLabel.text = getString(key: "com.charmphr.visitSummary.itemView.reason.title")
        setLabelProperties(uiLabel: reasonLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: reasonValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
    }
    
    func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textAlignment = .left
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setFontWeight(isRead: Bool){
        if isRead{
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
            facilityAndProviderLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        }
        else{
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
            facilityAndProviderLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
