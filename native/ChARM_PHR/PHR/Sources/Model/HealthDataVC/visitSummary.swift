//
//  visitSummary.swift
//  phr
//
//  Created by Sankar Saravanan on 29/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import Foundation

class PatientEncounterList{
    var patientEncounterId: String? = nil
    var practiceId: String? = nil
    var physicianId: String? = nil
    var patientId: String? = nil
    var date: Date? = nil
    var reason: String? = nil
    var fileId: String? = nil
    var consultation: Consultation? = nil
    var member: Provider? = nil
    var facility: Facility? = nil
    var readStatus: Bool = false
}

class Consultation{
    var consultationId: String? = nil
    var isApproved: Bool = false
    var createdBy: String? = nil
    var approvedBy: String? = nil
    var timeOfCreation: Date? = nil
    var isRenewal: Bool = false
    var isPaperRecord: Bool = false
    var consultationTitle: String? = nil
    var chartNotesType: String? = nil
    var isBillingNeeded: Bool = true
    var isBilled: Bool = false
    var isOtherInvBilled: Bool = false
    var visitTypeId: String? = nil
    var pricingProfileId: String? = nil
}
