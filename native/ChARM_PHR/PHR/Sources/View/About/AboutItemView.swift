//
//  File.swift
//  phr
//
//  Created by prathi-13964 on 23/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AboutFacilityItemView: UIView{
    
    let verticalStackView = UIStackView()
    let facilityLocationView = UIView()
    let facilityNameLabel = UILabel()
    let locationIcon = UIImageView(image: UIImage(named: "Location"))
    let addressLine1Label = UILabel()
    let phoneNumberView = UIView()
    let phoneLabel = UILabel()
    let phoneNumberLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(facilityLocationView)
        facilityLocationView.addSubview(facilityNameLabel)
        facilityLocationView.addSubview(locationIcon)
        verticalStackView.addArrangedSubview(addressLine1Label)
        verticalStackView.addArrangedSubview(phoneNumberView)
        phoneNumberView.addSubview(phoneLabel)
        phoneNumberView.addSubview(phoneNumberLabel)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setRight(offSet: -CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        
        facilityLocationView.setLeft(offSet: 0)
        facilityLocationView.setRight(offSet: 0)
        
        facilityNameLabel.setLeft(offSet: 0)
        facilityNameLabel.setTop(offSet: 0)
        facilityNameLabel.setBottom(offSet: 0)
        facilityNameLabel.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: locationIcon, relatedAttribute: .left)
        
        locationIcon.setRight(offSet: 0)
        locationIcon.setTop(offSet: 0)
        locationIcon.setBottom(offSet: 0)
        locationIcon.setHeight(constant: BUTTON_HEIGHT_20)
        locationIcon.setWidth(constant: BUTTON_HEIGHT_20)
        
        addressLine1Label.setLeft(offSet: 0)
        addressLine1Label.setRight(offSet: 0)
        
        phoneNumberView.setLeft(offSet: 0)
        phoneNumberView.setRight(offSet: 0)
        
        phoneLabel.setLeft(offSet: 0)
        phoneLabel.setTop(offSet: 0)
        phoneLabel.setBottom(offSet: 0)
        phoneLabel.setWidth(constant: phoneLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        
        phoneNumberLabel.setLeftRelatedToView(offSet: 0, relatedView: phoneLabel, relatedAttribute: .right)
        phoneNumberLabel.setRight(offSet: 0)
        phoneNumberLabel.setTop(offSet: 0)
        phoneNumberLabel.setBottom(offSet: 0)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.spacing = STACKVIEW_VERTICAL_PADDING
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        
        setLabelProperties(uiLabel: facilityNameLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold)
        setLabelProperties(uiLabel: addressLine1Label, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        phoneLabel.text = "Phone: "
        setLabelProperties(uiLabel: phoneLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        setLabelProperties(uiLabel: phoneNumberLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
    }
    
    private func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AboutProviderItemView: UIView{
    
    let verticalStackView = UIStackView()
    let providerNameLabel = UILabel()
    let specializationLabel = UILabel()
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(providerNameLabel)
        verticalStackView.addArrangedSubview(specializationLabel)
        addProperties()
        addConstraints()
    }
    private func addConstraints(){
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setRight(offSet: -CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        
        providerNameLabel.setLeft(offSet: 0)
        providerNameLabel.setRight(offSet: 0)
        
        specializationLabel.setLeft(offSet: 0)
        specializationLabel.setRight(offSet: 0)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.spacing = STACKVIEW_VERTICAL_PADDING
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        
        providerNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        providerNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        
        specializationLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        specializationLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
