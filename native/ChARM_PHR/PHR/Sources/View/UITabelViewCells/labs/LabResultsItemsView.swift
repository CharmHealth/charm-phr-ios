//
//  LabsItemView.swift
//  phr
//
//  Created by prathi-13964 on 21/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class LabResultsItemsView: UIView{
    
    let dateLabel = UILabel()
    let resultLabel = UILabel()
    private let labNameLabel = UILabel()
    let labNameValueLabel = UILabel()
    let recordslistNameLabel = UILabel()
    private let verticalStackView = UIStackView()
    let horizontalLine = UIView()
    let fromView = UIView()
    private let fromLabel = UILabel()
    let practiceLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(dateLabel)
        self.addSubview(resultLabel)
        self.addSubview(labNameLabel)
        self.addSubview(labNameValueLabel)
        self.addSubview(recordslistNameLabel)
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(fromView)
        fromView.addSubview(horizontalLine)
        fromView.addSubview(fromLabel)
        fromView.addSubview(practiceLabel)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
    
        dateLabel.setLeft(offSet: CARD_PADDING)
        dateLabel.setTop(offSet: CARD_PADDING)
        
        resultLabel.setRight(offSet: -15)
        resultLabel.setTop(offSet: CARD_PADDING)
        
        labNameLabel.setLeft(offSet: CARD_PADDING)
        labNameLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: dateLabel, relatedAttribute: .bottom)
        labNameLabel.wrapWidth(maxWidth: 300)
        
        labNameValueLabel.setLeftRelatedToView(offSet: PADDING_4, relatedView: labNameLabel, relatedAttribute: .right)
        labNameValueLabel.setRight(offSet: -CARD_PADDING)
        labNameValueLabel.setTopRelatedToView(offSet: 0, relatedView: labNameLabel, relatedAttribute: .top)
        
        recordslistNameLabel.setLeft(offSet: CARD_PADDING)
        recordslistNameLabel.setRight(offSet: -CARD_PADDING)
        recordslistNameLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: labNameValueLabel, relatedAttribute: .bottom)
        
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setRight(offSet: CARD_PADDING)
        verticalStackView.setTopRelatedToView(offSet: PADDING_8, relatedView: recordslistNameLabel, relatedAttribute: .bottom)
        verticalStackView.setBottom(offSet: -2)
        
        horizontalLine.setHeight(constant: LINE_HEIGHT)
        horizontalLine.setLeft(offSet: 0)
        horizontalLine.setRight(offSet: 0)
        horizontalLine.setTop(offSet: 0)
        
        fromLabel.setLeft(offSet: 0)
        fromLabel.setRight(offSet: 0)
        fromLabel.setTopRelatedToView(offSet: PADDING_8, relatedView: horizontalLine, relatedAttribute: .bottom)
        fromLabel.wrapWidth(maxWidth: 100)
        
        practiceLabel.setLeft(offSet: 0)
        practiceLabel.setRight(offSet: 0)
        practiceLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: fromLabel, relatedAttribute: .bottom)
        practiceLabel.setBottom(offSet: -PADDING_8)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = PADDING_8
        verticalStackView.alignment = .fill
        
        dateLabel.setProperties(fontsize: FONT_SIZE_MEDIUM, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        resultLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_DARK)
        
        labNameLabel.setProperties(textKey: "com.charmphr.labsResults.item.labname.title", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_GREY)
        labNameValueLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        labNameValueLabel.numberOfLines = 2
        labNameValueLabel.lineBreakMode = .byTruncatingTail
        
        recordslistNameLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        recordslistNameLabel.numberOfLines = 0
                
        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)
        
        fromLabel.setProperties(textKey: "com.charmphr.allergies.itemView.from.title", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        practiceLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        practiceLabel.numberOfLines = 0
    }
    
    func setFontWeight(isRead: Bool){
        if isRead{
            labNameValueLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .medium)
            practiceLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            recordslistNameLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        }
        else{
            labNameValueLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
            practiceLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
            recordslistNameLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
