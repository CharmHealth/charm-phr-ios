//
//  ProcedureItemView.swift
//  phr
//
//  Created by prathi-13964 on 19/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ProceduresItemView: UIView{
    
    let containerView = UIView()
    let verticalStackView = UIStackView()
    let deleteLabel = UILabel()
    let dateLabel = UILabel()
    let procedureNameAndTypeLabel = UILabel()
    let notesLabel = UILabel()
    var deleteLabelConstraint: NSLayoutConstraint? = nil
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews(){
        
        self.addSubview(deleteLabel)
        self.addSubview(containerView)
        containerView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(procedureNameAndTypeLabel)
        verticalStackView.addArrangedSubview(notesLabel)
        
        addProperties()
        addConstraints()
    }
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.spacing = ITEM_VERTICAL_MARGIN
        
        setLabelProperties(uiLabel: dateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold)
        setLabelProperties(uiLabel: procedureNameAndTypeLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        setLabelProperties(uiLabel: notesLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        
        deleteLabel.text = getString(key: "com.charmphr.action.delete")
        deleteLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        deleteLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        deleteLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
        deleteLabel.textAlignment = .center
        deleteLabel.addCornerRadius(.SMALL)
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    private func addConstraints(){
        
        containerView.setLeft(offSet: 0)
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setRight(offSet: -CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        
        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: containerView, relatedAttribute: .right)
        deleteLabel.setRight(offSet: 0)
        deleteLabel.setTop(offSet: 0)
        deleteLabel.setBottom(offSet: 0)
        deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
    }
    
    func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textAlignment = .left
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
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
