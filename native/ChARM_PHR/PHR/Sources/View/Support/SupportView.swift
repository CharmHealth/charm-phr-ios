//
//  SupportView.swift
//  phr
//
//  Created by prathi-13964 on 19/09/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

let REPORT: String = getString(key: "com.charmphr.support.segment.report.title")
let SUGGEST: String = getString(key: "com.charmphr.support.segment.suggest.title")
let ASK_QUESTION: String = getString(key: "com.charmphr.support.segment.askQuestion.title")
let APPRECIATE: String = getString(key: "com.charmphr.support.segment.appreciate.title")

class SupportView: UIView{
    
    let supportSegmentControl = UISegmentedControl(items: [REPORT, SUGGEST, ASK_QUESTION, APPRECIATE])
    let containerView = TPKeyboardAvoidingScrollView()
    let descriptionView = UIView()
    let attachmentView = UIView()
    let activityIndicator = UIActivityIndicatorView()
    weak var delegate: SupportViewController? = nil
    var attachmentButton: UIButton? = nil
    init(delegate: SupportViewController){
        super.init(frame: .zero)
        self.delegate = delegate
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        setSubViews()
    }
       
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setSubViews(){
        
        self.addSubview(containerView)
        self.addSubview(activityIndicator)
        containerView.addSubview(attachmentView)
        containerView.addSubview(supportSegmentControl)
        containerView.addSubview(descriptionView)
        setProperties()
        addConstraints()
    }
    
    private func setProperties(){
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        descriptionView.addCornerRadius(.SMALL)

        supportSegmentControl.addProperties(fontSize: FONT_SIZE_MEDIUM)
        supportSegmentControl.selectedSegmentIndex = 0
    }
    
    private func addConstraints(){
        
        containerView.setSafeAreaTop(offset: CARD_PADDING)
        containerView.setSafeAreaBottom(offset: 0)
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        supportSegmentControl.setLeft(offSet: X_SPACE)
        supportSegmentControl.setRight(offSet: -X_SPACE)
        supportSegmentControl.setTop(offSet: CARD_PADDING)
        supportSegmentControl.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        supportSegmentControl.setWidth(constant: SUPPORT_FRAME_WIDTH)
        
        descriptionView.setLeft(offSet: X_SPACE)
        descriptionView.setTopRelatedToView(offSet: CARD_PADDING + 1, relatedView: supportSegmentControl, relatedAttribute: .bottom)
        descriptionView.setWidth(constant: SUPPORT_FRAME_WIDTH)
        
        attachmentView.setLeft(offSet: X_SPACE)
        attachmentView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: descriptionView, relatedAttribute: .bottom)
        attachmentView.setBottom(offSet: -CARD_PADDING)
        attachmentView.setWidth(constant: SUPPORT_FRAME_WIDTH)
    }
}

