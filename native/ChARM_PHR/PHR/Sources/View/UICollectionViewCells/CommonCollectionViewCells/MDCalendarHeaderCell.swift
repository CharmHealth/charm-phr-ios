//
//  MDCalendarHeaderCell.swift
//  phr
//
//  Created by Raghul D on 30/04/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import JTAppleCalendar

class MDCalendarHeaderCell: JTACMonthReusableView {
    
    
    let calendarItem = MDCalendarHeaderItem()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        self.backgroundColor = UIColor.yellow
        self.addSubview(calendarItem)
        addConstraints()
    }
    
    private func addConstraints(){
        calendarItem.equalsTheContainerView()
    }
    
    func setValue(cellState: CellState){
        calendarItem.setValue(cellState: cellState)
    }
}

class MDCalendarHeaderItem: UIView {
    
    let monthLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.addSubview(monthLabel)
        setProperties()
        addConstraints()
    }
    
    private func setProperties() {
        
        
        monthLabel.font = UIFont.systemFont(ofSize: 17, Weight: .semibold)
    }
    
    private func addConstraints() {
        monthLabel.setLeft(offSet: 15)
        monthLabel.setCenterY()
    }
    
    func setValue(cellState: CellState){
        monthLabel.text = cellState.text
    }
}

