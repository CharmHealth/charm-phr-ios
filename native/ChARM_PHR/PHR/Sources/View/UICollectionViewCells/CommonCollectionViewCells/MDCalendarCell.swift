//
//  MDCalendarCell.swift
//  phr
//
//  Created by Raghul D on 30/04/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import JTAppleCalendar

class MDCalendarCell: JTACDayCell {
    
    
    let calendarItem = MDCalendarItem()

    private var highlightWidthConstraint: NSLayoutConstraint?
    private var highlightHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(calendarItem)
        
        
        //debugPrintLog("dateWidth: \(contentView.frame.size.width)")
       // debugPrintLog("dateHeight: \(contentView.frame.size.height)")

        addConstraints()
    }
    
    private func addConstraints(){
        calendarItem.equalsTheContainerView()

        let highlightView = calendarItem.highlightView
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        highlightWidthConstraint = highlightView.widthAnchor.constraint(equalToConstant: 0)
        highlightHeightConstraint = highlightView.heightAnchor.constraint(equalToConstant: 0)
        highlightWidthConstraint?.isActive = true
        highlightHeightConstraint?.isActive = true
    }

    // Cells are resized and reused when the calendar width changes, so the circle is sized on every layout
    // and capped by the height so it never gets clipped on wide screens.
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = min((contentView.bounds.width * 4) / 5, contentView.bounds.height)
        guard size > 0, size != highlightWidthConstraint?.constant else { return }
        highlightWidthConstraint?.constant = size
        highlightHeightConstraint?.constant = size
        calendarItem.highlightView.layer.cornerRadius = size / 2
    }
    
    func setValue(calendarData: MDCalendarData){
        calendarItem.setValue(calendarData: calendarData)
    }
}

class MDCalendarItem: UIView {
    
    let dateLabel = UILabel()
    let dotView = UIView()
    let highlightView = UIView()
    
    init() {
        super.init(frame: .zero)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.addSubview(highlightView)
        self.addSubview(dateLabel)
        self.addSubview(dotView)
        setProperties()
        addConstraints()
    }

    private func setProperties() {
        dateLabel.font = UIFont.systemFont(ofSize: 17, Weight: .regular)

        dotView.layer.cornerRadius = 2.5
        dotView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        
        highlightView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR).cgColor
        highlightView.layer.borderWidth = 1
        
    }
    
    private func addConstraints() {
        dateLabel.setCenterX()
        dateLabel.setCenterY()
        
        dotView.setTopRelatedToView(offSet: 0, relatedView: dateLabel, relatedAttribute: .bottom)
        
        dotView.setCenterX()
        dotView.setViewSize(sz: CGSize(width: 5, height: 5))
        
        setHeight(constant: 41)
        
        highlightView.setCenterX()
        highlightView.setCenterY()
        
        
    }
    
    func setValue(calendarData: MDCalendarData){
        
        if let cellState = calendarData.cellState {
            
            if cellState.dateBelongsTo == .thisMonth {
                
                var isHighlightViewShown = false
                if cellState.date.isSameDate(date: calendarData.calendarDates?.todaysDate ?? Date()){
                    highlightView.layer.borderWidth = 1
                    isHighlightViewShown = true
                }
                else{
                    highlightView.layer.borderWidth = 0
                }
                
                if calendarData.calendarDates?.isDateEnabled(date: cellState.date) == true{
                    
                    
                        
                    if cellState.isSelected {
                        isHighlightViewShown = true
                        highlightView.setBackgroundColor(bgColor: calendarSelectedDateBg)
                    }
                    else{
                        highlightView.backgroundColor = .clear
                    }
                        
                    
                    
            
                    if cellState.isSelected {
                        dateLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
                    }
                    else{
                        dateLabel.textColor = UIColor.black
                    }
                                
                    if calendarData.isAvailable{
                        dotView.isHidden = false
                    }
                    else{
                        dotView.isHidden = true
                    }
                }
                else{
                    dotView.isHidden = true
                    highlightView.isHidden = true
                    dateLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK50)
                }
                
                highlightView.isHidden = !isHighlightViewShown
                dateLabel.text = cellState.text
            }
            else {
                dotView.isHidden = true
                dateLabel.text = ""
                highlightView.isHidden = true
            }
        }
    }
}
