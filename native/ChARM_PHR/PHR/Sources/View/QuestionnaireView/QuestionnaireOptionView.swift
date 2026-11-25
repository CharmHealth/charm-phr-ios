//
//  QuestionnaireOptionView.swift
//  phr
//
//  Created by Sankar Saravanan on 31/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let ONE_LINE_BUTTON_HEIGHT:CGFloat = 24
fileprivate let commonButtonWidth: CGFloat = 24
fileprivate var OPTION_VIEW_STARTING_TAG = 50000000
fileprivate let othersFieldLeftPadding: CGFloat = 30
fileprivate let textFieldHeight: CGFloat = 39
fileprivate let lineColor: UInt = 0x707070FF
fileprivate let horizontalLineWidth: CGFloat = 15
fileprivate let verticalLineWidth: CGFloat = 0.5
fileprivate let verticalLineLeftPadding: CGFloat = 9
fileprivate let horizontalLineHeight: CGFloat = 0.5
fileprivate let VERTICAL_SPACING: CGFloat = 16
fileprivate let YES_String = "Yes"
fileprivate let NO_String = "No"
fileprivate let commentValue = "COMMENT_VALUE_"
fileprivate let optionSeparator = "^^"
fileprivate let heirarchySeparator = ">>"
fileprivate let commentTFPlaceHolder = "Add your comments here…"
fileprivate let addTagNo = 1000
fileprivate let SOAP_MAIN_VIEW_PADDING: CGFloat = 20

class QuestionnaireOptionView: UIView, MDTextFieldDelegate, UITextFieldDelegate {
    
    private var question : QuestionnaireEntryPOJO!
    private var isFixedOption = false
    private var viewWidth: CGFloat = 0
    private var textFieldHeightConstraint: NSLayoutConstraint?
    private let yesNoBtnWidth: CGFloat = 80
    
    init(question : QuestionnaireEntryPOJO,isFixedOption : Bool, width: CGFloat) {
        super.init(frame: .zero)
        self.question = question
        self.isFixedOption = isFixedOption
        self.viewWidth = width
        createSubView()
        
        self.backgroundColor = .white
    }
    
    func createSubView()
    {
        var previousView : UIView?
        var questionOptions = question.questionnaireOptions
        
        if !isFixedOption
        {
            let optionOthers = IntakeQuestTemplateOption()
            optionOthers.option = OTHERS
            optionOthers.entryId = question.questionnaireEntry.entryId
            questionOptions.append(optionOthers)
        }
        
        var optionsStr: [String] = []
        
        questionOptions.forEach{ option in
            optionsStr.append(option.option ?? "")
        }
        var answerList = question.questionnaireEntry.answersList
        
        guard !questionOptions.isEmpty else { return }
        for (i,option) in questionOptions.enumerated(){
            
            let optionBtn = OptionView()
            optionBtn.tag = OPTION_VIEW_STARTING_TAG +  i
            
            self.addSubview(optionBtn)

            optionBtn.initSubView(label: option.option ?? "", isRadio: !question.questionnaireEntry.isMultiChoice, width: viewWidth)
            
            optionBtn.isUserInteractionEnabled = true
            optionBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionBtbClicked(recognizer: ))))
            
            if question.questionnaireEntry.notesType == questionnaireNotesTypeYesOrNoOption {
                optionBtn.setTop(offSet: PADDING_4)
                optionBtn.setBottom(offSet: -PADDING_4)
                
                optionBtn.setWidth(constant: yesNoBtnWidth)
                
                if i == 0 {
                    optionBtn.setLeft(offSet: 0)
                }
                else if let previousView{
                    optionBtn.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: previousView, relatedAttribute: .right)
                }
            }
            else{
                
                if i == 0
                {
                    optionBtn.setTop(offSet: PADDING_8)
                }
                else if let previousView{
                    optionBtn.setTopRelatedToView(offSet: 0, relatedView: previousView, relatedAttribute: .bottom)
                }
                
                optionBtn.setLeft(offSet: 0)
                optionBtn.setRight(offSet: 0)
                if i == question.questionnaireOptions.count - 1 && isFixedOption
                {
                    optionBtn.setBottom(offSet: -PADDING_8)
                }
            }
            
            if !question.questionnaireEntry.isMultiChoice
            {
                let answer = answerList?.firstOrNil()
                
                if !answer.isNilOrBlank() {
                    if answer == option.option
                    {
                        optionBtn.setOptionSelected(isSelected: true)
                        if let index = answerList?.firstIndex(of: answer ?? ""){
                            answerList?.remove(at: index)
                        }
                    }
                }
                
            }else
            {
                if answerList?.firstIndex(of: option.option ?? "") != nil
                {
                    optionBtn.setOptionSelected(isSelected: true)
                    if let index = answerList?.firstIndex(of: option.option ?? ""){
                        answerList?.remove(at: index)
                    }
                }
            }
            previousView = optionBtn
            
            if i == questionOptions.count - 1 && !isFixedOption
            {
                let textField = MDTextField()
                textField.addCornerRadius(.SMALL)
                textField.layer.borderWidth = BORDER_WIDTH
                textField.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                textField.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BORDER_COLOR).cgColor
                textField.returnKeyType = .done
                textField.maxLength = OTHERS_TF_MAXLENGTH
                textField.tag = optionBtn.tag + 1
                textField.delegate = self
                self.addSubview(textField)
                
                textField.layer.masksToBounds = true
                textField.setPadding(width: TEXTFIELD_PADDING_5)
                
                textField.setTopRelatedToView(offSet: 0, relatedView: optionBtn, relatedAttribute: .bottom)
                textField.setLeft(offSet: othersFieldLeftPadding + CARD_PADDING)
                textField.setRight(offSet: -CARD_PADDING)
                textField.setBottom(offSet: -CARD_PADDING)
                
                textFieldHeightConstraint = textField.setAndReturnHeight(constant: 0)
                
                if question.questionnaireEntry.isMultiChoice
                {
                    if let answerList = question.questionnaireEntry.answersList {
                        
                        answerList.forEach{ ans in
                            if optionsStr.firstIndex(of: ans) == nil
                            {
                                optionBtn.setOptionSelected(isSelected: true)
                                textFieldHeightConstraint?.constant = textFieldHeight
                                textField.text = ans
                            }
                        }
                    }
                }
                else
                {
                    let answer = question.questionnaireEntry.answersList?.firstOrNil()
                    if !answer.isNilOrBlank(){
                        if optionsStr.firstIndex(of: answer!) == nil
                        {
                            optionBtn.setOptionSelected(isSelected: true)
                            textFieldHeightConstraint?.constant = textFieldHeight
                            textField.text = answer
                        }
                    }
                }
            }
        }
    }
    
    @objc func optionBtbClicked(recognizer: UITapGestureRecognizer){
        
        self.endEditing(true)
        
        if let view = recognizer.view {
            
            if let optionView = view as? OptionView{
                let isSelected = optionView.isOptionSelected
                if !isSelected{
                    
                    if optionView.buttonTitle == OTHERS{
                        
                        if let textField = self.viewWithTag(optionView.tag + 1) as? UITextField
                        {
                            UIView.animate(withDuration: 0.4){
                                self.textFieldHeightConstraint?.constant = textFieldHeight
                                self.layoutIfNeeded()
                            }
                            
                            textField.becomeFirstResponder()
                        }
                    }
                    
                    if !question.questionnaireEntry.isMultiChoice
                    {
                        for view in self.subviews
                        {
                            if let otherBtn = view as? OptionView
                            {
                                if optionView.tag != otherBtn.tag {
                                    if otherBtn.buttonTitle == OTHERS
                                    {
                                        if (self.viewWithTag(otherBtn.tag + 1) as? UITextField) != nil
                                        {
                                            UIView.animate(withDuration: 0.4){
                                                self.textFieldHeightConstraint?.constant = 0
                                                self.layoutIfNeeded()
                                            }
                                            
                                        }
                                    }
                                    otherBtn.setOptionSelected(isSelected: false)
                                }
                            }
                        }
                    }
                    optionView.setOptionSelected(isSelected: true)
                }
                else{
                    if question.questionnaireEntry.isMultiChoice{
                        if optionView.buttonTitle == OTHERS{
                            if (self.viewWithTag(optionView.tag + 1) as? UITextField) != nil
                            {
                                UIView.animate(withDuration: 0.4){
                                    self.textFieldHeightConstraint?.constant = 0
                                    self.layoutIfNeeded()
                                }
                            }
                        }
                        optionView.setOptionSelected(isSelected: false)
                    }
                }
            }
        }
    }
    
    func getSelectedOptionsAnswer() -> Array<String>
    {
        var arrayOfSelectedOptionsAnswer : Array<String> = []
        
        for view in self.subviews
        {
            if let btn = view as? OptionView
            {
                if btn.isOptionSelected
                {
                    if btn.buttonTitle == OTHERS
                    {
                        if let textField = self.viewWithTag(btn.tag + 1) as? UITextField
                        {
                            if !textField.text.isNilOrBlank(){
                                arrayOfSelectedOptionsAnswer.append(textField.text ?? "")
                            }
                        }
                    }else
                    {
                        arrayOfSelectedOptionsAnswer.append(btn.buttonTitle)
                    }
                }
            }
        }
        return arrayOfSelectedOptionsAnswer
    }
    
    func mdTextFieldShouldReturn(_ textField: MDTextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - QuestionnaireSoapOptionView

class QuestionnaireSoapOptionView: UIView, UIScrollViewDelegate, UITextFieldDelegate {
    
    private var soapWidget : SOAPWidgetEntry!
    private weak var delegate: QuestionnaireAnswerViewController? = nil
    
    private var viewWidth: CGFloat = 0
    private var yesTextFieldHeightConstraint: NSLayoutConstraint?
    private var noTextFieldHeightConstraint: NSLayoutConstraint?
    private var otherViewHeightConstraint: NSLayoutConstraint?
    private var scrollViewHeightConstraint: NSLayoutConstraint?
    private var checkListButtonToChildMap = Dictionary<Int , Int>()
    private var checkListBtnToSaopWidgetNameMap:[Int: [String]] = [:]
    private var soapNestedListModalDict: [Int: SoapNestedCheckListModal] = [:]
    private var allSoapNestedListModalDict: [Int: SoapNestedCheckListModal] = [:]
    private let mainView = UIView()
    private var commentView: UIView? = nil
    
    init(soapWidget : SOAPWidgetEntry, delegate: QuestionnaireAnswerViewController?, width: CGFloat, isDataEditAllowed: Bool)
    {
        super.init(frame: .zero)
        self.soapWidget = soapWidget
        self.delegate = delegate
        self.viewWidth = width
        createSubView()
        
        if soapWidget.entryType == soapWidgetTypeYesOrNo{
            self.isUserInteractionEnabled = isDataEditAllowed
        }
        else{
            mainView.isUserInteractionEnabled = isDataEditAllowed
            commentView?.isUserInteractionEnabled = isDataEditAllowed
        }
    }
    
    func createSubView(){
        if soapWidget.entryType == soapWidgetTypeYesOrNo{
            
            var previousView : UIView?
            
            let questionOptions: [String] = [YES_String,NO_String]
            for (i,option) in questionOptions.enumerated(){
                
                var hasCommentText: Bool = false
                let optionBtn = UIButton(type: .custom)
                optionBtn.setTitle(option, for: .normal)
                optionBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                optionBtn.setTitleColor(.black, for: .normal)
                optionBtn.addTarget(self, action: #selector(YesOrNoBtbClicked(btn:)), for: .touchUpInside)
                optionBtn.setImage(#imageLiteral(resourceName: "RadioBtnUnselected"), for: .normal)
                optionBtn.setImage(#imageLiteral(resourceName: "RadioBtnSelected"), for: .selected)
                optionBtn.tag = OPTION_VIEW_STARTING_TAG
                OPTION_VIEW_STARTING_TAG += 1
                self.addSubview(optionBtn)
                optionBtn.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                
                if i == 0{
                    optionBtn.setTop(offSet: CARD_PADDING)
                }else
                {
                    if let previousView = previousView{
                        optionBtn.setTopRelatedToView(offSet: VERTICAL_SPACING, relatedView: previousView, relatedAttribute: .bottom)
                    }
                }
                
                optionBtn.setLeft(offSet: CARD_PADDING)
                optionBtn.setRight(offSet: -CARD_PADDING)
                
                if i == questionOptions.count - 1
                {
                    optionBtn.setBottom(offSet: -CARD_PADDING)
                }
                
                optionBtn.contentHorizontalAlignment = .left
                optionBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -CARD_PADDING, bottom: 0, right: CARD_PADDING)
                optionBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                optionBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: CARD_PADDING, bottom: 0, right: CARD_PADDING)
                
                if let answer = soapWidget.questionnaireSOAPEntry?.value{
                    if answer.contains("_"){
                        if option.lowercased() == answer.components(separatedBy: optionSeparator).first?.lowercased(){
                            optionBtn.isSelected = true
                            hasCommentText = true
                        }
                    }
                    else{
                        if option.lowercased() == answer.lowercased(){
                            optionBtn.isSelected = true
                        }
                    }
                }
                else if soapWidget.defaultValue.isNilOrBlank() == false{
                    if option.lowercased() == (soapWidget.defaultValue ?? "").lowercased(){
                        optionBtn.isSelected = true
                    }
                }
                
                previousView = optionBtn
                soapWidget.propertyList?.forEach({ soapWidgetProperty in
                    if soapWidgetProperty.propertyName == soapYesNoAddtionalCommentYes && soapWidgetProperty.propertyValue == "true" && i == 0{
                        let textField = getTextField(isYes: true, isSelected: optionBtn.isSelected)
                        if hasCommentText{
                            if let answer = soapWidget.questionnaireSOAPEntry?.value, let textString = answer.components(separatedBy: "_").last{
                                textField.text = textString
                            }
                        }
                        textField.tag = optionBtn.tag + addTagNo
                        textField.setLeftRelatedToView(offSet: othersFieldLeftPadding, relatedView: optionBtn, relatedAttribute: .left)
                        if optionBtn.isSelected{
                            textField.setTopRelatedToView(offSet: PADDING_8, relatedView: optionBtn, relatedAttribute: .bottom)
                        }
                        else{
                            textField.setTopRelatedToView(offSet: 0, relatedView: optionBtn, relatedAttribute: .bottom)
                        }
                        previousView = textField
                    }
                    if soapWidgetProperty.propertyName == soapYesNoAddtionalCommentNo && soapWidgetProperty.propertyValue == "true" && i == 1{
                        let textField = getTextField(isYes: false, isSelected: optionBtn.isSelected)
                        
                        if hasCommentText{
                            if let answer = soapWidget.questionnaireSOAPEntry?.value, let textString = answer.components(separatedBy: "_").last{
                                textField.text = textString
                            }
                        }
                        textField.tag = optionBtn.tag + addTagNo
                        textField.setLeftRelatedToView(offSet: othersFieldLeftPadding, relatedView: optionBtn, relatedAttribute: .left)
                        if optionBtn.isSelected{
                            textField.setTopRelatedToView(offSet: PADDING_8, relatedView: optionBtn, relatedAttribute: .bottom)
                        }
                        else{
                            textField.setTopRelatedToView(offSet: 0, relatedView: optionBtn, relatedAttribute: .bottom)
                        }
                        previousView = textField
                        
                        optionBtn.removeConstraint(attribute: .bottom)
                        textField.setBottom(offSet: -CARD_PADDING)
                    }
                })
            }
        }
        else{
            let scrollView = UIScrollView()
            self.addSubview(scrollView)
            
            scrollView.delegate = self
            
            scrollView.setLeft(offSet: 0)
            scrollView.setRight(offSet: 0)
            scrollView.setTop(offSet: 0)
            
            scrollView.addSubview(mainView)

            mainView.setLeft(offSet: 0)
            mainView.setRight(offSet: 0)
            mainView.setTop(offSet: 0)
            mainView.setBottom(offSet: 0)
            // Options wrap to the card width and the list grows with its content, so it adapts to
            // rotation and iPhone Duo fold/unfold instead of using sizes measured once at build time.
            NSLayoutConstraint.activate([
                mainView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
            ])

            let soapWidgetOptionListParentStackView = UIStackView()
            mainView.addSubview(soapWidgetOptionListParentStackView)
            
            soapWidgetOptionListParentStackView.translatesAutoresizingMaskIntoConstraints = false
            soapWidgetOptionListParentStackView.axis = .vertical
            soapWidgetOptionListParentStackView.spacing = VERTICAL_SPACING
            soapWidgetOptionListParentStackView.alignment = .leading
            
            soapWidgetOptionListParentStackView.setTop(offSet: CARD_PADDING)
            soapWidgetOptionListParentStackView.setLeft(offSet: CARD_PADDING)
            soapWidgetOptionListParentStackView.setRight(offSet: -CARD_PADDING)
            
            var answerList:[String] = (soapWidget.questionnaireSOAPEntry?.value ?? "").split(separator: "^").map({elm in
                return "\(elm)"
            })
            
            if answerList.isEmpty{
                answerList = (soapWidget.defaultValue ?? "").split(separator: "^").map({elm in
                    return "\(elm)"
                })
            }
            
            if soapWidget.entryType == soapWidgetTypeCheckList{
                
                scrollView.setBottom(offSet: 0)
                soapWidgetOptionListParentStackView.setBottom(offSet: -CARD_PADDING)
                scrollViewHeightConstraint = scrollView.setAndReturnHeight(constant: CARD_PADDING * 2)
                scrollViewHeightConstraint?.isActive = false

                let spltStr:[String] = (soapWidget.entryName ?? "").split(separator: "^").map({elm in
                    return "\(elm)"
                })
                addCheckListView(parentView: soapWidgetOptionListParentStackView, optionsArr: spltStr, isOthersAllowed: false, isRadio: false)
                setSelectedOptions(stackView: soapWidgetOptionListParentStackView, answerList: answerList, optionsArr: spltStr)
            }
            else if soapWidget.entryType == soapWidgetTypeRadio || soapWidget.entryType == soapWidgetTypeCheckbox{
                
                var isAdditionalNotesEnabled = false
                var isOthersAllowed = false
                
                soapWidget.propertyList?.forEach({ soapWidgetProperty in
                    if soapWidgetProperty.propertyName == soapRadioIncludeOthers{
                        isOthersAllowed = soapWidgetProperty.propertyValue == "true"
                    }
                    if soapWidgetProperty.propertyName == soapRadioAddtionalComment{
                        isAdditionalNotesEnabled = soapWidgetProperty.propertyValue == "true"
                    }
                })
                
                if isAdditionalNotesEnabled {
                    var comment = ""
                    if let lastItem = answerList.last {
                        if lastItem.starts(with: commentValue){
                            comment = lastItem.components(separatedBy: commentValue).filter({elm in
                                return elm.isNotBlank()
                            }).joined(separator: "")
                            answerList.removeLast()
                        }
                    }
                    commentView =  getCommentView(comment: comment)
                }
                
                if let commentView = commentView {
                    
                    self.addSubview(commentView)
                    commentView.setLeft(offSet: 0)
                    commentView.setRight(offSet: 0)
                    commentView.setTopRelatedToView(offSet: PADDING_8, relatedView: scrollView, relatedAttribute: .bottom)
                    commentView.setBottom(offSet: 0)
                    
                    soapWidgetOptionListParentStackView.setBottom(offSet: -PADDING_8)
                    scrollViewHeightConstraint = scrollView.setAndReturnHeight(constant: (CARD_PADDING + PADDING_8))
                }
                else{
                    soapWidgetOptionListParentStackView.setBottom(offSet: -CARD_PADDING)
                    scrollViewHeightConstraint = scrollView.setAndReturnHeight(constant: CARD_PADDING * 2)
                    scrollView.setBottom(offSet: 0)
                }
                scrollViewHeightConstraint?.isActive = false
                
                var spltStr:[String] = (soapWidget.customText ?? "").split(separator: "^").map({elm in
                    return "\(elm)"
                })
                
                if isOthersAllowed{
                    spltStr.append(OTHERS)
                }
                
                addCheckListView(parentView: soapWidgetOptionListParentStackView, optionsArr: spltStr, isOthersAllowed: isOthersAllowed, isRadio: soapWidget.entryType == soapWidgetTypeRadio)
                
                setSelectedOptions(stackView: soapWidgetOptionListParentStackView, answerList: answerList, optionsArr: spltStr)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0.0
    }
    
//MARK: Create checkList
    
    private func addCheckListView(parentView: UIStackView, optionsArr: [String], isOthersAllowed: Bool, isRadio: Bool){
        
        for (i, optionString) in optionsArr.enumerated() {
            
            if !isHierarchialOptionPresent(option: optionString){
                let containerView = UIView()
                parentView.addArrangedSubview(containerView)
                
                let optionButton = SOAPOptionView()
                optionButton.index = i
                containerView.addSubview(optionButton)
                
                optionButton.initSubView(label: optionString, isRadio: isRadio, isHierarchy: (i + 1 < optionsArr.count) && (isHierarchialOptionPresent(option: optionsArr[i + 1])), width: viewWidth)
                
                if i == 0{
                    scrollViewHeightConstraint?.constant += optionButton.labelHeight
                }
                else{
                    scrollViewHeightConstraint?.constant += (optionButton.labelHeight + VERTICAL_SPACING)
                }
                
                optionButton.tag = OPTION_VIEW_STARTING_TAG
                OPTION_VIEW_STARTING_TAG += 1
                
                containerView.tag = OPTION_VIEW_STARTING_TAG
                OPTION_VIEW_STARTING_TAG += 1
                
                let soapNestedListModal = SoapNestedCheckListModal()
                soapNestedListModal.key = containerView.tag
                soapNestedListModal.heirarchyLevel = 0
                
                checkListBtnToSaopWidgetNameMap[optionButton.tag] = optionsArr
                
                if isRadio{
                    optionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickRadioBtn)))
                }
                else{
                    optionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickCheckListBtn)))
                }
                
                containerView.setLeft(offSet: 0)
                containerView.setRight(offSet: 0)
                
                optionButton.setLeft(offSet: 0)
                optionButton.setTop(offSet: 0)
                optionButton.setRight(offSet: 0)
                
                if isOthersAllowed && optionString == OTHERS{
                    let otherTF = UITextField()
                    containerView.addSubview(otherTF)
                    
                    otherTF.autocorrectionType = .no
                    otherTF.text = ""
                    otherTF.returnKeyType = .done
                    otherTF.addCornerRadius(.SMALL)
                    otherTF.layer.borderWidth = BORDER_WIDTH
                    otherTF.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                    otherTF.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BORDER_COLOR).cgColor
                    otherTF.delegate = self
                    
                    otherTF.setPadding(width: TEXTFIELD_PADDING_8)
                    otherTF.setLeftRelatedToView(offSet: othersFieldLeftPadding, relatedView: optionButton, relatedAttribute: .left)
                    otherTF.setTopRelatedToView(offSet: 0, relatedView: optionButton, relatedAttribute: .bottom)
                    otherTF.setBottom(offSet: 0)
                    otherTF.setRight(offSet: 0)
                    
                    otherTF.tag = OPTION_VIEW_STARTING_TAG
                    OPTION_VIEW_STARTING_TAG += 1
                    
                    checkListButtonToChildMap[optionButton.tag] = otherTF.tag
                    otherViewHeightConstraint = otherTF.setAndReturnHeight(constant: 0)
                    
                    soapNestedListModal.actualWidth = viewWidth - (CARD_PADDING * 2)
                    soapNestedListModal.modifieldWidth = soapNestedListModal.actualWidth
                }
                else{
                    optionButton.setBottom(offSet: 0)
                    soapNestedListModal.actualWidth = optionButton.viewWidth
                    soapNestedListModal.modifieldWidth = soapNestedListModal.actualWidth
                }
                soapNestedListModalDict[containerView.tag] = soapNestedListModal
                allSoapNestedListModalDict[containerView.tag] = soapNestedListModal
            }
        }
        setMainViewWidth()
    }
    
    func addChildViews(soapNestedModalParent: SoapNestedCheckListModal,optionsArr: [String], parentView: UIStackView, answerList: [String]){
        var answerArr = answerList
        for (i,optionString) in optionsArr.enumerated(){
            
            if !isHierarchialOptionPresent(option: optionString){
                let containerView = UIView()
                parentView.addArrangedSubview(containerView)
                
                let horizontalView = UIView()
                containerView.addSubview(horizontalView)
                
                horizontalView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: lineColor)
                
                let optionButton = SOAPOptionView()
                optionButton.index = i
                containerView.addSubview(optionButton)
                
                optionButton.initSubView(label: optionString, isRadio: false, isHierarchy: (i + 1 < optionsArr.count) && (isHierarchialOptionPresent(option: optionsArr[i + 1])), width: viewWidth)
                
                optionButton.tag = OPTION_VIEW_STARTING_TAG
                OPTION_VIEW_STARTING_TAG += 1
                
                containerView.tag = OPTION_VIEW_STARTING_TAG
                OPTION_VIEW_STARTING_TAG += 1
                
                let soapNestedListModal = SoapNestedCheckListModal()
                soapNestedListModal.key = containerView.tag
                soapNestedListModal.heirarchyLevel = soapNestedModalParent.heirarchyLevel + 1
                soapNestedListModal.actualWidth = optionButton.viewWidth + ((horizontalLineWidth + verticalLineWidth + verticalLineLeftPadding) * soapNestedListModal.heirarchyLevel)
                soapNestedListModal.modifieldWidth = soapNestedListModal.actualWidth
                
                soapNestedModalParent.child[containerView.tag] = soapNestedListModal
                soapNestedListModal.parent[soapNestedModalParent.key] = soapNestedModalParent
                soapNestedModalParent.child[containerView.tag] = soapNestedListModal
                
                allSoapNestedListModalDict[containerView.tag] = soapNestedListModal
                
                checkListBtnToSaopWidgetNameMap[optionButton.tag] = optionsArr
                scrollViewHeightConstraint?.constant += (optionButton.labelHeight + VERTICAL_SPACING)
                
                optionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickCheckListBtn)))
                
                optionButton.clipsToBounds = true
                containerView.clipsToBounds = true
                
                containerView.setLeft(offSet: 0)
                containerView.setRight(offSet: 0)
                
                optionButton.setTop(offSet: 0)
                optionButton.setBottom(offSet: 0)
                optionButton.setRight(offSet: 0)
                
                horizontalView.setLeft(offSet: 0)
                horizontalView.setTop(offSet: CARD_PADDING)
                horizontalView.setWidth(constant: horizontalLineWidth)
                horizontalView.setHeight(constant: horizontalLineHeight)
                
                optionButton.setLeftRelatedToView(offSet: 0, relatedView: horizontalView, relatedAttribute: .right)
                
                if !answerArr.isEmpty{
                    if answerArr.contains(where: { answerString in
                        if !isHierarchialOptionPresent(option: answerString){
                            return answerString.trim() == optionString.trim()
                        }
                        return false
                    }){
                        optionButton.setOptionSelected(isSelected: true)
                        setChildViews(btn: optionButton, parentView: containerView, optionsArr: optionsArr, answerList: answerList)
                        if let index = answerArr.firstIndex(of: optionString){
                            answerArr.remove(at: index)
                        }
                    }
                }
            }
        }
        setSubViewModal(soapNestedModalParent: soapNestedModalParent)
        setMainViewWidth()
    }
    
    func isHierarchialOptionPresent(option: String) -> Bool
    {
        if option.trimLeadingSpaces().hasPrefix(heirarchySeparator){
            return true
        }
        else{
            return false
        }
    }
    
    func setSubViewModal(soapNestedModalParent: SoapNestedCheckListModal, isRemoveView: Bool = false){
        
        var valueArr: [SoapNestedCheckListModal] = soapNestedModalParent.child.map { (key: Int, value: SoapNestedCheckListModal) in
            return value
        }
        valueArr.sort { modal1, modal2 in
            return modal1.modifieldWidth > modal2.modifieldWidth
        }
        
        if let childMaxWidth = valueArr.first?.modifieldWidth{
            if isRemoveView{
                if childMaxWidth > soapNestedModalParent.actualWidth{
                    soapNestedModalParent.modifieldWidth = childMaxWidth
                }
            }
            else{
                if childMaxWidth > soapNestedModalParent.modifieldWidth{
                    soapNestedModalParent.modifieldWidth = childMaxWidth
                }
            }
        }
        if let superParentFirst = soapNestedModalParent.parent.first{
            setSubViewModal(soapNestedModalParent: superParentFirst.value, isRemoveView: isRemoveView)
        }
    }
    
    func setMainViewWidth(containerView: UIView? = nil){
        
        if let containerView = containerView, let soapNestedModal = allSoapNestedListModalDict[containerView.tag]{
            
            soapNestedModal.modifieldWidth = soapNestedModal.actualWidth
            soapNestedModal.child = [:]
            if let soapNestedModalParent = soapNestedModal.parent.first?.value{
                setSubViewModal(soapNestedModalParent: soapNestedModalParent, isRemoveView: true)
            }
        }
        // mainView width now follows the card (see createSubView), so no measured width is applied here.
    }
    
//MARK: get ChildAnswer List
    
    func getChildAnswerList(answerList: [String], btnTitle: String) -> [String]{
        let nextIndex = (answerList.firstIndex(of: btnTitle) ?? 0) + 1
        
        var childList: [String] = []
        if nextIndex < answerList.count{
            for i in nextIndex ... answerList.count - 1 {
                let optionVal = answerList[i]
                if optionVal.trimLeadingSpaces().starts(with: heirarchySeparator){
                    childList.append(optionVal.trimLeadingSpaces().subString(from: 2))
                }
                else{
                    break
                }
            }
        }
        return childList
    }
    
//MARK: setChildViews
    
    func setChildViews(btn: SOAPOptionView, parentView: UIView, optionsArr: [String], answerList: [String] = []){
        var hasChild: Bool = true
        let nextIndex = btn.index + 1
        
        if nextIndex < optionsArr.count{
            if !isHierarchialOptionPresent(option: optionsArr[nextIndex]){
                hasChild = false
            }
        }
        else if nextIndex == optionsArr.count{
            hasChild = false
        }
        if hasChild{
            let soapWidgetOptionListParentStackView = UIStackView()
            parentView.addSubview(soapWidgetOptionListParentStackView)
            
            soapWidgetOptionListParentStackView.translatesAutoresizingMaskIntoConstraints = false
            soapWidgetOptionListParentStackView.axis = .vertical
            soapWidgetOptionListParentStackView.spacing = VERTICAL_SPACING
            soapWidgetOptionListParentStackView.alignment = .leading
            
            btn.removeConstraint(attribute: .bottom)
            
            soapWidgetOptionListParentStackView.setTopRelatedToView(offSet: VERTICAL_SPACING, relatedView: btn, relatedAttribute: .bottom)
            soapWidgetOptionListParentStackView.setRight(offSet: 0)
            soapWidgetOptionListParentStackView.setBottom(offSet: 0)
            
            var childList: [String] = []
            if nextIndex < optionsArr.count{
                for i in nextIndex ... optionsArr.count - 1 {
                    let optionVal = optionsArr[i]
                    if optionVal.trimLeadingSpaces().starts(with: heirarchySeparator){
                        childList.append(optionVal.trimLeadingSpaces().subString(from: 2))
                    }
                    else{
                        break
                    }
                }
            }
            
            if let soapNestedModalParent = allSoapNestedListModalDict[parentView.tag]{
                addChildViews(soapNestedModalParent: soapNestedModalParent, optionsArr: childList, parentView: soapWidgetOptionListParentStackView, answerList: getChildAnswerList(answerList: answerList, btnTitle: btn.buttonTitle))
            }
            
            if let lastbtn = soapWidgetOptionListParentStackView.subviews.last?.subviews.first(where: { subView in
                return subView is SOAPOptionView
            }){
                btn.addVerticalLine()
                let verticalLine = UIView()
                parentView.addSubview(verticalLine)

                verticalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: lineColor)
                verticalLine.setLeftRelatedToView(offSet: verticalLineLeftPadding, relatedView: btn, relatedAttribute: .left)
                verticalLine.setTopRelatedToView(offSet: 0, relatedView: btn, relatedAttribute: .bottom)
                verticalLine.setBottomRelatedToView(offSet: CARD_PADDING, relatedView: lastbtn, relatedAttribute: .top)
                verticalLine.setWidth(constant: verticalLineWidth)

                soapWidgetOptionListParentStackView.setLeftRelatedToView(offSet: 0, relatedView: verticalLine, relatedAttribute: .right)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: set Selected Options
    
    func setSelectedOptions(stackView: UIStackView, answerList: [String], optionsArr: [String]){
        
        var btnList: [SOAPOptionView] = []
        for btnSuperView in stackView.subviews{
            if let btn = btnSuperView.subviews.first(where: { subViews in
                return subViews is SOAPOptionView
            }) as? SOAPOptionView{
                btnList.append(btn)
            }
        }
        
        for answer in answerList{
            if !isHierarchialOptionPresent(option: answer){
                if let btn = btnList.first(where: { soapOptionView in
                    return soapOptionView.buttonTitle == answer
                }){
                    btn.setOptionSelected(isSelected: true)
                    setChildViews(btn: btn, parentView: btn.superview ?? UIView(), optionsArr: optionsArr, answerList: answerList)
                    btnList.removeAll { soapOptionView in
                        soapOptionView == btn
                    }
                }
                else if let btn = btnList.first(where: { soapOptionView in
                    return soapOptionView.buttonTitle == OTHERS
                }){
                    btn.setOptionSelected(isSelected: true)
                    let textFieldTag = checkListButtonToChildMap[btn.tag] ?? -1
                    if let textfield = self.viewWithTag(textFieldTag) as? UITextField{
                        textfield.text = answer
                        otherViewHeightConstraint?.constant = textFieldHeight
                        scrollViewHeightConstraint?.constant += (textFieldHeight + PADDING_8)
                        textfield.removeConstraint(attribute: .top)
                        textfield.setTopRelatedToView(offSet: PADDING_8, relatedView: btn, relatedAttribute: .bottom)
                    }
                    btnList.removeAll { soapOptionView in
                        soapOptionView == btn
                    }
                }
            }
        }
    }
    
//MARK: get Selected Options Answer
    
    func getSelectedOptionsAnswer(soapEntryType: String) -> String?
    {
        var answer: String? = nil
        if soapEntryType == soapWidgetTypeYesOrNo{
            for view in self.subviews
            {
                if let btn = view as? UIButton, btn.isSelected{
                    answer = btn.currentTitle
                    if let textField = self.viewWithTag(btn.tag + addTagNo) as? UITextField{
                        if !textField.text.isNilOrBlank(){
                            if btn.currentTitle == YES_String{
                                answer?.append("\(optionSeparator)COMMENT_FOR_YES_\(textField.text ?? "")")
                            }
                            else if btn.currentTitle == NO_String{
                                answer?.append("\(optionSeparator)COMMENT_FOR_NO_\(textField.text ?? "")")
                            }
                        }
                    }
                }
            }
        }
        else{
            var additonalComment: String? = nil
            for view in self.subviews
            {
                if let scrollView = view as? UIScrollView{
                    if let stackView = scrollView.subviews.first?.subviews.first(where: { subViews in
                        return subViews is UIStackView
                    }) as? UIStackView{
                        answer = getSelectedButtonsString(stackView: stackView, answerStr: "", i: 0)
                    }
                }
                else if soapEntryType == soapWidgetTypeRadio || soapEntryType == soapWidgetTypeCheckbox
                {
                    if let commentTF = view.subviews.first(where: { subViews in
                        return subViews is UITextField
                    }) as? UITextField{
                        if !commentTF.text.isNilOrBlank(){
                            additonalComment = "\(commentValue)\(commentTF.text ?? "")"
                        }
                    }
                }
                if !additonalComment.isNilOrBlank() && !answer.isNilOrBlank(){
                    answer?.append(additonalComment ?? "")
                }
            }
        }        
        return answer
    }
    
//MARK: get Selected Button's String
    
    func getSelectedButtonsString(stackView: UIStackView, answerStr: String?, i: Int) -> String?{
        var answerString = answerStr
        
        for subViews in stackView.subviews{
            if let button = subViews.subviews.first(where: { views in
                return views is SOAPOptionView
            }) as? SOAPOptionView, button.isOptionSelected{
                if i == 0 && button.buttonTitle == OTHERS{
                    if let othersTextField = subViews.subviews.first(where: { views in
                        return views is UITextField
                    }) as? UITextField{
                        if othersTextField.text.isNilOrBlank() == false{
                            answerString?.append("\(getShiftArrow(times: i))\(othersTextField.text ?? "")\(optionSeparator)")
                        }
                    }
                    else{
                        answerString?.append("\(getShiftArrow(times: i))\(button.buttonTitle)\(optionSeparator)")
                    }
                }
                else{
                    answerString?.append("\(getShiftArrow(times: i))\(button.buttonTitle)\(optionSeparator)")
                }
                if let childStackViews = subViews.subviews.first(where: { views in
                    return views is UIStackView
                }) as? UIStackView{
                    answerString = getSelectedButtonsString(stackView: childStackViews, answerStr: answerString, i: i + 1)
                }
            }
        }
        return answerString
    }
    
    func getShiftArrow(times: Int) -> String{
        var arrowString: String = ""
        if times > 0{
            for _ in 1...times{
                arrowString.append(heirarchySeparator)
            }
        }
        return arrowString
    }
    
//MARK:  get TextField
    
    func getTextField(isYes: Bool, isSelected: Bool) -> UITextField{
        let textField = UITextField()
        textField.addCornerRadius(.SMALL)
        textField.layer.borderWidth = BORDER_WIDTH
        textField.returnKeyType = .done
        textField.placeholder = commentTFPlaceHolder
        textField.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        textField.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BORDER_COLOR).cgColor
        textField.delegate = self
        self.addSubview(textField)
        
        textField.setPadding(width: TEXTFIELD_PADDING_8)
        textField.setRight(offSet: -CARD_PADDING)
        
        if isYes{
            if isSelected{
                yesTextFieldHeightConstraint = textField.setAndReturnHeight(constant: textFieldHeight)
            }
            else{
                yesTextFieldHeightConstraint = textField.setAndReturnHeight(constant: 0)
            }
        }
        else{
            if isSelected{
                noTextFieldHeightConstraint = textField.setAndReturnHeight(constant: textFieldHeight)
            }
            else{
                noTextFieldHeightConstraint = textField.setAndReturnHeight(constant: 0)
            }
        }
        return textField
    }
    
//MARK: get CommentView
    
    private func getCommentView(comment: String , disableComment: Bool = false) -> UIView{
        let commentView = UIView()
        
        let horizontalLine = UIView()
        commentView.addSubview(horizontalLine)
        
        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: lineColor)
        
        horizontalLine.setLeft(offSet: PADDING_4)
        horizontalLine.setRight(offSet: -PADDING_4)
        horizontalLine.setTop(offSet: 0)
        horizontalLine.setHeight(constant: 0.25)
        
        let commentTF = UITextField()
        commentTF.autocorrectionType = .no
        commentTF.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        commentTF.placeholder = commentTFPlaceHolder
        commentTF.text = comment
        commentTF.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: 0x70707099).cgColor
        commentTF.layer.borderWidth = 0.5
        commentTF.addCornerRadius(.SMALL)
        commentTF.setPadding(width: TEXTFIELD_PADDING_8, height: 30)
        commentTF.returnKeyType = .done
        commentTF.delegate = self
        
        if disableComment {
            commentTF.isUserInteractionEnabled = false
        }
        commentView.addSubview(commentTF)
        
        commentTF.setTopRelatedToView(offSet: PADDING_8, relatedView: horizontalLine, relatedAttribute: .bottom)
        commentTF.setLeft(offSet: CARD_PADDING)
        commentTF.setRight(offSet: -CARD_PADDING)
        commentTF.setHeight(constant: textFieldHeight)
        commentTF.setBottom(offSet: -CARD_PADDING)
        
        return commentView
    }
    
//MARK: Target functions
    
    @objc func onClickCheckListBtn(_ sender: UITapGestureRecognizer){
        self.endEditing(true)
        if let btn = sender.view as? SOAPOptionView{
            let textFieldTag = checkListButtonToChildMap[btn.tag] ?? -1
            if let textfield = self.viewWithTag(textFieldTag) as? UITextField{
                if !btn.isOptionSelected{
                    otherViewHeightConstraint?.constant = textFieldHeight
                    scrollViewHeightConstraint?.constant += (textFieldHeight + PADDING_8)
                    textfield.removeConstraint(attribute: .top)
                    textfield.setTopRelatedToView(offSet: PADDING_8, relatedView: btn, relatedAttribute: .bottom)
                    textfield.becomeFirstResponder()
                }
                else{
                    textfield.text = ""
                    otherViewHeightConstraint?.constant = 0
                    scrollViewHeightConstraint?.constant -= (textFieldHeight + PADDING_8)
                    textfield.removeConstraint(attribute: .top)
                    textfield.setTopRelatedToView(offSet: 0, relatedView: btn, relatedAttribute: .bottom)
                    textfield.resignFirstResponder()
                }
            }
            else if let optionsArr = checkListBtnToSaopWidgetNameMap[btn.tag]{
                if let parentView = btn.superview{
                    if btn.isOptionSelected{
                        if let childView = parentView.subviews.first(where: { subViews in
                            return subViews is UIStackView
                        }) as? UIStackView{
                            btn.removeVerticalLine()
                            let height = getSubViewsHeight(childView: childView, initCount: 0)
                            scrollViewHeightConstraint?.constant -= height
                            setMainViewWidth(containerView: parentView)
                        }
                        for subviews in parentView.subviews{
                            if !(subviews is SOAPOptionView || subviews.getHeight() == horizontalLineHeight){
                                subviews.removeFromSuperview()
                            }
                        }
                        btn.setBottom(offSet: 0)
                    }
                    else{
                        setChildViews(btn: btn, parentView: parentView, optionsArr: optionsArr)
                    }
                }
            }
            btn.setOptionSelected(isSelected: !btn.isOptionSelected)
        }
    }
    
    @objc func onClickRadioBtn(_ sender: UITapGestureRecognizer){
        self.endEditing(true)
        if let btn = sender.view as? SOAPOptionView{
            let textFieldTag = checkListButtonToChildMap[btn.tag] ?? -1
            if let textfield = self.viewWithTag(textFieldTag) as? UITextField{
                if !btn.isOptionSelected{
                    btn.setOptionSelected(isSelected: true)
                    
                    otherViewHeightConstraint?.constant = textFieldHeight
                    scrollViewHeightConstraint?.constant += (textFieldHeight + PADDING_8)
                    textfield.removeConstraint(attribute: .top)
                    textfield.setTopRelatedToView(offSet: PADDING_8, relatedView: btn, relatedAttribute: .bottom)
                    textfield.becomeFirstResponder()
                }
            }
            
            if let optionsArr = checkListBtnToSaopWidgetNameMap[btn.tag]{
                if let parentView = btn.superview{
                    if !btn.isOptionSelected{
                        btn.setOptionSelected(isSelected: true)
                        setChildViews(btn: btn, parentView: parentView, optionsArr: optionsArr)
                    }
                }
            }
            
            if let superParentView = btn.superview?.superview as? UIStackView{
                for btnSuperviews in superParentView.subviews{
                    
                    if let childRadio = btnSuperviews.subviews.first(where: { btnSubView in
                        return btnSubView is SOAPOptionView
                    }) as? SOAPOptionView {
                        if childRadio.isOptionSelected && childRadio.tag != btn.tag {
                            childRadio.setOptionSelected(isSelected: false)
                            childRadio.removeVerticalLine()
                            setMainViewWidth(containerView: childRadio.superview)
                            
                            let textFieldTag = checkListButtonToChildMap[childRadio.tag] ?? -1
                            if let textfield = self.viewWithTag(textFieldTag) as? UITextField{
                                textfield.text = ""
                                otherViewHeightConstraint?.constant = 0
                                scrollViewHeightConstraint?.constant -= (textFieldHeight + PADDING_8)
                                textfield.removeConstraint(attribute: .top)
                                textfield.setTopRelatedToView(offSet: 0, relatedView: childRadio, relatedAttribute: .bottom)
                                textfield.resignFirstResponder()
                            }
                            else{
                                if let otherBtnParentView = childRadio.superview{
                                    if let childView = otherBtnParentView.subviews.first(where: { subViews in
                                        return subViews is UIStackView
                                    }) as? UIStackView{
                                        let height = getSubViewsHeight(childView: childView, initCount: 0)
                                        scrollViewHeightConstraint?.constant -= height
                                    }
                                    for subviews in otherBtnParentView.subviews{
                                        if !(subviews is SOAPOptionView || subviews.getHeight() == horizontalLineHeight) || subviews is UITextField{
                                            subviews.removeFromSuperview()
                                        }
                                    }
                                    childRadio.setBottom(offSet: 0)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func YesOrNoBtbClicked(btn: UIButton)
    {
        self.endEditing(true)
        if !btn.isSelected
        {
            if btn.title(for: .normal) == YES_String{
                if let textField = self.viewWithTag(btn.tag + addTagNo) as? UITextField, let yesTextFieldHeightConstraint = yesTextFieldHeightConstraint{
                    UIView.animate(withDuration: 0.4){
                        yesTextFieldHeightConstraint.constant = textFieldHeight
                        self.layoutIfNeeded()
                    }
                    textField.removeConstraint(attribute: .top)
                    textField.setTopRelatedToView(offSet: PADDING_8, relatedView: btn, relatedAttribute: .bottom)
                    textField.becomeFirstResponder()
                }
            }
            else if btn.title(for: .normal) == NO_String{
                if let textField = self.viewWithTag(btn.tag + addTagNo) as? UITextField, let noTextFieldHeightConstraint = noTextFieldHeightConstraint{
                    UIView.animate(withDuration: 0.4){
                        noTextFieldHeightConstraint.constant = textFieldHeight
                        self.layoutIfNeeded()
                    }
                    textField.removeConstraint(attribute: .top)
                    textField.setTopRelatedToView(offSet: PADDING_8, relatedView: btn, relatedAttribute: .bottom)
                    textField.becomeFirstResponder()
                }
            }
            for view in self.subviews
            {
                if let otherBtn = view as? UIButton
                {
                    if btn.tag != otherBtn.tag && otherBtn.isSelected{
                        if otherBtn.title(for: .normal) == YES_String{
                            if let textField = self.viewWithTag(otherBtn.tag + addTagNo) as? UITextField, let yesTextFieldHeightConstraint = yesTextFieldHeightConstraint{
                                textField.text = ""
                                UIView.animate(withDuration: 0.4){
                                    yesTextFieldHeightConstraint.constant = 0
                                    self.layoutIfNeeded()
                                }
                                textField.resignFirstResponder()
                                textField.setTopRelatedToView(offSet: 0, relatedView: otherBtn, relatedAttribute: .bottom)
                            }
                        }
                        else if otherBtn.title(for: .normal) == NO_String{
                            if let textField = self.viewWithTag(otherBtn.tag + addTagNo) as? UITextField, let noTextFieldHeightConstraint = noTextFieldHeightConstraint{
                                textField.text = ""
                                UIView.animate(withDuration: 0.4){
                                    noTextFieldHeightConstraint.constant = 0
                                    self.layoutIfNeeded()
                                }
                                textField.removeConstraint(attribute: .top)
                                textField.setTopRelatedToView(offSet: 0, relatedView: otherBtn, relatedAttribute: .bottom)
                                textField.resignFirstResponder()
                            }
                        }
                        otherBtn.isSelected = false
                    }
                }
            }
            btn.isSelected = true
        }
        else{
            if let textField = self.viewWithTag(btn.tag + addTagNo) as? UITextField{
                textField.becomeFirstResponder()
            }
            else{
                delegate?.dismissKeyboard()
            }
        }
    }
    
    private func getSubViewsHeight(childView: UIStackView, initCount: CGFloat) -> CGFloat{
        return childView.frame.height + X_SPACE
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - OptionView

class OptionView : UIView {
    
    private var width: CGFloat = 0
    private var isSelected = false
    private var isRadio = true
    
    private let optionImg = UIImageView(image: UIImage(named: "RadioBtnSelected"))
    private let uiLabel = UILabel()

    init(){
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView(label: String, isRadio: Bool, width: CGFloat){
        
        self.isRadio = isRadio
        self.addSubview(optionImg)
        self.addSubview(uiLabel)
        
        uiLabel.setProperties(textKey: label, fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        
        setOptionSelected(isSelected: isSelected)
        
        uiLabel.setTop(offSet: 10)
        
        optionImg.setWidth(constant: ONE_LINE_BUTTON_HEIGHT)
        optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
        optionImg.setTop(offSet: PADDING_8)
        optionImg.setLeft(offSet: CARD_PADDING)
        
        uiLabel.setRight(offSet: -CARD_PADDING)
        uiLabel.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: optionImg, relatedAttribute: .right)
        uiLabel.setBottom(offSet: -PADDING_8)
    }
    
    var isOptionSelected: Bool {
        return isSelected
    }
    
    func setOptionSelected(isSelected: Bool) {
        self.isSelected = isSelected
        
        if isSelected {
            if isRadio {
                optionImg.image = UIImage(named: "RadioBtnSelected")
            }
            else{
                optionImg.image = UIImage(named: "CheckboxSelected")
            }
        }
        else{
            if isRadio {
                optionImg.image = UIImage(named: "RadioBtnUnselected")
            }
            else{
                optionImg.image = UIImage(named: "CheckboxUnselected")
            }
        }
    }
    
    var buttonTitle: String {
        return uiLabel.text ?? ""
    }
}

//MARK: - SoapOptionView

class SOAPOptionView : UIView {
    
    var index: Int = -1
    private var verticalLine: UIView? = nil
    private var width: CGFloat = 0
    private var isSelected = false
    private var isRadio = true
    private var isHierarchy = false
    private let optionImg = UIImageView(image: UIImage(named: "RadioBtnSelected"))
    private let labelView = UIView()
    private let uiLabel = UILabel()
    private var originalWidth: CGFloat = 0
    private let radioHeirarchyBtnWidth: CGFloat = 34
    
    init(){
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView(label: String, isRadio: Bool, isHierarchy: Bool, width: CGFloat){
        
        self.isRadio = isRadio
        self.isHierarchy = isHierarchy
        self.width = width
        self.originalWidth = width
        
        self.addSubview(optionImg)
        self.addSubview(labelView)
        labelView.addSubview(uiLabel)
        
        uiLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        uiLabel.textColor = .black
        uiLabel.numberOfLines = 0
        uiLabel.text = label
        
        if labelHeight <= ONE_LINE_BUTTON_HEIGHT {
            labelView.setTop(offSet: 0)
        }
        else{
            labelView.setTop(offSet: 0)
        }
        
        optionImg.setTop(offSet: 0)
        optionImg.setLeft(offSet: 0)
        
        labelView.setRight(offSet: 0)
        labelView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: optionImg, relatedAttribute: .right)
        labelView.setBottom(offSet: 0)
        
        uiLabel.setLeft(offSet: 0)
        uiLabel.setRight(offSet: 0)
        uiLabel.setTop(offSet: 0)
        uiLabel.setBottom(offSet: 0)
        // Minimum one-line height keeps short options aligned with the icon; longer ones wrap and grow.
        uiLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ONE_LINE_BUTTON_HEIGHT).isActive = true
        setOptionSelected(isSelected: isSelected)
    }
    
    var isOptionSelected: Bool {
        return isSelected
    }
    
    func setOptionSelected(isSelected: Bool) {
        optionImg.removeConstraint(attribute: .width)
        optionImg.removeConstraint(attribute: .height)
        
        self.isSelected = isSelected
        width = originalWidth
        
        if isSelected {
            if isRadio{
                if isHierarchy{
                    optionImg.image = UIImage(named: "radio-heirarchy-selected")
                    width = width - (33 + CARD_PADDING + SOAP_MAIN_VIEW_PADDING)
                    optionImg.setWidth(constant: 33)
                    optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                }
                else{
                    optionImg.image = UIImage(named: "RadioBtnSelected")
                    width = width - (commonButtonWidth + CARD_PADDING + SOAP_MAIN_VIEW_PADDING)
                    optionImg.setWidth(constant: commonButtonWidth)
                    optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                }
            }
            else{
                if isHierarchy{
                    optionImg.image = UIImage(named: "checkbox-heirarchy-selected")
                    width = width - (commonButtonWidth + CARD_PADDING + SOAP_MAIN_VIEW_PADDING)
                    optionImg.setWidth(constant: commonButtonWidth)
                    optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                }
                else{
                    optionImg.image = UIImage(named: "CheckboxSelected")
                    width = width - (commonButtonWidth + CARD_PADDING + SOAP_MAIN_VIEW_PADDING)
                    optionImg.setWidth(constant: commonButtonWidth)
                    optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                }
            }
        }
        else{
            if isRadio{
                if isHierarchy{
                    optionImg.image = UIImage(named: "radio-heirarchy-unselected")
                    width = width - (radioHeirarchyBtnWidth + CARD_PADDING + SOAP_MAIN_VIEW_PADDING)
                    optionImg.setWidth(constant: radioHeirarchyBtnWidth)
                    optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                }
                else{
                    optionImg.image = UIImage(named: "RadioBtnUnselected")
                    width = width - (commonButtonWidth + CARD_PADDING + SOAP_MAIN_VIEW_PADDING)
                    optionImg.setWidth(constant: commonButtonWidth)
                    optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                }
            }
            else{
                if isHierarchy{
                    optionImg.image = UIImage(named: "checkbox-heirarchy-unselected")
                    width = width - (commonButtonWidth + CARD_PADDING + SOAP_MAIN_VIEW_PADDING)
                    optionImg.setWidth(constant: commonButtonWidth)
                    optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                }
                else{
                    optionImg.image = UIImage(named: "CheckboxUnselected")
                    width = width - (commonButtonWidth + CARD_PADDING + SOAP_MAIN_VIEW_PADDING)
                    optionImg.setWidth(constant: commonButtonWidth)
                    optionImg.setHeight(constant: ONE_LINE_BUTTON_HEIGHT)
                }
            }
        }
    }
    
    var buttonTitle: String {
        return uiLabel.text ?? ""
    }
    
    private var labelWidth: CGFloat{
        return uiLabel.sizeThatFits(CGSize(width: width , height: 2000)).width
    }
    
    var viewWidth: CGFloat{
        return labelWidth + CARD_PADDING + (isRadio && isHierarchy && !isSelected ? radioHeirarchyBtnWidth : (isRadio && isHierarchy && isSelected ? 33.5 : commonButtonWidth))
    }
    
    var labelHeight: CGFloat{
        let labelHeight = self.uiLabel.sizeThatFits(CGSize(width: width, height: 2000)).height
        if labelHeight <= ONE_LINE_BUTTON_HEIGHT{
            return ONE_LINE_BUTTON_HEIGHT
        }
        else{
            return labelHeight
        }
    }
    
    func addVerticalLine(){
        verticalLine = UIView()
        if let verticalLine = verticalLine{
            self.addSubview(verticalLine)
                        
            verticalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: lineColor)
            verticalLine.setLeftRelatedToView(offSet: verticalLineLeftPadding, relatedView: optionImg, relatedAttribute: .left)
            verticalLine.setTopRelatedToView(offSet: 0, relatedView: optionImg, relatedAttribute: .bottom)
            verticalLine.setBottomRelatedToView(offSet: 0, relatedView: labelView, relatedAttribute: .bottom)
            verticalLine.setWidth(constant: verticalLineWidth)
        }
    }
    
    func removeVerticalLine(){
        if let verticalLine = verticalLine{
            verticalLine.removeFromSuperview()
        }
    }
}

class SoapNestedCheckListModal{
    var key: Int = 0
    var actualWidth: CGFloat = 0
    var modifieldWidth: CGFloat = 0
    var heirarchyLevel: CGFloat = 0
    var parent: [Int: SoapNestedCheckListModal] = [:]
    var child: [Int: SoapNestedCheckListModal] = [:]
}
