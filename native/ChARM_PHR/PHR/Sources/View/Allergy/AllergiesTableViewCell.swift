//
//  AllergyTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 18/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit
class AllergiesTableViewCell: UITableViewCell{
    
    weak var delegate: AllergiesTableViewCellDelegate?//changing from AllergiesViewController. have to use delegates. should not access properties of vc inside cell.
    let allergiesItemView = AllergiesItemView()
    private var allergiesListPOJO: AllergiesList? = nil
    private var indexPath: IndexPath? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(allergiesItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        allergiesItemView.setHorizontal(offSet: X_SPACE)
        allergiesItemView.setTop(offSet: PADDING_5)
        allergiesItemView.setBottom(offSet: -PADDING_5)
    }
    
    
    func setTableViewCell(data: AllergiesList, indexPath: IndexPath){
        self.indexPath = indexPath
        allergiesListPOJO = data
        
        allergiesItemView.setAllergiesValues(data: data)
        if !data.isViewOpened{
            allergiesItemView.moreButton.addTarget(self, action: #selector(onClickMoreBtn), for: .touchUpInside)
        }
    }
    
    func setRowActionForSwipeLeft(duration: TimeInterval, isAddedByPatient: Bool){
        allergiesItemView.setRowActionForSwipeLeft(duration: duration, isAddedByPatient: isAddedByPatient)
        allergiesItemView.deleteLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickDeleteBtn)))
    }
   
    @objc private func onClickDeleteBtn(){
       
        if let indexPath{
            delegate?.onDeleteBtnClicked(tableViewCell: self, indexPath: indexPath)
        }
    }
    
    @objc private func onClickMoreBtn(){
        //INFO: removed Allergy tablecell view changes and kept only model changes here.
        allergiesListPOJO?.isViewOpened = true
        if let indexPath{
            delegate?.onMoreBtnClicked(indexPath: indexPath)
        }
    }
}

protocol AllergiesTableViewCellDelegate: AnyObject {
    func onDeleteBtnClicked(tableViewCell: AllergiesTableViewCell, indexPath: IndexPath)
    func onMoreBtnClicked(indexPath: IndexPath)
}
