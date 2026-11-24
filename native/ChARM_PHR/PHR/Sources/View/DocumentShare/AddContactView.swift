//
//  AddContactView.swift
//  phr
//
//  Created by prathi-13964 on 03/11/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AddContactView: UIView{
    
    let activityIndicator = UIActivityIndicatorView()
    let containerScrollView = TPKeyboardAvoidingScrollView()
    let stackView = UIStackView()
    let addContactStackView = UIStackView()
    let initialView = CommonAddContactView.init()
    let addmoreView = UIView()
    let addmoreButton = UIButton()
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        self.addSubview(activityIndicator)
        self.addSubview(containerScrollView)
        containerScrollView.addSubview(stackView)
        stackView.addArrangedSubview(addContactStackView)
        stackView.addArrangedSubview(addmoreView)
        addContactStackView.addArrangedSubview(initialView)
        addmoreView.addSubview(addmoreButton)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        containerScrollView.setSafeAreaTop(offset: 0)
        containerScrollView.setLeft(offSet: 0)
        containerScrollView.setRight(offSet: 0)
        containerScrollView.setSafeAreaBottom(offset: 0)
        
        stackView.setLeft(offSet: 0)
        stackView.setRight(offSet: 0)
        stackView.setTop(offSet: CARD_PADDING)
        stackView.setBottom(offSet: -CARD_PADDING)
        
        addContactStackView.setLeft(offSet: 0)
        addContactStackView.setRight(offSet: 0)
       
        initialView.setConstraints()
        
        addmoreView.setLeft(offSet: CARD_PADDING)
        addmoreView.setWidth(constant: applicationFrame.width - (CARD_PADDING * 2))
        addmoreView.setBottom(offSet: -CARD_PADDING)
        
        addmoreButton.setCenterX()
        addmoreButton.setTop(offSet: 0)
        addmoreButton.setBottom(offSet: -CARD_PADDING)
        addmoreButton.setHeight(constant: BUTTON_HEIGHT_32)
        addmoreButton.setWidth(constant: addmoreButton.sizeThatFits(CGSize(width: 300, height: 50)).width)
    }
    
    private func addProperties(){
        
        activityIndicator.color = .gray
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = CARD_PADDING
        
        addContactStackView.axis = .vertical
        addContactStackView.alignment = .fill
        addContactStackView.spacing = CARD_PADDING
        
        addmoreButton.setProperties(titleStrKey: getString(key: "com.charmphr.sharedocuments.addcontactView.addmorebtn.title"), fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLUE)
        addmoreButton.titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Common AddContact View

class CommonAddContactView: UIStackView, UITextFieldDelegate{
    
    let fullNameView = UIView()
    let fullNameLabel = UILabel()
    let fullNameField = UITextField()
    let emailView = UIView()
    let emailLabel = UILabel()
    let emailField = UITextField()
    let removeBtnView = UIView()
    let removeBtn = UIButton()
    
    var autoCompletionPossibilities = [getString(key: "com.charmphr.sharedocuments.addcontact.email_suggestion.gmail"), getString(key: "com.charmphr.sharedocuments.addcontact.email_suggestion.apple"), getString(key: "com.charmphr.sharedocuments.addcontact.email_suggestion.yahoo")]
    var autoCompleteCharacterCount = 0
    var timer = Timer()
    var emailIdVal = ""
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        self.addArrangedSubview(fullNameView)
        fullNameView.addSubview(fullNameLabel)
        fullNameView.addSubview(fullNameField)
        self.addArrangedSubview(emailView)
        emailView.addSubview(emailLabel)
        emailView.addSubview(emailField)
        self.addArrangedSubview(removeBtnView)
        removeBtnView.addSubview(removeBtn)
        
        addProperties()
        addContraints()
    }
    
//MARK: Add constraints
    
    private func addContraints(){
        
        fullNameView.setTop(offSet: 0)
        fullNameView.setLeft(offSet: 0)
        fullNameView.setRight(offSet: 0)
        fullNameView.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        
        fullNameLabel.setLeft(offSet: CARD_PADDING)
        fullNameLabel.setTop(offSet: CARD_PADDING)
        fullNameLabel.setWidth(constant: fullNameLabel.sizeThatFits(CGSize(width: applicationFrame.width, height: 50)).width)

        fullNameField.setLeft(offSet: CARD_PADDING)
        fullNameField.setRight(offSet: -CARD_PADDING)
        fullNameField.setTopRelatedToView(offSet: SPACE_BW_TWO_SECTIONS, relatedView: fullNameLabel, relatedAttribute: .bottom)
        fullNameField.setBottom(offSet: -SPACE_BW_TWO_SECTIONS)
        fullNameField.setHeight(constant: ACTION_BTN_HEIGT)
       
        emailView.setLeft(offSet: 0)
        emailView.setRight(offSet: 0)
        emailView.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        
        emailLabel.setLeft(offSet: CARD_PADDING)
        emailLabel.setTop(offSet: SPACE_BW_TWO_SECTIONS)
        emailLabel.setWidth(constant: emailLabel.sizeThatFits(CGSize(width: applicationFrame.width, height: 50)).width + CARD_PADDING)
        
        emailField.setLeft(offSet: CARD_PADDING)
        emailField.setRight(offSet: -CARD_PADDING)
        emailField.setTopRelatedToView(offSet: SPACE_BW_TWO_SECTIONS, relatedView: emailLabel, relatedAttribute: .bottom)
        emailField.setBottom(offSet: -CARD_PADDING)
        emailField.setHeight(constant: ACTION_BTN_HEIGT)
        
        removeBtnView.setLeft(offSet: 0)
        removeBtnView.setRight(offSet: 0)
        removeBtnView.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        
        removeBtn.setTop(offSet: 0)
        removeBtn.setRight(offSet: -CARD_PADDING)
        removeBtn.setBottom(offSet: -CARD_PADDING)
        removeBtn.setHeight(constant: 19)
        removeBtn.setWidth(constant: removeBtn.sizeThatFits(CGSize(width: 300, height: 50)).width)
        
    }
    
//MARK: Add Properties
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        self.alignment = .fill
        self.axis = .vertical
        self.spacing = 0
        
        fullNameView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        fullNameView.addCornerRadius(.SMALL)
        
        setLabelProperties(uiLabel: fullNameLabel, textString: getString(key: "com.charmphr.sharedocuments.addcontactView.fullnameLabel.title"))
        setTextFieldProperties(textField: fullNameField)
        fullNameField.becomeFirstResponder()
        
        emailView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        emailView.addCornerRadius(.SMALL)
        removeBtnView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        removeBtnView.addCornerRadius(.SMALL)
        
        setLabelProperties(uiLabel: emailLabel, textString: getString(key: "com.charmphr.sharedocuments.addcontactView.emailLabel.title"))
        setTextFieldProperties(textField: emailField)
        emailField.keyboardType = .emailAddress
        emailField.autocorrectionType = .yes
        emailField.textContentType = .emailAddress
        emailField.autocapitalizationType = .none
       
        removeBtn.setProperties(titleStrKey: getString(key: "com.charmphr.sharedocuments.addcontactView.removeButton.title"), fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLUE)
        removeBtnView.isHidden = true
    }
    
//MARK: Text Field Delegate functions
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        let newText = oldText.replacingCharacters(in: r, with: string)
       
        if textField == fullNameField{
            return newText.count <= 50
        }
        else{
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullNameField{
            emailField.becomeFirstResponder()
        }
        else if textField == emailField{
            emailField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
            emailField.resignFirstResponder()
        }
        return false
    }
    
//MARK: Other functions
        
    func setLabelProperties(uiLabel: UILabel, textString: String){
        uiLabel.text = textString
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        uiLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        uiLabel.textAlignment = .left
    }
    func setTextFieldProperties(textField: UITextField){
        textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        textField.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        textField.setPadding(width: TEXTFIELD_PADDING_5)
        textField.textAlignment = .left
        textField.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DOCUMENT_TEXTFIELD_BACKGROUND_COLOR)
        textField.delegate = self
        textField.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
        textField.layer.borderWidth = BORDER_WIDTH
        textField.addCornerRadius(.SMALL)
        textField.contentVerticalAlignment = .center
    }
    func setConstraints(){
        self.setLeft(offSet: X_SPACE)
        self.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
