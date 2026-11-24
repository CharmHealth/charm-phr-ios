//
//  PatInsuranceView.swift
//  phr
//
//  Created by prathi-13964 on 22/04/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

fileprivate let MDFLTEXTFIELD_HEIGHT: CGFloat = 60
fileprivate let BUTTON_HEIGHT_42: CGFloat = 42

protocol PatInsuranceViewDelegate: AnyObject{
    func getPatientDataForInsurance()
    func onPracticeSelected(index: Int)
}

class PatInsuranceView: UIStackView, UITextFieldDelegate, MDTextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var praticePickerView = UIPickerView()
    private var birthSexPickerView = UIPickerView()
    private var insuranceTypePickerView = UIPickerView()
    private var relationshipPickerView = UIPickerView()
    private var insuranceCategoryPickerView = UIPickerView()
        
    let patInsuranceMainView = UIStackView()
    private let payerAddressView = UIStackView()

    private let patInsuranceHeading = UILabel()
    private var hasMoreLayout: CommonQuestionnaireLayout? = nil

    private var tagNo = 783170701
    private let topSpace = UIView()
    private let bottomSpace = UIView()
    
    var insuranceCardView: InsuranceCardView? = nil

    var hasMoreYesBtn: UIButton?
    var hasMoreNoBtn: UIButton?

//    private var practiceNameTF: MDFLTextField?
//    private let msgLabel = UILabel()
    var payerNameTF: MDFLTextField?
    var payerIdTF: MDFLTextField?
    private var insuranceTypeTF: MDFLTextField?
    private var insuranceIdTF: MDFLTextField?
    private var planNameTF: MDFLTextField?
    private var policyGrpTF: MDFLTextField?
    private var empNameTF: MDFLTextField?
    
    private let insuranceCategoryView = UIView()
    private let insuranceCategoryLabel = UILabel()
    private var primaryBtn: UIButton?
    private var secondaryBtn: UIButton?
    
    private var relationshipTF: MDFLTextField?
    private var firstNameMDTF : MDFLTextField?
    private var lastNameMDTF : MDFLTextField?
    private var dobMDTF : MDFLTextField?
    private var birthSexMDTF : MDFLTextField?
    
    private var sameAddressBtn: UIButton?
    
    private var line1MDTF: MDFLTextField?
    private var line2MDTF: MDFLTextField?
    private var cityMDTF: MDFLTextField?
    var countryMDTF: MDFLTextField?
    var stateMDTF: MDFLTextField?
    private var postalCodeMDTF: MDFLTextField?
    private var homePhoneMDTF : MDFLTextField?
    private var mobilePhoneMDTF : MDFLTextField?

    private var validFromMDTF: MDFLTextField?
    private var validToMDTF: MDFLTextField?
    private var copayMDTF: MDFLTextField?
    private var deductableMDTF: MDFLTextField?
    
    private var commentsTF: MDTextView?
    
    private var payerLine1MDTF: MDFLTextField?
    private var payerCityMDTF: MDFLTextField?
    var payerCountryMDTF: MDFLTextField?
    var payerStateMDTF: MDFLTextField?
    private var payerPostalCodeMDTF: MDFLTextField?
    
    var patient: Patient?
    private var insuranceCommonData: InsuranceCommonData?
    private var isQuestionnaireInsurance: Bool = false

    private var validFromDatePicker = UIDatePicker()
    private var validToDatePicker = UIDatePicker()
    private let relationDOBDatepicker = UIDatePicker()

    private let primaryDataHandler = PrimaryDataHandler.sharedInstance
    var practiceList: [String] = []
    
    weak var delegate: PatInsuranceViewDelegate?
    private var insuranceCategory: String = ""
    private var selectedInsuranceCompany: PracticePayer? = nil
        
    private var isPatient = false
    private var viewWidth:CGFloat = 0
    private var addShadow = true
    
    private var selectedPraticeIndex: Int = 0
    private var selectedBirthSexIndex: Int = 0
    private var selectedInsuranceTypeIndex: Int = 0
    private var selectedRelationshipIndex: Int = 0

//MARK: - init
    
    init(insurance: PatientInsuranceDetails? = nil, insuranceCommonData: InsuranceCommonData?, width: CGFloat = applicationFrame.width, addShadow: Bool = true, isQuestionnaireInsurance: Bool){
        super.init(frame: .zero)
        
        self.insuranceCommonData = insuranceCommonData
        self.viewWidth = width
        self.addShadow = addShadow
        self.isQuestionnaireInsurance = isQuestionnaireInsurance
        self.backgroundColor = .clear
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.spacing = 10
        self.alignment = .center
        
        hasMoreLayout = CommonQuestionnaireLayout(notes: getString(key: "com.charmphr.insurance.add.hasInsurance.txt"), addShadow: addShadow)
        
        patInsuranceMainView.translatesAutoresizingMaskIntoConstraints = false
        patInsuranceMainView.axis = .vertical
        patInsuranceMainView.spacing = 10
        patInsuranceMainView.alignment = .fill
        
        praticePickerView.delegate = self
        praticePickerView.dataSource = self
        
        birthSexPickerView.delegate = self
        birthSexPickerView.dataSource = self
        
        insuranceTypePickerView.delegate = self
        insuranceTypePickerView.dataSource = self
        
        insuranceCategoryPickerView.delegate = self
        insuranceCategoryPickerView.dataSource = self
        
        relationshipPickerView.delegate = self
        relationshipPickerView.dataSource = self
        
        addArrangedSubview(patInsuranceHeading)
        
        if let hasMoreLayout = hasMoreLayout {
            addArrangedSubview(hasMoreLayout)
            getOption(isYes: true, hasMoreLayout: hasMoreLayout)
            getOption(isYes: false, hasMoreLayout: hasMoreLayout)
        }
        
        addArrangedSubview(topSpace)
        

//        practiceNameTF = getMDFLTextField(keyStr: "com.charmphr.insurance.practiceName.hint")
//        if let practiceNameTF = practiceNameTF{
//            practiceNameTF.inputView = praticePickerView
//            
//            if let tfView = practiceNameTF.superview{
//                tfView.removeFromSuperview()
//                tfView.removeConstraints()
//                self.addArrangedSubview(tfView)
//                tfView.addSubview(practiceNameTF)
//                
//                practiceNameTF.setLeft(offSet: PADDING)
//                practiceNameTF.setRight(offSet: -PADDING)
//                practiceNameTF.setCenterY()
//                
//                tfView.setWidth(constant: viewWidth - (2 * X_SPACE))
//                tfView.setHeight(constant: MDFLTEXTFIELD_HEIGHT)
//            }
//        }
//        practiceNameTF?.superview?.isHidden = true
//        practiceNameTF?.isMandatoryField = true
        
//        self.addArrangedSubview(msgLabel)
//        msgLabel.addShadowAndCornerRadius()
//        msgLabel.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
//        msgLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
//        msgLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
//        msgLabel.textAlignment = .center
//        msgLabel.text = getString(key: "com.charmphr.appointments.practice.select_info")
//        msgLabel.isHidden = true
//        
//        msgLabel.setWidth(constant: viewWidth - (2 * X_SPACE))
//        msgLabel.setHeight(constant: 50)
        
        self.addArrangedSubview(patInsuranceMainView)
        
        insuranceTypeTF = getMDFLTextField(keyStr: "com.charmphr.insurance.add.type.label")
        insuranceTypeTF?.isMandatoryField = true
        insuranceTypeTF?.maxLength = INSURANCE_TYPE_SIZE
        
        planNameTF = getMDFLTextField(keyStr: "")
        planNameTF?.maxLength = INSURANCE_PLAN_NAME_SIZE
        
        insuranceIdTF = getMDFLTextField(keyStr: "com.charmphr.insurance.add.memberId.label")
        insuranceIdTF?.maxLength = INSURANCE_ID_SIZE
        insuranceIdTF?.isMandatoryField = true
        
        payerNameTF =  getMDFLTextField(keyStr: "")
        payerNameTF?.isMandatoryField = true
        payerNameTF?.maxLength = INSURANCE_PAYER_NAME_SIZE
        
        if isQuestionnaireInsurance{
            if insurance?.isAddNewPayerAllowed == true{
                payerIdTF = getMDFLTextField(keyStr: "com.charmphr.insurance.add.payerId.label")
                payerIdTF?.maxLength = INSURANCE_PAYER_ID_SIZE
            }
        }
        else{
            payerIdTF = getMDFLTextField(keyStr: "com.charmphr.insurance.add.payerId.label")
            payerIdTF?.maxLength = INSURANCE_PAYER_ID_SIZE
        }
        
        patInsuranceMainView.addArrangedSubview(insuranceCategoryView)
        insuranceCategoryView.addShadowAndCornerRadius(.SMALL)
        insuranceCategoryView.isHidden = true
        
        insuranceCategoryView.addSubview(insuranceCategoryLabel)
        
        insuranceCategoryLabel.setProperties(textKey: "com.charmphr.insurance.type.hint", fontsize: FONT_SIZE_MEDIUM, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
        insuranceCategoryLabel.makeMandatory()
        
        insuranceCategoryLabel.setLeft(offSet: PADDING)
        insuranceCategoryLabel.setRight(offSet: 0)
        insuranceCategoryLabel.setTop(offSet: PADDING)
        
        let primaryBtnArr = getInsuranceCategoryBtn(buttonTitle: "Primary")
        let secondrayBtnArr = getInsuranceCategoryBtn(buttonTitle: "Secondary")
        primaryBtn = primaryBtnArr.first as? UIButton
        secondaryBtn = secondrayBtnArr.first as? UIButton
        
        if let primaryBtnView = primaryBtnArr.last as? UIView, let secondaryBtnView = secondrayBtnArr.last as? UIView{
            
            insuranceCategoryView.addSubview(primaryBtnView)
            
            primaryBtnView.setLeft(offSet: CARD_PADDING)
            primaryBtnView.setTopRelatedToView(offSet: 10, relatedView: insuranceCategoryLabel, relatedAttribute: .bottom)
            primaryBtnView.setBottom(offSet: -10)
            primaryBtnView.setHeight(constant: 24)
            primaryBtnView.setWidth(constant: ((viewWidth - (2 * X_SPACE)) / 2) - CARD_PADDING)
            
            insuranceCategoryView.addSubview(secondaryBtnView)
            
            secondaryBtnView.setLeftRelatedToView(offSet: 10, relatedView: primaryBtnView, relatedAttribute: .right)
            secondaryBtnView.setTopRelatedToView(offSet: 10, relatedView: insuranceCategoryLabel, relatedAttribute: .bottom)
            secondaryBtnView.setBottom(offSet: -10)
            secondaryBtnView.setHeight(constant: 24)
            secondaryBtnView.setWidth(constant: (viewWidth - (2 * X_SPACE)) / 2)
        }
        
        validFromMDTF = getMDFLTextField(keyStr: "com.charmphr.insurance.add.validFrom.label")
        validFromMDTF?.inputView = validFromDatePicker
        
        validFromDatePicker.preferredDatePickerStyle = .wheels
        validFromDatePicker.datePickerMode = .date
        validFromDatePicker.addTarget(self, action: #selector(datePickerValidFromValueChanged(datePicker:)), for: .valueChanged)
        
        validToMDTF = getMDFLTextField(keyStr: "com.charmphr.insurance.add.validTo.label")
        validToMDTF?.inputView = validToDatePicker
        
        validToDatePicker.preferredDatePickerStyle = .wheels
        validToDatePicker.datePickerMode = .date
        validToDatePicker.addTarget(self, action: #selector(datePickerValidToValueChanged(datePicker:)), for: .valueChanged)
        
        policyGrpTF =  getMDFLTextField(keyStr: "com.charmphr.insuranceList.policyGrp.label")
        policyGrpTF?.maxLength = INSURANCE_POLICY_GROUP_SIZE
        
        copayMDTF = getMDFLTextField(keyStr: "com.charmphr.insurance.add.copay.label")
        copayMDTF?.keyboardType = .decimalPad
        copayMDTF?.maxLength = INSURANCE_COPAY_SIZE
        
        deductableMDTF = getMDFLTextField(keyStr: "com.charmphr.insurance.add.deductable.label")
        deductableMDTF?.keyboardType = .decimalPad
        deductableMDTF?.maxLength = INSURANCE_DEDUCTIBLE_SIZE
        
        empNameTF =  getMDFLTextField(keyStr: "com.charmphr.insurance.add.empName.label")
        empNameTF?.maxLength = INSURANCE_EMPLOYER_NAME_SIZE
        
        
        if !isQuestionnaireInsurance{
            patInsuranceMainView.addArrangedSubview(payerAddressView)
            
            payerAddressView.translatesAutoresizingMaskIntoConstraints = false
            payerAddressView.axis = .vertical
            payerAddressView.spacing = 10
            payerAddressView.alignment = .fill
            
            
            let payerAddressHeading = UILabel()
            payerAddressView.addArrangedSubview(payerAddressHeading)
            
            payerAddressHeading.setProperties(textKey: "com.charmphr.insurance.add.payerAddress.label", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
            
            payerAddressHeading.setWidth(constant: viewWidth - (2*X_SPACE))
            
            payerLine1MDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.ADDRESSLINE1.title" , parentView: payerAddressView)
            payerLine1MDTF?.maxLength = ADDRESS_LINE_1_SIZE
            
            
            payerCityMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.City.title", parentView: payerAddressView)
            payerCityMDTF?.maxLength = PAYER_CITY_SIZE
            
            payerCountryMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.Country.title", parentView: payerAddressView)
            
            payerStateMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.State.title", parentView: payerAddressView)
            payerStateMDTF?.maxLength = PAYER_STATE_SIZE
            
            payerPostalCodeMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.zipCode.title", parentView: payerAddressView)
            payerPostalCodeMDTF?.maxLength = ADDRESS_POSTAL_CODE_SIZE
            payerPostalCodeMDTF?.keyboardType = .numberPad
        }

        let insuredPersonDetailsHeading = UILabel()
        patInsuranceMainView.addArrangedSubview(insuredPersonDetailsHeading)
        
        relationshipTF =  getMDFLTextField(keyStr: "com.charmphr.insurance.add.relationship.label")
        if let relationshipTF = relationshipTF{
            relationshipTF.inputView = relationshipPickerView
            relationshipTF.isMandatoryField = true
        }
        
        firstNameMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.FirstName.title")
        firstNameMDTF?.isMandatoryField = true
        firstNameMDTF?.maxLength = FIRST_NAME_SIZE
        
        lastNameMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.LastName.title")
        lastNameMDTF?.isMandatoryField = true
        lastNameMDTF?.maxLength = LAST_NAME_SIZE

        
        relationDOBDatepicker.preferredDatePickerStyle = .wheels
        relationDOBDatepicker.datePickerMode = .date
        relationDOBDatepicker.maximumDate = Date()
        relationDOBDatepicker.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        
        dobMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.DateOfBirth.title")
        dobMDTF?.isMandatoryField = true
        dobMDTF?.inputView = relationDOBDatepicker
                
        birthSexMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.BirthSex.title")
        if let birthSexMDTF = birthSexMDTF{
            birthSexMDTF.inputView = birthSexPickerView
            birthSexMDTF.isMandatoryField = true
        }
        
        sameAddressBtn = getAddressCheckbox()
        
        line1MDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.ADDRESSLINE1.title")
        line1MDTF?.maxLength = INSURED_PERSON_ADDRESS_LINE1
        
        line2MDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.ADDRESSLINE2.title")
        line2MDTF?.maxLength = INSURED_PERSON_ADDRESS_LINE2
        
        cityMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.City.title")
        cityMDTF?.maxLength = ADDRESS_CITY_SIZE

        countryMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.Country.title")

        stateMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.State.title")
        stateMDTF?.maxLength = ADDRESS_STATE_SIZE

        postalCodeMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.zipCode.title")
        postalCodeMDTF?.maxLength = ADDRESS_POSTAL_CODE_SIZE
        postalCodeMDTF?.keyboardType = .numberPad
      
        homePhoneMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.HomePhone.title")
        homePhoneMDTF?.keyboardType = .numberPad
        homePhoneMDTF?.maxLength = CONTACT_NUMBER_SIZE
        
        mobilePhoneMDTF = getMDFLTextField(keyStr: "com.charmphr.EditDemographics.MobilePhone.title")
        mobilePhoneMDTF?.keyboardType = .numberPad
        mobilePhoneMDTF?.maxLength = CONTACT_NUMBER_SIZE
        
        commentsTF = getCommentsTextView()
        commentsTF?.maxLength = INSURANCE_COMMENTS_SIZE
        
        addArrangedSubview(bottomSpace)
        
        patInsuranceHeading.setProperties(textKey: "com.charmphr.questionnairevc.insurance.title", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        insuredPersonDetailsHeading.setProperties(textKey: "com.charmphr.insurance.add.personDetail.label", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        let fromtoolbar =  MDDateToolbarWithDone(textField: self.validFromMDTF , parent: self)
        let totoolbar = MDDateToolbarWithDone(textField: self.validToMDTF, parent: self)
        let dobtoolbar = MDDateToolbarWithDone(textField: self.dobMDTF, parent: self)

        fromtoolbar.done?.action = #selector(donedatePicker)
        totoolbar.done?.action = #selector(donedatePicker)
        dobtoolbar.done?.action = #selector(donedatePicker)
        
        patInsuranceHeading.setWidth(constant: viewWidth - (2*X_SPACE))
        
        topSpace.setWidth(constant: viewWidth)
        topSpace.setHeight(constant: CARD_PADDING)
        
        topSpace.isHidden = true
        
        bottomSpace.setWidth(constant: viewWidth)
        bottomSpace.setHeight(constant: CARD_PADDING)
        bottomSpace.isHidden = true
        
        hasMoreLayout?.setWidth(constant: viewWidth - (2*X_SPACE))
        patInsuranceMainView.setWidth(constant: viewWidth - (2*X_SPACE))
        
        if isQuestionnaireInsurance{
            
            insuranceTypeTF?.inputView = insuranceTypePickerView
            
            planNameTF?.placeholder = getString(key: "com.charmphr.insuranceList.questionnaire.insurance.plan.label")
            payerNameTF?.placeholder = getString(key: "com.charmphr.insurance.questionnaire.payerName.label")
            
            planNameTF?.isMandatoryField = false
            policyGrpTF?.isMandatoryField = true
        }
        else{
            if insuranceCommonData?.isUSUser == true{
                insuranceTypeTF?.inputView = insuranceTypePickerView
            }
            
            planNameTF?.placeholder = getString(key: "com.charmphr.insuranceList.plan.label")
            payerNameTF?.placeholder = getString(key: "com.charmphr.insurance.add.payerName.label")
            
            planNameTF?.isMandatoryField = true
            policyGrpTF?.isMandatoryField = false
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setInsuranceCompanyDetails(payer: PracticePayer){
        selectedInsuranceCompany = payer
        
        payerNameTF?.text = payer.payerName
        payerIdTF?.text = payer.payerId

        if let postalAddress = payer.postalAddress, !isQuestionnaireInsurance{
            
            payerLine1MDTF?.text = postalAddress.line1
            payerCityMDTF?.text = postalAddress.city
            
            if let country = postalAddress.country {
                if let countryVal = primaryDataHandler.countriesArr?.first(where: { (countryEntry) -> Bool in
                    return countryEntry.key == country
                }) {
                    payerCountryMDTF?.text = countryVal.value
                }
            }
            onPayerCountryChange()
                                    
            payerStateMDTF?.text = postalAddress.state
            payerPostalCodeMDTF?.text = postalAddress.postalCode
        }
    }
    
//MARK: - Show and Hide PracticeView
    
//    func showPracticeView(){
//        practiceNameTF?.superview?.isHidden = false
//        msgLabel.isHidden = false
//        patInsuranceMainView.isHidden = true
//    }
//    
//    private func hideErrorMsgLabel(){
//        msgLabel.isHidden = true
//        patInsuranceMainView.isHidden = false
//        self.endEditing(true)
//    }
    
//MARK: - Get InsuranceCategoryBtn
    
    private func getInsuranceCategoryBtn(buttonTitle: String) -> [Any]{
        
        let btnView = UIView()
        
        btnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapInsuranceCategoryView)))
        
        let button = UIButton()
        button.setImage(UIImage(named: "RadioBtnUnselected"), for: .normal)
        button.setImage(UIImage(named: "RadioBtnSelected"), for: .selected)
        button.setProperties(titleStrKey: buttonTitle, fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        button.tag = tagNo
        tagNo += 1
        button.setInsets(imageTitlePadding: 5)
        button.addTarget(self, action: #selector(onClickInsuranceCategoryBtn), for: .touchUpInside)
        
        btnView.addSubview(button)
        
        button.setLeft(offSet: 0)
        button.setTop(offSet: 0)
        button.setBottom(offSet: 0)
        button.setHeight(constant: BTN_SIZE_24)
        
        return [button,btnView]
    }
    
//MARK: - Get AddressCheckbox
    
    private func getAddressCheckbox() -> UIButton {
        let optionBtn = UIButton(type: .custom)
        
        optionBtn.setTitle(getString(key: "com.charmphr.insurance.add.sameAddress.label"), for: .normal)
        optionBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        optionBtn.setTitleColor(.black, for: .normal)
        optionBtn.addTarget(self, action: #selector(sameAddressBtnClicked(btn:)), for: .touchUpInside)
        
        optionBtn.setImage(#imageLiteral(resourceName: "CheckboxUnselected"), for: .normal)
        optionBtn.setImage(#imageLiteral(resourceName: "CheckboxSelected"), for: .selected)
        
        patInsuranceMainView.addArrangedSubview(optionBtn)
        optionBtn.setHeight(constant: 44)
        
        optionBtn.contentHorizontalAlignment = .left
        
        optionBtn.setPadding(vertical: 10, horizontal: 0)
        optionBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        optionBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        optionBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10)
        
        return optionBtn
    }
    
//MARK: - Get CommentsTextView
    
    private func getCommentsTextView() -> MDTextView {
        
        let commentLayout = UIView()
        if addShadow {
            commentLayout.addShadowAndCornerRadius(.SMALL)
        }
        else{
            commentLayout.addCornerRadius(.SMALL)
            commentLayout.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
            commentLayout.layer.borderWidth = 1
        }
        commentLayout.backgroundColor = .white
        
        let commentLabel = UILabel()
        commentLabel.text = getString(key: "com.charmphr.insurance.add.comment.label")
        commentLabel.numberOfLines = 0
        commentLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        commentLabel.setTextColor(fontcolor: TEXT_COLOR_BLACK87)
        
        let commentTextView = MDTextView()
        commentTextView.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
    
        commentTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        commentTextView.isScrollEnabled = false

        commentLayout.addSubview(commentLabel)
        commentLayout.addSubview(commentTextView)
        patInsuranceMainView.addArrangedSubview(commentLayout)
        
        commentLabel.setTop(offSet: CARD_PADDING)
        commentLabel.setLeft(offSet: PADDING)
        commentLabel.setRight(offSet: -PADDING)
        
        commentTextView.setTopRelatedToView(offSet: PADDING, relatedView: commentLabel, relatedAttribute: .bottom)
        commentTextView.setLeft(offSet: 2)
        commentTextView.setRight(offSet: -PADDING)
        commentTextView.setBottom(offSet: -PADDING)
        commentTextView.setHeight(constant: 27, relatedBy: .greaterThanOrEqual)
                
        return commentTextView
    }
    
//MARK: - Get MDFLTextField
    
    private func getMDFLTextField(keyStr:String, parentView: UIStackView? = nil) -> MDFLTextField
    {
        let tfView = UIView()
        let tf = MDFLTextField()
        tf.placeholder = getString(key: keyStr)
        tf.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .regular)
        tf.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.delegate = self
        tf.floatingLabelFont = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        tf.floatingLabelTextColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
        tf.floatingLabelActiveTextColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        tf.placeholderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
        
        tfView.addSubview(tf)
        tf.setLeft(offSet: PADDING)
        tf.setRight(offSet: -PADDING)
        tf.setCenterY()
        
        tf.clearButtonMode = .whileEditing

        if let parentView = parentView {
            parentView.addArrangedSubview(tfView)
        }
        else{
            patInsuranceMainView.addArrangedSubview(tfView)
        }
        tfView.setHeight(constant: MDFLTEXTFIELD_HEIGHT)
        
        tfView.backgroundColor = UIColor.white
        
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
    
//MARK: - Get Option
    
    private func getOption(isYes: Bool , hasMoreLayout: CommonQuestionnaireLayout)  {
        let optionBtn = UIButton(type: .custom)
        
        if isYes {
            optionBtn.setTitle("Yes", for: .normal)
            hasMoreYesBtn = optionBtn
        }
        else{
            hasMoreNoBtn = optionBtn
            optionBtn.setTitle("No", for: .normal)
        }
        optionBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        optionBtn.setTitleColor(.black, for: .normal)
        optionBtn.addTarget(self, action: #selector(optionBtbClicked(btn:)), for: .touchUpInside)
        
        optionBtn.setImage(#imageLiteral(resourceName: "RadioBtnUnselected"), for: .normal)
        optionBtn.setImage(#imageLiteral(resourceName: "RadioBtnSelected"), for: .selected)
        
        hasMoreLayout.commonQuestionnaireMainLayout.addSubview(optionBtn)
        optionBtn.setHeight(constant: BTN_SIZE_24)
        optionBtn.setTop(offSet: 15)
        optionBtn.setBottom(offSet: -15)
        optionBtn.setWidth(constant:80)

        if isYes {
            optionBtn.setLeft(offSet: 20)
        }
        else{
            optionBtn.setLeftRelatedToView(offSet: 20, relatedView: hasMoreYesBtn!, relatedAttribute: .right)
        }
        optionBtn.contentHorizontalAlignment = .left
        
        optionBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        optionBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
//MARK: - Action calls
    
    @objc private func datePickerValueChanged(datePicker : UIDatePicker)
    {
        dobMDTF?.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
    }
    
    @objc private func datePickerValidFromValueChanged(datePicker : UIDatePicker)
    {
        validFromMDTF?.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
    }
    
    @objc private func datePickerValidToValueChanged(datePicker : UIDatePicker)
    {
        validToMDTF?.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
    }
    
    @objc private func optionBtbClicked(btn: UIButton)
    {
        btn.isSelected = true
        
        if btn != hasMoreYesBtn {
            hasMoreYesBtn?.isSelected = false
            patInsuranceMainView.isHidden = true
        }
        else{
            patInsuranceMainView.isHidden = false
            hasMoreNoBtn?.isSelected = false
        }
    }
    
    @objc private func onTapInsuranceCategoryView(_ sender: UITapGestureRecognizer){
        
        if let view = sender.view, let btn = view.subviews.first as? UIButton{
            onClickInsuranceCategoryBtn(btn)
        }
    }
    
    @objc private func onClickInsuranceCategoryBtn(_ btn: UIButton){
        
        btn.isSelected = true
        
        if btn.currentTitle?.lowercased() == insuranceTypePrimary.lowercased(){
            insuranceCategory = insuranceTypePrimary
        }
        else if btn.currentTitle?.lowercased() == insuranceTypeSecondary.lowercased(){
            insuranceCategory = insuranceTypeSecondary
        }
        for view in insuranceCategoryView.subviews
        {
            if !(view is UILabel), let otherBtn = view.subviews.first as? UIButton{
                if otherBtn.tag != btn.tag {
                    otherBtn.isSelected = false
                }
            }
        }
    }
    
    @objc private func sameAddressBtnClicked(btn: UIButton){
        
        btn.isSelected = !btn.isSelected
        
        setInsuredAddressFieldsEnableStatus(isChecked: btn.isSelected)
        setInsuredAddressDetails(isSelf: btn.isSelected)
    }
    
    @objc private func donedatePicker(_ barItem: UIBarItem){
        var textField = validFromMDTF
        
        if validToMDTF?.isFirstResponder == true {
            textField = validToMDTF
        }
        else if dobMDTF?.isFirstResponder == true {
            textField = dobMDTF
        }
        if let textField = textField {
            if let datePicker = textField.inputView as? UIDatePicker{
                textField.text = datePicker.date.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                self.endEditing(true)
            }
        }
    }
    
    @objc private func dismissKeyboard(){
        setPickerSelectedValueText()
        self.endEditing(true)
    }
    
//MARK: - PickerView Delegate and Data source methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if birthSexMDTF?.isFirstResponder == true
        {
            return primaryDataHandler.birthSexArr?.count ?? 0
        }
        else if insuranceTypeTF?.isFirstResponder == true{
            return insuranceCommonData?.insuranceTypes.count ?? 0
        }
        else if relationshipTF?.isFirstResponder == true {
            return insuranceCommonData?.relationships.count ?? 0
        }
//        else if practiceNameTF?.isFirstResponder == true {
//            return practiceList.count
//        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if birthSexMDTF!.isFirstResponder
        {
            return primaryDataHandler.birthSexArr?[row]
        }
        else if insuranceTypeTF!.isFirstResponder {
            return insuranceCommonData?.insuranceTypes[row]
        }
        else if relationshipTF!.isFirstResponder {
            return insuranceCommonData?.relationships[row]
        }
//        else if practiceNameTF!.isFirstResponder {
//            return practiceList[row]
//        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(self.birthSexMDTF!.isFirstResponder){
            selectedBirthSexIndex = row
        }
        else if self.insuranceTypeTF!.isFirstResponder {
            selectedInsuranceTypeIndex = row
        }
        else if self.relationshipTF!.isFirstResponder {
            selectedRelationshipIndex = row
        }
//        else if self.practiceNameTF!.isFirstResponder {
//            selectedPraticeIndex = row
//        }
        setPickerSelectedValueText()
    }
    
//MARK: - Set PickerSelectedValueText
    
    private func setPickerSelectedValueText(){
        if(self.birthSexMDTF!.isFirstResponder)
        {
            self.birthSexMDTF!.text = primaryDataHandler.birthSexArr?[selectedBirthSexIndex]
        }
        else if self.insuranceTypeTF!.isFirstResponder {
            let insuranceType = insuranceCommonData?.insuranceTypes[selectedInsuranceTypeIndex]
            let insuranceTypeChange =  onInsuranceTypeChange(insuranceType: insuranceType)
            
            if isQuestionnaireInsurance{
                if !insuranceTypeChange.planName.isNilOrBlank(){
                    self.planNameTF?.text = insuranceTypeChange.planName
                }
            }
            else{
                self.planNameTF?.text = insuranceTypeChange.planName
                self.insuranceIdTF?.placeholder = insuranceTypeChange.memberIdLabel
            }
            self.insuranceTypeTF!.text = insuranceType
        }
        else if self.relationshipTF!.isFirstResponder {
            self.relationshipTF!.text = insuranceCommonData?.relationships[selectedRelationshipIndex]
            onRelationshipChange(isSelf: selectedRelationshipIndex == 0)
            sameAddressBtn?.isSelected = false
            setInsuredAddressFieldsEnableStatus(isChecked: false)
        }
//        else if self.practiceNameTF!.isFirstResponder {
//            self.practiceNameTF?.text = practiceList[selectedPraticeIndex]
//            delegate?.onPracticeSelected(index: selectedPraticeIndex)
//            hideErrorMsgLabel()
//        }
    }
    
//MARK: - Set Add and Edit InsuranceView
        
    func setEditInsuranceView(){
        payerNameTF?.isEnableTF(false)
        payerIdTF?.isEnableTF(false)
        planNameTF?.isEnableTF(false)
        insuranceTypeTF?.isEnableTF(false)
        insuranceIdTF?.isEnableTF(false)
        policyGrpTF?.isEnableTF(false)
        copayMDTF?.isEnableTF(false)
        deductableMDTF?.isEnableTF(false)
        empNameTF?.isEnableTF(false)
        relationshipTF?.isEnableTF(false)
        insuranceCategoryView.isHidden = false
    }
        
    func setAddInsuranceView(){
        topSpace.isHidden = false
        bottomSpace.isHidden = false
        hasMoreLayout?.isHidden = true
        patInsuranceHeading.isHidden = true
        insuranceCategoryView.isHidden = false
    }
    
//MARK: - TextField Delegate functions
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { // return NO to not change text

        if textField.keyboardType == .decimalPad {
            
            switch string {
            case "0","1","2","3","4","5","6","7","8","9":
                return true
            case ".":
                let array = Array(arrayLiteral: textField.text)
                var decimalCount = 0
                for character in array {
                    if character == "." {
                        decimalCount+=1
                    }
                }

                if decimalCount == 1 {
                    return false
                } else {
                    return true
                }
            default:
                let array = Array(string)
                if array.count == 0 {
                    return true
                }
                return false
            }
        }
        return true
    }
    
    func onCountryChange(){
        
        let country = countryMDTF?.text ?? ""
        if country.lowercased() == INDIA {
            
            if postalCodeMDTF?.text?.count ?? 0 > 6{
                postalCodeMDTF?.text = postalCodeMDTF?.text?.truncate(length: 6)
            }
            postalCodeMDTF?.maxLength = 6
            postalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
            
            if let inStates = primaryDataHandler.inStatesArr, !inStates.isEmpty {
                
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
        }
        else if country.lowercased() == UNITED_STATES {
            
            if postalCodeMDTF?.text?.count ?? 0 > 5{
                postalCodeMDTF?.text = postalCodeMDTF?.text?.truncate(length: 5)
            }
            
            postalCodeMDTF?.maxLength = 5
            postalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.zipCode.title")
            
            if let usStates = primaryDataHandler.usStatesArr, !usStates.isEmpty {
                
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
        }
        else if  country.lowercased() == AUSTRALIA {
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
        }
        else{
            postalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
            postalCodeMDTF?.maxLength = 10
            stateMDTF?.text = ""
        }
    }
    
    func onPayerCountryChange(){
        
        
        let country = payerCountryMDTF?.text ?? ""
        if country.lowercased() == INDIA {
            
            payerPostalCodeMDTF?.text = ""
            payerPostalCodeMDTF?.maxLength = 6
            payerPostalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
            
            if let inStates = primaryDataHandler.inStatesArr, !inStates.isEmpty{
                
                let stateStr = payerStateMDTF?.text ?? ""
                
                if stateStr.isNotBlank() {
                    if inStates.first(where: { (state) -> Bool in
                        return state == stateStr
                    }) == nil
                    {
                        payerStateMDTF?.text = ""
                    }
                }
            }
        }
        else if country.lowercased() == UNITED_STATES {
            payerPostalCodeMDTF?.text = ""
            payerPostalCodeMDTF?.maxLength = 5
            payerPostalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.zipCode.title")
            
            if let usStates = primaryDataHandler.usStatesArr, !usStates.isEmpty {
                
                let stateStr = payerStateMDTF?.text ?? ""
                
                if stateStr.isNotBlank() {
                    if usStates.first(where: { (state) -> Bool in
                        return state == stateStr
                    }) == nil
                    {
                        payerStateMDTF?.text = ""
                    }
                }
            }
        }
        else if country.lowercased() == AUSTRALIA {
            payerPostalCodeMDTF?.text = ""
            payerPostalCodeMDTF?.maxLength = 10
            payerPostalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
            
            if let auStates = primaryDataHandler.auStatesArr, !auStates.isEmpty {
                
                let stateStr = payerStateMDTF?.text ?? ""
                
                if stateStr.isNotBlank() {
                    if auStates.first(where: { (state) -> Bool in
                        return state == stateStr
                    }) == nil
                    {
                        payerStateMDTF?.text = ""
                    }
                }
            }
        }
        else{
            payerPostalCodeMDTF?.text = ""
            payerPostalCodeMDTF?.maxLength = 10
            payerPostalCodeMDTF?.placeholder = getString(key: "com.charmphr.EditDemographics.postalCode.title")
        }
    }
    
    private func onRelationshipChange(isSelf: Bool) {
        
        if isSelf {
            if let patient = patient {
                firstNameMDTF?.text = patient.firstName
                lastNameMDTF?.text = patient.lastName
                dobMDTF?.text = CharmUtil.getDateStringWith(date: patient.dateOfBirth, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                relationDOBDatepicker.date = patient.dateOfBirth ?? Date()
                birthSexMDTF?.text = patient.gender.capitalizingFirstLetter()
                
                setInsuredAddressDetails(isSelf: isSelf)
            }
            else{
                isPatient = true
                delegate?.getPatientDataForInsurance()
            }
        }
        else{
            firstNameMDTF?.text = nil
            lastNameMDTF?.text = nil
            dobMDTF?.text = nil
            birthSexMDTF?.text = nil
            
            setInsuredAddressDetails(isSelf: isSelf)
        }
    }
    
    private func setInsuredAddressDetails(isSelf: Bool){
        if isSelf{
            if let patient = patient {
                if let postalAddress = patient.postalAddress {
                    line1MDTF?.text = (postalAddress.line1.isNilOrBlank() == false) ? postalAddress.line1 : nil
                    line2MDTF?.text = (postalAddress.line2.isNilOrBlank() == false) ? postalAddress.line2 : nil
                    cityMDTF?.text = (postalAddress.city.isNilOrBlank() == false) ? postalAddress.city : nil
                    stateMDTF?.text = (postalAddress.state.isNilOrBlank() == false) ? postalAddress.state : nil
                    
                    if let countryKey = postalAddress.country {
                        let countryName =  PrimaryDataHandler.sharedInstance.countriesArr?.first(where: { (countryEntry) -> Bool in
                            return countryEntry.key == countryKey
                        })?.value ?? nil
                        countryMDTF?.text = countryName
                    }
                    postalCodeMDTF?.text = (postalAddress.postalCode.isNilOrBlank() == false) ? postalAddress.postalCode : nil
                }
                if let contactDetail = patient.contactDetail {
                    homePhoneMDTF?.text = (contactDetail.homePhone.isNilOrBlank() == false) ? contactDetail.homePhone : nil
                    mobilePhoneMDTF?.text = (contactDetail.mobile.isNilOrBlank() == false) ? contactDetail.mobile : nil
                }
            }
            else{
                isPatient = false
                delegate?.getPatientDataForInsurance()
            }
        }
        else{
            line1MDTF?.text = nil
            line2MDTF?.text = nil
            cityMDTF?.text = nil
            stateMDTF?.text = nil
            countryMDTF?.text = nil
            postalCodeMDTF?.text = nil
            homePhoneMDTF?.text = nil
            mobilePhoneMDTF?.text = nil
        }
    }
    
    private func setInsuredAddressFieldsEnableStatus(isChecked: Bool){
        
        let toDisable = !isChecked
        
        line1MDTF?.isEnableTF(toDisable)
        line2MDTF?.isEnableTF(toDisable)
        cityMDTF?.isEnableTF(toDisable)
        countryMDTF?.isEnableTF(toDisable)
        stateMDTF?.isEnableTF(toDisable)
        postalCodeMDTF?.isEnableTF(toDisable)
        homePhoneMDTF?.isEnableTF(toDisable)
        mobilePhoneMDTF?.isEnableTF(toDisable)
    }
    
    func onPatientFetchSuccess(){
        
        if isPatient{
            onRelationshipChange(isSelf: true)
        }
        else{
            setInsuredAddressDetails(isSelf: true)
        }
        self.endEditing(true)
    }
    
    //MARK: - Update Values
        
    func updateValues(insurance: PatientInsuranceDetails , isDataEditAvailable: Bool = true){
        if insurance.isPrimary{
            insuranceCategory = insuranceTypePrimary
            primaryBtn?.isSelected = true
            secondaryBtn?.isSelected = false
        }
        else{
            insuranceCategory = insuranceTypeSecondary
            primaryBtn?.isSelected = false
            secondaryBtn?.isSelected = true
        }
        
        insuranceTypeTF?.text = insurance.insurancePlanType
        let insuranceTypeChange = onInsuranceTypeChange(insuranceType: insurance.insurancePlanType ?? "")
        insuranceIdTF?.placeholder = insuranceTypeChange.memberIdLabel
        planNameTF?.text = insurance.insurancePlanName
        insuranceIdTF?.text = insurance.policyNumber
        policyGrpTF?.text = insurance.groupNumber
        validFromMDTF?.text = CharmUtil.getDateStringWith(date: insurance.policyStartDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        validFromDatePicker.date = insurance.policyStartDate ?? Date()
        validToMDTF?.text = CharmUtil.getDateStringWith(date: insurance.policyEndDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        validToDatePicker.date = insurance.policyEndDate ?? Date()
        copayMDTF?.text = insurance.copay
        deductableMDTF?.text = insurance.deductable
        commentsTF?.text = insurance.comment
        
        if let insuredAndGuarantorDetails = insurance.insuredAndGuarantorDetails {
            empNameTF?.text = insuredAndGuarantorDetails.insuredEmployerDetails?.name
            firstNameMDTF?.text = insuredAndGuarantorDetails.firstName
            lastNameMDTF?.text = insuredAndGuarantorDetails.lastName
            dobMDTF?.text = CharmUtil.getDateStringWith(date: insuredAndGuarantorDetails.dateOfBirth, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            relationDOBDatepicker.date = insuredAndGuarantorDetails.dateOfBirth ?? Date()
            birthSexMDTF?.text = insuredAndGuarantorDetails.gender?.capitalizingFirstLetter()
            relationshipTF?.text = insuredAndGuarantorDetails.relationship
            
            if let address = insuredAndGuarantorDetails.postalAddress {
                
                if let country = address.country {
                    if let countryVal = primaryDataHandler.countriesArr?.first(where: { (countryEntry) -> Bool in
                        return countryEntry.key == country
                    }) {
                        countryMDTF?.text = countryVal.value
                    }
                }
                onCountryChange()
                
                stateMDTF?.text = address.state
                line1MDTF?.text = address.line1
                line2MDTF?.text = address.line2
                cityMDTF?.text = address.city
                postalCodeMDTF?.text = address.postalCode
            }
            
            if let contactDetails = insuredAndGuarantorDetails.contactDetails {
                homePhoneMDTF?.text = contactDetails.homePhone
                mobilePhoneMDTF?.text = contactDetails.mobile
            }
        }
        if let payer = insurance.practicePayer {
            
            selectedInsuranceCompany = payer
            payerNameTF?.text = payer.payerName
            payerIdTF?.text = payer.payerId
            
            if let address = payer.postalAddress {
                
                if let country = address.country {
                    if let countryVal =  primaryDataHandler.countriesArr?.first(where: { (countryEntry) -> Bool in
                        return countryEntry.key == country
                    }) {
                        payerCountryMDTF?.text = countryVal.value
                    }
                }
                onPayerCountryChange()
                
                payerStateMDTF?.text = address.state
                payerLine1MDTF?.text = address.line1
                payerCityMDTF?.text = address.city
                payerPostalCodeMDTF?.text = address.postalCode
            }
        }
        
        if isQuestionnaireInsurance {
            
            if isDataEditAvailable || (!isDataEditAvailable && (insurance.isFrontCardAvailable == true || insurance.isBackCardAvailable == true)) {
                
                let insuranceCardHeading = UILabel()
                insuranceCardHeading.setProperties(textKey: "com.charmphr.insurance.card.title", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
                
                
                var insuranceCardSubHeading:UILabel? = nil
                
                if isDataEditAvailable {
                    insuranceCardSubHeading = UILabel()
                }
                
                insuranceCardSubHeading?.setProperties(textKey: "com.charmphr.insurance.card.maxsize.info", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_HEAVYDARK)
                
                
                patInsuranceMainView.addArrangedSubview(insuranceCardHeading)
                if let insuranceCardSubHeading = insuranceCardSubHeading {
                    patInsuranceMainView.addArrangedSubview(insuranceCardSubHeading)
                }
                
                let insuranceCardWidth = viewWidth - (2 * X_SPACE)
                let insuranceCard = InsuranceCardView(patientInsurance: insurance, viewWidth: insuranceCardWidth)
                patInsuranceMainView.addArrangedSubview(insuranceCard)
                
                insuranceCard.addShadowAndCornerRadius(.SMALL)
                
                self.insuranceCardView = insuranceCard
                
                if insurance.isFrontCardAvailable == true && !insurance.frontCardName.isNilOrBlank() {
                    insuranceCard.onCardUploadSuccess(type: "front", fileName: insurance.frontCardName ?? "")
                }
                
                if insurance.isBackCardAvailable == true && !insurance.backCardName.isNilOrBlank() {
                    insuranceCard.onCardUploadSuccess(type: "back", fileName: insurance.backCardName ?? "")
                }
            }
        }
    }
        
//MARK: - Validate PatientInsuranceDetails
    
    func validatePatientInsuranceDetails(isAddInsurance: Bool, isSubmitted: Bool = true) -> [String: Any?]{
        
        if hasMoreYesBtn?.isSelected == true || isAddInsurance{
            
            let insuranceType = insuranceTypeTF?.text ?? ""
            if insuranceType.isBlank() && isSubmitted {
                return ["com.charmphr.insurance.add.type.empty":insuranceTypeTF]
            }
            
            if !isQuestionnaireInsurance{
                let planName = planNameTF?.text ?? ""
                if planName.isBlank() && isSubmitted {
                    return ["com.charmphr.insurance.add.planName.empty":planNameTF]
                }
            }
            
            let memberId = insuranceIdTF?.text ?? ""
            if memberId.isBlank() && isSubmitted {
                var alertMsg = getString(key: "com.charmphr.insurance.add.id.empty")
                alertMsg.append(insuranceIdTF?.placeholder ?? "")
                return [alertMsg:insuranceIdTF]
            }
            
            let payerName = payerNameTF?.text ?? ""
            if payerName.isBlank() && isSubmitted{
                return ["com.charmphr.insurance.add.payerName.empty":payerNameTF?.superview]
            }
            if !payerName.hasAnyAlphabets() && isSubmitted {
                return ["com.charmphr.insurance.add.payerName.invalid":payerNameTF?.superview]
            }
            
            if insuranceCategory.isBlank() && isSubmitted && isAddInsurance{
                return ["com.charmphr.insurance.add.insurance.type.empty": insuranceCategoryView]
            }
            
            let startDate = CharmUtil.getDateObjectWith(dateString: validFromMDTF?.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            let stopDate = CharmUtil.getDateObjectWith(dateString: validToMDTF?.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            
            if let startDate, let stopDate{
                
                if startDate > stopDate {
                    return ["com.charmphr.insurance.add.invalidPeriod":validFromMDTF]
                }
                
                if let dateOfBirth =  CharmUtil.getDateObjectWith(dateString: dobMDTF?.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) {
                    
                    if dateOfBirth > startDate {
                        return ["com.charmphr.insurance.add.error.startDate.beforeDOB": validFromMDTF]
                    }
                    if dateOfBirth > stopDate{
                        return ["com.charmphr.insurance.add.error.endDate.beforeDOB":validToMDTF]
                    }
                }
            }
            
            if isQuestionnaireInsurance{
                let policyGrp = policyGrpTF?.text ?? ""
                if policyGrp.isBlank() && isSubmitted {
                    return ["com.charmphr.insurance.add.policyGrp.empty":policyGrpTF]
                }
            }
            
            let relationship = relationshipTF?.text ?? ""
            if relationship.isBlank(){
                return ["com.charmphr.insurance.add.relationship.empty":relationshipTF]
            }
            
            let firstName = firstNameMDTF?.text ?? ""
            let lastName = lastNameMDTF?.text ?? ""
            let dob = dobMDTF?.text ?? ""
            let birthSex = birthSexMDTF?.text ?? ""
            
            
            if firstName.isBlank() && isSubmitted {
                return ["com.charmphr.EditDemographics.FirstName.empty":firstNameMDTF]
            }
            if !firstName.hasAnyAlphabets() && isSubmitted {
                return ["com.charmphr.EditDemographics.FirstName.invalid":firstNameMDTF]
            }
            
            if lastName.isBlank() && isSubmitted {
                return ["com.charmphr.EditDemographics.LastName.empty":lastNameMDTF]
            }
            if !lastName.hasAnyAlphabets() && isSubmitted {
                return ["com.charmphr.EditDemographics.LastName.invalid":lastNameMDTF]
            }
            if dob.isBlank() && isSubmitted {
                return ["com.charmphr.insurance.add.dob.empty":dobMDTF]
            }
            
            if birthSex.isBlank(){
                return ["com.charmphr.insurance.add.insuredPerson.birthsex.empty":birthSexMDTF]
            }
        }
        return [:]
    }
    
//MARK: - Get PatientInsuranceDetails
    
    func getPatientInsuranceDetails() -> PatientInsuranceDetails{
        let insurance = PatientInsuranceDetails()
        
        insurance.insurancePlanName = planNameTF?.text
        insurance.insurancePlanType = insuranceTypeTF?.text
        if insuranceCategoryView.isHidden{
            insurance.type = insuranceTypePrimary
            insurance.isPrimary = true
        }
        else{
            insurance.type = insuranceCategory
            if insuranceCategory == insuranceTypePrimary{
                insurance.isPrimary = true
            }
            else{
                insurance.isPrimary = false
            }
        }
        insurance.policyNumber = insuranceIdTF?.text
        insurance.groupNumber = policyGrpTF?.text
        insurance.copay = copayMDTF?.text
        insurance.deductable = deductableMDTF?.text
        
        let insuredAndGuarantorDetails = InsuredAndGuarantorDetails()
        insuredAndGuarantorDetails.relationship = relationshipTF?.text
        insuredAndGuarantorDetails.firstName = firstNameMDTF?.text
        insuredAndGuarantorDetails.lastName = lastNameMDTF?.text
        insuredAndGuarantorDetails.dateOfBirth = CharmUtil.getDateObjectWith(dateString: dobMDTF?.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        insuredAndGuarantorDetails.gender = birthSexMDTF?.text
        
        let postalAddress = PostalAddress()
        postalAddress.line1 = line1MDTF?.text
        postalAddress.line2 = line2MDTF?.text
        postalAddress.city = cityMDTF?.text
        postalAddress.state = stateMDTF?.text
        let countryKey = primaryDataHandler.countriesArr?.first(where: { (countryEntry) -> Bool in
            return countryEntry.value == countryMDTF?.text
        })?.key ?? ""
        postalAddress.country = countryKey
        postalAddress.postalCode = postalCodeMDTF?.text
        
        let contactDetails = ContactDetails()
        contactDetails.homePhone = homePhoneMDTF?.text
        contactDetails.mobile = mobilePhoneMDTF?.text
        
        insuredAndGuarantorDetails.contactDetails = contactDetails
        insuredAndGuarantorDetails.postalAddress = postalAddress
        
        insurance.insuredAndGuarantorDetails = insuredAndGuarantorDetails
        
        let employerDetails = InsuredEmployerDetails()
        employerDetails.name = empNameTF?.text
        insuredAndGuarantorDetails.insuredEmployerDetails = employerDetails
        
        if isQuestionnaireInsurance{
            if selectedInsuranceCompany == nil{
                let payer = PracticePayer()
                payer.payerName = payerNameTF?.text
                payer.payerId = payerIdTF?.text
                
                selectedInsuranceCompany = payer
            }
            insurance.practicePayer = selectedInsuranceCompany
        }
        else{
            let payerPostalAddress = PostalAddress()
            payerPostalAddress.line1 = payerLine1MDTF?.text
            payerPostalAddress.city = payerCityMDTF?.text
            payerPostalAddress.state = payerStateMDTF?.text
            payerPostalAddress.postalCode = payerPostalCodeMDTF?.text
            
            let payerCountryName = payerCountryMDTF?.text ?? ""
            let payerCountryKey =  primaryDataHandler.countriesArr?.first(where: { (countryEntry) -> Bool in
                return countryEntry.value == payerCountryName
            })?.key ?? ""
            payerPostalAddress.country = payerCountryKey
            
            
            let payer = PracticePayer()
            payer.payerName = payerNameTF?.text
            payer.payerId = payerIdTF?.text
            payer.postalAddress = payerPostalAddress
            
            insurance.practicePayer = payer
        }
        
        insurance.policyStartDate = CharmUtil.getDateObjectWith(dateString: validFromMDTF?.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        insurance.policyEndDate = CharmUtil.getDateObjectWith(dateString: validToMDTF?.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        insurance.comment = commentsTF?.text
        
        if hasMoreYesBtn?.isSelected == true{
            insurance.isAvailable  = true
        }
        else{
            insurance.isAvailable  = false
        }
        return insurance
    }
}

extension MDFLTextField{
    func isEnableTF(_ isEnable: Bool){
        if isEnable{
            if self.placeholder?.hasSuffix("*") == true{
                self.removeStarAfterPlaceHolderText()
                self.placeholderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
                self.addStarAfterPlaceHolderText()
            }
            else{
                self.placeholderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
            }
            self.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
            self.floatingLabelTextColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK70)
            self.isEnabled = true
        }
        else{
            self.placeholderColor = UIColorFromRGB(rgbValueWithAlpha: 0x333333AD)
            self.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x333333BA)
            self.floatingLabelTextColor = UIColorFromRGB(rgbValueWithAlpha: 0x333333AD)
            self.isEnabled = false
            self.isMandatoryField = false
        }
    }
}

class InsuranceCardView: UIStackView {
    
    var patientInsurance: PatientInsuranceDetails? = nil
    weak var delegate:InsuranceCardViewDelegate? = nil
    private var viewWidth:CGFloat = 0
    
    private let fromLabel = UILabel()
    private let separator = UIView()

    private lazy var frontPageView = UIView()
    private lazy var frontPageIV = UIImageView()
    private lazy var frontPageLabel = UILabel()
    private lazy var frontPageDelete = UIButton()
    private lazy var frontPageCamera = UIButton()
    private lazy var frontPageGallery = UIButton()
    
    private lazy var lastPageView = UIView()
    private lazy var lastPageIV = UIImageView()
    private lazy var lastPageLabel = UILabel()
    private lazy var lastPageDelete = UIButton()
    private lazy var lastPageCamera = UIButton()
    private lazy var lastPageGallery = UIButton()

   
    private let lastLabel = UILabel()

    private let frontActionView = UIView()
    private let lastActionView = UIView()


    init(patientInsurance: PatientInsuranceDetails , viewWidth: CGFloat) {
        self.patientInsurance = patientInsurance
        self.viewWidth = viewWidth
        super.init(frame: .zero)
        initSubViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews(){
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = CARD_PADDING
        alignment = .center
        self.isLayoutMarginsRelativeArrangement = true
        self.layoutMargins = UIEdgeInsets(top: CARD_PADDING, left: 0, bottom: CARD_PADDING, right: 0)
        
        
        
        
        addArrangedSubview(fromLabel)
        addArrangedSubview(frontPageView)
        addArrangedSubview(frontActionView)
        addArrangedSubview(separator)
        
        frontPageView.addSubview(frontPageIV)
        frontPageView.addSubview(frontPageLabel)
        frontPageView.addSubview(frontPageDelete)
        
        frontActionView.addSubview(frontPageCamera)
        frontActionView.addSubview(frontPageGallery)
        
        addArrangedSubview(lastLabel)
        addArrangedSubview(lastPageView)
        addArrangedSubview(lastActionView)
        
        lastPageView.addSubview(lastPageIV)
        lastPageView.addSubview(lastPageLabel)
        lastPageView.addSubview(lastPageDelete)
        
        lastActionView.addSubview(lastPageCamera)
        lastActionView.addSubview(lastPageGallery)

//        let toLabel = UILabel()
//        addArrangedSubview(fromLabel)
//
//        
        fromLabel.setProperties(textKey: "com.charmphr.insurance.card.from.title", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        
        frontPageView.addCornerRadius(.SMALL)
        frontPageView.layer.borderWidth = BORDER_WIDTH
        frontPageView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        
        

        frontPageCamera.setImage(UIImage(named: "camera-icon"), for: .normal)
        frontPageCamera.setProperties(titleStrKey: "com.charmphr.insurance.card.camera.title", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        
        frontPageCamera.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        frontPageCamera.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        frontPageCamera.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        frontPageCamera.addTarget(self, action: #selector(onFrontCardCameraClicked), for: .touchUpInside)
        
        frontPageGallery.setImage(UIImage(named: "image-upload"), for: .normal)
        frontPageGallery.setProperties(titleStrKey: "com.charmphr.insurance.card.gallery.title", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)

        frontPageGallery.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        frontPageGallery.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        frontPageGallery.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        frontPageGallery.addTarget(self, action: #selector(onFrontCardGalleryClicked), for: .touchUpInside)

        
        frontPageIV.image = #imageLiteral(resourceName: "ImagePlaceHolder")
        frontPageLabel.setProperties(textKey: "Summa.jpeg", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        frontPageDelete.setImage(UIImage(named: "delete-red"), for: .normal)
        frontPageDelete.addTarget(self, action: #selector(onFrontCardDeleteClicked), for: .touchUpInside)
        
        frontPageLabel.isUserInteractionEnabled = true
        frontPageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFrontCardGetClicked)))

        
        
        separator.setBackgroundColor(bgColor: SEPARATOR_COLOR)
        
        lastLabel.setProperties(textKey: "com.charmphr.insurance.card.to.title", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        
        lastPageView.addCornerRadius(.SMALL)
        lastPageView.layer.borderWidth = BORDER_WIDTH
        lastPageView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        
       

        lastPageCamera.setImage(UIImage(named: "camera-icon"), for: .normal)
        lastPageCamera.setProperties(titleStrKey: "com.charmphr.insurance.card.camera.title", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        
        lastPageCamera.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        lastPageCamera.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        lastPageCamera.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        lastPageCamera.addTarget(self, action: #selector(onBackCardCameraClicked), for: .touchUpInside)
        
        lastPageGallery.setImage(UIImage(named: "image-upload"), for: .normal)
        lastPageGallery.setProperties(titleStrKey: "com.charmphr.insurance.card.gallery.title", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)

        lastPageGallery.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        lastPageGallery.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        lastPageGallery.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        lastPageGallery.addTarget(self, action: #selector(onBackCardGalleryClicked), for: .touchUpInside)
        
        lastPageIV.image = #imageLiteral(resourceName: "ImagePlaceHolder")
        lastPageLabel.setProperties(textKey: "", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        lastPageDelete.setImage(UIImage(named: "delete-red"), for: .normal)
        lastPageDelete.addTarget(self, action: #selector(onBackCardDeleteClicked), for: .touchUpInside)
        
        lastPageLabel.isUserInteractionEnabled = true
        lastPageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBackCardGetClicked)))

        
        separator.setWidth(constant: viewWidth - X_SPACE)
        separator.setHeight(constant: 0.5)
        
        fromLabel.setWidth(constant: viewWidth - (X_SPACE*2))
        frontPageView.setWidth(constant: viewWidth - (X_SPACE*2))
        frontPageView.setHeight(constant: 50)
        frontActionView.setWidth(constant: viewWidth - (X_SPACE*2))

        
        frontPageCamera.setLeft(offSet: 0)
        frontPageCamera.setTop(offSet: 0)
        frontPageCamera.setBottom(offSet: 0)
        
        frontPageGallery.setRight(offSet: 0)
        frontPageGallery.setTop(offSet: 0)
        frontPageGallery.setBottom(offSet: 0)
        
        frontPageIV.setLeft(offSet: 12)
        frontPageIV.setCenterY()
        frontPageIV.setWidth(constant: 20)
        frontPageIV.setHeight(constant: 20)
        
        frontPageDelete.setRight(offSet: -12)
        frontPageDelete.setCenterY()
        frontPageDelete.setWidth(constant: 20)
        frontPageDelete.setHeight(constant: 20)
        
        frontPageLabel.setLeftRelatedToView(offSet: 12, relatedView: frontPageIV, relatedAttribute: .right)
        frontPageLabel.setRightRelatedToView(offSet: -12, relatedView: frontPageDelete, relatedAttribute: .left)
        frontPageLabel.setCenterY()
        
        lastLabel.setWidth(constant: viewWidth - (X_SPACE*2))
        lastPageView.setWidth(constant: viewWidth - (X_SPACE*2))
        lastPageView.setHeight(constant: 50)
        lastActionView.setWidth(constant: viewWidth - (X_SPACE*2))

        
        lastPageCamera.setLeft(offSet: 0)
        lastPageCamera.setTop(offSet: 0)
        lastPageCamera.setBottom(offSet: 0)
        
        lastPageGallery.setRight(offSet: 0)
        lastPageGallery.setTop(offSet: 0)
        lastPageGallery.setBottom(offSet: 0)
        
        lastPageIV.setLeft(offSet: 12)
        lastPageIV.setCenterY()
        lastPageIV.setWidth(constant: 20)
        lastPageIV.setHeight(constant: 20)
        
        lastPageDelete.setRight(offSet: -12)
        lastPageDelete.setCenterY()
        lastPageDelete.setWidth(constant: 20)
        lastPageDelete.setHeight(constant: 20)
        
        lastPageLabel.setLeftRelatedToView(offSet: 12, relatedView: lastPageIV, relatedAttribute: .right)
        lastPageLabel.setRightRelatedToView(offSet: -12, relatedView: lastPageDelete, relatedAttribute: .left)
        lastPageLabel.setCenterY()
        
        lastPageView.hideView()
        frontPageView.hideView()
    }
    
    func hideActionButtons() {
        frontActionView.hideView()
        lastActionView.hideView()
        frontPageDelete.hideView()
        lastPageDelete.hideView()
        
        separator.hideView()
        
        if frontPageView.isHidden {
            fromLabel.hideView()
        }
        else{
            lastLabel.hideView()
        }
    }
    
    func onCardUploadSuccess(type:String , fileName: String?){
        if type == "front"{
            frontPageView.showView()
            frontPageLabel.text = fileName
        }
        else{
            lastPageView.showView()
            lastPageLabel.text = fileName
        }
    }
    
    func onCardDeleteSuccess(type:String){
        if type == "front"{
            frontPageView.hideView()
        }
        else{
            lastPageView.hideView()
        }
    }
    
    @objc private func onFrontCardCameraClicked(){
        delegate?.onInsuranceCardCameraClicked(type: "front")
    }
    
    @objc private func onBackCardCameraClicked(){
        delegate?.onInsuranceCardCameraClicked(type: "back")
    }
    
    @objc private func onFrontCardGalleryClicked(){
        delegate?.onInsuranceCardGalleryClicked(type: "front")
    }
    
    @objc private func onBackCardGalleryClicked(){
        delegate?.onInsuranceCardGalleryClicked(type: "back")
    }
    
    @objc private func onFrontCardDeleteClicked(){
        delegate?.onInsuranceCardDeleteClicked(type: "front")
    }
    
    @objc private func onBackCardDeleteClicked(){
        delegate?.onInsuranceCardDeleteClicked(type: "back")
    }
    
    @objc private func onFrontCardGetClicked(){
        delegate?.onInsuranceCardShowImg(type: "front", fileName: nil)
    }
    
    @objc private func onBackCardGetClicked(){
        delegate?.onInsuranceCardShowImg(type: "back", fileName: nil)
    }
}

protocol InsuranceCardViewDelegate: AnyObject {
    
    func onInsuranceCardCameraClicked(type: String)
    func onInsuranceCardGalleryClicked(type: String)
    func onInsuranceCardDeleteClicked(type: String)
    func onInsuranceCardShowImg(type:String, fileName: String?)
}
