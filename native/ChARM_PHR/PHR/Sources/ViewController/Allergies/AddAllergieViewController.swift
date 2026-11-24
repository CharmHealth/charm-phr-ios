//
//  AddAllergieViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 24/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AddAllergieViewController: AddDataUIViewController , CharmConnectionHandlerDelegate , SelectValueViewControllerDelagate , UITextViewDelegate, MDTextFieldDelegate, UITextFieldDelegate
{
    
    let ALLERGIENAME_VIEW_TAG = 100
    let ALLERGIETYPE_VIEW_TAG = 101
    let ALLERGIESEVERITY_VIEW_TAG = 102
    let ALLERGIESTATUS_VIEW_TAG = 103
    let ALLERGIEOBSERVED_ON_VIEW_TAG = 104
    let ALLERGIERESOLVED_ON_VIEW_TAG = 106
    let ALLERGIERESOLVED_ON_TF_TAG = 107
    let ALLERGIEREACTION_TEXTVIEW_TAG = 105
    let ALLERGIEOTHERTYPE_VIEW_TAG = 109
    let PRACTICEVIEW_TAG = 108
    let datePickerView = UIDatePicker()
    
    var charmconnectionHandler : CharmConnectionHandler?
    
    let activityIndicator = UIActivityIndicatorView()
    
    var allergyTypeOptionArr : [String] = [""]
    var allergySeverityOptionArr : [String] = [""]
    var allergyStatusOptionArr : [String] = [""]
    var isAllergyRelatedDataFetched = false
    
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView?
    
    var editAlergyList : AllergiesList?
    weak var delegate : AddViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard)))
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        
        setupSubView()
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
                       
        charmconnectionHandler = CharmConnectionHandler(delegate: self)
        
        if editAlergyList == nil{
            self.title = getString(key: "com.charmphr.addAllergies.title")
        }
        else{
            self.title = getString(key: "com.charmphr.editAllergies.title")
        }
        fetchCommonData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(activityIndicator)
    }
    @objc override func onBackClick(){
        let practiceNameView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
        if editAlergyList == nil
        {
            if !isNilOrEmpty(string: practiceNameView?.valueLabel.text)
            {
                showDiscardChangesDialog()
                return
            }
        }
        
        let allergieNameView = self.view.viewWithTag(ALLERGIENAME_VIEW_TAG) as? AddModuleKeyAndValueView
        if editAlergyList == nil
        {
            if !isNilOrEmpty(string: allergieNameView?.textField.text?.trim())
            {
                showDiscardChangesDialog()
                return
            }
        }
        
        let allergieTypeView = self.view.viewWithTag(ALLERGIETYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        if editAlergyList == nil
        {
            if !isNilOrEmpty(string: allergieTypeView?.valueLabel.text) && allergieTypeView?.valueLabel.text != allergyTypeOptionArr[0]
            {
                showDiscardChangesDialog()
                return
            }
        }
        
        let allergieOtherTypeView = self.view.viewWithTag(ALLERGIEOTHERTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        
        if editAlergyList == nil
        {
            if !isNilOrEmpty(string: allergieOtherTypeView?.textField.text)
            {
                showDiscardChangesDialog()
                return
            }
        }
        
        let allergieSeveritview = self.view.viewWithTag(ALLERGIESEVERITY_VIEW_TAG) as? AddModuleKeyAndValueView
        if editAlergyList == nil{
            if !isNilOrEmpty(string: allergieSeveritview?.valueLabel.text) && allergieSeveritview?.valueLabel.text != allergySeverityOptionArr[0]
            {
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if !isNilOrEmpty(string: allergieSeveritview?.valueLabel.text) && editAlergyList?.patientAllergyMap?.severity != allergieSeveritview?.valueLabel.text
            {
                showDiscardChangesDialog()
                return
            }
        }
        
        let allergieStatusView = self.view.viewWithTag(ALLERGIESTATUS_VIEW_TAG) as? AddModuleKeyAndValueView
        if editAlergyList == nil
        {
            if !isNilOrEmpty(string: allergieStatusView?.valueLabel.text) && allergieStatusView?.valueLabel.text != allergyStatusOptionArr[0]
            {
                showDiscardChangesDialog()
                return
            }
        }
        else
        {
            if !isNilOrEmpty(string: allergieStatusView?.valueLabel.text) && editAlergyList?.patientAllergyMap?.status != allergieStatusView?.valueLabel.text
            {
                showDiscardChangesDialog()
                return
            }
        }
        
        let allergieObservedOnView = self.view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
        if editAlergyList == nil
        {
            if !isNilOrEmpty(string: allergieObservedOnView?.textField.text) && allergieObservedOnView?.textField.text != CharmUtil.getDateStringWith(date: Date(), dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            {
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if !isNilOrEmpty(string: allergieObservedOnView?.textField.text) && editAlergyList?.patientAllergyMap?.observedDate != CharmUtil.getDateObjectWith(dateString: (allergieObservedOnView?.textField.text)!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            {
                showDiscardChangesDialog()
                return
            }
        }
        
        let allergieResolvedView = self.view.viewWithTag(ALLERGIERESOLVED_ON_TF_TAG) as? AddModuleKeyAndValueView
        if editAlergyList == nil
        {
            if !isNilOrEmpty(string: allergieResolvedView?.textField.text) && allergieResolvedView?.textField.text != CharmUtil.getDateStringWith(date: Date(), dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            {
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if editAlergyList?.patientAllergyMap?.status?.lowercased() == "resolved"
            {
                if !isNilOrEmpty(string: allergieResolvedView?.textField.text) && editAlergyList?.patientAllergyMap?.resolvedDate != CharmUtil.getDateObjectWith(dateString: (allergieResolvedView?.textField.text)!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                {
                    showDiscardChangesDialog()
                    return
                }
            }
        }
        let allergieReactionTextView = self.view.viewWithTag(ALLERGIEREACTION_TEXTVIEW_TAG) as? UITextView
        if editAlergyList == nil
        {
            if !isNilOrEmpty(string: allergieReactionTextView?.text.trim())
            {
                showDiscardChangesDialog()
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
            if !isNilOrEmpty(string: allergieReactionTextView?.text.trim()) && editAlergyList?.patientAllergyMap?.reactions?.trim() != allergieReactionTextView?.text.trim()
            {
                showDiscardChangesDialog()
                return
            }
            else
            {
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setupSubView()
    {
        
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
        
        
        let containerView = UIView()
        containerView.addShadowAndCornerRadius(.SMALL)
        
        containerScrollView.addSubview(containerView)
        
        let allergieNameView = AddModuleKeyAndValueView()
        allergieNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        allergieNameView.tag = ALLERGIENAME_VIEW_TAG
        allergieNameView.keyLabel.text = getString(key: "com.charmphr.addAllergies.AllergenName")
        allergieNameView.setPlaceholderForTextField(text: getString(key: "com.charmphr.addAllergies.AllergenName.placeholder"))
        allergieNameView.textField.maxLength = 50
        allergieNameView.textField.textFieldType = MDTextFieldTypeAlphaNumericWithSpace
        allergieNameView.textField.delegate = self
        allergieNameView.backgroundColor = .clear
        allergieNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        allergieNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        containerView.addSubview(allergieNameView)
        
        let allergieTypeView = AddModuleKeyAndValueView()
        allergieTypeView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        allergieTypeView.tag = ALLERGIETYPE_VIEW_TAG
        allergieTypeView.keyLabel.text = getString(key: "com.charmphr.addAllergies.AllergenType")
        allergieTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieTypeView.backgroundColor = .clear
        allergieTypeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(allergieTypeView)
        
        let allergieOtherTypeView = AddModuleKeyAndValueView()
        allergieOtherTypeView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        allergieOtherTypeView.tag = ALLERGIEOTHERTYPE_VIEW_TAG
        allergieOtherTypeView.keyLabel.text = getString(key: "com.charmphr.addAllergies.OtherType")
        allergieOtherTypeView.textField.delegate = self
        allergieOtherTypeView.textField.textFieldType = MDTextFieldTypeAlphaNumeric
        allergieOtherTypeView.textField.maxLength = 50
        allergieOtherTypeView.setPlaceholderForTextField(text: getString(key: "com.charmphr.addAllergies.OtherType"))
        allergieOtherTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieOtherTypeView.backgroundColor = .clear
        allergieOtherTypeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        allergieOtherTypeView.removeSubViews()
        containerView.addSubview(allergieOtherTypeView)
        
        let allergieSeverityiew = AddModuleKeyAndValueView()
        allergieSeverityiew.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        allergieSeverityiew.tag = ALLERGIESEVERITY_VIEW_TAG
        allergieSeverityiew.keyLabel.text = getString(key: "com.charmphr.addAllergies.Severity")
        allergieSeverityiew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieSeverityiew.backgroundColor = .clear
        allergieSeverityiew.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(allergieSeverityiew)
        
        let allergieStatusView = AddModuleKeyAndValueView()
        allergieStatusView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        allergieStatusView.tag = ALLERGIESTATUS_VIEW_TAG
        allergieStatusView.keyLabel.text = getString(key: "com.charmphr.addAllergies.Status")
        allergieStatusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieStatusView.backgroundColor = .clear
        allergieStatusView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(allergieStatusView)
        
        let allergieObservedOnView = AddModuleKeyAndValueView(isDateField: true)
        allergieObservedOnView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        allergieObservedOnView.tag = ALLERGIEOBSERVED_ON_VIEW_TAG
        allergieObservedOnView.setPlaceholderForTextField(text: getString(key: "com.charmphr.common.dateField.placeholder"))
        allergieObservedOnView.keyLabel.text = getString(key: "com.charmphr.addAllergies.ObservedOn")
        allergieObservedOnView.textField.tintColor = .clear
        allergieObservedOnView.backgroundColor = .clear
        
        datePickerView.preferredDatePickerStyle = .wheels
        datePickerView.datePickerMode = .date
        datePickerView.date = Date()
        datePickerView.maximumDate = Date()
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        allergieObservedOnView.textField.inputView = datePickerView

        allergieObservedOnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieObservedOnView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        
        containerView.addSubview(allergieObservedOnView)
        
        let allergieResolvedOnView = UIView()
        allergieResolvedOnView.tag = ALLERGIERESOLVED_ON_VIEW_TAG
        containerView.addSubview(allergieResolvedOnView)

        let allergieReactionView = AddModuleKeyAndValueWithTextView()
        allergieReactionView.KeyLabel.text = getString(key: "com.charmphr.addAllergies.AnyReactions")
        allergieReactionView.textView.maxLength = 255
        allergieReactionView.textView.delegate = self
        allergieReactionView.textView.tag = ALLERGIEREACTION_TEXTVIEW_TAG
        allergieReactionView.backgroundColor = .clear
        containerView.addSubview(allergieReactionView)
        
        
        if Patient.selectedPatientInstance?.practiceList.count ?? -1 > 1 && editAlergyList == nil
        {
            let practiceView = AddModuleKeyAndValueView()
            practiceView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
            practiceView.tag = PRACTICEVIEW_TAG
            practiceView.keyLabel.text = getString(key: "com.charmphr.common.Practice")
            practiceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
            practiceView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            practiceView.backgroundColor = .clear
            containerView.addSubview(practiceView)
            
            practiceView.setSafeAreaTop(offset: 0)
            practiceView.setLeft(offSet: 0)
            practiceView.setRight(offSet: -0)
            practiceView.setBottomRelatedToView(offSet: 0, relatedView: allergieNameView, relatedAttribute: .top)
            
        }else
        {
            allergieNameView.setSafeAreaTop(offset: 0)
        }
        
        allergieNameView.setLeft(offSet: 0)
        allergieNameView.setRight(offSet: -0)
        allergieNameView.setBottomRelatedToView(offSet: 0, relatedView: allergieTypeView, relatedAttribute: .top)
        
        allergieTypeView.setLeft(offSet: 0)
        allergieTypeView.setRight(offSet: -0)
        allergieTypeView.setBottomRelatedToView(offSet: 0, relatedView: allergieOtherTypeView, relatedAttribute: .top)
        
        allergieOtherTypeView.setLeft(offSet: 0)
        allergieOtherTypeView.setRight(offSet: -0)
        allergieOtherTypeView.setBottomRelatedToView(offSet: 0, relatedView: allergieSeverityiew, relatedAttribute: .top)
        
        allergieSeverityiew.setLeft(offSet: 0)
        allergieSeverityiew.setRight(offSet: -0)
        allergieSeverityiew.setBottomRelatedToView(offSet: 0, relatedView: allergieStatusView, relatedAttribute: .top)
        
        allergieStatusView.setLeft(offSet: 0)
        allergieStatusView.setRight(offSet: -0)
        allergieStatusView.setBottomRelatedToView(offSet: 0, relatedView: allergieObservedOnView, relatedAttribute: .top)
        
        allergieObservedOnView.setLeft(offSet: 0)
        allergieObservedOnView.setRight(offSet: -0)
        allergieObservedOnView.setBottomRelatedToView(offSet: 0, relatedView: allergieResolvedOnView, relatedAttribute: .top)
        
        allergieResolvedOnView.setLeft(offSet: 0)
        allergieResolvedOnView.setRight(offSet: -0)
        allergieResolvedOnView.setBottomRelatedToView(offSet: 0, relatedView: allergieReactionView, relatedAttribute: .top)
        
        allergieReactionView.setLeft(offSet: 0)
        allergieReactionView.setRight(offSet: -0)
        allergieReactionView.setBottom(offSet: 0)
        
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: Y_SPACE)
        containerView.setBottom(offSet: -Y_SPACE)
        containerView.setLeft(offSet: X_SPACE)
        containerView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        
        containerScrollView.setSafeAreaTop(offset: 0)
        containerScrollView.setLeft(offSet: 0)
        containerScrollView.setRight(offSet: 0)
        containerScrollView.setSafeAreaBottom(offset: 0)
    }
    
    func createResolvedView()
    {
        if let resolvedView = self.view.viewWithTag(ALLERGIERESOLVED_ON_VIEW_TAG)
        {
            let allergieResolvedView = AddModuleKeyAndValueView()
            allergieResolvedView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
            allergieResolvedView.tag = ALLERGIERESOLVED_ON_TF_TAG
            allergieResolvedView.textField.placeholder = getString(key: "com.charmphr.common.dateField.placeholder")
            allergieResolvedView.keyLabel.text = getString(key: "com.charmphr.addAllergies.ResolvedOn")
            allergieResolvedView.textField.tintColor = .clear
            
            datePickerView.preferredDatePickerStyle = .wheels
            datePickerView.datePickerMode = .date
            datePickerView.maximumDate = Date()
            datePickerView.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
            allergieResolvedView.textField.inputView = datePickerView
            allergieResolvedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
            allergieResolvedView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            resolvedView.addSubview(allergieResolvedView)
            allergieResolvedView.setTop(offSet: 0)
            allergieResolvedView.setRight(offSet: 0)
            allergieResolvedView.setBottom(offSet: 0)
            allergieResolvedView.setLeft(offSet: 0)
            
        }
    }
    
    func removeResolvedView()
    {
        if let resolvedView = self.view.viewWithTag(ALLERGIERESOLVED_ON_VIEW_TAG)
        {
            resolvedView.endEditing(true)
            for view in resolvedView.subviews
            {
                view.removeFromSuperview()
            }
        }
    }
    
    func fetchCommonData()
    {
        if self.editAlergyList == nil
        {
            if Patient.selectedPatientInstance?.practiceList.count ?? -1 == 1
            {
                self.charmconnectionHandler?.fetchAllergiesRelatedData(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: Patient.selectedPatientInstance?.practiceList[0].practiceId ?? "", identificationKey: "allergiesRelatedData")
                self.showActivityIndicator()
            }else
            {
                if let addAllergiesKeyAndLabelView = self.view.viewWithTag(self.PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
                {
                    if !isNilOrEmpty(string: addAllergiesKeyAndLabelView.valueLabel.text)
                    {
                        self.charmconnectionHandler?.fetchAllergiesRelatedData(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: Patient.selectedPatientInstance?.practiceList[Patient.selectedPatientInstance?.practiceNameArr.firstIndex(of: addAllergiesKeyAndLabelView.valueLabel.text ?? "") ?? 0].practiceId ?? "", identificationKey: "allergiesRelatedData")
                        self.showActivityIndicator()
                    }
                }
            }
        }else
        {
            self.charmconnectionHandler?.fetchAllergiesRelatedData(patientId: Patient.selectedPatientInstance?.patientId ?? "", practiceId: Patient.selectedPatientInstance?.practiceList[0].practiceId ?? "", identificationKey: "allergiesRelatedData")
            self.showActivityIndicator()
        }
    }
    
    
    //MARK: - action calls
    @objc func viewClicked(tapGestureRecognizer:UITapGestureRecognizer)
    {
        if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
        {
            if addAllergiesKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                
                let selectValueVC = SelectValueViewController()
                setSelectValueVCValues(vc: selectValueVC)
                self.navigationController?.pushViewController(selectValueVC, animated: true)
                
//                performSegue(withIdentifier: "SelectValueVC", sender: self)
            }else
            {
                if isAllergyRelatedDataFetched
                {
                    if addAllergiesKeyAndLabelView.tag == ALLERGIENAME_VIEW_TAG || addAllergiesKeyAndLabelView.tag == ALLERGIEOBSERVED_ON_VIEW_TAG || addAllergiesKeyAndLabelView.tag == ALLERGIERESOLVED_ON_TF_TAG
                    {
                        addAllergiesKeyAndLabelView.textField.becomeFirstResponder()
                    }
                    else if addAllergiesKeyAndLabelView.tag == ALLERGIETYPE_VIEW_TAG ||  addAllergiesKeyAndLabelView.tag == ALLERGIESEVERITY_VIEW_TAG || addAllergiesKeyAndLabelView.tag == ALLERGIESTATUS_VIEW_TAG
                    {
                        selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                        let selectValueVC = SelectValueViewController()
                        setSelectValueVCValues(vc: selectValueVC)
                        self.navigationController?.pushViewController(selectValueVC, animated: true)
                        
//                        performSegue(withIdentifier: "SelectValueVC", sender: self)
                    }
                    
                }else
                {
                    showSelectPracticeAlert()
                }
            }
        }
    }
    
    @objc func datePickerValueChanged(datePicker : UIDatePicker)
    {
        let allergieObservedOnView = self.view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieResolvedView = self.view.viewWithTag(ALLERGIERESOLVED_ON_TF_TAG) as? AddModuleKeyAndValueView
        
        if let addAllergiesKeyAndLabelView = view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            if addAllergiesKeyAndLabelView.textField.isFirstResponder
            {
                addAllergiesKeyAndLabelView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
                datePicker.minimumDate = .none
                if !isNilOrEmpty(string: allergieResolvedView?.textField.text)
                {
                    datePicker.maximumDate = CharmUtil.getDateObjectWith(dateString: allergieResolvedView!.textField.text!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                }
            }
        }
        
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(ALLERGIERESOLVED_ON_TF_TAG) as? AddModuleKeyAndValueView
        {
             if addAllergiesKeyAndLabelView.textField.isFirstResponder
             {
                addAllergiesKeyAndLabelView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
                datePicker.minimumDate = CharmUtil.getDateObjectWith(dateString: allergieObservedOnView!.textField.text!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                 datePicker.maximumDate = Date()
             }
        }
    }
    
    func showSelectPracticeAlert()
    {
        CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.common.selectPractice"), msg: nil)
    }
    
    func showMandatoryAlert(fieldName : String?)
    {
        CharmUtil.createOkayAlertWith(title: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName ?? "")", msg: nil)
    }
    
    @objc func dismissKeyBoard()
    {
        self.view.endEditing(true)
    }
    
    @objc func doneBtnClicked()
    {
        dismissKeyBoard()
        
        let practiceNameView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
        let allergieNameView = self.view.viewWithTag(ALLERGIENAME_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieTypeView = self.view.viewWithTag(ALLERGIETYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieSeverityiew = self.view.viewWithTag(ALLERGIESEVERITY_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieStatusView = self.view.viewWithTag(ALLERGIESTATUS_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieObservedOnView = self.view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieOtherTypeView = self.view.viewWithTag(ALLERGIEOTHERTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieReactionTextView = self.view.viewWithTag(ALLERGIEREACTION_TEXTVIEW_TAG) as? UITextView
        let allergieResolvedView = self.view.viewWithTag(ALLERGIERESOLVED_ON_TF_TAG) as? AddModuleKeyAndValueView
        
        if let allergieNameView = allergieNameView, let allergieTypeView = allergieTypeView, let allergieSeverityiew = allergieSeverityiew, let allergieStatusView = allergieStatusView,let allergieObservedOnView = allergieObservedOnView
        {
            let allergen = allergieNameView.textField.text ?? ""
            if isNilOrEmpty(string: allergen)
            {
                showMandatoryAlert(fieldName: allergieNameView.keyLabel.text)
                allergieNameView.textField.becomeFirstResponder()
            }
            else if (!allergen.hasAnyAlphabets()){
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.allergen.name.invalid"), msg: nil)
                allergieNameView.textField.becomeFirstResponder()
            }
            else if isNilOrEmpty(string: practiceNameView?.valueLabel.text) && Patient.selectedPatientInstance?.practiceList.count ?? -1 > 1 && editAlergyList == nil
            {
                showMandatoryAlert(fieldName: practiceNameView?.keyLabel.text ?? "")
            }
            else if isNilOrEmpty(string: allergieTypeView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: allergieTypeView.keyLabel.text)
            }
            else if isNilOrEmpty(string: allergieSeverityiew.valueLabel.text)
            {
                showMandatoryAlert(fieldName: allergieSeverityiew.keyLabel.text)
            }
            else if isNilOrEmpty(string: allergieStatusView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: allergieStatusView.keyLabel.text)
            }
            else if isNilOrEmpty(string: allergieObservedOnView.textField.text)
            {
                showMandatoryAlert(fieldName: allergieObservedOnView.keyLabel.text)
                allergieObservedOnView.textField.becomeFirstResponder()
            }
//            else if allergieTypeView?.valueLabel.text == "Others" && isNilOrEmpty(string: allergieOtherTypeView!.textField.text)
//            {
//                showMandatoryAlert(fieldName: allergieOtherTypeView!.keyLabel.text!)
//                allergieOtherTypeView!.textField.becomeFirstResponder()
//            }
            else if allergieStatusView.valueLabel.text == "Resolved" && isNilOrEmpty(string: allergieResolvedView?.textField.text)
            {
                showMandatoryAlert(fieldName: getString(key: "com.charmphr.addAllergies.ResolvedOn"))
                allergieResolvedView?.textField.becomeFirstResponder()
            }
                
//            else if !isNilOrEmpty(string: allergieReactionTextView?.text)
//            {
//                showMandatoryAlert(fieldName: allergieObservedOnView!.keyLabel.text!)
//            }
            else
            {
                
                let allergyList = AllergiesList()
                let patientAllergyMap = PatientAllergyMap()
                allergyList.allergy = allergieNameView.textField.text
                allergyList.allergyType = allergieTypeView.valueLabel.text
                patientAllergyMap.severity  = allergieSeverityiew.valueLabel.text
                patientAllergyMap.status = allergieStatusView.valueLabel.text
                patientAllergyMap.reactions = allergieReactionTextView?.text
                allergyList.patientAllergyMap = patientAllergyMap
                if allergieTypeView.valueLabel.text == OTHERS && !isNilOrEmpty(string: allergieOtherTypeView?.textField.text)
                {
                    allergyList.otherType = allergieOtherTypeView?.textField.text
                }
                
                if allergieResolvedView != nil
                {
                    if let datePicker : UIDatePicker = allergieResolvedView?.textField.inputView as? UIDatePicker
                    {
                        allergyList.patientAllergyMap?.resolvedDate = datePicker.date
                    }
                }
                
                if let datePicker : UIDatePicker = allergieObservedOnView.textField.inputView as? UIDatePicker
                {
                    allergyList.patientAllergyMap?.observedDate = datePicker.date
                }
                
                if charmconnectionHandler == nil
                {
                    charmconnectionHandler = CharmConnectionHandler(delegate: self)
                }
                
                self.showActivityIndicator()
                
                if editAlergyList == nil
                {
                    charmconnectionHandler?.addAllergy(jsonObject: JsonBuilder.convertAllergyToJson(allergiesList: allergyList), identificationKey: "addAllergyCalled" , httpMedthod:  HTTP_METHOD.HTTP_METHOD_POST)
                }else
                {
                    allergyList.allergyId = editAlergyList?.allergyId
                    allergyList.patientAllergyMap?.allergyMapId = editAlergyList?.patientAllergyMap?.allergyMapId
                    charmconnectionHandler?.addAllergy(jsonObject: JsonBuilder.convertAllergyToJson(allergiesList: allergyList), identificationKey: "addAllergyCalled", httpMedthod: .HTTP_METHOD_PUT)
                }
                
            }
        }
    }
    
    func setAllergyObservedDate(date : Date)
    {
        if let allergyObservedOn = self.view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            allergyObservedOn.textField.text = CharmUtil.getDateStringWith(date: date, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        }
    }
    
    func setAllergyResolvedDate(date : Date)
    {
        if let allergyResolvedOn = self.view.viewWithTag(ALLERGIERESOLVED_ON_TF_TAG) as? AddModuleKeyAndValueView
        {
            allergyResolvedOn.textField.text = CharmUtil.getDateStringWith(date: date, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        }
    }
    
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.backButton.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.backButton.isEnabled = true
    }
    
    func fillAllergyValueForEditAllergy()
    {
        let allergieNameView = self.view.viewWithTag(ALLERGIENAME_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieTypeView = self.view.viewWithTag(ALLERGIETYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieObservedOnView = self.view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieReactionTextView = self.view.viewWithTag(ALLERGIEREACTION_TEXTVIEW_TAG) as? UITextView
        
        allergieNameView?.textField.text = editAlergyList?.allergy
        
        if let datePicker = allergieObservedOnView?.textField.inputView as? UIDatePicker
        {
            datePicker.date = editAlergyList?.patientAllergyMap?.observedDate ?? Date()
            allergieObservedOnView?.textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
        }

        setStatus(selectedIndex: allergyStatusOptionArr.firstIndex(of: editAlergyList?.patientAllergyMap?.status ?? "") ?? 0)
        setSeverity(selectedIndex: allergySeverityOptionArr.firstIndex(of: editAlergyList?.patientAllergyMap?.severity ?? "") ?? 0)
        setAllergieType(selectedIndex: allergyTypeOptionArr.firstIndex(of: editAlergyList?.allergyType ?? "") ?? 0)
        allergieReactionTextView?.text = editAlergyList?.patientAllergyMap?.reactions
        
        if editAlergyList?.patientAllergyMap?.resolvedDate != nil
        {
            createResolvedView()
            if let textField = self.view.viewWithTag(ALLERGIERESOLVED_ON_TF_TAG) as? UITextField
            {
                let datePicker = textField.inputView as? UIDatePicker
                datePicker?.date = editAlergyList?.patientAllergyMap?.observedDate ?? Date()
                textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker?.date ?? Date())
            }
        }

        // set some view disable
        allergieNameView?.setViewDisabled()
        allergieTypeView?.setViewDisabled()
        
    }
    
    //MARK: - assingn value for keys
    func setAllergieType(selectedIndex : Int)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(ALLERGIETYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = allergyTypeOptionArr[selectedIndex]
            if allergyTypeOptionArr[selectedIndex] == OTHERS && editAlergyList == nil
            {
                if  let procedureOthersTypeView = self.view.viewWithTag(ALLERGIEOTHERTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
                {
                    procedureOthersTypeView.addSubViews()
                }
            }else
            {
                if  let procedureOthersTypeView = self.view.viewWithTag(ALLERGIEOTHERTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
                {
                    procedureOthersTypeView.removeSubViews()
                }
            }
        }
    }
    
    func setSeverity(selectedIndex : Int)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(ALLERGIESEVERITY_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = allergySeverityOptionArr[selectedIndex]
        }
    }
    
    func setStatus(selectedIndex : Int)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(ALLERGIESTATUS_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = allergyStatusOptionArr[selectedIndex]
            
            if allergyStatusOptionArr[selectedIndex] == "Resolved"
            {
                createResolvedView()
                setAllergyResolvedDate(date: Date())
                
            }else
            {
                removeResolvedView()
            }
        }
    }
    
    func setPractice(selectedIndex : Int)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = Patient.selectedPatientInstance?.practiceNameArr[selectedIndex]
            fetchCommonData()
        }
    }

    //MARK: - charmconnection handler delegate methods
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        
        if identificationKey == "allergiesRelatedData"
        {
            hideActivityIndicator()
            if let outputString = jsonObject.getAsJsonObject("output_string"){
                allergyTypeOptionArr = ParsingHelper.giveArrayOfAllergyTypeFromDictionary(dict: outputString)
            }
            if let outputString = jsonObject.getAsJsonObject("output_string"){
                allergySeverityOptionArr = ParsingHelper.giveArrayOfAllergySeverityFromDictionary(dict: outputString)
            }
            if let outputString = jsonObject.getAsJsonObject("output_string"){
                allergyStatusOptionArr = ParsingHelper.giveArrayOfAllergyStatusFromDictionary(dict: outputString)
            }
            if editAlergyList == nil
            {
                setAllergyObservedDate(date: Date())
                setAllergyResolvedDate(date: Date())
                setAllergieType(selectedIndex: 0)
                setSeverity(selectedIndex: 0)
                setStatus(selectedIndex: 0)
            }else
            {
                fillAllergyValueForEditAllergy()
            }
            
            isAllergyRelatedDataFetched = true
        }
        else if identificationKey == "addAllergyCalled"
        {
            if(delegate is AllergiesViewController){
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
        if identificationKey == "allergiesRelatedData"
        {
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.fetchCommonData()
            } cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            }
        }else
        {
            let nsError  = error as NSError
            if nsError.code == 5007 {
                CharmUtil.createOkayAlertWith(title: nil, msg: nsError.domain)
            }
            else{
                CharmUtil.createOkayAlertWith(error: error)
            }
        }
    }
    
    //MARK: - selectValueViewController delegate methods
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView
        {
            if selectedAddModuleKeyAndLabelView.tag == ALLERGIETYPE_VIEW_TAG
            {
                setAllergieType(selectedIndex: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == ALLERGIESEVERITY_VIEW_TAG
            {
                setSeverity(selectedIndex: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == ALLERGIESTATUS_VIEW_TAG
            {
                setStatus(selectedIndex: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                setPractice(selectedIndex: selectedRow)
            }
        }
    }


    //MARK: - navigation
    
    private func setSelectValueVCValues(vc: SelectValueViewController){
        vc.delegate = self

        if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView
        {
            vc.title = selectedAddModuleKeyAndLabelView.keyLabel.text
            if selectedAddModuleKeyAndLabelView.tag == ALLERGIETYPE_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = allergyTypeOptionArr
                vc.selectedValueIndex = allergyTypeOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == ALLERGIESEVERITY_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = allergySeverityOptionArr
                vc.selectedValueIndex = allergySeverityOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == ALLERGIESTATUS_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = allergyStatusOptionArr
                vc.selectedValueIndex = allergyStatusOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                vc.arrayOfValueToBeShown = Patient.selectedPatientInstance?.practiceNameArr ?? [String]()
                vc.selectedValueIndex = Patient.selectedPatientInstance?.practiceNameArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectValueVC"
        {
            dismissKeyBoard()
            let vc = segue.destination as? SelectValueViewController
            if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView
            {
                vc?.title = selectedAddModuleKeyAndLabelView.keyLabel.text
                vc?.delegate = self
                if selectedAddModuleKeyAndLabelView.tag == ALLERGIETYPE_VIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = allergyTypeOptionArr
                    vc?.selectedValueIndex = allergyTypeOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
                else if selectedAddModuleKeyAndLabelView.tag == ALLERGIESEVERITY_VIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = allergySeverityOptionArr
                    vc?.selectedValueIndex = allergySeverityOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
                else if selectedAddModuleKeyAndLabelView.tag == ALLERGIESTATUS_VIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = allergyStatusOptionArr
                    vc?.selectedValueIndex = allergyStatusOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
                else if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = Patient.selectedPatientInstance?.practiceNameArr ?? [String]()
                    vc?.selectedValueIndex = Patient.selectedPatientInstance?.practiceNameArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
            }
        }
    }
}
