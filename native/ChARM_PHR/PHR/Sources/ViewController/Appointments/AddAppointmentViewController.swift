//
//  AddAppointmentViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 09/12/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//


import UIKit
import Razorpay

class AddAppointmentViewController: CustomViewControllerWithTableView , CharmConnectionHandlerDelegate , UITableViewDataSource , selectAddAppointmentValueViewControllerDelegate , UIPickerViewDelegate ,UITextViewDelegate, UIPickerViewDataSource, RazorpayPaymentCompletionProtocol, UITextFieldDelegate , PaymentViewControllerDelegate, MDTextFieldDelegate
{
    let addAppointment : AddAppointment = AddAppointment()
    
    var razorpay : RazorpayCheckout!
    
    @objc let datePickerView = UIDatePicker()
   // let pickerView = UIPickerView()
    
    let timezoneLabel = UILabel()
    let timeZoneLabelView = UIView()
    
    let xSpace = 10
    let ySpace = 10
    
    let REASON_TEXTVIEW_TAG = 101
    var appointmentConfigAmmount : Float = 0.0
    
    // to have the data
    var facilityDictArr : [Dictionary<String,Any>] = []
    var facilityMemberDictArr : [Dictionary<String,Any>] = []
    
    var workingDaysDict : Dictionary<String,Any>?
    var slotTimingDictArr : [Array<Dictionary<String,Any>>] = []
        
    var appointmentTypeArray = [appointmentTypeInPerson, appointmentTypePhoneCall]
    var slotPreferance = ["Morning","Noon","Evening"]
        
//    var arrayOfSectionAndRow : Array<Array<Dictionary<String,String>>> = [[["Name":"Facility","PlaceHolder":"Select facility","value":""],["Name":"Provider","PlaceHolder":"Select provider","value":""]],[["Name":"Date preference","PlaceHolder":"Select provider","value":"Any date"],["Name":"Time preference","PlaceHolder":"Select provider","value":"Any time"]],[["Name":"Appointment type","PlaceHolder":"Select appointment Type","value":""],["Name":"Reason","PlaceHolder":"Reason","value":""]],[]]
    
    var arrayOfSectionAndRow : Array<Array<Dictionary<String,String>>> = [[["Name":"Facility","PlaceHolder":"Select facility","value":""],["Name":"Provider","PlaceHolder":"Select provider","value":""]],[],[],[]]
    
    var selectedIndex : IndexPath?
    weak var delegate : AddViewControllerDelegate?
    
    var charmConnectionHandler : CharmConnectionHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.createTableviewAndSubViews(tableViewStyle: .plain)
    
        timezoneLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        timezoneLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        timezoneLabel.numberOfLines = 3
        timeZoneLabelView.addSubview(timezoneLabel)

        self.navigationItem.title = getString(key: "com.charmphr.addAppointments.title")
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        
        customTableView.dataSource = self
        customTableView.delegate = self
        
       
        customTableView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR).cgColor
        customTableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldTableViewCell")
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        
        if Patient.selectedPatientInstance!.practiceList.count > 1
        {
            arrayOfSectionAndRow[0] = [["Name":"Practice","PlaceHolder":"Select practice","value":""],["Name":"Facility","PlaceHolder":"Select facility","value":""],["Name":"Provider","PlaceHolder":"Select provider","value":""]]
        }else
        {
            updatePratice(row: 0)
        }
        
       // updateAppoimentType(row: addAppointment.selectedAppointmentTypeIndex)
        
        datePickerView.preferredDatePickerStyle = .wheels
        datePickerView.addTarget(self, action: #selector( datePickerValueChanged(datePicker:)), for: .valueChanged)
        
    }
       
    //MARK: - TableView.delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfSectionAndRow[section].count
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
//        if isbluefinPaymentEnabledInAppointment()
//        {
//            //TODO:d
//            timeZoneLabelView.isHidden = true
//            return 1
//        }else
//        {
            timeZoneLabelView.isHidden = false
            return arrayOfSectionAndRow.count
        //}
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && !isNilOrEmpty(string: addAppointment.timeZone)
        {
            return timeZoneLabelView
        }else
        {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && !isNilOrEmpty(string: addAppointment.timeZone)
        {
            return timezoneLabel.frame.height
        }else
        {
            return 20
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrayOfSectionAndRow[indexPath.section][indexPath.row]["Name"] == "Reason"
        {
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as! TextFieldTableViewCell
            tableViewCell.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
            tableViewCell.textView.text = arrayOfSectionAndRow[indexPath.section][indexPath.row]["value"]
            tableViewCell.keyLabel.text = arrayOfSectionAndRow[indexPath.section][indexPath.row]["PlaceHolder"] ?? ""
            tableViewCell.selectionStyle = .none
//            tableViewCell.textView.maxLength = 400
            tableViewCell.textView.tag = REASON_TEXTVIEW_TAG
            tableViewCell.textView.delegate = self
            return tableViewCell
        }
        else if arrayOfSectionAndRow[indexPath.section][indexPath.row]["Name"] == "Slot Date"
        {
            let tableViewCell = AddAppointmentTableViewCell(style: .default, reuseIdentifier: "AddAppointmentTableViewCell")
            tableViewCell.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
            tableViewCell.keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
            tableViewCell.keyLabel.text = "\(arrayOfSectionAndRow[indexPath.section][indexPath.row]["Name"] ?? "")"
            datePickerView.datePickerMode = .date
            tableViewCell.textField.inputView = datePickerView
            tableViewCell.textField.delegate = self
            tableViewCell.textField.text = "\(arrayOfSectionAndRow[indexPath.section][indexPath.row]["value"] ?? "")"
            tableViewCell.selectionStyle = .none
            return tableViewCell
        }
        else if arrayOfSectionAndRow[indexPath.section][indexPath.row]["Name"] == "Amount"
        {
            let tableViewCell = AddAppointmentTableViewCell(style: .default, reuseIdentifier: "AddAppointmentTableViewCell")
            tableViewCell.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: false)
            tableViewCell.keyLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
            tableViewCell.keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
            tableViewCell.valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
            tableViewCell.keyLabel.text = "\(arrayOfSectionAndRow[indexPath.section][indexPath.row]["Name"] ?? "")"
            tableViewCell.valueLabel.text = "\(arrayOfSectionAndRow[indexPath.section][indexPath.row]["value"] ?? "")"
            tableViewCell.selectionStyle = .none
            return tableViewCell
        }
        else
        {
            let tableViewCell = AddAppointmentTableViewCell(style: .default, reuseIdentifier: "AddAppointmentTableViewCell")
            tableViewCell.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
                            
            tableViewCell.keyLabel.text = "\(arrayOfSectionAndRow[indexPath.section][indexPath.row]["Name"] ?? "")"
             
            if arrayOfSectionAndRow[indexPath.section][indexPath.row]["value"] == ""
            {
                tableViewCell.valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
                
                tableViewCell.valueLabel.attributedText = NSAttributedString(string: arrayOfSectionAndRow[indexPath.section][indexPath.row]["PlaceHolder"] ?? "" ,
                                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: 0x3C3C43C7) , NSAttributedString.Key.font : UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)])
            }else
            {
                tableViewCell.valueLabel.text = "\(arrayOfSectionAndRow[indexPath.section][indexPath.row]["value"] != "" ? arrayOfSectionAndRow[indexPath.section][indexPath.row]["value"]! : arrayOfSectionAndRow[indexPath.section][indexPath.row]["PlaceHolder"] ?? "" )"
                tableViewCell.valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
            }
            tableViewCell.selectionStyle = .none
            return tableViewCell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        if ((tableView.cellForRow(at: indexPath) as? AddAppointmentTableViewCell) != nil) || ((tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell) != nil)
        {
            if let cell = tableView.cellForRow(at: indexPath) as? AddAppointmentTableViewCell
            {
                cell.setSelected(false, animated: true)
                
                if cell.textField.isHidden == false
                {
                    cell.textField.isUserInteractionEnabled = true
                    cell.textField.becomeFirstResponder()
                    if cell.keyLabel.text == "Slot Date" && addAppointment.slotsOpeningPriorHours != nil && addAppointment.onlineBookingDaysLimit != nil
                    {
                        datePickerView.minimumDate = addAppointment.todayDate!.addingTimeInterval(TimeInterval(addAppointment.slotsOpeningPriorHours! * 60 * 60))
                        datePickerView.maximumDate = datePickerView.minimumDate?.addingTimeInterval(TimeInterval(addAppointment.onlineBookingDaysLimit! * 24 * 60 * 60))
                        
                        if addAppointment.selectedDate != nil
                        {
                            datePickerView.date = addAppointment.selectedDate!
                        }
                    }
                }else
                {
                    if canNavigateViewController() == true
                    {
                        performSegue(withIdentifier: "selectValueForAppointmentVC", sender: self)
                    }else
                    {
                        if cell.keyLabel.text != nil{
//                            showAlert(message: "\(cell.keyLabel.text ?? "")")
                        }else
                        {
                            showAlert(message: getString(key: "com.charmphr.addAppointments.fillFormFully"))
                        }
                    }
                }
            }else
            {
                //TODO: make single textfield as first responder
            }
        }
        
        
    }
    
    //MARK: - fetch of data methods
    func fetchProvider()
    {
        showActivityIndicatorWithoutHidingTableview()
        charmConnectionHandler.fetchProviderName(practiceId: addAppointment.selectedPractice?.practiceId ?? "", facilityId: facilityDictArr[addAppointment.selectedFacilityIndex!]["facility_id"] as! String, identificationKey: "fetchProviderNames")
    }
    
    func fetchAppointmenConfig()
    {
        showActivityIndicatorWithoutHidingTableview()
        charmConnectionHandler.fetchAppointmenConfig(practiceId: addAppointment.selectedPractice?.practiceId ?? "", memberId: facilityMemberDictArr[addAppointment.selectedProviderIndex!]["member_id"] as! String, facilityId: facilityDictArr[addAppointment.selectedFacilityIndex!]["facility_id"] as! String, identificationKey: "fetchAppointmentConf")
    }
    
    func fetchAppointmentSlots(visitTypeId : String?)
    {
        if addAppointment.selectedDate != nil && CharmUtil.getDateStringWith(date: addAppointment.selectedDate!, dateFormat: "MM-dd-yyyy") != "" && addAppointment.interval != nil && addAppointment.isConfigured
        {
            showActivityIndicatorWithoutHidingTableview()
            charmConnectionHandler.fetchAppointmentSlot(practiceId: addAppointment.selectedPractice?.practiceId ?? "", memberId: facilityMemberDictArr[addAppointment.selectedProviderIndex!]["member_id"] as! String, facilityId: facilityDictArr[addAppointment.selectedFacilityIndex!]["facility_id"] as! String, fromDate: CharmUtil.getDateStringWith(date: addAppointment.selectedDate!, dateFormat: "MM-dd-yyyy"), toDate: CharmUtil.getDateStringWith(date: addAppointment.selectedDate!, dateFormat: "MM-dd-yyyy"), visitTypeId: visitTypeId,interval: addAppointment.interval!, identificationKey: "fetchAppointmentSlot")
        }
    }
    
    //MARK: - charmconnectionHandler delegate methods
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String)
    {
        hideActivityIndicator()
        if identificationKey == "fetchFacilityList"
        {
            // if facility list is selected fetch provider
            facilityDictArr = jsonObject["output_string"] as! [Dictionary<String,Any>]
            
            if facilityDictArr.count == 1
            {
                updateFacilityName(row: 0)
            }
        }
        else if identificationKey == "fetchProviderNames"
        {
            // fetch provider for the facility and fetch config
            facilityMemberDictArr = jsonObject["facility_members"] as! [Dictionary<String,Any>]
            
            if facilityMemberDictArr.count == 1
            {
                updateProviderName(row: 0)
            }
        }
        else if identificationKey == "fetchAppointmentConf"
        {
            let outputJson = jsonObject["output_string"] as! Dictionary<String,Any>

            ParsingHelper.fillAppointmentConfigResponse(outputJson: outputJson, addAppointment: addAppointment)
            
            if (!isNilOrEmpty(string:addAppointment.timeZone))
            {
                timezoneLabel.text = "\(getString(key: "com.charmphr.addAppointments.timezone.title"))(\(addAppointment.timeZone ?? ""))"
                let height = timezoneLabel.sizeThatFits(CGSize(width: appDelegate.screenWidth - (X_SPACE + X_SPACE + 10 ), height: 1000)).height + 20
                
                timezoneLabel.frame = CGRect(x: SPACE_TO_BORDERS,y: 0,width: customTableView.frame.width-2*SPACE_TO_BORDERS,height: height)
            }
            
            setOrResetAppointmentTypes()
            
            if(addAppointment.paymentInfo != nil && addAppointment.paymentInfo?.chargeType != nil && addAppointment.paymentInfo?.chargeType == "VISIT_BASED" && addAppointment.visitTypeDictArr.isEmpty)
            {
                addAppointment.paymentInfo = nil
            }
            else if(addAppointment.paymentInfo != nil && addAppointment.paymentInfo?.chargeType != "VISIT_BASED" && addAppointment.paymentInfo?.chargeAmount?.toFloatOrNil() == 0)
            {
                addAppointment.paymentInfo = nil
            }
            if(addAppointment.paymentInfo != nil && addAppointment.paymentInfo?.chargeAmount?.toFloatOrNil() != 0 && addAppointment.paymentInfo?.chargeType == "VISIT_BASED"){
                addAppointment.paymentInfo?.chargeAmount = "0"
            }
            
            afterAppointmentConfigFetch()
            
        }
      /*  {
            let outputJson = jsonObject["output_string"] as! Dictionary<String,Any>
            
            if let todayDateObj = outputJson["today_details"] as? Dictionary<String,Any>
            {
                if (todayDateObj["date"] as? String) != nil && todayDateObj["time"] as? String != nil
                {
                    let today = "\(todayDateObj["date"] as! String) \(todayDateObj["time"] as! String)"
                    addAppointment.todayDate = CharmUtil.getDateObjectWith(dateString: today, dateFormat: "MM-dd-yyyy HH:mm")
                }
            }
            
            if outputJson["FACILITY_TIMEZONE"] as? String != nil
            {
                addAppointment.timeZone = outputJson["FACILITY_TIMEZONE"] as? String
                timezoneLabel.text = "\(NSLocalizedString("com.charmphr.addAppointments.timezone.title", comment: ""))(\(addAppointment.timeZone ?? ""))"
            }
            
            if outputJson["DATE_AT_FACILITY_TIMEZONE"] as? String != nil
            {
                addAppointment.facilityTime = CharmUtil.getDateObjectWith(dateString: outputJson["DATE_AT_FACILITY_TIMEZONE"] as! String, dateFormat: "yyyy/MM/dd HH:mm:ss")
            }
            
            if outputJson["ONLINE_BOOKING_DAYS_LIMIT"] as? String != nil && Int(outputJson["ONLINE_BOOKING_DAYS_LIMIT"] as! String) != nil
            {
                addAppointment.onlineBookingDaysLimit = Int(outputJson["ONLINE_BOOKING_DAYS_LIMIT"] as! String)
            }
            
            if outputJson["SLOTS_OPENING_PRIOR_HOURS"] as? String != nil && Int(outputJson["SLOTS_OPENING_PRIOR_HOURS"] as! String) != nil
            {
                addAppointment.slotsOpeningPriorHours = Int(outputJson["SLOTS_OPENING_PRIOR_HOURS"] as! String)
            }
            
            if outputJson["interval"] as? String != nil && Int(outputJson["interval"] as! String) != nil
            {
                addAppointment.interval = Int(outputJson["interval"] as! String)
            }
            
            if outputJson["TELEHEALTH_ENABLED"] as? Int != nil
            {
                if outputJson["TELEHEALTH_ENABLED"] as! Int == 1
                {
                    addAppointment.isTelehealthEnabled = true
                }else
                {
                    addAppointment.isTelehealthEnabled = false
                }
            }
            
            if outputJson["IS_CARD_PROCESSING_ENABLED"] as? Bool == true
            {
                let payment = PaymentDetail()
                
                payment.patientId = Patient.selectedPatientInstance!.patientId
                
                if outputJson["GATEWAY"] as? String != nil
                {
                    payment.gateway = outputJson["GATEWAY"] as? String
                    if payment.gateway == "RAZORPAY"
                    {
                        payment.currency = "INR"
                        payment.currencySymbol = "Rs."
                    }
                }
                
                if outputJson["CHARGE_AMOUNT"] as? Float != nil
                {
                    payment.amount = outputJson["CHARGE_AMOUNT"] as? Float
                }
                
                if outputJson["IS_CARD_PROCESSING_ENABLED"] as? Bool != nil
                {
                    payment.isCardProcessing = outputJson["IS_CARD_PROCESSING_ENABLED"] as? Bool
                }
                
                if outputJson["MERCHANT_ACCOUNT_ID"] as? String != nil
                {
                    payment.merchantAccountId = outputJson["MERCHANT_ACCOUNT_ID"] as? String
                }
                
                addAppointment.payment = payment
                
            }else
            {
                addAppointment.payment = nil
            }
            
            if outputJson["is_configured"] as? Int == 1
            {
                if let visitType = outputJson["visitTypes"] as? Array<Dictionary<String,Any>>
                {
                    updateVisitTypeDict(visitTypeArr: visitType, isConfigured: true)
                    if addAppointment.payment != nil
                    {
                        self.appointmentConfigAmmount = addAppointment.payment.amount
                        addAppointment.payment.amount = nil
                    }
                }else
                {
                    updateVisitTypeDict(visitTypeArr: nil, isConfigured: true)
                }
            }else
            {
                updateVisitTypeDict(visitTypeArr: nil, isConfigured: false)
            }
            
            updateAmount()
            
        } */
        else if identificationKey == "fetchAppointmentSlot"
        {
            let output = jsonObject["output_string"] as? Dictionary<String,Any>
            if output != nil
            {
                if let slotForThatDate = output!["available_slots"] as? Array<Dictionary<String,Any>>
                {
                    if slotForThatDate.count > 0 && addAppointment.selectedDate != nil
                    {
                        updateAppointmentSlotDict(availableSlotDict:slotForThatDate[0][CharmUtil.getDateStringWith(date: addAppointment.selectedDate!, dateFormat: PHR_DATE_API_FORMAT)] as? Array<Dictionary<String,Any>>)
                    }else
                    {
                        updateAppointmentSlotDict(availableSlotDict: nil)
                    }
                }
                
                if let workingDays = output!["working_days"] as? Dictionary<String,Any>
                {
                    workingDaysDict = workingDays
                }
                
                if output!["SHOW_WAIT_LIST"] as? Bool == true
                {
                    addAppointment.showWaitList = true
                }
                
            }
            
        }
        else if identificationKey == "addAppointment"
        {
            AppDataHandler.sharedInstance().refreshAppointments = true
            delegate?.addViewControllerDataAdded(message: nil)
            self.navigationController?.popViewController(animated: true)
        }
        else if identificationKey == "cretaeTranstion"
        {
            addAppointment.paymentInfo = ParsingHelper.updatePaymentDetailWithDictionary(paymentInfo: addAppointment.paymentInfo, dict: jsonObject)
            openRazorPay(paymentInfo: addAppointment.paymentInfo)
        }
        else if identificationKey == "updatPayment"
        {
            let outputJson = jsonObject["output_string"] as! Dictionary<String,Any>
            
            if let receiptDetail = outputJson["receipt_details"] as? [Dictionary<String,Any>]
            {
                if receiptDetail.first != nil && receiptDetail.first!["ehr_receipt_id"] as? String != nil
                {
                    addAppointment.receiptId = receiptDetail.first!["ehr_receipt_id"] as? String
                }
            }
            
            addAppointment.paymentInfo?.isPaymentSuccess = true
            requestAddAppointment()
        }
        
    }
    
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    //MARK: - selectAddAppointmentValueViewControllerDelegate method
    func selectAddAppointmentValueViewControllerDidSelectValue(indexPath: IndexPath, valueString: String?)
    {
        if let tableViewCell = customTableView.cellForRow(at: selectedIndex!) as? AddAppointmentTableViewCell
        {
            if tableViewCell.keyLabel.text == "Practice"
            {
                updatePratice(row: indexPath.row)
                customTableView.reloadData()
            }
            else if tableViewCell.keyLabel.text == "Facility"
            {
                updateFacilityName(row: indexPath.row)
            }
            else if tableViewCell.keyLabel.text == "Provider"
            {
                updateProviderName(row: indexPath.row)
            }
            else if tableViewCell.keyLabel.text == "Date preference"
            {
                updateDatePreference(row: indexPath.row, dateString: valueString ?? "")
            }
            else if tableViewCell.keyLabel.text == "Time preference"
            {
                updateTimePreference(row: indexPath.row, timeString: valueString ?? "")
            }
            else if tableViewCell.keyLabel.text ==  "Appointment type"
            {
                updateAppoimentType(row: indexPath.row)
            }
            else if tableViewCell.keyLabel.text ==  "Visit type"
            {
                updateVisitType(row: indexPath.row)
            }
            else if tableViewCell.keyLabel.text ==  "Slot preference"
            {
                updateSlotPreference(row: indexPath.row)
            }
            else if tableViewCell.keyLabel.text ==  "Slot time"
            {
                updateSlotTimePreference(row: indexPath.row)
            }
        
        }
    }
    
    //MARK: - update of each value method
    
    //TODO: after we split appointconfig params from addAppointment, no need for this reset
    func resetAppointmentConfig()
    {
        //visit types
        
        //only we need to reset section 0, others will get created after appointment config fetch 
        if Patient.selectedPatientInstance!.practiceList.count == 1 && arrayOfSectionAndRow[0].count > 2
        {
            arrayOfSectionAndRow[0][2].updateValue("", forKey: "value")
        }
        else if (Patient.selectedPatientInstance!.practiceList.count > 1 && arrayOfSectionAndRow[0].count > 3)
        {
            arrayOfSectionAndRow[0][3].updateValue("", forKey: "value")
        }
        
        
        addAppointment.selectedVisitTypeIndex = nil
        addAppointment.visitTypeId = nil
        addAppointment.interval = nil
        
        //date preference
        addAppointment.spcificDate = nil
        addAppointment.selectedDateIndex = 0
        
        //time preference
        addAppointment.selectedTimeIndex = 0
        addAppointment.spcificTimeRange = nil
        
        //slot date
        addAppointment.selectedDate = nil
        
        //slot pref
        addAppointment.slectedSlotPrefreanceIndex = nil
        
        //slot time
        addAppointment.selectedSlotTimeIndex = nil
        
        //appointment type
        addAppointment.selectedAppointmentTypeIndex = 0
        addAppointment.appoimentTypeStr = ""
        
        //for selected facility current date and time
        addAppointment.todayDate = nil
        addAppointment.timeZone = nil
        addAppointment.facilityTime = nil
        
        //appointment config variables
        addAppointment.isConfigured = false
        addAppointment.isTelehealthEnabled = false
        addAppointment.onlineBookingDaysLimit = nil
        addAppointment.slotsOpeningPriorHours = nil
        addAppointment.isWaitlistSelected = false
        addAppointment.showWaitList = false
        addAppointment.showVisitDuration = false
        addAppointment.visitTypeDictArr = []
        
        //payment
        addAppointment.paymentInfo = nil
    }
    
    func updatePratice(row:Int)
    {
        if(addAppointment.selectedPractice != nil && addAppointment.selectedPractice?.practiceId == Patient.selectedPatientInstance!.practiceList[row].practiceId){
            return
        }
        
        addAppointment.selectedPractice = Patient.selectedPatientInstance!.practiceList[row]
        
        if Patient.selectedPatientInstance!.practiceList.count > 1
        {
        arrayOfSectionAndRow[0][0].updateValue("\(Patient.selectedPatientInstance!.practiceList[row].practiceName!)", forKey: "value")
        
        arrayOfSectionAndRow[0][1].updateValue("", forKey: "value")
        addAppointment.selectedFacilityIndex = nil
        
        
        arrayOfSectionAndRow[0][2].updateValue("", forKey: "value")
        addAppointment.selectedProviderIndex = nil
        }
        else{
            arrayOfSectionAndRow[0][0].updateValue("", forKey: "value")
            addAppointment.selectedFacilityIndex = nil
            
            
            arrayOfSectionAndRow[0][1].updateValue("", forKey: "value")
            addAppointment.selectedProviderIndex = nil
        }
        
        showActivityIndicatorWithoutHidingTableview()
        charmConnectionHandler.fetchFacilityForAppointment(practiceId: addAppointment.selectedPractice?.practiceId ?? "", patientId: Patient.selectedPatientInstance!.patientId, identificationKey: "fetchFacilityList")
        
        //no need for reload table view bcoz,
        //updatePratice - called from 2places 1.initailly before tableview set and 2. did value change -> there reload called
    }
    
    func updateFacilityName(row:Int)
    {
        if(addAppointment.selectedFacilityIndex != nil && addAppointment.selectedFacilityIndex == row)
        {
            return
        }
        if Patient.selectedPatientInstance!.practiceList.count > 1
        {
            arrayOfSectionAndRow[0][1].updateValue(facilityDictArr[row]["facility_name"] as! String, forKey: "value")
            addAppointment.selectedFacilityIndex = row
            
            arrayOfSectionAndRow[0][2].updateValue("", forKey: "value")
            addAppointment.selectedProviderIndex = nil
        }else{
            arrayOfSectionAndRow[0][0].updateValue(facilityDictArr[row]["facility_name"] as! String, forKey: "value")
            addAppointment.selectedFacilityIndex = row
            
            arrayOfSectionAndRow[0][1].updateValue("", forKey: "value")
            addAppointment.selectedProviderIndex = nil
        }
        customTableView.reloadData()
        fetchProvider()
    }
    
    func updateProviderName(row:Int)
    {
        if(addAppointment.selectedProviderIndex != nil && addAppointment.selectedProviderIndex == row)
        {
          return
        }
        if Patient.selectedPatientInstance!.practiceList.count > 1
        {
            arrayOfSectionAndRow[0][2].updateValue(StringUtil.getNameWithPrefixAndFullName(fullName: facilityMemberDictArr[row]["full_name"] as! String, prefix: facilityMemberDictArr[row]["prefix"] as? String), forKey: "value")
            addAppointment.selectedProviderIndex = row
        }else{
            arrayOfSectionAndRow[0][1].updateValue(StringUtil.getNameWithPrefixAndFullName(fullName: facilityMemberDictArr[row]["full_name"] as! String, prefix: facilityMemberDictArr[row]["prefix"] as? String), forKey: "value")
            addAppointment.selectedProviderIndex = row
        }
        customTableView.reloadData()
        resetAppointmentConfig()
        fetchAppointmenConfig()
    }
    
    func updateDatePreference(row:Int , dateString:String)
    {
        if dateString == "" || row == 0
        {
            arrayOfSectionAndRow[1][0].updateValue("Any date", forKey: "value")
            addAppointment.spcificDate = nil
        }else{
            arrayOfSectionAndRow[1][0].updateValue(dateString, forKey: "value")
            addAppointment.spcificDate = dateString
        }
        addAppointment.selectedDateIndex = row
        customTableView.reloadData()
    }

    func updateTimePreference(row:Int , timeString:String)
    {
        if timeString == "" || row == 0
        {
            arrayOfSectionAndRow[1][1].updateValue("Any time", forKey: "value")
            addAppointment.spcificTimeRange = nil
        }else{
            arrayOfSectionAndRow[1][1].updateValue(timeString, forKey: "value")
            addAppointment.spcificTimeRange = timeString
        }
        addAppointment.selectedTimeIndex = row
        customTableView.reloadData()
    }
    
    func setOrResetAppointmentTypes()
    {
        appointmentTypeArray = [appointmentTypeInPerson,appointmentTypePhoneCall]
        
        if (addAppointment.isTelehealthEnabled)
        {
            appointmentTypeArray.append(appointmentTypeVideoCall)
        }
    }
    
    func updateAppoimentType(row:Int)
    {
        arrayOfSectionAndRow[2][0].updateValue(appointmentTypeArray[row], forKey: "value")
        addAppointment.appoimentTypeStr = appointmentTypeArray[row]
        addAppointment.selectedAppointmentTypeIndex = row
        customTableView.reloadData()
    }
    
    func updateVisitType(row:Int)
    {
        if arrayOfSectionAndRow[0].count > 2
        {
            if Patient.selectedPatientInstance!.practiceList.count == 1
            {
                arrayOfSectionAndRow[0][2].updateValue(addAppointment.visitTypeDictArr[row]["VISIT_TYPE"] as! String, forKey: "value")
            }else
            {
                arrayOfSectionAndRow[0][3].updateValue(addAppointment.visitTypeDictArr[row]["VISIT_TYPE"] as! String, forKey: "value")
            }
            
            customTableView.reloadData()
            
            addAppointment.interval = addAppointment.visitTypeDictArr[row]["DURATION"] as? Int
            addAppointment.selectedVisitTypeIndex = row
            addAppointment.visitTypeId = "\(addAppointment.visitTypeDictArr[row]["VISITTYPE_ID"] ?? "")"
            
            if addAppointment.paymentInfo != nil
            {
            
                let amount = String(addAppointment.visitTypeDictArr[row]["CHARGE"] as? Float ?? 0 )
                let amountFloatVal = (amount as NSString).floatValue
                let chargeType = addAppointment.paymentInfo?.chargeType
                
                if(amountFloatVal > 0 && chargeType == "VISIT_BASED"){
                    addAppointment.paymentInfo?.chargeAmount = amount
                }
                updateAmount()
                
//                if let amount = addAppointment.visitTypeDictArr[row]["CHARGE"] as? Int
//                {
//                    if Float(amount) > 0.0
//                    {
//                        addAppointment.payment.amount = Float(amount)
//                    }else
//                    {
//                        addAppointment.payment.amount = appointmentConfigAmmount
//                    }
//                    updateAmount()
//                }
            }
            
            if addAppointment.visitTypeDictArr[row]["APPOINTMENT_TYPE"] as? String != nil
            {
                appointmentTypeArray = [addAppointment.visitTypeDictArr[row]["APPOINTMENT_TYPE"] as! String]
                if(appointmentTypeArray.count == 1){
                    updateAppoimentType(row: 0)
                }
            }
            
            if addAppointment.selectedVisitTypeIndex != nil && addAppointment.visitTypeDictArr[addAppointment.selectedVisitTypeIndex!]["VISITTYPE_ID"] as? String != nil
            {
                fetchAppointmentSlots(visitTypeId: addAppointment.visitTypeDictArr[addAppointment.selectedVisitTypeIndex!]["VISITTYPE_ID"] as? String)
            }else
            {
                fetchAppointmentSlots(visitTypeId: nil)
            }
        }
    }
    
    func updateSelectedDate(date:Date)
    {
        if arrayOfSectionAndRow[1].count >= 3
        {
            addAppointment.selectedDate = date
            arrayOfSectionAndRow[1][0].updateValue(CharmUtil.getDateStringWith(date: addAppointment.selectedDate!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), forKey: "value")
            
            if addAppointment.selectedVisitTypeIndex != nil && addAppointment.visitTypeDictArr[addAppointment.selectedVisitTypeIndex!]["VISITTYPE_ID"] as? String != nil
            {
                fetchAppointmentSlots(visitTypeId: addAppointment.visitTypeDictArr[addAppointment.selectedVisitTypeIndex!]["VISITTYPE_ID"] as? String)
            }else
            {
                fetchAppointmentSlots(visitTypeId: nil)
            }
        }
    }
    
    func updateSlotPreference(row:Int)
    {
        if arrayOfSectionAndRow[1].count >= 3
        {
            arrayOfSectionAndRow[1][1].updateValue(slotPreferance[row], forKey: "value")
            addAppointment.slectedSlotPrefreanceIndex = row
            
            arrayOfSectionAndRow[1][2].updateValue("", forKey: "value")
            addAppointment.selectedSlotTimeIndex = nil
        }
        customTableView.reloadData()
    }
    
    
    func updateSlotTimePreference(row:Int)
    {
        if addAppointment.isWaitlistSelected == false
        {
            if arrayOfSectionAndRow[1].count > 1
            {
                arrayOfSectionAndRow[1][2].updateValue(slotTimingDictArr[addAppointment.slectedSlotPrefreanceIndex!][row]["start_time"] as! String, forKey: "value")
                addAppointment.selectedSlotTimeIndex = row
            }
        }else
        {
            arrayOfSectionAndRow[1][2].updateValue("Waitlist", forKey: "value")
            addAppointment.selectedSlotTimeIndex = nil
        }
        self.customTableView.reloadData()
    }
    
    func updateAppointmentReason(string:String)
    {
        arrayOfSectionAndRow[2][1].updateValue(string, forKey: "value")
        addAppointment.reasonStr = string
    }

    
    func afterAppointmentConfigFetch()
    {
        if(addAppointment.isConfigured)
        {
            arrayOfSectionAndRow[1] = [["Name":"Slot Date","PlaceHolder":"Select date","value":""],["Name":"Slot preference","PlaceHolder":"Select preference","value":""],["Name":"Slot time","PlaceHolder":"Select time","value":""]]
            arrayOfSectionAndRow[2] = [["Name":"Appointment type","PlaceHolder":"Select appointment Type","value":""],["Name":"Reason","PlaceHolder":"Reason","value":""]]
            if(addAppointment.visitTypeDictArr.isEmpty)
            {
                removeVisitTypeFromView()
            }
            else{
                addVisitTypeToView()
                
                if(addAppointment.visitTypeDictArr.count == 1){
                    updateVisitType(row: 0)}
            }
            
            let date = addAppointment.todayDate?.addingTimeInterval(TimeInterval((addAppointment.slotsOpeningPriorHours! * 60) * 60) ) ?? Date()// 60min * 60sec * afterslot
            
            updateSelectedDate(date: date)
        }
        else
        {
            removeVisitTypeFromView()
            arrayOfSectionAndRow[1] = [["Name":"Date preference","PlaceHolder":"Select provider","value":"Any date"],["Name":"Time preference","PlaceHolder":"Select provider","value":"Any time"]]
            arrayOfSectionAndRow[2] = [["Name":"Appointment type","PlaceHolder":"Select appointment Type","value":""],["Name":"Reason","PlaceHolder":"Reason","value":""]]
        }
        
        //since we are resetting everything after config, updating the reason string
        if(!isNilOrEmpty(string:addAppointment.reasonStr))
        {
            updateAppointmentReason(string:addAppointment.reasonStr!)
        }
        
        updateAppoimentType(row: 0)
        
        updateAmount()
        customTableView.reloadData()
    }
    
/*    func updateVisitTypeDict(visitTypeArr:Array< Dictionary<String,Any>>? , isConfigured :Bool)
    {
        addAppointment.isConfigured = isConfigured
        if isConfigured == false
        {
//            appointmentTypeArray = ["In Person","Phone call"]
//            updateAppoimentType(row: 0)
//            
//            removeVisitTypeFromList()
            
            if arrayOfSectionAndRow[1].count != 2
            {
                arrayOfSectionAndRow[1] = [["Name":"Date preference","PlaceHolder":"Select provider","value":"Any date"],["Name":"Time preference","PlaceHolder":"Select provider","value":"Any time"]]
            }
            
            customTableView.reloadData()
        }
        else
        {
            if visitTypeArr != nil
            {
               /* addAppointment.visitTypeDictArr = []
                for visitType in visitTypeArr!
                {
                    var visitTypeDict = visitType
                    if(addAppointment.showVisitDuration){
                        visitTypeDict.updateValue("\(visitType["VISIT_TYPE"] ?? "") [ \(visitType["DURATION"] ?? "") mins ] ", forKey: "VISIT_TYPE")}
                    else{
                        visitTypeDict.updateValue("\(visitType["VISIT_TYPE"] ?? "")", forKey: "VISIT_TYPE")
                        
                    }
                    
                    addAppointment.visitTypeDictArr.append(visitTypeDict)
                }*/
                
                if (Patient.selectedPatientInstance!.practiceList.count == 1 && arrayOfSectionAndRow[0].count <= 2) || (Patient.selectedPatientInstance!.practiceList.count > 1 && arrayOfSectionAndRow[0].count <= 3)
                {
                    arrayOfSectionAndRow[0].append(["Name":"Visit type","PlaceHolder":"Select visit type","value":""])
                }else
                {
                    arrayOfSectionAndRow[0][arrayOfSectionAndRow[0].count - 1] = ["Name":"Visit type","PlaceHolder":"Select visit type","value":""]
                }
//                if addAppointment.payment != nil && addAppointment.payment.gateway == "BLUEFIN"
//                {
//                    removeVisitTypeFromList()
//                }
                customTableView.reloadData()
            }
            else
            {
               // removeVisitTypeFromList()

//                if addAppointment.todayDate != nil && addAppointment.slotsOpeningPriorHours != nil
//                {
//                    addAppointment.selectedDate = addAppointment.todayDate!.addingTimeInterval(TimeInterval((addAppointment.slotsOpeningPriorHours! * 60) * 60) ) // 60min * 60sec * afterslot
//                }
                fetchAppointmentSlots( visitTypeId: nil)
            }
        }
    }
 */
    
    func removeVisitTypeFromView()
    {
        if Patient.selectedPatientInstance!.practiceList.count > 1
        {
            if arrayOfSectionAndRow[0].count == 4
            {
                arrayOfSectionAndRow[0].remove(at: 3)
            }
        }else
        {
            if arrayOfSectionAndRow[0].count == 3
            {
                arrayOfSectionAndRow[0].remove(at: 2)
            }
        }
    }
    
    func addVisitTypeToView()
    {
        if Patient.selectedPatientInstance!.practiceList.count > 1
        {
            if arrayOfSectionAndRow[0].count == 3
            {
                arrayOfSectionAndRow[0].append(["Name":"Visit type","PlaceHolder":"Select visit type","value":""])
            }
        }else
        {
            if arrayOfSectionAndRow[0].count == 2
            {
                arrayOfSectionAndRow[0].append(["Name":"Visit type","PlaceHolder":"Select visit type","value":""])
            }
        }
    }
    
    func updateAppointmentSlotDict(availableSlotDict : Array<Dictionary<String,Any>>?)
    {
        
        addAppointment.isWaitlistSelected  = false
        
        if availableSlotDict != nil
        {
            slotTimingDictArr = [[],[],[]]
            for dict in availableSlotDict!
            {
                let slotStartTime = dict["start_time"] as! String
                if slotStartTime.uppercased().contains("PM")
                {
                    if Int(slotStartTime.prefix(2))! >= 5 && Int(slotStartTime.prefix(2))! < 12
                    {
                        slotTimingDictArr[2].append(dict)
                    }else
                    {
                        slotTimingDictArr[1].append(dict)
                    }
                }else
                {
                    slotTimingDictArr[0].append(dict)
                }
            }
        }else
        {
            slotTimingDictArr = []
        }
        
        updateSlotPreference(row:0)
       
    }
    
    func updateAmount()
    {
        if addAppointment.paymentInfo != nil && (addAppointment.paymentInfo?.chargeAmount?.toFloatOrNil() ?? 0.0 ) > 0.0
        {
            
            let amount: Float = addAppointment.paymentInfo?.chargeAmount?.toFloatOrNil() ?? 0.0
            let reminder = amount.truncatingRemainder(dividingBy: 1)
            if(reminder == 0){
                
                let amount = "\(addAppointment.paymentCurrencySymbol ?? "") \(Int(amount))"
                arrayOfSectionAndRow[3] = [["Name":"Amount","PlaceHolder":"","value":amount.trim()]]
            }
            else{
                let amount = "\(addAppointment.paymentCurrencySymbol ?? "")\(amount)"
                arrayOfSectionAndRow[3] = [["Name":"Amount","PlaceHolder":"","value": amount.trim()]]
            }
        }else
        {
            arrayOfSectionAndRow[3] = []
        }
        customTableView.reloadData()
    }
    
    //MARK: - navigation
    //TODO: We should send only the display value to next VC. This logic should be changed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectValueForAppointmentVC"
        {
            let vc = segue.destination as! SelectAddAppointmentValueViewController
            vc.delegate = self
            
            if let tableViewCell = customTableView.cellForRow(at: selectedIndex!) as? AddAppointmentTableViewCell
            {
                
                vc.title = tableViewCell.keyLabel.text
                
                if tableViewCell.keyLabel.text == "Practice"
                {
                    
                    var practiceNameDictArr : [Dictionary<String,Any>] = []
                    
                    for practice in Patient.selectedPatientInstance!.practiceList
                    {
                        practiceNameDictArr.append(["name":"\(practice.practiceName!)"])
                    }
                    
                    vc.keyString = "name"
                    vc.arrayOfValues = practiceNameDictArr
                    if addAppointment.selectedPractice == nil
                    {
                        vc.selectedValueIndex = nil
                    }else
                    {
                        vc.selectedValueIndex = Patient.selectedPatientInstance!.practiceList.firstIndex(where: { (practice) -> Bool in
                            if practice === addAppointment.selectedPractice
                            {
                                return true
                            }else
                            {
                                return false
                            }
                        })
                    }
                    
                    vc.popViewControllerWhenValueChanged = true
                }
                else if tableViewCell.keyLabel.text == "Facility"
                {
                    vc.keyString = "facility_name"
                    vc.arrayOfValues = facilityDictArr
                    vc.selectedValueIndex = addAppointment.selectedFacilityIndex
                    
                    vc.popViewControllerWhenValueChanged = true
                }
                else if tableViewCell.keyLabel.text == "Provider"
                {
                    vc.keyString = "prefix"
                    //NOTE: this second string is only used for provider full name. Hence removing DR. prefix in SelectAddAppointmentValueViewController when both prefix is DR. and also full name contains DR. as prefix. This needs to be changed
                    vc.secondKeyString = "full_name"
                    vc.arrayOfValues = facilityMemberDictArr
                    vc.selectedValueIndex = addAppointment.selectedProviderIndex
                    
                    vc.popViewControllerWhenValueChanged = true
                }
                else if tableViewCell.keyLabel.text == "Date preference"
                {
                    vc.keyString = "date"
                    vc.arrayOfValues = [["date":"Any Date"],["date":"Specific Date","value":"","preference":"date","minimum":"","format":PHR_DATE_DISPLAY_FORMAT_WITH_YEAR]]
                    
                    if addAppointment.todayDate != nil
                    {
                        vc.arrayOfValues[1].updateValue(CharmUtil.getDateStringWith(date: addAppointment.todayDate!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), forKey: "minimum")
                    }
                    
                    if addAppointment.spcificDate != nil{
                        vc.arrayOfValues[1].updateValue(addAppointment.spcificDate!, forKey: "value")
                    }
                    vc.selectedValueIndex = addAppointment.selectedDateIndex
                }
                else if tableViewCell.keyLabel.text == "Time preference"
                {
                    vc.keyString = "time"
                    vc.arrayOfValues = [["time":"Any Time"],["time":"Specific time","value":"","preference":"time","format":"hh:mm a"]]
                    if addAppointment.todayDate != nil
                    {
                        vc.arrayOfValues[1].updateValue(CharmUtil.getDateStringWith(date: addAppointment.todayDate!, dateFormat: "hh:mm a"), forKey: "currentTime")
                    }
                    
                    if addAppointment.spcificTimeRange != nil{
                        vc.arrayOfValues[1].updateValue(addAppointment.spcificTimeRange!, forKey: "value")
                    }
                    
                    vc.selectedValueIndex = addAppointment.selectedTimeIndex
                }
                else if tableViewCell.keyLabel.text ==  "Appointment type"
                {
                    vc.keyString = "type"
                    
                    for type in appointmentTypeArray
                    {
                        vc.arrayOfValues.append(["type":type])
                    }
                    
//                    if addAppointment.isTelehealthEnabled && addAppointment.visitTypeDictArr.count == 0
//                    {
//                        vc.arrayOfValues.append(["type":"Video consult"])
//                    }
                    vc.selectedValueIndex = addAppointment.selectedAppointmentTypeIndex
                    
                    vc.popViewControllerWhenValueChanged = true
                }
                else if tableViewCell.keyLabel.text ==  "Visit type"
                {
                    vc.keyString = "VISIT_TYPE"
                    vc.arrayOfValues = addAppointment.visitTypeDictArr

                    vc.selectedValueIndex = addAppointment.selectedVisitTypeIndex
                    
                    vc.popViewControllerWhenValueChanged = true
                }
                else if tableViewCell.keyLabel.text ==  "Slot preference"
                {
                    vc.keyString = "type"
                    for type in slotPreferance
                    {
                        vc.arrayOfValues.append(["type":type])
                    }

                    vc.selectedValueIndex = addAppointment.slectedSlotPrefreanceIndex
                    
                    vc.popViewControllerWhenValueChanged = true
                }
                else if tableViewCell.keyLabel.text ==  "Slot time"
                {
                    vc.keyString = "start_time"
                    if addAppointment.slectedSlotPrefreanceIndex != nil
                    {
                        vc.arrayOfValues = slotTimingDictArr[addAppointment.slectedSlotPrefreanceIndex!]
                    }
                    
                    vc.selectedValueIndex = addAppointment.selectedSlotTimeIndex
                    
                    vc.popViewControllerWhenValueChanged = true
                }
                    
            }
            
            customTableView.deselectRow(at: selectedIndex!, animated: true)
        }
    }
    
    func canNavigateViewController() ->  Bool
    {
        if let tableViewCell = customTableView.cellForRow(at: selectedIndex!) as? AddAppointmentTableViewCell
        {
            if tableViewCell.keyLabel.text == "Practice"
            {
                return true
            }
            else if tableViewCell.keyLabel.text == "Facility"
            {
                if addAppointment.selectedPractice == nil
                {
                    showAlert(message: "\(getString(key: "com.charmphr.addAppointments.select")) practice")
                    return false
                }else
                {
                    return true
                }
            }
            else if tableViewCell.keyLabel.text == "Provider"
            {
                if addAppointment.selectedFacilityIndex == nil
                {
                    showAlert(message: "\(getString(key: "com.charmphr.addAppointments.select")) facility")
                    return false
                }else
                {
                    return true
                }
            }
            else if tableViewCell.keyLabel.text == "Date preference"
            {
                if addAppointment.selectedProviderIndex == nil
                {
                    showAlert(message: "\(getString(key: "com.charmphr.addAppointments.select")) provider")
                    return false
                }else
                {
                    if addAppointment.isConfigured == true
                    {
                        if addAppointment.selectedVisitTypeIndex != nil || addAppointment.visitTypeDictArr.isEmpty
                        {
                            return true
                        }else
                        {
                            showAlert(message: "\(getString(key: "com.charmphr.addAppointments.select")) visit type")
                            return false
                        }
                    }else
                    {
                        return true
                    }
                }
            }
            else if tableViewCell.keyLabel.text == "Time preference"
            {
                if addAppointment.selectedProviderIndex == nil
                {
                    showAlert(message: "\(getString(key: "com.charmphr.addAppointments.select")) provider")
                    return false
                }else
                {
                    if addAppointment.isConfigured == true
                    {
                        if addAppointment.selectedVisitTypeIndex != nil || addAppointment.visitTypeDictArr.isEmpty
                        {
                            return true
                        }else
                        {
                            showAlert(message: "\(getString(key: "com.charmphr.addAppointments.select")) visit type")
                            return false
                        }
                    }else
                    {
                        return true
                    }
                }
            }
            else if tableViewCell.keyLabel.text ==  "Appointment type"
            {
                return true
            }
            else if tableViewCell.keyLabel.text ==  "Visit type"
            {
                if addAppointment.selectedProviderIndex == nil
                {
                    showAlert(message: "\(getString(key: "com.charmphr.addAppointments.select")) provider")
                    return false
                }
                else{
                    return true
                }
            }
            else if tableViewCell.keyLabel.text ==  "Slot preference"
            {
                return true
            }
            else if tableViewCell.keyLabel.text ==  "Slot time"
            {
                if addAppointment.slectedSlotPrefreanceIndex != nil
                {
                    var isSlottimeAvailableForSelectedDate = false
                    for slotArr in slotTimingDictArr
                    {
                        if slotArr.count > 0
                        {
                            isSlottimeAvailableForSelectedDate = true
                            break
                        }
                    }
                    
                    if isSlottimeAvailableForSelectedDate == false
                    {
                        if workingDaysDict != nil
                        {
                            if addAppointment.selectedDate != nil
                            {
                                let calender = Calendar(identifier: .gregorian)
                                if (workingDaysDict!.keys.firstIndex(of: "\(calender.component(.weekday, from: addAppointment.selectedDate!) - 1)") == nil) && addAppointment.showWaitList
                                {
                                    let alertController = UIAlertController(title: getString(key: "com.charmphr.addAppointments.waitlist.available.title"), message: getString(key: "com.charmphr.addAppointments.waitlist.available.message"), preferredStyle: .alert)
                                                        
                                    let noAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.common.no"), style: .destructive) { (alert) in
                                        self.updateSlotPreference(row: self.addAppointment.slectedSlotPrefreanceIndex!)
                                            
                                    }
                                                        
                                    let yesAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.common.yes"), style: .default) { (alert) in
                                            self.addAppointment.isWaitlistSelected = true
                                            self.updateSlotTimePreference(row: 0)
                                        
                                    }
                                                        
                                    alertController.addAction(noAction)
                                    alertController.addAction(yesAction)
                                    alertController.show()
                                    
                                    return false
                                }
                            }
                            else
                            {
            //                      select date alert
                            }
                        }
                        showAlert(message: getString(key: "com.charmphr.addAppointments.slotTime.forSelectedDate"))
                        return false
                    }
                    else if slotTimingDictArr[addAppointment.slectedSlotPrefreanceIndex!].isEmpty
                    {
                            
                        showAlert(message: "\(getString(key: "com.charmphr.addAppointments.slotTime.forSelectedSlotPreference"))")
                        return false
                    }
                    else
                    {
                        return true
                    }
                }else
                {
                    return false
                }
            }
        }
        return true
    }
    
    func showAlert(message:String)
    {
        let alertController = UIAlertController(title: nil, message:message, preferredStyle: .alert)
        let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.show()
    }
    
    //MARK: - views delegate methods
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == REASON_TEXTVIEW_TAG
        {
            updateAppointmentReason(string: textView.text)
        }
    }
    
    func mdTextFieldDidBeginEditing(_ textField: MDTextField!) {
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        }
    }
    
    func mdTextFieldDidEndEditing(_ textField: MDTextField!) {
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
    }
    
    @objc func datePickerValueChanged(datePicker:UIDatePicker)
    {
        if selectedIndex != nil
        {
            if let cell = customTableView.cellForRow(at: selectedIndex!) as? AddAppointmentTableViewCell
            {
                cell.textField.text = CharmUtil.getDateStringWith(date: datePicker.date, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                updateSelectedDate(date: datePicker.date)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    
    // MARK: - action methods
    @objc func doneBtnClicked()
    {
        
        self.view.endEditing(true)
        
//        if isbluefinPaymentEnabledInAppointment()
//        {
//            return
//        }
        
        if(addAppointment.appoimentTypeStr == appointmentTypeVideoCall && addAppointment.isTelehealthEnabled == false)
        {
            CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.addAppointments.telehealth.notenabled.error"), msg:"")
            return
        }
        
        if addAppointment.selectedFacilityIndex == nil || addAppointment.selectedProviderIndex == nil || isNilOrEmpty(string: addAppointment.reasonStr)
        {
            showAlertFillAllFiledCorrtlyAlert()
        }
        else if addAppointment.isConfigured == false
        {
            if (addAppointment.selectedTimeIndex == 0 || (addAppointment.selectedTimeIndex == 1 && addAppointment.spcificTimeRange != nil && addAppointment.spcificTimeRange != "")) && addAppointment.selectedDateIndex == 0 || (addAppointment.selectedDateIndex == 1 && addAppointment.spcificDate != nil)
            {
                requestAddAppointment()
            }else
            {
                showAlertFillAllFiledCorrtlyAlert()
            }
        }
        else if addAppointment.isConfigured == true
        {
            if  addAppointment.selectedDate == nil || addAppointment.slectedSlotPrefreanceIndex == nil || (!addAppointment.isWaitlistSelected && addAppointment.selectedSlotTimeIndex == nil)
            {
                showAlertFillAllFiledCorrtlyAlert()
            }else
            {
                requestAddAppointment()
            }
        }
        else
        {
            showAlertFillAllFiledCorrtlyAlert()
        }
    }
    
    func requestAddAppointment()
    {
        
        if addAppointment.paymentInfo != nil && !(addAppointment.paymentInfo?.isPaymentSuccess ?? false) && (addAppointment.paymentInfo?.chargeAmount?.toFloatOrNil() ?? 0.0 ) > 0.0
        {
            let amount = addAppointment.paymentInfo?.chargeAmount?.toFloatOrNil() ?? 0.0
            
            let reminder = amount.truncatingRemainder(dividingBy: 1)
            var alertStr = ""
            if(reminder == 0){
                alertStr = "\(getString(key: "com.charmphr.addAppointments.payment.alert.message")) \("\(addAppointment.paymentCurrencySymbol ?? "")\(Int(amount))") to book appointment"
            }
            else{
                alertStr = "\(getString(key: "com.charmphr.addAppointments.payment.alert.message")) \("\(addAppointment.paymentCurrencySymbol ?? "")\(amount)") to book appointment"
            }
            let alertVC = UIAlertController(title: nil, message:alertStr, preferredStyle: .alert)
            let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.addAppointments.payment.paynow"), style: .default, handler: { (UIAlertAction) in
                self.makePayment()
            })
            let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .default, handler: { (UIAlertAction) in

            })
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            alertVC.show()
        }
        else
        {
            self.showActivityIndicatorWithoutHidingTableview()
            
            if addAppointment.isWaitlistSelected
            {
                charmConnectionHandler.requestWaitlistAppointment(json: JsonBuilder.convertAddApointmentToJson(addAppointment: addAppointment, facilityDictArr: facilityDictArr, appointmentType: appointmentTypeArray, providerDictArr: facilityMemberDictArr, arrayOfSlotTimeDict: slotTimingDictArr), identificationKey: "addAppointment")
            }
            else if addAppointment.isConfigured == false
            {
                charmConnectionHandler.requestAddAppointment(patientId: Patient.selectedPatientInstance!.patientId, json: JsonBuilder.convertAddApointmentToJson(addAppointment: addAppointment, facilityDictArr: facilityDictArr, appointmentType: appointmentTypeArray, providerDictArr: facilityMemberDictArr, arrayOfSlotTimeDict: slotTimingDictArr), identificationKey: "addAppointment")
            }else
            {
                charmConnectionHandler.addNewAppointment(patientId: Patient.selectedPatientInstance!.patientId, json: JsonBuilder.convertAddApointmentToJson(addAppointment: addAppointment, facilityDictArr: facilityDictArr, appointmentType: appointmentTypeArray, providerDictArr: facilityMemberDictArr, arrayOfSlotTimeDict: slotTimingDictArr), identificationKey: "addAppointment")
            }
        }
    }
    
    
    func makePayment()
    {
        
        let facilityId = facilityDictArr[addAppointment.selectedFacilityIndex!]["facility_id"] as! String
        let memberId = facilityMemberDictArr[addAppointment.selectedFacilityIndex!]["member_id"] as! String
        let practiceId = addAppointment.selectedPractice?.practiceId ?? ""
        
        if addAppointment.paymentInfo?.transactionInfo?.gateway == "BLUEFIN" {
            
            let paymentInfo = addAppointment.paymentInfo
            paymentInfo?.transactionInfo?.facilityId = facilityId
            paymentInfo?.transactionInfo?.memberId = memberId
            paymentInfo?.transactionInfo?.practiceId = practiceId
            paymentInfo?.transactionInfo?.paymentAmount = paymentInfo?.chargeAmount
            paymentInfo?.transactionInfo?.service = paymentServiceAppointment
            
            let paymentViewController = PaymentViewController()
            paymentViewController.paymentInfo = paymentInfo
            
            paymentViewController.amountPayableStr = paymentInfo?.chargeAmount ?? ""
            paymentViewController.currencySymbol = addAppointment.paymentCurrencySymbol ?? ""
            paymentViewController.delegate = self
            
            self.navigationController?.pushViewController(paymentViewController, animated: true)
            
        }
        else{
        
        showActivityIndicatorWithoutHidingTableview()
       let json = JsonBuilder.createJsonFromCreateTransaction(paymentInfo: addAppointment.paymentInfo, service: paymentServiceAppointment, practiceId: practiceId, facilityId: facilityId, memberid: memberId)
        charmConnectionHandler.createTransaction(patientId: Patient.selectedPatientInstance!.patientId, json: json, identificationKey: "cretaeTranstion")
        }
    }
    
    func openRazorPay(paymentInfo: PaymentInfo?)
    {
        guard let paymentInfo else { return }
        self.razorpay = RazorpayCheckout.initWithKey("\(paymentInfo.transactionInfo?.publicToken ?? "")", andDelegate: self)
        
        let options: [String:Any] = [
            "amount": "\((paymentInfo.chargeAmount?.toFloatOrNil() ?? 0 ) * 100)", //This is in currency subunits. 100 = 100 paise= INR 1.
            "currency": "\("INR")",
            "description": "Appointment booking amount",
            "order_id": "\(paymentInfo.transactionInfo?.razorPayOrderId ?? "")",
            "image": "", //TODO: can give image
            "name": "\(facilityDictArr[addAppointment.selectedFacilityIndex!]["facility_name"] as! String)",
            "prefill": [
                "contact": "\(paymentInfo.transactionInfo?.mobile ?? "")",
                "email": "\(paymentInfo.transactionInfo?.emailId ?? "")"
            ],
            "theme": [
                "color": "\(THEME_COLOR)"
            ]
        ]
        
        razorpay.open(options)
    }
    
    func showAlertFillAllFiledCorrtlyAlert()
    {
        let alertController = UIAlertController(title: nil, message: getString(key: "com.charmphr.addAppointments.fillFormFully"), preferredStyle: .alert)
        alertController.addAction(CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .cancel, handler: nil))
        alertController.show()
        
    }
    
    func showActivityIndicatorWithoutHidingTableview()
    {
        self.view.isUserInteractionEnabled = false
        self.view.bringSubviewToFront(activityIndicatorView)
        activityIndicatorView.startAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    override func showActivityIndicator()
    {
        self.view.isUserInteractionEnabled = false
        super.showActivityIndicator()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func hideActivityIndicator()
    {
        self.view.isUserInteractionEnabled = true
        super.hideActivityIndicator()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // MARK: - razor pay delegate methods
    func onPaymentError(_ code: Int32, description str: String) {
        debugPrintLog("Error in payment with : \(str) \(code)")
        let alertVC = UIAlertController(title: nil, message:"\(getString(key: "com.charmphr.addAppointments.payment.alert.error"))", preferredStyle: .alert)
        let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.addAppointments.payment.paynow"), style: .default, handler: { (UIAlertAction) in
            self.openRazorPay(paymentInfo: self.addAppointment.paymentInfo)
        })
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .default, handler: { (UIAlertAction) in

        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        alertVC.show()
    }
        
    func onPaymentSuccess(_ payment_id: String) {
        showActivityIndicator()
        charmConnectionHandler.updateTransaction(patientId: addAppointment.paymentInfo?.transactionInfo?.patientId ?? "" , practiceId : addAppointment.selectedPractice?.practiceId ?? "", gateway:addAppointment.paymentInfo?.transactionInfo?.gateway ?? "", transactionId: addAppointment.paymentInfo?.transactionInfo?.transactionId ?? "", identificationKey: "updatPayment")
    }
    
    //MARK: - Bluefin Payment delegate
    
    func onReceiptIdCreated(receiptId: String) {
        
        addAppointment.receiptId  = receiptId
        addAppointment.paymentInfo?.isPaymentSuccess = true
        requestAddAppointment()
    }
    
    
    // MARK: - other methods

    func isbluefinPaymentEnabledInAppointment() -> Bool{
        if addAppointment.paymentInfo?.transactionInfo?.gateway != nil && addAppointment.paymentInfo?.transactionInfo?.gateway == "BLUEFIN"
        {
            CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.addAppointments.bluefin.alert.message"), msg: nil)
            return true
        }
        return false
    }
}



class TextFieldTableViewCell : UITableViewCell , UITextViewDelegate
{
    var heightOfTextView = 50
    let keyLabel = UILabel()
    let textView = UITextView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        keyLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        self.contentView.addSubview(keyLabel)
        
        textView.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        textView.textColor = .black
        textView.delegate = self
        textView.addCornerRadius(.SMALL)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_VIEW_BORDER_COLOR).cgColor
        self.contentView.addSubview(textView)
        
        keyLabel.setTop(offSet: Y_SPACE)
        keyLabel.setLeft(offSet: 10)
        keyLabel.setRight(offSet: -10)
        keyLabel.setBottomRelatedToView(offSet: -5.5, relatedView: textView, relatedAttribute: .top)
        
        textView.setLeft(offSet: 10)
        textView.setRight(offSet: -10)
        textView.setBottom(offSet: -Y_SPACE)
        textView.setHeight(constant: CGFloat(heightOfTextView), relatedBy: .equal)
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
}
