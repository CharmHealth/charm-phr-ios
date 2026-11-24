//
//  BillingItemView.swift
//  phr
//
//  Created by prathi-13964 on 22/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class BillingItemView: UIView{
    
    let verticalStackView = UIStackView()
    let dateStatusView = UIView()
    let dateLabel = UILabel()
    let statusLabel = UILabel()
    let facilityNameBillNoView = UIView()
    let facilityNameLabel = UILabel()
    let billNoLabel = UILabel()
    let invoiceAmountView = UIView()
    let invoiceAmountLabel = UILabel()
    let billAmountLabel = UILabel()
    let dueAmountView = UIView()
    let dueAtPresentLabel = UILabel()
    let dueAmountLabel = UILabel()
    let paymentAmountView = UIView()
    let paymentRequestedLabel = UILabel()
    let amountLabel = UILabel()
    let amountPaidView = UIView()
    let amountPaidLabel = UILabel()
    let receiptAmount = UILabel()
    var invoiceItemViewHeight: CGFloat = 20
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(dateStatusView)
        dateStatusView.addSubview(dateLabel)
        dateStatusView.addSubview(statusLabel)
        verticalStackView.addArrangedSubview(facilityNameBillNoView)
        facilityNameBillNoView.addSubview(facilityNameLabel)
        facilityNameBillNoView.addSubview(billNoLabel)
        verticalStackView.addArrangedSubview(invoiceAmountView)
        invoiceAmountView.addSubview(invoiceAmountLabel)
        invoiceAmountView.addSubview(billAmountLabel)
        verticalStackView.addArrangedSubview(dueAmountView)
        dueAmountView.addSubview(dueAtPresentLabel)
        dueAmountView.addSubview(dueAmountLabel)
        verticalStackView.addArrangedSubview(paymentAmountView)
        paymentAmountView.addSubview(paymentRequestedLabel)
        paymentAmountView.addSubview(amountLabel)
        verticalStackView.addArrangedSubview(amountPaidView)
        amountPaidView.addSubview(amountPaidLabel)
        amountPaidView.addSubview(receiptAmount)
        
        addProperties()
        addConstraints()
    }
    private func addConstraints(){
        
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setRight(offSet: -CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        
        dateLabel.setLeft(offSet: 0)
        dateLabel.setTop(offSet: 0)
        dateLabel.setBottom(offSet: 0)
        
        statusLabel.setRight(offSet: 0)
        statusLabel.setTop(offSet: 0)
        statusLabel.setBottom(offSet: 0)
        
        facilityNameLabel.setLeft(offSet: 0)
        facilityNameLabel.setTop(offSet: 0)
        facilityNameLabel.setBottom(offSet: 0)
        facilityNameLabel.setRightRelatedToView(offSet: -PADDING_5, relatedView: billNoLabel, relatedAttribute: .left)
        
        billNoLabel.setRight(offSet: 0)
        billNoLabel.setTop(offSet: 0)
        billNoLabel.setBottom(offSet: 0)
        
        invoiceAmountLabel.setLeft(offSet: 0)
        invoiceAmountLabel.setTop(offSet: 0)
        invoiceAmountLabel.setBottom(offSet: 0)
        invoiceAmountLabel.wrapWidth(maxWidth: 300)
        
        billAmountLabel.setRight(offSet: 0)
        billAmountLabel.setTop(offSet: 0)
        billAmountLabel.setBottom(offSet: 0)
        
        dueAtPresentLabel.setLeft(offSet: 0)
        dueAtPresentLabel.setTop(offSet: 0)
        dueAtPresentLabel.setBottom(offSet: 0)
        dueAtPresentLabel.wrapWidth(maxWidth: 300)
        
        dueAmountLabel.setRight(offSet: 0)
        dueAmountLabel.setTop(offSet: 0)
        dueAmountLabel.setBottom(offSet: 0)
        
        paymentRequestedLabel.setLeft(offSet: 0)
        paymentRequestedLabel.setTop(offSet: 0)
        paymentRequestedLabel.setBottom(offSet: 0)
        paymentRequestedLabel.wrapWidth(maxWidth: 300)
        
        amountLabel.setRight(offSet: 0)
        amountLabel.setTop(offSet: 0)
        amountLabel.setBottom(offSet: 0)
        
        amountPaidLabel.setLeft(offSet: 0)
        amountPaidLabel.setTop(offSet: 0)
        amountPaidLabel.setBottom(offSet: 0)
        
        receiptAmount.setRight(offSet: 0)
        receiptAmount.setTop(offSet: 0)
        receiptAmount.setBottom(offSet: 0)
    }
    
    private func addProperties(){
        
        self.backgroundColor = .white
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 4
        verticalStackView.alignment = .fill
        
        setLabelProperties(uiLabel: dateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK87)
        
        setLabelProperties(uiLabel: statusLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold, textColor: SEVERE_TEXT_COLOR)
        statusLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEVERE_BG_COLOR)
        statusLabel.layer.cornerRadius = 2
        statusLabel.layer.masksToBounds = true
        statusLabel.textAlignment = .center
        
        setLabelProperties(uiLabel: facilityNameLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK87)
        facilityNameLabel.numberOfLines = 1
        setLabelProperties(uiLabel: billNoLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .regular, textColor: TEXT_COLOR_BLACK70)
        
        invoiceAmountLabel.text = getString(key: "com.charmphr.billing.invoice.invoiceAmount")
        setLabelProperties(uiLabel: invoiceAmountLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular, textColor: TEXT_COLOR_BLACK70)
        setLabelProperties(uiLabel: billAmountLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .regular, textColor: TEXT_COLOR_BLACK87)
        
        dueAtPresentLabel.text = getString(key: "com.charmphr.billing.invoice.dueAtPresent")
        setLabelProperties(uiLabel: dueAtPresentLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK70)
        setLabelProperties(uiLabel: dueAmountLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK87)
        
        paymentRequestedLabel.text = getString(key: "com.charmphr.billing.invoice.paymentRequested")
        setLabelProperties(uiLabel: paymentRequestedLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK70)
        setLabelProperties(uiLabel: amountLabel, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold, textColor: abnormalTxtColor)
        
        amountPaidLabel.text = getString(key: "com.charmphr.billing.invoice.amountPaid")
        setLabelProperties(uiLabel: amountPaidLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold, textColor: TEXT_COLOR_BLACK70)
        setLabelProperties(uiLabel: receiptAmount, fontSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold, textColor: normalTxtColor)
    }
    
    private func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight, textColor: UInt){
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textAlignment = .left
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: textColor)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setFontWeight(isRead: Bool){
        
        if isRead{
            facilityNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .regular)
            amountPaidLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        }
        else{
            facilityNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            amountPaidLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        }
    }
    
    func setViewHide(isInvoice: Bool){
        if isInvoice{
            statusLabel.isHidden = false
            dueAmountView.isHidden = false
            invoiceAmountView.isHidden = false
            paymentAmountView.isHidden = false
            amountPaidView.isHidden = true
        }
        else{
            statusLabel.isHidden = true
            dueAmountView.isHidden = true
            invoiceAmountView.isHidden = true
            paymentAmountView.isHidden = true
            amountPaidView.isHidden = false
        }
    }
    
    
    func setInvoice(bill:PHRBills){
        setViewHide(isInvoice: true)
        
        dateLabel.text = bill.billDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        
        facilityNameLabel.text = bill.facilityName
        
        if bill.isStatement{
            billNoLabel.text = getString(key: "com.charmphr.billing.invoice.statement")
        }
        else{
            billNoLabel.text = bill.billNumber
        }
        
        billNoLabel.removeConstraint(attribute: .height)
        invoiceItemViewHeight += (billNoLabel.sizeThatFits(CGSize(width: 500, height: 60)).height + 4)
        
        billNoLabel.removeConstraint(attribute: .width)
        billNoLabel.wrapWidth(maxWidth: 200)
        
        if isAmountValid(amount: bill.amount) && !bill.isPaid && bill.billType != billTypeCreditNote {
            setInvoiceView(isInvoiceView: false)
            amountLabel.text = "\(bill.practiceCurrencySymbol ?? "") \(bill.amount ?? "")"
            bill.isPaymentRequestedShown = true
            
            amountLabel.removeConstraint(attribute: .height)
            invoiceItemViewHeight += (amountLabel.sizeThatFits(CGSize(width: 500, height: 60)).height + 4)
      
        }
        else{
            setInvoiceView(isInvoiceView: true)
            billAmountLabel.text = "\(bill.practiceCurrencySymbol ?? "") \(bill.billAmount ?? "")"
            bill.isPaymentRequestedShown = false
            
            billAmountLabel.removeConstraint(attribute: .height)
            invoiceItemViewHeight += (billAmountLabel.sizeThatFits(CGSize(width: 500, height: 60)).height + 4)
        }
        
        
        if bill.status == Canceled {
            bill.isStatusVisible = true
            statusLabel.text = getString(key: "com.charmphr.billing.invoice.cancelled")
            
            statusLabel.wrapWidth(maxWidth: 300, maxHeight: 50 , extraSpacing: 10)
            
            statusLabel.removeConstraint(attribute: .height)
            invoiceItemViewHeight += statusLabel.sizeThatFits(CGSize(width: 500, height: 60)).height
        }
        else{
            bill.isStatusVisible = false
            
            dateLabel.removeConstraint(attribute: .height)
            invoiceItemViewHeight += dateLabel.sizeThatFits(CGSize(width: 500, height: 60)).height
        }
        
        if bill.isStatusVisible{
            statusLabel.isHidden = false
        }
        else{
            statusLabel.isHidden = true
        }
        
        var dueAmt = bill.dueAmount ?? ""
        
        if bill.billType == billTypeCreditNote {
            dueAmt = "0.00"
        }
        
        dueAmountLabel.text = "\(bill.practiceCurrencySymbol ?? "") \(dueAmt)"
        
        dueAmountLabel.removeConstraint(attribute: .height)
        invoiceItemViewHeight += (dueAmountLabel.sizeThatFits(CGSize(width: 500, height: 60)).height + 4)
    }
    
    func setReceipt(receipt: PHRReceipts){
        dateLabel.text = receipt.receiptDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        
        facilityNameLabel.text = receipt.facilityName
        billNoLabel.text = receipt.receiptNumber
        receiptAmount.text = "\(receipt.practiceCurrencySymbol ?? "") \(receipt.receiptAmount ?? "")".trim()
        
        setFontWeight(isRead: receipt.isRead)
        setViewHide(isInvoice: false)
        
        if !receipt.sentFromEhr {
            statusLabel.text = getString(key: "com.charmphr.billing.receipt.fromPHR")
            statusLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_BLUE_BACKGROUND_COLOR)
            statusLabel.setTextColor(fontcolor: BLUE_BTN_COLOR)

            statusLabel.wrapWidth(maxWidth: 300,maxHeight: 50 , extraSpacing: 10)
            statusLabel.isHidden = false
 //           statusLabel.setWidth(constant: statusLabel.sizeThatFits(CGSize(width: 300, height: 50)).width + 10)
        }
        else{
            statusLabel.isHidden = true
        }
    }
    
    
    
    func setInvoiceView(isInvoiceView: Bool){
        
        if isInvoiceView{
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
            facilityNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .regular)
            dueAtPresentLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            dueAmountLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .regular)
            paymentAmountView.isHidden = true
            invoiceAmountView.isHidden = false
        }
        else{
            dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
            facilityNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            dueAtPresentLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
            dueAmountLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            paymentAmountView.isHidden = false
            invoiceAmountView.isHidden = true
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
