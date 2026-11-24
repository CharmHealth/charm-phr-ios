//
//  PaymentViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 09/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController, CharmConnectionHandlerDelegate,CharmConnectionV2HandlerDelegate, SelectValueViewControllerDelagate {
    
    
  
    var amountPayableStr : String = ""
    var currencySymbol = ""
    var paymentInfo: PaymentInfo? = nil
    
    var charmConnectionHandler : CharmConnectionHandler?
    var cardList:[PaymentGatewayToken] = []
    
    var selectedCard: PaymentGatewayToken? = nil
    weak var delegate: PaymentViewControllerDelegate? = nil
    
    lazy var paymentView = PaymentView(delegate: self)

    //views
   
    var totalCheckStatusCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = getString(key: "com.charmphr.Payment.title")
        
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.v2Delegate = self
        // Do any additional setup after loading the view.
        
        self.view = paymentView
        //createSubViews()
    }
    
   
    func onCardValidationSuccess() {
        if let paymentInfo = paymentInfo {
            if let cardOnFileLayout = paymentView.cardOnFileLayout {
                if !cardOnFileLayout.isHidden{
                    paymentInfo.token = selectedCard?.token
                }
            }
            createPaymentTransaction(paymentInfo: paymentInfo)
        }
    }

    //MARK: CharmConnection Handler
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "checkStatus" {
            
            
            if paymentInfo?.chargeProcessingType == appointmentCardProcessingTypeStoreOnly{
                
                
                let isTransactionSuccess = ParsingHelper.isTransactionSuccessForBluefin(respObj: jsonObject)
                
                if isTransactionSuccess {
                    hideActivityIndicator()
                    delegate?.onReceiptIdCreated(receiptId: "")
                    navigationController?.popViewController(animated: true)
                }
                else{
                    if totalCheckStatusCount < 6 {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                            self.totalCheckStatusCount += 1
                            self.checkTransactionStatus()
                        })
                    }
                    else{
                        hideActivityIndicator()
                        CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.payment.store.failed"), msg: nil){
                                        // go to billing list
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
            }
            else{
                var isEHRReceipt = true
                
                if paymentInfo?.transactionInfo?.service == paymentServiceBilling {
                    isEHRReceipt = false
                }
                
                let receiptId = ParsingHelper.getReceiptIdForBluefin(respObj: jsonObject, isEHRReceipt: isEHRReceipt)
                
                if let receiptId = receiptId as? String {//show receipt PDF using this ID
                    // show receipt id pdf
                    hideActivityIndicator()
                    delegate?.onReceiptIdCreated(receiptId: receiptId)
                    navigationController?.popViewController(animated: true)
                }
                else{//show dialog with a given message(will update message here) and when ok is pressed send the user back to billing list view
                    
                    if totalCheckStatusCount < 6 {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                            self.totalCheckStatusCount += 1
                            self.checkTransactionStatus()
                        })
                    }
                    else{
                        hideActivityIndicator()
                        CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.billing.receipt.generate.failed"), msg: nil){
                                        // go to billing list
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        if identificationKey == "checkStatus" { //No need to change Payment is succues
            
            CharmUtil.createRetryAndCancelAlertWith(title: getString(key: "com.charmphr.alertError"), msg: nil, tryAgainClicked: {
                self.checkTransactionStatus()
            })
        }
        else {
            CharmUtil.createRetryAndCancelAlertWith(title: getString(key: "com.charmphr.alertError"), msg: nil){
                self.createPaymentTransaction(paymentInfo: self.paymentInfo!)
            }
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey == "MakePayment"{
            if let receiptId = response as? String {
                navigationController?.popViewController(animated: true)
                self.delegate?.onReceiptIdCreated(receiptId: receiptId)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        let nsError = error as NSError
        if nsError.code == errorPaymentSuccessButReceiptFailedCode{
            if totalCheckStatusCount < 6 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.totalCheckStatusCount += 1
                    self.checkTransactionStatus()
                })
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.billing.receipt.generate.failed"), msg: nil){
                                // go to billing list
                self.navigationController?.popViewController(animated: true)
                }
            }
        }
        else{
            CharmUtil.createRetryAndCancelAlertWith(title: getString(key: "com.charmphr.alertError"), msg: nil){
                self.createPaymentTransaction(paymentInfo: self.paymentInfo!)
            }
        }
    }
    
    
    func createPaymentTransaction(paymentInfo: PaymentInfo) {
        
        if let transactionInfo = paymentInfo.transactionInfo {
            let validated = PaymentUtil.validatePaymentTransactionData(paymentTransaction: transactionInfo, isBilling: paymentInfo.transactionInfo?.service == paymentServiceBilling)
            
            if validated {
                
                showActivityIndicator()
                charmConnectionHandler?.makePayment(paymentInfo: paymentInfo, identificationKey: "MakePayment")
            }
            else {
                hideActivityIndicator()
                CharmUtil.createRetryAndCancelAlertWith(title: getString(key: "com.charmphr.alertError"), msg: nil){
                    self.createPaymentTransaction(paymentInfo: self.paymentInfo!)
                }
            }
        }
    }
    
    func checkTransactionStatus() {
        
        if !paymentView.activityIndicator.isAnimating {
            showActivityIndicator()
        }
        charmConnectionHandler?.checkTransactionStatus( paymentInfo: paymentInfo!, identificationKey: "checkStatus")
    }
    
    func intentToCardListPage(){
        let selectValueVC = SelectValueViewController()
        selectValueVC.title = getString(key:"com.charmphr.Payment.card.title")
        
        selectValueVC.navigationItem.largeTitleDisplayMode = .never
        selectValueVC.delegate = self
        selectValueVC.arrayOfValueToBeShown = cardList.map({card in
            return getCardDetail(card: card)
        })
        
        
        if let selectedCard = selectedCard {
            selectValueVC.selectedValueIndex = cardList.indexOf(includedElement: {card in
                card.tokenId == selectedCard.tokenId
            })
        }
        
        self.navigationController?.pushViewController(selectValueVC, animated: true)
    }
    
  
    
    private func getCardDetail(card: PaymentGatewayToken) -> String {
        var cardValueArr: [String] = []
        
        if !card.cardNickName.isNilOrBlank(){
            cardValueArr.append(card.cardNickName ?? "")
        }
        
        cardValueArr.append(getString(key: "com.charmphr.card.file.label", with: [card.cardDigit ?? ""]))
        
        if !card.expiry.isNilOrBlank() {
            cardValueArr.append(getString(key: "com.charmphr.card.file.expiry.label", with: [card.expiry ?? ""]))
        }
        
        if !card.cardBrand.isNilOrBlank() {
            cardValueArr.append(card.cardBrand ?? "")
        }
        
        return cardValueArr.joined(separator: " | ")
    }
    
    
    func showActivityIndicator()
    {
        paymentView.showActivityIndicator()
    }
    
    func hideActivityIndicator()
    {
        paymentView.hideActivityIndicator()
    }
    
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        selectedCard = cardList.getElement(at: selectedRow)
        
        if let selectedCard = selectedCard {
            paymentView.setSelectedCard(cardDetail: getCardDetail(card: selectedCard))
        }
    }
}

protocol PaymentViewControllerDelegate: AnyObject {
    func onReceiptIdCreated(receiptId: String)
}

class PaymentUtil {

    
    static func validatePaymentTransactionData(paymentTransaction: TransactionInfo , isBilling: Bool = false)-> Bool {

        let facilityId = paymentTransaction.facilityId
        let merchantAccountId = paymentTransaction.merchantAccountId
        let paymentAmount = paymentTransaction.paymentAmount?.toFloatOrNil()
        let memberId = paymentTransaction.memberId


               return !facilityId.isNilOrBlank()  && (!merchantAccountId.isNilOrBlank() || isBilling) && (!memberId.isNilOrBlank() || isBilling)

    }
}
