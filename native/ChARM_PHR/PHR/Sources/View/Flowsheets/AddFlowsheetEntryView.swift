//
//  AddFlowsheetEntryView.swift
//  phr
//
//  Created by prathi-13964 on 04/07/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation

import UIKit

class AddFlowsheetEntryView: UIView{
    
    let stackView = UIStackView()
    let observedCard = UIView()
    let observedLabel = UILabel()
    let verticalLine = UIView()
    let flowsheetEntryDateField = DateTextField()
    let containerScrollView = TPKeyboardAvoidingScrollView()
    
    let icon = UIImageView(image: UIImage(named: "Calendar"))

    init(){
        
        super.init(frame: .zero)
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        setSubViews()
    }
       
    required init?(coder: NSCoder){
        
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setSubViews(){
        
        self.addSubview(containerScrollView)
    
        containerScrollView.addSubview(stackView)
        stackView.addArrangedSubview(observedCard)
        observedCard.addSubview(observedLabel)
        observedCard.addSubview(flowsheetEntryDateField)
        observedCard.addSubview(verticalLine)
        observedCard.addSubview(icon)
            
        setProperties()
        addConstraints()
    }

    func setProperties(){
        
        stackView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)

        stackView.distribution = .fill
        stackView.spacing = CARD_PADDING
        stackView.axis = .vertical

        observedCard.addShadowAndCornerRadius(.SMALL)
        
        observedLabel.numberOfLines = 0
        observedLabel.lineBreakMode = .byTruncatingTail
        observedLabel.text = getString(key: "com.charmphr.flowsheetentry.observed.title")
        observedLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        observedLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)

        flowsheetEntryDateField.backgroundColor = .clear
        flowsheetEntryDateField.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        flowsheetEntryDateField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        verticalLine.setBackgroundColor(bgColor: SEPARATOR_COLOR)
    }
    
    func addConstraints(){
        
        containerScrollView.setLeft(offSet: 0)
        containerScrollView.setRight(offSet: 0)
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
        
        stackView.setLeft(offSet: 0)
        stackView.setRight(offSet: 0)
        stackView.setTop(offSet: CARD_PADDING)
        stackView.setBottom(offSet: -CARD_PADDING)
        
        observedCard.setLeft(offSet: CARD_PADDING)
        observedCard.setWidth(constant: (applicationFrame.width - 20))
        
        observedLabel.setLeft(offSet: CARD_PADDING)
        observedLabel.setRight(offSet: -CARD_PADDING)
        observedLabel.setTop(offSet: CARD_PADDING)
        
        flowsheetEntryDateField.setLeft(offSet: CARD_PADDING)
        flowsheetEntryDateField.setRight(offSet: -CARD_PADDING)
        flowsheetEntryDateField.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: observedLabel, relatedAttribute: .bottom)
        flowsheetEntryDateField.setBottom(offSet: -CARD_PADDING)
        
        icon.setRight(offSet: -CARD_PADDING)
        icon.setCenterY()
        icon.setWidth(constant: 25)
        icon.setHeight(constant: 25)
        
        verticalLine.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: icon, relatedAttribute: .left)
        verticalLine.setTop(offSet: 5)
        verticalLine.setBottom(offSet: -5)
        verticalLine.setWidth(constant: 1)
    }
}

class CommonFlowsheetLayout: UIView {
    
    let commonFlowsheetLabel = UILabel()
    
    let commonFlowsheetMainLayout = UIView()
    init(notes : String? ) {
        super.init(frame: .zero)
        addShadowAndCornerRadius(.SMALL)
        
        commonFlowsheetLabel.text = notes
        commonFlowsheetLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        commonFlowsheetLabel.numberOfLines = 0
        self.addSubview(commonFlowsheetLabel)
        
        commonFlowsheetLabel.setTop(offSet:CARD_PADDING)
        commonFlowsheetLabel.setLeft(offSet: CARD_PADDING)
    
        commonFlowsheetLabel.setWidth(constant: applicationFrame.width - (2 * X_SPACE) - (2 * CARD_PADDING))

        let separator = UIView()
        
        self.addSubview(separator)
        separator.setBackgroundColor(bgColor: SEPARATOR_COLOR)
        separator.setTopRelatedToView(offSet: CARD_PADDING, relatedView: commonFlowsheetLabel, relatedAttribute: .bottom)
        separator.setLeft(offSet: 0)
        separator.setRight(offSet: 0)
        separator.setHeight(constant: 1)
        
        self.addSubview(commonFlowsheetMainLayout)
        
        commonFlowsheetMainLayout.setRight(offSet: 0)
        commonFlowsheetMainLayout.setLeft(offSet: 0)
        commonFlowsheetMainLayout.setTopRelatedToView(offSet: 0, relatedView: separator, relatedAttribute: .bottom)
        commonFlowsheetMainLayout.setBottom(offSet: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CommonFieldUnitView: UIView, UITextFieldDelegate{
    
    let commonTextField = UITextField()
    let commonUnitLabel = UILabel()

    init(notes : String? ) {
        super.init(frame: .zero)
        
        self.addCornerRadius(.SMALL)
        self.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SHADOW_COLOR).cgColor
        self.layer.borderWidth = BORDER_WIDTH
        self.backgroundColor = .white
        
        self.addSubview(commonTextField)
        
        self.addSubview(commonUnitLabel)
        
        commonTextField.keyboardType = .numberPad
        commonTextField.delegate = self
        commonTextField.contentVerticalAlignment = .center
        commonTextField.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        commonTextField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        commonTextField.returnKeyType = .done
        commonTextField.setPadding(width: TEXTFIELD_PADDING_5)
        
        commonTextField.setLeft(offSet: 0)
        commonTextField.setRightRelatedToView(offSet: 0, relatedView: commonUnitLabel, relatedAttribute: .left)
        commonTextField.setTop(offSet: 0)
        commonTextField.setBottom(offSet: 0)
        commonTextField.setHeight(constant: TEXTFIELD_HEIGHT)
        
        commonUnitLabel.textAlignment = .center
        commonUnitLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        commonUnitLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        commonUnitLabel.text = notes
        commonUnitLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: FLOWSHEET_UNIT_BG)
        
        commonUnitLabel.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: commonTextField, relatedAttribute: .right)
        commonUnitLabel.setRight(offSet: 0)
        commonUnitLabel.setTop(offSet: 0)
        commonUnitLabel.setWidth(constant: 60)
        commonUnitLabel.setBottom(offSet: 0)
    }
    
    func setConstraints(){
        self.setLeft(offSet: 0)
        self.setRight(offSet: 0)
        self.setBottom(offSet: 0)
        self.setHeight(constant: TEXTFIELD_HEIGHT)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//The field does not have cut and paste option

class DateTextField: MDTextField{

    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
      }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) ||  action == #selector(UIResponderStandardEditActions.cut(_:)){
                return false
            }
        return super.canPerformAction(action, withSender: sender)
    
    }
}
