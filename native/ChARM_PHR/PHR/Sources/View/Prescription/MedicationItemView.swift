//
//  MedicationItemView.swift
//  phr
//
//  Created by prathi-13964 on 27/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate var mainTagNo: Int = 287929202

protocol MedicationItemDelegate: AnyObject{
    func medicationAction(action: PrescriptionAction, medicationPOJO: MedicationPOJO?, viewTag: Int?)
    func beginUpdates()
    func endUpdates()
}

class MedicationItemView: UIView{
    
    private let medicationImageView = UIImageView(image: UIImage(named: "MedicationIcon"))
    private let medicationNameView = UIView()
    private let medicationNameLabel = UILabel()
    private let verticalStackView = UIStackView()
    let collapseBtn = UIButton()
    let subStackView = UIStackView()
    weak var delegate: MedicationItemDelegate? = nil
    
    init(){
        super.init(frame: .zero)
        setSubviews()
    }
    
    private func setSubviews(){
        self.addSubview(medicationImageView)
        self.addSubview(medicationNameView)
        medicationNameView.addSubview(medicationNameLabel)
        medicationNameView.addSubview(collapseBtn)
        self.addSubview(verticalStackView)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        medicationImageView.setLeft(offSet: CARD_PADDING)
        medicationImageView.setTop(offSet: CARD_PADDING)
        medicationImageView.setWidth(constant: PRESCRIPTION_IMAGE_SIZE)
        medicationImageView.setHeight(constant: PRESCRIPTION_IMAGE_SIZE)
        
        medicationNameView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: medicationImageView, relatedAttribute: .right)
        medicationNameView.setRight(offSet: 0)
        medicationNameView.setTop(offSet: CARD_PADDING)
        
        medicationNameLabel.setLeft(offSet: 0)
        medicationNameLabel.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: collapseBtn, relatedAttribute: .left)
        medicationNameLabel.setTop(offSet: 0)
        medicationNameLabel.setBottom(offSet: 0)

        collapseBtn.setRight(offSet: -CARD_PADDING)
        collapseBtn.setTopRelatedToView(offSet: 0, relatedView: medicationNameLabel, relatedAttribute: .top)
        collapseBtn.setHeight(constant: 24)
        collapseBtn.setWidth(constant: 24)
        
        verticalStackView.setLeft(offSet: 0)
        verticalStackView.setRight(offSet: 0)
        verticalStackView.setTopRelatedToView(offSet: 0, relatedView: medicationNameView, relatedAttribute: .bottom)
        verticalStackView.setBottom(offSet: 0)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 0
        verticalStackView.alignment = .fill
        
        subStackView.axis = .vertical
        subStackView.spacing = 0
        subStackView.alignment = .fill
        
        let arrowDownImg = UIImageView(image: UIImage(named: "Arrow_Down")).getModifiedImage(tintColor: THEME_COLOR)
        let arrowUpImg = UIImageView(image: UIImage(named: "Arrow_Up")).getModifiedImage(tintColor: THEME_COLOR)
        
        collapseBtn.setImage(arrowDownImg, for: .normal)
        collapseBtn.setImage(arrowUpImg, for: .selected)
        
        medicationNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        medicationNameLabel.textAlignment = .left
        medicationNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        medicationNameLabel.numberOfLines = 0
        medicationNameLabel.lineBreakMode = .byWordWrapping
    }
    
    func setValues(data: MedicationGroupPOJO, isFromReminderSelect: Bool){
        
        
        subStackView.subviews.forEach { subViews in
            subViews.removeFromSuperview()
        }
        subStackView.removeFromSuperview()
        
        verticalStackView.subviews.forEach { subViews in
            if subViews is MedicationEntryView{
                subViews.removeFromSuperview()
            }
        }
        
        medicationNameLabel.text = data.medicationName
        
        for (i,medicationPOJO) in data.medicationArr.enumerated(){
            
            let medicationEntryView = MedicationEntryView(delegate: delegate, tagNo: mainTagNo)
            mainTagNo += 1
            medicationEntryView.setValues(data: medicationPOJO, isFromReminderSelect: isFromReminderSelect)
            
            if i == 0{
                medicationEntryView.hideSeperatorLine = true
                verticalStackView.addArrangedSubview(medicationEntryView)
                verticalStackView.addArrangedSubview(subStackView)
            }
            else{
                medicationEntryView.hideSeperatorLine = false
                subStackView.addArrangedSubview(medicationEntryView)
            }
        }
        if data.medicationArr.count == 1{
            collapseBtn.isHidden = true
        }
        else{
            collapseBtn.isHidden = false
        }
        
        if data.isViewOpened{
            subStackView.isHidden = false
            subStackView.layer.opacity = 1
        }
        else{
            subStackView.isHidden = true
            subStackView.layer.opacity = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MedicationEntryView: UIView{
    
    private let parentDetailView = UIView()
    private let deleteLabel = UILabel()
    private let parentDetailStackView = UIStackView()
    private let intakeView = UIView()
    private let intakeLabel = UILabel()
    private let prescribedByView = UIView()
    private let prescribedByLabel = UILabel()
    private let prescribedByValueLabel = UILabel()
    private let detailsView = UIView()
    private let editIcon = UIImageView()
    private let refillButton = UIButton()
    private let detailsStackView = UIStackView()
    private let prescribedOnView = UIView()
    private let prescribedOnLabel = UILabel()
    private let prescribedOnValueLabel = UILabel()
    private let stopDateView = UIView()
    private let stopDateLabel = UILabel()
    private let stopDateValueLabel = UILabel()
    private let refillView = UIView()
    private let refillLabel = UILabel()
    private let refillValueLabel = UILabel()
    private let dispenseView = UIView()
    private let dispenseLabel = UILabel()
    private let dispenseValueLabel = UILabel()
    
    private var separatorLine: UIView? = nil
    private var deleteLabelConstraint: NSLayoutConstraint? = nil
    var medicationPOJO: MedicationPOJO? = nil
    private weak var delegate: MedicationItemDelegate? = nil
    private var tagNo: Int = 0
    
    fileprivate var hideRefillBtn: Bool = false{
        didSet{
            refillButton.isHidden = hideRefillBtn
        }
    }
    
    fileprivate var hideSeperatorLine: Bool = false{
        didSet{
            if hideSeperatorLine{
                separatorLine?.frame.size.height = 0
            }
            else{
                separatorLine?.frame.size.height = LINE_HEIGHT
            }
        }
    }
    
    init(delegate: MedicationItemDelegate?, tagNo: Int){
        super.init(frame: .zero)
        
        self.delegate = delegate
        self.tagNo = tagNo
        addSubviews()
    }
    
    private func addSubviews(){
        
        self.addSubview(deleteLabel)
        self.addSubview(parentDetailView)
        parentDetailView.addSubview(parentDetailStackView)
        parentDetailStackView.addArrangedSubview(intakeView)
        intakeView.addSubview(intakeLabel)
        parentDetailStackView.addArrangedSubview(prescribedByView)
        prescribedByView.addSubview(prescribedByLabel)
        prescribedByView.addSubview(prescribedByValueLabel)
        parentDetailStackView.addArrangedSubview(detailsView)
        detailsView.addSubview(editIcon)
        detailsView.addSubview(refillButton)
        detailsView.addSubview(detailsStackView)
        detailsStackView.addArrangedSubview(prescribedOnView)
        prescribedOnView.addSubview(prescribedOnLabel)
        prescribedOnView.addSubview(prescribedOnValueLabel)
        detailsStackView.addArrangedSubview(stopDateView)
        stopDateView.addSubview(stopDateLabel)
        stopDateView.addSubview(stopDateValueLabel)
        detailsStackView.addArrangedSubview(refillView)
        refillView.addSubview(refillLabel)
        refillView.addSubview(refillValueLabel)
        detailsStackView.addArrangedSubview(dispenseView)
        dispenseView.addSubview(dispenseLabel)
        dispenseView.addSubview(dispenseValueLabel)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        parentDetailView.setLeft(offSet: 0)
        parentDetailView.setTop(offSet: 0)
        parentDetailView.setBottom(offSet: 0)
        
        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: parentDetailView, relatedAttribute: .right)
        deleteLabel.setRight(offSet: 0)
        deleteLabel.setTop(offSet: 0)
        deleteLabel.setBottom(offSet: 0)
        deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
        
        parentDetailStackView.setLeft(offSet: PRESCRIPTION_IMAGE_SIZE + (CARD_PADDING * 2))
        parentDetailStackView.setRight(offSet: 0)
        parentDetailStackView.setTop(offSet: PADDING_6)
        parentDetailStackView.setBottom(offSet: -PADDING_8)
        
        intakeLabel.setLeft(offSet: 0)
        intakeLabel.setRight(offSet: -PADDING_5)
        intakeLabel.setTop(offSet: 0)
        intakeLabel.setBottom(offSet: 0)
        
        prescribedByLabel.setLeft(offSet: 0)
        prescribedByLabel.setTop(offSet: 0)
        prescribedByLabel.setWidth(constant: prescribedByLabel.sizeThatFits(CGSize(width: 300, height: 100)).width)
        prescribedByLabel.setHeight(constant: prescribedByLabel.sizeThatFits(CGSize(width: 300, height: 100)).height)
        
        prescribedByValueLabel.setLeftRelatedToView(offSet: 0, relatedView: prescribedByLabel, relatedAttribute: .right)
        prescribedByValueLabel.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        prescribedByValueLabel.setTopRelatedToView(offSet: 0, relatedView: prescribedByLabel, relatedAttribute: .top)
        prescribedByValueLabel.setBottom(offSet: 0)
        
        detailsStackView.setLeft(offSet: 0)
        detailsStackView.setTop(offSet: 0)
        detailsStackView.setBottom(offSet: 0)
        
        editIcon.setRight(offSet: -10)
        editIcon.setBottom(offSet: 0)
        editIcon.setHeight(constant: 20)
        editIcon.setWidth(constant: 20)
        
        refillButton.setRight(offSet: -CARD_PADDING)
        refillButton.setBottomRelatedToView(offSet: 0, relatedView: detailsStackView, relatedAttribute: .bottom)
        refillButton.setWidth(constant: refillButton.sizeThatFits(CGSize(width: 300, height: 50)).width + (CARD_PADDING * 2))
        refillButton.setHeight(constant: refillButton.sizeThatFits(CGSize(width: 300, height: 50)).height)
        
        prescribedOnLabel.setLeft(offSet: 0)
        prescribedOnLabel.setTop(offSet: 0)
        prescribedOnLabel.setWidth(constant: prescribedOnLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        prescribedOnLabel.setHeight(constant: prescribedOnLabel.sizeThatFits(CGSize(width: 300, height: 50)).height)
        
        prescribedOnValueLabel.setLeftRelatedToView(offSet: 0, relatedView: prescribedOnLabel, relatedAttribute: .right)
        prescribedOnValueLabel.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        prescribedOnValueLabel.setTopRelatedToView(offSet: 0, relatedView: prescribedOnLabel, relatedAttribute: .top)
        prescribedOnValueLabel.setBottom(offSet: 0)
        
        stopDateLabel.setLeft(offSet: 0)
        stopDateLabel.setTop(offSet: 0)
        stopDateLabel.setBottom(offSet: 0)
        stopDateLabel.setWidth(constant: stopDateLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        
        stopDateValueLabel.setLeftRelatedToView(offSet: 0, relatedView: stopDateLabel, relatedAttribute: .right)
        stopDateValueLabel.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        stopDateValueLabel.setTop(offSet: 0)
        stopDateValueLabel.setBottom(offSet: 0)
        
        dispenseLabel.setLeft(offSet: 0)
        dispenseLabel.setTop(offSet: 0)
        dispenseLabel.setBottom(offSet: 0)
        dispenseLabel.setWidth(constant: dispenseLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        
        dispenseValueLabel.setLeftRelatedToView(offSet: 0, relatedView: dispenseLabel, relatedAttribute: .right)
        dispenseValueLabel.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        dispenseValueLabel.setTop(offSet: 0)
        dispenseValueLabel.setBottom(offSet: 0)
        
        refillLabel.setLeft(offSet: 0)
        refillLabel.setTop(offSet: 0)
        refillLabel.setBottom(offSet: 0)
        refillLabel.setWidth(constant: refillLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        
        refillValueLabel.setLeftRelatedToView(offSet: 0, relatedView: refillLabel, relatedAttribute: .right)
        refillValueLabel.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        refillValueLabel.setTop(offSet: 0)
        refillValueLabel.setBottom(offSet: 0)
    }
    
    private func addProperties(){
        
        parentDetailStackView.axis = .vertical
        parentDetailStackView.spacing = STACKVIEW_VERTICAL_PADDING
        parentDetailStackView.alignment = .fill
        
        detailsStackView.axis = .vertical
        detailsStackView.spacing = STACKVIEW_VERTICAL_PADDING
        detailsStackView.alignment = .fill
        
        separatorLine = parentDetailView.addAndReturnTopBorder(color: UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR), borderWidth: LINE_HEIGHT)
        setLabelProperties(uiLabel: intakeLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        prescribedByLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Prescribedby.title")
        setLabelProperties(uiLabel: prescribedByLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: prescribedByValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        prescribedOnLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Prescribedon.title")
        setLabelProperties(uiLabel: prescribedOnLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: prescribedOnValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        editIcon.image = UIImage(named: "EditIconBlue")
        
        refillButton.setProperties(titleStrKey: getString(key: "com.charmphr.add.MedicationAndSupplememnts.refill.title"), fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: ORANGE_REFILL_BG)
        refillButton.addCornerRadius(.SMALL)
        refillButton.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: ORANGE_REFILL_BG).cgColor
        refillButton.layer.borderWidth = BORDER_WIDTH
        refillButton.titleLabel?.textAlignment = .center
        
        refillLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Refills.title")
        setLabelProperties(uiLabel: refillLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: refillValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        dispenseLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.dispense.title")
        setLabelProperties(uiLabel: dispenseLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: dispenseValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        stopDateLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.stopDate.title")
        setLabelProperties(uiLabel: stopDateLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: stopDateValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        deleteLabel.text = getString(key: "com.charmphr.action.delete")
        deleteLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        deleteLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        deleteLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
        deleteLabel.textAlignment = .center
        deleteLabel.addCornerRadius(.SMALL)
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    private func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textAlignment = .left
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
    }
    
    fileprivate func setValues(data: MedicationPOJO, isFromReminderSelect: Bool){
        
        medicationPOJO = data
        if let fromDateString = data.patientMedication?.fromDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
            prescribedOnValueLabel.text = fromDateString
            prescribedOnView.isHidden = false
        }
        else{
            prescribedOnView.isHidden = true
        }
        
        if data.patientMedication?.addedByPatient == true{
            editIcon.isHidden = isFromReminderSelect
            refillButton.isHidden = true
            dispenseView.isHidden = true
            refillView.isHidden = true
        }
        else{
            editIcon.isHidden = true
        }
        
        let intakeString = data.getIntakeName(separator: ", ")
        
        if intakeString.isNilOrBlank(){
            intakeLabel.text = "-"
        }
        else{
            intakeLabel.text = intakeString
        }
        
        var prescribedBy: String? = nil
        if data.patientMedication?.addedByPatient == true{
            prescribedBy = data.patientMedication?.prescribedBy
        }
        else{
            prescribedBy = data.patientMedication?.memberName
            
            if let refill = data.patientMedication?.refill, refill.isNotBlank(){
                refillValueLabel.text = refill
                refillView.isHidden = false
            }
            else{
                refillView.isHidden = true
            }
            if let dispense = data.patientMedication?.dispense, dispense.isNotBlank(){
                dispenseValueLabel.text = dispense
                dispenseView.isHidden = false
            }
            else{
                dispenseView.isHidden = true
            }
        }
        
        if let prescribedBy = prescribedBy, prescribedBy.isNotBlank(){
            
            if data.patientMedication?.addedAs == PRESCRIPTION || data.patientMedication?.addedByPatient == true{
                prescribedByValueLabel.text = prescribedBy
                prescribedByView.isHidden = false
            }
            else{
                prescribedByView.isHidden = true
            }
        }
        else{
            prescribedByView.isHidden = true
        }
        
        if let stopDate = data.patientMedication?.toDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
            stopDateValueLabel.text = stopDate
            stopDateView.isHidden = false
        }
        else{
            stopDateView.isHidden = true
        }
        
        if !isCustomApp() && data.patientMedication?.addedAs == PRESCRIPTION && (data.patientMedication?.allowRefill == true) && (data.patientMedication?.isActive == true) && !(data.patientMedication?.memberId.isNilOrBlank() ?? false) && !isFromReminderSelect{
            hideRefillBtn = false
            refillButton.addTarget(self, action: #selector(refillBtnClicked(btn:)), for: .touchUpInside)
        }
        else{
            hideRefillBtn = true
        }
        
        self.tag = tagNo
        self.isUserInteractionEnabled = true
        parentDetailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapMedicationEntryView)))
        
        if !isFromReminderSelect{
            let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
            self.addGestureRecognizer(swiftLeft)
            
            let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftRight.direction = UISwipeGestureRecognizer.Direction.right
            self.addGestureRecognizer(swiftRight)
            
            deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))
        }
        
        detailsStackView.removeConstraint(attribute: .right)
        if !editIcon.isHidden{
            detailsStackView.setRightRelatedToView(offSet: -10, relatedView: editIcon, relatedAttribute: .left)
        }
        else if !refillButton.isHidden{
            detailsStackView.setRightRelatedToView(offSet: -10, relatedView: refillButton, relatedAttribute: .left)
        }
        else{
            detailsStackView.setRight(offSet: -10)
        }
    }
    
    @objc private func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.left:
            setRowActionForSwipeLeft(duration: 0.4, isAddedByPatient: medicationPOJO?.patientMedication?.addedByPatient ?? false)
        case UISwipeGestureRecognizer.Direction.right:
            setRowActionForSwipeRight(duration: 0.4)
        default:
            break
        }
    }
    
    @objc private func onTouchLabel(sender: UITapGestureRecognizer){
        
        setRowActionForSwipeRight()
        CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.prescriptions.alert.delete.medication"), deleteClicked: { [self] in
            delegate?.medicationAction(action: .DELETE, medicationPOJO: medicationPOJO, viewTag: tagNo)
        })
    }
    
    @objc private func onTapMedicationEntryView(_ sender: UITapGestureRecognizer){
        hideSwipeRow()
        delegate?.medicationAction(action: .DID_SELECT, medicationPOJO: medicationPOJO, viewTag: nil)
    }
    
    @objc private func refillBtnClicked(btn: UIButton){
        delegate?.medicationAction(action: .REFILL, medicationPOJO: medicationPOJO, viewTag: nil)
    }
    
    private func setRowActionForSwipeLeft(duration: TimeInterval, isAddedByPatient: Bool){
        if isAddedByPatient{
            delegate?.beginUpdates()
            UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
                deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
                self.layoutIfNeeded()
            })
            delegate?.endUpdates()
            delegate?.medicationAction(action: .SWIPE_LEFT, medicationPOJO: medicationPOJO, viewTag: tagNo)
        }
    }
    
    private func setRowActionForSwipeRight(duration: TimeInterval = 0.4){
        swipeRightAction(duration: duration)
        delegate?.medicationAction(action: .SWIPE_RIGHT, medicationPOJO: nil, viewTag: tagNo)
    }
    
    func swipeRightAction(duration: TimeInterval = 0.4){
        delegate?.beginUpdates()
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            deleteLabelConstraint?.constant = 0
            self.layoutIfNeeded()
        })
        delegate?.endUpdates()
    }
    
    private func hideSwipeRow(){
        deleteLabelConstraint?.constant = 0
        delegate?.medicationAction(action: .SWIPE_RIGHT, medicationPOJO: nil, viewTag: tagNo)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
