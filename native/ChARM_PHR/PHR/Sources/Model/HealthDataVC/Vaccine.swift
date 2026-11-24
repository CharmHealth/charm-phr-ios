//
//  Vaccine.swift
//  phr
//
//  Created by Sankar Saravanan on 10/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

class Vaccine {
    var immunizationName : String!
    var immunizationType : String!
    var immunizationHistoryId : String!
    var immunizationId : String!
    var howAdministered : String!
    var givenBy : String!
    var comments : String!
    var manufacturer : String!
    var immunizationMapId : String!
    var addedByPatient : Bool!
    var immunizationDate : Date!
    var route : String!
    var site : String!
    var completionStatus : String!
    var practiceId : String!
    var orderingProvider : String!
    var refusalReason : String!
    var administeredAmount : String!
    var prescribedBy : String!
    
    var evidenceOfImmunity : String!
    var isAdministered : Bool!
    var vaccinationTime : String!
}

class VaccinesList{
    var vaccineId: String? = nil
    var cvxCode: String? = nil
    var vaccineName: String? = nil
    var vaccineDetails: String? = nil
    var addedBy: String? = nil
}

class PatientVaccineMap{
    var vaccineMapId: String? = nil
    var patientId: String? = nil
    var vaccineId: String? = nil
    var dateOfVaccination: Date? = nil
    var administeredAmount: String? = nil
    var administeredUnits: String? = nil
    var vaccineLotNumber: String? = nil
    var vaccineManufacturerId: String? = nil
    var vaccineNotes: String? = nil

    var vaccine: VaccinesList? = nil
    var vaccineManufactures: VaccineManufactures? = nil
    var orderingProvider: Provider? = nil
    var route: String? = nil
    var site: String? = nil
}

class VaccineManufactures{
    var vaccineManufacturerId: String? = nil
    var manufacturerName: String? = nil
    var manufacturerCode: String? = nil
}


class ImmunizationList{
    var immunizationId: String? = nil
    var immunizationName: String? = nil
    var immunizationType: String? = nil
    var patientCount: String? = nil
    var approvalStatus: String? = nil
    var addedBy: String? = nil
}

class PatientImmunizationMap{
    var immunizationMapId: String? = nil
    var patientId: String? = nil
    var immunizationId: String? = nil
    var immunizationList: ImmunizationList? = nil
    var patientImmunizationHistory: PatientImmunizationHistory? = nil
}

class PatientImmunizationHistory{
    var immunizationHistoryId: String? = nil
    var immunizationMapId: String? = nil
    var vaccinesOn: Date? = nil
    var givenBy: String? = nil
    var howAdministered: String? = nil
    var manufacturer: String? = nil
    var comments: String? = nil
}


class VaccineImmunizationPOJO{

    var addedByPatient: Bool = true
    var patientImmunizationMap: PatientImmunizationMap? = nil
    var patientVaccineMap: PatientVaccineMap? = nil
    var practiceId: String? = nil
    var toString: String = ""
    var isViewOpened: Bool = false
}
