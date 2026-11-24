//
//  AddSupplementViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 06/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AddSupplementViewController: AddDataUIViewController , CharmConnectionV2HandlerDelegate , SelectValueViewControllerDelagate , UITextViewDelegate , SelectValueViewControllerValueDelagate, MDTextFieldDelegate, UITextFieldDelegate
{

    let SUPPLEMENT_NAME_VIEW_TAG = 1000
    let DOSE_VIEW_TAG = 1001
    let DOSE_UNIT_VIEW_TAG = 1002
    let STRENGHT_VIEW_TAG = 1003
    let STRENGHT_UNIT_VIEW_TAG = 1004
    let MANUFACTURER_VIEW_TAG = 1005
    let FREQUENCY_VIEW_TAG = 1006
    let WHEN_VIEW_TAG = 1007
    let STARTDATE_VIEW_TAG = 1008
    let STOPDATE_VIEW_TAG = 1009
    let COMMENT_VIEW_TAG = 1013
    let COMMENT_TF_TAG = 1023
    let PRACTICEVIEW_TAG = 1014
    
    let activityIndicator = UIActivityIndicatorView()
    
    var charmConnectionHandeler : CharmConnectionHandler?
    
    var isCommonDataFetched = false
    
    var sxUnitListArr : Array<String> = []
    var supplementNameDict : MutableOrderedDictionary?
    var unitWithNameDict : MutableOrderedDictionary?
    var routeListArr : [String] = []
    var intakeDict : MutableOrderedDictionary?
//    var intakeArr : Array<String> = []
    var intakeWhenDict : MutableOrderedDictionary?
    var manufacturerDict : MutableOrderedDictionary?
    
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView?
    
    let startDatePicker = UIDatePicker()
    let stopDatePicker = UIDatePicker()
    
    
    var practiceArr: [Practice] = []
    var practiceNameArr: [String] = []
    
    var editSupplementPOJO : SupplementPOJO?
    var addSupplementPOJO : SupplementPOJO?
    
    weak var delegate : AddViewControllerDelegate?
    weak var addReminderAlertDelegate: AddReminderAlertDelegate? = nil
    
    override func viewDidLoad() {
    super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        
        createSubViews()
        readIntakeFrequencyJson()
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        charmConnectionHandeler = CharmConnectionHandler(v2Delegate: self)
        if editSupplementPOJO == nil
        {
            self.navigationItem.title = getString(key: "com.charmphr.add.MedicationAndSupplememnts.AddSupplement.title")
            fetchCommonData()
        }else
        {
            self.navigationItem.title = getString(key: "com.charmphr.add.MedicationAndSupplememnts.EditSupplement.title")
            fetchCommonData()
        }
    }
        
    func createSubViews()
    {
    
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
        let containerView = UIView()
        

        let supplementNameGroupView = UIView()
        
        containerView.addSubview(supplementNameGroupView)
        supplementNameGroupView.addShadowAndCornerRadius(.SMALL)
        
        let supplementsNameView = AddModuleKeyAndValueView()
        supplementsNameView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        supplementsNameView.tag = SUPPLEMENT_NAME_VIEW_TAG
        supplementsNameView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.supplementName.title")
        supplementsNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        supplementsNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        supplementNameGroupView.addSubview(supplementsNameView)
        
        let doseView = AddModuleKeyAndValueView()
        doseView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        doseView.tag = DOSE_VIEW_TAG
        doseView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.dose.title")
        doseView.setPlaceholderForTextField(text: getString(key: "com.charmphr.add.MedicationAndSupplememnts.dose.placeHolder"))
        doseView.textField.keyboardType = .decimalPad
        doseView.textField.delegate = self
        doseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        doseView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        supplementNameGroupView.addSubview(doseView)
        
        let doseUnitView = AddModuleKeyAndValueView()
        doseUnitView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        doseUnitView.tag = DOSE_UNIT_VIEW_TAG
        doseUnitView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.doseUnit.title")
        doseUnitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        doseUnitView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        supplementNameGroupView.addSubview(doseUnitView)
        
        let strengthView = AddModuleKeyAndValueView()
        strengthView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        strengthView.tag = STRENGHT_VIEW_TAG
        strengthView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Strength.title")
        strengthView.textField.delegate = self
        strengthView.textField.maxLength = 7
        strengthView.textField.keyboardType = .numberPad
        strengthView.textField.textFieldType = MDTextFieldTypeInteger
        strengthView.setPlaceholderForTextField(text: getString(key: "com.charmphr.add.MedicationAndSupplememnts.Strength.placeHoldeer"))
        strengthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        strengthView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        supplementNameGroupView.addSubview(strengthView)
        
        let strengthUnitView = AddModuleKeyAndValueView()
        strengthUnitView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        strengthUnitView.tag = STRENGHT_UNIT_VIEW_TAG
        strengthUnitView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.StrengthUnit.title")
        strengthUnitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        strengthUnitView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        supplementNameGroupView.addSubview(strengthUnitView)
        
        let manufacturerView = AddModuleKeyAndValueView()
        manufacturerView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        manufacturerView.tag = MANUFACTURER_VIEW_TAG
        manufacturerView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.manufacturer.title")
        manufacturerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
//        manufacturerView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        supplementNameGroupView.addSubview(manufacturerView)
        
        
        let frequencyGroupView = UIView()
        
        containerView.addSubview(frequencyGroupView)
        frequencyGroupView.addShadowAndCornerRadius(.SMALL)
        
        let frequencyView = AddModuleKeyAndValueView()
        frequencyView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        frequencyView.tag = FREQUENCY_VIEW_TAG
        frequencyView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Frequency.title")
        frequencyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        frequencyView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        frequencyGroupView.addSubview(frequencyView)
        
        let whenView = AddModuleKeyAndValueView()
        whenView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        whenView.tag = WHEN_VIEW_TAG
        whenView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.when.title")
        whenView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
//        whenView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        frequencyGroupView.addSubview(whenView)
        
        startDatePicker.preferredDatePickerStyle = .wheels
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(startDatePickerValueChanged(datePicker:)), for: .valueChanged)
        
        stopDatePicker.preferredDatePickerStyle = .wheels
        stopDatePicker.datePickerMode = .date
        stopDatePicker.addTarget(self, action: #selector(stopDatePickerValueChanged(datePicker:)), for: .valueChanged)
        
        
        
        let othersGroupView = UIView()
        
        containerView.addSubview(othersGroupView)
        othersGroupView.addShadowAndCornerRadius(.SMALL)
        
        let startDateView = AddModuleKeyAndValueView(isDateField: true)
        startDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        startDateView.tag = STARTDATE_VIEW_TAG
        startDateView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.StartDate.title")
//        startDateView.textField.canPreformAction = false
        startDateView.textField.tintColor = .clear
        startDateView.textField.inputView = startDatePicker
        
        startDateView.setPlaceholderForTextField(text: getString(key: "com.charmphr.common.dateField.placeholder"))
        startDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        startDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        othersGroupView.addSubview(startDateView)
        
//        startDatePicker.date = Date()
//        startDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: startDatePicker.date)
        
        
        let stopDateView = AddModuleKeyAndValueView(isDateField: true)
        stopDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        stopDateView.tag = STOPDATE_VIEW_TAG
        stopDateView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.EndDate.title")
//        stopDateView.textField.canPreformAction = false
        stopDateView.textField.tintColor = .clear
        stopDateView.textField.inputView = stopDatePicker
        
        stopDateView.setPlaceholderForTextField(text: getString(key: "com.charmphr.common.dateField.placeholder"))
        stopDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        stopDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        othersGroupView.addSubview(stopDateView)
        
//        stopDatePicker.date = Date()
//        stopDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: stopDatePicker.date)

        
        let commentView = AddModuleKeyAndValueWithTextView()
        commentView.KeyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Comment.title")
        commentView.textView.tag = COMMENT_TF_TAG
        commentView.textView.maxLength = 255
        commentView.textView.delegate = self
        othersGroupView.addSubview(commentView)
        
        practiceArr = getPHREntryEnabledPractices(moduleId: supplementModelId)
        practiceNameArr = practiceArr.map({practice in
            practice.practiceName ?? ""
        })
        
        if practiceNameArr.count > 1 && editSupplementPOJO == nil
        {
            
            let practiceView = AddModuleKeyAndValueView()
            practiceView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
            practiceView.tag = PRACTICEVIEW_TAG
            practiceView.keyLabel.text = getString(key: "com.charmphr.common.Practice")
            practiceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
            supplementNameGroupView.addSubview(practiceView)
            
            practiceView.setSafeAreaTop(offset: 0)
            practiceView.setLeft(offSet: 0)
            practiceView.setRight(offSet: -0)
            supplementsNameView.setTopRelatedToView(offSet: 0, relatedView: practiceView, relatedAttribute: .bottom)
            
        }else
        {
            supplementsNameView.setSafeAreaTop(offset: 0)
        }
        
        supplementsNameView.setLeft(offSet: 0)
        supplementsNameView.setRight(offSet: 0)
        
        doseView.setTopRelatedToView(offSet: 0, relatedView: supplementsNameView, relatedAttribute: .bottom)
        doseView.setLeft(offSet: 0)
        doseView.setRight(offSet: 0)
        
        doseUnitView.setTopRelatedToView(offSet: 0, relatedView: doseView, relatedAttribute: .bottom)
        doseUnitView.setLeft(offSet: 0)
        doseUnitView.setRight(offSet: 0)
        
        strengthView.setTopRelatedToView(offSet: 0, relatedView: doseUnitView, relatedAttribute: .bottom)
        strengthView.setLeft(offSet: 0)
        strengthView.setRight(offSet: 0)
        
        strengthUnitView.setTopRelatedToView(offSet: 0, relatedView: strengthView, relatedAttribute: .bottom)
        strengthUnitView.setLeft(offSet: 0)
        strengthUnitView.setRight(offSet: 0)
        
        manufacturerView.setTopRelatedToView(offSet: 0, relatedView: strengthUnitView, relatedAttribute: .bottom)
        manufacturerView.setLeft(offSet: 0)
        manufacturerView.setRight(offSet: 0)
        manufacturerView.setBottom(offSet: 0)
        
        frequencyView.setTop(offSet: 0)
        frequencyView.setLeft(offSet: 0)
        frequencyView.setRight(offSet: -0)
        
        whenView.setTopRelatedToView(offSet: 0, relatedView: frequencyView, relatedAttribute: .bottom)
        whenView.setLeft(offSet: 0)
        whenView.setRight(offSet: -0)
        whenView.setBottom(offSet: 0)


        startDateView.setTop(offSet: 0)
        startDateView.setLeft(offSet: 0)
        startDateView.setRight(offSet: 0)
        startDateView.setBottomRelatedToView(offSet: 0, relatedView: stopDateView, relatedAttribute: .top)
        
        stopDateView.setTopRelatedToView(offSet: 0, relatedView: startDateView, relatedAttribute: .bottom)
        stopDateView.setLeft(offSet: 0)
        stopDateView.setRight(offSet: 0)
        
        commentView.setTopRelatedToView(offSet: 0, relatedView: stopDateView, relatedAttribute: .bottom)
        commentView.setLeft(offSet: 0)
        commentView.setRight(offSet: 0)
        commentView.setBottom(offSet: 0)
        
        supplementNameGroupView.setTop(offSet: Y_SPACE)
        supplementNameGroupView.setHorizontal(offSet: X_SPACE)
        
        frequencyGroupView.setTopRelatedToView(offSet: 20, relatedView: supplementNameGroupView, relatedAttribute: .bottom)
        frequencyGroupView.setHorizontal(offSet: X_SPACE)
        
        othersGroupView.setTopRelatedToView(offSet: 20, relatedView: frequencyGroupView, relatedAttribute: .bottom)
        othersGroupView.setHorizontal(offSet: X_SPACE)
        othersGroupView.setBottom(offSet: -Y_SPACE)
        
        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setWidth(constant: applicationFrame.width)
        
        
        containerScrollView.setSafeAreaTop(offset: 0)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[containerScrollView]-X_SPACE-|", options: [], metrics:["X_SPACE":0], views: ["containerScrollView":containerScrollView]))
        containerScrollView.setSafeAreaBottom(offset: 0)
    
    }
        
    //MARK: - action calles
    
    func fetchCommonData()
    {
        if editSupplementPOJO == nil
        {
            if practiceArr.count == 1
            {
                charmConnectionHandeler?.fetchCommonDataForAddSupplement(practiceId: practiceArr.firstOrNil()?.practiceId ?? "", identificationKey: "AddSupplementCommonData")
                showActivityIndicator()
            }else
            {
                if let addAllergiesKeyAndLabelView = self.view.viewWithTag(self.PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
                {
                    if !isNilOrEmpty(string: addAllergiesKeyAndLabelView.valueLabel.text)
                    {
                        charmConnectionHandeler?.fetchCommonDataForAddSupplement( practiceId:practiceArr.getElement(at: addAllergiesKeyAndLabelView.selectedIndex)?.practiceId  ?? "" , identificationKey: "AddSupplementCommonData")
                        self.showActivityIndicator()
                    }
                }
            }
        }else
        {
            charmConnectionHandeler?.fetchCommonDataForAddSupplement( practiceId: editSupplementPOJO?.patientSupplement?.practiceId ?? practiceArr.firstOrNil()?.practiceId ?? "", identificationKey: "AddSupplementCommonData")
            showActivityIndicator()
        }
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
        
    @objc func startDatePickerValueChanged(datePicker : UIDatePicker)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(STARTDATE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
            stopDatePicker.minimumDate = datePicker.date
            
            if let stopDateKeyAndLabelView = self.view.viewWithTag(STOPDATE_VIEW_TAG) as? AddModuleKeyAndValueView
            {
                stopDateKeyAndLabelView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: stopDatePicker.date)
                
                if startDatePicker.date.timeIntervalSince(stopDatePicker.date) > 0
                {
                    stopDatePicker.date = startDatePicker.date
                    stopDateKeyAndLabelView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: stopDatePicker.date)
                    
                }
            }
            
        }
    }
        
    @objc func stopDatePickerValueChanged(datePicker : UIDatePicker)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(STOPDATE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
        }
    }
        
    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
        {
            
            if addAllergiesKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                dismissKeyboard()
                let selectVC = SelectValueViewController()
                navigateToSelectValueVC(vc: selectVC)
                
//                performSegue(withIdentifier: "SelectValueVC", sender: self)
            }
            else
            {
                if isCommonDataFetched
                {
                    if addAllergiesKeyAndLabelView.tag == SUPPLEMENT_NAME_VIEW_TAG || addAllergiesKeyAndLabelView.tag == DOSE_UNIT_VIEW_TAG || addAllergiesKeyAndLabelView.tag == STRENGHT_UNIT_VIEW_TAG || addAllergiesKeyAndLabelView.tag == FREQUENCY_VIEW_TAG || addAllergiesKeyAndLabelView.tag == WHEN_VIEW_TAG || addAllergiesKeyAndLabelView.tag == MANUFACTURER_VIEW_TAG
                    {
                        selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                        dismissKeyboard()
                        let selectVC = SelectValueViewController()
                        navigateToSelectValueVC(vc: selectVC)
                        
//                        performSegue(withIdentifier: "SelectValueVC", sender: self)
                    }
                    else if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
                    {
                        if !addAllergiesKeyAndLabelView.textField.isHidden
                        {
                            addAllergiesKeyAndLabelView.textField.becomeFirstResponder()
                        }
                    }
                }else
                {
                    CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.common.selectPractice"))
                }
            }
        }
    }
    
    func setPractice(selectedIndex : Int)
    {
        if let addAllergiesKeyAndLabelView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.selectedIndex = selectedIndex
            addAllergiesKeyAndLabelView.valueLabel.text = Patient.selectedPatientInstance?.practiceNameArr[selectedIndex]
            fetchCommonData()
        }
    }
        
    func setSupplemntName(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(SUPPLEMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView, let supplementNameDict = supplementNameDict
        {
            addAllergiesKeyAndLabelView.valueLabel.text = supplementNameDict[supplementNameDict.allKeys[selectedRow]] as? String
        }
    }
        
    func setDoseUnit(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(DOSE_UNIT_VIEW_TAG) as? AddModuleKeyAndValueView, let unitWithNameDict = unitWithNameDict
        {
            addAllergiesKeyAndLabelView.valueLabel.text = unitWithNameDict[unitWithNameDict.allKeys[selectedRow]] as? String
        }
    }
        
    func setStrenghtUnit(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(STRENGHT_UNIT_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = sxUnitListArr[selectedRow]
        }
    }
        
    func setFrequency(selectedRow : Int)
    {
        
        if let addAllergiesKeyAndLabelView = view.viewWithTag(FREQUENCY_VIEW_TAG) as? AddModuleKeyAndValueView, let intakeDict = intakeDict
        {
            addAllergiesKeyAndLabelView.valueLabel.text = intakeDict[intakeDict.allKeys[selectedRow]] as? String
        }
    }
        
    func setWhen(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(WHEN_VIEW_TAG) as? AddModuleKeyAndValueView, let intakeWhenDict = intakeWhenDict
        {
            addAllergiesKeyAndLabelView.valueLabel.text = intakeWhenDict[intakeWhenDict.allKeys[selectedRow]] as? String
        }
    }
        
    func setManufracturer(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(MANUFACTURER_VIEW_TAG) as? AddModuleKeyAndValueView, let manufacturerDict = manufacturerDict
        {
            addAllergiesKeyAndLabelView.valueLabel.text = manufacturerDict[manufacturerDict.allKeys[selectedRow]] as? String
        }
    }
    
    func setStartAndStopDate(startDate: Date, stopDate: Date){
        startDatePicker.date = startDate
        startDatePickerValueChanged(datePicker: startDatePicker)
        stopDatePicker.date = stopDate
        stopDatePickerValueChanged(datePicker: stopDatePicker)
    }
        
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
        
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
        
    @objc func doneBtnClicked()
    {
        
        dismissKeyboard()
        
        let practiceNameView = self.view.viewWithTag(PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
        if let supplementsNameView = self.view.viewWithTag(SUPPLEMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView,
        let doseView = self.view.viewWithTag(DOSE_VIEW_TAG) as? AddModuleKeyAndValueView,
        let doseUnitView = self.view.viewWithTag(DOSE_UNIT_VIEW_TAG) as? AddModuleKeyAndValueView,
        let strenghtView = self.view.viewWithTag(STRENGHT_VIEW_TAG) as? AddModuleKeyAndValueView,
        let strenghtUnitView = self.view.viewWithTag(STRENGHT_UNIT_VIEW_TAG) as? AddModuleKeyAndValueView,
        let manufacturerView = self.view.viewWithTag(MANUFACTURER_VIEW_TAG) as? AddModuleKeyAndValueView,
        let frequencyView = self.view.viewWithTag(FREQUENCY_VIEW_TAG) as? AddModuleKeyAndValueView,
        let whenView = self.view.viewWithTag(WHEN_VIEW_TAG) as? AddModuleKeyAndValueView,
        let startDateView = self.view.viewWithTag(STARTDATE_VIEW_TAG) as? AddModuleKeyAndValueView,
           let stopDateView = self.view.viewWithTag(STOPDATE_VIEW_TAG) as? AddModuleKeyAndValueView{
            let commentTf = self.view.viewWithTag(COMMENT_TF_TAG) as? UITextView
            
            if isNilOrEmpty(string: supplementsNameView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: supplementsNameView.keyLabel.text)
            }
            else if isNilOrEmpty(string: practiceNameView?.valueLabel.text) && Patient.selectedPatientInstance?.practiceList.count ?? -1 > 1 && editSupplementPOJO == nil
            {
                showMandatoryAlert(fieldName: practiceNameView?.keyLabel.text)
            }
            else if isNilOrEmpty(string: whenView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: whenView.keyLabel.text)
            }
            else if isNilOrEmpty(string: frequencyView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: frequencyView.keyLabel.text)
            }
            else if isNilOrEmpty(string: startDateView.textField.text)
            {
                showMandatoryAlert(fieldName: startDateView.keyLabel.text)
                startDateView.textField.becomeFirstResponder()
            }
            else if isNilOrEmpty(string: stopDateView.textField.text)
            {
                showMandatoryAlert(fieldName: stopDateView.keyLabel.text)
                stopDateView.textField.becomeFirstResponder()
            }
            else if isNilOrEmpty(string: manufacturerView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: manufacturerView.keyLabel.text)
            }
            //        else if isNilOrEmpty(string: commentTf.text)
            //        {
            //                showMandatoryAlert(fieldName: NSLocalizedString("com.charmphr.add.MedicationAndSupplememnts.Comment.title", comment: ""))
            //                commentTf.becomeFirstResponder()
            //        }
            else
            {
                
                var supplementPOJO = SupplementPOJO()
                
                if let editSupplementPOJO = editSupplementPOJO {
                    supplementPOJO = editSupplementPOJO
                }
                else{
                    let supplement = Supplement()
                    supplement.supplementName = supplementsNameView.valueLabel.text
                    supplement.numberOfIntake = strenghtView.textField.text ?? ""
                    supplement.intakeUnit = strenghtUnitView.valueLabel.text
                    
                    supplementPOJO.supplement = supplement
                }
                if (supplementPOJO.patientSupplement == nil) {
                    
                    let patientSupplement = PatientSupplement()
                    patientSupplement.isAddedByPatient = true
                    supplementPOJO.patientSupplement = patientSupplement
                }
                
                let valueOfDosageUnitArr = unitWithNameDict?.allValues as? Array<String>
                
                
                supplementPOJO.patientSupplement?.fromDate = startDatePicker.date
                supplementPOJO.patientSupplement?.toDate = stopDatePicker.date
                
                supplementPOJO.patientSupplement?.comments = commentTf?.text ?? ""
                
                supplementPOJO.patientSupplement?.intake = frequencyView.valueLabel.text
                supplementPOJO.supplement?.manufacturerName = manufacturerView.valueLabel.text
                supplementPOJO.patientSupplement?.intakeWhen = whenView.valueLabel.text
                supplementPOJO.patientSupplement?.dosageUnitId = unitWithNameDict?.allKeys[valueOfDosageUnitArr?.firstIndex(of: doseUnitView.valueLabel.text ?? "") ?? 0] as? String
                
                supplementPOJO.patientSupplement?.dosageUnit = doseUnitView.valueLabel.text
                supplementPOJO.patientSupplement?.dosage = doseView.textField.text
                                                
                let practiceId = practiceArr.getElement(at: practiceNameView?.selectedIndex ?? 0)?.practiceId ?? ""

                if editSupplementPOJO != nil {
                    charmConnectionHandeler?.editSupplement(supplementPOJO: supplementPOJO, identificationKey: "editSupplement")
                }
                else{
                    addSupplementPOJO = supplementPOJO
                    charmConnectionHandeler?.addSupplement(practiceId: practiceId, supplementPOJO: supplementPOJO, identificationKey: "addSupplement")
                }
                showActivityIndicator()
            }
        }
    }
        
    func showMandatoryAlert(fieldName : String?)
    {
        CharmUtil.createOkayAlertWith(title: nil, msg: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName ?? "")")
        
    }
    
    //MARK: - other Methods
    
    func readIntakeFrequencyJson()
    {
        if let path = Bundle.main.path(forResource: "frequecnyJson", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                     let frequency = jsonResult["frequency"] as? [Dictionary<String, Any>] {
                      let intakeDictionary: MutableOrderedDictionary = [:]
                      for dict in frequency
                      {
                          if (dict["NAME"] as? String != nil){
                              if let frequency = dict.getString("NAME"){
                                  intakeDictionary.setValue(frequency.capitalizingFirstLetter(), forKey: frequency)
                              }
                          }
                      }
                      intakeDict = intakeDictionary
                      
//                    for dict in frequency
//                    {
//                        if (dict["NAME"] as? String != nil)
//                        {
//                            intakeArr.append((dict["NAME"] as? String ?? "").capitalizingFirstLetter())
//                        }
//                    }
                    
                    if let strengthUnitList = jsonResult["unit"] as? Array<String> {
                        sxUnitListArr = strengthUnitList
                    }
                  }
                
              } catch {
                   // handle error
              }
        }
    }
        
    //MARK: - charmconnection handler deletage
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "AddSupplementCommonData"{
            if let jsonObject = response as? Dictionary<String, Any> {
                isCommonDataFetched = true
                if let outputDict = jsonObject["output_string"] as? Dictionary<String,Any>
                {
                  //  sxUnitListArr = outputDict["SXUNIT_LIST"] as! Array<String>
                    if let unitIdVSname = outputDict["UNITIDVSNAME"] as? Dictionary<String,Any>{
                        unitWithNameDict = MutableOrderedDictionary(dictionary: unitIdVSname)
                    }
                    if let routeList = outputDict["ROUTE_LIST"] as? Array<String>{
                        routeListArr = routeList
                    }
                  //  intakeDict = MutableOrderedDictionary(dictionary: outputDict["INTAKE_LIST"] as! Dictionary<String,Any>)
                    if let intakeWhenList = outputDict["INTAKE_WHEN_LIST"] as? Dictionary<String,Any>{
                        intakeWhenDict = MutableOrderedDictionary(dictionary: intakeWhenList)
                    }
                    
                    if let supplememntNameDictArr = outputDict["SEARCH_STRING"] as? Array<Dictionary<String,Any>>{
                        supplementNameDict = MutableOrderedDictionary()
                        for drugDict in supplememntNameDictArr
                        {
                            supplementNameDict?.setValue(drugDict["name"] as? String, forKey: "\(drugDict["id"] ?? 0)")
                        }
                    }
                    if let manufacturerDictArr = outputDict["MANUIDVSNAME"] as? Array<Dictionary<String,Any>>{
                        manufacturerDict = MutableOrderedDictionary()
                        for manufacturer in manufacturerDictArr
                        {
                            manufacturerDict?.setValue(manufacturer["name"] as? String, forKey: "\(manufacturer["id"] ?? 0)")
                        }
                    }
                    
                    if let editSupplementPOJO = editSupplementPOJO
                    {
                        if let supplementsNameView = self.view.viewWithTag(SUPPLEMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView,
                        let doseView = self.view.viewWithTag(DOSE_VIEW_TAG) as? AddModuleKeyAndValueView,
                        let strenghtView = self.view.viewWithTag(STRENGHT_VIEW_TAG) as? AddModuleKeyAndValueView,
                        let frequencyView = self.view.viewWithTag(FREQUENCY_VIEW_TAG) as? AddModuleKeyAndValueView,
                        let whenView = self.view.viewWithTag(WHEN_VIEW_TAG) as? AddModuleKeyAndValueView,
                        let manufacturerView = self.view.viewWithTag(MANUFACTURER_VIEW_TAG) as? AddModuleKeyAndValueView,
                        let commentView = self.view.viewWithTag(COMMENT_TF_TAG) as? UITextView{
                            
                            supplementsNameView.valueLabel.text = editSupplementPOJO.supplement?.supplementName
                            supplementsNameView.setViewDisabled()
                            
                            if let patientSupplement = editSupplementPOJO.patientSupplement, let supplement = editSupplementPOJO.supplement{
                                
                                let keysOfDosageUnitArr = unitWithNameDict?.allKeys as? Array<String>
                                if let index = keysOfDosageUnitArr?.firstIndex(of: "\(patientSupplement.dosageUnitId ?? "")")
                                {
                                    setDoseUnit(selectedRow: index)
                                }
                                
                                if let noOfIntake = supplement.numberOfIntake
                                {
                                    strenghtView.textField.text = noOfIntake
                                }
                                
                                doseView.textField.text = patientSupplement.dosage
                                
                                if let index = sxUnitListArr.firstIndex(of: supplement.intakeUnit ?? "")
                                {
                                    setStrenghtUnit(selectedRow: index)
                                }
                                
                                if let keysOfManufactrerArr = manufacturerDict?.allKeys as? Array<String>{
                                    if let index = keysOfManufactrerArr.firstIndex(of: supplement.manufacturerId ?? "")
                                    {
                                        setManufracturer(selectedRow: index)
                                        manufacturerView.setViewDisabled()
                                    }
                                }
                                let keysOfIntakeArr = intakeDict?.allKeys as? Array<String>
                                if let index = keysOfIntakeArr?.firstIndex(of: patientSupplement.intake ?? "")
                                {
                                    setFrequency(selectedRow: index)
                                }
                                
                                frequencyView.valueLabel.text = patientSupplement.intake
                                whenView.valueLabel.text = patientSupplement.intakeWhen
                                setStartAndStopDate(startDate: patientSupplement.fromDate ?? Date(), stopDate: patientSupplement.toDate ?? Date())
                                commentView.text = patientSupplement.comments
                            }
                        }
                    }else
                    {
                        setDoseUnit(selectedRow: 0)
                        setStrenghtUnit(selectedRow: 0)
                        setFrequency(selectedRow: 0)
                        setWhen(selectedRow: 0)
                        setStartAndStopDate(startDate: Date(), stopDate: Date())
                    }
                    hideActivityIndicator()
                }
            }
        }
        else if identificationKey == "addSupplement" || identificationKey == "editSupplement"{
            AppDataHandler.sharedInstance().refreshMedication = true

            if(delegate is PrescriptionsViewController){
                navigationController?.popViewController(animated: true)
                
                if identificationKey == "addSupplement", let addSupplementPOJO = addSupplementPOJO, let supplementObj = (response as? [String: Any])?.getAsJsonObject("output_string"){
                    
                    addSupplementPOJO.patientSupplement?.patientSupplementId =
                    supplementObj.getString("SUPPLEMENT_HISTORY_ID")
                    addSupplementPOJO.supplement?.supplementId = supplementObj.getString("SUPPLEMENT_ID")
                    
                    PatientDataHandler.addSupplement(supplementPOJO: addSupplementPOJO, patientId: getSelectedPatientId())
                    addReminderAlertDelegate?.showAddReminderAlert(transformModel: TransformUtil.transformSupplementToReminderModel(supplementPOJO: addSupplementPOJO))
                }
                if let resp = response as? [String: Any]{
                    if identificationKey == "addSupplement"{
                        delegate?.addViewControllerDataAdded(message: nil)
                    }
                    else{
                        delegate?.addViewControllerDataAdded(message: resp.getString("message"))
                    }
                }
                else{
                    delegate?.addViewControllerDataAdded(message: nil)
                }
            }
           
        }
        
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        if identificationKey == "addSupplement"{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
        else if identificationKey == "editSupplement"{
           
            CharmUtil.createOkayAlertWith(error: error)
        }
        else if identificationKey == "AddSupplementCommonData"{
            charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
        
    }
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "AddSupplementCommonData"
        {
            isCommonDataFetched = true
            if let outputDict = jsonObject["output_string"] as? Dictionary<String,Any>
            {
              //  sxUnitListArr = outputDict["SXUNIT_LIST"] as! Array<String>
                if let unitIdVSname = outputDict["UNITIDVSNAME"] as? Dictionary<String,Any>{
                    unitWithNameDict = MutableOrderedDictionary(dictionary: unitIdVSname)
                }
                if let routeList = outputDict["ROUTE_LIST"] as? Array<String>{
                    routeListArr = routeList
                }
              //  intakeDict = MutableOrderedDictionary(dictionary: outputDict["INTAKE_LIST"] as! Dictionary<String,Any>)
                if let intakeWhenList = outputDict["INTAKE_WHEN_LIST"] as? Dictionary<String,Any>{
                    intakeWhenDict = MutableOrderedDictionary(dictionary: intakeWhenList)
                }
                
                if let supplememntNameDictArr = outputDict["SEARCH_STRING"] as? Array<Dictionary<String,Any>>{
                    supplementNameDict = MutableOrderedDictionary()
                    for drugDict in supplememntNameDictArr
                    {
                        supplementNameDict?.setValue(drugDict["name"] as? String, forKey: "\(drugDict["id"] ?? 0)")
                    }
                }
                
                if let manufacturerDictArr = outputDict["MANUIDVSNAME"] as? Array<Dictionary<String,Any>>{
                    manufacturerDict = MutableOrderedDictionary()
                    for manufacturer in manufacturerDictArr
                    {
                        manufacturerDict?.setValue(manufacturer["name"] as? String, forKey: "\(manufacturer["id"] ?? 0)")
                    }
                }
                
                if let editSupplementPOJO = editSupplementPOJO{
                    if let supplementsNameView = self.view.viewWithTag(SUPPLEMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let doseView = self.view.viewWithTag(DOSE_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let strenghtView = self.view.viewWithTag(STRENGHT_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let frequencyView = self.view.viewWithTag(FREQUENCY_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let whenView = self.view.viewWithTag(WHEN_VIEW_TAG) as? AddModuleKeyAndValueView,
                       let commentView = self.view.viewWithTag(COMMENT_TF_TAG) as? UITextView{
                        
                        supplementsNameView.valueLabel.text = editSupplementPOJO.supplement?.supplementName
                        supplementsNameView.setViewDisabled()
                        
                        if let patientSupplement = editSupplementPOJO.patientSupplement, let supplement = editSupplementPOJO.supplement{
                            
                            let keysOfDosageUnitArr = unitWithNameDict?.allKeys as? Array<String>
                            if let index = keysOfDosageUnitArr?.firstIndex(of: "\(patientSupplement.dosageUnitId ?? "")")
                            {
                                setDoseUnit(selectedRow: index)
                            }
                            
                            if let noOfIntake = supplement.numberOfIntake
                            {
                                strenghtView.textField.text = noOfIntake
                            }
                            
                            doseView.textField.text = patientSupplement.dosage
                            
                            if let index = sxUnitListArr.firstIndex(of: supplement.intakeUnit ?? "")
                            {
                                setStrenghtUnit(selectedRow: index)
                            }
                            
                            
                            if let keysOfManufactrerArr = manufacturerDict?.allKeys as? Array<String>{
                                if let index = keysOfManufactrerArr.firstIndex(of: supplement.manufacturerId ?? "")
                                {
                                    setManufracturer(selectedRow: index)
                                }
                            }
                            let keysOfIntakeArr = intakeDict?.allKeys as? Array<String>
                            if let index = keysOfIntakeArr?.firstIndex(of: patientSupplement.intake ?? "")
                            {
                                setFrequency(selectedRow: index)
                            }
                            
                            frequencyView.valueLabel.text = patientSupplement.intake
                            whenView.valueLabel.text = patientSupplement.intakeWhen
                            startDatePicker.date = patientSupplement.fromDate ?? Date()
                            startDatePickerValueChanged(datePicker: startDatePicker)
                            stopDatePicker.date = patientSupplement.toDate ?? Date()
                            stopDatePickerValueChanged(datePicker: stopDatePicker)
                            commentView.text = patientSupplement.comments
                        }
                    }
                }
                else{
                    setDoseUnit(selectedRow: 0)
                    setStrenghtUnit(selectedRow: 0)
                    setFrequency(selectedRow: 0)
                    setWhen(selectedRow: 0)
                }
                hideActivityIndicator()
            }
        }
    }
            
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "AddSupplementCommonData"{
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.fetchCommonData()
            } cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
        
    }
            
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        
        if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView{
            if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                setPractice(selectedIndex: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == SUPPLEMENT_NAME_VIEW_TAG
            {
                setSupplemntName(selectedRow: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == DOSE_UNIT_VIEW_TAG
            {
                setDoseUnit(selectedRow: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == STRENGHT_UNIT_VIEW_TAG
            {
                setStrenghtUnit(selectedRow: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == FREQUENCY_VIEW_TAG
            {
                setFrequency(selectedRow: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == WHEN_VIEW_TAG
            {
                setWhen(selectedRow: selectedRow)
            }
            else if selectedAddModuleKeyAndLabelView.tag == MANUFACTURER_VIEW_TAG
            {
                setManufracturer(selectedRow: selectedRow)
            }
        }
    }
    
    func selectValueViewControllerDidSelectCustomString(customString: String) {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(SUPPLEMENT_NAME_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = customString
        }
    }
    
    func navigateToSelectValueVC(vc: SelectValueViewController){
        vc.delegate = self
        if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView
        {
            vc.title = selectedAddModuleKeyAndLabelView.keyLabel.text
            
            if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                vc.arrayOfValueToBeShown = practiceNameArr
                if !selectedAddModuleKeyAndLabelView.valueLabel.text.isNilOrBlank() {
                    vc.selectedValueIndex = selectedAddModuleKeyAndLabelView.selectedIndex
                }
            }
            else if selectedAddModuleKeyAndLabelView.tag == SUPPLEMENT_NAME_VIEW_TAG
            {
                vc.valueDelegate = self
                vc.isSearchBarNeeded = true
                vc.addSearchTextAsValue = true
                vc.arrayOfValueToBeShown = supplementNameDict?.allValues as? Array<String> ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == DOSE_UNIT_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = unitWithNameDict?.allValues as? Array<String> ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == STRENGHT_UNIT_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = sxUnitListArr
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == FREQUENCY_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = intakeDict?.allValues as! [String]
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == WHEN_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = intakeWhenDict?.allValues as? [String] ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == MANUFACTURER_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = manufacturerDict?.allValues as? Array<String> ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    //MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "SelectValueVC"
        {
            
            let vc = segue.destination as? SelectValueViewController
            if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView
            {
                vc?.title = selectedAddModuleKeyAndLabelView.keyLabel.text
                vc?.delegate = self
                
                if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = practiceNameArr
                    if !selectedAddModuleKeyAndLabelView.valueLabel.text.isNilOrBlank() {
                        vc?.selectedValueIndex = selectedAddModuleKeyAndLabelView.selectedIndex
                    }
                }
                else if selectedAddModuleKeyAndLabelView.tag == SUPPLEMENT_NAME_VIEW_TAG
                {
                    vc?.valueDelegate = self
                    vc?.isSearchBarNeeded = true
                    vc?.addSearchTextAsValue = true
                    vc?.arrayOfValueToBeShown = supplementNameDict?.allValues as? Array<String> ?? [String]()
                    vc?.selectedValueIndex = vc?.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
                else if selectedAddModuleKeyAndLabelView.tag == DOSE_UNIT_VIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = unitWithNameDict?.allValues as? Array<String> ?? [String]()
                    vc?.selectedValueIndex = vc?.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
                else if selectedAddModuleKeyAndLabelView.tag == STRENGHT_UNIT_VIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = sxUnitListArr
                    vc?.selectedValueIndex = vc?.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
                else if selectedAddModuleKeyAndLabelView.tag == FREQUENCY_VIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = intakeDict?.allValues as! [String]
                    vc?.selectedValueIndex = vc?.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
                else if selectedAddModuleKeyAndLabelView.tag == WHEN_VIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = intakeWhenDict?.allValues as? [String] ?? [String]()
                    vc?.selectedValueIndex = vc?.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
                else if selectedAddModuleKeyAndLabelView.tag == MANUFACTURER_VIEW_TAG
                {
                    vc?.arrayOfValueToBeShown = manufacturerDict?.allValues as? Array<String> ?? [String]()
                    vc?.selectedValueIndex = vc?.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
                }
            }
        }
    }
    
    @objc override func onBackClick(){
        if editSupplementPOJO == nil {
            if checkDataIsAvailable(){
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if checkDataIsEditted() {
                showDiscardChangesDialog()
                return
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func getTextView(tag:Int) -> UITextView {
        if let textview =  self.view.viewWithTag(tag) as? UITextView{
            return textview
        }
        return UITextView()
    }
    
    private func getKeyValueView(tag:Int) -> AddModuleKeyAndValueView {
        if let textview =  self.view.viewWithTag(tag) as? AddModuleKeyAndValueView{
            return textview
        }
        return AddModuleKeyAndValueView()
    }
    
    private func checkDataIsAvailable() -> Bool {
  
        if !routeListArr.isEmpty{
            
            if !getKeyValueView(tag: SUPPLEMENT_NAME_VIEW_TAG).valueLabel.text.isNilOrBlank() {
                return true
            }
            if !getKeyValueView(tag: STRENGHT_VIEW_TAG).textField.text.isNilOrBlank() {
                return true
            }
            if getKeyValueView(tag: STRENGHT_UNIT_VIEW_TAG).valueLabel.text != sxUnitListArr.getElement(at: 0)  {
                return true
            }
            if !getKeyValueView(tag: DOSE_VIEW_TAG).textField.text.isNilOrBlank() {
                return true
            }
            if getKeyValueView(tag: DOSE_UNIT_VIEW_TAG).valueLabel.text != unitWithNameDict?.allValues.getElement(at: 0) as? String ?? "" {
                
                return true
            }
            if getKeyValueView(tag: FREQUENCY_VIEW_TAG).valueLabel.text != intakeDict?.allValues.getElement(at: 0) as? String ?? "" {
                
                return true
            }
            if getKeyValueView(tag: WHEN_VIEW_TAG).valueLabel.text != intakeWhenDict?.allValues.getElement(at: 0) as? String ?? "" {
                
                return true
            }
            
            if !getKeyValueView(tag: MANUFACTURER_VIEW_TAG).valueLabel.text.isNilOrBlank()  {
                return true
            }
            
            if getKeyValueView(tag: STARTDATE_VIEW_TAG).textField.text != CharmUtil.getDisplayDateStringWithYear(date: Date()) {
                return true
            }
            
            if getKeyValueView(tag: STOPDATE_VIEW_TAG).textField.text != CharmUtil.getDisplayDateStringWithYear(date: Date()) {
                return true
            }
            
            if !getTextView(tag: COMMENT_TF_TAG).text.isNilOrBlank()  {
                return true
            }
        }
        
        return false
    }
    
    private func checkDataIsEditted() -> Bool {
        
        if !routeListArr.isEmpty{
            
            if let supplement = editSupplementPOJO?.supplement , let patientSupplement = editSupplementPOJO?.patientSupplement{
                
                if getKeyValueView(tag: STRENGHT_VIEW_TAG).textField.text != supplement.numberOfIntake {
                    return true
                }
                
                if getKeyValueView(tag: STRENGHT_UNIT_VIEW_TAG).valueLabel.text != supplement.intakeUnit  {
                    return true
                }
                
                if getKeyValueView(tag: DOSE_VIEW_TAG).textField.text != patientSupplement.dosage  {
                    return true
                }
                
                if getKeyValueView(tag: DOSE_UNIT_VIEW_TAG).valueLabel.text != patientSupplement.dosageUnit  {
                    return true
                }
                
                if getKeyValueView(tag: FREQUENCY_VIEW_TAG).valueLabel.text != patientSupplement.intake {
                    
                    return true
                }
                if getKeyValueView(tag: WHEN_VIEW_TAG).valueLabel.text != patientSupplement.intakeWhen {
                    
                    return true
                }
                
                if getKeyValueView(tag: MANUFACTURER_VIEW_TAG).valueLabel.text != supplement.manufacturerName {
                    
                    return true
                }
                
                if getKeyValueView(tag: STARTDATE_VIEW_TAG).textField.text != CharmUtil.getDisplayDateStringWithYear(date: patientSupplement.fromDate ?? Date()) {
                    return true
                }
                
                if getKeyValueView(tag: STOPDATE_VIEW_TAG).textField.text != CharmUtil.getDisplayDateStringWithYear(date: patientSupplement.toDate ?? Date()) {
                    return true
                }
                
                if getTextView(tag: COMMENT_TF_TAG ).text != patientSupplement.comments {
                    return true
                }
                
            }
            
        }
        

        
        return false
    }

    func mdTextField(_ textField: MDTextField!, shouldChangeCharactersIn range: NSRange, replacementString string: String!) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: r, with: string)
        
        let isNumeric = newText.isEmpty || (Double(newText) != nil)

        debugPrintLog("TEXTFIELDCALLED -> \(newText)")
        
        var isSuccess = true
        
        if textField.keyboardType == .decimalPad {
            
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            
            let numberOfDecimalDigits: Int
            let numberOfWholeDigits:Int
            if let dotIndex = newText.firstIndex(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
                numberOfWholeDigits = newText.distance(from: newText.startIndex, to: dotIndex) - 1

            } else {
                numberOfDecimalDigits = 0
                numberOfWholeDigits = newText.count
            }
            
             isSuccess = isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 3 && numberOfWholeDigits <= 10
        }
        else if textField.keyboardType == .numberPad {
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            isSuccess = isNumeric && newText.count <= 10 && numberOfDots == 0
        }
        
        return isSuccess
    }

}
