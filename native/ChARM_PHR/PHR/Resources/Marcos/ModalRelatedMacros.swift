//
//  Macros.swift
//  phr
//
//  Created by Sankar Saravanan on 11/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import Foundation
import LocalAuthentication
// TODO(Apptics): disabled until verified; re-enable later
//import AppticsEventTracker
import MobileRTC

let appDelegate : AppDelegate = UIApplication.shared.delegate! as! AppDelegate
let StandardUserDefaults = UserDefaults.standard

//TODO: contents should get moved to appropriate file

// MARK: - HTTP methods
enum HTTP_METHOD {
    case HTTP_METHOD_GET
    case HTTP_METHOD_POST
    case HTTP_METHOD_PUT
    case HTTP_METHOD_DELETE
}

//MARK: - Text View Place Holder

let textViewPlaceHolder = getString(key: "com.charmphr.reminder.addReminder.placeHolder.title")

let UPCOMING = "Upcoming"
let COMPLETED = "Completed"

// MARK: - date display format
let PHR_DATE_DISPLAY_FORMAT = "MMM dd"
let PHR_DATE_DISPLAY_FORMAT_WITH_YEAR = "MMM dd, yyyy"
let PHR_DATE_DISPLAY_FORMAT_WITH_TIME = "MMM dd, yyyy hh:mm a"
let PHR_DATE_DISPLAY_FORMAT_WITH_DAY = "E, MMM dd"
let PHR_DATE_DISPLAY_FORMAT_WITH_DAY_YEAR = "E, MMM dd YYYY"


let sqlTimeStampFormat = "yyyy-MM-dd HH:mm:ss"

let dateOfMonthDateFormat = "dd"
let monthOfYearDateFormat = "MMM"

let PHR_DATE_API_FORMAT = "yyyy-MM-dd"

let ReminderDateWithTimeFormat = "yyyy-MM-dd HH:mm"

let charmDisplayTimeFormat = "hh:mm a"
let dayDisplayFormat = "EEEE"
let FLOWSHEET_DATA_DATE_FORMAT =  "MMM dd, yyyy hh:mm a"

let dateAndTimeWithSlash = "yyyy/MM/dd HH:mm:ss"
let charmDateFormatForGettingSlots = "MM-dd-yyyy"
let charmDateFormatForSlot = "\(PHR_DATE_API_FORMAT) \(charmDisplayTimeFormat)"

let Time24HoursFormat = "HH:mm"

let charmDateFormatForMessageList = "\(PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) \(charmDisplayTimeFormat)"

let alphanumericAndPHRAllowedSplCharacters =  "[a-zA-Z0-9 \\\\`~!@#\\$%^/&amp*()_+\\-=\\[\\]}{;:'\",.?><\n]*" // used the regex which is used in android app
// MARK: - default vitals macros
//

let OTHERS = "Others"
let paymentServiceAppointment = "PHR_APPLICATION_APPOINTMENTS"
let paymentServiceBilling = "PHR_APPLICATION_BILLING"
let paymentServiceBillingTemp = "PHR_BILLING"

let errorPaymentSuccessButReceiptFailedCode = -3

let appointmentPaymentChargeTypeVisitBased = "VISIT_BASED"

let appointmentCardProcessingTypeChargeOnly = "CHARGE_ONLY"
let appointmentCardProcessingTypeStoreCharge = "STORE_CHARGE"
let appointmentCardProcessingTypeStoreOnly = "STORE_ONLY"

let appointmentGatewayTypeBluefin = "BLUEFIN"
let appointmentGatewayTypeRazorpay = "RAZORPAY"

let appointmentTransactionTypeSale = "SALE"
let appointmentTransactionTypeCapture = "CAPTURE"
let appointmentTransactionTypeAuthorization = "AUTHORIZATION"

let appointmentDatePreferenceAnyDate = "ANY_DATE"
let appointmentDatePreferenceSpecificDate = "SPECIFIC_DATE"

let appointmentTimePreferenceAnyTime = "ANY_TIME"
let appointmentTimePreferenceTimeRange = "TIME_RANGE"

let Any_Date = "Any Date"

let errorValueNull = "null"

let medicationUIType1 = "Type1"

let invoiceStatementStr = "Statement"

let appointmentVideoNotStartedErrorCode = 5120

//MARK: - Error Code

let patientSecondaryAccountErrorCode = 29000
let patientCustomAppInvalidUserErrorCode = 29001
let patientPHRPracticeError = 29002
let patientEHRLoginError = 5197
let CUSTOM_ERROR_CODE: Int = 260001

//MARK: - Lab Result

let ABNORMAL = "Abnormal"
let NORMAL = "Normal"

//MARK: - Billing

let Canceled = "Canceled"

//MARK: - Allergies

let ACTIVE = "Active"
let INACTIVE = "Inactive"

//MARK: - Prescription

let MEDICATION = "Medication"
let SUPPLEMENT = "Supplement"
let PRESCRIPTION = "Prescription"

//MARK: - Personal Details and Insurance

let FIRST_NAME_SIZE: Int32 = 50
let LAST_NAME_SIZE: Int32 = 30
let GENDER_IDENTITY_OTHER_SIZE: Int32 = 50
let EMERGENCY_CONTACT_NAME_SIZE: Int32 = 70
let ADDRESS_LINE_1_SIZE: Int32 = 35
let ADDRESS_LINE_2_SIZE: Int32 = 35
let ADDRESS_CITY_SIZE: Int32 = 50
let ADDRESS_STATE_SIZE: Int32 = 50
let ADDRESS_COUNTRY_SIZE: Int32 = 50
let ADDRESS_POSTAL_CODE_SIZE: Int32 = 10
let ADDRESS_POST_BOX_SIZE: Int32 = 4
let CONTACT_EMAIL_ID_SIZE: Int32 = 100
let CONTACT_NUMBER_SIZE: Int32 = 10
let CONTACT_EXTENSION_SIZE: Int32 = 4 

let SSN_LENGTH: Int32 = 11
let INSURANCE_TYPE_SIZE: Int32 = 50
let INSURANCE_PLAN_NAME_SIZE: Int32 = 100
let INSURANCE_POLICY_GROUP_SIZE: Int32 = 50
let INSURANCE_ID_SIZE: Int32 = 30
let INSURANCE_PAYER_NAME_SIZE: Int32 = 250
let INSURANCE_PAYER_ID_SIZE: Int32 = 30
let INSURANCE_COPAY_SIZE: Int32 = 10
let INSURANCE_DEDUCTIBLE_SIZE: Int32 = 10
let INSURANCE_EMPLOYER_NAME_SIZE: Int32 = 100
let INSURANCE_COMMENTS_SIZE: Int32 = 250
let INSURED_PERSON_ADDRESS_LINE1: Int32 = 100
let INSURED_PERSON_ADDRESS_LINE2: Int32 = 100
let PAYER_CITY_SIZE: Int32 = 35
let PAYER_STATE_SIZE: Int32 = 35

// MARK: - Questionnaire macros

let QUESTIONNAIRE_TYPE_ConsentForm = "Consent Form"
let questionnaireCurrentValue = "Current"
let questionnairePastValue = "Past"
let questionnaireNotesTypeLabel = "Label"
let questionnaireNotesTypeAllergy = "Allergies"
let questionnaireNotesTypeMedication = "Medications"
let questionnaireNotesTypeSupplement = "Supplements"
let questionnaireNotesTypeRating = "Rating"
let questionnaireNotesTypeRatingScale = "Rating Scale"
let questionnaireNotesTypeOptionWithOthers = "Question with Options"
let questionnaireNotesTypeOption = "Question with Fixed Options"
let questionnaireNotesTypeYesOrNoOption = "Yes/No Question"
let questionnaireNotesTypeSimpleQuestion = "Simple Question"
let questionnaireNotesTypeQuestion = "Question"
let questionnaireNotesTypeDate = "Date"
let questionnaireNotesTypeSignature = "Signature"
let questionnaireNotesTypePersonalDetails = "Personal Details"
let questionnaireNotesTypePrimaryContactDetail = "Primary Contact Details"
let questionnaireNotesTypeInsurance = "Primary Insurance Details"
let questionnaireNotesTypeSection = "Section"

let questionnaireSOAPTypeReviewOfSystems = "Review of Systems"
let questionnaireSOAPTypeHistoryOfPresentIllness = "History of Present Illness"
let questionnaireSOAPTypeCC = "Chief Complaints"
let questionnaireSOAPTypeSymptoms = "Symptoms"
let questionnaireSOAPTypePastMedicalHistory = "Past Medical History"
let questionnaireSOAPTypeSocialHistory = "Social History"
let questionnaireSOAPTypeFamHistory = "Family History"

let soapYesNoAddtionalCommentYes = "ADDITIONAL_COMMENT_FOR_YES"
let soapYesNoAddtionalCommentNo = "ADDITIONAL_COMMENT_FOR_NO"

let soapRadioAddtionalComment = "ADDITIONAL_COMMENT"
let soapRadioIncludeOthers = "INCLUDE_OTHERS"


let soapWidgetTypeHeading = "Header"
let soapWidgetTypeInstructions = "Instructions"
let soapWidgetTypeTable = "Table"
let soapWidgetTypeCheckList = "Check List"
let soapWidgetTypeSimpleQuestion = "Simple Question"
let soapWidgetTypeTextbox = "Text Box"
let soapWidgetTypeRadio = "Radio"
let soapWidgetTypeCheckbox = "Checkbox"
let soapWidgetTypeRatingScale = "Rating Scale"
let soapWidgetTypeYesOrNo = "Yes/No Question"
let SINGLELINE_MAXLENGTH: Int32 = 255
let MULTILINE_MAXLENGHT: Int32 = 5000
let OTHERS_TF_MAXLENGTH: Int32 = 1000

let questionnaireSupportedWidgets = [questionnaireNotesTypeLabel , questionnaireNotesTypeAllergy , questionnaireNotesTypeMedication , questionnaireNotesTypeSupplement , questionnaireNotesTypeRatingScale,  questionnaireNotesTypeOptionWithOthers , questionnaireNotesTypeOption , questionnaireNotesTypeYesOrNoOption , questionnaireNotesTypeSimpleQuestion , questionnaireNotesTypeQuestion , questionnaireNotesTypeDate , questionnaireNotesTypeSignature , questionnaireNotesTypePersonalDetails , questionnaireNotesTypePrimaryContactDetail, questionnaireNotesTypeInsurance , questionnaireNotesTypeRating, questionnaireNotesTypeSection,questionnaireSOAPTypeReviewOfSystems , questionnaireSOAPTypeHistoryOfPresentIllness,questionnaireSOAPTypeCC,questionnaireSOAPTypeSymptoms, questionnaireSOAPTypeSocialHistory,questionnaireSOAPTypeFamHistory, questionnaireSOAPTypePastMedicalHistory]

let questionnaireSOAPTypeList = [questionnaireSOAPTypeReviewOfSystems , questionnaireSOAPTypeHistoryOfPresentIllness,questionnaireSOAPTypeCC,questionnaireSOAPTypeSymptoms, questionnaireSOAPTypeSocialHistory,questionnaireSOAPTypeFamHistory, questionnaireSOAPTypePastMedicalHistory]


let questionnaireNotesTypeAllergyDrug = "Drug Allergy"
let questionnaireNotesTypeAllergyFood = "Food Allergy"
let questionnaireNotesTypeAllergyEnvironment = "Environmental Allergy"


let questionnairePersonalDetailDeclineToSpecify = "Declined to specify"

let questionnaireNotesTypeAllergySeveritySevere = "Severe"

let questionnaireLabelAlignmentLeft = "left"
let questionnaireLabelAlignmentRight = "right"
let questionnaireLabelAlignmentCenter = "center"
let questionnaireLabelAlignmentJustify = "justify"

let questionnaireLabelAlignmentBold = "bold"
let questionnaireLabelAlignmentItalics = "italic"
let questionnaireLabelAlignmentUnderline = "underline"

let questionnaireNoInsuranceResp = "No insurance available"


let allergySeveritySevere = "Severe"
let allergySeverityModerate = "Moderate"
let allergySeverityMild = "Mild"

let insuranceTypePrimary = "PRIMARY"
let insuranceTypeSecondary = "SECONDARY"

let country_us = "us"
let country_in = "in"
let country_au = "au"

let INDIA = "india"
let UNITED_STATES = "united states"
let AUSTRALIA = "australia"


let isStandardVitalUnitKey = "isStandardVitalUnit"
let laPrefShownKey = "isLocalAuthInfoShown"
let rbacPreferenceKey = "rbacPreferencesString"
let hkPreferenceKey = "healthKitPreferencesString"
let hkScopePreferenceKey = "healthKitScopePreferencesString" // -> for the next scope enhancement, just change the value here. it will take care.

let appointmentModelId: String = "appointment"
let billingModelId: String = "billing"
let invoiceModelId: String = "invoice"
let receiptModelId: String = "receipt"
let cardOnFileModelId: String = "cardOnFile"
let messageModuleId: String = "message"
let labModelId: String = "lab"
let medicationModelId: String = "rx"
let supplementModelId: String = "sx"
let prescriptionModelId: String = "presription"
let allergiesModelId: String = "allergy"
let visitSummaryModelId: String = "visit"
let procedureModelId: String = "procedure"
let vaccineModelId: String = "immunization"
let questionnaireModelId: String = "questionnaire"
let problemListModelId: String = "condition"
let documentModelId: String = "document"
let physicianModelId: String = "physician"
let permissionsModelId: String = "permission"
let wellnessModelId: String = "tracker"
let imagesModelId: String = "image"

let insuranceModelId: String = "insurance"

let flowsheetModelId: String = "symptomTracker"
let reminderModelId: String = "Reminder"
let shareSectionModelId: String = "shareSection"

let announcementModelId: String = "announcement"
let usefulInfoModelId: String = "usefulInfo"
let aboutModelId: String = "about"

let healthPassportModelId: String = "healthpassport"

let wellnessGeneralModelId = "General"
let wellnessWeightModelId = "Weight"
let wellnessHeightModelId = "Height"
let wellnessBMIModelId = "BMI"
let wellnessTemperatureModelId = "Temperature"
let wellnessPulseModelId = "Pulse Rate"
let wellnessBloodGlucoseModelId = "Blood Sugar"

let wellnessBeforeMealModelId = "Before Meal"
let wellnessAfterMealModelId = "Post Prandial"
let wellnessRandomMealModelId = "Random"

let wellnessSleepModelId = "Sleep"
let wellnessOtherModelId = "Others"
let wellnessStepModelId = "Daily Steps"

let wellnessBPModelId = "Blood Pressure"
let wellnessSystolicModelId = "Systolic"
let wellnessDiastolicModelId = "Diastolic"

let listPerPageCount = 200
let newlistPerPageCount = 20

//MARK: -> Flowsheet macros

let flowsheetEntryHeading = "HEADING"
let flowsheetEntryInstruction = "INSTRUCTIONS"
let flowsheetEntryCustom = "CUSTOM"
let flowsheetEntryVital = "VITAL"
let flowsheetEntryLab = "LAB"

let flowsheetCustomSingleLine = "Single Line Text"
let flowsheetCustomMultiLine = "Multi Line Text"
let flowsheetCustomNumber = "Number"
let flowsheetCustomRatingScale = "Rating Scale"
let flowsheetCustomDate = "Date"
let flowsheetCustomDateAndTime = "Date Time"
let flowsheetCustomSingleChoice = "Single Choice Option"
let flowsheetCustomMultiChoice = "Multi Choice Option"

let flowsheetVitalPlainText = "Plain Text"
let flowsheetVitalRatingScale = "Rating Scale"
let flowsheetVitalNumber = "Number"
let flowsheetVitalOption = "Text With Options"

let flowsheetVitalHeight = "Height"
let flowsheetVitalWeight = "Weight"
let flowsheetVitalBMI = "BMI"
let flowsheetVitalSPO2 = "SPO2"
let flowsheetVitalPulseRate = "Pulse Rate"
let flowsheetVitalPulsePattern = "Pulse Pattern"
let flowsheetVitalPulseVolume = "Pulse Volume"
let flowsheetVitalTemperature = "Temperature"
let flowsheetVitalBP = "BP"
let flowsheetVitalChest = "Chest"
let flowsheetVitalWaist = "Waist"
let flowsheetVitalRespiratoryRate = "Respiratory Rate"
let flowsheetVitalRespirationPattern = "Respiration Pattern"
let flowsheetVitalHeadCircumference = "Head Circumference"

let billTypeCreditNote = "Credit Note"

let POUNDS = "lbs"
let OUNCES = "ozs"
let FEET = "feet"
let INCHES = "inches"
let CM = "cm"
let CMS = "cms"
let KG = "kg"
let KGS = "kgs"
let LBS = "lbs"
let LB = "lb"
let INCH = "inch"
let BMI = "BMI"
let HEIGHT = "height"
let WEIGHT = "weight"
let bmi = "bmi"
let Pulse_Rate = "pulse rate"
let Temperature = "temperature"
let Temperature_Celsius = "C"
let Temperature_Fahrenheit = "F"
let BP_Systolic = "systolic"
let BP_Diastolic = "diastolic"

let HEAD_CIRCUMFERENCE = 200
let PULSE_RATE = 200
let SPO2 = 100
let FAHRENHEIT = 110
let CELSIUS = 43
let CHEST = 200
let WAIST = 200
let RESPIRATORY_RATE = 50
let SYSTOLIC = 200
let DIASTOLIC = 150
let HEIGHT_FEET = 10
let HEIGHT_INCH = 12
let WEIGHT_POUNDS = 440
let WEIGHT_OUNCES = 16
let WEIGHT_KGS = 250
let HEIGHT_CMS = 300
let HEIGHT_INCHES = 120
let MINUTES = 300
let PERCENTAGE = 100
let MILLI_LITRE = 6000
let HOURS = 24
let CharacterLength = 500
let NUMBER_MAX_VALUE = 10000


let weightMaxVal: Double = 150
let weightMinVal: Double = 5
let heightMaxVal: Double = 210
let heightMinVal: Double = 50
let bpSystolicMaxVal = 200
let bpSystolicMinVal = 90
let bpDiastolicMaxVal = 100
let bpDiastolicMinVal = 60
let temperatureCelsiusMaxVal = 39.0
let temperatureCelsiusMinVal = 36.0
let temperatureFahrenheitMaxVal = 103.0
let temperatureFahrenheitMinVal = 97.0
let pulseRateMaxValue = 100
let pulseRateMinValue = 60
let spo2MaxValue = 101
let spo2MinValue = 95
let respiratoryRateMaxValue = 25
let respiratoryRateMinValue = 12

//MARK: - Reminder

let HISTORY_LABEL: String = getString(key: "com.charmphr.reminder.all.item.history.title")
let WEEK = "week"
let DAY = "day"

//MARK: - Vital Unit

let vitalUnitStandard = "Standard"
let vitalUnitMetric = "Metric"

//MARK: - Document

let SHARE_LABEL: String = getString(key: "com.charmphr.action.share")
let UNSHARE_LABEL: String = getString(key: "com.charmphr.Document.unshare.title")
let DELETE_LABEL: String = getString(key: "com.charmphr.action.delete")
//MARK: - Appointment

let telemode_PHR: String = "PHR"
let telemode_KIOSK: String = "KIOSK"

let appointmentTypeInPerson = "In Person"
let appointmentTypePhoneCall = "Phone call"
let appointmentTypeVideoCall = "Video Consult"

func convertUTCtoDevice(_ millisString: String?) -> Date? {
    guard let millisString, let millis = Int64(millisString) else { return nil }
    let seconds = Double(millis) / 1000.0
    return Date(timeIntervalSince1970: seconds)
}

//MARK: - Share Section [SS]

let SS_Medications: String = "Medications"
let SS_Supplements: String = "Supplements"
let SS_Immunizations: String = "Immunizations"
let SS_Wellness: String = "Wellness"
let SS_Labs: String = "Labs"
let SS_Allergies: String = "Allergies"
let SS_Procedures: String = "Procedures"
let SS_ProblemList: String = "Problem List"
let SS_Diet: String = "Diet"
let SS_Therapies: String = "Therapies"

let shareSectionList: [String] = [SS_Medications, SS_Supplements, SS_Labs, SS_Allergies,SS_ProblemList , SS_Procedures, SS_Immunizations, SS_Wellness]
let sectionExcludeList: [String] = [SS_Diet,SS_Therapies]

//MARK: - Push Notification

let deviceTokenKey = "DeviceToken"
let installationIdKey = "InstallationId"
let isPushNotificationRegistered = "isPushNotificationRegistered"

//MARK: - User Functions
func isCustomApp() -> Bool{
    return AppConfig.sharedInstance.isCustomBrandApp
}


func getSelectedPatient() -> Patient{
    return Patient.selectedPatientInstance ?? Patient()
}

func getPatientObj(patientId: String?) -> Patient?{
    return Patient.patientList?.first { patient in
        return patient.patientId == patientId
    }
}

func getSelectedPatientId() -> String{
    return Patient.selectedPatientInstance?.patientId ?? ""
}

func getBluefinEnabledPractices(patient: Patient? = nil) -> [Practice]{

    var practiceList = Patient.selectedPatientInstance?.practiceList ?? []
    
    if let patient = patient {
        practiceList = patient.practiceList
    }
    
    return practiceList.filter({ practice in
        practice.isActive && practice.isBluefinEnabled
    })
}
func getBluefinEnabledPracticeId(patient: Patient? = nil) -> [String]{
    return getBluefinEnabledPractices(patient: patient).map({practice in practice.practiceId ?? ""})
}

func getEnabledPractices(moduleId: String , selectedPatient: Patient? = nil) -> [String]{
    
    if isCustomApp() {
        return Patient.selectedPatientInstance?.practiceList.map({practice in practice.practiceId ?? ""}) ?? []
    }
    else{
        
        var sectionConfig = AppDataHandler.sharedInstance().selectedPatientSection
        
        if selectedPatient != nil {
            sectionConfig = selectedPatient?.sectionConfigList
        }
        
        return sectionConfig?.sectionConfigMapList.filter({sectionConfigMap in
            sectionConfigMap.sectionConfigList.first(where: {section in
                section.section == moduleId
            })?.isEnable != false
        }).map({sectionConfigMap in
            sectionConfigMap.practiceId ?? ""
        }) ?? []
    }
}

func getPractice(practiceId: String) -> Practice?{
    return Patient.selectedPatientInstance?.practiceList.first { practice in
        return practice.practiceId == practiceId
    }
}

func getActivePracticeId() -> [String]{
    
    let practiceList = Patient.selectedPatientInstance?.practiceList ?? []
    
    return practiceList.filter({ practice in
        practice.isActive
    }).map({practice in practice.practiceId ?? ""})
}

func getActivePracticeList() -> [Practice]{
    let practiceList = Patient.selectedPatientInstance?.practiceList ?? []
    
    return practiceList.filter({ practice in
        practice.isActive
    }).map({practice in practice})
}

func getActivePractice() -> [Practice]{
    
    let practiceList = Patient.selectedPatientInstance?.practiceList ?? []
    
    return practiceList.filter({ practice in
        practice.isActive
    })
}

func isModuleEnabled(moduleId: String, selectedPatient: Patient? = nil) -> Bool{
        
    var sectionConfig = AppDataHandler.sharedInstance().selectedPatientSection
    
    if selectedPatient != nil {
        sectionConfig = selectedPatient?.sectionConfigList
    }
    
    if let sectionConfigBool = sectionConfig?.sectionConfigMapList.map({sectionConfigMap in
         sectionConfigMap.sectionConfigList.first(where: {section in
            section.section == moduleId
        })?.isEnable == true
    }) {
        return sectionConfigBool.contains(true)
    }
    
    return false
}

func isPHREntryEnabled(moduleId: String) -> Bool {
    let sectionConfig = AppDataHandler.sharedInstance().selectedPatientSection
    
    
    return sectionConfig?.sectionConfigMapList.map({sectionConfigMap in
        sectionConfigMap.sectionConfigList.first(where: {section in
            section.section == moduleId
        })?.allowPhrEntry != false
    }).contains(true) ?? true
}

func getPHREntryEnabledPractices(moduleId: String , selectedPatient: Patient? = nil) -> [Practice]{
    
    if isCustomApp() {
        return Patient.selectedPatientInstance?.practiceList ?? []
    }
    else{
        
        var sectionConfig = AppDataHandler.sharedInstance().selectedPatientSection
        
        if selectedPatient != nil {
            sectionConfig = selectedPatient?.sectionConfigList
        }
        
        
        let practiceIdList = sectionConfig?.sectionConfigMapList.filter({sectionConfigMap in
            sectionConfigMap.sectionConfigList.first(where: {section in
                section.section == moduleId
            })?.allowPhrEntry != false
        }).map({sectionConfigMap in
            sectionConfigMap.practiceId ?? ""
        }) ?? []
        
        let practiceList = Patient.selectedPatientInstance?.practiceList ?? []
        
        return practiceList.filter({ practice in
            practiceIdList.contains( practice.practiceId ?? "") && practice.isActive
        })
    }
}

func isPracticeEnabled(moduleId: String, practiceId: String , selectedPatient: Patient? = nil) -> Bool {
    
    let enabledPractices = getEnabledPractices(moduleId: moduleId, selectedPatient: selectedPatient)
    return enabledPractices.isEmpty || enabledPractices.contains(practiceId)
}

func getModule(moduleId: String) -> Section? {
    let sectionConfig = AppDataHandler.sharedInstance().selectedPatientSection
    
    return sectionConfig?.sectionConfigMapList.firstOrNil()?.sectionConfigList.first(where: {section in
        section.section == moduleId
    })
}


func isMeetingInProgress() -> Bool {
    
    if let meetingService = MobileRTC.shared().getMeetingService() {
        
        let meetingStatus = meetingService.getMeetingState()
        if meetingStatus != .idle && meetingStatus != .disconnecting && meetingStatus != .ended && meetingStatus != .failed{
            
            return true
        }
    }
    
    return false
}


func getIntialsFromSenderName(name : String) -> String
{
    
    var initialStr = ""
    let nameArr = name.split(separator: " ")
    
    for nameStr in nameArr
    {
        if !nameStr.lowercased().contains("dr.")
        {
            initialStr.append(String(nameStr).first?.uppercased() ?? "")
        }
        
        if initialStr.count == 2
        {
            return initialStr
        }
    }
    
    return initialStr
}

func isAmountValid(amount: String?)-> Bool {
    if (!amount.isNilOrBlank()) {

        let amt = amount?.toFloatOrNil()
        if let amt: Float = amt {
            return amt > 0
        }
    }
    return false
}

func timeStringAccordingToDate(timeString : String , dateString : String) -> String
{
            

    let dobj = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: dateString)
    let dateObj = dobj == nil ? Date() : dobj!
    
    let calender = Calendar(identifier: .gregorian)
    
    if calender.isDateInToday(dateObj)
    {
        return timeString
    }
    
    return CharmUtil.getDisplayDateStringAndToday(date: dateObj , showTimeForToday: false)
}


func backButton(withTitle string : String) -> UIBarButtonItem
{
    let backItem = UIBarButtonItem()
    backItem.title = string
    return backItem
}

//TODO: add this nil or empty check in strings extension and replace this method
func isNilOrEmpty(string : String?) -> Bool
{
    if string == nil || string == ""
    {
        return true
    }else
    {
        return false
    }
}

func onInsuranceTypeChange(insuranceType: String?) -> InsuranceTypeChange{

    let insuranceTypeChange = InsuranceTypeChange()

    if (insuranceType == "MEDICARE"){
        insuranceTypeChange.planName = insuranceType
        insuranceTypeChange.memberIdLabel = getString(key: "com.charmphr.insurance.id.medicare.label")
    }
    else if (insuranceType == "MEDICAID"){
        insuranceTypeChange.planName = insuranceType
        insuranceTypeChange.memberIdLabel = getString(key: "com.charmphr.insurance.id.medicaid.label")
    }
    else if (insuranceType == "TRICARE CHAMPUS"){
        insuranceTypeChange.memberIdLabel = getString(key: "com.charmphr.insurance.id.sponser.label")
    }
    else if (insuranceType == "CHAMPVA"){
        insuranceTypeChange.memberIdLabel = getString(key: "com.charmphr.insurance.id.member.label")
    }
    else if (insuranceType == "FECA BLK LUNG"){
        insuranceTypeChange.memberIdLabel = getString(key: "com.charmphr.insurance.id.ssn.label")
    }
    else{
        insuranceTypeChange.memberIdLabel = getString(key: "com.charmphr.insurance.id.label")
    }

    return insuranceTypeChange
}


enum RBACPrivileges: Int {
    case ADD_WELLNESS
    case VIEW_WELLNESS
    case EDIT_WELLNESS
    case DELETE_WELLNESS

    
    //reports
    case VIEW_REPORTS

    //insurance
    case ADD_INSURANCE
    case VIEW_INSURANCE
    case EDIT_INSURANCE
    case DELETE_INSURANCE

    //immune
    case ADD_IMMUNE
    case VIEW_IMMUNE
    case EDIT_IMMUNE
    case DELETE_IMMUNE

    //procedure
    case ADD_PROCEDURE
    case VIEW_PROCEDURE
    case EDIT_PROCEDURE
    case DELETE_PROCEDURE

    //allergies
    case ADD_ALLERGIES
    case VIEW_ALLERGIES
    case EDIT_ALLERGIES
    case DELETE_ALLERGIES

    //labresults
    case ADD_LABRESULTS
    case VIEW_LABRESULTS
    case EDIT_LABRESULTS
    case DELETE_LABRESULTS

    //laborders
    case VIEW_LABORDERS

    //medications
    case ADD_MEDICATIONS
    case VIEW_MEDICATIONS
    case EDIT_MEDICATIONS
    case DELETE_MEDICATIONS

    //supplements
    case ADD_SUPPLEMENTS
    case VIEW_SUPPLEMENTS
    case EDIT_SUPPLEMENTS
    case DELETE_SUPPLEMENTS

    //invoice
    case VIEW_INVOICE
    case VIEW_RECEIPT
    case ADD_PAYMENT

    //visitsummary
    case VIEW_VISITSUMMARY

    //questionnaire
    case VIEW_QUESTIONNAIRE
    case SUBMIT_QUESTIONNAIRE

    //documents
    case VIEW_DOCUMENTS
    case ADD_DOCUMENTS
    case  DELETE_DOCUMENTS
    case EXPORT_DOCUMENTS
    case VIEW_FOLDERS
    case ADD_FOLDERS
    case EDIT_FOLDERS
    case DELETE_FOLDERS

    //messages
    case VIEW_MESSAGES
    case ADD_MESSAGES
    case DELETE_MESSAGES

    //flowsheetdata
    case ADD_FLOWSHEETDATA
    case EDIT_FLOWSHEETDATA
    case DELETE_FLOWSHEETDATA
    case VIEW_FLOWSHEETDATA

    //appointment
    case ADD_APPOINTMENT
    case VIEW_APPOINTMENT
    case DELETE_APPOINTMENT
    case CANCEL_APPOINTMENT

    //clinicalsummary
    case VIEW_CLINICALSUMMARY
    case EXPORT_CLINICALSUMMARY

    //usefulinfo
    case VIEW_USEFULINFO

    //phrdata
    case EXPORT_PHRDATA

    //cardonfile
    case VIEW_CARDONFILE
    case ADD_CARDONFILE

    //section_config
    case VIEW_SECTION_CONFIG
    case EDIT_SECTION_CONFIG

    //familymembers
    case VIEW_FAMILYMEMBERS
    case EDIT_FAMILYMEMBERS

    //Not added Modules

    //healthchannel
    case VIEW_HEALTHCHANNEL

    //growthchart
    case VIEW_GROWTHCHART

    //library
    case VIEW_LIBRARY

    //therapy
    case ADD_THERAPY
    case VIEW_THERAPY
    case EDIT_THERAPY
    case DELETE_THERAPY

    //diet
    case ADD_DIET
    case VIEW_DIET
    case EDIT_DIET
    case DELETE_DIET

    //problem
    case ADD_PROBLEM
    case VIEW_PROBLEM
    case EDIT_PROBLEM
    case DELETE_PROBLEM

    //Images
    case VIEW_IMAGERESULTS
    case VIEW_IMAGEORDERS

    //timeline
    case VIEW_TIMELINE

    //announcements
    case VIEW_ANNOUNCEMENTS

    //Store
    case  VIEW_ONLINESTORE

    //doctors
    case ADD_DOCTORS
    case VIEW_DOCTORS
    case EDIT_DOCTORS
    case DELETE_DOCTORS

    //pharmacy
    case ADD_PHARMACY
    case VIEW_PHARMACY
    case  EDIT_PHARMACY
    case DELETE_PHARMACY

    //hospitals
    case ADD_HOSPITALS
    case VIEW_HOSPITALS
    case EDIT_HOSPITALS
    case DELETE_HOSPITALS

    //othercontact
    case ADD_OTHERCONTACT
    case VIEW_OTHERCONTACT
    case EDIT_OTHERCONTACT
    case DELETE_OTHERCONTACT

    //audits
    case VIEW_AUDITS

    //accountinfo
    case VIEW_ACCOUNTINFO
    case EDIT_ACCOUNTINFO

    //password
    case EDIT_PASSWORD

    //healthpassport
    case VIEW_HEALTHPASSPORT
    case EDIT_HEALTHPASSPORT
    case EXPORT_HEALTHPASSPORT

    //healthcard
    case VIEW_HEALTHCARD

    //other_associated_members
    case VIEW_OTHER_ASSOCIATED_MEMBERS

    //practicedetials
    case VIEW_PRACTICEDETIALS

    //All Privilege User
    case FULL_ACCESS

    //No access
    case NO_ACCESS
}


class AddDataUIViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let backButton = UIButton(type: .custom)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if navigationController?.interactivePopGestureRecognizer?.delegate === self {
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backIconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold, scale: .large)
        let backicon = UIImage(systemName: "chevron.backward", withConfiguration: backIconConfig)?.withRenderingMode(.alwaysTemplate)
        
        if #available (iOS 26.0, *){
            backButton.setImage(backicon, for: .normal)
            backButton.tintColor = .label
        }
        else{
            backButton.setProperties(titleStrKey: getString(key: "com.charmphr.action.back"), fontsize: 17, weight: .regular, fontcolor: THEME_COLOR)
            backButton.setTitleColor(.systemBlue, for: .normal)
            
            let backicon = UIImage(systemName: "chevron.backward", withConfiguration: backIconConfig)?.withRenderingMode(.alwaysOriginal)
            var config = UIButton.Configuration.plain()
            config.image = backicon
            config.imagePadding = 6
            config.contentInsets = .zero
            config.baseForegroundColor = .systemBlue
            backButton.configuration = config
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.addTarget(self, action: #selector(onBackClick), for: .touchUpInside)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        onBackClick()
        return false
    }
    
    @objc open func onBackClick(){
    }
    
    func showDiscardChangesDialog(callback: (() -> Void)? = nil){
        CharmUtil.showDiscardChangesAlert(discardBtnAction: {
            if let navController = self.navigationController{
                navController.popViewController(animated: true)
            }
            else{
                self.dismiss(animated: true)
            }
            callback?()
        }, barButtonItem: navigationItem.leftBarButtonItem)
    }
}

enum MDEventGroup: String {
    case appointment = "Appointment"
}

enum MDEvent : String{
    case bookAppointmentSucess = "BookAppointmentOnSuccess"
    case bookAppointmentFailure = "BookAppointmentOnFailure"
}

class EventUtil {
    func sendEvent(group: MDEventGroup, event: MDEvent)  {
        trackEvent(eventName: event.rawValue, withGroupName: group.rawValue)
    }
}

func trackEvent(eventName: String, withGroupName: String)  {
    // TODO(Apptics): disabled until verified; re-enable later
//    APEvent.trackEvent(eventName, withGroupName: withGroupName)
}

class RbacUtil {
    
    private static var privilegeArrList: [RBACPrivileges] = []

    class func resetInstance(){
        privilegeArrList = []
    }
    
    static func savePrivileges(privilegeList: [RBACPrivileges]){
        
        let privilegeRawInt = privilegeList.map({privilege in
            privilege.rawValue
        })
        
        StandardUserDefaults.set(privilegeRawInt , forKey: rbacPreferenceKey)
        privilegeArrList = privilegeList
    }
    
    static func updatePrivileges() {
        
        if let privilegeIntList = StandardUserDefaults.object(forKey: rbacPreferenceKey) as? [Int] {
            
            let privilegeTempList = privilegeIntList.map({privilege in
                RBACPrivileges(rawValue: privilege) 
            })
            
            let privilegeList: [RBACPrivileges] = privilegeTempList.filter({ privilege in
                privilege != nil
            }).map({privilege in
                privilege!
            })
            
            privilegeArrList = privilegeList
        }
        privilegeArrList = []
    }
    
    static func checkPrivilege(privilege: RBACPrivileges) -> Bool {
        return privilegeArrList.contains(.FULL_ACCESS) || privilegeArrList.contains(privilege)
    }

}



enum LAError {
    case noAuth
    case failed
    case cancelled
    
//    func getLocalisedMessage() -> String
//    {
//        if self == .noAuth {
//            return getString(key: "com.charmphr.local.authentication.noauth.message")
//        }
//        else if self == .failed {
//            return getString(key: "com.charmphr.local.authentication.failed.message")
//        }
//        return ""
//    }
}

class PermissionUtil {
    
    static func hasLocalAuthentication(laPolicy: LAPolicy = .deviceOwnerAuthentication) -> Bool {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            return true
        }
        else{
            return false
        }
    }
    
    static func evaluateAuthentication(laPolicy: LAPolicy = .deviceOwnerAuthentication , success: @escaping () -> Void, failure: @escaping (LAError) -> Void){
        
        let context = LAContext()
        let appName: String = AppConfig.sharedInstance.appDisplayName ?? "PHR"
        let message = getString(key: "com.charmphr.local.authentication.message", with: [appName])
        
       // var error: NSError? = nil
        if context.canEvaluatePolicy(laPolicy, error: nil) {
            context.evaluatePolicy(laPolicy, localizedReason: message, reply: { isSuccess , error in
                
                DispatchQueue.main.async {
                    if isSuccess {
                        success()
                    }
                    else{
                        if laPolicy == .deviceOwnerAuthenticationWithBiometrics {
                            PermissionUtil.evaluateAuthentication(success: success, failure: failure)
                        }
                        else{
                            var isErrorSent = false
                            if let error = error as? NSError {
                    
                                //error.code == -2 ||
                                if error.code == -4  {
                                    isErrorSent = true
                                    failure(.cancelled)
                                }
                                
                                debugPrintLog("\(error.code) ; \(error.localizedDescription)")
                                
                            }
                            
                            if !isErrorSent {
                                failure(.failed)
                            }
                            
                        }
                    }
                }
            })
            
        }
        else {
            if laPolicy == .deviceOwnerAuthenticationWithBiometrics {
                PermissionUtil.evaluateAuthentication(success: success, failure: failure)
            }
            else{
                failure(.noAuth)
            }
        }
        
    }
}
