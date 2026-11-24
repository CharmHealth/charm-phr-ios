//
//  AddVaccineViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 11/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AddVaccineViewController: AddDataUIViewController , CharmConnectionHandlerDelegate, CharmConnectionV2HandlerDelegate , SelectValueViewControllerDelagate , UITextViewDelegate, SelectValueViewControllerValueDelagate, UITextFieldDelegate
{
    let ageCategoryArr = ["Childhood","Adolescent"]
    
    let AGE_CATEGORY_VIEW_TAG = 1000
    let VACINENAME_VIEW_TAG = 1001
    let MANUFRCTURER_VIEW_TAG = 1002
    let DATE_VIEW_TAG = 1003
    let ADMINISTERED_VIEW_TAG = 1004
    let ADMINISTERED_BY_VIEW_TAG = 1005
    let COMMENT_TV_TAG = 1006
    
    let PRACTICEVIEW_TAG = 1014
    
    let activityIndicator = UIActivityIndicatorView()
    
    var charmConnectionHandeler : CharmConnectionHandler?
    
    var vaccineNameDict : MutableOrderedDictionary?
    var providerDict : MutableOrderedDictionary?
    var administeredList : Array<String> = []
    
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView?
    
    let startDatePicker = UIDatePicker()
    
    var isCommonDataFetched = false
    weak var delegate : AddViewControllerDelegate?
    
    var editVaccine : VaccineImmunizationPOJO?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        createSubViews()
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        charmConnectionHandeler = CharmConnectionHandler(delegate: self)
        charmConnectionHandeler?.v2Delegate = self
        
        if editVaccine == nil
        {
            
            if getPHREntryEnabledPractices(moduleId: vaccineModelId).count == 1
            {
                charmConnectionHandeler?.fetchCommonDataForVaccine(patientId: getSelectedPatientId(), practiceId: getPHREntryEnabledPractices(moduleId: vaccineModelId)[0].practiceId ?? "", identificationKey: "commonData")
                showActivityIndicator()
            }
            self.navigationItem.title = getString(key: "com.charmphr.AddVaccine.title")
        }else
        {
            charmConnectionHandeler?.fetchCommonDataForVaccine(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: editVaccine?.practiceId ?? "", identificationKey: "commonData")
            showActivityIndicator()
            self.navigationItem.title = getString(key: "com.charmphr.EditVaccine.title")
        }
    }
    
    @objc override func onBackClick(){

        let practiceNameView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
        if editVaccine == nil{
            if !isNilOrEmpty(string: practiceNameView?.valueLabel.text) && Patient.selectedPatientInstance!.practiceList.count > 1{
                showDiscardChangesDialog()
                return
            }
        }
        let ageCategoryView = self.view.viewWithTag(AGE_CATEGORY_VIEW_TAG)as? AddModuleKeyAndValueView
        if editVaccine == nil{
            if ageCategoryArr[0] != ageCategoryView?.valueLabel.text && !isNilOrEmpty(string: ageCategoryView?.valueLabel.text){
                showDiscardChangesDialog()
                return
            }
        }
        
        let vaccineNameView = self.view.viewWithTag(VACINENAME_VIEW_TAG) as? AddModuleKeyAndValueView
        if editVaccine == nil{
            if !isNilOrEmpty(string: vaccineNameView?.valueLabel.text){
                showDiscardChangesDialog()
                return
            }
        }
        
        let manufracturerView = self.view.viewWithTag(MANUFRCTURER_VIEW_TAG) as? AddModuleKeyAndValueView
        if editVaccine == nil{
            if !isNilOrEmpty(string: manufracturerView?.textField.text?.trim()){
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if !isNilOrEmpty(string: manufracturerView?.textField.text) && editVaccine?.patientImmunizationMap?.patientImmunizationHistory?.manufacturer?.trim() != manufracturerView?.textField.text?.trim(){
                showDiscardChangesDialog()
                return
            }
        }
        
        let dateView = self.view.viewWithTag(DATE_VIEW_TAG) as? AddModuleKeyAndValueView
        if editVaccine == nil {
            if !isNilOrEmpty(string: dateView?.textField.text) && dateView?.textField.text != CharmUtil.getDateStringWith(date: Date(), dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
                showDiscardChangesDialog()
                return
            }
        }
        else{
            

            if !isNilOrEmpty(string: dateView?.textField.text) && editVaccine?.patientImmunizationMap?.patientImmunizationHistory?.vaccinesOn != CharmUtil.getDateObjectWith(dateString: (dateView?.textField.text)!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
                showDiscardChangesDialog()
                return
            }
        }
        
        let administeredView = self.view.viewWithTag(ADMINISTERED_VIEW_TAG) as? AddModuleKeyAndValueView
        if editVaccine == nil{
            if  !isNilOrEmpty(string: administeredView?.valueLabel.text) && administeredView!.valueLabel.text != administeredList[0]{
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if  !isNilOrEmpty(string: administeredView?.valueLabel.text) && editVaccine?.patientImmunizationMap?.patientImmunizationHistory?.howAdministered != administeredView?.valueLabel.text{
                showDiscardChangesDialog()
                return
            }
        }
        
        let administeredByView = self.view.viewWithTag(ADMINISTERED_BY_VIEW_TAG) as? AddModuleKeyAndValueView
        if editVaccine == nil{
            if !isNilOrEmpty(string: administeredByView?.valueLabel.text) {
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if  !isNilOrEmpty(string: administeredByView?.valueLabel.text) && editVaccine?.patientImmunizationMap?.patientImmunizationHistory?.givenBy != administeredByView?.valueLabel.text{
                showDiscardChangesDialog()
                return
            }
        }
        
        let commentTextView = self.view.viewWithTag(COMMENT_TV_TAG) as? UITextView
        if editVaccine == nil{
            if !isNilOrEmpty(string: commentTextView?.text.trim()){
                showDiscardChangesDialog()
                return
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
            if !isNilOrEmpty(string: commentTextView?.text) && editVaccine?.patientImmunizationMap?.patientImmunizationHistory?.comments?.trim() != commentTextView?.text.trim(){
                showDiscardChangesDialog()
                return
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func createSubViews()
    {
    
        let containerScrollView = TPKeyboardAvoidingScrollView()
    
        
        let containerView = UIView()
        containerView.addShadowAndCornerRadius(.SMALL)
        
        let ageCategoryView = AddModuleKeyAndValueView()
        ageCategoryView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        ageCategoryView.tag = AGE_CATEGORY_VIEW_TAG
        ageCategoryView.keyLabel.text = getString(key: "com.charmphr.AddVaccine.AgeCategory.title")
        ageCategoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        ageCategoryView.backgroundColor = .clear
        ageCategoryView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(ageCategoryView)
        
        let vaccineNameView = AddModuleKeyAndValueView()
        vaccineNameView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        vaccineNameView.tag = VACINENAME_VIEW_TAG
        vaccineNameView.keyLabel.text = getString(key: "com.charmphr.AddVaccine.VaccineName.title")
        vaccineNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        vaccineNameView.backgroundColor = .clear
        vaccineNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(vaccineNameView)
        
        let manufacturerView = AddModuleKeyAndValueView()
        manufacturerView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        manufacturerView.tag = MANUFRCTURER_VIEW_TAG
        manufacturerView.keyLabel.text = getString(key: "com.charmphr.AddVaccine.Manufacturer.title")
        manufacturerView.textField.maxLength = 50
        manufacturerView.textField.pattern = alphanumericAndPHRAllowedSplCharacters
        manufacturerView.textField.textFieldType = MDTextFieldTypeSpecificPattern
        manufacturerView.textField.delegate = self
        manufacturerView.setPlaceholderForTextField(text: getString(key: "com.charmphr.AddVaccine.Manufacturer.placeHolder"))
        manufacturerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        manufacturerView.backgroundColor = .clear
        manufacturerView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(manufacturerView)
        
        startDatePicker.preferredDatePickerStyle = .wheels
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(startDatePickerValueChanged(datePicker:)), for: .valueChanged)
        
        let startDateView = AddModuleKeyAndValueView(isDateField: true)
        startDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        startDateView.tag = DATE_VIEW_TAG
        startDateView.keyLabel.text = getString(key: "com.charmphr.AddVaccine.Date.title")
//        startDateView.textField.canPreformAction = false
        startDateView.textField.tintColor = .clear
        startDateView.textField.inputView = startDatePicker
        
        startDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        startDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        startDateView.backgroundColor = .clear
        containerView.addSubview(startDateView)
        
        let adminiteredView = AddModuleKeyAndValueView()
        adminiteredView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        adminiteredView.tag = ADMINISTERED_VIEW_TAG
        adminiteredView.keyLabel.text = getString(key: "com.charmphr.AddVaccine.administered.title")
        adminiteredView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        adminiteredView.backgroundColor = .clear
        adminiteredView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(adminiteredView)
        
        let adminiteredByView = AddModuleKeyAndValueView()
        adminiteredByView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        adminiteredByView.tag = ADMINISTERED_BY_VIEW_TAG
        adminiteredByView.keyLabel.text = getString(key: "com.charmphr.AddVaccine.administeredBy.title")
        adminiteredByView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        adminiteredByView.backgroundColor = .clear
        adminiteredByView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(adminiteredByView)
        
        let commentView = AddModuleKeyAndValueWithTextView()
        commentView.KeyLabel.text = getString(key: "com.charmphr.AddVaccine.Comments.title")
        commentView.textView.tag = COMMENT_TV_TAG
        commentView.textView.delegate = self
        containerView.addSubview(commentView)
        commentView.backgroundColor = .clear
        commentView.textView.maxLength = 255
        
        if getPHREntryEnabledPractices(moduleId: vaccineModelId).count > 1 && editVaccine == nil
        {
            let practiceView = AddModuleKeyAndValueView()
            practiceView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
            practiceView.tag = PRACTICEVIEW_TAG
            practiceView.keyLabel.text = getString(key: "com.charmphr.common.Practice")
            practiceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
            practiceView.backgroundColor = .clear
            practiceView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            containerView.addSubview(practiceView)
            
            practiceView.setSafeAreaTop(offset: 0)
            practiceView.setLeft(offSet: 0)
            practiceView.setRight(offSet: -0)
            practiceView.setBottomRelatedToView(offSet: 0, relatedView: ageCategoryView, relatedAttribute: .top)
            
        }else
        {
            ageCategoryView.setSafeAreaTop(offset: 0)
        }
        
        ageCategoryView.setLeft(offSet: 0)
        ageCategoryView.setRight(offSet: -0)
        ageCategoryView.setBottomRelatedToView(offSet: 0, relatedView: vaccineNameView, relatedAttribute: .top)
        
        vaccineNameView.setLeft(offSet: 0)
        vaccineNameView.setRight(offSet: -0)
        vaccineNameView.setBottomRelatedToView(offSet: 0, relatedView: manufacturerView, relatedAttribute: .top)
        
        manufacturerView.setLeft(offSet: 0)
        manufacturerView.setRight(offSet: -0)
        manufacturerView.setBottomRelatedToView(offSet: 0, relatedView: startDateView, relatedAttribute: .top)
        
        startDateView.setLeft(offSet: 0)
        startDateView.setRight(offSet: -0)
        startDateView.setBottomRelatedToView(offSet: 0, relatedView: adminiteredView, relatedAttribute: .top)
        
        adminiteredView.setLeft(offSet: 0)
        adminiteredView.setRight(offSet: -0)
        adminiteredView.setBottomRelatedToView(offSet: 0, relatedView: adminiteredByView, relatedAttribute: .top)
        
        adminiteredByView.setLeft(offSet: 0)
        adminiteredByView.setRight(offSet: -0)
        adminiteredByView.setBottomRelatedToView(offSet: 0, relatedView: commentView, relatedAttribute: .top)
        
        commentView.setLeft(offSet: 0)
        commentView.setRight(offSet: -0)
        commentView.setBottom(offSet: -0)
        
        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: Y_SPACE)
        containerView.setBottom(offSet: -Y_SPACE)
        containerView.setLeft(offSet: X_SPACE)
        containerView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        
        
        containerScrollView.setSafeAreaTop(offset: 0)
        containerScrollView.setLeft(offSet: 0)
        containerScrollView.setRight(offSet: 0)
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[containerScrollView]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["containerScrollView":containerScrollView]))
        containerScrollView.setSafeAreaBottom(offset: 0)
    }
    
    //MARK: - action calls
    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        
        if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
        {
            
            if addAllergiesKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                dismissKeyboard()
                let selectValueVC = SelectValueViewController()
                setSelectValueVCValues(vc: selectValueVC)
                self.navigationController?.pushViewController(selectValueVC, animated: true)
//                performSegue(withIdentifier: "SelectValueVC", sender: self)
            }
            else
            {
                if isCommonDataFetched{
                    if addAllergiesKeyAndLabelView.tag == AGE_CATEGORY_VIEW_TAG || addAllergiesKeyAndLabelView.tag == VACINENAME_VIEW_TAG || addAllergiesKeyAndLabelView.tag == ADMINISTERED_VIEW_TAG || addAllergiesKeyAndLabelView.tag == ADMINISTERED_BY_VIEW_TAG
                    {
                        selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                        dismissKeyboard()
                        let selectValueVC = SelectValueViewController()
                        setSelectValueVCValues(vc: selectValueVC)
                        self.navigationController?.pushViewController(selectValueVC, animated: true)
//                        performSegue(withIdentifier: "SelectValueVC", sender: self)
                    }
                    else if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView{
                        if !addAllergiesKeyAndLabelView.textField.isHidden{
                            addAllergiesKeyAndLabelView.textField.becomeFirstResponder()
                        }
                    }
                }else
                {
                    CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.common.selectPractice"), msg: nil)
                }
            }
        }
    }
    
    func setPractice(selectedIndex : Int)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
        {
            let selectedPractice = getPHREntryEnabledPractices(moduleId: vaccineModelId)[selectedIndex]
            addAllergiesKeyAndLabelView.valueLabel.text = selectedPractice.practiceName ?? ""
            charmConnectionHandeler?.fetchCommonDataForVaccine(patientId: getSelectedPatientId(), practiceId: selectedPractice.practiceId ?? "", identificationKey: "commonData")
            showActivityIndicator()
        }
    }
    
    @objc func startDatePickerValueChanged(datePicker : UIDatePicker)
    {
        if (self.view.viewWithTag(DATE_VIEW_TAG) as? AddModuleKeyAndValueView) != nil
        {
            setDate(date: datePicker.date)
        }
    }
    
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
    
    @objc func doneBtnClicked()
    {
        dismissKeyboard()
        
        let practiceNameView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
        let ageCategoryView = self.view.viewWithTag(AGE_CATEGORY_VIEW_TAG) as? AddModuleKeyAndValueView
        let vaccineNameView = self.view.viewWithTag(VACINENAME_VIEW_TAG) as? AddModuleKeyAndValueView
        let manufracturerView = self.view.viewWithTag(MANUFRCTURER_VIEW_TAG) as? AddModuleKeyAndValueView
        let dateView = self.view.viewWithTag(DATE_VIEW_TAG) as? AddModuleKeyAndValueView
        let administeredView = self.view.viewWithTag(ADMINISTERED_VIEW_TAG) as? AddModuleKeyAndValueView
        let administeredByView = self.view.viewWithTag(ADMINISTERED_BY_VIEW_TAG) as? AddModuleKeyAndValueView
        let commentTextView = self.view.viewWithTag(COMMENT_TV_TAG) as? UITextView
        
        if let ageCategoryView = ageCategoryView, let vaccineNameView = vaccineNameView, let manufracturerView = manufracturerView, let dateView = dateView, let administeredView = administeredView, let administeredByView = administeredByView, let commentTextView = commentTextView
        {
            manufracturerView.textField.resignFirstResponder()
            dateView.textField.resignFirstResponder()
            commentTextView.resignFirstResponder()
            
            if isNilOrEmpty(string: vaccineNameView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: vaccineNameView.keyLabel.text)
            }
            else if isNilOrEmpty(string: practiceNameView?.valueLabel.text) && Patient.selectedPatientInstance?.practiceList.count ?? -1 > 1 && editVaccine == nil
            {
                showMandatoryAlert(fieldName: practiceNameView?.keyLabel.text)
            }
            else if isNilOrEmpty(string: dateView.textField.text)
            {
                showMandatoryAlert(fieldName: dateView.keyLabel.text)
                dateView.textField.becomeFirstResponder()
            }
            else if isNilOrEmpty(string: administeredView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: administeredView.keyLabel.text)
            }
            else if isNilOrEmpty(string: ageCategoryView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: ageCategoryView.keyLabel.text)
            }
            else
            {
                var vaccineImmunizationPOJO = VaccineImmunizationPOJO()
                
            
                if let editVaccine = editVaccine {
                    vaccineImmunizationPOJO = editVaccine
                }
                else{
                    let immune = ImmunizationList()
                    immune.immunizationName = vaccineNameView.valueLabel.text
                    
                    if ageCategoryView.valueLabel.text == "Childhood"
                    {
                        immune.immunizationType = "Vaccines_Childhood"
                    }else if ageCategoryView.valueLabel.text == "Adolescent"
                    {
                        immune.immunizationType = "Vaccines_Adolescent"
                    }
                    
                    let patientImmunizationMap = PatientImmunizationMap()
                    patientImmunizationMap.immunizationList = immune
                    patientImmunizationMap.patientImmunizationHistory = PatientImmunizationHistory()
                    vaccineImmunizationPOJO.patientImmunizationMap = patientImmunizationMap
                    
                }
                
                
                if let datePickerView = dateView.textField.inputView as? UIDatePicker
                {
                    vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.vaccinesOn = datePickerView.date
                }
                
                vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.comments = commentTextView.text.trim()
                vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.howAdministered = administeredView.valueLabel.text
                vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.manufacturer = manufracturerView.textField.text
                vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.givenBy = administeredByView.valueLabel.text

                

                
                if charmConnectionHandeler == nil
                {
                    charmConnectionHandeler = CharmConnectionHandler(delegate: self)
                }
                
                self.showActivityIndicator()
                
                if editVaccine == nil
                {
                    charmConnectionHandeler?.addOrUpdateVaccine(vaccine: vaccineImmunizationPOJO, identificationKey: "addVaccine")
                }else
                {
                    charmConnectionHandeler?.addOrUpdateVaccine(vaccine: vaccineImmunizationPOJO, identificationKey: "editVaccine", toUpdate: true)
                }
            }
        }
    }
    
    func showMandatoryAlert(fieldName : String?)
    {
        CharmUtil.createOkayAlertWith(title: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName ?? "")", msg: nil)
    }
    
    func setAgeCategory(selectedRow : Int){
        if let addAllergiesKeyAndLabelView = view.viewWithTag(AGE_CATEGORY_VIEW_TAG) as? AddModuleKeyAndValueView{
            addAllergiesKeyAndLabelView.valueLabel.text = ageCategoryArr[selectedRow]
        }
    }
    
    func setVaccineName(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(VACINENAME_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = vaccineNameDict?[vaccineNameDict?.allKeys[selectedRow] ?? ""] as? String
        }
    }
    
    func setAdministered(selectedRow : Int){
        if let addAllergiesKeyAndLabelView = view.viewWithTag(ADMINISTERED_VIEW_TAG) as? AddModuleKeyAndValueView{
            addAllergiesKeyAndLabelView.valueLabel.text = administeredList[selectedRow]
        }
    }
    
    func setAdministeredBy(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(ADMINISTERED_BY_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = providerDict?[providerDict?.allKeys[selectedRow] ?? ""] as? String
        }
    }
    
    func setDate(date : Date){
        startDatePicker.date = date
        if let vaccineDate = self.view.viewWithTag(DATE_VIEW_TAG) as? AddModuleKeyAndValueView{
            vaccineDate.textField.text = CharmUtil.getDisplayDateStringWithYear(date: date)
        }
    }
    
    // MARK: - charmconnectionhandler delegate
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "commonData"{
            
            isCommonDataFetched = true
            
            if let outputDict = jsonObject["output_string"] as? Dictionary<String,Any>
            {
                if let vaccineNameDictArr = outputDict["SEARCH_STRING"] as? Array<Dictionary<String,Any>>{
                    vaccineNameDict = MutableOrderedDictionary()
                    for vaccineDict in vaccineNameDictArr
                    {
                        vaccineNameDict?.setValue(vaccineDict["name"] as? String, forKey: "\(vaccineDict["id"] ?? "")")
                    }
                }
                
                if let providerDictArr = outputDict["PROVIDERS_LIST"] as? Array<Dictionary<String,Any>>{
                    providerDict = MutableOrderedDictionary()
                    for providerDictInducival in providerDictArr
                    {
                        providerDict?.setValue(providerDictInducival["FULL_NAME"] as? String, forKey: "\(providerDictInducival["PRACTICE_ID"] ?? "\(providerDictInducival["FULL_NAME"] ?? "")id" )")
                    }
                }
                
                if let administeredList = outputDict["ADMINISTERED_LIST"] as? Array<String>{
                    self.administeredList = administeredList
                }
                
                if let editVaccine = editVaccine {
                    let ageCategoryView = self.view.viewWithTag(AGE_CATEGORY_VIEW_TAG) as? AddModuleKeyAndValueView
                    let vaccineNameView = self.view.viewWithTag(VACINENAME_VIEW_TAG) as? AddModuleKeyAndValueView
                    let manufracturerView = self.view.viewWithTag(MANUFRCTURER_VIEW_TAG) as? AddModuleKeyAndValueView
                    let commentTextView = self.view.viewWithTag(COMMENT_TV_TAG) as? UITextView
                    
                    if editVaccine.patientImmunizationMap?.immunizationList?.immunizationType?.contains("Child") ?? true
                    {
                        setAgeCategory(selectedRow: 0)
                    }else
                    {
                        setAgeCategory(selectedRow:1)
                    }
                    
//                    let vaccineNameDictKeyArr = vaccineNameDict?.allKeys as? Array<String>
//                    if let index = vaccineNameDictKeyArr?.firstIndex(of: "\(editVaccine.patientImmunizationMap?.immunizationList?.immunizationId ?? "")")
//                    {
//                        setVaccineName(selectedRow: index)
//                    }
                    
                    vaccineNameView?.valueLabel.text = editVaccine.patientImmunizationMap?.immunizationList?.immunizationName 
                    
                    manufracturerView?.textField.text = editVaccine.patientImmunizationMap?.patientImmunizationHistory?.manufacturer ?? ""
                    
                    if let date = editVaccine.patientImmunizationMap?.patientImmunizationHistory?.vaccinesOn {
                        setDate(date: date)
                    }
                    
                    if let index = administeredList.firstIndex(of: editVaccine.patientImmunizationMap?.patientImmunizationHistory?.howAdministered ?? "")
                    {
                        setAdministered(selectedRow: index)
                    }
                    
                    let providerDictkeyArr = providerDict?.allValues as? Array<String>
                    if let index = providerDictkeyArr?.firstIndex(of: "\(editVaccine.patientImmunizationMap?.patientImmunizationHistory?.givenBy ?? "")")
                    {
                        setAdministeredBy(selectedRow: index)
                    }
                    
                    commentTextView?.text = editVaccine.patientImmunizationMap?.patientImmunizationHistory?.comments ?? ""
                    
                    vaccineNameView?.setViewDisabled()
                    ageCategoryView?.setViewDisabled()
                }
                else{
                    setAgeCategory(selectedRow: 0)
                    setDate(date: Date())
                    startDatePicker.date = Date()
                    setAdministered(selectedRow: 0)
                }
            }
            hideActivityIndicator()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "commonData"
        {
            if editVaccine == nil
            {
                if Patient.selectedPatientInstance?.practiceList.count == 1
                {
                    CharmUtil.createRetryAndCancelAlertWith(error: error) { [self] in
                        charmConnectionHandeler?.fetchCommonDataForVaccine(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: Patient.selectedPatientInstance?.practiceList[0].practiceId ?? "", identificationKey: "commonData")
                        showActivityIndicator()
                    } cancelClicked: {
                        self.navigationController?.popViewController(animated: true)
                    }
                }else
                {
                    if let addAllergiesKeyAndLabelView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
                    {
                        
                        CharmUtil.createRetryAndCancelAlertWith(error: error) { [self] in
                            charmConnectionHandeler?.fetchCommonDataForVaccine(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: Patient.selectedPatientInstance?.practiceList[Patient.selectedPatientInstance?.practiceNameArr.firstIndex(of: addAllergiesKeyAndLabelView.valueLabel.text ?? "") ?? 0].practiceId ?? "", identificationKey: "commonData")
                            showActivityIndicator()
                        } cancelClicked: {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else
            {
                CharmUtil.createRetryAndCancelAlertWith(error: error) { [self] in
                    charmConnectionHandeler?.fetchCommonDataForVaccine(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: editVaccine?.practiceId ?? "", identificationKey: "commonData")
                    showActivityIndicator()
                }
            }
        }else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        hideActivityIndicator()
        if identificationKey == "addVaccine" || identificationKey == "editVaccine"{
            
            if(delegate is VaccineViewController){
                navigationController?.popViewController(animated: true)
                if let resp = response as? [String: Any]{
                    delegate?.addViewControllerDataAdded(message: resp.getString("message"))
                }
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        
        if selectedAddModuleKeyAndLabelView?.tag == PRACTICEVIEW_TAG
        {
            setPractice(selectedIndex: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == AGE_CATEGORY_VIEW_TAG
        {
            setAgeCategory(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == VACINENAME_VIEW_TAG
        {
            setVaccineName(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == ADMINISTERED_BY_VIEW_TAG
        {
            setAdministeredBy(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == ADMINISTERED_VIEW_TAG
        {
            setAdministered(selectedRow: selectedRow)
        }
    }
    
    func selectValueViewControllerDidSelectCustomString(customString: String) {
        if selectedAddModuleKeyAndLabelView?.tag == VACINENAME_VIEW_TAG
        {
            if let addAllergiesKeyAndLabelView = view.viewWithTag(VACINENAME_VIEW_TAG) as? AddModuleKeyAndValueView
            {
                addAllergiesKeyAndLabelView.valueLabel.text = customString
            }
        }
        else if selectedAddModuleKeyAndLabelView?.tag == ADMINISTERED_VIEW_TAG
        {
            if let addAllergiesKeyAndLabelView = view.viewWithTag(ADMINISTERED_VIEW_TAG) as? AddModuleKeyAndValueView
            {
                addAllergiesKeyAndLabelView.valueLabel.text = customString
            }
        }
    }
//MARK: - SelectValue ViewController
    
    private func setSelectValueVCValues(vc: SelectValueViewController){
        vc.delegate = self
        if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView
        {
            vc.title = selectedAddModuleKeyAndLabelView.keyLabel.text
            
            if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                
                let practiceNameList = getPHREntryEnabledPractices(moduleId: vaccineModelId).map({practice in
                    practice.practiceName ?? ""
                })
                vc.arrayOfValueToBeShown =  practiceNameList
                vc.selectedValueIndex = practiceNameList.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == AGE_CATEGORY_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = ageCategoryArr
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == VACINENAME_VIEW_TAG
            {
                vc.valueDelegate = self
                vc.isSearchBarNeeded = true
                vc.addSearchTextAsValue = true
                vc.arrayOfValueToBeShown = vaccineNameDict?.allValues as? [String] ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == ADMINISTERED_BY_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = providerDict?.allValues as? [String] ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == ADMINISTERED_VIEW_TAG
            {
                vc.valueDelegate = self
                vc.isSearchBarNeeded = true
                vc.addSearchTextAsValue = true
                vc.arrayOfValueToBeShown = administeredList
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
        }
    }
    
    //MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "SelectValueVC"
        {
            
            if let vc = segue.destination as? SelectValueViewController{
                if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView
                {
                    vc.title = selectedAddModuleKeyAndLabelView.keyLabel.text
                    vc.delegate = self
                    
                    if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
                    {
                        
                        let practiceNameList = getPHREntryEnabledPractices(moduleId: vaccineModelId).map({practice in
                            practice.practiceName ?? ""
                        })
                        vc.arrayOfValueToBeShown =  practiceNameList
                        vc.selectedValueIndex = practiceNameList.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                    }
                    else if selectedAddModuleKeyAndLabelView.tag == AGE_CATEGORY_VIEW_TAG
                    {
                        vc.arrayOfValueToBeShown = ageCategoryArr
                        vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                    }
                    else if selectedAddModuleKeyAndLabelView.tag == VACINENAME_VIEW_TAG
                    {
                        vc.valueDelegate = self
                        vc.isSearchBarNeeded = true
                        vc.addSearchTextAsValue = true
                        vc.arrayOfValueToBeShown = vaccineNameDict?.allValues as! [String]
                        vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                    }
                    else if selectedAddModuleKeyAndLabelView.tag == ADMINISTERED_BY_VIEW_TAG
                    {
                        vc.arrayOfValueToBeShown = providerDict?.allValues as! [String]
                        vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                    }
                    else if selectedAddModuleKeyAndLabelView.tag == ADMINISTERED_VIEW_TAG
                    {
                        vc.valueDelegate = self
                        vc.isSearchBarNeeded = true
                        vc.addSearchTextAsValue = true
                        vc.arrayOfValueToBeShown = administeredList
                        vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                    }
                }
            }
        }
    }
}
