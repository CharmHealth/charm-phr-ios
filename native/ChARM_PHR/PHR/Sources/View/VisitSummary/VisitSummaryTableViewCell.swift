//
//  VisitSummaryTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 20/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class VisitSummaryTableViewCell: UITableViewCell{
    
    let visitSummaryItemView = VisitSummaryItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(visitSummaryItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        visitSummaryItemView.setHorizontal(offSet: X_SPACE)
        visitSummaryItemView.setTop(offSet: PADDING_5)
        visitSummaryItemView.setBottom(offSet: -PADDING_5)
    }
    func setTableViewCell(data: PatientEncounterList){
        
        visitSummaryItemView.dateLabel.text = CharmUtil.getDisplayDateStringWithDay(date: data.date ?? Date())
        visitSummaryItemView.facilityAndProviderLabel.text = getFacilityAndMemberName(visitSummary: data)
        
        if let reason = data.reason{
            if reason.isNotBlank(){
                visitSummaryItemView.reasonValueLabel.text = reason
                visitSummaryItemView.reasonView.isHidden = false
            }
            else{
                visitSummaryItemView.reasonView.isHidden = true
            }
        }
        else{
            visitSummaryItemView.reasonView.isHidden = true
        }
        visitSummaryItemView.setFontWeight(isRead: data.readStatus)
    }
    private func getFacilityAndMemberName(visitSummary: PatientEncounterList?) -> String{
        var facilityAndPhysianName = ""
        
        if let visitSummary = visitSummary {
            if let facilityName = visitSummary.facility?.facilityName{
                if facilityName.isNotBlank()
                {
                    facilityAndPhysianName.append(facilityName)
                }
            }
            
            if let physicianName = visitSummary.member?.formMemberName(){
                if physicianName.isNotBlank()
                {
                    facilityAndPhysianName.append(" - ")
                    facilityAndPhysianName.append(physicianName)
                }
            }
        }
        if facilityAndPhysianName.isBlank(){
            facilityAndPhysianName.append("-")
        }
        return facilityAndPhysianName
    }
}
