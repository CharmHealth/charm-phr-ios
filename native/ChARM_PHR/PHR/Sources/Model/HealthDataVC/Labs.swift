//
//  Labs.swift
//  phr
//
//  Created by Sankar Saravanan on 08/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

class MedicalRecordGroup {
    var groupId: String?
    var reportStatus: String? //result status
    var labReferenceNumber: String?
    var comments: String?
    var isElectronicallyReceived: Bool = false
    var additionalDetails: String?
    var messageControlId: String?
    var sendingFacility: String?
    var pathologyReviewStatus: String?
    var labName: String?
    var labId: String?
    var labOrderId: String?
    var medicalRecordEntryList : Array<MedicalRecordEntry> = []
    // added
    var isPdfAvailable : Bool = false
    var date : Date?
    var practiceId : String?
    var isAddedByPatient: Bool = false
    var isRead: Bool = false
    var isViewOpened: Bool = false
    var reviewerName: String? = nil

    func isAbnormalResult() -> Bool {
        return medicalRecordEntryList.contains(where: { entry in
            return entry.isAbnormalResult
        })
    }
}

class MedicalRecordEntry {
    var medicalRecordEntryId: String?
    var medicalRecordId: String?
    var patientId: String?
    var date: Date?
    var importedTime: String?
    var pdfDocument: String?
    var importedBy: String?
    var isAbnormalResult: Bool = false
    var isImportedByPatient: Bool = false
    var medicalRecords : MedicalRecords?
    var medicalRecordMapList : Array<MedicalRecordMap> = []
}

class MedicalRecords {
    var medicalRecordId: String?
    var medicalRecordName: String?
    var medicalRecordDisplayName: String?
    var labId: String?
    var isApproved: Bool = false
    var addedBy: String?
}

// added
class MedicalRecordMap {
    var medicalRecordParams : MedicalRecordParams?
    var medicalRecordValues : MedicalRecordValues?
}

class MedicalRecordParams {
    var medicalRecordParamId: String?
    var medicalRecordId: String?
    var parameterName: String?
    var parameterType: String?
    var parameterSubType: String?
    var recordunit: String?
    var testNo: String?
}

class MedicalRecordValues {
    var medicalRecordEntryId: String?
    var medicalRecordParamId: String?
    var recordvalue: String?
    var referenceMax: String?
    var referenceMin: String?
    var interpretation: String?
    var comment : String?
    var range : String?
}



class LabList {
    var labId: String?
    var labName: String?
    var labDisplayName: String?
    var isApproved: Bool = false
    var addedBy: String?
}

class MedicalRecordShareStatus {
    var medicalRecordId: String?
    var sharedBy: String?
    var sharedTo: String?
}

class ConsultationMedRecordsMap {
    var consultationMedMapId: String?
    var medicalRecordEntryId: String?
    var consultationId: String?
}

class ReviewMedicalRecordEntries {
    var reviewMedicalRecordEntryId: String?
    var medicalRecordEntryId: String?
    var reviewerId: String?
    var status: String?
    var reviewComments: String?
    var messageToPatient: String?
    var userMedicalRecordEntryId: String?
}

class PatientPracticeMedRecords {
    var patientPracticeMedRecordId: String?
    var practiceId: String?
    var medicalRecordEntryId: String?
}
 
class UploadesFiles{
    var fileId: String? = nil
    var fileName: String? = nil
    var fileSize: String? = nil
    var timeOfUpload: Int64? = nil
    var isDeleted: Bool = false
    var uploadedBy: String? = nil
    var date: Date? = nil
    var fileType: String? = nil
    var member: Provider? = nil
    var phrFileMap: PHRUploadedFilesMap? = nil
}

class PHRUploadedFilesMap{
    var phrFileMapId: String? = nil
    var senderId: String? = nil
    var receiverId: String? = nil
    var fileId: String? = nil
    var ehrEntryFileId: String? = nil
    var practiceId: String? = nil
    var sharedDate: Date? = nil
    var readStatus: Bool = false
    var messageToPatient: String? = nil
}
