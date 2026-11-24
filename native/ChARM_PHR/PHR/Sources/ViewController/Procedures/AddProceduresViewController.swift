//
//  AddProceduresViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 09/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AddProceduresViewController: AddDataUIViewController , CharmConnectionHandlerDelegate , SelectValueViewControllerDelagate , UITextViewDelegate , MDTextFieldDelegate, UITextFieldDelegate
{
    
    let PROCEDURESNAME_VIEW_TAG = 1000
    let PROCEDURESTYPE_VIEW_TAG = 1001
    let PROCEDURESDATE_VIEW_TAG = 1002
    let PROCEDURESENDDATE_VIEW_TAG = 1003
    let PROCEDURES_OTHERSTYPE_VIEW_TAG = 1004
    let PROCEDURESCOMMENT_TF_TAG = 1005
    
    let datePicker = UIDatePicker()
    let activityIndicator = UIActivityIndicatorView()
    
    var charmconnectionHandler : CharmConnectionHandler?
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView?
    var procedureTypeArr : [String] = []
    
    weak var delegate : AddViewControllerDelegate?
    var editProcedureList : ProceduresList?
    

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
        charmconnectionHandler?.fetchCommonDataForProcedure(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: Patient.selectedPatientInstance?.practiceList[0].practiceId ?? "", identificationKey: "commonDataProcedures")
        showActivityIndicator()
        
        if editProcedureList == nil{
            self.navigationItem.title = getString(key: "com.charmphr.addProcedures.title")
        }
        else{
            self.navigationItem.title = getString(key: "com.charmphr.editProcedures.title")
        }
    }

    @objc override func onBackClick(){
        let procedureNameView = self.view.viewWithTag(PROCEDURESNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        if editProcedureList == nil{
            if !isNilOrEmpty(string: procedureNameView.textField.text?.trim()){
                showDiscardChangesDialog()
                return
            }
        }
        
        let procedureTypeView = self.view.viewWithTag(PROCEDURESTYPE_VIEW_TAG) as! AddModuleKeyAndValueView
        if editProcedureList == nil{
            if procedureTypeView.valueLabel.text!.lowercased() != procedureTypeArr[0].lowercased() && !isNilOrEmpty(string: procedureTypeView.valueLabel.text!){
                showDiscardChangesDialog()
                return
            }
        }
    
        let procedureDateView = self.view.viewWithTag(PROCEDURESDATE_VIEW_TAG) as! AddModuleKeyAndValueView
        if editProcedureList == nil {
            if !isNilOrEmpty(string: procedureDateView.textField.text) && procedureDateView.textField.text! != CharmUtil.getDateStringWith(date: Date(), dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if  editProcedureList?.fromDate != CharmUtil.getDateObjectWith(dateString: procedureDateView.textField.text!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) && !isNilOrEmpty(string: procedureDateView.textField.text!){
                showDiscardChangesDialog()
                return
            }
        }
            
        let procedureEndDateView = self.view.viewWithTag(PROCEDURESENDDATE_VIEW_TAG) as! AddModuleKeyAndValueView
        if editProcedureList == nil{
            if !isNilOrEmpty(string: procedureEndDateView.textField.text) && procedureEndDateView.textField.text! != CharmUtil.getDateStringWith(date: Date(), dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if !isNilOrEmpty(string: procedureEndDateView.textField.text!) && editProcedureList?.toDate != CharmUtil.getDateObjectWith(dateString: procedureEndDateView.textField.text!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
                showDiscardChangesDialog()
                return
            }
        }
        
        let procedureCommentTF = self.view.viewWithTag(PROCEDURESCOMMENT_TF_TAG) as! UITextView
        if editProcedureList == nil{
            if !isNilOrEmpty(string: procedureCommentTF.text.trim()) {
                showDiscardChangesDialog()
                return
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            if editProcedureList?.comments?.trim() != procedureCommentTF.text.trim(){
                showDiscardChangesDialog()
                return
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func createSubView()
    {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
//        containerScrollView.layer.borderWidth = BORDER_WIDTH
//        containerScrollView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
//        containerScrollView.layer.cornerRadius = CORNER_RADIUS_5
        
        
        let containerView = UIView()
        containerView.addShadowAndCornerRadius(.SMALL)
        
        let proceduresNameView = AddModuleKeyAndValueView()
        proceduresNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        proceduresNameView.tag = PROCEDURESNAME_VIEW_TAG
        proceduresNameView.keyLabel.text = getString(key: "com.charmphr.addProcedures.Name.title")
        proceduresNameView.textField.delegate = self
        proceduresNameView.textField.maxLength = 50
        proceduresNameView.setPlaceholderForTextField(text: getString(key: "com.charmphr.addProcedures.Name.placeHolder"))
        proceduresNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(proceduresNameView)
        
        let proceduresTypeView = AddModuleKeyAndValueView()
        proceduresTypeView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        proceduresTypeView.tag = PROCEDURESTYPE_VIEW_TAG
        proceduresTypeView.keyLabel.text = getString(key: "com.charmphr.addProcedures.type.title")
        proceduresTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresTypeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(proceduresTypeView)
        
        let proceduresOthersTypeView = AddModuleKeyAndValueView()
        proceduresOthersTypeView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        proceduresOthersTypeView.tag = PROCEDURES_OTHERSTYPE_VIEW_TAG
        proceduresOthersTypeView.keyLabel.text = getString(key: "com.charmphr.addProcedures.others.type.title")
        proceduresOthersTypeView.textField.delegate = self
        proceduresOthersTypeView.textField.textFieldType = MDTextFieldTypeAlphaNumeric
        proceduresOthersTypeView.textField.maxLength = 50
        proceduresOthersTypeView.setPlaceholderForTextField(text: getString(key: "com.charmphr.addProcedures.others.type.placeHolder"))
        proceduresOthersTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresOthersTypeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        proceduresOthersTypeView.removeSubViews()
        containerView.addSubview(proceduresOthersTypeView)
        
        let proceduresDateView = AddModuleKeyAndValueView(isDateField: true)
        proceduresDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        proceduresDateView.tag = PROCEDURESDATE_VIEW_TAG
        proceduresDateView.keyLabel.text = getString(key: "com.charmphr.addProcedures.Date.title")
        proceduresDateView.textField.inputView = datePicker
        proceduresDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(proceduresDateView)
        
        let proceduresEndDateView = AddModuleKeyAndValueView()
        proceduresEndDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        proceduresEndDateView.tag = PROCEDURESENDDATE_VIEW_TAG
        proceduresEndDateView.keyLabel.text = getString(key: "com.charmphr.addProcedures.Date.title")
        proceduresEndDateView.textField.inputView = datePicker
        proceduresEndDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresEndDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        proceduresEndDateView.removeSubViews()
        containerView.addSubview(proceduresEndDateView)
        
        let proceduresCommentView = AddModuleKeyAndValueWithTextView()
        proceduresCommentView.KeyLabel.text = getString(key: "com.charmphr.addProcedures.Comments.title")
        proceduresCommentView.textView.tag = PROCEDURESCOMMENT_TF_TAG
        proceduresCommentView.textView.maxLength = 255
        proceduresCommentView.textView.delegate = self
        containerView.addSubview(proceduresCommentView)
        
        proceduresNameView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CardSize.SMALL.value)
        proceduresNameView.setSafeAreaTop(offset: 0)
        proceduresNameView.setLeft(offSet: 0)
        proceduresNameView.setRight(offSet: 0)
        proceduresNameView.setBottomRelatedToView(offSet: 0, relatedView: proceduresTypeView, relatedAttribute: .top)
        
        proceduresTypeView.setLeft(offSet: 0)
        proceduresTypeView.setRight(offSet: 0)
        proceduresTypeView.setBottomRelatedToView(offSet: 0, relatedView: proceduresOthersTypeView, relatedAttribute: .top)
        
        proceduresOthersTypeView.setLeft(offSet: 0)
        proceduresOthersTypeView.setRight(offSet: 0)
        proceduresOthersTypeView.setBottomRelatedToView(offSet: 0, relatedView: proceduresDateView, relatedAttribute: .top)
        
        proceduresDateView.setLeft(offSet: 0)
        proceduresDateView.setRight(offSet: 0)
        proceduresDateView.setBottomRelatedToView(offSet: 0, relatedView: proceduresEndDateView, relatedAttribute: .top)
        
        proceduresEndDateView.setLeft(offSet: 0)
        proceduresEndDateView.setRight(offSet: 0)
        proceduresEndDateView.setBottomRelatedToView(offSet: 0, relatedView: proceduresCommentView, relatedAttribute: .top)
        
        proceduresCommentView.setLeft(offSet: 0)
        proceduresCommentView.setRight(offSet: 0)
        proceduresCommentView.setBottom(offSet: 0)
        proceduresCommentView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)
        
        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: Y_SPACE)
        containerView.setBottom(offSet: -Y_SPACE)
        containerView.setLeft(offSet: X_SPACE)
        containerView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
       // containerView.setRight(offSet: -X_SPACE)
        //self.view.addConstraint(NSLayoutConstraint.init(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: -(X_SPACE + X_SPACE)))
        
        containerScrollView.setSafeAreaTop(offset: 0)
        containerScrollView.setLeft(offSet: 0)
        containerScrollView.setRight(offSet: 0)
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[containerScrollView]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["containerScrollView":containerScrollView]))
        containerScrollView.setSafeAreaBottom(offset: 0)
        
    }
    
    //MARK: - action calles
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }

    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        backButton.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        backButton.isEnabled = true
    }
    
    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
        {
            if addAllergiesKeyAndLabelView.tag == PROCEDURESTYPE_VIEW_TAG
            {
                selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                performSegue(withIdentifier: "selectValueVC", sender: self)
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
    
    @objc func datePickerValueChanged(datePicker : UIDatePicker)
    {
        if let procedureDateView = self.view.viewWithTag(PROCEDURESDATE_VIEW_TAG) as? AddModuleKeyAndValueView,
           let procedureEndDateView = self.view.viewWithTag(PROCEDURESENDDATE_VIEW_TAG) as? AddModuleKeyAndValueView{
            if procedureDateView.textField.isFirstResponder
            {
                setProcedureDate(date: datePicker.date)
            }else if procedureEndDateView.textField.isFirstResponder
            {
                setProcedureEndDate(date: datePicker.date)
            }
        }
    }

    func setProcedureDate(date : Date)
    {
        if let procedureDateView = self.view.viewWithTag(PROCEDURESDATE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            
            procedureDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: date)
        }
    }
    
    func setProcedureEndDate(date : Date)
    {
        if let procedureEndDateView = self.view.viewWithTag(PROCEDURESENDDATE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            procedureEndDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: date)
        }
    }
    
    func setProcedureType(row : Int)
    {
        if let procedureTypeView = self.view.viewWithTag(PROCEDURESTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            procedureTypeView.valueLabel.text = procedureTypeArr[row]
            
           // let procedureOthersTypeView = self.view.viewWithTag(PROCEDURES_OTHERSTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
            let procedureStartDateView = self.view.viewWithTag(PROCEDURESDATE_VIEW_TAG) as? AddModuleKeyAndValueView
            let procedureEndDateView = self.view.viewWithTag(PROCEDURESENDDATE_VIEW_TAG) as? AddModuleKeyAndValueView
            
            if procedureTypeArr[row].lowercased().contains("other") || procedureTypeArr[row].lowercased().contains("hospitalization")
            {
//                if procedureTypeArr[row].lowercased().contains("other")
//                {
//                    procedureOthersTypeView?.addSubViews()
//                }else
//                {
//                    procedureOthersTypeView?.removeSubViews()
//                }
                procedureEndDateView?.addSubViews()
                setProcedureEndDate(date: Date())
                procedureStartDateView?.keyLabel.text = getString(key: "com.charmphr.addProcedures.start.Date.title")
                procedureEndDateView?.keyLabel.text = getString(key: "com.charmphr.addProcedures.end.Date.title")
            }
            else
            {
               // procedureOthersTypeView?.removeSubViews()
                procedureEndDateView?.removeSubViews()
                procedureStartDateView?.keyLabel.text = getString(key: "com.charmphr.addProcedures.Date.title")
            }
        }
    }
    
    func showMandatoryAlert(fieldName : String?)
    {
        CharmUtil.createOkayAlertWith(title: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName ?? "")",msg: nil)
    }
    @objc func doneBtnClicked()
    {
        
       
        dismissKeyboard()
        
        if let procedureNameView = self.view.viewWithTag(PROCEDURESNAME_VIEW_TAG) as? AddModuleKeyAndValueView,
           let procedureTypeView = self.view.viewWithTag(PROCEDURESTYPE_VIEW_TAG) as? AddModuleKeyAndValueView,
           let procedureOtherTypeView = self.view.viewWithTag(PROCEDURES_OTHERSTYPE_VIEW_TAG) as? AddModuleKeyAndValueView,
           let procedureDateView = self.view.viewWithTag(PROCEDURESDATE_VIEW_TAG) as? AddModuleKeyAndValueView,
           let procedureEndDateView = self.view.viewWithTag(PROCEDURESENDDATE_VIEW_TAG) as? AddModuleKeyAndValueView,
           let procedureCommentTF = self.view.viewWithTag(PROCEDURESCOMMENT_TF_TAG) as? UITextView{
            
            let procedureName = procedureNameView.textField.text ?? ""
            
            if isNilOrEmpty(string: procedureName)
            {
                showMandatoryAlert(fieldName: procedureNameView.keyLabel.text)
                procedureNameView.textField.becomeFirstResponder()
            }
            else if (!procedureName.hasAnyAlphabets()){
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.procedure.name.invalid"), msg: nil)
                procedureNameView.textField.becomeFirstResponder()
            }
            else if isNilOrEmpty(string: procedureTypeView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: procedureTypeView.keyLabel.text)
            }
            else if isNilOrEmpty(string: procedureDateView.textField.text)
            {
                showMandatoryAlert(fieldName: procedureDateView.keyLabel.text)
                procedureDateView.textField.becomeFirstResponder()
            }
            else if (procedureTypeView.valueLabel.text?.lowercased().contains("other") ?? false && (isNilOrEmpty(string: procedureOtherTypeView.textField.text) || isNilOrEmpty(string: procedureEndDateView.textField.text) )) || (procedureTypeView.valueLabel.text?.lowercased().contains("hospitalization") ?? false && isNilOrEmpty(string: procedureEndDateView.textField.text))
            {
                if isNilOrEmpty(string: procedureEndDateView.textField.text)
                {
                    showMandatoryAlert(fieldName: procedureEndDateView.keyLabel.text)
                    procedureEndDateView.textField.becomeFirstResponder()
                }else
                {
                    if procedureTypeView.valueLabel.text?.lowercased().contains("other") ?? false && isNilOrEmpty(string: procedureOtherTypeView.textField.text)
                    {
                        showMandatoryAlert(fieldName: procedureOtherTypeView.keyLabel.text)
                        procedureOtherTypeView.textField.becomeFirstResponder()
                    }
                }
            }
            else
            {
                let procedureList = ProceduresList()
                
                procedureList.fromDate = CharmUtil.getDateObjectWith(dateString: procedureDateView.textField.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                
                if procedureTypeView.valueLabel.text?.lowercased().contains("other") ?? false || procedureTypeView.valueLabel.text?.lowercased().contains("hospitalization") ?? false
                {
                    procedureList.toDate = CharmUtil.getDateObjectWith(dateString: procedureEndDateView.textField.text ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                    if procedureTypeView.valueLabel.text?.lowercased().contains("other") ?? false
                    {
                        procedureList.procedureType = procedureOtherTypeView.textField.text
                    }else
                    {
                        procedureList.procedureType = procedureTypeView.valueLabel.text
                    }
                }else
                {
                    procedureList.procedureType = procedureTypeView.valueLabel.text
                }
                
                procedureList.procedureName = procedureNameView.textField.text
                procedureList.comments = procedureCommentTF.text
                
                if charmconnectionHandler == nil
                {
                    charmconnectionHandler = CharmConnectionHandler(delegate: self)
                }
                
                if let editProcedureList = editProcedureList
                {
                    procedureList.procedureMapId = editProcedureList.procedureMapId
                    charmconnectionHandler?.addProcedure(json: JsonBuilder.convertProcedureValueToJson(patientId: Patient.selectedPatientInstance?.patientId ?? "", procedureList: procedureList), identificationKey: "addProcedure", httpMedthod: .HTTP_METHOD_PUT)
                }else
                {
                    charmconnectionHandler?.addProcedure(json: JsonBuilder.convertProcedureValueToJson(patientId: Patient.selectedPatientInstance?.patientId ?? "", procedureList: procedureList), identificationKey: "addProcedure", httpMedthod: .HTTP_METHOD_POST)
                }
                showActivityIndicator()
            }
        }
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "commonDataProcedures"
        {
            if let outputString = jsonObject["output_string"] as? Dictionary<String,Any>
            {
                if let procedureType = outputString["PROCEDURE_TYPE"] as? Array<String>{
                    procedureTypeArr = procedureType
                }
            }
            
            if let editProcedureList = editProcedureList{
                if let procedureNameView = self.view.viewWithTag(PROCEDURESNAME_VIEW_TAG) as? AddModuleKeyAndValueView
                {
                    procedureNameView.textField.text = editProcedureList.procedureName
                    procedureNameView.setViewDisabled()
                }
                
                if let procedureTypeView = self.view.viewWithTag(PROCEDURESTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
                {
                    procedureTypeView.setViewDisabled()
                }
                
                if let procedureCommentTf = self.view.viewWithTag(PROCEDURESCOMMENT_TF_TAG) as? UITextView
                {
                    procedureCommentTf.text = editProcedureList.comments
                }
                
                setProcedureType(row: procedureTypeArr.firstIndex(of: editProcedureList.procedureType ?? "") ?? 0)
                setProcedureDate(date: editProcedureList.fromDate ?? Date())
                datePicker.date = editProcedureList.fromDate ?? Date()
                if (editProcedureList.toDate != nil && editProcedureList.procedureType?.lowercased() == getString(key: "com.charmphr.Hospitalization.noData.title"))
                {
                    let procedureEndDateView = self.view.viewWithTag(PROCEDURESENDDATE_VIEW_TAG) as? AddModuleKeyAndValueView
                    procedureEndDateView?.addSubViews()
                    setProcedureEndDate(date: editProcedureList.toDate ?? Date() )
                }
            }else
            {
                setProcedureType(row: 0)
                setProcedureDate(date: Date())
                datePicker.date = Date()
            }
            
            hideActivityIndicator()
        }
        else if identificationKey == "addProcedure"
        {
            if(delegate is ProceduresViewController){
                navigationController?.popViewController(animated: true)
                if let message = jsonObject.getString("message"){
                    delegate?.addViewControllerDataAdded(message: message)
                }
                else{
                    delegate?.addViewControllerDataAdded(message: nil)
                }
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "commonDataProcedures"
        {
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.charmconnectionHandler?.fetchCommonDataForProcedure(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: Patient.selectedPatientInstance?.practiceList[0].practiceId ?? "", identificationKey: "commonDataProcedures")
            }, cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            })
        }else
        {
            if identificationKey == "addProcedure"{
                let nsError  = error as NSError
                if nsError.code == 5009 {
                    CharmUtil.createOkayAlertWith(title: nil, msg: nsError.domain)
                }
                else{
                    CharmUtil.createOkayAlertWith(error: error)
                }
            }
            else{
                
                CharmUtil.createOkayAlertWith(error: error)
            }
        }
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        if selectedAddModuleKeyAndLabelView?.tag == PROCEDURESTYPE_VIEW_TAG
        {
            setProcedureType(row: selectedRow)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectValueVC"
        {
            if let vc = segue.destination as? SelectValueViewController, let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView{
                vc.title = selectedAddModuleKeyAndLabelView.keyLabel.text
                vc.delegate = self
                if selectedAddModuleKeyAndLabelView.tag == PROCEDURESTYPE_VIEW_TAG
                {
                    vc.arrayOfValueToBeShown  = procedureTypeArr
                    vc.selectedValueIndex = procedureTypeArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
            }
        }
    }

}

