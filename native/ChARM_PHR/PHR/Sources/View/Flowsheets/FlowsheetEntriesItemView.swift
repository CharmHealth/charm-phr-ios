//
//  FlowsheetEntriesItemView.swift
//  phr
//
//  Created by prathi-13964 on 04/07/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class FlowsheetEntriesItemView: UIView{
    
    let observedLabel = UILabel()
    let flowsheetEntryDateLabel = UILabel()
 
    init(){
        super.init(frame: .zero)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews(){
        
        self.addSubview(observedLabel)
        self.addSubview(flowsheetEntryDateLabel)
    
        setProperties()
        addConstraints()
    }
    private func addConstraints(){
        
        observedLabel.setLeft(offSet: CARD_PADDING)
        observedLabel.setRight(offSet: -CARD_PADDING)
        observedLabel.setTop(offSet: CARD_PADDING)
        
        flowsheetEntryDateLabel.setLeft(offSet: CARD_PADDING)
        flowsheetEntryDateLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: observedLabel, relatedAttribute: .bottom)
        flowsheetEntryDateLabel.setBottom(offSet: -CARD_PADDING)
    }
    private func setProperties(){
    
        addShadowAndCornerRadius(.SMALL)

        observedLabel.numberOfLines = 0
        observedLabel.lineBreakMode = .byTruncatingTail
        observedLabel.text = getString(key: "com.charmphr.flowsheetentry.observed.title")
        observedLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        observedLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)

        flowsheetEntryDateLabel.numberOfLines = 0
        flowsheetEntryDateLabel.lineBreakMode = .byTruncatingTail
        flowsheetEntryDateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        flowsheetEntryDateLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
    }
}
