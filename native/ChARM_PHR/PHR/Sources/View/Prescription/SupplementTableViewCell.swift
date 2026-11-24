//
//  SupplementTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 27/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class SupplementTableViewCell: UITableViewCell, SupplementItemDelegate{
    
    private let supplementItemView = SupplementItemView()
    weak var delegate: SupplementItemDelegate?
    private var supplementGroupPOJO: SupplementGroupPOJO? = nil
    var isFromReminderSelect: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(supplementItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        supplementItemView.delegate = self
        supplementItemView.setHorizontal(offSet: X_SPACE)
        supplementItemView.setTop(offSet: PADDING_5)
        supplementItemView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: SupplementGroupPOJO){
        
        
        supplementGroupPOJO = data
        supplementItemView.setValues(data: data, isFromReminderSelect: isFromReminderSelect)
        supplementItemView.collapseBtn.addTarget(self, action: #selector(onClickCollapseBtn(_:)), for: .touchUpInside)
        
        if data.isViewOpened{
            supplementItemView.subStackView.isHidden = false
        }
        else{
            supplementItemView.subStackView.isHidden = true
        }
        supplementItemView.collapseBtn.isSelected = data.isViewOpened
    }
    
    func onTableViewDidSelect(){
        if !supplementItemView.collapseBtn.isHidden{
            onClickCollapseBtn(supplementItemView.collapseBtn)
        }
    }
    
    @objc private func onClickCollapseBtn(_ btn: UIButton){
        btn.isSelected = !btn.isSelected
        
        supplementGroupPOJO?.isViewOpened = btn.isSelected
        beginUpdates()
        if #available(iOS 26.0, *){
            if btn.isSelected{
                supplementItemView.subStackView.isHidden = false
                supplementItemView.subStackView.layer.opacity = 1
            }
            else{
                supplementItemView.subStackView.isHidden = true
                supplementItemView.subStackView.layer.opacity = 0
            }
            self.layoutIfNeeded()
        }
        else{
            UIView.animate(withDuration: 0.3) { [self] in
                if btn.isSelected{
                    supplementItemView.subStackView.isHidden = false
                    supplementItemView.subStackView.layer.opacity = 1
                }
                else{
                    supplementItemView.subStackView.isHidden = true
                    supplementItemView.subStackView.layer.opacity = 0
                }
                self.layoutIfNeeded()
            }
        }
        endUpdates()
    }
    
    func supplementAction(action: PrescriptionAction, supplementPOJO: SupplementPOJO?, viewTag: Int?) {
        delegate?.supplementAction(action: action, supplementPOJO: supplementPOJO, viewTag: viewTag)
    }
    
    func beginUpdates() {
        delegate?.beginUpdates()
    }
    
    func endUpdates() {
        delegate?.endUpdates()
    }
}
