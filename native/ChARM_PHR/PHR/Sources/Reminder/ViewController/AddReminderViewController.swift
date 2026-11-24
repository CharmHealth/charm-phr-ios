//
//  AddReminderViewController.swift
//  phr
//
//  Created by prathi-13964 on 23/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol AddReminderDelegate: AnyObject{
    func reminderAdded(msg: String)
}

class AddReminderViewController: AddDataUIViewController, CharmConnectionV2HandlerDelegate, SelectValueViewControllerDelagate, UITextFieldDelegate, MDTextFieldDelegate{
    
    private var addReminderView: AddReminderView?
    var addReminderTransformModel: AddReminderTransformModel?
    weak var delegate: AddReminderDelegate?
    var editReminderPOJO: ReminderPOJO?
    private var charmConnectionHandler: CharmConnectionHandler?
    let addReminderVCModel = AddReminderVCModel()
    private var postReminderObj: Reminder?
    private var isReminderHistoryFetchCompleted: Bool = false
    var isFromPrescription: Bool = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        
        if let startDate = addReminderTransformModel?.startDate{
            addReminderVCModel.startDate = startDate
        }
        if let endDate = addReminderTransformModel?.endDate{
            addReminderVCModel.endDate = endDate
        }
        
        addReminderView = AddReminderView(addReminderTransformModel: addReminderTransformModel, delegate: self)
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addBtnClicked)), animated: true)
        if editReminderPOJO != nil{
            self.navigationItem.title = getString(key: "com.charmphr.reminder.editReminder.title")
            isReminderHistoryFetchCompleted = false
            setEditReminder()
        }
        else{
            self.navigationItem.title = getString(key: "com.charmphr.reminder.addReminder.title")
            
            addReminderVCModel.selectedFrequency = Frequency.Daily
            addReminderTransformModel?.selectedFrequency = Frequency.Daily
            
            setFrequencyIntakeValueText()
        }
        
        if let addReminderView = addReminderView{
            self.view = addReminderView
            
            addReminderView.startDateView.textField.delegate = self
            addReminderView.endDateView.textField.delegate = self
            addReminderView.addReminderField.delegate = self
            
            addReminderView.startDatePicker.addTarget(self, action: #selector(startDatePickerValueChanged(datePicker:)), for: .valueChanged)
            addReminderView.endDatePicker.addTarget(self, action: #selector(endDatePickerValueChanged(datePicker:)), for: .valueChanged)
            addReminderView.reminderTimePicker.addTarget(self, action: #selector(onClickAddReminderView(timePicker:)), for: .valueChanged)
            addReminderView.addReminderSubView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchAddReminderView)))
            
            addReminderView.frequencyIntakeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchFrequencyView)))
            
//            addReminderView.selectIntervalView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickIntervalView)))
//            addReminderView.selectIntervalView.textField.text = reminderModel.intervalArray[0]
            
            let startDateToolbar = MDDateToolbarWithDone(textField: addReminderView.startDateView.textField, parent: self)
            startDateToolbar.done?.action = #selector(onClickStartDateDone)
            
            let endDateToolbar = MDDateToolbarWithDone(textField: addReminderView.endDateView.textField, parent: self)
            endDateToolbar.done?.action = #selector(onClickEndDateDone)
            
            let reminderDateToolbar = MDDateToolbarWithDone(textField: addReminderView.reminderDateView.textField, parent: self)
            reminderDateToolbar.done?.action = #selector(onClickStartDateDone)
            
            let reminderTimeToolbar = MDDateToolbarWithDone(textField: addReminderView.addReminderField, parent: self)
            reminderTimeToolbar.done?.action = #selector(reminderTimePickerDoneOnClick)
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private func setEditReminder(){
        if let reminderObj = editReminderPOJO?.reminderDetails?.reminder{
            addReminderView?.scrollView.isHidden = true
            fetchRemindeHistory(reminderObj: reminderObj)
        }
    }
    
//    @objc func onClickIntervalView(){
//
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationHandler.requestNotificationAuthorise { [weak self] isAuthorised in
            if !isAuthorised{
                self?.presentNotificationPermissionError()
            }
        }
    }
    
    func presentNotificationPermissionError(){
        DispatchQueue.main.async { [weak self] in
            CharmUtil.createCancelAndSettingsAlertWith(title: getString(key: "com.charmphr.reminder.notification.permission.notAllowed.alert.title"), msg: getString(key: "com.charmphr.reminder.notification.permission.notAllowed.alert.message"), settingsClicked: {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
            }, cancelClicked: { [weak self] in
                guard let self else { return }
                if isFromPrescription{
                    popViewController()
                }
                else{
                    if let viewControllers: [UIViewController] = self.navigationController?.viewControllers as? [UIViewController]{
                        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3 ], animated: true)
                    }
                }
            })
        }
    }
    
//MARK: - TextField Delegate functions
    
    func mdTextFieldDidBeginEditing(_ textField: MDTextField!) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        }
    }
    
    func mdTextFieldDidEndEditing(_ textField: MDTextField!) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
    }
    
//MARK: - API calls
    
    private func fetchRemindeHistory(reminderObj: Reminder){
        showActivityIndicator()
        charmConnectionHandler?.fetchReminderHistory(reminderObj: reminderObj, identificationKey: "fetchReminderHistory")
    }
    
    private func editReminder(reminderObj: Reminder){
        showActivityIndicator()
        charmConnectionHandler?.editReminder(reminderObj: reminderObj, identificationKey: "EditReminder")
    }
    
    private func addReminder(reminderObj: Reminder){
        showActivityIndicator()
        charmConnectionHandler?.addReminder(reminderObj: reminderObj, identificationKey: "AddReminder")
    }
    
//MARK: - AddButton OnCLick
    
    @objc private func addBtnClicked(){
        self.view.endEditing(true)
        if let reminderObj = validate(){
            postReminderObj = reminderObj
            if editReminderPOJO != nil{
                editReminder(reminderObj: reminderObj)
            }
            else{
                addReminder(reminderObj: reminderObj)
            }
        }
    }
    
//MARK: - Validate
    
    private func validate() -> Reminder?{
        
        addReminderVCModel.alertList = []
        
        var addOrEditReminderObj: Reminder?
        
        if let editReminderPOJO = editReminderPOJO{
            if let reminder = editReminderPOJO.reminderDetails?.reminder{
                if let reminderObj = validateCommonfunction(){
                    reminderObj.reminderId = reminder.reminderId
                    reminderObj.practiceId = reminder.practiceId
                    reminderObj.reminderType = reminder.reminderType
                    reminderObj.moduleId = reminder.moduleId
                    reminderObj.patientId = reminder.patientId
                    
                    addOrEditReminderObj = reminderObj
                }
            }
        }
        else{
            if addReminderVCModel.startDate == nil{
                addReminderVCModel.alertList.append(getString(key: "com.charmphr.reminder.addReminder.startDate.alert.message"))
            }
            if addReminderVCModel.endDate == nil{
                addReminderVCModel.alertList.append(getString(key: "com.charmphr.reminder.addReminder.endDate.alert.message"))
            }
            let reminder = validateCommonfunction()
            reminder?.practiceId = addReminderTransformModel?.practiceId
            reminder?.reminderType = addReminderTransformModel?.type
            reminder?.moduleId = addReminderTransformModel?.moduleId
            reminder?.patientId = getSelectedPatientId()
            if let reminderObj = reminder{
                addOrEditReminderObj = reminderObj
            }
        }
        if addReminderVCModel.alertList.isEmpty{
            return addOrEditReminderObj
        }
        else{
            CharmUtil.createOkayAlertWith(title: nil, msg: addReminderVCModel.alertList.first)
            return nil
        }
    }
    
    private func validateCommonfunction() -> Reminder?{
        
        let reminderObj = Reminder()
        var frequencyArray: [ReminderFrequency] = []
        
        reminderObj.startDate = addReminderVCModel.startDate
        
        if let endDate = addReminderVCModel.endDate{
            if endDate.startOfDay < Date().startOfDay{
                addReminderVCModel.alertList.append(getString(key: "com.charmphr.reminder.addReminder.endDate.InvlaidAlert.message"))
            }
            else{
                reminderObj.endDate = endDate
            }
        }
        
        if addReminderVCModel.selectedFrequency == Frequency.Weekly{
            reminderObj.frequency = "0"
            if addReminderView?.selectedWeekDays.count == 0{
                addReminderVCModel.alertList.append(getString(key: "com.charmphr.reminder.addReminder.weekdays.alert.message"))
            }
            else{
                reminderObj.frequencyUnit = WEEK
                addReminderView?.selectedWeekDays.forEach({ dayInt in
                    addReminderVCModel.reminderTimeArray.forEach { time in
                        let reminderFrequency = ReminderFrequency()
                        reminderFrequency.time = time.getStringFromDate(dateFormat: Time24HoursFormat)
                        reminderFrequency.day = "\(dayInt)"
                        frequencyArray.append(reminderFrequency)
                    }
                })
            }
        }
        else{
            addReminderVCModel.reminderTimeArray.forEach { time in
                let reminderFrequency = ReminderFrequency()
                reminderFrequency.time = time.getStringFromDate(dateFormat: Time24HoursFormat)
                reminderFrequency.day = "-1"
                frequencyArray.append(reminderFrequency)
            }
            
            if addReminderVCModel.selectedFrequency == Frequency.Daily{
                reminderObj.frequencyUnit = DAY
                reminderObj.frequency = "0"
            }
            else if addReminderVCModel.selectedFrequency == Frequency.OneTime{
                reminderObj.frequency = "1"
                reminderObj.frequencyUnit = nil
            }
        }
        
        if addReminderVCModel.reminderTimeArray.isEmpty{
            addReminderVCModel.alertList.append(getString(key: "com.charmphr.reminder.addReminder.reminderTime.alert.message"))
        }
        reminderObj.reminderFrequencyArray = frequencyArray
        
        if addReminderVCModel.alertList.isEmpty{
            return reminderObj
        }
        return nil
    }
    
//MARK: - Back OnCLick
    
    override func onBackClick() {
        self.view.endEditing(true)
        if let reminder = editReminderPOJO?.reminderDetails?.reminder{
            if isReminderHistoryFetchCompleted{
                var reminderFreqency = Frequency.Daily
                if reminder.frequency == "1"{
                    reminderFreqency = Frequency.OneTime
                }
                else{
                    if reminder.frequencyUnit == WEEK{
                        reminderFreqency = Frequency.Weekly
                    }
                    else if reminder.frequencyUnit == DAY{
                        reminderFreqency = Frequency.Daily
                    }
                }
                if addReminderVCModel.selectedFrequency != reminderFreqency || addReminderVCModel.editReminderTimeArray != addReminderVCModel.reminderTimeArray || reminder.startDate != addReminderVCModel.startDate || reminder.endDate != addReminderVCModel.endDate || ((addReminderVCModel.selectedFrequency == Frequency.Weekly) && (addReminderView?.selectedWeekDays != addReminderVCModel.editReminderWeekArray)){
                    showDiscardChangesDialog()
                }
                else{
                    popViewController()
                }
            }
            else{
                popViewController()
            }
        }
        else{
            if addReminderVCModel.selectedFrequency != addReminderTransformModel?.selectedFrequency || !addReminderVCModel.reminderTimeArray.isEmpty || addReminderVCModel.startDate?.startOfDay != addReminderTransformModel?.startDate?.startOfDay || addReminderVCModel.endDate?.startOfDay != addReminderTransformModel?.endDate?.startOfDay{
                showDiscardChangesDialog()
            }
            else{
                popViewController()
            }
        }
    }
    
    private func popViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    
//MARK: - Target functions
    
    @objc private func startDatePickerValueChanged(datePicker: UIDatePicker){
        addReminderVCModel.startDatePickerDate = datePicker.date
    }
    
    @objc private func endDatePickerValueChanged(datePicker: UIDatePicker){
        addReminderVCModel.endDatePickerDate = datePicker.date
    }
    
    @objc private func onClickEndDateDone(){
        if addReminderVCModel.endDatePickerDate == nil{
            addReminderVCModel.endDatePickerDate = Date()
        }
        
        addReminderVCModel.endDate = addReminderVCModel.endDatePickerDate
        addReminderView?.endDateView.textField.text = addReminderVCModel.endDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        
        if addReminderVCModel.selectedFrequency == Frequency.Weekly{
            addReminderView?.setWeekDaysView()
        }
        dismissKeyboard()
    }
    
    @objc private func onClickStartDateDone(){
        if addReminderVCModel.startDatePickerDate == nil{
            addReminderVCModel.startDatePickerDate = Date()
        }
        addReminderVCModel.startDate = addReminderVCModel.startDatePickerDate
        
        if addReminderVCModel.selectedFrequency == Frequency.OneTime{
            addReminderVCModel.endDate = addReminderVCModel.startDate
        }
        addReminderView?.setStartAndEndDate(startDate: addReminderVCModel.startDate, endDate: addReminderVCModel.endDate)
        
        if addReminderVCModel.selectedFrequency == Frequency.Weekly{
            addReminderView?.setWeekDaysView()
        }
        dismissKeyboard()
    }
    
    @objc private func onTouchFrequencyView(){
        
        self.view.endEditing(true)
        let selectValueViewController = SelectValueViewController()
        selectValueViewController.delegate = self
        selectValueViewController.title = getString(key: "com.charmphr.reminder.frequencyIntake.title")
        selectValueViewController.arrayOfValueToBeShown  = addReminderVCModel.frequencyArray.map({ filter in
            filter.rawValue
        })
        selectValueViewController.selectedValueIndex = addReminderVCModel.frequencyArray.firstIndex(of: addReminderVCModel.selectedFrequency)
        navigationController?.pushViewController(selectValueViewController, animated: true)
    }
    
    @objc private func onClickAddReminderView(timePicker: UIDatePicker){
        addReminderVCModel.reminderTime = timePicker.date
    }
    
    @objc private func onTouchAddReminderView(){
        addReminderView?.reminderTimePicker.date = Date()
        addReminderVCModel.reminderTime = Date()
        addReminderView?.addReminderField.becomeFirstResponder()
    }
    
    @objc private func reminderTimePickerDoneOnClick(){
        
        self.view.endEditing(true)
        
        if addReminderVCModel.reminderTimeArray.contains(where: { date in
            return date.getStringFromDate(dateFormat: Time24HoursFormat) == addReminderVCModel.reminderTime.getStringFromDate(dateFormat: Time24HoursFormat)
        }){
            CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.reminder.reminderTime.duplicate.alert.title"), seconds: 2)
        }
        else{
            addReminderVCModel.reminderTimeArray.append(addReminderVCModel.reminderTime)
            addReminderView?.createTimeView()
        }
    }
    
    @objc func dismissKeyboard(){
        if addReminderView?.startDateView.textField.isFirstResponder == true || addReminderView?.endDateView.textField.isFirstResponder == true{
            addReminderVCModel.startDatePickerDate = addReminderVCModel.startDate
            addReminderVCModel.endDatePickerDate = addReminderVCModel.endDate
            addReminderView?.setStartAndEndDatePickersDate(startDate: addReminderVCModel.startDate, endDate: addReminderVCModel.endDate)
        }
        self.view.endEditing(true)
    }
    
//MARK: - Other functions
    
    private func setFrequencyIntakeValueText(){
        addReminderView?.frequencyIntakeView.textField.text = addReminderVCModel.selectedFrequency.rawValue
        
        if addReminderVCModel.selectedFrequency == Frequency.OneTime{
            
            addReminderView?.hideWeekDaysView(isHidden: true)
            
            addReminderView?.setFrequencyView(isOneTime: true)
            
            if let startDate = addReminderVCModel.startDate{
                if startDate.startOfDay < Date().startOfDay{
                    addReminderView?.setStartAndEndDate(startDate: Date(), endDate: Date())
                    addReminderView?.setReminderPickerMinimumDate(date: Date())
                }
                else{
                    addReminderView?.setStartAndEndDate(startDate: startDate, endDate: startDate)
                }
            }
        }
        else{
            addReminderView?.setFrequencyView(isOneTime: false)
            if let startDate = addReminderVCModel.startDate{
                if startDate.startOfDay < Date().startOfDay{
                    addReminderView?.setStartAndEndDate(startDate: Date(), endDate: addReminderVCModel.endDate)
                }
                else{
                    addReminderView?.setStartAndEndDate(startDate: startDate, endDate: addReminderVCModel.endDate)
                }
            }
            addReminderView?.setReminderPickerMinimumDate(date: nil)
            onClickStartDateDone()
            
            if addReminderVCModel.selectedFrequency == Frequency.Weekly{
                addReminderView?.hideWeekDaysView(isHidden: false)
                addReminderView?.setWeekDaysView()
            }
            else{
                addReminderView?.hideWeekDaysView(isHidden: true)
            }
            
        }
    }
    
//MARK: - SelectValueVC Delegate
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        
        let selectedFrequency = addReminderVCModel.frequencyArray[selectedRow]
        addReminderVCModel.selectedFrequency = selectedFrequency
        setFrequencyIntakeValueText()
    }
    
//MARK: - CharmConnectionHandler Delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
                
        if identificationKey == "AddReminder"{
            hideActivityIndicator()
            trackEvent(eventName: "AddReminderOnSuccess", withGroupName: "Reminder")
            if let responseDict = response as? [String: Any]{
                if let outputString = responseDict.getAsJsonObject("output_string"){
                    let reminderId =  outputString.getString("reminder_id")
                    if let postReminderObj = postReminderObj{
                        postReminderObj.reminderId = reminderId
                        ReminderHandler.addReminderAndNotification(reminderObj: postReminderObj)
                    }
                }
                
                let message = ParsingHelper.getMessageFromDict(responseDict)
                if isFromPrescription{
                    popViewController()
                }
                else{
                    if let viewControllers: [UIViewController] = self.navigationController?.viewControllers as? [UIViewController]{
                        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3 ], animated: true)
                    }
                }
                delegate?.reminderAdded(msg: message)
            }
        }
        else if identificationKey == "EditReminder"{
            
            trackEvent(eventName: "UpdateReminderOnSuccess", withGroupName: "Reminder")
            hideActivityIndicator()
            if let postReminderObj = postReminderObj{
                ReminderHandler.updateReminderAndNotification(reminderObj: postReminderObj)
            }
            popViewController()
            delegate?.reminderAdded(msg: getString(key: "com.charmphr.reminder.updateReminder.successfull.message"))
        }
        else if identificationKey == "fetchReminderHistory"{
            addReminderView?.scrollView.isHidden = false
            hideActivityIndicator()
            if let response = response as? [ReminderHistory]{
                let reminderHistoryArray = response
                if let editReminderPOJO = editReminderPOJO{
                    addReminderView?.setReminderValues(reminderDetails: editReminderPOJO.reminderDetails)
                }
                
                if !reminderHistoryArray.isEmpty{
                    addReminderView?.disableStartDateView()
                    addReminderView?.disableFrequencyView()
                }
                isReminderHistoryFetchCompleted = true
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "AddReminder" || identificationKey == "EditReminder"{
            
            if identificationKey == "AddReminder"{
                trackEvent(eventName: "AddReminderOnFailure", withGroupName: "Reminder")
            }
            else if identificationKey == "EditReminder"{
                trackEvent(eventName: "UpdateReminderOnFailure", withGroupName: "Reminder")
            }
            
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    private func showActivityIndicator(){
        
        if let activityIndicator = addReminderView?.activityIndicator{
            activityIndicator.startAnimating()
            self.view.bringSubviewToFront(activityIndicator)
        }
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func hideActivityIndicator(){
        addReminderView?.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

//MARK: - TransformUtil

class TransformUtil{
    
    static func transformMedicationToReminderModel(medicationPOJO: MedicationPOJO) -> AddReminderTransformModel{
        let addReminderTransformModel = AddReminderTransformModel()
        
        addReminderTransformModel.title = medicationPOJO.getMedicationDisplayName()
        addReminderTransformModel.instruction = medicationPOJO.getIntakeName(separator: " , ")
        
        if let startDate = medicationPOJO.patientMedication?.fromDate{
            if startDate.startOfDay < Date().startOfDay{
                addReminderTransformModel.startDate = Date()
            }
            else{
                addReminderTransformModel.startDate = startDate
            }
        }
        else{
            addReminderTransformModel.startDate = Date()
        }
        
        if let endDate = medicationPOJO.patientMedication?.toDate{
            addReminderTransformModel.hasEndDate = true
            addReminderTransformModel.endDate = endDate
        }
        else{
            addReminderTransformModel.hasEndDate = false
        }
        addReminderTransformModel.practiceId = medicationPOJO.patientMedication?.practiceId
        addReminderTransformModel.moduleId = medicationPOJO.patientMedication?.patientMedicationId
        
        addReminderTransformModel.type = getString(key: "com.charmphr.reminder.actionSheet.medication.title")
        
        return addReminderTransformModel
    }
    
    static func transformSupplementToReminderModel(supplementPOJO: SupplementPOJO) -> AddReminderTransformModel{
        let addReminderTransformModel = AddReminderTransformModel()
        
        addReminderTransformModel.title = supplementPOJO.getSupplementDisplayName()
        addReminderTransformModel.instruction = supplementPOJO.getIntakeName(separator: " , ")
        if let startDate = supplementPOJO.patientSupplement?.fromDate{
            if startDate.startOfDay < Date().startOfDay{
                addReminderTransformModel.startDate = Date()
            }
            else{
                addReminderTransformModel.startDate = startDate
            }
        }
        else{
            addReminderTransformModel.startDate = Date()
        }
        
        if let endDate = supplementPOJO.patientSupplement?.toDate{
            addReminderTransformModel.hasEndDate = true
            addReminderTransformModel.endDate = endDate
        }
        else{
            addReminderTransformModel.hasEndDate = false
        }
        addReminderTransformModel.moduleId = supplementPOJO.patientSupplement?.patientSupplementId
        addReminderTransformModel.practiceId = supplementPOJO.patientSupplement?.practiceId
        addReminderTransformModel.type = getString(key: "com.charmphr.reminder.actionSheet.supplement.title")
        
        return addReminderTransformModel
    }
    
    static func transformAllergyToCustomModel(allergy: AllergiesList, type: AllergyType) -> AddWidgetCommonModel{
        
        let addWidgetCommonModel = AddWidgetCommonModel()
        
        addWidgetCommonModel.name = allergy.allergy
        addWidgetCommonModel.description = allergy.patientAllergyMap?.reactions
        addWidgetCommonModel.severity = Severity(rawValue: allergy.patientAllergyMap?.severity ?? "")
        addWidgetCommonModel.type = type
        
        return addWidgetCommonModel
    }
    
    static func transformAllergyToCustomModel(allergiesEntries: IntakeQuestAllergyEntry) -> AddWidgetCommonModel{
        
        let addWidgetCommonModel = AddWidgetCommonModel()
        
        addWidgetCommonModel.name = allergiesEntries.allergen
        addWidgetCommonModel.description = allergiesEntries.reactions
        addWidgetCommonModel.severity = allergiesEntries.severity
        addWidgetCommonModel.type = allergiesEntries.type
        
        return addWidgetCommonModel
    }
    
    static func transformCustomModelToAllergy(addWidgetCommonModel: AddWidgetCommonModel) -> IntakeQuestAllergyEntry{
        
        let allergiesEntries = IntakeQuestAllergyEntry()
       
        allergiesEntries.allergen = addWidgetCommonModel.name
        allergiesEntries.reactions = addWidgetCommonModel.description
        allergiesEntries.severity = addWidgetCommonModel.severity
        allergiesEntries.type = addWidgetCommonModel.type
        
        return allergiesEntries
    }
    
    static func transformCustomModelToIntakeEntries(addWidgetCommonModel: AddWidgetCommonModel) -> IntakeQuestPrecriptionEntry{
        let intakeEntries = IntakeQuestPrecriptionEntry()
        
        intakeEntries.name = addWidgetCommonModel.name
        intakeEntries.intakeDetails = addWidgetCommonModel.description
        
        return intakeEntries
    }
    
    static func transformIntakeEntriesToCustomModel(intakeEntries: IntakeQuestPrecriptionEntry) -> AddWidgetCommonModel{
        
        let addWidgetCommonModel = AddWidgetCommonModel()
        
        addWidgetCommonModel.name = intakeEntries.name
        addWidgetCommonModel.description = intakeEntries.intakeDetails
        
        return addWidgetCommonModel
    }
    
    static func transformPracticeToSelectModel(practiceList: [Practice]) -> [SelectValueModel]{
        
        return practiceList.map { practice in
            return SelectValueModel(id: practice.practiceId ?? "", name: practice.practiceName ?? "")
        }
    }
    static func transformStringToSelectValueModel(stringArr: [String]) -> [SelectValueModel]{
        
        return stringArr.map { str in
            return SelectValueModel(id: str, name: str)
        }
    }
}
