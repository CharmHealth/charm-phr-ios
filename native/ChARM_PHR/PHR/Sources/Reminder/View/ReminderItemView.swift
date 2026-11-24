//
//  ReminderItemView.swift
//  phr
//
//  Created by prathi-13964 on 23/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let reminderTodayItemImageSize: CGFloat = 15
fileprivate let reminderTodayItemBorderColor: UInt = 0xDADADAFF
fileprivate let REMINDER_ACTIVE_TEXT_COLOR: UInt = 0x27A228FF
fileprivate let REMINDER_ACTIVE_BG_COLOR: UInt = 0x27A2281A
fileprivate let REMINDER_COMPLETED_TEXT_COLOR: UInt = 0x838383FF
fileprivate let REMINDER_COMPLETED_BG_COLOR: UInt = 0xDADADA80
fileprivate let PRESCRIPTION_ITEM_IMAGE_SIZE: CGFloat = 26

class ReminderTodayItemView: UIView{
    
    private let timeView = UIView()
    let timeLabel = UILabel()
    let selectAllBtn = UIButton()
    private let drugsStackView = UIStackView()
    var tableViewCellDelegate: ReminderTodayTableViewCell?
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(timeView)
        timeView.addSubview(timeLabel)
        timeView.addSubview(selectAllBtn)
        self.addSubview(drugsStackView)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        timeView.setLeft(offSet: 0)
        timeView.setRight(offSet: 0)
        timeView.setTop(offSet: 0)
        
        drugsStackView.setLeft(offSet: 0)
        drugsStackView.setRight(offSet: 0)
        drugsStackView.setTopRelatedToView(offSet: 0, relatedView: timeView, relatedAttribute: .bottom)
        drugsStackView.setBottom(offSet: 0)
        
        timeLabel.setLeft(offSet: CARD_PADDING)
        timeLabel.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: selectAllBtn, relatedAttribute: .left)
        timeLabel.setTop(offSet: SPACE_BW_TWO_SECTIONS)
        timeLabel.setBottom(offSet: -SPACE_BW_TWO_SECTIONS)
        
        selectAllBtn.setRight(offSet: -CARD_PADDING)
        selectAllBtn.setTop(offSet: SPACE_BW_TWO_SECTIONS)
        selectAllBtn.setBottom(offSet: -SPACE_BW_TWO_SECTIONS)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        drugsStackView.axis = .vertical
        drugsStackView.alignment = .fill
        drugsStackView.spacing = 0
        
        timeLabel.setProperties(textKey: "", fontsize: FONT_SIZE_TWENTY, weight: .regular, fontcolor: REMINDER_TIME_TEXT_COLOR)
        selectAllBtn.setProperties(titleStrKey: getString(key: "com.charmphr.reminder.today.item.selectAll.title"), fontsize: FONT_SIZE_EXTRALARGE, weight: .regular, fontcolor: THEME_COLOR)
    }
    
    func setDrugView(reminderPOJO: ReminderPOJO, index: Int){
        let reminderItemView = UIView()

        let reminderItemNameView = UIView()
        let selectImageView = UIView()
        let reminderImageTitleView = UIView()
        let imageView = UIImageView()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        let tickIcon = UIImageView(image: UIImage(named: "Tick_green"))
        let crossIcon = UIImageView(image: UIImage(named: "Cross_red"))
        let questionIcon = UIImageView(image: UIImage(named: "Question_grey"))
        
        drugsStackView.addArrangedSubview(reminderItemView)
        reminderItemView.addSubview(reminderItemNameView)
        reminderItemNameView.addSubview(reminderImageTitleView)
        reminderImageTitleView.addSubview(imageView)
        reminderImageTitleView.addSubview(titleLabel)
        reminderItemNameView.addSubview(descriptionLabel)
        reminderItemView.addSubview(selectImageView)
        selectImageView.addSubview(tickIcon)
        selectImageView.addSubview(crossIcon)
        selectImageView.addSubview(questionIcon)
        
        if reminderPOJO.reminderDetails?.moduleType == ReminderModuleEnum.medication {
            imageView.image = UIImage(named: "MedicationIcon")
        }
        else if reminderPOJO.reminderDetails?.moduleType == ReminderModuleEnum.supplement{
            imageView.image = UIImage(named: "SupplementIcon")
        }
        else if reminderPOJO.reminderDetails?.moduleType == ReminderModuleEnum.appointment{
            //Code for appointment icon
        }
        
        titleLabel.setProperties(textKey: reminderPOJO.reminderDetails?.title ?? "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_DARK)
        titleLabel.numberOfLines = 0
        descriptionLabel.setProperties(textKey: reminderPOJO.reminderDetails?.descripiton ?? "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        reminderItemView.tag = index
        
        reminderItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapReminderItemView(sender:))))
        
        if let reminderHistory = reminderPOJO.reminderHistoryDetail?.reminderHistory{
            
            if reminderHistory.status == 0{
                crossIcon.isHidden = false
                tickIcon.isHidden = true
                questionIcon.isHidden = true
            }
            else if reminderHistory.status == 1{
                crossIcon.isHidden = true
                tickIcon.isHidden = false
                questionIcon.isHidden = true
            }
        }
        else{
            crossIcon.isHidden = true
            tickIcon.isHidden = true
            questionIcon.isHidden = false
        }
        
        reminderItemNameView.setLeft(offSet: 0)
        reminderItemNameView.setTop(offSet: 0)
        reminderItemNameView.setBottom(offSet: 0)
        reminderItemNameView.setRightRelatedToView(offSet: 0, relatedView: selectImageView, relatedAttribute: .left)
        
        selectImageView.setTop(offSet: 0)
        selectImageView.setBottom(offSet: 0)
        selectImageView.setRight(offSet: 0)
        selectImageView.setWidth(constant: PRESCRIPTION_IMAGE_SIZE)
        
        reminderImageTitleView.setTop(offSet: CARD_PADDING)
        reminderImageTitleView.setLeft(offSet: 0)
        reminderImageTitleView.setRight(offSet: 0)
        
        imageView.setTop(offSet: 0)
        imageView.setLeft(offSet: ITEM_VERTICAL_MARGIN)
        imageView.setWidth(constant: PRESCRIPTION_ITEM_IMAGE_SIZE)
        imageView.setHeight(constant: PRESCRIPTION_ITEM_IMAGE_SIZE)
        
        titleLabel.setLeftRelatedToView(offSet: PADDING_5, relatedView: imageView, relatedAttribute: .right)
        titleLabel.setRight(offSet: 0)
        titleLabel.setTop(offSet: 0)
        titleLabel.setBottom(offSet: 0)
        
        descriptionLabel.setLeftRelatedToView(offSet: PADDING_5, relatedView: imageView, relatedAttribute: .right)
        descriptionLabel.setTopRelatedToView(offSet: 3, relatedView: reminderImageTitleView, relatedAttribute: .bottom)
        descriptionLabel.setBottom(offSet: -CARD_PADDING)
        descriptionLabel.setRight(offSet: -ITEM_VERTICAL_MARGIN)
        
        tickIcon.setRight(offSet: -X_SPACE)
        tickIcon.setCenterY()
        tickIcon.setWidth(constant: reminderTodayItemImageSize)
        tickIcon.setHeight(constant: reminderTodayItemImageSize)
        
        crossIcon.setRight(offSet: -X_SPACE)
        crossIcon.setCenterY()
        crossIcon.setWidth(constant: reminderTodayItemImageSize)
        crossIcon.setHeight(constant: reminderTodayItemImageSize)
        
        questionIcon.setRight(offSet: -X_SPACE)
        questionIcon.setCenterY()
        questionIcon.setWidth(constant: reminderTodayItemImageSize)
        questionIcon.setHeight(constant: reminderTodayItemImageSize)
        
        reminderItemView.addTopBorder(color: UIColorFromRGB(rgbValueWithAlpha: reminderTodayItemBorderColor), borderWidth: 0.5)
    }
    
    func removePreviousViews(){
        for subViews in drugsStackView.subviews{
            subViews.removeFromSuperview()
        }
    }
    
    @objc private func onTapReminderItemView(sender: UITapGestureRecognizer){
        if let uiView = sender.view{
            tableViewCellDelegate?.presentReminderDetailDialogVC(uiView: uiView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ReminderAllItemView: UIView{
    
    private let reminderAllView = UIView()
    let historyLabel = UILabel()
    let deleteLabel = UILabel()
    private let imageView = UIImageView()
    private let titleView = UIView()
    let titleLabel = UILabel()
    private let statusView = UIView()
    private let statusLabel = UILabel()
    let descriptionLabel = UILabel()
    private let scheduledLabel = UILabel()
    private var deleteLabelConstraint: NSLayoutConstraint? = nil
    private var historyLabelConstraint: NSLayoutConstraint? = nil
    weak var delegate: ReminderAllTableViewCell?
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(reminderAllView)
        self.addSubview(historyLabel)
        self.addSubview(deleteLabel)
        reminderAllView.addSubview(imageView)
        reminderAllView.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(statusView)
        statusView.addSubview(statusLabel)
        reminderAllView.addSubview(descriptionLabel)
        reminderAllView.addSubview(scheduledLabel)
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        reminderAllView.setLeft(offSet: 0)
        reminderAllView.setTop(offSet: 0)
        reminderAllView.setBottom(offSet: 0)
        
        historyLabel.setLeftRelatedToView(offSet: 0, relatedView: reminderAllView, relatedAttribute: .right)
        historyLabel.setTop(offSet: 0)
        historyLabel.setBottom(offSet: 0)
        historyLabelConstraint = historyLabel.setAndReturnWidth(constant: 0)
        
        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: historyLabel, relatedAttribute: .right)
        deleteLabel.setRight(offSet: 0)
        deleteLabel.setTop(offSet: 0)
        deleteLabel.setBottom(offSet: 0)
        deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
        
        imageView.setTop(offSet: CARD_PADDING)
        imageView.setLeft(offSet: ITEM_VERTICAL_MARGIN)
        imageView.setWidth(constant: PRESCRIPTION_ITEM_IMAGE_SIZE)
        imageView.setHeight(constant: PRESCRIPTION_ITEM_IMAGE_SIZE)
        
        titleView.setLeftRelatedToView(offSet: PADDING_5, relatedView: imageView, relatedAttribute: .right)
        titleView.setTop(offSet: CARD_PADDING)
        titleView.setRight(offSet: -CARD_PADDING)
        
        titleLabel.setLeft(offSet: 0)
        titleLabel.setTop(offSet: 0)
        titleLabel.setBottom(offSet: 0)
        titleLabel.setRightRelatedToView(offSet: -PADDING_5, relatedView: statusView, relatedAttribute: .left)
        
        statusView.setTop(offSet: 0)
        statusView.setBottom(offSet: 0)
        statusView.setRight(offSet: 0)

        statusLabel.setLeft(offSet: 0)
        statusLabel.setRight(offSet: 0)
        statusLabel.setTop(offSet: PADDING_5)
        
        descriptionLabel.setLeftRelatedToView(offSet: PADDING_5, relatedView: imageView, relatedAttribute: .right)
        descriptionLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: titleView, relatedAttribute: .bottom)
        descriptionLabel.setRight(offSet: -CARD_PADDING)
        
        scheduledLabel.setLeftRelatedToView(offSet: PADDING_5, relatedView: imageView, relatedAttribute: .right)
        scheduledLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: descriptionLabel, relatedAttribute: .bottom)
        scheduledLabel.setRight(offSet: -CARD_PADDING)
        scheduledLabel.setBottom(offSet: -CARD_PADDING)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        titleLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_DARK)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        
        descriptionLabel.setProperties(textKey: "", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        setSwipeLabelProperties(uiLabel: historyLabel, text: HISTORY_LABEL, bgColor: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR))
        setSwipeLabelProperties(uiLabel: deleteLabel, text: DELETE_LABEL, bgColor: UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR))
        deleteLabel.addCornerRadius(.SMALL)
        deleteLabel.layer.masksToBounds = true
        deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    private func setSwipeLabelProperties(uiLabel: UILabel, text: String, bgColor: UIColor){
        uiLabel.text = text
        uiLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        uiLabel.backgroundColor = bgColor
        uiLabel.textAlignment = .center
        uiLabel.isUserInteractionEnabled = true
    }
    
    func setIconAndScheduleValues(reminderDetails: ReminderDetails){
        if reminderDetails.moduleType == ReminderModuleEnum.medication{
            imageView.image = UIImage(named: "MedicationIcon")
        }
        else if reminderDetails.moduleType == ReminderModuleEnum.supplement{
            imageView.image = UIImage(named: "SupplementIcon")
        }
        else if reminderDetails.moduleType == ReminderModuleEnum.appointment{
            //Code for appointment icon
        }
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: getString(key: "com.charmphr.reminder.all.item.schedule.title"), attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREY)])
        
        if let startDate = reminderDetails.reminder?.startDate{
            let startDateString = startDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            attributedText.append(NSMutableAttributedString(string: startDateString, attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)]))
        }
        if let endDate = reminderDetails.reminder?.endDate{
            
            attributedText.append(NSAttributedString(string: getString(key: "com.charmphr.reminder.all.item.to.title"), attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREY)]))
            
            let endDateString = endDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            attributedText.append(NSMutableAttributedString(string: endDateString, attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)]))
        }
        scheduledLabel.attributedText = attributedText
    }
    
    func setStatusLabel(status: String){
        statusLabel.setProperties(textKey: status, fontsize: FONT_SIZE_MEDIUM, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 2
        statusLabel.layer.masksToBounds = true
        
        if status == ACTIVE{
            statusLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: REMINDER_ACTIVE_TEXT_COLOR)
            statusLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: REMINDER_ACTIVE_BG_COLOR)
        }
        else if status == UPCOMING{
            statusLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            statusLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_BLUE_BACKGROUND_COLOR)
        }
        else if status == COMPLETED{
            statusLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: REMINDER_COMPLETED_TEXT_COLOR)
            statusLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: REMINDER_COMPLETED_BG_COLOR)
        }
        statusLabel.removeConstraint(attribute: .width)
        statusLabel.setWidth(constant: statusLabel.sizeThatFits(CGSize(width: 300, height: 50)).width + PADDING_6)
        statusLabel.removeConstraint(attribute: .height)
        statusLabel.setHeight(constant: statusLabel.sizeThatFits(CGSize(width: 300, height: 50)).height)
    }
    
    func setRowActionForSwipeLeft(duration: TimeInterval, reminderPOJO: ReminderPOJO){
        UIView.animate(withDuration: duration, delay: 0, animations: { [weak self] in
            guard let self else { return }
            
            if reminderPOJO.reminderDetails?.isCompleted == true || reminderPOJO.reminderDetails?.isActive == true{
                historyLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
                deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
            }
            else if reminderPOJO.reminderDetails?.isUpcoming == true{
                deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
            }
            self.layoutIfNeeded()
        })
        updateTableView()
    }
    
    func setRowActionForSwipeRight(duration: TimeInterval){
        UIView.animate(withDuration: duration, delay: 0, animations: { [weak self] in
            guard let self else { return }
            deleteLabelConstraint?.constant = 0
            historyLabelConstraint?.constant = 0
            self.layoutIfNeeded()
        })
        updateTableView()
    }

    func updateTableView(){
        if let tableView = delegate?.delegate?.customTableView{
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
