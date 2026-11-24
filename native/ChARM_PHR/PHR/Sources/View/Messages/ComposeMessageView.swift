//
//  ComposeMessageView.swift
//  PHR
//
//  Created by prathi-13964 on 01/07/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import WebKit

class ComposeMessageView: UIView, UITextViewDelegate, DropDownViewDelegate{
    
    private let activityIndicator = UIActivityIndicatorView()
    private let containerScrollView = TPKeyboardAvoidingScrollView()
    private let bottomView = BottomCharView()
    private let containerView = UIView()
    private let fromLabel = UILabel()
    private let fromValueLabel = UILabel()
    private let practiceView = UIView()
    private let practiceLabel = UILabel()
    private let practiceValueLabel = UILabel()
    var practiceValueView: DropDownViewWithSearch?
    let subContainerView = UIView()
    private let toView = UIView()
    private let toLabel = UILabel()
    let toValueView = UIView()
    let toValueTextField = CustomTextField()
    private let verticalStackView = UIStackView()
    let providerListTableView = MDAutoGrowingTableView()
    private let noDataMemberView = UIView()
    private let noDataLabel = UILabel()
    private let subjectView = UIView()
    private let subjectLabel = UILabel()
    let subjectValueTextView = UITextView()
    let contentTextView = UITextView()
    let actionMessageWebView = WKWebView()
    let documentContainerView = UIView()
    
    private let contentFile: String
    private let practiceList: [Practice]
    private let delegate: ComposeMessageViewController
    
    private var textViewBottomConstraint : NSLayoutConstraint?
    private var charCountViewBottomConstraint : NSLayoutConstraint?
    private var MAX_CHARACTER_CAN_BE_USED : Int = 10000
    
    var selectedPractice: Practice? = nil
    var toValueViewWidth: CGFloat = applicationFrame.width
    
    init(contentFile: String, practiceList: [Practice], delegate: ComposeMessageViewController, selectedPractice: Practice? = nil){
        self.contentFile = contentFile
        self.practiceList = practiceList
        self.delegate = delegate
        super.init(frame: .zero)
        
        if selectedPractice != nil{
            self.selectedPractice = selectedPractice
            subContainerView.isHidden = false
        }
        else{
            if practiceList.count > 1{
                subContainerView.isHidden = true
            }
            else{
                self.selectedPractice = practiceList.first
                subContainerView.isHidden = false
            }
        }
        
        updateCharactersCount(count: "\(contentTextView.text.count)")
        
        addSubviews()
        setPracticeView()
        
        bottomView.isHidden = true
        
        subjectValueTextView.delegate = self
        contentTextView.delegate = self
        
        setFromValue()
        setMessageMaxLength()
    }
    
    private func addSubviews(){
        
        self.addSubview(activityIndicator)
        self.addSubview(bottomView)
        self.addSubview(containerScrollView)
        containerScrollView.addSubview(containerView)
        containerView.addSubview(fromLabel)
        containerView.addSubview(fromValueLabel)
        containerView.addSubview(subContainerView)
        containerView.addSubview(documentContainerView)
        
        subContainerView.addSubview(toView)
        toView.addSubview(toLabel)
        toView.addSubview(toValueView)
        toValueView.addSubview(toValueTextField)
        subContainerView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(providerListTableView)
        verticalStackView.addArrangedSubview(noDataMemberView)
        noDataMemberView.addSubview(noDataLabel)
        
        subContainerView.addSubview(subjectView)
        subjectView.addSubview(subjectLabel)
        subjectView.addSubview(subjectValueTextView)
        
        subContainerView.addSubview(contentTextView)
        subContainerView.addSubview(actionMessageWebView)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        containerView.setTop(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setWidth(constant: applicationFrame.width)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        fromLabel.setLeft(offSet: X_SPACE)
        fromLabel.setTop(offSet: 12)
        fromLabel.wrapWidth(maxWidth: 200)
        
        fromValueLabel.setLeftRelatedToView(offSet: 6, relatedView: fromLabel, relatedAttribute: .right)
        fromValueLabel.setRight(offSet: -X_SPACE)
        fromValueLabel.setTopRelatedToView(offSet: 0, relatedView: fromLabel, relatedAttribute: .top)
        
        subContainerView.setLeft(offSet: 0)
        subContainerView.setRight(offSet: 0)
        
        toView.setLeft(offSet: X_SPACE)
        toView.setRight(offSet: -X_SPACE)
        toView.setTop(offSet: 0)
        
        toValueViewWidth -= (X_SPACE * 2)
        
        toLabel.setLeft(offSet: 0)
        toLabel.setTop(offSet: 12)
        let toLabelWidth = toLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width
        toLabel.setWidth(constant:toLabelWidth)
        
        toValueViewWidth -= toLabelWidth
        
        toValueView.setLeftRelatedToView(offSet: 10, relatedView: toLabel, relatedAttribute: .right)
        toValueView.setTop(offSet: 8)
        toValueView.setBottom(offSet: -8)
        toValueView.setRight(offSet: 0)
        
        toValueViewWidth -= 10
        
        toValueTextField.setLeft(offSet: 0)
        toValueTextField.setRight(offSet: 0)
        toValueTextField.setTop(offSet: 0)
        toValueTextField.setBottom(offSet: 0)
        toValueTextField.setHeight(constant: 32)
        
        verticalStackView.setLeft(offSet: 0)
        verticalStackView.setRight(offSet: 0)
        verticalStackView.setTopRelatedToView(offSet: 0, relatedView: toView, relatedAttribute: .bottom)
        
        providerListTableView.heightConstraint = providerListTableView.setAndReturnHeight(constant: 0)
        noDataMemberView.setHeight(constant: 70)
        
        noDataLabel.setCenterX()
        noDataLabel.setCenterY()
        
        subjectView.setLeft(offSet: X_SPACE)
        subjectView.setRight(offSet: -X_SPACE)
        subjectView.setTopRelatedToView(offSet: 0, relatedView: verticalStackView, relatedAttribute: .bottom)
        
        subjectLabel.setLeft(offSet: 0)
        subjectLabel.setTop(offSet: 8)
        subjectLabel.wrapWidth(maxWidth: 200)
        subjectLabel.wrapHeight(maxHeight: 50)
        
        subjectValueTextView.setLeftRelatedToView(offSet: 10, relatedView: subjectLabel, relatedAttribute: .right)
        subjectValueTextView.setRight(offSet: 0)
        subjectValueTextView.setTop(offSet: 0)
        subjectValueTextView.setBottom(offSet: -5)
        
        contentTextView.setLeft(offSet: X_SPACE)
        contentTextView.setRight(offSet: -X_SPACE)
        contentTextView.setTopRelatedToView(offSet: 10, relatedView: subjectView, relatedAttribute: .bottom)
        let contentTextViewHeightConst = NSLayoutConstraint(item: contentTextView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 150)
        subContainerView.addConstraint(contentTextViewHeightConst)
        
        
        actionMessageWebView.setLeft(offSet: X_SPACE)
        actionMessageWebView.setRight(offSet: -X_SPACE)
        actionMessageWebView.setTopRelatedToView(offSet: 10, relatedView: contentTextView, relatedAttribute: .bottom)
        actionMessageWebView.setBottom(offSet: 0)
        
        if contentFile.isNotBlank(){
            actionMessageWebView.setHeight(constant: 150)
        }else{
            actionMessageWebView.setHeight(constant: 0)
        }
        
        documentContainerView.setLeft(offSet: X_SPACE)
        documentContainerView.setRight(offSet: -X_SPACE)
        documentContainerView.setTopRelatedToView(offSet: 5, relatedView: subContainerView, relatedAttribute: .bottom)
        documentContainerView.setBottom(offSet: -5)
        
        bottomView.setLeft(offSet: 0)
        bottomView.setRight(offSet: 0)
        bottomView.setBottom(offSet: 0)
        
        containerScrollView.setSafeAreaTop(offset: 0)
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        containerScrollView.setBottomRelatedToView(offSet: 0, relatedView: bottomView, relatedAttribute: .top)
    }
    
    private func addProperties(){
        
        self.backgroundColor = .white
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        fromLabel.setProperties(textKey: "com.charmphr.message.compose.from", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_LIGHT)
        
        fromValueLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .medium)
        fromValueLabel.numberOfLines = 0
        
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .fill
        verticalStackView.spacing = 0
        
        toView.addBottomBorder()
        
        toLabel.setProperties(textKey:  "com.charmphr.message.compose.to", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_LIGHT)
        
        toValueTextField.textAlignment = .left
        toValueTextField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        toValueTextField.returnKeyType = .done
        toValueTextField.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        
        subjectView.addBottomBorder()
        
        subjectLabel.setProperties(textKey: "com.charmphr.message.compose.subject", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_LIGHT)
        
        subjectValueTextView.maxLength = 225
        subjectValueTextView.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        subjectValueTextView.isScrollEnabled = false
        
        contentTextView.isScrollEnabled = false
        contentTextView.maxLength = MAX_CHARACTER_CAN_BE_USED
        contentTextView.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        contentTextView.placeholder = getString(key: "com.charmphr.message.compose.content.placeholder.title")
        
        noDataMemberView.addShadowAndCornerRadius(.SMALL)
        
        noDataLabel.setProperties(textKey: "com.charmphr.sharedocuments.member.noDataLabel.title", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        
        hideMemberNoData(isHidden: true)
        
        providerListTableView.separatorStyle = .singleLine
        providerListTableView.isScrollEnabled = true
        providerListTableView.maxHeight = 300
        providerListTableView.sectionHeaderTopPadding = 0
        
        bottomView.addTopBorder(color: UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR), borderWidth: 0.5)
    }
    
    //MARK: - setPractice View
    
    private func setPracticeView(){
        
        if let selectedPractice = selectedPractice{
            
            containerView.addSubview(practiceLabel)
            containerView.addSubview(practiceValueLabel)
            
            let practiceText = "\(getString(key: "com.charmphr.message.compose.practice")) :";
            practiceLabel.setProperties(textKey: practiceText, fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_LIGHT)
            practiceValueLabel.setProperties(textKey: selectedPractice.practiceName ?? "", fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
            practiceValueLabel.numberOfLines = 0
            
            practiceLabel.setLeft(offSet: X_SPACE)
            practiceLabel.setTopRelatedToView(offSet: 12, relatedView: fromValueLabel, relatedAttribute: .bottom)
            practiceLabel.wrapWidth(maxWidth: 300)
            
            practiceValueLabel.setLeftRelatedToView(offSet: 6, relatedView: practiceLabel, relatedAttribute: .right)
            practiceValueLabel.setRight(offSet: -X_SPACE)
            practiceValueLabel.setTopRelatedToView(offSet: 0, relatedView: practiceLabel, relatedAttribute: .top)
            
            subContainerView.setTopRelatedToView(offSet: 0, relatedView: practiceValueLabel, relatedAttribute: .bottom)
        }
        else{
            let selectModelList = TransformUtil.transformPracticeToSelectModel(practiceList: practiceList)
            practiceValueView = DropDownViewWithSearch(placeHolderKey: "com.charmphr.message.compose.practice.placeholder", renderingList: selectModelList, delegate: self)
            
            guard let practiceValueView else { return }
            containerView.addSubview(practiceLabel)
            containerView.addSubview(practiceValueView)
            
            practiceLabel.setProperties(textKey: "com.charmphr.message.compose.practice", fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
            
            practiceLabel.setLeft(offSet: X_SPACE)
            practiceLabel.setRight(offSet: 0)
            practiceLabel.setTopRelatedToView(offSet: 12, relatedView: fromValueLabel, relatedAttribute: .bottom)
            
            practiceValueView.setLeft(offSet: X_SPACE)
            practiceValueView.setRight(offSet: -X_SPACE)
            practiceValueView.setTopRelatedToView(offSet: 6, relatedView: practiceLabel, relatedAttribute: .bottom)
            
            subContainerView.setTopRelatedToView(offSet: 5, relatedView: practiceValueView, relatedAttribute: .bottom)
        }
    }
    
    private func setFromValue(){
        let patient = getSelectedPatient()
        
        if !patient.firstName.isNilOrBlank() && !patient.lastName.isNilOrBlank()
        {
            fromValueLabel.text = "\(patient.firstName ?? "") \(patient.lastName ?? "")"
        }
        else if !patient.firstName.isNilOrBlank() {
            fromValueLabel.text = patient.firstName ?? ""
        }
        else if !patient.lastName.isNilOrBlank() {
            fromValueLabel.text = patient.lastName ?? ""
        }
    }
    
    func setToTextFieldConstraint(hasSpace: Bool, beforeView: UIView?, width: CGFloat){
        toValueView.subviews.forEach({ view in
            if let textField = view as? UITextField{
                textField.removeConstraints()
                textField.arrangeViews(constant: 10, hasSpace: hasSpace, beforeView: beforeView)
                textField.setBottom(offSet: 0)
                textField.setHeight(constant: 32)
                textField.setWidth(constant: width)
            }
        })
    }
    
    private func setMessageMaxLength(){
        guard let selectedPractice else { return }
        bottomView.isHidden = false
        if let messageRestriction = delegate.getMessageRestriction(practiceId: selectedPractice.practiceId){
            MAX_CHARACTER_CAN_BE_USED = messageRestriction.numberOfCharAllowed
            contentTextView.maxLength = MAX_CHARACTER_CAN_BE_USED
        }
        
        updateCharactersCount(count: "\(contentTextView.text.count)")
    }
    
    //MARK: - DropDownView Delegate
    
    func didSelectValue(_ value: SelectValueModel) {
        selectedPractice = practiceList.first(where: { practice in
            return practice.practiceId == value.id
        })
        delegate.fetchMemberList(practice: selectedPractice)
        setMessageMaxLength()
    }
    
    func onClickClose() {
        delegate.emptySelectedValues()
        selectedPractice = nil
        toValueTextField.text = nil
        toValueView.subviews.forEach { subViews in
            if subViews is CardViewWithCloseBtn{
                subViews.removeFromSuperview()
            }
        }
        setToTextFieldConstraint(hasSpace: false, beforeView: nil, width: applicationFrame.width - 100)
        subContainerView.isHidden = true
        bottomView.isHidden = true
    }
    
    //MARK: - Other functions
    
    private func updateCharactersCount(count:String) {
        bottomView.characterLabel.text = "\(count) of \(MAX_CHARACTER_CAN_BE_USED) Characters"
    }
    
    func hideMemberNoData(isHidden: Bool){
        if !isHidden{
            self.bringSubviewToFront(noDataMemberView)
        }
        noDataMemberView.isHidden = isHidden
        noDataLabel.isHidden = isHidden
    }
    
    func changeHeightOfTextView(KeyboardFrame:CGRect) {
        textViewBottomConstraint?.constant = -(KeyboardFrame.height + 5)
        charCountViewBottomConstraint?.constant = -KeyboardFrame.height
    }
    
    func isValueNotChanged() -> Bool {
        return isNilOrEmpty(string: contentTextView.text) && isNilOrEmpty(string: toValueTextField.text) && isNilOrEmpty(string: subjectValueTextView.text)
    }
    
    //MARK: - TextView Delegate
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == contentTextView
        {
            updateCharactersCount(count: "\(contentTextView.text.count)")
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView == contentTextView
        {
            updateCharactersCount(count: "\(contentTextView.text.count)")
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == contentTextView
        {
            updateCharactersCount(count: "\(contentTextView.text.count)")
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRanges ranges: [NSValue], replacementText text: String) -> Bool {
        if textView == contentTextView
        {
            contentTextView.scrollRangeToVisible(NSMakeRange(contentTextView.text.count - 1, 1))
        }
        return true
    }

    //MARK: - ActivityIndicator
    
    func showActivityIndicator(){
        self.bringSubviewToFront(activityIndicator)
        resignFirstResponderForTextViews()
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator(){
        ///uncomment this when the pagination is uncommented
//        providerListTableView.infiniteScrollingView.stopAnimating()
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true
    }
    
    private func resignFirstResponderForTextViews(){
        toValueTextField.resignFirstResponder()
        subjectValueTextView.resignFirstResponder()
        contentTextView.resignFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class BottomCharView: UIView {
    
    let characterLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_GRAY_BG_COLOR)
        
        characterLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        self.addSubview(characterLabel)
        
        characterLabel.setSafeAreaBottom(offset: -14.5)
        characterLabel.setTop(offSet: 14.5)
        characterLabel.setCenterX()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
