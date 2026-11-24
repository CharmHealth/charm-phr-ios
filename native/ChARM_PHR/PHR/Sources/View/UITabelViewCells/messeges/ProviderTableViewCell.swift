//
//  ProviderTableViewCell.swift
//  PHR
//
//  Created by prathi-13964 on 07/07/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ProviderTableViewCell: UITableViewCell {

    private let providerListItemView = ProviderListItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = .white
        contentView.addSubview(providerListItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        providerListItemView.setHorizontal(offSet: 0)
        providerListItemView.setTop(offSet: PADDING_8)
        providerListItemView.setBottom(offSet: -PADDING_8)
    }
    
    func setTableViewCellData(data: Provider){
        
        let providerName = StringUtil.getNameWithPrefixAndFullName(fullName: data.fullName ?? "", prefix: data.prefix)
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: providerName, attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .medium), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)])
        
        let jobTitle = data.jobTitle ?? ""
        if jobTitle.isNotBlank(){
            attributedText.append(NSMutableAttributedString(string: " \(jobTitle)", attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREY)]))
        }
        providerListItemView.nameLabel.attributedText = attributedText
        providerListItemView.facilityNameLabel.text = data.practiceName.isNilOrBlank() ? "-" : data.practiceName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


private class ProviderListItemView: UIView{
    let nameLabel = UILabel()
    let facilityNameLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        
        self.addSubview(nameLabel)
        self.addSubview(facilityNameLabel)
        
        nameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
        nameLabel.numberOfLines = 0
        
        facilityNameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_MEDIUM, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        facilityNameLabel.numberOfLines = 0
        
        nameLabel.setLeft(offSet: 48)
        nameLabel.setRight(offSet: -CARD_PADDING)
        nameLabel.setTop(offSet: 0)
        
        facilityNameLabel.setLeft(offSet: 48)
        facilityNameLabel.setRight(offSet: -CARD_PADDING)
        facilityNameLabel.setTopRelatedToView(offSet: PADDING_4, relatedView: nameLabel, relatedAttribute: .bottom)
        facilityNameLabel.setBottom(offSet: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
