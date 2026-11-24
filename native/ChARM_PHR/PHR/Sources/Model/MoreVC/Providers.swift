//
//  Providers.swift
//  phr
//
//  Created by Sankar Saravanan on 19/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

class Provider
{
    var firstName : String?
    var lastName : String?
    var fullName : String?
    var middleName : String?
    var gender : String?
    var prefix : String?
    var specialization : String?
    var memberId : String?
    var degree : String?
    var jobTitle: String?
    var fullNameWithJobTitle : String?
    var type: String?
    
    var practiceName : String?
    var practiceId : String?
    var facilityName : String?
    var facilityId : String?
    
    var webUrl : String?
    var introduction : String?
    
    var phoneNumber : String?
    var emailID : String?
    var postalCode : String?
    var state : String?
    var city : String?
    var country : String?
    var landline : String?
    var directMailid : String?
    var countryName : String?
    var line1 : String?
    var line2 : String?
    
    var photo : UIImage?
    
    func formMemberName() -> String? {

        let prefixVal = prefix?.trim() ?? ""
        let memberName = fullName?.trim() ?? ""
        return formMemberNameFrom(fullName: memberName, prefix: prefixVal , degree: nil)
    }
    
    func formMemberNameWithDegree() -> String{
        let prefixVal = prefix?.trim() ?? ""
        let memberName = fullName?.trim() ?? ""
        return formMemberNameFrom(fullName: memberName, prefix: prefixVal , degree: degree)
    }
    
    func formInitials() -> String{
        var initials = ""
            
        if let firstNameFirst = self.firstName?.capitalized.first{
            initials = "\(firstNameFirst)"
            if let lastNameFirst = self.lastName?.capitalized.first{
                initials = "\(firstNameFirst)\(lastNameFirst)"
            }
        }
        return initials
    }
}


class MemberGroup{
    var groupName : String?
    var groupId : String?
    var types: String?
    var description: String?
}

class ProviderAndGroup{
    var memberList: [Provider] = []
    var groupList: [MemberGroup] = []
}
