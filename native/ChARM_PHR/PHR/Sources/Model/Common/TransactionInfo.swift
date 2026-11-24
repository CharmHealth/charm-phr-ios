//
//  TransactionInfo.swift
//  phr
//
//  Created by Raghul D on 17/11/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import UIKit

class TransactionInfo {

    var patientId: String?
    var facilityId: String?
    var practiceId: String?
    var memberId: String?
    var merchantAccountId: String?
    var billId: String?
    var statementId: String?
    var service: String?
    var paymentAmount: String?
    var currentDate: Date?
    var transactionId:String?
    var razorPayOrderId:String?
    var razorPayPaymentId: String?
    var clientId:String?
    var publicToken:String?
    var paymentAntFromAPI: String?
    var emailId: String?
    var mobile: String?
    var gateway: String?
    var nickName: String?
    var billNum:String?
    var ehrBillId:String?

}

class PaymentInfo {
    var cardNumber: String?
    var cardHolderName: String?
    var cardExpMonth: String?
    var cardExpYear: String?
    var cardCvv: String?
    var token: String?
    var chargeAmount: String?
    var chargeProcessingType: String?
    var chargeType: String?
    var transactionType: String?
    var transactionInfo: TransactionInfo?
    var cardDetails:PaymentGatewayToken?
    var isPaymentSuccess: Bool = false
    var isPartialPaymentEnabled: Bool = false
    var minAllowedAmount:String?
}


class CardMetaObj {
    var cardList:[PaymentGatewayToken] = []
    var patientAddress:PostalAddress? = nil
    var practiceId: String? = nil
}

class PaymentGatewayToken {//PaymentGatewayTokens
    var tokenId:String? = nil
    var merchantAccountId: String? = nil
    var facilityId: String? = nil
    var patientId: String? = nil
    var cardDigit: String? = nil
    var expiry: String? = nil // in mmyy format
    var cardBrand: String? = nil
    var isRecurringToken: Bool = false
    var nameOnCard: String? = nil
    var cardNickName: String? = nil
    var expiryDate: Date? = nil
    var createdMerchantTxnId: String? = nil
    var lastSuccessfulTxnId: String? = nil
    var lastSuccessfulTxnDate: String? = nil
    var lastFailedTxnDate: String? = nil
    var lastFailedTxnStatus: String? = nil
    var isPHRCard: Bool = false
    var isPrimaryCard: Bool = false
    var postalAddress: PostalAddress? = nil
    var cardGroupId: String? = nil
    
    var practiceId: String? = nil
    var allowPracticeCardDeletion: Bool = false
    var hasCardExpired: Bool = false
    var practicePatientId: String? = nil
    var token: String? = nil
    

    
}



class PatientCardGroup{
    var cardGroupId: String? = nil
    var practicePatientId: String? = nil
}

class PaymentResponse{
    var responseListener: ResponseListener? = nil
}

protocol ResponseListener {
    func onTransactionResp(resp: Any)
}

class MerchantAccountInfo {
    var merchantAccountId: String? = nil
    var type: String? = nil
    var facilityId:String? = nil
    var gateway: String? = nil
    var title: String? = nil
    var accountId: String? = nil
    var apiKey: String? = nil
    var group: String? = nil
    var profileId: String? = nil
    var addedBy: String? = nil
    var tokemType: String? = nil
    var expiresIn: String? = nil
    var accessToken: String? = nil
}
//
//<table name="MerchantAccountInfo">
//        <description>For storing Bluefin/Transfirst/Easypay account details of the user</description>
//        <columns>
//
//
//
//            <column name="ACCESS_TOKEN">
//                <description>Secret for server to server calls</description>
//                <data-type>SCHAR</data-type>
//                <max-size>500</max-size>
//                <nullable>true</nullable>
//            </column>
//            <column name="PUBLIC_TOKEN">
//                <description>Secret for client side calls</description>
//                <data-type>SCHAR</data-type>
//                <max-size>500</max-size>
//                <nullable>true</nullable>
//            </column>
//            <column name="REFRESH_TOKEN">
//                <description>Secret for client side calls</description>
//                <data-type>SCHAR</data-type>
//                <max-size>500</max-size>
//                <nullable>true</nullable>
//            </column>
//            <column name="TIME">
//                <description>Profile creation time</description>
//                <data-type>BIGINT</data-type>
//                <nullable>false</nullable>
//            </column>
//            <column name="UPDATED_TIME">
//                <description>Profile creation time</description>
//                <data-type>BIGINT</data-type>
//            </column>
//            <column name="DESCRIPTION">
//                <description>Description entered by the user</description>
//                <data-type>CHAR</data-type>
//                <max-size>50</max-size>
//                <nullable>true</nullable>
//            </column>
//            <column name="IS_PAX_ENABLED">
//                <description>To check whether PAX has been enabled</description>
//                <data-type>BOOLEAN</data-type>
//                <default-value>false</default-value>
//            </column>
//            <column name="IS_DELETED">
//                <description>For handling delete</description>
//                <data-type>BOOLEAN</data-type>
//                <default-value>false</default-value>
//            </column>
//        </columns>
//        <primary-key name="MerchantAccountInfo_PK">
//            <primary-key-column>MERCHANT_ACCOUNT_ID</primary-key-column>
//        </primary-key>
//    </table>
