//
//  ActiveMedicationsView.swift
//  phr
//
//  Created by Sankar Saravanan on 13/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ActiveMedicationsView: UIView {
    
    private var colourView = UIView()
    private var medicationLabel = UILabel()
    private var dateLabel = UILabel()
    private var medicationDescripitionLabel = UILabel()
   
    let LEFT_VIEW_BG_COLOR : UInt = 0x18B434FF
    
    init(){
        super.init(frame: .zero)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews(){
        
        self.addSubview(colourView)
        self.addSubview(medicationLabel)
        self.addSubview(dateLabel)
        self.addSubview(medicationDescripitionLabel)
        
        colourView.setLeft(offSet: 8)
        colourView.setTop(offSet: 8)
        colourView.setHeight(constant: 20)
        colourView.setWidth(constant: 2.5)
        
        medicationLabel.setTop(offSet: 6)
        medicationLabel.setLeftRelatedToView(offSet: 8, relatedView: colourView, relatedAttribute: .right)
        medicationLabel.setRightRelatedToView(offSet: -5, relatedView: dateLabel, relatedAttribute: .left)
        
        dateLabel.setTop(offSet: 8)
        dateLabel.setRight(offSet: -8)
        
        medicationDescripitionLabel.setTopRelatedToView(offSet: 2, relatedView: medicationLabel, relatedAttribute: .bottom)
        medicationDescripitionLabel.setLeftRelatedToView(offSet: 8, relatedView: colourView, relatedAttribute: .right)
        medicationDescripitionLabel.setRight(offSet: -8)
        medicationDescripitionLabel.setBottom(offSet: -8)
        
        dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        
        medicationLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        medicationLabel.numberOfLines = 0
        
        medicationDescripitionLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        medicationDescripitionLabel.numberOfLines = 0
        
        colourView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LEFT_VIEW_BG_COLOR)
        colourView.layer.cornerRadius = 2.5/2
    }
    
    func setValues(activeMedicationPOJO: MedicationPOJO){
        medicationLabel.text = activeMedicationPOJO.getMedicationDisplayName()
        if activeMedicationPOJO.patientMedication?.fromDate != nil
        {
            dateLabel.text = CharmUtil.getDisplayDateStringWithYear(date: activeMedicationPOJO.patientMedication?.fromDate ?? Date())
        }else
        {
            dateLabel.text = ""
        }
        medicationDescripitionLabel.text = activeMedicationPOJO.getIntakeName(separator: ", ") ?? "-"
        dateLabel.removeConstraint(attribute: .width)
        dateLabel.wrapWidth(maxWidth: 100)
    }
    
}
