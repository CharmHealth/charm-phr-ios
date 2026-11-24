//
//  FlowsheetEntriesTabelViewCell.swift
//  phr
//
//  Created by prathi-13964 on 04/07/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class FlowsheetEntriesTableViewCell: UITableViewCell {
    
    let flowsheetEntriesItemView = FlowsheetEntriesItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(flowsheetEntriesItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        flowsheetEntriesItemView.setHorizontal(offSet: X_SPACE)
        flowsheetEntriesItemView.setTop(offSet: PADDING_5)
        flowsheetEntriesItemView.setBottom(offSet: -PADDING_5)
    }
    func setTableViewCell(data: PHRFlowsheets){
        
        flowsheetEntriesItemView.flowsheetEntryDateLabel.text = CharmUtil.getDisplayDateStringWithYearAndTime(date:data.date!)
    }
}
