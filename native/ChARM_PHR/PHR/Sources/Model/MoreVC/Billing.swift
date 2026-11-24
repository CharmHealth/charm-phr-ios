//
//  Billing.swift
//  phr
//
//  Created by Sankar Saravanan on 29/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import Foundation

class PHRBills : DateDelegate{
    func getDate() -> Date {
        return billDate ?? Date()
    }
    
    var phrBillId: String? = nil
    var patientPracticeMapId: String? = nil
    var ehrBillId: String? = nil
    var billNumber: String? = nil
    var billDate: Date? = nil
    var billType: String? = nil
    var amount: String? = nil
    var billAmount: String? = nil
    var dueAmount: String? = nil
    var status: String? = nil
    var facilityId: String? = nil
    var sharedBy: String? = nil
    var time: Date? = nil
    var isPaid: Bool = false
    var isRead: Bool = false
    // added
    var facilityName : String? = nil
    var practiceCurrencySymbol : String? = nil
    var practiceId : String? = nil
    var paymentInfo : PaymentInfo? = nil
    
    var isStatement : Bool = false
    var statementId : String? = nil
    var gateway : String? = nil
    var facility: Facility?
    var memberId: String? = nil
    var isStatusVisible: Bool = false
    var merchantId: String? = nil
    var patient : Patient? = nil
    
    var storeCardInFile: Bool = false
    var isPaymentRequestedShown: Bool = false
}

class PHRBillData {
    var phrBillDataId: String? = nil
    var phrBillId: String? = nil
    var filePath: String? = nil
    var billAmount: String? = nil
    var time: Date? = nil
    var sharedBy: String? = nil
}

class PHRReceipts: DateDelegate {
    func getDate() -> Date {
        return receiptDate ?? Date()
    }
    
    var phrReceiptId: String? = nil
    var patientPracticeMapId: String? = nil
    var ehrReceiptId: String? = nil
    var receiptNumber: String? = nil
    var receiptDate: Date? = nil
    var receiptAmount: String? = nil
    var usedAmount: String? = nil
    var status: String? = nil
    var details: String? = nil
    var facilityId: String? = nil
    var sharedBy: String? = nil
    var time: Date? = nil
    var filePath: String? = nil
    var isRead: Bool = false
    var sentFromEhr: Bool = false
    var pdfData: Data? = nil
    //added
    var practiceId : String? = nil
    var facilityName : String? = nil
    var practiceCurrencySymbol : String? = nil
}

class PHRReceiptData {
    var phrReceiptDataId: String? = nil
    var phrReceiptId: String? = nil
    var filePath: String? = nil
    var receiptAmount: String? = nil
    var time: Date? = nil
    var sharedBy: String? = nil
}

class PHRBillStatements {
    var statementId: String? = nil
    var statementAmount: String? = nil
    var statementDue: String? = nil
    var paymentRequest: String? = nil
    var merchantAccountId: String? = nil
    var facilityId: String? = nil
    var sharedBy: String? = nil
    var practiceId: String? = nil
    var time: Date? = nil
    var isPaid: Bool = false
    var isRead: Bool = false
    var phrBills:[PHRBills] = []
    
    var isPartialPaymentEnabled: Bool = false
    var minAllowedAmount:String? = nil
    var storeCardInFile: Bool = false
}
