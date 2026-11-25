//
//  BookAppointmentView.swift
//  phr
//
//  Created by Raghul D on 22/04/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit
import Razorpay
import JTAppleCalendar


let bookAppointmentFontSize = FONT_SIZE_LARGE

class BookAppointmentView: UIView , UITextViewDelegate{
    
    
    let scrollView = TPKeyboardAvoidingScrollView()
    
    private let bookAppStackView = UIStackView()
    
    let practiceCard: UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.center
        stackView.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
        //stackView.spacing = 7
        
        return stackView
    }()
    
    let practiceView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    let facilityView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    let memberView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)

    let onlineAppointmentCard: UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.center
        stackView.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
        //stackView.spacing = 7
        
        return stackView
    }()
    
    
    let visitTypeView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    let slotDateView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true, icon: "Calendar")
    let slotPrefView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    let slotTimeView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    
    
    let calendarMonthView = JTACMonthView()
    let calendarView = UIView()

    let errorMsgLabel = UILabel()
    
    
    let slotNoDataView = UIView()
    
    let slotNoDataLabel = UILabel()
    
    let calendarMonthLabel = UILabel()
    
    let calendarLeftArrow = UIButton(type: .custom)
    let calendarRightArrow = UIButton(type: .custom)

    
    let waitlistCheckbox = UIButton(type: .custom)
    
    
    let calendarSeparator = UIView()

    private var slotNoDataViewHeightConstraint: NSLayoutConstraint? = nil
    
    
    let requestAppointmentCard: UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = .vertical
        stackView.alignment = .fill
        
        return stackView
    }()
    
    let datePrefView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    let timePrefView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
   
    let otherDetailsCard: UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = .vertical
        stackView.alignment = .fill
        
        return stackView
    }()
    
    let appointmentTypeView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    
    
    let paymentView = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)

    let reasonView = UIView()
    let reasonLabel = UILabel()
    let reasonTextView = UITextView()
    let timezoneLabel = UILabel()
    
    let activityIndicator = UIActivityIndicatorView()
    
    let errorPage = NoDataView()
    
    let slotWeekDayView: UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.center
        stackView.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
        //stackView.spacing = 7
        
        return stackView
    }()

    
    init(){
        super.init(frame: .zero)
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        setSubViews()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubViews(){
        
        addSubview(scrollView)
        scrollView.addSubview(bookAppStackView)
        bookAppStackView.addArrangedSubview(practiceCard)
        
        practiceCard.addArrangedSubview(practiceView)
        practiceCard.addArrangedSubview(facilityView)
        practiceCard.addArrangedSubview(memberView)
        
        bookAppStackView.addArrangedSubview(timezoneLabel)
        
        bookAppStackView.addArrangedSubview(onlineAppointmentCard)
        
        onlineAppointmentCard.addArrangedSubview(visitTypeView)
        onlineAppointmentCard.addArrangedSubview(slotDateView)
        onlineAppointmentCard.addArrangedSubview(calendarView)
        
        calendarView.addSubview(calendarLeftArrow)
        calendarView.addSubview(calendarRightArrow)
        calendarView.addSubview(calendarMonthLabel)
        calendarView.addSubview(slotWeekDayView)
        calendarView.addSubview(calendarMonthView)
        onlineAppointmentCard.addArrangedSubview(calendarSeparator)
        onlineAppointmentCard.addArrangedSubview(slotPrefView)
        onlineAppointmentCard.addArrangedSubview(slotTimeView)
        
        onlineAppointmentCard.addArrangedSubview(slotNoDataView)
        
        slotNoDataView.addSubview(slotNoDataLabel)
        slotNoDataView.addSubview(waitlistCheckbox)
        
        
        bookAppStackView.addArrangedSubview(requestAppointmentCard)
        
        requestAppointmentCard.addArrangedSubview(datePrefView)
        requestAppointmentCard.addArrangedSubview(timePrefView)
        
        bookAppStackView.addArrangedSubview(otherDetailsCard)
        
        otherDetailsCard.addArrangedSubview(appointmentTypeView)
        otherDetailsCard.addArrangedSubview(reasonView)
        otherDetailsCard.addArrangedSubview(paymentView)

        reasonView.addSubview(reasonLabel)
        reasonView.addSubview(reasonTextView)

       
        addSubview(activityIndicator)
        addSubview(errorPage)
        
        bookAppStackView.addArrangedSubview(errorMsgLabel)
        
        let lastSpacing = UIView()
        lastSpacing.setHeight(constant: 20)
        bookAppStackView.addArrangedSubview(lastSpacing)
        
        setProperties()
        addConstraints()
        
    }
    
    func setProperties(){
        
        setBackgroundColor(bgColor: APPLICATION_BACKGROUND_COLOR)
        
        bookAppStackView.translatesAutoresizingMaskIntoConstraints = false
        bookAppStackView.axis = .vertical
        bookAppStackView.spacing = 20
        bookAppStackView.distribution = .fill
        bookAppStackView.alignment = .fill
        bookAppStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: X_SPACE, bottom: 0, trailing: X_SPACE)
        bookAppStackView.isLayoutMarginsRelativeArrangement = true

        slotWeekDayView.distribution = .fillEqually
        
        practiceCard.addShadowAndCornerRadius(.SMALL)
        practiceView.hideSeparator()
        facilityView.hideSeparator()
        memberView.hideSeparator()
        timePrefView.hideSeparator()
        visitTypeView.hideSeparator()
        
        practiceView.textField?.isUserInteractionEnabled = false
        facilityView.textField?.isUserInteractionEnabled = false
        memberView.textField?.isUserInteractionEnabled = false
        visitTypeView.textField?.isUserInteractionEnabled = false
        datePrefView.textField?.isUserInteractionEnabled = false
        timePrefView.textField?.isUserInteractionEnabled = false
        slotDateView.textField?.isUserInteractionEnabled = false
        slotPrefView.textField?.isUserInteractionEnabled = false
        slotTimeView.textField?.isUserInteractionEnabled = false
        appointmentTypeView.textField?.isUserInteractionEnabled = false
        paymentView.textField?.isUserInteractionEnabled = false

        practiceView.keyLabel.text = getString(key: "com.charmphr.common.Practice")
        facilityView.keyLabel.text = getString(key: "com.charmphr.facilityName.title")
        memberView.keyLabel.text = getString(key: "com.charmphr.provider.title")
        visitTypeView.keyLabel.text = getString(key: "com.charmphr.appointments.visitType.title")
        
        timezoneLabel.font = UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .regular)
        timezoneLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUM_LIGHT)
        timezoneLabel.numberOfLines = 3
            //timeZoneLabelView.addSubview(timezoneLabel)
        
        onlineAppointmentCard.addShadowAndCornerRadius(.SMALL)
        
        calendarMonthView.backgroundColor = UIColor.white
        calendarMonthView.scrollDirection = .horizontal
        calendarMonthView.scrollingMode = .stopAtEachCalendarFrame
        calendarMonthView.showsHorizontalScrollIndicator = false
        
        calendarMonthLabel.font = UIFont.systemFont(ofSize: 17, Weight: .semibold)
        calendarMonthLabel.textColor = .black
        
        slotDateView.keyLabel.text = getString(key: "com.charmphr.appointments.slotDate.title")

        slotPrefView.keyLabel.text = getString(key: "com.charmphr.appointments.slotPref.title")
        
        slotTimeView.keyLabel.text = getString(key: "com.charmphr.appointments.slotTime.title")
        slotTimeView.hideSeparator()
        
        requestAppointmentCard.addShadowAndCornerRadius(.SMALL)
        
        datePrefView.keyLabel.text = getString(key: "com.charmphr.appointments.datePref.title")
        datePrefView.addCornerRadius(.SMALL)
        
        timePrefView.keyLabel.text = getString(key: "com.charmphr.appointments.timePref.title")
        timePrefView.addCornerRadius(.SMALL)
        
        calendarSeparator.setBackgroundColor(bgColor: bookAppointmentSeparatorColor)
        
        otherDetailsCard.addShadowAndCornerRadius(.SMALL)
        
        appointmentTypeView.keyLabel.text = getString(key: "com.charmphr.appointments.type.title")
        paymentView.keyLabel.setText(key: "com.charmphr.appointments.payment.info")
        
        reasonView.backgroundColor = .white
        reasonView.addCornerRadius(.SMALL)
        reasonLabel.font = UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .regular)
        reasonLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        reasonLabel.text = getString(key: "com.charmphr.appointments.reason.title")
        
        reasonTextView.font = UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .regular)
        reasonTextView.textColor = .black
        reasonTextView.delegate = self
        reasonTextView.addCornerRadius(.SMALL)
        reasonTextView.layer.borderWidth = 1
        reasonTextView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_VIEW_BORDER_COLOR).cgColor

        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        errorPage.setImage(enum: .oops)
        errorPage.setTitle(string: getString(key: "com.charmphr.common.somethingWentWrong"))
        errorPage.setMessage(string: getString(key: "com.charmphr.common.somethingWentWrong.msg"))
        
        errorMsgLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        errorMsgLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
        errorMsgLabel.textAlignment = .center
        
        slotNoDataView.backgroundColor = .white

        slotNoDataLabel.setProperties(textKey: "com.charmphr.appointments.no_slots_available", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        
        waitlistCheckbox.setTitle(getString(key: "com.charmphr.appointments.waitlist.info"), for: .normal)
        waitlistCheckbox.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        waitlistCheckbox.setTitleColor(.black, for: .normal)
        waitlistCheckbox.addTarget(self, action: #selector(waitlistCheckboxClicked(btn:)), for: .touchUpInside)
        
        waitlistCheckbox.setImage(#imageLiteral(resourceName: "CheckboxUnselected"), for: .normal)
        waitlistCheckbox.setImage(#imageLiteral(resourceName: "CheckboxSelected"), for: .selected)
        
        calendarLeftArrow.setImage(#imageLiteral(resourceName: "calendarLeftIcon"), for: .normal)
        calendarRightArrow.setImage(#imageLiteral(resourceName: "calendarRightIcon"), for: .normal)
        
//        calendarRightArrow.backgroundColor = .yellow
//        calendarLeftArrow.backgroundColor = .orange

        
        waitlistCheckbox.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        waitlistCheckbox.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        waitlistCheckbox.contentEdgeInsets = UIEdgeInsets(top: 11, left: 20, bottom: 11, right: 10)
        
        paymentView.isHidden = true
        
        addWeekDays()
    }
    
    func addConstraints() {
       
        bookAppStackView.setTop(offSet: 0)
        bookAppStackView.setBottom(offSet: 0)
        bookAppStackView.setLeft(offSet: 0)
        bookAppStackView.setRight(offSet: 0)
        // Edge pins inside a scroll view only set content bounds; this ties the width to the visible area.
        bookAppStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true

        scrollView.setSafeAreaTop(offset: 0)
        scrollView.setSafeAreaLeft(offset: 0)
        scrollView.setSafeAreaRight(offset: 0)
        scrollView.setSafeAreaBottom(offset: 0)

        practiceView.setLeft(offSet: 0)
        practiceView.setRight(offSet: 0)
        
        facilityView.setLeft(offSet: 0)
        facilityView.setRight(offSet: 0)
        
        memberView.setLeft(offSet: 0)
        memberView.setRight(offSet: 0)
        
        visitTypeView.setLeft(offSet: 0)
        visitTypeView.setRight(offSet: 0)
        
        slotDateView.setLeft(offSet: 0)
        slotDateView.setRight(offSet: 0)
        
        calendarMonthView.setLeft(offSet: 0)
        calendarMonthView.setRight(offSet: 0)
       // calendarMonthView.setHeight(constant: 200)
        calendarMonthView.setTopRelatedToView(offSet: 0, relatedView: slotWeekDayView, relatedAttribute: .bottom)
        calendarMonthView.setBottom(offSet: 0)
        
        calendarSeparator.setLeft(offSet: 0)
        calendarSeparator.setRight(offSet: 0)
        calendarSeparator.setHeight(constant: SEPARATOR_HEIGHT)
        
        calendarMonthView.minimumInteritemSpacing = 2
        calendarMonthView.minimumLineSpacing = 5 


        calendarView.setLeft(offSet: 0)
        calendarView.setRight(offSet: 0)
        calendarView.setHeight(constant: 311)
        
        
        slotWeekDayView.setLeft(offSet: 0)
        slotWeekDayView.setRight(offSet: 0)
        slotWeekDayView.setTopRelatedToView(offSet: 10, relatedView: calendarMonthLabel, relatedAttribute: .bottom)
    
        
        calendarMonthLabel.setTop(offSet: 10)
        calendarMonthLabel.setLeft(offSet: 10)
        calendarMonthLabel.setRightRelatedToView(offSet: -5, relatedView: calendarLeftArrow , relatedAttribute: .left)
        
        calendarRightArrow.setRight(offSet: -8)
        calendarRightArrow.setTopRelatedToView(offSet: 0, relatedView: calendarMonthLabel, relatedAttribute: .top)
        calendarRightArrow.setWidth(constant: 23)
        calendarRightArrow.setHeight(constant: 23)
        
        calendarLeftArrow.setWidth(constant: 23)
        calendarLeftArrow.setHeight(constant: 23)
        calendarLeftArrow.setTopRelatedToView(offSet: 0, relatedView: calendarMonthLabel, relatedAttribute: .top)
        calendarLeftArrow.setRightRelatedToView(offSet: -5, relatedView: calendarRightArrow , relatedAttribute: .left)
        
        
        slotPrefView.setLeft(offSet: 0)
        slotPrefView.setRight(offSet: 0)
        
        slotTimeView.setLeft(offSet: 0)
        slotTimeView.setRight(offSet: 0)
        
        reasonLabel.setTop(offSet: Y_SPACE)
        reasonLabel.setLeft(offSet: 10)
        reasonLabel.setRight(offSet: -10)
        reasonLabel.setBottomRelatedToView(offSet: -5.5, relatedView: reasonTextView, relatedAttribute: .top)
        
        reasonTextView.setLeft(offSet: 10)
        reasonTextView.setRight(offSet: -10)
        reasonTextView.setBottom(offSet: -Y_SPACE)
        reasonTextView.setHeight(constant: 50, relatedBy: .greaterThanOrEqual)
        
        errorMsgLabel.setHeight(constant: 50)
        
       // errorPage.equalsTheContainerView()
        
        errorPage.setLeft(offSet: 0)
        errorPage.setRight(offSet: 0)
        errorPage.setCenterY()
        
       // slotNoDataView.setBackgroundColor(bgColor: TEXT_COLOR_RED)
        slotNoDataView.setLeft(offSet: 0)
        slotNoDataView.setRight(offSet: 0)
        
        slotNoDataLabel.setCenterX()
        slotNoDataLabel.setTop(offSet: 20)
        
        waitlistCheckbox.setCenterX()
        waitlistCheckbox.setTopRelatedToView(offSet: 0, relatedView: slotNoDataLabel, relatedAttribute: .bottom)
        waitlistCheckbox.setBottom(offSet: -20)
        slotNoDataViewHeightConstraint = waitlistCheckbox.setAndReturnHeight(constant: 40)

        hideWaitlistView()
        
        //slotNoDataViewHeightConstraint?.constant = 0
        //waitlistCheckbox.isHidden = true
        
        errorPage.isHidden = true
    }
    
    private func addWeekDays(){
        
        let calendar = Calendar(identifier: .gregorian)
        let days:[String] = calendar.shortWeekdaySymbols

        days.forEach{ day in
            
            let dayLabel = UILabel()
            dayLabel.font = UIFont.systemFont(ofSize: 16, Weight: .semibold)
            dayLabel.setTextColor(fontcolor: TEXT_COLOR_LIGHT)
            dayLabel.text = day
            dayLabel.textAlignment = .center
            
            slotWeekDayView.addArrangedSubview(dayLabel)

            dayLabel.setTop(offSet: 0)
            dayLabel.setBottom(offSet: 0)
        }
    
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 1000
    }
    
    func showWaitlistView() {
        slotNoDataViewHeightConstraint?.constant = 40
        waitlistCheckbox.isHidden = false
        
        waitlistCheckbox.isSelected = false
    }
    
    func hideWaitlistView() {
        slotNoDataViewHeightConstraint?.constant = 0
        waitlistCheckbox.isHidden = true
    }
    
    func showActivityIndicator(hideView:Bool = false)
    {
        if hideView {
            scrollView.isHidden = true
        }
        self.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator()
    {
        
        if scrollView.isHidden {
            scrollView.isHidden = false
        }
        
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true
    }
    
    func resetCompleteData(localizedKey: String , showFacility: Bool = false){
        hideActivityIndicator()
        if showFacility {
            facilityView.isHidden = false
        }
        else{
            facilityView.isHidden = true
        }
        
        memberView.isHidden = true
        
        resetAppointmentData(localizedKey: localizedKey)
    }
    
    func resetAppointmentData(localizedKey: String) {
        
        onlineAppointmentCard.isHidden = true
        otherDetailsCard.isHidden = true
        requestAppointmentCard.isHidden = true
        timezoneLabel.isHidden = true
    
        showErrorMsg(localizedKey: localizedKey)
           
    }
    
    func showErrorMsg(localizedKey: String) {
        errorMsgLabel.isHidden = false
        errorMsgLabel.setText(key: localizedKey)
    }
    
    func hideErrorMsg(){
        errorMsgLabel.isHidden = true
    }
    
    @objc func waitlistCheckboxClicked(btn: UIButton){
        btn.isSelected = !btn.isSelected
    }
}


class TextFieldLabelItemView: UIView {
    
    let keyLabel = UILabel()
    var valueLabel:UILabel? = nil
    var textField: MDTextField? = nil
    var arrowImageView: UIImageView? = nil
    
    var separator = UIView()
    var isArrowImageNeeded = true
    var isTextFieldShouldBeShown = false
    var icon = ""
    
    init(isArrowImageNeeded: Bool, isTextFieldShouldBeShown: Bool , icon: String = "") {
        super.init(frame: .zero)
        self.isArrowImageNeeded = isArrowImageNeeded
        self.isTextFieldShouldBeShown = isTextFieldShouldBeShown
        self.icon = icon
        self.backgroundColor = .clear
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubViews(){
        
        addSubview(keyLabel)
        
        if isTextFieldShouldBeShown {
            textField = MDTextField()
            addSubview(textField!)
        }
        else{
            valueLabel = UILabel()
            addSubview(valueLabel!)
        }
        
        if isArrowImageNeeded {
            
            var iconStr = "ArrowRight"
            
            if icon.isNotBlank(){
                iconStr = icon
            }
            arrowImageView = UIImageView(image: #imageLiteral(resourceName: iconStr))
            addSubview(arrowImageView!)
        }
        
        addSubview(separator)
        
        
        setProperties()
        addConstraints()
    }
    
    func setProperties(){
        keyLabel.font = UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .regular)
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        
        valueLabel?.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        valueLabel?.font = UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .semibold)
        valueLabel?.textAlignment = .right
        
        valueLabel?.isUserInteractionEnabled = false
        valueLabel?.tintColor = .clear
        
       // textField?.isUserInteractionEnabled = false
        textField?.textAlignment = .right
        textField?.font = UIFont.systemFont(ofSize: bookAppointmentFontSize, weight: .regular)
        textField?.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        
        if icon.isBlank(){
            textField?.placeholder = "Tap to Select"
        }
        separator.setBackgroundColor(bgColor: bookAppointmentSeparatorColor)

    }
    
    
    func addConstraints() {
        keyLabel.setLeft(offSet: 10)
        keyLabel.setTop(offSet: 13)
        keyLabel.setBottomRelatedToView(offSet: SEPARATOR_HEIGHT - 13, relatedView: separator, relatedAttribute: .top)
        
        
        separator.setBottom(offSet: 0)
        separator.setLeft(offSet: 0)
        separator.setRight(offSet: 0)
        separator.setHeight(constant: SEPARATOR_HEIGHT)
        keyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        valueLabel?.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if isTextFieldShouldBeShown
        {
            if let textField = textField{
            
                if isArrowImageNeeded
                {
                    if let arrowImageView = arrowImageView  {
                        
                        
                        //textField.setLeftRelatedToView(offSet: 5, relatedView: keyLabel, relatedAttribute: .right)
                        keyLabel.setRightRelatedToView(offSet: -5, relatedView: textField, relatedAttribute: .left)
                        textField.setCenterY()
                        textField.setRightRelatedToView(offSet: -10, relatedView: arrowImageView, relatedAttribute: .left)
                        arrowImageView.setCenterY()
                        if icon.isNotBlank(){
                            arrowImageView.setWidth(constant: 20)
                            arrowImageView.setHeight(constant: 20)
                        }
                        else{
                        arrowImageView.setWidth(constant: ARROW_IMAGE_VIEW_SIZE.width)
                        arrowImageView.setHeight(constant: ARROW_IMAGE_VIEW_SIZE.height)
                        }
                        arrowImageView.setRight(offSet: -10)
                    }
                        
                }else
                {
                    keyLabel.setRightRelatedToView(offSet: -5, relatedView: textField, relatedAttribute: .left)
                    textField.setCenterY()
                    textField.setRight(offSet: -10)
                    //arrowImageView.image = nil
                }
            }
        }
        else
        {
            //textField.isHidden = true
            
            if let valueLabel = valueLabel {
                if isArrowImageNeeded
                {
                    if let arrowImageView = arrowImageView  {
                        keyLabel.setRightRelatedToView(offSet: -5, relatedView: valueLabel, relatedAttribute: .left)
                        valueLabel.setCenterY()
                        valueLabel.setRightRelatedToView(offSet: -10, relatedView: arrowImageView, relatedAttribute: .left)
                        arrowImageView.setCenterY()
                        
                        if icon.isNotBlank(){
                            arrowImageView.setWidth(constant: 22)
                            arrowImageView.setHeight(constant: 21)
                        }
                        else{
                        arrowImageView.setWidth(constant: ARROW_IMAGE_VIEW_SIZE.width)
                        arrowImageView.setHeight(constant: ARROW_IMAGE_VIEW_SIZE.height)
                        }
                        arrowImageView.setRight(offSet: -10)
                    }
                }
                else
                {
                    keyLabel.setRightRelatedToView(offSet: -5, relatedView: valueLabel, relatedAttribute: .left)
                    valueLabel.setCenterY()
                    valueLabel.setRight(offSet: -10)
                    
                   // arrowImageView.image = nil
                }
            }
            
        }
    }
    
    func showSeparator(){
        separator.isHidden = false
    }
    
    func hideSeparator(){
        separator.isHidden = true
    }
    
    func isSeparatorShown() -> Bool {
        return !separator.isHidden
    }
    
    func showImgView(){
        arrowImageView?.isHidden = false
    }
    
    func hideImgView(){
        arrowImageView?.isHidden = true
    }
    
    
}

class BookAppointmentData {
    var memberList: [Provider] = []
    var facilityList:[Facility] = []
    var practiceList: [Practice] = []
    
    
    var selectedFacility = Facility()
    var selectedMember = Provider()
    var selectedPractice = Practice()

    var isFromDashboard = false

    var appointmentConfig:AppointmentConfig? = nil

    var selectedVisitType : VisitTypes? = nil
    var selectedDate: Date? = Date()

    var lastSelectedSlotStr: String? = nil


    var razorPayPublicToken: String? = nil
    var paymentTransaction: TransactionInfo? = nil

    var appointmentRequest = AppointmentRequest()
    var errorInAPI = -1
    
    var selectedItem = -1
    
    var calendarDataMap: Dictionary<String,MDCalendarData> = [:]
    var calendarDates = MDCalendarDates()
    
    var slotMetaData = SlotMetaData()
    
    var selectFacility = false
    var selectStartDate = false
    
    var appointmentTypeList: [String] = []
    
    var appointmentTimeStr: String? = nil
    
    var slotPreferance = ["Morning","Noon","Evening"]
    var noSlotSessions: [String] = []

    var selectedSlotPreference = 0
    
    var razorpay: RazorpayCheckout? = nil
    
    var selectedMemberAvailability: MemberAvailability? = nil
    
    var startDateForSlotFetch = Date()
    var endDateForSlotFetch = Date()


    func resetAppointmentData(){
        selectedMember = Provider()
        selectedVisitType = nil
        lastSelectedSlotStr = nil
        appointmentConfig = nil
    }
}



