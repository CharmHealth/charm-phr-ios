//
//  HealthPassportDetailView.swift
//  phr
//
//  Created by Sankar Saravanan on 30/12/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class HealthPassportDetailView: UIView
{
    
    let NAME_LABEL_TAG = 1000
    let PATIENT_INFO_LABEL_TAG = 1001
    let ADDRESS_LABEL_TAG = 1002
    let PATINET_PHOTO_VIEW_TAG = 1003
    let CONTACT_NUMBER_LABEL_TAG = 1004
    let CAREGIVER_NAME_LABEL_TAG = 1005
    let CAREGIVER_NUMBER_LABEL_TAG = 1006
    
    private let LEFT_KEY_LABEL_MAX_WIDTH = 110
    let DARK_BLUE_COLOR : UInt = 0x071F3DDB
    let BORDER_COLOR : UInt = 0x071F3D66
    
    var patient : Patient!
    var passcode : String!
    //var canShowPasscode : Bool!
    //var healthUrl : String!
    
    var healthUrlView : UIView!
    var viewPassCodeLabel : UILabel!
    //var viewHealthData : UILabel!
    
    var patientDetailContainerView = UIView()
    var passcodeView : UIView!
    
    init(frame: CGRect, patient : Patient, passcode : String) {
        super.init(frame: .zero)
        self.patient = patient
        self.passcode = passcode
       // self.canShowPasscode = canShowPasscode
       // self.healthUrl = healthUrl
        createSubViews()
        setData(patient: patient)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubViews()
    {
        
        patientDetailContainerView.backgroundColor = .white
        patientDetailContainerView.addCornerRadius(.SMALL)
        
        passcodeView = getPasscodeView(passcodeNumber: passcode)
        passcodeView.backgroundColor = .white
        passcodeView.addCornerRadius(.SMALL)
        passcodeView.isHidden = true
        
        let nameLabel = UILabel()
        nameLabel.tag = NAME_LABEL_TAG
        nameLabel.font = .systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        patientDetailContainerView.addSubview(nameLabel)
        
        let patientInfoView = UILabel()
        patientInfoView.tag = PATIENT_INFO_LABEL_TAG
        patientInfoView.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        patientInfoView.textColor = UIColorFromRGB(rgbValueWithAlpha: DARK_BLUE_COLOR)
        patientDetailContainerView.addSubview(patientInfoView)
        
        
        let addressLabel = getValueLabel()
        addressLabel.tag = ADDRESS_LABEL_TAG
        addressLabel.numberOfLines = 0
        patientDetailContainerView.addSubview(addressLabel)
        
        let contactNumberValueLabel = getValueLabel()
        contactNumberValueLabel.tag = CONTACT_NUMBER_LABEL_TAG
        patientDetailContainerView.addSubview(contactNumberValueLabel)
        
        let caregiverValueLabel = getValueLabel()
        caregiverValueLabel.tag = CAREGIVER_NAME_LABEL_TAG
        patientDetailContainerView.addSubview(caregiverValueLabel)
        
        let caregiverNumberValueLabel = getValueLabel()
        caregiverNumberValueLabel.tag = CAREGIVER_NUMBER_LABEL_TAG
        patientDetailContainerView.addSubview(caregiverNumberValueLabel)
        
        
        
        let patientPhotoImageView = ImageViewWithInitailsView(initials: "\(isNilOrEmpty(string: patient.firstName) == false ? String(patient.firstName.first!) : "")\(isNilOrEmpty(string: patient.lastName) == false ? String(patient.lastName.first!) : "")", image: patient.patientPhoto)
        patientPhotoImageView.addCornerRadius(.SMALL)
        patientPhotoImageView.tag = PATINET_PHOTO_VIEW_TAG
        patientDetailContainerView.addSubview(patientPhotoImageView)
        
        let contactNumberKeyLabel = getKeyLabel(text: getString(key: "com.charmphr.Demographics.ContactNo.title"))
        contactNumberKeyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        patientDetailContainerView.addSubview(contactNumberKeyLabel)
        
        let caregiverKeyLabel = getKeyLabel(text: getString(key: "com.charmphr.Demographics.CaregiverName.title"))
        caregiverKeyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        patientDetailContainerView.addSubview(caregiverKeyLabel)
        
        let caregiverNumberKeyLabel = getKeyLabel(text: getString(key: "com.charmphr.Demographics.CaregiverNo.title"))
        caregiverNumberKeyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        patientDetailContainerView.addSubview(caregiverNumberKeyLabel)
        
        //this view is for aligning the left views and the right view at the same level
        let leftviewContinerView = UIView()
        leftviewContinerView.backgroundColor = .yellow
        patientDetailContainerView.addSubview(leftviewContinerView)
    
        leftviewContinerView.setTop(offSet: 0)
        leftviewContinerView.setBottom(offSet: 0)
        leftviewContinerView.setWidth(constant: 0)
        
        patientPhotoImageView.setWidth(constant: 96)
        patientPhotoImageView.setHeight(constant: 112
        )
        patientPhotoImageView.setLeft(offSet: 8)
        patientPhotoImageView.setTop(offSet: 8)
        
        patientPhotoImageView.setTopRelatedToView(offSet: 0, relatedView:nameLabel , relatedAttribute: .top)
        patientPhotoImageView.setBottomRelatedToView(offSet: 0, relatedView:addressLabel , relatedAttribute: .bottom)
        
        nameLabel.setLeftRelatedToView(offSet: 0, relatedView: leftviewContinerView, relatedAttribute: .right)
        nameLabel.setRightRelatedToView(offSet: -8, relatedView: patientDetailContainerView, multiplier: 1, relatedAttribute: .right, relatedBy: .lessThanOrEqual)
        nameLabel.setTop(offSet: 8)
        
        patientInfoView.setLeftRelatedToView(offSet: 0, relatedView: leftviewContinerView, relatedAttribute: .right)
        patientInfoView.setTopRelatedToView(offSet: 3, relatedView: nameLabel, relatedAttribute: .bottom)
        patientInfoView.setRightRelatedToView(offSet: -8, relatedView: patientDetailContainerView, multiplier: 1, relatedAttribute: .right, relatedBy: .lessThanOrEqual)
        
//        addressLabel.setTopRelatedToView(offSet: 8, relatedView: patientInfoView, relatedAttribute: .bottom)
        addressLabel.setLeftRelatedToView(offSet: 0, relatedView: leftviewContinerView, relatedAttribute: .right)
        addressLabel.setRightRelatedToView(offSet: -8, relatedView: patientDetailContainerView, multiplier: 1, relatedAttribute: .right, relatedBy: .lessThanOrEqual)
        addressLabel.setBottomRelatedToView(offSet: 0, relatedView: patientPhotoImageView, relatedAttribute: .bottom)
        
        contactNumberValueLabel.setCenterYWithOffset(offset: 0, view: contactNumberKeyLabel)
        contactNumberValueLabel.setLeftRelatedToView(offSet: 0, relatedView: leftviewContinerView, relatedAttribute: .right)
        contactNumberValueLabel.setRightRelatedToView(offSet: -8, relatedView: patientDetailContainerView, multiplier: 1, relatedAttribute: .right, relatedBy: .lessThanOrEqual)
        
        caregiverValueLabel.setCenterYWithOffset(offset: 0, view: caregiverKeyLabel)
        caregiverValueLabel.setLeftRelatedToView(offSet: 0, relatedView: leftviewContinerView, relatedAttribute: .right)
        caregiverValueLabel.setRightRelatedToView(offSet: -8, relatedView: patientDetailContainerView, multiplier: 1, relatedAttribute: .right, relatedBy: .lessThanOrEqual)
        
        caregiverNumberValueLabel.setCenterYWithOffset(offset: 0, view: caregiverNumberKeyLabel)
        caregiverNumberValueLabel.setLeftRelatedToView(offSet: 0, relatedView: leftviewContinerView, relatedAttribute: .right)
        caregiverNumberValueLabel.setRightRelatedToView(offSet: -8, relatedView: patientDetailContainerView, multiplier: 1, relatedAttribute: .right, relatedBy: .lessThanOrEqual)
        
        contactNumberKeyLabel.setTopRelatedToView(offSet: 8, relatedView: addressLabel, multiplier: 1, relatedAttribute: .bottom ,relatedBy: .greaterThanOrEqual)
        contactNumberKeyLabel.setTopRelatedToView(offSet: 8, relatedView: patientPhotoImageView, multiplier: 1, relatedAttribute: .bottom ,relatedBy: .greaterThanOrEqual)
        contactNumberKeyLabel.setLeft(offSet: 8)
        contactNumberKeyLabel.setRightRelatedToView(offSet: -8, relatedView: leftviewContinerView, multiplier: 1, relatedAttribute: .left, relatedBy: .lessThanOrEqual)
        
        caregiverKeyLabel.setTopRelatedToView(offSet: 5, relatedView: contactNumberKeyLabel, relatedAttribute: .bottom)
        caregiverKeyLabel.setLeft(offSet: 8)
        caregiverKeyLabel.setRightRelatedToView(offSet: -8, relatedView: leftviewContinerView, multiplier: 1, relatedAttribute: .left, relatedBy: .lessThanOrEqual)
        
        caregiverNumberKeyLabel.setTopRelatedToView(offSet: 5, relatedView: caregiverKeyLabel, relatedAttribute: .bottom)
        caregiverNumberKeyLabel.setLeft(offSet: 8)
        caregiverNumberKeyLabel.setRightRelatedToView(offSet: -8, relatedView: leftviewContinerView, multiplier: 1, relatedAttribute: .left, relatedBy: .lessThanOrEqual)
        caregiverNumberKeyLabel.wrapWidth(maxWidth: 200)
        
        //NOTE: We have changed the design now
//        if canShowPasscode
//        {
//
//            let healthUrlKeyLabel = getKeyLabel(text: getString(key: "com.charmphr.Demographics.HealthURL.title"))
       //     healthUrlKeyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//            patientDetailContainerView.addSubview(healthUrlKeyLabel)
//
//            healthUrlView = getKeyLabel(text: healthUrl)
//            healthUrlView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//            patientDetailContainerView.addSubview(healthUrlView)
//
//            healthUrlKeyLabel.setTopRelatedToView(offSet: 5, relatedView: caregiverNumberKeyLabel, relatedAttribute: .bottom)
//            healthUrlKeyLabel.setLeft(offSet: 8)
//            healthUrlKeyLabel.setRightRelatedToView(offSet: -8, relatedView: leftviewContinerView, multiplier: 1, relatedAttribute: .left, relatedBy: .lessThanOrEqual)
//
//            healthUrlView.setCenterYWithOffset(offset: 0, view: healthUrlKeyLabel)
//            healthUrlView.setLeftRelatedToView(offSet: 0, relatedView: leftviewContinerView, relatedAttribute: .right)
//            healthUrlView.setRightRelatedToView(offSet: -8, relatedView: patientDetailContainerView, multiplier: 1, relatedAttribute: .right, relatedBy: .lessThanOrEqual)
//            healthUrlView.setBottom(offSet: -8)
//
//            viewPassCodeLabel = UILabel()
//            viewPassCodeLabel.text = NSLocalizedString("com.charmphr.Demographics.ViewPasscode.title", comment: "")
//            viewPassCodeLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
//            viewPassCodeLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: 0xED9A00FF)
//            viewPassCodeLabel.isUserInteractionEnabled = true
//            patientDetailContainerView.addSubview(viewPassCodeLabel)
//
//            viewPassCodeLabel.setRight(offSet: -10)
//            viewPassCodeLabel.setWidth(constant: viewPassCodeLabel.sizeThatFits(CGSize(width: 100, height: 100)).width)
//            viewPassCodeLabel.setTopRelatedToView(offSet: 4, relatedView: caregiverNumberKeyLabel, relatedAttribute: .bottom)
//
//        }else
//        {
            caregiverNumberKeyLabel.setBottom(offSet: -8)
      //  }
        
        self.addSubview(patientDetailContainerView)
        self.addSubview(passcodeView)
        
        patientDetailContainerView.setTop(offSet: 0)
        patientDetailContainerView.setLeft(offSet: 0)
        patientDetailContainerView.setRight(offSet: 0)
        patientDetailContainerView.setBottom(offSet: 0)
        
        let htConst = NSLayoutConstraint(item: passcodeView!, attribute: .height, relatedBy: .equal, toItem: patientDetailContainerView, attribute: .height, multiplier: 1, constant: 0)
        self.addConstraint(htConst)
        let wtConst = NSLayoutConstraint(item: passcodeView!, attribute: .width, relatedBy: .equal, toItem: patientDetailContainerView, attribute: .width, multiplier: 1, constant: 0)
        self.addConstraint(wtConst)
        
        passcodeView.setLeft(offSet: 0)
        passcodeView.setTop(offSet: 0)
        
    }
    
    func getValueLabel() -> UILabel
    {
        let label = UILabel()
        // we can set value afterwards
//        label.text = text
        label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DFF)
        label.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
        return label
    }
    
    func getKeyLabel(text:String) -> UILabel
    {
        let label = UILabel()
        label.text = text
        label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x094B9DFF)
        label.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        return label
    }
    
    func getPasscodeView(passcodeNumber : String) -> UIView
    {
        let containerView = UIView()
        
        containerView.backgroundColor = .white
        
        let healthCardTitleLabel = UILabel()
        healthCardTitleLabel.text = getString(key: "com.charmphr.Demographics.passcode.Healthcard.title")
        healthCardTitleLabel.font = .systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        healthCardTitleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DFF)
        containerView.addSubview(healthCardTitleLabel)
        
        let healthCardSubTitleLabel = UILabel()
        healthCardSubTitleLabel.text = getString(key: "com.charmphr.Demographics.passcode.Healthcard.subtitle")
        healthCardSubTitleLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        healthCardSubTitleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DDB)
        containerView.addSubview(healthCardSubTitleLabel)
        
        let point1DotView = UIView()
        point1DotView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR)
        containerView.addSubview(point1DotView)
        
        let healthCardPoint1Label = UILabel()
        healthCardPoint1Label.text = getString(key: "com.charmphr.Demographics.passcode.point1.title")
        healthCardPoint1Label.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        healthCardPoint1Label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DDB)
        containerView.addSubview(healthCardPoint1Label)
        
        let point2DotView = UIView()
        point2DotView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR)
        containerView.addSubview(point2DotView)
        
        let healthCardPoint2Label = UILabel()
        healthCardPoint2Label.text = getString(key: "com.charmphr.Demographics.passcode.point2.title")
        healthCardPoint2Label.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        healthCardPoint2Label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DDB)
        containerView.addSubview(healthCardPoint2Label)
        
        let point3DotView = UIView()
        point3DotView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR)
        containerView.addSubview(point3DotView)
        
        let healthCardPoint3Label = UILabel()
        healthCardPoint3Label.text = getString(key: "com.charmphr.Demographics.passcode.point3.title")
        healthCardPoint3Label.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        healthCardPoint3Label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DDB)
        containerView.addSubview(healthCardPoint3Label)
        
        let passcodeNumberlabel = UILabel()
        passcodeNumberlabel.text = passcodeNumber
        passcodeNumberlabel.font = .systemFont(ofSize: FONT_SIZE_TWENTY, Weight: .semibold)
        passcodeNumberlabel.textColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR)
        containerView.addSubview(passcodeNumberlabel)
        
        let passcodeNumbertitleLabel = UILabel()
        passcodeNumbertitleLabel.text = getString(key: "com.charmphr.Demographics.passcode.title")
        passcodeNumbertitleLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        containerView.addSubview(passcodeNumbertitleLabel)
        
        
        healthCardTitleLabel.setTop(offSet: 13)
        healthCardTitleLabel.setLeft(offSet: 15)
        healthCardTitleLabel.setRight(offSet: -15)
        healthCardTitleLabel.setBottomRelatedToView(offSet: -2, relatedView: healthCardSubTitleLabel, relatedAttribute: .top)
        
        healthCardSubTitleLabel.setLeft(offSet: 15)
        healthCardSubTitleLabel.setRight(offSet: -15)
        healthCardSubTitleLabel.setBottomRelatedToView(offSet: -15, relatedView: healthCardPoint1Label, relatedAttribute: .top)
        
        point1DotView.setHeight(constant: 4)
        point1DotView.setWidth(constant: 4)
        point1DotView.layer.cornerRadius = 2
        point1DotView.setLeft(offSet: 15)
        point1DotView.setCenterY(view: healthCardPoint1Label)
        point1DotView.setRightRelatedToView(offSet: -6, relatedView: healthCardPoint1Label, relatedAttribute: .left)
        
        healthCardPoint1Label.setRight(offSet: -15)
        healthCardPoint1Label.setBottomRelatedToView(offSet: -2, relatedView: healthCardPoint2Label, relatedAttribute: .top)
        
        point2DotView.setHeight(constant: 4)
        point2DotView.setWidth(constant: 4)
        point2DotView.layer.cornerRadius = 2
        point2DotView.setLeft(offSet: 15)
        point2DotView.setCenterY(view: healthCardPoint2Label)
        point2DotView.setRightRelatedToView(offSet: -6, relatedView: healthCardPoint2Label, relatedAttribute: .left)
        
        healthCardPoint2Label.setRight(offSet: -15)
        healthCardPoint2Label.setBottomRelatedToView(offSet: -2, relatedView: healthCardPoint3Label, relatedAttribute: .top)
        
        point3DotView.setHeight(constant: 4)
        point3DotView.setWidth(constant: 4)
        point3DotView.layer.cornerRadius = 2
        point3DotView.setLeft(offSet: 15)
        point3DotView.setCenterY(view: healthCardPoint3Label)
        point3DotView.setRightRelatedToView(offSet: -6, relatedView: healthCardPoint3Label, relatedAttribute: .left)
        
        healthCardPoint3Label.setRight(offSet: -15)
        
        let bottomConst = NSLayoutConstraint(item: healthCardPoint3Label, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: passcodeNumberlabel, attribute: .top, multiplier: 1, constant: -10)
        containerView.addConstraint(bottomConst)
        
        passcodeNumberlabel.setCenterX()
        passcodeNumberlabel.setBottomRelatedToView(offSet: -6, relatedView: passcodeNumbertitleLabel, relatedAttribute: .top)
        
        passcodeNumbertitleLabel.setCenterX()
        passcodeNumbertitleLabel.setBottom(offSet: -20)
        
//        viewHealthData = UILabel()
//        viewHealthData.text = NSLocalizedString("com.charmphr.Demographics.viewHealthData.title", comment: "")
//        viewHealthData.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
//        viewHealthData.textColor = UIColorFromRGB(rgbValueWithAlpha: 0xED9A00FF)
//        viewPassCodeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPasscodeClicked)))
//        viewHealthData.isUserInteractionEnabled = true
//        containerView.addSubview(viewHealthData)
//
//        viewHealthData.setRight(offSet: -10)
//        viewHealthData.setWidth(constant: viewHealthData.sizeThatFits(CGSize(width: 100, height: 100)).width)
//        viewHealthData.setTopRelatedToView(offSet: 4, relatedView: passcodeNumberlabel, relatedAttribute: .bottom)
        
        return containerView
    }
     
    func getPatientDetailIndividualView(key:String , value: String?) -> UIView
    {
        let patientDetailIndividualView = UIView()
        
        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x094B9DDE)
        patientDetailIndividualView.addSubview(keyLabel)
        
        let valueLabel = UILabel()
        if isNilOrEmpty(string: value)
        {
            valueLabel.text = "-"
        }else
        {
            valueLabel.text = value
        }
        valueLabel.numberOfLines = 0
        valueLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        patientDetailIndividualView.addSubview(valueLabel)
        
        keyLabel.setTop(offSet: 4)
        keyLabel.setLeft(offSet: 7)
        keyLabel.setRightRelatedToView(offSet: -5, relatedView: valueLabel, relatedAttribute: .left)
        keyLabel.setWidth(constant: CGFloat(LEFT_KEY_LABEL_MAX_WIDTH))
        
        valueLabel.setTop(offSet: 4)
        valueLabel.setBottom(offSet: -4)
        valueLabel.setRight(offSet: -7)
        
        return patientDetailIndividualView
    }
    
    func setData( patient : Patient)
    {
        
        if let label = self.viewWithTag(NAME_LABEL_TAG) as? UILabel
        {
            label.text = "\(patient.firstName ?? "") \(patient.lastName ?? "")"
        }
        
        if let label = self.viewWithTag(PATIENT_INFO_LABEL_TAG) as? UILabel
        {
            var valueString : NSMutableAttributedString?
            let lineColorAtributes = [NSAttributedString.Key.foregroundColor : UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR)]
            let redTextColorAtributes = [NSAttributedString.Key.foregroundColor : UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_RED)]
            let borderAttibutedStr = NSMutableAttributedString(string: " | ", attributes: lineColorAtributes)
            
            valueString  =  NSMutableAttributedString(string: patient.gender.capitalizingFirstLetter() )
            valueString?.append(NSAttributedString(attributedString: borderAttibutedStr))
            valueString?.append(NSAttributedString(string: CharmUtil.getDateStringWith(date: patient.dateOfBirth!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)))
            valueString?.append(NSAttributedString(attributedString: borderAttibutedStr))
            valueString?.append(NSMutableAttributedString(string: patient.bloodGroup ?? "" , attributes: redTextColorAtributes))
            label.attributedText = valueString
        }
        
        if let label = self.viewWithTag(ADDRESS_LABEL_TAG) as? UILabel
        {
            
            var addressArr: [String] = [];
            
            if let address = patient.postalAddress {
                
                if !address.line1.isNilOrBlank() {
                    addressArr.append(address.line1 ?? "")
                }
                if !address.line2.isNilOrBlank() {
                    addressArr.append(address.line2 ?? "")
                }
                if !address.city.isNilOrBlank() {
                    addressArr.append(address.city ?? "")
                }
                if !address.state.isNilOrBlank() {
                    addressArr.append(address.state ?? "")
                }
                if !address.postalCode.isNilOrBlank() {
                    addressArr.append(address.postalCode ?? "")
                }
                
            }
           
            
            let addressAtributtedStr = NSMutableAttributedString(string: addressArr.joined(separator: ", "))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3.5
            addressAtributtedStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, addressAtributtedStr.string.count))
            label.attributedText = addressAtributtedStr
        }
        
        if let imageViewWithInitailsView = self.viewWithTag(PATINET_PHOTO_VIEW_TAG) as? ImageViewWithInitailsView
        {
            imageViewWithInitailsView.setInitialsAndImage(initials: "\(isNilOrEmpty(string: patient.firstName) == false ? String(patient.firstName.first!) : "")\(isNilOrEmpty(string: patient.lastName) == false ? String(patient.lastName.first!) : "")", image: patient.patientPhoto)
        }
        
        let attributedText = NSMutableAttributedString(string: getString(key: "com.charmphr.common.notAvailable"))
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)], range: NSRange(location: 0, length:attributedText.string.count))
        
        if let label = self.viewWithTag(CONTACT_NUMBER_LABEL_TAG) as? UILabel
        {
            if isNilOrEmpty(string: patient.contactDetail?.mobile)
            {
                label.attributedText = attributedText
            }else
            {
                label.text = patient.contactDetail?.mobile
                label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DFF)
            }
        }
        
        if let label = self.viewWithTag(CAREGIVER_NAME_LABEL_TAG) as? UILabel
        {
            if isNilOrEmpty(string: patient.primaryCaregiver?.firstName)
            {
                label.attributedText = attributedText
            }else
            {
                label.text = patient.primaryCaregiver?.firstName
                label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DFF)
            }
        }
        
        if let label = self.viewWithTag(CAREGIVER_NUMBER_LABEL_TAG) as? UILabel
        {
            if isNilOrEmpty(string: patient.primaryCaregiver?.mobile)
            {
                label.attributedText = attributedText
            }else
            {
                label.text = patient.primaryCaregiver?.mobile
                label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DFF)
            }
        }
        
    }
    
}

