//
//  AddModuleKeyAndValueView.swift
//  phr
//
//  Created by Sankar Saravanan on 24/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

//TODO: we have to define a type insted of isArrowImageNeeded and isTextFieldShouldBeShown boolean
//TODO: there is no width specified for key label and value label.
//tapgesture was added to the whole view and keyboard was present in the respective VCs (based on this type). This logic needs to be changed
class AddModuleKeyAndValueView: UIView, UITextFieldDelegate, MDTextFieldDelegate {

    var textField = MDTextField()
    let keyLabel = UILabel()
    let valueLabel = UILabel()
    var selectedIndex = 0
    
    let arrowImageView = UIImageView(image: #imageLiteral(resourceName: "ArrowRight"))
    
    private var isArrowImageNeeded : Bool = false
    private var isTextFieldShouldBeShown : Bool = true
    
    init(isDateField: Bool = false) {
        super.init(frame: .zero)
        
        if isDateField{
            textField = DateTextField()
        }
        
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(keyLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(valueLabel)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(arrowImageView)
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textField)
            
        setNormal()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNormal()
    {
        keyLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        valueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        valueLabel.textAlignment = .right
        
        textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        textField.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        textField.textAlignment = .right
        textField.delegate = self
    }
    
    func setPlaceholderForTextField(text : String)
    {
        let attributedString = NSAttributedString(string: text,
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: 0x3C3C43C7) , NSAttributedString.Key.font : UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)])
        textField.attributedPlaceholder = attributedString
    }
    
    func setViewDisabled()
    {
        self.isUserInteractionEnabled = false
       // keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DISABLED)
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DISABLED)
        textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DISABLED)
        
        if isArrowImageNeeded {
            arrowImageView.hideView()
            
            if isTextFieldShouldBeShown {
                textField.removeConstraint(attribute: .right)
                textField.setRight(offSet: -10)
            }
            else{
                valueLabel.removeConstraint(attribute: .right)
                valueLabel.setRight(offSet: -10)
            }
        }
    }
    
    func setSubviews(isArrowImageNeeded: Bool, isTextFieldShouldBeShown: Bool)
    {
        
        self.isArrowImageNeeded = isArrowImageNeeded
        self.isTextFieldShouldBeShown = isTextFieldShouldBeShown
        
        keyLabel.setLeft(offSet: 10)
        keyLabel.setTop(offSet: 13)
        keyLabel.setBottom(offSet: -13)

        if isTextFieldShouldBeShown
        {
            valueLabel.isHidden = true
            valueLabel.removeFromSuperview()
            if isArrowImageNeeded
            {
                keyLabel.setRightRelatedToView(offSet:-5, relatedView: textField, relatedAttribute: .left)
                textField.setCenterY()
                textField.setRightRelatedToView(offSet: -10, relatedView: arrowImageView, relatedAttribute: .left)
                arrowImageView.setCenterY()
                arrowImageView.setWidth(constant: ARROW_IMAGE_VIEW_SIZE.width)
                arrowImageView.setHeight(constant: ARROW_IMAGE_VIEW_SIZE.height)
                arrowImageView.setRight(offSet: -10)
                
            }else
            {
                arrowImageView.image = nil
                
                keyLabel.setRightRelatedToView(offSet: -5, relatedView: textField, relatedAttribute: .left)
                textField.setCenterY()
                textField.setRight(offSet: -10)
            }
        }else
        {
            textField.isHidden = true
            textField.removeFromSuperview()
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
                arrowImageView.image = nil
                
                keyLabel.setRightRelatedToView(offSet: 5, relatedView: valueLabel, relatedAttribute: .left)
                valueLabel.setCenterY()
                valueLabel.setRight(offSet: -10)
            }
            
        }
    }
    
    func removeSubViews()
    {
        keyLabel.removeFromSuperview()
        valueLabel.removeFromSuperview()
        arrowImageView.removeFromSuperview()
        textField.removeFromSuperview()
        self.isHidden = true
        
        self.removeConstraints(self.constraints)
    }
    
    func addSubViews()
    {
        self.isHidden = false
        if keyLabel.superview == nil
        {
            self.addSubview(keyLabel)
            self.addSubview(valueLabel)
            self.addSubview(arrowImageView)
            self.addSubview(textField)
        }
        setSubviews(isArrowImageNeeded: isArrowImageNeeded, isTextFieldShouldBeShown: isTextFieldShouldBeShown)
    }
    
    func mdTextFieldDidBeginEditing(_ textField: MDTextField!) {
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        }
    }
    
    func mdTextFieldDidEndEditing(_ textField: MDTextField!) {
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
    }
}

class AddModuleKeyAndValueWithTextView : UIView
{

    let textView = MDTextView()
    let KeyLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        KeyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        KeyLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        self.addSubview(KeyLabel)
        
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        textView.textColor = .black
        textView.addCornerRadius(.SMALL)
        textView.layer.borderWidth = 1
        textView.maxLength = 500
        textView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_VIEW_BORDER_COLOR).cgColor
        self.addSubview(textView)
        
        KeyLabel.setTop(offSet: Y_SPACE)
        KeyLabel.setLeft(offSet: 10)
        KeyLabel.setRight(offSet: -10)
        KeyLabel.setBottomRelatedToView(offSet: -5.5, relatedView: textView, relatedAttribute: .top)
        
        textView.setLeft(offSet: 10)
        textView.setRight(offSet: -10)
        textView.setBottom(offSet: -Y_SPACE)
        textView.setHeight(constant: 50, relatedBy: .greaterThanOrEqual)
        
        //self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
