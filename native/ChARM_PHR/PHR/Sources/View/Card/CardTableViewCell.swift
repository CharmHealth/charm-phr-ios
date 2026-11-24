//
//  CardTableViewCell.swift
//  phr
//
//  Created by Raghul D on 19/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation
class CardTableViewCell: UITableViewCell {

    let cardView = CardItemView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(cardView)
        addConstraints()
    }
    
    private func addConstraints(){
        cardView.setLeft(offSet: X_SPACE)
        cardView.setRight(offSet: -X_SPACE)
        cardView.setTop(offSet: Y_SPACE/2)
        cardView.setBottom(offSet: -(Y_SPACE/2))
    }
    
    func setValues(card: PaymentGatewayToken , delegate: CardItemViewDelegate) {
        cardView.delegate = delegate
        cardView.setValues(card: card)
    }

}
