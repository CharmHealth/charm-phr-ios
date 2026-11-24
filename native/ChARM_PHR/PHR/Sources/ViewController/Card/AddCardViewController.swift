//
//  AddCardViewController.swift
//  phr
//
//  Created by Raghul D on 01/02/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation

class AddCardViewController: AddDataUIViewController , SelectValueViewControllerDelagate, CharmConnectionV2HandlerDelegate {

    
    var selectedPractice:Practice? = nil
    var patientAddress:PostalAddress? = nil
    var practiceList = getBluefinEnabledPractices()
    
    lazy var addCardView:AddCardView = AddCardView(delegate: self)
    
    var paymentInfo: PaymentInfo? = nil
    weak var delegate: AddViewControllerDelegate? = nil

    var charmConnectionHandler: CharmConnectionHandler?
    var editCard:PaymentGatewayToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedPractice == nil {
            selectedPractice = practiceList.firstOrNil()
        }
        self.view = addCardView
        charmConnectionHandler = CharmConnectionHandler(delegate:nil)
        charmConnectionHandler?.v2Delegate = self
        
        
        if let editCard = editCard {
            self.navigationItem.title = getString(key: "com.charmphr.card.edit.title")
            addCardView.setPaymentGatewayToken(paymentGatewayToken: editCard)
        }
        else{
            self.navigationItem.title = getString(key: "com.charmphr.card.add.title")
            if let postalAddress = patientAddress {
                addCardView.setPostalAddress(postalAddress: postalAddress)
            }
        }
    }
    
    func addCard(paymentInfo: PaymentInfo){
    
        paymentInfo.transactionInfo?.practiceId = selectedPractice?.practiceId
        paymentInfo.transactionInfo?.patientId = getSelectedPatientId()
        self.paymentInfo = paymentInfo
        addCardView.showActivityIndicator()
        charmConnectionHandler?.addCard(paymentInfo: paymentInfo, identificationKey: "AddCard")
    }
    
    func editCard(card: PaymentGatewayToken){
        addCardView.showActivityIndicator()
        charmConnectionHandler?.updateCard(paymentGatewayToken: card, identificationKey: "EditCard")
    }
    
    func intentToCountrySelect(){
        let selectValueVC = SelectValueViewController()
        
        selectValueVC.navigationItem.largeTitleDisplayMode = .never
        selectValueVC.navigationItem.title = getString(key: "com.charmphr.EditDemographics.Country.title")
        selectValueVC.delegate = self
        selectValueVC.arrayOfValueToBeShown = PrimaryDataHandler.sharedInstance.countriesArr?.map({ country in
            country.value
        }) ?? []
        selectValueVC.isSearchBarNeeded = true
        
        let country = addCardView.country.textField?.text ?? ""
    
        if country.isNotBlank(){
            selectValueVC.selectedValueIndex = PrimaryDataHandler.sharedInstance.countriesArr?.firstIndex(where: {tempCountry in
                tempCountry.value == country
            })
        }
            
        self.navigationController?.pushViewController(selectValueVC, animated: true)
    }
    
    func intentToPracticeSelect(){
        let selectValueVC = SelectValueViewController()
        
        selectValueVC.navigationItem.largeTitleDisplayMode = .never
        selectValueVC.navigationItem.title = getString(key: "com.charmphr.common.selectPractice")
        selectValueVC.delegate = self
        selectValueVC.arrayOfValueToBeShown = practiceList.map({ practice in
            practice.practiceName ?? ""
        })
        
        let practiceName = addCardView.practiceLayout?.textField?.text ?? ""
        
        if practiceName.isNotBlank() {
            selectValueVC.selectedValueIndex = practiceList.firstIndex(where: {tempPractice in
                tempPractice.practiceName == practiceName
            })
        }
        self.navigationController?.pushViewController(selectValueVC, animated: true)
    }
    
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        
        if addCardView.practiceLayout?.textField?.isFirstResponder ?? false {
            selectedPractice = practiceList.getElement(at: selectedRow)
            addCardView.practiceLayout?.textField?.text = selectedPractice?.practiceName ?? ""
        }
        else{
            addCardView.country.textField?.text = PrimaryDataHandler.sharedInstance.countriesArr?.getElement(at: selectedRow)?.value
            addCardView.onCountryChange()
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "AddCard" ||  identificationKey == "EditCard" {
            var successMsgKey = "com.charmphr.card.add.success.msg"
            
            if identificationKey == "EditCard"{
                successMsgKey = "com.charmphr.card.edit.success.msg"
            }
            addCardView.hideActivityIndicator()
            navigationController?.popViewController(animated: true)
            delegate?.addViewControllerDataAdded(message: getString(key: successMsgKey))
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        addCardView.hideActivityIndicator()
        if identificationKey == "AddCard"{
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                if let paymentInfo = self.paymentInfo {
                    self.addCard(paymentInfo: paymentInfo)
                }
            })
        }
        else if identificationKey == "EditCard"{
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                if let card = self.editCard {
                    self.editCard(card: card)
                }
            })
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
      
    }
    
    @objc override func onBackClick(){
       
        if editCard == nil {
            if addCardView.checkDataIsAvailable(){
                showDiscardChangesDialog()
                return
            }
        }
        else{
            if addCardView.checkDataIsEditted() {
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
    
   

}
