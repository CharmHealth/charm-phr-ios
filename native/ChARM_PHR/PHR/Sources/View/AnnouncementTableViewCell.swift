//
//  AnnouncementTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 20/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AnnouncementTableViewCell: UITableViewCell{
    let announcementItemView = AnnouncementItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(announcementItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        announcementItemView.setHorizontal(offSet: X_SPACE)
        announcementItemView.setTop(offSet: PADDING_5)
        announcementItemView.setBottom(offSet: -PADDING_5)
    }
    func setTableViewCell(data: Announcement){
        announcementItemView.dateLabel.text = data.time?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        announcementItemView.announcementLabel.text = data.subject
        let practice = Patient.selectedPatientInstance?.getPracticeWith(practiceId: data.practiceId ?? "")
        if let facilityList = practice?.practiceName{
            if facilityList.isNotBlank(){
                announcementItemView.facilityListLabel.text = facilityList
                announcementItemView.fromLabel.isHidden = false
                announcementItemView.facilityListLabel.isHidden = false
            }
            else{
                announcementItemView.fromLabel.isHidden = true
                announcementItemView.facilityListLabel.isHidden = true
            }
        }
        else{
            announcementItemView.fromLabel.isHidden = true
            announcementItemView.facilityListLabel.isHidden = true
        }
        announcementItemView.setFontWeight(isRead: data.isRead)
    }
}
