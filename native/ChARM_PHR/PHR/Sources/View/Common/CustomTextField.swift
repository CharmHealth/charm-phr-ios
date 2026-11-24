//
//  CustomTextField.swift
//  PHR
//
//  Created by prathi-13964 on 08/07/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

protocol CustomTextFieldDelegate: AnyObject{
    func selectView()
    func backButtonOnEmptyField()
}

class CustomTextField: UITextField {
    weak var textFieldDelegate: CustomTextFieldDelegate?
    var backCount = 0
    override public func deleteBackward() {
        let isPrevBlank = self.text.isNilOrBlank()
        if isPrevBlank{
            backCount += 1
        }
        super.deleteBackward()
        
        if backCount == 1 && self.text.isNilOrBlank(){
            textFieldDelegate?.selectView()
        }

        if self.text.isNilOrBlank() && isPrevBlank && backCount >= 2{
            textFieldDelegate?.backButtonOnEmptyField()
            backCount = 0
        }
    }
}

class CutCopyPasteDisabledField: UITextField{

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) ||  action == #selector(UIResponderStandardEditActions.cut(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)){
                return false
            }
        else if action.description.contains("_share") || action.description.contains("_translate") || action.description.contains("_define"){
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    
    }
}
