//
//  PrescriptionTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 27/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class MedicationTableViewCell: UITableViewCell, MedicationItemDelegate{
    
    private let medicationItemView = MedicationItemView()
    weak var delegate: MedicationItemDelegate?
    private var medicationGroupPOJO: MedicationGroupPOJO? = nil
    var isFromReminderSelect: Bool = false
    
    private var indexPath: IndexPath? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(medicationItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        medicationItemView.delegate = self
        medicationItemView.setHorizontal(offSet: X_SPACE)
        medicationItemView.setTop(offSet: PADDING_5)
        medicationItemView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: MedicationGroupPOJO , indexPath: IndexPath? = nil){
        self.indexPath = indexPath
        medicationGroupPOJO = data
        medicationItemView.setValues(data: data, isFromReminderSelect: isFromReminderSelect)
        medicationItemView.collapseBtn.addTarget(self, action: #selector(onClickCollapseBtn(_:)), for: .touchUpInside)
        
        if data.isViewOpened{
            medicationItemView.subStackView.isHidden = false
        }
        else{
            medicationItemView.subStackView.isHidden = true
        }
        medicationItemView.collapseBtn.isSelected = data.isViewOpened
    }
    
    func onTableViewDidSelect(){
        if !medicationItemView.collapseBtn.isHidden{
            onClickCollapseBtn(medicationItemView.collapseBtn)
        }
    }
    
    @objc private func onClickCollapseBtn(_ btn: UIButton){
        btn.isSelected = !btn.isSelected
        
        medicationGroupPOJO?.isViewOpened = btn.isSelected
        beginUpdates()
        if #available(iOS 26.0, *){
            if btn.isSelected{
                medicationItemView.subStackView.isHidden = false
                medicationItemView.subStackView.layer.opacity = 1
            }
            else{
                medicationItemView.subStackView.isHidden = true
                medicationItemView.subStackView.layer.opacity = 0
            }
            self.layoutIfNeeded()
        }
        else{
            UIView.animate(withDuration: 0.3) { [self] in
                if btn.isSelected{
                    medicationItemView.subStackView.isHidden = false
                    medicationItemView.subStackView.layer.opacity = 1
                }
                else{
                    medicationItemView.subStackView.isHidden = true
                    medicationItemView.subStackView.layer.opacity = 0
                }
                self.layoutIfNeeded()
            }
        }
        endUpdates()
    }
    
    func medicationAction(action: PrescriptionAction, medicationPOJO: MedicationPOJO?, viewTag: Int?) {
        delegate?.medicationAction(action: action, medicationPOJO: medicationPOJO, viewTag: viewTag)
    }
    
    func beginUpdates() {
        delegate?.beginUpdates()
    }
    
    func endUpdates() {
        delegate?.endUpdates()
    }
}

enum PrescriptionAction {
    case REFILL
    case DID_SELECT
    case DELETE
    case SWIPE_LEFT
    case SWIPE_RIGHT
}
