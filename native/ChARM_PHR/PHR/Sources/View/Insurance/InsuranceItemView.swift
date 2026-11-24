//
//  InsuranceItemView.swift
//  phr
//
//  Created by Raghul D on 01/06/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit


class InsuranceItemView: UIView {
    
    static let cardPadding:CGFloat = 10.0
    static let itemVerticalMargin: CGFloat = 4.0
    static let itemTextSpacing: CGFloat = 6.0
    static let statusHeight: CGFloat = 17
    static let normalTVHeight: CGFloat = 19

//contentInset
    
    //needsLayout
    
    let cardView = UIView()
    let deleteLabel = UILabel()
    let insuranceNameLabel = UILabel()
    let insuranceIDHintLabel = UILabel()
    let insuranceIDLabel = UILabel()
    let insurancePlanHintLabel = UILabel()
    let insurancePlanLabel = UILabel()
    let insurancePolicyGrpHintLabel = UILabel()
    let insurancePolicyGrpLabel = UILabel()
    let insuranceInsuredPersonHintLabel = UILabel()
    let insuranceInsuredPersonLabel = UILabel()
    let insuranceDateLabel = UILabel()

    
    var insuranceIDHintHeightConstraint: NSLayoutConstraint? = nil
    var insuranceIDHeightConstraint: NSLayoutConstraint? = nil
    var insuranceIDHintTopConstraint: NSLayoutConstraint? = nil
    var insuranceIDHintWidthConstraint: NSLayoutConstraint? = nil

    var insurancePlanHintHeightConstraint: NSLayoutConstraint? = nil
    var insurancePlanHeightConstraint: NSLayoutConstraint? = nil
    var insurancePlanHintTopConstraint: NSLayoutConstraint? = nil

    
    var insuranceInsuredPersonHintHeightConstraint: NSLayoutConstraint? = nil
    var insuranceInsuredPersonHeightConstraint: NSLayoutConstraint? = nil
    var insuranceInsuredPersonHintTopConstraint: NSLayoutConstraint? = nil
    
    var insurancePolicyGrpHintHeightConstraint: NSLayoutConstraint? = nil
    var insurancePolicyGrpHeightConstraint: NSLayoutConstraint? = nil
    var insurancePolicyGrpHintTopConstraint: NSLayoutConstraint? = nil
    
    var insuranceDateHeightConstraint: NSLayoutConstraint? = nil
    var insuranceDateTopConstraint: NSLayoutConstraint? = nil
    
    var deleteLabelConstraint: NSLayoutConstraint? = nil

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.addSubview(cardView)
        self.addSubview(deleteLabel)
        cardView.addSubview(insuranceNameLabel)
        cardView.addSubview(insuranceIDHintLabel)
        cardView.addSubview(insuranceIDLabel)
        cardView.addSubview(insurancePlanHintLabel)
        cardView.addSubview(insurancePlanLabel)
        cardView.addSubview(insurancePolicyGrpHintLabel)
        cardView.addSubview(insurancePolicyGrpLabel)
        cardView.addSubview(insuranceInsuredPersonHintLabel)
        cardView.addSubview(insuranceInsuredPersonLabel)
        cardView.addSubview(insuranceDateLabel)
        
        setProperties()
        addConstraints()
    }

    private func setProperties()  {
        addShadowAndCornerRadius(.SMALL)
    
        insuranceNameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        insuranceNameLabel.numberOfLines = 0

        insuranceIDLabel.numberOfLines = 1
        insuranceIDLabel.lineBreakMode = .byTruncatingTail
        insuranceIDLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)

        insuranceIDHintLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)

        insurancePlanLabel.numberOfLines = 1
        insurancePlanLabel.lineBreakMode = .byTruncatingTail
        insurancePlanLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)

        insurancePlanHintLabel.setProperties(textKey: "com.charmphr.insuranceList.plan.label", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)

        insuranceInsuredPersonLabel.numberOfLines = 1
        insuranceInsuredPersonLabel.lineBreakMode = .byTruncatingTail
        insuranceInsuredPersonLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)

        insuranceInsuredPersonHintLabel.setProperties(textKey: "com.charmphr.insuranceList.insuredPerson.label", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)

        
        insurancePolicyGrpHintLabel.setProperties(textKey: "com.charmphr.insuranceList.policyGrp.label", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)

        insurancePolicyGrpLabel.numberOfLines = 1
        insurancePolicyGrpLabel.lineBreakMode = .byTruncatingTail
        insurancePolicyGrpLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        insuranceDateLabel.numberOfLines = 0
        insuranceDateLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
        
        deleteLabel.text = getString(key: "com.charmphr.action.delete")
        deleteLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        deleteLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        deleteLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
        deleteLabel.textAlignment = .center
        deleteLabel.addCornerRadius(.SMALL)
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    private func addConstraints() {
    
        cardView.setLeft(offSet: 0)
        cardView.setTop(offSet: 0)
        cardView.setBottom(offSet: 0)

        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: cardView, relatedAttribute: .right)
        deleteLabel.setRight(offSet: 0)
        deleteLabel.setTop(offSet: 0)
        deleteLabel.setBottom(offSet: 0)
        deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
        
        insuranceNameLabel.setSafeAreaTop(offset: QuestionnaireItemView.cardPadding)
        insuranceNameLabel.setLeft(offSet: QuestionnaireItemView.cardPadding)
        insuranceNameLabel.setRight(offSet: -QuestionnaireItemView.cardPadding)

        insuranceIDHintTopConstraint =  insuranceIDHintLabel.setAndReturnTopRelatedToView(offSet: QuestionnaireItemView.itemVerticalMargin, relatedView: insuranceNameLabel, relatedAttribute: .bottom)
        insuranceIDHintLabel.setLeft(offSet: QuestionnaireItemView.cardPadding)
        insuranceIDHintHeightConstraint = insuranceIDHintLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)
        insuranceIDHintWidthConstraint = insuranceIDHintLabel.setAndReturnWidth(constant: insuranceIDHintLabel.sizeThatFits(CGSize(width: 200, height: QuestionnaireItemView.normalTVHeight)).width)

        insuranceIDLabel.setTopRelatedToView(offSet: 0, relatedView: insuranceIDHintLabel, relatedAttribute: .top)
        insuranceIDLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: insuranceIDHintLabel , relatedAttribute: .right)
        insuranceIDLabel.setRight(offSet: -QuestionnaireItemView.cardPadding)
        insuranceIDHeightConstraint = insuranceIDLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)


        insurancePlanHintTopConstraint =  insurancePlanHintLabel.setAndReturnTopRelatedToView(offSet: QuestionnaireItemView.itemVerticalMargin, relatedView: insuranceIDLabel, relatedAttribute: .bottom)
        insurancePlanHintLabel.setLeft(offSet: QuestionnaireItemView.cardPadding)
        insurancePlanHintHeightConstraint = insurancePlanHintLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)
        insurancePlanHintLabel.setWidth(constant: insurancePlanHintLabel.sizeThatFits(CGSize(width: 200, height: QuestionnaireItemView.normalTVHeight)).width)
        
        insurancePlanLabel.setTopRelatedToView(offSet: 0, relatedView: insurancePlanHintLabel, relatedAttribute: .top)
        insurancePlanLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: insurancePlanHintLabel , relatedAttribute: .right)
        insurancePlanLabel.setRight(offSet: -QuestionnaireItemView.cardPadding)
        insurancePlanHeightConstraint = insurancePlanLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)

        insuranceInsuredPersonHintHeightConstraint = insuranceInsuredPersonHintLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)
        insuranceInsuredPersonHintLabel.setWidth(constant: insuranceInsuredPersonHintLabel.sizeThatFits(CGSize(width: 200, height: QuestionnaireItemView.normalTVHeight)).width)
        
        insuranceInsuredPersonHintTopConstraint =  insuranceInsuredPersonHintLabel.setAndReturnTopRelatedToView(offSet: QuestionnaireItemView.itemVerticalMargin, relatedView: insurancePolicyGrpLabel, relatedAttribute: .bottom)
        insuranceInsuredPersonHintLabel.setLeft(offSet: QuestionnaireItemView.cardPadding)


        insuranceInsuredPersonLabel.setTopRelatedToView(offSet: 0, relatedView: insuranceInsuredPersonHintLabel, relatedAttribute: .top)
        insuranceInsuredPersonLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: insuranceInsuredPersonHintLabel , relatedAttribute: .right)
        insuranceInsuredPersonLabel.setRight(offSet: -QuestionnaireItemView.cardPadding)
        insuranceInsuredPersonHeightConstraint = insuranceInsuredPersonLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)
        
        
        
        insurancePolicyGrpHintHeightConstraint = insurancePolicyGrpHintLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)
        insurancePolicyGrpHintLabel.setWidth(constant: insurancePolicyGrpHintLabel.sizeThatFits(CGSize(width: 200, height: QuestionnaireItemView.normalTVHeight)).width)
        
        insurancePolicyGrpHintTopConstraint =  insurancePolicyGrpHintLabel.setAndReturnTopRelatedToView(offSet: QuestionnaireItemView.itemVerticalMargin, relatedView: insurancePlanLabel, relatedAttribute: .bottom)
        insurancePolicyGrpHintLabel.setLeft(offSet: QuestionnaireItemView.cardPadding)


        insurancePolicyGrpLabel.setTopRelatedToView(offSet: 0, relatedView: insurancePolicyGrpHintLabel, relatedAttribute: .top)
        insurancePolicyGrpLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: insurancePolicyGrpHintLabel , relatedAttribute: .right)
        insurancePolicyGrpLabel.setRight(offSet: -QuestionnaireItemView.cardPadding)
        insurancePolicyGrpHeightConstraint = insurancePolicyGrpLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)

        
        
        insuranceDateHeightConstraint = insuranceDateLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)
        insuranceDateTopConstraint =  insuranceDateLabel.setAndReturnTopRelatedToView(offSet: QuestionnaireItemView.itemVerticalMargin, relatedView: insuranceInsuredPersonLabel, relatedAttribute: .bottom)
        
        insuranceDateLabel.setBottom(offSet: -InsuranceItemView.cardPadding)
        insuranceDateLabel.setLeft(offSet: InsuranceItemView.cardPadding)
        insuranceDateLabel.setRight(offSet: -InsuranceItemView.cardPadding)

    }
    
    func setValues(insurance: PatientInsuranceDetails) {
        
        
        var type = insurance.type?.lowercased().capitalizingFirstLetter() ?? ""
        
        if type.isBlank(){
            type = getString(key: "com.charmphr.insurance.type.secondary")
        }
        
        let insuranceTypeChange = onInsuranceTypeChange(insuranceType: insurance.insurancePlanType ?? "")
        
        
        
        if !insurance.policyNumber.isNilOrBlank() {
            insuranceIDHintTopConstraint?.constant = QuestionnaireItemView.itemVerticalMargin
            insuranceIDHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
            insuranceIDHintHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
            insuranceIDLabel.text = insurance.policyNumber
            insuranceIDHintLabel.text = insuranceTypeChange.memberIdLabel
            insuranceIDHintWidthConstraint?.constant = insuranceIDHintLabel.sizeThatFits(CGSize(width: 200, height: QuestionnaireItemView.normalTVHeight)).width
        }
        else{
            insuranceIDHintTopConstraint?.constant = 0
            insuranceIDHeightConstraint?.constant = 0
            insuranceIDHintHeightConstraint?.constant = 0
        }
        
        
        if insurance.practicePayer?.payerName.isNilOrBlank() ?? true {
            insuranceNameLabel.text = type
        }
        else{
            insuranceNameLabel.text = "\(type) - \(insurance.practicePayer?.payerName ?? "")"
        }
        
        if !insurance.insurancePlanType.isNilOrBlank() {
            insurancePlanHintTopConstraint?.constant = QuestionnaireItemView.itemVerticalMargin
            insurancePlanHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
            insurancePlanHintHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
            insurancePlanLabel.text = insurance.insurancePlanType
        }
        else{
            insurancePlanHintTopConstraint?.constant = 0
            insurancePlanHeightConstraint?.constant = 0
            insurancePlanHintHeightConstraint?.constant = 0
        }
        
        if !insurance.groupNumber.isNilOrBlank() {
            insurancePolicyGrpHintTopConstraint?.constant = QuestionnaireItemView.itemVerticalMargin
            insurancePolicyGrpHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
            insurancePolicyGrpHintHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
            insurancePolicyGrpLabel.text = insurance.groupNumber
        }
        else{
            insurancePolicyGrpHintTopConstraint?.constant = 0
            insurancePolicyGrpHeightConstraint?.constant = 0
            insurancePolicyGrpHintHeightConstraint?.constant = 0
        }
        
        
        let insuredPerson = "\(insurance.insuredAndGuarantorDetails?.firstName ?? "") \(insurance.insuredAndGuarantorDetails?.lastName ?? "")"
        
        if insuredPerson.isNotBlank() {
            insuranceInsuredPersonHintTopConstraint?.constant = QuestionnaireItemView.itemVerticalMargin
            insuranceInsuredPersonHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
            insuranceInsuredPersonHintHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
            insuranceInsuredPersonLabel.text = insuredPerson
        }
        else{
            insuranceInsuredPersonHintTopConstraint?.constant = 0
            insuranceInsuredPersonHeightConstraint?.constant = 0
            insuranceInsuredPersonHintHeightConstraint?.constant = 0
        }
    
        
        if let startDate = insurance.policyStartDate , let endDate = insurance.policyEndDate {
            insuranceDateLabel.attributedText = makeInsuranceValidDateTxt(startDate: startDate, endDate: endDate)
            
            insuranceDateTopConstraint?.constant = QuestionnaireItemView.itemVerticalMargin
            insuranceDateHeightConstraint?.constant = QuestionnaireItemView.normalTVHeight
        }
        else{
            
            insuranceDateTopConstraint?.constant = 0
            insuranceDateHeightConstraint?.constant = 0
        }
        self.setNeedsLayout()
    }
    
    func setRowActionForSwipeLeft(duration: TimeInterval){
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
            self.layoutIfNeeded()
        })
    }
    
    func setRowActionForSwipeRight(duration: TimeInterval){
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            deleteLabelConstraint?.constant = 0
            self.layoutIfNeeded()
        })
    }
}

class InsuranceTableViewCell: UITableViewCell {

    let insuranceItemView = InsuranceItemView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(insuranceItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        insuranceItemView.setHorizontal(offSet: X_SPACE)
        insuranceItemView.setTop(offSet: Y_SPACE/2)
        insuranceItemView.setBottom(offSet: -(Y_SPACE/2))
    }
    
    func setValues(insurance: PatientInsuranceDetails) {
        insuranceItemView.setValues(insurance: insurance)
    }
}


