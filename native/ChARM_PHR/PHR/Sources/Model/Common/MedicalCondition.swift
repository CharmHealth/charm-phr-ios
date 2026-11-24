//
//  MedicalCondition.swift
//  phr
//
//  Created by Sankar Saravanan on 29/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

class MedicalCondition: DateDelegate {
    
    var medicalConditionMapId : String?
    var name : String?
    var notes : String?
    var dateOfOnset : Date?
    var resolvedDate : Date?
    var medicalConditionId : String?
    var status : String?
    var allowEdit: Bool = false
    var practiceId: String?
    var isViewOpened: Bool = true
    
    func getDate() -> Date {
        return dateOfOnset ?? Date()
    }
}
