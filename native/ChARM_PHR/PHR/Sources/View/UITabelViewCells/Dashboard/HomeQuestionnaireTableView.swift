//
//  HomeQuestionnaireTableView.swift
//  phr
//
//  Created by Raghul D on 03/03/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation

class HomeQuestionnaireTableView: UITableViewCell {
    
    let homeQuestionnaireListView = HomeQuestionnaireListView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        contentView.addSubview(homeQuestionnaireListView)
        addConstraints()
    }
    
    private func addConstraints()
    {
        homeQuestionnaireListView.setLeft(offSet: 0)
        homeQuestionnaireListView.setRight(offSet: 0)
        homeQuestionnaireListView.setTop(offSet: 0)
        homeQuestionnaireListView.setBottom(offSet: 0)
    }
    
    func setValues(physicianTemplate: PhysicianTemplates, type: String)
    {
        homeQuestionnaireListView.setValues(physicianTemplate: physicianTemplate, type: type)
    }
    
}
