//
//  ActiveInvoiceIndividualView.swift
//  phr
//
//  Created by Raghul D on 04/03/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation

class ActiveInvoiceIndividualView: UIView {
    
    let dateLabel = UILabel()
    let monthLabel = UILabel()
    let facilityNameLabel = UILabel()
    let amountLabel = UILabel()
    
    private var amountLabelWidthConstraint: NSLayoutConstraint!
    private let paymentReqLabel = UILabel()
    private let dateLayout = UIView()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews(){
        
        self.addSubview(dateLayout)
        self.addSubview(paymentReqLabel)
        self.addSubview(facilityNameLabel)
        self.addSubview(amountLabel)
        
        dateLayout.addSubview(dateLabel)
        dateLayout.addSubview(monthLabel)
        
        setProperties()
        addConstraints()
    }
    
    func setProperties() {
        
        dateLayout.setBackgroundColor(bgColor: THEME_COLOR)
        dateLayout.layer.cornerRadius = CardSize.SMALL.value

        dateLabel.setProperties(textKey: "", fontsize: 18, weight: .bold, fontcolor: TEXT_COLOR_WHITE)
        dateLabel.numberOfLines = 1
        monthLabel.setProperties(textKey: "", fontsize: 12, weight: .regular, fontcolor: TEXT_COLOR_WHITE)
        monthLabel.numberOfLines = 1
        paymentReqLabel.setProperties(textKey: "com.charmphr.invoice.PaymentRequested.title", fontsize: 16, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        paymentReqLabel.numberOfLines = 1
        facilityNameLabel.setProperties(textKey: "", fontsize: 14, weight: .regular, fontcolor: TEXT_COLOR_LIGHTGRAY)
        facilityNameLabel.numberOfLines = 1
        amountLabel.setProperties(textKey: "", fontsize: 16, weight: .semibold, fontcolor: TEXT_COLOR_RED)
        amountLabel.numberOfLines = 1
        
    }
    
    func addConstraints() {
        
        dateLayout.setHeight(constant: 48)
        dateLayout.setWidth(constant: 38)
        dateLayout.setLeft(offSet: CARD_PADDING)
        dateLayout.setTop(offSet: CARD_PADDING)
        dateLayout.setBottom(offSet: -CARD_PADDING)
        
        dateLabel.setCenterX()
        dateLabel.setTop(offSet: 4)
        
        monthLabel.setCenterX()
        monthLabel.setBottom(offSet: -4)
        
        paymentReqLabel.setLeftRelatedToView(offSet: 8, relatedView: dateLayout, relatedAttribute: .right)
        paymentReqLabel.setTopRelatedToView(offSet: 2, relatedView: dateLayout, relatedAttribute: .top)
        paymentReqLabel.setRightRelatedToView(offSet: 8, relatedView: amountLabel, relatedAttribute: .left)
        
        amountLabel.setTopRelatedToView(offSet: 0, relatedView: paymentReqLabel, relatedAttribute: .top)
        amountLabel.setRight(offSet: -CARD_PADDING)
        amountLabelWidthConstraint = amountLabel.setAndReturnWidth(constant: 0)
        
        
        facilityNameLabel.setTopRelatedToView(offSet: 2, relatedView: paymentReqLabel, relatedAttribute: .bottom)
        facilityNameLabel.setLeftRelatedToView(offSet: 0, relatedView: paymentReqLabel, relatedAttribute: .left)
        facilityNameLabel.setRight(offSet: -CARD_PADDING)
    }
    
    func setValues(phrBill: PHRBills){
        
        dateLabel.text = phrBill.billDate?.getStringFromDate(dateFormat: dateOfMonthDateFormat)
        monthLabel.text = phrBill.billDate?.getStringFromDate(dateFormat: monthOfYearDateFormat)
        facilityNameLabel.text = phrBill.facility?.facilityName
        amountLabel.text = "\(phrBill.practiceCurrencySymbol ?? "") \(phrBill.amount ?? "")"
        amountLabelWidthConstraint.constant = amountLabel.sizeThatFits(CGSize(width: 300, height: 50)).width
    }
}
