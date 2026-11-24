//
//  AllergyItemView.swift
//  phr
//
//  Created by prathi-13964 on 18/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

private let allergyParentWidth: CGFloat = applicationFrame.width - (2 * X_SPACE) - CARD_PADDING

class AllergiesItemView: UIView{

    private let verticalStackView = UIStackView()
    var deleteLabel: UILabel? = nil
    private let dateAndSeverityView = UIView()
    private let dateLabel = UILabel()
    private let severityLabel = UILabel()
    private let previousSeverityView = UIView()
    private let previousSeverityLabel = UILabel()
    private let previousSeverityValueLabel = UILabel()
    private let patientAddedView = UIView()
    private let patientAddedStackView = UIStackView()
    private let editIcon = UIImageView()
    private let allergyNameLabel = UILabel()
    private let reactionLabel = UILabel()
    let moreButton = UIButton()
    private let fromView = UIView()
    private let horizontalLine = UIView()
    private let fromLabel = UILabel()
    private let facilityListLabel = UILabel()
    
    private var deleteLabelConstraint: NSLayoutConstraint? = nil
    private var severityLabelConstraint: NSLayoutConstraint? = nil
    private var previousSeverityValueLabelConstraint: NSLayoutConstraint? = nil
    private var editIconWidthConstraint: NSLayoutConstraint? = nil
    private var editIconHeightConstraint: NSLayoutConstraint? = nil
    private var sepatorHeightConstraint: NSLayoutConstraint? = nil
    
    private var allergyParentWidthConstraint: NSLayoutConstraint? = nil
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(dateAndSeverityView)
            dateAndSeverityView.addSubview(dateLabel)
            dateAndSeverityView.addSubview(severityLabel)
        verticalStackView.addArrangedSubview(previousSeverityView)
            previousSeverityView.addSubview(previousSeverityLabel)
            previousSeverityView.addSubview(previousSeverityValueLabel)
        verticalStackView.addArrangedSubview(patientAddedView)
            patientAddedView.addSubview(patientAddedStackView)
            patientAddedView.addSubview(editIcon)
                patientAddedStackView.addArrangedSubview(allergyNameLabel)
                patientAddedStackView.addArrangedSubview(reactionLabel)
        verticalStackView.addArrangedSubview(moreButton)
        verticalStackView.addArrangedSubview(fromView)
            fromView.addSubview(horizontalLine)
            fromView.addSubview(fromLabel)
            fromView.addSubview(facilityListLabel)
        addProperties()
        addConstraints()
        checkAndCreateDeleteLabel()
    }
    
    private func addConstraints(){
        
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        allergyParentWidthConstraint = verticalStackView.setAndReturnWidth(constant: allergyParentWidth)
        
        dateLabel.setLeft(offSet: 0)
        dateLabel.setTop(offSet: 0)
        dateLabel.setBottom(offSet: 0)
        
        severityLabel.setRight(offSet: -CARD_PADDING)
        severityLabel.setTop(offSet: 0)
        severityLabel.setBottom(offSet: 0)
        severityLabelConstraint = severityLabel.setAndReturnWidth(constant: 0)
        
        previousSeverityLabel.setLeft(offSet: 0)
        previousSeverityLabel.setTop(offSet: 0)
        previousSeverityLabel.setBottom(offSet: 0)
        previousSeverityLabel.setWidth(constant: previousSeverityLabel.sizeThatFits(CGSize(width: 500, height: 50)).width)
        
        previousSeverityValueLabel.setLeftRelatedToView(offSet: PADDING_5, relatedView: previousSeverityLabel, relatedAttribute: .right)
        previousSeverityValueLabel.setTop(offSet: 0)
        previousSeverityValueLabel.setBottom(offSet: 0)
        previousSeverityValueLabelConstraint = previousSeverityValueLabel.setAndReturnWidth(constant: 0)
        
        patientAddedStackView.setLeft(offSet: 0)
        patientAddedStackView.setTop(offSet: 0)
        patientAddedStackView.setBottom(offSet: 0)
        patientAddedStackView.setRightRelatedToView(offSet: -10, relatedView: editIcon, relatedAttribute: .left)
        
        editIcon.setRight(offSet: -10)
        editIcon.setBottom(offSet: 0)
        editIconWidthConstraint = editIcon.setAndReturnWidth(constant: 0)
        editIconHeightConstraint = editIcon.setAndReturnHeight(constant: 0)
        
        moreButton.setHeight(constant: ITEM_MORE_BUTTON_HEIGHT)
        
//        horizontalLine.setHeight(constant: LINE_HEIGHT)
        horizontalLine.setLeft(offSet: 0)
        horizontalLine.setRight(offSet: -CARD_PADDING)
        horizontalLine.setTop(offSet: PADDING_5)
        sepatorHeightConstraint = horizontalLine.setAndReturnHeight(constant: 0)
        
        fromLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: horizontalLine, relatedAttribute: .bottom)
        fromLabel.setLeft(offSet: 0)
        fromLabel.setRight(offSet: -CARD_PADDING)
        
        facilityListLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: fromLabel, relatedAttribute: .bottom)
        facilityListLabel.setLeft(offSet: 0)
        facilityListLabel.setRight(offSet: -CARD_PADDING)
        facilityListLabel.setBottom(offSet: 0)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = STACKVIEW_VERTICAL_PADDING
        verticalStackView.alignment = .fill
        
        patientAddedStackView.axis = .vertical
        patientAddedStackView.spacing = STACKVIEW_VERTICAL_PADDING
        patientAddedStackView.alignment = .fill
        
        setLabelProperties(uiLabel: dateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold)
        setSeverityLabel(uiLabel: severityLabel)
        setLabelProperties(uiLabel: allergyNameLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold)
        
        previousSeverityLabel.text = getString(key: "com.charmphr.allergies.itemView.PreviousSeverity.title")
        setLabelProperties(uiLabel: previousSeverityLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        setSeverityLabel(uiLabel: previousSeverityValueLabel)
        
        editIcon.image = UIImage(named: "EditIconBlue")
        
        setLabelProperties(uiLabel: reactionLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        fromLabel.text = getString(key: "com.charmphr.allergies.itemView.from.title")
        setLabelProperties(uiLabel: fromLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        
        setLabelProperties(uiLabel: facilityListLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
         
        moreButton.setProperties(titleStrKey: getString(key: "com.charmphr.Immunization.more.title"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: BLUE_BTN_COLOR)
        moreButton.contentHorizontalAlignment = .left
        
        moreButton.isHidden = false
        fromView.isHidden = true
        
        previousSeverityView.isHidden = true
        reactionLabel.isHidden = true
        dateAndSeverityView.isHidden = true
        
    }
    
    private func setSeverityLabel(uiLabel: UILabel){
        uiLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        uiLabel.textAlignment = .center
    }
    
    private func setSeverityLabelProperties(uiLabel: UILabel ,bgColor: UInt, textColor: UInt){
        uiLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: bgColor)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: textColor)
        uiLabel.layer.cornerRadius = 2
        uiLabel.layer.masksToBounds = true
    }
    
    private func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textAlignment = .left
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
    }
    
    private func isCheckActive(val: Bool){
        severityLabel.isHidden = !val
        reactionLabel.isHidden = !val
        previousSeverityView.isHidden = val
    }
    
    private func isAddedByPatient(val: Bool){
        editIcon.isHidden = !val
        if val{
            editIconHeightConstraint?.constant = 20
            editIconWidthConstraint?.constant = 20
        }
        else{
            editIconHeightConstraint?.constant = 0
            editIconWidthConstraint?.constant = 0
        }
    }
    
    private func setSeverityAsMild()
    {
        setSeverityLabelProperties(uiLabel: severityLabel, bgColor: MILD_BG_COLOR, textColor: MILD_TEXT_COLOR)
        setSeverityLabelProperties(uiLabel: previousSeverityValueLabel, bgColor: MILD_BG_COLOR, textColor: MILD_TEXT_COLOR)
    }
    
    private func setSeverityAsModerate()
    {
        setSeverityLabelProperties(uiLabel: severityLabel, bgColor: MODERATE_BG_COLOR, textColor: MODERATE_TEXT_COLOR)
        setSeverityLabelProperties(uiLabel: previousSeverityValueLabel, bgColor: MODERATE_BG_COLOR, textColor: MODERATE_TEXT_COLOR)
    }
    
    private func setSeverityAsSevere()
    {
        setSeverityLabelProperties(uiLabel: severityLabel, bgColor: SEVERE_BG_COLOR, textColor: SEVERE_TEXT_COLOR)
        setSeverityLabelProperties(uiLabel: previousSeverityValueLabel, bgColor: SEVERE_BG_COLOR, textColor: SEVERE_TEXT_COLOR)
    }
    
    func setSpacing(){
        if moreButton.isHidden{
            sepatorHeightConstraint?.constant = LINE_HEIGHT
            verticalStackView.setCustomSpacing(STACKVIEW_VERTICAL_PADDING, after: allergyNameLabel)
        }
        else{
            sepatorHeightConstraint?.constant = 0
            verticalStackView.setCustomSpacing(0, after: allergyNameLabel)
        }
    }
    
    func setRowActionForSwipeLeft(duration: TimeInterval, isAddedByPatient: Bool){
        if isAddedByPatient{
            checkAndCreateDeleteLabel()
            
            UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
                deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
                allergyParentWidthConstraint?.constant = allergyParentWidth - SWIPE_LABEL_HEIGHT_CONSTRAINT
                self.layoutIfNeeded()
            })
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//                UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
//                    deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
//                    allergyParentWidthConstraint?.constant = allergyParentWidth - SWIPE_LABEL_HEIGHT_CONSTRAINT
//                    self.layoutIfNeeded()
//                })
//            })
            
        }
    }
    
    func setRowActionForSwipeRight(duration: TimeInterval){
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            deleteLabelConstraint?.constant = 0
            allergyParentWidthConstraint?.constant = allergyParentWidth
            self.layoutIfNeeded()
        })
    }
    
    private func checkAndCreateDeleteLabel(){
        if deleteLabel == nil {
            deleteLabel = UILabel()
            
            if let deleteLabel {
                self.addSubview(deleteLabel)
                deleteLabel.text = getString(key: "com.charmphr.action.delete")
                deleteLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
                deleteLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
                deleteLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
                deleteLabel.textAlignment = .center
                deleteLabel.addCornerRadius(.SMALL)
                deleteLabel.isUserInteractionEnabled = true
                deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
              
                
                deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: verticalStackView, relatedAttribute: .right)
                deleteLabel.setRight(offSet: 0)
                deleteLabel.setTop(offSet: 0)
                deleteLabel.setBottom(offSet: 0)
                deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
            }
            
         
        }
        else{
            deleteLabelConstraint?.constant = 0
        }
    }
    
    func setView(allergiesList: AllergiesList?){
        moreButton.isHidden = true
        if let allergiesList = allergiesList , let patientAllergyMap = allergiesList.patientAllergyMap{
            if !patientAllergyMap.isAddedByPatient{
                if allergiesList.isViewOpened{
                    fromView.isHidden = false
                
                    let practice = Patient.selectedPatientInstance?.getPracticeWith(practiceId: patientAllergyMap.practiceId ?? "")
                    facilityListLabel.text = practice?.practiceName
                    let facilityListLabelHeight = facilityListLabel.sizeThatFits(CGSize(width: 500, height: applicationFrame.height)).height
                    facilityListLabel.setHeight(constant: facilityListLabelHeight)
                }
            }
        }
    }
    
    func setAllergiesValues(data: AllergiesList){
        if let patientAllergyMap = data.patientAllergyMap{
            
            
            isAddedByPatient(val: patientAllergyMap.isAddedByPatient)
            
            if let observedDateObj = patientAllergyMap.observedDate{
                let observedDateString = observedDateObj.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                dateLabel.text = observedDateString
                dateAndSeverityView.isHidden = false
            }
            else{
                dateAndSeverityView.isHidden = true
            }
            allergyNameLabel.text = "\(data.allergyType ?? "") - \(data.allergy ?? "")"
            reactionLabel.text = patientAllergyMap.reactions
            
            
            if patientAllergyMap.isAddedByPatient{
                severityLabel.text = patientAllergyMap.severity
                severityLabelConstraint?.constant = severityLabel.sizeThatFits(CGSize(width: 400, height: 50)).width + 10
                moreButton.isHidden = true
                fromView.isHidden = true
                isCheckActive(val: true)
            }
            else{
                
                if patientAllergyMap.isActive{
                    severityLabel.text = patientAllergyMap.severity
                    severityLabelConstraint?.constant = severityLabel.sizeThatFits(CGSize(width: 400, height: 50)).width + 10
                    isCheckActive(val: patientAllergyMap.isActive)

                }
                else{
                    previousSeverityValueLabel.text = patientAllergyMap.severity
                    previousSeverityValueLabelConstraint?.constant = previousSeverityValueLabel.sizeThatFits(CGSize(width: 400, height: 50)).width + 10
                    isCheckActive(val: patientAllergyMap.isActive)

                }
                
                if data.isViewOpened{
                    moreButton.isHidden = true
                    setView(allergiesList: data)
                }
                else{
                    fromView.isHidden = true
                    moreButton.isHidden = false
                }
            }
            if patientAllergyMap.severity == allergySeverityMild
            {
                setSeverityAsMild()
            }
            else if patientAllergyMap.severity == allergySeverityModerate
            {
                setSeverityAsModerate()
            }
            else if patientAllergyMap.severity == allergySeveritySevere
            {
                setSeverityAsSevere()
            }
        }
        setSpacing()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
