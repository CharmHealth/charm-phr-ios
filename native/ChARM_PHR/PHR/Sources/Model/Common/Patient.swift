//
//  Patient.swift
//  phr
//
//  Created by Sankar Saravanan on 12/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//


class Patient : NSCopying
{
    static var selectedPatientInstance : Patient? = nil
    static var patientList : Array<Patient>? = nil
    
    var patientPhoto : UIImage?
    var patientId : String!
    var firstName : String!
    var lastName : String!
    var fullName : String?
    var gender : String!
    var dob : String!
    var dateOfBirth: Date?
    var age : Int! = 0
    var bloodGroup : String!
    var isPhotoAvailable : Bool = false
    var isHealthPassportAvailable: Bool = false
    var practiceList : Array<Practice> = []
    var practiceNameArr : Array<String> = []
    var maidenName: String?

    var genderIdentity: String?
    var race: String?
    var ethnicity: String?
    var employmentStatus: String?
    var maritalStatus: String?
    var smokingStatus: String?
    var language: String?
    var patRecordId: String?
    var requiredTabs: [String] = []
    var emergencyContactName: String?
    var emergencyContactNumber: String?
    var emergencyContactExtn: String?
    
    var contactDetail: ContactDetails?
    var postalAddress: PostalAddress?
    
    var caregiverFirstName: String?
    var caregiverLastName: String?
     
    var sectionConfigList: SectionConfigList?
    var primaryCaregiver: CareGiver?
    
    var isBluefinEnabled: Bool = false

    func copy(with zone: NSZone? = nil) -> Any
    {
        let copyPatient = Patient()
        
        copyPatient.patientPhoto = self.patientPhoto?.copy() as? UIImage
        copyPatient.patientId = self.patientId
        copyPatient.firstName = self.firstName
        copyPatient.lastName = self.lastName
        copyPatient.gender = self.gender
        copyPatient.dob = self.dob
        copyPatient.age = self.age
        copyPatient.bloodGroup = self.bloodGroup
        
        return copyPatient
    }
    
    
    func fill(using patient: Patient) {
        
        self.patientId = patient.patientId
        self.firstName = patient.firstName
        self.lastName = patient.lastName
        self.gender = patient.gender
        self.dateOfBirth = patient.dateOfBirth
        self.age = patient.age
        self.bloodGroup = patient.bloodGroup
        
        self.emergencyContactName = patient.emergencyContactName
        self.emergencyContactNumber = patient.emergencyContactNumber

        self.contactDetail = patient.contactDetail
        self.postalAddress = patient.postalAddress
        self.primaryCaregiver = patient.primaryCaregiver
        
        debugPrintLog("country In Fill -> \(self.postalAddress?.country ?? "")")
    }
    
    func getPracticeWith(practiceId:String) -> Practice?
    {
        if Patient.selectedPatientInstance == nil
        {
            return nil
        }
        
//        let indexOfPractice = Patient.selectedPatientInstance!.practiceList.firstIndex { (practice) -> Bool in
//            if practice.practiceId == practiceId
//            {
//                return true
//            }else
//            {
//                return false
//            }
//        }
        
        let indexOfPractice = Patient.selectedPatientInstance!.practiceList.firstIndex(where: {$0.practiceId == practiceId})
        
        if indexOfPractice != nil
        {
            return Patient.selectedPatientInstance!.practiceList[indexOfPractice!]
        }else
        {
            return nil
        }
    }
}
class ContactDetails{
    var contactDetailsId: String?
    var preferredCommunication: String?
    var emailId: String?
    var landline: String?
    var mobile: String?
    var fax: String?
    var webUrl: String?
    var workPhone: String?
    var workPhoneExtn: String?
    var contactPreference: String?
    
    var homePhone: String?
    var primaryPhone: String?
}

class PostalAddress{
    var postalAddressId: String?
    var line1: String?
    var line2: String?
    var area: String?
    var city: String?
    var district: String?
    var state: String?
    var county: String?
    var country: String?
    var postalCode: String?
    var postbox: String?
}

class PatientInsuranceDetails {
    var patientInsuranceDetailsId: String?
    var insuredDetailsId: String?
    var practicePatientId: String?
    var insuranceCompanyDetailsId: String?
    var insurancePlanName: String?
    var insurancePlanType: String?
    var type: String?
    var policyNumber: String?
    var isPatientUniqueMid: Bool = true
    var policyStartDate: Date?
    var policyEndDate: Date?
    var copay: String?
    var deductable: String?
    var coinsurance: String?
    var additionalPrDetails: String?
    var policyDeductible: String?
    var groupNumber: String?
    var comment: String?
    var priorAuthNumber: String?
    var priorAuthType: String?
    var priorAuthEndDate: Date?
    var memberId: String?
    var groupName: String?
    var insuranceCardCopyId: String?
    var isActive: Bool = true
    var addedDate: String?
    var lastModifiedDate: String?
    var addedBy: String?
    var lastModifiedBy: String?
    var addedThrough: String?
    var lastModifiedThrough: String?
    var insuredAndGuarantorDetails: InsuredAndGuarantorDetails?
    var practicePayer: PracticePayer?
    var isAddNewPayerAllowed: Bool = false
    
    var isSelected: Bool = false
    var isPrimary: Bool = false
    var practiceId: String?
    var isAvailable: Bool = true
    var toString: String = ""
    
    var isFrontCardAvailable: Bool?
    var isBackCardAvailable: Bool?
    
    var frontCardName: String? = nil
    var backCardName: String? = nil

}

class InsuredAndGuarantorDetails {
    var insuredGuarantorDetailsId: String?
    var lastName: String?
    var firstName: String?
    var middleName: String?
    var contactdetailsId: String?
    var postaladdressId: String?
    var dateOfBirth: Date?
    var gender: String?
    var relationship: String?
    var ssn: String?
    var maritalStatus: String?
    var employmentStatus: String?
    var contactDetails: ContactDetails?
    var postalAddress: PostalAddress?
    var insuredEmployerDetails: InsuredEmployerDetails?
}

class InsuredEmployerDetails {
    var employerDetailsId: String?
    var insuredGuarantorDetailsId: String?
    var name: String?
    var contactLastName: String?
    var contactFirstName: String?
    var contactdetailsId: String?
    var postaladdressId: String?
}

class PracticePayer { //PracticePayerList
    var practicePayerId: String?
    var payerId: String?
    var eligibilityPayerId: String?
    var payerName: String?
    var knownName: String?
    var groupType: String?
    var contactPerson: String?
    var contactdetailsId: String?
    var postaladdressId: String?
    var is270Supported: Bool = false
    var isActive: Bool = true
    var isBluefinEnabled: Bool = false
    var isVerified: Bool = false
    var payerEobTypeId: String?
    var payerEobTypeId2: String?
    var contactDetails: ContactDetails?
    var postalAddress: PostalAddress?
}

class InsuranceCommonData{
    var relationships: Array<String> = []
    var insuranceTypes: Array<String> =  []
    var isUSUser: Bool = false
}

class DataWithId {
    var key: String = ""
    var value: String = ""
}

class InsuranceTypeChange{
    var memberIdLabel: String? = nil
    var planName: String? = nil
}

public class PatientData: NSObject, NSSecureCoding{
    
    var dob: Date? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var fullName: String? = nil
    var gender: String? = nil
    var practiceList: [Practice] = []
    
    public static var supportsSecureCoding: Bool = true
    
    override init() {
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(dob, forKey: "dob")
        coder.encode(firstName, forKey: "firstName")
        coder.encode(lastName, forKey: "lastName")
        coder.encode(fullName, forKey: "fullName")
        coder.encode(gender, forKey: "gender")
        coder.encode(practiceList, forKey: "practiceList")
    }
    
    required public init?(coder: NSCoder) {
        dob = coder.decodeObject(forKey: "dob") as? Date
        firstName = coder.decodeObject(forKey: "firstName") as? String
        lastName = coder.decodeObject(forKey: "lastName") as? String
        fullName = coder.decodeObject(forKey: "fullName") as? String
        gender = coder.decodeObject(forKey: "gender") as? String
        practiceList = coder.decodeObject(forKey: "practiceList") as? [Practice] ?? []
    }
}

class InsuranceCard {
    var patientId: String? = nil
    var practiceId: String? = nil
    var type: String? = nil
    var cardData: Data? = nil
    var fileName: String? = nil
}

class CareGiver
{
    var contactType : String? = nil
    var mobile : String? = nil
    var contactDetailId : String? = nil
    var firstName : String? = nil
    var lastName : String? = nil
}
