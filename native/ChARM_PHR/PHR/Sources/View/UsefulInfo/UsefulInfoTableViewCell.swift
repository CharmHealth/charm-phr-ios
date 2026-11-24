//
//  UsefulInfoTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 20/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class UsefulInfoTableViewCell: UITableViewCell{
    let usefulInfoItemView = UsefulInfoItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(usefulInfoItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        usefulInfoItemView.setHorizontal(offSet: X_SPACE)
        usefulInfoItemView.setTop(offSet: PADDING_5)
        usefulInfoItemView.setBottom(offSet: -PADDING_5)
    }
    func setTableViewCell(data: UsefulInfo){
        
        usefulInfoItemView.dateLabel.text = data.time?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        usefulInfoItemView.categoryLabel.text = data.category
        
        let practice = Patient.selectedPatientInstance?.getPracticeWith(practiceId: data.practiceId ?? "")
        if let facilityList = practice?.practiceName{
            if facilityList.isNotBlank(){
                usefulInfoItemView.facilityListLabel.text = facilityList
                usefulInfoItemView.fromLabel.isHidden = false
                usefulInfoItemView.facilityListLabel.isHidden = false
            }
            else{
                usefulInfoItemView.fromLabel.isHidden = true
                usefulInfoItemView.facilityListLabel.isHidden = true
            }
        }
        else{
            usefulInfoItemView.fromLabel.isHidden = true
            usefulInfoItemView.facilityListLabel.isHidden = true
        }
    }
}
