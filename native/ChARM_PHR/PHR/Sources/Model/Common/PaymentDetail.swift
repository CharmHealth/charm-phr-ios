//
//  PaymentDetail.swift
//  phr
//
//  Created by Sankar Saravanan on 29/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class PaymentDetail {
    var patientId : String!
    var merchantAccountId : String!
    var currency : String!
    var currencySymbol : String!
    var gateway : String!
    var amount : Float = 0
    var chargeType : String?
    var isCardProcessing : Bool!
    var transactionId : String!
    var publicToken : String!
    var orderid : String!
    var clientId : String!
    var receiptId : String!
    
    var phoneNumber : String!
    var emailId : String!
    var isPaymentSuccess : Bool  = false
}
