//
//  AddMedicationViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 05/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

//TODO: want to add layers
//TODO: want to check for option values diff in wed and diff in api
//TODO: want to find a way to show the dictonary of value in a orderwed form
//TODO: want to check for resone for taking is wanted while editing medication
class AddMedicationViewController: AddDataUIViewController, SelectValueViewControllerValueDelagate, CharmConnectionHandlerDelegate, SelectValueViewControllerDelagate, UITextViewDelegate, MDTextFieldDelegate, UITextFieldDelegate, CharmConnectionV2HandlerDelegate
{
    let DRUGNAME_VIEW_TAG = 1000
    let DOSE_VIEW_TAG = 1001
    let DOSE_UNIT_VIEW_TAG = 1002
    let STRENGHT_VIEW_TAG = 1003
    let STRENGHT_UNIT_VIEW_TAG = 1004
    let FREQUENCY_VIEW_TAG = 1005
    let WHEN_VIEW_TAG = 1006
    let HOWTOTAKE_VIEW_TAG = 1007
    let STARTDATE_VIEW_TAG = 1008
    let STOPDATE_VIEW_TAG = 1009
    let RESONEFORTAKING_VIEW_TAG = 1010
    let PRESCRIBED_VIEW_TAG = 1011
    let REFILL_VIEW_TAG = 1012
    let COMMENT_TF_TAG = 1023
    let COMMENT_VIEW_TAG = 1013
    
    let PRACTICEVIEW_TAG = 1014
    
    let activityIndicator = UIActivityIndicatorView()
    
    var charmConnectionHandeler : CharmConnectionHandler?
    
    var isCommonDataFetched = false
    
    var rxUnitListArr : Array<String> = []
    var resoneForTakingDict : MutableOrderedDictionary?
    var drugNameDict : MutableOrderedDictionary?
    var unitWithNameDict : MutableOrderedDictionary?
    var routeListArr : [String] = []
    var intakeDict : MutableOrderedDictionary?
    var intakeWhenDict : MutableOrderedDictionary?
    var providerList : Array<String> = []
    
    var selectedAddModuleKeyAndLabelView : AddModuleKeyAndValueView?
    
    let startDatePicker = UIDatePicker()
    let stopDatePicker = UIDatePicker()
    
    var editMedicationPOJO : MedicationPOJO?
    var addMedicationPOJO: MedicationPOJO?
    weak var delegate : AddViewControllerDelegate?
    weak var addReminderAlertDelegate: AddReminderAlertDelegate? = nil
    var isHealthPassport : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        if isHealthPassport
        {
            self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        }else
        {
            self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        createSubViews()
        readLocalPrescriptionJson()
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        
        charmConnectionHandeler = CharmConnectionHandler(delegate: self)
        charmConnectionHandeler?.v2Delegate = self
        
        if editMedicationPOJO == nil
        {
            self.navigationItem.title = getString(key: "com.charmphr.add.MedicationAndSupplememnts.AddMedications.title")
        }else
        {
            self.navigationItem.title = getString(key: "com.charmphr.add.MedicationAndSupplememnts.EditMedications.title")
        }
        fetchCommonData()
    }
    
    func createSubViews()
    {
        
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let drugNameGroupView = UIView()
        
        containerView.addSubview(drugNameGroupView)
        drugNameGroupView.addShadowAndCornerRadius(.SMALL)
        
        let drugNameView = AddModuleKeyAndValueView()
        drugNameView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        drugNameView.tag = DRUGNAME_VIEW_TAG
        drugNameView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.drugName.title")
//        drugNameView.textField.placeholder = NSLocalizedString("com.charmphr.add.MedicationAndSupplememnts.drugName.placeHolder", comment: "")
        drugNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        drugNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        drugNameGroupView.addSubview(drugNameView)
        
        let doseView = AddModuleKeyAndValueView()
        doseView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        doseView.tag = DOSE_VIEW_TAG
        doseView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.dose.title")
        doseView.setPlaceholderForTextField(text: getString(key: "com.charmphr.add.MedicationAndSupplememnts.dose.placeHolder"))
        doseView.textField.keyboardType = .decimalPad
        doseView.textField.delegate = self
        doseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        doseView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        drugNameGroupView.addSubview(doseView)
        
        let doseUnitView = AddModuleKeyAndValueView()
        doseUnitView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        doseUnitView.tag = DOSE_UNIT_VIEW_TAG
        doseUnitView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.doseUnit.title")
        doseUnitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        doseUnitView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        drugNameGroupView.addSubview(doseUnitView)
        
        let strengthView = AddModuleKeyAndValueView()
        strengthView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        strengthView.tag = STRENGHT_VIEW_TAG
        strengthView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Strength.title")
        strengthView.setPlaceholderForTextField(text: getString(key: "com.charmphr.add.MedicationAndSupplememnts.Strength.placeHoldeer"))
        strengthView.textField.maxLength = 7
        strengthView.textField.keyboardType = .numberPad
        strengthView.textField.textFieldType = MDTextFieldTypeInteger
        strengthView.textField.delegate = self
        strengthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        strengthView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        drugNameGroupView.addSubview(strengthView)
        
        let strengthUnitView = AddModuleKeyAndValueView()
        strengthUnitView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        strengthUnitView.tag = STRENGHT_UNIT_VIEW_TAG
        strengthUnitView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.StrengthUnit.title")
        strengthUnitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
//        strengthUnitView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        drugNameGroupView.addSubview(strengthUnitView)
        
        
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
        whenView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        frequencyGroupView.addSubview(whenView)
        
        let howToTakeView = AddModuleKeyAndValueView()
        howToTakeView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        howToTakeView.tag = HOWTOTAKE_VIEW_TAG
        howToTakeView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.HowtoTake.title")
        howToTakeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
//        howToTakeView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        frequencyGroupView.addSubview(howToTakeView)
        
        startDatePicker.preferredDatePickerStyle = .wheels
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(startDatePickerValueChanged(datePicker:)), for: .valueChanged)
        
        stopDatePicker.preferredDatePickerStyle = .wheels
        stopDatePicker.datePickerMode = .date
        stopDatePicker.addTarget(self, action: #selector(stopDatePickerValueChanged(datePicker:)), for: .valueChanged)
        
        
        let dateGroupView = UIView()
        containerView.addSubview(dateGroupView)
        dateGroupView.addShadowAndCornerRadius(.SMALL)

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
        dateGroupView.addSubview(startDateView)
        
//        startDatePicker.date = Date()
//        startDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: startDatePicker.date)
        
        let stopDateView = AddModuleKeyAndValueView(isDateField: true)
        stopDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        stopDateView.tag = STOPDATE_VIEW_TAG
        stopDateView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.EndDate.title")
        stopDateView.textField.tintColor = .clear
        stopDateView.textField.inputView = stopDatePicker
        
        stopDateView.setPlaceholderForTextField(text: getString(key: "com.charmphr.common.dateField.placeholder"))
        stopDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        dateGroupView.addSubview(stopDateView)
        
//        stopDatePicker.date = Date()
//        stopDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: stopDatePicker.date)
        
        
        let othersGroupView = UIView()
        containerView.addSubview(othersGroupView)
        othersGroupView.addShadowAndCornerRadius(.SMALL)

        let reasonforTakingView = AddModuleKeyAndValueView()
        reasonforTakingView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        reasonforTakingView.tag = RESONEFORTAKING_VIEW_TAG
        reasonforTakingView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.ReasonforTaking.title")
        reasonforTakingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        reasonforTakingView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        othersGroupView.addSubview(reasonforTakingView)
        
        let prescribedByView = AddModuleKeyAndValueView()
        prescribedByView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        prescribedByView.tag = PRESCRIBED_VIEW_TAG
        prescribedByView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Prescribedby.title")
        prescribedByView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        prescribedByView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        othersGroupView.addSubview(prescribedByView)
        
        let refillsView = AddModuleKeyAndValueView()
        refillsView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        refillsView.tag = REFILL_VIEW_TAG
        refillsView.keyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Refills.title")
        refillsView.textField.delegate = self
        refillsView.textField.textFieldType = MDTextFieldTypeInteger
        refillsView.textField.maxLength = 2
        refillsView.textField.keyboardType = .numberPad
        refillsView.setPlaceholderForTextField(text: getString(key: "com.charmphr.supplements.refill.placeHolder"))
        refillsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        refillsView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        othersGroupView.addSubview(refillsView)
        
        let commentView = AddModuleKeyAndValueWithTextView()
        commentView.KeyLabel.text = getString(key: "com.charmphr.add.MedicationAndSupplememnts.Comment.title")
        commentView.textView.tag = COMMENT_TF_TAG
        commentView.textView.maxLength = 255
        commentView.textView.delegate = self
        othersGroupView.addSubview(commentView)
        
        if Patient.selectedPatientInstance?.practiceList.count ?? -1 > 1 && editMedicationPOJO == nil && isHealthPassport == false
        {
            let practiceView = AddModuleKeyAndValueView()
            practiceView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
            practiceView.tag = PRACTICEVIEW_TAG
            practiceView.keyLabel.text = getString(key: "com.charmphr.common.Practice")
            practiceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
            practiceView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            drugNameGroupView.addSubview(practiceView)
            
            practiceView.setSafeAreaTop(offset: 0)
            practiceView.setLeft(offSet: 0)
            practiceView.setRight(offSet: 0)
            
            drugNameView.setTopRelatedToView(offSet: 0, relatedView: practiceView, relatedAttribute: .bottom)
            
        }else
        {
            drugNameView.setSafeAreaTop(offset: 0)
        }
        
        drugNameGroupView.setTop(offSet: Y_SPACE)
        drugNameGroupView.setHorizontal(offSet: X_SPACE)
        
        frequencyGroupView.setTopRelatedToView(offSet: 20, relatedView: drugNameGroupView, relatedAttribute: .bottom)
        frequencyGroupView.setHorizontal(offSet: X_SPACE)
        
        dateGroupView.setTopRelatedToView(offSet: 20, relatedView: frequencyGroupView, relatedAttribute: .bottom)
        dateGroupView.setHorizontal(offSet: X_SPACE)
        
        othersGroupView.setTopRelatedToView(offSet: 20, relatedView: dateGroupView, relatedAttribute: .bottom)
        othersGroupView.setHorizontal(offSet: X_SPACE)
        othersGroupView.setBottom(offSet: -Y_SPACE)
        
        
        drugNameView.setLeft(offSet: 0)
        drugNameView.setRight(offSet: 0)
        
        doseView.setTopRelatedToView(offSet: 0, relatedView: drugNameView, relatedAttribute: .bottom)
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
        strengthUnitView.setBottom(offSet: 0)
        
        
        frequencyView.setTop(offSet: 0)
        frequencyView.setLeft(offSet: 0)
        frequencyView.setRight(offSet: 0)
        
        whenView.setTopRelatedToView(offSet: 0, relatedView: frequencyView, relatedAttribute: .bottom)
        whenView.setLeft(offSet: 0)
        whenView.setRight(offSet: 0)
        
        howToTakeView.setTopRelatedToView(offSet: 0, relatedView: whenView, relatedAttribute: .bottom)
        howToTakeView.setLeft(offSet: 0)
        howToTakeView.setRight(offSet: 0)
        howToTakeView.setBottom(offSet: 0)

        
        startDateView.setTop(offSet: 0)
        startDateView.setLeft(offSet: 0)
        startDateView.setRight(offSet: 0)
        
        stopDateView.setTopRelatedToView(offSet: 0, relatedView: startDateView, relatedAttribute: .bottom)
        stopDateView.setLeft(offSet: 0)
        stopDateView.setRight(offSet: 0)
        stopDateView.setBottom(offSet: 0)
        

        reasonforTakingView.setTop(offSet: 0)
        reasonforTakingView.setLeft(offSet: 0)
        reasonforTakingView.setRight(offSet: 0)
        
        prescribedByView.setTopRelatedToView(offSet: 0, relatedView: reasonforTakingView, relatedAttribute: .bottom)
        prescribedByView.setLeft(offSet: 0)
        prescribedByView.setRight(offSet: 0)
        
        refillsView.setTopRelatedToView(offSet: 0, relatedView: prescribedByView, relatedAttribute: .bottom)
        refillsView.setLeft(offSet: 0)
        refillsView.setRight(offSet: 0)
        
        commentView.setTopRelatedToView(offSet: 0, relatedView: refillsView, relatedAttribute: .bottom)
        commentView.setLeft(offSet: 0)
        commentView.setRight(offSet: 0)
        commentView.setBottom(offSet: 0)
        
        

        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        // Content follows the visible width (fold/unfold, rotation, iOS 27.1 landscape side bar), so it only scrolls vertically.
        containerView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor).isActive = true
         
        
        containerScrollView.setSafeAreaTop(offset: 0)
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        containerScrollView.setSafeAreaBottom(offset: -0)
        
    }
    
    func fetchCommonData()
    {
        if editMedicationPOJO == nil
        {
            if Patient.selectedPatientInstance?.practiceList.count == 1
            {
                charmConnectionHandeler?.fetchCommonDataForAddMedication(practiceId: Patient.selectedPatientInstance?.practiceList[0].practiceId ?? "", isHealthCard: isHealthPassport, identificationKey: "AddMedicationCommonData")
                showActivityIndicator()
            }else
            {
                if let addAllergiesKeyAndLabelView = self.view.viewWithTag(self.PRACTICEVIEW_TAG) as? AddModuleKeyAndValueView
                {
                    if !isNilOrEmpty(string: addAllergiesKeyAndLabelView.valueLabel.text)
                    {
                        self.charmConnectionHandeler?.fetchCommonDataForAddMedication(practiceId: Patient.selectedPatientInstance?.practiceList[Patient.selectedPatientInstance?.practiceNameArr.firstIndex(of: addAllergiesKeyAndLabelView.valueLabel.text ?? "") ?? 0].practiceId ?? "", isHealthCard: false, identificationKey: "AddMedicationCommonData")
                        self.showActivityIndicator()
                    }
                }
            }
        }else
        {
            charmConnectionHandeler?.fetchCommonDataForAddMedication(practiceId: editMedicationPOJO?.patientMedication?.practiceId ?? "", isHealthCard: isHealthPassport, identificationKey: "AddMedicationCommonData")
            showActivityIndicator()
        }
    }
    
    //MARK: - action calles
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
            
//            debugPrintLog("Start Date -> \(CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)) ; Stop Date -> \(CharmUtil.getDisplayDateStringWithYear(date: stopDatePicker.date))")
//
//            debugPrintLog("Time interval since \(startDatePicker.date.timeIntervalSince(stopDatePicker.date))")
            
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
                navigateToSelectValueVC()
            }else
            {
                if isCommonDataFetched
                {
                    if addAllergiesKeyAndLabelView.tag == DRUGNAME_VIEW_TAG || addAllergiesKeyAndLabelView.tag == DOSE_UNIT_VIEW_TAG || addAllergiesKeyAndLabelView.tag == STRENGHT_UNIT_VIEW_TAG || addAllergiesKeyAndLabelView.tag == FREQUENCY_VIEW_TAG || addAllergiesKeyAndLabelView.tag == WHEN_VIEW_TAG || addAllergiesKeyAndLabelView.tag == HOWTOTAKE_VIEW_TAG || addAllergiesKeyAndLabelView.tag == RESONEFORTAKING_VIEW_TAG || addAllergiesKeyAndLabelView.tag == PRESCRIBED_VIEW_TAG
                    {
                        selectedAddModuleKeyAndLabelView = addAllergiesKeyAndLabelView
                        dismissKeyboard()
                        navigateToSelectValueVC()
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
    
    func readLocalPrescriptionJson()
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
                      if let routeList = jsonResult["route"] as? Array<String> {
                          routeListArr = routeList
                      }
                      
                      if let unitList = jsonResult["unit"] as? Array<String> {
                          rxUnitListArr = unitList
                      }
                  }
              } catch {
                   // handle error
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
    
    func setDrugName(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(DRUGNAME_VIEW_TAG) as? AddModuleKeyAndValueView, let drugNameDict = drugNameDict
        {
            addAllergiesKeyAndLabelView.valueLabel.text = drugNameDict[drugNameDict.allKeys[selectedRow]] as? String
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
            addAllergiesKeyAndLabelView.valueLabel.text = rxUnitListArr[selectedRow]
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
    
    func setHowToTake(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(HOWTOTAKE_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = routeListArr[selectedRow]
        }
    }
    
    func setResoneForTaking(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(RESONEFORTAKING_VIEW_TAG) as? AddModuleKeyAndValueView, let resoneForTakingDict = resoneForTakingDict
        {
            addAllergiesKeyAndLabelView.valueLabel.text = resoneForTakingDict[resoneForTakingDict.allKeys[selectedRow]] as? String
        }
    }
    
    func setProvider(selectedRow : Int)
    {
        if let addAllergiesKeyAndLabelView = view.viewWithTag(PRESCRIBED_VIEW_TAG) as? AddModuleKeyAndValueView
        {
            addAllergiesKeyAndLabelView.valueLabel.text = providerList[selectedRow]
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
        if let drugNameView = self.view.viewWithTag(DRUGNAME_VIEW_TAG) as? AddModuleKeyAndValueView,
        let doseView = self.view.viewWithTag(DOSE_VIEW_TAG) as? AddModuleKeyAndValueView,
        let doseUnitView = self.view.viewWithTag(DOSE_UNIT_VIEW_TAG) as? AddModuleKeyAndValueView,
        let strenghtView = self.view.viewWithTag(STRENGHT_VIEW_TAG) as? AddModuleKeyAndValueView,
        let strenghtUnitView = self.view.viewWithTag(STRENGHT_UNIT_VIEW_TAG) as? AddModuleKeyAndValueView,
        let frequencyView = self.view.viewWithTag(FREQUENCY_VIEW_TAG) as? AddModuleKeyAndValueView,
        let whenView = self.view.viewWithTag(WHEN_VIEW_TAG) as? AddModuleKeyAndValueView,
        let howToTakeView = self.view.viewWithTag(HOWTOTAKE_VIEW_TAG) as? AddModuleKeyAndValueView,
        let startDateView = self.view.viewWithTag(STARTDATE_VIEW_TAG) as? AddModuleKeyAndValueView,
        let stopDateView = self.view.viewWithTag(STOPDATE_VIEW_TAG) as? AddModuleKeyAndValueView,
        let resoneForTakingView = self.view.viewWithTag(RESONEFORTAKING_VIEW_TAG) as? AddModuleKeyAndValueView,
        let prescribedView = self.view.viewWithTag(PRESCRIBED_VIEW_TAG) as? AddModuleKeyAndValueView,
        let refillView = self.view.viewWithTag(REFILL_VIEW_TAG) as? AddModuleKeyAndValueView,
           let commentTf = self.view.viewWithTag(COMMENT_TF_TAG) as? UITextView{
            
            if isNilOrEmpty(string: drugNameView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: drugNameView.keyLabel.text)
            }
            else if isNilOrEmpty(string: practiceNameView?.valueLabel.text) && Patient.selectedPatientInstance?.practiceList.count ?? -1 > 1 && editMedicationPOJO == nil
            {
                showMandatoryAlert(fieldName: practiceNameView?.keyLabel.text)
            }
            else if isNilOrEmpty(string: resoneForTakingView.valueLabel.text) && editMedicationPOJO == nil
            {
                showMandatoryAlert(fieldName: resoneForTakingView.keyLabel.text)
            }
            else if isNilOrEmpty(string: howToTakeView.valueLabel.text)
            {
                showMandatoryAlert(fieldName: howToTakeView.keyLabel.text)
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
            //        else if isNilOrEmpty(string: commentTf.text)
            //        {
            //                showMandatoryAlert(fieldName: NSLocalizedString("com.charmphr.add.MedicationAndSupplememnts.Comment.title", comment: ""))
            //                commentTf.becomeFirstResponder()
            //        }
            else
            {
                let medicationPOJO = MedicationPOJO()
                let patientMedication = PatientMedication()
                let medication = Medication()
                
                medication.medicationName = drugNameView.valueLabel.text
                patientMedication.addedByPatient = true
                patientMedication.patientId = Patient.selectedPatientInstance?.patientId
                patientMedication.dosage = doseView.textField.text
                let valueOfDosageUnitArr = unitWithNameDict?.allValues as? Array<String>
                if let index = valueOfDosageUnitArr?.firstIndex(of: doseUnitView.valueLabel.text ?? "")
                {
                    patientMedication.dosageUnitId = "\(unitWithNameDict?.allKeys[index] ?? "")"
                }
                medication.numberOfIntake = strenghtView.textField.text
                medication.intakeUnit = "\(strenghtUnitView.valueLabel.text ?? "")"
                patientMedication.intake = "\(frequencyView.valueLabel.text ?? "")"
                patientMedication.intakeWhen = "\(whenView.valueLabel.text ?? "")"
                patientMedication.intakeRoute = "\(howToTakeView.valueLabel.text ?? "")"
                patientMedication.fromDate = startDatePicker.date
                patientMedication.toDate = stopDatePicker.date
                let resoneForTakingValueArr = resoneForTakingDict?.allValues as? Array<String>
                if let index = resoneForTakingValueArr?.firstIndex(of: resoneForTakingView.valueLabel.text ?? "")
                {
                    patientMedication.medicalConditionId = "\(resoneForTakingDict?.allKeys[index] ?? "")"
                }
                patientMedication.prescribedBy = prescribedView.valueLabel.text ?? ""
                patientMedication.refill = refillView.textField.text
                patientMedication.comment = commentTf.text ?? ""
                
                medicationPOJO.patientMedication = patientMedication
                medicationPOJO.medication = medication
                
                if charmConnectionHandeler == nil
                {
                    charmConnectionHandeler = CharmConnectionHandler(delegate: self)
                    charmConnectionHandeler?.v2Delegate = self
                }
                
                //            if editMedicationPOJO == nil{
                //                charmConnectionHandeler.addMedication(patientMedication: medication, identificationKey: "addMedication")
                //            }
                //            else{
                //                medication.patientMedicationId = editMedicationPOJO!.patientMedicationId
                //                medication.prescriptionHistoryId = editMedicationPOJO!.prescriptionHistoryId
                //                medication.prescriptionName = nil
                //                charmConnectionHandeler.editMedicationPOJO(patientMedication: medication, identificationKey: "editMedicationPOJO")
                //            }
                
                
                
                if editMedicationPOJO == nil
                {
                    addMedicationPOJO = medicationPOJO
                    if Patient.selectedPatientInstance?.practiceList.count ?? -1 > 1
                    {
                        let practiceIndex: Int = Patient.selectedPatientInstance?.practiceList.firstIndex { (practice) -> Bool in
                            if practice.practiceName == practiceNameView?.valueLabel.text
                            {
                                return true
                            }else
                            {
                                return false
                            }
                        } ?? -1
                        let practiceId = isHealthPassport == false ? Patient.selectedPatientInstance?.practiceList[practiceIndex].practiceId : nil
                        charmConnectionHandeler?.addMedication(practiceId: practiceId, medicationPOJO: medicationPOJO, identificationKey: "addMedication")
                    }else
                    {
                        let practiceId = isHealthPassport == false ? Patient.selectedPatientInstance?.practiceList[0].practiceId :  nil
                        
                        charmConnectionHandeler?.addMedication(practiceId: practiceId, medicationPOJO: medicationPOJO, identificationKey: "addMedication")
                    }
                }else
                {
                    medicationPOJO.patientMedication?.patientMedicationId = editMedicationPOJO?.patientMedication?.patientMedicationId
                    medicationPOJO.medication?.medicationName = nil
                    charmConnectionHandeler?.editMedication(practiceId: nil, medicationPOJO: medicationPOJO, identificationKey: "editMedicationPOJO")
                }
                showActivityIndicator()
            }
        }
    }
    
    func showMandatoryAlert(fieldName : String?)
    {
        CharmUtil.createOkayAlertWith(title: nil, msg: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName ?? "")")
    }
    
    //MARK: - charmconnection handler deletage
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {

        if identificationKey == "addMedication" || identificationKey == "editMedicationPOJO"{
            hideActivityIndicator()
            AppDataHandler.sharedInstance().refreshMedication = true
            
            navigationController?.popViewController(animated: true)
            if identificationKey == "addMedication", let addMedicationPOJO = addMedicationPOJO, let medicationObj = (response as? [String: Any])?.getAsJsonObject("output_string"){
                
                addMedicationPOJO.patientMedication?.patientMedicationId = medicationObj.getString("PRESCRIPTION_HISTORY_ID")
                addMedicationPOJO.medication?.medicationId = medicationObj.getString("PRESCRIPTION_ID")
                
                PatientDataHandler.addMedication(medicationPOJO: addMedicationPOJO, patientId: getSelectedPatientId())
                addReminderAlertDelegate?.showAddReminderAlert(transformModel: TransformUtil.transformMedicationToReminderModel(medicationPOJO: addMedicationPOJO))
            }
            if let resp = response as? [String: Any]{
                if identificationKey == "addMedication"{
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
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "addMedication"{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
        else if identificationKey == "editMedicationPOJO"{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "AddMedicationCommonData"
        {
            isCommonDataFetched = true
                        
            if let outputDict = jsonObject["output_string"] as? Dictionary<String,Any>
            {
               // rxUnitListArr = outputDict["RXUNIT_LIST"] as! Array<String>
                if let medNameVSid = outputDict["MED_NAMEVSID"] as? Dictionary<String,Any>{
                    resoneForTakingDict = MutableOrderedDictionary(dictionary: (medNameVSid))
                }
                if let unitIsVSname = outputDict["UNITIDVSNAME"] as? Dictionary<String,Any>{
                    unitWithNameDict = MutableOrderedDictionary(dictionary: unitIsVSname)
                }
                //routeListArr = outputDict["ROUTE_LIST"] as! Array<String>
//                if let intakeList = outputDict["INTAKE_LIST"] as? Dictionary<String,Any>{
//                    intakeDict = MutableOrderedDictionary(dictionary: intakeList)
//                }
                if let providerList = outputDict["PROVIDER_LIST"] as? Array<String>{
                    self.providerList = providerList
                }
                if let intakeWhenList = outputDict["INTAKE_WHEN_LIST"] as? Dictionary<String,Any>{
                    intakeWhenDict = MutableOrderedDictionary(dictionary: intakeWhenList)
                }
                
                if let drugNameDictArr = outputDict["SEARCH_STRING"] as? Array<Dictionary<String,Any>>{
                    
                    drugNameDict = MutableOrderedDictionary()
                    for drugDict in drugNameDictArr
                    {
                        drugNameDict?.setValue(drugDict["name"] as? String, forKey: "\(drugDict["id"] ?? "")")
                    }
                }
                
                if let editMedicationPOJO = editMedicationPOJO
                {
                    if let drugNameView = self.view.viewWithTag(DRUGNAME_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let doseView = self.view.viewWithTag(DOSE_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let strenghtView = self.view.viewWithTag(STRENGHT_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let whenView = self.view.viewWithTag(WHEN_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let frequencyView = self.view.viewWithTag(FREQUENCY_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let howToTakeView = self.view.viewWithTag(HOWTOTAKE_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let prescribedView = self.view.viewWithTag(PRESCRIBED_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let refillView = self.view.viewWithTag(REFILL_VIEW_TAG) as? AddModuleKeyAndValueView,
                    let reasonForTakingView = self.view.viewWithTag(RESONEFORTAKING_VIEW_TAG) as? AddModuleKeyAndValueView,
                       let commentView = self.view.viewWithTag(COMMENT_TF_TAG) as? UITextView{
                        
                        drugNameView.valueLabel.text = editMedicationPOJO.medication?.medicationName
                        drugNameView.setViewDisabled()
                        doseView.textField.text = editMedicationPOJO.patientMedication?.dosage
                        let keysOfDosageUnitArr = unitWithNameDict?.allKeys as? Array<String>
                        if let index = keysOfDosageUnitArr?.firstIndex(of: "\(editMedicationPOJO.patientMedication?.dosageUnitId ?? "")")
                        {
                            setDoseUnit(selectedRow: index)
                        }
                        if editMedicationPOJO.medication?.numberOfIntake != nil
                        {
                            strenghtView.textField.text = editMedicationPOJO.medication?.numberOfIntake
                        }
                        if let index = rxUnitListArr.firstIndex(of: editMedicationPOJO.medication?.intakeUnit ?? "")
                        {
                            setStrenghtUnit(selectedRow: index)
                        }
                        let keysOfIntakeArr = intakeDict?.allKeys as? Array<String>
                        if let index = keysOfIntakeArr?.firstIndex(of: "\(editMedicationPOJO.patientMedication?.intake ?? "")")
                        {
                            setFrequency(selectedRow: index)
                        }
                        if let intake = editMedicationPOJO.patientMedication?.intake{
                            frequencyView.valueLabel.text = intake
                        }
                        whenView.valueLabel.text = editMedicationPOJO.patientMedication?.intakeWhen
                        setStartAndStopDate(startDate: editMedicationPOJO.patientMedication?.fromDate ?? Date(), stopDate: editMedicationPOJO.patientMedication?.toDate ?? Date())
                        
                        
                        let resoneForTakingKeyArr = resoneForTakingDict?.allKeys as? Array<String>
                        if let index = resoneForTakingKeyArr?.firstIndex(of: "\(editMedicationPOJO.patientMedication?.medicalConditionId ?? "")")
                        {
                            setResoneForTaking(selectedRow: index)
                        }
                        reasonForTakingView.setViewDisabled()
                        
                        howToTakeView.valueLabel.text = editMedicationPOJO.patientMedication?.intakeRoute
                        prescribedView.valueLabel.text = editMedicationPOJO.patientMedication?.prescribedBy
                        if editMedicationPOJO.patientMedication?.refill != nil
                        {
                            refillView.textField.text = editMedicationPOJO.patientMedication?.refill
                        }
                        commentView.text = editMedicationPOJO.patientMedication?.comment
                    }
                    
                }else
                {
                    setDoseUnit(selectedRow: 0)
                    setStrenghtUnit(selectedRow: 0)
                    setFrequency(selectedRow: 0)
                    setWhen(selectedRow: 0)
                    setHowToTake(selectedRow: 0)
                    setResoneForTaking(selectedRow: 0)
                    setProvider(selectedRow: 0)
                    setStartAndStopDate(startDate: Date(), stopDate: Date())
                }
                
                hideActivityIndicator()
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "AddMedicationCommonData"
        {
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.fetchCommonData()
            },cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            })
        }else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        if selectedAddModuleKeyAndLabelView?.tag == PRACTICEVIEW_TAG
        {
            setPractice(selectedIndex: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == DRUGNAME_VIEW_TAG
        {
            setDrugName(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == DOSE_UNIT_VIEW_TAG
        {
            setDoseUnit(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == STRENGHT_UNIT_VIEW_TAG
        {
            setStrenghtUnit(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == FREQUENCY_VIEW_TAG
        {
            setFrequency(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == WHEN_VIEW_TAG
        {
            setWhen(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == HOWTOTAKE_VIEW_TAG
        {
            setHowToTake(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == RESONEFORTAKING_VIEW_TAG
        {
            setResoneForTaking(selectedRow: selectedRow)
        }
        else if selectedAddModuleKeyAndLabelView?.tag == PRESCRIBED_VIEW_TAG
        {
            setProvider(selectedRow: selectedRow)
        }
    }
    
    func selectValueViewControllerDidSelectCustomString(customString: String) {
        if selectedAddModuleKeyAndLabelView?.tag == DRUGNAME_VIEW_TAG
        {
            if let addAllergiesKeyAndLabelView = view.viewWithTag(DRUGNAME_VIEW_TAG) as? AddModuleKeyAndValueView
            {
                addAllergiesKeyAndLabelView.valueLabel.text = customString
            }
        }
    }
    
    //MARK: - navigation
    func navigateToSelectValueVC()
    {
        let vc = SelectValueViewController()
        vc.delegate = self
        if let selectedAddModuleKeyAndLabelView = selectedAddModuleKeyAndLabelView
        {
            vc.title = selectedAddModuleKeyAndLabelView.keyLabel.text
            
            if selectedAddModuleKeyAndLabelView.tag == PRACTICEVIEW_TAG
            {
                vc.arrayOfValueToBeShown = Patient.selectedPatientInstance?.practiceNameArr ?? [String]()
                vc.selectedValueIndex = Patient.selectedPatientInstance?.practiceNameArr.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == DRUGNAME_VIEW_TAG
            {
                vc.valueDelegate = self
                vc.isSearchBarNeeded = true
                vc.addSearchTextAsValue = true
                vc.arrayOfValueToBeShown = drugNameDict?.allValues as? Array<String> ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == DOSE_UNIT_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = unitWithNameDict?.allValues as? Array<String> ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == STRENGHT_UNIT_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = rxUnitListArr
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == FREQUENCY_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = intakeDict?.allValues as? [String] ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == WHEN_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = intakeWhenDict?.allValues as? [String] ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == HOWTOTAKE_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = routeListArr
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == RESONEFORTAKING_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = resoneForTakingDict?.allValues as? [String] ?? [String]()
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            else if selectedAddModuleKeyAndLabelView.tag == PRESCRIBED_VIEW_TAG
            {
                vc.arrayOfValueToBeShown = providerList
                vc.selectedValueIndex = vc.arrayOfValueToBeShown.firstIndex(of: selectedAddModuleKeyAndLabelView.valueLabel.text ?? "")
            }
            
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc override func onBackClick(){

        if editMedicationPOJO == nil {
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
            
            if !getKeyValueView(tag: DRUGNAME_VIEW_TAG).valueLabel.text.isNilOrBlank() {
                return true
            }
            if !getKeyValueView(tag: STRENGHT_VIEW_TAG).textField.text.isNilOrBlank() {
                return true
            }
            if getKeyValueView(tag: STRENGHT_UNIT_VIEW_TAG).valueLabel.text != rxUnitListArr.getElement(at: 0)  {
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
            
            if getKeyValueView(tag: HOWTOTAKE_VIEW_TAG).valueLabel.text != routeListArr.getElement(at: 0)  {
                return true
            }
            
            if getKeyValueView(tag: STARTDATE_VIEW_TAG).textField.text != CharmUtil.getDisplayDateStringWithYear(date: Date()) {
                return true
            }
            
            if getKeyValueView(tag: STOPDATE_VIEW_TAG).textField.text != CharmUtil.getDisplayDateStringWithYear(date: Date()) {
                return true
            }
            
            if getKeyValueView(tag: RESONEFORTAKING_VIEW_TAG).valueLabel.text != resoneForTakingDict?.allValues.getElement(at: 0) as? String ?? ""  {
                return true
            }
            
            if getKeyValueView(tag: PRESCRIBED_VIEW_TAG).valueLabel.text != providerList.getElement(at: 0) ?? ""  {
                return true
            }
            
            
            if !getKeyValueView(tag: REFILL_VIEW_TAG).textField.text.isNilOrBlank()  {
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
            

            if let medicationPOJO = editMedicationPOJO {
                
                var intakeStr = ""
                
                if let intake = medicationPOJO.medication?.numberOfIntake {
                    intakeStr = "\(intake)"
                }
                
                if getKeyValueView(tag: STRENGHT_VIEW_TAG).textField.text != intakeStr {
                    return true
                }
                
                if getKeyValueView(tag: STRENGHT_UNIT_VIEW_TAG).valueLabel.text != medicationPOJO.medication?.intakeUnit  {
                    return true
                }
                
                if getKeyValueView(tag: DOSE_VIEW_TAG).textField.text != medicationPOJO.patientMedication?.dosage  {
                    return true
                }
                
                if getKeyValueView(tag: DOSE_UNIT_VIEW_TAG).valueLabel.text != medicationPOJO.patientMedication?.dosageUnit  {
                    return true
                }
                
                if getKeyValueView(tag: FREQUENCY_VIEW_TAG).valueLabel.text != medicationPOJO.patientMedication?.intake {
                    
                    return true
                }
                if getKeyValueView(tag: WHEN_VIEW_TAG).valueLabel.text != medicationPOJO.patientMedication?.intakeWhen {
                    
                    return true
                }
                
                if getKeyValueView(tag: HOWTOTAKE_VIEW_TAG).valueLabel.text != medicationPOJO.patientMedication?.intakeRoute {
                    
                    return true
                }
                
                if getKeyValueView(tag: STARTDATE_VIEW_TAG).textField.text != CharmUtil.getDisplayDateStringWithYear(date: medicationPOJO.patientMedication?.fromDate ?? Date()) {
                    return true
                }
                
                if getKeyValueView(tag: STOPDATE_VIEW_TAG).textField.text != CharmUtil.getDisplayDateStringWithYear(date:medicationPOJO.patientMedication?.toDate ?? Date()) {
                    return true
                }
                
                if getKeyValueView(tag: PRESCRIBED_VIEW_TAG ).valueLabel.text != medicationPOJO.patientMedication?.prescribedBy {
                    
                    return true
                }
                var refillStr = ""
                

                if let refill = medicationPOJO.patientMedication?.refill {
                    refillStr = "\(refill)"
                }
                
                if getKeyValueView(tag: REFILL_VIEW_TAG ).textField.text != refillStr {
                    
                    return true
                }

                if getTextView(tag: COMMENT_TF_TAG ).text != medicationPOJO.patientMedication?.comment {
                    
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
