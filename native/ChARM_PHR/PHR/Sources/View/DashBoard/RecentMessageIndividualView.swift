//
//  RecentMessageIndividualView.swift
//  phr
//
//  Created by Raghul D on 02/03/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation


class RecentMessageIndividualView : UIView {
    
    let horizontalSpace : CGFloat = 12.0

    let memberImg = ImageViewWithInitailsView()
    let memberNameTV = UILabel()
    let subjectTV = UILabel()
    let dateTV = UILabel()

    var dateLabelWidthContraint: NSLayoutConstraint!
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        
        self.addSubview(memberImg)
        self.addSubview(memberNameTV)
        self.addSubview(subjectTV)
        self.addSubview(dateTV)
        
        addConstraints()
        setProperties()
    }
    
    private func setProperties(){
        dateTV.setProperties(textKey: "", fontsize: 12, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        dateTV.numberOfLines = 1
        memberNameTV.setProperties(textKey: "", fontsize: 14, weight: .bold, fontcolor: TEXT_COLOR_HEAVYDARK)
        subjectTV.setProperties(textKey: "", fontsize: 14, weight: .regular, fontcolor: TEXT_COLOR_HEAVYDARK)
        subjectTV.numberOfLines = 0
        
        memberImg.layer.cornerRadius = 12
        memberImg.clipsToBounds = true
    }
    
    private func addConstraints(){
        
        memberImg.setLeft(offSet: horizontalSpace)
        memberImg.setTop(offSet: CARD_PADDING)
        memberImg.setWidth(constant: 42)
        memberImg.setHeight(constant: 42)
        
        dateTV.setRight(offSet: -horizontalSpace)
        dateTV.setTop(offSet: CARD_PADDING)

        dateLabelWidthContraint = NSLayoutConstraint(item: dateTV
                                                     , attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        self.addConstraint(dateLabelWidthContraint)

        memberNameTV.setTop(offSet: CARD_PADDING)
        memberNameTV.setLeftRelatedToView(offSet: 10, relatedView: memberImg, relatedAttribute: .right)
        memberNameTV.setRightRelatedToView(offSet: -10, relatedView: dateTV, relatedAttribute: .left)

        subjectTV.setLeftRelatedToView(offSet: 10, relatedView: memberImg, relatedAttribute: .right)
        subjectTV.setRight(offSet: -horizontalSpace)
        subjectTV.setTopRelatedToView(offSet: 4, relatedView: memberNameTV, relatedAttribute: .bottom)
        subjectTV.setBottom(offSet: -CARD_PADDING)
        
    }
    
    func setValues(message: Messages){
        
        
        dateTV.text = timeStringAccordingToDate(timeString: message.timeString ?? "", dateString: message.dateString ?? "")
        dateLabelWidthContraint.constant = dateTV.sizeThatFits(CGSize(width: 1000, height: 1000)).width

        memberNameTV.text = message.messageReceipients?.fromName
        if message.subject.isNilOrBlank()
        {
            subjectTV.text = "(No subject)"
        }
        else{
            subjectTV.text = message.subject
        }
        
        setImage(message: message)
    }
    
    func setImage(message: Messages){
        
        if let data = message.senderImg {
            memberImg.setImage(image: data)
        }
        else{
            memberImg.setInitialsAndImage(initials: getIntialsFromSenderName(name:memberNameTV.text ?? ""), image: nil)
        }
    }
}
