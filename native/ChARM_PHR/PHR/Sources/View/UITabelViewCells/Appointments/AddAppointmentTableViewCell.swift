//
//  AddAppointmentTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 09/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AddAppointmentTableViewCell: UITableViewCell {
    
    let textField = MDTextField()
    let keyLabel = UILabel()
    let valueLabel = UILabel()
    
    let arrowImageView = UIImageView(image: #imageLiteral(resourceName: "ArrowRight"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(keyLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(valueLabel)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(arrowImageView)
        textField.tintColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        self.contentView.addSubview(textField)
        
        setNormal()
    }
    
    func setNormal()
    {
        keyLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        valueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        valueLabel.textAlignment = .right
        
        textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        textField.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        textField.textAlignment = .right
    }
    
    func setPlaceholderForTextField(text : String)
    {
        let attributedString = NSAttributedString(string: text,
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: 0x3C3C43C7) , NSAttributedString.Key.font : UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)])
        textField.attributedPlaceholder = attributedString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews(isArrowImageNeeded: Bool, isTextFieldShouldBeShown: Bool)
    {
        
        keyLabel.setLeft(offSet: 10)
        keyLabel.setTop(offSet: 13)
        keyLabel.setBottom(offSet: -13)
        keyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if isTextFieldShouldBeShown
        {
            valueLabel.isHidden = true
            if isArrowImageNeeded
            {
                keyLabel.setRightRelatedToView(offSet: -5, relatedView: textField, relatedAttribute: .left)
                textField.setCenterY()
                textField.setRightRelatedToView(offSet: -10, relatedView: arrowImageView, relatedAttribute: .left)
                arrowImageView.setCenterY()
                arrowImageView.setWidth(constant: ARROW_IMAGE_VIEW_SIZE.width)
                arrowImageView.setHeight(constant: ARROW_IMAGE_VIEW_SIZE.height)
                arrowImageView.setRight(offSet: -10)
                
            }else
            {
                keyLabel.setRightRelatedToView(offSet: -5, relatedView: textField, relatedAttribute: .left)
                textField.setCenterY()
                textField.setRight(offSet: -10)
                
                arrowImageView.image = nil
            }
        }else
        {
            textField.isHidden = true
            if isArrowImageNeeded
            {
                keyLabel.setRightRelatedToView(offSet: -5, relatedView: valueLabel, relatedAttribute: .left)
                valueLabel.setCenterY()
                valueLabel.setRightRelatedToView(offSet: -10, relatedView: arrowImageView, relatedAttribute: .left)
                arrowImageView.setCenterY()
                arrowImageView.setWidth(constant: ARROW_IMAGE_VIEW_SIZE.width)
                arrowImageView.setHeight(constant: ARROW_IMAGE_VIEW_SIZE.height)
                arrowImageView.setRight(offSet: -10)

            }else
            {
                keyLabel.setRightRelatedToView(offSet: -5, relatedView: valueLabel, relatedAttribute: .left)
                valueLabel.setCenterY()
                valueLabel.setRight(offSet: -10)
                
                arrowImageView.image = nil
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
