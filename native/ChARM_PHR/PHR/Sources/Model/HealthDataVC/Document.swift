//
//  Document.swift
//  phr
//
//  Created by Sankar Saravanan on 27/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class Document {

    var fileSize : String? = nil
    var fileId : String? = nil
    var fileName : String? = nil
    var fileType : String? = nil
    var fileStatusId : String? = nil
    var receiverId : String? = nil
    var senderId : String? = nil
    var sentby : String? = nil
    var sharedDate : Date? = nil
    var date : Date? = nil
    var ehrFileId : String? = nil
    var contentType : String? = nil
    var readStatus: Bool = false
    var timeOfUpload : Int? = nil
    var messageToPatient : String? = nil
    var categoryId :  String? = nil
    var categoryName : String? = nil
    var categoryDescription : String? = nil
    var sharedByMeArr : Array<String> = []
    var fileData: Data? = nil
}

class Pharmacy{
    var pharmacyId: String? = nil
    var pharmacyName: String? = nil
    var contactType: String? = nil
    var patientPharmaMapId: String? = nil
    var contactDetails: ContactDetails? = nil
    var postalAddress: PostalAddress? = nil
    var patientId: String? = nil
    var isHealthPassport: Bool = false
    var toString: String = ""
}

class ShareDocRestriction{
    var isShareAllowed: Bool = false
    var practiceId: String = ""
}
class ShareDocumentModel{
    
    var providerArray: [Provider] = []
    var providerArrayToBeShown : [Provider] = []
    var selectedProviderArray : [Provider] = []
    var receiverProviderNames : String = ""
    var isListViewOpened : Bool = false
    var pharmacyList: [Pharmacy] = []
    var pharmacyArrayToBeShown: [Pharmacy] = []
    var selectedPharmacyArray: [Pharmacy] = []
    var receiverPharmacyNames: String = ""
    var count = 0
    var expiryDayValue = "1"
    var otherTextFieldValue: String = ""
    var tagNo = 013193048322424
    var providerViewTagArr: [Int] = []
    var pharmacyViewTagArr: [Int] = []
}
