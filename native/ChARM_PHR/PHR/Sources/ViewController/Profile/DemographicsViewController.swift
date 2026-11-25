//
//  DemographicsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 01/09/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import MobileCoreServices
import PhotosUI

protocol DemographicsViewControllerDidChangeValueDelegate: AnyObject {
    func demographicsViewControllerDidChangeName()
    func demographicsViewControllerDidChangePatientPhoto(photo : UIImage)
}

class DemographicsViewController:  UIViewController , CharmConnectionHandlerDelegate,CharmConnectionV2HandlerDelegate, SelectValueViewControllerDelagate, UIImagePickerControllerDelegate , UINavigationControllerDelegate, PrimaryDataHandlerDelegate, MDTextFieldDelegate, UITextFieldDelegate , PHPickerViewControllerDelegate , DismissModelViewDelegate
{
 
    
    let DEMOGRAPHICS_PATIENT_IMAGE_VIEW_TAG = 1050
    
    let DEMOGRAPHICS_FIRSTNAME_VIEW_TAG = 1000
    let DEMOGRAPHICS_LASTNAME_VIEW_TAG = 1001
    let DEMOGRAPHICS_DATEOFBIRTH_VIEW_TAG = 1002
    let DEMOGRAPHICS_BIRTHSEX_VIEW_TAG = 1003
    let DEMOGRAPHICS_BLOODGROUP_VIEW_TAG = 1004
    let DEMOGRAPHICS_ADDRESSLINE1_VIEW_TAG = 1005
    let DEMOGRAPHICS_ADDRESSLINE2_VIEW_TAG = 1006
    let DEMOGRAPHICS_COUNTRY_VIEW_TAG = 1007
    let DEMOGRAPHICS_STATE_VIEW_TAG = 1008
    let DEMOGRAPHICS_CITY_VIEW_TAG = 1009
    let DEMOGRAPHICS_HOMEPHONE_VIEW_TAG = 1010
    let DEMOGRAPHICS_MOBILEPHONE_VIEW_TAG = 1011
    let DEMOGRAPHICS_CAREGIVERNAME_VIEW_TAG = 1012
    let DEMOGRAPHICS_CAREGIVERPHONE_VIEW_TAG = 1013
    let DEMOGRAPHICS_CONTACTNAME_VIEW_TAG = 1014
    let DEMOGRAPHICS_CONTACTNUMBER_VIEW_TAG = 1015
    let DEMOGRAPHICS_POSTALCODE_VIEW_TAG = 1016
    
    var patient : Patient!
    
    let activityIndicator = UIActivityIndicatorView()
    
    var charmConnectionHandler : CharmConnectionHandler?
    
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView?
    weak var valueChangedDelegate : DemographicsViewControllerDidChangeValueDelegate?
    
    let primaryDataHandler = PrimaryDataHandler.sharedInstance
    
    var stateArr : Array<String> = []
    private var countryKey: String = ""
    
    var uploadingImage : UIImage!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patient = Patient.selectedPatientInstance!.copy() as? Patient

        self.setLargeTitle(enable: false)
        self.navigationItem.title = getString(key: "com.charmphr.Demographics.title")
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveBtnClicked)), animated: true)
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
                
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.v2Delegate = self
        
        fetchApi()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func fetchApi(){
        
        showActivityIndicator()
        if !PrimaryDataHandler.hasAllData()
        {
            primaryDataHandler.delegate = self
            primaryDataHandler.fetchPrimaryData()
        }else
        {
            charmConnectionHandler?.fetchDemographics(patientId: Patient.selectedPatientInstance!.patientId, identificationKey: "fetchDemographics")
        }
    }
    
    func createSubViews()
    {
        
        let datepicker = UIDatePicker()
        
        datepicker.preferredDatePickerStyle = .wheels
        datepicker.datePickerMode = .date
        datepicker.maximumDate = Date()
        datepicker.date = patient.dateOfBirth ?? Date()
        datepicker.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let patientPhotoImagView = ImageViewWithInitailsView(initials: "\(isNilOrEmpty(string: patient.firstName) == false ? String(patient.firstName.first!) : "")\(isNilOrEmpty(string: patient.lastName) == false ? String(patient.lastName.first!) : "")", image: patient.patientPhoto)
        patientPhotoImagView.addCornerRadius(.SMALL)
        patientPhotoImagView.layer.masksToBounds = true
        patientPhotoImagView.tag = DEMOGRAPHICS_PATIENT_IMAGE_VIEW_TAG
        containerView.addSubview(patientPhotoImagView)
        
        let changePhofilePhotoBtn = UIButton()
        changePhofilePhotoBtn.setTitle(getString(key: "com.charmphr.EditDemographics.changeProfilePhoto.title"), for: .normal)
        changePhofilePhotoBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
        changePhofilePhotoBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR), for: .normal)
        changePhofilePhotoBtn.addTarget(self, action: #selector(changeProfileBtnClicked), for: .touchUpInside)
        containerView.addSubview(changePhofilePhotoBtn)
        
        
        let patientInfoView = UIView()
        patientInfoView.addShadowAndCornerRadius(.SMALL)
        
        containerView.addSubview(patientInfoView)
        
        let firstNameView = AddModuleKeyAndValueView()
        firstNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        firstNameView.tag = DEMOGRAPHICS_FIRSTNAME_VIEW_TAG
        firstNameView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.FirstName.title")
        firstNameView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.FirstName.title")
        firstNameView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        firstNameView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        firstNameView.textField.maxLength = 50
        firstNameView.textField.delegate = self
        firstNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        firstNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        patientInfoView.addSubview(firstNameView)
        
        let lastNameView = AddModuleKeyAndValueView()
        lastNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        lastNameView.tag = DEMOGRAPHICS_LASTNAME_VIEW_TAG
        lastNameView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.LastName.title")
        lastNameView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.LastName.title")
        lastNameView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        lastNameView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        lastNameView.textField.delegate = self
        lastNameView.textField.maxLength = 50
        lastNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        lastNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        patientInfoView.addSubview(lastNameView)
        
        let dateOfBirthView = AddModuleKeyAndValueView()
        dateOfBirthView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        dateOfBirthView.tag = DEMOGRAPHICS_DATEOFBIRTH_VIEW_TAG
        dateOfBirthView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.DateOfBirth.title")
        dateOfBirthView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.DateOfBirth.title")
        dateOfBirthView.textField.inputView = datepicker
        dateOfBirthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        dateOfBirthView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        patientInfoView.addSubview(dateOfBirthView)
        
        let birthSexView = AddModuleKeyAndValueView()
        birthSexView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        birthSexView.tag = DEMOGRAPHICS_BIRTHSEX_VIEW_TAG
        birthSexView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.BirthSex.title")
        birthSexView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        birthSexView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        patientInfoView.addSubview(birthSexView)
        
        let bloodGroupView = AddModuleKeyAndValueView()
        bloodGroupView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        bloodGroupView.tag = DEMOGRAPHICS_BLOODGROUP_VIEW_TAG
        bloodGroupView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.BloodGroup.title")
        bloodGroupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
//        bloodGroupView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        patientInfoView.addSubview(bloodGroupView)
        
        
        let addressView = UIView()
        
        addressView.addShadowAndCornerRadius(.SMALL)
        containerView.addSubview(addressView)
        
        let addressLine1View = AddModuleKeyAndValueView()
        addressLine1View.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        addressLine1View.tag = DEMOGRAPHICS_ADDRESSLINE1_VIEW_TAG
        addressLine1View.keyLabel.text = getString(key: "com.charmphr.EditDemographics.ADDRESSLINE1.title")
        addressLine1View.textField.placeholder = getString(key: "com.charmphr.EditDemographics.ADDRESSLINE1.title")
        addressLine1View.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        addressLine1View.textField.textFieldType = MDTextFieldTypeSpecificPattern
        addressLine1View.textField.delegate = self
        addressLine1View.textField.maxLength = 35
        addressLine1View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        addressLine1View.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        addressView.addSubview(addressLine1View)
        
        let addressLine2View = AddModuleKeyAndValueView()
        addressLine2View.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        addressLine2View.tag = DEMOGRAPHICS_ADDRESSLINE2_VIEW_TAG
        addressLine2View.keyLabel.text = getString(key: "com.charmphr.EditDemographics.ADDRESSLINE2.title")
        addressLine2View.textField.placeholder = getString(key: "com.charmphr.EditDemographics.ADDRESSLINE2.title")
        addressLine2View.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        addressLine2View.textField.textFieldType = MDTextFieldTypeSpecificPattern
        addressLine2View.textField.delegate = self
        addressLine2View.textField.maxLength = 35
        addressLine2View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        addressLine2View.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        addressView.addSubview(addressLine2View)
        
        let countryView = AddModuleKeyAndValueView()
        countryView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        countryView.tag = DEMOGRAPHICS_COUNTRY_VIEW_TAG
        countryView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.Country.title")
        countryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        countryView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        addressView.addSubview(countryView)
        
        let stateView = AddModuleKeyAndValueView()
        stateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        stateView.tag = DEMOGRAPHICS_STATE_VIEW_TAG
        stateView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.State.title")
        stateView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.State.title")
        stateView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        stateView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        stateView.textField.delegate = self
        stateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        stateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        addressView.addSubview(stateView)
        
        let cityView = AddModuleKeyAndValueView()
        cityView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        cityView.tag = DEMOGRAPHICS_CITY_VIEW_TAG
        cityView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.City.title")
        cityView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.City.title")
        cityView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        cityView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        cityView.textField.delegate = self
        cityView.textField.maxLength = 35
        cityView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        cityView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        addressView.addSubview(cityView)

        let postalCodeView = AddModuleKeyAndValueView()
        postalCodeView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        postalCodeView.tag = DEMOGRAPHICS_POSTALCODE_VIEW_TAG
        postalCodeView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.postalCode.title")
        postalCodeView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
        postalCodeView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        postalCodeView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        postalCodeView.textField.delegate = self
        postalCodeView.textField.maxLength = ADDRESS_POSTAL_CODE_SIZE
        postalCodeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        addressView.addSubview(postalCodeView)


        let otherViews = UIView()
        
        otherViews.addShadowAndCornerRadius(.SMALL)
        containerView.addSubview(otherViews)
        
        let homePhoneView = AddModuleKeyAndValueView()
        homePhoneView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        homePhoneView.tag = DEMOGRAPHICS_HOMEPHONE_VIEW_TAG
        homePhoneView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.HomePhone.title")
        homePhoneView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.HomePhone.title")
       // homePhoneView.textField.textFieldType = MDTextFieldTypeInteger
        homePhoneView.textField.maxLength = 10
        homePhoneView.textField.delegate = self
        homePhoneView.textField.keyboardType = .numberPad
        homePhoneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        homePhoneView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        otherViews.addSubview(homePhoneView)
        
        let mobilePhoneView = AddModuleKeyAndValueView()
        mobilePhoneView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        mobilePhoneView.tag = DEMOGRAPHICS_MOBILEPHONE_VIEW_TAG
        mobilePhoneView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.MobilePhone.title")
        mobilePhoneView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.MobilePhone.title")
        mobilePhoneView.textField.keyboardType = .numberPad
        mobilePhoneView.textField.delegate = self
        mobilePhoneView.textField.maxLength = 10
        mobilePhoneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        mobilePhoneView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        otherViews.addSubview(mobilePhoneView)
        
        let careGiverNameView = AddModuleKeyAndValueView()
        careGiverNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        careGiverNameView.tag = DEMOGRAPHICS_CAREGIVERNAME_VIEW_TAG
        careGiverNameView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.CaregiverName.title")
        careGiverNameView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.CaregiverName.title")
        careGiverNameView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        careGiverNameView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        careGiverNameView.textField.delegate = self
        careGiverNameView.textField.maxLength = 100
        careGiverNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        careGiverNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        otherViews.addSubview(careGiverNameView)
        
        let caregiverPhoneView = AddModuleKeyAndValueView()
        caregiverPhoneView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        caregiverPhoneView.tag = DEMOGRAPHICS_CAREGIVERPHONE_VIEW_TAG
        caregiverPhoneView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.CaregiverPhone.title")
        caregiverPhoneView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.CaregiverPhone.title")
        caregiverPhoneView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        caregiverPhoneView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        caregiverPhoneView.textField.delegate = self
        caregiverPhoneView.textField.keyboardType = .numberPad
        caregiverPhoneView.textField.maxLength = 10
        caregiverPhoneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        caregiverPhoneView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        otherViews.addSubview(caregiverPhoneView)
        
        let contactNameView = AddModuleKeyAndValueView()
        contactNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        contactNameView.tag = DEMOGRAPHICS_CONTACTNAME_VIEW_TAG
        contactNameView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.ContactName.title")
        contactNameView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.ContactName.title")
        contactNameView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        contactNameView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        contactNameView.textField.delegate = self
        contactNameView.textField.maxLength = 50
        contactNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        contactNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        otherViews.addSubview(contactNameView)
        
        let contactNumberView = AddModuleKeyAndValueView()
        contactNumberView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        contactNumberView.tag = DEMOGRAPHICS_CONTACTNUMBER_VIEW_TAG
        contactNumberView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.ContactNumber.title")
        contactNumberView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.ContactNumber.title")
        contactNumberView.textField.keyboardType = .numberPad
        contactNumberView.textField.delegate = self
        contactNumberView.textField.maxLength = 10
        contactNumberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        otherViews.addSubview(contactNumberView)
        
        patientPhotoImagView.setTop(offSet: 8)
        patientPhotoImagView.setCenterX()
        patientPhotoImagView.setHeight(constant: 75)
        patientPhotoImagView.setWidth(constant: 75)
        
        changePhofilePhotoBtn.setTopRelatedToView(offSet: 9, relatedView: patientPhotoImagView, relatedAttribute: .bottom)
        changePhofilePhotoBtn.setCenterX()
        
        patientInfoView.setTopRelatedToView(offSet: 8, relatedView: changePhofilePhotoBtn, relatedAttribute: .bottom)
        patientInfoView.setHorizontal(offSet: X_SPACE)
        
        
        
        firstNameView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CardSize.SMALL.value)
        firstNameView.setTop(offSet: 0)
        firstNameView.setLeft(offSet: 0)
        firstNameView.setRight(offSet: 0)
        
        lastNameView.setTopRelatedToView(offSet: 0, relatedView: firstNameView, relatedAttribute: .bottom)
        lastNameView.setLeft(offSet: 0)
        lastNameView.setRight(offSet: 0)
        
        dateOfBirthView.setTopRelatedToView(offSet: 0, relatedView: lastNameView, relatedAttribute: .bottom)
        dateOfBirthView.setLeft(offSet: 0)
        dateOfBirthView.setRight(offSet: 0)
        
        birthSexView.setTopRelatedToView(offSet: 0, relatedView: dateOfBirthView, relatedAttribute: .bottom)
        birthSexView.setLeft(offSet: 0)
        birthSexView.setRight(offSet: 0)
        
        bloodGroupView.setTopRelatedToView(offSet: 0, relatedView: birthSexView, relatedAttribute: .bottom)
        bloodGroupView.setLeft(offSet: 0)
        bloodGroupView.setRight(offSet: 0)
        bloodGroupView.setBottom(offSet: 0)
        bloodGroupView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)

        
        addressView.setTopRelatedToView(offSet: 8, relatedView: patientInfoView, relatedAttribute: .bottom)
        addressView.setHorizontal(offSet: X_SPACE)
        
        addressLine1View.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CardSize.SMALL.value)
        addressLine1View.setTop(offSet: 0)
        addressLine1View.setLeft(offSet: 0)
        addressLine1View.setRight(offSet: 0)
        
        addressLine2View.setTopRelatedToView(offSet: 0, relatedView: addressLine1View, relatedAttribute: .bottom)
        addressLine2View.setLeft(offSet: 0)
        addressLine2View.setRight(offSet: 0)
        addressLine2View.setBottomRelatedToView(offSet: 0, relatedView: countryView, relatedAttribute: .top)
        
        countryView.setTopRelatedToView(offSet: 0, relatedView: addressLine2View, relatedAttribute: .bottom)
        countryView.setLeft(offSet: 0)
        countryView.setRight(offSet: 0)

        stateView.setTopRelatedToView(offSet: 0, relatedView: countryView, relatedAttribute: .bottom)
        stateView.setLeft(offSet: 0)
        stateView.setRight(offSet: 0)
        
        cityView.setTopRelatedToView(offSet: 0, relatedView: stateView, relatedAttribute: .bottom)
        cityView.setLeft(offSet: 0)
        cityView.setRight(offSet: 0)

        postalCodeView.setTopRelatedToView(offSet: 0, relatedView: cityView, relatedAttribute: .bottom)
        postalCodeView.setLeft(offSet: 0)
        postalCodeView.setRight(offSet: 0)
        postalCodeView.setBottom(offSet: 0)
        postalCodeView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)

        otherViews.setTopRelatedToView(offSet: 8, relatedView: addressView, relatedAttribute: .bottom)
        otherViews.setHorizontal(offSet: X_SPACE)
        otherViews.setBottom(offSet: -8)
        
        homePhoneView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CardSize.SMALL.value)
        homePhoneView.setTop(offSet: 0)
        homePhoneView.setLeft(offSet: 0)
        homePhoneView.setRight(offSet: 0)
        
        mobilePhoneView.setTopRelatedToView(offSet: 0, relatedView: homePhoneView, relatedAttribute: .bottom)
        mobilePhoneView.setLeft(offSet: 0)
        mobilePhoneView.setRight(offSet: -0)
        
        careGiverNameView.setTopRelatedToView(offSet: 0, relatedView: mobilePhoneView, relatedAttribute: .bottom)
        careGiverNameView.setLeft(offSet: 0)
        careGiverNameView.setRight(offSet: -0)
        
        caregiverPhoneView.setTopRelatedToView(offSet: 0, relatedView: careGiverNameView, relatedAttribute: .bottom)
        caregiverPhoneView.setLeft(offSet: 0)
        caregiverPhoneView.setRight(offSet: 0)
        
        contactNameView.setTopRelatedToView(offSet: 0, relatedView: caregiverPhoneView, relatedAttribute: .bottom)
        contactNameView.setLeft(offSet: 0)
        contactNameView.setRight(offSet: -0)
        
        contactNumberView.setTopRelatedToView(offSet: 0, relatedView: contactNameView, relatedAttribute: .bottom)
        contactNumberView.setLeft(offSet: 0)
        contactNumberView.setRight(offSet: 0)
        contactNumberView.setBottom(offSet: 0)
        contactNumberView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)
        
        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        // Edge pins inside a scroll view only set content bounds; this ties the width to the visible area.
        containerView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor).isActive = true

        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        
        self.view.bringSubviewToFront(activityIndicator)
        
    }
    
    //MARK: - action calles
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
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
    
    @objc func changeProfileBtnClicked(_ btn: UIButton)
    {
        self.view.endEditing(true)
                
        CharmUtil.showCameraOrPhotoSelectionAlert(view: btn, barButton: nil, photoSelected: {
            var configuration = PHPickerConfiguration()
            //0 - unlimited 1 - default
            configuration.selectionLimit = 1
            configuration.filter = .images
            let pickerViewController = PHPickerViewController(configuration: configuration)
            pickerViewController.delegate = self
            self.present(pickerViewController, animated: true)
        }, cameraSelected: {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.mediaTypes = [String(kUTTypeImage),String(kUTTypePNG),String(kUTTypeJPEG)]
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
    }
    
    //ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let imageURL = info[.imageURL] as? URL
        {
            picker.dismiss(animated: true) {
                self.uploadingImage = (info[.originalImage] as? UIImage)?.fixedOrientation()
                
                if let data = try? Data(contentsOf: imageURL) {
                    self.charmConnectionHandler?.uploadPatientImage(param: ["\(imageURL.lastPathComponent)":data ], patientId: Patient.selectedPatientInstance!.patientId, identificationKey: "uploadImage")
                    self.showActivityIndicator()
                }
                else{
                    CharmUtil.createOkayAlertWith(title: "", msg: getString(key: "com.charmphr.profile.image.failed"))
                }
                
                
            }
        }
        else {
            if let image = (info[.originalImage] as? UIImage)?.fixedOrientation()
            {
                picker.dismiss(animated: true) {
                   
            
                    self.uploadingImage = image
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        self.charmConnectionHandler?.uploadPatientImage(param: ["patientImg.jpeg":data ], patientId: getSelectedPatientId(), identificationKey: "uploadImage")
                        self.showActivityIndicator()
                    }
                    else{
                        CharmUtil.createOkayAlertWith(title: "", msg: getString(key: "com.charmphr.profile.image.failed"))
                    }
                    

                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
    //MARK: - PHPicker delegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if let result = results.firstOrNil() {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { object , error in
                if let uploadingImage = object as? UIImage {
//                    let jpeg = uploadingImage.jpegData(compressionQuality: 1)
//                    debugPrintLog("Fallback image size: \(jpeg?.count ?? 0) bytes")
//                    
                    DispatchQueue.main.async {
                        
                        self.uploadingImage = uploadingImage
                        if let data = uploadingImage.jpegData(compressionQuality: 0.8) {
                            self.charmConnectionHandler?.uploadPatientImage(param: ["patientImg.jpeg":data ], patientId: getSelectedPatientId(), identificationKey: "uploadImage")
                            self.showActivityIndicator()
                        }
                        else{
                            CharmUtil.createOkayAlertWith(title: "", msg: getString(key: "com.charmphr.profile.image.failed"))
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        CharmUtil.createOkayAlertWith(title: "", msg: getString(key: "com.charmphr.profile.image.failed"))
                    }
                }
            })
        }
    }
    
    
    @objc func saveBtnClicked()
    {
        let firstNameView = self.view.viewWithTag(DEMOGRAPHICS_FIRSTNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let lastNameView = self.view.viewWithTag(DEMOGRAPHICS_LASTNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let birthSexView = self.view.viewWithTag(DEMOGRAPHICS_BIRTHSEX_VIEW_TAG) as! AddModuleKeyAndValueView
        let dateOfBirthView = self.view.viewWithTag(DEMOGRAPHICS_DATEOFBIRTH_VIEW_TAG) as! AddModuleKeyAndValueView
        let bloodGroupView = self.view.viewWithTag(DEMOGRAPHICS_BLOODGROUP_VIEW_TAG) as! AddModuleKeyAndValueView
        let addressLine1 = self.view.viewWithTag(DEMOGRAPHICS_ADDRESSLINE1_VIEW_TAG) as! AddModuleKeyAndValueView
        let addressLine2 = self.view.viewWithTag(DEMOGRAPHICS_ADDRESSLINE2_VIEW_TAG) as! AddModuleKeyAndValueView
        let stateView = self.view.viewWithTag(DEMOGRAPHICS_STATE_VIEW_TAG) as! AddModuleKeyAndValueView
        let cityView = self.view.viewWithTag(DEMOGRAPHICS_CITY_VIEW_TAG) as! AddModuleKeyAndValueView
        let countryView = self.view.viewWithTag(DEMOGRAPHICS_COUNTRY_VIEW_TAG) as! AddModuleKeyAndValueView
        let homePhoneView = self.view.viewWithTag(DEMOGRAPHICS_HOMEPHONE_VIEW_TAG) as! AddModuleKeyAndValueView
        let mobilePhoneView = self.view.viewWithTag(DEMOGRAPHICS_MOBILEPHONE_VIEW_TAG) as! AddModuleKeyAndValueView
        let careGiverNameView = self.view.viewWithTag(DEMOGRAPHICS_CAREGIVERNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let careGiverPhoneView = self.view.viewWithTag(DEMOGRAPHICS_CAREGIVERPHONE_VIEW_TAG) as! AddModuleKeyAndValueView
        let contactNameView = self.view.viewWithTag(DEMOGRAPHICS_CONTACTNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let contactNumberView = self.view.viewWithTag(DEMOGRAPHICS_CONTACTNUMBER_VIEW_TAG) as! AddModuleKeyAndValueView
        
        if isNilOrEmpty(string: firstNameView.textField.text)
        {
            showMandatoryAlert(fieldName: firstNameView.keyLabel.text!)
            firstNameView.textField.becomeFirstResponder()
        }
        else if isNilOrEmpty(string: lastNameView.textField.text)
        {
            showMandatoryAlert(fieldName: lastNameView.keyLabel.text!)
            firstNameView.textField.becomeFirstResponder()
        }
        else if isNilOrEmpty(string: birthSexView.valueLabel.text)
        {
            showMandatoryAlert(fieldName: birthSexView.keyLabel.text!)
        }
        else if isNilOrEmpty(string: dateOfBirthView.textField.text)
        {
            showMandatoryAlert(fieldName: dateOfBirthView.keyLabel.text!)
            dateOfBirthView.textField.becomeFirstResponder()
        }
        else if isNilOrEmpty(string: mobilePhoneView.textField.text)
        {
            showMandatoryAlert(fieldName: mobilePhoneView.keyLabel.text!)
            mobilePhoneView.textField.becomeFirstResponder()
        }else
        {
            patient.firstName = firstNameView.textField.text
            patient.lastName = lastNameView.textField.text
            patient.gender = birthSexView.valueLabel.text?.lowercased() ?? ""
            patient.dateOfBirth = CharmUtil.getDateObjectWith(dateString: dateOfBirthView.textField.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            patient.age = patient.dateOfBirth?.age
            patient.bloodGroup = bloodGroupView.valueLabel.text
            
            
            let address = patient.postalAddress ?? PostalAddress()
            
            address.line1 = addressLine1.textField.text
            address.line2 = addressLine2.textField.text
            
            let countryVal = countryView.valueLabel.text ?? ""
            
            if countryVal.isNotBlank() {
                address.country = countryKey
            }
            else {
                address.country = ""
            }
             
            address.state = stateView.textField.text
            address.city = cityView.textField.text
            let postalCodeView = self.view.viewWithTag(DEMOGRAPHICS_POSTALCODE_VIEW_TAG) as! AddModuleKeyAndValueView
            address.postalCode = postalCodeView.textField.text
            patient.postalAddress = address
            
           
            let contactDetail = patient.contactDetail ?? ContactDetails()
            
            
            contactDetail.landline = homePhoneView.textField.text
            contactDetail.mobile = mobilePhoneView.textField.text
            
            patient.contactDetail = contactDetail
            
            patient.emergencyContactName = contactNameView.textField.text
            patient.emergencyContactNumber = contactNumberView.textField.text
            
            
            let caregiver = patient.primaryCaregiver ?? CareGiver()
            
            caregiver.contactType = "primary"
            caregiver.firstName = careGiverNameView.textField.text
            caregiver.mobile = careGiverPhoneView.textField.text
            
            patient.primaryCaregiver = caregiver
            patient.patientId = getSelectedPatientId()

            showActivityIndicator()
            charmConnectionHandler?.saveDemographics(patient: patient, identificationKey: "updateDemographics")

        }
    }
    
    func showMandatoryAlert(fieldName : String)
    {
        let alertController = UIAlertController(title: nil, message: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName)", preferredStyle: .alert)
        let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default) { (alert) in
        
        }
        alertController.addAction(okAction)
        alertController.show()
    }
    
    @objc func datePickerValueChanged(datePicker : UIDatePicker)
    {
        setDateOfBirth(date: datePicker.date)
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        if selectedAddModuleKeyAndLabelView!.tag == DEMOGRAPHICS_BIRTHSEX_VIEW_TAG
        {
            setBirthSex(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView!.tag == DEMOGRAPHICS_BLOODGROUP_VIEW_TAG
        {
            setBloodGroup(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView!.tag == DEMOGRAPHICS_COUNTRY_VIEW_TAG
        {
            setCountry(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView!.tag == DEMOGRAPHICS_STATE_VIEW_TAG
        {
            setState(selectedRow: selectedRow)
        }
    }
    
    
    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
        {
            
            if addAllergiesKeyAndLabelView.tag == DEMOGRAPHICS_BIRTHSEX_VIEW_TAG || addAllergiesKeyAndLabelView.tag == DEMOGRAPHICS_BLOODGROUP_VIEW_TAG || addAllergiesKeyAndLabelView.tag == DEMOGRAPHICS_COUNTRY_VIEW_TAG || (addAllergiesKeyAndLabelView.tag == DEMOGRAPHICS_STATE_VIEW_TAG && stateArr.count > 0)
            {
                selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                dismissKeyboard()
                navigateToSelectValueVC()
            }
            else if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
            {
                if !addAllergiesKeyAndLabelView.textField.isHidden
                {
                    addAllergiesKeyAndLabelView.textField.becomeFirstResponder()
                }
            }
            
        }
    }

    //MARK: - charmconnection handler deletage
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchStates" ||  identificationKey == "fetchStatesToFill"
        {
            if countryKey == country_in {
                PrimaryDataHandler.sharedInstance.inStatesArr = ParsingHelper.formStateList(respObj: jsonObject)
                stateArr = PrimaryDataHandler.sharedInstance.inStatesArr ?? []
            }
            else if countryKey == country_us {
                PrimaryDataHandler.sharedInstance.usStatesArr = ParsingHelper.formStateList(respObj: jsonObject)
                stateArr = PrimaryDataHandler.sharedInstance.usStatesArr ?? []
            }
            else if countryKey == country_au{
                PrimaryDataHandler.sharedInstance.auStatesArr = ParsingHelper.formStateList(respObj: jsonObject)
                stateArr = PrimaryDataHandler.sharedInstance.auStatesArr ?? []
            }
            
            if identificationKey == "fetchStates"{
                setState(selectedRow: 0)
            }
            hideActivityIndicator()
        }
        
        else if identificationKey == "uploadImage"
        {
            hideActivityIndicator()
            if Patient.selectedPatientInstance?.isPhotoAvailable == false{
                Patient.selectedPatientInstance?.isPhotoAvailable = true
            }
            Patient.selectedPatientInstance?.patientPhoto = uploadingImage
            if let imageView = self.view.viewWithTag(DEMOGRAPHICS_PATIENT_IMAGE_VIEW_TAG) as? ImageViewWithInitailsView
            {
                imageView.setImage(image: uploadingImage)
            }
            valueChangedDelegate?.demographicsViewControllerDidChangePatientPhoto(photo: uploadingImage)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
       
        if identificationKey == "updateDemographics"{
            if let patient = response as? Patient {
                valueChangedDelegate?.demographicsViewControllerDidChangeName()
                self.navigationController?.popViewController(animated: true)
            }
        }
        else if identificationKey == "fetchDemographics"
        {
            if let tempPatient = response as? Patient {
                patient?.fill(using: tempPatient)
                
                createSubViews()
                hideActivityIndicator()
                fillvalues(demographics: patient)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    // fill answers
    func setDateOfBirth(date : Date)
    {
        if let addModuleKeyAndValueView = view.viewWithTag(DEMOGRAPHICS_DATEOFBIRTH_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addModuleKeyAndValueView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: date)
        }
    }
    
    func setBirthSex(selectedRow : Int)
    {
        if let addModuleKeyAndValueView = view.viewWithTag(DEMOGRAPHICS_BIRTHSEX_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addModuleKeyAndValueView.valueLabel.text = primaryDataHandler.birthSexArr?[selectedRow]
        }
    }
    
    func setBloodGroup(selectedRow : Int)
    {
        if let addModuleKeyAndValueView = view.viewWithTag(DEMOGRAPHICS_BLOODGROUP_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addModuleKeyAndValueView.valueLabel.text = primaryDataHandler.bloodGroupArr?[selectedRow]
        }
    }
    
    func setCountry(selectedRow : Int)
    {
        if let addModuleKeyAndValueView = view.viewWithTag(DEMOGRAPHICS_COUNTRY_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            if addModuleKeyAndValueView.valueLabel.text != primaryDataHandler.countriesArr?[selectedRow].value
            {
                if let selectedRowCountry = primaryDataHandler.countriesArr?[selectedRow]{
                    countryKey = selectedRowCountry.key
                    if selectedRowCountry.key == country_in{
                        if primaryDataHandler.inStatesArr == nil || primaryDataHandler.inStatesArr?.isEmpty == true{
                            if let stateView = view.viewWithTag(DEMOGRAPHICS_STATE_VIEW_TAG) as? AddModuleKeyAndValueView
                            {
                                stateView.textField.isUserInteractionEnabled = false
                            }
                            charmConnectionHandler?.fetchStates(countryCode: selectedRowCountry.key, identificationKey: "fetchStates")
                            showActivityIndicator()
                        }
                        else{
                            stateArr = primaryDataHandler.inStatesArr ?? []
                            setState(selectedRow: 0)
                        }
                    }
                    else if selectedRowCountry.key == country_us{
                        if primaryDataHandler.usStatesArr == nil || primaryDataHandler.usStatesArr?.isEmpty == true{
                            if let stateView = view.viewWithTag(DEMOGRAPHICS_STATE_VIEW_TAG) as? AddModuleKeyAndValueView
                            {
                                stateView.textField.isUserInteractionEnabled = false
                            }
                            charmConnectionHandler?.fetchStates(countryCode: selectedRowCountry.key, identificationKey: "fetchStates")
                            showActivityIndicator()
                        }
                        else{
                            stateArr = primaryDataHandler.usStatesArr ?? []
                            setState(selectedRow: 0)
                        }
                    }
                    else if selectedRowCountry.key == country_au
                    {
                        if primaryDataHandler.auStatesArr == nil || primaryDataHandler.auStatesArr?.isEmpty == true{
                            if let stateView = view.viewWithTag(DEMOGRAPHICS_STATE_VIEW_TAG) as? AddModuleKeyAndValueView
                            {
                                stateView.textField.isUserInteractionEnabled = false
                            }
                            charmConnectionHandler?.fetchStates(countryCode: selectedRowCountry.key, identificationKey: "fetchStates")
                            showActivityIndicator()
                        }
                        else{
                            stateArr = primaryDataHandler.auStatesArr ?? []
                            setState(selectedRow: 0)
                        }
                    }else
                    {
                        stateArr = []
                        if let stateView = view.viewWithTag(DEMOGRAPHICS_STATE_VIEW_TAG) as? AddModuleKeyAndValueView
                        {
                            stateView.textField.text = ""
                            stateView.textField.isUserInteractionEnabled = true
                        }
                    }
                    addModuleKeyAndValueView.valueLabel.text = selectedRowCountry.value
                    if let postalCodeView = view.viewWithTag(DEMOGRAPHICS_POSTALCODE_VIEW_TAG) as? AddModuleKeyAndValueView {
                        if selectedRowCountry.key == country_us {
                            postalCodeView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.zipCode.title")
                            postalCodeView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.zipCode.title")
                            postalCodeView.textField.maxLength = 5
                        } else {
                            postalCodeView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.postalCode.title")
                            postalCodeView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
                            
                            if selectedRowCountry.key == country_in {
                                postalCodeView.textField.maxLength = 6
                            }
                            else{
                                postalCodeView.textField.maxLength = ADDRESS_POSTAL_CODE_SIZE
                            }
                        }
                    }
                }
            }
        }
    }

    func setState(selectedRow : Int)
    {
        if let addModuleKeyAndValueView = view.viewWithTag(DEMOGRAPHICS_STATE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addModuleKeyAndValueView.textField.text = stateArr[selectedRow]
        }
    }
    
    func fillvalues(demographics : Patient)
    {
        let firstNameView = self.view.viewWithTag(DEMOGRAPHICS_FIRSTNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let lastNameView = self.view.viewWithTag(DEMOGRAPHICS_LASTNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let addressLine1 = self.view.viewWithTag(DEMOGRAPHICS_ADDRESSLINE1_VIEW_TAG) as! AddModuleKeyAndValueView
        let addressLine2 = self.view.viewWithTag(DEMOGRAPHICS_ADDRESSLINE2_VIEW_TAG) as! AddModuleKeyAndValueView
        let countryView = self.view.viewWithTag(DEMOGRAPHICS_COUNTRY_VIEW_TAG) as! AddModuleKeyAndValueView
        let stateView = self.view.viewWithTag(DEMOGRAPHICS_STATE_VIEW_TAG) as! AddModuleKeyAndValueView
        let cityView = self.view.viewWithTag(DEMOGRAPHICS_CITY_VIEW_TAG) as! AddModuleKeyAndValueView
        let homePhoneView = self.view.viewWithTag(DEMOGRAPHICS_HOMEPHONE_VIEW_TAG) as! AddModuleKeyAndValueView
        let mobilePhoneView = self.view.viewWithTag(DEMOGRAPHICS_MOBILEPHONE_VIEW_TAG) as! AddModuleKeyAndValueView
        let careGiverNameView = self.view.viewWithTag(DEMOGRAPHICS_CAREGIVERNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let careGiverPhoneView = self.view.viewWithTag(DEMOGRAPHICS_CAREGIVERPHONE_VIEW_TAG) as! AddModuleKeyAndValueView
        let contactNameView = self.view.viewWithTag(DEMOGRAPHICS_CONTACTNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let contactNumberView = self.view.viewWithTag(DEMOGRAPHICS_CONTACTNUMBER_VIEW_TAG) as! AddModuleKeyAndValueView
        
        firstNameView.textField.text = demographics.firstName ?? ""
        lastNameView.textField.text = demographics.lastName ?? ""
        addressLine1.textField.text = demographics.postalAddress?.line1 ?? ""
        addressLine2.textField.text = demographics.postalAddress?.line2 ?? ""
        cityView.textField.text = demographics.postalAddress?.city ?? ""
        let postalCodeView = self.view.viewWithTag(DEMOGRAPHICS_POSTALCODE_VIEW_TAG) as! AddModuleKeyAndValueView
        postalCodeView.textField.text = demographics.postalAddress?.postalCode ?? ""
        homePhoneView.textField.text = demographics.contactDetail?.landline ?? ""
        mobilePhoneView.textField.text = demographics.contactDetail?.mobile ?? ""
        
        careGiverNameView.textField.text = demographics.primaryCaregiver?.firstName ?? ""
        careGiverPhoneView.textField.text = demographics.primaryCaregiver?.mobile ?? ""
        contactNameView.textField.text = demographics.emergencyContactName ?? ""
        contactNumberView.textField.text = demographics.emergencyContactNumber  ?? ""
        
        stateView.textField.text = demographics.postalAddress?.state  ?? ""
        
        setDateOfBirth(date: demographics.dateOfBirth ?? Date())
        if let indexOfBirthSex = primaryDataHandler.birthSexArr?.firstIndex(of: demographics.gender.capitalizingFirstLetter())
        {
            setBirthSex(selectedRow: indexOfBirthSex)
        }
        if let indexOfBloodGroup = primaryDataHandler.bloodGroupArr?.firstIndex(of: demographics.bloodGroup ?? "")
        {
            setBloodGroup(selectedRow: indexOfBloodGroup)
        }
        
        let countryStr = demographics.postalAddress?.country

        if !countryStr.isNilOrBlank(){
            if let country = primaryDataHandler.countriesArr?.first(where: { dataWithId in
                return dataWithId.key == countryStr
            })
            {
                countryView.valueLabel.text = country.value
                countryKey = country.key
                if countryKey == country_us {
                    postalCodeView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.zipCode.title")
                    postalCodeView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.zipCode.title")
                } else {
                    postalCodeView.keyLabel.text = getString(key: "com.charmphr.EditDemographics.postalCode.title")
                    postalCodeView.textField.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
                }
                if countryKey == country_in{
                    if primaryDataHandler.inStatesArr == nil || primaryDataHandler.inStatesArr?.isEmpty == true{
                        stateView.textField.isUserInteractionEnabled = false
                        charmConnectionHandler?.fetchStates(countryCode: countryKey, identificationKey: "fetchStatesToFill")
                        showActivityIndicator()
                    }
                    else{
                        stateArr = primaryDataHandler.inStatesArr ?? []
                    }
                }
                else if countryKey == country_us{
                    if primaryDataHandler.usStatesArr == nil || primaryDataHandler.usStatesArr?.isEmpty == true{
                        stateView.textField.isUserInteractionEnabled = false
                        charmConnectionHandler?.fetchStates(countryCode: countryKey, identificationKey: "fetchStatesToFill")
                        showActivityIndicator()
                    }
                    else{
                        stateArr = primaryDataHandler.usStatesArr ?? []
                    }
                }
                else if countryKey == country_au
                {
                    if primaryDataHandler.auStatesArr == nil || primaryDataHandler.auStatesArr?.isEmpty == true{
                        stateView.textField.isUserInteractionEnabled = false
                        charmConnectionHandler?.fetchStates(countryCode: countryKey, identificationKey: "fetchStatesToFill")
                        showActivityIndicator()
                    }
                    else{
                        stateArr = primaryDataHandler.auStatesArr ?? []
                    }
                }else
                {
                    stateArr = []
                    stateView.textField.isUserInteractionEnabled = true
                }
            }else{
                stateArr = []
                stateView.textField.isUserInteractionEnabled = true
            }
            
        }
        else{
            stateArr = []
            stateView.textField.isUserInteractionEnabled = true
        }
        
        
    }

    func primaryDataHandlerDidReceiveData() {
        charmConnectionHandler?.fetchDemographics(patientId: getSelectedPatientId(), identificationKey: "fetchDemographics")
    }
    
    func primaryDataHandlerDidReceiveError(error:Error) {
        hideActivityIndicator()
        CharmUtil.createRetryAndCancelAlertWith(error: error) {
            self.showActivityIndicator()
            self.primaryDataHandler.fetchPrimaryData()
        }
    }
    
    //MARK: - navigation
    func navigateToSelectValueVC()
    {
        let vc = SelectValueViewController()
        vc.delegate = self
        if selectedAddModuleKeyAndLabelView != nil
        {
            vc.title = selectedAddModuleKeyAndLabelView!.keyLabel.text
            
            if selectedAddModuleKeyAndLabelView!.tag == DEMOGRAPHICS_BLOODGROUP_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = primaryDataHandler.bloodGroupArr ?? []
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView!.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView!.tag == DEMOGRAPHICS_BIRTHSEX_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = primaryDataHandler.birthSexArr ?? []
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView!.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView!.tag == DEMOGRAPHICS_COUNTRY_VIEW_TAG
            {
                vc.isSearchBarNeeded = true
                vc.arrayOfValueToBeShown = primaryDataHandler.countriesArr?.map({ dataWithId in
                    dataWithId.value
                }) as? [String] ?? []
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView!.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView!.tag == DEMOGRAPHICS_STATE_VIEW_TAG
            {
                vc.isSearchBarNeeded = true
                vc.arrayOfValueToBeShown = stateArr
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView!.valueLabel.text ?? "")
            }
            
        }
            
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Dismiss Modal View delegate
    func dismissModelView() {
        if let vc = self.presentedViewController {
            vc.dismiss(animated: false)
        }
    }
}
