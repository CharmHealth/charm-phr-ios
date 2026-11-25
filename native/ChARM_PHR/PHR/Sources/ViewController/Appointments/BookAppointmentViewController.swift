//
//  BookAppointmentViewController.swift
//  phr
//
//  Created by Raghul D on 22/04/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import Razorpay
import JTAppleCalendar
import WebKit

class BookAppointmentViewController: AddDataUIViewController , selectAddAppointmentValueViewControllerDelegate , CharmConnectionHandlerDelegate, CharmConnectionV2HandlerDelegate , PaymentViewControllerDelegate , RazorpayPaymentCompletionProtocol , JTACMonthViewDataSource , JTACMonthViewDelegate , NoDataViewDelegate{
    
    let bookAppointmentFacilityFetchCode = 1
    let bookAppointmentFacilityFetchFromPracticeCode = 5
    let bookAppointmentMemberFetchCode = 2
    let bookAppointmentAppointmentConfigFetchCode = 3
    let bookAppointmentSlotsFetchCode = 4
    let bookAppointmentPracticeFetchCode = 6
    let bookAppointmentAppointmentTypeCode = 7
    let bookAppointmentDatePrefCode = 8
    let bookAppointmentTimePrefCode = 9
    let bookAppointmentVisitTypePrefCode = 10
    let bookAppointmentSlotPrefPrefCode = 11
    let bookAppointmentSlotTimePrefCode = 12

    
    var bookAppointmentView: BookAppointmentView? = nil
    
    var bookAppointmentData = BookAppointmentData()
    
    var charmConnectionHandler:CharmConnectionHandler?
    
    weak var delegate: AddViewControllerDelegate? = nil
    
    var reBookAppointment: Appointment? = nil
    private var isRebook: Bool? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookAppointmentView = BookAppointmentView.init()
        self.view = bookAppointmentView!
        
        bookAppointmentView?.errorPage.delegate = self
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.v2Delegate = self
        
        self.navigationItem.title = getString(key: "com.charmphr.addAppointments.title")
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        self.navigationItem.largeTitleDisplayMode = .never
        
        updatePracticeList()
        if reBookAppointment != nil{
            isRebook = true
            setRebookAppointmentPractice()
        }
    }
    
    func updatePracticeList(){
        bookAppointmentData.practiceList = getPHREntryEnabledPractices(moduleId: appointmentModelId)
        
        if bookAppointmentData.practiceList.count == 1 {
            bookAppointmentView?.practiceView.isHidden = true
            bookAppointmentData.selectedPractice = bookAppointmentData.practiceList.first ?? Practice()
            bookAppointmentView?.practiceView.textField?.text = bookAppointmentData.selectedPractice.practiceName
            getFacilityList()
        }
        else{

            bookAppointmentView?.memberView.isHidden = true
            bookAppointmentView?.facilityView.isHidden = true
            resetAppointmentData(localizedKey: "com.charmphr.appointments.practice.select_info")
            bookAppointmentView?.practiceView.isHidden = false
            hideActivityIndicator()
            bookAppointmentView?.practiceView.target(forAction: #selector(onPracticeClick), withSender: self)
            
            bookAppointmentView?.practiceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPracticeClick)))
            

        }
        
        bookAppointmentView?.facilityView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFacilityClick)))
        bookAppointmentView?.memberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMemberClick)))
        
        bookAppointmentView?.datePrefView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDatePrefClick)))
        bookAppointmentView?.timePrefView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTimePrefClick)))

        
        bookAppointmentView?.visitTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onVisitTypeClick)))

        bookAppointmentView?.appointmentTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAppointmentTypeClick)))

        bookAppointmentView?.slotPrefView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSlotPrefClick)))
        bookAppointmentView?.slotTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSlotTimeClick)))

        
        
        bookAppointmentView?.calendarLeftArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCalendarLeftArrowClick)))

        bookAppointmentView?.calendarRightArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCalendarRightArrowClick)))

        bookAppointmentView?.calendarMonthView.register(MDCalendarCell.self, forCellWithReuseIdentifier: "CalCell")
        
        //bookAppointmentView?.calendarView.register(MDCalendarHeaderCell.self, forSupplementaryViewOfKind: "CalHeader", withReuseIdentifier: "CalHeader")
        
        bookAppointmentView?.calendarMonthView.ibCalendarDataSource = self
        bookAppointmentView?.calendarMonthView.ibCalendarDelegate = self
        bookAppointmentView?.calendarMonthView.reloadData()
        

    }
    
//MARK: - Rebook Appointment functions
    
    func setRebookAppointmentPractice(){
        if let practiceIndex = bookAppointmentData.practiceList.firstIndex(where: { practiceObj in
            return practiceObj.practiceId == reBookAppointment?.practiceId
        }){
            onPracticeSelected(index: practiceIndex)
        }
        else{
            CharmUtil.createOkayAlertWith(title: "Selected practice is unavailable. Please select another practice.", msg: "", okClicked: { [self] in
                reBookAppointment = nil
            })
        }
        
        if bookAppointmentData.practiceList.count == 1 {
            bookAppointmentView?.practiceView.isHidden = true
        }
        else{
            bookAppointmentView?.practiceView.isHidden = false
            bookAppointmentView?.practiceView.target(forAction: #selector(onPracticeClick), withSender: self)
            bookAppointmentView?.practiceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPracticeClick)))
        }
    }
    
    func setRebookAppointmentDatePref(){
        bookAppointmentData.selectedDate = nil
        bookAppointmentView?.datePrefView.textField?.text = Any_Date
    }
    
    func setRebookAppointmentTimePref(){
        
        let valueString = "\(reBookAppointment?.appointmentStartTime ?? "") - \(reBookAppointment?.appointmentEndTime?.getStringFromDate(dateFormat: "hh:mm a") ?? "")"
        bookAppointmentView?.timePrefView.textField?.text = valueString
        bookAppointmentData.appointmentTimeStr = valueString
    }
    
    func setRebookAppointmentType(becomeReasonFieldRespond: Bool){
        
        if let appointmentType = bookAppointmentData.appointmentTypeList.first(where: { appointmentTypeList in
            return appointmentTypeList == reBookAppointment?.appointmentType
        }){
            bookAppointmentView?.appointmentTypeView.textField?.text = appointmentType
            if becomeReasonFieldRespond{
                bookAppointmentView?.reasonTextView.becomeFirstResponder()
            }
        }
        else{
            CharmUtil.createOkayAlertWith(title: "Selected appointment type is unavailable. Please select another appointment type.", msg: "", okClicked: { [self] in
                bookAppointmentView?.appointmentTypeView.textField?.text = ""
                reBookAppointment = nil
            })
        }
    }
    
    func setRebookAppointmentVisitType(){
        if let visitTypeIndex = bookAppointmentData.appointmentConfig?.visitTypeList.firstIndex(where: { visitTypesObj in
            return visitTypesObj.appointmentMode == reBookAppointment?.appointmentType
        }){
            if let visitType = bookAppointmentData.appointmentConfig?.visitTypeList[visitTypeIndex]{
                var visitTypeName = visitType.visitType ?? ""
                if bookAppointmentData.appointmentConfig?.showVisitDuration == true {
                    visitTypeName += " [ \(visitType.duration ?? 0) mins ]"
                }
                onVisitTypeSelected(index: visitTypeIndex, selectedStr: visitTypeName)
            }
        }
        else{
            bookAppointmentView?.slotNoDataView.isHidden = true
            bookAppointmentView?.slotPrefView.isHidden = true
            bookAppointmentView?.slotTimeView.isHidden = true
            bookAppointmentView?.calendarView.isHidden = true
            bookAppointmentView?.slotDateView.isHidden = true
            
            bookAppointmentView?.otherDetailsCard.isHidden = true
            bookAppointmentView?.showErrorMsg(localizedKey: "com.charmphr.appointments.empty_visit_type")
            CharmUtil.createOkayAlertWith(title: "Selected visit type is unavailable. Please select another visit type.", msg: "", okClicked: { [self] in
                reBookAppointment = nil
            })
        }
    }
    
    func setRebookAppointmentSlotTimeAndSlotPref(){
        
        if let memberAvailability = bookAppointmentData.selectedMemberAvailability {
            
            let startOfDay = Date().startOfDay
            let morningStartTime: Int = Int(startOfDay.getStringFromDate(dateFormat: "HH")) ?? 0
            let noonStartTime = Int(startOfDay.add(hours: 12).getStringFromDate(dateFormat: "HH")) ?? 0
            let eveStartTime = Int(startOfDay.add(hours: 16).getStringFromDate(dateFormat: "HH")) ?? 0
            
            let appointmentStartTime_24_hours: Int = Int(reBookAppointment?.appointmentDate?.getStringFromDate(dateFormat: "HH") ?? "") ?? 0
            
            let morningSlots =  memberAvailability.splitSessions()[MemberSession.Morning] ?? []
            let noonSlots =  memberAvailability.splitSessions()[MemberSession.Noon] ?? []
            let eveningSlots =  memberAvailability.splitSessions()[MemberSession.Evening] ?? []
             
            if let slotTime = morningSlots.first(where: { memberSlotObj in
                return memberSlotObj.startTime?.getStringFromDate(dateFormat: charmDisplayTimeFormat) == reBookAppointment?.appointmentStartTime
            }){
                onSlotPrefSelected(index: 0)
                onSlotTimeSelected(selectedItem: slotTime.startTime?.getStringFromDate(dateFormat: charmDisplayTimeFormat))
                setAppointmentReasonView(becomeReasonFieldRespond: true)
            }
            else if appointmentStartTime_24_hours >= morningStartTime && appointmentStartTime_24_hours < noonStartTime && !morningSlots.isEmpty{
                onSlotPrefSelected(index: 0)
                callUnavailableSlotTimeError()
                setAppointmentReasonView(becomeReasonFieldRespond: false)
            }
            else if let slotTime = noonSlots.first(where: { memberSlotObj in
                return memberSlotObj.startTime?.getStringFromDate(dateFormat: charmDisplayTimeFormat) == reBookAppointment?.appointmentStartTime || memberSlotObj.startTime?.getStringFromDate(dateFormat: "hh a") == reBookAppointment?.appointmentDate?.getStringFromDate(dateFormat: "hh a")
            }){
                onSlotPrefSelected(index: 1)
                onSlotTimeSelected(selectedItem: slotTime.startTime?.getStringFromDate(dateFormat: charmDisplayTimeFormat))
                setAppointmentReasonView(becomeReasonFieldRespond: true)
            }
            else if appointmentStartTime_24_hours >= noonStartTime && appointmentStartTime_24_hours < eveStartTime && !noonSlots.isEmpty{
                onSlotPrefSelected(index: 1)
                callUnavailableSlotTimeError()
                setAppointmentReasonView(becomeReasonFieldRespond: false)
            }
            else if let slotTime = eveningSlots.first(where: { memberSlotObj in
                return memberSlotObj.startTime?.getStringFromDate(dateFormat: charmDisplayTimeFormat) == reBookAppointment?.appointmentStartTime || memberSlotObj.startTime?.getStringFromDate(dateFormat: "hh a") == reBookAppointment?.appointmentDate?.getStringFromDate(dateFormat: "hh a")
            }){
                onSlotPrefSelected(index: 2)
                onSlotTimeSelected(selectedItem: slotTime.startTime?.getStringFromDate(dateFormat: charmDisplayTimeFormat))
                setAppointmentReasonView(becomeReasonFieldRespond: true)
            }
            else if appointmentStartTime_24_hours >= eveStartTime && !eveningSlots.isEmpty{
                onSlotPrefSelected(index: 2)
                callUnavailableSlotTimeError()
                setAppointmentReasonView(becomeReasonFieldRespond: false)
            }
            else{
                bookAppointmentData.selectedSlotPreference = -1
                bookAppointmentView?.slotPrefView.textField?.text = ""
                CharmUtil.createOkayAlertWith(title: "Selected slot preference is unavailable. Please select another slot preference.", msg: "", okClicked: { [self] in
                    reBookAppointment = nil
                })
                setAppointmentReasonView(becomeReasonFieldRespond: false)
            }
        }
    }
    
    func setAppointmentReasonView(becomeReasonFieldRespond: Bool){
        if bookAppointmentView?.otherDetailsCard.isHidden == false{
            setRebookAppointmentType(becomeReasonFieldRespond: becomeReasonFieldRespond)
        }
    }
    
    func callUnavailableSlotTimeError(){
        CharmUtil.createOkayAlertWith(title: "Selected slot time is unavailable. Please select another slot time.", msg: "", okClicked: { [self] in
            reBookAppointment = nil
        })
    }
    
//MARK: - Other functions and target functions
    
    @objc private func onPracticeClick(){
        
        let selectVC = SelectAddAppointmentValueViewController()
        selectVC.delegate = self
        selectVC.title = bookAppointmentView?.practiceView.keyLabel.text
        
        
        var practiceNameDictArr : [Dictionary<String,Any>] = []
            
        for practice in bookAppointmentData.practiceList
        {
            practiceNameDictArr.append(["name":"\(practice.practiceName!)"])
        }
            
        selectVC.keyString = "name"
        selectVC.arrayOfValues = practiceNameDictArr
        
        if bookAppointmentData.selectedPractice.practiceId.isNilOrBlank()
            {
            selectVC.selectedValueIndex = nil
        }else
        {
            selectVC.selectedValueIndex = bookAppointmentData.practiceList.firstIndex(where: { (practice) -> Bool in
                return practice.practiceId ?? "" == bookAppointmentData.selectedPractice.practiceId ?? ""
                })
        }
        selectVC.popViewControllerWhenValueChanged = true
        
        bookAppointmentData.selectedItem = bookAppointmentPracticeFetchCode
        
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    private func onPracticeSelected(index: Int){
        
        let practice = bookAppointmentData.practiceList[index]
        
        if practice.easycareURL.isNilOrBlank() {
            
            if bookAppointmentData.selectedPractice.practiceId != practice.practiceId {
                
                bookAppointmentData.selectedPractice = bookAppointmentData.practiceList[index]
                bookAppointmentData.selectedFacility = Facility()
                bookAppointmentData.facilityList.removeAll()
                bookAppointmentView?.facilityView.textField?.text = ""
                bookAppointmentView?.practiceView.textField?.text = bookAppointmentData.selectedPractice.practiceName
                bookAppointmentView?.practiceView.showSeparator()
                
                getFacilityList()
            }
        }
        else{
            let easyTelecareURL = practice.easycareURL ?? ""
            if easyTelecareURL.isNotBlank() {
//                if let url = URL(string: easyTelecareURL) {
//                    self.navigationController?.popViewController(animated: true)
//                    UIApplication.shared.open(url)
//                }
                
                self.navigationController?.popViewController(animated: false)

                let bookAppointmentVC = EasyTelecareBookAppointmentWebViewController()
                bookAppointmentVC.urlString = easyTelecareURL
                bookAppointmentVC.delegate = self.navigationController?.viewControllers.last(where: { vc in
                    return (vc as? EasyCareBookAppointmentDelegate) != nil
                }) as? EasyCareBookAppointmentDelegate
                
                
                
                self.navigationController?.pushViewController(bookAppointmentVC, animated: true)
                
            }
        }
    }
    private func getFacilityList() {
        
        
        hideErrorPage()
     
        if reBookAppointment != nil{
            bookAppointmentData.selectFacility = true
            showActivityIndicator()
            bookAppointmentView?.practiceCard.isHidden = false
            bookAppointmentView?.facilityView.isHidden = false
            bookAppointmentView?.memberView.isHidden = true
            bookAppointmentView?.hideErrorMsg()
            bookAppointmentView?.onlineAppointmentCard.isHidden = true
            bookAppointmentView?.otherDetailsCard.isHidden = true
            bookAppointmentView?.requestAppointmentCard.isHidden = true
        }
        else{
            if bookAppointmentData.practiceList.count == 1{
                showActivityIndicator(hideView: true)
            }
            else{
                showActivityIndicator()
            }
        }
        charmConnectionHandler?.getFacilityList(selectedPractice: bookAppointmentData.selectedPractice , identificationKey: "getFacility")
    }
    
    private func onAppointmentConfigSuccess(){
        
        bookAppointmentData.selectedDate = nil
        bookAppointmentData.appointmentTimeStr = nil
        
        bookAppointmentView?.datePrefView.textField?.text = ""
        bookAppointmentView?.timePrefView.textField?.text = ""
        
        
        bookAppointmentData.calendarDates.selectedDate = nil
        
        bookAppointmentView?.slotDateView.textField?.text = ""
        bookAppointmentData.lastSelectedSlotStr = nil
        bookAppointmentData.selectedVisitType = nil
        
        bookAppointmentData.slotMetaData = SlotMetaData()
        bookAppointmentData.calendarDataMap.removeAll()
        
        bookAppointmentView?.calendarMonthView.deselectAllDates()

        bookAppointmentView?.slotTimeView.textField?.text = ""

        if let appointmentConfig = bookAppointmentData.appointmentConfig {
            bookAppointmentView?.errorPage.isHidden = true
            bookAppointmentView?.errorMsgLabel.isHidden = true
            
            bookAppointmentData.appointmentTypeList.removeAll()
            bookAppointmentData.appointmentTypeList.append(contentsOf: [appointmentTypeInPerson , appointmentTypePhoneCall])
            
            if appointmentConfig.isTelehealthEnabled {
                bookAppointmentData.appointmentTypeList.append(appointmentTypeVideoCall)
            }
            
            bookAppointmentView?.appointmentTypeView.textField?.text = ""
            
            bookAppointmentData.calendarDates.todaysDate = appointmentConfig.currentFacilityTimezone
            
            bookAppointmentView?.calendarMonthView.reloadData()
            
            if appointmentConfig.facilityTimezone.isNilOrBlank(){
                bookAppointmentView?.timezoneLabel.isHidden = true
            }
            else{
                bookAppointmentView?.timezoneLabel.isHidden = false
                var timezone = getString(key:  "com.charmphr.appointments.timezone.info", with: [appointmentConfig.facilityTimezone ?? ""])
                let timeZoneLength = appointmentConfig.facilityTimezone?.count ?? 0 + 2
                if appointmentConfig.showAppOnPatientTimezone != true {
                    timezone = getString(key: "com.charmphr.appointments.patient.timezone.info", with: [appointmentConfig.facilityTimezone ?? ""])
                    let attributedString = NSMutableAttributedString(string: timezone, attributes: [.font: UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUM_LIGHT)])
                    attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .semibold), range: NSMakeRange(74, timeZoneLength))
                    
                    bookAppointmentView?.timezoneLabel.attributedText = attributedString
                }
                else{
                    let attributedString = NSMutableAttributedString(string: timezone, attributes: [.font: UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUM_LIGHT)])
                    attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: bookAppointmentFontSize, Weight: .semibold), range: NSMakeRange(66, timeZoneLength))
                    
                    bookAppointmentView?.timezoneLabel.attributedText = attributedString
                }
            }
            
            if appointmentConfig.isEnabled {
                bookAppointmentView?.onlineAppointmentCard.isHidden = false
                bookAppointmentView?.requestAppointmentCard.isHidden = true
                
                if appointmentConfig.visitTypeList.isEmpty{
                    bookAppointmentView?.visitTypeView.isHidden = true
                    bookAppointmentView?.otherDetailsCard.isHidden = false
                    
                    bookAppointmentView?.appointmentTypeView.showImgView()
                    setUpDateSlots()
                    if reBookAppointment == nil{
                        bookAppointmentView?.appointmentTypeView.textField?.text = bookAppointmentData.appointmentTypeList[0]
                    }
                }
                else{
                    bookAppointmentView?.appointmentTypeView.hideImgView()
                    hideActivityIndicator()
                    bookAppointmentView?.visitTypeView.textField?.text = ""
                    bookAppointmentView?.visitTypeView.isHidden = false
                    
                    if reBookAppointment != nil{
                        setRebookAppointmentVisitType()
                    }
                    else{
                        bookAppointmentView?.slotNoDataView.isHidden = true
                        bookAppointmentView?.slotPrefView.isHidden = true
                        bookAppointmentView?.slotTimeView.isHidden = true
                        bookAppointmentView?.calendarView.isHidden = true
                        bookAppointmentView?.slotDateView.isHidden = true
                        
                        bookAppointmentView?.otherDetailsCard.isHidden = true
                        bookAppointmentView?.showErrorMsg(localizedKey: "com.charmphr.appointments.empty_visit_type")
                    }
                }
            }
            else{
                
                hideActivityIndicator()
                bookAppointmentView?.onlineAppointmentCard.isHidden = true
                bookAppointmentView?.requestAppointmentCard.isHidden = false
                bookAppointmentView?.otherDetailsCard.isHidden = false
                
                bookAppointmentView?.appointmentTypeView.showImgView()
                bookAppointmentView?.appointmentTypeView.textField?.text = bookAppointmentData.appointmentTypeList[0]
            }
            
            if appointmentConfig.isCardProcessingEnabled {
                if appointmentConfig.chargeType != appointmentPaymentChargeTypeVisitBased{
                    
                    if appointmentConfig.paymentGateway == appointmentGatewayTypeBluefin && appointmentConfig.cardProcessingType == appointmentCardProcessingTypeStoreOnly {
                        bookAppointmentView?.paymentView.isHidden = true
                    }
                    else{
                        let paymentAmt = appointmentConfig.chargeAmount?.toDoubleOrNil() ?? 0
                        
                        if paymentAmt > 0{
                            let amountStr = String(format: "%.2f", paymentAmt)
                            let paymentStr = "\(appointmentConfig.paymentCurrencySymbol ?? "") \(amountStr)"
                            bookAppointmentView?.paymentView.textField?.text = paymentStr.trim()
                            bookAppointmentView?.paymentView.isHidden = false
                        }
                        else{
                            bookAppointmentView?.paymentView.isHidden = true
                        }
                    }
                }
                else{
                    bookAppointmentView?.paymentView.isHidden = true
                }
            }
            else{
                bookAppointmentView?.paymentView.isHidden = true
            }
        }
        
        if reBookAppointment != nil{
            if bookAppointmentView?.requestAppointmentCard.isHidden == false{
                setRebookAppointmentDatePref()
                setRebookAppointmentTimePref()
                setAppointmentReasonView(becomeReasonFieldRespond: true)
            }
        }
    }
    
    private func onFacilityFetchSuccess(){
        if !bookAppointmentData.facilityList.isEmpty{
            hideErrorPage()
            //show bookApppointmentButton
            
            if bookAppointmentData.selectFacility{
                bookAppointmentData.selectedFacility = bookAppointmentData.facilityList[0]
                bookAppointmentView?.facilityView.textField?.text = bookAppointmentData.selectedFacility.facilityName
                bookAppointmentView?.facilityView.isHidden = false
                getMembersList(isFirst: true)
            }
            else{
                if reBookAppointment == nil{
                    bookAppointmentView?.facilityView.isHidden = false
                    hideActivityIndicator()
                    bookAppointmentView?.facilityView.isHidden = false
                    resetAppointmentData(localizedKey: "com.charmphr.appointments.facility.select_info")
                    bookAppointmentView?.memberView.isHidden = true
                }
                else{
                    bookAppointmentView?.facilityView.isHidden = false
                    if let facilityIndex = bookAppointmentData.facilityList.firstIndex(where: { facilityObj in
                        return facilityObj.facilityId == reBookAppointment?.facilityId
                    }){
                        onFacilitySelected(index: facilityIndex)
                        bookAppointmentView?.memberView.isHidden = true
                    }
                    else{
                        hideActivityIndicator()
                        bookAppointmentView?.facilityView.isHidden = false
                        bookAppointmentView?.memberView.isHidden = true
                        CharmUtil.createOkayAlertWith(title: "Selected facility is unavailable. Please select another facility.", msg: "") { [self] in
                            resetAppointmentData(localizedKey: "com.charmphr.appointments.facility.select_info")
                            reBookAppointment = nil
                        }
                    }
                }
            }
        }
        else{
            //hide bookApppointmentButton
            hideActivityIndicator()
            resetCompleteData(localizedKey: "com.charmphr.appointments.facility.empty")
        }
    }
    
    @objc private func onFacilityClick(){
        
        let selectVC = SelectAddAppointmentValueViewController()
        selectVC.delegate = self
        selectVC.title = bookAppointmentView?.facilityView.keyLabel.text
        
        
        var facilityNameDictArr : [Dictionary<String,Any>] = []
            
        for facility in bookAppointmentData.facilityList
        {
            facilityNameDictArr.append(["name":"\(facility.facilityName ?? "")"])
        }
            
        selectVC.keyString = "name"
        selectVC.arrayOfValues = facilityNameDictArr
        
        if bookAppointmentData.selectedFacility.facilityId.isNilOrBlank()
            {
            selectVC.selectedValueIndex = nil
        }else
        {
            selectVC.selectedValueIndex = bookAppointmentData.facilityList.firstIndex(where: { (facility) -> Bool in
                return facility.facilityId ?? "" == bookAppointmentData.selectedFacility.facilityId ?? ""
            })
        }
        
        selectVC.popViewControllerWhenValueChanged = true
        
        
        bookAppointmentData.selectedItem = bookAppointmentFacilityFetchCode
        self.navigationController?.pushViewController(selectVC, animated: true)
        
    }
    
    private func onFacilitySelected(index: Int){
        
        if bookAppointmentData.selectedFacility.facilityId != bookAppointmentData.facilityList[index].facilityId {
            bookAppointmentData.selectedFacility = bookAppointmentData.facilityList[index]
            bookAppointmentData.memberList.removeAll()
            bookAppointmentView?.facilityView.textField?.text = bookAppointmentData.selectedFacility.facilityName
            bookAppointmentView?.memberView.textField?.text = ""
            bookAppointmentView?.facilityView.showSeparator()
            getMembersList()
        }
    }   
    
    private func getMembersList(isFirst: Bool = false) {
        
        hideErrorPage()
        
        if reBookAppointment != nil{
            showActivityIndicator()
            bookAppointmentView?.memberView.isHidden = false
            bookAppointmentView?.hideErrorMsg()
            bookAppointmentView?.onlineAppointmentCard.isHidden = true
            bookAppointmentView?.otherDetailsCard.isHidden = true
            bookAppointmentView?.requestAppointmentCard.isHidden = true
        }
        else{
            if isFirst {
                showActivityIndicator(hideView: true)
            }
            else{
                showActivityIndicator()
            }
        }
        charmConnectionHandler?.getMemberListForBookAppointment(facility: bookAppointmentData.selectedFacility, identificationKey: "getMember")
    }
    
    @objc private func onMemberClick(){

        let selectVC = SelectAddAppointmentValueViewController()
        selectVC.delegate = self
        selectVC.title = bookAppointmentView?.memberView.keyLabel.text
        
        var memberNameDictArr : [Dictionary<String,Any>] = []
        for member in bookAppointmentData.memberList
        {
            memberNameDictArr.append(["name": member.formMemberName() ?? ""])
        }
        selectVC.keyString = "name"
        selectVC.arrayOfValues = memberNameDictArr
        
        if bookAppointmentData.selectedMember.memberId.isNilOrBlank()
            {
            selectVC.selectedValueIndex = nil
        }else
        {
            selectVC.selectedValueIndex = bookAppointmentData.memberList.firstIndex(where: { (member) -> Bool in
                return member.memberId ?? "" == bookAppointmentData.selectedMember.memberId ?? ""
            })
        }
         
        selectVC.popViewControllerWhenValueChanged = true
        bookAppointmentData.selectedItem = bookAppointmentMemberFetchCode
        
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    private func onMemberFetchSuccess(){
        
        if !bookAppointmentData.memberList.isEmpty{
            hideErrorPage()
            
            if reBookAppointment == nil{
                bookAppointmentView?.memberView.textField?.text = ""
                bookAppointmentView?.memberView.isHidden = false
                resetAppointmentData(localizedKey: "com.charmphr.appointments.provider.select_info")
            }
            else{
                if let providerIndex = bookAppointmentData.memberList.firstIndex(where: { memberObj in
                    return memberObj.memberId == reBookAppointment?.member?.memberId
                }){
                    onMemberSelected(index: providerIndex)
                }
                else{
                    bookAppointmentView?.facilityView.isHidden = false
                    bookAppointmentView?.memberView.isHidden = false
                    hideActivityIndicator()
                    CharmUtil.createOkayAlertWith(title: "Selected provider is unavailable. Please select another provider.", msg: "", okClicked: { [self] in
                        bookAppointmentView?.memberView.textField?.text = ""
                        resetAppointmentData(localizedKey: "com.charmphr.appointments.provider.select_info")
                        reBookAppointment = nil
                    })
                }
            }
        }
        else{
            resetCompleteData(localizedKey: "com.charmphr.appointments.member.empty", showFacility: true)
        }
        if reBookAppointment == nil{
            hideActivityIndicator()
        }
        else{
            hideActivityIndicator()
            bookAppointmentView?.onlineAppointmentCard.isHidden = true
            bookAppointmentView?.otherDetailsCard.isHidden = true
            bookAppointmentView?.requestAppointmentCard.isHidden = true
        }
    }
    
    private func onMemberSelected(index: Int){
        
        if bookAppointmentData.selectedMember.memberId != bookAppointmentData.memberList[index].memberId {
            bookAppointmentData.selectedMember = bookAppointmentData.memberList[index]
            bookAppointmentView?.memberView.textField?.text = bookAppointmentData.selectedMember.formMemberName()
            getAppointmentConfig()
        }
        bookAppointmentView?.visitTypeView.hideSeparator()
    }
    
    private func getAppointmentConfig(){
        
        hideErrorPage()
        
        if reBookAppointment != nil{
            showActivityIndicator()
            bookAppointmentView?.onlineAppointmentCard.isHidden = false
            bookAppointmentView?.otherDetailsCard.isHidden = true
            bookAppointmentView?.requestAppointmentCard.isHidden = true
        }
        else{
            if bookAppointmentView?.activityIndicator.isHidden == true {
                showActivityIndicator()
            }
        }
        
        charmConnectionHandler?.getAppointmentConfig(memberId: bookAppointmentData.selectedMember.memberId ?? "", facility: bookAppointmentData.selectedFacility, identificationKey: "getAppointmentConfig")
    }
    
    @objc private func onVisitTypeClick(){

        let selectVC = SelectAddAppointmentValueViewController()
        selectVC.delegate = self
        selectVC.title = bookAppointmentView?.visitTypeView.keyLabel.text
        
        var visitTypeDictArr : [Dictionary<String,Any>] = []
        
        for visitType in bookAppointmentData.appointmentConfig?.visitTypeList ?? []
        {
            var visitTypeName = visitType.visitType ?? ""
            
            if bookAppointmentData.appointmentConfig?.showVisitDuration == true {
                visitTypeName += " [ \(visitType.duration ?? 0) mins ]"
            }
            
            visitTypeDictArr.append(["name": visitTypeName])
        }
        selectVC.keyString = "name"
        selectVC.arrayOfValues = visitTypeDictArr
        
        if bookAppointmentData.selectedVisitType?.visittypeId.isNilOrBlank() ?? true
        {
            selectVC.selectedValueIndex = nil
        }else
        {
            selectVC.selectedValueIndex = bookAppointmentData.appointmentConfig?.visitTypeList.firstIndex(where: { (visitType) -> Bool in
                return visitType.visittypeId ?? "" == bookAppointmentData.selectedVisitType?.visittypeId ?? ""
            })
        }
         
        selectVC.popViewControllerWhenValueChanged = true
        bookAppointmentData.selectedItem = bookAppointmentVisitTypePrefCode
        
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    private func onVisitTypeSelected(index: Int , selectedStr: String?){
        
        
        if bookAppointmentData.selectedVisitType == nil || bookAppointmentData.selectedVisitType?.visittypeId != bookAppointmentData.appointmentConfig?.visitTypeList[index].visittypeId  {
            
            bookAppointmentData.selectedVisitType = bookAppointmentData.appointmentConfig?.visitTypeList[index]
            bookAppointmentView?.visitTypeView.textField?.text = selectedStr
            bookAppointmentView?.visitTypeView.showSeparator()

            bookAppointmentView?.appointmentTypeView.textField?.text = bookAppointmentData.selectedVisitType?.appointmentMode
            
            bookAppointmentData.slotMetaData = SlotMetaData()
            bookAppointmentData.calendarDataMap.removeAll()
            
            
            bookAppointmentData.selectedDate = nil
            bookAppointmentData.calendarDates.selectedDate = nil
            bookAppointmentView?.slotDateView.textField?.text = ""
            
            
            if reBookAppointment != nil{
                bookAppointmentView?.otherDetailsCard.isHidden = false
                bookAppointmentView?.hideErrorMsg()
            }
            else{
                if bookAppointmentView?.otherDetailsCard.isHidden == true{
                    bookAppointmentView?.otherDetailsCard.isHidden = false
                    bookAppointmentView?.hideErrorMsg()
                }
            }

            showActivityIndicator()
            setUpDateSlots()
            
            
            if let appointmentConfig = bookAppointmentData.appointmentConfig {
                
                if appointmentConfig.isCardProcessingEnabled{
                    
                    if appointmentConfig.chargeType == appointmentPaymentChargeTypeVisitBased{
                        
                        if appointmentConfig.paymentGateway == appointmentGatewayTypeBluefin && appointmentConfig.cardProcessingType == appointmentCardProcessingTypeStoreOnly {
                            bookAppointmentView?.paymentView.isHidden = true
                        }
                        else{
                            let paymentAmt = bookAppointmentData.selectedVisitType?.charge?.toFloatOrNil() ?? 0
                            
                            if paymentAmt > 0 {
                                let paymentStr = "\(appointmentConfig.paymentCurrencySymbol ?? "") \(paymentAmt)"
                                bookAppointmentView?.paymentView.textField?.text = paymentStr.trim()
                                bookAppointmentView?.paymentView.isHidden = false
                            }
                            else{
                                bookAppointmentView?.paymentView.isHidden = true
                            }
                        }
                    }
                }
//                else{
//                    bookAppointmentView?.paymentView.isHidden = true
//                }
            }
        }
    }
    
    private func setUpDateSlots() {
        
        if reBookAppointment == nil{
            bookAppointmentView?.slotPrefView.textField?.text = bookAppointmentData.slotPreferance.getElement(at: bookAppointmentData.selectedSlotPreference)
        }
        let startDate = bookAppointmentData.calendarDates.startDateCalendar
        let endDate = startDate.endOfMonth
        
        bookAppointmentData.selectStartDate = true
        
        bookAppointmentView?.calendarMonthLabel.text = startDate.getStringFromDate(dateFormat: "MMM yyyy")
        
        bookAppointmentData.startDateForSlotFetch = startDate
        bookAppointmentData.endDateForSlotFetch = endDate
        getSlotsData(startDate: startDate, endDate: endDate)
    }
    
    private func getSlotsData(startDate: Date , endDate: Date){
        
        hideErrorPage()
        showActivityIndicator()
    
        
        var interval  = bookAppointmentData.appointmentConfig?.interval ?? 0
        var visitTypeId = ""

        if let selectedVisitType = bookAppointmentData.selectedVisitType {
            visitTypeId = selectedVisitType.visittypeId ?? ""
            interval = selectedVisitType.duration ?? 0
        }
        
        charmConnectionHandler?.getApoointmentSlots(memberId: bookAppointmentData.selectedMember.memberId ?? "", facility: bookAppointmentData.selectedFacility, startDate: startDate, endDate: endDate, visitTypeId: visitTypeId, interval: interval, identificationKey: "getSlots")
    }
    
    func onSlotFetchSuccess(slotMetaData: SlotMetaData) {
        
        hideActivityIndicator()
        
        if bookAppointmentData.slotMetaData.memberAvailability.isEmpty {
            
            bookAppointmentData.slotMetaData = slotMetaData
        }
        else{
            bookAppointmentData.slotMetaData.memberAvailability.append(contentsOf: slotMetaData.memberAvailability)
        }
        
        bookAppointmentView?.onlineAppointmentCard.isHidden = false
        bookAppointmentView?.calendarView.isHidden = false
        bookAppointmentView?.slotDateView.isHidden = false
        
        bookAppointmentView?.calendarMonthView.reloadData()

        
        if bookAppointmentData.selectStartDate {
            
            if let memberAvail = bookAppointmentData.slotMetaData.memberAvailability.first(where: {memberAvail in
                !memberAvail.memberSlots.isEmpty
            }) {
                
                bookAppointmentView?.calendarMonthView.selectDates([memberAvail.date ?? Date()])
                bookAppointmentData.calendarDates.selectedDate = memberAvail.date ?? Date()
                onCalendarDateSelected()
            }
            else{
                bookAppointmentView?.slotNoDataView.isHidden = true
                bookAppointmentView?.slotPrefView.isHidden = true
                bookAppointmentView?.slotTimeView.isHidden = true
            }
            //bookAppointmentView?.calendarView.dataSource
        }
    }
    
    func onCalendarDateSelected() {
        
        let selectedDate = bookAppointmentData.calendarDates.selectedDate ?? Date()
        
        bookAppointmentView?.slotDateView.textField?.text = selectedDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        
        bookAppointmentView?.slotTimeView.textField?.text = ""
        bookAppointmentData.lastSelectedSlotStr = nil
        
        if let memberAvailability = getMemberAvailability(date: selectedDate) {
            
            let slotMetaData = bookAppointmentData.slotMetaData
            if memberAvailability.memberSlots.isEmpty {
                bookAppointmentView?.slotNoDataView.isHidden = false
                bookAppointmentView?.slotPrefView.isHidden = true
                bookAppointmentView?.slotTimeView.isHidden = true
             
                if slotMetaData.showWaitingList && slotMetaData.memberWorkTiming.first(where: {
                    memWorkTiming in
                    memWorkTiming.dayOfWeek == selectedDate.weekday
                })?.isMemberWorking == true {
                    bookAppointmentView?.showWaitlistView()
                }
                else{
                    bookAppointmentView?.hideWaitlistView()
                }
            }
            else{
                
                bookAppointmentView?.hideWaitlistView()
                bookAppointmentData.selectedMemberAvailability = memberAvailability
                
                let sessions = memberAvailability.splitSessions()
                
                
                bookAppointmentData.noSlotSessions = []
                
                if sessions[.Morning]?.isEmpty == false {
                    bookAppointmentData.selectedSlotPreference = 0
                }
                else if sessions[.Noon]?.isEmpty == false {
                    bookAppointmentData.selectedSlotPreference = 1
                }
                else {
                    bookAppointmentData.selectedSlotPreference = 2
                }
                

                 
                if sessions[.Morning]?.isEmpty == true {
                    bookAppointmentData.noSlotSessions.append(bookAppointmentData.slotPreferance[0])
                }
                if sessions[.Noon]?.isEmpty == true {
                    bookAppointmentData.noSlotSessions.append(bookAppointmentData.slotPreferance[1])
                }
                if sessions[.Evening]?.isEmpty == true {
                    bookAppointmentData.noSlotSessions.append(bookAppointmentData.slotPreferance[2])
                }
               
                
                bookAppointmentView?.slotPrefView.textField?.text = bookAppointmentData.slotPreferance[bookAppointmentData.selectedSlotPreference]
                
                
                bookAppointmentView?.slotNoDataView.isHidden = true
                bookAppointmentView?.slotPrefView.isHidden = false
                bookAppointmentView?.slotTimeView.isHidden = false
                
                if bookAppointmentView?.slotPrefView.isHidden == false && bookAppointmentView?.slotTimeView.isHidden == false{
                    if reBookAppointment != nil{
                        setRebookAppointmentSlotTimeAndSlotPref()
                    }
                }
            }
        }
    }
    
    @objc func onDatePrefClick(){
        let selectVC = SelectAddAppointmentValueViewController()
        selectVC.delegate = self
        selectVC.title = bookAppointmentView?.datePrefView.keyLabel.text
        
        selectVC.keyString = "date"
        selectVC.arrayOfValues = [["date":"Any Date"],["date":"Specific Date","value":"","preference":"date","minimum":"","format":PHR_DATE_DISPLAY_FORMAT_WITH_YEAR]]
        
        if let date = bookAppointmentData.appointmentConfig?.currentFacilityTimezone
        {
            selectVC.arrayOfValues[1].updateValue(date.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), forKey: "minimum")
        }
        
        if let selectedDate = bookAppointmentData.selectedDate {
            selectVC.arrayOfValues[1].updateValue(selectedDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), forKey: "value")
        }
        
        
        if bookAppointmentView?.datePrefView.textField?.text.isNilOrBlank() != true{
            selectVC.selectedValueIndex = bookAppointmentData.selectedDate == nil ? 0 : 1
        }
        bookAppointmentData.selectedItem = bookAppointmentDatePrefCode
        
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    @objc func onTimePrefClick(){
        
        let selectVC = SelectAddAppointmentValueViewController()
        selectVC.delegate = self
        selectVC.title = bookAppointmentView?.timePrefView.keyLabel.text
        
        selectVC.keyString = "time"
        selectVC.arrayOfValues = [["time":"Any Time"],["time":"Specific time","value":"","preference":"time","format":"hh:mm a"]]
        
        
        if let date = bookAppointmentData.appointmentConfig?.currentFacilityTimezone
        {
            selectVC.arrayOfValues[1].updateValue( date.getStringFromDate(dateFormat: charmDisplayTimeFormat), forKey: "currentTime")
        }
        
        if let time = bookAppointmentData.appointmentTimeStr{
            selectVC.arrayOfValues[1].updateValue(time, forKey: "value")
        }
        
        
        if !(bookAppointmentView?.timePrefView.textField?.text.isNilOrBlank() ?? true) {
            selectVC.selectedValueIndex = bookAppointmentData.appointmentTimeStr == nil ? 0 : 1
        }
        
        bookAppointmentData.selectedItem = bookAppointmentTimePrefCode
        self.navigationController?.pushViewController(selectVC, animated: true)
    
    }
    
    
    private func updateCell(cell: MDCalendarCell , cellState: CellState , date: Date){
        
        let dateStr = date.getStringFromDate(dateFormat: PHR_DATE_API_FORMAT)
        
        var calendarData: MDCalendarData? = bookAppointmentData.calendarDataMap[dateStr]

        if calendarData == nil{
            if let memberAvailability = getMemberAvailability(date: date) {
                    calendarData = MDCalendarData()
                    calendarData?.isAvailable = !memberAvailability.memberSlots.isEmpty
                    calendarData?.calendarDates = bookAppointmentData.calendarDates
                    bookAppointmentData.calendarDataMap[dateStr] = calendarData
            }
            
        }
        
        if calendarData == nil {
            calendarData = MDCalendarData()
            calendarData?.calendarDates = bookAppointmentData.calendarDates
        }
        
    
        if let calendarData = calendarData {
            calendarData.cellState = cellState
            cell.setValue(calendarData: calendarData)
        }
    }
    
    // JTAppleCalendar sizes its day cells from its bounds, so it must reload on rotation and fold/unfold.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let monthView = bookAppointmentView?.calendarMonthView else { return }
        monthView.viewWillTransition(to: size, with: coordinator, anchorDate: monthView.visibleDates().monthDates.first?.date)
    }

    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let date = visibleDates.monthDates.last {
            
            bookAppointmentView?.calendarMonthLabel.text =  date.date.getStringFromDate(dateFormat: "MMM yyyy")
            
            let startDate = date.date.startOfMonth
            let endDate = startDate.endOfMonth
            
            if bookAppointmentData.slotMetaData.memberAvailability.first(where: {
                memAvail in
                return endDate.isSameDate(date: memAvail.date ?? Date())
            }) == nil {
                
                bookAppointmentData.startDateForSlotFetch = startDate
                bookAppointmentData.endDateForSlotFetch = endDate
                
                bookAppointmentData.selectStartDate = false
                getSlotsData(startDate: startDate, endDate: endDate)
            }
        }
    }
    
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
   
        guard let cell = cell as? MDCalendarCell  else { return }
        updateCell(cell: cell, cellState: cellState, date: date)
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        
        let startDateTemp = bookAppointmentData.appointmentConfig?.currentFacilityTimezone ?? Date()
        var startDateComponent = DateComponents()
        startDateComponent.hour = bookAppointmentData.appointmentConfig?.slotsOpeningPriorHours ?? 0
        
        let startDate = Calendar.current.date(byAdding: startDateComponent, to: startDateTemp) ?? Date()

        
        var endDateComponent = DateComponents()
        endDateComponent.day = bookAppointmentData.appointmentConfig?.onlineBookingDaysLimit ?? 0

        let endDate = Calendar.current.date(byAdding: endDateComponent, to: startDate) ?? Date()

        
        bookAppointmentData.calendarDates.startDateCalendar = startDate
        bookAppointmentData.calendarDates.endDateCalendar = endDate
        return ConfigurationParameters(startDate: startDate, endDate: endDate , firstDayOfWeek: .sunday)
        
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalCell", for: indexPath) as! MDCalendarCell
        
        updateCell(cell: cell, cellState: cellState, date: date)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        
        bookAppointmentData.calendarDates.selectedDate = date
        
        if let cell = cell as? MDCalendarCell {
            updateCell(cell: cell, cellState: cellState, date: date)
        }
        
        onCalendarDateSelected()
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        
        if let cell = cell as? MDCalendarCell {
            updateCell(cell: cell, cellState: cellState, date: date)
        }
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        
        
        return bookAppointmentData.calendarDates.isDateEnabled(date: date)
    }
    
    
//    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
//        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "CalHeader", for: indexPath) as!
//        MDCalendarHeaderCell
//
//        header.calendarItem.monthLabel.text = range.start.getStringFromDate(dateFormat: "MMM yyyy")
//        return header
//    }
//
//    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
//        
//        return MonthSize(defaultSize: 30)
//    }
//    
    @objc private func onSlotPrefClick(){

        let selectVC = SelectAddAppointmentValueViewController()
        selectVC.delegate = self
        selectVC.title = bookAppointmentView?.slotPrefView.keyLabel.text
        
        var visitTypeDictArr : [Dictionary<String,Any>] = []
        
        
        for slotPref in bookAppointmentData.slotPreferance
        {
            var slotPrefObj: [String:Any] = ["name": slotPref]
            
            if bookAppointmentData.noSlotSessions.contains( slotPref) {
                slotPrefObj.addProperty("preference", "disabled")
                slotPrefObj.addProperty("value", "No Slots")
            }
            
            visitTypeDictArr.append(slotPrefObj)
        }
        selectVC.keyString = "name"
        selectVC.arrayOfValues = visitTypeDictArr
        selectVC.selectedValueIndex = bookAppointmentData.selectedSlotPreference
        
        selectVC.popViewControllerWhenValueChanged = true
        bookAppointmentData.selectedItem = bookAppointmentSlotPrefPrefCode
        
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    private func onSlotPrefSelected(index: Int) {
        
        if bookAppointmentData.selectedSlotPreference != index {
            bookAppointmentData.selectedSlotPreference = index
            bookAppointmentView?.slotPrefView.textField?.text = bookAppointmentData.slotPreferance[index]
            bookAppointmentData.lastSelectedSlotStr = nil
            bookAppointmentView?.slotTimeView.textField?.text = ""
        }
    }
    
    private func onSlotTimeSelected(selectedItem: String?) {
        
        bookAppointmentData.lastSelectedSlotStr = selectedItem
        bookAppointmentView?.slotTimeView.textField?.text = selectedItem
    }
    
    @objc private func onSlotTimeClick(){

        let selectVC = SelectAddAppointmentValueViewController()
        selectVC.delegate = self
        selectVC.title = bookAppointmentView?.slotTimeView.keyLabel.text
        
        var visitTypeDictArr : [Dictionary<String,Any>] = []
        
        if let memberAvailability = bookAppointmentData.selectedMemberAvailability {
            let slots =  memberAvailability.splitSessions()[MemberSession(rawValue: bookAppointmentData.selectedSlotPreference) ?? .Morning] ?? []
            
            for slot in slots{
                let slotStartTime = slot.startTime?.getStringFromDate(dateFormat: charmDisplayTimeFormat) ?? ""
                
                if bookAppointmentData.lastSelectedSlotStr == slotStartTime {
                    let index = slots.firstIndex{$0 === slot}
                    selectVC.selectedValueIndex = index
                }
                visitTypeDictArr.append(["name": slotStartTime ])
            }
        }
        
        selectVC.keyString = "name"
        selectVC.arrayOfValues = visitTypeDictArr
         
        selectVC.popViewControllerWhenValueChanged = true
        bookAppointmentData.selectedItem = bookAppointmentSlotTimePrefCode
        
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    @objc func onCalendarLeftArrowClick(){
        
        if let monthView = bookAppointmentView?.calendarMonthView {
            
            
            var lastDateOfPrevMonth = monthView.visibleDates().indates.last?.date
            
            if lastDateOfPrevMonth == nil {
                if let firstMonthDate =  monthView.visibleDates().monthDates.first?.date {
                    lastDateOfPrevMonth = firstMonthDate.minus(days: 1)
                }
            }
            
            if let lastDateOfPrevMonth = lastDateOfPrevMonth {
                
                if  lastDateOfPrevMonth.startOfDay.isAfter(date: bookAppointmentData.calendarDates.startDateCalendar.startOfDay){
                    monthView.scrollToDate(lastDateOfPrevMonth)
                }
                else{
                    debugPrintLog("JTCalendar prev month illai")
                }
            }
            else{
                debugPrintLog("JTCalendar last date illai")
            }
        }
        else{
            debugPrintLog("JTCalendar month illai")
        }
    }
    
    @objc func onCalendarRightArrowClick(){
        
        if let monthView = bookAppointmentView?.calendarMonthView {
            
            if let firstDateOfNextMonth = monthView.visibleDates().outdates.first?.date {
                
                if  firstDateOfNextMonth.startOfDay.isBefore(date: bookAppointmentData.calendarDates.endDateCalendar.startOfDay){
                    monthView.scrollToDate(firstDateOfNextMonth)
                }
                else{
                    debugPrintLog("JTCalendar next month illai")
                }
            }
            else{
                debugPrintLog("JTCalendar outdates illai")
            }
        }
        else{
            debugPrintLog("JTCalendar month illai")
        }
    }
    
    @objc func onAppointmentTypeClick(){
        
        
        if bookAppointmentData.appointmentConfig?.visitTypeList.isEmpty == true {
            
            let selectVC = SelectAddAppointmentValueViewController()
            selectVC.delegate = self
            selectVC.title = bookAppointmentView?.appointmentTypeView.keyLabel.text
            
            
            var typeDictArr : [Dictionary<String,Any>] = []
                
            for type in bookAppointmentData.appointmentTypeList
            {
                typeDictArr.append(["name": type])
            }
                
            selectVC.keyString = "name"
            selectVC.arrayOfValues = typeDictArr
            
            let selectedType: String = bookAppointmentView?.appointmentTypeView.textField?.text ?? ""
            if selectedType.isBlank()
            {
                selectVC.selectedValueIndex = nil
            }
            else
            {
                selectVC.selectedValueIndex = bookAppointmentData.appointmentTypeList.firstIndex(where: { (type) -> Bool in
                    return type == selectedType
                })
            }
            
            
                
            selectVC.popViewControllerWhenValueChanged = true
            
            
            bookAppointmentData.selectedItem = bookAppointmentAppointmentTypeCode
            
            self.navigationController?.pushViewController(selectVC, animated: true)
        }
    }
    
    @objc func doneBtnClicked(){
        if let appointmentRequest = validateAppointment(){
            
            bookAppointmentView?.endEditing(true)
            bookAppointmentData.appointmentRequest = appointmentRequest
            
            if bookAppointmentData.appointmentConfig?.isCardProcessingEnabled == true && appointmentRequest.paymentInfo != nil {
                bookAppointmentData.paymentTransaction = appointmentRequest.paymentInfo?.transactionInfo
                startPayment()
            }
            else{
                addAppointment()
            }
        }
        
    }
    
    
    private func validateAppointment() -> AppointmentRequest? {
        
        if bookAppointmentView?.practiceView.isHidden == false {
            if bookAppointmentView?.practiceView.textField?.text.isNilOrBlank() ?? true {
                CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.empty_practice"))
                return nil
            }
        }

        
        if bookAppointmentData.facilityList.isEmpty {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.facility.empty"))
            return nil
        }
        
        if bookAppointmentView?.facilityView.textField?.text.isNilOrBlank() ?? true {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.empty_facility"))
            return nil
        }
        
        if bookAppointmentData.memberList.isEmpty {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.member.empty"))
            return nil
        }
        
        if bookAppointmentView?.memberView.textField?.text.isNilOrBlank() ?? true {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.empty_provider"))
            return nil
        }
        
        if let appointmentConfig = bookAppointmentData.appointmentConfig {
            
            if appointmentConfig.isEnabled {
                
                
                if !appointmentConfig.visitTypeList.isEmpty{
                    if bookAppointmentView?.visitTypeView.textField?.text.isNilOrBlank() ?? true {
                        CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.empty_visit_type"))
                        return nil
                    }
                }
                
                if bookAppointmentData.selectedVisitType?.appointmentMode == appointmentTypeVideoCall && !appointmentConfig.isTelehealthEnabled{
                    CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.telehealth_not_enabled"))
                    return nil
                }
                
                if bookAppointmentData.calendarDates.selectedDate == nil {
                    CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.empty_date"))
                    return nil
                }
                
                
                if bookAppointmentView?.waitlistCheckbox.isHidden == false {
                   
                    if bookAppointmentView?.waitlistCheckbox.isSelected == false {
                        CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.uncheck_waiting_list"))
                        return nil
                    }
                }
                else{
                    if bookAppointmentData.lastSelectedSlotStr == nil {
                        CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.empty_slot"))
                        return nil
                    }
                }
            }
            else{
                if  !(bookAppointmentView?.timePrefView.textField?.text.isNilOrBlank() ?? true) && !bookAppointmentData.appointmentTimeStr.isNilOrBlank() {
                    
                    let  appointmentTimeStrList = (bookAppointmentData.appointmentTimeStr ?? "").split(separator: "-")
                    if let startTime = Date.getDateFromString(dateFormat: charmDisplayTimeFormat, dateString: "\(appointmentTimeStrList[0])".trim()) ,
                       let endTime = Date.getDateFromString(dateFormat: charmDisplayTimeFormat, dateString: "\(appointmentTimeStrList[1])".trim())
                    {
                        if startTime.isAfterOrEqual(date: endTime){
                            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.incorrect_time"))
                            return nil
                        }
                    }
                    
                }
            }
            
            let reason = bookAppointmentView?.reasonTextView.text ?? ""
            
            if reason.isBlank() {
                CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.empty_reason"))
                return nil
            }
            
            if !reason.hasAnyAlphabets(){
                CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.invalid_reason"))
                return nil
            }
            
            
            let appointmentRequest = AppointmentRequest()
            
            appointmentRequest.member = bookAppointmentData.selectedMember
            appointmentRequest.facility = bookAppointmentData.selectedFacility
            appointmentRequest.reason = bookAppointmentView?.reasonTextView.text
            appointmentRequest.appointmentType = bookAppointmentView?.appointmentTypeView.textField?.text
            appointmentRequest.isEnabled =  appointmentConfig.isEnabled
            
            let practiceId = appointmentRequest.facility?.practiceId ?? ""
            appointmentRequest.practiceId = practiceId
            
            if appointmentConfig.isEnabled {
                
                appointmentRequest.datePreference = appointmentDatePreferenceSpecificDate
                appointmentRequest.dateChoice1 = bookAppointmentData.calendarDates.selectedDate
                
                
                
                if let visitType = bookAppointmentData.selectedVisitType{
                    appointmentRequest.duration = visitType.duration
                }
                else{
                    appointmentRequest.duration = appointmentConfig.interval
                }
                                
                
                if bookAppointmentView?.waitlistCheckbox.isHidden == false{
                    appointmentRequest.addAsWaitingList = true
                }
                else{
                
                    let lastSelectedSlot = bookAppointmentData.lastSelectedSlotStr ?? ""
                    
                    let lastSelectedSlotArr = lastSelectedSlot.split(separator:" ").map({slotStr in
                        return "\(slotStr)"
                    })
                    
                    appointmentRequest.startSession = lastSelectedSlotArr[1].uppercased()
                    
                    let lastSelectedSlotDayMinArr = lastSelectedSlotArr[0].split(separator:":").map({slotStr in
                        return "\(slotStr)"
                    })

                    appointmentRequest.startHour = lastSelectedSlotDayMinArr[0]
                    appointmentRequest.startMinutes = lastSelectedSlotDayMinArr[1]
                }


                
                if !appointmentConfig.visitTypeList.isEmpty{
                    appointmentRequest.visitType = bookAppointmentData.selectedVisitType
                }
                
            }
            else{
                
                appointmentRequest.reminderType = "Mail"
                appointmentRequest.addAsWaitingList = false
                
                if let appointmentDate = bookAppointmentData.selectedDate {
                    
                    appointmentRequest.datePreference = appointmentDatePreferenceSpecificDate
                    appointmentRequest.dateChoice1 = appointmentDate
                }
                else{
                    appointmentRequest.datePreference = appointmentDatePreferenceAnyDate
                }
                
                
                if let appointmentTimeStr = bookAppointmentData.appointmentTimeStr {
                    appointmentRequest.timePreference = appointmentTimePreferenceTimeRange
                    let  appointmentTimeStrList = appointmentTimeStr.split(separator: "-").map({timeStr in
                        return "\(timeStr)".trim()
                    })

                    let startTimeStr = appointmentTimeStrList[0]
                    let startTimeArr = startTimeStr.split(separator: " ").map({timeStr in
                        return "\(timeStr)".trim()
                    })
                    appointmentRequest.startSession = startTimeArr[1].uppercased()
                    
                    let startTimeMinArr = startTimeArr[0].split(separator:":").map({slotStr in
                        return "\(slotStr)"
                    })

                    appointmentRequest.startHour = startTimeMinArr[0]
                    appointmentRequest.startMinutes = startTimeMinArr[1]
                    
                    let endTimeStr = appointmentTimeStrList[1]
                    let endTimeArr = endTimeStr.split(separator: " ").map({timeStr in
                        return "\(timeStr)".trim()
                    })
                    appointmentRequest.endSession = endTimeArr[1].uppercased()
                    
                    let endTimeMinArr = endTimeArr[0].split(separator:":").map({slotStr in
                        return "\(slotStr)"
                    })

                    appointmentRequest.endHour = endTimeMinArr[0]
                    appointmentRequest.endMinutes = endTimeMinArr[1]

                }
                else{
                    appointmentRequest.timePreference = appointmentTimePreferenceAnyTime
                }
            }
            
            let paymentInfo = PaymentInfo()
            
            if ((appointmentConfig.isCardProcessingEnabled && (appointmentConfig.cardProcessingType == appointmentCardProcessingTypeStoreOnly) || (appointmentConfig.cardProcessingType == appointmentCardProcessingTypeStoreCharge)) || (appointmentConfig.isCardProcessingEnabled && ((appointmentConfig.chargeAmount != nil && appointmentConfig.chargeAmount!.toFloatOrNil() ?? 0 > 0 && appointmentConfig.chargeType != appointmentPaymentChargeTypeVisitBased) || (appointmentConfig.chargeType == appointmentPaymentChargeTypeVisitBased && appointmentRequest.visitType?.charge?.toFloatOrNil() ?? 0 > 0)))) {

                
                paymentInfo.chargeProcessingType = appointmentConfig.cardProcessingType
                paymentInfo.chargeType = appointmentConfig.chargeType

                if appointmentConfig.chargeType == appointmentPaymentChargeTypeVisitBased {
                    paymentInfo.chargeAmount = appointmentRequest.visitType?.charge
                }
                else{
                    paymentInfo.chargeAmount = appointmentConfig.chargeAmount
                }
                
                let transactionInfo = TransactionInfo()
                transactionInfo.facilityId = appointmentRequest.facility?.facilityId
                transactionInfo.practiceId = appointmentRequest.practiceId
                transactionInfo.memberId = appointmentRequest.member?.memberId
                transactionInfo.patientId = getSelectedPatientId()
                transactionInfo.merchantAccountId = appointmentConfig.merchantAccountId
                transactionInfo.service = paymentServiceAppointment
                transactionInfo.paymentAmount = paymentInfo.chargeAmount
                transactionInfo.gateway = appointmentConfig.paymentGateway
                paymentInfo.transactionInfo = transactionInfo
                
                appointmentRequest.paymentInfo = paymentInfo
                
            }
            return appointmentRequest
        }
        
        
       
        
        return nil
    }
    
    private func startPayment() {
        
        if bookAppointmentData.paymentTransaction?.gateway == appointmentGatewayTypeBluefin {
            showActivityIndicator()
            charmConnectionHandler?.getCardList(identificationKey: "getCardList",selectedPractice: bookAppointmentData.appointmentRequest.practiceId ?? "" , merchantId: bookAppointmentData.appointmentConfig?.merchantAccountId ?? "")
        }
        else{
            
            showActivityIndicator()
            
            let json = JsonBuilder.formTransactionObj(paymentInfo: bookAppointmentData.appointmentRequest.paymentInfo ?? PaymentInfo())
            charmConnectionHandler?.createTransaction(patientId: getSelectedPatientId(), json: json, identificationKey: "createTransaction")
        }
    }
    
    private func intentToBluefinPayment(cardList:[PaymentGatewayToken] = []){
        hideActivityIndicator()
        let paymentInfo = bookAppointmentData.appointmentRequest.paymentInfo
        
        if paymentInfo?.chargeProcessingType == appointmentCardProcessingTypeStoreOnly && !cardList.isEmpty{
            addAppointment()
        }
        else if paymentInfo?.chargeProcessingType == appointmentCardProcessingTypeStoreCharge && !cardList.isEmpty && paymentInfo?.chargeAmount?.toDoubleOrNil() ?? 0.0 == 0.0 {
            addAppointment()
        }
        else{
            let paymentViewController = PaymentViewController()
            paymentViewController.paymentInfo = paymentInfo
            
            paymentViewController.amountPayableStr = paymentInfo?.chargeAmount ?? ""
            paymentViewController.currencySymbol = bookAppointmentData.appointmentConfig?.paymentCurrencySymbol ?? ""
            paymentViewController.delegate = self
            paymentViewController.cardList = cardList
            
            self.navigationController?.pushViewController(paymentViewController, animated: true)
        }
   
    }
    
    private func addAppointment() {
        
        let appointmentRequest = bookAppointmentData.appointmentRequest
        
        showActivityIndicator()

        
        charmConnectionHandler?.bookAppointment(appointmentRequest: appointmentRequest, identificationKey: "bookAppointment")
    }
    
    private func onBookAppointmentSuccess(successMsg: String){
        
        AppDataHandler.sharedInstance().refreshAppointments = true
        
        if isRebook != nil {
            if let vc = delegate as? UIViewController {
                self.navigationController?.popToViewController(vc, animated: true)
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
        
        delegate?.addViewControllerDataAdded(message: successMsg)
    }
    
    private func openRazorpay(){
        
        
        if let paymentInfo = bookAppointmentData.appointmentRequest.paymentInfo {
            bookAppointmentData.razorpay = RazorpayCheckout.initWithKey("\(paymentInfo.transactionInfo?.publicToken ?? "")", andDelegate: self)
            
            let options: [String:Any] = [
                "amount": "\((paymentInfo.chargeAmount?.toFloatOrNil() ?? 0 ) * 100)", //This is in currency subunits. 100 = 100 paise= INR 1.
                "currency": "\("INR")",
                "description": "Appointment booking amount",
                "order_id": "\(paymentInfo.transactionInfo?.razorPayOrderId ?? "")",
                "image": "", //TODO: can give image
                "name": bookAppointmentData.selectedFacility.facilityName ?? "",
                "prefill": [
                    "contact": "\(paymentInfo.transactionInfo?.mobile ?? "")",
                    "email": "\(paymentInfo.transactionInfo?.emailId ?? "")"
                ],
                "theme": [
                    "color": "\(THEME_COLOR_BILLING)"
                ]
            ]
            
            bookAppointmentData.razorpay?.open(options)
        }
        
        
    }
    
    
    func showErrorPage(errorInAPI: Int){
        
        bookAppointmentData.errorInAPI = errorInAPI
        bookAppointmentView?.errorPage.isHidden = false
        bookAppointmentView?.scrollView.isHidden = true
    }
    
    func hideErrorPage() {
        
        bookAppointmentData.errorInAPI = -1
                
        bookAppointmentView?.scrollView.isHidden = false

        if bookAppointmentView?.errorPage.isHidden == false {
            bookAppointmentView?.errorPage.isHidden = true
        }
    }
    
    func resetCompleteData(localizedKey: String , showFacility: Bool = false){
        bookAppointmentData.resetAppointmentData()
        bookAppointmentView?.resetCompleteData(localizedKey: localizedKey, showFacility: showFacility)
    }
    
    func resetAppointmentData(localizedKey: String) {
        
        bookAppointmentView?.resetAppointmentData(localizedKey: localizedKey)
    
        bookAppointmentData.resetAppointmentData()
    }
    
    func selectAddAppointmentValueViewControllerDidSelectValue(indexPath: IndexPath, valueString: String?) {
        
        
        if bookAppointmentData.selectedItem == bookAppointmentPracticeFetchCode {
            onPracticeSelected(index: indexPath.row)
        }
        else if bookAppointmentData.selectedItem == bookAppointmentFacilityFetchCode {
            onFacilitySelected(index: indexPath.row)
        }
        else if bookAppointmentData.selectedItem == bookAppointmentMemberFetchCode{
            onMemberSelected(index: indexPath.row)
        }
        else if bookAppointmentData.selectedItem == bookAppointmentVisitTypePrefCode {
            onVisitTypeSelected(index: indexPath.row , selectedStr: valueString)
        }
        else if bookAppointmentData.selectedItem == bookAppointmentAppointmentTypeCode {
            bookAppointmentView?.appointmentTypeView.textField?.text = bookAppointmentData.appointmentTypeList[indexPath.row]
        }
        else if bookAppointmentData.selectedItem == bookAppointmentDatePrefCode {
            
            
            if (indexPath.row == 0 && bookAppointmentView?.datePrefView.textField?.text != Any_Date) || indexPath.row == 1 &&  bookAppointmentView?.datePrefView.textField?.text != valueString{
                if indexPath.row == 0{
                    bookAppointmentData.selectedDate = nil
                    bookAppointmentView?.datePrefView.textField?.text = Any_Date
                }
                else{
                    bookAppointmentView?.datePrefView.textField?.text = valueString
                    bookAppointmentData.selectedDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: valueString ?? "")
                }
            }
            
            
           
        }
        else if bookAppointmentData.selectedItem == bookAppointmentTimePrefCode {
            if indexPath.row == 0{
                bookAppointmentData.appointmentTimeStr = nil
                bookAppointmentView?.timePrefView.textField?.text = "Any Time"
            }
            else{
                bookAppointmentView?.timePrefView.textField?.text = valueString
                bookAppointmentData.appointmentTimeStr = valueString
            }
        }
        else if bookAppointmentData.selectedItem == bookAppointmentSlotPrefPrefCode {
            onSlotPrefSelected(index: indexPath.row)
        }
        else if bookAppointmentData.selectedItem == bookAppointmentSlotTimePrefCode {
            onSlotTimeSelected(selectedItem: valueString)
        }
        
    }
    
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        
        if identificationKey == "createTransaction"
        {
            
            if let paymentInfo = bookAppointmentData.appointmentRequest.paymentInfo {
                ParsingHelper.updatePaymentDetailWithDictionary(paymentInfo: paymentInfo, dict: jsonObject)
                openRazorpay()
            }
        }
        else if identificationKey == "updatePayment"
        {
            let outputJson = jsonObject["output_string"] as! Dictionary<String,Any>
            
            if let receiptDetail = outputJson["receipt_details"] as? [Dictionary<String,Any>]
            {
                if receiptDetail.first != nil && receiptDetail.first!["ehr_receipt_id"] as? String != nil
                {
                    bookAppointmentData.appointmentRequest.receiptId = receiptDetail.first!["ehr_receipt_id"] as? String
                }
            }
            
            bookAppointmentData.appointmentRequest.paymentInfo?.isPaymentSuccess = true
            addAppointment()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        if identificationKey == "createTransaction"
        {
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.startPayment()
            }
        }
        else if identificationKey == "updatePayment"{
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.onPaymentSuccess("")
            }
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey == "getFacility"{
            if let facilityList = response as? [Facility] {
                if facilityList.count == 1{
                    bookAppointmentData.selectFacility = true
                }
                bookAppointmentData.facilityList = facilityList
                onFacilityFetchSuccess()
            }
        }
        if identificationKey == "getMember"{
            if let memberList  = response as? [Provider] {
                bookAppointmentData.memberList = memberList
                onMemberFetchSuccess()
            }
        }
        if identificationKey == "getAppointmentConfig"{
            if let appointmentConfig = response as? AppointmentConfig {
                bookAppointmentData.appointmentConfig = appointmentConfig
                
                onAppointmentConfigSuccess()
            }
        }
        if identificationKey == "bookAppointment" {
            if let respStr = response as? String {
                onBookAppointmentSuccess(successMsg: respStr)
            }
        }
        if identificationKey == "getSlots" {
            if let slotMetaData = response as? SlotMetaData {
                onSlotFetchSuccess(slotMetaData: slotMetaData)
            }
        }
        if identificationKey == "getCardList"{
            if let cardMetaObj = response as? [CardMetaObj] {
                
                let merchantAccountId = bookAppointmentData.appointmentRequest.paymentInfo?.transactionInfo?.merchantAccountId ?? ""
                
                let paymentSavedCards = cardMetaObj.firstOrNil()?.cardList.filter({tempCard in
                    !tempCard.hasCardExpired
                }) ?? []
                intentToBluefinPayment(cardList: paymentSavedCards)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        
        if identificationKey == "getFacility"{
            showErrorPage(errorInAPI: bookAppointmentFacilityFetchCode)
        }
        else if identificationKey == "getMember"{
            showErrorPage(errorInAPI: bookAppointmentMemberFetchCode)
        }
        else if identificationKey == "getAppointmentConfig"{
            showErrorPage(errorInAPI: bookAppointmentAppointmentConfigFetchCode)
        }
        else if identificationKey == "bookAppointment" {
            CharmUtil.createOkayAlertWith(error: error)
        }
        else if identificationKey == "getSlots" {
            showErrorPage(errorInAPI: bookAppointmentSlotsFetchCode)
        }
    }
    
    func onReceiptIdCreated(receiptId: String) {
        bookAppointmentView?.endEditing(true)
        showActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.bookAppointmentData.appointmentRequest.receiptId = receiptId
            self.addAppointment()
        })

    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        debugPrintLog("Error in payment with : \(str) \(code)")
        let alertVC = UIAlertController(title: nil, message:"\(getString(key: "com.charmphr.addAppointments.payment.alert.error"))", preferredStyle: .alert)
        let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.addAppointments.payment.paynow"), style: .default, handler: { (UIAlertAction) in
            self.openRazorpay()
        })
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .default, handler: { (UIAlertAction) in

        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        alertVC.show()
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        showActivityIndicator()
        charmConnectionHandler?.updateTransaction(patientId: getSelectedPatientId() , practiceId : bookAppointmentData.selectedPractice.practiceId ?? "", gateway:bookAppointmentData.appointmentRequest.paymentInfo?.transactionInfo?.gateway ?? "", transactionId: bookAppointmentData.appointmentRequest.paymentInfo?.transactionInfo?.transactionId ?? "", identificationKey: "updatePayment")
  
    }
    
    private func getMemberAvailability(date: Date) -> MemberAvailability? {
        return bookAppointmentData.slotMetaData.memberAvailability.first(where: { memAvail in
            date.isSameDate(date: memAvail.date ?? Date())
        })
    }
    
    func noDataViewRetryBtnClicked() {
        
        if bookAppointmentData.errorInAPI == bookAppointmentFacilityFetchCode{
            getFacilityList()
        }
        else if bookAppointmentData.errorInAPI == bookAppointmentFacilityFetchFromPracticeCode {
            getFacilityList()
        }
        else if bookAppointmentData.errorInAPI == bookAppointmentMemberFetchCode {
            getMembersList()
        }
        else if bookAppointmentData.errorInAPI == bookAppointmentAppointmentConfigFetchCode{
            getAppointmentConfig()
        }
        else if bookAppointmentData.errorInAPI == bookAppointmentSlotsFetchCode{
            getSlotsData(startDate: bookAppointmentData.startDateForSlotFetch, endDate: bookAppointmentData.endDateForSlotFetch)
        }
        else {
            hideErrorPage()
        }
    }
    
    func showActivityIndicator(hideView:Bool = false)
    {
        navigationItem.rightBarButtonItem?.isEnabled = false
        bookAppointmentView?.showActivityIndicator(hideView: hideView)
    }
    
    func hideActivityIndicator()
    {
        navigationItem.rightBarButtonItem?.isEnabled = true
        bookAppointmentView?.hideActivityIndicator()
    }
    
    @objc override func onBackClick(){
       
        if checkDataIsAvailable(){
            showDiscardChangesDialog()
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func checkDataIsAvailable() -> Bool {
        if bookAppointmentView?.practiceView.isHidden == false {
            if !(bookAppointmentView?.practiceView.textField?.text.isNilOrBlank() ?? true) {
                return true
            }
        }
        
        
        if bookAppointmentView?.practiceView.isHidden == false {
            if !(bookAppointmentView?.facilityView.textField?.text.isNilOrBlank() ?? true) {
                return true
            }
        }
        else{
            if bookAppointmentData.facilityList.count > 1{
                if !(bookAppointmentView?.facilityView.textField?.text.isNilOrBlank() ?? true) {
                    return true
                }
            }
        }
        
        if !(bookAppointmentView?.memberView.textField?.text.isNilOrBlank() ?? true) {
            return true
        }
        
        
        return false
    }
    
}


class EasyTelecareBookAppointmentWebViewController: UIViewController , WKNavigationDelegate{
    
    var urlString: String? = nil
    let activityIndicator = UIActivityIndicatorView()
    let webView = WKWebView()

    weak var delegate: EasyCareBookAppointmentDelegate? = nil
    
    var isCloseButton:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIButton()
        let backIconConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .large)
        if let backicon = UIImage(systemName: "chevron.backward", withConfiguration: backIconConfig){
            backButton.setImage(backicon, for: .normal)
        }
        
        var backKey = "com.charmphr.action.back"
        
        if isCloseButton {
            backKey = "com.charmphr.action.close"
        }
        backButton.setProperties(titleStrKey: getString(key: backKey), fontsize: 17, weight: .regular, fontcolor: THEME_COLOR)
        backButton.setTitleColor(.systemBlue, for: .normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -9)

        self.navigationItem.title = ""
        
        let baseView = UIView()
        self.view = baseView
        
        baseView.setBackgroundColor(bgColor: APPLICATION_BACKGROUND_COLOR)
        self.setLargeTitle(enable: false)

        webView.navigationDelegate = self
        
        baseView.addSubview(webView)

       
        if let url = URL(string: urlString ?? "") {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
         
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        baseView.addSubview(activityIndicator)

        
        
        webView.setSafeAreaTop(offset: 0)
        webView.setSafeAreaBottom(offset: 0)
        webView.setLeft(offSet: 0)
        webView.setRight(offSet: 0)
        
        webView.isHidden = true
        
        activityIndicator.setLeft(offSet: 0)
        activityIndicator.setRight(offSet: 0)
        activityIndicator.setSafeAreaTop(offset: 0)
        activityIndicator.setSafeAreaBottom(offset: 0)
        
        activityIndicator.startAnimating()
        baseView.bringSubviewToFront(activityIndicator)
    }
    
    @objc func backButtonPressed(){
        
        if self.webView.canGoBack {
            debugPrintLog("Can go back")
            self.webView.goBack()
           // self.webView.reload()
        }
        else {
            delegate?.onBookAppointmentBackPressed()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        debugPrintLog("finish loading")
        webView.isHidden = false
        activityIndicator.stopAnimating()
    }
}


protocol EasyCareBookAppointmentDelegate: AnyObject{
    func onBookAppointmentBackPressed()
}
