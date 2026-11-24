//
//  ReminderHistoryTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 31/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let REMINDER_HISTORY_ITEM_BORDER_WIDTH: CGFloat = 0.25
fileprivate let REMINDER_HISTORY_ITEM_IMAGE_SIZE: CGFloat = 16
fileprivate let REMINDER_HISTORY_ITEM_BORDER_COLOR: UInt = 0x4074D999

class ReminderHistoryTableViewCell: UITableViewCell{
    
    private let reminderHistoryItemView = ReminderHistoryItemView()
    weak var delegate: ReminderHistoryViewController? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        contentView.addSubview(reminderHistoryItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        reminderHistoryItemView.setLeft(offSet: SPACE_TO_BORDERS)
        reminderHistoryItemView.setRight(offSet: -SPACE_TO_BORDERS)
        reminderHistoryItemView.setTop(offSet: PADDING_3)
        reminderHistoryItemView.setBottom(offSet: -PADDING_3)
    }
    
    func setTableViewCellData(data: ReminderHistoryGroupPOJO){
        reminderHistoryItemView.dateLabel.text = data.date?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT)
        
        reminderHistoryItemView.reminderHistoryStackView.subviews.forEach { subviews in
            subviews.removeFromSuperview()
        }
        data.reminderHistoryTranformList.forEach({ historyTranform in
            if let delegate = delegate{
                reminderHistoryItemView.setHistoryStatus(reminderHistoryTransfrom: historyTranform, timeObjToWidthMap: delegate.timeObjToWidthMap)
            }
        })
    }
}

class ReminderHistoryItemView: UIView{
    
    let dateLabel = UILabel()
    let reminderHistoryStackView = UIStackView()
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(dateLabel)
        self.addSubview(reminderHistoryStackView)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        dateLabel.setLeft(offSet: CARD_PADDING)
        dateLabel.setCenterY()
        dateLabel.setWidth(constant: reminderPopSubviewHeight)

        reminderHistoryStackView.setLeftRelatedToView(offSet: 0, relatedView: dateLabel, relatedAttribute: .right)
        reminderHistoryStackView.setRight(offSet: -SPACING_12)
        reminderHistoryStackView.setTop(offSet: 0)
        reminderHistoryStackView.setBottom(offSet: 0)
    }
    
    private func addProperties(){
        
        self.backgroundColor = .white
        self.layer.borderWidth = REMINDER_HISTORY_ITEM_BORDER_WIDTH
        self.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: REMINDER_HISTORY_ITEM_BORDER_COLOR).cgColor
        self.addCornerRadius(.SMALL)
        
        reminderHistoryStackView.axis = .horizontal
        reminderHistoryStackView.alignment = .fill
        reminderHistoryStackView.spacing = X_SPACE

        dateLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
    }
    
    func setHistoryStatus(reminderHistoryTransfrom: ReminderHistoryTranformPOJO, timeObjToWidthMap: [Date:CGFloat]){
        
        let timeObjWidth: CGFloat = timeObjToWidthMap[reminderHistoryTransfrom.time ?? Date()] ?? 0
        let imageContainerView = UIView()
        let imageView = UIImageView()
        reminderHistoryStackView.addArrangedSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        
        if reminderHistoryTransfrom.reminderHistoryStatus == ReminderHistoryStatus.isTaken{
            imageView.image = UIImage(named: "Tick_green")
        }
        else if reminderHistoryTransfrom.reminderHistoryStatus == ReminderHistoryStatus.isSkipped{
            imageView.image = UIImage(named: "Cross_red")
        }
        else if reminderHistoryTransfrom.reminderHistoryStatus == ReminderHistoryStatus.isUnMarked{
            imageView.image = UIImage(named: "Question_grey")
        }
        
        imageContainerView.setTop(offSet: 0)
        imageContainerView.setBottom(offSet: 0)
        imageContainerView.setWidth(constant: timeObjWidth)

        imageView.setCenterX()
        imageView.setCenterY()
        imageView.setWidth(constant: REMINDER_HISTORY_ITEM_IMAGE_SIZE)
        imageView.setHeight(constant: REMINDER_HISTORY_ITEM_IMAGE_SIZE)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
