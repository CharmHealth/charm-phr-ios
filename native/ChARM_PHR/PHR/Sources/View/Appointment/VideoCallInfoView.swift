//
//  VideoCallInfoView.swift
//  phr
//
//  Created by Raghul D on 10/09/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

class VideoCallInfoView: UIView {
    
    private weak var delegate: VideoCallInfoViewController? = nil
    
    let copyBtn = UIButton()
    let proceedBtn = UIButton()

    init(delegate: VideoCallInfoViewController?){
        self.delegate = delegate
        super.init(frame: .zero)
        
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews(){
    
        let headingLabel = UILabel()
        let infoLabel = UILabel()
        
        let pwdView = UIView()
        let pwdLabel = UILabel()

        let subHeadingLabel = UILabel()

        addSubview(headingLabel)
        addSubview(infoLabel)
        addSubview(proceedBtn)
        addSubview(pwdView)
        addSubview(subHeadingLabel)
        
        pwdView.addSubview(pwdLabel)
        pwdView.addSubview(copyBtn)
        
        headingLabel.setProperties(textKey: "com.charmphr.opentok.heading", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        infoLabel.setProperties(textKey: "com.charmphr.opentok.info", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: 0x262626DB)
        infoLabel.numberOfLines = 0
        
        proceedBtn.setProperties(titleStrKey: "com.charmphr.feedback.action.proceed", fontsize: FONT_SIZE_VALUE_LABEL, weight: .semibold, fontcolor: TEXT_COLOR_WHITE, bgcolor: THEME_COLOR)
        proceedBtn.addPillCornerRadiusAndShadow(height: 36)
        proceedBtn.titleLabel?.textAlignment = .center
        
        copyBtn.setProperties(titleStrKey: "com.charmphr.opentok.copy.label", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: THEME_COLOR, bgcolor: LIGHT_BLUE_BACKGROUND_COLOR)
        
        copyBtn.addCornerRadius(.SMALL)
        copyBtn.layer.masksToBounds = true
        copyBtn.titleLabel?.textAlignment = .center
        
        backgroundColor = .white
        
        pwdLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        pwdLabel.text = delegate?.zoomCredentials?.password ?? ""
        
        pwdView.addCornerRadius(.SMALL)
        pwdView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        pwdView.layer.borderWidth = BORDER_WIDTH
        
        subHeadingLabel.setProperties(textKey: "com.charmphr.opentok.subheading", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)

        addShadowAndCornerRadius(.LARGE)
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        headingLabel.setTop(offSet: X_SPACE)
        headingLabel.setLeft(offSet: X_SPACE)
        
        infoLabel.setLeft(offSet: X_SPACE)
        infoLabel.setRight(offSet: -X_SPACE)
        infoLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: headingLabel, relatedAttribute: .bottom)
        
        proceedBtn.setLeft(offSet: X_SPACE)
        proceedBtn.setRight(offSet: -X_SPACE)
        proceedBtn.setHeight(constant: 36)
        proceedBtn.setBottom(offSet: -X_SPACE)
        
        pwdView.setBottomRelatedToView(offSet: -26, relatedView: proceedBtn, relatedAttribute: .top)
        pwdView.setLeft(offSet: X_SPACE)
        pwdView.setRight(offSet: -X_SPACE)
        pwdView.setHeight(constant: 42)
        
        pwdLabel.setCenterY()
        pwdLabel.setLeft(offSet: X_SPACE)
        pwdLabel.wrapWidth(maxWidth: 300)
        
        copyBtn.setCenterY()
        copyBtn.setHeight(constant: 36)
        copyBtn.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        copyBtn.wrapWidth(maxWidth: 300 , extraSpacing: 2*X_SPACE)
        
        subHeadingLabel.setBottomRelatedToView(offSet: -ITEM_VERTICAL_MARGIN, relatedView: pwdView, relatedAttribute: .top)
        subHeadingLabel.setLeft(offSet: X_SPACE)
        subHeadingLabel.setRight(offSet: -X_SPACE)
    }
    
    
    func addConstraintPostViewLoad(){
        
      //  setWidth(constant: 380)
        setLeft(offSet: X_SPACE)
        setRight(offSet: -X_SPACE)
        setHeight(constant: 278)
        
        //setCenterX()
        setCenterY()
    }
    
    func onPasscodeCopied(){
        copyBtn.setTitle(getString(key: "com.charmphr.opentok.copied.label"), for: .normal)
        copyBtn.setBackgroundColor(bgColor: 0x66BAB21A)
        copyBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: 0x55A39CFF), for: .normal)
        copyBtn.wrapWidth(maxWidth: 300 , extraSpacing: 2*X_SPACE)
    }
    
    func onPassocdeRevert(){
        copyBtn.setTitle(getString(key: "com.charmphr.opentok.copy.label"), for: .normal)
        copyBtn.setBackgroundColor(bgColor: LIGHT_BLUE_BACKGROUND_COLOR)
        copyBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for: .normal)
        copyBtn.wrapWidth(maxWidth: 300 , extraSpacing: 2*X_SPACE)
    }
    
}
