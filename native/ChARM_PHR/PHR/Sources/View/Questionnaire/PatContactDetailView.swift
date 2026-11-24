//
//  PatContactDetailView.swift
//  phr
//
//  Created by prathi-13964 on 22/04/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

fileprivate let MDFLTEXTFIELD_HEIGHT: CGFloat = 60

class PatContactDetailView: UIStackView, UITextFieldDelegate, MDTextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var homePhoneMDTF : MDFLTextField?
    private var mobilePhoneMDTF : MDFLTextField?
    private var workPhoneMDTF : MDFLTextField?
    private var workPhoneExtnMDTF : MDFLTextField?
    private var faxMDTF : MDFLTextField?
    private var emailMDTF: MDFLTextField?
    private var primaryPhoneMDTF : MDFLTextField?
    private var line1MDTF : MDFLTextField?
    private var line2MDTF : MDFLTextField?
    private var cityMDTF : MDFLTextField?
    var countryMDTF : MDFLTextField?
    var stateMDTF : MDFLTextField?
    private var postalCodeMDTF : MDFLTextField?
    private var postBoxMDTF : MDFLTextField?
    private var emgContactNameMDTF : MDFLTextField?
    private var emgContactNumMDTF : MDFLTextField?
    private var emgContactExtnMDTF : MDFLTextField?

    private var customPickerView = UIPickerView()
    
    private var viewWidth: CGFloat = 0
    private var addShadow = true
    private let primaryPhoneArr = [getString(key: "com.charmphr.EditDemographics.HomePhone.title"), getString(key: "com.charmphr.EditDemographics.MobilePhone.title"), getString(key: "com.charmphr.EditDemographics.WorkPhone.title")]
    private let primaryDataHandler = PrimaryDataHandler.sharedInstance
    private var selectedPrimaryPhoneIndex: Int = 0
    
//MARK: - init
    
    init(width: CGFloat, addShadow: Bool) {
        super.init(frame: .zero)
        
        self.viewWidth = width
        self.addShadow = addShadow
        
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.spacing = CARD_PADDING
        self.alignment = .center
        
        customPickerView.delegate = self
        customPickerView.dataSource = self
        
        let patContactDetailHeading = UILabel()
        addArrangedSubview(patContactDetailHeading)
        
        patContactDetailHeading.setProperties(textKey: "com.charmphr.questionnairevc.patContact.title", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        patContactDetailHeading.setWidth(constant: viewWidth - (2*X_SPACE))

        homePhoneMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.HomePhone.title")
        homePhoneMDTF?.keyboardType = .numberPad
        homePhoneMDTF?.maxLength = CONTACT_NUMBER_SIZE
        
        mobilePhoneMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.MobilePhone.title")
        mobilePhoneMDTF?.keyboardType = .numberPad
        mobilePhoneMDTF?.maxLength = CONTACT_NUMBER_SIZE
        
        workPhoneMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.WorkPhone.title")
        workPhoneMDTF?.keyboardType = .numberPad
        workPhoneMDTF?.maxLength = CONTACT_NUMBER_SIZE

        workPhoneExtnMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.extension.title")
        workPhoneExtnMDTF?.keyboardType = .numberPad
        workPhoneExtnMDTF?.maxLength = CONTACT_EXTENSION_SIZE

        faxMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.fax.title")
        faxMDTF?.keyboardType = .numberPad
        faxMDTF?.maxLength = CONTACT_NUMBER_SIZE
            
        emailMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.email.title")
        emailMDTF?.isMandatoryField = true
        emailMDTF?.maxLength = CONTACT_EMAIL_ID_SIZE
        
        primaryPhoneMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.PrimaryPhone.title",isCustomPicker: true)
        
        line1MDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.ADDRESSLINE1.title")
        line1MDTF?.maxLength = ADDRESS_LINE_1_SIZE
        line1MDTF?.isMandatoryField = true
        
        line2MDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.ADDRESSLINE2.title")
        line2MDTF?.maxLength = ADDRESS_LINE_2_SIZE
        
        cityMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.City.title")
        cityMDTF?.maxLength =  ADDRESS_CITY_SIZE
        cityMDTF?.isMandatoryField = true

        countryMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.Country.title")
        countryMDTF?.isMandatoryField = true
        
        stateMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.State.title")
        stateMDTF?.maxLength = ADDRESS_STATE_SIZE
        stateMDTF?.isMandatoryField = true

        postalCodeMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.zipCode.title")
        postalCodeMDTF?.maxLength = ADDRESS_POSTAL_CODE_SIZE
        postalCodeMDTF?.keyboardType = .numberPad
        postalCodeMDTF?.isMandatoryField = true

        postBoxMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.postBox.title")
        postBoxMDTF?.maxLength = ADDRESS_POST_BOX_SIZE
        postBoxMDTF?.keyboardType = .numberPad

        emgContactNameMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.emgContactName.title")
        emgContactNameMDTF?.maxLength = EMERGENCY_CONTACT_NAME_SIZE
        
        emgContactNumMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.emgContactNum.title")
        emgContactNumMDTF?.maxLength = CONTACT_NUMBER_SIZE
        emgContactNumMDTF?.keyboardType = .numberPad
        
        emgContactExtnMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.extension.title")
        emgContactExtnMDTF?.maxLength = CONTACT_EXTENSION_SIZE

        self.layoutIfNeeded()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - On CountryChange
    
    func onCountryChange(isMakeEmpty: Bool = true) -> String?{
        
        let country = countryMDTF?.text ?? ""
        if country.lowercased() == INDIA {
            
            postBoxMDTF?.superview?.isHidden = true
            
            if isMakeEmpty{
                postBoxMDTF?.text = ""
                postalCodeMDTF?.text = ""
            }
            postalCodeMDTF?.maxLength = 6
            postalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
            
            if let inStates = primaryDataHandler.inStatesArr, !inStates.isEmpty{
                
                let stateStr = stateMDTF?.text ?? ""
                
                if stateStr.isNotBlank() {
                    if inStates.first(where: { (state) -> Bool in
                        return state == stateStr
                    }) == nil
                    {
                        stateMDTF?.text = ""
                    }
                }
            }
            else{
                if isMakeEmpty{
                    stateMDTF?.text = ""
                }
                return country_in
            }
        }
        else if country.lowercased() == UNITED_STATES {
            postBoxMDTF?.superview?.isHidden = false
            
            if isMakeEmpty{
                postalCodeMDTF?.text = ""
            }
            postalCodeMDTF?.maxLength = 5
            postalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.zipCode.title")
            
            
            if let usStates = primaryDataHandler.usStatesArr, !usStates.isEmpty{
                
                let stateStr = stateMDTF?.text ?? ""
                
                if stateStr.isNotBlank() {
                    if usStates.first(where: { (state) -> Bool in
                        return state == stateStr
                    }) == nil
                    {
                        stateMDTF?.text = ""
                    }
                }
            }
            else{
                if isMakeEmpty{
                    stateMDTF?.text = ""
                }
                return country_us
            }
        }
        else if  country.lowercased() == AUSTRALIA {
            
            postBoxMDTF?.superview?.isHidden = true
            
            if isMakeEmpty{
                postBoxMDTF?.text = ""
                postalCodeMDTF?.text = ""
            }
            postalCodeMDTF?.maxLength = 10
            postalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
            
            if let auStates = primaryDataHandler.auStatesArr, !auStates.isEmpty{
                
                let stateStr = stateMDTF?.text ?? ""
                
                if stateStr.isNotBlank() {
                    if auStates.first(where: { (state) -> Bool in
                        return state == stateStr
                    }) == nil
                    {
                        stateMDTF?.text = ""
                    }
                }
            }
            else{
                return country_au
            }
        }
        else{
            if isMakeEmpty{
                stateMDTF?.text = ""
                postBoxMDTF?.text = ""
            }
            postBoxMDTF?.superview?.isHidden = true
            postalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
            postalCodeMDTF?.maxLength = 10
            return nil
        }
        return nil
    }
    
//MARK: - Update Values
    
    func updateValues(patientObj: Patient){
        
        homePhoneMDTF?.text = patientObj.contactDetail?.homePhone
        mobilePhoneMDTF?.text = patientObj.contactDetail?.mobile
        workPhoneMDTF?.text = patientObj.contactDetail?.workPhone
        workPhoneExtnMDTF?.text = patientObj.contactDetail?.workPhoneExtn
        faxMDTF?.text = patientObj.contactDetail?.fax
        emailMDTF?.text = patientObj.contactDetail?.emailId
        
        if patientObj.contactDetail?.primaryPhone.isNilOrBlank() == false{
            if patientObj.contactDetail?.primaryPhone?.lowercased() == "c" {
                primaryPhoneMDTF?.text = primaryPhoneArr[1]
            }
            else if patientObj.contactDetail?.primaryPhone?.lowercased() == "w" {
                primaryPhoneMDTF?.text = primaryPhoneArr[2]
            }
            else{
                primaryPhoneMDTF?.text = primaryPhoneArr[0]
            }
        }
        
        line1MDTF?.text = patientObj.postalAddress?.line1
        line2MDTF?.text = patientObj.postalAddress?.line2
        cityMDTF?.text = patientObj.postalAddress?.city
        if let country = patientObj.postalAddress?.country {
            if let countryVal = primaryDataHandler.countriesArr?.first(where: { (countryEntry) -> Bool in
                return countryEntry.key == country
            }) {
                countryMDTF?.text = countryVal.value
            }
        }
        
        stateMDTF?.text = patientObj.postalAddress?.state
        postalCodeMDTF?.text = patientObj.postalAddress?.postalCode
        postBoxMDTF?.text = patientObj.postalAddress?.postbox
        emgContactNameMDTF?.text = patientObj.emergencyContactName
        emgContactNumMDTF?.text = patientObj.emergencyContactNumber
        emgContactExtnMDTF?.text = patientObj.emergencyContactExtn
    }
    
//MARK: - Validate ContactDetails
    
    func validateContactDetails(isSubmitted: Bool) -> [String: MDFLTextField?]{
        
        let emailId = emailMDTF?.text ?? ""
        if emailId.isBlank(){
            return ["com.charmphr.questionnairevc.patContact.email.empty":emailMDTF]
        }
        if !emailId.validateEmail(){
            return ["com.charmphr.questionnairevc.patContact.email.invalid":emailMDTF]
        }
        
        let line1 = line1MDTF?.text ?? ""
        if line1.isBlank() && isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.line1.empty":line1MDTF]
        }
        if !line1.hasAnyAlphabets() && isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.line1.invalid":line1MDTF]
        }
        
        let line2 = line2MDTF?.text ?? ""
        if line2.isNotBlank() {
            if !line2.hasAnyAlphabets() && isSubmitted{
                return ["com.charmphr.questionnairevc.patContact.line2.invalid":line2MDTF]
            }
        }
        
        let city = cityMDTF?.text ?? ""
        if city.isBlank() && isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.city.empty":cityMDTF]
        }
        if !city.hasAnyAlphabets() && isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.city.invalid":cityMDTF]
        }
        
        let countryName = countryMDTF?.text ?? ""
        if countryName.isBlank() && isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.country.empty": countryMDTF]
        }
        
        let countryKey = primaryDataHandler.countriesArr?.first(where: { (countryEntry) -> Bool in
            return countryEntry.value == countryName
        })?.key ?? ""
        if countryKey.isBlank() && isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.country.invalid": countryMDTF]
        }
        
        let state = stateMDTF?.text ?? ""
        if state.isBlank() && isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.state.empty":stateMDTF]
        }
        if !state.hasAnyAlphabets() && countryKey != country_in && countryKey != country_us && countryKey != country_au && isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.stateAlpha.invalid":stateMDTF]
        }
        
        let pinCode = postalCodeMDTF?.text ?? ""
        if pinCode.isNotBlank() && isSubmitted{
            if countryKey == country_in {
                if pinCode.count != 6 {
                    return ["com.charmphr.questionnairevc.patContact.pincode.invalid":postalCodeMDTF]
                }
            }
            else if countryKey == country_us {
                if pinCode.count != 5 {
                    return ["com.charmphr.questionnairevc.patContact.pincode.invalid":postalCodeMDTF]
                }
            }
        }
        else if isSubmitted{
            return ["com.charmphr.questionnairevc.patContact.pincode.empty":postalCodeMDTF]
        }
        
        if countryKey == country_us {
            let postBox = postBoxMDTF?.text ?? ""
            if postBox.trim().count > 4 && isSubmitted{
                return ["com.charmphr.questionnairevc.patContact.postalcode.invalid":postBoxMDTF]
            }
        }
        
        let emgContactName = emgContactNameMDTF?.text ?? ""
        if emgContactName.isNotBlank() {
            if !emgContactName.hasAnyAlphabets() && isSubmitted{
                return ["com.charmphr.questionnairevc.patContact.emgContactName.invalid":emgContactNameMDTF]
            }
        }
        return [:]
    }
    
//MARK: - Get PatientData
    
    func getPatientData(patient: Patient) -> Patient{
        
        patient.emergencyContactName = emgContactNameMDTF?.text
        patient.emergencyContactNumber = emgContactNumMDTF?.text
        patient.emergencyContactExtn = emgContactExtnMDTF?.text

        if let contactDetails = patient.contactDetail{
            contactDetails.homePhone = homePhoneMDTF?.text
            contactDetails.workPhone = workPhoneMDTF?.text
            contactDetails.workPhoneExtn = workPhoneExtnMDTF?.text
            contactDetails.mobile = mobilePhoneMDTF?.text
            
            let primaryPhone = primaryPhoneMDTF?.text
            if primaryPhone == primaryPhoneArr[0] {
                contactDetails.primaryPhone = "H"
            }
            else if primaryPhone == primaryPhoneArr[1] {
                contactDetails.primaryPhone = "C"
            }
            else if primaryPhone == primaryPhoneArr[2] {
                contactDetails.primaryPhone = "W"
            }
            else{
                contactDetails.primaryPhone = ""
            }
            contactDetails.emailId = emailMDTF?.text
            contactDetails.fax = faxMDTF?.text
            patient.contactDetail = contactDetails
        }

        if let postalAddress = patient.postalAddress{
            postalAddress.line1 = line1MDTF?.text
            postalAddress.line2 = line2MDTF?.text
            postalAddress.city = cityMDTF?.text
            let countryKey = primaryDataHandler.countriesArr?.first(where: { (countryEntry) -> Bool in
                return countryEntry.value == countryMDTF?.text
            })?.key ?? ""
            postalAddress.country = countryKey
            postalAddress.state = stateMDTF?.text ?? ""
            postalAddress.postalCode = postalCodeMDTF?.text
            postalAddress.postbox = postBoxMDTF?.text
            
            patient.postalAddress = postalAddress
        }
        
        return patient
    }
        
//MARK: - Get MDFLTextField
    
    func getMDFLTextField(keyStr:String, isCustomPicker:Bool = false) -> MDFLTextField
    {
        let tfView = UIView()
        let tf = MDFLTextField()
        tf.placeholder = getString(key: keyStr)
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.delegate = self
        tf.floatingLabelFont = .systemFont(ofSize: 12, Weight: .regular)
        tf.floatingLabelTextColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
        tf.floatingLabelActiveTextColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        tf.placeholderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
        
        tfView.addSubview(tf)
        tf.setLeft(offSet: 5)
        tf.setRight(offSet: -5)
        tf.setCenterY()
        
        self.addArrangedSubview(tfView)
        tfView.backgroundColor = UIColor.white
        tfView.setWidth(constant: viewWidth - (2 * X_SPACE))
        tfView.setHeight(constant: MDFLTEXTFIELD_HEIGHT)
        
        if addShadow {
            tfView.addShadowAndCornerRadius(.SMALL)
        }
        else{
            tfView.addCornerRadius(.SMALL)
            tfView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
            tfView.layer.borderWidth = 1
        }
        
        if(isCustomPicker == true)
        {
            tf.inputView = customPickerView
        }
        return tf
    }
    
//MARK: - Action Calls
        
    @objc func dismissKeyboard(){
        setPickerSelectedValueText()
        self.endEditing(true)
    }
    
//MARK: - PickerView Delegate and Data source methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(self.primaryPhoneMDTF!.isFirstResponder)
        {
            return primaryPhoneArr.count
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(self.primaryPhoneMDTF!.isFirstResponder)
        {
            return primaryPhoneArr[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.primaryPhoneMDTF!.isFirstResponder)
        {
            selectedPrimaryPhoneIndex = row
        }
        setPickerSelectedValueText()
    }
    
//MARK: - Set PickerSelectedValueText
    
    func setPickerSelectedValueText(){
        if(self.primaryPhoneMDTF!.isFirstResponder)
        {
            self.primaryPhoneMDTF!.text = primaryPhoneArr[selectedPrimaryPhoneIndex]
        }
    }
}
