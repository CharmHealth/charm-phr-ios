//
//  MessageItemView.swift
//  phr
//
//  Created by prathi-13964 on 22/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class MessageItemView: UIView{
    
    let verticalStackView = UIStackView()
    let deleteLabel = UILabel()
    let subjectDateView = UIView()
    let subjectLabel = UILabel()
    let dateLabel = UILabel()
    let fromOrToAttachmentView = UIView()
    let fromOrToLabel = UILabel()
    let attachmentIcon = UIImageView(image: UIImage(named: "Attachment"))
    var deleteLabelConstraint: NSLayoutConstraint? = nil

    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(verticalStackView)
        self.addSubview(deleteLabel)
        verticalStackView.addArrangedSubview(subjectDateView)
        subjectDateView.addSubview(subjectLabel)
        subjectDateView.addSubview(dateLabel)
        verticalStackView.addArrangedSubview(fromOrToAttachmentView)
        fromOrToAttachmentView.addSubview(fromOrToLabel)
        fromOrToAttachmentView.addSubview(attachmentIcon)
        addProperties()
        addConstraints()
    }

    private func addConstraints(){
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        
        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: verticalStackView, relatedAttribute: .right)
        deleteLabel.setRight(offSet: 0)
        deleteLabel.setTop(offSet: 0)
        deleteLabel.setBottom(offSet: 0)
        deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
        
//        subjectDateView.setLeft(offSet: 0)
//        subjectDateView.setRight(offSet: -CARD_PADDING)
        
        subjectLabel.setLeft(offSet: 0)
        subjectLabel.setTop(offSet: 0)
        subjectLabel.setBottom(offSet: 0)
        subjectLabel.setRightRelatedToView(offSet: -15, relatedView: dateLabel, relatedAttribute: .left)
        
        dateLabel.setRight(offSet: -10)
        dateLabel.setCenterY()
        
//        fromOrToAttachmentView.setLeft(offSet: 0)
//        fromOrToAttachmentView.setRight(offSet: -CARD_PADDING)
        
        fromOrToLabel.setTop(offSet: 0)
        fromOrToLabel.setLeft(offSet: 0)
        fromOrToLabel.setBottom(offSet: 0)
        fromOrToLabel.setRightRelatedToView(offSet: -4, relatedView: attachmentIcon, relatedAttribute: .left)
        
        attachmentIcon.setCenterY()
        attachmentIcon.setRight(offSet: -10)
        attachmentIcon.setWidth(constant: 16)
        attachmentIcon.setHeight(constant: 16)
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = ITEM_VERTICAL_MARGIN
        verticalStackView.alignment = .fill
        
        setLabelProperties(uiLabel: subjectLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK87)
        setLabelProperties(uiLabel: dateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK80)
        dateLabel.textAlignment = .right
        setLabelProperties(uiLabel: fromOrToLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK80)
        
        deleteLabel.text = getString(key: "com.charmphr.action.delete")
        deleteLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        deleteLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        deleteLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
        deleteLabel.textAlignment = .center
        deleteLabel.addCornerRadius(.SMALL)
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight, textColor: UInt){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: textColor)
        uiLabel.numberOfLines = 1
        uiLabel.lineBreakMode = .byTruncatingTail
    }
    func setfontWeight(isRead: Bool){
        if isRead{
            subjectLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .regular)
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
            fromOrToLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        }
        else{
            subjectLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
            fromOrToLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        }
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
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
