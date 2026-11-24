//
//  QuestionnaireTableViewCell.swift
//  phr
//
//  Created by Raghul D on 26/11/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import UIKit

class QuestionnaireTableViewCell: UITableViewCell {

    let questionnaireView = QuestionnaireItemView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(questionnaireView)
        addConstraints()
    }
    
    private func addConstraints(){
        questionnaireView.setLeft(offSet: X_SPACE)
        questionnaireView.setRight(offSet: -X_SPACE)
        questionnaireView.setTop(offSet: Y_SPACE/2)
        questionnaireView.setBottom(offSet: -(Y_SPACE/2))
    }
    
    func setValues(physicianTemplates: PhysicianTemplates , type: String) {
        questionnaireView.setValues(physicianTemplate: physicianTemplates, type: type)
    }

}
