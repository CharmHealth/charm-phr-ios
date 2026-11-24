//
//  Allergies.swift
//  phr
//
//  Created by Sankar Saravanan on 18/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import Foundation

class AllergiesList {
    var allergyId: String?
    var allergy: String?
    var allergyType: String?
    var otherType : String?
    var patientAllergyMap : PatientAllergyMap? = nil
    var isViewOpened: Bool = true
}

class PatientAllergyMap {
    var allergyMapId: String?
    var dateOfEntry: Date?
    var allergyId: String?
    var practicePatientId: String?
    var severity: String?
    var observedDate: Date?
    var resolvedDate : Date?
    var reactions: String?
    var isActive: Bool = false
    //added
    var status : String?
    var isAddedByPatient : Bool = false
    var practiceId : String?
}
