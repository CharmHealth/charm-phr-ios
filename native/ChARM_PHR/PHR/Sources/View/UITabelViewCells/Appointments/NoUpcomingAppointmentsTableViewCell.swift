//
//  NoUpcomingAppointmentsTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 11/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class NoUpcomingAppointmentsTableViewCell: UITableViewCell {
    
    let noDataImageview = UIImageView()
    let noDataMsgLabelOne = UILabel()
    let tryAgainBtn = UIButton()
    private let tryAgainBtnHeight: CGFloat = 30
    
    var appDataHandler = AppDataHandler.sharedInstance()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addSubview(noDataImageview)
        self.addSubview(noDataMsgLabelOne)
        self.addSubview(tryAgainBtn)
        
        
        noDataImageview.image = #imageLiteral(resourceName: "NoAppointment")
        tryAgainBtn.setProperties(titleStrKey: "com.charmphr.home.upcoming.Add.appointment", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_WHITE, bgcolor: THEME_COLOR)
        tryAgainBtn.addPillCornerRadiusAndShadow(height: tryAgainBtnHeight)
        
        noDataMsgLabelOne.numberOfLines = 0
        noDataMsgLabelOne.textAlignment = .center
        
        noDataMsgLabelOne.setProperties(textKey: "com.charmphr.noUpcomingAppointments.title", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_DARK)
        
        let tryAgainBtnWidthConstraint = tryAgainBtn.titleLabel?.setAndReturnWidth(constant: 0)

        tryAgainBtn.titleLabel?.textAlignment = .center
        tryAgainBtnWidthConstraint?.constant = (tryAgainBtn.titleLabel?.sizeThatFits(CGSize(width: 200, height: 100)).width ?? 0) + 20
        
        noDataImageview.setHeight(constant: 85)
        noDataImageview.setWidth(constant: 95)
        noDataImageview.setCenterX()
        noDataImageview.setTop(offSet: 24)
        
        noDataMsgLabelOne.setTopRelatedToView(offSet: 6, relatedView: noDataImageview, relatedAttribute: .bottom)
        noDataMsgLabelOne.setLeft(offSet: 20)
        noDataMsgLabelOne.setRight(offSet: -20)
        
        tryAgainBtn.setTopRelatedToView(offSet: 16, relatedView: noDataMsgLabelOne, relatedAttribute: .bottom)
        tryAgainBtn.setCenterX()
        tryAgainBtn.setBottom(offSet: -24)
        tryAgainBtn.setHeight(constant: tryAgainBtnHeight)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
