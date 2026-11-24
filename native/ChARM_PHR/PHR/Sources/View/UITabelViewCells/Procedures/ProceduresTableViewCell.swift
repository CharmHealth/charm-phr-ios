//
//  ProceduresTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 02/12/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ProceduresTableViewCell: UITableViewCell{
    let proceduresItemView = ProceduresItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(proceduresItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        proceduresItemView.setHorizontal(offSet: X_SPACE)
        proceduresItemView.setTop(offSet: PADDING_5)
        proceduresItemView.setBottom(offSet: -PADDING_5)
    }
    func setTableViewCell(data: ProceduresList){
        
        proceduresItemView.dateLabel.text = data.fromDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        proceduresItemView.procedureNameAndTypeLabel.text = "\(data.procedureType ?? "") - \(data.procedureName ?? "")"
        
        if let notes = data.comments{
            if notes.isNotBlank(){
                proceduresItemView.notesLabel.text = notes
                proceduresItemView.notesLabel.isHidden = false
            }
            else{
                proceduresItemView.notesLabel.isHidden = true
            }
        }
        else{
            proceduresItemView.notesLabel.isHidden = true
        }
    }
}
