//
//  AddFlowsheetEntryViewController.swift
//  phr
//
//  Created by prathi-13964 on 04/07/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit
import WebKit

class AddFlowsheetEntryViewController: UIViewController, UITextFieldDelegate, CharmConnectionHandlerDelegate, WKNavigationDelegate, UITextViewDelegate, DateTimePickerDelegate{
   
    weak var delegate: AddViewControllerDelegate? = nil
    var charmConnectionHandler : CharmConnectionHandler?

    var phrFlowsheet: PHRFlowsheets?
    var flowsheet: Flowsheets!
    
    let activityIndicator = UIActivityIndicatorView()
    var addFlowsheetEntryView: AddFlowsheetEntryView!
    
    var tagNo = 1
    var tagList: [String] = []
    var bpTagList: [String] = []
    var idList: [String] = []
    var bmiTagList: [String] = []
    var alertList: [String] = []
    var emptyAlertList: [String] = []

    var barItemToTextFieldMap = Dictionary<Int , Int>()
    var datePickerToTextFieldMap =  Dictionary<Int , Int>()
    var sliderToLabelMap =  Dictionary<Int , Int>()
    var buttonToFieldMap = Dictionary<Int , Int>()
    var fieldToHeightMap = Dictionary<Int , NSLayoutConstraint>()
    var buttonToStackMap = Dictionary<Int , Int>()
    var fieldToLabelMap = Dictionary<Int , Int>()
    var fieldToButtonMap = Dictionary<Int , Int>()
    var dateTimePickerViewController: DateTimePickerViewController?

    
    private var textFieldHeightConstraint: NSLayoutConstraint?

//MARK: - INITIALIZER
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFlowsheetEntryView = AddFlowsheetEntryView.init()
        self.view = addFlowsheetEntryView
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        
        if (phrFlowsheet != nil){
            if RbacUtil.checkPrivilege(privilege: .EDIT_FLOWSHEETDATA) && flowsheet.allowEdit{
                self.navigationItem.title = getString(key: "com.charmphr.flowsheetentry.editflowsheet.title")
            
                self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing)), animated: true)
            }
            else{
                self.navigationItem.title = getString(key: "com.charmphr.flowsheetentry.title")
                addFlowsheetEntryView.stackView.isUserInteractionEnabled = false
            }
        }
        else if RbacUtil.checkPrivilege(privilege: .ADD_FLOWSHEETDATA) && flowsheet.allowEdit{
            self.navigationItem.title = getString(key: "com.charmphr.flowsheetentry.addflowsheet.title")
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing)), animated: true)
        }
        
        if flowsheet.allowEdit{
            addFlowsheetEntryView.observedCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateTextfieldOnClick)))
            addFlowsheetEntryView.flowsheetEntryDateField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateTextfieldOnClick)))
        }
        else{
            addFlowsheetEntryView.flowsheetEntryDateField.isUserInteractionEnabled = false
            addFlowsheetEntryView.observedCard.isUserInteractionEnabled = false
        }
        setValues()
    }
    
    @objc func doneEditing(){
        
        self.view.endEditing(true)
        
        if let phrFlowsheetObj = validateData() {
            
            
            if emptyAlertList.count > 0{
                CharmUtil.createOkayAlertWith(title: nil, msg: emptyAlertList.first ?? "")
            }
            else{
                if alertList.isEmpty{
                    updateFlowsheetEntries(phrFlowsheetObj: phrFlowsheetObj)
                }
                else{
                    var dialogMessage: UIAlertController
                    if (alertList.count == 1){
                        dialogMessage = UIAlertController(title: nil, message: "\(alertList.first ?? "")\(getString(key: "com.charmphr.add_flowsheet.alert.single_item_str"))", preferredStyle: .alert)
                    }
                    else{
                        dialogMessage = UIAlertController(title: "Alert", message: getString(key: "com.charmphr.add_flowsheet.alert.multiple_item_str"), preferredStyle: .alert)
                    }
                    let yes = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.common.yes"), style: .default, handler: { [weak self] (action) -> Void in
                        self?.updateFlowsheetEntries(phrFlowsheetObj: phrFlowsheetObj)
                    })
                    let no = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.common.no"), style: .cancel) { (action) -> Void in
                        
                    }
                    dialogMessage.addAction(yes)
                    dialogMessage.addAction(no)
                    self.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func updateFlowsheetEntries(phrFlowsheetObj: PHRFlowsheets){
        showActivityIndicator()
        if self.phrFlowsheet != nil {
            self.charmConnectionHandler?.editFlowsheetEntry( phrFlowsheet: phrFlowsheetObj, identificationKey: "editFlowsheetEntry")
        }
        else{
            self.charmConnectionHandler?.addFlowsheetEntry( phrFlowsheet: phrFlowsheetObj, identificationKey: "addFlowsheetEntry")
        }
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        hideActivityIndicator()
        self.navigationController?.popViewController(animated: true)
        if let message = jsonObject.getString("message"){
            delegate?.addViewControllerDataAdded(message: message)
        }
    }

    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
// MARK: - VALIDATION
    private func validateData() -> PHRFlowsheets?{
        
        alertList = []
        emptyAlertList = []
        var emptyCheckCount = 0
        let phrFlowsheetsObj = PHRFlowsheets()
        var flowsheetEntryList: [FlowsheetEntries] = []
       
        for (index,tag) in tagList.enumerated(){
            let entryId = idList[index]
            
            if let phrFlowsheetEntry =  flowsheet?.flowsheetEntries.first(where: {phrFlowsheetEntry in
                return phrFlowsheetEntry.flowSheetEntryId == entryId
            }){
                
                let entryType = phrFlowsheetEntry.type
                if (entryType == flowsheetEntryCustom){
                    let fieldType = phrFlowsheetEntry.fieldType
                
                    if let tag = tag.toIntOrNil() {
                        if(fieldType == flowsheetCustomSingleLine || fieldType == flowsheetCustomMultiLine || fieldType == flowsheetCustomNumber || fieldType == flowsheetCustomRatingScale || fieldType == flowsheetCustomDate || fieldType == flowsheetCustomDateAndTime){
                            
                            var answer: String? = nil
                            
                            if let textField = self.view.viewWithTag(tag) as? UITextField
                            {
                                answer = textField.text
                            }
                            else if let textView = self.view.viewWithTag(tag) as? UITextView
                            {
                                answer = textView.text
                            }
                            else if let label = self.view.viewWithTag(tag) as? UILabel
                            {
                                answer = label.text
                            }
                            if(fieldType == flowsheetCustomNumber){
                                
                                if (!answer.isNilOrBlank() && answer?.isNumber() == false){
                                    if let textField = self.view.viewWithTag(tag) as? UITextField{
                                        textField.becomeFirstResponder()
                                        showAlertDialog(titleKey: "com.charmphr.flowsheetaddvc.customnumber.invalid")
                                        return nil
                                    }
                                }
                                if answer.isNilOrBlank(){
                                    emptyCheckCount += 1
                                }
                                phrFlowsheetEntry.value = answer
                                flowsheetEntryList.append(phrFlowsheetEntry)
                                
                            }
                            else if(fieldType == flowsheetCustomDateAndTime){
                                let date = Date.getDateFromString(dateFormat: FLOWSHEET_DATA_DATE_FORMAT, dateString: answer ?? "")
                                if answer.isNilOrBlank(){
                                    emptyCheckCount += 1
                                }
                                phrFlowsheetEntry.value = date?.getStringFromDate(dateFormat: sqlTimeStampFormat)
                                flowsheetEntryList.append(phrFlowsheetEntry)
                            }
                            else if(fieldType == flowsheetCustomDate){
                                let date = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: answer ?? "")
                                if answer.isNilOrBlank(){
                                    emptyCheckCount += 1
                                }
                                phrFlowsheetEntry.value = date?.getStringFromDate(dateFormat: PHR_DATE_API_FORMAT)
                                flowsheetEntryList.append(phrFlowsheetEntry)
                            }
                            else{
                                if answer.isNilOrBlank(){
                                    emptyCheckCount += 1
                                }
                                phrFlowsheetEntry.value = answer
                                flowsheetEntryList.append(phrFlowsheetEntry)
                            }
                        }
                        else if(fieldType == flowsheetCustomMultiChoice || fieldType == flowsheetCustomSingleChoice){
                            var answerList: [String] = []
                            var commentList: [String] = []
                            var buttonAnswer: String?
                            if let stackView = self.view.viewWithTag(tag) as? UIStackView{
                                
                                for view in stackView.subviews{
                                    if let button = view as? UIButton
                                    {
                                        if button.isSelected{
                                            
                                            buttonAnswer = button.title(for: .selected)
                                            answerList.append(buttonAnswer?.trimLeadingSpaces() ?? "")
                                            if phrFlowsheetEntry.addAdditionalNotes{
                                                
                                                let textFieldTag = buttonToFieldMap[button.tag] ?? -1
                                                if let textField = self.view.viewWithTag(textFieldTag) as? UITextField{
                                                    
                                                    commentList.append(textField.text ?? "")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            let answerButton = answerList.joined(separator: "\n")
                            let answerField = commentList.joined(separator: "\n")
                            if answerButton.isBlank() || answerField.isBlank(){
                                emptyCheckCount += 1
                            }
                            phrFlowsheetEntry.value = answerButton
                            phrFlowsheetEntry.comments = answerField
                            flowsheetEntryList.append(phrFlowsheetEntry)
                        }
                    }
                }
                else if(entryType == flowsheetEntryVital){
                    
                    let fieldType = phrFlowsheetEntry.fieldType
                    let entryName = phrFlowsheetEntry.name
                    
                    if(fieldType.isNilOrBlank() && entryName == flowsheetVitalBP){
                        let tagBPList = tag.split(separator: ",")
                        var answerBPList: [String] = []
                        for tagBP in tagBPList{
                            if let tag = "\(tagBP)".toIntOrNil(){
                                if let textField = self.view.viewWithTag(tag) as? UITextField{
                                    answerBPList.append(textField.text ?? "")
                                }
                            }
                        }
                        if let answer = answerBPList[0].toIntOrNil(){
                            if (answer < bpSystolicMinVal){
                                alertList.append("Systolic")
                            }
                        }
                        if let answer = answerBPList[1].toIntOrNil(){
                            if (answer > bpDiastolicMaxVal || answer < bpDiastolicMinVal){
                                alertList.append("Diastolic")
                            }
                        }
                        let answerBP = answerBPList.joined(separator: "/")
                        if answerBPList[0].isBlank() && answerBPList[1].isBlank(){
                            emptyCheckCount += 1
                        }
                        phrFlowsheetEntry.value = answerBP
                        flowsheetEntryList.append(phrFlowsheetEntry)
                    }
                    else if(fieldType.isNilOrBlank() && (entryName == flowsheetVitalWeight || entryName == flowsheetVitalHeight)){
                        var answerList: [String] = []
                        let tagStringList = tag.split(separator: ",")
                        if (tagStringList.count == 1){
                            var answer: String?
                            if let tag = "\(tagStringList.first ?? "")".toIntOrNil(){
                                if let textField = self.view.viewWithTag(tag) as? UITextField{
                                    answer = textField.text
                                }
                            }
                            if let answer = answer?.toDoubleOrNil(){
                                if(entryName == flowsheetVitalWeight){
                                    if (answer > weightMaxVal || answer < weightMinVal){
                                        alertList.append(entryName ?? "")
                                    }
                                    else{
                                        phrFlowsheetEntry.value = "\(answer)"
                                        flowsheetEntryList.append(phrFlowsheetEntry)
                                    }
                                }
                                else if(entryName == flowsheetVitalHeight){
                                    if (answer > heightMaxVal || answer < heightMinVal){
                                        alertList.append(entryName ?? "")
                                    }
                                    else{
                                        phrFlowsheetEntry.value = "\(answer)"
                                        flowsheetEntryList.append(phrFlowsheetEntry)
                                    }
                                }
                            }
                            else{
                                emptyCheckCount += 1
                            }
                        }
                        else{
                            for subString in tagStringList{
                                if let tag = "\(subString)".toIntOrNil(){
                                    if let textField = self.view.viewWithTag(tag) as? UITextField{
                                        answerList.append(textField.text ?? "")
                                    }
                                }
                            }
                            if(entryName == flowsheetVitalHeight){
                                
                                if (answerList[0].isNotBlank() || answerList[1].isNotBlank()){
                                    let inch: Double = ((Double(answerList[0]) ?? 0) * 12) + (Double(answerList[1]) ?? 0)
                                    let height:Double = inch * 2.54
                                    if (height > heightMaxVal || height < heightMinVal){
                                        alertList.append(entryName ?? "")
                                    }
                                }
                            }
                            else if(entryName == flowsheetVitalWeight){
                                if (answerList[0].isNotBlank() || answerList[1].isNotBlank()){
                                    let pounds: Double = (Double(answerList[0]) ?? 0) + ((Double(answerList[1]) ?? 0) / 16)
                                    let weight: Double = pounds / 2.205
                                    if (weight > weightMaxVal || weight < weightMinVal){
                                        alertList.append(entryName ?? "")
                                    }
                                }
                            }
                            let answer = answerList.joined(separator: ",")
                            if answerList[0].isBlank() && answerList[1].isBlank(){
                                emptyCheckCount += 1
                            }
                            phrFlowsheetEntry.value = answer
                            flowsheetEntryList.append(phrFlowsheetEntry)
                        }
                    }
                    else if let tag = tag.toIntOrNil(){
                        
                        if(entryName == flowsheetVitalPulsePattern || entryName == flowsheetVitalPulseVolume || entryName == flowsheetVitalRespirationPattern || fieldType == flowsheetVitalOption){
                            var answer: String?
                            var buttonAnswer: String?
                            if let stackView = self.view.viewWithTag(tag) as? UIStackView{
                                
                                for view in stackView.subviews{
                                    if let button = view as? UIButton
                                    {
                                        if button.isSelected
                                        {
                                            buttonAnswer = button.title(for: .selected)
                                            answer = buttonAnswer?.trimLeadingSpaces()
                                        }
                                    }
                                }
                            }
                            if answer.isNilOrBlank(){
                                emptyCheckCount += 1
                            }
                            phrFlowsheetEntry.value = answer
                            flowsheetEntryList.append(phrFlowsheetEntry)
                        }
                        else if(fieldType.isNilOrBlank() && entryName == flowsheetVitalTemperature){

                            var answerUnit: String? = nil
                            var answer: String? = nil
                            if let textField = self.view.viewWithTag(tag) as? UITextField
                            {
                                answer = textField.text
                                let buttonTag = fieldToButtonMap[textField.tag] ?? -1
                                if let button = self.view.viewWithTag(buttonTag) as? UIButton{
                                    if ((button.currentTitle?.contains("F")) == true){
                                        answerUnit = "F"
                                    }
                                    else if((button.currentTitle?.contains("C")) == true){
                                        answerUnit = "C"
                                    }
                                }
                            }
                            if (answerUnit == "F"){
                                if let answer = answer?.toDoubleOrNil() {
                                    if (answer > temperatureFahrenheitMaxVal || answer < temperatureFahrenheitMinVal){
                                        alertList.append(entryName ?? "")
                                    }
                                }
                            }
                            else if( answerUnit == "C"){
                                if let answer = answer?.toDoubleOrNil() {
                                    if (answer > temperatureCelsiusMaxVal || answer < temperatureCelsiusMinVal){
                                        alertList.append(entryName ?? "")
                                    }
                                }
                            }
                            if answerUnit.isNilOrBlank() || answer.isNilOrBlank(){
                                emptyCheckCount += 1
                            }
                            phrFlowsheetEntry.unit = answerUnit
                            phrFlowsheetEntry.value = answer
                            flowsheetEntryList.append(phrFlowsheetEntry)
                        }
                        else if(fieldType.isNilOrBlank() && (entryName == flowsheetVitalPulseRate || entryName == flowsheetVitalSPO2 || entryName == flowsheetVitalRespiratoryRate)){
                            var answer: String? = nil
                            
                            if let textField = self.view.viewWithTag(tag) as? UITextField
                            {
                                answer = textField.text
                            }
                            if(entryName == flowsheetVitalPulseRate){
                                if let answer = answer?.toIntOrNil() {
                                    if (answer > pulseRateMaxValue || answer < pulseRateMinValue){
                                        alertList.append(entryName ?? "")
                                    }
                                    phrFlowsheetEntry.value = "\(answer)"
                                    flowsheetEntryList.append(phrFlowsheetEntry)
                                }
                                else{
                                    emptyCheckCount += 1
                                }
                            }
                            else if(entryName == flowsheetVitalSPO2){
                                if let answer = answer?.toIntOrNil() {
                                    if (answer > spo2MaxValue || answer < spo2MinValue){
                                        alertList.append(entryName ?? "")
                                    }
                                    phrFlowsheetEntry.value = "\(answer)"
                                    flowsheetEntryList.append(phrFlowsheetEntry)
                                }
                                else{
                                    emptyCheckCount += 1
                                }
                            }
                            else if(entryName == flowsheetVitalRespiratoryRate){
                                if let answer = answer?.toIntOrNil() {
                                    if (answer > respiratoryRateMaxValue || answer < respiratoryRateMinValue){
                                        alertList.append(entryName ?? "")
                                    }
                                    phrFlowsheetEntry.value = "\(answer)"
                                    flowsheetEntryList.append(phrFlowsheetEntry)
                                }
                                else{
                                    emptyCheckCount += 1
                                }
                            }
                            else{
                                if answer.isNilOrBlank(){
                                    emptyCheckCount += 1
                                }
                                phrFlowsheetEntry.value = answer
                                flowsheetEntryList.append(phrFlowsheetEntry)
                            }
                        }
                        else if(fieldType.isNilOrBlank() || fieldType == flowsheetVitalPlainText || fieldType == flowsheetVitalNumber || fieldType == flowsheetVitalRatingScale){
                            var answer: String? = nil
                            
                            if let textField = self.view.viewWithTag(tag) as? UITextField
                            {
                                answer = textField.text
                            }
                            else if let label = self.view.viewWithTag(tag) as? UILabel
                            {
                                answer = label.text
                            }
                            if answer.isNilOrBlank(){
                                emptyCheckCount += 1
                            }
                            phrFlowsheetEntry.value = answer
                            flowsheetEntryList.append(phrFlowsheetEntry)
                        }
                    }
                }
                else if(entryType == flowsheetEntryLab){
                    var answer: String? = nil
                    
                    if let tag = tag.toIntOrNil(){
                        if let textField = self.view.viewWithTag(tag) as? UITextField
                        {
                            answer = textField.text
                        }
                        if answer.isNilOrBlank(){
                            emptyCheckCount += 1
                        }
                        phrFlowsheetEntry.value = answer
                        flowsheetEntryList.append(phrFlowsheetEntry)
                    }
                }
            }
        }
        
        if tagList.count == emptyCheckCount{
            emptyAlertList.append(getString(key: "com.charmphr.add_flowsheet.emptyAlert.message"))
        }
        phrFlowsheetsObj.flowsheetEntries = flowsheetEntryList
        phrFlowsheetsObj.practiceId = flowsheet.practiceId
        phrFlowsheetsObj.flowSheetId = flowsheet.flowSheetId
        let date = addFlowsheetEntryView.flowsheetEntryDateField.text
        phrFlowsheetsObj.date = Date.getDateFromString(dateFormat: FLOWSHEET_DATA_DATE_FORMAT, dateString: date ?? "")
        phrFlowsheetsObj.phrFlowsheetId = phrFlowsheet?.phrFlowsheetId
        
        return phrFlowsheetsObj
    }
    
//MARK: - SET FLOWSHEET ENTRY
    func setValues(){
        
        let today = Date()
    
        if let date = phrFlowsheet?.date{
            addFlowsheetEntryView.flowsheetEntryDateField.text = date.getStringFromDate(dateFormat: FLOWSHEET_DATA_DATE_FORMAT)
        }
        else{
            addFlowsheetEntryView.flowsheetEntryDateField.text = today.getStringFromDate(dateFormat: FLOWSHEET_DATA_DATE_FORMAT)
        }
        let groupedFlowsheetEntry = groupFlowsheet(flowsheetEntries: flowsheet.flowsheetEntries)
        groupedFlowsheetEntry.forEach{ flowsheetEntryList in
            
            if let flowsheetEntryPOJO = flowsheetEntryList.first{
                
                
                switch (flowsheetEntryPOJO.type){
                    
                case flowsheetEntryHeading:
                    createHeadingLabel(flowsheetEntry: flowsheetEntryPOJO)
                case flowsheetEntryInstruction:
                    createInstructionView(flowsheetEntry: flowsheetEntryPOJO)
                case flowsheetEntryCustom:
                    if(flowsheetEntryPOJO.fieldType == flowsheetCustomSingleLine){
                        createQuestion(flowsheetEntry: flowsheetEntryPOJO ,isSingleLine: true)
                    }
                    else if(flowsheetEntryPOJO.fieldType == flowsheetCustomMultiLine){
                        createQuestion(flowsheetEntry: flowsheetEntryPOJO ,isSingleLine: false)
                    }
                    else if(flowsheetEntryPOJO.fieldType == flowsheetCustomNumber){
                        createQuestion(flowsheetEntry: flowsheetEntryPOJO, isSingleLine: true, isNum: true)
                    }
                    else if(flowsheetEntryPOJO.fieldType == flowsheetCustomRatingScale){
                        createRatingScale(flowsheetEntry: flowsheetEntryPOJO)
                    }
                    else if(flowsheetEntryPOJO.fieldType == flowsheetCustomDate){
                        createDate(flowsheetEntry: flowsheetEntryPOJO, isWithTime: false)
                    }
                    else if(flowsheetEntryPOJO.fieldType == flowsheetCustomDateAndTime){
                        createDate(flowsheetEntry: flowsheetEntryPOJO, isWithTime: true)
                    }
                    else if(flowsheetEntryPOJO.fieldType == flowsheetCustomSingleChoice){
                        createChoice(flowsheetEntry: flowsheetEntryPOJO, isMultiple: false)
                    }
                    else if(flowsheetEntryPOJO.fieldType == flowsheetCustomMultiChoice){
                        createChoice(flowsheetEntry: flowsheetEntryPOJO, isMultiple: true)
                    }
                case flowsheetEntryVital:
                    createVitals(flowsheetEntryList: flowsheetEntryList)
                case flowsheetEntryLab:
                    createLab(flowsheetEntryList: flowsheetEntryList)
                default: break
                }
            }
        }
    }
//MARK: - HEADING LABEL
    func createHeadingLabel(flowsheetEntry: FlowsheetEntries){
        
        let typeLabel = UILabel()
        addFlowsheetEntryView.stackView.addArrangedSubview(typeLabel)

        typeLabel.numberOfLines = 0
        typeLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        typeLabel.text = flowsheetEntry.name
        typeLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        
        typeLabel.setLeft(offSet: CARD_PADDING)
        typeLabel.setRight(offSet: -CARD_PADDING)

        
    }
//MARK: - INSTRUCTION VIEW

    func createInstructionView(flowsheetEntry: FlowsheetEntries){
        
        let instructionView = UIView()
        addFlowsheetEntryView.stackView.addArrangedSubview(instructionView)
                
        instructionView.addShadowAndCornerRadius(.SMALL)
        let contentString = flowsheetEntry.name ?? ""
        let htmlString: String = """
        <!doctype html>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <html>
        <head>
        <style>
            /* Force all font sizes to 14px – overrides inline styles */
            * {
                font-size: 14px !important;
                line-height: 1.4 !important;
            }

            /* Prevent overflow issues caused by fixed widths in your HTML */
            body, html {
                margin: 0;
                padding: 0;
                max-width: 100%;
                overflow-x: hidden;
            }

            div, span, label {
                max-width: 100% !important;
                width: 100% !important;
            }
        </style>
        </head>
        <body>
            <div style="max-width: 100%; width: 100%;">
                \(contentString)
            </div>
        </body>
        </html>
        """
        
        let webView = WKWebView()
        instructionView.addSubview(webView)
        
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.loadHTMLString(htmlString, baseURL: nil)

        webView.setLeft(offSet: CARD_PADDING)
        webView.setRight(offSet: -CARD_PADDING)
        webView.setTop(offSet: 0)
        webView.setBottom(offSet: 0)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.isLoading == false {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { result, error in
                if let height = result as? CGFloat {
                    webView.setHeight(constant: height + CARD_PADDING)
                }
            }
        }
    }
    
//MARK: - QUESTION VIEW

    func createQuestion(flowsheetEntry: FlowsheetEntries, isSingleLine: Bool, isNum: Bool = false){
        
        let commonFlowsheetLayout = CommonFlowsheetLayout.init(notes: flowsheetEntry.name)
        addFlowsheetEntryView.stackView.addArrangedSubview(commonFlowsheetLayout)

        var unitLabel: UILabel?
        var questionTextField: UITextField?
        var questionTextView: UITextView?

        if isSingleLine{
            
            questionTextField = UITextField()
            commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(questionTextField ?? UITextField())
            
            textFieldSetProperty(textField: questionTextField)
            questionTextField?.delegate = self
            questionTextField?.setPadding(width: TEXTFIELD_PADDING_5)
            
            if isNum{
                questionTextField?.keyboardType = .decimalPad
            }
        }
        else{
            
            questionTextView = UITextView()
            commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(questionTextView ?? UITextView())

            questionTextView?.layer.borderWidth = BORDER_WIDTH
            questionTextView?.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
            questionTextView?.addCornerRadius(.SMALL)
            questionTextView?.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BACKGROUND_COLOR)
            questionTextView?.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
            questionTextView?.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
            questionTextView?.isScrollEnabled = false
            questionTextView?.sizeToFit()
            questionTextView?.delegate = self
        }
        
        if flowsheet.allowEdit{
            if isSingleLine{
                questionTextField?.tag = tagNo
            }
            else{
                questionTextView?.tag = tagNo
            }
            tagList.append("\(tagNo)")
            idList.append(flowsheetEntry.flowSheetEntryId ?? "")
            tagNo = tagNo + 1
        }
        else{
            if isSingleLine{
                questionTextField?.isUserInteractionEnabled = false
            }
            else{
                questionTextView?.isUserInteractionEnabled = false
            }
        }
        
        if !flowsheetEntry.unit.isNilOrBlank(){
            
            unitLabel = UILabel()
            commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(unitLabel ?? UILabel())
            unitLabelSetProperty(unitLabel: unitLabel, labelText: flowsheetEntry.unit ?? "")
        }
        
        if let unitLabel = unitLabel {
            unitLabelSetConstraints(unitLabel: unitLabel)
        }
        
        if let questionTextField = questionTextField {
            questionTextField.setLeft(offSet: CARD_PADDING)
            
            if let unitLabel = unitLabel {
                questionTextField.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: unitLabel, relatedAttribute: .left)
            }
            else{
                questionTextField.setRight(offSet: -CARD_PADDING)
            }
            questionTextField.setTop(offSet: CARD_PADDING)
            questionTextField.setBottom(offSet: -CARD_PADDING)
            questionTextField.setHeight(constant: TEXTFIELD_HEIGHT)
        }
        else if let questionTextView = questionTextView{
            questionTextView.setLeft(offSet: CARD_PADDING)
            
            if let unitLabel = unitLabel {
                questionTextView.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: unitLabel, relatedAttribute: .left)
            }
            else{
                questionTextView.setRight(offSet: -CARD_PADDING)
            }
            questionTextView.setTop(offSet: CARD_PADDING)
            questionTextView.setBottom(offSet: -CARD_PADDING)

        }
        if let phrFlowsheetEntry = getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
            if isSingleLine{
                questionTextField?.text = phrFlowsheetEntry.value
            }
            else{
                questionTextView?.text = phrFlowsheetEntry.value
            }
        }
    }
    
//MARK: - RATING SCALE
    
    func createRatingScale(flowsheetEntry: FlowsheetEntries){
        
        let commonFlowsheetLayout = CommonFlowsheetLayout.init(notes: flowsheetEntry.name)
        addFlowsheetEntryView.stackView.addArrangedSubview(commonFlowsheetLayout)
        
        let ratingSlider = UISlider()
        commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(ratingSlider)
        
        let sliderValue = UILabel()
        commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(sliderValue)
        
        let string = flowsheetEntry.option
        let ch = Character("-")
        let result = string?.split(separator: ch)
        ratingSlider.minimumValue = Float(result?[0] ?? "") ?? 0
        ratingSlider.maximumValue = Float(result?[1] ?? "") ?? 0
        ratingSlider.tintColor  = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        
        sliderValue.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        sliderValue.layer.borderWidth = BORDER_WIDTH
        sliderValue.addCornerRadius(.SMALL)
        sliderValue.textAlignment = .center
        sliderValue.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        sliderValue.setTextColor(fontcolor: TEXT_COLOR_HEAVYDARK)
        
        if let phrFlowsheetEntry = getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
            sliderValue.text = phrFlowsheetEntry.value
            if let textValue = sliderValue.text?.toFloatOrNil(){
                ratingSlider.setValue(textValue, animated: true)
            }
        }
        
        if flowsheet.allowEdit{
            sliderValue.tag = tagNo
            tagList.append("\(tagNo)")
            idList.append(flowsheetEntry.flowSheetEntryId ?? "")
            tagNo = tagNo + 1
            
            ratingSlider.tag = tagNo
            tagNo = tagNo + 1
            
            sliderToLabelMap[ratingSlider.tag] = sliderValue.tag
        }
        else{
            ratingSlider.isUserInteractionEnabled = false
        }
        
        ratingSlider.setLeft(offSet: CARD_PADDING)
        ratingSlider.setTop(offSet: CARD_PADDING)
        ratingSlider.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: sliderValue, relatedAttribute: .left)
        ratingSlider.setBottom(offSet: -CARD_PADDING)
        
        sliderValue.setRight(offSet:-CARD_PADDING)
        sliderValue.setTop(offSet: CARD_PADDING)
        sliderValue.setBottom(offSet: -CARD_PADDING)
        sliderValue.setWidth(constant: flowsheetSliderLabelSize)
        sliderValue.setHeight(constant: flowsheetSliderLabelSize)
        
        ratingSlider.addTarget(self, action: #selector(onSliderValueChange(slider:)), for: .valueChanged)
    }
    
// MARK: - DATE LABEL
    
    func createDate(flowsheetEntry: FlowsheetEntries, isWithTime: Bool){
        
        let dateLayout = UIView()
        addFlowsheetEntryView.stackView.addArrangedSubview(dateLayout)
        dateLayout.addShadowAndCornerRadius(.SMALL)
        
        let dateLabel = UILabel()
        dateLayout.addSubview(dateLabel)

        let dateValueField = DateTextField()
        dateLayout.addSubview(dateValueField)
        
        let verticalLine = UIView()
        dateLayout.addSubview(verticalLine)
        
        let icon = UIImageView(image: UIImage(named: "Calendar"))
        dateLayout.addSubview(icon)
        
        var datePicker: UIDatePicker?

        dateLabel.numberOfLines = 0
        dateLabel.text = flowsheetEntry.name
        dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        dateLabel.setTextColor(fontcolor: TEXT_COLOR_BLACK87)

        dateValueField.backgroundColor = .clear
        dateValueField.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        dateValueField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
                
        verticalLine.setBackgroundColor(bgColor: SEPARATOR_COLOR)

        if flowsheet.allowEdit{
            
            datePicker = UIDatePicker()
           
            
            dateValueField.tag = tagNo
            tagList.append("\(tagNo)")
            idList.append(flowsheetEntry.flowSheetEntryId ?? "")
            tagNo = tagNo + 1
            if !isWithTime{
                
                datePicker?.tag  = tagNo
                tagNo = tagNo + 1
                
                datePickerToTextFieldMap[datePicker?.tag ?? -1 ] = dateValueField.tag
                
                dateValueField.inputView = datePicker
                datePicker?.backgroundColor = .white
                let dateToolbar = MDDateToolbarWithDone(textField: dateValueField, parent: self)
                datePicker?.datePickerMode = .date
                datePicker?.preferredDatePickerStyle = .wheels
                
                datePicker?.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
                dateToolbar.done?.action = #selector(donedatePicker)
           
                dateToolbar.done?.tag = tagNo
                tagNo = tagNo + 1
                barItemToTextFieldMap[dateToolbar.done?.tag ?? -1] = dateValueField.tag
                dateLayout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateTextFieldTouchEvent(_:))))
            }
            else{
                dateValueField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateTimeFieldOnClick(_:))))
                dateLayout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateTimeFieldOnClick(_:))))
            }
        }
        else{
            dateLayout.isUserInteractionEnabled = false
            dateValueField.isUserInteractionEnabled = false
        }
        
        icon.setRight(offSet: -CARD_PADDING)
        icon.setCenterY()
        icon.setWidth(constant: 25)
        icon.setHeight(constant: 25)
        
        verticalLine.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: icon, relatedAttribute: .left)
        verticalLine.setTop(offSet: SEPARATOR_LINE_PADDING)
        verticalLine.setBottom(offSet: -SEPARATOR_LINE_PADDING)
        verticalLine.setWidth(constant: BORDER_WIDTH)
        
        dateLabel.setLeft(offSet: CARD_PADDING)
        dateLabel.setRight(offSet: -CARD_PADDING)
        dateLabel.setTop(offSet: CARD_PADDING)
        
        dateValueField.setLeft(offSet: CARD_PADDING)
        dateValueField.setRight(offSet: -CARD_PADDING)
        dateValueField.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: dateLabel, relatedAttribute: .bottom)
        dateValueField.setBottom(offSet: -CARD_PADDING)
        
        if let phrFlowsheetEntry = getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
            dateValueField.text = phrFlowsheetEntry.value
            setEntryDate(datePicker: datePicker ?? UIDatePicker(), dateString: phrFlowsheetEntry.value ?? "")
        }
    }
    
// MARK: - SINGLE AND MULTIPLE CHOICE
    
    func createChoice(flowsheetEntry: FlowsheetEntries, isMultiple: Bool){
        let commonFlowsheetLayout = CommonFlowsheetLayout.init(notes: flowsheetEntry.name)
        addFlowsheetEntryView.stackView.addArrangedSubview(commonFlowsheetLayout)
        
        let stackView = UIStackView()
        commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(stackView)
        
        var unitLabel: UILabel?
        
        if !flowsheetEntry.unit.isNilOrBlank(){
            
            unitLabel = UILabel()
            commonFlowsheetLayout.addSubview(unitLabel ?? UILabel())
            unitLabelSetProperty(unitLabel: unitLabel, labelText: flowsheetEntry.unit ?? "")
           
        }
        
        if let unitLabel = unitLabel {
            
            commonFlowsheetLayout.commonFlowsheetLabel.setWidth(constant: commonFlowsheetLayout.commonFlowsheetLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
            unitLabel.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: commonFlowsheetLayout.commonFlowsheetLabel, relatedAttribute: .right)
            unitLabel.setTop(offSet: CARD_PADDING)
        }
        
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.axis = .vertical
        
        stackView.setLeft(offSet: 0)
        stackView.setRight(offSet: 0)
        stackView.setTop(offSet: CARD_PADDING)
        stackView.setBottom(offSet: -CARD_PADDING)
        
        if flowsheet.allowEdit{
            stackView.tag = tagNo
            tagList.append("\(tagNo)")
            idList.append(flowsheetEntry.flowSheetEntryId ?? "")
            tagNo = tagNo + 1
        }
        else{
            stackView.isUserInteractionEnabled = false
        }
        
        let phrFlowsheetEntry: FlowsheetEntries? = getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry)
        
        
        let value = phrFlowsheetEntry?.value ?? ""
        
        let string = flowsheetEntry.option
        let ch = Character("\n")
        if let optionList = string?.split(separator: ch){
            
            for optionListObj in optionList{
                
                
                let optionButton = UIButton(type: .custom)
                stackView.addArrangedSubview(optionButton)
                
                optionButton.setTitle("  \(String(optionListObj))" , for: .normal)
                optionButton.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                optionButton.setTitleColor(.black, for: .normal)
                
//                let spacing: CGFloat = CARD_PADDING; // the amount of spacing to appear between image and title
//                optionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing);
//                optionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0);
                if isMultiple{
                    optionButton.setImage(#imageLiteral(resourceName: "CheckboxUnselected"), for: .normal)
                    optionButton.setImage(#imageLiteral(resourceName: "CheckboxSelected"), for: .selected)
                }
                else{
                    optionButton.setImage(#imageLiteral(resourceName: "RadioBtnUnselected"), for: .normal)
                    optionButton.setImage(#imageLiteral(resourceName: "RadioBtnSelected"), for: .selected)
                }
                
                optionButton.setLeft(offSet: CARD_PADDING)
                optionButton.setHeight(constant: 40)
                optionButton.setWidth(constant: optionButton.sizeThatFits(CGSize(width: 300, height: 50)).width + CARD_PADDING)
                
                
                var optionField: UITextField?
                
                if flowsheetEntry.addAdditionalNotes{
                    
                    optionField = UITextField()
                    stackView.addArrangedSubview(optionField ?? UITextField())
                    
                    optionField?.addCornerRadius(.SMALL)
                    optionField?.layer.borderWidth = 1
                    optionField?.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                    optionField?.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BORDER_COLOR).cgColor
                    optionField?.returnKeyType = .done
                    optionField?.delegate = self
                    optionField?.setPadding(width: TEXTFIELD_PADDING_5)
                   
                    if let optionField = optionField {
                        
                        optionField.setTopRelatedToView(offSet: 0, relatedView: optionButton, relatedAttribute: .bottom)
                        optionField.setLeft(offSet: 38)
                        optionField.setRight(offSet: -CARD_PADDING)
                        textFieldHeightConstraint = optionField.setAndReturnHeight(constant: 0)
                    }
                }
                
                if phrFlowsheetEntry != nil && value.isNotBlank(){
                    
                    if isMultiple{
                        
                        let fieldValueList = value.split(separator: Character("\n"))
                        if let selectedValue = fieldValueList.first(where: {fieldValue in
                            return fieldValue == optionListObj
                        }){
                            optionButton.isSelected = true
                            if flowsheetEntry.addAdditionalNotes{
                                let commentList =  (phrFlowsheetEntry?.comments ?? "").components(separatedBy: "\n")
                                let commentIndex = fieldValueList.firstIndex(of: selectedValue)
                                
                                if let commentIndex = commentIndex {
                                    
                                    textFieldHeightConstraint?.constant = TEXTFIELD_HEIGHT
                                    optionField?.text = "\(commentList.getElement(at: commentIndex) ?? "")"
                                }
                            }
                        }
                    }
                    else{
                        if (optionListObj == value){
                            optionButton.isSelected = true
                            if flowsheetEntry.addAdditionalNotes{
                                let comment = phrFlowsheetEntry?.comments ?? ""
                                textFieldHeightConstraint?.constant = TEXTFIELD_HEIGHT
                                optionField?.text = comment
                            }
                        }
                    }
                }
                
                if flowsheet.allowEdit{
                    optionButton.tag = tagNo
                    tagNo = tagNo + 1
                    buttonToStackMap[optionButton.tag] = stackView.tag
                    if let optionField = optionField {
                        optionField.tag = tagNo
                        tagNo = tagNo + 1
                        buttonToFieldMap[optionButton.tag ] = optionField.tag
                        fieldToHeightMap[optionField.tag] = textFieldHeightConstraint
                    }
                }
                if isMultiple{
                    optionButton.addTarget(self, action: #selector(optionBtbClickedMultiple(btn:)), for: .touchUpInside)
                }
                else{
                    optionButton.addTarget(self, action: #selector(optionBtbClickedSingle(btn:)), for: .touchUpInside)
                }
            }
        }
    }
    
//MARK: - LAB
    func createLab(flowsheetEntryList: [FlowsheetEntries]){
        let commonFlowsheetLayout = CommonFlowsheetLayout.init(notes: flowsheetEntryList.first?.type)
        addFlowsheetEntryView.stackView.addArrangedSubview(commonFlowsheetLayout)
        
        var prevView: UIView? = nil
        
        var hasSpace = false
        flowsheetEntryList.forEach(){ flowsheetEntry in
            
            let isLast = flowsheetEntryList.last?.flowSheetEntryId == flowsheetEntry.flowSheetEntryId
            if (flowsheetEntry.fieldType.isNilOrBlank()){
                
                let vitalView = UIView()
                commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(vitalView)
                
                let vitalLabel = UILabel()
                vitalView.addSubview(vitalLabel)
                            
                vitalLabel.text = flowsheetEntry.name
                vitalLabel.textAlignment = .left
                vitalLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                vitalLabel.numberOfLines = 0
                                
                vitalLabel.setTop(offSet: CARD_PADDING)
                vitalLabel.setLeft(offSet: 0)
                vitalLabel.setRight(offSet: 0)
                let vitalLabelWidth = vitalLabel.sizeThatFits(CGSize(width: applicationFrame.width - 40, height: 50)).width
                
                let isAboveHalf = vitalLabelWidth > APPLICATION_FRAME_WIDTH_HALF - flowsheetGridLayoutPaddingConstant
                
                let vitalLabelHeight = vitalLabel.sizeThatFits(CGSize(width: applicationFrame.width - 40, height: applicationFrame.height)).height
                
                vitalView.setRight(offSet: -CARD_PADDING)
                
                /* --> If there is space on the right side and if the label width is more than half -> Assign left to the parent
                        --> If the previous view is not nil -> Assign top to the bottom of the previous view
                        --> If the previous view is nil -> Assign top to the paren
                   --> If the label width is not more than half
                        --> If the previous view is not nil -> Assign top to the top of the previous view and left to the right of the previous view
                        --> If the previous view in nil -> Assign top to the parent */
                
                if hasSpace{
                    if (isAboveHalf){
                        vitalView.setLeft(offSet: CARD_PADDING)
                        if let prevView = prevView {
                            vitalView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevView, relatedAttribute: .bottom)
                        }
                        else{
                            vitalView.setTop(offSet: CARD_PADDING)
                        }
                    }
                    else{
                        if let prevView = prevView {
                            
                            vitalView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: prevView, relatedAttribute: .right)
                            vitalView.setTopRelatedToView(offSet: 0, relatedView: prevView, relatedAttribute: .top)
                        }
                        else{
                            vitalView.setTop(offSet: CARD_PADDING)
                        }
                    }
                }
                
                /* --> If there is no space on the right side -> Assign left to the parent
                        --> If the previous view not nil -> Assign top to the bottom of the previous view
                        --> If the previous view is nil -> Assign top to the parent */
                else{
                    vitalView.setLeft(offSet: CARD_PADDING)
                    if let prevView = prevView {
                        vitalView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevView, relatedAttribute: .bottom)
                    }
                    else{
                        vitalView.setTop(offSet: CARD_PADDING)
                    }
                }
                
                /* --> If the label width is more than half
                        --> If the label height is more than twice the font size -> View width = application frame
                        --> If the label height is not more than twice the font size -> View width = Lable width
                   --> If the label width is not more than half -> View width = Half of the application frame */
                if(isAboveHalf){
                   
                    if (vitalLabelHeight > FONT_SIZE_NORMAL * 2) {
                        vitalView.setFullGridWidth()
                    }
                    else{
                        vitalView.setWidth(constant: vitalLabelWidth)
                    }
                }
                else{
                    vitalView.setHalfGridWidth()
                }
                // Forcing hasSpace to false if the label width is more than half
                if (isAboveHalf){
                    hasSpace = false
                }
                else{
                    hasSpace = !hasSpace
                }
                prevView = vitalView
                
                if isLast{
                    vitalView.setBottom(offSet: -CARD_PADDING)
                }
                
                let commonFieldUnitView = CommonFieldUnitView(notes: flowsheetEntry.unit)
                vitalView.addSubview(commonFieldUnitView)
                                
                commonFieldUnitView.commonTextField.keyboardType = .default
                commonFieldUnitView.commonTextField.delegate = self
                commonFieldUnitView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: vitalLabel, relatedAttribute: .bottom)
                commonFieldUnitView.setConstraints()
                
                if flowsheet.allowEdit{
                    commonFieldUnitView.commonTextField.tag = tagNo
                    tagList.append("\(tagNo)")
                    idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                    tagNo = tagNo + 1
                }
                else{
                    commonFieldUnitView.commonTextField.isUserInteractionEnabled = false
                }
                
                if let phrFlowsheetEntry =  getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                    commonFieldUnitView.commonTextField.text = phrFlowsheetEntry.value
                }
            }
        }
    }
//MARK: - VITALS
    
    func createVitals(flowsheetEntryList: [FlowsheetEntries]){
        
        let commonFlowsheetLayout = CommonFlowsheetLayout.init(notes: flowsheetEntryList.first?.type)
        addFlowsheetEntryView.stackView.addArrangedSubview(commonFlowsheetLayout)
        
        
        var prevTopView: UIView? = nil
        let prevLeftView: UIView? = nil
        
        var hasSpace = false
        
        let hasBMI = flowsheetEntryList.contains(where: {flowsheetEntry in
            flowsheetEntry.fieldType.isNilOrBlank()
        }) &&
        flowsheetEntryList.contains(where: {flowsheetEntry in
            flowsheetEntry.name == flowsheetVitalHeight
        }) &&
        flowsheetEntryList.contains(where: {flowsheetEntry in
            flowsheetEntry.name == flowsheetVitalWeight
        }) &&
        flowsheetEntryList.contains(where: {flowsheetEntry in
            flowsheetEntry.name == flowsheetVitalBMI
        })
    
        flowsheetEntryList.forEach(){ flowsheetEntry in
            
            let isLast = flowsheetEntryList.last?.flowSheetEntryId == flowsheetEntry.flowSheetEntryId
            
//MARK: - Vital Rating Scale
            if(flowsheetEntry.fieldType == flowsheetVitalRatingScale){
                
                if hasSpace{
                    if let lastTag = tagList.lastOrNil(){
                        if let tagStr = lastTag.split(separator: ",").firstOrNil(){
                            if let tag = "\(tagStr)".toIntOrNil(){
                                if let prevView = self.view.viewWithTag(tag){
                                    prevTopView = prevView
                                }
                            }
                        }
                    }
                    hasSpace = false
                }
                
                let ratingView = UIView()
                commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(ratingView)

                ratingView.setRight(offSet: 0)
                ratingView.setLeft(offSet: 0)
                if let prevTopView = prevTopView {
                    ratingView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevTopView, relatedAttribute: .bottom)
                }
                else{
                    ratingView.setTop(offSet: CARD_PADDING)
                }
                if isLast{
                    ratingView.setBottom(offSet: -CARD_PADDING)
                }
                prevTopView = ratingView
                
                let ratingSlider = UISlider()
                ratingView.addSubview(ratingSlider)
                
                let sliderValue = UILabel()
                ratingView.addSubview(sliderValue)
                
                let label = UILabel()
                ratingView.addSubview(label)
                
                var horizontalLine: UIView?

                label.text = flowsheetEntry.name
                label.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                label.numberOfLines = 0
                
                label.setTop(offSet:CARD_PADDING)
                label.setLeft(offSet: CARD_PADDING)
                label.setWidth(constant: label.sizeThatFits(CGSize(width: 300, height: 50)).width)
                
                let string = flowsheetEntry.option
                let ch = Character("-")
                let result = string?.split(separator: ch)
                ratingSlider.minimumValue = Float(result?[0] ?? "") ?? 0
                ratingSlider.maximumValue = Float(result?[1] ?? "") ?? 0
                ratingSlider.tintColor  = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
                
                sliderValue.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
                sliderValue.layer.borderWidth = BORDER_WIDTH
                sliderValue.addCornerRadius(.SMALL)
                sliderValue.textAlignment = .center
                sliderValue.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
                sliderValue.setTextColor(fontcolor: TEXT_COLOR_HEAVYDARK)
                
                if let phrFlowsheetEntry = getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                    sliderValue.text = phrFlowsheetEntry.value
                    if let textValue = sliderValue.text?.toFloatOrNil(){
                        ratingSlider.setValue(textValue, animated: true)
                    }
                }
                
                sliderValue.tag = tagNo
                tagList.append("\(tagNo)")
                idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                tagNo = tagNo + 1
                
                ratingSlider.tag = tagNo
                tagNo = tagNo + 1
                
                sliderToLabelMap[ratingSlider.tag] = sliderValue.tag
                
                if !flowsheet.allowEdit{
                    ratingSlider.isUserInteractionEnabled = false
                }
               
                if !isLast{
                    horizontalLine = UIView()
                    ratingView.addSubview(horizontalLine ?? UIView())
                    horizontalLine?.setBackgroundColor(bgColor: SEPARATOR_COLOR)
                    horizontalLine?.setTopRelatedToView(offSet: 12, relatedView: sliderValue, relatedAttribute: .bottom)
                    horizontalLine?.setLeft(offSet: 0)
                    horizontalLine?.setRight(offSet: 0)
                    horizontalLine?.setBottom(offSet: 0)
                    horizontalLine?.setHeight(constant: BORDER_WIDTH)
                }
                else{
                    ratingSlider.setBottom(offSet: -CARD_PADDING)
                    sliderValue.setBottom(offSet: -CARD_PADDING)
                }
                ratingSlider.setLeft(offSet: CARD_PADDING)
                ratingSlider.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: label, relatedAttribute: .bottom)
                ratingSlider.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: sliderValue, relatedAttribute: .left)
                
                sliderValue.setRight(offSet:-CARD_PADDING)
                sliderValue.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: label, relatedAttribute: .bottom)
                sliderValue.setWidth(constant: flowsheetSliderLabelSize)
                sliderValue.setHeight(constant: flowsheetSliderLabelSize)
                
                ratingSlider.addTarget(self, action: #selector(onSliderValueChange(slider:)), for: .valueChanged)
                
            }
            
//MARK: - Vital Plain Text
            if (flowsheetEntry.fieldType == flowsheetVitalPlainText){
                
                
                let textView = UIView()
                commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(textView)
                
                var unitLabel: UILabel?

                if hasSpace{
                    if let lastTag = tagList.lastOrNil(){
                        if let tagStr = lastTag.split(separator: ",").firstOrNil(){
                            if let tag = "\(tagStr)".toIntOrNil(){
                                if let prevView = self.view.viewWithTag(tag){
                                    prevTopView = prevView
                                }
                            }
                        }
                    }
                    hasSpace = false
                }
                
                textView.setRight(offSet: 0)
                textView.setLeft(offSet: 0)
                    
                if let prevTopView = prevTopView {
                    textView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevTopView, relatedAttribute: .bottom)
                }
                else{
                    textView.setTop(offSet: CARD_PADDING)
                }
                if isLast{
                    textView.setBottom(offSet: -CARD_PADDING)
                }
                prevTopView = textView
                
                let textLabel = UILabel()
                textView.addSubview(textLabel)
                
                textLabel.text = flowsheetEntry.name
                textLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                textLabel.numberOfLines = 0

                textLabel.setLeft(offSet: CARD_PADDING)
                textLabel.setTop(offSet:CARD_PADDING)
                textLabel.setWidth(constant: textLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
                
                let plainTextField = UITextField()
                textView.addSubview(plainTextField)

                textFieldSetProperty(textField: plainTextField)
                plainTextField.setPadding(width: TEXTFIELD_PADDING_5)
                plainTextField.delegate = self
                
                plainTextField.tag = tagNo
                tagList.append("\(tagNo)")
                idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                tagNo = tagNo + 1
                
                if !flowsheet.allowEdit{
                    plainTextField.isUserInteractionEnabled = false
                }
                
                if !flowsheetEntry.unit.isNilOrBlank(){
                    
                    unitLabel = UILabel()
                    textView.addSubview(unitLabel ?? UILabel())
                    unitLabelSetProperty(unitLabel: unitLabel, labelText: flowsheetEntry.unit ?? "")
                }
                
                if let unitLabel = unitLabel {
                    unitLabelSetConstraints(unitLabel: unitLabel)
                }
                plainTextField.setLeft(offSet: CARD_PADDING)
                
                if let unitLabel = unitLabel {
                    plainTextField.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: unitLabel, relatedAttribute: .left)
                }
                else{
                    plainTextField.setRight(offSet: -CARD_PADDING)
                }
                plainTextField.setTopRelatedToView(offSet: CARD_PADDING, relatedView: textLabel, relatedAttribute: .bottom)
                plainTextField.setBottom(offSet: -ITEM_VERTICAL_MARGIN)
                plainTextField.setHeight(constant: TEXTFIELD_HEIGHT)
                
                if let phrFlowsheetEntry =  getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                    plainTextField.text = phrFlowsheetEntry.value
                }
            }
            
//MARK: - Vital Number
            if (flowsheetEntry.fieldType == flowsheetVitalNumber){
                
                let vitalView = UIView()
                commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(vitalView)
                
                vitalView.setRight(offSet: -CARD_PADDING)
                
                
                if hasSpace{
                    if let prevLeftView = prevLeftView {
                        vitalView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: prevLeftView, relatedAttribute: .right)
                    }
                }
                else{
                    vitalView.setLeft(offSet: CARD_PADDING)
                }
                if let prevTopView = prevTopView {
                    vitalView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevTopView, relatedAttribute: .bottom)
                }
                else{
                    vitalView.setTop(offSet: CARD_PADDING)
                }
                
                hasSpace = !hasSpace
                
                if !hasSpace{
                    prevTopView = vitalView
                }
                if isLast{
                    vitalView.setBottom(offSet: -CARD_PADDING)
                }
                vitalView.setHalfGridWidth()
                
                let vitalLabel = UILabel()
                vitalView.addSubview(vitalLabel)
                
                vitalLabel.text = flowsheetEntry.name
                vitalLabel.textAlignment = .left
                vitalLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                vitalLabel.numberOfLines = 0
                
                vitalLabel.setTop(offSet: CARD_PADDING)
                vitalLabel.setLeft(offSet: 0)
                vitalLabel.setWidth(constant: vitalLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
            
                let commonFieldUnitView = CommonFieldUnitView(notes: flowsheetEntry.unit)
                vitalView.addSubview(commonFieldUnitView)
                
                commonFieldUnitView.commonTextField.delegate = self
                
                if (flowsheetEntry.unit == "minutes" || flowsheetEntry.unit == "min"){
                    commonFieldUnitView.commonTextField.keyboardType = .numberPad
                }
                else if (flowsheetEntry.unit == "percent" || flowsheetEntry.unit == "percentage" || flowsheetEntry.unit == "%"){
                    commonFieldUnitView.commonTextField.keyboardType = .numberPad
                }
                else if(flowsheetEntry.unit == "ml"){
                    commonFieldUnitView.commonTextField.keyboardType = .numberPad
                }
                else if (flowsheetEntry.unit == "hours" || flowsheetEntry.unit == "hrs"){
                    commonFieldUnitView.commonTextField.keyboardType = .numberPad
                }
                else if(flowsheetEntry.unit == "calories"){
                    commonFieldUnitView.commonTextField.keyboardType = .decimalPad
                }
                else{
                    commonFieldUnitView.commonTextField.keyboardType = .decimalPad
                }
                
                
                commonFieldUnitView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: vitalLabel, relatedAttribute: .bottom)
                commonFieldUnitView.setConstraints()
                
                commonFieldUnitView.commonTextField.tag = tagNo
                tagList.append("\(tagNo)")
                idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                tagNo = tagNo + 1
                
                commonFieldUnitView.commonUnitLabel.tag = tagNo
                tagNo = tagNo + 1
                fieldToLabelMap[commonFieldUnitView.commonTextField.tag] = commonFieldUnitView.commonUnitLabel.tag
                
                if !flowsheet.allowEdit{
                    commonFieldUnitView.commonTextField.isUserInteractionEnabled = false
                }
               
                if let phrFlowsheetEntry =  getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                    commonFieldUnitView.commonTextField.text = phrFlowsheetEntry.value
                }
            }
//MARK: - Vital Options

            if(!flowsheetEntry.option.isNilOrBlank() && (flowsheetEntry.name == flowsheetVitalPulsePattern || flowsheetEntry.name == flowsheetVitalPulseVolume || flowsheetEntry.name == flowsheetVitalRespirationPattern || flowsheetEntry.fieldType == flowsheetVitalOption)){
                
                let optionView = UIView()
                commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(optionView)

                if hasSpace{
                    if let lastTag = tagList.lastOrNil(){
                        if let tagStr = lastTag.split(separator: ",").firstOrNil(){
                            if let tag = "\(tagStr)".toIntOrNil(){
                                if let prevView = self.view.viewWithTag(tag){
                                    prevTopView = prevView
                                }
                            }
                        }
                    }
                    hasSpace = false
                }
                
                optionView.setRight(offSet: 0)
                optionView.setLeft(offSet: 0)
                    
                if let prevTopView = prevTopView {
                    optionView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevTopView, relatedAttribute: .bottom)
                }
                else{
                    optionView.setTop(offSet: CARD_PADDING)
                }
            
                if isLast{
                    optionView.setBottom(offSet: -CARD_PADDING)
                }
                
                prevTopView = optionView
                
                let stackView = UIStackView()
                optionView.addSubview(stackView)
                
                stackView.distribution = .fill
                stackView.spacing = 4
                stackView.axis = .vertical
                
                let label = UILabel()
                stackView.addArrangedSubview(label)

                label.text = flowsheetEntry.name
                label.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
                label.numberOfLines = 0

                
                label.setTop(offSet:CARD_PADDING)
                label.setLeft(offSet: CARD_PADDING)
                label.setWidth(constant: label.sizeThatFits(CGSize(width: 300, height: 50)).width)

                var unitLabel: UILabel?
                
                if !flowsheetEntry.unit.isNilOrBlank(){
                    
                    unitLabel = UILabel()
                    
                    stackView.addSubview(unitLabel ?? UILabel())
                    unitLabelSetProperty(unitLabel: unitLabel, labelText: flowsheetEntry.unit ?? "")
                }
                
                if let unitLabel = unitLabel {
                    
                    label.setWidth(constant: label.sizeThatFits(CGSize(width: 300, height: 50)).width)
                    unitLabel.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: label, relatedAttribute: .right)
                    unitLabel.setTop(offSet: CARD_PADDING)
                }
                
                
                stackView.setLeft(offSet: 0)
                stackView.setRight(offSet: 0)
                stackView.setTop(offSet: 0)
                stackView.setBottom(offSet: 0)
                
                stackView.tag = tagNo
                tagList.append("\(tagNo)")
                idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                tagNo = tagNo + 1
                
                if !flowsheet.allowEdit{
                    stackView.isUserInteractionEnabled = false
                }
                
                let string = flowsheetEntry.option
                let ch = Character("\n")
                if let optionList = string?.split(separator: ch){
                    
                    for optionListObj in optionList{
                        
                        let optionButton = UIButton(type: .custom)
                        stackView.addArrangedSubview(optionButton)
                
                        optionButton.setTitle("  \(String(optionListObj))" , for: .normal)
                        optionButton.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                        optionButton.setTitleColor(.black, for: .normal)
                       
                        optionButton.setImage(#imageLiteral(resourceName: "RadioBtnUnselected"), for: .normal)
                        optionButton.setImage(#imageLiteral(resourceName: "RadioBtnSelected"), for: .selected)
                        
                        optionButton.setLeft(offSet: CARD_PADDING)
                        //optionButton.setTopRelatedToView(offSet: 0, relatedView: label, relatedAttribute: .bottom)
                        optionButton.setHeight(constant: 32)
                        optionButton.setWidth(constant: optionButton.sizeThatFits(CGSize(width: 300, height: 50)).width)
                        
                        optionButton.tag = tagNo
                        tagNo = tagNo + 1
                        buttonToStackMap[optionButton.tag] = stackView.tag
                       
                        optionButton.addTarget(self, action: #selector(vitalOptionBtnClicked(btn:)), for: .touchUpInside)
                      
                        if let phrFlowsheetEntry = getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                            if let fieldValue = phrFlowsheetEntry.value{
                                if (optionListObj == fieldValue){
                                    optionButton.isSelected = true
                                }
                            }
                        }
                    }
                }
            }
            if(flowsheetEntry.fieldType.isNilOrBlank()){
//MARK: - Hieght And Weight
                if(flowsheetEntry.name == flowsheetVitalHeight || flowsheetEntry.name == flowsheetVitalWeight){
                    
                    var isFirst = true
                    let string = flowsheetEntry.unit
                    let ch = Character(",")
                    if let unitList = string?.split(separator: ch){
                        
                        if (unitList.count == 1){
                            
                            let vitalView = UIView()
                            commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(vitalView)
                                    
                            vitalView.setRight(offSet: -CARD_PADDING)
                            if hasSpace{
                                if let prevLeftView = prevLeftView {
                                    vitalView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: prevLeftView, relatedAttribute: .right)
                                }
                            }
                            else{
                                vitalView.setLeft(offSet: CARD_PADDING)
                            }
                            if let prevTopView = prevTopView {
                                vitalView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevTopView, relatedAttribute: .bottom)
                            }
                            else{
                                vitalView.setTop(offSet: CARD_PADDING)
                            }
                                            
                            hasSpace = !hasSpace
                                    
                            if !hasSpace{
                                prevTopView = vitalView
                            }
                            if isLast{
                                vitalView.setBottom(offSet: -CARD_PADDING)
                            }
                            vitalView.setHalfGridWidth()
                                            
                            let vitalLabel = UILabel()
                            vitalView.addSubview(vitalLabel)
                                        
                            vitalLabel.text = flowsheetEntry.name
                            vitalLabel.textAlignment = .left
                            vitalLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                            vitalLabel.numberOfLines = 0
                                            
                            vitalLabel.setTop(offSet: CARD_PADDING)
                            vitalLabel.setLeft(offSet: 0)
                            vitalLabel.setWidth(constant: vitalLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
                            
                            let commonFieldUnitView = CommonFieldUnitView(notes: flowsheetEntry.unit)
                            vitalView.addSubview(commonFieldUnitView)
                            
                            commonFieldUnitView.commonTextField.delegate = self
                            if (flowsheetEntry.unit == KG || flowsheetEntry.unit == KGS){
                                commonFieldUnitView.commonTextField.keyboardType = .decimalPad
                            }
                            else{
                                commonFieldUnitView.commonTextField.keyboardType = .numberPad
                            }
                            commonFieldUnitView.setTopRelatedToView(offSet: 8, relatedView: vitalLabel, relatedAttribute: .bottom)
                            commonFieldUnitView.setConstraints()
                            
                            commonFieldUnitView.commonTextField.addTarget(self, action: #selector(onHeightWeightTextChange(textField:)), for: .editingChanged)
                            
                            commonFieldUnitView.commonTextField.tag = tagNo
                            tagList.append("\(tagNo)")
                            idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                            if hasBMI{
                                bmiTagList.append("\(tagNo)")
                            }
                            tagNo = tagNo + 1
                            
                            commonFieldUnitView.commonUnitLabel.tag = tagNo
                            tagNo = tagNo + 1
                            fieldToLabelMap[commonFieldUnitView.commonTextField.tag] = commonFieldUnitView.commonUnitLabel.tag
                            
                            if !flowsheet.allowEdit{
                                commonFieldUnitView.commonTextField.isUserInteractionEnabled = false
                            }
                            
                            if let phrFlowsheetEntry =  getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                                commonFieldUnitView.commonTextField.text = phrFlowsheetEntry.value
                            }
                            
                        }
                        else{
                            var unitTagList: [String] = []
                            var i = 0
                            for unitListObj in unitList {
                                
                                let vitalView = UIView()
                                commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(vitalView)
                                
                                vitalView.setRight(offSet: -CARD_PADDING)
                                if hasSpace{
                                    if let prevLeftView = prevLeftView {
                                        vitalView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: prevLeftView, relatedAttribute: .right)
                                    }
                                }
                                else{
                                    vitalView.setLeft(offSet: CARD_PADDING)
                                }
                                if let prevTopView = prevTopView {
                                    vitalView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevTopView, relatedAttribute: .bottom)
                                }
                                else{
                                    vitalView.setTop(offSet: CARD_PADDING)
                                }
                                
                                hasSpace = !hasSpace
                                
                                if !hasSpace{
                                    prevTopView = vitalView
                                }
                                if isLast{
                                    vitalView.setBottom(offSet: -CARD_PADDING)
                                }
                                vitalView.setHalfGridWidth()
                                
                                let vitalLabel = UILabel()
                                vitalView.addSubview(vitalLabel)
                                
                                vitalLabel.text = flowsheetEntry.name
                                vitalLabel.textAlignment = .left
                                vitalLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                                vitalLabel.numberOfLines = 0
                                if(!isFirst){
                                    vitalLabel.isHidden = true
                                }
                                else{
                                    isFirst = false
                                }
                                
                                vitalLabel.setTop(offSet: CARD_PADDING)
                                vitalLabel.setLeft(offSet: 0)
                                vitalLabel.setWidth(constant: vitalLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
                                
                                let commonFieldUnitView = CommonFieldUnitView(notes: String(unitListObj))
                                vitalView.addSubview(commonFieldUnitView)
                                
                                commonFieldUnitView.commonTextField.delegate = self
                                commonFieldUnitView.commonTextField.keyboardType = .numberPad
                                
                                commonFieldUnitView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: vitalLabel, relatedAttribute: .bottom)
                                commonFieldUnitView.setConstraints()
                                
                                commonFieldUnitView.commonTextField.tag = tagNo
                                unitTagList.append("\(tagNo)")
                                tagNo = tagNo + 1
                                
                                commonFieldUnitView.commonUnitLabel.tag = tagNo
                                tagNo = tagNo + 1
                                fieldToLabelMap[commonFieldUnitView.commonTextField.tag] = commonFieldUnitView.commonUnitLabel.tag
                                
                                if !flowsheet.allowEdit{
                                    commonFieldUnitView.commonTextField.isUserInteractionEnabled = false
                                }
                               
                                if(unitListObj == INCHES || unitListObj == OUNCES || unitListObj == FEET || unitListObj == POUNDS){
                                    commonFieldUnitView.commonTextField.addTarget(self, action: #selector(onHeightWeightTextChange(textField:)), for: .editingChanged)
                                }
                                if let phrFlowsheetEntry =  getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                                    let string = phrFlowsheetEntry.value
                                    let ch = Character(",")
                                    if let valueList = string?.split(separator: ch){
                                        if (valueList.count == 1){
                                            if(i == 0){
                                                commonFieldUnitView.commonTextField.text = "\(valueList[0])"
                                            }
                                            else{
                                                commonFieldUnitView.commonTextField.text = ""
                                            }
                                        }
                                        else if (valueList.count > 1){
                                            commonFieldUnitView.commonTextField.text = "\(valueList[i])"
                                        }
                                    }
                                    i = i + 1
                                }
                            }
                            let tag = unitTagList.joined(separator: ",")
                            tagList.append(tag)
                            idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                            if hasBMI{
                                bmiTagList.append(tag)
                            }
                        }
                    }
                }
//MARK: - Vital BP
                else if(flowsheetEntry.name == flowsheetVitalBP){
                    
                    let bpView = UIView()
                    commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(bpView)
                    
                    if hasSpace{
                        if let lastTag = tagList.lastOrNil(){
                            if let tagStr = lastTag.split(separator: ",").firstOrNil(){
                                if let tag = "\(tagStr)".toIntOrNil(){
                                    if let prevView = self.view.viewWithTag(tag){
                                        prevTopView = prevView
                                    }
                                }
                            }
                        }
                        hasSpace = false
                    }
                    
                    bpView.setRight(offSet: 0)
                    bpView.setLeft(offSet: 0)
                    
                    if let prevTopView = prevTopView {
                        bpView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevTopView, relatedAttribute: .bottom)
                    }
                    else{
                        bpView.setTop(offSet: CARD_PADDING)
                    }
                    
                    if isLast{
                        bpView.setBottom(offSet: -CARD_PADDING)
                    }
                    prevTopView = bpView
                    
                    let bpLabel = UILabel()
                    bpView.addSubview(bpLabel)
                    
                    bpLabel.text = "Blood Pressure"
                    bpLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
                    bpLabel.numberOfLines = 0

                    
                    bpLabel.setTop(offSet:CARD_PADDING)
                    bpLabel.setLeft(offSet: CARD_PADDING)
                    bpLabel.setWidth(constant: bpLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
                
                    let systolicLabel = UILabel()
                    bpView.addSubview(systolicLabel)

                    systolicLabel.text = "Systolic"
                    systolicLabel.textAlignment = .left
                    systolicLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                    systolicLabel.numberOfLines = 0

                    systolicLabel.setTopRelatedToView(offSet: CARD_PADDING, relatedView: bpLabel, relatedAttribute: .bottom)
                    systolicLabel.setLeft(offSet: CARD_PADDING)
                    systolicLabel.setHalfGridWidth()

                    let systolicView = CommonFieldUnitView(notes: flowsheetEntry.unit)
                    bpView.addSubview(systolicView)
                    
                    systolicView.commonTextField.delegate = self
                    systolicView.commonTextField.keyboardType = .numberPad
                    
                    systolicView.setLeft(offSet: CARD_PADDING)
                    systolicView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: systolicLabel, relatedAttribute: .bottom)
                    systolicView.setBottom(offSet: 0)
                    systolicView.setHalfGridWidth()
                    systolicView.setHeight(constant: 40)
            
                    let diastolicLabel = UILabel()
                    bpView.addSubview(diastolicLabel)

                    diastolicLabel.text = "Diastolic"
                    diastolicLabel.textAlignment = .left
                    diastolicLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                    diastolicLabel.numberOfLines = 0

                    diastolicLabel.setTopRelatedToView(offSet: CARD_PADDING, relatedView: bpLabel, relatedAttribute: .bottom)
                    diastolicLabel.setRight(offSet: -CARD_PADDING)
                    diastolicLabel.setLeftRelatedToView(offSet: 0, relatedView: systolicLabel, relatedAttribute: .right)
                    diastolicLabel.setHalfGridWidth()
                    
                    let diastolicView = CommonFieldUnitView(notes: flowsheetEntry.unit)
                    bpView.addSubview(diastolicView)
                    
                    diastolicView.commonTextField.delegate = self
                    diastolicView.commonTextField.keyboardType = .numberPad
                    
                    diastolicView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: systolicView, relatedAttribute: .right)
                    diastolicView.setRight(offSet: -CARD_PADDING)
                    diastolicView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: diastolicLabel, relatedAttribute: .bottom)
                    diastolicView.setBottom(offSet: 0)
                    diastolicView.setHalfGridWidth()
                    diastolicView.setHeight(constant: 40)

                    systolicView.commonTextField.tag = tagNo
                    bpTagList.append("\(tagNo)")
                    tagNo = tagNo + 1
                    
                    systolicLabel.tag = tagNo
                    tagNo = tagNo + 1
                    fieldToLabelMap[systolicView.commonTextField.tag] = systolicLabel.tag
                   
                    diastolicView.commonTextField.tag = tagNo
                    bpTagList.append("\(tagNo)")
                    tagNo = tagNo + 1
                    
                    diastolicLabel.tag = tagNo
                    tagNo = tagNo + 1
                    fieldToLabelMap[diastolicView.commonTextField.tag] = diastolicLabel.tag
                    
                    let tag = bpTagList.joined(separator: ",")
                    tagList.append(tag)
                    idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                    
                    if !flowsheet.allowEdit{
                        systolicView.commonTextField.isUserInteractionEnabled = false
                        diastolicView.commonTextField.isUserInteractionEnabled = false
                    }
                    
                    if let phrFlowsheetEntry =  getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                        let string = phrFlowsheetEntry.value
                        if let valueList = string?.components(separatedBy: "/"){
                            if valueList.count > 0{
                                systolicView.commonTextField.text = String(valueList[0])
                                diastolicView.commonTextField.text = String(valueList[1])
                            }
                        }
                    }
                }
//MARK: - Other Vitals
                else if(flowsheetEntry.name == flowsheetVitalBMI || flowsheetEntry.name == flowsheetVitalSPO2 || flowsheetEntry.name == flowsheetVitalPulseRate || flowsheetEntry.name == flowsheetVitalTemperature || flowsheetEntry.name == flowsheetVitalChest || flowsheetEntry.name == flowsheetVitalWaist || flowsheetEntry.name == flowsheetVitalRespiratoryRate || flowsheetEntry.name == flowsheetVitalHeadCircumference){
                                    
                    let vitalView = UIView()
                    commonFlowsheetLayout.commonFlowsheetMainLayout.addSubview(vitalView)
                            
                    vitalView.setRight(offSet: -CARD_PADDING)
                    if hasSpace{
                        if let prevLeftView = prevLeftView {
                            vitalView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: prevLeftView, relatedAttribute: .right)
                        }
                    }
                    else{
                        vitalView.setLeft(offSet: CARD_PADDING)
                    }
                    if let prevTopView = prevTopView {
                        vitalView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: prevTopView, relatedAttribute: .bottom)
                    }
                    else{
                        vitalView.setTop(offSet: CARD_PADDING)
                    }
                    hasSpace = !hasSpace
                            
                    if !hasSpace{
                        prevTopView = vitalView
                    }
                    
                    if isLast{
                        vitalView.setBottom(offSet: -CARD_PADDING)
                    }
                    vitalView.setHalfGridWidth()
                                    
                    let vitalLabel = UILabel()
                    vitalView.addSubview(vitalLabel)
                                
                    vitalLabel.text = flowsheetEntry.name
                    vitalLabel.textAlignment = .left
                    vitalLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                    vitalLabel.numberOfLines = 0
                                    
                    vitalLabel.setTop(offSet: CARD_PADDING)
                    vitalLabel.setLeft(offSet: 0)
                    vitalLabel.setWidth(constant: vitalLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
                    
                    let commonFieldUnitView = CommonFieldUnitView(notes: flowsheetEntry.unit)
                    vitalView.addSubview(commonFieldUnitView)
                    
                    commonFieldUnitView.commonTextField.delegate = self
                    commonFieldUnitView.commonTextField.keyboardType = .numberPad
                    
                    if (flowsheetEntry.name == flowsheetVitalBMI){
                        commonFieldUnitView.commonTextField.isUserInteractionEnabled = false
                    }
                    
                    if (flowsheetEntry.name == flowsheetVitalTemperature){
                        commonFieldUnitView.commonUnitLabel.isHidden = true
                        commonFieldUnitView.commonTextField.keyboardType = .decimalPad
                        
                        let unitButton = UIButton()
                        commonFieldUnitView.addSubview(unitButton)
                        
                        if (phrFlowsheet == nil){
                            unitButton.setTitle("°F", for: .normal)
                        }
                        else{
                            if let phrFlowsheetEntry =  getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                                let unit = phrFlowsheetEntry.unit
                                if(!unit.isNilOrBlank()){
                                    unitButton.setTitle("°\(unit ?? "")", for: .normal)
                                }
                                else{
                                    unitButton.setTitle("°F", for: .normal)
                                }
                            }
                            else{
                                unitButton.setTitle("°F", for: .normal)
                            }
                        }
                        
                        unitButton.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                        unitButton.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87), for: .normal)
                        unitButton.titleLabel?.textAlignment = .center
                        unitButton.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: FLOWSHEET_UNIT_BG)
                        
                        let fahrenheit = UIAction(title: "°F") { (action) in
                            if(unitButton.currentTitle == "°C"){
                                if !commonFieldUnitView.commonTextField.text.isNilOrBlank(){
                                    commonFieldUnitView.commonTextField.text = self.celsiusToFahrenheit(val: commonFieldUnitView.commonTextField.text?.toDoubleOrNil() ?? 0)
                                }
                                else{
                                    commonFieldUnitView.commonTextField.text = ""
                                }
                            }
                            unitButton.setTitle("°F", for: .normal)
                        }
                        let celsius = UIAction(title: "°C") { (action) in
                            if(unitButton.currentTitle == "°F"){
                                if !commonFieldUnitView.commonTextField.text.isNilOrBlank(){
                                    commonFieldUnitView.commonTextField.text = self.fahrenheitToCelsius(val: commonFieldUnitView.commonTextField.text?.toDoubleOrNil() ?? 0)
                                }
                                else{
                                    commonFieldUnitView.commonTextField.text = ""
                                }
                            }
                            unitButton.setTitle("°C", for: .normal)
                        }
                        let menu = UIMenu(title: "", options: .displayInline, children: [fahrenheit , celsius])

                        unitButton.menu = menu
                        unitButton.showsMenuAsPrimaryAction = true
                        
                        unitButton.setLeftRelatedToView(offSet: 8, relatedView: commonFieldUnitView.commonTextField, relatedAttribute: .right)
                        unitButton.setRight(offSet: 0)
                        unitButton.setTop(offSet: 0)
                        unitButton.setWidth(constant: 60)
                        unitButton.setBottom(offSet: 0)
                        
                        commonFieldUnitView.commonTextField.tag = tagNo
                        tagList.append("\(tagNo)")
                        idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                        tagNo = tagNo + 1
                        
                        unitButton.tag = tagNo
                        tagNo = tagNo + 1
                        fieldToButtonMap[commonFieldUnitView.commonTextField.tag] = unitButton.tag
                        buttonToFieldMap[unitButton.tag] = commonFieldUnitView.commonTextField.tag
                        
                        if !flowsheet.allowEdit{
                            commonFieldUnitView.commonTextField.isUserInteractionEnabled = false
                            unitButton.isUserInteractionEnabled = false
                        }
                    }
                    else{
                        
                        commonFieldUnitView.commonTextField.tag = tagNo
                        tagList.append("\(tagNo)")
                        
                        if (flowsheetEntry.name == flowsheetVitalBMI){
                            if hasBMI{
                                bmiTagList.append("\(tagNo)")
                            }
                        }
                        idList.append(flowsheetEntry.flowSheetEntryId ?? "")
                        tagNo = tagNo + 1
                        
                        if !flowsheet.allowEdit{
                            commonFieldUnitView.commonTextField.isUserInteractionEnabled = false
                        }
                    }
                    vitalLabel.tag = tagNo
                    tagNo = tagNo + 1
                    fieldToLabelMap[commonFieldUnitView.commonTextField.tag] = vitalLabel.tag
                    
                    commonFieldUnitView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: vitalLabel, relatedAttribute: .bottom)
                    commonFieldUnitView.setConstraints()
                    
                    if let phrFlowsheetEntry =  getPHRFlowsheetEntry(flowsheetEntry: flowsheetEntry){
                        commonFieldUnitView.commonTextField.text = phrFlowsheetEntry.value
                    }
                }
            }
        }
    }
// MARK: - DELEGATE
    
    func dateTimePickerDelegateDoneAction(datePickerString: String, tag: Int? ) {        
        if let dateTag = tag {
            if let textField = self.view.viewWithTag(dateTag) as? UITextField{
                textField.text = datePickerString
            }
        }
        else{
            addFlowsheetEntryView.flowsheetEntryDateField.text = datePickerString
        }
        self.view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 500
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

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

        let label = getLabel(textField: textField)
        if (label?.text == "Systolic" || label?.text == flowsheetVitalHeadCircumference || label?.text == flowsheetVitalPulseRate || label?.text == flowsheetVitalChest || label?.text == flowsheetVitalWaist){

            maxValue = Int(newText) ?? 0 <= 200
        }
        else if (label?.text == "Diastolic"){
            maxValue = Int(newText) ?? 0 <= DIASTOLIC
        }
        else if (label?.text == flowsheetVitalSPO2){
            maxValue = Int(newText) ?? 0 <= SPO2
        }
        else if (label?.text == FEET){
            maxValue = Int(newText) ?? 0 <= HEIGHT_FEET
        }
        else if(label?.text == INCHES){
            maxValue = Int(newText) ?? 0 <= HEIGHT_INCH
        }
        else if (label?.text == POUNDS){
            maxValue = Int(newText) ?? 0 <= WEIGHT_POUNDS
        }
        else if (label?.text == OUNCES){
            maxValue = Int(newText) ?? 0 <= WEIGHT_OUNCES
        }
        else if (label?.text == CM || label?.text == CMS){
            maxValue = Int(newText) ?? 0 <= HEIGHT_CMS
        }
        else if (label?.text == KG || label?.text == KGS){
            maxValue = Int(newText) ?? 0 <= WEIGHT_KGS
        }
        else if (label?.text == flowsheetVitalTemperature){
            let buttonTag = fieldToButtonMap[textField.tag] ?? -1
            if let button = self.view.viewWithTag(buttonTag) as? UIButton{
                if (button.currentTitle == "°F"){
                    maxValue = Int(newText) ?? 0 <= FAHRENHEIT
                }
                else if (button.currentTitle == "°C"){
                    maxValue = Int(newText) ?? 0 <= CELSIUS
                }
            }
        }
        else if (label?.text == flowsheetVitalRespiratoryRate){
            maxValue = Int(newText) ?? 0 <= RESPIRATORY_RATE
        }
        else if (label?.text == "minutes" || label?.text == "min") || (label?.text == "mins"){
            maxValue = Int(newText) ?? 0 <= MINUTES
        }
        else if (label?.text == "percent" || label?.text == "percentage" || label?.text == "%"){
            maxValue = Int(newText) ?? 0 <= PERCENTAGE
        }
        else if(label?.text == "ml"){
            maxValue = Int(newText) ?? 0 <= MILLI_LITRE
        }
        else if (label?.text == "hours" || label?.text == "hrs"){
            maxValue = Int(newText) ?? 0 <= HOURS
        }
        else{
            if(newText.isNumber()){
                maxValue = Int(newText) ?? 0 <= NUMBER_MAX_VALUE
            }
            else{
                maxValue = newText.count <= CharacterLength
            }
        }
        return maxValue && (numberOfDots <= 1 && numberOfDecimalDigits <= 3)
    }
    
// MARK: - FUNCTIONS
    
    @objc func dateTextfieldOnClick(){
        dateTimePickerViewController = DateTimePickerViewController()
        dateTimePickerViewController?.delegate = self
        dateTimePickerViewController?.datePicker.maximumDate = Date()
        dateTimePickerViewController?.setDate(dateObjString: addFlowsheetEntryView.flowsheetEntryDateField.text ?? "")
        dateTimePickerViewController?.dullParentView()
        self.navigationController?.present(dateTimePickerViewController ?? DateTimePickerViewController(), animated: true, completion: nil)
    }
    
    func setEntryDate(datePicker: UIDatePicker, dateString: String){
        let dateObj = CharmUtil.getDateObjectWith(dateString: dateString, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        datePicker.date = dateObj ?? Date()
    }
    
    @objc func dateTextFieldTouchEvent(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
        if let uiView = sender.view{
            for subView in uiView.subviews{
                if let textField = subView as? UITextField{
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    @objc func dateTimeFieldOnClick(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
        dateTimePickerViewController = DateTimePickerViewController()
        dateTimePickerViewController?.delegate = self
        dateTimePickerViewController?.dullParentView()
        if let uiView = sender.view{
            if let textField = uiView as? UITextField{
                dateTimeTextField(textField: textField, dateTimePickerViewController: dateTimePickerViewController)
            }
            else{
                for subView in uiView.subviews{
                    if let textField = subView as? UITextField{
                        dateTimeTextField(textField: textField, dateTimePickerViewController: dateTimePickerViewController)
                    }
                }
            }
        }
        self.navigationController?.present(dateTimePickerViewController ?? DateTimePickerViewController(), animated: true, completion: nil)
    }
    func dateTimeTextField(textField: UITextField, dateTimePickerViewController: DateTimePickerViewController?){
        textField.resignFirstResponder()
        dateTimePickerViewController?.delegateTag = textField.tag
        dateTimePickerViewController?.setDate(dateObjString: textField.text ?? "")
    }
    
    func getPHRFlowsheetEntry(flowsheetEntry: FlowsheetEntries) -> FlowsheetEntries?{
        let phrFlowsheetEntry =  phrFlowsheet?.flowsheetEntries.first(where: {phrFlowsheetEntry in
            return flowsheetEntry.flowSheetEntryId == phrFlowsheetEntry.flowSheetEntryId
        })
        return phrFlowsheetEntry
    }
    
    func unitLabelSetProperty(unitLabel: UILabel?, labelText: String){
        unitLabel?.textAlignment = .right
        unitLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        unitLabel?.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        unitLabel?.text = labelText
    }
    
    func unitLabelSetConstraints(unitLabel: UILabel){
        unitLabel.setRight(offSet: -CARD_PADDING)
        unitLabel.setTop(offSet: CARD_PADDING)
        unitLabel.setBottom(offSet: -CARD_PADDING)
        unitLabel.setWidth(constant: (unitLabel.sizeThatFits(CGSize(width: 300, height: 50)).width))
    }
    
    func textFieldSetProperty(textField: UITextField?){
        
        textField?.layer.borderWidth = BORDER_WIDTH
        textField?.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
        textField?.addCornerRadius(.SMALL)
        textField?.contentVerticalAlignment = .center
        textField?.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BACKGROUND_COLOR)
        textField?.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        textField?.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        textField?.returnKeyType = .done
    }
    
    private func triggerTextField(textField: UITextField?) -> Bool{
        if let textField = textField {
            let nsText = textField.text as NSString?
            let textRange = NSMakeRange(0, nsText?.length ?? 0)
            return (self.textField(textField, shouldChangeCharactersIn: textRange, replacementString: textField.text ?? ""))
        }
        return false
    }
    
    private func onSecondaryValTextChange(textField: UITextField, feetOrPounds: Int, inchOrOunces: Int){
        if let textInput = textField.text{
            if (textInput.toIntOrNil() == inchOrOunces){
                textField.text = ""
                bmiTagList.forEach(){bmiTag in
                    let tagList = bmiTag.split(separator: ",")
                    if tagList.count > 1{
                        if "\(tagList[1])".toIntOrNil() == textField.tag{
                            let textFieldFP = getTextField(tagVal: "\(tagList[0])")
                            
                            let textInputFP = textFieldFP?.text?.toIntOrNil() ?? 0
                            let isTriggerSucces = triggerTextField(textField: textFieldFP)
                            if isTriggerSucces{
                                if !(textInputFP == feetOrPounds){
                                    textFieldFP?.text = "\(textInputFP + 1)"
                                }
                                else{
                                    if(textInput.toIntOrNil() == inchOrOunces){
                                        textField.text = "\(1)"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    @objc func onHeightWeightTextChange(textField: UITextField) {
        
        let label = getLabel(textField: textField)
        if (label?.text == INCHES){
            onSecondaryValTextChange(textField: textField, feetOrPounds: HEIGHT_FEET, inchOrOunces: HEIGHT_INCH)
        }
        else if (label?.text == OUNCES){
            onSecondaryValTextChange(textField: textField, feetOrPounds: WEIGHT_POUNDS, inchOrOunces: WEIGHT_OUNCES)
        }
        if !bmiTagList.isEmpty{
            bmiCalculation()
        }
    }
    
    private func bmiCalculation(){
        
        var height: Double = 0
        var weight: Double = 0
        var bmi: Double = 0
        
        var heightVal: Double = 0.0
        var heightSecondaryVal: Double? = nil
        var weightVal: Double = 0.0
        var weightSecondaryVal: Double? = nil
        
        bmiTagList.forEach(){bmiTag in
            let tagList = bmiTag.split(separator: ",")
            if (tagList.count == 1){
                let label = getLabelWithTag(tagVal: "\(tagList.first ?? "")")
                let textField = getTextField(tagVal: "\(tagList.first ?? "")")
                
                if let textInput = textField?.text?.toDoubleOrNil(){
                    if(label?.text == CM || label?.text == CMS){
                        heightVal = textInput
                    }
                    else if(label?.text == KG || label?.text == KGS){
                        weightVal = textInput
                    }
                }
            }
            else if (tagList.count > 1){
                for tagObj in tagList{
                    let label = getLabelWithTag(tagVal: "\(tagObj)")
                    let textField = getTextField(tagVal: "\(tagObj)")
                    
                    let textInput = textField?.text?.toDoubleOrNil() ?? 0
                    if (label?.text == FEET){
                        heightVal = textInput
                    }
                    else if(label?.text == INCHES){
                        heightSecondaryVal = textInput
                    }
                    else if(label?.text == POUNDS){
                        weightVal = textInput
                    }
                    else if(label?.text == OUNCES){
                        weightSecondaryVal = textInput
                    }
                }
            }
        }
        
        if (heightSecondaryVal != nil || weightSecondaryVal != nil) {
            height = (heightVal * 12.0) + (heightSecondaryVal ?? 0)
            weight = ((weightSecondaryVal ?? 0.0) / 16.0) + weightVal
            bmi = (weight/(height * height)) * 703.0
        }
        else{
            height = heightVal / 100
            bmi = weightVal/(height * height)
        }
        bmiTagList.forEach(){bmiTag in
            let tagList = bmiTag.split(separator: ",")
            if (tagList.count == 1){
                let label = getLabelWithTag(tagVal: "\(tagList.first ?? "")")
                let textField = getTextField(tagVal: "\(tagList.first ?? "")")
                if (label?.text == flowsheetVitalBMI){
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
    }
    
    private func getTextField(tagVal: String) -> UITextField?{
        if let tag = tagVal.toIntOrNil(){
            if let textField = self.view.viewWithTag(tag) as? UITextField{
                return textField
            }
        }
        return nil
    }
    private func getLabelWithTag(tagVal: String) -> UILabel?{
        
        if let tag = tagVal.toIntOrNil(){
            if let textField = self.view.viewWithTag(tag) as? UITextField{
                let labelTag = fieldToLabelMap[textField.tag] ?? -1
                if let label = self.view.viewWithTag(labelTag) as? UILabel{
                    return label
                }
            }
        }
        return nil
    }
    func getLabel(textField: UITextField) -> UILabel?{
        let labelTag = fieldToLabelMap[textField.tag] ?? -1
        if let label = self.view.viewWithTag(labelTag) as? UILabel{
            return label
        }
        return nil
    }
    
    
    
    private func fahrenheitToCelsius(val: Double) -> String{
        let celsius: Double = (val - 32) * (5 / 9)
        return "\(String(format: "%.2f", celsius))"
    }
    private func celsiusToFahrenheit(val: Double) -> String{
        let fahrenheit: Double = (val * (9 / 5)) + 32
        return "\(String(format: "%.2f", fahrenheit))"
    }
    @objc func vitalOptionBtnClicked(btn: UIButton){
        
        self.view.endEditing(true)
        
        if !btn.isSelected{
        
            let stackTag = buttonToStackMap[btn.tag] ?? -1
            if let stackView = self.view.viewWithTag(stackTag) as? UIStackView{

                for view in stackView.subviews{

                    if let otherBtn = view as? UIButton
                    {
                        if btn.tag != otherBtn.tag && otherBtn.isSelected{
                            otherBtn.isSelected = false
                            break
                        }
                    }
                }
            }
            btn.isSelected = true
        }
    }
    @objc func optionBtbClickedMultiple(btn: UIButton){
        
        self.view.endEditing(true)
        
        let textFieldTag = buttonToFieldMap[btn.tag] ?? -1
        
        btn.isSelected = !btn.isSelected
        
        if let textField = self.view.viewWithTag(textFieldTag) as? UITextField
        {
            
            if btn.isSelected {
                textField.isHidden = false
            }
            
            UIView.animate(withDuration: 0.4, delay: 0, animations: {
                let height = self.fieldToHeightMap[textField.tag]
                    
                if btn.isSelected{
                    height?.constant = TEXTFIELD_HEIGHT
                    textField.becomeFirstResponder()
                }
                else{
                    height?.constant = 0
                }
                self.view.layoutIfNeeded()

            }, completion: {_ in
                
                if !btn.isSelected {
                    textField.isHidden = true
                    textField.resignFirstResponder()
//                    self.view.endEditing(true)
                }
            })
        }
    }
    
    @objc func optionBtbClickedSingle(btn: UIButton){
        
        self.view.endEditing(true)
        
        if !btn.isSelected{
            
            let textFieldTag = buttonToFieldMap[btn.tag] ?? -1
            if let textField = self.view.viewWithTag(textFieldTag) as? UITextField
            {
                let height = fieldToHeightMap[textField.tag]

                DispatchQueue.main.async {
                  UIView.transition(with: textField, duration: 0.4,
                                    options: .transitionCrossDissolve,
                                    animations: {
                      height?.constant = TEXTFIELD_HEIGHT
                      self.view.layoutIfNeeded()
                      textField.isHidden = false
                                })
                }
//                UIView.animate(withDuration: 0.4, delay: 0, animations: {
//
//
//                    height?.constant = self.TEXT_FIELD_HEIGHT
//                    self.view.layoutIfNeeded()
//
//                }, completion: {_ in
//
//                })
                textField.becomeFirstResponder()
            }
            
            let stackTag = buttonToStackMap[btn.tag] ?? -1
            if let stackView = self.view.viewWithTag(stackTag) as? UIStackView{

                for view in stackView.subviews{

                    if let otherBtn = view as? UIButton
                    {
                        if btn.tag != otherBtn.tag && otherBtn.isSelected{
                            
                            let textFieldTag = buttonToFieldMap[otherBtn.tag] ?? -1
                            if let textField = self.view.viewWithTag(textFieldTag) as? UITextField
                            {
                                let height = fieldToHeightMap[textField.tag]

                                DispatchQueue.main.async {
                                  UIView.transition(with: textField, duration: 0.4,
                                                    options: .transitionCrossDissolve,
                                                    animations: {
                                  })
                                }
                                DispatchQueue.main.async {
                                  UIView.transition(with: textField, duration: 0.4,
                                                    options: .transitionCrossDissolve,
                                                    animations: {
                                      height?.constant = 0
                                      self.view.layoutIfNeeded()
                                      textField.isHidden = true
//                                      self.view.endEditing(true)
                                  })
                                }
                                

//                                UIView.animate(withDuration: 0.4, delay: 0, animations: {
//
//                                    height?.constant = 0
//                                    //textField.isHidden = true
//                                    self.view.layoutIfNeeded()
//                                }, completion: {_ in
//                                    UIView.animate(withDuration: 0.3) {
//                                    }
//                                })
                            }
                            otherBtn.isSelected = false
                            break
                        }
                    }
                }
            }
            btn.isSelected = true
        }
    }
    
    @objc private func datePickerValueChanged(datePicker : UIDatePicker){
        
        let textFieldTag = datePickerToTextFieldMap[datePicker.tag]  ?? -1
        if let textField = self.view.viewWithTag(textFieldTag) as? UITextField
        {
            
            textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
        }
    }
    
    @objc func donedatePicker(_ barItem: UIBarButtonItem){
        
        let barButtonTag = barItemToTextFieldMap[barItem.tag]  ?? -1
        if let textField = self.view.viewWithTag(barButtonTag) as? UITextField
        {
            if let datePicker = textField.inputView as? UIDatePicker{
                datePickerValueChanged(datePicker: datePicker)
            }
        }
        self.view.endEditing(true)
    }
   
    @objc private func onSliderValueChange(slider: UISlider){
        self.view.endEditing(true)
        let sliderLabelTag = sliderToLabelMap[slider.tag]  ?? -1
        if let labelView = self.view.viewWithTag(sliderLabelTag) as? UILabel
        {
            labelView.text = "\(Int(slider.value))"
        }
    }
    
    private func groupFlowsheet(flowsheetEntries:[FlowsheetEntries]) -> [[FlowsheetEntries]]{
        
        var groupedFlowsheet:[[FlowsheetEntries]] = []
        var localFlowsheetEntries:[FlowsheetEntries] = []
        
        
        flowsheetEntries.forEach{flowsheetEntry in
            
            if (localFlowsheetEntries.isEmpty){
                localFlowsheetEntries.append(flowsheetEntry)
            }
            else{
                if(localFlowsheetEntries.first?.type ?? "" == flowsheetEntry.type){
                    localFlowsheetEntries.append(flowsheetEntry)
                }else{
                    groupedFlowsheet.append(localFlowsheetEntries)
                    localFlowsheetEntries = []
                    localFlowsheetEntries.append(flowsheetEntry)
                }
            }
            
            if((flowsheetEntry.type != "VITAL" && flowsheetEntry.type != "LAB") && !localFlowsheetEntries.isEmpty){
                groupedFlowsheet.append(localFlowsheetEntries)
                localFlowsheetEntries = []
            }
        }
        
        if (!localFlowsheetEntries.isEmpty){
            groupedFlowsheet.append(localFlowsheetEntries)
            localFlowsheetEntries = []
        }
        return groupedFlowsheet
    }
    
    
    func showAlertDialog(titleKey: String) {
        CharmUtil.createOkayAlertWith(title: getString(key: titleKey), msg: nil)
    }
}

// Grid widths relative to the card, so fields resize on rotation and fold/unfold.
fileprivate extension UIView {

    // Two fields per row: padding + field + padding + field + padding = container width.
    func setHalfGridWidth() {
        guard let superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.5, constant: -(CARD_PADDING * 3) / 2).isActive = true
    }

    func setFullGridWidth() {
        guard let superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -(CARD_PADDING * 2)).isActive = true
    }
}
