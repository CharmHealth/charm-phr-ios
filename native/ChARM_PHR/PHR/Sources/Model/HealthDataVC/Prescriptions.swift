//
//  Prescriptions.swift
//  phr
//
//  Created by Sankar Saravanan on 18/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

public class MedicationGroupPOJO{
        
    var medicationId: String? = nil
    var medicationName: String? = nil
    var medicationArr: [MedicationPOJO] = []
    var isViewOpened: Bool = false
}

public class MedicationPOJO: NSObject, NSSecureCoding{

    public static var supportsSecureCoding: Bool = true
    
    var medication: Medication? = nil
    var patientMedication: PatientMedication? = nil
    
    override init(){
        super.init()
    }
    
    public func encode(with coder: NSCoder){
        coder.encode(medication, forKey: "medication")
        coder.encode(patientMedication, forKey: "patientMedication")
    }
    
    public required init?(coder: NSCoder){
        medication = coder.decodeObject(forKey: "medication") as? Medication
        patientMedication = coder.decodeObject(forKey: "patientMedication") as? PatientMedication
    }
    
    public func getMedicationDisplayName() -> String{
        var medicationName = ""
        
        if patientMedication?.addedByPatient == true{
            if medication?.intakeUnit?.trim() == "-"{
                medicationName = "\(medication?.medicationName ?? "") \(medication?.numberOfIntake ?? "")"
            }
            else{
                medicationName = "\(medication?.medicationName ?? "") \(medication?.numberOfIntake ?? "") \(medication?.intakeUnit ?? "")"
            }
        }
        else{
            let genericProductName = medication?.genericProductName ?? ""
            if medication?.uiType == medicationUIType1 {
                medicationName = genericProductName
                let tradeName = medication?.tradeName ?? ""
                if tradeName.isNotBlank() {
                    if tradeName != genericProductName {
                        medicationName = "\(tradeName) [ \(genericProductName) ]"
                    }
                }
            }
            else{
                if !(medication?.eRxDisplayName.isNilOrBlank() ?? true){
                    medicationName = medication?.eRxDisplayName ?? ""
                }
                else if genericProductName.isNotBlank(){
                    medicationName = genericProductName
                }
                else{
                    medicationName = medication?.medicationName ?? ""
                }
            }
        }
        return medicationName
    }

    
    public func getIntakeName(separator: String) -> String?{
        
        var intakeString: String? = nil
        if ((patientMedication?.addedByPatient) == true){
            
            var intakeStringArray: [String] = []
            let dosageWithUnit = patientMedication?.dosageWithUnit ?? ""
            let intakeRoute = patientMedication?.intakeRoute ?? ""
            let intake = patientMedication?.intake ?? ""
            let intakeWhen = patientMedication?.intakeWhen ?? ""
            
            intakeStringArray = [dosageWithUnit, intakeRoute, intake, intakeWhen]
            
            intakeStringArray.removeAll { string in
                return string.isBlank()
            }
            if intakeStringArray.joined(separator: ", ").isBlank(){
                intakeString = nil
            }
            else{
                intakeString = intakeStringArray.joined(separator: ", ")
            }
        }
        else{
            intakeString = (patientMedication?.direction.isNilOrBlank() == true) ? nil : patientMedication?.direction
        }
        return intakeString
    }
}

public class Medication: NSObject, NSSecureCoding{
        
    public static var supportsSecureCoding: Bool = true
    
    var medicationId: String? = nil
    var medicationName: String? = nil
    var genericProductName : String? = nil
    var tradeName : String? = nil
    var eRxDisplayName: String? = nil
    var numberOfIntake: String? = nil
    var intakeUnit: String? = nil
    var uiType: String? = nil
    
    override init() {
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(medicationId, forKey: "medicationId")
        coder.encode(medicationName, forKey: "medicationName")
        coder.encode(genericProductName, forKey: "genericProductName")
        coder.encode(tradeName, forKey: "tradeName")
        coder.encode(eRxDisplayName, forKey: "eRxDisplayName")
        coder.encode(numberOfIntake, forKey: "numberOfIntake")
        coder.encode(intakeUnit, forKey: "intakeUnit")
        coder.encode(uiType, forKey: "uiType")
    }
    
    required public init?(coder: NSCoder) {
        medicationId = coder.decodeObject(forKey: "medicationId") as? String
        medicationName = coder.decodeObject(forKey: "medicationName") as? String
        genericProductName = coder.decodeObject(forKey: "genericProductName") as? String
        tradeName = coder.decodeObject(forKey: "tradeName") as? String
        eRxDisplayName = coder.decodeObject(forKey: "eRxDisplayName") as? String
        numberOfIntake = coder.decodeObject(forKey: "numberOfIntake") as? String
        intakeUnit = coder.decodeObject(forKey: "intakeUnit") as? String
        uiType = coder.decodeObject(forKey: "uiType") as? String
    }
}

class PatientMedication: NSObject, NSSecureCoding{
    
    public static var supportsSecureCoding: Bool = true
    
    var patientMedicationId: String? = nil
    var medicationId: String? = nil
    var fromDate: Date? = nil
    var toDate: Date? = nil
    var dosage: String? = nil
    var dosageUnit: String? = nil
    var dosageUnitId: String? = nil
    var dosageWithUnit: String? = nil
    var frequency: String? = nil
    var intake: String? = nil
    var intakeRoute: String? = nil
    var intakeWhen: String? = nil
    var comment: String? = nil
    var prescribedBy : String? = nil
    var dispense: String? = nil
    var refill: String? = nil
    var direction : String? = nil
    var memberId : String? = nil
    var memberName: String? = nil
    var isActive: Bool = false
    var addedByPatient : Bool = false
    var patientId: String? = nil
    var medicalConditionId: String? = nil
    var addedAs : String? = nil // added as encounter or as practice ..
    var practiceId : String? = nil
    var allowRefill: Bool = false
    var reasonForRefill: String? = nil
    var isReminderPresent: Bool = false
    
    override init() {
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(patientMedicationId, forKey: "patientMedicationId")
        coder.encode(medicationId, forKey: "medicationId")
        coder.encode(fromDate, forKey: "fromDate")
        coder.encode(toDate, forKey: "toDate")
        coder.encode(dosage, forKey: "dosage")
        coder.encode(dosageUnit, forKey: "dosageUnit")
        coder.encode(dosageUnitId, forKey: "dosageUnitId")
        coder.encode(dosageWithUnit, forKey: "dosageWithUnit")
        coder.encode(frequency, forKey: "frequency")
        coder.encode(intake, forKey: "intake")
        coder.encode(intakeRoute, forKey: "intakeRoute")
        coder.encode(intakeWhen, forKey: "intakeWhen")
        coder.encode(comment, forKey: "comment")
        coder.encode(prescribedBy, forKey: "prescribedBy")
        coder.encode(direction, forKey: "direction")
        coder.encode(dispense, forKey: "dispense")
        coder.encode(refill, forKey: "refill")
        coder.encode(memberName, forKey: "memberName")
        coder.encode(memberId, forKey: "memberId")
        coder.encode(isActive, forKey: "isActive")
        coder.encode(addedByPatient, forKey: "addedByPatient")
        coder.encode(patientId, forKey: "patientId")
        coder.encode(medicalConditionId, forKey: "medicalConditionId")
        coder.encode(addedAs, forKey: "addedAs")
        coder.encode(practiceId, forKey: "practiceId")
        coder.encode(allowRefill, forKey: "allowRefill")
        coder.encode(reasonForRefill, forKey: "reasonForRefill")
        coder.encode(isReminderPresent, forKey: "isReminderPresent")
    }
    
    required public init?(coder: NSCoder) {
        patientMedicationId = coder.decodeObject(forKey: "patientMedicationId") as? String
        medicationId = coder.decodeObject(forKey: "medicationId") as? String
        fromDate = coder.decodeObject(forKey: "fromDate") as? Date
        toDate = coder.decodeObject(forKey: "toDate") as? Date
        dosage = coder.decodeObject(forKey: "dosage") as? String
        dosageUnit = coder.decodeObject(forKey: "dosageUnit") as? String
        dosageUnitId = coder.decodeObject(forKey: "dosageUnitId") as? String
        dosageWithUnit = coder.decodeObject(forKey: "dosageWithUnit") as? String
        frequency = coder.decodeObject(forKey: "frequency") as? String
        intake = coder.decodeObject(forKey: "intake") as? String
        intakeRoute = coder.decodeObject(forKey: "intakeRoute") as? String
        intakeWhen = coder.decodeObject(forKey: "intakeWhen") as? String
        comment = coder.decodeObject(forKey: "comment") as? String
        prescribedBy = coder.decodeObject(forKey: "prescribedBy") as? String
        dispense = coder.decodeObject(forKey: "dispense") as? String
        refill = coder.decodeObject(forKey: "refill") as? String
        direction = coder.decodeObject(forKey: "direction") as? String
        memberName = coder.decodeObject(forKey: "memberName") as? String
        memberId = coder.decodeObject(forKey: "memberId") as? String
        isActive = coder.decodeBool(forKey: "isActive")
        addedByPatient = coder.decodeBool(forKey: "addedByPatient")
        patientId = coder.decodeObject(forKey: "patientId") as? String
        medicalConditionId = coder.decodeObject(forKey: "medicalConditionId") as? String
        addedAs = coder.decodeObject(forKey: "addedAs") as? String
        practiceId = coder.decodeObject(forKey: "practiceId") as? String
        allowRefill = coder.decodeBool(forKey: "allowRefill")
        reasonForRefill = coder.decodeObject(forKey: "reasonForRefill") as? String
        isReminderPresent = coder.decodeBool(forKey: "isReminderPresent")
    }
}

public class SupplementGroupPOJO{
        
    var supplementId: String? = nil
    var supplementName: String? = nil
    var supplementArr: [SupplementPOJO] = []
    var isViewOpened: Bool = false
}

public class SupplementPOJO: NSObject, NSSecureCoding{
    
    public static var supportsSecureCoding: Bool = true
    
    var supplement: Supplement? = nil
    var patientSupplement: PatientSupplement? = nil
    var isViewOpened: Bool = false
    
    override init(){
        super.init()
    }
    
    public func encode(with coder: NSCoder){
        coder.encode(supplement, forKey: "supplement")
        coder.encode(patientSupplement, forKey: "patientSupplement")
    }
    
    public required init?(coder: NSCoder){
        supplement = coder.decodeObject(forKey: "supplement") as? Supplement
        patientSupplement = coder.decodeObject(forKey: "patientSupplement") as? PatientSupplement
    }
    
    public func getIntakeName(separator: String) -> String?{
        
        var intakeString: String? = nil
        if ((patientSupplement?.isAddedByPatient) == true){
            
            var intakeStringArray: [String] = []
            let dosageWithUnit = patientSupplement?.dosageWithUnit ?? ""
            let intakeRoute = patientSupplement?.intakeRoute ?? ""
            let intake = patientSupplement?.intake ?? ""
            let intakeWhen = patientSupplement?.intakeWhen ?? ""
            
            intakeStringArray = [dosageWithUnit, intakeRoute, intake, intakeWhen]
            
            intakeStringArray.removeAll { string in
                return string.isBlank()
            }
            if intakeStringArray.joined(separator: ", ").isBlank(){
                intakeString = nil
            }
            else{
                intakeString = intakeStringArray.joined(separator: ", ")
            }
        }
        else{
            intakeString = (patientSupplement?.instructions.isNilOrBlank() == true) ? nil : patientSupplement?.instructions
        }
        return intakeString
    }
    
    public func getSupplementDisplayName() -> String{
        
        var supplementName = ""
        if patientSupplement?.isAddedByPatient == true{
            
            if supplement?.intakeUnit == "-"{
                supplementName = "\(supplement?.supplementName ?? "") \(supplement?.numberOfIntake?.trim() ?? "")"
            }
            else{
                supplementName = "\(supplement?.supplementName ?? "") \(supplement?.numberOfIntake?.trim() ?? "") \(supplement?.intakeUnit?.trim() ?? "")"
            }
        }
        else{
            supplementName = supplement?.supplementName ?? ""
        }
        
        return supplementName
    }
}

class Supplement: NSObject, NSSecureCoding{
        
    public static var supportsSecureCoding: Bool = true
    
    var supplementId: String? = nil
    var supplementName: String? = nil
    var manufacturerId: String? = nil
    var manufacturerName: String? = nil
    var numberOfIntake: String? = nil
    var intakeUnit: String? = nil
    
    override init(){
        super.init()
    }
    
    public func encode(with coder: NSCoder){
        coder.encode(supplementId, forKey: "supplementId")
        coder.encode(supplementName, forKey: "supplementName")
        coder.encode(manufacturerId, forKey: "manufacturerId")
        coder.encode(manufacturerName, forKey: "manufacturerName")
        coder.encode(intakeUnit, forKey: "intakeUnit")
        coder.encode(numberOfIntake, forKey: "numberOfIntake")
    }
    
    public required init?(coder: NSCoder){
        supplementId = coder.decodeObject(forKey: "supplementId") as? String
        supplementName = coder.decodeObject(forKey: "supplementName") as? String
        manufacturerId = coder.decodeObject(forKey: "manufacturerId") as? String
        manufacturerName = coder.decodeObject(forKey: "manufacturerName") as? String
        intakeUnit = coder.decodeObject(forKey: "intakeUnit") as? String
        numberOfIntake = coder.decodeObject(forKey: "numberOfIntake") as? String
    }
}

class PatientSupplement: NSObject, NSSecureCoding{
    
    public static var supportsSecureCoding: Bool = true
    
    var patientSupplementId: String? = nil
    var supplementId: String? = nil
    var fromDate: Date? = nil
    var toDate: Date? = nil
    var memberId: String? = nil
    var memberName: String? = nil
    var dosage: String? = nil
    var dosageUnitId: String? = nil
    var dosageUnit: String? = nil
    var dosageWithUnit: String? = nil
    var frequency: String? = nil
    var intake: String? = nil
    var intakeRoute: String? = nil
    var comments: String? = nil
    var intakeWhen: String? = nil
    var instructions: String? = nil
    var isActive: Bool = false
    var isAddedByPatient: Bool = false
    var patientId: String? = nil
    var allowRefill: Bool = false
    var reasonForRefill: String? = nil
    var practiceId: String? = nil
    var isReminderPresent: Bool = false
    
    override init(){
        super.init()
    }
    
    public func encode(with coder: NSCoder){
        coder.encode(patientSupplementId, forKey: "patientSupplementId")
        coder.encode(supplementId, forKey: "supplementId")
        coder.encode(fromDate, forKey: "fromDate")
        coder.encode(toDate, forKey: "toDate")
        coder.encode(memberId, forKey: "memberId")
        coder.encode(memberName, forKey: "memberName")
        coder.encode(dosage, forKey: "dosage")
        coder.encode(dosageUnitId, forKey: "dosageUnitId")
        coder.encode(dosageUnit, forKey: "dosageUnit")
        coder.encode(dosageWithUnit, forKey: "dosageWithUnit")
        coder.encode(frequency, forKey: "frequency")
        coder.encode(intake, forKey: "intake")
        coder.encode(intakeRoute, forKey: "intakeRoute")
        coder.encode(comments, forKey: "comments")
        coder.encode(intakeWhen, forKey: "intakeWhen")
        coder.encode(instructions, forKey: "instructions")
        coder.encode(isActive, forKey: "isActive")
        coder.encode(isAddedByPatient, forKey: "isAddedByPatient")
        coder.encode(patientId, forKey: "patientId")
        coder.encode(allowRefill, forKey: "allowRefill")
        coder.encode(reasonForRefill, forKey: "reasonForRefill")
        coder.encode(practiceId, forKey: "practiceId")
        coder.encode(isReminderPresent, forKey: "isReminderPresent")
    }
    
    public required init?(coder: NSCoder){
        patientSupplementId = coder.decodeObject(forKey: "patientSupplementId") as? String
        supplementId = coder.decodeObject(forKey: "supplementId") as? String
        fromDate = coder.decodeObject(forKey: "fromDate") as? Date
        toDate = coder.decodeObject(forKey: "toDate") as? Date
        memberId = coder.decodeObject(forKey: "memberId") as? String
        memberName = coder.decodeObject(forKey: "memberName") as? String
        dosage = coder.decodeObject(forKey: "dosage") as? String
        dosageUnitId = coder.decodeObject(forKey: "dosageUnitId") as? String
        dosageUnit = coder.decodeObject(forKey: "dosageUnit") as? String
        dosageWithUnit = coder.decodeObject(forKey: "dosageWithUnit") as? String
        frequency = coder.decodeObject(forKey: "frequency") as? String
        intake = coder.decodeObject(forKey: "intake") as? String
        intakeRoute = coder.decodeObject(forKey: "intakeRoute") as? String
        comments = coder.decodeObject(forKey: "comments") as? String
        intakeWhen = coder.decodeObject(forKey: "intakeWhen") as? String
        instructions = coder.decodeObject(forKey: "instructions") as? String
        isActive = coder.decodeBool(forKey: "isActive")
        isAddedByPatient = coder.decodeBool(forKey: "isAddedByPatient")
        patientId = coder.decodeObject(forKey: "patientId") as? String
        allowRefill = coder.decodeBool(forKey: "allowRefill")
        reasonForRefill = coder.decodeObject(forKey: "reasonForRefill") as? String
        practiceId = coder.decodeObject(forKey: "practiceId") as? String
        isReminderPresent = coder.decodeBool(forKey: "isReminderPresent")
    }
}
