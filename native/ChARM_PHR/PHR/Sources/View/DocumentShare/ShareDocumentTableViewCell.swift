//
//  ShareDocumentTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 02/11/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ShareDocumentTableViewCell: UITableViewCell{
    
    let shareDocumentListView = ShareDocumentListView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = .white
        contentView.addSubview(shareDocumentListView)
        addConstraints()
    }
    private func addConstraints(){
        
        shareDocumentListView.setLeft(offSet: 0)
        shareDocumentListView.setRight(offSet: -PADDING_5)
        shareDocumentListView.setTop(offSet: PADDING_5)
        shareDocumentListView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: Pharmacy){
        shareDocumentListView.initialLabel.text = data.pharmacyName?.formInitials()
        shareDocumentListView.pharmacyNameLabel.text = data.pharmacyName
        shareDocumentListView.mailIdLabel.text = data.contactDetails?.emailId
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)

         if selected {
             contentView.setBackgroundColor(bgColor: APPLICATION_BACKGROUND_COLOR)
         } else {
             contentView.backgroundColor = .white
         }
     }
}

class ShareDocumentListView: UIView{
    
    let circle = UIView()
    let initialLabel = UILabel()
    let pharmacyNameLabel = UILabel()
    let mailIdLabel = UILabel()
    private let CIRCLE_WIDTH: CGFloat = 44
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews(){
        self.addSubview(circle)
        circle.addSubview(initialLabel)
        self.addSubview(pharmacyNameLabel)
        self.addSubview(mailIdLabel)
        addProperties()
        addConstraints()
    }
    
    private func addProperties(){
        
        circle.layer.cornerRadius = CIRCLE_WIDTH / 2
        circle.layer.masksToBounds = true
        circle.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: PHOTO_INITIAL_BG_COLOR)
        
        initialLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        initialLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .bold)
        
        pharmacyNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        pharmacyNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        pharmacyNameLabel.textAlignment = .left
        pharmacyNameLabel.numberOfLines = 0
        pharmacyNameLabel.lineBreakMode = .byTruncatingTail
    
        mailIdLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        mailIdLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        mailIdLabel.textAlignment = .left
        mailIdLabel.numberOfLines = 0
        mailIdLabel.lineBreakMode = .byTruncatingTail
       
    }
    private func addConstraints(){
        
        circle.setLeft(offSet: CARD_PADDING)
        circle.setTop(offSet: PADDING_5)
        circle.setBottom(offSet: -PADDING_5)
        circle.setWidth(constant: CIRCLE_WIDTH)
        circle.setHeight(constant: CIRCLE_WIDTH)
        
        initialLabel.setCenterX()
        initialLabel.setCenterY()
        
        pharmacyNameLabel.setTopRelatedToView(offSet: 0, relatedView: circle, relatedAttribute: .top)
        pharmacyNameLabel.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: circle, relatedAttribute: .right)
        pharmacyNameLabel.setRight(offSet: -CARD_PADDING)
        
        mailIdLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: pharmacyNameLabel, relatedAttribute: .bottom)
        mailIdLabel.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: circle, relatedAttribute: .right)
        mailIdLabel.setRight(offSet: -CARD_PADDING)
        mailIdLabel.setBottom(offSet: -PADDING_5)
    }
}
