//
//  AddReminderView.swift
//  phr
//
//  Created by prathi-13964 on 23/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let ADD_REMINDER_WIDTH = applicationFrame.width - 32

class AddReminderView: UIView{
    
    let activityIndicator = UIActivityIndicatorView()
    let scrollView = TPKeyboardAvoidingScrollView()
    private let stackView = UIStackView()
    private let titleInstructionDetailView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateStackView = UIStackView()
    let startDateView = AddModuleKeyAndValueView(isDateField: true)
    let endDateView = AddModuleKeyAndValueView(isDateField: true)
    let reminderDateView = AddModuleKeyAndValueView(isDateField: true)
    private let frequencyIntakeStackView = UIStackView()
    let frequencyIntakeView = AddModuleKeyAndValueView()
    private let selectIntervalView = AddModuleKeyAndValueView()
    private let enterValueView = AddModuleKeyAndValueView()
    private let selectDaysLabelView = UIView()
    private let selectDaysLabel = UILabel()
    private let weekDaysStackView = UIStackView()
    private let addReminderView = UIView()
    private let addReminderStackView = UIStackView()
    let addReminderSubView = UIView()
    private let alarmImageView = UIImageView(image: UIImage(named: "ReminderFrequency"))
    private let addReminderTimeLabel = UILabel()
    let addReminderField = DateTextField()
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let reminderTimePicker = UIDatePicker()
    
    private var addReminderVCDelegate: AddReminderViewController?
    private var addReminderTransformModel: AddReminderTransformModel?
    
    private let weekArray = [WeekDays.Sunday, WeekDays.Monday, WeekDays.Tuesday, WeekDays.Wednesday, WeekDays.Thursday, WeekDays.Friday, WeekDays.Saturday]
    private var imageViewToLabelMap: [Int: Int] = [:]
    var selectedWeekDays: [Int] = []
    private var tagNo = 890000
    
    init(addReminderTransformModel: AddReminderTransformModel?, delegate: AddReminderViewController?){
        super.init(frame: .zero)
        self.addReminderTransformModel = addReminderTransformModel
        addReminderVCDelegate = delegate
        initViews()
    }
    
    private func initViews(){
        
        self.addSubview(activityIndicator)
        self.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(titleInstructionDetailView)
        titleInstructionDetailView.addSubview(titleLabel)
        titleInstructionDetailView.addSubview(descriptionLabel)
        stackView.addArrangedSubview(dateStackView)
        dateStackView.addArrangedSubview(startDateView)
        dateStackView.addArrangedSubview(endDateView)
        dateStackView.addArrangedSubview(reminderDateView)
        stackView.addArrangedSubview(frequencyIntakeStackView)
        frequencyIntakeStackView.addArrangedSubview(frequencyIntakeView)
        frequencyIntakeStackView.addArrangedSubview(selectIntervalView)
        frequencyIntakeStackView.addArrangedSubview(enterValueView)
        stackView.addArrangedSubview(selectDaysLabelView)
        selectDaysLabelView.addSubview(selectDaysLabel)
        stackView.addArrangedSubview(weekDaysStackView)
        stackView.addArrangedSubview(addReminderView)
        addReminderView.addSubview(addReminderStackView)
        addReminderView.addSubview(addReminderSubView)
        addReminderSubView.addSubview(alarmImageView)
        addReminderSubView.addSubview(addReminderTimeLabel)
        addReminderSubView.addSubview(addReminderField)
        
        addProperties()
        addConstraints()
    }
    
//MARK: - addConstraints
    
    private func addConstraints(){
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        scrollView.setLeft(offSet: 0)
        scrollView.setRight(offSet: 0)
        scrollView.setSafeAreaTop(offset: 0)
        scrollView.setSafeAreaBottom(offset: 0)
        
        stackView.setLeft(offSet: X_SPACE)
        stackView.setRight(offSet: -X_SPACE)
        stackView.setTop(offSet: CARD_PADDING)
        stackView.setBottom(offSet: -CARD_PADDING)
        stackView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        titleInstructionDetailView.setLeft(offSet: 0)
        titleInstructionDetailView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        titleLabel.setLeft(offSet: CELL_PADDING)
        titleLabel.setRight(offSet: -CELL_PADDING)
        titleLabel.setTop(offSet: CARD_PADDING)
        
        descriptionLabel.setLeft(offSet: CELL_PADDING)
        descriptionLabel.setRight(offSet: -CELL_PADDING)
        descriptionLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: titleLabel, relatedAttribute: .bottom)
        descriptionLabel.setBottom(offSet: -CARD_PADDING)
        
        dateStackView.setLeft(offSet: 0)
        dateStackView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        startDateView.setLeft(offSet: 0)
        startDateView.setRight(offSet: 0)
  
        endDateView.setLeft(offSet: 0)
        endDateView.setRight(offSet: 0)
        
        reminderDateView.setLeft(offSet: 0)
        reminderDateView.setRight(offSet: 0)
        
        frequencyIntakeStackView.setLeft(offSet: 0)
        frequencyIntakeStackView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        frequencyIntakeView.setLeft(offSet: 0)
        frequencyIntakeView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        selectIntervalView.setLeft(offSet: 0)
        selectIntervalView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        enterValueView.setLeft(offSet: 0)
        enterValueView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        selectDaysLabelView.setLeft(offSet: 0)
        selectDaysLabelView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        selectDaysLabel.setLeft(offSet: 5)
        selectDaysLabel.setRight(offSet: 0)
        selectDaysLabel.setTop(offSet: 0)
        selectDaysLabel.setBottom(offSet: 0)
        
        weekDaysStackView.setLeft(offSet: 0)
        weekDaysStackView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        addReminderView.setLeft(offSet: 0)
        addReminderView.setWidth(constant: ADD_REMINDER_WIDTH)
        
        addReminderStackView.setLeft(offSet: 0)
        addReminderStackView.setRight(offSet: 0)
        addReminderStackView.setTop(offSet: 0)
        
        addReminderSubView.setLeft(offSet: 0)
        addReminderSubView.setRight(offSet: 0)
        addReminderSubView.setTopRelatedToView(offSet: 0, relatedView: addReminderStackView, relatedAttribute: .bottom)
        addReminderSubView.setBottom(offSet: 0)
        
        alarmImageView.setLeft(offSet: CELL_PADDING)
        alarmImageView.setTop(offSet: SPACING_12)
        alarmImageView.setBottom(offSet: -SPACING_12)
        alarmImageView.setHeight(constant: BUTTON_HEIGHT_20)
        alarmImageView.setWidth(constant: BUTTON_HEIGHT_20)
        
        addReminderTimeLabel.setLeftRelatedToView(offSet: SPACE_BW_TWO_SECTIONS, relatedView: alarmImageView, relatedAttribute: .right)
        addReminderTimeLabel.setTop(offSet: TABLEVIEWCELL_Y_SPACE)
        addReminderTimeLabel.setBottom(offSet: -TABLEVIEWCELL_Y_SPACE)
        
        addReminderField.setLeftRelatedToView(offSet: SPACE_BW_TWO_SECTIONS, relatedView: addReminderTimeLabel, relatedAttribute: .right)
        addReminderField.setRight(offSet: -CARD_PADDING)
        addReminderField.setTop(offSet: TABLEVIEWCELL_Y_SPACE)
        addReminderField.setBottom(offSet: -TABLEVIEWCELL_Y_SPACE)
    }
    
//MARK: - addProperties
    
    private func addProperties(){
        
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        stackView.spacing = CARD_PADDING
        stackView.alignment = .fill
        stackView.axis = .vertical
        
        frequencyIntakeStackView.spacing = 0
        frequencyIntakeStackView.alignment = .fill
        frequencyIntakeStackView.axis = .vertical
        
        weekDaysStackView.spacing = 0
        weekDaysStackView.alignment = .fill
        weekDaysStackView.axis = .vertical
        
        addReminderStackView.spacing = 0
        addReminderStackView.alignment = .fill
        addReminderStackView.axis = .vertical
        
        dateStackView.spacing = 0
        dateStackView.alignment = .fill
        dateStackView.axis = .vertical
        
        titleLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_DARK)
        titleLabel.numberOfLines = 0
        
        descriptionLabel.setProperties(textKey: "", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        descriptionLabel.numberOfLines = 0
        
        if let addReminderTransformModel = addReminderTransformModel{
            titleLabel.text = addReminderTransformModel.title
            descriptionLabel.text = addReminderTransformModel.instruction
            
            if let startDate = addReminderTransformModel.startDate{
                if let endDate = addReminderTransformModel.endDate{
                    startDateView.textField.text = startDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                    endDateView.textField.text = endDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                    setStartAndEndDatePickersDate(startDate: startDate, endDate: endDate)
                }
            }
        }
        
        startDatePicker.preferredDatePickerStyle = .wheels
        startDatePicker.datePickerMode = .date
        if let startDate = addReminderTransformModel?.startDate{
            if startDate.startOfDay < Date().startOfDay{
                startDatePicker.minimumDate = Date()
            }
            else{
                startDatePicker.minimumDate = addReminderTransformModel?.startDate
            }
        }
        else{
            startDatePicker.minimumDate = Date()
        }
        
        if addReminderTransformModel?.hasEndDate == true{
            startDatePicker.maximumDate = addReminderTransformModel?.endDate
            endDatePicker.maximumDate = addReminderTransformModel?.endDate
        }
        
        endDatePicker.preferredDatePickerStyle = .wheels
        endDatePicker.datePickerMode = .date
        
        startDateView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
        startDateView.keyLabel.text = getString(key: "com.charmphr.reminder.addReminder.startDate")
        startDateView.textField.tintColor = .clear
        startDateView.textField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        startDateView.textField.inputView = startDatePicker
        startDateView.addBottomBorder(borderWidth: DEFAULT_BORDER_WIDTH)
                
        endDateView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
        endDateView.keyLabel.text = getString(key: "com.charmphr.reminder.addReminder.endDate")
        endDateView.textField.tintColor = .clear
        endDateView.textField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        endDateView.textField.inputView = endDatePicker
        
        reminderDateView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
        reminderDateView.keyLabel.text = getString(key: "com.charmphr.reminder.addReminder.reminderdate")
        reminderDateView.textField.tintColor = .clear
        reminderDateView.textField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        reminderDateView.textField.inputView = startDatePicker
        reminderDateView.isHidden = true
        
        frequencyIntakeView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
        frequencyIntakeView.keyLabel.text = getString(key: "com.charmphr.reminder.addReminder.FrequencyOfIntake.title")
        frequencyIntakeView.textField.tintColor = .clear
        frequencyIntakeView.textField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        frequencyIntakeView.textField.isEnabled = false
        
        selectIntervalView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
        selectIntervalView.keyLabel.text = getString(key: "com.charmphr.reminder.addReminder.selectFrequency.title")
        selectIntervalView.textField.tintColor = .clear
        selectIntervalView.textField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        selectIntervalView.textField.isEnabled = false
        selectIntervalView.addBottomBorder(borderWidth: DEFAULT_BORDER_WIDTH)

        enterValueView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
        enterValueView.keyLabel.text = getString(key: "com.charmphr.reminder.addReminder.enterValueN.title")
        enterValueView.textField.tintColor = .clear
        enterValueView.textField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        enterValueView.setPlaceholderForTextField(text: getString(key: "com.charmphr.reminder.addReminder.placeHolder.title"))
        enterValueView.textField.keyboardType = .numberPad
        
        selectDaysLabel.text = getString(key: "com.charmphr.reminder.addReminder.selectDays.title")
        selectDaysLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUMDARK)
        selectDaysLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        
        endDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchEndDateView)))
        startDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchStartDateView)))
        reminderDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchStartDateView)))
        
        reminderTimePicker.datePickerMode = .time
        reminderTimePicker.preferredDatePickerStyle = .wheels
        
        if addReminderTransformModel?.startDate?.isSameDate(date: Date()) == true && addReminderTransformModel?.endDate?.isSameDate(date: Date()) == true{
            reminderTimePicker.minimumDate = Date()
        }
        
        addReminderTimeLabel.setProperties(textKey: "com.charmphr.reminder.addReminder.addReminderTime.title", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: THEME_COLOR)
        
        addReminderField.inputView = reminderTimePicker
        
        setViewBorder(uiView: titleInstructionDetailView)
        setViewBorder(uiView: dateStackView)
        setViewBorder(uiView: frequencyIntakeView)
        setViewBorder(uiView: weekDaysStackView)
        setViewBorder(uiView: addReminderView)
        
        selectIntervalView.isHidden = true
        enterValueView.isHidden = true
    }
    
    func createWeekdayView(weekDayArray: [WeekDays]){
        for days in weekDayArray {
            let dayView = UIView()
            let dayLabel = UILabel()
            let tickImageView = UIImageView(image: UIImage(named: "Tick_blue"))
            
            weekDaysStackView.addArrangedSubview(dayView)
            dayView.addSubview(dayLabel)
            dayView.addSubview(tickImageView)
            
            dayLabel.setLeft(offSet: CELL_PADDING)
            dayLabel.setTop(offSet: TABLEVIEWCELL_Y_SPACE)
            dayLabel.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: tickImageView, relatedAttribute: .left)
            
            tickImageView.setRight(offSet: -CELL_PADDING)
            tickImageView.setCenterY(view: dayLabel)
            tickImageView.setHeight(constant: 18)
            tickImageView.setWidth(constant: 18)
            
            if selectedWeekDays.contains(days.rawValue){
                tickImageView.isHidden = false
            }
            else{
                tickImageView.isHidden = true
            }
            
            if days == weekArray[weekArray.count - 1]{
                dayLabel.setBottom(offSet: -TABLEVIEWCELL_Y_SPACE)
            }
            else{
                let horizontalLine = UIView()
                dayView.addSubview(horizontalLine)
                
                horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
                
                horizontalLine.setLeft(offSet: 0)
                horizontalLine.setRight(offSet: 0)
                horizontalLine.setTopRelatedToView(offSet: TABLEVIEWCELL_Y_SPACE, relatedView: dayLabel, relatedAttribute: .bottom)
                horizontalLine.setBottom(offSet: 0)
                horizontalLine.setHeight(constant: DEFAULT_BORDER_WIDTH)
            }
            dayLabel.setProperties(textKey: "\(days)", fontsize: TABLEVIEWCELL_Y_SPACE, weight: .regular, fontcolor: TEXT_COLOR_DARK)
            dayLabel.textAlignment = .left
            
            tickImageView.tag = tagNo
            tagNo += 1
            dayLabel.tag = tagNo
            tagNo += 1
            
            imageViewToLabelMap[tickImageView.tag] = dayLabel.tag
            dayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchDaysView(_:))))
        }
    }
    
//MARK: - Other functions
    
    func hideWeekDaysView(isHidden: Bool){
        weekDaysStackView.isHidden = isHidden
        selectDaysLabelView.isHidden = isHidden
    }
    
    func setWeekDaysView(){
        if let startDate = addReminderVCDelegate?.addReminderVCModel.startDate, let endDate = addReminderVCDelegate?.addReminderVCModel.endDate{
            let dateArr = Date.dates(from: startDate, to: endDate)
            var weekdayIntArr: [Int] = []
            var weekdayArr: [WeekDays] = []
            if dateArr.count < 7{
                weekdayIntArr = dateArr.map({ dateObj in
                    return dateObj.weekday - 1
                })
                weekdayIntArr = weekdayIntArr.removeDuplicateElements()
                weekdayIntArr.sort()
                
                selectedWeekDays.forEach { selectedInt in
                    if !weekdayIntArr.contains(selectedInt){
                        if let index = selectedWeekDays.firstIndex(of: selectedInt){
                            selectedWeekDays.remove(at: index)
                        }
                    }
                }
                
                weekdayArr = weekdayIntArr.map({ rawVal in
                    return WeekDays(rawValue: rawVal) ?? WeekDays.Sunday
                })
            }
            else{
                weekdayArr = weekArray
            }
            
            
            weekDaysStackView.subviews.forEach { subView in
                subView.removeFromSuperview()
            }
            createWeekdayView(weekDayArray: weekdayArr)
        }
    }
    
    private func setViewBorder(uiView: UIView){
        
        uiView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        uiView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SUPPORT_BORDER_COLOR).cgColor
        uiView.layer.borderWidth = DEFAULT_BORDER_WIDTH
        uiView.addCornerRadius(.SMALL)
    }

    private func setEndDatePickerMaximum(){
        
        if addReminderTransformModel?.hasEndDate == true{
            endDatePicker.maximumDate = addReminderTransformModel?.endDate
        }
        
        if addReminderVCDelegate?.editReminderPOJO?.reminderDetails?.hasEndDate == true{
            endDatePicker.maximumDate = addReminderVCDelegate?.editReminderPOJO?.reminderDetails?.reminder?.endDate
        }
    }
    
    func setReminderPickerMinimumDate(date: Date?){
        reminderTimePicker.minimumDate = date
    }
    
    func setStartAndEndDate(startDate: Date?, endDate: Date?){
        startDateView.textField.text = startDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        endDateView.textField.text = endDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        reminderDateView.textField.text = startDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        addReminderVCDelegate?.addReminderVCModel.startDatePickerDate = startDate
        addReminderVCDelegate?.addReminderVCModel.endDatePickerDate = endDate
        addReminderVCDelegate?.addReminderVCModel.startDate = startDate
        addReminderVCDelegate?.addReminderVCModel.endDate = endDate
        
        if let startDate = startDate{
            if startDate.startOfDay > Date().startOfDay{
                endDatePicker.minimumDate = startDate
            }
            else{
                endDatePicker.minimumDate = Date()
            }
        }
        setStartAndEndDatePickersDate(startDate: startDate, endDate: endDate)
    }
    
    func setStartAndEndDatePickersDate(startDate: Date?, endDate: Date?){
        if let startDate = startDate{
            startDatePicker.date = startDate
        }
        if let endDate = endDate{
            endDatePicker.date = endDate
        }
    }
    
    func setFrequencyView(isOneTime: Bool){
        startDateView.isHidden = isOneTime
        endDateView.isHidden = isOneTime
        reminderDateView.isHidden = !isOneTime
    }
    
//MARK: - createTimeView
    
    func createTimeView(){
        
        addReminderStackView.subviews.forEach{ subviews in
            subviews.removeFromSuperview()
        }
        
        if var timeList = addReminderVCDelegate?.addReminderVCModel.reminderTimeArray{
            
            timeList.sort {($0.getStringFromDate(dateFormat: Time24HoursFormat) < $1.getStringFromDate(dateFormat: Time24HoursFormat))}
            
            timeList.forEach { time in
                
                let timeView = ReminderTimeView(time: time, reminderTimeMinimumDate: reminderTimePicker.minimumDate, delegateVC: addReminderVCDelegate, delegateView: self)
                addReminderStackView.addArrangedSubview(timeView)
                
                timeView.addBottomBorder(color: UIColorFromRGB(rgbValueWithAlpha: REMINDER_CANCEL_BTN_COLOR), borderWidth: DEFAULT_BORDER_WIDTH)
                
                timeView.cancelBtn.addTarget(self, action: #selector(onCancelTimeClicked(btn:)), for: .touchUpInside)
            }
        }
    }
    
//MARK: - setReminderValues
    
    func setReminderValues(reminderDetails: ReminderDetails?){
        
        var dayList: [Int] = []
        var timeList: [String] = []
        
        if let reminderObj = reminderDetails?.reminder{
            
            startDateView.textField.text = reminderObj.startDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            endDateView.textField.text = reminderObj.endDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            reminderDateView.textField.text = reminderObj.startDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            
            reminderObj.reminderFrequencyArray.forEach { reminderFrequency in
                if let day = reminderFrequency.day?.toIntOrNil(), let time = reminderFrequency.time{
                    dayList.append(day)
                    timeList.append(time)
                }
            }
            
            let filteredDayList = dayList.removeDuplicateElements()
            
            let filteredTimeList = timeList.removeDuplicateElements()
            
            filteredTimeList.forEach { timeString in
                if let timeObj = Date.getDateFromString(dateFormat: Time24HoursFormat, dateString: timeString){
                    addReminderVCDelegate?.addReminderVCModel.reminderTimeArray.append(timeObj)
                }
            }
            createTimeView()
            if let addReminderVCDelegate = addReminderVCDelegate{
                addReminderVCDelegate.addReminderVCModel.editReminderTimeArray = addReminderVCDelegate.addReminderVCModel.reminderTimeArray
            }
            
            if reminderObj.frequency == "1"{
                frequencyIntakeView.textField.text = Frequency.OneTime.rawValue
                setReminderPickerMinimumDate(date: Date())
                hideWeekDaysView(isHidden: true)
                addReminderVCDelegate?.addReminderVCModel.selectedFrequency = Frequency.OneTime
                
                setFrequencyView(isOneTime: true)
            }
            else{
                setFrequencyView(isOneTime: false)
                
                if reminderObj.frequencyUnit == WEEK{
                    frequencyIntakeView.textField.text = Frequency.Weekly.rawValue
                    hideWeekDaysView(isHidden: false)
                    setSelectedWeekdays(weekDaysList: filteredDayList)
                    addReminderVCDelegate?.addReminderVCModel.selectedFrequency = Frequency.Weekly
                }
                else if reminderObj.frequencyUnit == DAY{
                    frequencyIntakeView.textField.text = Frequency.Daily.rawValue
                    addReminderVCDelegate?.addReminderVCModel.selectedFrequency = Frequency.Daily
                    hideWeekDaysView(isHidden: true)
                }
            }
            if let startDate = reminderObj.startDate{
                
                if startDate.startOfDay >= Date().startOfDay{
                    startDatePicker.date = startDate
                    addReminderVCDelegate?.addReminderVCModel.startDatePickerDate = startDate
                }
                
                if startDate.startOfDay > Date().startOfDay{
                    endDatePicker.minimumDate = startDate
                }
                else{
                    endDatePicker.minimumDate = Date()
                }
                
                addReminderVCDelegate?.addReminderVCModel.startDate = startDate
            }
            if let endDate = reminderObj.endDate{
                endDatePicker.date = endDate
                addReminderVCDelegate?.addReminderVCModel.endDate = endDate
                addReminderVCDelegate?.addReminderVCModel.endDatePickerDate = endDate
            }
            else{
                addReminderVCDelegate?.addReminderVCModel.endDate = nil
            }
            
            if addReminderVCDelegate?.addReminderVCModel.selectedFrequency == Frequency.Weekly{
                selectedWeekDays = filteredDayList
                addReminderVCDelegate?.addReminderVCModel.editReminderWeekArray = selectedWeekDays
            }
        }
        titleLabel.text = reminderDetails?.title
        descriptionLabel.text = reminderDetails?.descripiton
        
        setEndDatePickerMaximum()
        setWeekDaysView()
    }
    
    func disableStartDateView(){
        startDateView.textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        startDateView.arrowImageView.isHidden = true
        startDateView.isUserInteractionEnabled = false
    }
    
    func disableFrequencyView(){
        frequencyIntakeView.textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        frequencyIntakeView.arrowImageView.isHidden = true
        frequencyIntakeView.isUserInteractionEnabled = false
    }
    
    
//MARK: - setSelectedWeekdays
    
    private func setSelectedWeekdays(weekDaysList: [Int]){
        weekDaysStackView.subviews.forEach { weekDayView in
            if let label = weekDayView.subviews.first(where: { uiView in
                return uiView is UILabel
            }) as? UILabel, let imageView = weekDayView.subviews.first(where: { uiView in
                return uiView is UIImageView
            }) as? UIImageView{
                if weekDaysList.contains(where: { weekDayInt in
                    let weekDaysString: String = "\(WeekDays(rawValue: weekDayInt) ?? WeekDays.Sunday)"
                    return weekDaysString == label.text
                }){
                    imageView.isHidden = false
                }
                else{
                    imageView.isHidden = true
                }
            }
        }
    }
    
//MARK: - Target functions
    
    @objc private func onCancelTimeClicked(btn: UIButton){
        
        if let delegate = addReminderVCDelegate{
            delegate.dismissKeyboard()
            if let reminderTimeView = btn.superview as? ReminderTimeView{
                let dateObj = reminderTimeView.timeObj
                if reminderTimeView.superview is UIStackView{ //Double check
                    reminderTimeView.removeFromSuperview()
                    
                    if let index = delegate.addReminderVCModel.reminderTimeArray.firstIndex(where: { date in
                        return dateObj.getStringFromDate(dateFormat: Time24HoursFormat) == date.getStringFromDate(dateFormat: Time24HoursFormat) //Prathi: to be discussed
                    }){
                        delegate.addReminderVCModel.reminderTimeArray.remove(at: index)
                    }
                }
            }
        }
    }
    
    @objc private func onTouchDaysView(_ sender: UITapGestureRecognizer){
        if let weekdayView = sender.view{
            let tickImage = weekdayView.subviews.first { subView in
                if subView is UIImageView{
                    return true
                }
                return false
            }
            if let tickImage = tickImage{
                if let labelTag = imageViewToLabelMap[tickImage.tag],
                    let daysLabel = self.viewWithTag(labelTag) as? UILabel{
                    let selectedDay = weekArray.first { weekdays in
                        return "\(weekdays)" == daysLabel.text
                    }
                    if tickImage.isHidden{
                        tickImage.isHidden = false
                        if let selectedDay = selectedDay{
                            selectedWeekDays.append(selectedDay.rawValue)
                        }
                    }
                    else{
                        tickImage.isHidden = true
                        if let selectedDay = selectedDay,
                           let index = selectedWeekDays.firstIndex(of: selectedDay.rawValue){
                            selectedWeekDays.remove(at: index)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func onTouchEndDateView(){
        endDateView.textField.becomeFirstResponder()
    }
    
    @objc private func onTouchStartDateView(){
        if reminderDateView.isHidden{
            startDateView.textField.becomeFirstResponder()
        }
        else{
            reminderDateView.textField.becomeFirstResponder()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class ReminderTimeView: UIView, UITextFieldDelegate, MDTextFieldDelegate{
    
    var timeObj = Date()
    private let timeField = DateTextField()
    let cancelBtn = UIButton(type: .custom)
    private var reminderTimePicker = UIDatePicker()
    private var delegateVC: AddReminderViewController? = nil
    private var delegateView: AddReminderView? = nil
    private var reminderTime: Date = Date()
    
    init(time: Date, reminderTimeMinimumDate: Date?, delegateVC: AddReminderViewController?, delegateView: AddReminderView?){
        super.init(frame: .zero)
        
        self.timeObj = time
        reminderTimePicker.minimumDate = reminderTimeMinimumDate
        reminderTimePicker.date = time
        reminderTime = time
        self.delegateVC = delegateVC
        self.delegateView = delegateView
        
        initViews()
    }
    
    func initViews(){
        
        self.addSubview(timeField)
        self.addSubview(cancelBtn)
        
        timeField.text = timeObj.getStringFromDate(dateFormat: charmDisplayTimeFormat)
        timeField.font = UIFont.systemFont(ofSize: FONT_SIZE_TWENTY, Weight: .regular)
        timeField.textColor = UIColorFromRGB(rgbValueWithAlpha: REMINDER_TIME_TEXT_COLOR)
        
        timeField.delegate = self
        timeField.inputView = reminderTimePicker
        reminderTimePicker.addTarget(self, action: #selector(onClickAddReminderView(timePicker:)), for: .valueChanged)

        let reminderTimeToolbar = MDDateToolbarWithDone(textField: timeField, parent: self)
        reminderTimeToolbar.done?.action = #selector(reminderTimePickerDoneOnClick)
        
        cancelBtn.setProperties(titleStrKey: getString(key: "com.charmphr.action.cancel"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLUE)
        
        timeField.setLeft(offSet: CELL_PADDING)
        timeField.setTop(offSet: CARD_PADDING)
        timeField.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: cancelBtn, relatedAttribute: .left)
        timeField.setBottom(offSet: -CARD_PADDING)
        
        cancelBtn.setTop(offSet: CARD_PADDING)
        cancelBtn.setRight(offSet: -CELL_PADDING)
        cancelBtn.setBottom(offSet: -CARD_PADDING)
        cancelBtn.setWidth(constant: cancelBtn.sizeThatFits(CGSize(width: 300, height: 50)).width)
        
        reminderTimePicker.datePickerMode = .time
        reminderTimePicker.preferredDatePickerStyle = .wheels
    }
    
    func mdTextFieldDidBeginEditing(_ textField: MDTextField!) {
        delegateVC?.navigationItem.rightBarButtonItem?.isEnabled = false
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        }
    }
    
    func mdTextFieldDidEndEditing(_ textField: MDTextField!) {
        delegateVC?.navigationItem.rightBarButtonItem?.isEnabled = true
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
    }
    
    @objc private func onClickAddReminderView(timePicker: UIDatePicker){
        reminderTime = timePicker.date
    }
    
    @objc private func reminderTimePickerDoneOnClick(){
        
        self.endEditing(true)
        
        if let delegateVC = delegateVC{
            if let index = delegateVC.addReminderVCModel.reminderTimeArray.firstIndex(where: { date in
                return timeObj.getStringFromDate(dateFormat: Time24HoursFormat) == date.getStringFromDate(dateFormat: Time24HoursFormat) //Prathi: to be discussed
            }){
                delegateVC.addReminderVCModel.reminderTimeArray.remove(at: index)
            }
            
            if delegateVC.addReminderVCModel.reminderTimeArray.contains(where: { date in
                return date.getStringFromDate(dateFormat: Time24HoursFormat) == reminderTime.getStringFromDate(dateFormat: Time24HoursFormat)
            }){
                CharmUtil.showToast(controller: delegateVC, message: getString(key: "com.charmphr.reminder.reminderTime.duplicate.alert.title"), seconds: 2)
            }
            else{
                timeObj = reminderTime
                delegateVC.addReminderVCModel.reminderTimeArray.append(timeObj)
                delegateView?.createTimeView()
                
                timeField.text = timeObj.getStringFromDate(dateFormat: charmDisplayTimeFormat)
            }
        }
    }
    
    @objc func dismissKeyboard(){
        reminderTime = timeObj
        reminderTimePicker.date = timeObj
        self.endEditing(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
