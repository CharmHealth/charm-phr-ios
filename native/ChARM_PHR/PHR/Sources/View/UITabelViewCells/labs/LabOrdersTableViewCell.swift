//
//  LabOrdersTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 19/04/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation

class LabOrdersTableViewCell: UITableViewCell{
    
    private let labOrdersItemView = LabOrdersItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(labOrdersItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        labOrdersItemView.setHorizontal(offSet: X_SPACE)
        labOrdersItemView.setTop(offSet: PADDING_5)
        labOrdersItemView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: UploadesFiles, indexPath: IndexPath){
        
        labOrdersItemView.dateLabel.text = data.date?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        labOrdersItemView.documentNameLabel.text = data.fileName
        if let memberName = data.member?.formMemberName(), memberName.isNotBlank(){
            labOrdersItemView.sharedByProviderNameLabel.text = memberName
            labOrdersItemView.shareByView.isHidden = false
        }
        else{
            labOrdersItemView.shareByView.isHidden = true
        }
        
        let practice = Patient.selectedPatientInstance?.getPracticeWith(practiceId: data.phrFileMap?.practiceId ?? "")
        labOrdersItemView.facilityListLabel.text = practice?.practiceName
        
        if let phrFileMap = data.phrFileMap{
            labOrdersItemView.setFontWeight(isRead: phrFileMap.readStatus)
        }
    }
    
    var isRead: Bool = false {
        didSet {
            labOrdersItemView.setFontWeight(isRead: isRead)
        }
    }
}
