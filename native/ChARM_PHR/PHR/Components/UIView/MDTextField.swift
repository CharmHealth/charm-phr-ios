////
////  MDTextField.swift
////  phr
////
////  Created by Sankar Saravanan on 30/12/19.
////  Copyright © 2019 Dhanuprasanya P. All rights reserved.
////
//
//import Foundation
//
//enum ValueType: String {
//    case none
//    case onlyLetters
//    case onlyNumbers
//    case phoneNumber   // Allowed "+0123456789"
//    case alphaNumeric
//    case fullName       // Allowed space and .
//    case allowSpecialCharacters = "/?<>()"   // custom charaters
//}
//
//
//class MDTextField : UITextField , UITextFieldDelegate {
//
//    // to disable actions
//    var canPreformAction : Bool = true
//    var maxLength : Int = 0
//    var valueType: ValueType = ValueType.none
//
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return canPreformAction
//    }
//
//    func hideCursor()
//    {
//
//        guard let cell = self.superview as? UITableViewCell else {
//            return
//        }
//        cell.isSelected = true
//        self.tintColor = .clear
//    }
//
//    func verifyFields(shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        switch valueType {
//            case .none:
//                break // Do nothing
//
//            case .onlyLetters:
//                var characterSet = CharacterSet.letters
//                characterSet = characterSet.union(CharacterSet.whitespaces)
//                if string.rangeOfCharacter(from: characterSet.inverted) != nil {
//                    return false
//                }
//
//            case .onlyNumbers:
//                let numberSet = CharacterSet.decimalDigits
//                if string.rangeOfCharacter(from: numberSet.inverted) != nil {
//                    return false
//                }
//
//            case .phoneNumber:
//                let phoneNumberSet = CharacterSet(charactersIn: "+0123456789")
//                if string.rangeOfCharacter(from: phoneNumberSet.inverted) != nil {
//                    return false
//                }
//
//            case .alphaNumeric:
//                var alphaNumericSet = CharacterSet.alphanumerics
//                alphaNumericSet = alphaNumericSet.union(CharacterSet.whitespaces)
//                if string.rangeOfCharacter(from: alphaNumericSet.inverted) != nil {
//                    return false
//                }
//
//            case .fullName:
//                var characterSet = CharacterSet.letters
//                debugPrintLog(characterSet)
//                characterSet = characterSet.union(CharacterSet(charactersIn: "."))
//                characterSet = characterSet.union(CharacterSet.whitespaces)
//                if string.rangeOfCharacter(from: characterSet.inverted) != nil {
//                    return false
//                }
//            case .allowSpecialCharacters:
//                var characterSet = CharacterSet.init(charactersIn: "\(valueType.rawValue)")
//                characterSet = characterSet.union(CharacterSet.alphanumerics)
//                if string.rangeOfCharacter(from: characterSet.inverted) != nil {
//                    return false
//                }
//
//        }
//
//        if let text = self.text, let textRange = Range(range, in: text) {
//            let finalText = text.replacingCharacters(in: textRange, with: string)
//            if maxLength > 0 && finalText.count > maxLength {
//                return false
//            }
//        }
//
//        return true
//    }
//
//}
//
//
//extension UIViewController : UITextFieldDelegate
//{
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        // Verify all the conditions
//        if let mdTextField = textField as? MDTextField {
//            return mdTextField.verifyFields(shouldChangeCharactersIn: range, replacementString: string)
//        }
//
//        return true
//    }
//}
