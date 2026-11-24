//
//  DocumentsHorizontalCollectionViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 27/11/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class DocumentsHorizontalCollectionViewCell: UICollectionViewCell {
    
    let nameLabel = UILabel()
    private let documentImgView = UIImageView(image: UIImage(named: "Documents"))
    private let horizontalLine = UIView ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        
        contentView.addSubview(documentImgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(horizontalLine)
        
        documentImgView.contentMode = .scaleAspectFit
        
        nameLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        nameLabel.numberOfLines = 2
        
        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        
        documentImgView.setLeft(offSet: 24)
        documentImgView.setTop(offSet: 5)
        documentImgView.setHeight(constant: 30)
        documentImgView.setWidth(constant: 36)
        
        nameLabel.setLeftRelatedToView(offSet: 12, relatedView: documentImgView, relatedAttribute: .right)
        nameLabel.setRight(offSet: -12)
        nameLabel.setCenterY(view: documentImgView)
        nameLabel.setHeight(constant: 50)
        
        horizontalLine.setLeft(offSet: 0)
        horizontalLine.setRight(offSet: 0)
        horizontalLine.setTopRelatedToView(offSet: 16, relatedView: documentImgView, relatedAttribute: .bottom)
        horizontalLine.setBottom(offSet: 0)
        horizontalLine.setHeight(constant: 1)
    }
}
