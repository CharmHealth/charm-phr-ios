//
//  QuestionnaireEntryViews.swift
//  phr
//
//  Created by prathi-13964 on 03/04/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let buttonSize: CGFloat = 24
fileprivate var tagNo = 503909430

//MARK: - Question View

class QuestionView: UIView, UITextFieldDelegate, MDTextFieldDelegate{
    
    private let textField = MDTextField()
    private let textView = MDTextView()
    
    init(isSingleLine: Bool, feedbackPOJO: QuestionnaireEntryPOJO?, soapWidgetPOJO: SOAPWidgetEntry?){
        super.init(frame: .zero)
        
        if isSingleLine {
            
            textField.addCornerRadius(.SMALL)
            textField.layer.borderWidth = 1
            textField.maxLength = SINGLELINE_MAXLENGTH
            textField.delegate = self
            textField.returnKeyType = .done
            textField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            textField.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BORDER_COLOR).cgColor
            textField.setPadding(width: TEXTFIELD_PADDING_8)
            
            self.addSubview(textField)
            
            textField.setLeft(offSet: 0)
            textField.setRight(offSet: 0)
            textField.setBottom(offSet: 0)
            textField.setTop(offSet: 0)
            textField.setHeight(constant: 42)
        }
        else{
            
            self.addSubview(textView)
            
            textView.addCornerRadius(.SMALL)
            textView.layer.borderWidth = 1
            textView.maxLength = MULTILINE_MAXLENGHT
            textView.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            textView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BORDER_COLOR).cgColor
            textView.isScrollEnabled = false
            
            textView.setTop(offSet: 0)
            textView.setLeft(offSet: 0)
            textView.setRight(offSet: 0)
            textView.setBottom(offSet: 0)
            textView.setHeight(constant: 42, relatedBy: .greaterThanOrEqual)
        }
        
        if let feedbackPOJO = feedbackPOJO{
            if isSingleLine{
                textField.text = feedbackPOJO.questionnaireEntry.answersList?.firstOrNil() ?? ""
            }
            else{
                textView.text = feedbackPOJO.questionnaireEntry.answersList?.firstOrNil() ?? ""
            }
        }
        else if let soapWidgetPOJO = soapWidgetPOJO{
            
            if soapWidgetPOJO.questionnaireSOAPEntry?.value.isNilOrBlank() == true{
                if isSingleLine{
                    textField.text = soapWidgetPOJO.defaultValue
                }
                else{
                    textView.text = soapWidgetPOJO.defaultValue
                }
            }
            else{
                if isSingleLine{
                    textField.text = soapWidgetPOJO.questionnaireSOAPEntry?.value ?? ""
                }
                else{
                    textView.text = soapWidgetPOJO.questionnaireSOAPEntry?.value ?? ""
                }
            }
        }
    }
    
    var value: String?{
        if textField.text.isNilOrBlank() == false{
            return textField.text
        }
        else if textView.text.isNilOrBlank() == false{
            return textView.text
        }
        return nil
    }
    
    func mdTextFieldShouldReturn(_ textField: MDTextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Rating Scale View

class RatingScale: UIView{
    
    private let slider = UISlider()
    private let uiLabel = UILabel()
    
    init(feedbackPOJO: QuestionnaireEntryPOJO?, soapWidgetPOJO: SOAPWidgetEntry?){
        super.init(frame: .zero)
        
        self.addSubview(slider)
        self.addSubview(uiLabel)
        
        if let feedbackPOJO = feedbackPOJO{
            slider.maximumValue = Float(truncating: NSNumber(value: feedbackPOJO.questionnaireEntry.toScale ?? 10))
            slider.value = Float(truncating: NSNumber(value: feedbackPOJO.questionnaireEntry.fromScale ?? 0))
            slider.minimumValue = Float(truncating: NSNumber(value: feedbackPOJO.questionnaireEntry.fromScale ?? 10))
        }
        else if let soapWidgetPOJO = soapWidgetPOJO{
            if let toScale = Float(soapWidgetPOJO.customText?.components(separatedBy: "^^").last ?? ""), let fromScale = Float(soapWidgetPOJO.customText?.components(separatedBy: "^^").first ?? ""){
                slider.maximumValue =  toScale
                slider.value = fromScale
                slider.minimumValue = fromScale
            }
        }
        slider.tintColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        
        slider.addTarget(self, action: #selector(onSliderValueChange(slider:)), for: .valueChanged)
        
       
        uiLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        uiLabel.setTextColor(fontcolor: TEXT_COLOR_HEAVYDARK)
        
        if let feedbackPOJO = feedbackPOJO{
            
            uiLabel.text = feedbackPOJO.questionnaireEntry.answersList?.firstOrNil()
            
            if let value = Int(uiLabel.text ?? ""){
                slider.value = Float(truncating: NSNumber(value: value))
            }
        }
        else if let soapWidgetPOJO = soapWidgetPOJO{
            
            let valueStr = soapWidgetPOJO.questionnaireSOAPEntry?.value ?? soapWidgetPOJO.defaultValue ?? ""
            uiLabel.text = valueStr
            if let value = Int(valueStr){
                slider.value = Float(truncating: NSNumber(value: value))
            }
        }
        uiLabel.textAlignment = .center
        uiLabel.layer.borderWidth = 1.0
        uiLabel.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        
        
        slider.setLeft(offSet: 0)
        slider.setTop(offSet: 0)
        slider.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: uiLabel, relatedAttribute: .left)
        slider.setBottom(offSet: 0)
        
        uiLabel.setRight(offSet: 0)
        uiLabel.setTop(offSet: 0)
        uiLabel.setBottom(offSet: 0)
        uiLabel.setWidth(constant: 30)
        uiLabel.setHeight(constant: 30)
    }
    
    var value: String?{
        return uiLabel.text
    }
    
    @objc private func onSliderValueChange(slider: UISlider){
        uiLabel.text = "\(Int(slider.value))"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Section View

class SectionView: UIStackView{
    
    private let sectionHeaderView  = UIView()
    private let sectionLabel = UILabel()
    private let separator = UIView()
    let stackView = UIStackView()
    private var collapseBtn: UIImageView? = nil
    weak var delegate: QuestionnaireAnswerView? = nil
    private var questionnaireEntryPOJO: QuestionnaireEntryPOJO? = nil
    private var SECTION_HEADER_HEIGHT: CGFloat = 0
    
    init(questionnaireEntryPOJO: QuestionnaireEntryPOJO, delegate: QuestionnaireAnswerView?){
        super.init(frame: .zero)
        
        self.delegate = delegate
        self.questionnaireEntryPOJO = questionnaireEntryPOJO
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.spacing = 0
        self.alignment = .center
        self.addShadowAndCornerRadius(.SMALL)
        
        self.addArrangedSubview(sectionHeaderView)
        sectionHeaderView.addSubview(sectionLabel)
        
        self.addArrangedSubview(separator)
        self.addArrangedSubview(stackView)
        
        separator.setBackgroundColor(bgColor: SEPARATOR_COLOR)
        
        stackView.backgroundColor = .white
        stackView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)
        
        stackView.layoutMargins = UIEdgeInsets(top: CARD_PADDING, left: 0, bottom: CARD_PADDING, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        if questionnaireEntryPOJO.questionnaireEntry.isCollapsible == true {
            
            collapseBtn = UIImageView(image: UIImage(named: "expand-arrow"))
            if let collapseBtn = collapseBtn{
                collapseBtn.isUserInteractionEnabled = true
                sectionHeaderView.addSubview(collapseBtn)
                
                collapseBtn.setWidth(constant: buttonSize)
                collapseBtn.setHeight(constant: buttonSize)
                
                collapseBtn.setCenterY()
                collapseBtn.setLeftRelatedToView(offSet: PADDING_4, relatedView: sectionLabel, relatedAttribute: .right)
                collapseBtn.setRight(offSet: 0)
                
                sectionHeaderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAnimateSectionView(recognizer: ))))
                
                if questionnaireEntryPOJO.questionnaireEntry.expandByDefault == true {
                    stackView.isHidden = false
                    collapseBtn.transform = CGAffineTransform(rotationAngle: .pi)
                }
                else{
                    stackView.isHidden = true
                    collapseBtn.transform = CGAffineTransform.identity
                }
            }
        }
        sectionLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        sectionLabel.numberOfLines = 0
        sectionLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        sectionLabel.text = questionnaireEntryPOJO.questionnaireEntry.notes
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = CARD_PADDING
        stackView.alignment = .fill
        
        separator.setHeight(constant: 1)
        
        sectionLabel.setLeft(offSet: 0)
        sectionLabel.setTop(offSet: PADDING_8)
        sectionLabel.setBottom(offSet: -PADDING_8)
        
        SECTION_HEADER_HEIGHT = sectionLabel.sizeThatFits(CGSize(width: applicationFrame.width - (2 * X_SPACE) - buttonSize - PADDING_4, height: 200)).height + (PADDING_8 * 2)
        sectionHeaderView.setHeight(constant: SECTION_HEADER_HEIGHT)
    }
    
    func setConstraints(width: CGFloat){
        stackView.setWidth(constant: width - (2 * CARD_PADDING))
        separator.setWidth(constant: width)
        sectionHeaderView.setWidth(constant: width - (2 * CARD_PADDING))
    }
    
    @objc func onAnimateSectionView(recognizer: UIGestureRecognizer){
        onAnimateSectionView(toHide: !stackView.isHidden)
    }
    
    func onAnimateSectionView(toHide: Bool, tag: Int? = nil){
        
        self.superview?.layoutIfNeeded()
        self.superview?.superview?.layoutIfNeeded()
        
        if stackView.isHidden {
            collapseBtn?.transform = CGAffineTransform.identity
        }
        else{
            collapseBtn?.transform = CGAffineTransform(rotationAngle: .pi)
        }
        
        if !toHide{
            stackView.isHidden = toHide
            separator.isHidden = stackView.isHidden
        }
        UIView.animate(withDuration: 0.5) { [self] in
            self.layoutIfNeeded()
            delegate?.layoutIfNeeded()
        } completion: { [self]_ in
            if toHide{
                stackView.isHidden = toHide
                separator.isHidden = stackView.isHidden
            }
        }
        
        if let tag = tag{
            if let view = self.viewWithTag(tag){
                let superViewPoint = view.superview?.superview?.frame.minY ?? 0
                delegate?.scrollToViewWithTag(view: stackView, isSectionScroll: true, y_point: superViewPoint + SECTION_HEADER_HEIGHT)
            }
        }
        else if !toHide{
            delegate?.scrollToViewWithTag(view: stackView, isSectionScroll: true)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Date View

class DateView: UIView{
    
    private let dateTextField = DateTextField()
    private let calendarIcon = UIImageView(image: UIImage(named: "Calendar"))
    private var selectedDate: Date? = nil
    var dateText: String? = nil
    
    init(feedbackPOJO: QuestionnaireEntryPOJO){
        super.init(frame: .zero)
        
        self.addSubview(dateTextField)
        self.addSubview(calendarIcon)
        
        dateTextField.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        dateTextField.placeholder = getString(key: "com.charmphr.common.dateField.placeholder")
        dateTextField.text = feedbackPOJO.questionnaireEntry.answersList?.firstOrNil() ?? ""
        
        calendarIcon.setRight(offSet: -CARD_PADDING)
        calendarIcon.setCenterY()
        calendarIcon.setWidth(constant: 25)
        calendarIcon.setHeight(constant: 25)
        
        
        let datePickerView = UIDatePicker()
        datePickerView.preferredDatePickerStyle = .wheels
        
        let dateToolbar = MDDateToolbarWithDone(textField: dateTextField, parent: self)
        dateToolbar.done?.action =  #selector(onClickDateDoneBtn)
        
        let currentDate = Date()
        datePickerView.date = currentDate
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = CharmUtil.getDateObjectWith(dateString: "\(currentDate.get(.year) + 150)-01-01", dateFormat: PHR_DATE_API_FORMAT)
        datePickerView.minimumDate =  CharmUtil.getDateObjectWith(dateString: "\(currentDate.get(.year) - 150)-01-01", dateFormat: PHR_DATE_API_FORMAT)
        
        dateText = dateTextField.text
        
        datePickerView.date = CharmUtil.getDateObjectWith(dateString: dateText ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) ?? Date()
        
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        dateTextField.inputView = datePickerView
        
        
        dateTextField.setTop(offSet: 0)
        dateTextField.setLeft(offSet: CARD_PADDING)
        dateTextField.setRight(offSet: -CARD_PADDING)
        dateTextField.setBottom(offSet: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func datePickerValueChanged(datePicker : UIDatePicker){
        selectedDate = datePicker.date
    }
    
    @objc private func onClickDateDoneBtn(_ btn: UIButton){
        
        if let selectedDate = selectedDate{
            dateText = CharmUtil.getDisplayDateStringWithYear(date: selectedDate)
            dateTextField.text = dateText
        }
        else{
            dateText = CharmUtil.getDisplayDateStringWithYear(date: Date())
            dateTextField.text = dateText
        }
        self.endEditing(true)
    }
}

//MARK: - Table View

class SOAPTableView: UIView, UIScrollViewDelegate{
    
    private let separatorWidth: CGFloat = 0.25
    private var soapWidgetEntry: SOAPWidgetEntry? = nil
    
    private let tableContainerView = UIView()
    private let soapWidgetTableStackView = UIStackView()
    private let scrollView = UIScrollView()
    private var width: CGFloat = 0
    
    init() {
        super.init(frame: .zero)
    }
    
    func initView(isSectionPresent: Bool, soapWidgetEntry: SOAPWidgetEntry, viewWidth: CGFloat){
        self.soapWidgetEntry = soapWidgetEntry
        self.width = viewWidth
        
        self.addSubview(tableContainerView)
        
        if !isSectionPresent{
            tableContainerView.setLeft(offSet: 10)
            tableContainerView.setRight(offSet: -10)
            tableContainerView.setTop(offSet: 10)
            tableContainerView.setBottom(offSet: -10)
        }
        else{
            tableContainerView.setLeft(offSet: 0)
            tableContainerView.setRight(offSet: 0)
            tableContainerView.setTop(offSet: 0)
            tableContainerView.setBottom(offSet: 0)
        }
        tableContainerView.addSubview(scrollView)
        
        scrollView.setLeft(offSet: 0)
        scrollView.setRight(offSet: 0)
        scrollView.setTop(offSet: 0)
        scrollView.setBottom(offSet: 0)
        
        scrollView.addSubview(soapWidgetTableStackView)
        
        soapWidgetTableStackView.translatesAutoresizingMaskIntoConstraints = false
        soapWidgetTableStackView.axis = .vertical
        soapWidgetTableStackView.spacing = separatorWidth
        soapWidgetTableStackView.alignment = .leading
        
        soapWidgetTableStackView.layer.cornerRadius = CardSize.SMALL.value
        soapWidgetTableStackView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: soapTableStrokeColor).cgColor
        soapWidgetTableStackView.layer.borderWidth = separatorWidth
        soapWidgetTableStackView.layer.masksToBounds = true
        
        soapWidgetTableStackView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: soapTableStrokeColor)
        
        setTableView()
        
        soapWidgetTableStackView.setLeft(offSet: 0)
        soapWidgetTableStackView.setRight(offSet: 0)
        soapWidgetTableStackView.setTop(offSet: 0)
        soapWidgetTableStackView.setBottom(offSet: 0)
    }
    
    private func setTableView(){
        
        var tableStr = soapWidgetEntry?.questionnaireSOAPEntry?.value ?? ""
        
        if tableStr.isBlank(){
            tableStr = soapWidgetEntry?.defaultValue ?? ""
            if tableStr.isBlank(){
                tableStr = soapWidgetEntry?.entryName ?? ""
            }
        }
        
        if let table = convertToArrayOfDictionary(text: tableStr) {
            
            var tableContainerViewHeight: CGFloat = (separatorWidth * CGFloat((table.count - 1))) + 0.5
            for tableRow in table{
                
                let totalSpan: CGFloat = CGFloat(tableRow.map({tableColumn in
                    tableColumn.getInt("colspan") ?? 0
                }).reduce(0, +))
                
                var perColumnWidth: CGFloat = 0
                let parentWidth = width
                if (parentWidth - ((2 * CARD_PADDING) + 0.5)) >= (totalSpan * 100){
                    perColumnWidth = (parentWidth - ((2 * CARD_PADDING) + 0.5)) / totalSpan
                    scrollView.isScrollEnabled = true
                }
                else{
                    perColumnWidth = 100
                    scrollView.isScrollEnabled = true
                    scrollView.delegate = self
                }
                let columnCount = tableRow.count
                let columnLastIndex = columnCount - 1
                
                let rowView = UIView()
                soapWidgetTableStackView.addArrangedSubview(rowView)
                
                rowView.setLeft(offSet: 0)
                rowView.setRight(offSet: 0)
                
                var prevView:UIView? = nil
                
                var rowHeight: CGFloat = 50
                
                for (columnIndex, tableColumn) in tableRow.enumerated() {
                    
                    var colView:UIView? = nil
                    let columnWidth = CGFloat(tableColumn.getInt("colspan") ?? 0) * perColumnWidth
                    
                    if tableColumn.getString("type") == "label"{
                        
                        let lableContainer = UIView()
                        rowView.addSubview(lableContainer)
                        
                        lableContainer.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
                        
                        let labelView = UILabel()
                        lableContainer.addSubview(labelView)
                        
                        lableContainer.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xF6F6F6FF)
                        labelView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xF6F6F6FF)
                        labelView.textColor = .black
                        labelView.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                        labelView.textAlignment = .center
                        labelView.numberOfLines = 0
                        
                        labelView.text = tableColumn.getString("value")?.trim()
                        
                        labelView.setLeft(offSet: 8)
                        labelView.setRight(offSet: -8)
                        labelView.setTop(offSet: 8)
                        labelView.setBottom(offSet: -8)
                        
                        let viewHeight = labelView.sizeThatFits(CGSize(width: columnWidth - (8 * 2), height: 1000)).height + (CARD_PADDING * 2) + (8 * 2)
                        if rowHeight < viewHeight  {
                            rowHeight = viewHeight
                        }
                        colView = lableContainer
                    }
                    else{
                        let lableContainer = UIView()
                        rowView.addSubview(lableContainer)
                        lableContainer.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
                        
                        let labelView = UITextView()
                        lableContainer.addSubview(labelView)
                        
                        labelView.backgroundColor = .white
                        labelView.textColor = .black
                        labelView.font = UIFont.systemFont(ofSize: 14, Weight: .regular)
                        labelView.textAlignment = .center
                        labelView.textContainerInset = UIEdgeInsets(top: 5, left: 9, bottom: 5, right: 9)
                        labelView.returnKeyType = .default
                        
                        labelView.text = tableColumn.getString("value")
                        
                        labelView.setLeft(offSet: 8)
                        labelView.setRight(offSet: -8)
                        labelView.setTop(offSet: 8)
                        labelView.setBottom(offSet: -8)
                        
                        colView = lableContainer
                    }
                    
                    if let prevView = prevView{
                        colView?.setLeftRelatedToView(offSet: 0, relatedView: prevView, relatedAttribute: .right)
                    }
                    else{
                        colView?.setLeft(offSet: 0)
                    }
                    
                    if columnIndex == columnLastIndex{
                        colView?.setRight(offSet: 0)
                    }
                    else{
                        colView?.addRightBorder(color: UIColorFromRGB(rgbValueWithAlpha: soapTableStrokeColor), borderWidth: separatorWidth)
                    }
                    colView?.setWidth(constant: columnWidth)
                    colView?.setTop(offSet: 0)
                    colView?.setBottom(offSet: 0)
                    
                    prevView = colView
                }
                
                rowView.setHeight(constant: rowHeight)
                tableContainerViewHeight += rowHeight
                prevView = nil
            }
            tableContainerView.setHeight(constant: tableContainerViewHeight)
        }
    }
    
    func convertToArrayOfDictionary(text: String) -> [[[String: Any]]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[[String: Any]]]
            } catch {
                debugPrintLog(error.localizedDescription)
            }
        }
        return nil
    }
    
    func convertToString(json: [[[String: Any]]]?) -> String{
        
        if let json = json {
            
            if !json.isEmpty {
                if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    
                    if !jsonString.isNilOrBlank(){
                        return jsonString ?? ""
                    }
                }
            }
        }
        return ""
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0.0
    }
    
    func getTableStackView() -> UIStackView{
        return soapWidgetTableStackView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Rating View

class RatingView: UIView{
    
    private let greatTxtColor:UInt = 0x27A228FF
    private let normalTxtColor:UInt = 0xED9103FF
    private let badTxtColor:UInt = 0xFF4539FF
    private var ratingLabel:UILabel = UILabel()
    var rating:Int=0{
        willSet{
            clearRating()
            ratingLabel.text = "\(newValue)"
            if newValue > 3 {
                ratingLabel.setTextColor(fontcolor: greatTxtColor)
            }
            else if newValue < 2 {
                ratingLabel.setTextColor(fontcolor: badTxtColor)
            }
            else{
                ratingLabel.setTextColor(fontcolor: normalTxtColor)
            }
            setRating(withRating: newValue)
        }
    }
    
    func createElements(){
        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        ratingLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
        ratingLabel.sizeToFit()
        
        self.addSubview(ratingLabel)

        ratingLabel.setCenterY()
        ratingLabel.setRight(offSet: -CARD_PADDING)
        
        var prevStarView:UIView? = nil
        
        for n in 1...5{
            
            let starView = UIView()
            self.addSubview(starView)
            
            starView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapStarView)))
            
            starView.setTop(offSet: 0)
            starView.setBottom(offSet: 0)
            
            let starBtn = UIButton(type: .custom)
            starBtn.setImage(UIImage(named: "Star-unfilled"), for: .normal)
            starBtn.setImage(UIImage(named: "Rating_Star_Filled"), for: .selected)
            starBtn.addTarget(self, action: #selector(updateRating), for: .touchUpInside)
            starBtn.isUserInteractionEnabled = true
            starBtn.tag = n
            
            starView.addSubview(starBtn)
            
            starBtn.setWidth(constant: buttonSize)
            starBtn.setHeight(constant: buttonSize)
            starBtn.setLeft(offSet: 5)
            starBtn.setRight(offSet: -5)
            starBtn.setTop(offSet: 6)
            starBtn.setBottom(offSet: -6)
            
            if n == 1 {
                starView.setLeft(offSet: 0)
            }
            else {
                if let prevStarView = prevStarView {
                    starView.setLeftRelatedToView(offSet: 6, relatedView: prevStarView, relatedAttribute: .right)
                }
            }
            prevStarView = starView
        }
    }
    
    private func clearRating(){
        for starView in self.subviews where !(starView is UILabel){
            if let starBtn = starView.subviews.first as? UIButton{
                starBtn.isSelected = false
            }
        }
    }
    
    private func setRating(withRating rating:Int){
        if(rating > 0){
            for starView in self.subviews where !(starView is UILabel){
                if let starBtn = starView.subviews.first as? UIButton{
                    if(Int(rating) >= starBtn.tag){
                        starBtn.isSelected = true
                    }
                }
            }
        }
        else {
            self.ratingLabel.text = ""
        }
    }
    
    @objc func onTapStarView(_ sender: UITapGestureRecognizer){
        if let btn = sender.view?.subviews.first as? UIButton{
            updateRating(btn)
        }
    }
    
    @objc func updateRating(_ sender: UIButton){
        self.rating = sender.tag
    }
}


//MARK: - CommonQuestionnaireLayout Views

class CommonQuestionnaireLayout: UIView {
    
    let commonQuestionnaireLabel = UILabel()
    let commonQuestionnaireMainLayout = UIView()
    
    init(notes : String?, addShadow: Bool) {
        super.init(frame: .zero)
        
        if addShadow {
            addShadowAndCornerRadius(.SMALL)
        }
        else{
            addCornerRadius(.SMALL)
            layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
            layer.borderWidth = 1
        }
        commonQuestionnaireMainLayout.addCornerRadius(.SMALL)
        
        commonQuestionnaireLabel.setTextColor(fontcolor: TEXT_COLOR_BLACK87)
        commonQuestionnaireLabel.text = notes
        commonQuestionnaireLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        commonQuestionnaireLabel.numberOfLines = 0
        self.addSubview(commonQuestionnaireLabel)
        
        commonQuestionnaireLabel.setTop(offSet:CARD_PADDING)
        commonQuestionnaireLabel.setLeft(offSet: CARD_PADDING)
        commonQuestionnaireLabel.setRight(offSet: -CARD_PADDING)

        let separator = UIView()
        self.addSubview(separator)
        
        separator.setBackgroundColor(bgColor: SEPARATOR_COLOR)
        separator.setTopRelatedToView(offSet: CARD_PADDING, relatedView: commonQuestionnaireLabel, relatedAttribute: .bottom)
        separator.setLeft(offSet: 0)
        separator.setRight(offSet: 0)
        separator.setHeight(constant: 1)
        
        self.addSubview(commonQuestionnaireMainLayout)
        
        commonQuestionnaireMainLayout.setRight(offSet: 0)
        commonQuestionnaireMainLayout.setLeft(offSet: 0)
        commonQuestionnaireMainLayout.setTopRelatedToView(offSet: 0, relatedView: separator, relatedAttribute: .bottom)
        commonQuestionnaireMainLayout.setBottom(offSet: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - AllergiesWidgetView

protocol AllergyFetchDelegate: AnyObject {
    func patientAddedAllergies(allergies: [AllergiesList])
}

class AllergiesWidgetView: UIStackView, QuestAddEntryVCDelegate, WidgetContainerActionDelegate, QuestSelectEntryDelegate, AllergyFetchDelegate{
    
    private var drugAllergyView: WidgetContainerView? = nil
    private var foodAllergyView: WidgetContainerView? = nil
    private var environmentalAllergyView: WidgetContainerView? = nil
    
    private var drugAllergyList: [AddWidgetCommonModel] = []
    private var foodAllergyList: [AddWidgetCommonModel] = []
    private var environmentalAllergyList: [AddWidgetCommonModel] = []
    
    private weak var delegate: QuestionnaireAnswerViewController? = nil
    private var btnToViewMap: [Int: Int] = [:]
    private var selectedViewTag: Int? = nil
    private var selectedAllergyType: AllergyType? = nil
    
    var nkda: Bool{
        return drugAllergyView?.isNoKnownChecked ?? false
    }
    var nkfa: Bool{
        return foodAllergyView?.isNoKnownChecked ?? false
    }
    var nkea: Bool{
        return environmentalAllergyView?.isNoKnownChecked ?? false
    }
        
    init(feedbackPOJO: QuestionnaireEntryPOJO, addShadow: Bool, width: CGFloat, isDataEditAllowed: Bool, delegate: QuestionnaireAnswerViewController?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
    
        self.axis = .vertical
        self.spacing = CARD_PADDING
        self.alignment = .fill
        
        var customModelList: [AddWidgetCommonModel] = []
        customModelList = feedbackPOJO.questionnaireAllergyList.map { allergiesEntries in
            return TransformUtil.transformAllergyToCustomModel(allergiesEntries: allergiesEntries)
        }
        
        drugAllergyList = customModelList.filter({ addWidgetCommonModel in
            return addWidgetCommonModel.type == .DrugAllergy
        })
        
        foodAllergyList = customModelList.filter({ addWidgetCommonModel in
            return addWidgetCommonModel.type == .FoodAllergy
        })
        
        environmentalAllergyList = customModelList.filter({ addWidgetCommonModel in
            return addWidgetCommonModel.type == .EnvironmentalAllergy
        })
        
        var allergyTypeList : [AllergyType] = []
        feedbackPOJO.questionnaireOptions.forEach({ option in
            if option.option == questionnaireNotesTypeAllergyDrug{
                allergyTypeList.append(.DrugAllergy)
            }
            else if option.option == questionnaireNotesTypeAllergyFood{
                allergyTypeList.append(.FoodAllergy)
            }
            else if option.option == questionnaireNotesTypeAllergyEnvironment{
                allergyTypeList.append(.EnvironmentalAllergy)
            }
        })
        
        if allergyTypeList.contains(.DrugAllergy){
            drugAllergyView = WidgetContainerView(entryType: .Allergy, allergyType: .DrugAllergy, customModelList: drugAllergyList, isNoKnownChecked: feedbackPOJO.nkda, isAddShadow: addShadow, delegate: self, width: width)
            if let drugAllergyView{
                self.addArrangedSubview(drugAllergyView)
            }
        }
        
        if allergyTypeList.contains(.FoodAllergy){
            foodAllergyView = WidgetContainerView(entryType: .Allergy, allergyType: .FoodAllergy, customModelList: foodAllergyList, isNoKnownChecked: feedbackPOJO.nkfa, isAddShadow: addShadow, delegate: self, width: width)
            if let foodAllergyView{
                self.addArrangedSubview(foodAllergyView)
            }
        }
        
        if allergyTypeList.contains(.EnvironmentalAllergy){
            environmentalAllergyView = WidgetContainerView(entryType: .Allergy, allergyType: .EnvironmentalAllergy, customModelList: environmentalAllergyList, isNoKnownChecked: feedbackPOJO.nkea, isAddShadow: addShadow, delegate: self, width: width)
            if let environmentalAllergyView{
                self.addArrangedSubview(environmentalAllergyView)
            }
        }
        
        self.subviews.forEach { subviews in
            if let widgetView = subviews as? WidgetContainerView{
                if isDataEditAllowed{
                    widgetView.addButton.addTarget(self, action: #selector(onClickAddBtn), for: .touchUpInside)
                    widgetView.addButton.tag = tagNo
                    tagNo += 1
                    widgetView.tag = tagNo
                    tagNo += 1
                    btnToViewMap[widgetView.addButton.tag] = widgetView.tag
                }
            }
        }
        self.isUserInteractionEnabled = isDataEditAllowed
    }
    
    private func getWidgetContainer(allergyType: AllergyType?) -> WidgetContainerView?{
        if allergyType == .DrugAllergy{
            return drugAllergyView
        }
        else if allergyType == .FoodAllergy{
            return foodAllergyView
        }
        else if allergyType == .EnvironmentalAllergy{
            return environmentalAllergyView
        }
        return nil
    }
    
    private func getAllergyList(allergyType: AllergyType?) -> [AddWidgetCommonModel]{
        if allergyType == .DrugAllergy{
            return drugAllergyList
        }
        else if allergyType == .FoodAllergy{
            return foodAllergyList
        }
        else if allergyType == .EnvironmentalAllergy{
            return environmentalAllergyList
        }
        return []
    }
    
    //MARK: Action calls
    
    @objc private func onClickAddBtn(_ btn: UIButton){
        
        let containerViewTag = btnToViewMap[btn.tag] ?? -1
        if let containerView = self.viewWithTag(containerViewTag) as? WidgetContainerView{
            selectedAllergyType = containerView.allergyType
            delegate?.fetchAllergyList(allergyDelegate: self)
        }
    }
    
    func showActionSheet(entryList: [AddWidgetCommonModel], allergyType: AllergyType){
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let chooseExistingAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.questionnaire.widget.chooseFrom.title"), style: .default) { [self] (uialertaction) in
            self.presentQuestSelectEntry(entryList: entryList, allergyType: allergyType)
        }
        
        let addNewAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.addNew"), style: .default) { [self] (uialertaction) in
            presentQuestAddEntry(customModelList: getAllergyList(allergyType: allergyType), allergyType: allergyType, index: nil)
        }
        
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel) { (uialertaction) in
        }
        alertVC.addAction(chooseExistingAction)
        alertVC.addAction(addNewAction)
        alertVC.addAction(cancelAction)
        
        if let popover = alertVC.popoverPresentationController {
            if allergyType == .DrugAllergy{
                popover.sourceView = drugAllergyView?.addButton
            }
            else if allergyType == .FoodAllergy{
                popover.sourceView = foodAllergyView?.addButton
            }
            else if allergyType == .EnvironmentalAllergy{
                popover.sourceView = environmentalAllergyView?.addButton
            }
            popover.permittedArrowDirections = .up
        }
        alertVC.show()
    }
    
    private func presentQuestAddEntry(customModelList: [AddWidgetCommonModel], allergyType: AllergyType?, index: Int?){
        let vc = QuestAddEntryViewController(entryWidgetType: .Allergy, allergyType: allergyType, entryList: customModelList, index: index, delegate: self)
        vc.modalPresentationStyle = .custom
        delegate?.present(vc, animated: true, completion: nil)
    }
    
    private func presentQuestSelectEntry(entryList: [AddWidgetCommonModel],allergyType: AllergyType?){
        let vc = QuestAddEntryViewController(entryList: entryList, allergyType: allergyType, selectDelegate: self)
        vc.modalPresentationStyle = .custom
        delegate?.present(vc, animated: true, completion: nil)
    }
    
    //MARK: Delegate functions
    
    func patientAddedAllergies(allergies: [AllergiesList]) {
        
        if let selectedAllergyType{
            
            var entryList: [AddWidgetCommonModel] = []
            
            if !allergies.isEmpty{
                allergies.forEach({ allergiesList in
                    if allergiesList.allergyType == questionnaireNotesTypeAllergyDrug && selectedAllergyType == .DrugAllergy{
                        entryList.append(TransformUtil.transformAllergyToCustomModel(allergy: allergiesList, type: .DrugAllergy))
                    }
                    else if allergiesList.allergyType == questionnaireNotesTypeAllergyFood && selectedAllergyType == .FoodAllergy{
                        entryList.append(TransformUtil.transformAllergyToCustomModel(allergy: allergiesList, type: .FoodAllergy))
                    }
                    else if allergiesList.allergyType == questionnaireNotesTypeAllergyEnvironment && selectedAllergyType == .EnvironmentalAllergy{
                        entryList.append(TransformUtil.transformAllergyToCustomModel(allergy: allergiesList, type: .EnvironmentalAllergy))
                    }
                })
            }
            
            if entryList.isEmpty{
                let list = getAllergyList(allergyType: selectedAllergyType)
                presentQuestAddEntry(customModelList: list, allergyType: selectedAllergyType, index: nil)
            }
            else{
                showActionSheet(entryList: entryList, allergyType: selectedAllergyType)
            }
        }
        selectedAllergyType = nil
    }
    
    func onTapWidgetEntryView(customModelList: [AddWidgetCommonModel], allergyType: AllergyType?, index: Int?, tagNo: Int) {
        selectedViewTag = tagNo
        presentQuestAddEntry(customModelList: customModelList, allergyType: allergyType, index: index)
    }
    
    func questionnaireEditEntries(allergyType: AllergyType?, entryList: [AddWidgetCommonModel], index: Int?, isDeleted: Bool) {
        
        if allergyType == .DrugAllergy{
            drugAllergyList = entryList
        }
        else if allergyType == .FoodAllergy{
            foodAllergyList = entryList
        }
        else if allergyType == .EnvironmentalAllergy{
            environmentalAllergyList = entryList
        }
        
        if let selectedViewTag, let widgetView = self.viewWithTag(selectedViewTag) as? WidgetEntryView{
            if !isDeleted{
                widgetView.removeFromSuperview()
            }
            else if let parentView = widgetView.superview, let deleteIndex = index{
                parentView.subviews.forEach({ (view) in
                    if let view = view as? WidgetEntryView, let viewIndex = view.index{
                        if viewIndex == deleteIndex{
                            widgetView.removeFromSuperview()
                        }
                        else if viewIndex > deleteIndex{
                            view.index! -= 1
                        }
                    }
                })
            }
        }
        if let widgetContainer = getWidgetContainer(allergyType: allergyType){
            widgetContainer.customModelList = entryList
            if !isDeleted, let index{
                widgetContainer.addCustomModelEntry(customModelEntry: entryList[index], index: index)
            }
        }
        selectedViewTag = nil
    }
    
    func selectEntryList(allergyType: AllergyType?, addedList: [AddWidgetCommonModel]) {
        
        var entryList: [AddWidgetCommonModel] = []
        if allergyType == .DrugAllergy{
            drugAllergyList.append(contentsOf: addedList)
            entryList = drugAllergyList
        }
        else if allergyType == .FoodAllergy{
            foodAllergyList.append(contentsOf: addedList)
            entryList = foodAllergyList
        }
        else if allergyType == .EnvironmentalAllergy{
            environmentalAllergyList.append(contentsOf: addedList)
            entryList = environmentalAllergyList
        }
        
        if let widgetContainer = getWidgetContainer(allergyType: allergyType){
            widgetContainer.customModelList = entryList
            
            let indexList = Array(entryList.indices.suffix(addedList.count))
            indexList.forEach { (index) in
                widgetContainer.addCustomModelEntry(customModelEntry: entryList[index], index: index)
            }
        }
    }
    
    //MARK: GetAllergyList
    
    func getAllergyEntriesList() -> [IntakeQuestAllergyEntry] {
        
        var customModelList: [AddWidgetCommonModel] = []
        if !nkda{
            customModelList.append(contentsOf: drugAllergyList)
        }
        if !nkfa{
            customModelList.append(contentsOf: foodAllergyList)
        }
        if !nkea{
            customModelList.append(contentsOf: environmentalAllergyList)
        }
        if !customModelList.isEmpty{
            return customModelList.map { addWidgetCommonModel in
                return TransformUtil.transformCustomModelToAllergy(addWidgetCommonModel: addWidgetCommonModel)
            }
        }
        return []
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - PrescriptionWidgetView

class PrescriptionWidgetView: UIView, WidgetContainerActionDelegate, QuestAddEntryVCDelegate{
    
    private var widgetContainerView: WidgetContainerView? = nil
    private var customModelList: [AddWidgetCommonModel] = []
    private var selectedViewTag: Int? = nil
    
    private var entryType: QuestEntryWidgetType? = nil
    private weak var delegate: QuestionnaireAnswerViewController? = nil
    
    var nam: Bool{
        if entryType == .Medication{
            return widgetContainerView?.isNoKnownChecked ?? false
        }
        return false
    }
    
    init(entryType: QuestEntryWidgetType, feedbackPOJO: QuestionnaireEntryPOJO, addShadow: Bool, isDataEditAllowed: Bool, width: CGFloat, delegate: QuestionnaireAnswerViewController?) {
        super.init(frame: .zero)
        
        self.entryType = entryType
        self.delegate = delegate
        
        var isNoKnownChecked: Bool = false
        if entryType == .Medication{
            customModelList = feedbackPOJO.questionnaireMedicationList.map { medicationEntries in
                return TransformUtil.transformIntakeEntriesToCustomModel(intakeEntries: medicationEntries)
            }
            isNoKnownChecked = feedbackPOJO.nam
        }
        else if entryType == .Supplement{
            customModelList = feedbackPOJO.questionnaireSupplementList.map { medicationEntries in
                return TransformUtil.transformIntakeEntriesToCustomModel(intakeEntries: medicationEntries)
            }
        }
        
        widgetContainerView = WidgetContainerView(entryType: entryType, customModelList: customModelList, isNoKnownChecked: isNoKnownChecked, isAddShadow: addShadow, delegate: self, width: width)
        
        if let widgetContainerView{
            
            self.addSubview(widgetContainerView)
            
            widgetContainerView.setLeft(offSet: 0)
            widgetContainerView.setRight(offSet: 0)
            widgetContainerView.setTop(offSet: 0)
            widgetContainerView.setBottom(offSet: 0)
            
            if isDataEditAllowed{
                widgetContainerView.addButton.addTarget(self, action: #selector(onClickAddBtn), for: .touchUpInside)
            }
        }
        self.isUserInteractionEnabled = isDataEditAllowed
    }
    
    @objc private func onClickAddBtn(_ btn: UIButton){
        if let widgetContainerView{
            presentQuestAddEntryVC(customModelList: widgetContainerView.customModelList, index: nil)
        }
    }
    
    private func presentQuestAddEntryVC(customModelList: [AddWidgetCommonModel], index: Int?){
        let vc = QuestAddEntryViewController(entryWidgetType: entryType, allergyType: nil, entryList: customModelList, index: index, delegate: self)
        vc.modalPresentationStyle = .custom
        delegate?.present(vc, animated: true, completion: nil)
    }
    
    //MARK: Delegate functions
    
    func onTapWidgetEntryView(customModelList: [AddWidgetCommonModel], allergyType: AllergyType?, index: Int?, tagNo: Int) {
        selectedViewTag = tagNo
        presentQuestAddEntryVC(customModelList: customModelList, index: index)
    }
    
    func questionnaireEditEntries(allergyType: AllergyType?, entryList: [AddWidgetCommonModel], index: Int?, isDeleted: Bool) {
        
        customModelList = entryList
        
        if let selectedViewTag, let widgetView = self.viewWithTag(selectedViewTag) as? WidgetEntryView{
            if !isDeleted{
                widgetView.removeFromSuperview()
            }
            else if let parentView = widgetView.superview, let deleteIndex = index{
                parentView.subviews.forEach({ (view) in
                    if let view = view as? WidgetEntryView, let viewIndex = view.index{
                        if viewIndex == deleteIndex{
                            widgetView.removeFromSuperview()
                        }
                        else if viewIndex > deleteIndex{
                            view.index! -= 1
                        }
                    }
                })
            }
        }
        widgetContainerView?.customModelList = entryList
        if !isDeleted, let index{
            widgetContainerView?.addCustomModelEntry(customModelEntry: entryList[index], index: index)
        }
        selectedViewTag = nil
    }
    
    //MARK: getPrescriptionList
    
    func getPrescriptionList() -> [IntakeQuestPrecriptionEntry]{
        
        var prescriptionList: [IntakeQuestPrecriptionEntry] = []
        
        if !customModelList.isEmpty && ((!nam && entryType == .Medication) || entryType == .Supplement){
            prescriptionList = customModelList.map({ addWidgetCommonModel in
                return TransformUtil.transformCustomModelToIntakeEntries(addWidgetCommonModel: addWidgetCommonModel)
            })
        }
        return prescriptionList
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - WidgetContainerView

protocol WidgetContainerActionDelegate: AnyObject{
    func onTapWidgetEntryView(customModelList: [AddWidgetCommonModel], allergyType: AllergyType?, index: Int?, tagNo: Int)
}

class WidgetContainerView: UIView {
    
    private let containerStackView = UIStackView()
    private let titleView = UIView()
    private let titleLabel = UILabel()
    fileprivate let addButton = UIButton()
    private lazy var noknownBtn = UIButton()
    private let stackView = UIStackView()
    
    fileprivate var entryType: QuestEntryWidgetType? = nil
    fileprivate var allergyType: AllergyType? = nil
    fileprivate var customModelList: [AddWidgetCommonModel] = []
    private weak var delegate: WidgetContainerActionDelegate? = nil
    private var width: CGFloat? = nil
    
    private let DISABLED_BTN_COLOR: UInt = 0xA9A9A9FF
    
    fileprivate var isNoKnownChecked: Bool {
        return noknownBtn.isSelected
    }
    
    init(entryType: QuestEntryWidgetType, allergyType: AllergyType? = nil, customModelList: [AddWidgetCommonModel], isNoKnownChecked: Bool, isAddShadow: Bool, delegate: WidgetContainerActionDelegate, width: CGFloat?){
        super.init(frame: .zero)
        
        self.entryType = entryType
        self.allergyType = allergyType
        self.customModelList = customModelList
        self.delegate = delegate
        self.width = width
        
        if isAddShadow{
            self.addShadowAndCornerRadius(.SMALL)
        }
        
        self.addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(addButton)
        
        titleLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        
        addButton.setProperties(titleStrKey: "com.charmphr.action.add", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: THEME_COLOR)
        addButton.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: DISABLED_BTN_COLOR), for: .disabled)
        
        if entryType != .Supplement{
            
            let noknownBtnView = UIView()
            containerStackView.addArrangedSubview(noknownBtnView)
            noknownBtnView.addSubview(noknownBtn)
            
            noknownBtn.setImage(UIImage(named: "CheckboxUnselected"), for: .normal)
            noknownBtn.setImage(UIImage(named: "CheckboxSelected"), for: .selected)
            noknownBtn.setProperties(titleStrKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
            noknownBtn.addTarget(self, action: #selector(onSelectNoKnownBtn), for: .touchUpInside)
            noknownBtn.isSelected = isNoKnownChecked
            addButton.isEnabled = !isNoKnownChecked
            noknownBtn.setInsets(imageTitlePadding: CARD_PADDING)
                        
            noknownBtn.setLeft(offSet: CARD_PADDING)
            noknownBtn.setTop(offSet: 0)
            noknownBtn.setBottom(offSet: 0)
            
            containerStackView.setCustomSpacing(SPACING_12, after: noknownBtnView)
        }
        containerStackView.addArrangedSubview(stackView)
        
        if entryType == .Allergy, let allergyType{
            var noKnownTitle = getString(key: "com.charmphr.questionnairevc.entryWidget.noKnown.title")
            if allergyType == .DrugAllergy{
                titleLabel.text = getString(key: "com.charmphr.questionnairevc.drugAllergies.title")
            }
            else if allergyType == .FoodAllergy{
                titleLabel.text = getString(key: "com.charmphr.questionnairevc.foodAllergies.title")
            }
            else if allergyType == .EnvironmentalAllergy{
                titleLabel.text = getString(key: "com.charmphr.questionnairevc.environmentAllergies.title")
            }
            noKnownTitle.append(titleLabel.text ?? "")
            
            noknownBtn.setTitle(noKnownTitle, for: .normal)
        }
        else if entryType == .Medication{
            titleLabel.text = getString(key: "com.charmphr.questionnairevc.medication.title", with: ["s"])
            noknownBtn.setTitle(getString(key: "com.charmphr.questionnairevc.entryWidget.noActiveMedication.title"), for: .normal)
        }
        else if entryType == .Supplement{
            titleLabel.text = getString(key: "com.charmphr.questionnairevc.supplement.title", with: ["s"])
        }
        
        containerStackView.axis = .vertical
        containerStackView.spacing = 0
        containerStackView.alignment = .fill
        
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        
        containerStackView.setLeft(offSet: 0)
        containerStackView.setRight(offSet: 0)
        containerStackView.setTop(offSet: 0)
        containerStackView.setBottom(offSet: 0)
        
        titleLabel.setLeft(offSet: CARD_PADDING)
        titleLabel.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: addButton, relatedAttribute: .left)
        titleLabel.setCenterY(view: addButton)
        
        addButton.setRight(offSet: 0)
        addButton.setTop(offSet: 0)
        addButton.setBottom(offSet: 0)
        addButton.setWidth(constant: 50)
        addButton.setHeight(constant: 44)
        
        for i in 0 ..< customModelList.count{
            let addWidgetCommonModel = customModelList[i]
            addCustomModelEntry(customModelEntry: addWidgetCommonModel, index: i)
        }
    }
    
    fileprivate func addCustomModelEntry(customModelEntry: AddWidgetCommonModel, index: Int){
        let widgetEntryView = WidgetEntryView(addWidgetCommonModel: customModelEntry, isHideRightArrow: false, index: index, width: width)
        widgetEntryView.tag = tagNo
        tagNo += 1
        
        if stackView.subviews.count - 1 >= index{
            stackView.insertArrangedSubview(widgetEntryView, at: index)
        }
        else if stackView.subviews.count - 1 >= 0{
            stackView.insertArrangedSubview(widgetEntryView, at: stackView.subviews.count - 1)
        }
        else{
            stackView.insertArrangedSubview(widgetEntryView, at: 0)
        }
        
        widgetEntryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapWidgetEntryView)))
    }
    
    @objc private func onTapWidgetEntryView(_ sender: UITapGestureRecognizer){
        if let view = sender.view as? WidgetEntryView{
            delegate?.onTapWidgetEntryView(customModelList: customModelList, allergyType: allergyType, index: view.index, tagNo: view.tag)
        }
    }
    
    @objc private func onSelectNoKnownBtn(){
                
        noknownBtn.isSelected = !noknownBtn.isSelected
        addButton.isEnabled = !noknownBtn.isSelected
        
        containerStackView.removeConstraint(attribute: .bottom)
        if noknownBtn.isSelected{
            containerStackView.setBottom(offSet: -SPACING_12)
        }
        else{
            containerStackView.setBottom(offSet: 0)
        }
        
        UIView.animate(withDuration: 0.3) { [self] in
            if noknownBtn.isSelected{
                stackView.isHidden = true
                stackView.layer.opacity = 0
            }
            else{
                stackView.isHidden = false
                stackView.layer.opacity = 1
            }
            self.layoutIfNeeded()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - WidgetEntryView

protocol WidgetEntryViewDelegate: AnyObject{
    func selectActionOnWidget(index: Int, isSelected: Bool)
}

class WidgetEntryView: UIView{
    
    lazy var checkBoxBtn = UIButton()
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private var severityView: SeverityView? = nil
    private var descriptionLabel: UILabel? = nil
    private lazy var rightArrowBtn = UIButton()
    private weak var delegate: WidgetEntryViewDelegate? = nil
    
    var addWidgetCommonModel: AddWidgetCommonModel? = nil
    var index: Int? = nil
    
    var isSelected: Bool = false{
        didSet{
            checkBoxBtn.isSelected = isSelected
        }
    }
    
    init(addWidgetCommonModel: AddWidgetCommonModel, isShowCheckBox: Bool = false, isHideRightArrow: Bool, index: Int, width: CGFloat?, delegate: WidgetEntryViewDelegate? = nil){
        super.init(frame: .zero)
        
        self.index = index
        self.delegate = delegate
        var balanceWidth: CGFloat = width ?? 0
        
        self.addSubview(containerView)
        containerView.addSubview(nameLabel)
        
        containerView.setTop(offSet: CARD_PADDING)
        containerView.setBottom(offSet: -CARD_PADDING)
                
        if isShowCheckBox{
            self.addSubview(checkBoxBtn)
            checkBoxBtn.setImage(UIImage(named: "CheckboxUnselected"), for: .normal)
            checkBoxBtn.setImage(UIImage(named: "CheckboxSelected"), for: .selected)
                        
            let btnSize: CGFloat = 40
            checkBoxBtn.setLeft(offSet: PADDING_6)
            checkBoxBtn.setTop(offSet: 0)
            checkBoxBtn.setWidth(constant: btnSize)
            checkBoxBtn.setHeight(constant: btnSize)
            checkBoxBtn.addTarget(self, action: #selector(onTapCheckBoxBtn), for: .touchUpInside)
            
            containerView.setLeftRelatedToView(offSet: 0, relatedView: checkBoxBtn, relatedAttribute: .right)
            
            balanceWidth -= btnSize
        }
        else{
            containerView.setLeft(offSet: CARD_PADDING)
            balanceWidth -= CARD_PADDING
        }
        if isHideRightArrow{
            containerView.setRight(offSet: -CARD_PADDING)
            balanceWidth -= CARD_PADDING
        }
        else{
            self.addTopBorder(color: UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR))
            self.addSubview(rightArrowBtn)
            rightArrowBtn.setImage(UIImage(named: "ArrowRight"), for: .normal)
            
            rightArrowBtn.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: containerView, relatedAttribute: .right)
            rightArrowBtn.setRight(offSet: -CARD_PADDING)
            rightArrowBtn.setCenterY(view: containerView)
            rightArrowBtn.setWidth(constant: BTN_SIZE_24)
            rightArrowBtn.setHeight(constant: BTN_SIZE_24)
            
            balanceWidth -= (BTN_SIZE_24 + CARD_PADDING)
        }
        
        nameLabel.setProperties(textKey: addWidgetCommonModel.name ?? "", fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
        
        nameLabel.setLeft(offSet: 0)
        nameLabel.setTop(offSet: 0)
        
        if let severity = addWidgetCommonModel.severity{
            severityView = SeverityView(severity: severity)
            if let severityView{
                containerView.addSubview(severityView)
                
                severityView.setLeftRelatedToView(offSet: SPACING_12, relatedView: nameLabel, relatedAttribute: .right)
                severityView.setTop(offSet: 0)
                severityView.setWidth(constant: severityView.viewWidth)
                severityView.setHeight(constant: severityView.viewHeight)
                
                balanceWidth -= (SPACING_12 + severityView.viewWidth)
            }
            
            let labelWidth = nameLabel.sizeThatFits(CGSize(width: 1000, height: 50)).width
            
            if labelWidth > balanceWidth{
                nameLabel.setWidth(constant: balanceWidth)
            }
            else{
                nameLabel.setWidth(constant: labelWidth)
            }
        }
        else{
            nameLabel.removeConstraint(attribute: .right)
            nameLabel.setRight(offSet: 0)
        }
        
        if let description = addWidgetCommonModel.description, description.isNotBlank(){
            descriptionLabel = UILabel()
            if let descriptionLabel{
                containerView.addSubview(descriptionLabel)
                
                descriptionLabel.setProperties(textKey: description, fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
                descriptionLabel.numberOfLines = 0
                
                descriptionLabel.setLeft(offSet: 0)
                descriptionLabel.setRight(offSet: 0)
                descriptionLabel.setTopRelatedToView(offSet: PADDING_8, relatedView: nameLabel, relatedAttribute: .bottom)
                descriptionLabel.setBottom(offSet: 0)
            }
        }
        else{
            nameLabel.removeConstraint(attribute: .bottom)
            nameLabel.setBottom(offSet: 0)
        }
    }
    
    @objc func onTapCheckBoxBtn(_ btn: UIButton){
        btn.isSelected.toggle()
        if let index{
            delegate?.selectActionOnWidget(index: index, isSelected: btn.isSelected)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SeverityView: UIView{
    
    private let label = UILabel()
    private let PADDING: CGFloat = 4
    
    init(severity: Severity){
        super.init(frame: .zero)
        
        self.addCornerRadius(.SMALL)        
        self.addSubview(label)
        
        label.text = severity.rawValue
        label.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        
        label.setLeft(offSet: PADDING_4)
        label.setRight(offSet: -PADDING_4)
        label.setTop(offSet: 0)
        label.setBottom(offSet: 0)
        
        if severity == .Mild{
            self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: MILD_BG_COLOR)
            label.textColor = UIColorFromRGB(rgbValueWithAlpha: MILD_TEXT_COLOR)
        }
        else if severity == .Moderate{
            self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: MODERATE_BG_COLOR)
            label.textColor = UIColorFromRGB(rgbValueWithAlpha: MODERATE_TEXT_COLOR)
        }
        else if severity == .Severe{
            self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEVERE_BG_COLOR)
            label.textColor = UIColorFromRGB(rgbValueWithAlpha: SEVERE_TEXT_COLOR)
        }
    }
    
    var viewWidth: CGFloat{
        return label.sizeThatFits(CGSize(width: 500, height: 200)).width + (PADDING_4 * 2)
    }
    
    var viewHeight: CGFloat{
        return label.sizeThatFits(CGSize(width: 500, height: 200)).height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum Severity: String{
    
    case Severe = "Severe"
    case Moderate = "Moderate"
    case Mild = "Mild"
}


//MARK: - SignatureView

class SignatureView: UIView {
    
    let stackView = UIStackView()
    let signatureImgView = UIImageView()
    let signatureLabel = UIButton()
    let btnLayout = UIView()
    let editOrSaveBtn = UIButton()
    let activityIndicator = UIActivityIndicatorView()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(stackView)
        self.addSubview(activityIndicator)
        
        stackView.setLeft(offSet: 0)
        stackView.setRight(offSet: 0)
        stackView.setTop(offSet: 0)
        stackView.setBottom(offSet: 0)
        
        activityIndicator.color = .gray
        
        let signatureLayout = UIView()
        signatureLayout.addSubview(signatureImgView)
        signatureLayout.addSubview(signatureLabel)
        stackView.addArrangedSubview(signatureLayout)
        stackView.addArrangedSubview(btnLayout)
        
        btnLayout.addSubview(editOrSaveBtn)
        
        activityIndicator.setCenterX(view: signatureImgView)
        activityIndicator.setCenterY(view: signatureImgView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        
        editOrSaveBtn.setProperties(titleStrKey: getString(key: "com.charmphr.questionnairevc.signature.edit.txt"), fontsize: FONT_SIZE_VALUE_LABEL, weight: .regular, fontcolor: THEME_COLOR)

        signatureLabel.setProperties(titleStrKey: "com.charmphr.questionnairevc.signature.placeholder", fontsize: FONT_SIZE_VALUE_LABEL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
        
        //signatureLabel.textAlignment = .center
        
        signatureLayout.setLeft(offSet: 0)
        signatureLayout.setRight(offSet: 0)
        
        signatureImgView.setLeft(offSet: 0)
        signatureImgView.setRight(offSet: 0)
        signatureImgView.setTop(offSet: 0)
        signatureImgView.setBottom(offSet: 0)
        signatureImgView.setHeight(constant: 150)
        
        signatureLabel.setTop(offSet: 0)
        signatureLabel.setBottom(offSet: 0)
        signatureLabel.setLeft(offSet: 0)
        signatureLabel.setRight(offSet: 0)
        signatureLabel.setHeight(constant: 150)

        btnLayout.setLeft(offSet: 0)
        btnLayout.setRight(offSet: 0)
       
        editOrSaveBtn.setRight(offSet: 0)
        editOrSaveBtn.setWidth(constant: 104)
        editOrSaveBtn.setHeight(constant: 44)
        editOrSaveBtn.setTop(offSet: 0)
        editOrSaveBtn.setBottom(offSet: 0)
    }
    
    func showActivityIndicator(){
        self.bringSubviewToFront(activityIndicator)
        signatureLabel.isHidden = true
        self.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(){
        signatureLabel.isHidden = false
        self.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AddWidgetCommonModel{
    
    var name: String? = nil
    var description: String? = nil
    var severity: Severity? = nil
    var type: AllergyType? = nil
}
