//
//  Facility.swift
//  phr
//
//  Created by Sankar Saravanan on 05/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

class Facility {
    var practiceId : String? = nil
    var facilityId : String? = nil
    var facilityName : String? = nil
    var phoneNumber : String? = nil
    var emailAddress : String? = nil
    var direction : String? = nil
    var weburl : String? = nil
    var logoUrl : String? = nil
    var preferredCommunication : String? = nil
    
    var postalCode : String? = nil
    var state : String? = nil
    var city : String? = nil
    var country : String? = nil
    var landline : String? = nil
    var directMailid : String? = nil
    var countryName : String? = nil
    var line1 : String? = nil
    var line2 : String? = nil
}

public class Practice: NSObject, NSSecureCoding{
    public static var supportsSecureCoding: Bool = true
    var practiceName : String? = nil
    var firstFacilityName : String? = nil
    var practiceId : String? = nil
    var facilitiesCount : Int = 0
    var facilitiesList : String? = nil
    var isActive : Bool = false
    var isBluefinEnabled: Bool = false
    var easycareURL : String? = nil

    override init(){
        super.init()
    }

    public func encode(with coder: NSCoder) {
        coder.encode(practiceName, forKey: "practiceName")
        coder.encode(firstFacilityName, forKey: "firstFacilityName")
        coder.encode(practiceId, forKey: "practiceId")
        coder.encode(facilitiesCount, forKey: "facilitiesCount")
        coder.encode(facilitiesList, forKey: "facilitiesList")
        coder.encode(isActive, forKey: "isActive")
        coder.encode(isBluefinEnabled, forKey: "isBluefinEnabled")
        coder.encode(easycareURL, forKey: "easycareURL")
    }
    
    required public init?(coder: NSCoder) {
        practiceName = coder.decodeObject(forKey: "practiceName") as? String
        firstFacilityName = coder.decodeObject(forKey: "firstFacilityName") as? String
        practiceId = coder.decodeObject(forKey: "practiceId") as? String
        facilitiesCount = coder.decodeInteger(forKey: "facilitiesCount")
        facilitiesList = coder.decodeObject(forKey: "facilitiesList") as? String
        isActive = coder.decodeBool(forKey: "isActive")
        isBluefinEnabled = coder.decodeBool(forKey: "isBluefinEnabled")
        easycareURL = coder.decodeObject(forKey: "easycareURL") as? String
    }
    
}

class About {
    var facilityList:[Facility] = []
    var providerList:[Provider] = []
}
