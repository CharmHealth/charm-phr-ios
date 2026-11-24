//
//  AddHospitalizationViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 30/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

/*import UIKit

class AddHospitalizationViewController: UIViewController, CharmConnectionHandlerDelegate, UITextViewDelegate, SelectValueViewControllerDelagate
{

    let PROCEDURESNAME_VIEW_TAG = 1000
    let PROCEDURESTYPE_VIEW_TAG = 1001
    let PROCEDURESDATE_VIEW_TAG = 1002
    let PROCEDURES_OTHERSTYPE_VIEW_TAG = 1004
    let PROCEDURESCOMMENT_TF_TAG = 1005
    
    let datePicker = UIDatePicker()
    let activityIndicator = UIActivityIndicatorView()
    
    var charmconnectionHandler : CharmConnectionHandler!
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView!
    var procedureTypeArr : [String] = []
    
    var delegate : AddViewControllerDelegate?
    var editProcedure : ProceduresList?

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
        charmconnectionHandler.fetchCommonDataForProcedure(patientId: Patient.selectedPatientInstance!.patientId,isHealthPassport: true, identificationKey: "commonDataProcedures")
        showActivityIndicator()
        
        if editProcedure == nil
        {
            self.navigationItem.title = NSLocalizedString("com.charmphr.addHospitalization.title", comment: "")
        }else
        {
            self.navigationItem.title = NSLocalizedString("com.charmphr.editHospitalization.title", comment: "")
        }
        
        
    }
    
    func createSubView()
    {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
        let containerView = UIView()
        containerView.layer.cornerRadius = CORNER_RADIUS_5
        containerView.backgroundColor = .clear
        
        let proceduresNameView = AddModuleKeyAndValueView()
        proceduresNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        proceduresNameView.tag = PROCEDURESNAME_VIEW_TAG
        proceduresNameView.keyLabel.text = NSLocalizedString("com.charmphr.addHospitalization.Hospitalization.title", comment: "")
        proceduresNameView.textField.delegate = self
        proceduresNameView.textField.valueType = .allowSpecialCharacters
        proceduresNameView.textField.maxLength = 50
        proceduresNameView.textField.placeholder = NSLocalizedString("com.charmphr.addHospitalization.Hospitalization.PlaceHolder", comment: "")
        proceduresNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(proceduresNameView)
        
        let proceduresTypeView = AddModuleKeyAndValueView()
        proceduresTypeView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        proceduresTypeView.tag = PROCEDURESTYPE_VIEW_TAG
        proceduresTypeView.keyLabel.text = NSLocalizedString("com.charmphr.addHospitalization.type.title", comment: "")
        proceduresTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresTypeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(proceduresTypeView)
        
        let proceduresOthersTypeView = AddModuleKeyAndValueView()
        proceduresOthersTypeView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        proceduresOthersTypeView.tag = PROCEDURES_OTHERSTYPE_VIEW_TAG
        proceduresOthersTypeView.keyLabel.text = NSLocalizedString("com.charmphr.addProcedures.others.type.title", comment: "")
        proceduresOthersTypeView.textField.delegate = self
        proceduresOthersTypeView.textField.valueType = .alphaNumeric
        proceduresOthersTypeView.textField.maxLength = 50
        proceduresOthersTypeView.textField.placeholder = NSLocalizedString("com.charmphr.addProcedures.others.type.placeHolder", comment: "")
        proceduresOthersTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresOthersTypeView.removeSubViews()
        containerView.addSubview(proceduresOthersTypeView)
        
        let proceduresDateView = AddModuleKeyAndValueView()
        proceduresDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        proceduresDateView.tag = PROCEDURESDATE_VIEW_TAG
        proceduresDateView.keyLabel.text = NSLocalizedString("com.charmphr.addHospitalization.dateOn.title", comment: "")
        proceduresDateView.textField.inputView = datePicker
        proceduresDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        proceduresDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        containerView.addSubview(proceduresDateView)
        
        let proceduresCommentView = UIView()
        
        let proceduresCommentLabel = UILabel()
        proceduresCommentLabel.text = NSLocalizedString("com.charmphr.addHospitalization.Outcome.title", comment: "")
        proceduresCommentLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        proceduresCommentLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        proceduresCommentView.addSubview(proceduresCommentLabel)
        
        let proceduresCommentTextView = MDTextView()
        proceduresCommentTextView.isScrollEnabled = false
        proceduresCommentTextView.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        proceduresCommentTextView.textColor = .black
        proceduresCommentTextView.tag = PROCEDURESCOMMENT_TF_TAG
        proceduresCommentTextView.layer.cornerRadius = CORNER_RADIUS_5
        proceduresCommentTextView.layer.borderWidth = 1
        proceduresCommentTextView.maxLength = 500
        proceduresCommentTextView.delegate = self
        proceduresCommentTextView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_VIEW_BORDER_COLOR).cgColor
        proceduresCommentView.addSubview(proceduresCommentTextView)
        
        proceduresCommentLabel.setTop(offSet: Y_SPACE)
        proceduresCommentLabel.setLeft(offSet: 10)
        proceduresCommentLabel.setRight(offSet: -10)
        proceduresCommentLabel.setBottomRelatedToView(offSet: -5.5, relatedView: proceduresCommentTextView, relatedAttribute: .top)
        
        proceduresCommentTextView.setLeft(offSet: 10)
        proceduresCommentTextView.setRight(offSet: -10)
        proceduresCommentTextView.setBottom(offSet: -Y_SPACE)
        proceduresCommentTextView.setHeight(constant: 50, relatedBy: .greaterThanOrEqual)
        
        proceduresCommentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        containerView.addSubview(proceduresCommentView)
        
        proceduresNameView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CORNER_RADIUS_5)
        proceduresNameView.setSafeAreaTop(offset: 0)
        proceduresNameView.setLeft(offSet: 0)
        proceduresNameView.setRight(offSet: 0)
        proceduresNameView.setBottomRelatedToView(offSet: 0, relatedView: proceduresTypeView, relatedAttribute: .top)
        
        proceduresTypeView.setLeft(offSet: 0)
        proceduresTypeView.setRight(offSet: 0)
        proceduresTypeView.setBottomRelatedToView(offSet: 0, relatedView: proceduresOthersTypeView, relatedAttribute: .top)
        
        proceduresOthersTypeView.setLeft(offSet: 0)
        proceduresOthersTypeView.setRight(offSet: 0)
        proceduresOthersTypeView.setBottomRelatedToView(offSet: -12, relatedView: proceduresDateView, relatedAttribute: .top)
        proceduresOthersTypeView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CORNER_RADIUS_5)
        
        proceduresDateView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CORNER_RADIUS_5)
        proceduresDateView.setLeft(offSet: 0)
        proceduresDateView.setRight(offSet: 0)
        proceduresDateView.setBottomRelatedToView(offSet: 0, relatedView: proceduresCommentView, relatedAttribute: .top)
        
        proceduresCommentView.setLeft(offSet: 0)
        proceduresCommentView.setRight(offSet: 0)
        proceduresCommentView.setBottom(offSet: 0)
        proceduresCommentView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CORNER_RADIUS_5)
        
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
            if addAllergiesKeyAndLabelView.tag == PROCEDURESTYPE_VIEW_TAG
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
    
    @objc func datePickerValueChanged(datePicker : UIDatePicker)
    {
        setProcedureDate(date: datePicker.date)
    }

    func setProcedureDate(date : Date)
    {
        if let procedureDateView = self.view.viewWithTag(PROCEDURESDATE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            procedureDateView.textField.text = CharmUtil.getDateStringWith(date: date, dateFormat: PHR_DATE_DISPLAY_FORMAT)
        }
    }
    
    func setProcedureType(row : Int)
    {
        if let procedureTypeView = self.view.viewWithTag(PROCEDURESTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            procedureTypeView.valueLabel.text = procedureTypeArr[row]
            
            let procedureOthersTypeView = self.view.viewWithTag(PROCEDURES_OTHERSTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
            
            if procedureTypeArr[row].lowercased().contains("other")
            {
                procedureOthersTypeView?.addSubViews()
            }
            else if procedureTypeArr[row].contains("Hospitalization")
            {
                procedureOthersTypeView?.removeSubViews()
            }
            else
            {
                procedureOthersTypeView?.removeSubViews()
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

    @objc func doneBtnClicked()
    {
        dismissKeyboard()
        
        let procedureNameView = self.view.viewWithTag(PROCEDURESNAME_VIEW_TAG) as! AddModuleKeyAndValueView
        let procedureTypeView = self.view.viewWithTag(PROCEDURESTYPE_VIEW_TAG) as! AddModuleKeyAndValueView
        let procedureOtherTypeView = self.view.viewWithTag(PROCEDURES_OTHERSTYPE_VIEW_TAG) as! AddModuleKeyAndValueView
        let procedureDateView = self.view.viewWithTag(PROCEDURESDATE_VIEW_TAG) as! AddModuleKeyAndValueView
        let procedureCommentTF = self.view.viewWithTag(PROCEDURESCOMMENT_TF_TAG) as! UITextView
        
        if isNilOrEmpty(string: procedureNameView.textField.text)
        {
            showMandatoryAlert(fieldName: procedureNameView.keyLabel.text!)
            procedureNameView.textField.becomeFirstResponder()
        }
        else if isNilOrEmpty(string: procedureTypeView.valueLabel.text)
        {
            showMandatoryAlert(fieldName: procedureTypeView.keyLabel.text!)
        }
        else if isNilOrEmpty(string: procedureDateView.textField.text)
        {
            showMandatoryAlert(fieldName: procedureDateView.keyLabel.text!)
            procedureDateView.textField.becomeFirstResponder()
        }
        else if procedureTypeView.valueLabel.text!.lowercased().contains("other") && isNilOrEmpty(string: procedureOtherTypeView.textField.text)
        {
            showMandatoryAlert(fieldName: procedureOtherTypeView.keyLabel.text!)
            procedureOtherTypeView.textField.becomeFirstResponder()
        }
            
        else
        {
            
            let procedureList = ProceduresList()
            
            procedureList.fromDate = CharmUtil.getDateObjectWith(dateString: procedureDateView.textField.text!, dateFormat: PHR_DATE_DISPLAY_FORMAT)

            if procedureTypeView.valueLabel.text!.lowercased().contains("other")
            {
                procedureList.procedureType = procedureOtherTypeView.textField.text
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
            
            if editProcedure != nil
            {
                procedureList.procedureMapId = editProcedure!.procedureMapId
                var json = JsonBuilder.convertProcedureValueToJson(patientId: Patient.selectedPatientInstance!.patientId, procedureList: procedureList)
                json.updateValue("true", forKey: "health_passport")
                charmconnectionHandler.addProcedure(json: json, isHealthPassport: true,identificationKey: "addProcedure", httpMedthod: .HTTP_METHOD_PUT)
            }else
            {
                var json = JsonBuilder.convertProcedureValueToJson(patientId: Patient.selectedPatientInstance!.patientId, procedureList: procedureList)
                json.updateValue("true", forKey: "health_passport")
                charmconnectionHandler.addProcedure(json: json,isHealthPassport: true, identificationKey: "addProcedure", httpMedthod: .HTTP_METHOD_POST)
            }
            showActivityIndicator()
        }
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "commonDataProcedures"
        {
            if let outputString = jsonObject["output_string"] as? Dictionary<String,Any>
            {
                procedureTypeArr = outputString["PROCEDURE_TYPE"] as! Array<String>
            }
            
            if (editProcedure != nil)
            {
                if let procedureNameView = self.view.viewWithTag(PROCEDURESNAME_VIEW_TAG) as? AddModuleKeyAndValueView
                {
                    procedureNameView.textField.text = editProcedure!.procedureName
                    procedureNameView.textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
                    procedureNameView.isUserInteractionEnabled = false
                }
                
                if let procedureTypeView = self.view.viewWithTag(PROCEDURESTYPE_VIEW_TAG) as? AddModuleKeyAndValueView
                {
                    procedureTypeView.valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
                    procedureTypeView.isUserInteractionEnabled = false
                }
                
                if let procedureCommentTf = self.view.viewWithTag(PROCEDURESCOMMENT_TF_TAG) as? UITextView
                {
                    procedureCommentTf.text = editProcedure!.comments
                }
                
                setProcedureType(row: procedureTypeArr.firstIndex(of: editProcedure!.procedureType) ?? 0)
                setProcedureDate(date: editProcedure!.fromDate)
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
            delegate?.addViewControllerDataAdded()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        if selectedAddModuleKeyAndLabelView.tag == PROCEDURESTYPE_VIEW_TAG
        {
            setProcedureType(row: selectedRow)
        }
    }
    
    //MARK: - navigation
    func navigateToSelectValueVC()
    {
        let vc = SelectValueViewController()
        vc.title = selectedAddModuleKeyAndLabelView.keyLabel.text
        vc.delegate = self
        if selectedAddModuleKeyAndLabelView.tag == PROCEDURESTYPE_VIEW_TAG
        {
            vc.arrayOfValueToBeShown  = procedureTypeArr
            vc.selectedValueIndex = procedureTypeArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text!)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
*/
