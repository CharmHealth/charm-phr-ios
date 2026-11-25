//
//  ReminderDetailDialogView.swift
//  phr
//
//  Created by prathi-13964 on 24/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let REMINDER_Y_SPACE_14: CGFloat = 14
fileprivate let reminderImageSize: CGFloat = 25

class ReminderDetailDialogView: UIView{
    
    private let containterView = UIStackView()
    private let scheduleView = UIView()
    private let stackView = UIStackView()
    private let patientNameLabel = UILabel()
    private let scheduleSubView = UIView()
    private let scheduleForLabel = UILabel()
    private let timeLabel = UILabel()
    let editButton = UIButton()
    let historyButton = UIButton()
    let closeBtn = UIButton()
    private let reminderItemView = UIView()
    let scrollView = UIScrollView()
    private let reminderItemStackView = UIStackView()
    private let takenView = UIView()
    let takenBtn = UIButton()
    private let skipView = UIView()
    let skipBtn = UIButton()
    let activityIndicator = UIActivityIndicatorView()

    weak var delegate: ReminderDetailDialogViewController?
    
    init(delegate: ReminderDetailDialogViewController, patientId: String?){
        super.init(frame: .zero)
        self.delegate = delegate
        initViews()
        
        if delegate.isFromNotification, let patientFirstName = PatientDataHandler.getPatient(patientId: patientId)?.patientData?.fullName{
            patientNameLabel.text = "\(getString(key: "com.charmphr.reminder.detail.hi.patientName.title"))\(patientFirstName)"
            stackView.setRightRelatedToView(offSet: -PADDING_5, relatedView: closeBtn, relatedAttribute: .left)
        }
        else{
            stackView.setRightRelatedToView(offSet: -PADDING_5, relatedView: historyButton, relatedAttribute: .left)
        }
    }
    
    private func initViews(){
        
        self.addSubview(containterView)
        self.addSubview(activityIndicator)
        containterView.addArrangedSubview(scheduleView)
        scheduleView.addSubview(stackView)
        stackView.addArrangedSubview(patientNameLabel)
        stackView.addArrangedSubview(scheduleSubView)
        scheduleSubView.addSubview(scheduleForLabel)
        scheduleSubView.addSubview(timeLabel)
        scheduleView.addSubview(historyButton)
        scheduleView.addSubview(editButton)
        scheduleView.addSubview(closeBtn)
        containterView.addArrangedSubview(reminderItemView)
        reminderItemView.addSubview(scrollView)
        scrollView.addSubview(reminderItemStackView)
        containterView.addArrangedSubview(takenView)
        takenView.addSubview(takenBtn)
        containterView.addArrangedSubview(skipView)
        skipView.addSubview(skipBtn)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        // Width comes from the dialog's own width (set by the presenting VC), not the launch-time
        // screen width, so every row follows fold/unfold and rotation. Rows fill via .fill alignment.
        containterView.setLeft(offSet: 0)
        containterView.setRight(offSet: 0)
        containterView.setTop(offSet: 0)
        containterView.setBottom(offSet: 0)

        stackView.setLeft(offSet: X_SPACE)
        stackView.setTop(offSet: REMINDER_Y_SPACE_14)
        stackView.setBottom(offSet: -REMINDER_Y_SPACE_14)

        patientNameLabel.setLeft(offSet: 0)
        patientNameLabel.setRight(offSet: 0)
        
        scheduleSubView.setLeft(offSet: 0)
        scheduleSubView.setRight(offSet: 0)
        
        scheduleForLabel.setLeft(offSet: 0)
        scheduleForLabel.setTop(offSet: 0)
        scheduleForLabel.setBottom(offSet: 0)
        scheduleForLabel.setWidth(constant: scheduleForLabel.sizeThatFits(CGSize(width: 500, height: 100)).width)
        
        timeLabel.setLeftRelatedToView(offSet: 0, relatedView: scheduleForLabel, relatedAttribute: .right)
        timeLabel.setTop(offSet: 0)
        timeLabel.setBottom(offSet: 0)
        timeLabel.setRight(offSet: 0)
        
        historyButton.setCenterY(view: stackView)
        historyButton.setWidth(constant: BUTTON_HEIGHT_20 + (CARD_PADDING * 2))
        historyButton.setHeight(constant: BUTTON_HEIGHT_20 + (CARD_PADDING * 2))
        historyButton.setRightRelatedToView(offSet: 0, relatedView: editButton, relatedAttribute: .left)
        
        editButton.setCenterY(view: stackView)
        editButton.setWidth(constant: reminderEditBtnSize + (CARD_PADDING * 2))
        editButton.setHeight(constant: reminderEditBtnSize + CARD_PADDING)
        editButton.setRight(offSet: -PADDING_5)
        
        closeBtn.setCenterY(view: stackView)
        closeBtn.setWidth(constant: BUTTON_HEIGHT_20 + (CARD_PADDING * 2))
        closeBtn.setHeight(constant: BUTTON_HEIGHT_20 + (CARD_PADDING * 2))
        closeBtn.setRight(offSet: -PADDING_5)
        
        scrollView.setLeft(offSet: 0)
        scrollView.setRight(offSet: 0)
        scrollView.setTop(offSet: 0)
        scrollView.setBottom(offSet: 0)

        reminderItemStackView.setLeft(offSet: 0)
        reminderItemStackView.setRight(offSet: 0)
        reminderItemStackView.setTop(offSet: 0)
        reminderItemStackView.setBottom(offSet: 0)
        // Edge pins inside a scroll view only set content bounds; tie the width to the visible area.
        reminderItemStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        // The list wants its full height; the presenting VC caps the dialog to the safe area,
        // so beyond that the list scrolls (replaces the launch-time applicationFrame.height cap).
        let fitContent = scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        fitContent.priority = .defaultHigh
        fitContent.isActive = true

        takenView.setHeight(constant: reminderPopSubviewHeight)
        
        takenBtn.setLeft(offSet: CARD_PADDING)
        takenBtn.setRight(offSet: -CARD_PADDING)
        takenBtn.setTop(offSet: CELL_PADDING)
        takenBtn.setBottom(offSet: -CELL_PADDING)
        
        skipView.setHeight(constant: reminderPopSubviewHeight)
        
        skipBtn.setLeft(offSet: CARD_PADDING)
        skipBtn.setRight(offSet: -CARD_PADDING)
        skipBtn.setTop(offSet: CELL_PADDING)
        skipBtn.setBottom(offSet: -CELL_PADDING)
    }
    
    private func addProperties(){
        
        self.addCornerRadius(.LARGE)
        self.backgroundColor = .white
        
        containterView.axis = .vertical
        containterView.alignment = .fill
        containterView.spacing = 0
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        
        if let delegate = delegate{
            if delegate.isFromNotification{
                patientNameLabel.isHidden = false
                
                patientNameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EIGHTEEN, weight: .semibold, fontcolor: TEXT_COLOR_BLACK75)
                patientNameLabel.adjustsFontSizeToFitWidth = true
                
                scheduleForLabel.setProperties(textKey: getString(key: "com.charmphr.reminder.detail.scheduleFor.title"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK75)
                timeLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK75)
            }
            else{
                patientNameLabel.isHidden = true
                
                scheduleForLabel.setProperties(textKey: getString(key: "com.charmphr.reminder.detail.scheduleFor.title"), fontsize: FONT_SIZE_EIGHTEEN, weight: .regular, fontcolor: TEXT_COLOR_BLACK75)
                timeLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EIGHTEEN, weight: .semibold, fontcolor: TEXT_COLOR_BLACK75)
            }
        }
        
        historyButton.setImage(UIImage(named: "ReminderHistory"), for: .normal)
        historyButton.contentVerticalAlignment = .fill
        historyButton.contentHorizontalAlignment = .fill
        historyButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        editButton.setImage(UIImage(named: "ReminderEdit"), for: .normal)
        editButton.contentVerticalAlignment = .fill
        editButton.contentHorizontalAlignment = .fill
        editButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        closeBtn.setImage(UIImage(named: "Reminder_Cross"), for: .normal)
        closeBtn.contentVerticalAlignment = .fill
        closeBtn.contentHorizontalAlignment = .fill
        closeBtn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        closeBtn.addTarget(self, action: #selector(onClickCloseBtn), for: .touchUpInside)
        
        reminderItemStackView.axis = .vertical
        reminderItemStackView.alignment = .fill
        reminderItemStackView.spacing = 0
        
        takenBtn.setProperties(titleStrKey: getString(key: "com.charmphr.reminder.detail.taken.title"), fontsize: FONT_SIZE_TWENTY, weight: .medium, fontcolor: TEXT_COLOR_BLUE)
        takenBtn.setTitleColor(.systemBlue, for: .normal)
        skipBtn.setProperties(titleStrKey: getString(key: "com.charmphr.reminder.detail.skip.title"), fontsize: FONT_SIZE_TWENTY, weight: .regular, fontcolor: TEXT_COLOR_BRIGHT_RED)
        
        scheduleView.addBottomBorder(color: UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR), borderWidth: BORDER_WIDTH)
        reminderItemView.addBottomBorder(color: UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR), borderWidth: BORDER_WIDTH)
        takenView.addBottomBorder(color: UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR), borderWidth: BORDER_WIDTH)
        takenView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTakenView)))
        skipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSkipView)))
    }
    
    @objc func onClickCloseBtn(){
        delegate?.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REMINDER_POP_DISMISSED"), object: nil)
    }
    
    @objc func onTapTakenView(_ sender: UITapGestureRecognizer){
        delegate?.onClickTakenBtn()
    }
    
    @objc func onTapSkipView(_ sender: UITapGestureRecognizer){
        delegate?.OnClickSkipBtn()
    }
    
    func setReminderItems(reminderPOJO: ReminderPOJO, isCheckBoxHidden: Bool){
        let reminderItemView = UIView()
        let imageView = UIView()
        let imageSubView = UIImageView()
        let reminderItemNameView = UIView()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        let buttonView = UIView()
        let checkBoxBtn = UIButton()
        let reminderCheckBoxSize: CGFloat = 24
        
        reminderItemStackView.addArrangedSubview(reminderItemView)
        reminderItemView.addSubview(imageView)
        imageView.addSubview(imageSubView)
        reminderItemView.addSubview(reminderItemNameView)
        reminderItemNameView.addSubview(titleLabel)
        reminderItemNameView.addSubview(descriptionLabel)
        reminderItemView.addSubview(buttonView)
        buttonView.addSubview(checkBoxBtn)
        
        if reminderPOJO.reminderDetails?.moduleType == ReminderModuleEnum.medication {
            imageSubView.image = UIImage(named: "MedicationIcon")
        }
        else if reminderPOJO.reminderDetails?.moduleType == ReminderModuleEnum.supplement{
            imageSubView.image = UIImage(named: "SupplementIcon")
        }
        else if reminderPOJO.reminderDetails?.moduleType == ReminderModuleEnum.appointment{
            //Code for appointment icon
        }
        
        titleLabel.setProperties(textKey: reminderPOJO.reminderDetails?.title ?? "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_DARK)
        titleLabel.numberOfLines = 0
        descriptionLabel.setProperties(textKey: reminderPOJO.reminderDetails?.descripiton ?? "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        checkBoxBtn.setImage(UIImage(named: "CheckboxUnselected"), for: .normal)
        checkBoxBtn.setImage(UIImage(named: "CheckboxSelected"), for: .selected)
        checkBoxBtn.isHidden = isCheckBoxHidden
        checkBoxBtn.isSelected = true
        delegate?.setCheckBoxBtnAction(btn: checkBoxBtn, itemView: reminderItemView, reminderPOJO: reminderPOJO)
        
        reminderItemView.setLeft(offSet: 0)
        reminderItemView.setRight(offSet: 0)
        
        imageView.setLeft(offSet: X_SPACE)
        imageView.setTop(offSet: 0)
        imageView.setBottom(offSet: 0)
        
        imageSubView.setLeft(offSet: 0)
        imageSubView.setRight(offSet: 0)
        imageSubView.setTop(offSet: 12)
        imageSubView.setWidth(constant: reminderImageSize)
        imageSubView.setHeight(constant: reminderImageSize)
        
        reminderItemNameView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: imageView, relatedAttribute: .right)
        reminderItemNameView.setTop(offSet: CARD_PADDING)
        reminderItemNameView.setBottom(offSet: -X_SPACE)
        reminderItemNameView.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: buttonView, relatedAttribute: .left)
        
        titleLabel.setLeft(offSet: 0)
        titleLabel.setRight(offSet: 0)
        titleLabel.setTop(offSet: 0)
        
        descriptionLabel.setLeft(offSet: 0)
        descriptionLabel.setRight(offSet: 0)
        descriptionLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: titleLabel, relatedAttribute: .bottom)
        descriptionLabel.setBottom(offSet: 0)
        
        buttonView.setRight(offSet: -X_SPACE)
        buttonView.setTop(offSet: 0)
        buttonView.setBottom(offSet: 0)
        
        checkBoxBtn.setCenterY()
        checkBoxBtn.setLeft(offSet: 0)
        checkBoxBtn.setRight(offSet: 0)
        checkBoxBtn.setWidth(constant: reminderCheckBoxSize)
        checkBoxBtn.setHeight(constant: reminderCheckBoxSize)
    }
    
    func setTimeLabelText(str: String?){
        timeLabel.text = str
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
