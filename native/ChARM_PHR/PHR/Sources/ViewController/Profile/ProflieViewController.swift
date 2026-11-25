//
//  ProflieViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 13/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let logoutColor:UInt = 0xFE3C30FF

class ProfileViewController: UIViewController , DemographicsViewControllerDidChangeValueDelegate, AddViewControllerDelegate, HKPatientSelectVCDelegate, HKPatientSelectCancelDelegate
{
    let PATIENT_VIEW_STARTING_TAG = 1000
    let PROFILE_IMAGE_VIEW_TAG = 999
    let SELECTED_PATIENT_NAME_VIEW_TAG = 998
    let SELECTED_PATIENT_GENDER_VIEW_TAG = 997
    
    var demographicsValueChangedDelegate : DemographicsViewControllerDidChangeValueDelegate?
    let activityIndicatorView = UIActivityIndicatorView()
    var appDataHandler = AppDataHandler.sharedInstance()
    
    private var hkSettingsViewHeightConstraint:NSLayoutConstraint? = nil
    
    private var hkPatientLabel:UILabel? = nil
    private var hkPatientSelectView: UIView? = nil
    
    private let analyticsSwitch = UISwitch()
    private var healthSwitch: UISwitch?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        self.setLargeTitle(enable: false)
        
        self.navigationItem.title = getString(key: "com.charmphr.profile.title")
        createSubViews()
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = .lightGray
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.setCenterY()
        activityIndicatorView.setCenterX()
    }
    
    private func createSubViews()
    {
        let profileImageSize : CGFloat = 100
        
        let containerScrollView = UIScrollView()
        let containerView = UIView()
        
        self.view.addSubview(containerScrollView)
        containerScrollView.addSubview(containerView)
        
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addCornerRadius(.SMALL)
        
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        // Edge pins inside a scroll view only set content bounds; this ties the width to the visible area.
        containerView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor).isActive = true

        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        
        let profileImageView = ImageViewWithInitailsView()
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleToFill
        
        let patient = Patient.selectedPatientInstance ?? Patient()
        profileImageView.setInitialsAndImage(initials: patient.fullName?.formInitials() ?? "", image: patient.patientPhoto)
        profileImageView.tag = PROFILE_IMAGE_VIEW_TAG
        profileImageView.layer.cornerRadius = profileImageSize / 2
        profileImageView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        containerView.addSubview(profileImageView)
        
        let namelabel = UILabel()
        namelabel.text = patient.fullName ?? ""
        namelabel.font = .systemFont(ofSize: FONT_SIZE_TWENTY, Weight: .semibold)
        namelabel.tag = SELECTED_PATIENT_NAME_VIEW_TAG
        containerView.addSubview(namelabel)
        
        let genderAndAgelabel = UILabel()
        if (patient.age > 0){
            genderAndAgelabel.text = "\(patient.gender.capitalized), \(patient.age ?? 0) Years"
        }
        else{
            genderAndAgelabel.text = patient.gender.capitalized
        }
        genderAndAgelabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        genderAndAgelabel.tag = SELECTED_PATIENT_GENDER_VIEW_TAG
        containerView.addSubview(genderAndAgelabel)
        
        profileImageView.setHeight(constant: profileImageSize)
        profileImageView.setWidth(constant: profileImageSize)
        profileImageView.setCenterX()
        profileImageView.setTop(offSet: Y_SPACE)
        
        namelabel.setTopRelatedToView(offSet: Y_SPACE, relatedView: profileImageView, relatedAttribute: .bottom)
        namelabel.setCenterX()
        
        genderAndAgelabel.setTopRelatedToView(offSet: 4, relatedView: namelabel, relatedAttribute: .bottom)
        genderAndAgelabel.setCenterX()
        
        let stackView = UIStackView()
        containerView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        
        stackView.setLeft(offSet: X_SPACE)
        stackView.setRight(offSet: -X_SPACE)
        stackView.setBottom(offSet: -Y_SPACE)
        
        if (Patient.patientList?.count ?? 0 ) > 1
        {
            let linkedAccountView = UIView()
            let linkedAccountSubView = UIView()
            
            linkedAccountSubView.addShadowAndCornerRadius(.LARGE, shadowOffset: .zero)
            
            let linkedAccountLabel = UILabel()
            
            linkedAccountLabel.text = getString(key: "com.charmphr.linkedAccount.title")
            linkedAccountLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
            linkedAccountLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_HEAVYDARK)
            
            linkedAccountView.addSubview(linkedAccountLabel)
            linkedAccountView.addSubview(linkedAccountSubView)
            
            linkedAccountLabel.setTop(offSet: 0)
            linkedAccountLabel.setLeft(offSet: 0)
            linkedAccountLabel.setRight(offSet: 0)
            
            linkedAccountSubView.setLeft(offSet: 0)
            linkedAccountSubView.setRight(offSet: 0)
            linkedAccountSubView.setTopRelatedToView(offSet: 11, relatedView: linkedAccountLabel, relatedAttribute: .bottom)
            linkedAccountSubView.setBottom(offSet: 0)
            
            var previousPatientView : UIView?
            
            if let patientList = Patient.patientList {
                
                for (index, patient) in patientList.enumerated() {
                    
                    if patient.patientId != Patient.selectedPatientInstance?.patientId {
                        let patientView = createPatientView(patient: patient)
                        
                        patientView.tag = PATIENT_VIEW_STARTING_TAG + index
                        patientView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(patientSelected(tapGesture:))))
                        linkedAccountSubView.addSubview(patientView)
                        patientView.setLeft(offSet: 0)
                        patientView.setRight(offSet: 0)
                        
                        if let previousPatientView = previousPatientView
                        {
                            patientView.setTopRelatedToView(offSet: 0, relatedView: previousPatientView, relatedAttribute: .bottom)
                        }else
                        {
                            patientView.setTop(offSet: 0)
                            if Patient.patientList!.count > 2
                            {
                                // patientView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CORNER_RADIUS_5)
                            }
                        }
                        
                        patientView.setLeft(offSet: 0 )
                        patientView.setRight(offSet: 0)
                        
                        if Patient.patientList!.count == 2
                        {
                            // patientView.layer.cornerRadius = CORNER_RADIUS_5
                        }
                        previousPatientView = patientView
                    }
                    
                    if previousPatientView != nil && patientList.last?.patientId == patient.patientId
                    {
                        
                        if patientList.count > 2
                        {
                            // previousPatientView?.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CORNER_RADIUS_5)
                        }
                        previousPatientView?.setBottom(offSet: 0)
                    }
                    else if previousPatientView != nil && patientList.last?.patientId != patient.patientId {
                        let horizontalLine = UIView()
                        linkedAccountSubView.addSubview(horizontalLine)
                        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
                        
                        horizontalLine.setLeft(offSet: 50)
                        horizontalLine.setRight(offSet: 0)
                        horizontalLine.setHeight(constant: 1)
                        if let previousPatientView = previousPatientView{
                            horizontalLine.setTopRelatedToView(offSet: 0, relatedView: previousPatientView, relatedAttribute: .bottom)
                        }
                        previousPatientView = horizontalLine
                    }
                }
            }
            stackView.addArrangedSubview(linkedAccountView)
            stackView.setCustomSpacing(20, after: linkedAccountView)
            
            stackView.setTopRelatedToView(offSet: 15, relatedView: genderAndAgelabel, relatedAttribute: .bottom)
        }
        else{
            stackView.setTopRelatedToView(offSet: 20, relatedView: genderAndAgelabel, relatedAttribute: .bottom)
        }
        
        let myViewLabel = UILabel()
        stackView.addArrangedSubview(myViewLabel)
        
        myViewLabel.setProperties(textKey: "com.charmphr.MyInfo.title", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        let demoView = SectionsItemView()
        stackView.addArrangedSubview(demoView)
        stackView.setCustomSpacing(20, after: demoView)
        
        demoView.setModuleLabel(labelKey: "com.charmphr.Demographics.title")
        demoView.setModuleIcon(namedImage: "HP_profile_image")
        demoView.addShadowAndCornerRadius(.LARGE, shadowOffset: .zero)
        demoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(demographicsViewClicked)))
        
        let feedbackLabel = UILabel()
        let feedbackView = UIView()
        
        stackView.addArrangedSubview(feedbackLabel)
        stackView.addArrangedSubview(feedbackView)
        stackView.setCustomSpacing(20, after: feedbackView)
        
        let contactView = SectionsItemView()
        let appFeedbackView = SectionsItemView()
        let contactSeparator = UIView()
        
        feedbackView.addSubview(contactView)
        feedbackView.addSubview(contactSeparator)
        feedbackView.addSubview(appFeedbackView)
        
        feedbackView.addShadowAndCornerRadius(.LARGE, shadowOffset: .zero)
        feedbackLabel.setProperties(textKey: "com.charmphr.feedback.title", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        contactSeparator.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        
        contactView.setModuleLabel(labelKey: "com.charmphr.profile.contactPractice.title")
        contactView.setModuleIcon(namedImage: "contact_practice")
        contactView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushPracticeFeedback)))
        
        appFeedbackView.setModuleLabel(labelKey: "com.charmphr.profile.contactUs.title")
        appFeedbackView.setModuleIcon(namedImage: "ContactUs")
        appFeedbackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushCharmFeedback)))
        
        contactView.setTop(offSet: 0)
        contactView.setLeft(offSet: 0)
        contactView.setRight(offSet: 0)
        
        contactSeparator.setTopRelatedToView(offSet: 0, relatedView: contactView, relatedAttribute: .bottom)
        contactSeparator.setLeft(offSet: 0)
        contactSeparator.setRight(offSet: 0)
        contactSeparator.setHeight(constant: SEPARATOR_HEIGHT)
        
        appFeedbackView.setLeft(offSet: 0)
        appFeedbackView.setRight(offSet: 0)
        appFeedbackView.setTopRelatedToView(offSet: 0, relatedView: contactSeparator, relatedAttribute: .bottom)
        appFeedbackView.setBottom(offSet: 0)
        
        createHealthKitView(parentView: stackView)
        
        
        let otherSettingLabel = UILabel()
        stackView.addArrangedSubview(otherSettingLabel)
        
        otherSettingLabel.setProperties(textKey: "com.charmphr.OtherSetting.title", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        let otherSettingView = UIView()
        let analyticsIcon = UIImageView()
        let analyticsLabel = UILabel()
        let analyticsInfo = UILabel()
        
        stackView.addArrangedSubview(otherSettingView)
        stackView.setCustomSpacing(20, after: otherSettingView)
        otherSettingView.addSubview(analyticsIcon)
        otherSettingView.addSubview(analyticsLabel)
        otherSettingView.addSubview(analyticsSwitch)
        otherSettingView.addSubview(analyticsInfo)
        
        otherSettingView.addShadowAndCornerRadius(.LARGE, shadowOffset: .zero)
        
        // TODO(Apptics): disabled until verified; re-enable later
        //analyticsSwitch.isOn = Apptics.trackingStatus()
        analyticsSwitch.addTarget(self, action: #selector(onAnalyticsSwitch), for: .valueChanged)
        
        analyticsLabel.setProperties(textKey: "com.charmphr.profile.analytics.title", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        analyticsInfo.setProperties(textKey: "com.charmphr.profile.analytics.info", fontsize: FONT_SIZE_MEDIUM, weight: .medium, fontcolor: TEXT_COLOR_LIGHT)
        analyticsInfo.numberOfLines = 0
        
        analyticsIcon.image = UIImage(named: "analytics")
        
        analyticsIcon.setWidth(constant: 36)
        analyticsIcon.setTop(offSet: 5)
        analyticsIcon.setLeft(offSet: 10)
        
        analyticsLabel.setCenterY(view: analyticsIcon)
        analyticsLabel.setLeftRelatedToView(offSet: 8, relatedView: analyticsIcon, relatedAttribute: .right)
        analyticsLabel.wrapHeight(maxHeight: 50)
        
        analyticsSwitch.setRight(offSet: -10)
        analyticsSwitch.setCenterY(view: analyticsIcon)
        
        analyticsInfo.setLeftRelatedToView(offSet: 0, relatedView: analyticsLabel, relatedAttribute: .left)
        analyticsInfo.setRightRelatedToView(offSet: -8, relatedView: analyticsSwitch, relatedAttribute: .left)
        analyticsInfo.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN * 2, relatedView: analyticsLabel, relatedAttribute: .bottom)
        analyticsInfo.setBottom(offSet: -10)
        
        let logoutView = SectionsItemView()
        stackView.addArrangedSubview(logoutView)

        logoutView.setModuleLabel(labelKey: "com.charmphr.profile.LogOut.title")
        logoutView.setModuleIcon(namedImage: "Logout")
        logoutView.setModuleTextColor(textcolor: logoutColor)
        logoutView.addShadowAndCornerRadius(.LARGE, shadowOffset: .zero)
        logoutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signOutBtnClicked)))
    }
    
    private func createHealthKitView(parentView: UIStackView){
        
        let hkSettingsLabel = UILabel()
        let hkSettingsView = UIStackView()
        
        parentView.addArrangedSubview(hkSettingsLabel)
        parentView.addArrangedSubview(hkSettingsView)
        parentView.setCustomSpacing(20, after: hkSettingsView)
        
        let healthIV = UIImageView(image: UIImage(named: "health-kit"))
        var goIcon: UIImageView? = nil
        
        if (Patient.patientList?.count ?? 0) > 1 {
            goIcon = UIImageView(image: UIImage(named: "section-arrow-right"))
        }
        
        let healthDetailContainer = UIView()
        let healthHeading = UILabel()
        let healthPlaceholder = UILabel()
        let patientLabel = UILabel()
        let healthSubHeading = UILabel()
        let healthSwitch = UISwitch()
        let separator = UIView()
        let patientView = UIView()
        
        hkSettingsView.addArrangedSubview(healthDetailContainer)
        healthDetailContainer.addSubview(healthIV)
        healthDetailContainer.addSubview(healthHeading)
        healthDetailContainer.addSubview(healthSubHeading)
        healthDetailContainer.addSubview(healthSwitch)
        self.healthSwitch = healthSwitch
        hkSettingsView.addArrangedSubview(patientView)
        
        patientView.addSubview(separator)
        patientView.addSubview(patientLabel)
        patientView.addSubview(healthPlaceholder)
        
        
        hkSettingsView.axis = .vertical
        hkSettingsView.alignment = .fill
        hkSettingsView.spacing = 0
        
        if let goIcon {
            patientView.addSubview(goIcon)
            patientView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentHKPatientSelectVC)))
        }
        
        separator.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        healthIV.addShadowAndCornerRadius(.SMALL)
        hkSettingsLabel.setProperties(textKey: "com.charmphr.wellness.healthkit.sync.heading", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        healthHeading.setProperties(textKey: "com.charmphr.wellness.healthkit.sync.item.heading", fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
        healthSubHeading.setProperties(textKey: "com.charmphr.wellness.healthkit.sync.item.subheading", fontsize: FONT_SIZE_MEDIUM, weight: .regular, fontcolor: TEXT_COLOR_LIGHT)
        
        
        healthPlaceholder.setProperties(textKey: "com.charmphr.wellness.healthkit.sync.value.placeholder", fontsize: FONT_SIZE_MEDIUM, weight: .regular, fontcolor: TEXT_COLOR_LIGHT)
        
        patientLabel.setProperties( fontsize: FONT_SIZE_MEDIUM, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        patientLabel.textAlignment = .right
        
        
        hkSettingsView.addShadowAndCornerRadius(.SMALL)
        hkSettingsView.backgroundColor = .white
        
        healthSwitch.addTarget(self, action: #selector(onHealthSwitchChange(healthSwitch  : )), for: .valueChanged)
        
        if let hkPatient = CharmUtil.getHealthKitPreference() {
            patientLabel.text = hkPatient.fullName
            hkSettingsViewHeightConstraint = hkSettingsView.setAndReturnHeight(constant: 107)
            healthSwitch.isOn = true
            patientView.showView()
        }
        else{
            hkSettingsViewHeightConstraint = hkSettingsView.setAndReturnHeight(constant: 70)
            healthSwitch.isOn = false
            patientView.hideView()
        }
        
        healthIV.setWidth(constant: 22)
        healthIV.setHeight(constant: 22)
        healthIV.setTop(offSet: 13)
        healthIV.setLeft(offSet: 14)
        
        healthHeading.setTop(offSet: 13)
        healthHeading.setLeftRelatedToView(offSet: 8, relatedView: healthIV, relatedAttribute: .right)
        
        healthSubHeading.setTopRelatedToView(offSet: 3, relatedView: healthHeading, relatedAttribute: .bottom)
        healthSubHeading.setLeftRelatedToView(offSet: 0, relatedView: healthHeading, relatedAttribute: .left)
        healthSubHeading.setBottom(offSet: -12)
        
        hkPatientSelectView = patientView
        separator.setTop(offSet: 0)
        separator.setHorizontal()
        separator.setHeight(constant: 1)
        
        healthPlaceholder.setTopRelatedToView(offSet: 8, relatedView: separator, relatedAttribute: .bottom)
        healthPlaceholder.setLeft(offSet: 14)
        
        patientLabel.setTopRelatedToView(offSet: 0, relatedView: healthPlaceholder, relatedAttribute: .top)
        patientLabel.setLeftRelatedToView(offSet: 8, relatedView: healthPlaceholder, relatedAttribute: .right)
        
        healthSwitch.setTop(offSet: 12)
        healthSwitch.setRight(offSet: -12)
        
        if let goIcon {
            patientLabel.setRightRelatedToView(offSet: -2, relatedView: goIcon, relatedAttribute: .left)
            
            goIcon.setBottom(offSet: -8)
            goIcon.setWidth(constant: 24)
            goIcon.setHeight(constant: 24)
            goIcon.setRight(offSet: -8)
            goIcon.setTopRelatedToView(offSet: 8, relatedView: separator, relatedAttribute: .bottom)
            
            patientLabel.setBottom(offSet: -8)
            healthPlaceholder.setBottom(offSet: -8)
        }
        else{
            patientLabel.setRight(offSet: -16)
            patientLabel.setBottom(offSet: -12)
            healthPlaceholder.setBottom(offSet: -12)
        }
        
        self.hkPatientLabel = patientLabel
    }
    
    private func createPatientView(patient:Patient) -> UIView
    {
        let patientView = UIView()
        
        let imageView = ImageViewWithInitailsView(initials: patient.fullName?.formInitials() ?? "", image: patient.patientPhoto)
        imageView.addCornerRadius(.SMALL)
        patientView.addSubview(imageView)
        
        let nameLabel = UILabel()
        nameLabel.text = patient.fullName
        nameLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        patientView.addSubview(nameLabel)
        
        let genderAndDobLabel = UILabel()
        if (patient.age > 0){
            genderAndDobLabel.text = "\(patient.gender.capitalized), \(patient.age ?? 0) Years"
        }
        else{
            genderAndDobLabel.text = patient.gender.capitalized
        }
        
        genderAndDobLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        genderAndDobLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        patientView.addSubview(genderAndDobLabel)
        
        let arrowImageView = UIImageView(image: UIImage(named: "section-arrow-right"))
        patientView.addSubview(arrowImageView)
        
        imageView.setLeft(offSet: 8)
        imageView.setWidth(constant: 32)
        imageView.setHeight(constant: 32)
        imageView.setRightRelatedToView(offSet: -10, relatedView: nameLabel, relatedAttribute: .left)
        imageView.setRightRelatedToView(offSet: -10, relatedView: genderAndDobLabel, relatedAttribute: .left)
        imageView.setCenterY()
        
        nameLabel.setTop(offSet: 6)
        nameLabel.setBottomRelatedToView(offSet: -2, relatedView: genderAndDobLabel, relatedAttribute: .top)
        nameLabel.setRightRelatedToView(offSet: -8, relatedView: arrowImageView, relatedAttribute: .left)
        
        genderAndDobLabel.setBottom(offSet: -6)
        genderAndDobLabel.setRightRelatedToView(offSet: -8, relatedView: arrowImageView, relatedAttribute: .left)
        
        arrowImageView.setCenterY()
        arrowImageView.setWidth(constant: 24)
        arrowImageView.setHeight(constant: 24)
        arrowImageView.setRight(offSet: -8)
        
        return patientView
    }
    
    @objc private func onAnalyticsSwitch()
    {
        // TODO(Apptics): disabled until verified; re-enable later
        //Apptics.setTrackingStatus(analyticsSwitch.isOn)
    }
    
    @objc private func patientSelected(tapGesture : UITapGestureRecognizer)
    {
        if let view = tapGesture.view
        {
            let patient = Patient.patientList![view.tag - PATIENT_VIEW_STARTING_TAG]
            self.navigationController?.popViewController(animated: true)
            AuthManager.switchPatient(patientObj: patient)
        }
    }
    
    @objc private func demographicsViewClicked()
    {
        
        let demographicVC = DemographicsViewController()
        demographicVC.valueChangedDelegate = self
        self.navigationController?.pushViewController(demographicVC, animated: true)
    }
    
    @objc private func pushPracticeFeedback() {
        checkAndPushToComposeVC()
    }
    
    @objc private func onHealthSwitchChange(healthSwitch: UISwitch) {
        if healthSwitch.isOn {
            hkSettingsViewHeightConstraint?.constant = 107
            presentHKPatientSelectVC()
            hkPatientSelectView?.showView()
        }
        else {
            hkSettingsViewHeightConstraint?.constant = 70
            hkPatientSelectView?.hideView()
            CharmUtil.removeHealthKitPreference()
        }
    }
    
    @objc private func presentHKPatientSelectVC(){
        let patientSelectVC = HKPatientSelectViewController()
//        patientSelectVC.modalTransitionStyle = .crossDissolve
//        patientSelectVC.modalPresentationStyle = .overFullScreen
        patientSelectVC.delegate = self
        patientSelectVC.cancelDelegate = self
        self.navigationController?.pushViewController(patientSelectVC, animated: true)
    }
    
    
    
    @objc private func pushCharmFeedback() {
        let supportPopVc = SupportViewController()
        supportPopVc.delegate = self
        self.navigationController?.pushViewController(supportPopVc, animated: true)
    }
    
    private func checkAndPushToComposeVC(){
        
        if canAllowComposeMessage() && appDataHandler.canAllowMessage{
            let arrayOfMessageRestriction = self.appDataHandler.arrayOfMessageRestriction.filter { (messageRestriction) -> Bool in
                if (messageRestriction.isMessageRestrict == false && messageRestriction.allowMessaging == true)
                {
                    return true
                }
                return false
            }
            if(arrayOfMessageRestriction.count > 0){
                
                let composeMsgVc = ComposeMessageViewController(enabledMessageRestictionList: arrayOfMessageRestriction, delegate: self)
                self.navigationController?.pushViewController(composeMsgVc, animated: true)
            }
            else{
                CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.message.alert.MessageRestrict.message"))
            }
        }
        else{
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.message.alert.sendMessageRestrict.message"))
        }
    }
    
    private func canAllowComposeMessage() -> Bool
    {
        var canAllow = false
        for messageRestriction in self.appDataHandler.arrayOfMessageRestriction
        {
            if messageRestriction.allowMessaging
            {
                canAllow = messageRestriction.allowMessaging
            }
        }
        return canAllow
    }
    
    func demographicsViewControllerDidChangeName()
    {
        self.demographicsValueChangedDelegate?.demographicsViewControllerDidChangeName()
        
        let patient = Patient.selectedPatientInstance ?? Patient()

        if let nameview = self.view.viewWithTag(SELECTED_PATIENT_NAME_VIEW_TAG) as? UILabel
        {
            nameview.text = patient.fullName ?? ""
        }
        
        if let genderLabel = self.view.viewWithTag(SELECTED_PATIENT_GENDER_VIEW_TAG) as? UILabel
        {
            if (patient.age > 0){
                genderLabel.text = "\(patient.gender.capitalized), \(patient.age ?? 0) Years"
            }
            else{
                genderLabel.text = patient.gender.capitalized
            }
        }
    }
    
    func demographicsViewControllerDidChangePatientPhoto(photo: UIImage) {
        demographicsValueChangedDelegate?.demographicsViewControllerDidChangePatientPhoto(photo: photo)
        if let imageView = self.view.viewWithTag(PROFILE_IMAGE_VIEW_TAG) as? ImageViewWithInitailsView
        {
            if Patient.selectedPatientInstance?.patientPhoto != nil
            {
                imageView.setImage(image: Patient.selectedPatientInstance!.patientPhoto!)
            }
        }
    }
    
    @objc private func signOutBtnClicked()
    {
        let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.logout.conformation"), preferredStyle: .alert)
        let noAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.common.no"), style: .cancel, handler: { (UIAlertAction) in
        })
        let logoutAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.common.yes"), style: .destructive, handler: { (UIAlertAction) in
            self.showActivityIndicator()
            AuthManager.logoutUser(isInvalidOAuth: false) {
                self.hideActivityIndicator()
            }
        })
        alertVC.addAction(noAction)
        alertVC.addAction(logoutAction)
        
        alertVC.show()
    }
    
    private func showActivityIndicator()
    {
        view.bringSubviewToFront(activityIndicatorView)
        self.view.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func hideActivityIndicator()
    {
        self.view.isUserInteractionEnabled = true
        activityIndicatorView.stopAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
    }
    
    func onHKPatientSelected(patient: Patient) {
        self.navigationController?.popViewController(animated: true)
        hkPatientLabel?.text = patient.fullName ?? ""
        CharmUtil.saveHealthKitPreference(patient: patient)
    }
    
    func onHKPatientSelectionCancelled(){
        if CharmUtil.getHealthKitPreference() == nil {
            if let healthSwitch {
                if healthSwitch.isOn {
                    healthSwitch.isOn = false
                    onHealthSwitchChange(healthSwitch: healthSwitch)
                }
            }
        }
    }
}

private class InfoView : UIView
{
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init( title : String , textColor : UIColor , isArrowNeeded : Bool) {
        super.init(frame: .zero)
        
        imageView.addCornerRadius(.SMALL)
        self.addSubview(imageView)
        
        let nameLabel = UILabel()
        nameLabel.text = title
        nameLabel.textColor = textColor
        nameLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        self.addSubview(nameLabel)
        
        let arrowImageView = UIImageView(image: #imageLiteral(resourceName: "ArrowRight"))
        self.addSubview(arrowImageView)
        
        imageView.setLeft(offSet: 8)
        imageView.setTop(offSet: 5)
        imageView.setBottom(offSet: -5)
        imageView.setWidth(constant: 32)
        imageView.setHeight(constant: 32)
        imageView.setRightRelatedToView(offSet: -10, relatedView: nameLabel, relatedAttribute: .left)
        
        nameLabel.setCenterY()
        
        if isArrowNeeded
        {
            nameLabel.setRightRelatedToView(offSet: -5, relatedView: arrowImageView, relatedAttribute: .left)
            
            arrowImageView.setCenterY()
            arrowImageView.setWidth(constant: ARROW_IMAGE_VIEW_SIZE.width)
            arrowImageView.setHeight(constant: ARROW_IMAGE_VIEW_SIZE.height)
            arrowImageView.setRight(offSet: -9)
        }
        else
        {
            arrowImageView.image = nil
            nameLabel.setRight(offSet: -9)
        }
        
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
