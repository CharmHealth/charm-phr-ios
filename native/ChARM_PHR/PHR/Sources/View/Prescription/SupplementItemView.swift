//
//  SupplementItemView.swift
//  phr
//
//  Created by prathi-13964 on 27/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate var mainTagNo: Int = 997929202

protocol SupplementItemDelegate: AnyObject{
    func supplementAction(action: PrescriptionAction, supplementPOJO: SupplementPOJO?, viewTag: Int?)
    func beginUpdates()
    func endUpdates()
}

class SupplementItemView: UIView{
    
    private let supplementImageView = UIImageView(image: UIImage(named: "SupplementIcon"))
    private let supplementNameView = UIView()
    private let supplementNameLabel = UILabel()
    private let verticalStackView = UIStackView()
    let collapseBtn = UIButton()
    let subStackView = UIStackView()
    weak var delegate: SupplementTableViewCell? = nil
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(supplementImageView)
        self.addSubview(supplementNameView)
        supplementNameView.addSubview(supplementNameLabel)
        supplementNameView.addSubview(collapseBtn)
        self.addSubview(verticalStackView)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        supplementImageView.setLeft(offSet: CARD_PADDING)
        supplementImageView.setTop(offSet: CARD_PADDING)
        supplementImageView.setWidth(constant: PRESCRIPTION_IMAGE_SIZE)
        supplementImageView.setHeight(constant: PRESCRIPTION_IMAGE_SIZE)
        
        supplementNameView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: supplementImageView, relatedAttribute: .right)
        supplementNameView.setRight(offSet: 0)
        supplementNameView.setTop(offSet: CARD_PADDING)
        
        supplementNameLabel.setLeft(offSet: 0)
        supplementNameLabel.setTop(offSet: 0)
        supplementNameLabel.setBottom(offSet: 0)
        supplementNameLabel.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: collapseBtn, relatedAttribute: .left)

        collapseBtn.setRight(offSet: -CARD_PADDING)
        collapseBtn.setTopRelatedToView(offSet: 0, relatedView: supplementNameLabel, relatedAttribute: .top)
        collapseBtn.setHeight(constant: 24)
        collapseBtn.setWidth(constant: 24)
        
        verticalStackView.setLeft(offSet: 0)
        verticalStackView.setRight(offSet: 0)
        verticalStackView.setTopRelatedToView(offSet: 0, relatedView: supplementNameLabel, relatedAttribute: .bottom)
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
        
        supplementNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        supplementNameLabel.textAlignment = .left
        supplementNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        supplementNameLabel.numberOfLines = 0
        supplementNameLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setValues(data: SupplementGroupPOJO, isFromReminderSelect: Bool){
        
        
        subStackView.subviews.forEach { subViews in
            subViews.removeFromSuperview()
        }
        subStackView.removeFromSuperview()
        
        verticalStackView.subviews.forEach { subViews in
            if subViews is SupplementEntryView{
                subViews.removeFromSuperview()
            }
        }
        
        supplementNameLabel.text = data.supplementName
        
        for (i,supplementPOJO) in data.supplementArr.enumerated(){
            
            let supplementEntryView = SupplementEntryView(delegate: delegate, tagNo: mainTagNo)
            mainTagNo += 1
            supplementEntryView.setValues(data: supplementPOJO, isFromReminderSelect: isFromReminderSelect)
            
            if i == 0{
                supplementEntryView.hideSeperatorLine = true
                verticalStackView.addArrangedSubview(supplementEntryView)
                verticalStackView.addArrangedSubview(subStackView)
            }
            else{
                supplementEntryView.hideSeperatorLine = false
                subStackView.addArrangedSubview(supplementEntryView)
            }
        }
        if data.supplementArr.count == 1{
            collapseBtn.isHidden = true
        }
        else{
            collapseBtn.isHidden = false
        }
        if data.isViewOpened{
            subStackView.layer.opacity = 1
        }
        else{
            subStackView.layer.opacity = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SupplementEntryView: UIView{
    
    private let verticalStackView = UIStackView()
    private let deleteLabel = UILabel()
    private let parentDetailView = UIView()
    private let parentDetailStackView = UIStackView()
    private let intakeView = UIView()
    private let intakeLabel = UILabel()
    private let detailsView = UIView()
    private let detailsStackView = UIStackView()
    private let editIcon = UIImageView()
    private let refillButton = UIButton()
    private let manufacturerView = UIView()
    private let manufacturerLabel = UILabel()
    private let manufacturerValueLabel = UILabel()
    private let prescribedByView = UIView()
    private let prescribedByLabel = UILabel()
    private let prescribedByValueLabel = UILabel()
    private let prescribedOnView = UIView()
    private let prescribedOnLabel = UILabel()
    private let prescribedOnValueLabel = UILabel()
    private let stopDateView = UIView()
    private let stopDateLabel = UILabel()
    private let stopDateValueLabel = UILabel()
    
    private var separatorLine: UIView? = nil
    private var deleteLabelConstraint: NSLayoutConstraint? = nil
    var supplementPOJO: SupplementPOJO? = nil
    private weak var delegate: SupplementItemDelegate? = nil
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
    
    init(delegate: SupplementItemDelegate?, tagNo: Int){
        super.init(frame: .zero)
        
        self.delegate = delegate
        self.tagNo = tagNo
        addSubviews()
    }
    
    private func addSubviews(){
        
        self.addSubview(deleteLabel)
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(parentDetailView)
        parentDetailView.addSubview(parentDetailStackView)
        parentDetailStackView.addArrangedSubview(intakeView)
        intakeView.addSubview(intakeLabel)
        parentDetailStackView.addArrangedSubview(detailsView)
        detailsView.addSubview(detailsStackView)
        detailsView.addSubview(editIcon)
        detailsView.addSubview(refillButton)
        detailsStackView.addArrangedSubview(manufacturerView)
        manufacturerView.addSubview(manufacturerLabel)
        manufacturerView.addSubview(manufacturerValueLabel)
        detailsStackView.addArrangedSubview(prescribedByView)
        prescribedByView.addSubview(prescribedByLabel)
        prescribedByView.addSubview(prescribedByValueLabel)
        detailsStackView.addArrangedSubview(prescribedOnView)
        prescribedOnView.addSubview(prescribedOnLabel)
        prescribedOnView.addSubview(prescribedOnValueLabel)
        detailsStackView.addArrangedSubview(stopDateView)
        stopDateView.addSubview(stopDateLabel)
        stopDateView.addSubview(stopDateValueLabel)
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        verticalStackView.setLeft(offSet: 0)
        verticalStackView.setTop(offSet: 0)
        verticalStackView.setBottom(offSet: 0)
        
        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: verticalStackView, relatedAttribute: .right)
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
        
        manufacturerLabel.setLeft(offSet: 0)
        manufacturerLabel.setTop(offSet: 0)
        manufacturerLabel.setWidth(constant: manufacturerLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        
        manufacturerValueLabel.setLeftRelatedToView(offSet: 0, relatedView: manufacturerLabel, relatedAttribute: .right)
        manufacturerValueLabel.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        manufacturerValueLabel.setTop(offSet: 0)
        manufacturerValueLabel.setBottom(offSet: 0)
        
        prescribedByLabel.setLeft(offSet: 0)
        prescribedByLabel.setTop(offSet: 0)
        prescribedByLabel.setWidth(constant: prescribedByLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        prescribedByLabel.setHeight(constant: prescribedByLabel.sizeThatFits(CGSize(width: 300, height: 50)).height)
        
        prescribedByValueLabel.setLeftRelatedToView(offSet: 0, relatedView: prescribedByLabel, relatedAttribute: .right)
        prescribedByValueLabel.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        prescribedByValueLabel.setTopRelatedToView(offSet: 0, relatedView: prescribedByLabel, relatedAttribute: .top)
        prescribedByValueLabel.setBottom(offSet: 0)
        
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
    }
    
    private func addProperties(){
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = STACKVIEW_VERTICAL_PADDING
        verticalStackView.alignment = .fill
        
        parentDetailStackView.axis = .vertical
        parentDetailStackView.spacing = STACKVIEW_VERTICAL_PADDING
        parentDetailStackView.alignment = .fill
        
        detailsStackView.axis = .vertical
        detailsStackView.spacing = STACKVIEW_VERTICAL_PADDING
        detailsStackView.alignment = .fill
        
        separatorLine = verticalStackView.addAndReturnTopBorder(color: UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR), borderWidth: LINE_HEIGHT)
        setLabelProperties(uiLabel: intakeLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        editIcon.image = UIImage(named: "EditIconBlue")
        
        refillButton.setProperties(titleStrKey: getString(key: "com.charmphr.add.MedicationAndSupplememnts.refill.title"), fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: ORANGE_REFILL_BG)
        refillButton.addCornerRadius(.SMALL)
        refillButton.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: ORANGE_REFILL_BG).cgColor
        refillButton.layer.borderWidth = BORDER_WIDTH
        refillButton.titleLabel?.textAlignment = .center
        
        manufacturerLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.manufacturer.title")
        setLabelProperties(uiLabel: manufacturerLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: manufacturerValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        prescribedByLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Prescribedby.title")
        setLabelProperties(uiLabel: prescribedByLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: prescribedByValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
        prescribedOnLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Prescribedon.title")
        setLabelProperties(uiLabel: prescribedOnLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: prescribedOnValueLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        
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
    
    fileprivate func setValues(data: SupplementPOJO, isFromReminderSelect: Bool){
        
        supplementPOJO = data
        if let fromDateString = data.patientSupplement?.fromDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
            prescribedOnValueLabel.text = fromDateString
            prescribedOnView.isHidden = false
        }
        else{
            prescribedOnView.isHidden = true
        }
        
        if data.patientSupplement?.isAddedByPatient == true{
            editIcon.isHidden = isFromReminderSelect
            refillButton.isHidden = true
            prescribedByView.isHidden = true
            manufacturerView.isHidden = true
        }
        else{
            editIcon.isHidden = true
            stopDateView.isHidden = true
        }
        
        let intakeString = data.getIntakeName(separator: ", ")
        
        if intakeString.isNilOrBlank(){
            intakeLabel.text = "-"
        }
        else{
            intakeLabel.text = intakeString
        }
        
        
        if let stopDate = data.patientSupplement?.toDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), stopDate.isNotBlank(){
            if data.patientSupplement?.isAddedByPatient == true || !prescribedOnView.isHidden{
                stopDateValueLabel.text = stopDate
                stopDateView.isHidden = false
            }
            else{
                stopDateView.isHidden = true
            }
        }
        else{
            stopDateView.isHidden = true
        }
        
        if data.patientSupplement?.isAddedByPatient == false{
            
            if let prescribedBy = data.patientSupplement?.memberName, prescribedBy.isNotBlank(){
                prescribedByValueLabel.text = prescribedBy
                prescribedByView.isHidden = false
            }
            else{
                prescribedByView.isHidden = true
            }
            if let manufacturer = data.supplement?.manufacturerName, manufacturer.isNotBlank(){
                manufacturerValueLabel.text = manufacturer
                manufacturerView.isHidden = false
            }
            else{
                manufacturerView.isHidden = true
            }
        }
        
        if !isCustomApp() && (data.patientSupplement?.allowRefill == true) && (data.patientSupplement?.isActive == true) && !(data.patientSupplement?.memberId.isNilOrBlank() ?? false) && !isFromReminderSelect{
            hideRefillBtn = false
            refillButton.addTarget(self, action: #selector(refillBtnClicked(btn:)), for: .touchUpInside)
        }
        else{
            hideRefillBtn = true
        }
        
        self.tag = tagNo
        self.isUserInteractionEnabled = true
        verticalStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapMedicationEntryView)))
        
        if !isFromReminderSelect{
            let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
            self.addGestureRecognizer(swiftLeft)
            
            let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftRight.direction = UISwipeGestureRecognizer.Direction.right
            self.addGestureRecognizer(swiftRight)
            
            deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))
        }
        
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
            setRowActionForSwipeLeft(duration: 0.4, isAddedByPatient: supplementPOJO?.patientSupplement?.isAddedByPatient ?? false)
        case UISwipeGestureRecognizer.Direction.right:
            setRowActionForSwipeRight(duration: 0.4)
        default:
            break
        }
    }
    
    @objc private func onTouchLabel(sender: UITapGestureRecognizer){
        
        setRowActionForSwipeRight(duration: 0.4)
        CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.prescriptions.alert.delete.supplement"), deleteClicked: { [self] in
            delegate?.supplementAction(action: .DELETE, supplementPOJO: supplementPOJO, viewTag: tagNo)
        })
    }
    
    @objc private func onTapMedicationEntryView(_ sender: UITapGestureRecognizer){
        hideSwipeRow()
        delegate?.supplementAction(action: .DID_SELECT, supplementPOJO: supplementPOJO, viewTag: nil)
    }
    
    @objc private func refillBtnClicked(btn: UIButton){
        delegate?.supplementAction(action: .REFILL, supplementPOJO: supplementPOJO, viewTag: nil)
    }
    
    private func setRowActionForSwipeLeft(duration: TimeInterval, isAddedByPatient: Bool){
        if isAddedByPatient{
            delegate?.beginUpdates()
            UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
                deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
                self.layoutIfNeeded()
            })
            delegate?.endUpdates()
            delegate?.supplementAction(action: .SWIPE_LEFT, supplementPOJO: nil, viewTag: tagNo)
        }
    }
    
    private func setRowActionForSwipeRight(duration: TimeInterval){
        swipeRightAction(duration: duration)
        delegate?.supplementAction(action: .SWIPE_RIGHT, supplementPOJO: nil, viewTag: tagNo)
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
        delegate?.supplementAction(action: .SWIPE_RIGHT, supplementPOJO: nil, viewTag: tagNo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
