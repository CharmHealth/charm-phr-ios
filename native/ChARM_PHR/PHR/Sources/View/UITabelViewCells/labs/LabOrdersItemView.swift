//
//  LabOrdersItemView.swift
//  phr
//
//  Created by prathi-13964 on 19/04/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation

class LabOrdersItemView: UIView{
    
    private let verticalStackView = UIStackView()
    let dateLabel = UILabel()
    let documentNameLabel = UILabel()
    let shareByView = UIView()
    private let shareByLabel = UILabel()
    let sharedByProviderNameLabel = UILabel()
    private let fromView = UIView()
    private let horizontalLine = UIView()
    private let fromLabel = UILabel()
    let facilityListLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        setSubviews()
    }
    
    private func setSubviews(){
        
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(documentNameLabel)
        verticalStackView.addArrangedSubview(shareByView)
        shareByView.addSubview(shareByLabel)
        shareByView.addSubview(sharedByProviderNameLabel)
        verticalStackView.addArrangedSubview(fromView)
        fromView.addSubview(horizontalLine)
        fromView.addSubview(fromLabel)
        fromView.addSubview(facilityListLabel)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setRight(offSet: -CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        
        shareByLabel.setLeft(offSet: 0)
        shareByLabel.setTop(offSet: 0)
        shareByLabel.wrapHeight(maxHeight: 60)
        shareByLabel.wrapWidth(maxWidth: 400)
        
        sharedByProviderNameLabel.setLeftRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: shareByLabel, relatedAttribute: .right)
        sharedByProviderNameLabel.setRight(offSet: 0)
        sharedByProviderNameLabel.setTop(offSet: 0)
        sharedByProviderNameLabel.setBottom(offSet: 0)
                
        horizontalLine.setHeight(constant: LINE_HEIGHT)
        horizontalLine.setLeft(offSet: 0)
        horizontalLine.setRight(offSet: 0)
        horizontalLine.setTop(offSet: PADDING_5)
        
        fromLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: horizontalLine, relatedAttribute: .bottom)
        fromLabel.setLeft(offSet: 0)
        fromLabel.setRight(offSet: 0)
        
        facilityListLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: fromLabel, relatedAttribute: .bottom)
        facilityListLabel.setLeft(offSet: 0)
        facilityListLabel.setRight(offSet: 0)
        facilityListLabel.setBottom(offSet: 0)
    }
    
    private func addProperties(){
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = STACKVIEW_VERTICAL_PADDING
        verticalStackView.alignment = .fill
        
        self.addShadowAndCornerRadius(.SMALL)
        
        dateLabel.setProperties(textKey: "", fontsize: FONT_SIZE_MEDIUM, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        documentNameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        documentNameLabel.numberOfLines = 0
                
        shareByLabel.setProperties(textKey: getString(key: "com.charmphr.labOrders.shareBy.title"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_GREY)
        sharedByProviderNameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        sharedByProviderNameLabel.numberOfLines = 0
        
        fromLabel.setProperties(textKey: getString(key: "com.charmphr.allergies.itemView.from.title"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        
        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)
        
        facilityListLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        facilityListLabel.numberOfLines = 0
    }
    
    func setFontWeight(isRead: Bool){
        if isRead{
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .medium)
            documentNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            sharedByProviderNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            facilityListLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        }
        else{
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
            documentNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
            sharedByProviderNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
            facilityListLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
