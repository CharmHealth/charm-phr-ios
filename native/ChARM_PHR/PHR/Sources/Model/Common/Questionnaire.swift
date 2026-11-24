//
//  Questionnaire.swift
//  phr
//
//  Created by Sankar Saravanan on 30/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

class QuestionnaireAnswerModel{
    var questionnaireDetailPOJO: QuestionnaireDetailPOJO? = nil
    var patientObj: Patient? = nil
    var patientInsuranceDetails: PatientInsuranceDetails? = nil
    var insuranceCommonData: InsuranceCommonData? = nil
    var practicePayerList: [PracticePayer] = []
    var isPast: Bool = false
}

class QuestionnaireEntryPOJO{
    var questionnaireEntry: IntakeQuestTemplateEntry = IntakeQuestTemplateEntry()
    var questionnaireOptions: [IntakeQuestTemplateOption] = []
    var questionnaireLabel:IntakeQuestTemplateLabels = IntakeQuestTemplateLabels()
    var questionnaireAllergyList: [IntakeQuestAllergyEntry] = []
    var questionnaireMedicationList: [IntakeQuestPrecriptionEntry] = []
    var questionnaireSupplementList: [IntakeQuestPrecriptionEntry] = []
    var questionnairePersonalDetails: Patient?
    var questionnairePatContacts: Patient?
    var questionnaireInsurance: PatientInsuranceDetails?
    var soapWidget: SOAPWidget? = nil
    var nkda : Bool = false // NO KNOWN DRUG ALLERGIES
    var nkfa : Bool = false // NO KNOWN FOOD ALLERGIES
    var nkea : Bool = false // NO KNOWN ENVOIRMENT ALLERGIES
    var nam : Bool = false // NO ACTIVE MEDICATIONS
    var sectionTag:Int? = nil
}

class QuestionnaireDetailPOJO {
    var questionnairEntryPOJOList: [QuestionnaireEntryPOJO] = []
    var patientId:String?
    var providerId: String?
    var departmentId: String?
    var patientQuesMapId: String?
    var templateId: String?
    var patientQuesMap: PatientQuesMap?
}

class IntakeQuestTemplateEntry{
    var entryId : String  = ""
    var templateId : String = ""
    var notes : String?
    var notesType : String?
    var isMultiChoice : Bool = false
    var fromScale : Int?
    var ratingDescription :[String] = []
    var toScale : Int?
    var position : Int?
    var isDeleted : Bool = false
    var isMandatory : Bool = false
    var answersList:[String]? = []
    var toBeDeleted: Bool = false
    var isCollapsible: Bool? = nil
    var expandByDefault: Bool? = nil
}


class IntakeQuestTemplateOption{
    var optionId : String = ""
    var entryId : String = ""
    var option : String?
}

class IntakeQuestTemplateLabels{
    var fontSize : Int = 14
    var fontStyle : UIFont = UIFont.systemFont(ofSize: 14, Weight: .regular)
    var fontWeightBold : Bool = false
    var textAlign : NSTextAlignment = .left
    var textDecorationUnderline : Bool = false
    var labelId: String = ""
    var entryId: String = ""
    var fontWeight : String = ""
    var textDecoration : String = ""
}
class IntakeQuestAllergyEntry{
    var allergen: String?
    var severity: Severity?
    var type: AllergyType?
    var reactions: String?
}

class IntakeQuestPrecriptionEntry{
    var name: String?
    var intakeDetails: String?
}

class PatientQuesMap{
    var patientQuesMapId: String?
    var appointmentId: String?
    var practicePatientId: String?
    var templateId: String?
    var isFilled: Bool = false
    var allowPhrEditing: Bool?
    var isSubmitted: Bool = false
    var memberId: String?
    var facilityId: String?
    var providerId: String?
    var departmentId: String?
    var lastModifiedTime: String?
    var timeOfSharing: String?
    var randomKey: String?
    var appointment: Appointment?
}

class PhysicianTemplates {
    var templateId: String?
    var memberId: String?
    var name: String?
    var questionnaireType: String?
    var timeOfCreation: String?
    var comments: String?
    var tags: String?
    var isPracticeTemplate: Bool?
    var isDeleted: Bool?
    var isEditable: Bool?
    var customFunction: String?
    var layout: String?
    var patientQuesMap: PatientQuesMap?
    var member: Provider?
    var practiceId: String?
    var toString: String = ""
    var isHealthPassport: Bool = false
}

class SOAPWidget{
    var widgetId: String? = nil
    var templateId: String? = nil
    var widgetName: String? = nil
    var widgetModule: String? = nil
    var tags: String? = nil
    var layout: String? = nil
    var widgetEntries:[SOAPWidgetEntry] = []
}

class SOAPWidgetEntry{
    var entryId: String? = nil
    var widgetId: String? = nil
    var entryName: String? = nil
    var entryType: String? = nil
    var defaultValue: String? = nil
    var entryPosition: Int? = nil
    var customText: String? = nil
    var isValueAccepted: Bool = true
    var isMandatory: Bool = false
    var questionnaireSOAPEntry: QuestionnaireSOAPEntry? = nil
    var propertyList: [SOAPWidgetProperty]? = nil
}

class QuestionnaireSOAPEntry{
    var quesSoapEntryId:String? = nil
    var questionnaireEntryId: String? = nil
    var soapEntryId: String? = nil
    var value: String? = nil
}

class SOAPWidgetProperty{
    var propertyId: String? = nil
    var entryId: String? = nil
    var propertyName: String? = nil
    var propertyValue: String? = nil
}

//MARK: - Flowsheet

class Flowsheets {
    var flowSheetId: String?
    var name: String?
    var createdBy: String?
    var createdOn: String?
    var lastModifiedOn: Date?
    var dataInRows: Bool?
    var showTime: Bool?
    var isAscending: Bool?
    var assignToAllPatients: Bool?
    var isDeleted: Bool?
    var shareToAllPatients: Bool?
    var fillFrequency: String?
    var flowsheetEntries: Array<FlowsheetEntries> = []
    var practiceId: String?
    var allowEdit: Bool = false
    var toString: String = ""
    var phrFlowsheetEntriesList: [PHRFlowsheets] = []
}

class FlowsheetEntries {
    var flowSheetEntryId: String?
    var flowSheetId: String?
    var name: String?
    var type: String?
    var position: Int?
    var unit: String?
    var option: String?
    var fieldType: String?
    var addAdditionalNotes: Bool = false
    var additionalNotesLabel: String?
    var value: String?
    var comments: String?

}

class PHRFlowsheets {
    var phrFlowsheetId: String?
    var practicePatientId: String?
    var flowSheetId: String?
    var time: String?
    var date: Date?
    var flowsheetEntries: Array<FlowsheetEntries> = []
    var practiceId: String?
    var toString: String?
    var flowsheetName: String?
}
