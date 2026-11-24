//
//  AddWellnessViewController.swift
//  phr
//
//  Created by Dhanuprasanya P on 05/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import MDTextField


class AddWellnessViewController: UIViewController , CharmConnectionHandlerDelegate, CharmConnectionV2HandlerDelegate ,UITextViewDelegate, MDTextFieldDelegate, UITextFieldDelegate , SelectValueViewControllerDelagate , WellnessMetricViewControllerDelegate, DismissModelViewDelegate
{
    

    let activityIndicator = UIActivityIndicatorView()
    
    var charmConnectionHandeler : CharmConnectionHandler!
    let entryDateView = AddModuleKeyAndValueView()
    let datePicker = UIDatePicker()
    let entryTimeView = AddModuleKeyAndValueView()
    let containerView = UIView()
    let timePicker = UIDatePicker()
    weak var delegate : AddViewControllerDelegate?
    
    
    var vitalUnitView:AddModuleKeyAndValueView? = nil

    var tracker : Tracker?
    var metric : Metric?
    var tag = 10000
    var tagNo = 1
    var bmiTagList: [Int] = []
    var tagList: [Int] = []
    var fieldToLabelMap = Dictionary<Int , Int>()
    var fieldToStringMap = Dictionary<Int , String>()
    var fieldToUnitMap = Dictionary<Int, String>()
    
    
    var unitList:[String]? = nil
    private var addVital:AddVital? = nil
    
    private var presentingVC:UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        var title = "Add"
        if(tracker != nil && metric == nil)
        {
            title = title + " " + (tracker!.trackerName ?? "")
        }
        else if(metric != nil)
        {
            title = title + " " + (metric!.metricName ?? "")
        }
        
        charmConnectionHandeler = CharmConnectionHandler(delegate: self)
        charmConnectionHandeler?.v2Delegate = self
        self.navigationItem.title = title
        
        
        if tracker?.isDefaultTracker == true && (tracker?.trackerType == .general || tracker?.trackerType == .temperature) {
            
            if VitalUtil.getPatientVitalUnit() != nil{
                createSubViews()
            }
            else{
                fetchVitalUnit()
            }
        }
        else{
            createSubViews()
        }
    }
    
    func createSubViews(includeVitalUnit: Bool = false)
    {
        let containerScrollView = TPKeyboardAvoidingScrollView()

        
        var vitalUnitWrapperView: UIView? = nil
        
        if includeVitalUnit {
            vitalUnitWrapperView = UIView()
            vitalUnitView = AddModuleKeyAndValueView()
            
            if let vitalUnitView = vitalUnitView {
                vitalUnitWrapperView?.addSubview(vitalUnitView)
                
                vitalUnitView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
                vitalUnitView.keyLabel.text = getString(key: "com.charmphr.wellnessmetric.option.label")
                vitalUnitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(vitalUnitClicked(tapGestureRecognizer:))))
                
                vitalUnitView.addShadowAndCornerRadius(.SMALL)
                
                vitalUnitView.setTop(offSet: Y_SPACE)
                vitalUnitView.setLeft(offSet: X_SPACE)
                vitalUnitView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
            }
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addShadowAndCornerRadius(.SMALL)
       
        datePicker.preferredDatePickerStyle = .wheels
        timePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 5
        timePicker.addTarget(self, action: #selector(timePickerValueChanged(datePicker:)), for: .valueChanged)
        
        
        entryDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        entryDateView.keyLabel.text = getString(key: "com.charmphr.date.keyField")
        entryDateView.textField.tintColor = .clear
        entryDateView.textField.inputView = datePicker
        
        setDate(date: Date())
        entryDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        entryDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(entryDateView)
        
        entryTimeView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        entryTimeView.keyLabel.text = getString(key: "com.charmphr.time.keyField")
        entryTimeView.textField.tintColor = .clear
        entryTimeView.textField.inputView = timePicker
        
        setTime(date: Date())
        entryTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        entryTimeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(entryTimeView)
        
        entryDateView.setLeft(offSet: 0)
        entryDateView.setRight(offSet: 0)
        
        entryDateView.setSafeAreaTop(offset: 0)
        entryDateView.setBottomRelatedToView(offSet: 0, relatedView: entryTimeView, relatedAttribute: .top)
    
        entryTimeView.setLeft(offSet: 0)
        entryTimeView.setRight(offSet: 0)
        
        var previousView = entryTimeView
        
        if(tracker != nil && tracker?.metricList != nil && metric == nil)
        {
            var metricTag = tag
            for metric in tracker!.metricList!{
                
                metricTag = metricTag + 1
                var name = metric.metricName ?? ""
                let metricName = name.lowercased()
                
                let metricView = AddModuleKeyAndValueView()
                metricView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
                
                var isDictDataSet = false
                if metric.isDefaultMetric{
                    
                    metricView.textField.tag = tagNo
                    
                    if (metricName == HEIGHT || metricName == WEIGHT || metricName == bmi){
                        isDictDataSet = true
                        if metric.metricUnit == KG || metric.metricUnit == KGS {
                            fieldToUnitMap[tagNo] = KG
                            fieldToStringMap[metricView.textField.tag] = KG
                        }
                        else if metric.metricUnit == CMS || metric.metricUnit == CM {
                            fieldToUnitMap[tagNo] = CM
                            fieldToStringMap[metricView.textField.tag] = CM
                        }
                        else if metric.metricUnit == INCHES || metric.metricUnit == INCH  {
                            fieldToUnitMap[tagNo] = INCHES
                            fieldToStringMap[metricView.textField.tag] = INCHES
                        }
                        else if metric.metricUnit == LB || metric.metricUnit == LBS {
                            fieldToUnitMap[tagNo] = LB
                            fieldToStringMap[metricView.textField.tag] = LB
                        }
                        bmiTagList.append(tagNo)
                        metricView.textField.addTarget(self, action: #selector(onHeightWeightTextChange(textField:)), for: .editingChanged)
                    }
                    else if (metricName == Pulse_Rate){
                        isDictDataSet = true
                        fieldToStringMap[metricView.textField.tag] = Pulse_Rate
                    }
                    else if (metricName == Temperature && metric.metricUnit == Temperature_Celsius){
                        isDictDataSet = true
                        fieldToStringMap[metricView.textField.tag] = Temperature_Celsius
                    }
                    else if (metricName == Temperature && metric.metricUnit == Temperature_Fahrenheit){
                        isDictDataSet = true
                        fieldToStringMap[metricView.textField.tag] = Temperature_Fahrenheit
                    }
                    else if (metricName == BP_Systolic){
                        isDictDataSet = true
                        fieldToStringMap[metricView.textField.tag] = BP_Systolic
                    }
                    else if (metricName == BP_Diastolic){
                        isDictDataSet = true
                        fieldToStringMap[metricView.textField.tag] = BP_Diastolic
                    }
                    
                    tagList.append(tagNo)
                    tagNo = tagNo + 1
                    metricView.textField.delegate = self
                }
                
                
                if !isDictDataSet {
                    fieldToUnitMap[metricView.textField.tag] = metric.metricUnit ?? ""
                }
                
                
                if(!isNilOrEmpty(string: metric.metricUnit))
                {
                    if(metric.metricName == "Temperature"){
                        name = name + " (°" + (metric.metricUnit ?? "") + ")"
                    }
                    else{
                        name = name + " (" + (metric.metricUnit ?? "") + ")"
                    }
                }
                
                
                metricView.tag = metricTag
                metricView.keyLabel.text = name
                
                metricView.keyLabel.tag = tagNo
                tagNo = tagNo + 1
                fieldToLabelMap[metricView.textField.tag] = metricView.keyLabel.tag
                
                let unit = metric.metricUnit ?? ""
                
                if (unit == "minutes" || unit == "min") || (unit == "mins" || unit == "minute"){
                    metricView.textField.keyboardType = .numberPad
                }
                else if (unit == "percent" || unit == "percentage" || unit == "%"){
                    metricView.textField.keyboardType = .numberPad
                }
                else if(unit == "ml"){
                    metricView.textField.keyboardType = .numberPad
                }
                else if (unit == "hours" || unit == "hrs"){
                    metricView.textField.keyboardType = .numberPad
                }
                else{
                    metricView.textField.keyboardType = .decimalPad
                }
                
                metricView.textField.keyboardType = .decimalPad
               //metricView.textField.valueType = .onlyNumbers
//                metricView.textField.delegate = self
                metricView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
                metricView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
                containerView.addSubview(metricView)
                
                metricView.setLeft(offSet: 0)
                metricView.setRight(offSet: 0)
                
                previousView.setBottomRelatedToView(offSet: 0, relatedView: metricView, relatedAttribute: .top)
                previousView = metricView
                
                if(metric.isDefaultMetric && tracker?.isDefaultTracker == true && tracker?.trackerName != OTHERS)
                {
                    metricView.textField.maxLength = 4
                }
                if(tracker?.trackerType == .general && ((tracker?.isDefaultTracker) == true) )
                {
                    metricView.textField.maxLength = 5
                    
                }
                
            }
            
            previousView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)

            

            //TODO: we have to move this validations to seperate function
            if(tracker?.trackerType == .general && ((tracker?.isDefaultTracker) == true) )
            {
                let bmiView = containerView.viewWithTag(metricTag) as! AddModuleKeyAndValueView
                bmiView.isUserInteractionEnabled = false
            }
            
        }
        else if(metric != nil)
        {
            var name = metric!.metricName ?? ""
            if(!isNilOrEmpty(string: metric!.metricUnit))
            {
                name = name + " (" + metric!.metricUnit! + ")"
            }
            let metricView = AddModuleKeyAndValueView()
            metricView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
            metricView.tag = tag
            metricView.keyLabel.text = name
           
            metricView.textField.keyboardType = .numberPad
            metricView.textField.textFieldType = MDTextFieldTypeInteger
            metricView.textField.delegate = self
            metricView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
            metricView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            containerView.addSubview(metricView)
            
            metricView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)
            metricView.setLeft(offSet: 0)
            metricView.setRight(offSet: 0)
            
            
            
            
            previousView.setBottomRelatedToView(offSet: 0, relatedView: metricView, relatedAttribute: .top)
            previousView = metricView
            
            if(metric!.isDefaultMetric)
            {
                metricView.textField.maxLength = 6
            }
            
            fieldToUnitMap[metricView.textField.tag] = metric?.metricUnit ?? ""

            
            let unit = metric?.metricUnit ?? ""
            
            if (unit == "minutes" || unit == "min") || (unit == "mins" || unit == "minute"){
                metricView.textField.keyboardType = .numberPad
            }
            else if (unit == "percent" || unit == "percentage" || unit == "%"){
                metricView.textField.keyboardType = .numberPad
            }
            else if(unit == "ml"){
                metricView.textField.keyboardType = .numberPad
            }
            else if (unit == "hours" || unit == "hrs"){
                metricView.textField.keyboardType = .numberPad
            }
            else{
                metricView.textField.keyboardType = .decimalPad
            }
            
        }
        previousView.setBottom(offSet: -0)
        self.view.addSubview(containerScrollView)
        
        
        if let vitalUnitWrapperView = vitalUnitWrapperView {
            containerScrollView.addSubview(vitalUnitWrapperView)
            
            vitalUnitWrapperView.setTop(offSet: 0)
            vitalUnitWrapperView.setBottom(offSet: 0)
            vitalUnitWrapperView.setLeft(offSet: 0)
            vitalUnitWrapperView.setWidth(constant: applicationFrame.width)
            
            vitalUnitWrapperView.addSubview(containerView)
            
            if let vitalUnitView = vitalUnitView {
                containerView.setTopRelatedToView(offSet: Y_SPACE, relatedView: vitalUnitView, relatedAttribute: .bottom)
            }
            
        }
        else {
            containerScrollView.addSubview(containerView)
            containerView.setTop(offSet: 0)
        }

        
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: X_SPACE)
        containerView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[containerScrollView]-X_SPACE-|", options: [], metrics:["X_SPACE":0], views: ["containerScrollView":containerScrollView]))
        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
    }
   
    //MARK: - action calles
    
    func setDate(date : Date)
    {
        entryDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: date)
    }
    
//    func setInitialTime(){
//        let date = Date()
//        let calendar = Calendar.current
//        let reminder = calendar.component(.minute, from: date) % 5
//
//        let minutes = reminder == 0 ? 0 : 5 - reminder
//
//        let newdate = calendar.date(byAdding: .minute, value: minutes, to: date) ?? timePicker.date
//        timePicker.date = newdate
//
//        entryTimeView.textField.text = CharmUtil.getDateStringWith(date: newdate, dateFormat: charmDisplayTimeFormat)
//    }
    
    func setTime(date : Date)
    {
        let calendar = Calendar.current
        let reminder = calendar.component(.minute, from: date) % 5
        
        let minutes = reminder == 0 ? 0 : 5 - reminder

        let newdate = calendar.date(byAdding: .minute, value: minutes, to: date) ?? timePicker.date
        
        timePicker.date = newdate
        
        entryTimeView.textField.text = CharmUtil.getDateStringWith(date: newdate, dateFormat: charmDisplayTimeFormat)
        
//        entryTimeView.textField.text = CharmUtil.getDateStringWith(date: date, dateFormat: charmDisplayTimeFormat)
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func datePickerValueChanged(datePicker : UIDatePicker)
    {
        setDate(date: datePicker.date)
    }
    
    @objc func timePickerValueChanged(datePicker : UIDatePicker)
    {
        setTime(date: timePicker.date)
    }
    
    
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func doneBtnClicked()
    {
        dismissKeyboard()
        var metricJsonArr : Array<[String:Any]> = []
        let entryDate = entryDateView.textField.text
        let entryTime = entryTimeView.textField.text
        
        if(isNilOrEmpty(string: entryDate))
        {
            showMandatoryAlert(fieldName: entryDateView.keyLabel.text!)
            entryDateView.textField.becomeFirstResponder()
            return
        }
        else if(isNilOrEmpty(string: entryTime))
        {
            showMandatoryAlert(fieldName: entryTimeView.keyLabel.text!)
            entryTimeView.textField.becomeFirstResponder()
            return
        }
        else
        {
            if(tracker != nil && tracker?.metricList != nil && metric == nil)
            {
                var metricTag = tag
                var bloodSugarEmptyCount = 0
                metricJsonArr = []
                for metric in tracker!.metricList!{
                    metricTag = metricTag + 1
                    let metricDataView = containerView.viewWithTag(metricTag) as! AddModuleKeyAndValueView
                    
                    let metricVal = metricDataView.textField.text
                    if(isNilOrEmpty(string: metricVal))
                    {
                        if(tracker?.trackerType == .bloodSugar)
                        {
                            bloodSugarEmptyCount = bloodSugarEmptyCount+1
                            if(bloodSugarEmptyCount == 5)
                            {
                                showMandatoryAlert(fieldName: metricDataView.keyLabel.text! )
                                metricDataView.textField.becomeFirstResponder()
                                return
                            }
                        }
                        else{
                            showMandatoryAlert(fieldName: metricDataView.keyLabel.text! )
                            metricDataView.textField.becomeFirstResponder()
                            return
                        }
                    }
                    else
                    {
                        var metricJson : [String:Any] = [:]
                        metricJson.updateValue(metric.metricId ?? "",forKey: "metric_id")
                        metricJson.updateValue(metricVal!,forKey: "tracked_value")
                        metricJsonArr.append(metricJson)
                    }
                }
            }
            else if(metric != nil)
            {
        
                let metricDataView = containerView.viewWithTag(tag) as! AddModuleKeyAndValueView
                
                let metricVal = metricDataView.textField.text
                if(isNilOrEmpty(string: metricVal))
                {
                    showMandatoryAlert(fieldName: metricDataView.keyLabel.text! )
                    metricDataView.textField.becomeFirstResponder()
                    return
                }
                else
                {
                    var metricJson : [String:Any] = [:]
                    metricJson.updateValue(metric!.metricId ?? "",forKey: "metric_id")
                    metricJson.updateValue(metricVal!,forKey: "tracked_value")
                    metricJsonArr.append(metricJson)
                }
            }
        }
        
        let dateStr = CharmUtil.getDateStringWith(date: timePicker.date, dateFormat: PHR_DATE_API_FORMAT)
        
        let timeStr = CharmUtil.getDateStringWith(date: timePicker.date, dateFormat: "HH:mm:ss")
        
        let dateTimeStr = dateStr + " " + timeStr
        
        
        let addVital = AddVital()
        
        addVital.trackerId = tracker?.trackerId
        addVital.notes = ""
        addVital.dateStr = dateTimeStr
        addVital.metricArr = metricJsonArr
        
        
        
        
        self.addVital = addVital
        if let vitalUnitView = vitalUnitView {
            let unitVal = vitalUnitView.valueLabel.text ?? ""
            
            if unitVal.contains(vitalUnitStandard){
                saveVitalUnit(unitSystem: vitalUnitStandard)
            }
            else{
                saveVitalUnit(unitSystem: vitalUnitMetric)
            }
            
        }
        else{
            showActivityIndicator()
            charmConnectionHandeler?.addVital(addVital: addVital, identificationKey: "addVital")
        }
    }
    
    //TODO: Need to change this properly. Doing the same hack done previously to present input type
    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if let keyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
        {
            if !keyAndLabelView.textField.isHidden
            {
                keyAndLabelView.textField.becomeFirstResponder()
            }
        }
    }
    
    @objc func vitalUnitClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        let selectVC = SelectValueViewController()
        selectVC.delegate = self
        
        if unitList == nil {
            unitList = [getString(key: "com.charmphr.wellnessmetric.standard.option") , getString(key: "com.charmphr.wellnessmetric.metric.option")]
        }
        
        selectVC.arrayOfValueToBeShown = unitList ?? []
        
        selectVC.title = getString(key: "com.charmphr.wellnessmetric.option.label")
        
        
        if vitalUnitView?.valueLabel.text?.localizedCaseInsensitiveContains("Metric") == true {
            selectVC.selectedValueIndex = 1
        }
        else{
            selectVC.selectedValueIndex = 0
        }
        
        
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    func showMandatoryAlert(fieldName : String)
    {
        let alertController = UIAlertController(title: nil, message: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName)", preferredStyle: .alert)
        let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default) { (alert) in
        
        }
        alertController.addAction(okAction)
        alertController.show()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) {
                    return false
                }
        return super.canPerformAction(action, withSender: sender)
    }
    
    
    //MARK: - API Call
    
    func fetchVitalUnit() {
        showActivityIndicator()
        charmConnectionHandeler?.fetchVitalUnit(identificationKey: "vitalUnit")
    }
    
    func fetchDemographics() {
        showActivityIndicator()
        charmConnectionHandeler?.fetchDemographics(identificationKey: "fetchDemographics")
    }
    
    func saveVitalUnit(unitSystem: String) {
        showActivityIndicator()
        charmConnectionHandeler?.postVitalUnit(unitSystem: unitSystem, identificationKey: "saveVitalUnit")
    }
    
    //MARK: - charmconnection handler deletage
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
       
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
      
    }
    
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "vitalUnit" {
            if response is String {
                hideActivityIndicator()
                createSubViews()
            }
            else {
                //show
                
                let country = getSelectedPatient().postalAddress?.country ?? ""
                
                debugPrintLog("country -> \(country)")
                if country.isNotBlank() {
                    hideActivityIndicator()
                    showVitalMetricVC(countryKey: country)
                    createSubViews(includeVitalUnit: true)
                }
                else{
                    fetchDemographics()
                }
            }
        }
        else if identificationKey == "addVital"{
            hideActivityIndicator()
            if let trackerType = tracker?.trackerType {
                if trackerType == TrackerType.general || trackerType == TrackerType.bloodPressure{
                    AppDataHandler.sharedInstance().refreshVitals = true
                }
            }
            navigationController?.popViewController(animated: true)
            
            if let message = response as? String {
                delegate?.addViewControllerDataAdded(message: message)
            }
        }
        else if identificationKey == "saveVitalUnit" {
            
            if let addVital = addVital {
                charmConnectionHandeler?.addVital(addVital: addVital, identificationKey: "addVital")
            }
        }
        else if identificationKey == "fetchDemographics" {
            hideActivityIndicator()
            if let patient = response as? Patient {
                let country = patient.postalAddress?.country ?? ""
                
                showVitalMetricVC(countryKey: country)
                createSubViews(includeVitalUnit: true)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "vitalUnit" {
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.fetchVitalUnit()
            }, cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            })
        }
        else if identificationKey == "saveVitalUnit"{
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.doneBtnClicked()
            })
        }
        else if identificationKey == "addVital"{
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                if let addVital = self.addVital {
                    self.charmConnectionHandeler?.addVital(addVital: addVital, identificationKey: "addVital")
                }
            })
        }
        else if identificationKey == "fetchDemographics" {
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.fetchDemographics()
            }, cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            })
        }
        else {
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
//MARK: - BMI CALCULATION
    
    @objc func onHeightWeightTextChange(textField: UITextField) {
        
        if !bmiTagList.isEmpty{
            bmiCalculation()
        }
    }
    private func getTextField(tagVal: Int) -> UITextField?{
        
        if let textField = self.view.viewWithTag(tagVal) as? UITextField{
            return textField
        }
        return nil
    }
    private func getLabelWithTag(tagVal: Int) -> UILabel?{
        
        if let textField = self.view.viewWithTag(tagVal) as? UITextField{
            let labelTag = fieldToLabelMap[textField.tag] ?? -1
            if let label = self.view.viewWithTag(labelTag) as? UILabel{
                return label
            }
        }
        return nil
    }
    private func bmiCalculation(){
        var height: Double = 0
        var bmi: Double = 0
        
        var heightVal: Double = 0.0
        var weightVal: Double = 0.0
        
        bmiTagList.forEach(){bmiTag in
            
            let label = getLabelWithTag(tagVal: bmiTag)
            let textField = getTextField(tagVal: bmiTag)
                
            if let textInput = textField?.text?.toDoubleOrNil(){
                
                let unit = fieldToUnitMap[bmiTag]
                if (unit == KG || unit == KGS || unit == CM || unit == CMS){
                    if (unit == KG || unit == KGS){
                        weightVal = textInput
                    }
                    else { //(unit == CM || unit == CMS){
                        heightVal = textInput
                    }
                    height = heightVal / 100
                    bmi = weightVal/(height * height)
                }
                else if (unit == LB || unit == LBS || unit == INCHES || unit == INCH){
                    if (unit == LB || unit == LBS){
                        weightVal = textInput
                    }
                    else {//if (unit == INCHES){
                        heightVal = textInput
                    }
                    bmi = (weightVal/(heightVal * heightVal)) * 703.0
                }
            }
            if (label?.text?.contains(BMI) == true){
                if (bmi == 0.00){
                    textField?.text = ""
                }
                else{
                    textField?.text = "\(String(format: "%.2f", bmi))"
                }
                if (textField?.text == "nan" || textField?.text == "inf"){
                    textField?.text = ""
                }
            }
        }
    }
    
    
    private func showVitalMetricVC(countryKey: String){
        
        let wellnessVC = WellnessMetricViewController()
        
        wellnessVC.countrykey = countryKey.isNotBlank() ? countryKey : nil
        wellnessVC.delegate = self
        wellnessVC.modalTransitionStyle = .crossDissolve
        wellnessVC.modalPresentationStyle = .overFullScreen
        present(wellnessVC, animated: true)
    }
    
//MARK: - Delegate Functions
    
    func mdTextField(_ textField: MDTextField!, shouldChangeCharactersIn range: NSRange, replacementString string: String!) -> Bool {
        guard let oldText1 = textField.text, let r = Range(range, in: oldText1) else {
            return true
        }

        let newText1 = oldText1.replacingCharacters(in: r, with: string)
        let numberOfDots = newText1.components(separatedBy: ".").count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = newText1.firstIndex(of: ".") {
            numberOfDecimalDigits = newText1.distance(from: dotIndex, to: newText1.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }

        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        
        let newText = oldText.replacingCharacters(in: r, with: string)
        var maxValue: Bool = false
        
        let str = fieldToStringMap[textField.tag]
            
        if (str == KG || str == KGS){
            maxValue = Int(newText) ?? 0 <= WEIGHT_KGS
        }
        else if (str == CM || str == CMS){
            maxValue = Int(newText) ?? 0 <= HEIGHT_CMS
        }
        else if (str == INCHES || str == INCH){
            maxValue = Int(newText) ?? 0 <= HEIGHT_INCHES
        }
        else if (str == LB || str == LBS){
            maxValue = Int(newText) ?? 0 <= WEIGHT_POUNDS
        }
        else if (str == Pulse_Rate){
            maxValue = Int(newText) ?? 0 <= PULSE_RATE
        }
        else if (str == Temperature_Celsius){
            maxValue = Int(newText) ?? 0 <= CELSIUS
        }
        else if (str == Temperature_Fahrenheit){
            maxValue = Int(newText) ?? 0 <= FAHRENHEIT
        }
        else if (str == BP_Systolic){
            maxValue = Int(newText) ?? 0 <= SYSTOLIC
        }
        else if (str == BP_Diastolic){
            maxValue = Int(newText) ?? 0 <= DIASTOLIC
        }
        else{
            
            let unit = fieldToUnitMap[textField.tag]?.lowercased() ?? ""
            
            if (unit == "minutes" || unit == "min") || (unit == "mins" || unit == "minute"){
                maxValue = Int(newText) ?? 0 <= MINUTES
            }
            else if (unit == "percent" || unit == "percentage" || unit == "%"){
                maxValue = Int(newText) ?? 0 <= PERCENTAGE
            }
            else if(unit == "ml"){
                maxValue = Int(newText) ?? 0 <= MILLI_LITRE
            }
            else if (unit == "hours" || unit == "hrs"){
                maxValue = Int(newText) ?? 0 <= HOURS
            }
            else{
                maxValue = Int(newText) ?? 0 <= NUMBER_MAX_VALUE
            }
        }
        return maxValue && (numberOfDots <= 1 && numberOfDecimalDigits <= 3)
    }
    
    //MARK: - SelectValueVc delegate
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        
        let unitStr = unitList?.getElement(at: selectedRow)
        vitalUnitView?.valueLabel.text = unitStr
        
        if let metricList = tracker?.metricList {
            
            for metric in metricList{
                if metric.metricName?.contains("Weight") == true{
                    if unitStr?.contains(vitalUnitStandard) == true {
                        metric.metricUnit = LBS
                    }
                    else{
                        metric.metricUnit = KGS
                    }
                }
                else if metric.metricName?.contains("Height") == true{
                    if unitStr?.contains(vitalUnitStandard) == true {
                        metric.metricUnit = INCHES
                    }
                    else{
                        metric.metricUnit = CMS
                    }
                }
                else if metric.metricName?.contains("Temp") == true{
                    if unitStr?.contains(vitalUnitStandard) == true {
                        metric.metricUnit = Temperature_Fahrenheit
                    }
                    else{
                        metric.metricUnit = Temperature_Celsius
                    }
                }
                else if metric.metricName?.contains("BMI") == true{
                    if unitStr?.contains(vitalUnitStandard) == true {
                        metric.metricUnit = ""
                    }
                    else{
                        metric.metricUnit = "kg/m2"
                    }
                }
            }
            var metricTag = tag
            for metric in metricList{
                metricTag = metricTag + 1
                if let metricDataView = containerView.viewWithTag(metricTag) as? AddModuleKeyAndValueView {
                    
                    
                    metricDataView.textField.text = ""
                    
                    var name = metric.metricName ?? ""
                    if(!isNilOrEmpty(string: metric.metricUnit))
                    {
                        name = name + " (" + (metric.metricUnit ?? "")  + ")"
                    }
                    
                    fieldToUnitMap[metricDataView.textField.tag] = metric.metricUnit
                    fieldToStringMap[metricDataView.textField.tag] = metric.metricUnit
                    
                    metricDataView.keyLabel.text = name
                }
            }
        }
    }
    
    //MARK: - WellnessMetric VC
    
    func onWellnessUnitSelected(unit: String) {
        if unitList == nil {
            unitList = [getString(key: "com.charmphr.wellnessmetric.standard.option") , getString(key: "com.charmphr.wellnessmetric.metric.option")]
        }
        
        
        if unit == vitalUnitStandard {
            selectValueViewControllerDidSelectValue(selectedRow: 0)
        }
        else{
            selectValueViewControllerDidSelectValue(selectedRow: 1)
        }
    }
    
    //MARK: - Dismiss Modal delegate
    
    func dismissModelView() {
        
        debugPrint("DismissModelView:BaseEncounter")
        
        if let presentedVC = self.presentedViewController {
            debugPrint("DismissModelView:BaseEncounter:Present")
            NotificationCenter.default.addObserver(self, selector: #selector(makeDelay), name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
            self.presentingVC = presentedVC
            presentedVC.dismiss(animated: false)
        }
        
    }
    
    @objc func makeDelay(){
        self.perform(#selector(presentViewController), with: nil, afterDelay: 0.35)
    }
    
    @objc func presentViewController(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
        
        if let presentingVC = presentingVC {
            self.present(presentingVC, animated: true)
        }
        self.presentingVC = nil
    }
    
    
}
