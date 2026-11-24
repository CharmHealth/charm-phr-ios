//
//  File.swift
//  phr
//
//  Created by prathi-13964 on 04/07/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class FlowsheetItemView: UIView{
    
    let flowsheetNameLabel = UILabel()
    let flowsheetFillFrequencyLabel = UILabel()
    let flowsheetFillFrequencyValueLabel = UILabel()

    init(){
        super.init(frame: .zero)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews(){
        self.addSubview(flowsheetNameLabel)
        self.addSubview(flowsheetFillFrequencyLabel)
        self.addSubview(flowsheetFillFrequencyValueLabel)
        
        setProperties()
        addConstraints()
    }
    private func addConstraints(){
            
        flowsheetNameLabel.setLeft(offSet: CARD_PADDING)
        flowsheetNameLabel.setRight(offSet: -CARD_PADDING)
        flowsheetNameLabel.setTop(offSet: CARD_PADDING)

        flowsheetFillFrequencyLabel.setLeft(offSet: CARD_PADDING)
        flowsheetFillFrequencyLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: flowsheetNameLabel, relatedAttribute: .bottom)
        flowsheetFillFrequencyLabel.setBottom(offSet: -CARD_PADDING)
        
        flowsheetFillFrequencyValueLabel.setLeft(offSet: 193)
        flowsheetFillFrequencyValueLabel.setRight(offSet: -CARD_PADDING)
        flowsheetFillFrequencyValueLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: flowsheetNameLabel, relatedAttribute: .bottom)
        flowsheetFillFrequencyValueLabel.setBottom(offSet: -CARD_PADDING)
    }
    private func setProperties(){
        
        addShadowAndCornerRadius(.SMALL)
        
        flowsheetNameLabel.numberOfLines = 0
        flowsheetNameLabel.lineBreakMode = .byTruncatingTail
        flowsheetNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        flowsheetNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)

        flowsheetFillFrequencyLabel.numberOfLines = 0
        flowsheetFillFrequencyLabel.lineBreakMode = .byTruncatingTail
        flowsheetFillFrequencyLabel.text = getString(key: "com.charmphr.flowsheet.fillfrequency.title")
        flowsheetFillFrequencyLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        flowsheetFillFrequencyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)

        flowsheetFillFrequencyValueLabel.numberOfLines = 1
        flowsheetFillFrequencyValueLabel.lineBreakMode = .byTruncatingTail
        flowsheetFillFrequencyValueLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        flowsheetFillFrequencyValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: FLOWSHEET_FREQUENCY_LABEL_COLOR)
    }
}
