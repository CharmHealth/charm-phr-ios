//
//  HpAddAllergiesViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 30/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//
/*
import UIKit

class HpAddAllergiesViewController: UIViewController, CharmConnectionHandlerDelegate, UITextViewDelegate, SelectValueViewControllerDelagate
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
    
    var charmconnectionHandler : CharmConnectionHandler!
    
    let activityIndicator = UIActivityIndicatorView()
    
    var allergyTypeOptionArr : [String] = [""]
    var allergySeverityOptionArr : [String] = [""]
    var allergyStatusOptionArr : [String] = [""]
    var isAllergyRelatedDataFetched = false
    
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView!
    
    var editAlergyList : AllergiesList?
    var delegate : AddViewControllerDelegate?
    

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
        charmconnectionHandler.fetchAllergiesRelatedData(patientId: Patient.selectedPatientInstance!.patientId, practiceId: "", identificationKey: "fetchCommonData")
        showActivityIndicator()
        
        if editAlergyList == nil
        {
            self.title = NSLocalizedString("com.charmphr.hpAddAllergies.title", comment: "")
        }else
        {
            self.title = NSLocalizedString("com.charmphr.hpEditAllergies.title", comment: "")
        }
    }
    
    func createSubView()
    {
        
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
        let containerView = UIView()
        containerView.layer.cornerRadius = CORNER_RADIUS_5
        containerView.backgroundColor = .clear
        
        let allergieNameView = AddModuleKeyAndValueView()
        allergieNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        allergieNameView.tag = ALLERGIENAME_VIEW_TAG
        allergieNameView.keyLabel.text = NSLocalizedString("com.charmphr.hpAddAllergies.AllergenName", comment: "")
        allergieNameView.textField.placeholder = NSLocalizedString("com.charmphr.hpAddAllergies.AllergenName.placeholder", comment: "")
        allergieNameView.textField.maxLength = 50
        allergieNameView.textField.valueType = .alphaNumeric
        allergieNameView.textField.delegate = self
        allergieNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        allergieNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        containerView.addSubview(allergieNameView)
        
        let allergieTypeView = AddModuleKeyAndValueView()
        allergieTypeView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        allergieTypeView.tag = ALLERGIETYPE_VIEW_TAG
        allergieTypeView.keyLabel.text = NSLocalizedString("com.charmphr.hpAddAllergies.AllergenType", comment: "")
        allergieTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieTypeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(allergieTypeView)
        
        let allergieOtherTypeView = AddModuleKeyAndValueView()
        allergieOtherTypeView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        allergieOtherTypeView.tag = ALLERGIEOTHERTYPE_VIEW_TAG
        allergieOtherTypeView.keyLabel.text = NSLocalizedString("com.charmphr.hpAddAllergies.OtherType", comment: "")
        allergieOtherTypeView.textField.delegate = self
        allergieOtherTypeView.textField.valueType = .alphaNumeric
        allergieOtherTypeView.textField.maxLength = 50
        allergieOtherTypeView.textField.placeholder = NSLocalizedString("com.charmphr.hpAddAllergies.OtherType", comment: "")
        allergieOtherTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieOtherTypeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        allergieOtherTypeView.removeSubViews()
        containerView.addSubview(allergieOtherTypeView)
        
        let allergieSeverityiew = AddModuleKeyAndValueView()
        allergieSeverityiew.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        allergieSeverityiew.tag = ALLERGIESEVERITY_VIEW_TAG
        allergieSeverityiew.keyLabel.text = NSLocalizedString("com.charmphr.hpAddAllergies.Severity", comment: "")
        allergieSeverityiew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieSeverityiew.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(allergieSeverityiew)
        
        let allergieStatusView = AddModuleKeyAndValueView()
        allergieStatusView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        allergieStatusView.tag = ALLERGIESTATUS_VIEW_TAG
        allergieStatusView.keyLabel.text = NSLocalizedString("com.charmphr.hpAddAllergies.Status", comment: "")
        allergieStatusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        containerView.addSubview(allergieStatusView)
        
        let allergieObservedOnView = AddModuleKeyAndValueView()
        allergieObservedOnView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        allergieObservedOnView.tag = ALLERGIEOBSERVED_ON_VIEW_TAG
        allergieObservedOnView.textField.placeholder = NSLocalizedString("com.charmphr.common.dateField.placeholder", comment: "")
        allergieObservedOnView.keyLabel.text = NSLocalizedString("com.charmphr.hpAddAllergies.ObservedOn", comment: "")
        allergieObservedOnView.textField.tintColor = .clear
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
        datePickerView.maximumDate = Date()
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        allergieObservedOnView.textField.inputView = datePickerView
        allergieObservedOnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        allergieObservedOnView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(allergieObservedOnView)

        let allergieReactionView = UIView()
        
        let anyReactionLabel = UILabel()
        anyReactionLabel.text = NSLocalizedString("com.charmphr.hpAddAllergies.AnyReactions", comment: "")
        anyReactionLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        anyReactionLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        allergieReactionView.addSubview(anyReactionLabel)
        
        let anyReactionsTextView = MDTextView()
        anyReactionsTextView.isScrollEnabled = false
        anyReactionsTextView.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        anyReactionsTextView.textColor = .black
        anyReactionsTextView.maxLength = 255
        anyReactionsTextView.delegate = self
        anyReactionsTextView.tag = ALLERGIEREACTION_TEXTVIEW_TAG
        anyReactionsTextView.layer.cornerRadius = CORNER_RADIUS_5
        anyReactionsTextView.layer.borderWidth = 1
        anyReactionsTextView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha:TEXT_VIEW_BORDER_COLOR).cgColor
        allergieReactionView.addSubview(anyReactionsTextView)
        
        anyReactionLabel.setTop(offSet: Y_SPACE)
        anyReactionLabel.setLeft(offSet: 10)
        anyReactionLabel.setRight(offSet: -10)
        anyReactionLabel.setBottomRelatedToView(offSet: -5.5, relatedView: anyReactionsTextView, relatedAttribute: .top)
        
        anyReactionsTextView.setLeft(offSet: 10)
        anyReactionsTextView.setRight(offSet: -10)
        anyReactionsTextView.setBottom(offSet: -Y_SPACE)
        anyReactionsTextView.setHeight(constant: 50, relatedBy: .greaterThanOrEqual)
        
        allergieReactionView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        containerView.addSubview(allergieReactionView)
        
        
        allergieNameView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CORNER_RADIUS_5)
        allergieNameView.setSafeAreaTop(offset: 0)
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
        allergieStatusView.setBottomRelatedToView(offSet: -12, relatedView: allergieObservedOnView, relatedAttribute: .top)
        allergieStatusView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CORNER_RADIUS_5)
        
        allergieObservedOnView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CORNER_RADIUS_5)
        allergieObservedOnView.setLeft(offSet: 0)
        allergieObservedOnView.setRight(offSet: -0)
        allergieObservedOnView.setBottomRelatedToView(offSet: 0, relatedView: allergieReactionView, relatedAttribute: .top)
        
        allergieReactionView.setLeft(offSet: 0)
        allergieReactionView.setRight(offSet: -0)
        allergieReactionView.setBottom(offSet: 0)
        allergieReactionView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CORNER_RADIUS_5)
        
        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        self.view.addConstraint(NSLayoutConstraint.init(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: -(X_SPACE + X_SPACE)))
        
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[containerScrollView]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["containerScrollView":containerScrollView]))
        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
        
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
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
        {
            if addAllergiesKeyAndLabelView.tag == ALLERGIETYPE_VIEW_TAG ||  addAllergiesKeyAndLabelView.tag == ALLERGIESEVERITY_VIEW_TAG || addAllergiesKeyAndLabelView.tag == ALLERGIESTATUS_VIEW_TAG
            {
                selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                dismissKeyboard()
                navigateToSelectValueVC()
            }
            else if !addAllergiesKeyAndLabelView.textField.isHidden
            {
                addAllergiesKeyAndLabelView.textField.becomeFirstResponder()
            }
        }
    }
    
    func showMandatoryAlert(fieldName : String)
    {
        let alertController = UIAlertController(title: nil, message: "\(NSLocalizedString("com.charmphr.common.mandatory.alert.msg", comment: ""))\(fieldName)", preferredStyle: .alert)
        let okAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.Ok", comment: ""), style: .default) { (alert) in
        
        }
        alertController.addAction(okAction)
        alertController.show()
    }
    
    //MARK: - selectValueViewController delegate methods
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        if selectedAddModuleKeyAndLabelView != nil
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
        }
    }
    
    @objc func datePickerValueChanged(datePicker : UIDatePicker)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.textField.text = CharmUtil.getDateStringWith(date: datePicker.date, dateFormat: PHR_DATE_DISPLAY_FORMAT)
        }
    }
    
    //MARK: - assingn value for keys
    func setAllergieType(selectedIndex : Int)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(ALLERGIETYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = allergyTypeOptionArr[selectedIndex]
            if allergyTypeOptionArr[selectedIndex] == "Others"
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
        }
    }
    
    
    @objc func doneBtnClicked()
    {
        dismissKeyboard()
        let allergieNameView = self.view.viewWithTag(ALLERGIENAME_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieTypeView = self.view.viewWithTag(ALLERGIETYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieSeverityiew = self.view.viewWithTag(ALLERGIESEVERITY_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieStatusView = self.view.viewWithTag(ALLERGIESTATUS_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieObservedOnView = self.view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieOtherTypeView = self.view.viewWithTag(ALLERGIEOTHERTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        let allergieReactionTextView = self.view.viewWithTag(ALLERGIEREACTION_TEXTVIEW_TAG) as? UITextView
                
        if allergieNameView != nil && allergieTypeView != nil && allergieSeverityiew != nil && allergieStatusView != nil && allergieObservedOnView != nil
        {
            if isNilOrEmpty(string: allergieNameView!.textField.text)
            {
                showMandatoryAlert(fieldName: allergieNameView!.keyLabel.text!)
                allergieNameView!.textField.becomeFirstResponder()
            }
            else if isNilOrEmpty(string: allergieTypeView!.valueLabel.text)
            {
                showMandatoryAlert(fieldName: allergieTypeView!.keyLabel.text!)
            }
            else if isNilOrEmpty(string: allergieSeverityiew!.valueLabel.text)
            {
                showMandatoryAlert(fieldName: allergieSeverityiew!.keyLabel.text!)
            }
            else if isNilOrEmpty(string: allergieStatusView!.valueLabel.text)
            {
                showMandatoryAlert(fieldName: allergieStatusView!.keyLabel.text!)
            }
            else if isNilOrEmpty(string: allergieObservedOnView!.textField.text)
            {
                showMandatoryAlert(fieldName: allergieObservedOnView!.keyLabel.text!)
                allergieObservedOnView!.textField.becomeFirstResponder()
            }
            else if allergieTypeView?.valueLabel.text == "Others" && isNilOrEmpty(string: allergieOtherTypeView!.textField.text)
            {
                showMandatoryAlert(fieldName: allergieOtherTypeView!.keyLabel.text!)
                allergieOtherTypeView!.textField.becomeFirstResponder()
            }
            else
            {
                        
                let allergyList = AllergiesList()
                        
                allergyList.allergy = allergieNameView!.textField.text
                allergyList.allergyType = allergieTypeView!.valueLabel.text
                allergyList.patientAllergyMap.severity  = allergieSeverityiew?.valueLabel.text
                allergyList.patientAllergyMap.status = allergieStatusView!.valueLabel.text
                allergyList.patientAllergyMap.reactions = allergieReactionTextView?.text
                        
                if allergieTypeView?.valueLabel.text == "Others" && !isNilOrEmpty(string: allergieOtherTypeView?.textField.text)
                {
                    allergyList.otherType = allergieOtherTypeView?.textField.text!
                }
                        
                        
                if let datePicker : UIDatePicker = allergieObservedOnView?.textField.inputView as? UIDatePicker
                {
                    allergyList.patientAllergyMap.observedDate = datePicker.date
                }
                        
                if charmconnectionHandler == nil
                {
                    charmconnectionHandler = CharmConnectionHandler(delegate: self)
                }
                        
                self.showActivityIndicator()
                        
                if editAlergyList == nil
                {
                    charmconnectionHandler.addAllergy(jsonObject: JsonBuilder.convertAllergyToJson(allergiesList: allergyList), identificationKey: "addAllergy" , httpMedthod:  .HTTP_METHOD_POST)
                }else
                {
                    allergyList.allergyId = editAlergyList?.allergyId
                    allergyList.patientAllergyMap.allergyMapId = editAlergyList?.patientAllergyMap.allergyMapId
                    charmconnectionHandler.addAllergy(jsonObject: JsonBuilder.convertAllergyToJson(allergiesList: allergyList), identificationKey: "addAllergy", httpMedthod: .HTTP_METHOD_PUT)
                }
                        
            }
        }
        
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String)
    {
        if identificationKey == "fetchCommonData"
        {
            hideActivityIndicator()
            let parsingHelper = ParsingHelper()
            allergyTypeOptionArr = parsingHelper.giveArrayOfAllergyTypeFromDictionary(dict: jsonObject["output_string"] as! Dictionary<String,Any>)
            allergySeverityOptionArr = parsingHelper.giveArrayOfAllergySeverityFromDictionary(dict: jsonObject["output_string"] as! Dictionary<String,Any>)
            allergyStatusOptionArr = parsingHelper.giveArrayOfAllergyStatusFromDictionary(dict: jsonObject["output_string"] as! Dictionary<String,Any>)
            
            if editAlergyList == nil
            {
                setAllergieType(selectedIndex: 0)
                setSeverity(selectedIndex: 0)
                setStatus(selectedIndex: 0)
            }else
            {
                let allergieNameView = self.view.viewWithTag(ALLERGIENAME_VIEW_TAG) as? AddModuleKeyAndValueView
                let allergieTypeView = self.view.viewWithTag(ALLERGIETYPE_VIEW_TAG) as? AddModuleKeyAndValueView
                let allergieObservedOnView = self.view.viewWithTag(ALLERGIEOBSERVED_ON_VIEW_TAG) as? AddModuleKeyAndValueView
                let allergieReactionTextView = self.view.viewWithTag(ALLERGIEREACTION_TEXTVIEW_TAG) as? UITextView
                       
                allergieNameView!.textField.text = editAlergyList?.allergy
                       
                if let datePicker = allergieObservedOnView?.textField.inputView as? UIDatePicker
                {
                    datePicker.date = editAlergyList!.patientAllergyMap.observedDate
                    allergieObservedOnView?.textField.text = CharmUtil.getDateStringWith(date: datePicker.date, dateFormat: "dd MMM yyyy")
                }

                setStatus(selectedIndex: allergyStatusOptionArr.firstIndex(of: editAlergyList!.patientAllergyMap.status) ?? 0)
                setSeverity(selectedIndex: allergySeverityOptionArr.firstIndex(of: editAlergyList!.patientAllergyMap.severity) ?? 0)
                setAllergieType(selectedIndex: allergyTypeOptionArr.firstIndex(of: editAlergyList!.allergyType) ?? 0)
                allergieReactionTextView?.text = editAlergyList?.patientAllergyMap.reactions

                // set some view disable
                allergieNameView!.textField.isUserInteractionEnabled = false
                allergieNameView?.textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
                allergieTypeView?.isUserInteractionEnabled = false
                allergieTypeView?.valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
            }
        }
        else if identificationKey == "addAllergy"
        {
            delegate?.addViewControllerDataAdded()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        self.hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    //MARK: - navigation
    func navigateToSelectValueVC()
    {
        dismissKeyboard()
        let vc = SelectValueViewController()
        if selectedAddModuleKeyAndLabelView != nil
        {
            vc.title = selectedAddModuleKeyAndLabelView.keyLabel.text
            vc.delegate = self
            if selectedAddModuleKeyAndLabelView.tag == ALLERGIETYPE_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = allergyTypeOptionArr
                vc.selectedValueIndex = allergyTypeOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text!)
            }
            else if selectedAddModuleKeyAndLabelView.tag == ALLERGIESEVERITY_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = allergySeverityOptionArr
                vc.selectedValueIndex = allergySeverityOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text!)
            }
            else if selectedAddModuleKeyAndLabelView.tag == ALLERGIESTATUS_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = allergyStatusOptionArr
                vc.selectedValueIndex = allergyStatusOptionArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text!)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
*/
