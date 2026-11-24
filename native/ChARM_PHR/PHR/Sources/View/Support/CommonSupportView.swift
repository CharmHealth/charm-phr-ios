//
//  CommonView.swift
//  phr
//
//  Created by prathi-13964 on 19/09/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class CommonSupportView: UIStackView, UITextViewDelegate , UITextFieldDelegate{
    
    let severityMainView = UIView()
    let subjectMainView = UIView()
    let descriptionView = UIView()
    let appreciateView = UIView()
    let severityView = UIView()
    let chooseSeverityLabel = UILabel()
    let severityValueTextField = DateTextField()
//    let arrowIcon = UIImageView(image: UIImage(named: "ArrowRight"))
    let line1 = UIView()
    let subjectView = UIView()
    let subjectLabel = UILabel()
    let subjectField = UITextField()
    let line2 = UIView()
    let descriptionTextView = UITextView()
    let descriptionLabel = UILabel()
    let titleLabel = UILabel()
    let buttonView = UIView()
    var severityHeightConstraint: NSLayoutConstraint?
    var subjectHeightConstraint: NSLayoutConstraint?
    var line1HeightConstraint: NSLayoutConstraint?
    var line2HeightConstraint: NSLayoutConstraint?
//    var arrowHeightConstraint: NSLayoutConstraint?
    var appreciateHeightConstraint: NSLayoutConstraint?
    var textViewTextAndSelectedButtonCount: Int = 0
    var textViewTextCount: Int = 0
    weak var delegate: SupportViewController?
    private let CORNER_RADIUS: CGFloat = 16
    
    let buttonArray = [getString(key: "com.champhr.support.appreciate.button.productive.title"),
                       getString(key: "com.champhr.support.appreciate.button.good.title"),
                       getString(key: "com.champhr.support.appreciate.button.easyToUse.title"),
                       getString(key: "com.champhr.support.appreciate.button.wellIntegrated.title"),
                       getString(key: "com.champhr.support.appreciate.button.affordable.title"),
                       getString(key: "com.champhr.support.appreciate.button.robust.title"),
                       getString(key: "com.champhr.support.appreciate.button.easyToCustomize.title")]
    var selectedButtonList: [String] = []
    var charLength = 0
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews(){
        
        self.addArrangedSubview(severityMainView)
        self.addArrangedSubview(subjectMainView)
        self.addArrangedSubview(appreciateView)
        self.addArrangedSubview(descriptionView)
        
        severityMainView.addSubview(severityView)
        severityMainView.addSubview(line1)
        
        subjectMainView.addSubview(subjectView)
        subjectMainView.addSubview(line2)
        
        subjectView.addSubview(subjectLabel)
        subjectView.addSubview(subjectField)
        
        appreciateView.addSubview(titleLabel)
        appreciateView.addSubview(buttonView)
        
        descriptionView.addSubview(descriptionLabel)
        descriptionView.addSubview(descriptionTextView)
        
        severityView.addSubview(chooseSeverityLabel)
        severityView.addSubview(severityValueTextField)
//        severityView.addSubview(arrowIcon)
        
        addProperties()
        addConstraints()
    }
    private func addProperties(){
        self.distribution = .fill
        self.spacing = 0
        self.axis = .vertical
        
        severityMainView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        severityMainView.addCornerRadius(.SMALL)
        
        chooseSeverityLabel.text = getString(key: "com.charmphr.support.reportProblem.severity.title")
        chooseSeverityLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        chooseSeverityLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        chooseSeverityLabel.textAlignment = .left
        
        severityValueTextField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        severityValueTextField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        severityValueTextField.textAlignment = .right
        
        line1.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SUPPORT_BORDER_COLOR)
        
        subjectMainView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        subjectMainView.addCornerRadius(.SMALL)
        subjectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(subjectViewOnTap)))
        
        subjectLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        subjectLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        subjectLabel.textAlignment = .left
        
        subjectField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        subjectField.setPadding(width: TEXTFIELD_PADDING_5)
        subjectField.textAlignment = .right
        subjectField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        subjectField.delegate = self
        subjectField.placeholder = getString(key: "com.charmphr.support.textField.placeHolder.title")
        
        line2.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SUPPORT_BORDER_COLOR)
        
        titleLabel.text = getString(key: "com.charmphr.support.appreciate.titleLabel.title")
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_VALUE_LABEL, Weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        
        var hasSpace = false
        var prevButton: UIButton? = nil
        var buttonFrame = SUPPORT_FRAME_WIDTH
        
        for buttonArrayObj in buttonArray {
            
            let button = UIButton()
            buttonView.addSubview(button)
            
            button.setTitle(buttonArrayObj, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR), for: .selected)
            button.titleLabel?.textAlignment = .center
            button.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)

            button.layer.cornerRadius = CORNER_RADIUS
            button.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87).cgColor
            button.layer.borderWidth = BORDER_WIDTH
            
            button.addTarget(self, action: #selector(onButtonClick(btn:)), for: .touchUpInside)
            
            let buttonWidth = button.sizeThatFits(CGSize(width: 300, height: 50)).width + (CARD_PADDING * 2)
            
            if buttonWidth <= buttonFrame{
                hasSpace = true
            }
            else{
                hasSpace = false
                buttonFrame = SUPPORT_FRAME_WIDTH
            }
            if hasSpace{
                if let prevButton = prevButton {
                    button.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: prevButton, relatedAttribute: .right)
                    button.setTopRelatedToView(offSet: 0, relatedView: prevButton, relatedAttribute: .top)
                }
                else{
                    button.setTop(offSet: CARD_PADDING)
                }
            }
            else{
                button.setLeft(offSet: 0)
                if let prevButton = prevButton {
                    button.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevButton, relatedAttribute: .bottom)
                }
                else{
                    button.setTop(offSet: CARD_PADDING)
                }
            }
            buttonFrame = buttonFrame - buttonWidth
            prevButton = button
            
            if (buttonArray[buttonArray.count - 1] == button.currentTitle){
                button.setBottom(offSet: -CARD_PADDING)
            }
            button.setWidth(constant: buttonWidth)
            button.setHeight(constant: BUTTON_HEIGHT_32)
        }
 
        descriptionLabel.textAlignment = .left
        descriptionLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        descriptionLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
    
        descriptionTextView.layer.borderWidth = BORDER_WIDTH
        descriptionTextView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SUPPORT_TEXT_VIEW_BORDER_COLOR).cgColor
        descriptionTextView.addCornerRadius(.SMALL)
        descriptionTextView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_VIEW_BG_COLOR)
        descriptionTextView.layer.shadowColor = UIColorFromRGB(rgbValueWithAlpha: SUPPORT_BORDER_COLOR).cgColor
        descriptionTextView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        descriptionTextView.layer.shadowOpacity = 0
        descriptionTextView.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        descriptionTextView.text = textViewPlaceHolder
        descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        descriptionTextView.delegate = self
    }
    private func addConstraints(){
        
        severityMainView.setLeft(offSet: 0)
        severityMainView.setWidth(constant: SUPPORT_FRAME_WIDTH)
        severityHeightConstraint = severityMainView.setAndReturnHeight(constant: 0)
        
        severityView.setLeft(offSet: 0)
        severityView.setTop(offSet: 0)
        severityView.setWidth(constant: SUPPORT_FRAME_WIDTH)
        
        chooseSeverityLabel.setLeft(offSet: CELL_PADDING)
        chooseSeverityLabel.setTop(offSet: CARD_PADDING)
        chooseSeverityLabel.setBottom(offSet: -CARD_PADDING)
        chooseSeverityLabel.setWidth(constant: APPLICATION_FRAME_WIDTH_HALF - (CARD_PADDING * 7))
        
        severityValueTextField.setLeftRelatedToView(offSet: PADDING_5, relatedView: chooseSeverityLabel, relatedAttribute: .right)
        severityValueTextField.setTop(offSet: CARD_PADDING)
        severityValueTextField.setBottom(offSet: -CARD_PADDING)
        severityValueTextField.setRight(offSet: -CARD_PADDING)
//        severityValueTextField.setWidth(constant: APPLICATION_FRAME_WIDTH_HALF - CELL_PADDING)
        
//        arrowIcon.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: severityValueTextField, relatedAttribute: .right)
//        arrowIcon.setRight(offSet: -CARD_PADDING)
//        arrowIcon.setCenterY()
//        arrowHeightConstraint = arrowIcon.setAndReturnHeight(constant: 0)
//        arrowIcon.setWidth(constant: CARD_PADDING + 1)
        
        line1.setLeft(offSet: 0)
        line1.setTopRelatedToView(offSet: 0, relatedView: severityView, relatedAttribute: .bottom)
        line1.setBottom(offSet: 0)
        line1.setWidth(constant: SUPPORT_FRAME_WIDTH)
        line1HeightConstraint = line1.setAndReturnHeight(constant: 0)

        subjectMainView.setLeft(offSet: 0)
        subjectMainView.setWidth(constant: SUPPORT_FRAME_WIDTH)
        subjectHeightConstraint = subjectMainView.setAndReturnHeight(constant: 0)
        
        subjectView.setLeft(offSet: 0)
        subjectView.setTop(offSet: 0)
        subjectView.setWidth(constant: SUPPORT_FRAME_WIDTH)
        
        line2.setLeft(offSet: 0)
        line2.setTopRelatedToView(offSet: 0, relatedView: subjectView, relatedAttribute: .bottom)
        line2.setBottom(offSet: 0)
        line2.setWidth(constant: SUPPORT_FRAME_WIDTH)
        line2HeightConstraint = line2.setAndReturnHeight(constant: 0)
                
        subjectLabel.setLeft(offSet: CELL_PADDING)
        subjectLabel.setTop(offSet: CARD_PADDING)
        subjectLabel.setBottom(offSet: -CARD_PADDING)
        subjectLabel.setWidth(constant: APPLICATION_FRAME_WIDTH_HALF - (CARD_PADDING * 7))
        
        subjectField.setLeftRelatedToView(offSet: PADDING_5, relatedView: subjectLabel, relatedAttribute: .right)
        subjectField.setRight(offSet: -PADDING_5)
        subjectField.setTop(offSet: CARD_PADDING)
        subjectField.setBottom(offSet: -CARD_PADDING)
        
        appreciateView.setLeft(offSet: 0)
        appreciateView.setWidth(constant: SUPPORT_FRAME_WIDTH)
        appreciateHeightConstraint = appreciateView.setAndReturnHeight(constant: 0)
        debugPrintLog("Appreciate Height: \(appreciateView.sizeThatFits(CGSize(width: applicationFrame.width, height: 500)).height)")
        
        titleLabel.setLeft(offSet: 0)
        titleLabel.setTop(offSet: CARD_PADDING)

        buttonView.setLeft(offSet: 0)
        buttonView.setWidth(constant: SUPPORT_FRAME_WIDTH)
        buttonView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: titleLabel, relatedAttribute: .bottom)
        
        descriptionView.setLeft(offSet: 0)
        descriptionView.setWidth(constant: SUPPORT_FRAME_WIDTH)
       
        descriptionLabel.setLeft(offSet: CELL_PADDING)
        descriptionLabel.setRight(offSet: -(CARD_PADDING + 1))
        descriptionLabel.setTop(offSet: CARD_PADDING)
        
        descriptionTextView.setLeft(offSet: CELL_PADDING)
        descriptionTextView.setRight(offSet: -(CARD_PADDING + 1))
        descriptionTextView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: descriptionLabel, relatedAttribute: .bottom)
        descriptionTextView.setBottom(offSet: -CARD_PADDING)
        descriptionTextView.setHeight(constant: supportTextViewHeight)
    }
    
    
//MARK: - Other Functions
    
    func isAppreciateView(isAppreciateView: Bool){
        
        if isAppreciateView{
            self.removeShadowAndCornerRadius()
            descriptionView.addShadowAndCornerRadius(.SMALL)
            descriptionView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMinYCorner]
        }
        else{
            self.addShadowAndCornerRadius(.SMALL)
            descriptionView.removeShadowAndCornerRadius()
            descriptionView.addCornerRadius(.SMALL)
            descriptionView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
        }
    }
    
    func setProperties(subjectString: String, descriptionString: String, severityValueText: String? = nil){
        
        severityValueTextField.text = severityValueText
        subjectLabel.text = "\(subjectString)"
        descriptionLabel.text = "\(descriptionString)"
    }
    
    func setConstraints(isSeverity: Bool, isSubject: Bool, isAppreciate: Bool){
        if isSeverity{
            severityHeightConstraint?.constant = ACTION_BTN_HEIGT
            line1HeightConstraint?.constant = supportBorderWidth
//            arrowHeightConstraint?.constant = X_SPACE
            severityValueTextField.isHidden = false
            severityMainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            subjectMainView.layer.maskedCorners = []
        }
        else{
            severityHeightConstraint?.constant = 0
            line1HeightConstraint?.constant = 0
//            arrowHeightConstraint?.constant = 0
            severityValueTextField.isHidden = true
            severityMainView.layer.maskedCorners = []
        }
        
        if isSubject{
            subjectHeightConstraint?.constant = ACTION_BTN_HEIGT
            line2HeightConstraint?.constant = supportBorderWidth
            subjectField.isHidden = false
            if !isSeverity{
                subjectMainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }
        else{
            subjectHeightConstraint?.constant = 0
            line2HeightConstraint?.constant = 0
            subjectField.isHidden = true
            subjectMainView.layer.maskedCorners = []
            
        }
        if isAppreciate{
            
            appreciateHeightConstraint?.constant = supportAppreciateViewHeight
            descriptionTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textviewDidChange(_:))))
            buttonView.isHidden = false
            titleLabel.isHidden = false
        }
        else{
            appreciateHeightConstraint?.constant = 0
            buttonView.isHidden = true
            titleLabel.isHidden = true
        }
        self.setLeft(offSet: 0)
        self.setRight(offSet: 0)
        self.setTop(offSet: 0)
        self.setBottom(offSet: 0)
        self.setWidth(constant: SUPPORT_FRAME_WIDTH)
    }
    
    func checkPreviuouslySelectedButtons(buttonList: [UIButton]){
        
        for buttonObj in buttonView.subviews{
            if let button = buttonObj as? UIButton{
                if buttonList.contains(button){
                    button.isSelected = true
                    button.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR).cgColor
                }
                else{
                    button.isSelected = false
                    button.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87).cgColor
                }
            }
        }
    }
    
//MARK: - Delegate Functions
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT) {
            textView.text = ""
            textView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isNilOrBlank(){
            descriptionTextView.text = textViewPlaceHolder
            descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        }
        else{
            textViewTextCount = textView.text.count
            debugPrintLog("Text View Text Count: \(textViewTextCount)")
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var maxLength = 0
        let textInput = descriptionLabel.text
        if (textInput?.contains("Describe") == true){
            maxLength = 950
        }
        else if (textInput?.contains("Appreciate") == true){
            maxLength = 950 - charLength
        }
        
        let char = text.cString(using: String.Encoding.utf8)
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        }else{
            if textViewTextAndSelectedButtonCount > 950{
                return false
            }
            else{
                if newText.count <= maxLength{
                    textViewTextAndSelectedButtonCount = newText.count
                }
                else{
                    textViewTextAndSelectedButtonCount = textView.text.count
                }
                return newText.count <= maxLength
            }
        }
    }
    
//MARK: - Target Functions
    
    @objc func subjectViewOnTap(){
        subjectField.becomeFirstResponder()
    }
    
    @objc private func textviewDidChange(_ sender: UITapGestureRecognizer){
        charLength = 0
     //   charLength = getSelectedBtnStringCount()

        selectedButtonList = []
        for buttonObj in buttonView.subviews{
            if let button = buttonObj as? UIButton{
                if button.isSelected{
                    let buttonTitle = button.title(for: .selected) ?? ""
                    selectedButtonList.append(buttonTitle)
                }
            }
        }
        var answerString: String?
        if selectedButtonList.count == 1{
            answerString = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(selectedButtonList.joined())."
        }
        else if selectedButtonList.count == 2{
            answerString = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(selectedButtonList.joined(separator: " and "))."
        }
        else if selectedButtonList.count >= 3{
            let exceptLast = selectedButtonList[0 ..< (selectedButtonList.count - 1)]
            let last = selectedButtonList[selectedButtonList.count - 1]
            
            let newArray: [String] = ["\(exceptLast.joined(separator: ", "))",last]
            answerString = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(newArray.joined(separator: " and "))."
        }
        charLength = answerString?.count ?? 0
        
        if let textView = sender.view as? UITextView{
            if textView.textColor == UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT) {
                textView.text = ""
                textView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
            }
            textView.becomeFirstResponder()
            debugPrintLog("CHARLENGTH:  \(charLength)")
        }
    }

    @objc func onButtonClick(btn: UIButton){
        self.endEditing(true)
        
        let remainingCount = textViewTextAndSelectedButtonCount - textViewTextCount
        textViewTextAndSelectedButtonCount -= remainingCount
        btn.isSelected = !btn.isSelected
        if btn.isSelected{
            selectedButtonList.append(btn.currentTitle ?? "")
            textViewTextAndSelectedButtonCount += getSelectedBtnStringCount()
            if textViewTextAndSelectedButtonCount > 950{
                btn.isSelected = !btn.isSelected
                if let delegate = delegate{
                    CharmUtil.showToast(controller: delegate, message: "your message content should be less than 1000", seconds: 2.0)
                }
            }
            else{
                btn.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR).cgColor
            }
        }
        if !btn.isSelected{
            selectedButtonList.removeAll { str in
                return str == btn.currentTitle
            }
            btn.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87).cgColor
        }
        debugPrintLog("CharLength: \(textViewTextAndSelectedButtonCount)")
    }
    
    func getSelectedBtnStringCount() -> Int{
        var answerString: String?
        if selectedButtonList.count == 1{
            answerString = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(selectedButtonList.joined())."
        }
        else if selectedButtonList.count == 2{
            answerString = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(selectedButtonList.joined(separator: " and "))."
        }
        else if selectedButtonList.count >= 3{
            let exceptLast = selectedButtonList[0 ..< (selectedButtonList.count - 1)]
            let last = selectedButtonList[selectedButtonList.count - 1]
            
            let newArray: [String] = ["\(exceptLast.joined(separator: ", "))",last]
            answerString = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(newArray.joined(separator: " and "))."
        }
        return answerString?.count ?? 0
    }
}
