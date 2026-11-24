//
//  QuestionnaireItemView.swift
//  phr
//
//  Created by Raghul D on 26/11/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import UIKit

class QuestionnaireItemView: UIView {
    
    static let cardPadding:CGFloat = 10.0
    static let itemVerticalMargin: CGFloat = 4.0
    static let itemTextSpacing: CGFloat = 6.0
    static let statusHeight: CGFloat = 17
    static let normalTVHeight: CGFloat = 19
    
    private let verticalStackView = UIStackView()
    private let nameView = UIView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let facilityView = UIView()
    private let facilityNameLabel = UILabel()
    private let facilityNameValueLabel = UILabel()
    private let senderView = UIView()
    private let senderLabel = UILabel()
    private let senderValueLabel = UILabel()
    private let appointmentView = UIView()
    private let appointmentLabel = UILabel()
    private let appointmentDateLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        initViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(nameView)
        nameView.addSubview(nameLabel)
        nameView.addSubview(statusLabel)
        verticalStackView.addArrangedSubview(facilityView)
        facilityView.addSubview(facilityNameLabel)
        facilityView.addSubview(facilityNameValueLabel)
        verticalStackView.addArrangedSubview(senderView)
        senderView.addSubview(senderLabel)
        senderView.addSubview(senderValueLabel)
        verticalStackView.addArrangedSubview(appointmentView)
        appointmentView.addSubview(appointmentLabel)
        appointmentView.addSubview(appointmentDateLabel)
        
        setProperties()
        addConstraints()
    }

    private func setProperties()  {
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.spacing = QuestionnaireItemView.itemVerticalMargin
        
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 3
        statusLabel.layer.masksToBounds = true

        statusLabel.setProperties(textKey: "", fontsize: FONT_SIZE_MEDIUM, weight: .semibold, fontcolor: questionnaireListStatusNewTxtColor )
        statusLabel.setBackgroundColor(bgColor: questionnaireListStatusNewBg)
        
        nameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        nameLabel.numberOfLines = 0

        facilityNameLabel.setProperties(textKey: getString(key: "com.charmphr.questionnaire.facility.hint"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
        facilityNameValueLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        facilityNameValueLabel.numberOfLines = 0
        
        senderLabel.setProperties(textKey: getString(key: "com.charmphr.questionnaire.member.hint"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
        senderValueLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        senderValueLabel.numberOfLines = 0

        appointmentLabel.setProperties(textKey: getString(key: "com.charmphr.questionnaire.appointmentdate.hint"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
        appointmentDateLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
    }
    
    private func addConstraints() {
        
        verticalStackView.setLeft(offSet: QuestionnaireItemView.cardPadding)
        verticalStackView.setRight(offSet: -QuestionnaireItemView.cardPadding)
        verticalStackView.setTop(offSet: QuestionnaireItemView.cardPadding)
        verticalStackView.setBottom(offSet: -QuestionnaireItemView.cardPadding)
        
        nameLabel.setLeft(offSet: 0)
        nameLabel.setRightRelatedToView(offSet: -QuestionnaireItemView.cardPadding, relatedView: statusLabel, relatedAttribute: .left)
        nameLabel.setTop(offSet: 0)
        nameLabel.setBottom(offSet: 0)

        statusLabel.setRight(offSet: 0)
        statusLabel.setTopRelatedToView(offSet: 3, relatedView: nameLabel, relatedAttribute: .top)
        
        facilityNameLabel.setLeft(offSet: 0)
        facilityNameLabel.setTop(offSet: 0)
        facilityNameLabel.wrapWidth(maxWidth: 300)
        facilityNameLabel.wrapHeight(maxHeight: 100)

        facilityNameValueLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: facilityNameLabel , relatedAttribute: .right)
        facilityNameValueLabel.setRight(offSet: 0)
        facilityNameValueLabel.setTop(offSet: 0)
        facilityNameValueLabel.setBottom(offSet: 0)
        
        senderLabel.setLeft(offSet: 0)
        senderLabel.setTop(offSet: 0)
        senderLabel.wrapWidth(maxWidth: 200)
        senderLabel.wrapHeight(maxHeight: 100)
        
        senderValueLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: senderLabel , relatedAttribute: .right)
        senderValueLabel.setRight(offSet: 0)
        senderValueLabel.setTop(offSet: 0)
        senderValueLabel.setBottom(offSet: 0)

        appointmentLabel.setLeft(offSet: 0)
        appointmentLabel.setTop(offSet: 0)
        appointmentLabel.wrapWidth(maxWidth: 300)
        appointmentLabel.wrapHeight(maxHeight: 100)
        
        appointmentDateLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: appointmentLabel , relatedAttribute: .right)
        appointmentDateLabel.setRight(offSet: 0)
        appointmentDateLabel.setTop(offSet: 0)
        appointmentDateLabel.setBottom(offSet: 0)
    }
    
    func setValues(physicianTemplate: PhysicianTemplates , type: String) {
        
        nameLabel.text = physicianTemplate.name ?? ""
        
        if let patQuesMap = physicianTemplate.patientQuesMap {
            
            if let appointmentDate = patQuesMap.appointment?.appointmentDate {
                appointmentView.isHidden = false
                appointmentDateLabel.text = CharmUtil.getDateStringWith(date: appointmentDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            }
            else{
                appointmentView.isHidden = true
            }
            
            let memberName = physicianTemplate.member?.formMemberName()

            if !memberName.isNilOrBlank() {
                senderView.isHidden = false
                senderValueLabel.text = memberName
            }
            else{
                senderView.isHidden = true
            }
            
            let facilityName = patQuesMap.appointment?.facilityName

            if !facilityName.isNilOrBlank() {
                facilityView.isHidden = false
                facilityNameValueLabel.text = facilityName
            }
            else{
                facilityView.isHidden = true
            }
            self.setNeedsLayout()
            
                
            if patQuesMap.isFilled && patQuesMap.isSubmitted {
                statusLabel.setBackgroundColor(bgColor: questionnaireListStatusSubmittedBg)
                statusLabel.setTextColor(fontcolor: questionnaireListStatusSubmittedTxtColor)
                statusLabel.text = getString(key: "com.charmphr.questionnaire.status.submitted")
            }
            else if !patQuesMap.isFilled && !patQuesMap.isSubmitted {
                    
                if type == questionnaireCurrentValue {

                    statusLabel.setBackgroundColor(bgColor: questionnaireListStatusNewBg)
                    statusLabel.setTextColor(fontcolor: questionnaireListStatusNewTxtColor)
                    statusLabel.text = getString(key: "com.charmphr.questionnaire.status.new")
                }
                else{
                    statusLabel.setBackgroundColor(bgColor: questionnaireListStatusNotSubmittedBg)
                    statusLabel.setTextColor(fontcolor: questionnaireListStatusNotSubmittedTxtColor)
                    statusLabel.text = getString(key: "com.charmphr.questionnaire.status.notsubmitted")
                }
            }
            else {
                statusLabel.setBackgroundColor(bgColor: questionnaireListStatusDraftBg)
                statusLabel.setTextColor(fontcolor: questionnaireListStatusDraftTxtColor)
                statusLabel.text = getString(key: "com.charmphr.questionnaire.status.draft")
            }
            
            statusLabel.removeConstraint(attribute: .width)
            statusLabel.wrapWidth(maxWidth: 300, extraSpacing: 10)
        }
    }
}
