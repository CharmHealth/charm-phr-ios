//
//  ReminderHistroryItemEditView.swift
//  phr
//
//  Created by prathi-13964 on 01/02/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation

fileprivate let rmeinderHistoryItemSliderBtnHeight: CGFloat = 27
fileprivate let rmeinderHistoryItemSliderBtnWidth: CGFloat = 45
class ReminderHistroryItemEditView: UIView{
    
    let activityIndicator = UIActivityIndicatorView()
    private let scrollView = UIScrollView()
    private let historyEditView = UIView()
    let historyEditStackView = UIStackView()
    private weak var delegate: ReminderHistroryItemEditViewController? = nil
    
    init(delegate: ReminderHistroryItemEditViewController){
        super.init(frame: .zero)
        self.delegate = delegate
        
        self.addSubview(activityIndicator)
        self.addSubview(scrollView)
        scrollView.addSubview(historyEditView)
        historyEditView.addSubview(historyEditStackView)
        
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        historyEditStackView.axis = .vertical
        historyEditStackView.alignment = .fill
        historyEditStackView.spacing = 0
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        scrollView.setLeft(offSet: 0)
        scrollView.setRight(offSet: 0)
        scrollView.setSafeAreaTop(offset: 0)
        scrollView.setSafeAreaBottom(offset: 0)
        
        historyEditView.setLeft(offSet: X_SPACE)
        historyEditView.setRight(offSet: -X_SPACE)
        historyEditView.setTop(offSet: CARD_PADDING)
        historyEditView.setBottom(offSet: -CARD_PADDING)
        
        historyEditStackView.setLeft(offSet: 0)
        historyEditStackView.setRight(offSet: 0)
        historyEditStackView.setTop(offSet: 0)
        historyEditStackView.setBottom(offSet: 0)
    }
    
    func setTimeView(reminderHistoryTranform: ReminderHistoryTranformPOJO){
        
        let uiView = UIView()
        let timeLabel = UILabel()
        let statusLabel = UILabel()
        let uiSwitch = UISwitch()
        
        historyEditStackView.addArrangedSubview(uiView)
        uiView.addSubview(timeLabel)
        uiView.addSubview(statusLabel)
        uiView.addSubview(uiSwitch)
        
        uiView.backgroundColor = .white
        
        timeLabel.setProperties(textKey: reminderHistoryTranform.time?.getStringFromDate(dateFormat: charmDisplayTimeFormat) ?? "", fontsize: FONT_SIZE_LARGE, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        statusLabel.setProperties(textKey: getString(key: "com.charmphr.reminder.reminderHistory.edit.item.taken.title"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLUE)
        
        if let status = reminderHistoryTranform.reminderHistory?.status{
            if status == 0{
                uiSwitch.isOn = false
                statusLabel.isHidden = true
            }
            else if status == 1{
                uiSwitch.isOn = true
                statusLabel.isHidden = false
            }
        }
        else{
            uiSwitch.isOn = false
            statusLabel.isHidden = true
        }
        
        delegate?.setSwitchToHistoryTranformAndLabelMap(historyStatusSwitch: uiSwitch, reminderHistoryTranform: reminderHistoryTranform, uiLabel: statusLabel)
        
        uiView.addBottomBorder(color: UIColorFromRGB(rgbValueWithAlpha: SUPPORT_BORDER_COLOR), borderWidth: 1)
        
        uiView.setLeft(offSet: 0)
        uiView.setWidth(constant: applicationFrame.width - (X_SPACE * 2))
        
        timeLabel.setLeft(offSet: SPACING_12)
        timeLabel.setTop(offSet: CARD_PADDING)
        timeLabel.setBottom(offSet: -CARD_PADDING)
        
        statusLabel.setRightRelatedToView(offSet: -(CARD_PADDING * 2), relatedView: uiSwitch, relatedAttribute: .left)
        statusLabel.setTop(offSet: CARD_PADDING)
        statusLabel.setBottom(offSet: -CARD_PADDING)
        statusLabel.setWidth(constant: statusLabel.sizeThatFits(CGSize(width: 200, height: 50)).width)
        
        uiSwitch.setRight(offSet: -SPACING_12)
        uiSwitch.setTop(offSet: PADDING_5)
        uiSwitch.setBottom(offSet: -CARD_PADDING)
        uiSwitch.setHeight(constant: rmeinderHistoryItemSliderBtnHeight)
        uiSwitch.setWidth(constant: rmeinderHistoryItemSliderBtnWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
