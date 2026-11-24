//
//  RecentMessageTableViewCell.swift
//  phr
//
//  Created by Raghul D on 02/03/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation


class RecentMessageTableViewCell: UITableViewCell {
    
    let recentMessageIndividualView = RecentMessageIndividualView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        contentView.addSubview(recentMessageIndividualView)
        addConstraints()
    }
    
    private func addConstraints()
    {
        recentMessageIndividualView.setLeft(offSet: 0)
        recentMessageIndividualView.setRight(offSet: 0)
        recentMessageIndividualView.setTop(offSet: 0)
        recentMessageIndividualView.setBottom(offSet: 0)
    }
    
    func setValues(message : Messages)
    {
        recentMessageIndividualView.setValues(message: message)
    }
    
    func setImage(message : Messages)
    {
        recentMessageIndividualView.setImage(message: message)
    }
}
