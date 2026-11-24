//
//  ComposeMemberTableViewCell.swift
//  PHR
//
//  Created by prathi-13964 on 07/07/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ComposeMemberTableViewCell: UITableViewCell {

    private let memberListItemView = MemberListItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = .white
        contentView.addSubview(memberListItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        memberListItemView.setLeft(offSet: 48)
        memberListItemView.setRight(offSet: -SPACING_12)
        memberListItemView.setTop(offSet: 6)
        memberListItemView.setBottom(offSet: -6)
    }
    
    func setTableViewCellData(data: Provider){
        
        let providerName = StringUtil.getNameWithPrefixAndFullName(fullName: data.fullName ?? "", prefix: data.prefix)
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: providerName, attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .medium), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)])
        
        let jobTitle = data.jobTitle ?? ""
        if jobTitle.isNotBlank(){
            attributedText.append(NSMutableAttributedString(string: " \(jobTitle)", attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREY)]))
        }
        memberListItemView.nameLabel.attributedText = attributedText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

fileprivate class MemberListItemView: UIView{
    let nameLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        
        self.addSubview(nameLabel)
        
        nameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
        nameLabel.numberOfLines = 0
        
        nameLabel.setLeft(offSet: 0)
        nameLabel.setRight(offSet: 0)
        nameLabel.setTop(offSet: 6)
        nameLabel.setBottom(offSet: -6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MemberGroupTableViewCell: UITableViewCell{
    private let memberGroupListItemView = MemberGroupListItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = .white
        contentView.addSubview(memberGroupListItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        memberGroupListItemView.setLeft(offSet: 48)
        memberGroupListItemView.setRight(offSet: -SPACING_12)
        memberGroupListItemView.setTop(offSet: 6)
        memberGroupListItemView.setBottom(offSet: -6)
    }
    
    func setTableViewCellData(data: MemberGroup){
        memberGroupListItemView.nameLabel.text = data.groupName
        memberGroupListItemView.descriptionLabel.text = data.description
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class MemberGroupListItemView: UIView{
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        
        self.addSubview(nameLabel)
        self.addSubview(descriptionLabel)
        
        nameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
        nameLabel.numberOfLines = 0
        
        descriptionLabel.setProperties(textKey: "", fontsize: FONT_SIZE_MEDIUM, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        descriptionLabel.numberOfLines = 0
        
        nameLabel.setLeft(offSet: 0)
        nameLabel.setRight(offSet: 0)
        nameLabel.setTop(offSet: 0)
        
        descriptionLabel.setLeft(offSet: 0)
        descriptionLabel.setRight(offSet: 0)
        descriptionLabel.setTopRelatedToView(offSet: PADDING_3, relatedView: nameLabel, relatedAttribute: .bottom)
        descriptionLabel.setBottom(offSet: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
