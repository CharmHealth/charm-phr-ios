//
//  VaccineItemView.swift
//  phr
//
//  Created by prathi-13964 on 08/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class VaccineItemView: UIView{
    
    let containerView = UIView()
    let verticalStackView = UIStackView()
    let deleteLabel = UILabel()
    let dateLabel = UILabel()
    let vaccineNameLabel = UILabel()
    let patientAddedView = UIView()
    let patientAddedStackView = UIStackView()
    let editIcon = UIImageView()
    let administeredTypeAndAgeCategoryLabel = UILabel()
    let administeredByView = UIView()
    let administeredByLabel = UILabel()
    let administeredByValueLabel = UILabel()
    let moreButton = UIButton()
    let manufacturerView = UIView()
    let manufacturerLabel = UILabel()
    let manufacturerValueLabel = UILabel()
    let commentsLabel = UILabel()
    let routeAndSiteLabel = UILabel()
    let prescribedByView = UIView()
    let prescribedByLabel = UILabel()
    let prescribedByValueLabel = UILabel()
    let practiceMoreBtn = UIButton()
    let fromView = UIView()
    let horizontalLine = UIView()
    let fromLabel = UILabel()
    let facilityListLabel = UILabel()
    var administeredTypeLabelConstraint: NSLayoutConstraint? = nil
    var deleteLabelConstraint: NSLayoutConstraint? = nil
    weak var delegate: VaccineTableViewCell? = nil
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(deleteLabel)
        self.addSubview(containerView)
        containerView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(vaccineNameLabel)
        verticalStackView.addArrangedSubview(patientAddedView)
        patientAddedView.addSubview(patientAddedStackView)
        patientAddedView.addSubview(editIcon)
        patientAddedStackView.addArrangedSubview(administeredTypeAndAgeCategoryLabel)
        patientAddedStackView.addArrangedSubview(administeredByView)
        administeredByView.addSubview(administeredByLabel)
        administeredByView.addSubview(administeredByValueLabel)
        patientAddedStackView.addArrangedSubview(moreButton)
        patientAddedStackView.addArrangedSubview(manufacturerView)
        manufacturerView.addSubview(manufacturerLabel)
        manufacturerView.addSubview(manufacturerValueLabel)
        patientAddedStackView.addArrangedSubview(commentsLabel)
        verticalStackView.addArrangedSubview(routeAndSiteLabel)
        verticalStackView.addArrangedSubview(prescribedByView)
        prescribedByView.addSubview(prescribedByLabel)
        prescribedByView.addSubview(prescribedByValueLabel)
        verticalStackView.addArrangedSubview(practiceMoreBtn)
        verticalStackView.addArrangedSubview(fromView)
        fromView.addSubview(horizontalLine)
        fromView.addSubview(fromLabel)
        fromView.addSubview(facilityListLabel)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        containerView.setLeft(offSet: 0)
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: -0)
        
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setRight(offSet: -CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        
        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: containerView, relatedAttribute: .right)
        deleteLabel.setRight(offSet: 0)
        deleteLabel.setTop(offSet: 0)
        deleteLabel.setBottom(offSet: 0)
        deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
        
        patientAddedStackView.setLeft(offSet: 0)
        patientAddedStackView.setTop(offSet: 0)
        patientAddedStackView.setBottom(offSet: 0)
        patientAddedStackView.setRightRelatedToView(offSet: -10, relatedView: editIcon, relatedAttribute: .left)
        
        editIcon.setRight(offSet: -10)
        editIcon.setBottom(offSet: 0)
        editIcon.setHeight(constant: 20)
        editIcon.setWidth(constant: 20)
        
        administeredByLabel.setLeft(offSet: 0)
        administeredByLabel.setTop(offSet: 0)
        administeredByLabel.wrapWidth(maxWidth: 300)
        administeredByLabel.wrapHeight(maxHeight: 50)
        
        administeredByValueLabel.setLeftRelatedToView(offSet: 0, relatedView: administeredByLabel, relatedAttribute: .right)
        administeredByValueLabel.setRight(offSet: 0)
        administeredByValueLabel.setTopRelatedToView(offSet: 0, relatedView: administeredByLabel, relatedAttribute: .top)
        administeredByValueLabel.setBottom(offSet: 0)
        
        moreButton.setHeight(constant: ITEM_MORE_BUTTON_HEIGHT)
        
        manufacturerLabel.setLeft(offSet: 0)
        manufacturerLabel.setTop(offSet: 0)
        manufacturerLabel.setWidth(constant: manufacturerLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        manufacturerLabel.setHeight(constant: manufacturerLabel.sizeThatFits(CGSize(width: 300, height: 50)).height)
        
        manufacturerValueLabel.setLeftRelatedToView(offSet: 0, relatedView: manufacturerLabel, relatedAttribute: .right)
        manufacturerValueLabel.setRight(offSet: 0)
        manufacturerValueLabel.setTopRelatedToView(offSet: 0, relatedView: manufacturerLabel, relatedAttribute: .top)
        manufacturerValueLabel.setBottom(offSet: 0)
        
        prescribedByLabel.setLeft(offSet: 0)
        prescribedByLabel.setTop(offSet: 0)
        prescribedByLabel.setWidth(constant: prescribedByLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        prescribedByLabel.setHeight(constant: prescribedByLabel.sizeThatFits(CGSize(width: 300, height: 50)).height)
        
        prescribedByValueLabel.setLeftRelatedToView(offSet: 0, relatedView: prescribedByLabel, relatedAttribute: .right)
        prescribedByValueLabel.setRight(offSet: 0)
        prescribedByValueLabel.setTopRelatedToView(offSet: 0, relatedView: prescribedByLabel, relatedAttribute: .top)
        prescribedByValueLabel.setBottom(offSet: 0)
        
        practiceMoreBtn.setHeight(constant: ITEM_MORE_BUTTON_HEIGHT)
        
        horizontalLine.setHeight(constant: LINE_HEIGHT)
        horizontalLine.setLeft(offSet: 0)
        horizontalLine.setRight(offSet: 0)
        horizontalLine.setTop(offSet: PADDING_5)
        
        fromLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: horizontalLine, relatedAttribute: .bottom)
        fromLabel.setLeft(offSet: 0)
        fromLabel.setRight(offSet: 0)
        
        facilityListLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: fromLabel, relatedAttribute: .bottom)
        facilityListLabel.setLeft(offSet: 0)
        facilityListLabel.setRight(offSet: 0)
        facilityListLabel.setBottom(offSet: 0)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = ITEM_VERTICAL_MARGIN
        verticalStackView.alignment = .fill
        
        patientAddedStackView.axis = .vertical
        patientAddedStackView.spacing = STACKVIEW_VERTICAL_PADDING
        patientAddedStackView.alignment = .fill
        
        setLabelProperties(uiLabel: dateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold)
        setLabelProperties(uiLabel: vaccineNameLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold)
        setLabelProperties(uiLabel: administeredTypeAndAgeCategoryLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        administeredByLabel.text = getString(key: "com.charmphr.Immunization.administeredBy.title")
        setLabelProperties(uiLabel: administeredByLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        setLabelProperties(uiLabel: routeAndSiteLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        setLabelProperties(uiLabel: administeredByValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        prescribedByLabel.text = getString(key: "com.charmphr.Immunization.prescribedBy.title")
        setLabelProperties(uiLabel: prescribedByLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        setLabelProperties(uiLabel: prescribedByValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        fromLabel.text = getString(key: "com.charmphr.allergies.itemView.from.title")
        setLabelProperties(uiLabel: fromLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        
        setLabelProperties(uiLabel: facilityListLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        editIcon.image = UIImage(named: "EditIconBlue")
        
        manufacturerLabel.text = getString(key: "com.charmphr.Immunization.manufacturer.title")
        setLabelProperties(uiLabel: manufacturerLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: manufacturerValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        setLabelProperties(uiLabel: commentsLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        deleteLabel.text = getString(key: "com.charmphr.action.delete")
        deleteLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        deleteLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        deleteLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
        deleteLabel.textAlignment = .center
        deleteLabel.addCornerRadius(.SMALL)
        deleteLabel.layer.masksToBounds = true
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        moreButton.setProperties(titleStrKey: getString(key: "com.charmphr.Immunization.more.title"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: BLUE_BTN_COLOR)
        moreButton.contentHorizontalAlignment = .left
        
        practiceMoreBtn.setProperties(titleStrKey: getString(key: "com.charmphr.Immunization.more.title"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: BLUE_BTN_COLOR)
        practiceMoreBtn.contentHorizontalAlignment = .left
        
        moreButton.isHidden = true
        practiceMoreBtn.isHidden = true
        manufacturerView.isHidden = true
        commentsLabel.isHidden = true
        fromView.isHidden = true
        prescribedByView.isHidden = true
        administeredByView.isHidden = true
        administeredTypeAndAgeCategoryLabel.isHidden = true
        routeAndSiteLabel.isHidden = true
    }
    
    func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textAlignment = .left
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
    }
   
    func setRowActionForSwipeLeft(duration: TimeInterval, vaccine: VaccineImmunizationPOJO){
        if vaccine.addedByPatient{
            UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
                deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
                self.layoutIfNeeded()
            }, completion: {_ in
                self.updateTableView()
            })
        }
    }
    
    func isAddedByPatient(val: Bool){
        administeredTypeAndAgeCategoryLabel.isHidden = !val
        administeredByView.isHidden = !val
        moreButton.isHidden = !val
        routeAndSiteLabel.isHidden = val
        practiceMoreBtn.isHidden = val
        prescribedByView.isHidden = val
        editIcon.isHidden = !val
    }
    
    func setRowActionForSwipeRight(duration: TimeInterval){
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            deleteLabelConstraint?.constant = 0
            self.layoutIfNeeded()
        }, completion: {_ in
            self.updateTableView()
        })
    }
    
    func updateTableView(){
        if let tableView = delegate?.delegate?.customTableView{
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
