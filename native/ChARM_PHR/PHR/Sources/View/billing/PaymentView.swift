//
//  PaymentView.swift
//  phr
//
//  Created by Raghul D on 23/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation

class PaymentView: UIView , UITextFieldDelegate {
    let containerScrollView = TPKeyboardAvoidingScrollView()
    let containerStackView = UIStackView()
    let payBtn = UIButton(type: .custom)
    var cardOnFileBtn:UIButton? = nil
    let cardDetailsLayout = UIView()
    var infoView:InformationView? = nil
    
    var cardOnFileLayout:TextFieldLabelItemView? = nil
    let activityIndicator = UIActivityIndicatorView()

    
    let cardHolderNameTF = MDTextField()
    let cardNumberTF = MDTextField()
    let cardExpiryTF = MDTextField()
    let cardCvvTF = MDTextField()
    
    
    let monthYearPicker = MonthYearPicker()
    
    var amountPayableTF: UITextField? = nil
  //  var amount

    weak var delegate : PaymentViewController?
    
    private var maxAmount:Double = 0
    private let payBtnHeight: CGFloat = 56
    
    init(delegate: PaymentViewController) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubViews() {
  
        self.addSubview(activityIndicator)
        self.addSubview(containerScrollView)
        self.addSubview(payBtn)
        containerScrollView.addSubview(containerStackView)
        
        //Scenarios For shows stored cards
        
        //CHARGEONLY
        // Stored cards present -> Show card on file
        // Stored cards not present -> No Card on file
        
        //STOREONLY
        //Stored cards present -> Payment page will not be shown.-> Direct Appointment booking.
        // Stored cards not present -> No Card on file
        
        //STORE_CHARGE
        // Stored cards present -> Show card on file (Don't store again only charge if card is selected)
        // Stored cards not present -> No Card on file
        
        
//        debugPrintLog("chargeType -> \(paymentVC.paymentInfo?.chargeType ?? "")")
//        debugPrintLog("cardList -> \(paymentVC.cardList)")
        
        var payableView: UIView? = nil
        
        let payableAmount = delegate?.paymentInfo?.chargeAmount?.toDoubleOrNil() ?? 0.00

        if delegate?.paymentInfo?.chargeProcessingType != appointmentCardProcessingTypeStoreOnly && payableAmount > 0 {
            payableView = UIView()
        }
        
        var payableViewLabel: UILabel? = nil
        var payableViewValLabel:UILabel? = nil

        if let payableView {
            containerStackView.addArrangedSubview(payableView)

            payableViewLabel = UILabel()
            
            if let payableViewLabel {
                payableView.addSubview(payableViewLabel)
            }
            


            if let paymentVC = delegate {
                
            
                let isPartialPaymentEnabled = paymentVC.paymentInfo?.isPartialPaymentEnabled ?? false
                
                let minAmount = paymentVC.paymentInfo?.minAllowedAmount?.toDoubleOrNil() ?? 0.00
                
                if isPartialPaymentEnabled &&  minAmount < payableAmount{
                    amountPayableTF = UITextField()
                }
                
                if !paymentVC.cardList.isEmpty {
                    cardOnFileBtn = UIButton(type: .custom)
                    if let cardOnFileBtn = cardOnFileBtn {
                        containerStackView.addArrangedSubview(cardOnFileBtn)
                    }
                }
            }
            
            if let amountPayableTF = amountPayableTF {
                payableView.addSubview(amountPayableTF)
            }
            else{
                let amountPayableValLabel = UILabel()
                payableView.addSubview(amountPayableValLabel)
                payableViewValLabel = amountPayableValLabel
            }
            
        }
        
       
       
        
        
        containerStackView.addArrangedSubview(cardDetailsLayout)
        
        if cardOnFileBtn != nil {
            cardOnFileLayout = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
            if let cardOnFileLayout = cardOnFileLayout {
                cardOnFileLayout.textField?.isUserInteractionEnabled = false
                containerStackView.addArrangedSubview(cardOnFileLayout)
            }
        }
        
        
        
        let cardHolderNameView = UIView()
        cardDetailsLayout.addSubview(cardHolderNameView)
        
        let cardHolderNameLabel = UILabel()
        cardHolderNameView.addSubview(cardHolderNameLabel)
        cardHolderNameView.addSubview(cardHolderNameTF)
        
        let cardNumberView = UIView()
        cardDetailsLayout.addSubview(cardNumberView)
        
        let cardNumberLabel = UILabel()
        cardNumberView.addSubview(cardNumberLabel)
        cardNumberView.addSubview(cardNumberTF)

        let cardExpiresDateView = UIView()
        cardDetailsLayout.addSubview(cardExpiresDateView)

        let cardExpiresDateLabel = UILabel()
        cardExpiresDateView.addSubview(cardExpiresDateLabel)
        cardExpiresDateView.addSubview(cardExpiryTF)
        
    
       
        let cardCvvView = UIView()
        cardDetailsLayout.addSubview(cardCvvView)

        let cardCvvLabel = UILabel()
        cardCvvView.addSubview(cardCvvLabel)
        cardCvvView.addSubview(cardCvvTF)
        
        
        if delegate?.paymentInfo?.chargeProcessingType != appointmentCardProcessingTypeChargeOnly {
            infoView = InformationView(infoLocalisedKey: "com.charmphr.Payment.paymentNote.info")
        }
        
        if let infoView = infoView {
            containerStackView.addArrangedSubview(infoView)
        }

        //Properties
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        
        payBtn.setBackgroundColor(bgColor: THEME_COLOR)
        
        if delegate?.paymentInfo?.chargeProcessingType == appointmentCardProcessingTypeStoreOnly || payableAmount == 0 {
            payBtn.setTitle(getString(key: "com.charmphr.Payment.storeCard.title"), for: .normal)
        }
        else{
            payBtn.setTitle(getString(key:"com.charmphr.Payment.makePayment.title"), for: .normal)
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
        
        
        cardOnFileBtn?.setTitle(getString(key: "com.charmphr.payment.card.title"), for: .normal)
        cardOnFileBtn?.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        cardOnFileBtn?.setTitleColor(.black, for: .normal)
        cardOnFileBtn?.titleLabel?.textAlignment = .left
        cardOnFileBtn?.addTarget(self, action: #selector(cardOnFileBtnClicked(btn:)), for: .touchUpInside)
        cardOnFileBtn?.setImage(#imageLiteral(resourceName: "CheckboxUnselected"), for: .normal)
        cardOnFileBtn?.setImage(#imageLiteral(resourceName: "CheckboxSelected"), for: .selected)
        cardOnFileBtn?.setInsets(imageTitlePadding: 10)
        
        cardDetailsLayout.addShadowAndCornerRadius(.SMALL)
        cardHolderNameView.addBottomBorder()
        
        cardHolderNameLabel.text = getString(key: "com.charmphr.Payment.name.title")
        cardHolderNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        cardHolderNameLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
    
        cardHolderNameTF.placeholder = getString(key: "com.charmphr.Payment.name.placeholder")
        cardHolderNameTF.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        cardHolderNameTF.textAlignment = .right
        
        cardNumberView.addBottomBorder()

        cardNumberLabel.text = getString(key: "com.charmphr.Payment.cardNumber.title")
        cardNumberLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        cardNumberLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)

        cardNumberTF.placeholder = getString(key: "com.charmphr.Payment.cardNumber.placeholder")
        cardNumberTF.maxLength = 16
        cardNumberTF.delegate = self
        cardNumberTF.keyboardType = .numberPad
        cardNumberTF.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        cardNumberTF.textAlignment = .right
        
        cardExpiresDateView.addBottomBorder()

        cardExpiresDateLabel.text = getString(key: "com.charmphr.Payment.Expires.title")
        cardExpiresDateLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        cardExpiresDateLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        
        cardExpiryTF.placeholder = getString(key: "com.charmphr.Payment.Expires.placeholder")
        cardExpiryTF.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        cardExpiryTF.delegate = self
        cardExpiryTF.inputView = monthYearPicker
        
        monthYearPicker.addTarget(self, action: #selector(monthYearPickerDidChange), for: .valueChanged)

  
        cardCvvLabel.text = getString(key: "com.charmphr.Payment.CVV.title")
        cardCvvLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        cardCvvLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        
        cardCvvTF.placeholder = getString(key: "com.charmphr.Payment.CVV.placeholder")
        cardCvvTF.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        cardCvvTF.maxLength = 4
        cardCvvTF.keyboardType = .numberPad
        cardCvvTF.delegate = self
        cardCvvTF.textAlignment = .right
        
        cardOnFileLayout?.addShadowAndCornerRadius(.SMALL)
        cardOnFileLayout?.keyLabel.setText(key: "com.charmphr.Payment.card.title")
        cardOnFileLayout?.hideSeparator()
        cardOnFileLayout?.isUserInteractionEnabled = true
        cardOnFileLayout?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStoredCardListClicked(view:))))
        
        
        payableViewLabel?.text = getString(key: "com.charmphr.Payment.AmountPayable.title")
        payableViewLabel?.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        payableViewLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        
        payableView?.addShadowAndCornerRadius(.SMALL)
        
        if let amountPayableTF = amountPayableTF {
            amountPayableTF.placeholder = getString(key: "com.charmphr.Payment.AmountPayable.placeholder")
            amountPayableTF.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            amountPayableTF.keyboardType = .decimalPad
            amountPayableTF.delegate = self
            amountPayableTF.textAlignment = .right
            amountPayableTF.text = delegate?.amountPayableStr ?? ""
        }
        else{
            if let payableViewValLabel = payableViewValLabel {
                payableViewValLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
                payableViewValLabel.textAlignment = .right
                payableViewValLabel.setTextColor(fontcolor: TEXT_COLOR_BLUE)
                payableViewValLabel.text = "\(delegate?.currencySymbol ?? "") \(delegate?.amountPayableStr ?? "")".trim()
            }
            
        }
        
        cardCvvTF.placeholder = getString(key: "com.charmphr.Payment.CVV.placeholder")
        cardCvvTF.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        cardCvvTF.maxLength = 4
        cardCvvTF.keyboardType = .numberPad
        cardCvvTF.delegate = self
        cardCvvTF.textAlignment = .right
        
        
        maxAmount = delegate?.amountPayableStr.toDoubleOrNil() ?? 0
       
        //Constraints
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        // Safe-area edges keep the form clear of the Dynamic Island and the iOS 27.1 landscape side bar.
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        containerScrollView.setBottomRelatedToView(offSet: -Y_SPACE, relatedView: payBtn, relatedAttribute: .top)
        
        containerStackView.setTop(offSet: 0)
        containerStackView.setBottom(offSet: 0)
        containerStackView.setLeft(offSet: 0)
        containerStackView.setRight(offSet: 0)
        // Edge pins inside a scroll view only set content bounds; tie the width to the visible area so the
        // form follows fold/unfold and rotation (was the launch-time applicationFrame.width).
        containerStackView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor).isActive = true
        // Cards are pinned X_SPACE from both stack edges below; the card-on-file checkbox keeps its own width.
        containerStackView.alignment = .leading
        
        payBtn.setSafeAreaLeft(offset: X_SPACE)
        payBtn.setSafeAreaRight(offset: -X_SPACE)
        payBtn.setSafeAreaBottom(offset: -Y_SPACE)
        payBtn.setHeight(constant: payBtnHeight)
        
        cardOnFileBtn?.setHeight(constant: 42)
        cardOnFileBtn?.setWidth(constant: (cardOnFileBtn?.titleLabel?.sizeThatFits(CGSize(width: 200, height: 40)).width ?? 0) + 52)
        //cardOnFileBtn.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        cardOnFileBtn?.setLeft(offSet: 4)
        
        cardDetailsLayout.setLeft(offSet: X_SPACE)
        cardDetailsLayout.setRight(offSet: -X_SPACE)
            
        cardHolderNameView.setLeft(offSet: 0)
        cardHolderNameView.setRight(offSet: 0)
        cardHolderNameView.setTop(offSet: 0)
        
      //  cardHolderNameView.layer.bott
        
        cardHolderNameLabel.setLeft(offSet: X_SPACE)
        cardHolderNameLabel.setTop(offSet: 13)
        cardHolderNameLabel.setBottom(offSet: -13)
        //cardHolderNameLabel.setRightRelatedToView(offSet: -10, relatedView: cardHolderNameTF, relatedAttribute: .left)

        cardHolderNameTF.setTop(offSet: 13)
        cardHolderNameTF.setBottom(offSet: -13)
        cardHolderNameTF.setRight(offSet: -X_SPACE)
        cardHolderNameTF.setLeftRelatedToView(offSet: 10, relatedView: cardHolderNameLabel, relatedAttribute: .right)
        
        
        cardNumberView.setLeft(offSet: 0)
        cardNumberView.setRight(offSet: 0)
        cardNumberView.setTopRelatedToView(offSet: 0, relatedView: cardHolderNameView, relatedAttribute: .bottom)
        
        cardNumberLabel.setLeft(offSet: X_SPACE)
        cardNumberLabel.setTop(offSet: 13)
        cardNumberLabel.setBottom(offSet: -13)
        cardNumberLabel.setRightRelatedToView(offSet: -10, relatedView: cardNumberTF, relatedAttribute: .left)

        cardNumberTF.setCenterY()
        cardNumberTF.setRight(offSet: -X_SPACE)
        
        cardExpiresDateView.setLeft(offSet: 0)
        cardExpiresDateView.setRight(offSet: 0)
        cardExpiresDateView.setTopRelatedToView(offSet: 0, relatedView: cardNumberView, relatedAttribute: .bottom)
        
        cardExpiresDateLabel.setLeft(offSet: X_SPACE)
        cardExpiresDateLabel.setTop(offSet: 13)
        cardExpiresDateLabel.setBottom(offSet: -13)
        cardExpiresDateLabel.setRightRelatedToView(offSet: -10, relatedView: cardExpiryTF, relatedAttribute: .left)

        
        cardExpiryTF.setCenterY()
        cardExpiryTF.setRight(offSet: -X_SPACE)
        
        cardCvvView.setLeft(offSet: 0)
        cardCvvView.setRight(offSet: 0)
        cardCvvView.setTopRelatedToView(offSet: 0, relatedView: cardExpiresDateView, relatedAttribute: .bottom)
        cardCvvView.setBottom(offSet: 0)
        
        cardCvvLabel.setLeft(offSet: X_SPACE)
        cardCvvLabel.setTop(offSet: 13)
        cardCvvLabel.setBottom(offSet: -13)
        cardCvvLabel.setRightRelatedToView(offSet: -10, relatedView: cardCvvTF, relatedAttribute: .left)

        cardCvvTF.setCenterY()
        cardCvvTF.setRight(offSet: -X_SPACE)
        
        payableViewLabel?.setLeft(offSet: X_SPACE)
        payableViewLabel?.setTop(offSet: 13)
        payableViewLabel?.setBottom(offSet: -13)
        
        if let amountPayableTF = amountPayableTF {
            payableViewLabel?.setRightRelatedToView(offSet: -10, relatedView: amountPayableTF, relatedAttribute: .left)
            amountPayableTF.setCenterY()
            amountPayableTF.setRight(offSet: -X_SPACE)
        }
        else{
            if let payableViewValLabel = payableViewValLabel {
                payableViewLabel?.setRightRelatedToView(offSet: -10, relatedView: payableViewValLabel, relatedAttribute: .left)
                payableViewValLabel.setCenterY()
                payableViewValLabel.setRight(offSet: -X_SPACE)
            }
        }
        

        
        
        cardOnFileLayout?.setLeft(offSet: X_SPACE)
        cardOnFileLayout?.setRight(offSet: -X_SPACE)
        
        payableView?.setLeft(offSet: X_SPACE)
        payableView?.setRight(offSet: -X_SPACE)
        
        if let infoView = infoView {
            infoView.setLeft(offSet: X_SPACE)
            infoView.setRight(offSet: -X_SPACE)
        }

        onCardOnFileChange()
    }

    @objc func cardOnFileBtnClicked(btn: UIButton){
        
        btn.isSelected = !btn.isSelected
        onCardOnFileChange()
    }
    
    @objc func monthYearPickerDidChange(){
        let date = monthYearPicker.date
        cardExpiryTF.text = date.getStringFromDate(dateFormat: "MM / yyyy")
    }
    
    @objc func dismissKeyBoard()
    {
        self.endEditing(true)
    }
    
    
    private func onCardOnFileChange(){
        
        if let cardOnFileBtn = cardOnFileBtn, let cardOnFileLayout = cardOnFileLayout {
            if cardOnFileBtn.isSelected{
                cardOnFileLayout.showView()
                cardDetailsLayout.hideView()
                infoView?.hideView()
            }
            else{
                cardOnFileLayout.hideView()
                cardDetailsLayout.showView()
                infoView?.showView()
            }
        }
        else{
            cardDetailsLayout.showView()
            infoView?.showView()
        }
    }
    
    @objc func onStoredCardListClicked(view: UIView){
        delegate?.intentToCardListPage()
    }
    
    @objc func onPayBtnClicked(btn: UIButton){
        if validateData() {
            if let amountPayableTF = amountPayableTF {
                delegate?.paymentInfo?.chargeAmount = amountPayableTF.text ?? ""
                delegate?.paymentInfo?.transactionInfo?.paymentAmount = amountPayableTF.text ?? ""
            }
            delegate?.onCardValidationSuccess()
        }
    }
    
    func setSelectedCard(cardDetail: String){
        cardOnFileLayout?.textField?.text = cardDetail
    }
    
    func validateData() -> Bool {
        
        if let amountPayableTF = amountPayableTF {
            let amountStr = amountPayableTF.text ?? ""
            
            if let amount = amountStr.toDoubleOrNil() {
                
                if amount == 0 {
                    
                    CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_amount"), msg: nil)
                    return false
                }
                
                let minAmount = delegate?.paymentInfo?.minAllowedAmount?.toDoubleOrNil() ?? 0.00

                if amount < minAmount {
                    CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.min_amount.info" , with: ["\(delegate?.currencySymbol ?? "")\(minAmount)"]), msg: nil)
                    return false
                }
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_amount"), msg: nil)
                return false
            }
        }
        
        
        if cardOnFileLayout?.isHidden ?? true {
            
            
            if cardHolderNameTF.text.isNilOrBlank()  {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_name"), msg: nil)
                return false
            }
            else if(cardNumberTF.text.isNilOrBlank())
            {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_number"), msg: nil)
                return false
            }
            else if(cardExpiryTF.text.isNilOrBlank()){
                    CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_month"), msg: nil)

                return false
            }
            else if(cardCvvTF.text.isNilOrBlank() || (cardCvvTF.text?.count ?? 0 ) < 3){
                
                if cardCvvTF.text.isNilOrBlank() {
                    CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.empty_cvv"), msg: nil)
                }
                else{
                    CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.invalid_cvv"), msg: nil)
                }
                
                return false
            }
            let paymentInfo = delegate?.paymentInfo
            paymentInfo?.cardNumber = cardNumberTF.text
            
            let expiryDate = (cardExpiryTF.text ?? "").components(separatedBy: "/")
            paymentInfo?.cardExpMonth = expiryDate.getElement(at: 0)?.trim() ?? ""
            paymentInfo?.cardExpYear = expiryDate.getElement(at: 1)?.trim() ?? ""
          
            paymentInfo?.cardCvv = cardCvvTF.text
            paymentInfo?.cardHolderName = cardHolderNameTF.text
            
            if let amountPayableTF = amountPayableTF {
                let amountStr = amountPayableTF.text ?? ""
                paymentInfo?.chargeAmount =  amountStr
                paymentInfo?.transactionInfo?.paymentAmount = amountStr
            }


        }
        else{
            
            let cardDetail = cardOnFileLayout?.textField?.text ?? ""
            
            if cardDetail.isBlank(){
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.storedcard.empty"), msg: nil)

                return false
            }
        }
        return true
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }

        let newText = oldText.replacingCharacters(in: r, with: string)
        
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        
        if textField.keyboardType == .decimalPad {
            
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            
            let numberOfDecimalDigits: Int
            if let dotIndex = newText.firstIndex(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            
            var isSuccess = isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
            
            if textField == amountPayableTF {
                isSuccess = isSuccess &&  (newText.toDoubleOrNil() ?? 0.0 ) <= maxAmount
            }
            
            return isSuccess
        }
        
      
        return true
    }
    
}


class InformationView: UIView {
    
    private let infoLabel = UILabel()
    private let imageSize: CGFloat = 16
    
    init(infoLocalisedKey: String) {
        super.init(frame: .zero)
        infoLabel.setText(key: infoLocalisedKey)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews(){
        
        let infoImgView = UIImageView(image: UIImage(named: "info"))
        self.addSubview(infoImgView)
        self.addSubview(infoLabel)
        
        self.setBackgroundColor(bgColor: INFO_BG_COLOR)
        self.addCornerRadius(.SMALL)
        
        infoLabel.numberOfLines = 0
        infoLabel.setTextColor(fontcolor: TEXT_COLOR_BLACK87)
        infoLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        
        infoImgView.setWidth(constant: imageSize)
        infoImgView.setHeight(constant: imageSize)
        infoImgView.setLeft(offSet: 6)
        infoImgView.setTop(offSet: 8)
        
        infoLabel.setLeftRelatedToView(offSet: 6, relatedView: infoImgView, relatedAttribute: .right)
        infoLabel.setRight(offSet: -6)
        infoLabel.setTop(offSet: 6)
        infoLabel.setBottom(offSet: -6)
    }
    
    func setInfoText(infoLocalisedKey: String){
        infoLabel.setText(key: infoLocalisedKey)
    }
}

class ErrorView: UIView {
    
    private let infoLabel = UILabel()
    private let imageSize: CGFloat = 16
    
    init(infoLocalisedKey: String) {
        super.init(frame: .zero)
        infoLabel.setText(key: infoLocalisedKey)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews(){
        
        let infoImgView = UIImageView(image: UIImage(named: "error-red"))
        self.addSubview(infoImgView)
        self.addSubview(infoLabel)
        
        self.setBackgroundColor(bgColor: ERROR_BG_COLOR)
        self.addCornerRadius(.SMALL)
        
        infoLabel.numberOfLines = 0
        infoLabel.setTextColor(fontcolor: TEXT_COLOR_BLACK87)
        infoLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        
        infoImgView.setWidth(constant: imageSize)
        infoImgView.setHeight(constant: imageSize)
        infoImgView.setLeft(offSet: 6)
        infoImgView.setTop(offSet: 8)
        
        infoLabel.setLeftRelatedToView(offSet: 6, relatedView: infoImgView, relatedAttribute: .right)
        infoLabel.setRight(offSet: -6)
        infoLabel.setTop(offSet: 6)
        infoLabel.setBottom(offSet: -6)
    }
}
