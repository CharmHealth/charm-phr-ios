//
//  CancelAppointmentView.swift
//  phr
//
//  Created by Raghul D on 03/10/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

class CancelAppointmentView: UIView , MDTextViewDelegate , UITextViewDelegate {
    
    weak var delegate: CancelAppointmentViewController?
    
    private let reasonTV = MDTextView()
    private let lengthCountLabel = UILabel()
    private let errorLabel = UILabel()

    private let activityIndicator = UIActivityIndicatorView()

    init(delegate: CancelAppointmentViewController){
        super.init(frame: .zero)
        self.delegate = delegate
        initSubViews()
    }
    
    
    private func initSubViews(){
        
        let headingLabel = UILabel()
        let closeBtn = UIButton()
        let cancelBtn = UIButton()
        
        let scrollView = TPKeyboardAvoidingScrollView()
        let contentView = UIView()
        
        let infoLabel = UILabel()
        let appointmentListView = AppointmentListView()

        let reasonLabel = UILabel()
        addSubview(headingLabel)
        addSubview(closeBtn)
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(infoLabel)
        contentView.addSubview(appointmentListView)
        contentView.addSubview(reasonLabel)
        contentView.addSubview(reasonTV)
        contentView.addSubview(lengthCountLabel)
        contentView.addSubview(errorLabel)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(cancelBtn)

        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        headingLabel.setProperties(textKey: "com.charmphr.appointment.cancel.heading", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        
        closeBtn.setImage(UIImage(named: "Reminder_Cross"), for: .normal)
        closeBtn.setPadding(vertical: 10, horizontal: 10)
        
        closeBtn.addTarget(self, action: #selector(onCloseBtnClicked), for: .touchUpInside)
        
        infoLabel.setProperties(textKey: "com.charmphr.appointment.cancel.info", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        infoLabel.numberOfLines = 0
        
        lengthCountLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: 0x788090FF)
        
        lengthCountLabel.setText(key: "com.charmphr.appointments.cancel.reason.maxlength", with: ["0"])
        
        reasonLabel.setProperties(textKey: "com.charmphr.appointments.cancel.reason.title", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        
        reasonTV.font = .systemFont(ofSize: FONT_SIZE_VALUE_LABEL, Weight: .regular)
        reasonTV.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        
        reasonTV.textAlignment = .left
        reasonTV.layer.borderWidth = 1.0
        reasonTV.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor;
        reasonTV.layer.cornerRadius = CardSize.MEDIUM.value
        reasonTV.layer.masksToBounds = true
        reasonTV.maxLength = 500
        reasonTV.delegate = self
        
        if let appointment = delegate?.appointment {
            
            appointmentListView.setAppointmentItemValues(appointment: appointment, delegate: nil, isLast: true , hideVideoBtn: true)
            appointmentListView.rebookBtn.isHidden = true
        }
        
        cancelBtn.addPillCornerRadiusAndShadow(height: PILL_BTN_HEIGHT)
        cancelBtn.clipsToBounds = true

        cancelBtn.addTarget(self, action: #selector(onCancelAppointmentClicked), for: .touchUpInside)
        cancelBtn.setProperties(titleStrKey: "com.charmphr.appointment.cancel.submit", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: WHITE_COLOR, bgcolor: THEME_COLOR)
        
        addShadowAndCornerRadius(.LARGE)
        
        headingLabel.setLeft(offSet: X_SPACE)
        headingLabel.setRightRelatedToView(offSet: -X_SPACE, relatedView: closeBtn, relatedAttribute: .left)
        headingLabel.setTop(offSet: X_SPACE)
        
        closeBtn.setRight(offSet: -5)
        closeBtn.setTop(offSet: 5)
        closeBtn.setWidth(constant: BUTTON_HEIGHT_20 + (CARD_PADDING * 2))
        closeBtn.setHeight(constant: BUTTON_HEIGHT_20 + (CARD_PADDING * 2))
        
        scrollView.setTopRelatedToView(offSet: 6, relatedView: headingLabel, relatedAttribute: .bottom)
        scrollView.setLeft(offSet: 0)
        scrollView.setRight(offSet: 0)
        scrollView.setBottom(offSet: 0)
        
        contentView.setTop(offSet: 0)
        contentView.setBottom(offSet: 0)
        contentView.setLeft(offSet: 0)
        contentView.setHeight(constant: 480)
        contentView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        
        cancelBtn.setLeft(offSet: X_SPACE)
        cancelBtn.setRight(offSet: -X_SPACE)
        cancelBtn.setBottom(offSet: -Y_SPACE)
        cancelBtn.setHeight(constant: PILL_BTN_HEIGHT)
        
        infoLabel.setTop(offSet: 0)
        infoLabel.setLeft(offSet: X_SPACE)
        infoLabel.setRight(offSet: -X_SPACE)
        
        appointmentListView.setTopRelatedToView(offSet: 20, relatedView: infoLabel, relatedAttribute: .bottom)
        appointmentListView.setLeft(offSet: 0)
        appointmentListView.setRight(offSet: 0)
        
        reasonLabel.setTopRelatedToView(offSet: 20, relatedView: appointmentListView, relatedAttribute: .bottom)
        reasonLabel.setLeft(offSet: X_SPACE)
        
        reasonTV.setTopRelatedToView(offSet: 4, relatedView: reasonLabel, relatedAttribute: .bottom)
        reasonTV.setLeft(offSet: X_SPACE)
        reasonTV.setRight(offSet: -X_SPACE)
        reasonTV.setHeight(constant: 123)
        
        lengthCountLabel.setTopRelatedToView(offSet: 2, relatedView: reasonTV, relatedAttribute: .bottom)
        lengthCountLabel.setRight(offSet: -X_SPACE)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
    }
    
    func addConstraintPostViewLoad(){
        
        setLeft(offSet: X_SPACE)
        setRight(offSet: -X_SPACE)
        setHeight(constant: 530)
        setCenterY()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onCloseBtnClicked(){
        delegate?.dismissCancelVC()
    }
    
    @objc func onCancelAppointmentClicked(){
        
        let reason = reasonTV.text ?? ""
        
        if reason.isBlank() {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.cancel.reason.empty.error"))
            return
        }
        
        if reason.count < 5 {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.cancel.reason.mincount.error"))
            return
        }
        
        delegate?.cancelAppointment(reason: reason)
        
        //delegate?.dismiss(animated: true)
    }
    
    func mdTextViewDidChange(_ textView: MDTextView!) {
        
        let reasonTextCount = reasonTV.text?.count ?? 0
        
        lengthCountLabel.setText(key: "com.charmphr.appointments.cancel.reason.maxlength", with: ["\(reasonTextCount)"])
    }
    
    func showActivityIndicator()
    {
        self.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true
    }
}
