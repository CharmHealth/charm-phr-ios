//
//  PersonalDetailsView.swift
//  phr
//
//  Created by Dhanuprasanya P on 08/12/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let MDFLTEXTFIELD_HEIGHT: CGFloat = 60
fileprivate let BUTTON_HEIGHT_42: CGFloat = 42

//MARK: - PersonalDetailsView

class PersonalDetailsView: UIStackView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MDTextFieldDelegate {
    
    private var firstNameMDTF : MDFLTextField?
    private var lastNameMDTF : MDFLTextField?
    private var dobMDTF : MDFLTextField?
    private var birthSexMDTF : MDFLTextField?
    var genderIdentityMDTF : MDFLTextField?
    private var genderIdOtherMDTF: MDFLTextField?
    private var bloodGroupMDTF : MDFLTextField?
    var languageMDTF : MDFLTextField?
    var raceMDTF : MDFLTextField?
    var ethnicityMDTF : MDFLTextField?
    private var maritalStatusMDTF : MDFLTextField?
    private var employmentStatusMDTF : MDFLTextField?
    private var smokingStatusMDTF : MDFLTextField?
    
    private var birthSexPickerView = UIPickerView()
    private var bloodGroupPickerView = UIPickerView()
    private var maritalStatusPickerView = UIPickerView()
    private var employmentStatusPickerView = UIPickerView()
    private var smokingStatusPickerView = UIPickerView()
    
    private var selectedBirthSexIndex: Int = 0
    private var selectedGenderIdentityIndex: Int = 0
    private var selectedBloodGroupIndex: Int = 0
    private var selectedEthnicityIndex: Int = 0
    private var selectedMaritalStatusIndex: Int = 0
    private var selectedEmploymentStatusIndex: Int = 0
    private var selectedSmokingStatusIndex: Int = 0
    
    private let datepicker = UIDatePicker()
    private let primaryDataHandler = PrimaryDataHandler.sharedInstance
    private var viewWidth: CGFloat = 0
    /// Gap between this view's edges and its fields: 0 at the questionnaire's top level (the container already
    /// insets widgets by X_SPACE), X_SPACE - CARD_PADDING inside a section card. Fields are sized relative to
    /// this view so they follow fold/unfold and rotation (were fixed from the build-time width).
    private var horizontalInset: CGFloat = 0
    private var addShadow: Bool = true

//MARK: - init
    
    init(patient: Patient, width: CGFloat, addShadow: Bool) {
        super.init(frame: .zero)
        self.viewWidth = width
        self.addShadow = addShadow
        
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.spacing = 10
        self.alignment = .center
        horizontalInset = addShadow ? 0 : max(X_SPACE - CARD_PADDING, 0)
        // `width` is only a fallback; the questionnaire's .fill stacks normally set our width.
        let fallbackWidth = self.widthAnchor.constraint(equalToConstant: width)
        fallbackWidth.priority = UILayoutPriority(999)
        fallbackWidth.isActive = true
        
        birthSexPickerView.delegate = self
        birthSexPickerView.dataSource = self
        
        bloodGroupPickerView.delegate = self
        bloodGroupPickerView.dataSource = self
        
        maritalStatusPickerView.delegate = self
        maritalStatusPickerView.dataSource = self
        
        employmentStatusPickerView.delegate = self
        employmentStatusPickerView.dataSource = self
        
        smokingStatusPickerView.delegate = self
        smokingStatusPickerView.dataSource = self
        
        let personalDetailHeading = UILabel()
        addArrangedSubview(personalDetailHeading)
        
        personalDetailHeading.setProperties(textKey: "com.charmphr.questionnairevc.presonalDetail.title", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        personalDetailHeading.setWidth(constant: -(2 * horizontalInset), relatedView: self)
        
        self.firstNameMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.FirstName.title")
        self.firstNameMDTF?.isMandatoryField = true
        self.firstNameMDTF?.isEnableTF(false)
        firstNameMDTF?.text = patient.firstName
        
        self.lastNameMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.LastName.title")
        self.lastNameMDTF?.isMandatoryField = true
        self.lastNameMDTF?.isEnableTF(false)
        lastNameMDTF?.text = patient.lastName

        datepicker.preferredDatePickerStyle = .wheels
        datepicker.datePickerMode = .date
        datepicker.maximumDate = Date()
        datepicker.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        self.dobMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.DateOfBirth.title")
        self.dobMDTF?.isMandatoryField = true
        self.dobMDTF?.inputView = datepicker
        
        let dobtoolbar = MDDateToolbarWithDone(textField: self.dobMDTF, parent: self)
        dobtoolbar.done?.action = #selector(donedatePicker)
        
        dobMDTF?.text = CharmUtil.getDateStringWith(date: patient.dateOfBirth, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        datepicker.date = patient.dateOfBirth ?? Date()
        
        self.birthSexMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.BirthSex.title")
        if let birthSexMDTF = birthSexMDTF{
            birthSexMDTF.inputView = birthSexPickerView
            birthSexMDTF.isMandatoryField = true
            birthSexMDTF.text = patient.gender?.capitalizingFirstLetter()
        }
        
        if patient.requiredTabs.contains("Gender Identity"){
            self.genderIdentityMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.genderIdentity.title")
        }
        self.genderIdOtherMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.genderIdentity.other.title")
        
        let genderId = patient.genderIdentity ?? ""
        if genderId.lowercased().starts(with: "other") {
            let genderIdArr = genderId.components(separatedBy: ":")
            genderIdentityMDTF?.text = genderIdArr.firstOrNil() ?? ""
            genderIdOtherMDTF?.text = genderIdArr.dropFirst(1).joined(separator: ":")
            genderIdOtherMDTF?.superview?.isHidden = false
            genderIdOtherMDTF?.maxLength = GENDER_IDENTITY_OTHER_SIZE
        }
        else{
            genderIdOtherMDTF?.superview?.isHidden = true
            genderIdentityMDTF?.text = genderId
        }
        
        self.bloodGroupMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.BloodGroup.title")
        if let bloodGroupMDTF = bloodGroupMDTF{
            bloodGroupMDTF.inputView = bloodGroupPickerView
            bloodGroupMDTF.text = patient.bloodGroup
        }
        
        self.languageMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.language.title")
        languageMDTF?.text = patient.language
        
        if patient.requiredTabs.contains("Race"){
            self.raceMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.Race.title")
            raceMDTF?.text = patient.race
        }
        
        if patient.requiredTabs.contains("Ethnicity"){
            self.ethnicityMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.ethnicity.title")
            ethnicityMDTF?.text = patient.ethnicity
        }
        
        self.maritalStatusMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.maritalstatus.title")
        if let maritalStatusMDTF = maritalStatusMDTF{
            maritalStatusMDTF.inputView = maritalStatusPickerView
        }
        maritalStatusMDTF?.text = patient.maritalStatus
        
        self.employmentStatusMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.employmentstatus.title")
        if let employmentStatusMDTF = employmentStatusMDTF{
            employmentStatusMDTF.inputView = employmentStatusPickerView
        }
        employmentStatusMDTF?.text = patient.employmentStatus
        
        self.smokingStatusMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.smokingstatus.title")
        if let smokingStatusMDTF = smokingStatusMDTF{
            smokingStatusMDTF.inputView = smokingStatusPickerView
        }
        smokingStatusMDTF?.text = patient.smokingStatus
        
        self.layoutIfNeeded()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
//MARK: - Action calls
    
    @objc func dismissKeyboard(){
        setPickerSelectedValueText()
        self.endEditing(true)
    }
    
    @objc func datePickerValueChanged(datePicker : UIDatePicker)
    {
        dobMDTF?.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
    }
    @objc func donedatePicker(_ barItem: UIBarItem){
        
        if let textField = dobMDTF {
            if let datePicker = textField.inputView as? UIDatePicker{
                textField.text = datePicker.date.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                self.endEditing(true)
            }
        }
    }
    
//MARK: - Validate PersonalDetails
    
    func validatePersonalDetails(isSubmitted: Bool) -> [String: MDFLTextField?]{
        let dob = dobMDTF?.text ?? ""
        if dob.isBlank() && isSubmitted{
            return ["com.charmphr.questionnairevc.presonalDetail.dob.empty": dobMDTF]
        }
        
        let genderId = genderIdentityMDTF?.text ?? ""
        if genderId.lowercased() == "other" {
            let otherVal = genderIdOtherMDTF?.text ?? ""
            
            if otherVal.isBlank() && isSubmitted{
                return ["com.charmphr.questionnairevc.presonalDetail.genderId.empty":genderIdOtherMDTF]
            }
        }
        return [:]
    }
    
//MARK: - Get Patient Data
    
    func getPatientData(patient: Patient) -> Patient{
        
        var genderId = genderIdentityMDTF?.text ?? ""
        if genderId.lowercased() == "other" {
            let otherVal = genderIdOtherMDTF?.text ?? ""
            genderId = "\(genderId):\(otherVal)"
        }
        
        patient.firstName = firstNameMDTF?.text
        patient.lastName = lastNameMDTF?.text
        patient.dateOfBirth = CharmUtil.getDateObjectWith(dateString: dobMDTF?.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        patient.gender = birthSexMDTF?.text
        patient.genderIdentity = genderId
        patient.bloodGroup = bloodGroupMDTF?.text
        patient.language = languageMDTF?.text
        patient.race = raceMDTF?.text
        patient.ethnicity = ethnicityMDTF?.text
        patient.maritalStatus = maritalStatusMDTF?.text
        patient.smokingStatus = smokingStatusMDTF?.text
        patient.employmentStatus = employmentStatusMDTF?.text
        
        return patient
    }
    
//MARK: - Get MDFLTextField
    
    func getMDFLTextField(keyStr:String) -> MDFLTextField
    {
        let tfView = UIView()
        let tf = MDFLTextField()
        tf.placeholder = getString(key: keyStr)
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.delegate = self
        // Without this the floated label fell back to a serif default font.
        tf.floatingLabelFont = .systemFont(ofSize: 12, Weight: .regular)
        tf.floatingLabelTextColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
        tf.floatingLabelActiveTextColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        tf.placeholderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)

        
        tfView.addSubview(tf)
        tf.setLeft(offSet: PADDING)
        tf.setRight(offSet: -PADDING)
        tf.setCenterY()
        
        self.addArrangedSubview(tfView)
        tfView.backgroundColor = UIColor.white
        tfView.setWidth(constant: -(2 * horizontalInset), relatedView: self)
        tfView.setHeight(constant: MDFLTEXTFIELD_HEIGHT)
        if addShadow {
            tfView.addShadowAndCornerRadius(.SMALL)
        }
        else{
            tfView.addCornerRadius(.SMALL)
            tfView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
            tfView.layer.borderWidth = 1
        }
        
        return tf
    }
    
//MARK: - PickerView Delegate and Data source methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.birthSexMDTF?.isFirstResponder == true{
            return primaryDataHandler.birthSexArr?.count ?? 0
        }
        else if self.genderIdentityMDTF?.isFirstResponder == true{
            return primaryDataHandler.genderIdentityArr?.count ?? 0
        }
        else if self.bloodGroupMDTF?.isFirstResponder == true{
            return primaryDataHandler.bloodGroupArr?.count ?? 0
        }
        else if self.ethnicityMDTF?.isFirstResponder == true{
            return primaryDataHandler.ethnicityArr?.count ?? 0
        }
        else if self.maritalStatusMDTF?.isFirstResponder == true{
            return primaryDataHandler.maritalStatusArr?.count ?? 0
        }
        else if self.employmentStatusMDTF?.isFirstResponder == true{
            return primaryDataHandler.employmentStausArr?.count ?? 0
        }
        else if self.smokingStatusMDTF?.isFirstResponder == true{
            return primaryDataHandler.smokingStatusArr?.count ?? 0
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if self.birthSexMDTF?.isFirstResponder == true{
            return primaryDataHandler.birthSexArr?[row]
        }
        else if self.genderIdentityMDTF?.isFirstResponder == true{
            return primaryDataHandler.genderIdentityArr?[row]
        }
        else if self.bloodGroupMDTF?.isFirstResponder == true{
            return primaryDataHandler.bloodGroupArr?[row]
        }
        else if self.ethnicityMDTF?.isFirstResponder == true{
            return primaryDataHandler.ethnicityArr?[row]
        }
        else if self.maritalStatusMDTF?.isFirstResponder == true{
            return primaryDataHandler.maritalStatusArr?[row]
        }
        else if self.employmentStatusMDTF?.isFirstResponder == true{
            return primaryDataHandler.employmentStausArr?[row]
        }
        else if self.smokingStatusMDTF?.isFirstResponder == true{
            return primaryDataHandler.smokingStatusArr?[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.birthSexMDTF?.isFirstResponder == true{
            selectedBirthSexIndex = row
        }
        else if self.genderIdentityMDTF?.isFirstResponder == true {
            selectedGenderIdentityIndex = row
        }
        else if self.bloodGroupMDTF?.isFirstResponder == true {
            selectedBloodGroupIndex = row
        }
        else if self.ethnicityMDTF?.isFirstResponder == true {
            selectedEthnicityIndex = row
        }
        else if self.maritalStatusMDTF?.isFirstResponder == true {
            selectedMaritalStatusIndex = row
        }
        else if self.employmentStatusMDTF?.isFirstResponder == true {
            selectedEmploymentStatusIndex = row
        }
        else if self.smokingStatusMDTF?.isFirstResponder == true {
            selectedSmokingStatusIndex = row
        }
        setPickerSelectedValueText()
    }
    
//MARK: - Set PickerSelectedValueText
    
    func setPickerSelectedValueText(){
        if self.birthSexMDTF?.isFirstResponder == true
        {
            self.birthSexMDTF?.text = primaryDataHandler.birthSexArr?[selectedBirthSexIndex]
        }
        else if self.genderIdentityMDTF?.isFirstResponder  == true{
            let genderId = primaryDataHandler.genderIdentityArr?[selectedGenderIdentityIndex]
            self.genderIdentityMDTF?.text = genderId
            setGenderIdentity()
        }
        else if self.bloodGroupMDTF?.isFirstResponder  == true{
            self.bloodGroupMDTF!.text = primaryDataHandler.bloodGroupArr?[selectedBloodGroupIndex]
        }
        else if self.ethnicityMDTF?.isFirstResponder == true {
            self.ethnicityMDTF!.text = primaryDataHandler.ethnicityArr?[selectedEthnicityIndex]
        }
        else if self.maritalStatusMDTF?.isFirstResponder == true{
            self.maritalStatusMDTF!.text = primaryDataHandler.maritalStatusArr?[selectedMaritalStatusIndex]
        }
        else if self.employmentStatusMDTF?.isFirstResponder == true {
            self.employmentStatusMDTF!.text = primaryDataHandler.employmentStausArr?[selectedEmploymentStatusIndex]
        }
        else if self.smokingStatusMDTF?.isFirstResponder == true{
            self.smokingStatusMDTF!.text = primaryDataHandler.smokingStatusArr?[selectedSmokingStatusIndex]
        }
    }
    
    func setGenderIdentity(){
        if genderIdentityMDTF?.text?.lowercased() == "other" {
            self.genderIdOtherMDTF?.superview?.isHidden = false
        }
        else{
            if self.genderIdOtherMDTF?.superview?.isHidden == false {
                self.genderIdOtherMDTF?.superview?.isHidden = true
            }
        }
    }
}

//MARK: - MDDateToolbar

class MDDateToolbarWithDone{
    
    var textField: UITextField? = nil
    var parent: Any? = nil
    var done: UIBarButtonItem? = nil
    
    init(textField: UITextField? , parent: Any) {
        self.textField = textField
        self.parent = parent
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: parent, action: nil)
        done = UIBarButtonItem(title: getString(key: "com.charmphr.action.done"), style: .plain, target: parent, action: nil)
        
        let appearance = UIBarButtonItemAppearance()
        appearance.normal.titleTextAttributes = [.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)]
        appearance.highlighted.titleTextAttributes = [.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)]

        // Apply to toolbar
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.buttonAppearance = appearance
        toolbarAppearance.doneButtonAppearance = appearance

        toolbar.standardAppearance = toolbarAppearance
        if #available(iOS 15.0, *) {
            toolbar.scrollEdgeAppearance = toolbarAppearance
        }
        toolbar.setItems([space, done!], animated: false)
        
        self.textField?.inputAccessoryView = toolbar
    }
}
