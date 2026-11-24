//
//  AddCardView.swift
//  phr
//
//  Created by Raghul D on 01/02/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation

class AddCardView: UIView , UITextFieldDelegate, MDTextFieldDelegate {
    
    let containerScrollView = TPKeyboardAvoidingScrollView()
    let containerStackView = UIStackView()
    let payBtn = UIButton(type: .custom)
    let isPrimaryBtn = UIButton(type: .custom)
    let cardDetailsLayout = UIView()
    var infoView:InformationView? = nil
    
    let monthYearPicker = MonthYearPicker()
    let addressLayout = UIView()

    var practiceLayout: TextFieldLabelItemView? = nil

    let activityIndicator = UIActivityIndicatorView()

    var cardHolderName:TextFieldLabelItemView? = nil
    var cardNumber:TextFieldLabelItemView? = nil
    let cardNickName = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
    var cardExpiry:TextFieldLabelItemView? = nil
    var cardCvv:TextFieldLabelItemView? = nil

    let line1 = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
    let line2 = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
    let city = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
    let state = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
    let country = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    let pinCode = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)

    private let pincodeTag = 1222
    private let payBtnHeight: CGFloat = 56
    var delegate : AddCardViewController?
    
    private var hyphencharacterSet = NSCharacterSet.decimalDigits
    
    init(delegate: AddCardViewController) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubViews() {
        
        hyphencharacterSet.insert("-")
  
        self.addSubview(activityIndicator)
        self.addSubview(containerScrollView)
        self.addSubview(payBtn)
        containerScrollView.addSubview(containerStackView)
        
        
        var practiceHeader: UILabel? = nil
        if ((delegate?.practiceList.count ?? 0 ) > 1 && delegate?.editCard == nil) {
            
            let pracLayout = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
            practiceHeader = getHeaderLabel(key: "com.charmphr.card.add.practice.header")
            if let practiceHeader = practiceHeader {
                containerStackView.addArrangedSubview(practiceHeader)
            }
            containerStackView.addArrangedSubview(pracLayout)
            practiceLayout = pracLayout
        }

//        if let paymentVC = delegate {
//            if paymentVC.paymentInfo?.chargeType != appointmentCardProcessingTypeChargeOnly &&  !paymentVC.cardList.isEmpty {
//                debugPrintLog("chargeType -> \(paymentVC.paymentInfo?.chargeType ?? "")")
//                debugPrintLog("cardList -> \(paymentVC.cardList)")
//            }
//        }
        
        let cardDetailsHeader = getHeaderLabel(key: "com.charmphr.card.add.carddetails.header")
        containerStackView.addArrangedSubview(cardDetailsHeader)
        containerStackView.addArrangedSubview(cardDetailsLayout)
        
        
        if delegate?.editCard == nil {
            let holderName = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
            
            let number = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
            
            let expiry = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
            
            let cvv = TextFieldLabelItemView(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        
            cardDetailsLayout.addSubview(holderName)
            cardDetailsLayout.addSubview(number)
            
            cardDetailsLayout.addSubview(expiry)
            cardDetailsLayout.addSubview(cvv)
            
            cardHolderName = holderName
            cardNumber = number
            cardExpiry = expiry
            cardCvv = cvv
        }
        
        cardDetailsLayout.addSubview(cardNickName)
        
        
        containerStackView.addArrangedSubview(isPrimaryBtn)
     
        infoView = InformationView(infoLocalisedKey: "com.charmphr.Payment.paymentNote.info")
        
        
        let addressHeader = getHeaderLabel(key: "com.charmphr.card.add.address.header")
        containerStackView.addArrangedSubview(addressHeader)
        containerStackView.addArrangedSubview(addressLayout)
        
        addressLayout.addSubview(line1)
        addressLayout.addSubview(line2)
        addressLayout.addSubview(city)
        addressLayout.addSubview(state)
        addressLayout.addSubview(country)
        addressLayout.addSubview(pinCode)
        
        if let infoView = infoView {
            containerStackView.addArrangedSubview(infoView)
        }

        //Properties
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        payBtn.setBackgroundColor(bgColor: THEME_COLOR)
        
        if delegate?.editCard != nil {
            payBtn.setTitle(getString(key:"com.charmphr.action.update"), for: .normal)
        }
        else{
            payBtn.setTitle(getString(key:"com.charmphr.action.add"), for: .normal)
        }
        payBtn.setTitleColor(.white, for: .normal)
        payBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        payBtn.addPillCornerRadiusAndShadow(height: payBtnHeight)
        payBtn.clipsToBounds = true
        payBtn.addTarget(self, action: #selector(onPayBtnClicked(btn:)), for: .touchUpInside)

        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .vertical
        containerStackView.spacing = 10
        containerStackView.distribution = .fill
        
        isPrimaryBtn.setTitle(getString(key: "com.charmphr.card.add.isprimary.title"), for: .normal)
        isPrimaryBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        isPrimaryBtn.setTitleColor(.black, for: .normal)
        isPrimaryBtn.titleLabel?.textAlignment = .left
        isPrimaryBtn.addTarget(self, action: #selector(isPrimaryBtnClicked(btn:)), for: .touchUpInside)
        isPrimaryBtn.setImage(#imageLiteral(resourceName: "CheckboxUnselected"), for: .normal)
        isPrimaryBtn.setImage(#imageLiteral(resourceName: "CheckboxSelected"), for: .selected)
        isPrimaryBtn.setInsets(imageTitlePadding: 10)
        
        cardDetailsLayout.addShadowAndCornerRadius(.SMALL)
        cardHolderName?.addBottomBorder()
        
        cardHolderName?.keyLabel.text = getString(key:"com.charmphr.Payment.name.title")
        cardHolderName?.textField?.placeholder = getString(key:"com.charmphr.Payment.name.placeholder")
        
        cardNumber?.keyLabel.text = getString(key:"com.charmphr.Payment.cardNumber.title")
     
        cardNumber?.textField?.placeholder = getString(key:"com.charmphr.Payment.cardNumber.placeholder")
        cardNumber?.textField?.maxLength = 16
        cardNumber?.textField?.delegate = self
        cardNumber?.textField?.keyboardType = .numberPad
       
        cardNumber?.addBottomBorder()
        
        if cardNumber != nil {
            cardNickName.addBottomBorder()
        }
        
        cardNickName.keyLabel.text = getString(key:"com.charmphr.card.add.nickname.title")
        cardNickName.textField?.placeholder = getString(key:"com.charmphr.card.add.nickname.title")
        
        monthYearPicker.addTarget(self, action: #selector(monthYearPickerDidChange), for: .valueChanged)
        cardExpiry?.keyLabel.text = getString(key:"com.charmphr.Payment.Expires.title")
        cardExpiry?.textField?.inputView = monthYearPicker
        cardExpiry?.textField?.placeholder = getString(key:"com.charmphr.Payment.Expires.placeholder")
        cardExpiry?.textField?.delegate = self
        cardExpiry?.addBottomBorder()
       // cardExpiry.textField?.maxLength = 2
        //cardExpiry.textField?.keyboardType = .numberPad
        
        if let cardExpiry = cardExpiry {
            let cardExpiryToolbar = MDDateToolbarWithDone(textField: cardExpiry.textField, parent: self)
            cardExpiryToolbar.done?.action = #selector(onClickDoneMonthYearPicker)
        }
        
        cardCvv?.keyLabel.text = getString(key:"com.charmphr.Payment.CVV.title")
          
        cardCvv?.textField?.placeholder = getString(key: "com.charmphr.Payment.CVV.placeholder")
        cardCvv?.textField?.maxLength = 4
        cardCvv?.textField?.keyboardType = .numberPad
        cardCvv?.textField?.delegate = self
        cardCvv?.hideSeparator()
        
        addressLayout.addShadowAndCornerRadius(.SMALL)
        
        line1.keyLabel.text = getString(key:"com.charmphr.EditDemographics.ADDRESSLINE1.title")
        line1.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.ADDRESSLINE1.title")
        line1.textField?.pattern = alphanumericAndPHRAllowedSplCharacters
        line1.textField?.textFieldType = MDTextFieldTypeSpecificPattern
        line1.textField?.delegate = self
        line1.textField?.maxLength = 35
        line1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTextAddressClicked(view: ))))
        line1.addBottomBorder()
        
        line2.keyLabel.text = getString(key:"com.charmphr.EditDemographics.ADDRESSLINE2.title")
        line2.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.ADDRESSLINE2.title")
        line2.textField?.pattern = alphanumericAndPHRAllowedSplCharacters
        line2.textField?.textFieldType = MDTextFieldTypeSpecificPattern
        line2.textField?.delegate = self
        line2.textField?.maxLength = 35
        line2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTextAddressClicked(view: ))))
        line2.addBottomBorder()

        city.keyLabel.text = getString(key:"com.charmphr.EditDemographics.City.title")
        city.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.City.title")
        city.textField?.pattern = alphanumericAndPHRAllowedSplCharacters
        city.textField?.textFieldType = MDTextFieldTypeSpecificPattern
        city.textField?.delegate = self
        city.textField?.maxLength = 35
        city.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTextAddressClicked(view: ))))
        city.addBottomBorder()

        state.keyLabel.text = getString(key:"com.charmphr.EditDemographics.State.title")
        state.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.State.title")
        state.textField?.pattern = alphanumericAndPHRAllowedSplCharacters
        state.textField?.textFieldType = MDTextFieldTypeSpecificPattern
        state.textField?.delegate = self
        state.textField?.maxLength = 2
        state.addBottomBorder()

        country.keyLabel.text = getString(key:"com.charmphr.EditDemographics.Country.title")
        country.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.Country.title")
        country.textField?.isUserInteractionEnabled = false
        country.textField?.delegate = self
        country.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryClicked(view:))))

        country.addBottomBorder()

        pinCode.keyLabel.text = getString(key:"com.charmphr.EditDemographics.zipCode.title")
        pinCode.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.zipCode.title")
        pinCode.textField?.keyboardType = .numbersAndPunctuation
        pinCode.textField?.delegate = self
        pinCode.textField?.mdTextFieldDelegateForScrollView = self
        pinCode.textField?.tag = pincodeTag
        pinCode.textField?.maxLength = 10
        pinCode.hideSeparator()
        pinCode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTextAddressClicked(view: ))))
        
        if let practiceLayout = practiceLayout {
            practiceLayout.addShadowAndCornerRadius(.SMALL)
            practiceLayout.keyLabel.setText(key: "com.charmphr.Payment.card.title")
            practiceLayout.hideSeparator()
            practiceLayout.isUserInteractionEnabled = true
            practiceLayout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPracticeClicked(view:))))
        }
        //Constraints
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        containerScrollView.setLeft(offSet: 0)
        containerScrollView.setRight(offSet: 0)
        containerScrollView.setBottomRelatedToView(offSet: -Y_SPACE, relatedView: payBtn, relatedAttribute: .top)
        
        containerStackView.setTop(offSet: 0)
        containerStackView.setBottom(offSet: 0)
        containerStackView.setLeft(offSet: 0)
        containerStackView.setWidth(constant: applicationFrame.width)
        
        payBtn.setLeft(offSet: X_SPACE)
        payBtn.setRight(offSet: -X_SPACE)
        payBtn.setSafeAreaBottom(offset: -Y_SPACE)
        payBtn.setHeight(constant: payBtnHeight)
        
        isPrimaryBtn.setHeight(constant: 42)
        isPrimaryBtn.setWidth(constant: (isPrimaryBtn.titleLabel?.sizeThatFits(CGSize(width: 200, height: 40)).width ?? 0) + 52)
        //isPrimaryBtn.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        isPrimaryBtn.setLeft(offSet: 4)
        
        cardDetailsLayout.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        cardDetailsLayout.setLeft(offSet: X_SPACE)
            
        cardNickName.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        cardNickName.setLeft(offSet: 0)
        
        if let cardHolderName = cardHolderName, let cardNumber = cardNumber , let cardCvv = cardCvv , let cardExpiry = cardExpiry{
            cardHolderName.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
            cardHolderName.setLeft(offSet: 0)
            cardHolderName.setTop(offSet: 0)
            
            cardNumber.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
            cardNumber.setLeft(offSet: 0)
            cardNumber.setTopRelatedToView(offSet: 0, relatedView: cardHolderName, relatedAttribute: .bottom)
           
            cardExpiry.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
            cardExpiry.setLeft(offSet: 0)
            cardExpiry.setTopRelatedToView(offSet: 0, relatedView: cardNickName, relatedAttribute: .bottom)

            cardCvv.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
            cardCvv.setLeft(offSet: 0)
            cardCvv.setTopRelatedToView(offSet: 0, relatedView: cardExpiry, relatedAttribute: .bottom)
            cardCvv.setBottom(offSet: 0)
            
            cardNickName.setTopRelatedToView(offSet: 0, relatedView: cardNumber, relatedAttribute: .bottom)

        }
        else{
            cardNickName.setTop(offSet: 0)
            cardNickName.setBottom(offSet: 0)
        }
     
        if let practiceLayout = practiceLayout {
            practiceLayout.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
            practiceLayout.setLeft(offSet: X_SPACE)
        }
    

        if let practiceHeader = practiceHeader {
            practiceHeader.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
            practiceHeader.setLeft(offSet: X_SPACE)
        }
        
        cardDetailsHeader.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        cardDetailsHeader.setLeft(offSet: X_SPACE)
        
        addressHeader.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        addressHeader.setLeft(offSet: X_SPACE)
        
        addressLayout.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        addressLayout.setLeft(offSet: X_SPACE)
        
        line1.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        line1.setLeft(offSet: 0)
        line1.setTop(offSet: 0)
        
        line2.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        line2.setLeft(offSet: 0)
        line2.setTopRelatedToView(offSet: 0, relatedView: line1, relatedAttribute: .bottom)
        
        city.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        city.setLeft(offSet: 0)
        city.setTopRelatedToView(offSet: 0, relatedView: line2, relatedAttribute: .bottom)
        
        state.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        state.setLeft(offSet: 0)
        state.setTopRelatedToView(offSet: 0, relatedView: city, relatedAttribute: .bottom)
        
        country.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        country.setLeft(offSet: 0)
        country.setTopRelatedToView(offSet: 0, relatedView: state, relatedAttribute: .bottom)

        pinCode.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        pinCode.setLeft(offSet: 0)
        pinCode.setTopRelatedToView(offSet: 0, relatedView: country, relatedAttribute: .bottom)
        pinCode.setBottom(offSet: 0)
        
        if let infoView = infoView {
            infoView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
            infoView.setLeft(offSet: X_SPACE)
        }
        
//        cardHolderName?.textField?.text = "ipad Test"
//        cardNumber?.textField?.text = "4111111111111111"
//        cardExpiry?.textField?.text = "12 / 2023"
//        cardNickName.textField?.text = "ipad Test"
//        cardCvv?.textField?.text = "123"
    }
    
    func setPaymentGatewayToken(paymentGatewayToken: PaymentGatewayToken){
        
        cardNickName.textField?.text = paymentGatewayToken.cardNickName
        isPrimaryBtn.isSelected = paymentGatewayToken.isPrimaryCard
    
        if let postalAddress = paymentGatewayToken.postalAddress {
            setPostalAddress(postalAddress: postalAddress)
        }
    }
    
    func setPostalAddress(postalAddress: PostalAddress){
        line1.textField?.text = postalAddress.line1
        line2.textField?.text = postalAddress.line2
        city.textField?.text = postalAddress.city
        state.textField?.text = postalAddress.state
        
        
        if let countryStr = postalAddress.country {
            if let countryVal = PrimaryDataHandler.sharedInstance.countriesArr?.first(where: { (countryEntry) -> Bool in
                return countryEntry.key == countryStr
            }) {
                country.textField?.text = countryVal.value
            }
        }
        onCountryChange()
        pinCode.textField?.text = postalAddress.postalCode
    }
    
    func onCountryChange(){
        
        
//        let country = country.textField?.text ?? ""
//        if country.lowercased() == "india" {
//          //  patContactWidget.postBoxMDTF?.superview?.isHidden = true
//           // patContactWidget.postBoxMDTF?.text = ""
//
//            pinCode.textField?.text = ""
//            pinCode.textField?.maxLength = 6
//            pinCode.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.postalCode.title")
//
//        }
//        else if country.lowercased() == "united states" {
//           // patContactWidget.postBoxMDTF?.superview?.isHidden = false
//
//            pinCode.textField?.text = ""
//            pinCode.textField?.maxLength = 5
//            pinCode.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.zipCode.title")
//
//        }
//        else{
//            pinCode.textField?.maxLength = 10
//            pinCode.textField?.placeholder = getString(key:"com.charmphr.EditDemographics.postalCode.title")
//        }
    }

    @objc func isPrimaryBtnClicked(btn: UIButton){
        btn.isSelected = !btn.isSelected
    }
    
    @objc func onPracticeClicked(view: UIView){
    //    delegate?.intentToCardListPage()
        delegate?.intentToCountrySelect()
    }
    
    @objc func onCountryClicked(view: UIView){
        delegate?.intentToCountrySelect()
    }
    
    @objc func onTextAddressClicked(view: UIView){
        
        if let addressField = view as? TextFieldLabelItemView {
            addressField.textField?.becomeFirstResponder()
        }
    }
    
    @objc func monthYearPickerDidChange(){
        self.endEditing(true)
        let date = monthYearPicker.date
        cardExpiry?.textField?.text = date.getStringFromDate(dateFormat: "MM / yyyy")
    }
    
    @objc func dismissKeyBoard()
    {
        self.endEditing(true)
    }
    
    @objc func onClickDoneMonthYearPicker(){
        let date = monthYearPicker.date
        cardExpiry?.textField?.text = date.getStringFromDate(dateFormat: "MM / yyyy")
    }
    
    @objc func onPayBtnClicked(btn: UIButton){
        
        if delegate?.editCard != nil {
            if let editCard = validateEditData() {
                delegate?.editCard(card: editCard)
            }
        }
        else{
            
            if let paymentInfo = validateAddData() {
                //         delegate?.onCardValidationSuccess()
                delegate?.addCard(paymentInfo: paymentInfo)
            }
        }
    }
    
    func setPracticeName(practiceName: String){
        practiceLayout?.valueLabel?.text = practiceName
    }
    
    func validateEditData() -> PaymentGatewayToken? {
        
        guard let card = delegate?.editCard else {
            return nil
        }
        
        let line1Str = line1.textField?.text ?? ""
        let line2Str = line2.textField?.text ?? ""
        let cityStr = city.textField?.text ?? ""
        let stateStr = state.textField?.text ?? ""
        
        
        if line1Str.isNotBlank() {
            if !line1Str.hasAnyAlphabets() {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.line1.invalid")
                line1.textField?.becomeFirstResponder()
                return nil
            }
        }
        
        
        if line2Str.isNotBlank() {
            if !line2Str.hasAnyAlphabets() {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.line2.invalid")
                line2.textField?.becomeFirstResponder()
                return nil
            }
        }
        
        
        if cityStr.isNotBlank() {
            if !cityStr.hasAnyAlphabets() {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.city.invalid")
                city.textField?.becomeFirstResponder()
                return nil
            }
        }
        
        
        if stateStr.isNotBlank() {
            if stateStr.count != 2 {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.stateAlpha.invalid")
                state.textField?.becomeFirstResponder()
                return nil
            }
        }
        
        let countryName = country.textField?.text ?? ""

       
       var countryKey  = ""
        if countryName.isNotBlank() {
            countryKey =  PrimaryDataHandler.sharedInstance.countriesArr?.first(where: { (countryEntry) -> Bool in
                return countryEntry.value == countryName
            })?.key ?? ""
            if countryKey.isBlank() {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.country.invalid")
                return nil
            }
        }
        
        let pinCodeStr = pinCode.textField?.text ?? ""
        
       
        
        card.cardNickName = cardNickName.textField?.text ?? ""
        card.isPrimaryCard = isPrimaryBtn.isSelected
        
        card.postalAddress?.line1 = line1Str
        card.postalAddress?.line2 = line2Str
        card.postalAddress?.city = cityStr
        card.postalAddress?.state = stateStr
        card.postalAddress?.country = countryKey
        card.postalAddress?.postalCode = pinCodeStr
        return card
    }
    
    func validateAddData() -> PaymentInfo? {
        
        
        if cardHolderName?.textField?.text.isNilOrBlank() ?? true  {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_name"), msg: nil)
                return nil
        }
        else if(cardNumber?.textField?.text.isNilOrBlank() ?? true)
            {
            CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_number"), msg: nil)
              
            return nil
            }
        else if(cardExpiry?.textField?.text.isNilOrBlank() ?? true){
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_month"), msg: nil)

                return nil
            }

        else if(cardCvv?.textField?.text.isNilOrBlank() ?? true || (cardCvv?.textField?.text?.count ?? 0 ) < 3){

            if cardCvv?.textField?.text.isNilOrBlank() ?? true {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_cvv"), msg: nil)
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.invalid_cvv"), msg: nil)
            }

            return nil
        }
        
        let line1Str = line1.textField?.text ?? ""
        let line2Str = line2.textField?.text ?? ""
        let cityStr = city.textField?.text ?? ""
        let stateStr = state.textField?.text ?? ""
        
        
        if line1Str.isNotBlank() {
            if !line1Str.hasAnyAlphabets() {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.line1.invalid")
                line1.textField?.becomeFirstResponder()
                return nil
            }
        }
        
        
        if line2Str.isNotBlank() {
            if !line2Str.hasAnyAlphabets() {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.line2.invalid")
                line2.textField?.becomeFirstResponder()
                return nil
            }
        }
        
        
        if cityStr.isNotBlank() {
            if !cityStr.hasAnyAlphabets() {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.city.invalid")
                city.textField?.becomeFirstResponder()
                return nil
            }
        }
        
        
        if stateStr.isNotBlank() {
            if stateStr.count != 2 {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.stateAlpha.invalid")
                state.textField?.becomeFirstResponder()
                return nil
            }
        }
        
        let countryName = country.textField?.text ?? ""

       
       var countryKey  = ""
        if countryName.isNotBlank() {
            countryKey =  PrimaryDataHandler.sharedInstance.countriesArr?.first(where: { (countryEntry) -> Bool in
                return countryEntry.value == countryName
            })?.key ?? ""
            if countryKey.isBlank() {
                showAlertDialog(titleKey: "com.charmphr.questionnairevc.patContact.country.invalid")
                return nil
            }
        }
        
        let pinCodeStr = pinCode.textField?.text ?? ""
        
        
        let paymentInfo = PaymentInfo()
        paymentInfo.cardNumber = cardNumber?.textField?.text
        
        let expiryDate = (cardExpiry?.textField?.text ?? "").components(separatedBy: "/")
        paymentInfo.cardExpMonth = expiryDate.getElement(at: 0)?.trim() ?? ""
        paymentInfo.cardExpYear = expiryDate.getElement(at: 1)?.trim() ?? ""
        paymentInfo.cardCvv = cardCvv?.textField?.text
        paymentInfo.cardHolderName = cardHolderName?.textField?.text
        paymentInfo.chargeProcessingType = appointmentCardProcessingTypeStoreOnly
        
        
        
        
        
        
        let transactionInfo = TransactionInfo()
        transactionInfo.gateway = appointmentGatewayTypeBluefin
        transactionInfo.service = paymentServiceBilling
        transactionInfo.paymentAmount = "0"
        transactionInfo.memberId = "" //lOCAL 494000000097207 //"43118000000021019"
        
        let cardDetails = PaymentGatewayToken()
        cardDetails.isPHRCard = true
        cardDetails.isPrimaryCard = isPrimaryBtn.isSelected
        cardDetails.cardNickName = cardNickName.textField?.text ?? ""
        transactionInfo.nickName = cardDetails.cardNickName
        paymentInfo.cardDetails = cardDetails
        
        let postalAddress = PostalAddress()
        postalAddress.line1 = line1Str
        postalAddress.line2 = line2Str
        postalAddress.city = cityStr
        postalAddress.state = stateStr
        postalAddress.country = countryKey
        postalAddress.postalCode = pinCodeStr
        
        cardDetails.postalAddress = postalAddress
        paymentInfo.transactionInfo = transactionInfo
        
        return paymentInfo
    }
    
    func showActivityIndicator()
    {
        self.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
       // self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true
     //   self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func getHeaderLabel(key: String) -> UILabel{
        let header = UILabel()
        header.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        header.setTextColor(fontcolor: TEXT_COLOR_BLACK87)
        header.setText(key: key)
        header.numberOfLines = 1
        
        return header
    }
    
    func showAlertDialog(titleKey: String) {
        CharmUtil.createOkayAlertWith(title: getString(key: titleKey), msg: nil)
    }
    
    func mdTextField(_ textField: MDTextField!, shouldChangeCharactersIn range: NSRange, replacementString string: String!) -> Bool {
        
        if textField == pinCode.textField {
            
            
            if string.isBlank(){
                return true
            }
            
            if string.rangeOfCharacter(from: hyphencharacterSet) != nil {
                return true
            }
            else {
                return false
            }
        }
        else{
            return true
        }
    }
    
    
    func checkDataIsAvailable() -> Bool {
  
            
        if !(cardHolderName?.textField?.text.isNilOrBlank() ?? true) {
            return true
        }
        if !(cardNumber?.textField?.text.isNilOrBlank() ?? true) {
            return true
        }
        if !(cardNickName.textField?.text.isNilOrBlank() ?? true) {
            return true
        }
        if !(cardExpiry?.textField?.text.isNilOrBlank() ?? true) {
            return true
        }
        if !(cardCvv?.textField?.text.isNilOrBlank() ?? true) {
            return true
        }
        
        if isPrimaryBtn.isSelected {
            return true
        }
        
        if let postalAddress = delegate?.patientAddress {
            if (line1.textField?.text?.trim() ?? "") != (postalAddress.line1 ?? "") {
                return true
            }
            if (line2.textField?.text?.trim() ?? "") != (postalAddress.line2 ?? "") {
                return true
            }
            if (city.textField?.text?.trim() ?? "") != (postalAddress.city ?? "") {
                return true
            }
            if (state.textField?.text?.trim() ?? "") != (postalAddress.state ?? "") {
                return true
            }
            
            
            
            if let countryStr = postalAddress.country {
                if let countryVal = PrimaryDataHandler.sharedInstance.countriesArr?.first(where: { (countryEntry) -> Bool in
                    return countryEntry.key == countryStr
                }) {
                    if country.textField?.text != countryVal.value {
                        return true
                    }
                }
            }
            
            if (pinCode.textField?.text?.trim() ?? "") != (postalAddress.postalCode ?? "") {
                return true
            }
        }
        
        
        return false
    }
    
    func checkDataIsEditted() -> Bool {
        
            
        if let editCard = delegate?.editCard {
              
            if editCard.cardNickName != cardNickName.textField?.text  {
                return true
            }
            
            if editCard.isPrimaryCard != isPrimaryBtn.isSelected  {
                return true
            }
            
            if let postalAddress = editCard.postalAddress {
                if line1.textField?.text != postalAddress.line1 {
                    return true
                }
                if line2.textField?.text != postalAddress.line2 {
                    return true
                }
                if city.textField?.text != postalAddress.city {
                    return true
                }
                if state.textField?.text != postalAddress.state {
                    return true
                }
                
                
                
                if let countryStr = postalAddress.country {
                    if let countryVal = PrimaryDataHandler.sharedInstance.countriesArr?.first(where: { (countryEntry) -> Bool in
                        return countryEntry.key == countryStr
                    }) {
                        if country.textField?.text != countryVal.value {
                            return true
                        }
                    }
                }
                
                if pinCode.textField?.text != postalAddress.postalCode {
                    return true
                }
            }
        }
            
        
        return false
    }
}
