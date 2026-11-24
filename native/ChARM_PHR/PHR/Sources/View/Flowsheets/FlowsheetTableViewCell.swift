//
//  FlowsheetTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 04/07/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class FlowsheetTableViewCell: UITableViewCell {
    
    let flowsheetItemView = FlowsheetItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(flowsheetItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        flowsheetItemView.setHorizontal(offSet: X_SPACE)
        flowsheetItemView.setTop(offSet: 5)
        flowsheetItemView.setBottom(offSet: -5)
    }
    func setTableViewCell(data: Flowsheets){
        
        flowsheetItemView.flowsheetNameLabel.text = data.name
        flowsheetItemView.flowsheetFillFrequencyValueLabel.text = data.fillFrequency
    }
}
