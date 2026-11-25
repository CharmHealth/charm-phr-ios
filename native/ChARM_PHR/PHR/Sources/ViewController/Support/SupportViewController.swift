//
//  SupportViewController.swift
//  phr
//
//  Created by prathi-13964 on 14/09/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit
import MobileCoreServices
import PDFKit
import WebKit
import PhotosUI

//protocol SupportViewControllerDelegate{
//    func supportSent(toastMessage: String)
//}

class SupportViewController: AddDataUIViewController, CharmConnectionHandlerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UIDocumentPickerDelegate, SelectValueViewControllerDelagate, UITextFieldDelegate , UIPickerViewDelegate, UIPickerViewDataSource, PHPickerViewControllerDelegate , CharmConnectionV2HandlerDelegate, DocumentAttachmentViewDelegate{
    
    var charmConnectionHandler : CharmConnectionHandler?
    lazy var supportView = SupportView(delegate: self)
    let supportModel = SupportModel()
    var commonView = CommonSupportView()
    var previewItem : URL?
    weak var delegate: AddViewControllerDelegate? = nil
    var supportDetails: SupportDetails? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = supportView
        self.title = getString(key: "com.charmphr.support.title")
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.v2Delegate = self
        
        supportView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        supportView.supportSegmentControl.addTarget(self, action: #selector(onSegmentControlChange(_:)), for: .valueChanged)
        supportView.descriptionView.addSubview(commonView)
        
        if (supportView.supportSegmentControl.selectedSegmentIndex == 0){
            setRightBarButton()
            createProblemView()
        }
        
        supportModel.selectedSegmentName = supportView.supportSegmentControl.titleForSegment(at: supportView.supportSegmentControl.selectedSegmentIndex)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isBeingDismissed {
            debugPrintLog("Support Dissmissed called")
        }
    }
    
    func setRightBarButton(){
        
        let attachment = UIBarButtonItem(image: UIImage(systemName: "paperclip"), style: .plain, target: self, action: #selector(attachmentOnClick))
        let send = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(sendBtnOnClick))
        self.navigationItem.rightBarButtonItems = [send, attachment]
    }
    func setSendBarButton(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(sendBtnOnClick))
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
//MARK: - UIPickerView Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return supportModel.severityArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return supportModel.severityArray.getElement(at: row)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        supportModel.severitySelectedIndex = row
        createProblemView()
    }

//MARK: - SegmentControl OnChange
    
    @objc func onSegmentControlChange(_ sender: UISegmentedControl){
        
        storeValues()
        self.navigationItem.rightBarButtonItem = nil
        if sender.selectedSegmentIndex == 0{
            setRightBarButton()
            createProblemView()
        }
        else if sender.selectedSegmentIndex == 1{
            setRightBarButton()
            createSuggestView()
        }
        else if sender.selectedSegmentIndex == 2{
            setRightBarButton()
            createQuestionView()
        }
        else if sender.selectedSegmentIndex == 3{
            setSendBarButton()
            createAppreciateView()
        }
    }
    
    func storeValues(){
         
        supportModel.selectedButtons = []
        var subject: String?
        var description: String?
        for (_,tag) in supportModel.tagList.enumerated(){
            if let textView = self.view.viewWithTag(tag) as? UITextView{
                if textView.textColor != UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT){
                    description = textView.text
                    textView.text = ""
                }
            }
            else if let textField = self.view.viewWithTag(tag) as? UITextField{
                subject = textField.text
                textField.text = ""
            }
            else if let buttonView = self.view.viewWithTag(tag){
                for view in buttonView.subviews{
                    if let button = view as? UIButton
                    {
                        if button.isSelected{
                            supportModel.selectedButtons.append(button)
                        }
                    }
                }
                let textViewTag = supportModel.buttonViewToTextViewMap[buttonView.tag] ?? -1
                if let textView = self.view.viewWithTag(textViewTag) as? UITextView{
                    if textView.textColor != UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT) {
                        description = textView.text
                        textView.text = ""
                    }
                }
            }
        }
        
        if supportModel.selectedSegmentName == REPORT{
            supportModel.subejct_0 = subject
            supportModel.description_0 = description
        }
        else if supportModel.selectedSegmentName == SUGGEST{
            supportModel.subejct_1 = subject
            supportModel.description_1 = description
        }
        else if supportModel.selectedSegmentName == ASK_QUESTION{
            supportModel.subejct_2 = subject
            supportModel.description_2 = description
        }
        else if supportModel.selectedSegmentName == APPRECIATE{
            supportModel.description_3 = description
        }
    }
    
//MARK: - Back OnClick
    
    override func onBackClick() {
        
        self.view.endEditing(true)
        
        supportModel.alertList = []
        var answer: String?
        var appreciateButton: String?
        var answerList: [String] = []
        for (_, tag) in supportModel.tagList.enumerated(){
            if let textField = self.view.viewWithTag(tag) as? UITextField{
                answer = textField.text
                if !answer.isNilOrBlank() && answer != "None"{
                    supportModel.alertList.append("subject")
                }
            }
            else if let textView = self.view.viewWithTag(tag) as? UITextView{
                if textView.textColor != UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT){
                    if !textView.text.isNilOrBlank(){
                        supportModel.alertList.append("describe")
                    }
                }
            }
            else if let buttonView = self.view.viewWithTag(tag){
                for view in buttonView.subviews{
                    if let button = view as? UIButton
                    {
                        if button.isSelected{
                            appreciateButton = button.title(for: .selected)
                            answerList.append(appreciateButton ?? "")
                        }
                    }
                }
                let textViewTag = supportModel.buttonViewToTextViewMap[buttonView.tag] ?? -1
                if let textView = self.view.viewWithTag(textViewTag) as? UITextView{
                    if textView.textColor != UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT) {
                        answer = textView.text
                        if !answerList.isEmpty || !answer.isNilOrBlank(){
                            supportModel.alertList.append("Button and describe")
                        }
                    }
                    else{
                        if !answerList.isEmpty{
                            supportModel.alertList.append("Button and describe")
                        }
                    }
                }
            }
        }
        if supportModel.severitySelectedIndex != 0{
            supportModel.alertList.append("severity")
        }
        
        if !supportModel.attachmentDetailsArray.isEmpty{
            supportModel.alertList.append("Attachment")
        }
        if supportModel.alertList.count == 0{
            removeTempFiles()
            
            if let navController = navigationController{
                navController.popViewController(animated: true)
            }
            else{
                dismiss(animated: true)
            }
        }
        else{
            showDiscardChangesDialog(callback: {
                self.removeTempFiles()
            })
        }
    }
    
//MARK: - Send OnClick
    
    @objc func sendBtnOnClick(){
        
        self.view.endEditing(true)
        
        supportModel.attachmentArr = []
        if let supportDetails = validateData(){
            
            if supportModel.alertList.isEmpty{
                
                if supportModel.attachmentDictArray.count > 0{
                    self.supportDetails = supportDetails
                    if supportModel.attachmentDictArray.count == supportModel.attachmentDetailsArray.count{
                        showActivityIndicator()
                        charmConnectionHandler?.addAttachmentFile(paramList: supportModel.attachmentDictArray, identificationKey: "addAttachments")
//                        for i in 0..<supportModel.attachmentDictArray.count{
//                            showActivityIndicator()
//                            charmConnectionHandler?.getAttachmentFileIds(param: supportModel.attachmentDictArray[i], identificationKey: "addAttachments:file_name-\(supportModel.attachmentDetailsArray[i]["name"] ?? "")")
//                        }
                    }
                }
                else{
                    debugPrintLog("\nCATEGORY: \(supportDetails.category ?? "")\nSUBJECT: \(supportDetails.subject ?? "")\nFILE_IDS: \(supportDetails.fileIds)\nMESSAGE CONTENT: \(supportDetails.messageContent ?? "")")
                    showActivityIndicator()
                    charmConnectionHandler?.addSupportDetails(supportDetails: supportDetails, identificationKey: "AddSupport")
                }
            }
            else {
                var dialogMessage: UIAlertController?
                if supportModel.alertList[0].contains("Button"){
                    dialogMessage = UIAlertController(title: nil, message: getString(key: "com.charmphr.support.alert.selectOrProviderData.title"), preferredStyle: .alert)
                }
                else{
                    
                    if let alertMessage = supportModel.alertList.first?.lowercased(){
                        if alertMessage.capitalizingFirstLetter().contains("Subject"){
                            dialogMessage = UIAlertController(title: nil, message: getString(key: "com.charmphr.support.alert.subject.title"), preferredStyle: .alert)
                        }
                        else{
                            if alertMessage.contains("describe"){
                                for (_, tag) in supportModel.tagList.enumerated(){
                                    if let textView = self.view.viewWithTag(tag) as? UITextView{
                                        textView.becomeFirstResponder()
                                    }
                                }
                            }
                            dialogMessage = UIAlertController(title: nil, message: "Please \(alertMessage)", preferredStyle: .alert)
                        }
                    }
                }
                let okay = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: nil)
                dialogMessage?.addAction(okay)
                self.present(dialogMessage ?? UIAlertController(), animated: true, completion: nil)
            }
        }
    }
    
//MARK: - Validate
    
    func validateData() -> SupportDetails?{
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let systemVersion = UIDevice.current.systemVersion
        
        supportModel.alertList = []
        let supportDetailsObj = SupportDetails()
        var answer: String?
        var appreciateButton: String?
        var answerList: [String] = []
        for (_, tag) in supportModel.tagList.enumerated(){
            if let textField = self.view.viewWithTag(tag) as? UITextField{
                answer = textField.text
                if !(self.view.viewWithTag(tag) is DateTextField){
                    if answer.isNilOrBlank() && !textField.isHidden{
                        let labelTag = supportModel.textFieldToLabelMap[textField.tag] ?? -1
                        if let label = self.view.viewWithTag(labelTag) as? UILabel{
                            if supportView.supportSegmentControl.selectedSegmentIndex == 0{
                                supportModel.alertList.append("Subject")
                            }
                            else{
                                supportModel.alertList.append(label.text ?? "")
                            }
                        }
                        textField.becomeFirstResponder()
                    }
                    else{
                        if ((answer?.hasAnyAlphabets()) == true){
                            let subjectLabelTag = supportModel.textFieldToLabelMap[textField.tag] ?? -1
                            let severityTextFieldTag = supportModel.textFieldToLabelMap[subjectLabelTag] ?? -1
                            if let severityTextField = self.view.viewWithTag(severityTextFieldTag) as? UITextField{
                                if supportModel.severityArray.contains(where: { severityObj in
                                    return severityObj == severityTextField.text
                                }) && supportModel.severitySelectedIndex != 0{
                                    supportDetailsObj.subject = "\(getString(key: "com.charmphr.support.subject.answerHolder.title"))\(answer?.trim() ?? "") [\(severityTextField.text ?? "")]"
                                }
                                else{
                                    supportDetailsObj.subject = "\(getString(key: "com.charmphr.support.subject.answerHolder.title"))\(answer?.trim() ?? "")"
                                }
                            }
                            else{
                                if self.view.viewWithTag(subjectLabelTag) is UILabel{
                                    supportDetailsObj.subject = "\(getString(key: "com.charmphr.support.subject.answerHolder.title"))\(answer?.trim() ?? "")"
                                }
                            }
                        }
                        else{
                            if !answer.isNilOrBlank(){
                                supportModel.alertList.append("\(getString(key: "com.charmphr.support.invalidInput.error.title"))subject")
                            }
                        }
                    }
                }
            }
            else if let textView = self.view.viewWithTag(tag) as? UITextView{
                let labelTag: Int = supportModel.textViewToLabelMap[textView.tag] ?? -1
                if let label = self.view.viewWithTag(labelTag) as? UILabel{
                    if textView.textColor != UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT){
                        answer = textView.text
                        if answer.isNilOrBlank(){
                            supportModel.alertList.append(label.text ?? "")
                        }else{
                            if ((answer?.hasAnyAlphabets()) == true){
                                supportDetailsObj.messageContent = "\(answer?.trim() ?? "") \n\niOS OS version = \(systemVersion) \nApp version = \(appVersion ?? "")"
                            }
                            else{
                                supportModel.alertList.append("\(getString(key: "com.charmphr.support.invalidInput.error.title"))description")
                            }
                        }
                    }
                    else{
                        supportModel.alertList.append(label.text ?? "")
                    }
                }
            }
            else if let buttonView = self.view.viewWithTag(tag){
                for view in buttonView.subviews{
                    if let button = view as? UIButton
                    {
                        if button.isSelected{
                            appreciateButton = button.title(for: .selected)
                            answerList.append(appreciateButton ?? "")
                        }
                    }
                }
                let textViewTag = supportModel.buttonViewToTextViewMap[buttonView.tag] ?? -1
                if let textView = self.view.viewWithTag(textViewTag) as? UITextView{
                    if textView.textColor != UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT) {
                        answer = textView.text
                        if answerList.isEmpty && answer.isNilOrBlank(){
                            supportModel.alertList.append("Button and describe")
                        }
                        else if !answer.isNilOrBlank() && ((answer?.hasAnyAlphabets()) == false){
                            supportModel.alertList.append("\(getString(key: "com.charmphr.support.invalidInput.error.title"))description")
                        }
                    }
                    else{
                        if answerList.isEmpty{
                            supportModel.alertList.append("Button and describe")
                        }
                    }
                }
                supportDetailsObj.subject = "\(getString(key: "com.charmphr.support.subject.answerHolder.title"))Appreciation"
                if answerList.isEmpty{
                    supportDetailsObj.messageContent = "\(answer?.trim() ?? "") \n\n\(getString(key: "com.charmphr.support.messageContent.iosVersion.title"))\(systemVersion) \n\(getString(key: "com.charmphr.support.messageContent.appVersion.title"))\(appVersion ?? "")"
                }
                else{
                    var supportDetailsObject: SupportDetails?
                    if answer.isNilOrBlank(){
                        supportDetailsObject = addMessageContent(answerList: answerList, answer: "")
                    }
                    else{
                        supportDetailsObject = addMessageContent(answerList: answerList, answer: "\(answer?.trim() ?? "")")
                    }
                    supportDetailsObj.messageContent = "\(supportDetailsObject?.messageContent ?? "") \n\n\(getString(key: "com.charmphr.support.messageContent.iosVersion.title"))\(systemVersion) \n\(getString(key: "com.charmphr.support.messageContent.appVersion.title"))\(appVersion ?? "")"
                }
            }
        }

        let selectedIndex = supportView.supportSegmentControl.selectedSegmentIndex
        if selectedIndex == 0 || selectedIndex == 1 || selectedIndex == 2{
            if selectedIndex == 0{
                supportDetailsObj.category = "Report a Problem"
            }
            else if selectedIndex == 1{
                supportDetailsObj.category = "Suggest a Feature"
            }
            else{
                supportDetailsObj.category = "Ask a Question"
            }
//            for attactmentDict in supportModel.attachmentArr
//            {
//                attachmentArray.append(attactmentDict["id"] as? String ?? "")
//            }
//            supportDetailsObj.fileIds = attachmentArray
//            supportModel.attachmentArr = []
        }
        else{
            supportDetailsObj.category = supportView.supportSegmentControl.titleForSegment(at: selectedIndex)
        }
        if supportDetailsObj.subject?.count ?? 0 > 225{
            supportModel.alertList.append(getString(key: "com.charmphr.support.alert.subject.maxlength"))
        }
        if supportDetailsObj.messageContent?.count ?? 0 > 1000{
            supportModel.alertList.append(getString(key: "com.charmphr.support.alert.messageContent.malength"))
        }
        return supportDetailsObj
    }
    
    func addMessageContent(answerList: [String], answer: String) -> SupportDetails{
        
        let supportDetails = SupportDetails()
        if answerList.count == 1{
            let answerString = answerList.joined()
            supportDetails.messageContent = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(answerString). \(answer)"
        }
        else if answerList.count == 2{
            let answerString = answerList.joined(separator: " and ")
            supportDetails.messageContent = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(answerString). \(answer)"
        }
        else if answerList.count >= 3{
            let exceptLast = answerList[0 ..< (answerList.count - 1)]
            let last = answerList[answerList.count - 1]
            
            let newArray: [String] = ["\(exceptLast.joined(separator: ", "))",last]
            let answerString = newArray.joined(separator: " and ")
            
            supportDetails.messageContent = "\(getString(key: "com.charmphr.support.appreciate.charm_mPHR_app_is.title"))\(answerString). \(answer)"
        }
        
        return supportDetails
    }

//MARK: - Create Segment Views
        
    func createProblemView(){
        
        commonView.setProperties(subjectString: getString(key: "com.charmphr.support.subject.title"), descriptionString: getString(key: "com.charmphr.support.problem.description.title"), severityValueText: supportModel.severityArray[supportModel.severitySelectedIndex])
        commonView.setConstraints(isSeverity: true, isSubject: true, isAppreciate: false)
        commonView.isAppreciateView(isAppreciateView: false)
        commonView.subjectField.delegate = self
        supportView.attachmentView.isHidden = false
        if !supportModel.description_0.isNilOrBlank(){
            commonView.descriptionTextView.text = supportModel.description_0
            commonView.descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
        
        commonView.descriptionTextView.resignFirstResponder()
        commonView.subjectField.resignFirstResponder()
        if !supportModel.subejct_0.isNilOrBlank(){
            commonView.subjectField.text = supportModel.subejct_0
        }
        
        let severityPicker = UIPickerView()
        severityPicker.delegate = self
        severityPicker.dataSource = self
        commonView.severityValueTextField.inputView = severityPicker
        
        severityPicker.selectRow(supportModel.severitySelectedIndex, inComponent: 0, animated: true)
        
//        commonView.severityView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportViewClicked(tapGestureRecognizer:))))
            
        commonView.severityValueTextField.tag = supportModel.tagNo
        supportModel.tagList.append(supportModel.tagNo)
        supportModel.tagNo = supportModel.tagNo + 1
                
        commonView.subjectField.tag = supportModel.tagNo
        supportModel.tagList.append(supportModel.tagNo)
        supportModel.tagNo = supportModel.tagNo + 1
                
        commonView.subjectLabel.tag = supportModel.tagNo
        supportModel.tagNo = supportModel.tagNo + 1
        supportModel.textFieldToLabelMap[commonView.subjectField.tag] = commonView.subjectLabel.tag
                
        supportModel.textFieldToLabelMap[commonView.subjectLabel.tag] = commonView.severityValueTextField.tag
        
        commonView.descriptionTextView.tag = supportModel.tagNo
        supportModel.tagList.append(supportModel.tagNo)
        supportModel.tagNo = supportModel.tagNo + 1
        
        commonView.descriptionLabel.tag = supportModel.tagNo
        supportModel.tagNo = supportModel.tagNo + 1
        
        supportModel.textViewToLabelMap[commonView.descriptionTextView.tag] = commonView.descriptionLabel.tag
        
        supportModel.selectedSegmentName = supportView.supportSegmentControl.titleForSegment(at: supportView.supportSegmentControl.selectedSegmentIndex)
    }
    
    func createSuggestView(){
       
        commonView.setProperties(subjectString: getString(key: "com.charmphr.support.subject.title"), descriptionString: getString(key: "com.charmphr.support.suggestion.description.title"))
        commonView.setConstraints(isSeverity: false, isSubject: true, isAppreciate: false)
        
        commonView.isAppreciateView(isAppreciateView: false)
        supportView.attachmentView.isHidden = false
        commonView.subjectField.delegate = self
        
        if !supportModel.description_1.isNilOrBlank(){
            commonView.descriptionTextView.text = supportModel.description_1
            commonView.descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
        else{
            commonView.descriptionTextView.text = textViewPlaceHolder
            commonView.descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        }
        commonView.descriptionTextView.resignFirstResponder()
        commonView.subjectField.resignFirstResponder()
        if !supportModel.subejct_1.isNilOrBlank(){
            commonView.subjectField.text = supportModel.subejct_1
        }
        
        commonView.subjectField.tag = supportModel.tagNo
        supportModel.tagList.append(supportModel.tagNo)
        supportModel.tagNo = supportModel.tagNo + 1
        
        commonView.subjectLabel.tag = supportModel.tagNo
        supportModel.tagNo = supportModel.tagNo + 1
        supportModel.textFieldToLabelMap[commonView.subjectField.tag] = commonView.subjectLabel.tag
        
        commonView.descriptionTextView.tag = supportModel.tagNo
        supportModel.tagList.append(supportModel.tagNo)
        supportModel.tagNo = supportModel.tagNo + 1
        
        commonView.descriptionLabel.tag = supportModel.tagNo
        supportModel.tagNo = supportModel.tagNo + 1
        
        supportModel.textViewToLabelMap[commonView.descriptionTextView.tag] = commonView.descriptionLabel.tag
        
        supportModel.selectedSegmentName = supportView.supportSegmentControl.titleForSegment(at: supportView.supportSegmentControl.selectedSegmentIndex)
    }
    func createQuestionView(){
        
        commonView.setProperties(subjectString: getString(key: "com.charmphr.support.question.subject.title"), descriptionString: getString(key: "com.charmphr.support.question.description.title"))
        commonView.setConstraints(isSeverity: false, isSubject: true, isAppreciate: false)
    
        commonView.isAppreciateView(isAppreciateView: false)
        supportView.attachmentView.isHidden = false
        commonView.subjectField.delegate = self
        
        if !supportModel.description_2.isNilOrBlank(){
            commonView.descriptionTextView.text = supportModel.description_2
            commonView.descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
        else{
            commonView.descriptionTextView.text = textViewPlaceHolder
            commonView.descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        }
        commonView.descriptionTextView.resignFirstResponder()
        commonView.subjectField.resignFirstResponder()
        if !supportModel.subejct_2.isNilOrBlank(){
            commonView.subjectField.text = supportModel.subejct_2
        }
        
        commonView.subjectField.tag = supportModel.tagNo
        supportModel.tagList.append(supportModel.tagNo)
        supportModel.tagNo = supportModel.tagNo + 1
        
        commonView.subjectLabel.tag = supportModel.tagNo
        supportModel.tagNo = supportModel.tagNo + 1
        supportModel.textFieldToLabelMap[commonView.subjectField.tag] = commonView.subjectLabel.tag
        
        commonView.descriptionTextView.tag = supportModel.tagNo
        supportModel.tagList.append(supportModel.tagNo)
        supportModel.tagNo = supportModel.tagNo + 1
        
        commonView.descriptionLabel.tag = supportModel.tagNo
        supportModel.tagNo = supportModel.tagNo + 1
        
        supportModel.textViewToLabelMap[commonView.descriptionTextView.tag] = commonView.descriptionLabel.tag
        
        supportModel.selectedSegmentName = supportView.supportSegmentControl.titleForSegment(at: supportView.supportSegmentControl.selectedSegmentIndex)
    }
    func createAppreciateView(){
        
        commonView.setProperties(subjectString: "", descriptionString: getString(key: "com.charmphr.support.appreciate.description.title"))
        commonView.setConstraints(isSeverity: false, isSubject: false, isAppreciate: true)
        commonView.isAppreciateView(isAppreciateView: true)
        supportView.attachmentView.isHidden = true
        commonView.delegate = self
        
        if !supportModel.description_3.isNilOrBlank(){
            commonView.descriptionTextView.text = supportModel.description_3
            commonView.descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
        else{
            commonView.descriptionTextView.text = textViewPlaceHolder
            commonView.descriptionTextView.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        }
        commonView.descriptionTextView.resignFirstResponder()
        commonView.checkPreviuouslySelectedButtons(buttonList: supportModel.selectedButtons)
        
        commonView.buttonView.tag = supportModel.tagNo
        supportModel.tagList.append(supportModel.tagNo)
        supportModel.tagNo = supportModel.tagNo + 1
        
        commonView.descriptionTextView.tag = supportModel.tagNo
        supportModel.tagNo = supportModel.tagNo + 1
        
        supportModel.buttonViewToTextViewMap[commonView.buttonView.tag] = commonView.descriptionTextView.tag
        
        supportModel.selectedSegmentName = supportView.supportSegmentControl.titleForSegment(at: supportView.supportSegmentControl.selectedSegmentIndex)
    }
    
    @objc func reportViewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
//        let selectValueVC = SelectValueViewController()
//        selectValueVC.title = NSLocalizedString("com.chamrphr.support.problem.severity.title", comment: "")
//
//        selectValueVC.navigationItem.largeTitleDisplayMode = .never
//        selectValueVC.delegate = self
//        selectValueVC.arrayOfValueToBeShown = supportModel.severityArray
//        selectValueVC.selectedValueIndex = supportModel.severitySelectedIndex
//        self.navigationController?.pushViewController(selectValueVC, animated: true)
    }
    
//MARK: - Charm Connection Handler Delegate
        
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
            
        if identificationKey.hasPrefix("addAttachment")
        {
            let name = "\(identificationKey.split(separator: "-").last ?? "file")"
            
            if let attachmentList = jsonObject["attachments"] as? [Dictionary<String,Any>]
            {
                for attchmentObj in attachmentList{
                    if let attachment = attchmentObj["file_id"], let attachmentName = attchmentObj["file_name"]{
                        
                        supportModel.attachmentArr.append(["name":"\(name)","id": attachment,"fileName": attachmentName])
                        let selectedIndex = supportView.supportSegmentControl.selectedSegmentIndex
                        if selectedIndex == 0 || selectedIndex == 1 || selectedIndex == 2{
                            for attactmentDict in supportModel.attachmentArr
                            {
                                supportModel.fileIdArray.append(attactmentDict["id"] as? String ?? "")
                            }
                            if let supportDetails = supportDetails{
                                if supportModel.attachmentDictArray.count == supportModel.fileIdArray.count{
                                    supportDetails.fileIds =  supportModel.fileIdArray
                                    debugPrintLog("\nCATEGORY: \(supportDetails.category ?? "")\nSUBJECT: \(supportDetails.subject ?? "")\nFILE_IDS: \(supportDetails.fileIds)\nMESSAGE CONTENT: \(supportDetails.messageContent ?? "")")
                                    charmConnectionHandler?.addSupportDetails(supportDetails: supportDetails, identificationKey: "AddSupport")
                                }
                            }
                        }
                    }
                }
            }
        }
        else if identificationKey == "AddSupport"{
            hideActivityIndicator()
            
            removeTempFiles()
            if let navController = navigationController {
                navController.popViewController(animated: true)
            }
            else{
                dismiss(animated: true)
            }
            
            let message: String = jsonObject.getString("message") ?? getString(key: "com.charmphr.support.supportSend.thankYouMessage.title")
            delegate?.addViewControllerDataAdded(message: message)
        }
    }
        
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey.hasPrefix("addAttachments"){
            if let fileIds = response as? [String] {
                
                if let supportDetails = supportDetails{
                    supportModel.fileIdArray = fileIds
                    supportDetails.fileIds = fileIds
                    debugPrintLog("\nCATEGORY: \(supportDetails.category ?? "")\nSUBJECT: \(supportDetails.subject ?? "")\nFILE_IDS: \(supportDetails.fileIds)\nMESSAGE CONTENT: \(supportDetails.messageContent ?? "")")
                    charmConnectionHandler?.addSupportDetails(supportDetails: supportDetails, identificationKey: "AddSupport")
                }
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    


//MARK: - selectValueViewControllerDidSelectValue
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        supportModel.severitySelectedIndex = selectedRow
        createProblemView()
    }
    
//MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        let newText = oldText.replacingCharacters(in: r, with: string)
        
        let char = string.cString(using: String.Encoding.utf8)
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        }
        else{
            if supportView.supportSegmentControl.selectedSegmentIndex != 0{
                return newText.count <= 207
            }
            else if supportView.supportSegmentControl.selectedSegmentIndex == 0 && supportModel.severitySelectedIndex == 0{
                return newText.count <= 207
            }
            else{
                return newText.count <= 204 - supportModel.severityArray[supportModel.severitySelectedIndex].count
            }
        }
    }
    
//MARK: - Attachment OnClick
    
    @objc private func attachmentOnClick(_ btn: UIBarButtonItem){
        self.view.endEditing(true)
        
        if supportModel.attachmentDetailsArray.count >= 5{
            CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.support.attachment.limit.errorMessage.title"), seconds: 2)
        }
        else{
            CharmUtil.showPhotoOrDocumentSelectionAlert(barButton: btn) {
                var configuration = PHPickerConfiguration()
                        //0 - unlimited 1 - default
                configuration.selectionLimit = 1
                    //configuration.filter = .images
                let pickerViewController = PHPickerViewController(configuration: configuration)
                pickerViewController.delegate = self
                self.present(pickerViewController, animated: true)
            } documentSelected: {
                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image, .png, .movie] , asCopy: true)
                documentPicker.delegate = self
                self.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
    
//MARK: - Image and Document Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let imageURL = info[.imageURL] as? URL
        {
            var fileSize: Double = 0.0
            if let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)?.fixedOrientation(){
                let imgData = NSData(data: image.jpegData(compressionQuality: 0.8) ?? Data())
                let imageSize: Int = imgData.count
                
                 fileSize = Double(imageSize) / (1024 * 1024)
            }
            let imageName = imageURL.lastPathComponent
            supportModel.fileNameToUrlMap[imageName] = imageURL
            
            do {
                if let data = try? Data(contentsOf: imageURL){
                    
                    if supportModel.attachmentDetailsArray.contains(where: { attachmentDetailName in
                        if let newName = attachmentDetailName["url"] as? URL{
                            return "\(newName)" == "\(imageURL)"
                        }
                        return false
                    }){
                        showDuplicateFilesAlert()
                    }
                    else{
                        if (fileSize <= 20.0){
                            var fileSizeString: String = ""
                            if fileSize < 1.0{
                                let fileSizeCount = 1000 * fileSize
                                fileSizeString = "\(Double(round(100 * fileSizeCount) / 100)) KB"
                            }
                            else{
                                fileSizeString = "\(Double(round(100 * fileSize) / 100)) MB"
                            }
                            
                            supportModel.attachmentDictArray.append(["\(imageName)" : data])
                            supportModel.attachmentDetailsArray.append(["name": imageName, "fileSize": fileSizeString, "url": imageURL])
                            loadDocumentListView()
                        }
                        else{
                            showMaximumFileSizeAlert()
                        }
                    }
                }
                
            }
        }
        picker.dismiss(animated: true) {
            self.loadDocumentListView()
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL)
    {
        onURLPicked(tempUrl: url)
        controller.dismiss(animated: true) {
            self.loadDocumentListView()
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
    {
        for url in urls
        {
            onURLPicked(tempUrl: url)
        }
        controller.dismiss(animated: true) {
            self.loadDocumentListView()
        }
    }
    
    private func onURLPicked(tempUrl: URL ,fileName: String? = nil , toCompress: Bool = false){
        if let url = FileUtil.createTempFile(fileUrl: tempUrl, tempFileName: fileName , toCompress: toCompress) {
            
            if let data = try? Data(contentsOf: url){
                let fileName = url.lastPathComponent
                supportModel.fileNameToUrlMap[fileName] = url
                
                let fileSizeInBytes: Int = data.count
                let fileSize: Double = Double(fileSizeInBytes) / (1024 * 1024)
                
                
                
                debugPrintLog("File Size: \(fileSize)")
                
                if supportModel.attachmentDetailsArray.contains(where: { attachmentDetailUrl in
                    if let newURL = attachmentDetailUrl["url"] as? URL{
                        return newURL.absoluteString == url.absoluteString
                    }
                    return false
                }){
                    showDuplicateFilesAlert()
                }
                else{
                    
                    if fileSize <= 20.0{
                        var fileSizeString: String = ""
                        if fileSize < 1.0{
                            let fileSizeCount = 1000 * fileSize
                            fileSizeString = "\(Double(round(100 * fileSizeCount) / 100)) KB"
                        }
                        else{
                            fileSizeString = "\(Double(round(100 * fileSize) / 100)) MB"
                        }
                        supportModel.attachmentDictArray.append(["\(fileName)" : data])
                        supportModel.attachmentDetailsArray.append(["name": fileName, "fileSize": fileSizeString, "url": url])
                        
                        supportModel.attachmentDetailsArray.forEach({attachment in
                            debugPrintLog("Name -> \(attachment.getString("name") ?? "")")
                            debugPrintLog("URL -> \((attachment["url"] as? URL)?.absoluteString ?? "")")
                        })
                        loadDocumentListView()
                    }
                    else{
                        FileUtil.removeTempFile(fileUrl: url)
                        showMaximumFileSizeAlert()
                    }
                }
            }
        }
        else{
            DispatchQueue.main.async {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.message.attachment.select.error"), msg: nil)
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        if let result = results.firstOrNil() {
            
            let itemProvider = result.itemProvider
            var typeIdenti = UTType.image.identifier
            
            //debugPrintLog("typeInde -> \(itemProvider.iden)")
            debugPrintLog("typeIndeImg -> \(UTType.image.identifier)")
            debugPrintLog("typeIndeMp4 -> \(UTType.video.identifier)")
            debugPrintLog("typeIndeMov -> \(UTType.movie.identifier  )")

            debugPrintLog("typeMp4 -> \(result.itemProvider.hasItemConformingToTypeIdentifier(UTType.video.identifier))")
            debugPrintLog("typeMov -> \(result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier))")

            var  tempFileName = "filename.jpeg"
            if(result.itemProvider.hasItemConformingToTypeIdentifier(UTType.video.identifier) ){
                    typeIdenti = UTType.video.identifier
                    tempFileName = "video_file.mp4"
            }
            else if(result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) ){
                typeIdenti = UTType.movie.identifier
                tempFileName = "video_file.mov"
            }
            
            
            if itemProvider.hasItemConformingToTypeIdentifier(typeIdenti){
                
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdenti , completionHandler: {data, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.onURLPicked(tempUrl: data, fileName: tempFileName , toCompress: true)
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.hideActivityIndicator()
                        }
                    }
                })
            }
            else{
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    func showMaximumFileSizeAlert(){
        CharmUtil.createOkayAlertWith(title: nil, msg:  getString(key: "com.charmphr.support.fileSize.alert.message.title", with: ["20"]))
    }
    
    func showDuplicateFilesAlert(){
        CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.suppport.duplicateFiles.alert.message.title"))
    }

//MARK: - Load Docoument List View

    func loadDocumentListView()
    {
        for view in supportView.attachmentView.subviews
        {
            view.removeFromSuperview()
        }
        
        if supportModel.attachmentDetailsArray.count >= 1
        {
            var hasSpace = false
            var beforeView: UIView?
            
            for (i,attachmentDict) in supportModel.attachmentDetailsArray.enumerated()
            {
                let attachmentView = DocumentAttachmentView(name: attachmentDict["name"] as? String ?? "", fileSize: attachmentDict["fileSize"] as? String ?? "", delegate: self)
                attachmentView.tag = supportModel.ATTACHMENT_VIEW_TAG + i
                
                supportView.attachmentView.addSubview(attachmentView)

                attachmentView.arrangeViews(constant: CARD_PADDING, hasSpace: hasSpace, beforeView: beforeView)
                beforeView = attachmentView
                hasSpace = !hasSpace
                attachmentView.widthAnchor.constraint(equalTo: supportView.attachmentView.widthAnchor, multiplier: 0.5, constant: -CARD_PADDING / 2).isActive = true

                attachmentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewAttachmentClicked(tapGesture:))))
                
                if i == supportModel.attachmentDetailsArray.count - 1
                {
                    attachmentView.setBottom(offSet: -PADDING_5)
                }
            }
        }
    }
    
    @objc func viewAttachmentClicked(tapGesture : UITapGestureRecognizer){
        
        if let view = tapGesture.view as? DocumentAttachmentView{
            viewSelectedAttachment(parentView: view)
        }
    }
    
    func viewSelectedAttachment(parentView: DocumentAttachmentView){
        if supportModel.attachmentDetailsArray.count >= 1
        {
            
            if let attachmentDetail = supportModel.attachmentDetailsArray.getElement(at: (parentView.tag - supportModel.ATTACHMENT_VIEW_TAG)) {
                if let fileURL = attachmentDetail["url"] as? URL{
                    let pdfImageVC = PDFImageViewController(fileName: fileURL.lastPathComponent, data: nil, url: fileURL)
                    self.navigationController?.pushViewController(pdfImageVC, animated: true)
                }
            }
        }
    }
    
//MARK: - DocumentAttachmentView Delegate
    
    func onCloseBtnTapped(_ view: DocumentAttachmentView) {
        let detailObj =  supportModel.attachmentDetailsArray.remove(at: (view.tag - supportModel.ATTACHMENT_VIEW_TAG))
        
        if let url = detailObj["url"] as? URL {
            FileUtil.removeTempFile(fileUrl: url)
        }
        
        supportModel.attachmentDictArray.remove(at: (view.tag - supportModel.ATTACHMENT_VIEW_TAG))
        loadDocumentListView()
    }
    
//MARK: - Other Functions
    
    func showActivityIndicator(){
        self.view.endEditing(true)
        self.view.bringSubviewToFront(supportView.activityIndicator)
        supportView.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator(){
        supportView.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    private func removeTempFiles(){
        self.supportModel.attachmentDetailsArray.forEach({attachmentObj in
            if let url = attachmentObj["url"] as? URL {
                FileUtil.removeTempFile(fileUrl: url)
            }
        })
    }
}
