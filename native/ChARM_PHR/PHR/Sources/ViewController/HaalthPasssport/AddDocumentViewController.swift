//
//  AddDocumentViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 29/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol AddDocumentVCDelegate: AnyObject{
    func onAddDocumentSuccess(message: String, documentObj: Document)
}

class AddDocumentViewController: AddDataUIViewController, CharmConnectionHandlerDelegate , SelectValueViewControllerDelagate, MDTextFieldDelegate, UITextFieldDelegate
{
    
    let DOCUMENT_TYPE_VIEW_TAG = 1000
    let DOCUMENT_OTHERTYPE_VIEW_TAG = 1001
    let DOCUMENT_NAME_VIEW_TAG = 1002
    
    var selectedFileUrl : URL?
    
    var charmconnectionHandler : CharmConnectionHandler?
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView?
    
    let activityIndicator = UIActivityIndicatorView()
    weak var delegate : AddDocumentVCDelegate?
    
    var numberOfPracticeDataGotForDocumentFolder = 0
    var arrayOfDocumentCategory : Array<DocumentCategory> = []
    
    var selectedFolder : DocumentCategory?
        
    var isHealthPassport = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setLargeTitle(enable: false)
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        
        createSubView()
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        charmconnectionHandler = CharmConnectionHandler(delegate: self)
        if isHealthPassport
        {
            charmconnectionHandler?.fetchCommonDataForDocument(patientId: getSelectedPatientId(), identificationKey: "fetchCommonData")
        }else
        {
            showActivityIndicator()
            numberOfPracticeDataGotForDocumentFolder = 0
            arrayOfDocumentCategory = []
            for practice in Patient.selectedPatientInstance?.practiceList ?? []
            {
                if RbacUtil.checkPrivilege(privilege: .VIEW_FOLDERS){
                    charmconnectionHandler?.fetchDocumentsCategory(patientId: getSelectedPatientId(), practiceId: practice.practiceId ?? "", identificationKey: "fetchFolderList")
                }
                else{
                    
//                    let allDocumentCategory = DocumentCategory()
//                    allDocumentCategory.name = "All"
//                    arrayOfDocumentCategory.append(allDocumentCategory)
//
                    if let documentNameView = self.view.viewWithTag(DOCUMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView
                    {
                        documentNameView.textField.text = getOnlyNameOfTheFileWithotExtenion(fileName: selectedFileUrl?.lastPathComponent ?? "")
                    }
//                    setDocumentType(row: 0)
                    hideActivityIndicator()
                }
            }
        }
//        showActivityIndicator()
        
        self.navigationItem.title = getString(key: "com.charmphr.addDocuments.title")
        
    }
    
    func createSubView()
    {
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
        let containerView = UIView()
        containerView.addShadowAndCornerRadius(.SMALL)
        
        let documentNameView = AddModuleKeyAndValueView()
        documentNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        documentNameView.tag = DOCUMENT_NAME_VIEW_TAG
        documentNameView.keyLabel.text = getString(key: "com.charmphr.addDocuments.name.title")
        documentNameView.textField.delegate = self
       // documentNameView.textField.valueType = .none
        documentNameView.textField.maxLength = 50
        documentNameView.backgroundColor = .clear
        documentNameView.textField.placeholder = getString(key: "com.charmphr.addDocuments.name.placeHolder")
        documentNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        documentNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(documentNameView)
        
        let documentTypeView = AddModuleKeyAndValueView()
        documentTypeView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        documentTypeView.tag = DOCUMENT_TYPE_VIEW_TAG
        documentTypeView.keyLabel.text = getString(key: "com.charmphr.addDocuments.type.title")
        documentTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        documentTypeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        documentTypeView.backgroundColor = .clear
        containerView.addSubview(documentTypeView)
        
        let documentOthersTypeView = AddModuleKeyAndValueView()
        documentOthersTypeView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        documentOthersTypeView.tag = DOCUMENT_OTHERTYPE_VIEW_TAG
        documentOthersTypeView.keyLabel.text = getString(key: "com.charmphr.addDocuments.othertype.title")
        documentOthersTypeView.textField.delegate = self
        documentOthersTypeView.textField.textFieldType = MDTextFieldTypeAlphaNumeric
        documentOthersTypeView.textField.maxLength = 50
        documentOthersTypeView.textField.placeholder = getString(key: "com.charmphr.addProcedures.others.type.placeHolder")
        documentOthersTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        documentOthersTypeView.removeSubViews()
        documentOthersTypeView.backgroundColor = .clear
        containerView.addSubview(documentOthersTypeView)
        
        documentNameView.setSafeAreaTop(offset: 0)
        documentNameView.setLeft(offSet: 0)
        documentNameView.setRight(offSet: 0)
        documentNameView.setBottomRelatedToView(offSet: 0, relatedView: documentTypeView, relatedAttribute: .top)
        
        documentTypeView.setLeft(offSet: 0)
        documentTypeView.setRight(offSet: 0)
        documentTypeView.setBottomRelatedToView(offSet: 0, relatedView: documentOthersTypeView, relatedAttribute: .top)
        
        documentOthersTypeView.setLeft(offSet: 0)
        documentOthersTypeView.setRight(offSet: 0)
        documentOthersTypeView.setBottom(offSet: 0)
        documentOthersTypeView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)
        
        
        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: Y_SPACE)
        containerView.setBottom(offSet: -Y_SPACE)
        containerView.setLeft(offSet: X_SPACE)
        containerView.setRight(offSet: -X_SPACE)
        // Edge pins inside a scroll view only set content bounds; tie the width to the visible area so the
        // form follows fold/unfold and rotation (was the launch-time applicationFrame.width).
        containerView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor, constant: -(2 * X_SPACE)).isActive = true

        // Safe-area edges keep the form clear of the Dynamic Island and the iOS 27.1 landscape side bar.
        containerScrollView.setSafeAreaTop(offset: 0)
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        containerScrollView.setSafeAreaBottom(offset: 0)
        
    }
    
    //MARK: charmconnectionHandler Delagete
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        
        if identificationKey == "fetchFolderList"
        {
            numberOfPracticeDataGotForDocumentFolder += 1
            
            let arrayOfDocumentCategory = ParsingHelper.fillArrayOfDocumentCategory(dict: jsonObject)
            
            for documentCategory in arrayOfDocumentCategory
            {
                if (self.arrayOfDocumentCategory.firstIndex { (selfDocumentCategory) -> Bool in
                    if documentCategory.name == selfDocumentCategory.name
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }) == nil
                {
                    self.arrayOfDocumentCategory.append(documentCategory)
                }
            }
            
            if let documentNameView = self.view.viewWithTag(DOCUMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView
            {
                documentNameView.textField.text = getOnlyNameOfTheFileWithotExtenion(fileName: selectedFileUrl?.lastPathComponent ?? "")
            }
            
            var index = 0
            
            if let selectedFolder = selectedFolder {
                
                if (selectedFolder.categoryId ?? "").isNotBlank() {
                    if let selectedIndex = self.arrayOfDocumentCategory.firstIndex(where: { category in
                        return (category.categoryId ?? "") == (selectedFolder.categoryId ?? "")
                    }){
                        index = self.arrayOfDocumentCategory.index(of: selectedIndex)
                    }
                }
            }
            
            setDocumentType(row: index)
            hideActivityIndicator()
        }
        else if identificationKey == "fetchCommonData"
        {
            numberOfPracticeDataGotForDocumentFolder += 1
            arrayOfDocumentCategory = ParsingHelper.fillArrayOfDocumentCategory(dict: jsonObject)
            
            if let documentNameView = self.view.viewWithTag(DOCUMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView
            {
                documentNameView.textField.text = getOnlyNameOfTheFileWithotExtenion(fileName: selectedFileUrl?.lastPathComponent ?? "")
            }
            setDocumentType(row: 0)
            hideActivityIndicator()
        }else if identificationKey == "uploadDocument"{
            
            self.navigationController?.popViewController(animated: true)
            if let message = jsonObject.getString("message"){
                let document = ParsingHelper.formDocumentObj(json: jsonObject, fileSize: getFileSize())
                delegate?.onAddDocumentSuccess(message: message, documentObj: document)
            }
            
            if let selectedFileUrl = selectedFileUrl {
                FileUtil.removeTempFile(fileUrl: selectedFileUrl)
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }

    //MARK: - action calles
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
        {
            if addAllergiesKeyAndLabelView.tag == DOCUMENT_TYPE_VIEW_TAG
            {
                selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                navigateToSelectValueVC()
            }
            else
            {
                if !addAllergiesKeyAndLabelView.textField.isHidden
                {
                    addAllergiesKeyAndLabelView.textField.becomeFirstResponder()
                }
            }
        }
    }
    
    func getFileSize() -> String {
        do {
            if let fileSize = try selectedFileUrl?.resourceValues(forKeys: [.fileSizeKey]).fileSize{
                let sizeInKB = Double(fileSize) / 1024
                let sizeInMB = sizeInKB / 1024
                
                if sizeInMB < 1 {
                    return (String(format: "%.2f KB", sizeInKB))
                }
                else{
                    return (String(format: "%.2f MB", sizeInMB))
                }
            }
        }
        catch {
            debugPrintLog("Error getting file size: \(error)")
        }
        return ""
    }
    
    
    func setDocumentType(row : Int)
    {
        if let documenTypeView = self.view.viewWithTag(DOCUMENT_TYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            selectedFolder = arrayOfDocumentCategory[row]
            documenTypeView.valueLabel.text = arrayOfDocumentCategory[row].name
        }
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        if selectedAddModuleKeyAndLabelView?.tag == DOCUMENT_TYPE_VIEW_TAG
        {
            setDocumentType(row: selectedRow)
        }
    }
    
    func getOnlyNameOfTheFileWithotExtenion(fileName : String) -> String
    {
        let arrayOfSubstringOfFileName  = fileName.split(separator: ".")
        return fileName.replacingOccurrences(of: ".\(String(arrayOfSubstringOfFileName[arrayOfSubstringOfFileName.count - 1]))", with: "")
    }
    
    override func onBackClick() {
        // Also blocks the swipe-back gesture, which AddDataUIViewController routes through onBackClick.
        guard !activityIndicator.isAnimating else { return }
        dismissKeyboard()
        
        if let selectedFileUrl = selectedFileUrl {
                FileUtil.removeTempFile(fileUrl: selectedFileUrl)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneBtnClicked()
    {
        dismissKeyboard()
            
        let documentTypeView = self.view.viewWithTag(DOCUMENT_TYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        let documentNameView = self.view.viewWithTag(DOCUMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView
        let documentOtherTypeView = self.view.viewWithTag(DOCUMENT_OTHERTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        
            
        let documentName = documentNameView?.textField.text ?? ""
        
        let documentType = documentTypeView?.valueLabel.text ?? ""
        let documentOtherType = documentOtherTypeView?.textField.text ?? ""


        if documentName.isBlank()
        {
            showMandatoryAlert(fieldName: documentNameView?.keyLabel.text ?? "")
            documentNameView?.textField.becomeFirstResponder()
        }
        else if documentType == OTHERS && documentOtherType.isBlank()
        {
            showMandatoryAlert(fieldName: documentOtherTypeView?.keyLabel.text ?? "")
            documentOtherTypeView?.textField.becomeFirstResponder()
        }else
        {
            
            
            if let selectedFileUrl = selectedFileUrl {
                
                do {
                    
                    if charmconnectionHandler == nil
                    {
                        charmconnectionHandler = CharmConnectionHandler(delegate: self)
                    }
                    
                    if isHealthPassport
                    {
                        var categoryName = ""
                        if documentType == OTHERS
                        {
                            categoryName = documentOtherType
                        }else
                        {
                            categoryName = documentType
                        }
                        
                        charmconnectionHandler?.uploadDocument(patientId: getSelectedPatientId(), param: ["category_name":categoryName,documentName:try Data(contentsOf: selectedFileUrl),"health_passport":"true"], identificationKey: "uploadDocument")
                    }else
                    {
                        
                        debugPrintLog("Extension -> \(selectedFileUrl.pathExtension )")

                        var reqParam: [String: Any] = ["\(documentName).\(selectedFileUrl.pathExtension)":try Data(contentsOf: selectedFileUrl)]
                        
                        let categoryId = selectedFolder?.categoryId ?? ""
                        
                        if categoryId.isNotBlank()
                        {
                            reqParam.addProperty("category_id", selectedFolder?.categoryId ?? "")
                        }
                        
                        charmconnectionHandler?.uploadDocument(patientId: getSelectedPatientId(), param: reqParam , identificationKey: "uploadDocument")
                    }
                    showActivityIndicator()
                }
                catch {
                    CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.alertError"))
                }
            }
            
        }

    }
    
    func showMandatoryAlert(fieldName : String)
    {
        CharmUtil.createOkayAlertWith(title: nil, msg: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName)")
    }
    

    //MARK: - navigation
    func navigateToSelectValueVC()
    {
        let vc = SelectValueViewController()
        vc.delegate = self
        if selectedAddModuleKeyAndLabelView != nil
        {
            vc.title = selectedAddModuleKeyAndLabelView?.keyLabel.text ?? ""
            
            if selectedAddModuleKeyAndLabelView?.tag == DOCUMENT_TYPE_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = arrayOfDocumentCategory.map{$0.name ?? ""}
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView?.valueLabel.text ?? "")
            }
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//MARK: - ActivityIndicator
    
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        // Back is a custom-view bar item, so the button itself must be disabled too.
        backButton.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        backButton.isEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
}
