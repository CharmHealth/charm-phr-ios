//
//  MessageTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 22/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell{
    
    let messageItemView = MessageItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(messageItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        messageItemView.setHorizontal(offSet: X_SPACE)
        messageItemView.setTop(offSet: 0)
        messageItemView.setBottom(offSet: -PADDING_5)
    }
    
    
    func setTableViewCell(data: Messages, isInbox: Bool){
        
        if data.subject.isNilOrBlank(){
            messageItemView.subjectLabel.text = "(No subject)"
        }
        else{
            messageItemView.subjectLabel.text = data.subject
        }
        
        let isRead: Bool = data.messageReceipients?.status == "1"
        if isInbox{
            messageItemView.fromOrToLabel.text = data.messageReceipients?.fromName
            messageItemView.setfontWeight(isRead: isRead)
        }
        else{
            messageItemView.fromOrToLabel.text = data.messageReceipients?.toName
            messageItemView.setfontWeight(isRead: true)
        }
        if data.hasAttachments{
            messageItemView.attachmentIcon.isHidden = false
        }
        else{
            messageItemView.attachmentIcon.isHidden = true
        }
        messageItemView.dateLabel.text = timeStringAccordingToDate(timeString: data.timeString ?? "", dateString: data.dateString ?? "")
        messageItemView.dateLabel.removeConstraint(attribute: .width)
        messageItemView.dateLabel.setWidth(constant: messageItemView.dateLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
    }
}
