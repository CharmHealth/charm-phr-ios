//
//  PatientMObj+CoreDataClass.swift
//  phr
//
//  Created by prathi-13964 on 30/08/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PatientMObj)
public class PatientMObj: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PatientMObj> {
        return NSFetchRequest<PatientMObj>(entityName: "PatientMObj")
    }
    
    @NSManaged public var medicationPOJOArr: [MedicationPOJO]?
    @NSManaged public var patientData: PatientData?
    @NSManaged public var reminderArr: [Reminder]?
    @NSManaged public var supplementPOJOArr: [SupplementPOJO]?
    @NSManaged public var patientId: String?
    
    func fillWithPropertiesFromPatientObj(patient: Patient){
        patientId = patient.patientId
        let patientData = PatientData()
        
        if let dob = patient.dob{
            patientData.dob = CharmUtil.getDateObjectWith(dateString: dob, dateFormat: PHR_DATE_API_FORMAT)
        }
        patientData.firstName = patient.firstName
        patientData.lastName = patient.lastName
        patientData.fullName = patient.fullName
        patientData.gender = patient.gender
        
        patientData.practiceList = patient.practiceList
        
        self.patientData = patientData
    }
}
