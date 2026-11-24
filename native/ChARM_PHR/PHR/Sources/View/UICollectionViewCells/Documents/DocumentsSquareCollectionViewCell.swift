//
//  DocumentsSquareCollectionViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 27/11/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class DocumentsSquareCollectionViewCell: UICollectionViewCell {
    
    let nameLabel = UILabel()
    private let documentImgView = UIImageView(image: UIImage(named: "Documents"))
    
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

        documentImgView.contentMode = .scaleAspectFit

        nameLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, weight: .regular)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.widthAnchor.constraint(equalToConstant: 80).isActive = true

        documentImgView.setCenterX()
        documentImgView.setTop(offSet: 8)
        documentImgView.setHeight(constant: 36)
        documentImgView.setWidth(constant: 43)

        nameLabel.setLeft(offSet: 0)
        nameLabel.setRight(offSet: 0)
        nameLabel.setTopRelatedToView(offSet: 12, relatedView: documentImgView, relatedAttribute: .bottom)
        nameLabel.setBottom(offSet: -4)

        nameLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
}
