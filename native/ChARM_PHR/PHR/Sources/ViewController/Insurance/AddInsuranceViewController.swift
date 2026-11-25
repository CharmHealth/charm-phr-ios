//
//  AddInsuranceViewController.swift
//  phr
//
//  Created by Raghul D on 02/06/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit


class AddInsuranceViewController: UIViewController , PatInsuranceViewDelegate, CharmConnectionHandlerDelegate , CharmConnectionV2HandlerDelegate, SelectValueViewControllerSearchStringDelagate, SelectValueViewControllerDelagate , SelectValueViewControllerValueDelagate, PrimaryDataHandlerDelegate {
   
    var insurance: PatientInsuranceDetails? = nil
    weak var delegate: AddViewControllerDelegate? = nil
    
    private var patInsuranceView: PatInsuranceView? = nil
    private var insuranceCommonData: InsuranceCommonData? = nil
    private let scrollView = TPKeyboardAvoidingScrollView()
    private var charmConnectionHandler: CharmConnectionHandler? = nil
    private var selectedTF: MDFLTextField? = nil
    private let activityIndicator = UIActivityIndicatorView()
    private var practiceList:[Practice] = []
    private var selectedPractice:Practice? = nil
    private var practicePayerList: [PracticePayer] = []
    private var selectViewController: SelectValueViewController?
    private let primaryDataHandler = PrimaryDataHandler.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.v2Delegate = self
        
        setUpSubView()
    }
    
    private func setUpSubView(){
        
        if insurance != nil {
            self.navigationItem.title = getString(key: "com.charmphr.insurance.edit.title")
        }
        else {
            self.navigationItem.title = getString(key: "com.charmphr.insurance.add.title")
        }
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        
        // View background too, so nothing below the safe area (home indicator) shows black.
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        scrollView.setBackgroundColor(bgColor: APPLICATION_BACKGROUND_COLOR)
        self.view.addSubview(scrollView)
        self.view.addSubview(activityIndicator)
        
        practiceList = getPHREntryEnabledPractices(moduleId: insuranceModelId)

        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        scrollView.setSafeAreaTop(offset: 0)
        scrollView.setSafeAreaBottom(offset: 0)
        // Safe-area edges keep the form clear of the iOS 27.1 landscape side bar / Dynamic Island.
        scrollView.setSafeAreaLeft(offset: 0)
        scrollView.setSafeAreaRight(offset: 0)
        
        if !PrimaryDataHandler.hasAllData()
        {
            showActivityIndicator()
            primaryDataHandler.delegate = self
            primaryDataHandler.fetchPrimaryData()
        }
        
        selectedPractice = practiceList.first
        getInsuranceCommonData()
    }
    
    private func setInsuranceView(){
        if let patInsuranceView = patInsuranceView {
            
            patInsuranceView.delegate = self
            patInsuranceView.setAddInsuranceView()
            
            patInsuranceView.practiceList = practiceList.map{practice in practice.practiceName ?? ""}
            
            patInsuranceView.payerNameTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPayerNameClicked(tapGestureRecognizer:))))
            
            patInsuranceView.stateMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStateClicked(tapGestureRecognizer:))))
            
            patInsuranceView.countryMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryClicked(tapGestureRecognizer:))))
            
            patInsuranceView.payerStateMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStateClicked(tapGestureRecognizer:))))
            
            patInsuranceView.payerCountryMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryClicked(tapGestureRecognizer:))))
            
            scrollView.addSubview(patInsuranceView)
            patInsuranceView.setTop(offSet: 0)
            patInsuranceView.setBottom(offSet: 0)
            patInsuranceView.setLeft(offSet: 0)
            patInsuranceView.setRight(offSet: 0)
            // Form follows the visible width (fold/unfold, rotation); vertical scrolling only.
            patInsuranceView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        }
    }
    
//MARK: - API calls
    
    private func getInsuranceCommonData(){
        
        showActivityIndicator()
        charmConnectionHandler?.getInsuranceCommonData(practiceId: selectedPractice?.practiceId ?? "", identificationKey: "getInsuranceCommonData")
    }
    
//MARK: - Patient InsuranceView Delegate functios
    
    func getPatientDataForInsurance() {
        showActivityIndicator()
        charmConnectionHandler?.fetchDemographics(patientId: Patient.selectedPatientInstance?.patientId ?? "", identificationKey: "getPatientDetailForInsurance")
    }
    
    func onPracticeSelected(index: Int){
        selectedPractice = practiceList[index]
        getInsuranceCommonData()
    }
    
//MARK: - SelectValueVC delegate methods
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
    
        if let selectedTF = selectedTF {
            if let patInsuranceWidget = patInsuranceView
            {
                if selectedTF == patInsuranceWidget.countryMDTF || selectedTF == patInsuranceWidget.payerCountryMDTF {
                    selectedTF.text = primaryDataHandler.countriesArr?[selectedRow].value
                    
                    if selectedTF == patInsuranceWidget.countryMDTF {
                        patInsuranceWidget.onCountryChange()
                    }
                    else{
                        patInsuranceWidget.onPayerCountryChange()
                    }
                }
                else if selectedTF == patInsuranceWidget.stateMDTF || selectedTF == patInsuranceWidget.payerStateMDTF {
                    
                    var country = patInsuranceWidget.countryMDTF?.text?.lowercased() ?? ""
                    
                    if selectedTF == patInsuranceWidget.payerStateMDTF{
                        country = patInsuranceWidget.payerCountryMDTF?.text?.lowercased() ?? ""
                    }
                    
                    if country == INDIA {
                        selectedTF.text = primaryDataHandler.inStatesArr?[selectedRow]
                    }
                    else if country == UNITED_STATES{
                        selectedTF.text = primaryDataHandler.usStatesArr?[selectedRow]
                    }
                    else if country == AUSTRALIA{
                        selectedTF.text = primaryDataHandler.auStatesArr?[selectedRow]
                    }
                }
                else if selectedTF == patInsuranceWidget.payerNameTF {
                    let payer = practicePayerList[selectedRow]
                    patInsuranceWidget.setInsuranceCompanyDetails(payer: payer)
                }
            }
        }
    }
    
    func selectValueViewControllerDidSelectCustomString(customString: String) {
        if selectedTF == patInsuranceView?.payerNameTF{
            selectedTF?.text = customString
            patInsuranceView?.payerIdTF?.text = ""
        }
    }
    
    func onSearchStringChanged(searchStr: String) {
        CharmConnectionHandler.updateSession()
        charmConnectionHandler?.getPayerList(searchStr: searchStr, practiceId: selectedPractice?.practiceId ?? "", identificationKey: "getPayerList")
    }
    
//MARK: - Connection Handler delegate methods
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        
        if identificationKey == "getInsuranceCommonData"{
            
            insuranceCommonData = ParsingHelper.formInsuranceCommonData(respObj: jsonObject)
            
            patInsuranceView = PatInsuranceView(insuranceCommonData: insuranceCommonData, isQuestionnaireInsurance: false)
            setInsuranceView()
            
            hideActivityIndicator()
            
            if let insurance = insurance{
                patInsuranceView?.setEditInsuranceView()
                patInsuranceView?.updateValues(insurance: insurance)
            }
        }
        else if identificationKey == "getPayerList"{
            
            practicePayerList =  ParsingHelper.formPayerList(respObj: jsonObject)
            
            selectViewController?.arrayOfValueToBeShown = practicePayerList.map{payer in
                payer.payerName ?? ""
            }
            selectViewController?.filterValueArrayWithSearchText(isFromApi: true)
        }
        else if identificationKey == "getPatientDetailForInsurance"{
            hideActivityIndicator()
            let patient = ParsingHelper.getPatientDetails(patientObj: Patient(), dict: jsonObject)
            
            patInsuranceView?.patient = patient
            patInsuranceView?.onPatientFetchSuccess()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "getInsuranceCommonData"{
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.getInsuranceCommonData()
            } cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            }
        }
        else if identificationKey == "getPatientDetailForInsurance"{
            
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.getPatientDataForInsurance()
            }
        }
        else if identificationKey == "getPayerList"{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "addInsurance"{
            hideActivityIndicator()
            navigationController?.popViewController(animated: true)
            if let resp = response as? [String: Any]{
                delegate?.addViewControllerDataAdded(message: resp.getString("message"))
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "addInsurance"{
            
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.doneBtnClicked()
            } cancelClicked: {
                self.hideActivityIndicator()
            }
        }
    }
    
    //MARK: -Primary data handler delegate
    
    func primaryDataHandlerDidReceiveData() {
        hideActivityIndicator()
    }
    
    func primaryDataHandlerDidReceiveError(error:Error) {
        
        hideActivityIndicator()
        CharmUtil.createRetryAndCancelAlertWith(error: error) {
            self.showActivityIndicator()
            self.primaryDataHandler.fetchPrimaryData()
        } cancelClicked: {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//MARK: - Action calls
    
    @objc func onPayerNameClicked(tapGestureRecognizer : UITapGestureRecognizer){
        
        if selectedPractice == nil{
            CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.common.selectPractice"), msg: nil)
        }
        else{
            if let payerNameET = tapGestureRecognizer.view as? MDFLTextField {
                if insuranceCommonData?.isUSUser == true {
                    selectedTF = payerNameET
                    
                    selectViewController = SelectValueViewController()
                    if let selectViewController = selectViewController{
                        selectViewController.isSearchBarNeeded = true
                        selectViewController.searchStrDelegate = self
                        selectViewController.searchLocally = false
                        selectViewController.delegate = self
                        selectViewController.addSearchTextAsValue = true
                        selectViewController.isSearchOn3Char = true
                        selectViewController.valueDelegate = self
                        self.navigationController?.pushViewController(selectViewController, animated: true)
                    }
                    self.view.endEditing(true)
                }
                else{
                    payerNameET.becomeFirstResponder()
                }
            }
        }
    }
    
    @objc func onStateClicked(tapGestureRecognizer : UITapGestureRecognizer){
        if let stateET = tapGestureRecognizer.view as? MDFLTextField {
            if let patInsuranceView = patInsuranceView {
                var country = patInsuranceView.countryMDTF?.text?.lowercased() ?? ""
                
                if stateET == patInsuranceView.payerStateMDTF{
                    country = patInsuranceView.payerCountryMDTF?.text?.lowercased() ?? ""
                }
                
                if country == INDIA || country == UNITED_STATES || country == AUSTRALIA{
                    selectedTF = stateET
                    let vc = SelectValueViewController()
                    var stateList = primaryDataHandler.inStatesArr ?? []
                    
                    if country == UNITED_STATES {
                        stateList = primaryDataHandler.usStatesArr ?? []
                    }
                    else if country == AUSTRALIA{
                        stateList = primaryDataHandler.auStatesArr ?? []
                    }
                    vc.isSearchBarNeeded = true
                    vc.arrayOfValueToBeShown = stateList
                    vc.selectedValueIndex = stateList.firstIndex(of: stateET.text ?? "")
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    self.view.endEditing(true)
                }
                else{
                    stateET.becomeFirstResponder()
                }
            }
        }
    }
    
    @objc func onCountryClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if let countryET = tapGestureRecognizer.view as? MDFLTextField {
            
            let vc = SelectValueViewController()

            selectedTF = countryET
            let countryList = primaryDataHandler.countriesArr?.map{country in country.value } ?? []
        
            vc.isSearchBarNeeded = true
            vc.arrayOfValueToBeShown = countryList
            vc.selectedValueIndex = countryList.firstIndex(of: countryET.text ?? "")
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            self.view.endEditing(true)
        }
    }
    
    @objc func doneBtnClicked(){
        
        if let validateDict = patInsuranceView?.validatePatientInsuranceDetails(isAddInsurance: true){
            if !validateDict.isEmpty{
                if let firstVal = validateDict.first{
                    if let mdTextField = firstVal.value as? MDFLTextField{
                        showAlertDialog(titleKey: firstVal.key, textField: mdTextField)
                    }
                    else if let uiView = firstVal.value as? UIView{
                        self.view.endEditing(true)
                        CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: firstVal.key)) {
                            self.scrollView.setContentOffset(CGPoint(x: 0, y: uiView.frame.minY), animated: true)
                        }
                    }
                }
            }
            else{
                if let insurance = patInsuranceView?.getPatientInsuranceDetails(){
                    insurance.practiceId = selectedPractice?.practiceId
                    insurance.patientInsuranceDetailsId = self.insurance?.patientInsuranceDetailsId
                    
                    showActivityIndicator()
                    charmConnectionHandler?.addOrUpdateInsurance(insurance: insurance, identificationKey: "addInsurance")
                }
            }
        }
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
        self.view.endEditing(true)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func showAlertDialog(titleKey: String, textField: MDFLTextField?) {
        CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: titleKey)) {
            if let textField = textField{
                textField.becomeFirstResponder()
            }
        }
    }
}

