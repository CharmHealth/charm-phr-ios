//
//  LabResultTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 25/07/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

class LabResultTableViewCell: UITableViewCell{
    
    private let labResultsItemsView = LabResultsItemsView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(labResultsItemsView)
        addConstraints()
    }
    private func addConstraints(){
        
        labResultsItemsView.setHorizontal(offSet: X_SPACE)
        labResultsItemsView.setTop(offSet: PADDING_5)
        labResultsItemsView.setBottom(offSet: -PADDING_5)
    }
    func setTableViewCell(data: MedicalRecordGroup, indexPath: IndexPath){
        
        labResultsItemsView.dateLabel.text = data.date?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        labResultsItemsView.labNameValueLabel.text = data.labName
        
        let recordsList = data.medicalRecordEntryList
        var interpretationList: [String] = []
        var recordNameList: [String] = []
        
        for recordsListObj in recordsList{
            if recordsListObj.isAbnormalResult{
                interpretationList.append(ABNORMAL)
            }
            else{
                interpretationList.append(NORMAL)
            }
            recordNameList.append(recordsListObj.medicalRecords?.medicalRecordName ?? "")
        }
        
        if recordNameList.count <= 2{
            labResultsItemsView.recordslistNameLabel.text = nil
            labResultsItemsView.recordslistNameLabel.text = recordNameList.joined(separator: "\n")
        }
        else{
            labResultsItemsView.recordslistNameLabel.text = nil
            
            let recordList: String = "\(recordNameList[0])\n\(recordNameList[1])"
            let more: String = getString(key: "com.charmphr.Immunization.more.title")
            let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "\(recordList)\n\(more)", attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)])
            
            attributedText.addAttribute(.foregroundColor, value: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), range: NSMakeRange(recordList.count, more.count))
            
            labResultsItemsView.recordslistNameLabel.attributedText = attributedText
        }
                
        if !data.isAddedByPatient{
            if interpretationList.contains(ABNORMAL){
                labResultsItemsView.resultLabel.text = ABNORMAL
                labResultsItemsView.resultLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: abnormalTxtColor)
            }
            else{
                labResultsItemsView.resultLabel.text = NORMAL
                labResultsItemsView.resultLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: normalTxtColor)
            }
        }
        
        labResultsItemsView.resultLabel.removeConstraint(attribute: .width)
        labResultsItemsView.resultLabel.wrapWidth(maxWidth: 300)
        
        labResultsItemsView.dateLabel.removeConstraint(attribute: .width)
        labResultsItemsView.dateLabel.wrapWidth(maxWidth: 200)
        
        if data.isAddedByPatient{
            labResultsItemsView.horizontalLine.isHidden = true
            labResultsItemsView.fromView.isHidden = true
        }
        else{
            let practice = Patient.selectedPatientInstance?.getPracticeWith(practiceId: data.practiceId ?? "")
            labResultsItemsView.practiceLabel.text = practice?.practiceName
            
            labResultsItemsView.horizontalLine.isHidden = false
            labResultsItemsView.fromView.isHidden = false
        }
        
        labResultsItemsView.resultLabel.isHidden = data.isAddedByPatient
        labResultsItemsView.setFontWeight(isRead: data.isRead)
    }
    
    var isRead: Bool = false {
        didSet {
            labResultsItemsView.setFontWeight(isRead: isRead)
        }
    }
}
