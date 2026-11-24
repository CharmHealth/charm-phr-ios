//
//  ParsingHelper.swift
//  phr
//
//  Created by Sankar Saravanan on 12/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

//TODO: 1. add pragma mark for respective modules

//TODO: 2. id's are stored as long in many places. We need to replace those with strings (have to check each and every modal)

import UIKit
import Foundation

struct ParsingHelper{
    
//MARK: - Patient
    
    static func fillArrayOfPatientWithDictionary(dictionary :Dictionary<String, Any>) -> Any
    {
        var arrayOfPatient : [Patient] = []
            
        
        var isSecondaryAccountFound = false
        
        if let patientArr = dictionary["output_string"] as?  [Dictionary<String,Any>]{
            
            if patientArr.isEmpty {
                return NSError(domain: getString(key: "com.charmphr.ehr.login.error"), code: patientEHRLoginError)
            }
            
            for dict in patientArr
            {
                
                if dict.getBoolean("SECONDARY_ACCOUNT") == true {
                    isSecondaryAccountFound = true
                    break
                }
                
                
                let patient = Patient()
                    
                if (dict["PATIENT_ID"] != nil)
                {
                    patient.patientId = dict["PATIENT_ID"] as? String
                }
                
                if (dict["AGE"] != nil)
                {
                    patient.age = dict["AGE"] as? Int
                }
                
                if (dict["FIRST_NAME"] != nil)
                {
                    patient.firstName = dict["FIRST_NAME"] as? String
                }
                    
                if (dict["LAST_NAME"] != nil)
                {
                    patient.lastName = dict["LAST_NAME"] as? String
                }
                
                if (patient.firstName ?? "").isNotBlank() && (patient.lastName ?? "" ).isNotBlank() {
                    patient.fullName = "\(patient.firstName ?? "") \(patient.lastName ?? "")"
                }
                else if (patient.firstName ?? "").isNotBlank() {
                    patient.fullName = patient.firstName ?? ""
                }
                else if (patient.lastName ?? "").isNotBlank() {
                    patient.fullName = patient.lastName ?? ""
                }
                
                
                
                if (dict["GENDER"] != nil)
                {
                    patient.gender = dict["GENDER"] as? String
                }
                
                if (dict["IS_PHOTO_AVAILABLE"] != nil)
                {
                    patient.isPhotoAvailable = (dict["IS_PHOTO_AVAILABLE"] as? Bool)!
                }
                
                if (dict["DATE_OF_BIRTH"] != nil)
                {
                    let dobStr = dict["DATE_OF_BIRTH"] as? String ?? ""
                    patient.dob = dobStr //dict["DATE_OF_BIRTH"] as? String
                    
                    if dobStr.isNotBlank() {
                        patient.dateOfBirth = Date.getDateFromString(dateFormat: PHR_DATE_API_FORMAT, dateString: dobStr)
                    }
                }
                
               
                
                patient.isHealthPassportAvailable = dict.getBoolean("IS_HEALTH_PASSPORT_AVAILABLE") ?? false
                
        //            if (dict["blood_group"] != nil)
        //            {
        //                patient.bloodGroup = dict["blood_group"] as? String
        //            }
                    
                let practiceDictArr = dict["PRACTICES_LIST"] as! [Dictionary<String,Any>]
                var praticeNameArr : Array<String> = []
                for practiceDict in practiceDictArr
                {
                    if practiceDict.count > 0
                    {
                        let practice = Practice()
                        
                        practice.isBluefinEnabled = practiceDict.getBoolean("IS_BLUEFIN_ENABLED") ?? false

                        practice.easycareURL = practiceDict.getString("EASYCARE_URL")

                        if (practiceDict["PRACTICE_NAME"] != nil)
                        {
                            practice.practiceName = practiceDict["PRACTICE_NAME"] as? String
                        }
                            
                        if (practiceDict["FIRST_FACILITY_NAME"] != nil)
                        {
                            practice.firstFacilityName = practiceDict["FIRST_FACILITY_NAME"] as? String
                        }
                        
                        if (practiceDict["PRACTICE_ID"] != nil)
                        {
                            practice.practiceId = practiceDict["PRACTICE_ID"] as? String
                        }
                        
                        if (practiceDict["FACILITIES_COUNT"] != nil)
                        {
                            practice.facilitiesCount = practiceDict["FACILITIES_COUNT"] as? Int ?? 0
                        }
                        
                        if (practiceDict["FACILITIES_LIST"] != nil)
                        {
                            practice.facilitiesList = practiceDict["FACILITIES_LIST"] as? String
                            
                            if let facilityList = practice.facilitiesList {
                                if facilityList.hasSuffix(",")
                                {
                                    practice.facilitiesList = String(facilityList.dropLast(1))
                                }
                                else if facilityList.hasSuffix(", ")
                                {
                                    practice.facilitiesList = String(facilityList.dropLast(2))
                                }
                            }
                        }
                        
                        if (practiceDict["IS_ACTIVE"] != nil)
                        {
                            practice.isActive = practiceDict["IS_ACTIVE"] as? Bool ?? false
                        }
                        
                        if isCustomApp()
                        {
                            if practice.isActive && practice.practiceId == AppConfig.sharedInstance.customAppPracticeId
                            {
                                praticeNameArr.append(practice.practiceName ?? "")
                                patient.practiceList.append(practice)
                            }
                        }else
                        {
                            if practice.isActive
                            {
                                praticeNameArr.append(practice.practiceName ?? "")
                                patient.practiceList.append(practice)
                            }
                        }
                    }
                }
                patient.practiceNameArr = praticeNameArr
                
                if patient.practiceList.count > 0
                {
                    patient.isBluefinEnabled = !getBluefinEnabledPracticeId(patient: patient).isEmpty
                    arrayOfPatient.append(patient)
                }
            }
        }
        
        if isSecondaryAccountFound {
            return NSError(domain: getString(key: "com.charmphr.patient.secondaryaccess.error"), code: patientSecondaryAccountErrorCode)
        }
        
        if isCustomApp() && arrayOfPatient.isEmpty {
            return NSError(domain: getString(key: "com.charmphr.selectpatient.customapp.invaildUser.loginPage.title"), code: patientCustomAppInvalidUserErrorCode)
        }
        
        if !isCustomApp() && arrayOfPatient.isEmpty {
            return NSError(domain: getString(key: "com.charmphr.phr.practice.error"), code: patientPHRPracticeError)
        }
        return arrayOfPatient
    }
    
    static func getAttachmentId(respObj: Dictionary<String, Any>) -> String {
        
        if let attachmentObj = respObj.getAsJsonObject("attachment") {
            return attachmentObj.getString("attachment_id") ?? ""
        }
        
        return ""
    }
    
    static func isPasswordVerified(respObj: Dictionary<String, Any>) -> Bool {
        return respObj.getBoolean("output_string") ?? false
    }
    
    static func getVitalUnit(respObj: Dictionary<String, Any>) -> String? {
        if let outputString = respObj["output_string"] as? Dictionary<String,Any>{
            
            
            var standardVitalUnitDefault = StandardUserDefaults.object(forKey: isStandardVitalUnitKey)  as? [String : Bool] ?? [:]
            
            if(outputString["unit_system"] != nil)
            {
                if let unitStr = outputString["unit_system"] as? String {
                    VitalUtil.savePatientVitalUnit(vitalUnit: unitStr)
                    return unitStr
                }
            }
        }
        
        return nil
    }
    
//MARK: - AppData Handler
    
    static func fillArrayOfSectionsWithDictionary(dictionary :Dictionary<String, Any>) -> Array<Section>
    {
        var arrayOfSection : Array<Section> = []
        
        let outputStringArr = dictionary["output_string"] as! Array<Dictionary<String,Any>>
        
        if outputStringArr.count > 0
        {
            let outputStringDict = outputStringArr[0]
            
            if let recordConfigurableArr = outputStringDict["RECORD_CONFIGURABLE"] as? Array<Dictionary<String,Any>>
            {
                for singleConfi in recordConfigurableArr
                {
                    arrayOfSection.append(getSectionWithDictionary(dict:singleConfi))
                }
            }
            if let othersArr = outputStringDict["OTHERS"] as? Array<Dictionary<String,Any>>
            {
                for singleConfi in othersArr
                {
                    arrayOfSection.append(getSectionWithDictionary(dict:singleConfi))
                }
            }
            if let recordUnConfigurableArr = outputStringDict["RECORD_UNCONFIGURABLE"] as? Array<Dictionary<String,Any>>
            {
                for singleConfi in recordUnConfigurableArr
                {
                    arrayOfSection.append(getSectionWithDictionary(dict:singleConfi))
                }
            }
            if let recordArr = outputStringDict["RECORD"] as? Array<Dictionary<String,Any>>
            {
                for singleConfi in recordArr
                {
                    arrayOfSection.append(getSectionWithDictionary(dict:singleConfi))
                }
            }
            if let wellnessArr = outputStringDict["WELLNESS"] as? Array<Dictionary<String,Any>>
            {
                for singleConfi in wellnessArr
                {
                    arrayOfSection.append(getSectionWithDictionary(dict:singleConfi))
                }
            }            
        }
        
        return arrayOfSection
    }
    
    //Section Config V2
    static func formPatientSection(respObj: Dictionary<String, Any>) -> SectionConfigList {
        
        let sectionConfigList = SectionConfigList()
        
        if let outputDataArr = respObj["output_string"] as? Array<Dictionary<String,Any>>{
            outputDataArr.forEach({ outputData in
                let sectionPracticeMap = SectionPracticeMap()
                
                sectionPracticeMap.practiceId = outputData.getString("practice_id")
                
                let isPracticeActive = Patient.selectedPatientInstance?.practiceList.contains(where: {practice in
                    return practice.practiceId == sectionPracticeMap.practiceId
                }) ?? false
                
                if isPracticeActive {
                    
                    let appointmentEnable = outputData.getBoolean("APPOINTMENT_ENABLED") ?? false
                    
                    if let recordArr = outputData["RECORD"] as? Array<Dictionary<String,Any>> {
                        
                        recordArr.forEach({recordObj in
                            let sectionConfig = Section()
                            sectionConfig.section = recordObj.getString("SECTION") ?? ""
                            sectionConfig.name = recordObj.getString("SECTION_NAME") ?? ""
                            sectionConfig.sectionOrder = recordObj.getInt("SECTION_ORDER") ?? 0
                            sectionConfig.isDefaultEnabled = recordObj.getBoolean("IS_DEFAULT_ENABLED")
                            ?? false
                            sectionConfig.isEnable = recordObj.getBoolean("IS_ENABLED") ?? false
                            
                            if (sectionConfig.section == appointmentModelId) {
                                sectionConfig.allowPhrEntry = appointmentEnable
                            } else {
                                sectionConfig.allowPhrEntry = recordObj.getBoolean("ALLOW_PHR_ENTRY")
                                ?? false
                            }
                            
                            sectionPracticeMap.sectionConfigList.append(sectionConfig)
                        })
                    }
                    
                    if let wellnessArr = outputData["WELLNESS"] as? Array<Dictionary<String,Any>> {
                        
                        wellnessArr.forEach({recordObj in
                            let sectionConfig = Section()
                            sectionConfig.section = recordObj.getString("SECTION") ?? ""
                            sectionConfig.name = recordObj.getString("SECTION_NAME") ?? ""
                            sectionConfig.sectionOrder = recordObj.getInt("SECTION_ORDER") ?? 0
                            sectionConfig.isDefaultEnabled = recordObj.getBoolean("IS_DEFAULT_ENABLED")
                            ?? false
                            sectionConfig.isEnable = recordObj.getBoolean("IS_ENABLED") ?? false
                            
                            
                            sectionConfig.allowPhrEntry = recordObj.getBoolean("ALLOW_PHR_ENTRY")
                            ?? false
                            
                            sectionPracticeMap.sectionConfigList.append(sectionConfig)
                        })
                    }
                    
                    let announcementEnable = outputData.getBoolean("ANNOUNCEMENT_ENABLED") ?? false
                    
                    
                    
                    
                    
                    let sectionConfig = Section()
                    sectionConfig.section = announcementModelId
                    sectionConfig.name = "Announcements"
                    sectionConfig.sectionOrder = 1
                    sectionConfig.isDefaultEnabled = announcementEnable
                    sectionConfig.isEnable = announcementEnable
                    sectionConfig.allowPhrEntry = false
                    
                    sectionPracticeMap.sectionConfigList.append(sectionConfig)
                    sectionConfigList.sectionConfigMapList.append(sectionPracticeMap)
                    
                }
            })
        }
        
        return sectionConfigList
    }

    static func getSectionWithDictionary(dict : Dictionary<String,Any>) -> Section
    {
        let section = Section()
        if (dict["SECTION_NAME"] != nil)
        {
            section.name = dict["SECTION_NAME"] as? String ?? ""
        }
        
        if (dict["SECTION_ICON"] != nil)
        {
            section.icon = dict["SECTION_ICON"] as? String ?? ""
        }
        
        if (dict["MODULE_GROUP"] != nil)
        {
            section.moduleGroup = dict["MODULE_GROUP"] as? String ?? ""
        }
        
        if (dict["ALLOW_PHR_ENTRY"] != nil)
        {
            section.allowPhrEntry  = dict["ALLOW_PHR_ENTRY"] as! Bool
        }
        
        if (dict["SECTION_ORDER"] != nil)
        {
            section.sectionOrder = dict.getInt("SECTION_ORDER") ?? 0
        }
        
        if (dict["IS_ENABLED"] != nil)
        {
            section.isEnable = dict["IS_ENABLED"] as! Bool
        }
        
        if (dict["SECTION"] != nil)
        {
            section.section = dict["SECTION"] as? String ?? ""
        }
        
        if (dict["SECTION_ID"] != nil)
        {
            section.id = dict["SECTION_ID"] as? String ?? ""
        }
        
        if (dict["CONFIGURABLE"] != nil)
        {
            section.configurable = dict["CONFIGURABLE"] as! Bool
        }
        return section
    }
    
    //MARK:  - vitals
    
    static func fillArrayOfVirtasWithDictionary(dictionary :Dictionary<String, Any>) -> Array<Vital>
    {
        var arrayOfVitals : Array<Vital> = []
        
        if let vitalDict = dictionary["VITALS"] as? Dictionary<String, Any>
        {
            let weightVital = Vital()
            weightVital.vitalType = .Weight
            let heightVital = Vital()
            heightVital.vitalType = .Height
            
            if let generalVitalDictArr = vitalDict["General"] as? [Dictionary<String, Any>]
            {
                for generalVitalDict in generalVitalDictArr
                {
                    if generalVitalDict["METRIC_NAME"] as? String == "Weight"
                    {
                        weightVital.metricName = generalVitalDict["METRIC_NAME"] as? String
                        
                        if (generalVitalDict["TRACKED_VALUE_UNIT"] != nil)
                        {
                            weightVital.valueUnit = generalVitalDict["TRACKED_VALUE_UNIT"] as? String
                        }
                        
                        if (generalVitalDict["HEALTH_METRIC_ID"] != nil)
                        {
                            weightVital.healthMetricId = generalVitalDict["HEALTH_METRIC_ID"] as? String
                        }
                        
                        if (generalVitalDict["TRACKED_VALUE"] != nil)
                        {
                            weightVital.vitalValue = "\(generalVitalDict["TRACKED_VALUE"] ?? 0)"
                        }
                        
                        if (generalVitalDict["TRACKER_ID"] != nil)
                        {
                            weightVital.trackerId = generalVitalDict["TRACKER_ID"] as? String
                        }
                        
                        if (generalVitalDict["TRACKER_NAME"] != nil)
                        {
                            weightVital.trackerName = generalVitalDict["TRACKER_NAME"] as? String
                        }
                        
                        if (generalVitalDict["DAY"] as? String != nil) && (generalVitalDict["MONTH"] as? String  != nil) && (generalVitalDict["YEAR"] as? String  != nil)
                        {
                            let dateString = "\(generalVitalDict["DAY"]!) \(generalVitalDict["MONTH"]!) \(generalVitalDict["YEAR"]!)"
                            weightVital.date = CharmUtil.getDateObjectWith(dateString: dateString, dateFormat: "dd MMM yyyy")
                        }
                        
                    }
                    
                    if generalVitalDict["METRIC_NAME"] as? String == "Height"
                    {
                        heightVital.metricName = generalVitalDict["METRIC_NAME"] as? String
                        
                        if (generalVitalDict["TRACKED_VALUE_UNIT"] != nil)
                        {
                            heightVital.valueUnit = generalVitalDict["TRACKED_VALUE_UNIT"] as? String
                        }
                        
                        if (generalVitalDict["HEALTH_METRIC_ID"] != nil)
                        {
                            heightVital.healthMetricId = generalVitalDict["HEALTH_METRIC_ID"] as? String
                        }
                        
                        if (generalVitalDict["TRACKED_VALUE"] != nil)
                        {
                            heightVital.vitalValue = "\(generalVitalDict["TRACKED_VALUE"] ?? 0)"
                        }
                        
                        if (generalVitalDict["TRACKER_ID"] != nil)
                        {
                            heightVital.trackerId = generalVitalDict["TRACKER_ID"] as? String
                        }
                        
                        if (generalVitalDict["TRACKER_NAME"] != nil)
                        {
                            heightVital.trackerName = generalVitalDict["TRACKER_NAME"] as? String
                        }
                        
                        if (generalVitalDict["DAY"] as? String != nil) && (generalVitalDict["MONTH"] as? String  != nil) && (generalVitalDict["YEAR"] as? String  != nil)
                        {
                            let dateString = "\(generalVitalDict["DAY"]!) \(generalVitalDict["MONTH"]!) \(generalVitalDict["YEAR"]!)"
                            heightVital.date = CharmUtil.getDateObjectWith(dateString: dateString, dateFormat: "dd MMM yyyy")
                        }
                    }
                }
            }
            arrayOfVitals.append(weightVital)
            arrayOfVitals.append(heightVital)
            
            
            let bpVital = Vital()
            bpVital.vitalType = .Blood_pressure
            if let bpDictArr = vitalDict["Blood Pressure"] as? [Dictionary<String, Any>]
            {
                if bpDictArr.count > 1
                {
                    let systolicDict = bpDictArr[0]
                    let diastolicDict = bpDictArr[1]
                    
                    bpVital.metricName = systolicDict["TRACKER_NAME"] as? String
                    
                    if (systolicDict["VALUE_UNIT"] != nil)
                    {
                        bpVital.valueUnit = systolicDict["VALUE_UNIT"] as? String
                    }
                    
                    if (systolicDict["HEALTH_METRIC_ID"] != nil)
                    {
                        bpVital.healthMetricId = systolicDict["HEALTH_METRIC_ID"] as? String
                    }
                    
                    if (systolicDict["TRACKED_VALUE"] != nil)
                    {
                        bpVital.vitalValue = "\(systolicDict["TRACKED_VALUE"] ?? 0)/\(diastolicDict["TRACKED_VALUE"] ?? 0)"
                    }
                    
                    if (systolicDict["TRACKER_ID"] != nil)
                    {
                        bpVital.trackerId = systolicDict["TRACKER_ID"] as? String
                    }
                    
                    if (systolicDict["TRACKER_NAME"] != nil)
                    {
                        bpVital.trackerName = systolicDict["TRACKER_NAME"] as? String
                    }
                    
                    if (systolicDict["DAY"] as? String != nil) && (systolicDict["MONTH"] as? String  != nil) && (systolicDict["YEAR"] as? String  != nil)
                    {
                        let dateString = "\(systolicDict["DAY"]!) \(systolicDict["MONTH"]!) \(systolicDict["YEAR"]!)"
                        bpVital.date = CharmUtil.getDateObjectWith(dateString: dateString, dateFormat: "dd MMM yyyy")
                    }
                    
                    
                }else
                {
                    bpVital.trackerName = "Blood Pressure"
                    bpVital.valueUnit = "mmHg"
                }
                
            }
            arrayOfVitals.append(bpVital)
            
        }
        return arrayOfVitals
    }
    
    
    static func formVitalTrackerList(respObj: Dictionary<String,Any>) -> Array<Tracker>
    {
        
        var arrayOfTrackers : Array<Tracker> = []
        if let trackerArr = respObj["output_string"] as? [Dictionary<String,Any>] {
            for dict in trackerArr
            {
                //TODO: Dhanu -> have to remove after api fix
                if let trackerType = setTrackerType(trackerName: dict["tracker_name"] as? String){
                    let tracker = Tracker()
                    tracker.trackerName = dict["tracker_name"] as? String
                    tracker.trackerId = "\(dict["tracker_id"] ?? "")"
                    if (dict["is_default_tracker"] != nil){
                        tracker.isDefaultTracker = dict["is_default_tracker"] as? Bool ?? false
                    }
                    tracker.metricList = []
                    tracker.trackerType = trackerType
                    if let metricArr = dict["metric_list"] as? Array<Dictionary<String,Any>>{
                        for metricDict in metricArr{
                            let metric = Metric()
                            metric.metricId = "\(metricDict["metric_id"] ?? "")"
                            metric.metricName = metricDict["metric_name"] as? String
                            metric.metricUnit = metricDict["metric_unit"] as? String
                            metric.isDefaultMetric =  metricDict["is_default_metric"] as? Bool ?? false
                            tracker.metricList?.append(metric)
                        }
                    }
                    arrayOfTrackers.append(tracker)
                }
            }
        }
        
        return arrayOfTrackers
    }
    
    static func setTrackerType(trackerName : String?) -> TrackerType? {
        if(trackerName == "General")
        {
            return .general
        }
        else if(trackerName == "Pulse Rate")
        {
            return .pulseRate
        }
        else if(trackerName == "Temperature")
        {
            return .temperature
        }
        else if(trackerName == "Blood Pressure")
        {
            return .bloodPressure
        }
        else if(trackerName == "Blood Sugar")
        {
            return .bloodSugar
        }
        else if(trackerName == "Cholesterol")
        {
            return .cholesterol
        }
        else if(trackerName == OTHERS)
        {
            return .others
        }
        return nil
    }
    
    static func formPatientVitalsDetailsList(outputDict :Dictionary<String,Any>) -> Array<PatientVitals>{
        
        var patVitalsArr : Array<PatientVitals> = []
        if let historyArr = outputDict["history"] as? Array<Dictionary<String,Any>>?{
            if(historyArr?.count ?? 0 > 0){
                for dict in historyArr!
                {
                    let metricId = "\(dict["metric_id"] ?? "")"
                    patVitalsArr.append(formPatientVital(dict: dict, metricId: metricId))
                }
                
            }
        }
        return patVitalsArr
    }
    
    static func formPatientVital(dict : Dictionary<String,Any>, metricId : String) -> PatientVitals{
        let patientVitals = PatientVitals()
        let metric = Metric()
        metric.metricId = "\(dict["metric_id"] ?? "")"
        metric.metricName = dict["metric_name"] as? String
        patientVitals.metric = metric
        patientVitals.metricHistoryArr = []
        if let metricArr = dict["metric_history"] as? Array<Dictionary<String,Any>>{
            
            for metricDict in metricArr{
                let metricHistory = MetricHistory()
                if (metricDict["date_of_entry"] != nil){
                    metricHistory.dateOfEntry = CharmUtil.getDateObjectWith(dateString:metricDict["date_of_entry"] as! String , dateFormat: "yyyy-MM-dd HH:mm:ss.S")
                }
                if (metricDict["tracked_unit"] != nil){
                    metricHistory.trackedValueUnit = metricDict["tracked_unit"] as? String
                }
                if (metricDict["tracked_value"] != nil){
                    metricHistory.trackedValue = "\(metricDict["tracked_value"] ?? "")"
                }
                metricHistory.entryId = "\(metricDict["entry_id"] ?? "")"
                patientVitals.metricHistoryArr?.append(metricHistory)
            }
            
        }
        return patientVitals
    }
    //MARK:  - appointments
    
    static func formAppointmentRestriction(practice:Practice?, respObj : [String:Any]) -> AppointmentRestriction{
        let appointmentRestriction = AppointmentRestriction()
        
        if let outputData = respObj.getAsJsonObject("output_string")
        {
            appointmentRestriction.expiryInMinutes = outputData.getInt("tele_link_expiry_in_minutes")
            appointmentRestriction.earlyCheckinInMinutes = outputData.getInt("tele_link_early_checkin_in_minutes")

            appointmentRestriction.practice = practice
        }
        return appointmentRestriction
    }
    
    static func fillAppointmentWithDictionary(dictionary :Dictionary<String, Any>) -> Appointment
    {
        
        let appointment = Appointment()
        
        let provider = Provider()
        provider.fullName = dictionary.getString("FULL_NAME")
        provider.prefix = dictionary.getString("PREFIX")
                
        if dictionary["PHYSICIAN_ID"] != nil{
            provider.memberId = dictionary["PHYSICIAN_ID"] as? String
        }
        
        appointment.cancelOption = dictionary.getString("APPOINTMENT_CANCEL_OPTION")
        
        appointment.member = provider
        appointment.appointmentDoctorName = provider.formMemberName()
        
        if (dictionary["FACILITY_NAME"] != nil)
        {
            appointment.facilityName = dictionary["FACILITY_NAME"] as? String
        }
        
        else if (dictionary["FACILITY_DETAILS"] != nil)
        {
            let facilityDict = dictionary["FACILITY_DETAILS"] as! Dictionary<String,Any>
            appointment.facilityName = facilityDict["FACILITY_NAME"] as? String
        }
        
        if dictionary["FACILITY_ID"] != nil{
            appointment.facilityId = dictionary["FACILITY_ID"] as? String
        }
        
        if (dictionary["PRACTICE_PATIENT_ID"] != nil)
        {
            appointment.practicePatientId = dictionary["PRACTICE_PATIENT_ID"] as? Int
        }
        
        
        let appointmentDate = dictionary.getString("APPOINTMENT_DATE")
        if let appointmentDate = appointmentDate
        {
            
            appointment.appointmentDate = Date.getDateFromString(dateFormat: sqlTimeStampFormat, dateString: appointmentDate)
        }
        
        if (dictionary["PHYSICIAN_REMARK"] != nil)
        {
            appointment.physicanRemark = dictionary["PHYSICIAN_REMARK"] as? String
        }
        
        if (dictionary["STATUS"] != nil)
        {
            appointment.appointmentStatus = dictionary["STATUS"] as? String
        }
        
        if (dictionary["APPOINTMENT_TYPE"] != nil)
        {
            appointment.appointmentType = dictionary["APPOINTMENT_TYPE"] as? String
        }
        
        let appointmentEndTime = dictionary.getString("APPOINTMENT_END_TIME")
        if let appointmentEndTime = appointmentEndTime
        {
            
            appointment.appointmentEndTime = Date.getDateFromString(dateFormat: sqlTimeStampFormat, dateString: appointmentEndTime)
        }
        
        if let teleMode = dictionary.getString("TELE_MODE"){
            appointment.teleMode = teleMode
        }
        
        if let questionnaireArrTemp = dictionary["FORMS"] as? [Dictionary<String, Any>] {
            appointment.questionnaireCount = questionnaireArrTemp.count
            appointment.isQuestionnairePresent = !questionnaireArrTemp.isEmpty
        }
        
        if (dictionary["REQUEST_ID"] != nil)
        {
            appointment.requestId = dictionary["REQUEST_ID"] as? String
        }
        
        if (dictionary["REASON"] != nil)
        {
            appointment.reason = dictionary["REASON"] as? String
        }
        
        if (dictionary["TIMEZONE"] != nil)
        {
            appointment.timeZone = dictionary["TIMEZONE"] as? String
        }
        
        if (dictionary["PHYSICIAN_ID"] != nil)
        {
            appointment.physicanId = dictionary["PHYSICIAN_ID"] as? Int
        }
        
        if (dictionary["PRACTICE_ID"] != nil)
        {
            appointment.practiceId  = dictionary["PRACTICE_ID"] as? String
            provider.practiceId = dictionary["PRACTICE_ID"] as? String
        }
        
        if (dictionary["APPOINTMENT_ID"] != nil)
        {
            appointment.appointmentId = dictionary["APPOINTMENT_ID"] as? String
        }
        
        if (dictionary["APPOINTMENT_START_TIME"] != nil)
        {
            appointment.appointmentStartTime = dictionary["APPOINTMENT_START_TIME"] as? String
        }
        
        if (dictionary["SPECIALIZATION"] != nil)
        {
            appointment.specialization = dictionary["SPECIALIZATION"] as? String
        }
        
        if (dictionary["TIME_PREFERENCE"] != nil)
        {
            appointment.timePreference = dictionary["TIME_PREFERENCE"] as? String
            
            if appointment.timePreference != "ANY_TIME"
            {
                var appointmentStartTime = ""
                appointmentStartTime = ""
                if dictionary["START_HOUR"] != nil && dictionary["START_SESSION"] != nil
                {
                    appointmentStartTime.append(dictionary["START_HOUR"] as! String)
                    appointmentStartTime.append(":")
                    let startMin = (dictionary["START_MINUTES"] as? String ?? "00").count == 1 ? "0\(dictionary["START_MINUTES"] as? String ?? "00")" : dictionary["START_MINUTES"] as? String ?? "00"
                    appointmentStartTime.append(startMin )
                    appointmentStartTime.append(" ")
                    appointmentStartTime.append(dictionary["START_SESSION"] as! String)
                    
                    if dictionary["END_HOUR"] != nil && dictionary["END_SESSION"] != nil
                    {
                        appointmentStartTime.append(" - ")
                        appointmentStartTime.append(dictionary["END_HOUR"] as! String)
                        appointmentStartTime.append(":")
                        let endMin = (dictionary["END_MINUTES"] as? String ?? "00").count == 1 ? "0\(dictionary["END_MINUTES"] as? String ?? "00")" : dictionary["END_MINUTES"] as? String ?? "00"
                        appointmentStartTime.append(endMin )
                        appointmentStartTime.append(" ")
                        appointmentStartTime.append(dictionary["END_SESSION"] as! String)
                    }
                }
                appointment.appointmentStartTime = appointmentStartTime
            }
        }
        
        if let visitTypeDetail = dictionary.getAsJsonObject("VISIT_TYPE_DETAIL"){
            let visitType = VisitTypes()
            visitType.duration = visitTypeDetail.getInt("VISITTYPE_DURATION")
            visitType.visittypeId = visitTypeDetail.getString("VISITTYPE_ID")
            visitType.visittypeColor = visitTypeDetail.getString("VISITTYPE_COLOR")
            visitType.appointmentMode = visitTypeDetail.getString("VISIT_TYPE_APPOINTMENT_MODE")
            visitType.charge = "\(visitTypeDetail.getInt("VISITTYPE_CHARGE") ?? 0)"
            visitType.visitType = visitTypeDetail.getString("VISIT_TYPE")
            
            appointment.visitTypeDetail = visitType
        }
        
        if (dictionary["REMINDER_TYPE"] != nil)
        {
            appointment.reminderType = dictionary["REMINDER_TYPE"] as? String
        }
        
        if (dictionary["DATE_PREFERENCE"] != nil)
        {
            appointment.datePreference = dictionary["DATE_PREFERENCE"] as? String
            
            if (dictionary["DATE_CHOICE1"] != nil)
            {
                if let date = CharmUtil.getDateObjectWith(dateString: dictionary["DATE_CHOICE1"] as! String, dateFormat: PHR_DATE_API_FORMAT)
                {
                    appointment.dateChoice1 = date
                }else
                {
                    appointment.dateChoice1 = CharmUtil.getDateObjectWith(dateString: dictionary["DATE_CHOICE1"] as! String, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                }
            }
        }
        appointment.startTimeUTC = dictionary.getString("START_TIME_UTC")
        appointment.endTimeUTC = dictionary.getString("END_TIME_UTC")
        appointment.appointmentDeviceStartTime = convertUTCtoDevice(appointment.startTimeUTC)
        appointment.appointmentDeviceEndTime = convertUTCtoDevice(appointment.endTimeUTC)

        return appointment
    }
    
    static func fillAppointmentConfigResponse(outputJson :Dictionary<String, Any>, addAppointment : AddAppointment){
              
        if let todayDateObj = outputJson["today_details"] as? Dictionary<String,Any>
            {
                if (todayDateObj["date"] as? String) != nil && todayDateObj["time"] as? String != nil
                {
                    let today = "\(todayDateObj["date"] as! String) \(todayDateObj["time"] as! String)"
                      addAppointment.todayDate = CharmUtil.getDateObjectWith(dateString: today, dateFormat: "MM-dd-yyyy HH:mm")
                }
            }
              
            if outputJson["FACILITY_TIMEZONE"] as? String != nil
            {
                addAppointment.timeZone = outputJson["FACILITY_TIMEZONE"] as? String
            }
              
            if outputJson["DATE_AT_FACILITY_TIMEZONE"] as? String != nil
            {
                addAppointment.facilityTime = CharmUtil.getDateObjectWith(dateString: outputJson["DATE_AT_FACILITY_TIMEZONE"] as! String, dateFormat: "yyyy/MM/dd HH:mm:ss")
            }
              
            if outputJson["ONLINE_BOOKING_DAYS_LIMIT"] as? String != nil
            {
                addAppointment.onlineBookingDaysLimit = Int(outputJson["ONLINE_BOOKING_DAYS_LIMIT"] as! String)
            }
              
            if outputJson["SLOTS_OPENING_PRIOR_HOURS"] as? String != nil
            {
                addAppointment.slotsOpeningPriorHours = Int(outputJson["SLOTS_OPENING_PRIOR_HOURS"] as! String)
            }
              
            if outputJson["SHOW_VISIT_DURATION"] as? Bool == true
            {
                addAppointment.showVisitDuration = true
            }
            
            if outputJson["interval"] as? String != nil
            {
                addAppointment.interval = Int(outputJson["interval"] as! String)
            }
              
            if outputJson["TELEHEALTH_ENABLED"] as? Int != nil
            {
                if outputJson["TELEHEALTH_ENABLED"] as! Int == 1
                {
                    addAppointment.isTelehealthEnabled = true
                }else
                {
                    addAppointment.isTelehealthEnabled = false
                }
            }
              
            if outputJson["IS_CARD_PROCESSING_ENABLED"] as? Bool == true
            {
                let paymentInfo = PaymentInfo()
                let transactionInfo = TransactionInfo()
                
                transactionInfo.patientId = Patient.selectedPatientInstance!.patientId
                      
                if outputJson["GATEWAY"] as? String != nil
                {
                    transactionInfo.gateway = outputJson["GATEWAY"] as? String
                    if transactionInfo.gateway == "RAZORPAY"
                    {
                        addAppointment.paymentCurrency = "INR"
                        addAppointment.paymentCurrencySymbol = "Rs."
                    }
                    else if transactionInfo.gateway == "BLUEFIN"{
                        addAppointment.paymentCurrencySymbol = "$"
                        addAppointment.paymentCurrency = "USD"
                    }
                }
                      
                if outputJson["CHARGE_AMOUNT"] as? Float != nil
                {
                    paymentInfo.chargeAmount = String(outputJson["CHARGE_AMOUNT"] as? Float ?? 0)
                }
                    
                paymentInfo.chargeProcessingType = outputJson.getString("CARD_PROCESSING_TYPE")
                
                if outputJson["CHARGE_TYPE"] as? String != nil
                {
                    paymentInfo.chargeType = outputJson["CHARGE_TYPE"] as? String
                }
                      
                if outputJson["IS_CARD_PROCESSING_ENABLED"] as? Bool != nil
                {
                    addAppointment.isCardProcessing = outputJson["IS_CARD_PROCESSING_ENABLED"] as? Bool
                }
                      
                if outputJson["MERCHANT_ACCOUNT_ID"] as? String != nil
                {
                    transactionInfo.merchantAccountId = outputJson["MERCHANT_ACCOUNT_ID"] as? String
                }
                      
                paymentInfo.transactionInfo = transactionInfo
                addAppointment.paymentInfo = paymentInfo
                      
            }else
            {
                addAppointment.paymentInfo = nil
            }
              
            if outputJson["is_configured"] as? Bool == true
            {
            addAppointment.isConfigured = true
            let visitTypeArr = outputJson["visitTypes"] as? Array<Dictionary<String,Any>>
            if (visitTypeArr != nil)
            {
                addAppointment.visitTypeDictArr = []
                for visitType in visitTypeArr!
                {
                    var visitTypeDict = visitType
                    if(addAppointment.showVisitDuration){
                        visitTypeDict.updateValue("\(visitType["VISIT_TYPE"] ?? "") [ \(visitType["DURATION"] ?? "") mins ] ", forKey: "VISIT_TYPE")}
                    else{
                        visitTypeDict.updateValue("\(visitType["VISIT_TYPE"] ?? "")", forKey: "VISIT_TYPE")
                    }
                    addAppointment.visitTypeDictArr.append(visitTypeDict)
                }
            }
        }
    }
    
    static func formFacilityListForAppointment(respObj: Dictionary<String, Any>, practiceId: String) -> [Facility] {

        var facilityList:[Facility] = []

        if let facilityArr = respObj["output_string"] as? [Dictionary<String,Any>]
        {
            
            facilityArr.forEach({facilityObj in
                let facility = Facility()
                facility.facilityId = facilityObj.getString("facility_id")
                facility.facilityName = facilityObj.getString("facility_name")
                facility.practiceId = practiceId

                facilityList.append(facility)
            })
        }

                
        return facilityList
    }
    
    static func formMemberListForAppointment(respObj: Dictionary<String, Any>, practiceId: String) -> [Provider] {

        var memberList:[Provider] = []

        if let facilityMemberArr = respObj["facility_members"] as? [Dictionary<String,Any>]
        {
            
            facilityMemberArr.forEach({facilityMemberObj in
                let member = Provider()
                member.firstName = facilityMemberObj.getString("first_name")
                member.lastName = facilityMemberObj.getString("last_name")
                member.fullName = facilityMemberObj.getString("full_name")
                member.gender = facilityMemberObj.getString("gender")
                member.prefix = facilityMemberObj.getString("prefix")
                member.specialization = facilityMemberObj.getString("specialization")
                member.memberId = facilityMemberObj.getString("member_id")
                member.degree = facilityMemberObj.getString("degree")

                member.practiceId = practiceId
              
                memberList.append(member)
            })
        }

                
        return memberList
    }
    
    static func formAppointmentConfig(respObj: Dictionary<String, Any>) -> AppointmentConfig {
        let appointmentConfig = AppointmentConfig()

        if let outputData = respObj["output_string"] as? Dictionary<String,Any>
        {
            appointmentConfig.showAppOnPatientTimezone = outputData.getBoolean("SHOW_APPT_ON_PAT_TIMEZONE") ?? false
            
            appointmentConfig.isEnabled = outputData.getBoolean("is_configured") ?? true
            
            let facTimeZone = outputData.getString("FACILITY_TIMEZONE") ?? ""
            
            if (facTimeZone.firstOrNil()?.isDigit() == true) {
            
                appointmentConfig.currentFacilityTimezone = Date.getDateFromString(dateFormat:dateAndTimeWithSlash , dateString: facTimeZone)
                
            }
            else {
                appointmentConfig.facilityTimezone = facTimeZone
                appointmentConfig.currentFacilityTimezone = Date.getDateFromString(dateFormat:dateAndTimeWithSlash , dateString: outputData.getString("DATE_AT_FACILITY_TIMEZONE")
                                                                                  ?? "")
            }

            appointmentConfig.isTelehealthEnabled = outputData.getBoolean("TELEHEALTH_ENABLED")
                    ?? false
            
            
            if appointmentConfig.isEnabled {
                var visitTypesList: [VisitTypes] = []
                if let visitTypesArr = outputData["visitTypes"] as? [Dictionary<String,Any>]
                {
                    
                    visitTypesArr.forEach({visitTypesObj in
                        let visitTypes = VisitTypes()
                        
                        
                        
                        visitTypes.appointmentMode = visitTypesObj.getString("APPOINTMENT_TYPE")?.split(separator: " ").map({ temp in
                            "\(temp)".capitalizingFirstLetter()
                        }).joined(separator: " ")
                        
                        
                        
                        visitTypes.duration = visitTypesObj.getInt("DURATION")
                        
                        if let charge = visitTypesObj.getDouble("CHARGE"){
                            visitTypes.charge = "\(charge)"
                        }
                        visitTypes.visitType = visitTypesObj.getString("VISIT_TYPE")
                        visitTypes.visittypeId = visitTypesObj.getString("VISITTYPE_ID")
                        visitTypesList.append(visitTypes)
                    })
                }
                appointmentConfig.visitTypeList = visitTypesList
                appointmentConfig.interval = outputData.getInt("interval") ?? 0
                appointmentConfig.slotsOpeningPriorHours = outputData.getInt("SLOTS_OPENING_PRIOR_HOURS")
                        ?? 0
                appointmentConfig.onlineBookingDaysLimit = outputData.getInt("ONLINE_BOOKING_DAYS_LIMIT")
                        ?? 0
                appointmentConfig.patientNote = outputData.getString("PATIENT_NOTE")
                appointmentConfig.showVisitDuration = outputData.getBoolean("SHOW_VISIT_DURATION")
                        ?? false
            }
            
            if let cardProcessEnabled = outputData.getBoolean("IS_CARD_PROCESSING_ENABLED"){
                appointmentConfig.isCardProcessingEnabled = cardProcessEnabled
                
                if appointmentConfig.isCardProcessingEnabled {
                    appointmentConfig.cardProcessingType = outputData.getString("CARD_PROCESSING_TYPE")
                    
                    if let paymentAmt = outputData.getDouble("CHARGE_AMOUNT"){
                        appointmentConfig.chargeAmount = "\(paymentAmt)"
                    }
                    
                    appointmentConfig.chargeType = outputData.getString("CHARGE_TYPE")

                    appointmentConfig.paymentCurrency = outputData.getString("PRACTICE_CURRENCY_CODE")
                    appointmentConfig.paymentCurrencySymbol = outputData.getString("PRACTICE_CURRENCY_SYMBOL")

                    if (appointmentConfig.paymentCurrencySymbol.isNilOrBlank() && isCustomApp()) {
                        appointmentConfig.paymentCurrencySymbol = "₹"
                    }
                    
                    

                    if (appointmentConfig.paymentCurrency.isNilOrBlank() && isCustomApp()) {
                        appointmentConfig.paymentCurrency = "INR"
                    }
                    
                    if appointmentConfig.cardProcessingType == appointmentCardProcessingTypeChargeOnly {
                        if (appointmentConfig.chargeType != appointmentPaymentChargeTypeVisitBased) {
                            if (appointmentConfig.chargeAmount?.toFloatOrNil() ?? 0 == 0) {
                                appointmentConfig.isCardProcessingEnabled = false
                            }
                        }
                        else {
                            if appointmentConfig.visitTypeList.isEmpty {
                                appointmentConfig.isCardProcessingEnabled = false
                            }
                        }
                    }
                    
                    
                    appointmentConfig.merchantAccountId = outputData.getString("MERCHANT_ACCOUNT_ID")
                    appointmentConfig.paymentGateway = outputData.getString("GATEWAY")

                    if (appointmentConfig.paymentGateway == appointmentGatewayTypeBluefin){
                        appointmentConfig.paymentCurrencySymbol = "$"
                        appointmentConfig.paymentCurrency = "USD"
                    }
                    
                    if (appointmentConfig.paymentCurrencySymbol.isNilOrBlank() && appointmentConfig.paymentGateway == appointmentGatewayTypeRazorpay) {
                        appointmentConfig.paymentCurrencySymbol = "₹"
                    }
                    
                    if (appointmentConfig.paymentCurrency.isNilOrBlank() && appointmentConfig.paymentGateway == appointmentGatewayTypeRazorpay) {
                        appointmentConfig.paymentCurrency = "INR"
                    }
                    
                    
                }
            }
            
        }
        return appointmentConfig
    }
    
    static func formSlotsList(respObj: Dictionary<String, Any>) -> SlotMetaData {
        
        let slotMetaData = SlotMetaData()

        if let outputData = respObj["output_string"] as? Dictionary<String, Any>
        {
            
            
            if let availableSlotsArr = outputData["available_slots"] as? [Dictionary<String, Any>]
            {
                
                availableSlotsArr.forEach({availableSlotObj in
                    for (slotDateStr,slotsArr) in availableSlotObj  {
                       
                        if let slotDate = Date.getDateFromString(dateFormat: PHR_DATE_API_FORMAT, dateString: slotDateStr) ,let slotsArr = slotsArr as? [Dictionary<String, Any>] {
                            
                            let memberAvailablity = MemberAvailability()
                            memberAvailablity.date = slotDate
                            
                            slotsArr.forEach({slotObj in
                                let startTimeStr = slotObj.getString("start_time") ?? ""
                                let endTimeStr = slotObj.getString("end_time") ?? ""

                                let memberSlot = MemberSlot()
                                memberSlot.startTime = Date.getDateFromString(dateFormat: charmDateFormatForSlot, dateString: "\(slotDateStr) \(startTimeStr)")
                                memberSlot.endTime = Date.getDateFromString(dateFormat: charmDateFormatForSlot, dateString: "\(slotDateStr) \(endTimeStr)")

                                memberAvailablity.memberSlots.append(memberSlot)
                                
                            })
                            slotMetaData.memberAvailability.append(memberAvailablity)
                        }
                        
                    }
                })
            }
            
            slotMetaData.showWaitingList = outputData.getBoolean("SHOW_WAIT_LIST") ?? false

            var memberWorkTimingList: [MemberWorkTiming] = []
            
            if let workingDays =  outputData["working_days"] as? Dictionary<String, Any> {
                
                for dayIndex in 0...6{
                    memberWorkTimingList.append(getMemberWorkTimingForSlot(workingDaysObj: workingDays, dayOfWeek: dayIndex ))
                }
            }
            
            slotMetaData.memberWorkTiming = memberWorkTimingList
        }
        return slotMetaData
    }
    
    static func formBookAppointmentResp(respObj: Dictionary<String, Any>) -> String{
        
        if let outputData = respObj["output_string"] as? Dictionary<String, Any>
        {
            return outputData.getString("message") ?? ""
        }
        
        return respObj.getString("message") ?? ""
    }
    
    private static func getMemberWorkTimingForSlot(workingDaysObj: Dictionary<String, Any>, dayOfWeek: Int) -> MemberWorkTiming {
        let workingDays = workingDaysObj.getBoolean("\(dayOfWeek)") ?? true

        let workingDaysTiming = MemberWorkTiming()
        
        workingDaysTiming.dayOfWeek = dayOfWeek + 1
        
//        if dayOfWeek == 0{
//            workingDaysTiming.dayOfWeek = 7
//        }
        
        workingDaysTiming.isMemberWorking = workingDays
        
        return workingDaysTiming
    }
    
//MARK: - Billing
    
    static func formInvoiceList(dictionary : Dictionary<String,Any> , practiceId : String) -> Array<PHRBills>
    {
        var arrayOfInvoices : Array<PHRBills> = []
        
    
        
        if let outputData = dictionary["output_string"] as? Dictionary<String,Any>{
            

            let invoiceArr = outputData["INVOICES_LIST"] as? [Dictionary<String,Any>]
            let facilitiesObj = outputData["FACILITIES_LIST"] as? Dictionary<String,Any>
            let practiceCurrencySymbol = outputData.getString("PRACTICE_CURRENCY_SYMBOL")
            let paymentGateWay = outputData.getString("GATEWAY")
            let ehrInvoiceArr = outputData["EHR_INVOICES_LIST"] as? Dictionary<String,Any>

            invoiceArr?.forEach({invoiceObj in
                let phrBill = PHRBills()
                
                phrBill.gateway = paymentGateWay
                phrBill.isStatement = invoiceObj.getBoolean("IS_STATEMENT") ?? false
                phrBill.practiceId = practiceId
                phrBill.memberId = invoiceObj.getString("BILL_PROVIDER_ID")
                
                if phrBill.isStatement{
                    phrBill.statementId = invoiceObj.getString("STATEMENT_ID")
                    if let statementMapObj = outputData["STATEMENT_MAP"] as? Dictionary<String,Any>{
                        if let statementObj = statementMapObj[phrBill.statementId ?? ""] as? Dictionary<String, Any> {
                            
                            phrBill.billAmount = statementObj.getString("STATEMENT_AMOUNT")
                            phrBill.dueAmount = statementObj.getString("CURRENT_STATEMENT_DUE")
                            phrBill.amount = statementObj.getString("CURRENT_STATEMENT_PAYMENT_REQUEST")
                            phrBill.isPaid = statementObj.getBoolean("IS_PAID") ?? false
                            phrBill.billNumber = invoiceStatementStr
                            
                            if let facilityIdList = statementObj["FACILITY_IDS"] as? [Any] {
                                let facilityId = facilityIdList.firstOrNil()
                                if let facilityId = facilityId {
                                    let facilityObj = facilitiesObj?["\(facilityId)"] as? Dictionary<String, Any>
                                    phrBill.facility = formFacilityObj(facilityObj: facilityObj , facilityId: "\(facilityId)")
                                    
                                    
                                    phrBill.facilityName = phrBill.facility?.facilityName
                                    phrBill.facilityId = "\(facilityId)"
                                
                                }
                            }
                        }
                    }
                }
                else{
                    phrBill.amount = invoiceObj.getString("AMOUNT")
                    phrBill.billAmount = invoiceObj.getString("BILL_AMOUNT")
                    //phrBill.dueAmount = invoiceObj.getString("DUE_AMOUNT")
                    phrBill.billNumber = invoiceObj.getString("BILL_NUMBER")
                    phrBill.ehrBillId = invoiceObj.getString("EHR_BILL_ID")
                    phrBill.phrBillId = invoiceObj.getString("PHR_BILL_ID")

                    let ehrBillObj = ehrInvoiceArr?[phrBill.ehrBillId ?? ""] as? Dictionary<String , Any>
                    let billStatus = ehrBillObj?.getString("BILL_STATUS") ?? ""
                    phrBill.isPaid = billStatus.lowercased() == "paid" || billStatus.lowercased() == "canceled"
                    
                    
                    
                 //   debugPrintLog("Old Due -> \(phrBill.dueAmount ?? ""); New Due -> \(ehrBillObj?.getString("DUE") ?? "")")
                    
                    phrBill.dueAmount = ehrBillObj?.getString("DUE") ?? ""
                    phrBill.billType = ehrBillObj?.getString("BILL_TYPE") ?? ""
                    
                    
                    if let dueAmt = phrBill.dueAmount?.toDoubleOrNil(), let reqAmt = phrBill.amount?.toDoubleOrNil() {
                        if reqAmt > dueAmt {
                            phrBill.amount = phrBill.dueAmount
                        }
                    }

                    phrBill.status = invoiceObj.getString("STATUS")
                    let facilityId = invoiceObj.getString("FACILITY_ID") ?? ""
                    if (facilityId.isNotBlank()) {
                        let facilityObj = facilitiesObj?[facilityId] as? Dictionary<String, Any>
                        phrBill.facility = formFacilityObj(facilityObj: facilityObj , facilityId: facilityId)
                        
                        phrBill.facilityName = phrBill.facility?.facilityName
                        phrBill.facilityId = facilityId
                    }
                }
                phrBill.practiceCurrencySymbol = practiceCurrencySymbol
                
                let billDateStr = invoiceObj.getString("BILL_DATE")
                
                
                
                

                if !billDateStr.isNilOrBlank(){
                    
                    phrBill.billDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: billDateStr ?? "")
                    
                    
                    if phrBill.billDate == nil {
                        debugPrintLog("bill date format -> \(PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)")
                        debugPrintLog("bill date -> \(billDateStr ?? "") : isStatement -> \(phrBill.isStatement)")
                    }
                }
                
                arrayOfInvoices.append(phrBill)
            })

        }
      
    
        return arrayOfInvoices
    }
    
    static func formReceiptList(dictionary : Dictionary<String,Any> , practiceId : String) -> Array<PHRReceipts>
    {
        var receiptList : Array<PHRReceipts> = []
        
        
        
        if let outputData = dictionary["output_string"] as? Dictionary<String,Any>{
            
            let receiptArr = outputData["RECEIPT_LIST"] as? [Dictionary<String,Any>]
            
            receiptArr?.forEach({receiptObj in
                
                let receipt  = PHRReceipts()

                receipt.practiceId = practiceId
                receipt.status = receiptObj.getString("STATUS")
                receipt.patientPracticeMapId = receiptObj.getString("PATIENT_PRACTICE_MAP_ID")
                receipt.ehrReceiptId = receiptObj.getString("EHR_RECEIPT_ID")
                receipt.receiptAmount = receiptObj.getString("RECEIPT_AMOUNT")
                receipt.receiptNumber = receiptObj.getString("RECEIPT_NUMBER")
                receipt.isRead = receiptObj.getBoolean("IS_READ") ?? false
                receipt.sharedBy = receiptObj.getString("SHARED_BY")
                receipt.phrReceiptId = receiptObj.getString("PHR_RECEIPT_ID")
                receipt.usedAmount = receiptObj.getString("USED_AMOUNT")
                receipt.details = receiptObj.getString("DETAILS")
                receipt.sentFromEhr = receiptObj.getBoolean("SENT_FROM_EHR") ?? false

                let billDateStr = receiptObj.getString("RECEIPT_DATE")
                if let billDateStr = billDateStr
                {
                    receipt.receiptDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: billDateStr)
                }

                if (receiptObj["FACILITY_ID"] != nil)
                {
                    receipt.facilityId = receiptObj["FACILITY_ID"] as? String

                    if let facilityListDict : Dictionary<String,Dictionary<String,Any>> = outputData["FACILITIES_LIST"] as? Dictionary<String, Dictionary<String,Any>>
                    {
                        if let facilityObj = facilityListDict[receipt.facilityId ?? ""] {
                            receipt.facilityName = facilityObj.getString("FACILITY_NAME")
                        }
                    }
                }

                
                receipt.practiceCurrencySymbol = outputData.getString("PRACTICE_CURRENCY_SYMBOL")
                receiptList.append(receipt)
            })
        }
        
        return receiptList
    }
    
    static func formFacilityObj(facilityObj: Dictionary<String,Any>?, facilityId: String = "") -> Facility? {
        if let facilityObj = facilityObj {

            let facility = Facility()
            facility.facilityId = facilityId
            if (facilityId.isBlank()) {
                facility.facilityId = facilityObj.getString("FACILITY_ID")
            }
            facility.facilityName = facilityObj.getString("FACILITY_NAME")
                return facility
        }
        return nil
    }
    
    static func fillPaymentWithDictFromInvoiceDetail(dict : Dictionary<String,Any> , gateway : String) -> PaymentInfo
    {
        let paymentInfo = PaymentInfo()
        let transactionInfo = TransactionInfo()
        
    //TODO: check for crt value for json
        if let outputJson = dict["output_string"] as? Dictionary<String,Any>
        {
            transactionInfo.patientId = getSelectedPatientId()
                
                
            transactionInfo.gateway = gateway
            
//            if payment.gateway == "RAZORPAY"
//            {
//                payment.currency = "INR"
//                payment.currencySymbol = "Rs."
//            }
            
            paymentInfo.isPartialPaymentEnabled = outputJson.getBoolean("is_partial_payment_allowed") ?? false
            paymentInfo.minAllowedAmount = outputJson.getString("minimum_payment_amount")


            let isStoreCard = outputJson.getBoolean("save_card_details") ?? false
            
            if isStoreCard {
                paymentInfo.chargeProcessingType = appointmentCardProcessingTypeStoreCharge
            }
            else{
                paymentInfo.chargeProcessingType = appointmentCardProcessingTypeChargeOnly
            }
            
                
            if outputJson["payment_requested"] as? Float != nil
            {
                paymentInfo.chargeAmount = String(outputJson["payment_requested"] as? Float ?? 0)
            }
                
//            if outputJson["IS_CARD_PROCESSING_ENABLED"] as? String != nil
//            {
//                payment.isCardProcessing = outputJson["IS_CARD_PROCESSING_ENABLED"] as? Bool
//            }
                
            if outputJson["MERCHANT_ACCOUNT_ID"] as? String != nil
            {
                transactionInfo.merchantAccountId = outputJson["MERCHANT_ACCOUNT_ID"] as? String
            }
            
            transactionInfo.merchantAccountId = outputJson.getString("merchant_account_id")
        }
        
        paymentInfo.transactionInfo = transactionInfo
        return paymentInfo
    }
    
//MARK: - Messages
    
    static func formMessageRestriction(practice:Practice?, respObj : Dictionary<String,Any>) -> MessageRestriction{
        let messageRestriction = MessageRestriction()
        
        if let outputData = respObj.getAsJsonObject("output_string")
        {
            messageRestriction.allowMessaging = outputData.getBoolean("allow_phr_messaging") ?? true
            messageRestriction.isMessageRestrict = outputData.getBoolean("is_message_restrict") ?? false
            messageRestriction.numberOfCharAllowed = outputData.getInt("no_of_chars_allowed") ?? 0

            messageRestriction.practice = practice
        }
        return messageRestriction
    }
    
    static func formMessageList(respObj : Dictionary<String,Any> , messageType  : String , practiceId : String) -> [Messages]{
        
        var messageList : Array<Messages> = []
        
        if let messageArr = respObj["output_string"] as? [Dictionary<String,Any>] {
            for messagesDict in messageArr
            {
                let messages = Messages()
                let messageReceipients = MessageReceipients()
                
                messages.messageType = messageType
                messages.practiceId = practiceId
                
                messageReceipients.toSpace = messagesDict.getString("TO_SPACE")
                messageReceipients.fromSpace = messagesDict.getString("FROM_SPACE")
                messages.practicePatientId = messagesDict.getString("PRACTICE_PATIENT_ID")
                messageReceipients.fromName = messagesDict.getString("FROM_NAME")
                messages.time = messagesDict.getString("TIME")
                messages.priority = messagesDict.getString("PRIORITY")
                messageReceipients.fromId = messagesDict.getString("FROM_ID")
                messageReceipients.status = messagesDict.getString("STATUS")
                messageReceipients.toName = messagesDict.getString("TO_NAME")
            
                messages.messageId = messagesDict.getString("MESSAGE_ID")
                messageReceipients.messageId = messages.messageId
                
                messageReceipients.messageRecipientId = messagesDict.getString("MESSAGE_RECIPIENT_ID")
                messages.subject = messagesDict.getString("SUBJECT")
                
                messageReceipients.toId = messagesDict.getString("TO_ID")
                messages.type = messagesDict.getString("TYPE")
                
                messages.hasAttachments = messagesDict.getBoolean("HAS_ATTACHMENTS") ?? false
                
                let dateString = messagesDict.getString("MESSAGE_DATE") ?? ""
                let timeString = messagesDict.getString("MESSAGE_TIME") ?? ""
                messages.dateString = dateString
                messages.timeString = timeString

                messages.messageDate = Date.getDateFromString(dateFormat: charmDateFormatForMessageList, dateString: "\(dateString) \(timeString)")
                messages.messageReceipients = messageReceipients
                
                messageList.append(messages)
            }
        }
        return messageList
    }

    static func updateMessageObjWithMessageDeatilDict(dict:Dictionary<String,Any>,message:Messages) -> Messages
    {
        if dict["message_id"] as? String == message.messageId
        {
            message.subject = dict.getString("subject")
            message.contentFile = dict.getString("content")
            let dateObj = CharmUtil.getDateObjectWith(dateString: dict.getString("date") ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
            message.dateString = dateObj?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            message.timeString = dateObj?.getStringFromDate(dateFormat: charmDisplayTimeFormat)
            
            let receipients = MessageReceipients()
            if let sender = dict.getAsJsonObject("sender"){
                receipients.fromId = sender.getString("sender_id")
                receipients.fromName = sender.getString("sender_name")
            }
            
            message.msgAttachmentList = []
            for attachmentDict in dict["attachments"] as! Array<Dictionary<String,Any>>
            {
                let attachment = MessagesAttachmentsMap()
                if (attachmentDict["attachment_id"] != nil)
                {
                    attachment.attachmentId = attachmentDict["attachment_id"] as? String
                }
                
                if (attachmentDict["attachment_name"] != nil)
                {
                    attachment.attachmentName = attachmentDict["attachment_name"] as? String
                }
                
                attachment.messageId = dict["content"] as? String
                message.msgAttachmentList.append(attachment)
            }
            message.type = dict.getString("type")
            message.ownerId = dict.getString("owner_id")
            
            if let receivers = dict["receivers"] as? [String: [[String:String]]]
            {
                message.arrayOfRecivers = []
                if receivers["members"]!.count > 0
                {
                    for member in receivers["members"]!
                    {
                        if message.type == GROUP{
                            receipients.toName = member["member_name"]
                            receipients.toId = member["member_id"]
                        }
                        else{
                            let provider = Provider()
                            provider.fullName = member["member_name"]
                            provider.memberId = member["member_id"]
                            provider.practiceId = message.practiceId
                            
                            if !message.arrayOfRecivers.contains(where: { providerObj in
                                return providerObj.memberId == provider.memberId
                            }){
                                message.arrayOfRecivers.append(provider)
                            }
                        }
                    }
                }
                if let patient = receivers["patients"]?.first{
                    receipients.toName = patient.getString("patient_name")
                    receipients.toId = patient.getString("patient_id")
                }
            }
            if message.messageReceipients == nil{
                message.messageReceipients = receipients
            }
        }
        
        return message
    }
    
    static func formProviderForComposeMessage(dict : Dictionary<String,Any>) -> ProviderAndGroup{
        var providerList: [Provider] = []
        var memberGroupList: [MemberGroup] = []
                
        guard let outputString = dict.getAsJsonObject("output_string") else { return ProviderAndGroup() }
        
        if let groupList = outputString.getAsJsonArray("group_list"){
            groupList.forEach { groupObj in
                let memberGroup = MemberGroup()
               
                memberGroup.groupName = groupObj.getString("GROUP_NAME")
                memberGroup.groupId = groupObj.getString("GROUP_ID")
                memberGroup.types = groupObj.getString("TYPE")
                memberGroup.description = groupObj.getString("GROUP_DESC")
                
                memberGroupList.append(memberGroup)
            }
        }
        if let physicianList = outputString.getAsJsonArray("physician_list"){
            physicianList.forEach { providerObj in
                let provider = Provider()
                provider.memberId = providerObj.getString("MEMBER_ID")
                provider.prefix = providerObj.getString("PREFIX")
                provider.firstName = providerObj.getString("FIRST_NAME")
                provider.lastName = providerObj.getString("LAST_NAME")
                provider.fullName = providerObj.getString("MEMBER_NAME")
                provider.gender = providerObj.getString("GENDER")
                provider.specialization = providerObj.getString("SPECIALIZATION")
                provider.degree = providerObj.getString("DEGREE")
                provider.jobTitle = providerObj.getString("JOB_TITLE")
                provider.fullNameWithJobTitle = providerObj.getString("MEMBER_NAME_WITH_TITLE")
                provider.type = providerObj.getString("TYPE")
                
                providerList.append(provider)
            }
        }
        let providerAndGroup = ProviderAndGroup()
        providerAndGroup.memberList = providerList
        providerAndGroup.groupList = memberGroupList
        
        return providerAndGroup
    }
    
//MARK: Lab
    
    static func formLabList(respObj : Dictionary<String,Any>) -> Array<MedicalRecordGroup>
    {
        var arrayOfMedicalRecordGroup : Array<MedicalRecordGroup> = []
        
        if let outputData = respObj["output_string"] as? Dictionary<String,Any> {
            
            if let dataList = outputData["DATA_LIST"] as? [Dictionary<String,Any>] {
                
                for medicalRecordGroupDict in dataList{
                    let medicalRecordGroup = MedicalRecordGroup()
                    
                    medicalRecordGroup.isRead = medicalRecordGroupDict.getBoolean("read_status") ?? false
                    medicalRecordGroup.isAddedByPatient = medicalRecordGroupDict.getBoolean("ADDED_BY_PATIENT") ?? false
                    medicalRecordGroup.practiceId = "\(medicalRecordGroupDict.getInt("practice_id") ?? 0)"
                    medicalRecordGroup.groupId = medicalRecordGroupDict.getString("group_id")
                    medicalRecordGroup.labName = medicalRecordGroupDict.getString("lab_name")
                    medicalRecordGroup.labId = medicalRecordGroupDict.getString("lab_id")
                    medicalRecordGroup.comments = medicalRecordGroupDict.getString("message_to_patient")
                    medicalRecordGroup.date = CharmUtil.getDateObjectWith(dateString: medicalRecordGroupDict.getString("result_date") ?? "", dateFormat: sqlTimeStampFormat)
                    
                    if let recordsDict = medicalRecordGroupDict["records"] as? [Dictionary<String,Any>]{
                        for recordsDictObj in recordsDict{
                            let medicalRecordEntry = MedicalRecordEntry()
                            let medicalRecord = MedicalRecords()
                            
                            medicalRecordEntry.medicalRecords = medicalRecord
                            medicalRecord.medicalRecordName = recordsDictObj.getString("record_name")
                            
                            if recordsDictObj.getString("interpretation") == "Abnormal"{
                                medicalRecordEntry.isAbnormalResult  = true
                            }else{
                                medicalRecordEntry.isAbnormalResult  = false
                            }
                            medicalRecordEntry.isImportedByPatient = medicalRecordGroupDict.getBoolean("ADDED_BY_PATIENT") ?? false
                            medicalRecordEntry.isImportedByPatient = true
                            medicalRecordEntry.date = CharmUtil.getDateObjectWith(dateString: medicalRecordGroupDict.getString("result_date") ?? "", dateFormat: sqlTimeStampFormat)
                            medicalRecordGroup.medicalRecordEntryList.append(medicalRecordEntry)
                            
                            arrayOfMedicalRecordGroup.append(medicalRecordGroup)
                        }
                    }
                }
            }
        }
        return arrayOfMedicalRecordGroup
    }
    
    static func formLabOrderList(dict : Dictionary<String,Any>) -> [UploadesFiles]{
        var labOrdersArray: [UploadesFiles] = []
        
        if let outputString = dict.getAsJsonObject("output_string"){
            if let labOrderList = outputString.getAsJsonArray("lab_order_list"){
                labOrderList.forEach { labOrder in
                    let labOrderObj = UploadesFiles()
                    let phrfileMap = PHRUploadedFilesMap()
                    
                    labOrderObj.fileSize = labOrder.getString("FILE_SIZE")
                    labOrderObj.isDeleted = labOrder.getBoolean("IS_DELETED") ?? false
                    labOrderObj.fileId = labOrder.getString("FILE_ID")
                    labOrderObj.fileName = labOrder.getString("FILE_NAME")
                    labOrderObj.uploadedBy = labOrder.getString("UPLOADED_BY")
                    labOrderObj.date = CharmUtil.getDateObjectWith(dateString: labOrder.getString("DATE") ?? "", dateFormat: PHR_DATE_API_FORMAT)
                    labOrderObj.timeOfUpload = labOrder.getString("TIME_OF_UPLOAD")?.toInt64OrNil()
                    labOrderObj.fileType = labOrder.getString("FILE_TYPE")
                    
                    
                    phrfileMap.practiceId = labOrder.getString("PRACTICE_ID")
                    phrfileMap.senderId = labOrder.getString("SENDER_ID")
                    phrfileMap.sharedDate = CharmUtil.getDateObjectWith(dateString: labOrder.getString("SHARED_DATE") ?? "", dateFormat: PHR_DATE_API_FORMAT)
                    phrfileMap.ehrEntryFileId = labOrder.getString("EHR_FILE_ENTRY_ID")
                    phrfileMap.receiverId = labOrder.getString("RECEIVER_ID")
                    phrfileMap.fileId = labOrder.getString("FILE_ID")
                    phrfileMap.readStatus = labOrder.getBoolean("READ_STATUS") ?? false
                    phrfileMap.messageToPatient = labOrder.getString("MESSAGE_TO_PATIENT")
                    phrfileMap.phrFileMapId = labOrder.getString("PHR_FILE_MAP_ID")
                    
                    labOrderObj.phrFileMap = phrfileMap
                    
                    if let practiceIdVSMemObj = outputString.getAsJsonObject("practice_id_vs_mem_obj"){
                        if let practiceId = practiceIdVSMemObj.getAsJsonObject(phrfileMap.practiceId ?? ""){
                            let member = Provider()
                            member.practiceId = phrfileMap.practiceId
                            if let memberId = practiceId.getAsJsonObject(labOrderObj.uploadedBy ?? ""){
                                member.memberId = labOrderObj.uploadedBy
                                member.fullName = memberId.getString("MEMBER_NAME")
                                member.prefix = memberId.getString("PREFIX")
                                member.degree = memberId.getString("DEGREE")
                                member.specialization = memberId.getString("SPECIALIZATION")
                            }
                            labOrderObj.member = member
                        }
                    }
                    if !labOrderObj.isDeleted{
                        labOrdersArray.append(labOrderObj)
                    }
                }
            }
        }
        return labOrdersArray
    }
    
    static func updateMedicalRecordGroupWithDictionary(dict : Dictionary<String,Any> , medicalRecordGroup : MedicalRecordGroup) -> MedicalRecordGroup
        {
            
            medicalRecordGroup.medicalRecordEntryList = []
            
            if (dict["message_to_patient"] != nil)
            {
                medicalRecordGroup.comments = dict["message_to_patient"] as? String
            }
            medicalRecordGroup.reportStatus = dict.getString("RESULT_STATUS")
            medicalRecordGroup.reviewerName = dict.getString("reviewer_name")

            for recordsDict in ((dict["records"] as? [Dictionary<String,Any>])!)
            {
                let medicalRecordEntry = MedicalRecordEntry()
                
                if medicalRecordEntry.medicalRecords == nil
                {
                    medicalRecordEntry.medicalRecords = MedicalRecords()
                }
                
                if (recordsDict["group_id"] != nil)
                {
                    medicalRecordEntry.medicalRecordId = recordsDict["record_id"] as? String
                }
                
                if (recordsDict["interpretation"] != nil)
                {
                    if ((recordsDict["interpretation"] as? String ) == "Abnormal" )
                    {
                        medicalRecordEntry.isAbnormalResult  = true
                    }else
                    {
                        medicalRecordEntry.isAbnormalResult  = false
                    }
                }
                
                if (recordsDict["record_name"] != nil)
                {
                    let medicalRecords = MedicalRecords()
                    medicalRecords.medicalRecordName = recordsDict["record_name"] as? String
                    medicalRecordEntry.medicalRecords = medicalRecords
                }
                
                if (recordsDict["entry_id"] != nil)
                {
                    medicalRecordEntry.medicalRecordEntryId = recordsDict["entry_id"] as? String
                }
                
                if (recordsDict["is_pdf_avail"] != nil)
                {
                    medicalRecordGroup.isPdfAvailable = recordsDict["is_pdf_avail"] as? Bool ?? false
                    medicalRecordEntry.pdfDocument = "\(recordsDict["is_pdf_avail"]!)"
                }
                
                for parametersDict in ((recordsDict["parameters"] as? [Dictionary<String,Any>])!)
                {
                    let medicalRecordMap = MedicalRecordMap()
                    
                    let medicalRecordParams = MedicalRecordParams()
                    let medicalRecordValues = MedicalRecordValues()
                    
                    medicalRecordMap.medicalRecordParams = medicalRecordParams
                    medicalRecordMap.medicalRecordValues = medicalRecordValues
                    
                    
                    if (parametersDict["param_id"] != nil)
                    {
                        medicalRecordParams.medicalRecordParamId = parametersDict["param_id"] as? String
                    }
                    if (parametersDict["param_name"] != nil)
                    {
                        medicalRecordParams.parameterName = parametersDict["param_name"] as? String
                    }
                    if (parametersDict["unit"] != nil)
                    {
                        medicalRecordParams.recordunit = parametersDict["unit"] as? String
                    }
                    
                    
                    if (parametersDict["range"] != nil)
                    {
                        medicalRecordValues.range = "\(parametersDict["range"]!)"
                    }
                    if (parametersDict["comments"] != nil)
                    {
                        medicalRecordValues.comment = "\(parametersDict["comments"]!)"
                    }
                    
                    if (parametersDict["ref_min"] != nil)
                    {
                        medicalRecordValues.referenceMin = "\(parametersDict["ref_min"]!)"
                    }
                    if (parametersDict["ref_max"] != nil)
                    {
                        medicalRecordValues.referenceMax = "\(parametersDict["ref_max"]!)"
                    }
                    if (parametersDict["param_value"] != nil)
                    {
                        medicalRecordValues.recordvalue = parametersDict["param_value"] as? String
                    }
                    if (parametersDict["interpretation"] != nil)
                    {
                        medicalRecordValues.interpretation = parametersDict["interpretation"] as? String
                    }
    
                    medicalRecordValues.medicalRecordEntryId = medicalRecordEntry.medicalRecordEntryId
                    medicalRecordValues.medicalRecordParamId = medicalRecordParams.medicalRecordParamId
                    
                    medicalRecordEntry.medicalRecordMapList.append(medicalRecordMap)
                }
                medicalRecordGroup.medicalRecordEntryList.append(medicalRecordEntry)
            }
            
            return medicalRecordGroup
        }
    
//MARK: - Allergy
    
    static func formAllergyList(dict: Dictionary<String,Any>, status: String?) -> [AllergiesList]{
        var allergyArray: [AllergiesList] = []
        
        if let outputString = dict["output_string"] as? [String: Any]{
            if let dataList = outputString["DATA_LIST"] as? [[String: Any]]{
                for dataListObj in dataList{
                    let allergiesList = AllergiesList()
                    let patientAllergyMap = PatientAllergyMap()
                    
                    if let status = status{
                        patientAllergyMap.status = status
                    }
                    allergiesList.allergyType = dataListObj.getString("ALLERGY_TYPE")
                    patientAllergyMap.reactions = dataListObj.getString("REACTIONS")
                    allergiesList.allergy = dataListObj.getString("ALLERGY")
                    patientAllergyMap.practiceId = dataListObj.getString("PRACTICE_ID")
                    let dateOfEntryString = dataListObj.getString("DATE_OF_ENTRY") ?? ""
                    patientAllergyMap.dateOfEntry = CharmUtil.getDateObjectWith(dateString: dateOfEntryString, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                    
                    if dataListObj.getString("OBSERVED_DATE") == "null"{
                        patientAllergyMap.observedDate = nil
                    }
                    else{
                        let observedDateString = dataListObj.getString("OBSERVED_DATE") ?? ""
                        patientAllergyMap.observedDate = CharmUtil.getDateObjectWith(dateString: observedDateString, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                    }
                    
                    let resolvedDateString = dataListObj.getString("RESOLVED_DATE") ?? ""
                    patientAllergyMap.resolvedDate = CharmUtil.getDateObjectWith(dateString: resolvedDateString, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                    patientAllergyMap.isActive = dataListObj.getBoolean("IS_ACTIVE") ?? false
                    patientAllergyMap.severity = dataListObj.getString("SEVERITY")
                    patientAllergyMap.isAddedByPatient = dataListObj.getBoolean("ADDED_BY_PATIENT") ?? false
                    allergiesList.allergyId = dataListObj.getString("ALLERGY_ID")
                    patientAllergyMap.practicePatientId = dataListObj.getString("PATIENT_ID")
                    allergiesList.patientAllergyMap = patientAllergyMap
                    
                    if patientAllergyMap.isAddedByPatient{
                        patientAllergyMap.allergyMapId = dataListObj.getString("ALLERGY_MAP_ID")
                    }
                    else{
                        patientAllergyMap.allergyMapId = "\(dataListObj.getInt("ALLERGY_MAP_ID") ?? 0)"
                    }
                    
                    if status == nil{
                        if patientAllergyMap.resolvedDate != nil
                        {
                            patientAllergyMap.status = "Resolved"
                        }
                        else if !patientAllergyMap.isAddedByPatient && !patientAllergyMap.isActive
                        {
                            patientAllergyMap.status = "Inactive"
                        }else
                        {
                            patientAllergyMap.status = "Active"
                        }
                    }
                    
                    allergyArray.append(allergiesList)
                }
            }
        }
        return allergyArray
    }
    
    static func giveArrayOfAllergyTypeFromDictionary(dict : Dictionary<String,Any>) -> Array<String>
    {
        if let alleryTypeArr = dict["ALLERGY_TYPE"] as? Array<String>
        {
            return alleryTypeArr
        }else
        {
            return []
        }
    }
    
    static func giveArrayOfAllergySeverityFromDictionary(dict : Dictionary<String,Any>) -> Array<String>
    {
        if let alleryTypeArr = dict["ALLERGY_SEVERITY"] as? Array<String>
        {
            return alleryTypeArr
        }else
        {
            return []
        }
    }
    
    static func giveArrayOfAllergyStatusFromDictionary(dict : Dictionary<String,Any>) -> Array<String>
    {
        if let alleryTypeArr = dict["ALLERGY_STATUS"] as? Array<String>
        {
            return alleryTypeArr
        }else
        {
            return []
        }
        
    }
    
//MARK: - Medication
    
    static func formMedicationList(respObj: Dictionary<String, Any>) -> [MedicationPOJO] {
        
        var medicationPOJOList: [MedicationPOJO] = []
        
        if let outputString = respObj.getAsJsonObject("output_string"){
            if let prescriptionList = outputString.getAsJsonArray("PRESCRIPTION_LIST"){
                prescriptionList.forEach({ prescriptionObj in
                    let medicationPOJO = MedicationPOJO()
                    let patientMedication = PatientMedication()
                    let medication = Medication()
                    
                    patientMedication.allowRefill = outputString.getBoolean("ALLOW_RX_REFILL") ?? false
                    
                    patientMedication.addedByPatient = prescriptionObj.getBoolean("ADDED_BY_PATIENT") ?? false
                    
                    patientMedication.fromDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: prescriptionObj.getString("START_DATE") ?? "")
                    patientMedication.toDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: prescriptionObj.getString("STOP_DATE") ?? "")
                    patientMedication.isActive = prescriptionObj.getBoolean("IS_ACTIVE") ?? false
                    
                    patientMedication.comment = prescriptionObj.getString("COMMENTS")
                    
                    if !patientMedication.addedByPatient{
                        
                        patientMedication.patientId = getSelectedPatientId()
                        patientMedication.patientMedicationId = prescriptionObj.getString("PATIENT_MEDICATION_ID")
                        patientMedication.addedAs = prescriptionObj.getString("ADDED_AS")
                        patientMedication.direction = prescriptionObj.getString("DIRECTIONS")
                        patientMedication.practiceId = prescriptionObj.getString("PRACTICE_ID")
                        patientMedication.memberId = prescriptionObj.getString("MEMBER_ID")
                        patientMedication.memberName = formMemberNameFrom(fullName: prescriptionObj.getString("FULL_NAME") ?? "", prefix: prescriptionObj.getString("PREFIX") ?? "")
                        
                        patientMedication.refill = prescriptionObj.getString("REFILL")
                        patientMedication.dispense = prescriptionObj.getString("DISPENSE")
                        
                        medication.uiType = outputString.getString("UI_TYPE")
                        medication.medicationName = prescriptionObj.getString("GENERIC_DRUG_NAME")
                        medication.tradeName = prescriptionObj.getString("TRADE_NAME")
                        medication.medicationId = prescriptionObj.getString("DRUGDETAILS_ID")
                        medication.genericProductName = prescriptionObj.getString("GENERIC_PRODUCT_NAME")
                        medication.eRxDisplayName = prescriptionObj.getString("DRUG_ERX_DISPLAY_NAME")
                    }
                    else{
                        patientMedication.patientId = prescriptionObj.getString("PATIENT_ID")
                        patientMedication.prescribedBy = prescriptionObj.getString("PRESCRIBED_BY")
                        patientMedication.patientMedicationId = prescriptionObj.getString("PRESCRIPTION_HISTORY_ID")
                        patientMedication.intakeRoute = prescriptionObj.getString("INTAKE_ROUTE")
                        patientMedication.dosageUnit = prescriptionObj.getString("DOSAGE_UNIT")
                        medication.numberOfIntake = "\(prescriptionObj.getInt("NUMBER_OF_INTAKE") ?? 0)"
                        if let frequency = prescriptionObj.getString("FREQUENCY"){
                            if frequency == "null"{
                                patientMedication.frequency = nil
                            }
                            else{
                                patientMedication.frequency = frequency
                            }
                        }
                        patientMedication.dosageWithUnit = prescriptionObj.getString("DOSAGE_WITH_UNIT")
                        patientMedication.intakeWhen = prescriptionObj.getString("INTAKE_WHEN")
                        patientMedication.intake = prescriptionObj.getString("INTAKE")
                        patientMedication.dosageUnitId = prescriptionObj.getString("DOSAGE_UNIT_ID")
                        patientMedication.dosage = prescriptionObj.getString("DOSAGE")
                        medication.intakeUnit = prescriptionObj.getString("INTAKE_UNIT")
                        patientMedication.medicalConditionId = prescriptionObj.getString("MEDICAL_CONDITION_ID")
                        
                        medication.medicationName = prescriptionObj.getString("PRESCRIPTION_NAME")
                        medication.medicationId = prescriptionObj.getString("PRESCRIPTION_ID")
                    }
                    
                    if let remindersArr = prescriptionObj.getAsJsonArray("REMINDERS"){
                        
                        for dict in remindersArr{
                            if let endDate = dict.getString("end_date"),
                               let dateObj = CharmUtil.getDateObjectWith(dateString: endDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
                                
                                if dateObj.startOfDay >= Date().startOfDay{
                                    patientMedication.isReminderPresent = true
                                    break
                                }
                            }
                        }
                    }
                    
                    patientMedication.medicationId = medication.medicationId
                    medicationPOJO.medication = medication
                    medicationPOJO.patientMedication = patientMedication
                    medicationPOJOList.append(medicationPOJO)
                })
            }
        }
        return medicationPOJOList
    }
   
//MARK: - Supplement
    
    static func formSupplementList(respObj: Dictionary<String, Any>, practiceId: String) -> [SupplementPOJO] {
        var supplementPOJOList: [SupplementPOJO] = []

        let outputString = respObj.getAsJsonObject("output_string")

        if let supplementArr = outputString?.getAsJsonArray("SUPPLEMENT_LIST"){
            supplementArr.forEach { supplementObj in

                let supplementPOJO = SupplementPOJO()
                let patientSupplement = PatientSupplement()
                let supplement = Supplement()

                patientSupplement.allowRefill = outputString?.getBoolean("ALLOW_SX_REFILL") ?? false
                patientSupplement.isAddedByPatient = supplementObj.getBoolean("ADDED_BY_PATIENT")
                    ?? false
                let startDateStr = supplementObj.getString("FROM_DATE")
                if (!startDateStr.isNilOrBlank()) {
                    patientSupplement.fromDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: startDateStr ?? "")
                }
                let stopDateStr = supplementObj.getString("TO_DATE")
                if (!stopDateStr.isNilOrBlank()) {
                    patientSupplement.toDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: stopDateStr ?? "")
                }
                patientSupplement.comments = supplementObj.getString("COMMENTS")
                patientSupplement.frequency = supplementObj.getString("FREQUENCY")
                patientSupplement.dosage = "\(supplementObj.getInt("DOSAGE") ?? 0)"
                patientSupplement.dosageUnitId = "\(supplementObj.getInt("DOSAGE_UNIT_ID") ?? 0)"
                patientSupplement.dosageUnit = supplementObj.getString("DOSAGE_UNIT")
                patientSupplement.dosageWithUnit = supplementObj.getString("DOSAGE_WITH_UNIT")
                
                if patientSupplement.isAddedByPatient == true{
                    
                    patientSupplement.patientSupplementId =
                        supplementObj.getString("SUPPLEMENT_HISTORY_ID")
                    patientSupplement.intake = supplementObj.getString("INTAKE")
                    supplement.intakeUnit = supplementObj.getString("INTAKE_UNIT")
                    patientSupplement.intakeWhen = supplementObj.getString("INTAKE_WHEN")
                    
                    if let remindersArr = supplementObj.getAsJsonArray("REMINDERS"){
                        
                        for dict in remindersArr{
                            if let endDate = dict.getString("end_date"),
                               let dateObj = CharmUtil.getDateObjectWith(dateString: endDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR){
                                
                                if dateObj.startOfDay >= Date().startOfDay{
                                    patientSupplement.isReminderPresent = true
                                    break
                                }
                            }
                        }
                    }
                    
                }
                else{
                    patientSupplement.practiceId = practiceId
                    patientSupplement.patientSupplementId =
                        supplementObj.getString("PATIENT_SUPPLEMENT_ID")
                    patientSupplement.isActive = supplementObj.getBoolean("IS_ACTIVE") ?? false
                    patientSupplement.instructions = supplementObj.getString("INSTRUCTIONS")
                }
                
                patientSupplement.patientId = getSelectedPatientId()
                supplement.supplementId = supplementObj.getString("SUPPLEMENT_ID")
                supplement.supplementName = supplementObj.getString("SUPPLEMENT_NAME")
                supplement.manufacturerName = supplementObj.getString("MANUFACTURER_NAME")
                supplement.manufacturerId = supplementObj.getString("MANUFACTURER_ID")

                patientSupplement.supplementId = supplement.supplementId
                supplement.numberOfIntake = "\(supplementObj.getInt("NUMBER_OF_INTAKE") ?? 0)"
                patientSupplement.memberName = supplementObj.getString("PRESCRIBED_BY")
                patientSupplement.memberId = supplementObj.getString("PHYSICIAN_ID")
                
                supplementPOJO.patientSupplement = patientSupplement
                supplementPOJO.supplement = supplement
                supplementPOJOList.append(supplementPOJO)

            }
        }
        return  supplementPOJOList
    }
    
//MARK: - Visit Summary
    
    static func formVisitSummaryList(respObj : Dictionary<String,Any>) -> [PatientEncounterList]{

        var visitSummaryList: [PatientEncounterList] = []
        if let outputString = respObj["output_string"] as? Dictionary<String,Any> {
            let enabledPracticeList = getEnabledPractices(moduleId: visitSummaryModelId)

            if let consultationArr = outputString["PAST_ENCOUNTER_LIST"] as? [Dictionary<String,Any>]
               {
                
                let facilityMap = outputString["CONSULTATION_VS_FACILITY"] as? Dictionary<String,Any>
                let memberMap = outputString["MEMBER_ID_VS_DETAIL"] as? Dictionary<String,Any>

                consultationArr.forEach({consultationObj in

                    let practiceId = consultationObj.getString("PRACTICE_ID") ?? ""

                    if enabledPracticeList.contains(practiceId){

                        let visitSummary = PatientEncounterList()

                        let dateStr = consultationObj.getString("CONSULTATION_DATE") ?? ""

                        if dateStr.isNotBlank(){
                            visitSummary.date = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: dateStr)
                        }
                        visitSummary.readStatus = consultationObj.getBoolean("READ_STATUS")
                        ?? false
                        visitSummary.patientEncounterId =
                        consultationObj.getString("PATIENT_ENCOUNTER_ID")

                        let consultationId =
                        consultationObj.getString("PRACTICE_CONSULTATION_ID")
                            ?? ""

                        let facilityObj = facilityMap?.getAsJsonObject(consultationId)

                        visitSummary.reason = consultationObj.getString("REASON")
                        visitSummary.practiceId = practiceId


                        let fileId = consultationObj.getString("DOCUMENT_ID") ?? ""

                        if (!fileId.contains(errorValueNull)) {
                            visitSummary.fileId = fileId
                        }

                        visitSummary.facility = formFacilityObj(facilityObj: facilityObj)

                        let memberId = consultationObj.getString("MEMBER_ID") ?? ""
                        let memberObj = memberMap?.getAsJsonObject(memberId)
                        

                        visitSummary.member = formMemberObj(memberObj: memberObj, memberId: memberId)

                        let consultation = Consultation()
                        consultation.consultationId = consultationId
                        visitSummary.consultation = consultation


                        visitSummaryList.append(visitSummary)

                    }
                })
            }
        }

        return visitSummaryList
    }
    
    static private func formMemberObj(memberObj: Dictionary<String,Any>?, memberId: String) -> Provider? {
        if let memberObj = memberObj {

            let member = Provider()
            member.memberId = memberId
            member.fullName = memberObj.getString("MEMBER_NAME")
            member.degree = memberObj.getString("DEGREE")
            member.specialization = memberObj.getString("SPECIALIZATION")
            member.prefix = memberObj.getString("PREFIX")

            return member
        }

        return nil
    }
    
//MARK: - Vaccine
    
    static func formVaccineList(respObj: Dictionary<String,Any> , practiceId: String) -> [VaccineImmunizationPOJO]{
        
        var vaccineList:[VaccineImmunizationPOJO] = []
        
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>
        {
            
            if let vaccineArr = outputData["DATA_LIST"] as? [Dictionary<String,Any>]{
                
                vaccineArr.forEach({vaccineObj in
                    
                    let vaccineImmunizationPOJO = VaccineImmunizationPOJO()
                    vaccineImmunizationPOJO.practiceId = practiceId                    
                    vaccineImmunizationPOJO.addedByPatient = vaccineObj.getBoolean("ADDED_BY_PATIENT")
                        ?? false

                    let dateOfVaccinationStr = vaccineObj.getString("DATE_OF_IMMUNIZATION") ?? ""
                    
                    if (vaccineImmunizationPOJO.addedByPatient) {
                        
                        let immuneMap = PatientImmunizationMap()
                        let immunization = ImmunizationList()
                        let immuneHistory = PatientImmunizationHistory()

                        immunization.immunizationName = vaccineObj.getString("IMMUNIZATION_NAME")
                        immunization.immunizationType = vaccineObj.getString("IMMUNIZATION_TYPE")
                        immunization.immunizationId = "\(vaccineObj.getInt("IMMUNIZATION_ID") ?? 0)"
                        
                        immuneHistory.immunizationHistoryId =
                            vaccineObj.getString("IMMUNIZATION_HISTORY_ID")

                        let notesEle = vaccineObj.getString("COMMENTS")
                        immuneHistory.comments = notesEle


                        let givenByEle = vaccineObj.getString("GIVEN_BY")
                        immuneHistory.givenBy = givenByEle


                        let howAdministeredEle = vaccineObj.getString("HOW_ADMINISTERED")
                        immuneHistory.howAdministered = howAdministeredEle


                        let manufacturerEle = vaccineObj.getString("MANUFACTURER")
                        immuneHistory.manufacturer = manufacturerEle


                        if (dateOfVaccinationStr.isNotBlank()) {
                            immuneHistory.vaccinesOn = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: dateOfVaccinationStr)
                        }
                        immuneMap.patientImmunizationHistory = immuneHistory
                        immuneMap.immunizationList = immunization
                        vaccineImmunizationPOJO.patientImmunizationMap = immuneMap
                    }
                    else{

                        let vaccineMap = PatientVaccineMap()
                        let vaccine = VaccinesList()
                        
                        vaccine.vaccineName = vaccineObj.getString("VACCINE_NAME")
                        vaccineMap.administeredAmount = vaccineObj.getString("ADMINISTERED_AMOUNT")
                        
                        if (dateOfVaccinationStr.isNotBlank()) {
                            vaccineMap.dateOfVaccination = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: dateOfVaccinationStr)
                        }

                        let member = Provider()
                        member.fullName = vaccineObj.getString("ORDERING_PROVIDER")
                        ?? ""
                        vaccineMap.orderingProvider = member
                        

                        vaccineMap.site = vaccineObj.getString("SITE")
                        vaccineMap.route = vaccineObj.getString("ROUTE")

                        vaccineMap.vaccine = vaccine
                        vaccineImmunizationPOJO.patientVaccineMap = vaccineMap
                    }
                    vaccineList.append(vaccineImmunizationPOJO)
                })
            }
        }
        return vaccineList
    }
    
//MARK: - Procedures
    
    static func formProcedureList(resp : Dictionary<String,Any>) -> [ProceduresList]{
        var procedureArray: [ProceduresList] = []
        if let outputString = resp["output_string"] as? [[String:Any]]{
            for procedureObj in outputString{
                let procedureList = ProceduresList()
                procedureList.fromDate = CharmUtil.getDateObjectWith(dateString: procedureObj.getString("FROM_DATE") ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                procedureList.toDate = CharmUtil.getDateObjectWith(dateString: procedureObj.getString("TO_DATE") ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                procedureList.comments = procedureObj.getString("NOTES")
                procedureList.procedureId = procedureObj.getString("PROCEDURE_ID")
                procedureList.procedureName = procedureObj.getString("PROCEDURE")
                procedureList.procedureType = procedureObj.getString("PROCEDURE_TYPE")
                procedureList.procedureMapId = procedureObj.getString("PROCEDURE_MAP_ID")
                procedureArray.append(procedureList)
            }
        }
        return procedureArray
    }
    
//MARK: - Announcement
    
    static func formAnnouncementList(dict: [String:Any]) -> [Announcement]{
        var announcementList: [Announcement] = []
        if let outputString = dict["output_string"] as? [String: Any]{
            
            outputString.keys.forEach({key in
                
                if let announcementObj = outputString[key] as? Dictionary<String ,Any>{
                    let announcement = Announcement()
                    
                    announcement.announcementId = announcementObj.getString("ANNOUNCEMENT_ID")
                    announcement.isRead = announcementObj.getBoolean("IS_READ") ?? false
                    announcement.practiceId = announcementObj.getString("PRACTICE_ID")
                    announcement.practiceAnnouncementId = announcementObj.getString("PRACTICE_ANNOUNCEMENT_ID")
                    announcement.status = announcementObj.getString("STATUS")
                    announcement.isDeleted = announcementObj.getBoolean("IS_DELETED") ?? false
                    announcement.senderId = announcementObj.getString("SENDER_ID")
                    announcement.subject = announcementObj.getString("SUBJECT")
                    
                    let timeString = announcementObj.getString("TIME") ?? ""
                    announcement.time = Date.getDateFromString(dateFormat: "yyyy/MM/dd HH:mm:ss", dateString: timeString)
                    announcement.content = announcementObj.getString("CONTENT")
                    announcementList.append(announcement)
                }
            })
        }
        return announcementList
    }
    
//MARK: - Useful Info
    
    static func formUsefulInfo(dict: [String: Any]) -> [UsefulInfo]{
        
        var usefulInfoList: [UsefulInfo] = []
        
        if let outputString = dict["output_string"] as? [[String:Any]]{
            for usefulInfoObj in outputString{
                let usefulInfo = UsefulInfo()
                
                usefulInfo.infoId = usefulInfoObj.getString("Info_id")
                usefulInfo.category = usefulInfoObj.getString("Category")
                usefulInfo.practiceId = usefulInfoObj.getString("PRACTICE_ID")
                usefulInfo.infoFile = usefulInfoObj.getString("Info_file")
                usefulInfo.time = Date.getDateFromString(dateFormat: "yyyy-MM-dd HH:mm:ss.S", dateString: usefulInfoObj.getString("Time") ?? "")
                
                usefulInfoList.append(usefulInfo)
            }
        }
        return usefulInfoList
    }
    
//MARK: - About
    
    static func formAboutDetail(respObj: [String: Any]) -> About{
        let about = About()
        
        if let  outputData = respObj.getAsJsonObject("output_string") {
        
            let practiceId = outputData.getString("PRACTICE_ID")


            let facilityArr = outputData.getAsJsonArray("FACILITIES_LIST")
            
            facilityArr?.forEach { facilityObj in

                let facility = Facility()

                facility.facilityName = facilityObj.getString("FACILITY_NAME")
                facility.facilityId = facilityObj.getString("FACILITY_ID")
                facility.direction = facilityObj.getString("DIRECTION")

//                    let postalAddress = PostalAddress()

                let line1 = facilityObj.getString("LINE_1") ?? ""
                if (line1.isNotBlank() && line1.lowercased() != "null") {
                    facility.line1 = line1
                }

                let line2 = facilityObj.getString("LINE_2") ?? ""
                if (line2.isNotBlank() && line2.lowercased() != "null") {
                    facility.line2 = line2
                }

//                    let contactDetails = ContactDetails()
                let landline = facilityObj.getString("LANDLINE") ?? ""
                if (landline.isNotBlank() && landline.lowercased() != "null") {
                    facility.landline = landline
                }
//                    facility.postalAddress = postalAddress
//                    facility.contactDetails = contactDetails

                facility.practiceId = practiceId
                about.facilityList.append(facility)
            }

            let providerArr = outputData.getAsJsonArray("PROVIDERS_LIST")

            providerArr?.forEach { providerObj in

                let member = Provider()

                member.fullName = providerObj.getString("FULL_NAME")
                member.prefix = providerObj.getString("PREFIX")

                let degree = providerObj.getString("DEGREE") ?? ""
                if (degree.isNotBlank() && degree.lowercased() != "null") {
                    member.degree = degree
                }


                let specialization = providerObj.getString("SPECIALIZATION") ?? ""
                if (specialization.isNotBlank() && specialization.lowercased() != "null") {
                    member.specialization = specialization
                }

                member.practiceId = practiceId

                about.providerList.append(member)

            }
        }
        return about
    }
        
//MARK: - Payment
    
    static func updatePaymentDetailWithDictionary(paymentInfo:PaymentInfo? ,dict : Dictionary<String,Any>) ->  PaymentInfo?
    {
        
        let transactionInfo = paymentInfo?.transactionInfo
        if let outputString = dict["output_string"] as? Dictionary<String,Any>
        {
            if (outputString["transaction_id"] != nil)
            {
                transactionInfo?.transactionId = outputString["transaction_id"] as? String
            }
            
            if (outputString["public_token"] != nil)
            {
                transactionInfo?.publicToken = outputString["public_token"] as? String
            }
            if (outputString["razorpay_order_id"] != nil)
            {
                transactionInfo?.razorPayOrderId = outputString["razorpay_order_id"] as? String
            }

            if (outputString["client_id"] != nil)
            {
                transactionInfo?.clientId = outputString["client_id"] as? String
            }
            
            if (outputString["mobile"] != nil)
            {
                transactionInfo?.mobile = outputString["mobile"] as? String
            }
            
            if (outputString["email"] != nil)
            {
                transactionInfo?.emailId = outputString["email"] as? String
            }
        }
         
        return paymentInfo
    }
    
    
    static func getReceiptIdForBluefin(respObj: Dictionary<String,Any> , isEHRReceipt: Bool) -> Any {
        
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>{
            
            
            if let isTransactionReported = outputData.getBoolean("is_transaction_reported") {
                
                if isTransactionReported {
                    
                    if let receiptArr = outputData["receipt_details"] as? Array<Dictionary<String,Any>>{
                        
                        if let receiptDetailObj = receiptArr.last {
                            
                            var receiptKey = "phr_receipt_id"
                            
                            if (isEHRReceipt){
                                receiptKey = "ehr_receipt_id"
                            }
                            
                            return receiptDetailObj.getString(receiptKey) ?? NSError(domain: "Error Occured", code: errorPaymentSuccessButReceiptFailedCode)
                        }
                    }
                }
            }
        }
        return NSError(domain: "Error Occured", code: errorPaymentSuccessButReceiptFailedCode)
    }
    
    
    static func isTransactionSuccessForBluefin(respObj: Dictionary<String,Any> ) -> Bool {
        
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>{
            
            if let isTransactionReported = outputData.getBoolean("is_transaction_reported") {
                return isTransactionReported
            }
            
            
        }
        return false
    }
    
    static func onCreateTransactionSuccess(respObj: Dictionary<String,Any> , paymentInfo: PaymentInfo ) -> Dictionary<String,Any>?  {
        
        debugPrintLog("transaction Success ->\(respObj)")
        
        if let transactionInfo = paymentInfo.transactionInfo{
            return onCreateTransactionSuccess(respObj: respObj, transactionInfo: transactionInfo)
        }
        return nil
    }
    
//MARK: - Card on file
    
    static func onCreateTransactionSuccess(respObj: Dictionary<String,Any> , transactionInfo: TransactionInfo ) -> Dictionary<String,Any>?  {
                
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>{
            transactionInfo.transactionId = outputData.getString("transactionId")
            return outputData
        }
        return nil
    }
    
    static func getBluefinURLFromTransaction(respObj: Dictionary<String,Any>) -> String  {
                
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>{
            return outputData.getString("bluefin_url") ?? ""
        }
        return ""
    }
    
    
    static func getMerchantAccountList(respObj:Dictionary<String,Any>) -> [MerchantAccountInfo]{
        var merchantAccountList:[MerchantAccountInfo] = []
        if let merchantAccArr = respObj["output_string"] as? [Dictionary<String,Any>]{
            
            merchantAccArr.forEach({merchantAccObj in
                
                let merchantAccount = MerchantAccountInfo()
                merchantAccount.merchantAccountId = merchantAccObj.getString("merchant_account_id")
                merchantAccount.facilityId = merchantAccObj.getString("facility_id")
                merchantAccount.title = merchantAccObj.getString("title")
                
                merchantAccountList.append(merchantAccount)
            })
        }
        
        return merchantAccountList
    }
    
    static func getCardGroupId(respObj:Dictionary<String,Any>) -> String{
        if let groupObj = respObj["output_string"] as? Dictionary<String,Any>{
            return groupObj.getString("group_id") ?? ""
        }
        
        return ""
    }
    
    static func formPaymentInfoList(primaryPaymentInfo: PaymentInfo , merchantAccountList:[MerchantAccountInfo]) -> [PaymentInfo]{
        var paymentInfoList:[PaymentInfo] = []
        
        merchantAccountList.forEach({merchantAccount in
            
            let paymentInfo = PaymentInfo()
            let transactionInfo = TransactionInfo()
            transactionInfo.practiceId = primaryPaymentInfo.transactionInfo?.practiceId
            transactionInfo.facilityId = merchantAccount.facilityId
            transactionInfo.memberId = primaryPaymentInfo.transactionInfo?.memberId
            transactionInfo.patientId = primaryPaymentInfo.transactionInfo?.patientId
            transactionInfo.merchantAccountId = merchantAccount.merchantAccountId
            transactionInfo.billId = primaryPaymentInfo.transactionInfo?.billId
            transactionInfo.service = primaryPaymentInfo.transactionInfo?.service
            transactionInfo.paymentAmount = primaryPaymentInfo.transactionInfo?.paymentAmount
            transactionInfo.currentDate = primaryPaymentInfo.transactionInfo?.currentDate
            transactionInfo.transactionId = primaryPaymentInfo.transactionInfo?.transactionId
            transactionInfo.razorPayOrderId = primaryPaymentInfo.transactionInfo?.razorPayOrderId
            transactionInfo.razorPayPaymentId = primaryPaymentInfo.transactionInfo?.razorPayPaymentId
            transactionInfo.clientId = primaryPaymentInfo.transactionInfo?.clientId
            transactionInfo.publicToken = primaryPaymentInfo.transactionInfo?.publicToken
            transactionInfo.paymentAntFromAPI = primaryPaymentInfo.transactionInfo?.paymentAntFromAPI
            transactionInfo.emailId = primaryPaymentInfo.transactionInfo?.emailId
            transactionInfo.mobile = primaryPaymentInfo.transactionInfo?.mobile
            transactionInfo.gateway = primaryPaymentInfo.transactionInfo?.gateway
            transactionInfo.nickName = primaryPaymentInfo.transactionInfo?.nickName

            paymentInfo.cardNumber = primaryPaymentInfo.cardNumber
            paymentInfo.cardHolderName = primaryPaymentInfo.cardHolderName
            paymentInfo.cardExpMonth = primaryPaymentInfo.cardExpMonth
            paymentInfo.cardExpYear = primaryPaymentInfo.cardExpYear
            paymentInfo.cardCvv = primaryPaymentInfo.cardCvv
            paymentInfo.chargeAmount = primaryPaymentInfo.chargeAmount
            paymentInfo.chargeProcessingType = primaryPaymentInfo.chargeProcessingType
            paymentInfo.chargeType = primaryPaymentInfo.chargeType
            paymentInfo.transactionType = primaryPaymentInfo.transactionType
            paymentInfo.cardDetails = primaryPaymentInfo.cardDetails
            paymentInfo.transactionInfo = transactionInfo

            paymentInfoList.append(paymentInfo)
        })
        
        return paymentInfoList
    }
    
    static func getCardList(respObj: Dictionary<String,Any>, practiceId: String) -> CardMetaObj{
        let cardMeta:CardMetaObj = CardMetaObj()
        cardMeta.practiceId = practiceId
        if let outputData = respObj["output_string"] as? Dictionary<String,Any> {
            
            let allowPracCardDelete = outputData.getBoolean("allow_prac_card_deletion") ?? false
            
            if let patientCardArr = outputData["patient_cards"] as? [Dictionary<String,Any>] {
                patientCardArr.forEach({patientCardObj in
                    let card = getCardDetail(cardObj: patientCardObj)
                    card.allowPracticeCardDeletion = allowPracCardDelete
                    card.practiceId = practiceId
                    cardMeta.cardList.append(card)
                })
            }
            
            if let practiceCardArr = outputData["practice_cards"] as? [Dictionary<String,Any>] {
                practiceCardArr.forEach({patientCardObj in
                    let card = getCardDetail(cardObj: patientCardObj)
                    card.allowPracticeCardDeletion = allowPracCardDelete
                    card.practiceId = practiceId
                    cardMeta.cardList.append(card)
                })
            }
            
            if PrimaryDataHandler.sharedInstance.countriesArr == nil || PrimaryDataHandler.sharedInstance.countriesArr?.isEmpty == true{
                if let countryObj = outputData["country_list"] as? Dictionary<String , Any> {
                    var countryList: [DataWithId] = []
                    for (key,value) in countryObj  {
                        let countryObj = DataWithId()
                        countryObj.value = key
                        if let value = value as? String {
                            countryObj.key = value
                            countryList.append(countryObj)
                        }
                    }
                    countryList.sort{
                        $0.value < $1.value
                    }
                    PrimaryDataHandler.sharedInstance.countriesArr = countryList
                }
            }
            if let addressObj = outputData["patient_address"] as? Dictionary<String,Any> {
                
                let address = PostalAddress()
                address.line1 = addressObj.getString("LINE_1")
                address.line2 = addressObj.getString("LINE_2")
                address.city = addressObj.getString("CITY")
                address.state = addressObj.getString("STATE")
                address.country = addressObj.getString("COUNTRY")
                address.postalCode = addressObj.getString("POSTALCODE")
                cardMeta.patientAddress = address
            }
        }
        return cardMeta
    }
    
    static func formPaymentInfo(from statement: PHRBillStatements) -> PaymentInfo{
        let paymentInfo = PaymentInfo()
        paymentInfo.chargeAmount = statement.paymentRequest
        
        if statement.storeCardInFile {
            paymentInfo.transactionType = appointmentTransactionTypeAuthorization
            paymentInfo.chargeProcessingType = appointmentCardProcessingTypeStoreCharge
        }
        else{
            paymentInfo.transactionType = appointmentTransactionTypeSale
            paymentInfo.chargeProcessingType = appointmentCardProcessingTypeChargeOnly
        }
        

        paymentInfo.isPartialPaymentEnabled = statement.isPartialPaymentEnabled
        paymentInfo.minAllowedAmount = statement.minAllowedAmount
        
        let transactionInfo = TransactionInfo()
        transactionInfo.practiceId = statement.practiceId
        transactionInfo.facilityId = statement.facilityId
        transactionInfo.memberId = statement.sharedBy
        transactionInfo.service = paymentServiceBilling
        transactionInfo.merchantAccountId = statement.merchantAccountId
        transactionInfo.paymentAmount = statement.paymentRequest
        transactionInfo.patientId = getSelectedPatientId()
        transactionInfo.statementId = statement.statementId
        transactionInfo.gateway = "BLUEFIN"
        paymentInfo.transactionInfo = transactionInfo
        
        return paymentInfo
    }
    
    static func formStatementDetail(respObj: Dictionary<String, Any>) -> PHRBillStatements {
        let statement = PHRBillStatements()
        
        if let outputData = respObj["output_string"] as? Dictionary<String,Any> {
            
            statement.isRead = outputData.getBoolean("is_read") ?? false
            statement.statementId = outputData.getString("phr_statement_id")
            statement.merchantAccountId = outputData.getString("merchant_account_id")
            statement.paymentRequest = outputData.getString("payment_requested")
            statement.isPaid = outputData.getBoolean("is_paid") ?? false
            statement.isPartialPaymentEnabled = outputData.getBoolean("is_partial_payment_allowed") ?? false
            statement.minAllowedAmount = outputData.getString("minimum_payment_amount")
            
            statement.storeCardInFile = outputData.getBoolean("save_card_details") ?? false
            
            if let facilityObj = outputData["facility"] as? Dictionary<String,Any>{
                statement.facilityId = facilityObj.getString("facility_id")
            }
            
            if let memberObj = outputData["shared_by"] as? Dictionary<String,Any>{
                statement.sharedBy = memberObj.getString("member_id")
            }
            
            if let invoiceDetailArray = outputData.getAsJsonArray("invoice_details"){
                var phrbillsList: [PHRBills] = []
                invoiceDetailArray.forEach { invoiceDetailObj in
                    let phrBills = PHRBills()
                    phrBills.billNumber = invoiceDetailObj.getString("bill_number")
                    phrBills.billAmount = invoiceDetailObj.getString("bill_amount")
                    phrBills.dueAmount = invoiceDetailObj.getString("due_amount")
                    phrBills.billDate = Date.getDateFromString(dateFormat: PHR_DATE_API_FORMAT, dateString: invoiceDetailObj.getString("bill_date") ?? "")
                    phrBills.amount = invoiceDetailObj.getString("payment_requested")
                    phrBills.status = invoiceDetailObj.getString("bill_status")
                    
                    let patient = Patient()
                    
                    patient.patientId = invoiceDetailObj.getString("patient_id")
                    patient.patRecordId = invoiceDetailObj.getString("patient_record_id")
                    patient.fullName = invoiceDetailObj.getString("patient_name")

                    phrBills.patient = patient
                    
                    phrbillsList.append(phrBills)
                }
                statement.phrBills = phrbillsList
            }
        }
        return statement
    }
    
    private static func getCardDetail(cardObj: Dictionary<String,Any>) -> PaymentGatewayToken {
        let paymentGatewayToken = PaymentGatewayToken()
        
        paymentGatewayToken.cardBrand = cardObj.getString("CARD_BRAND")
        paymentGatewayToken.cardDigit = cardObj.getString("CARD_DIGIT")
        paymentGatewayToken.cardNickName = cardObj.getString("CARD_NICK_NAME")
        paymentGatewayToken.expiry = cardObj.getString("EXPIRY_DATE")
        paymentGatewayToken.facilityId = cardObj.getString("FACILITY_ID")
        paymentGatewayToken.hasCardExpired = cardObj.getBoolean("HAS_CARD_EXPIRED") ?? false
        paymentGatewayToken.isPHRCard = cardObj.getBoolean("IS_PHR_CARD") ?? false
        paymentGatewayToken.isPrimaryCard = cardObj.getBoolean("IS_PRIMARY_CARD") ?? false
        paymentGatewayToken.merchantAccountId = cardObj.getString("MERCHANT_ACCOUNT_ID")
        paymentGatewayToken.nameOnCard = cardObj.getString("NAME_ON_CARD")
        paymentGatewayToken.patientId = cardObj.getString("PATIENT_ID")
        paymentGatewayToken.practicePatientId = cardObj.getString("PRACTICE_PATIENT_ID")
        paymentGatewayToken.tokenId = cardObj.getString("TOKEN_ID")
        paymentGatewayToken.token = cardObj.getString("TOKEN")
        
        let postalAddress = PostalAddress()
        postalAddress.line1 = cardObj.getString("STREET_ADDRESS1")
        postalAddress.line2 = cardObj.getString("STREET_ADDRESS2")
        postalAddress.city = cardObj.getString("CITY")
        postalAddress.state = cardObj.getString("STATE")
        postalAddress.country = cardObj.getString("COUNTRY")
        postalAddress.postalCode = cardObj.getString("ZIP")
        
        paymentGatewayToken.postalAddress = postalAddress

        return paymentGatewayToken
    }
    
//MARK: - Documents
    
    static func getArrayOfDocuments(dict : Dictionary<String,Any>) -> [Document]
    {
        var arrayOfDocument : Array<Document> = []
        
        if let arrayOfDocumentDict = dict.getAsJsonArray("output_string")
        {
            for documentDict in arrayOfDocumentDict
            {
                let document = Document()
                
                document.categoryId = documentDict.getString("CATEGORY_ID")
                document.fileSize = documentDict.getString("FILE_SIZE")
                document.senderId = documentDict.getString("SENDER_ID")
                document.sentby = documentDict.getString("SENT_BY")
                document.categoryDescription = documentDict.getString("CATEGORY_DESCRIPTION")
                document.sharedDate = CharmUtil.getDateObjectWith(dateString: documentDict.getString("SHARED_DATE") ?? "", dateFormat: PHR_DATE_API_FORMAT)
                document.receiverId = documentDict.getString("RECEIVER_ID")
                document.fileId = documentDict.getString("FILE_ID")
                document.fileName = documentDict.getString("FILE_NAME")
                document.date = CharmUtil.getDateObjectWith(dateString: documentDict.getString("DATE") ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                document.ehrFileId = documentDict.getString("EHR_FILE_ID")
                document.contentType = documentDict.getString("CONTENT_TYPE")
                document.readStatus = documentDict.getBoolean("READ_STATUS") ?? false
                document.timeOfUpload = documentDict.getInt("TIME_OF_UPLOAD")
                document.fileType = documentDict.getString("FILE_TYPE")
                document.messageToPatient = documentDict.getString("MESSAGE_TO_PATIENT")
                document.categoryName = documentDict.getString("CATEGORY_NAME")
                document.fileStatusId = documentDict.getString("FILE_STATUS_ID")
                document.sharedByMeArr = documentDict.getAsStringArray("SHARED_BY_ME_PRAC_NAME") ?? []
                
                if document.senderId == nil{
                    document.readStatus = true
                }
                
                arrayOfDocument.append(document)
            }
        }
        return arrayOfDocument
    }
    
    static func formDocumentObj(json: [String: Any], fileSize: String) -> Document{
         let document = Document()
        document.fileSize = fileSize
        
        if let dict = json.getAsJsonObject("output_string"){
            document.categoryName = dict.getString("CATEGORY_NAME")
            document.fileId = dict.getString("FILE_ID")
            document.fileName = dict.getString("FILE_NAME")
        }
        return document
    }
    
    static func fillArrayOfDocumentCategory(dict : Dictionary<String,Any>) -> Array<DocumentCategory>
    {
        
        var arrayOfDocumentCategory : Array<DocumentCategory> = []
        
        if let outputString = dict["output_string"] as? Array<Any>
        {
            let categoryDictArr = outputString[0] as! Array<Dictionary<String, Any>>
            for categoryDict in categoryDictArr
            {
                let documentCategory = DocumentCategory()
                
                if categoryDict["CATEGORY_ID"] != nil
                {
                    documentCategory.categoryId = categoryDict["CATEGORY_ID"] as? String
                }
                
                if categoryDict["CATEGORY_NAME"] != nil
                {
                    documentCategory.name = categoryDict["CATEGORY_NAME"] as? String
                }
                
                if categoryDict["CREATED_ON"] != nil
                {
                    documentCategory.createdOn = categoryDict["CREATED_ON"] as? String
                }
                
                if categoryDict["DESCRIPTION"] != nil
                {
                    documentCategory.description = categoryDict["DESCRIPTION"] as? String
                }
                
                if !isNilOrEmpty(string: categoryDict["IS_DELETED"] as? String)
                {
                    if (categoryDict["IS_DELETED"] as! String).lowercased() == "false"
                    {
                        documentCategory.isDeleted = false
                    }
                    else
                    {
                        documentCategory.isDeleted = true
                    }
                }
                
                if categoryDict["MODIFIED_ON"] != nil
                {
                    documentCategory.modifiedOn = categoryDict["MODIFIED_ON"] as? String
                }
                
                arrayOfDocumentCategory.append(documentCategory)
            }
        }
        return arrayOfDocumentCategory
    }
    
//MARK: - Treating Physician
    
    static func getArrayOfTreatingPhysicians(dict : Dictionary<String,Any>) -> [Provider]
    {
        var arrayOfProvider : Array<Provider> = []
        
        if let outputString = dict["output_string"] as? Dictionary<String,Any>
        {
            if let medcontactList = outputString["MEDCONTACT_LIST"] as? [Dictionary<String,Any>]
            {
                for medContactDict in medcontactList
                {
                    let provider = Provider()
                    
                    if medContactDict["PHARMACY_ID"] != nil
                    {
                        provider.facilityId = medContactDict["PHARMACY_ID"] as? String
                    }
                    
                    if medContactDict["COUNTRY"] != nil
                    {
                        provider.country = medContactDict["COUNTRY"] as? String
                    }
                    
                    if medContactDict["PHARMACY_NAME"] != nil
                    {
                        provider.fullName = medContactDict["PHARMACY_NAME"] as? String
                    }
                    
                    if medContactDict["PATIENT_PHARMA_MAP_ID"] != nil
                    {
                        provider.practiceId = medContactDict["PATIENT_PHARMA_MAP_ID"] as? String
                    }
                    
                    if medContactDict["LINE_1"] != nil
                    {
                        provider.line1 = medContactDict["LINE_1"] as? String
                    }
                    
                    if medContactDict["MOBILE"] != nil
                    {
                        provider.phoneNumber = medContactDict["MOBILE"] as? String
                    }
                    
                    arrayOfProvider.append(provider)
                    
                }
            }
        }
        return arrayOfProvider
    }
    
//MARK: - MedicalCondition
    
    static func formConditionCommonData(respObj: Dictionary<String,Any>) -> [DataWithId] {
        var searchList: [DataWithId] = []
        
        let outputString = respObj["output_string"] as! Dictionary<String, Any>
       
        if let arrayofNameDict = outputString["SEARCH_STRING"] as? [Dictionary<String, Any>]{
            for dict in arrayofNameDict {
                
                let data =  DataWithId()
                data.key = dict.getString("id") ?? ""
                data.value = dict.getString("name") ?? ""
                searchList.append(data)
            }
        }
        
        return searchList
    }
    
    static func formMedicalConditionList(dict : Dictionary<String,Any>, practiceId: String) -> [MedicalCondition]
    {
        var arrayOfMedicalCondition : Array<MedicalCondition> = []
        
        if let outputString = dict.getAsJsonObject("output_string")
        {
            if let dataListDictArr = outputString.getAsJsonArray("DATA_LIST")
            {
                for dataListDict in dataListDictArr
                {
                    let medicalCondition = MedicalCondition()
                    
                    if let medicalConditionId = dataListDict.getString("MEDICAL_CONDITION_ID")
                    {
                        medicalCondition.medicalConditionId = medicalConditionId
                        medicalCondition.name = dataListDict.getString("MEDICAL_CONDITION_NAME")
                        medicalCondition.notes = dataListDict.getString("NOTES")
                        medicalCondition.medicalConditionMapId = dataListDict.getString("MEDICAL_CONDITION_MAP_ID")
                        medicalCondition.status = dataListDict.getString("STATUS")
                        medicalCondition.allowEdit = true
                        
                        if let startDate = dataListDict.getString("DATE_OF_ONSET") {
                            medicalCondition.dateOfOnset = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: startDate)
                        }
                        if let resolvedDate = dataListDict.getString("RESOLVED_DATE") {
                            medicalCondition.resolvedDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: resolvedDate)
                        }
                    }
                    else{
                        medicalCondition.medicalConditionId = dataListDict.getString("DIAGNOSIS_ID")
                        medicalCondition.name = dataListDict.getString("DIAGNOSIS")
                        medicalCondition.notes = dataListDict.getString("COMMENTS")
                        medicalCondition.medicalConditionMapId = dataListDict.getString("DIAGNOSIS_MAP_ID")
                        medicalCondition.status = dataListDict.getString("STATUS")
                        medicalCondition.practiceId = practiceId
                        
                        if let startDate = dataListDict.getString("FROM_DATE") {
                            medicalCondition.dateOfOnset = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: startDate)
                        }
                        if let resolvedDate = dataListDict.getString("TO_DATE") {
                            medicalCondition.resolvedDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: resolvedDate)
                        }
                    }
                    arrayOfMedicalCondition.append(medicalCondition)
                }
            }
        }
            
        
        return arrayOfMedicalCondition
    }
    
    
    //MARK: - Questionnaire
    
    static func formQuestionnaireList(respObj : Dictionary<String,Any>, practiceId: String? = nil , appointmentId: String? = nil , isAscOrder: Bool = true) -> [PhysicianTemplates] {
        var physicianTemplatesList: Array<PhysicianTemplates> = []
        
        if let outputData = respObj["output_string"] as? [Dictionary<String,Any>]
        {
            outputData.forEach{ questionnaireObj in
                
                
                var allowAdd = false
                
                let respAppointmentId =  questionnaireObj.getString("APPOINTMENT_ID")
                
                if !appointmentId.isNilOrBlank(){
                    if appointmentId == respAppointmentId {//filter: To show questionnaires of a specific appointment
                        allowAdd = true
                    }
                }
                else{//Normal: Show all questionnaires
                    allowAdd = true
                }
                
                if allowAdd{
                    let physicianTemplates = PhysicianTemplates()
                    physicianTemplates.name = questionnaireObj.getString("NAME")
                    physicianTemplates.templateId = questionnaireObj.getString("TEMPLATE_ID")
                    physicianTemplates.comments = questionnaireObj.getString("COMMENTS")
                    physicianTemplates.practiceId = questionnaireObj.getString("PRACTICE_ID") ?? practiceId
                    physicianTemplates.questionnaireType = questionnaireObj.getString("TYPE")

                    let member = Provider()
                    member.fullName = questionnaireObj.getString("FULL_NAME")
                    member.prefix = questionnaireObj.getString("PREFIX")
                    member.memberId = questionnaireObj.getString("MEMBER_ID")

                    let patientQuesMap = PatientQuesMap()
                    patientQuesMap.patientQuesMapId = questionnaireObj.getString("PATIENT_QUES_MAP_ID")
                    patientQuesMap.allowPhrEditing = questionnaireObj.getBoolean("ALLOW_PHR_EDITING")
                            ?? false
                    patientQuesMap.isSubmitted = questionnaireObj.getBoolean("IS_SUBMITTED") ?? false
                    patientQuesMap.isFilled = questionnaireObj.getBoolean("IS_FILLED") ?? false

                    let appointment = Appointment()
                    appointment.appointmentId = respAppointmentId

                    let appointmentDate = questionnaireObj.getString("APPOINTMENT_DATE")

                    if (!appointmentDate.isNilOrBlank()) {
                        appointment.appointmentDate = CharmUtil.getDateObjectWith(dateString: appointmentDate!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                    }

                    appointment.facilityId = questionnaireObj.getString("FACILITY_ID")
                    appointment.facilityName = questionnaireObj.getString("FACILITY_NAME")

                    patientQuesMap.appointment = appointment
                    physicianTemplates.member = member
                    physicianTemplates.patientQuesMap = patientQuesMap
                    physicianTemplatesList.append(physicianTemplates)
                }
                
            }
        }
        
        physicianTemplatesList = physicianTemplatesList.sorted(by: {
            
            let appointmentDate0 = $0.patientQuesMap?.appointment?.appointmentDate
            let appointmentDate1 = $1.patientQuesMap?.appointment?.appointmentDate
            if let appointmentDate0 = appointmentDate0, let appointmentDate1 = appointmentDate1{
                if  isAscOrder {
                    return appointmentDate0 < appointmentDate1
                }
                else{
                    return appointmentDate0 > appointmentDate1
                }
            }
            return false
        })

        return physicianTemplatesList
    }
    
    static func formQuestionnaireHPList(dict : Dictionary<String,Any>) -> [PhysicianTemplates]
    {
        var arrayOfQuestionnaire : Array<PhysicianTemplates> = []
        let outputString = dict["output_string"] as! Dictionary<String,Any>
        
        for (key,value) in outputString
        {
            let physicianTemplates = PhysicianTemplates()
            physicianTemplates.isHealthPassport = true
            physicianTemplates.isEditable = true
        
            let patQuesMap = PatientQuesMap()
            patQuesMap.patientQuesMapId = value as? String
            physicianTemplates.patientQuesMap = patQuesMap
            
            if key == "past_med"
            {
                physicianTemplates.name  = "Past Medical History"
            }else if key == "covid"
            {
                physicianTemplates.name = "COVID-19 Screening"
            }
            else if key == "med_info"
            {
                physicianTemplates.name = "Medical Information"
            }
            else if key == "autism"
            {
                physicianTemplates.name = "Autism"
            }
            else if key == "permission"
            {
                // don't show permission in questionnaire vc
            }
            else
            {
                physicianTemplates.name  = key
            }
            if !isNilOrEmpty(string: physicianTemplates.name)
            {
                arrayOfQuestionnaire.append(physicianTemplates)
            }
        }
        
        return arrayOfQuestionnaire
    }
    
    static func fillQuestionnaireAnswers(respObj: [String:Any]) -> QuestionnaireDetailPOJO {
        let questionnaireDetailPOJO = QuestionnaireDetailPOJO()

        if let outputData = respObj["output_string"] as? [String:Any]{
            let patientQuesMap = PatientQuesMap()
            
            patientQuesMap.isFilled = outputData.getBoolean("is_filled") ?? false
            patientQuesMap.isSubmitted = outputData.getBoolean("is_submitted") ?? false
            patientQuesMap.allowPhrEditing = outputData.getBoolean("allow_phr_editing")
            questionnaireDetailPOJO.patientId = outputData.getString("patient_id")
            questionnaireDetailPOJO.templateId = outputData.getString("template_id")
            questionnaireDetailPOJO.patientQuesMapId = outputData.getString("ques_map_id")
            if let questionsArr = outputData["questions"] as? [Dictionary<String,Any>]{
            
                var questionnaireEntryPOJOList: [QuestionnaireEntryPOJO] = []

                questionsArr.forEach{ questionObj in
                    
                    let questionnaireEntryPOJO = QuestionnaireEntryPOJO()
                    let intakeQuestTemplateEntry = IntakeQuestTemplateEntry()
                    intakeQuestTemplateEntry.notes = questionObj.getString("notes")
                    intakeQuestTemplateEntry.isMultiChoice = questionObj.getBoolean("is_multi_choice")
                            ?? false
                    intakeQuestTemplateEntry.isDeleted = questionObj.getBoolean("is_deleted")
                            ?? false

                    intakeQuestTemplateEntry.templateId = questionObj.getString("template_id")
                            ?? ""

                    intakeQuestTemplateEntry.isMandatory = questionObj.getBoolean("is_mandatory")
                            ?? false
                    intakeQuestTemplateEntry.position = questionObj.getInt("position")
                    intakeQuestTemplateEntry.entryId = questionObj.getString("entry_id") ?? ""
                    intakeQuestTemplateEntry.notesType = questionObj.getString("notes_type")
                            ?? ""
                    questionnaireEntryPOJO.nam = questionObj.getBoolean("nam") ?? false
                    questionnaireEntryPOJO.nkda = questionObj.getBoolean("nkda") ?? false
                    questionnaireEntryPOJO.nkfa = questionObj.getBoolean("nkfa") ?? false
                    questionnaireEntryPOJO.nkea = questionObj.getBoolean("nkea") ?? false
                    
                    var optionsList: Array<IntakeQuestTemplateOption> = []

                    if let questionsArr = questionObj["options"] as? [String]{
                        
                        questionsArr.forEach{ option in
                            let intakeOption = IntakeQuestTemplateOption()
                            intakeOption.option = option
                            intakeOption.entryId = intakeQuestTemplateEntry.entryId
                            optionsList.append(intakeOption)
                        }
                    }
                    
                    if intakeQuestTemplateEntry.notesType == questionnaireNotesTypeLabel {
                        let intakeLabel = IntakeQuestTemplateLabels()
                        
                        let fontSize: CGFloat = CGFloat(questionObj.getInt("font_size") ?? 14)
                        if questionObj.getString("font_style") != "normal"
                        {
                            if questionObj.getString("font_weight") != "normal"
                            {
                                intakeLabel.fontStyle = UIFont.systemFont(ofSize: fontSize, Weight: .boldItalic)
                            }
                            else {
                                intakeLabel.fontStyle = UIFont.systemFont(ofSize: fontSize, Weight: .italic)
                            }
                        }else
                        {
                            if questionObj.getString("font_weight") != "normal"
                            {
                                intakeLabel.fontStyle = UIFont.systemFont(ofSize: fontSize, Weight: .bold)
                            }
                            else {
                                intakeLabel.fontStyle = UIFont.systemFont(ofSize: fontSize, Weight: .regular)
                            }
                        }

                        if  questionObj.getString("text_align") == "center" {
                            intakeLabel.textAlign = .center
                        }
                        else if questionObj.getString("text_align") == "right" {
                            intakeLabel.textAlign = .right
                        }
                        else if questionObj.getString("text_align") == "justify"{
                            intakeLabel.textAlign = .justified
                        }
                        else{
                            intakeLabel.textAlign = .left
                        }

                        if questionObj.getString("text_decoration") == "underline" {
                            intakeLabel.textDecorationUnderline = true
                        }
                        intakeLabel.entryId = intakeQuestTemplateEntry.entryId
                        questionnaireEntryPOJO.questionnaireLabel = intakeLabel
                    }
                    else if intakeQuestTemplateEntry.notesType == questionnaireNotesTypeAllergy {
                        if let allergyListArr = questionObj["allergy_entries"] as? [Dictionary<String,Any>]{
                        
                            allergyListArr.forEach{ allergyObj in
                                let questAllergyEntry = IntakeQuestAllergyEntry()
                                questAllergyEntry.allergen = allergyObj.getString("allergen")
                                questAllergyEntry.type = AllergyType(rawValue: allergyObj.getString("type") ?? "")
                                questAllergyEntry.reactions = allergyObj.getString("reactions")
                                questAllergyEntry.severity = Severity(rawValue: allergyObj.getString("severity") ?? "")

                                questionnaireEntryPOJO.questionnaireAllergyList.append(questAllergyEntry)
                            }
                        }
                    }
                    else if intakeQuestTemplateEntry.notesType == questionnaireNotesTypeMedication {
                        if let medicationListArr = questionObj["medication_entries"] as? [Dictionary<String,Any>]{
                        
                            medicationListArr.forEach{ medicationObj in
                                let questMedicationEntry = IntakeQuestPrecriptionEntry()
                                questMedicationEntry.name = medicationObj.getString("medication")
                                questMedicationEntry.intakeDetails = medicationObj.getString("intake_details")

                                questionnaireEntryPOJO.questionnaireMedicationList.append(questMedicationEntry)
                            }
                        }
                    }
                    else if intakeQuestTemplateEntry.notesType == questionnaireNotesTypeSupplement {
                        if let supplementListArr = questionObj["supplement_entries"] as? [Dictionary<String,Any>]{
                        
                            supplementListArr.forEach{ supplementObj in
                                let questSupplementEntry = IntakeQuestPrecriptionEntry()
                                questSupplementEntry.name = supplementObj.getString("supplement")
                                questSupplementEntry.intakeDetails = supplementObj.getString("intake_details")

                                questionnaireEntryPOJO.questionnaireSupplementList.append(questSupplementEntry)
                            }
                        }
                    }
                    else if intakeQuestTemplateEntry.notesType == questionnaireNotesTypeRatingScale{
                        intakeQuestTemplateEntry.fromScale = questionObj.getInt("from_scale")
                        intakeQuestTemplateEntry.toScale = questionObj.getInt("to_scale")
                        intakeQuestTemplateEntry.answersList = [questionObj.getString("answer")
                                ?? ""]
                    }
                    else if intakeQuestTemplateEntry.notesType == questionnaireNotesTypeSignature {
                        let signLink = questionObj.getString("signature_url")
                        if !signLink.isNilOrBlank() {
                            intakeQuestTemplateEntry.answersList = [signLink ?? ""]
                        }
                    }
                    else if intakeQuestTemplateEntry.notesType == questionnaireNotesTypeSection {
                        intakeQuestTemplateEntry.isCollapsible = questionObj.getBoolean("is_collapsible") ?? false
                        intakeQuestTemplateEntry.expandByDefault = questionObj.getBoolean("expand_by_default") ?? false
                    }
                    else if intakeQuestTemplateEntry.isMultiChoice {
                        if let answerListArr = questionObj["multiple_answers"] as? [Dictionary<String,Any>]{
                        
                            var answerList: Array<String> = []
                            answerListArr.forEach{ answerListObj in
                                answerList.append(answerListObj.getString("answer") ?? "")
                            }
                            
                            intakeQuestTemplateEntry.answersList = answerList
                        }
                    }
                    else {
                        let answer = questionObj.getString("answer") ?? ""
                        intakeQuestTemplateEntry.answersList = [answer]
                    }
                    
                    
                    if intakeQuestTemplateEntry.notesType == questionnaireNotesTypeYesOrNoOption {
                        let optionYes = IntakeQuestTemplateOption()
                        optionYes.option = "Yes"
                        optionYes.entryId = intakeQuestTemplateEntry.entryId
                        let optionNo = IntakeQuestTemplateOption()
                        optionNo.option = "No"
                        optionNo.entryId = intakeQuestTemplateEntry.entryId

                        questionnaireEntryPOJO.questionnaireOptions = [optionYes , optionNo]

                    }
                    else {
                        questionnaireEntryPOJO.questionnaireOptions = optionsList
                    }
                    
                    if (questionnaireSOAPTypeList.contains(intakeQuestTemplateEntry.notesType ?? "")){
                        
                        if let soapWidgetObj = questionObj["soap_widget"] as? Dictionary<String , Any> {
                            //
                            let soapWidget = SOAPWidget()
                            
                            soapWidget.widgetId = soapWidgetObj.getString("soap_widget_id")
                            soapWidget.templateId = soapWidgetObj.getString("soap_template_id")
                            soapWidget.widgetName = soapWidgetObj.getString("soap_widget_name")
                            soapWidget.widgetModule = soapWidgetObj.getString("soap_widget_module")
                            
                            if let soapEntryArr = soapWidgetObj["entries"] as? [Dictionary<String , Any>] {
                            
                                soapEntryArr.forEach({soapEntryObj in
                                    let soapEntry = SOAPWidgetEntry()
                                    soapEntry.widgetId = soapWidget.widgetId
//                                    soapEntry.defaultValue = soapEntryObj.getString("DEFAULT_VALUE")
                                    soapEntry.entryName = soapEntryObj.getString("soap_entry_name")
                                    soapEntry.entryType = soapEntryObj.getString("soap_entry_type")
                                    soapEntry.entryId = soapEntryObj.getString("soap_entry_id")
                                    soapEntry.isMandatory = soapEntryObj.getBoolean("is_mandatory") ?? false
                                    
                                    if soapEntry.entryType == soapWidgetTypeHeading{
                                        soapEntry.customText = soapEntryObj.getString("PROPERTIES")
                                    }
                                    
                                    if soapEntry.entryType == soapWidgetTypeYesOrNo {
                                        soapEntry.propertyList = []
                                        
                                        let additionalCommentYesProp = SOAPWidgetProperty()
                                        additionalCommentYesProp.propertyName = soapYesNoAddtionalCommentYes
                                        additionalCommentYesProp.propertyValue = soapEntryObj.getString(soapYesNoAddtionalCommentYes)
                                        
                                        soapEntry.propertyList?.append( additionalCommentYesProp)
                                        
                                        let additionalCommentNoProp = SOAPWidgetProperty()
                                        additionalCommentNoProp.propertyName = soapYesNoAddtionalCommentNo
                                        additionalCommentNoProp.propertyValue = soapEntryObj.getString(soapYesNoAddtionalCommentNo)
                                        
                                        soapEntry.propertyList?.append( additionalCommentNoProp)
                                    }
                                    else if soapEntry.entryType == soapWidgetTypeSimpleQuestion || soapEntry.entryType == soapWidgetTypeRatingScale {
                                        
                                        soapEntry.customText = soapEntryObj.getString("OPTIONS")
                                    }
                                    else if soapEntry.entryType == soapWidgetTypeRadio || soapEntry.entryType == soapWidgetTypeCheckbox {
                                        
                                        soapEntry.customText = soapEntryObj.getString("OPTIONS")
                                        
                                        soapEntry.propertyList = []
                                        
                                        let soapRadioAddtionalCommentProp = SOAPWidgetProperty()
                                        soapRadioAddtionalCommentProp.propertyName = soapRadioAddtionalComment
                                        soapRadioAddtionalCommentProp.propertyValue = soapEntryObj.getString(soapRadioAddtionalComment)
                                        
                                        soapEntry.propertyList?.append(soapRadioAddtionalCommentProp)
                                        
                                        let soapRadioIncludeOthersProp = SOAPWidgetProperty()
                                        soapRadioIncludeOthersProp.propertyName = soapRadioIncludeOthers
                                        soapRadioIncludeOthersProp.propertyValue = soapEntryObj.getString(soapRadioIncludeOthers)
                                        
                                        soapEntry.propertyList?.append(soapRadioIncludeOthersProp)
                                        
                                        
                                    }
                                    
                                    
                                    let answer = QuestionnaireSOAPEntry()
                                    answer.soapEntryId = soapEntry.entryId
                                    answer.questionnaireEntryId = intakeQuestTemplateEntry.entryId
                                    answer.value = soapEntryObj.getString("soap_entry_answer")
                                    
                                    soapEntry.questionnaireSOAPEntry = answer
                                    soapWidget.widgetEntries.append(soapEntry)
                                })
                            }
                            
                            questionnaireEntryPOJO.soapWidget = soapWidget
                        }
                    }
                    questionnaireEntryPOJO.questionnaireEntry = intakeQuestTemplateEntry
                    
                    if !intakeQuestTemplateEntry.isDeleted {
                        questionnaireEntryPOJOList.append(questionnaireEntryPOJO)
                    }
                }
                
                questionnaireDetailPOJO.questionnairEntryPOJOList = questionnaireEntryPOJOList
            }
        }
        return questionnaireDetailPOJO
    }
    
//MARK: - Insurance
    
    static func formInsuranceCommonData(respObj: Dictionary<String,Any>) -> InsuranceCommonData {
        let insuranceCommonData = InsuranceCommonData()
        
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>{
            if let insuranceTypeArr = outputData["INSURANCE_TYPES"] as? [String]{
                insuranceCommonData.insuranceTypes = insuranceTypeArr
            }
            if let relationshipArr = outputData["RELATIONSHIP_LIST"] as? [String]{
                insuranceCommonData.relationships = relationshipArr
            }
            
            if let stateListObj = outputData["COUNTRYVSSTATEMAP"] as? Dictionary<String , Any>{
                if PrimaryDataHandler.sharedInstance.inStatesArr == nil || PrimaryDataHandler.sharedInstance.inStatesArr?.isEmpty == true{
                    if let inStateArr = stateListObj.getAsStringArray("in"){
                        PrimaryDataHandler.sharedInstance.inStatesArr = inStateArr
                    }
                }
                if PrimaryDataHandler.sharedInstance.usStatesArr == nil || PrimaryDataHandler.sharedInstance.usStatesArr?.isEmpty == true{
                    if let usStateArr = stateListObj.getAsStringArray("us"){
                        PrimaryDataHandler.sharedInstance.usStatesArr = usStateArr
                    }
                }
                if PrimaryDataHandler.sharedInstance.auStatesArr == nil || PrimaryDataHandler.sharedInstance.auStatesArr?.isEmpty == true{
                    if let auStatesArr = stateListObj.getAsStringArray("au"){
                        PrimaryDataHandler.sharedInstance.auStatesArr = auStatesArr
                    }
                }
            }
            
            if PrimaryDataHandler.sharedInstance.countriesArr == nil || PrimaryDataHandler.sharedInstance.countriesArr?.isEmpty == true{
                if let countryObj = outputData["COUNTRY_LIST"] as? Dictionary<String , Any> {
                    var countryList: [DataWithId] = []
                    for (key,value) in countryObj  {
                        let countryObj = DataWithId()
                        countryObj.value = key
                        if let value = value as? String {
                            countryObj.key = value
                            countryList.append(countryObj)
                        }
                    }
                    countryList.sort {
                        $0.value < $1.value
                    }
                    PrimaryDataHandler.sharedInstance.countriesArr = countryList
                }
            }
            insuranceCommonData.isUSUser = outputData.getBoolean("IS_US_USER") ?? false
        }
        return insuranceCommonData
    }
    
    static func formPrimaryInsuranceForQuestionnaire(respObj: Dictionary<String,Any>) -> PatientInsuranceDetails {
        
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>{
            //todo
            return formInsuranceObj(insuranceObj: outputData)
        }
        
        return PatientInsuranceDetails()
    }
    
    static func formInsuranceObj(insuranceObj: Dictionary<String,Any>)-> PatientInsuranceDetails {
        let patInsuranceDetails = PatientInsuranceDetails()
        patInsuranceDetails.patientInsuranceDetailsId = insuranceObj.getString("INSURED_ID")
        patInsuranceDetails.insuranceCompanyDetailsId = insuranceObj.getString("INSURANCE_COMPANY_DETAILS_ID")
        patInsuranceDetails.insuredDetailsId = insuranceObj.getString("INSURED_DETAILS_ID")
        patInsuranceDetails.practicePatientId = insuranceObj.getString("PATIENT_ID")
        patInsuranceDetails.type = insuranceObj.getString("TYPE")
        patInsuranceDetails.isPrimary = insuranceObj.getBoolean("IS_PRIMARY") ?? false
        patInsuranceDetails.policyNumber = insuranceObj.getString("ID_NUMBER")
        patInsuranceDetails.copay = "\(insuranceObj.getDouble("COPAY") ?? 0)"
        patInsuranceDetails.deductable = "\(insuranceObj.getDouble("DEDUCTABLE") ?? 0)"
        patInsuranceDetails.policyDeductible = insuranceObj.getString("POLICY_DEDUCTIBLE")
        patInsuranceDetails.groupNumber = insuranceObj.getString("POLICY_GROUP_NUMBER")
        patInsuranceDetails.comment = insuranceObj.getString("COMMENT")
        patInsuranceDetails.insurancePlanType = insuranceObj.getString("INSURANCE_TYPE")
        patInsuranceDetails.insurancePlanName = insuranceObj.getString("PLAN_NAME")
        patInsuranceDetails.isAddNewPayerAllowed = insuranceObj.getBoolean("is_add_new_payer_allowed") ?? false
        
        patInsuranceDetails.isFrontCardAvailable = insuranceObj.getBoolean("is_front_copy_available")
        patInsuranceDetails.isBackCardAvailable = insuranceObj.getBoolean("is_back_copy_available")


        if patInsuranceDetails.isFrontCardAvailable == true {
            let cardPathArr = (insuranceObj.getString("FIRST_PAGE_FILE_PATH") ?? "").components(separatedBy: "!->")
            if let frontCardName = cardPathArr.firstOrNil() {
                patInsuranceDetails.frontCardName = frontCardName
            }
        }
        
        if patInsuranceDetails.isBackCardAvailable == true {
            let cardPathArr = (insuranceObj.getString("LAST_PAGE_FILE_PATH") ?? "").components(separatedBy: "!->")
            if let backCardName = cardPathArr.firstOrNil() {
                patInsuranceDetails.backCardName = backCardName
            }
        }
        
        
        let planFromDateStr = insuranceObj.getString("PLAN_FROM_DATE")
        if (!planFromDateStr.isNilOrBlank()) {
            patInsuranceDetails.policyStartDate = CharmUtil.getDateObjectWith(dateString: planFromDateStr ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        }
        let planToDateStr = insuranceObj.getString("PLAN_TO_DATE")
        if (!planToDateStr.isNilOrBlank()) {
            patInsuranceDetails.policyEndDate = CharmUtil.getDateObjectWith(dateString: planToDateStr ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        }

        let insuredAndGuarantorDetails = InsuredAndGuarantorDetails()
        insuredAndGuarantorDetails.insuredGuarantorDetailsId = insuranceObj.getString("INSURED_GUARANTOR_DETAILS_ID")
        insuredAndGuarantorDetails.lastName = insuranceObj.getString("LAST_NAME")
        insuredAndGuarantorDetails.firstName = insuranceObj.getString("FIRST_NAME")
        insuredAndGuarantorDetails.gender = insuranceObj.getString("GENDER")
        insuredAndGuarantorDetails.relationship = insuranceObj.getString("RELATIONSHIP")
        insuredAndGuarantorDetails.ssn = insuranceObj.getString("SSN")

        let dobStr = insuranceObj.getString("DATE_OF_BIRTH")
        if (!dobStr.isNilOrBlank()) {
            insuredAndGuarantorDetails.dateOfBirth = CharmUtil.getDateObjectWith(dateString: dobStr ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        }

        let insuredEmployerDetails = InsuredEmployerDetails()
        insuredEmployerDetails.employerDetailsId = insuranceObj.getString("EMPLOYER_DETAILS_ID")
        insuredEmployerDetails.name = insuranceObj.getString("EMPLOYER_NAME")
        insuredEmployerDetails.contactLastName = insuranceObj.getString("CONTACT_LAST_NAME")
        insuredEmployerDetails.contactFirstName = insuranceObj.getString("CONTACT_FIRST_NAME")

        let practicePayer = PracticePayer()
        practicePayer.practicePayerId = insuranceObj.getString("PRACTICE_PAYER_ID")
        practicePayer.payerName = insuranceObj.getString("PAYER_NAME")
        practicePayer.knownName = insuranceObj.getString("KNOWN_NAME")
        practicePayer.payerId = insuranceObj.getString("PAYER_ID")
        practicePayer.practicePayerId = insuranceObj.getString("PRACTICE_PAYER_ID")
//            practicePayer.practicePayerId = insuranceObj.getString("PRACTICE_PAYER_ID")

        let payerPostalAddress = PostalAddress()
        payerPostalAddress.postalAddressId = insuranceObj.getString("POSTALADDRESS_ID")
        payerPostalAddress.line1 = insuranceObj.getString("PAYER_ADDR_LIINE1")
        payerPostalAddress.city = insuranceObj.getString("PAYER_CITY")
        payerPostalAddress.state = insuranceObj.getString("PAYERSTATE")
        payerPostalAddress.country = insuranceObj.getString("PAYERCOUNTRY")
        payerPostalAddress.postalCode = insuranceObj.getString("PAYERZIP")

        let contactDetails = ContactDetails()
        contactDetails.contactDetailsId = insuranceObj.getString("CONTACTDETAILS_ID")
        contactDetails.homePhone = insuranceObj.getString("LANDLINE")
        contactDetails.mobile = insuranceObj.getString("MOBILE")

        let postalAddress = PostalAddress()
        postalAddress.postalAddressId = insuranceObj.getString("POSTALADDRESS_ID")
        postalAddress.line1 = insuranceObj.getString("LINE_1")
        postalAddress.line2 = insuranceObj.getString("LINE_2")
        postalAddress.city = insuranceObj.getString("CITY")
        postalAddress.state = insuranceObj.getString("STATE")
        postalAddress.country = insuranceObj.getString("COUNTRY")
        postalAddress.postalCode = insuranceObj.getString("POSTALCODE")


        patInsuranceDetails.insuredAndGuarantorDetails = insuredAndGuarantorDetails
        insuredAndGuarantorDetails.insuredEmployerDetails = insuredEmployerDetails
        insuredAndGuarantorDetails.postalAddress = postalAddress
        insuredAndGuarantorDetails.contactDetails = contactDetails
        patInsuranceDetails.practicePayer = practicePayer
        practicePayer.postalAddress = payerPostalAddress

        return patInsuranceDetails
    }
    
    static func formPayerList(respObj: Dictionary<String,Any>) -> [PracticePayer]{
        
        var practicePayerList: [PracticePayer] = []
        if let outputData = respObj["output_string"] as? [Dictionary<String,Any>]{
            outputData.forEach{payerObj in
                let practicePayer = PracticePayer()
                practicePayer.practicePayerId = payerObj.getString("PRACTICE_PAYER_ID")
                practicePayer.payerName = payerObj.getString("PAYER_NAME")
                practicePayer.payerId = payerObj.getString("CODE")

                let postalAddress = PostalAddress()
                postalAddress.line1 = payerObj.getString("LINE_1")
                postalAddress.line2 = payerObj.getString("LINE_2")
                postalAddress.city = payerObj.getString("CITY")
                postalAddress.country = payerObj.getString("COUNTRY")
                postalAddress.state = payerObj.getString("STATE")
                postalAddress.postalCode = payerObj.getString("ZIPCODE")
                postalAddress.country = payerObj.getString("COUNTRY")

                practicePayer.postalAddress = postalAddress
                
                practicePayerList.append(practicePayer)
            }
        }
        return practicePayerList
    }
    
    static func formInsuranceList(respObj: Dictionary<String,Any>) -> [PatientInsuranceDetails]{
        
        var patInsuranceDetailList: [PatientInsuranceDetails] = []
        
        if let outputData = respObj["output_string"] as? Dictionary<String, Any> {
            
            if let insuranceArr = outputData["INSURANCE_LIST"] as? [Dictionary<String, Any>] {
                insuranceArr.forEach({insuranceObj in
                    patInsuranceDetailList.append(formInsuranceObj(insuranceObj: insuranceObj))
                })
            }
        }
        return patInsuranceDetailList
    }
    
//MARK: - Patient Demographics
    
    static func formPrimaryContactDetailForQuestionnaire(patientObj: Patient, respObj: Dictionary<String,Any>) -> Patient {
        let patient = patientObj
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>{
            
            patient.caregiverFirstName = outputData.getString("CAREGIVER_FIRST_NAME")
            patient.caregiverLastName = outputData.getString("CAREGIVER_LAST_NAME")
            patient.emergencyContactName = outputData.getString("EMERGENCY_CONTACT_NAME")
            patient.emergencyContactNumber = outputData.getString("EMERGENCY_CONTACT_NUMBER")
            patient.emergencyContactExtn = outputData.getString("EMERGENCY_EXTN")
            patient.patientId = outputData.getString("CAREGIVER_ID")

            let postalAddress = PostalAddress()
            postalAddress.city = outputData.getString("CITY")
            postalAddress.country = outputData.getString("COUNTRY")
            postalAddress.postalAddressId = outputData.getString("POSTALADDRESS_ID")
            postalAddress.line1 = outputData.getString("LINE_1")
            postalAddress.line2 = outputData.getString("LINE_2")
            postalAddress.postalCode = outputData.getString("POSTALCODE")
            postalAddress.postbox = outputData.getString("POSTBOX_NO")
            postalAddress.state = outputData.getString("STATE")


            let contactDetails = ContactDetails()
            contactDetails.emailId = outputData.getString("EMAILID")
            contactDetails.contactDetailsId = outputData.getString("CONTACTDETAILS_ID")
            contactDetails.fax = outputData.getString("FAX")
            contactDetails.homePhone = outputData.getString("LANDLINE")
            contactDetails.mobile = outputData.getString("MOBILE")
            contactDetails.workPhone = outputData.getString("WORKPHONE")
            contactDetails.workPhoneExtn = outputData.getString("WORKPHONE_EXTN")
            contactDetails.primaryPhone = outputData.getString("CONTACT_PREFERENCE")

            patient.contactDetail = contactDetails
            patient.postalAddress = postalAddress
            //todo
        }
        return patient
    }
    
    static func formPrimaryDetailForQuestionnaire(patientObj: Patient, respObj: Dictionary<String,Any>) -> Patient {
        let patient = patientObj
        if let outputData = respObj["output_string"] as? Dictionary<String,Any>{
            patient.bloodGroup = outputData.getString("BLOOD_GROUP")
            patient.emergencyContactName = outputData.getString("EMERGENCY_CONTACT_NAME")
            patient.emergencyContactNumber = outputData.getString("EMERGENCY_CONTACT_NUMBER")
            patient.emergencyContactExtn = outputData.getString("EMERGENCY_EXTN")
            patient.employmentStatus = outputData.getString("EMPLOYMENT_STATUS")
            patient.ethnicity = outputData.getString("ETHNICITY")
            patient.firstName = outputData.getString("FIRST_NAME")
            patient.gender = outputData.getString("GENDER")
            patient.genderIdentity = outputData.getString("GENDER_IDENTITY")
            patient.language = outputData.getString("LANGUAGE")
            patient.lastName = outputData.getString("LAST_NAME")
            patient.maritalStatus = outputData.getString("MARITAL_STATUS")
            patient.patientId = outputData.getString("PRACTICE_PATIENT_ID")
            patient.race = outputData.getString("RACE")
            patient.smokingStatus = outputData.getString("SMOKING_STATUS")
            patient.requiredTabs = outputData.getAsStringArray("requiredTabs") ?? []
            let dob = outputData.getString("DOB")
            if (!dob.isNilOrBlank()) {
                patient.dateOfBirth = CharmUtil.getDateObjectWith(dateString: dob!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            }
        }
        return patient
    }
    
    static func getDemographics(dict : Dictionary<String,Any>) -> Patient
    {
  /*      if outputString["MAIDEN_NAME"] != nil
        {
            demographics.maidenName = outputString["MAIDEN_NAME"] as? String
        }
        
        if outputString["MIDDLE_NAME"] != nil
        {
            demographics.middleName = outputString["MIDDLE_NAME"] as? String
        }

        if outputString["DOB_FORMAT"] != nil
        {
            demographics.dobFormat = outputString["DOB_FORMAT"] as? String
        }
        
        if outputString["NICK_NAME"] != nil
        {
            demographics.nickName = outputString["NICK_NAME"] as? String
        }
        
        if outputString["MEMBER_STATUS"] != nil
        {
            demographics.memberStatus = outputString["MEMBER_STATUS"] as? String
        }
   
   */
        
        
        let demographics = Patient()
        
        let outputString = dict["output_string"] as! Dictionary<String,Any>
        
        if outputString["FIRST_NAME"] != nil
        {
            demographics.firstName = outputString["FIRST_NAME"] as? String
        }
        
      
        
        
        if outputString["LAST_NAME"] != nil
        {
            demographics.lastName = outputString["LAST_NAME"] as? String
        }
      
        if outputString["DATE_OF_BIRTH"] != nil
        {
            demographics.dateOfBirth = CharmUtil.getDateObjectWith(dateString: outputString["DATE_OF_BIRTH"] as! String, dateFormat: PHR_DATE_API_FORMAT)
        }
        
       
        
        if outputString["MARITAL_STATUS"] != nil
        {
            demographics.maritalStatus = outputString["MARITAL_STATUS"] as? String
        }
        
        if outputString["BLOOD_GROUP"] != nil
        {
            demographics.bloodGroup = outputString["BLOOD_GROUP"] as? String
        }
        
        if outputString["GENDER"] != nil
        {
            demographics.gender = outputString["GENDER"] as? String
        }
        
        demographics.patientId = outputString.getString("PATIENT_ID")

        let address = PostalAddress()
        
        if outputString["LINE_1"] != nil
        {
            address.line1 = outputString["LINE_1"] as? String
        }
        
        if outputString["LINE_2"] != nil
        {
            address.line2 = outputString["LINE_2"] as? String
        }
        
        if outputString["CITY"] != nil
        {
            address.city = outputString["CITY"] as? String
        }
        
        if outputString["STATE"] != nil
        {
            address.state = outputString["STATE"] as? String
        }
        
        if let country = outputString.getString("COUNTRY")
        {
            address.country = country
        }
        
        if outputString["POSTALCODE"] != nil
        {
            address.postalCode = outputString["POSTALCODE"] as? String
        }
        
        demographics.postalAddress = address
        
        let contactDetail = ContactDetails()
        
        if outputString["ACC_MOBILE"] != nil
        {
            contactDetail.mobile = outputString["ACC_MOBILE"] as? String
        }
        
        if outputString["ACC_LANDLINE"] != nil
        {
            contactDetail.landline = outputString["ACC_LANDLINE"] as? String
        }
        
        demographics.contactDetail = contactDetail
        
        if outputString["EMERGENCY_EXTN"] != nil
        {
            demographics.emergencyContactExtn = outputString["EMERGENCY_EXTN"] as? String
        }
        
        if outputString["EMERGENCY_CONTACT_NAME"] != nil
        {
            demographics.emergencyContactName = outputString["EMERGENCY_CONTACT_NAME"] as? String
        }
        
        if outputString["EMERGENCY_CONTACT_NUMBER"] != nil
        {
            demographics.emergencyContactNumber = outputString["EMERGENCY_CONTACT_NUMBER"] as? String
        }
        
        let careGiver = CareGiver()
        
        if let contactsDictArr = outputString["contacts"] as? [Dictionary<String,Any>]
        {
            if contactsDictArr.count > 0 
            {
                let contactsDict = contactsDictArr[0]
                if contactsDict["CONTACTDETAILS_ID"] != nil
                {
                    careGiver.contactDetailId = contactsDict["CONTACTDETAILS_ID"] as? String
                }
                
                if contactsDict["FIRST_NAME"] != nil
                {
                    careGiver.firstName = contactsDict["FIRST_NAME"] as? String
                }
                
                if contactsDict["CONTACT_TYPE"] != nil
                {
                    careGiver.contactType = contactsDict["CONTACT_TYPE"] as? String
                }
                
                if contactsDict["MOBILE"] != nil
                {
                    careGiver.mobile = contactsDict["MOBILE"] as? String
                }
            }
        }
        demographics.primaryCaregiver = careGiver
        
        
        
        return demographics
    }
    
    static func getPatientDetails(patientObj: Patient, dict : Dictionary<String,Any>) -> Patient
    {
        let patient = patientObj
        
        let outputString = dict["output_string"] as! Dictionary<String,Any>
        
        patient.firstName = outputString.getString("FIRST_NAME")
        patient.lastName = outputString.getString("LAST_NAME")
        
        if let dobStr = outputString.getString("DATE_OF_BIRTH"){
            patient.dateOfBirth = CharmUtil.getDateObjectWith(dateString: dobStr, dateFormat: PHR_DATE_API_FORMAT)
        }
        
        patient.maritalStatus = outputString.getString("MARITAL_STATUS")
        patient.bloodGroup = outputString.getString("BLOOD_GROUP")
        patient.gender = outputString.getString("GENDER")
        patient.patientId = "\(outputString.getInt("PATIENT_ID") ?? -1)"
        
        var postalAddress: PostalAddress?
        if patient.postalAddress != nil{
            postalAddress = patient.postalAddress
        }
        else{
            postalAddress = PostalAddress()
        }
        
        if let postalAddress = postalAddress{
            postalAddress.line1 = outputString.getString("LINE_1")
            postalAddress.line2 = outputString.getString("LINE_2")
            postalAddress.city = outputString.getString("CITY")
            postalAddress.state = outputString.getString("STATE")
            postalAddress.country = outputString.getString("COUNTRY")
            postalAddress.postalCode = outputString.getString("POSTALCODE")
            patient.postalAddress = postalAddress
        }
        
        var contactDetail: ContactDetails?
        if patient.contactDetail != nil{
            contactDetail = patient.contactDetail
        }
        else{
            contactDetail = ContactDetails()
        }
        
        if let contactDetail = contactDetail{
            contactDetail.mobile = outputString.getString("ACC_MOBILE")
            contactDetail.homePhone = outputString.getString("ACC_LANDLINE")
            patient.contactDetail = contactDetail
        }
        
        patient.emergencyContactExtn = outputString.getString("EMERGENCY_EXTN")
        patient.emergencyContactName = outputString.getString("EMERGENCY_CONTACT_NAME")
        patient.emergencyContactNumber = outputString.getString("EMERGENCY_CONTACT_NUMBER")
        
        return patient
    }
    
    static func formStateList(respObj: Dictionary<String,Any>) -> [String] {
        if let outputData = respObj["output_string"] as? [String]
        {
            return outputData
        }
        return []
    }
    
    static func formLanguageList(respObj: Dictionary<String,Any>) -> [String] {
        var languageList:[String] = []
        if let outputData = respObj["output_string"] as? Dictionary<String, Any>
        {
            for (key,_) in outputData  {
               
                languageList.append(key)
            }
        }
        languageList.sort{
            $0 < $1
        }
        languageList.append(questionnairePersonalDetailDeclineToSpecify)
        return languageList
    }
    
    //MARK: - Flowsheet
    
    
    static func formFlowsheetList(respObj : Dictionary<String,Any>) -> [Flowsheets] {
        var flowsheetList: Array<Flowsheets> = []
    
        if let outputData = respObj["output_string"] as? [Dictionary<String,Any>]{
            
            for flowsheetPracticeData in outputData{
                
                if let flowSheetData = flowsheetPracticeData["flowsheets"] as? [Dictionary<String,Any>]{
                    
                    for flowSheetObj in flowSheetData{
                        
                        let flowSheet = Flowsheets()
                        
                        flowSheet.name = flowSheetObj.getString("flowsheet_name")
                        flowSheet.allowEdit = flowSheetObj.getBoolean("allow_patient_editing") ?? false
                        flowSheet.fillFrequency = flowSheetObj.getString("fill_frequency")
                        flowSheet.flowSheetId = flowSheetObj.getString("flowsheet_id")
                        flowSheet.practiceId = flowsheetPracticeData.getString("practice_id")
                        
                        if let flowsheetParams = flowSheetObj["flowsheet_params"] as? [Dictionary<String,Any>]{
                            
                            for flowsheetParamsObj in flowsheetParams{
                                
                                let flowsheetEntries = FlowsheetEntries()
                                
                                flowsheetEntries.flowSheetEntryId = flowsheetParamsObj.getString("flowsheet_entry_id")
                                flowsheetEntries.option = flowsheetParamsObj.getString("field_options")
                                flowsheetEntries.name = flowsheetParamsObj.getString("flowsheet_entry_name")
                                flowsheetEntries.additionalNotesLabel = flowsheetParamsObj.getString("additional_notes_label")
                                flowsheetEntries.addAdditionalNotes = flowsheetParamsObj.getBoolean("add_additional_notes") ?? false
                                flowsheetEntries.position = flowsheetParamsObj.getInt("position")
                                flowsheetEntries.unit = flowsheetParamsObj.getString("field_unit")
                                flowsheetEntries.type = flowsheetParamsObj.getString("flowsheet_entry_type")
                                flowsheetEntries.fieldType = flowsheetParamsObj.getString("field_type")
                                flowsheetEntries.flowSheetId = flowSheetObj.getString("flowsheet_id")
                                
                                flowSheet.flowsheetEntries.append(flowsheetEntries)
                            }
                        }
                        flowsheetList.append(flowSheet)
                    }
                }
            }
        }
        return flowsheetList
    }
    
    static func formFlowsheetListEntry(respObj : Dictionary<String,Any>) -> [PHRFlowsheets]{
        
        var flowSheetEntryTemplateList: Array<PHRFlowsheets> = []
        
        if let outputData = respObj["output_string"] as? [String: Any]{
                             
            if let flowSheetData = outputData["flowsheet_data"] as? [Dictionary<String,Any>]{
                    
                for flowSheetObj in flowSheetData{
                        
                    let phrFlowSheet = PHRFlowsheets()

                    phrFlowSheet.flowsheetName = outputData.getString("flowsheet_name")
                    phrFlowSheet.date = Date.getDateFromString(dateFormat: FLOWSHEET_DATA_DATE_FORMAT, dateString: flowSheetObj.getString("date") ?? "")
                    
                    phrFlowSheet.phrFlowsheetId = flowSheetObj.getString("flowsheet_data_id")
                    
                        
                    if let flowSheetDataEntries = flowSheetObj["data_entries"] as? Array<Dictionary<String,Any>>{
                        
                        
                        for dataEntries in flowSheetDataEntries{
                            
                            let flowSheetEntries = FlowsheetEntries()
                                                        
                            
                            flowSheetEntries.flowSheetEntryId = dataEntries.getString("flowsheet_entry_id")
                            flowSheetEntries.option = dataEntries.getString("field_options")
                            flowSheetEntries.name = dataEntries.getString("flowsheet_entry_name")
                            flowSheetEntries.comments = dataEntries.getString("comments")
                            flowSheetEntries.value = dataEntries.getString("field_value")
                            flowSheetEntries.position = dataEntries.getInt("position")
                            flowSheetEntries.unit = dataEntries.getString("field_unit")
                            flowSheetEntries.type = dataEntries.getString("flowsheet_entry_type")
                            flowSheetEntries.fieldType = dataEntries.getString("field_type")
                            
                            phrFlowSheet.flowsheetEntries.append(flowSheetEntries)
                        }
                    }
                    flowSheetEntryTemplateList.append(phrFlowSheet)
                }
            }
        }
        
        return flowSheetEntryTemplateList
    }
    
//MARK: - Share Documents
    
    static func formPharmacyList(respObj: Dictionary<String, Any>) -> [Pharmacy]{
        var pharmacyList: [Pharmacy] = []
        if let patientDetailsList = respObj["Patient_Details"] as? [Dictionary<String,Any>]{
            for patientDetails in patientDetailsList {
                let pharmacy = Pharmacy()
                pharmacy.patientPharmaMapId = patientDetails.getString("ID")
                pharmacy.pharmacyName = patientDetails.getString("NAME")
                
                let contactDetails = ContactDetails()
                contactDetails.emailId = patientDetails.getString("EMAIL_ID")
                
                pharmacy.contactDetails = contactDetails
                pharmacyList.append(pharmacy)
            }
        }
        return pharmacyList
    }
    
    static func formPatientMemberList(respObj: Dictionary<String, Any>) -> [Provider]{
        var memberList: [Provider] = []
        var memberIdList: [String] = []
        if let outputString = respObj["output_string"] as? [Dictionary<String,Any>]{
            for memberListObj in outputString{
                let provider = Provider()
                provider.practiceName = memberListObj.getString("PRACTICE_NAME")
                provider.practiceId = memberListObj.getString("PRACTICE_ID")
                provider.fullName = memberListObj.getString("FULL_NAME")
                let prefix = memberListObj.getString("PREFIX")
                if !prefix.isNilOrBlank() && prefix != "null"{
                    provider.prefix = prefix
                }
                provider.facilityName = memberListObj.getString("FACILITY_NAME")
                provider.facilityId = memberListObj.getString("FACILITY_ID")
                provider.memberId = memberListObj.getString("MEMBER_ID")
                provider.gender = memberListObj.getString("GENDER")
                provider.specialization = memberListObj.getString("SPECIALIZATION")
                
                if !memberIdList.contains(provider.memberId ?? ""){
                    memberIdList.append(provider.memberId ?? "")
                    memberList.append(provider)
                }
            }
        }
        return memberList
    }
    
    static func getShareDocRestriction(resp: [String: Any], practiceId: String) -> ShareDocRestriction{
        let shareDocRestriction = ShareDocRestriction()
        shareDocRestriction.practiceId = practiceId
        if let outputString = resp["output_string"] as? Dictionary<String, Any>{
            shareDocRestriction.isShareAllowed = outputString.getBoolean("is_document_share_allowed") ?? false
        }
        return shareDocRestriction
    }
    
//MARK: - Reminder
    
    static func formReminderList(respObj: Dictionary<String, Any>, patientId: String?) -> [Reminder]{
        var reminderList: [Reminder] = []
        if let reminderArray = respObj.getAsJsonArray("output_string"){
            for reminderObj in reminderArray{
                let reminder = getReminderObj(reminderObj: reminderObj)
                reminder.patientId = patientId
                reminderList.append(reminder)
            }
        }
        return reminderList
    }
    
    static func getReminderObj(reminderObj: [String: Any]) -> Reminder{
        let reminder = Reminder()
        var frequencyArray: [ReminderFrequency] = []
        
        reminder.startDate = CharmUtil.getDateObjectWith(dateString: reminderObj.getString("start_date") ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        reminder.endDate = CharmUtil.getDateObjectWith(dateString: reminderObj.getString("end_date") ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        reminder.isReminderDeleted = reminderObj.getBoolean("is_deleted") ?? false
        reminder.addedBy = reminderObj.getString("added_by")
        reminder.reminderId = reminderObj.getString("reminder_id")
        reminder.isReminderDeleted = reminderObj.getBoolean("is_deleted") ?? false
        if let modifiedTime = reminderObj.getInt("modified_time"){
            reminder.modifiedTime = "\(modifiedTime)"
        }
        
        reminder.moduleId = reminderObj.getString("module_id")
        reminder.practiceId = reminderObj.getString("practice_id")
        reminder.reminderType = reminderObj.getString("type")
        
        if let frequency = reminderObj.getAsJsonObject("frequency"){
            let frequencyUnit = frequency.getString("frequency_unit")
            if frequencyUnit == "null"{
                reminder.frequencyUnit = nil
            }
            else{
                reminder.frequencyUnit = frequencyUnit
            }
            reminder.frequency = "\(frequency.getInt("frequency_value") ?? -1)"
            if let durationArray = frequency.getAsJsonArray("duration"){
                durationArray.forEach({ durationObj in
                    if let timeArray = durationObj["time"] as? [[String: Any]]{
                        timeArray.forEach ({ timeStringDict in
                            let reminderFrequency = ReminderFrequency()
                            let day = durationObj.getString("day")
                            if day == "not_configured"{
                                reminderFrequency.day = "-1"
                            }
                            else{
                                reminderFrequency.day = day
                            }
                            timeStringDict.forEach { (key: String, value: Any) in
                                reminderFrequency.frequencyMapId = key
                                reminderFrequency.time = value as? String
                            }
                            
                            reminderFrequency.reminderId = reminder.reminderId
                            reminderFrequency.timeDayPrimaryKey = ((reminderFrequency.time ?? "") + (reminderFrequency.day ?? ""))
                            frequencyArray.append(reminderFrequency)
                        })
                    }
                })
            }
        }
        reminder.reminderFrequencyArray = frequencyArray
        return reminder
    }
    
    static func formTodayReminderHistoryList(respObj: Dictionary<String, Any>) -> [ReminderHistory]{
        var reminderHistoryList: [ReminderHistory] = []
        
        if let outputStringArr = respObj["output_string"] as? [Any]{
            for outputStringObj in outputStringArr{
                if let outputStringSubArr = outputStringObj as? [[String: Any]]{
                    for reminderhistory in outputStringSubArr{
                        
                        if let historyObj = reminderhistory.getAsJsonArray("history"){
                            for history in historyObj {
                                
                                let reminderHistoryObj  = ReminderHistory()
                                let reminderFrequencyObj = ReminderFrequency()
                                
                                reminderFrequencyObj.reminderId = reminderhistory.getString("reminder_id")
                                reminderFrequencyObj.time = history.getString("reminder_time")
                                let day = history.getString("reminder_day")
                                if day == "not_configured"{
                                    reminderFrequencyObj.day = "-1"
                                }
                                else{
                                    reminderFrequencyObj.day = day
                                }
                                
                                reminderFrequencyObj.timeDayPrimaryKey = ((reminderFrequencyObj.time ?? "") + (reminderFrequencyObj.day ?? ""))
                                let timeString = history.getString("status_updated_time") ?? ""
                                let dateString = history.getString("status_updated_date") ?? ""
                                reminderHistoryObj.statusUpdatedTime = Date.getDateFromString(dateFormat: "MMM dd, yyyy HH:mm", dateString: "\(dateString) \(timeString)")
                                reminderHistoryObj.historyId = history.getString("history_id")
                                reminderHistoryObj.status = history.getInt("status")
                                reminderHistoryObj.reminderId = reminderhistory.getString("reminder_id")
                                reminderHistoryObj.patientId = getSelectedPatientId()
                                
                                reminderHistoryObj.reminderFrequency = reminderFrequencyObj
                                
                                reminderHistoryList.append(reminderHistoryObj)
                            }
                        }
                    }
                }
            }
        }
        
        return reminderHistoryList
    }
    
    static func formReminderHistoryList(respObj: Dictionary<String, Any>, reminderId: String?) -> [ReminderHistory]{
        
        var reminderHistoryList: [ReminderHistory] = []
        
        if let outputString = respObj.getAsJsonArray("output_string"){
            outputString.forEach({ historyObj in
                let reminderHistory = ReminderHistory()
                let reminderFrequency = ReminderFrequency()
                
                reminderFrequency.time = historyObj.getString("reminder_time")
                if historyObj.getString("reminder_day") == "not_configured"{
                    reminderFrequency.day = "-1"
                }
                else{
                    reminderFrequency.day = historyObj.getString("reminder_day")
                }
                reminderHistory.status = historyObj.getInt("status")
                reminderHistory.historyId = historyObj.getString("history_id")
                let timeString = historyObj.getString("status_updated_time") ?? ""
                let dateString = historyObj.getString("status_updated_date") ?? ""
                reminderHistory.statusUpdatedTime = Date.getDateFromString(dateFormat: "MMM dd, yyyy HH:mm", dateString: "\(dateString) \(timeString)")
                
                reminderFrequency.timeDayPrimaryKey = ((reminderFrequency.time ?? "") + (reminderFrequency.day ?? ""))
                reminderHistory.reminderId = reminderId
                reminderHistory.patientId = getSelectedPatientId()
                reminderHistory.reminderFrequency = reminderFrequency
                reminderHistoryList.append(reminderHistory)
            })
        }
        return reminderHistoryList
    }
    
    static func getMessageFromDict(_ dict: [String: Any]) -> String{
        if let outputString = dict.getAsJsonObject("output_string"){
            return outputString.getString("message") ?? ""
        }
        else{
            return dict.getString("message") ?? ""
        }
    }
    
    static func getReminderHistoryId(_ dict: [String: Any]) -> String{
        if let outputString = dict.getAsJsonObject("output_string"){
            return outputString.getString("reminder_history_id") ?? ""
        }
        return ""
    }
    
    //MARK: - ShareSection
    
    static func getSharedSectionPracticeList(dict: [String: Any]) -> [ShareSection]{
        var shareSectionList:[ShareSection] = []
        guard let shareSectionDictArr = dict.getAsJsonArray("output_string") else { return [] }
        shareSectionDictArr.forEach { sectionDictObj in
            var shareSection = ShareSection()
            shareSection.facilitiesName = sectionDictObj.getString("facilities_name")
            shareSection.isActive = sectionDictObj.getBoolean("is_active") ?? false
            shareSection.practiceId = sectionDictObj.getString("practice_id")
            shareSection.practiceName = sectionDictObj.getString("careteam_display_name")
            let sectionsList = sectionDictObj.getAsStringArray("sections") ?? []
            shareSection.sectionsList = sectionsList
            let afterExclusiveSectionsList = sectionsList.filter {
                !sectionExcludeList.contains($0)
            }
            if !afterExclusiveSectionsList.isEmpty{
                shareSectionList.append(shareSection)
            }
        }
        return shareSectionList
    }
    
    static func getPracticeShareSection(dict: [String: Any]) -> ShareSection{
        var shareSection = ShareSection()
        
        guard let outputDict = dict.getAsJsonObject("output_string") else { return shareSection }
        let list = outputDict["SECTIONS"] as? [String?]
        shareSection.sectionsList = list?.filter{$0 != nil}.compactMap{ $0 } ?? []
        
        return shareSection
    }
    
    //MARK: - Images
    
    static func formImagesResultList(resp: [String: Any], practice: Practice?) -> [ImagesResult]{
        var imageResultList: [ImagesResult] = []
        
        guard let outputString = resp.getAsJsonObject("output_string") else { return imageResultList }
        
        guard let resultListDict = outputString.getAsJsonObject("result_list") else { return imageResultList }
        
        guard let resultList = resultListDict.getAsJsonArray("RESULT_LIST") else { return imageResultList }
        
        guard let imageTestType = resultListDict.getAsJsonObject("image_test_type") else { return imageResultList }
        
        guard let testNameDetails = resultListDict.getAsJsonObject("test_name_details") else { return imageResultList }
        
        for resultDict in resultList{
            let imageResult = ImagesResult()
            
            imageResult.practice = practice
            imageResult.photoOrig = resultDict.getString("PHOTO_ORIG")
            imageResult.phrimageResultGrpId = resultDict.getString("PHR_IMAGE_RESULT_GROUP_ID")
            imageResult.imageResultGrpId = resultDict.getString("IMAGE_RESULT_GROUP_ID")
            imageResult.status = resultDict.getString("STATUS")
            imageResult.instruction = resultDict.getString("MESSAGE_TO_PATIENT")
            imageResult.isReviewed = resultDict.getBoolean("REVIEW_STATUS") ?? false
            let dateString = resultDict.getString("DATE") ?? ""
            imageResult.date = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_TIME, dateString: dateString)
            
            let member = Provider()
            member.fullName = resultDict.getString("MEMBER_NAME")
            member.memberId = resultDict.getString("MEMBER_ID")
            imageResult.member = member
                        
            let imageTestIdList: [String] = resultDict.getAsStringArray("IMAGE_TEST_IDS") ?? []
            
            var imageTestList: [ImageTest] = []
            imageTestIdList.forEach { imageTestId in
                
                if let testDetailObj = testNameDetails.getAsJsonObject(imageTestId) {
                    
                    let imageTest = ImageTest()
                    
                    imageTest.testId = testDetailObj.getString("IMAGE_TEST_ID")
                    imageTest.testCode = testDetailObj.getString("IMAGE_TEST_CODE")
                    imageTest.testName = testDetailObj.getString("IMAGE_TEST")
                    imageTest.imageTypeId = testDetailObj.getString("IMAGE_TYPE_ID")
                    imageTest.isDeleted = testDetailObj.getBoolean("IS_DELETED") ?? false
                    
                    if let type = imageTestType.getString(imageTest.imageTypeId ?? ""), type.isNotBlank(){
                        imageResult.type = type
                    }
                    
                    imageTestList.append(imageTest)
                }
            }
            imageResult.imageTestList = imageTestList
            
            imageResultList.append(imageResult)
        }
        
        return imageResultList
    }
    
    static func formImagesOrderList(resp: [String: Any]) -> [ImagesOrder]{
        var imageOrderList: [ImagesOrder] = []
        
        guard let dictArr = resp.getAsJsonArray("output_string") else { return imageOrderList }
        
        for dict in dictArr{
            let imageOrder = ImagesOrder()
            
            imageOrder.filesize = dict.getString("FILE_SIZE")
            imageOrder.patientId = dict.getString("RECEIVER_ID")
            imageOrder.date = Date.getDateFromString(dateFormat: PHR_DATE_API_FORMAT, dateString: dict.getString("SHARED_DATE") ?? "")
            imageOrder.fileId = dict.getString("FILE_ID")
            imageOrder.fileName = dict.getString("FILE_NAME")
            imageOrder.contentType = dict.getString("CONTENT_TYPE")
            imageOrder.readStatus = dict.getBoolean("READ_STATUS") ?? false
            imageOrder.fileType = dict.getString("FILE_TYPE")
            imageOrder.fileStatusId = dict.getString("FILE_STATUS_ID")
            
            let practice = Practice()
            practice.practiceId = dict.getString("SENDER_ID")
            practice.practiceName = dict.getString("SENT_BY")
            imageOrder.practice = practice
            
            imageOrderList.append(imageOrder)
        }
        
        return imageOrderList
    }
    
    //MARK: - Privilege
    
    static func formPrivilegeList(respObj: Dictionary<String, Any>)-> [RBACPrivileges]{
        var privilegeList:[RBACPrivileges] = []
        
        
        if let outputString = respObj.getAsJsonObject("output_string"),let privilegeArr =  outputString.getAsStringArray("privileges"){
            
            for privilegeStr in privilegeArr {
                
                switch privilegeStr {
                    case "full_access":
                        privilegeList.append(.FULL_ACCESS)
                    case "add_wellness":
                        privilegeList.append(.ADD_WELLNESS)
                    case "delete_wellness":
                        privilegeList.append(.DELETE_WELLNESS)
                    case "edit_wellness":
                        privilegeList.append(.EDIT_WELLNESS)
                    case "view_reports":
                        privilegeList.append(.VIEW_REPORTS)
                    case "add_insurance":
                        privilegeList.append(.ADD_INSURANCE)
                    case "view_insurance":
                        privilegeList.append(.VIEW_INSURANCE)
                    case "edit_insurance":
                        privilegeList.append(.EDIT_INSURANCE)
                    case "delete_insurance":
                        privilegeList.append(.DELETE_INSURANCE)
                    case "add_immune":
                        privilegeList.append(.ADD_IMMUNE)
                    case "view_immune":
                        privilegeList.append(.VIEW_IMMUNE)
                    case "edit_immune":
                        privilegeList.append(.EDIT_IMMUNE)
                    case "delete_immune":
                        privilegeList.append(.DELETE_IMMUNE)
                    case "view_appointment":
                        privilegeList.append(.VIEW_APPOINTMENT)
                    case "view_questionnaire":
                        privilegeList.append(.VIEW_QUESTIONNAIRE)
                    case "submit_questionnaire":
                        privilegeList.append(.SUBMIT_QUESTIONNAIRE)
                    case "view_announcements":
                        privilegeList.append(.VIEW_ANNOUNCEMENTS)
                    case "view_visitsummary":
                        privilegeList.append(.VIEW_VISITSUMMARY)
                    case "view_invoice":
                        privilegeList.append(.VIEW_INVOICE)
                    case "view_receipt":
                        privilegeList.append(.VIEW_RECEIPT)
                    case "view_messages":
                        privilegeList.append(.VIEW_MESSAGES)
                    case "view_medications":
                        privilegeList.append(.VIEW_MEDICATIONS)
                    case "view_documents":
                        privilegeList.append(.VIEW_DOCUMENTS)
                    case "view_allergies":
                        privilegeList.append(.VIEW_ALLERGIES)
                    case "view_wellness":
                        privilegeList.append(.VIEW_WELLNESS)
                    case "view_labresults":
                        privilegeList.append(.VIEW_LABRESULTS)
                    case "view_procedure":
                        privilegeList.append(.VIEW_PROCEDURE)
                    case "add_procedure":
                        privilegeList.append(.ADD_PROCEDURE)
                    case "edit_procedure":
                        privilegeList.append(.EDIT_PROCEDURE)
                    case "delete_procedure":
                        privilegeList.append(.DELETE_PROCEDURE)
                    case "view_usefulinfo":
                        privilegeList.append(.VIEW_USEFULINFO)
                    case "view_clinicalsummary":
                        privilegeList.append(.VIEW_CLINICALSUMMARY)
                    case "add_allergies":
                        privilegeList.append(.ADD_ALLERGIES)
                    case "edit_allergies":
                        privilegeList.append(.EDIT_ALLERGIES)
                    case "delete_allergies":
                        privilegeList.append(.DELETE_ALLERGIES)
                    case "add_medications":
                        privilegeList.append(.ADD_MEDICATIONS)
                    case "edit_medications":
                        privilegeList.append(.EDIT_MEDICATIONS)
                    case "delete_medications":
                        privilegeList.append(.DELETE_MEDICATIONS)
                    case "edit_supplements":
                        privilegeList.append(.EDIT_SUPPLEMENTS)
                    case "delete_supplements":
                        privilegeList.append(.DELETE_SUPPLEMENTS)
                    case "view_practicedetials":
                        privilegeList.append(.VIEW_PRACTICEDETIALS)
                    case "add_supplements":
                        privilegeList.append(.ADD_SUPPLEMENTS)
                    case "view_supplements":
                        privilegeList.append(.VIEW_SUPPLEMENTS)
                    case "add_messages":
                        privilegeList.append(.ADD_MESSAGES)
                    case "delete_messages":
                        privilegeList.append(.DELETE_MESSAGES)
                    case "add_documents":
                        privilegeList.append(.ADD_DOCUMENTS)
                    case "export_documents":
                        privilegeList.append(.EXPORT_DOCUMENTS)
                    case "delete_documents":
                        privilegeList.append(.DELETE_DOCUMENTS)
                    case "add_folders":
                        privilegeList.append(.ADD_FOLDERS)
                    case "view_folders":
                        privilegeList.append(.VIEW_FOLDERS)
                    case "edit_folders":
                        privilegeList.append(.EDIT_FOLDERS)
                    case "delete_folders":
                        privilegeList.append(.DELETE_FOLDERS)
                    case "view_flowsheetdata":
                        privilegeList.append(.VIEW_FLOWSHEETDATA)
                    case "add_flowsheetdata":
                        privilegeList.append(.ADD_FLOWSHEETDATA)
                    case "edit_flowsheetdata":
                        privilegeList.append(.EDIT_FLOWSHEETDATA)
                    case "delete_flowsheetdata":
                        privilegeList.append(.DELETE_FLOWSHEETDATA)
                    case "add_appointment":
                        privilegeList.append(.ADD_APPOINTMENT)
                
                    default:
                        debugPrintLog("")
                }
            }
        }
        
        return privilegeList
    }

    static func formZoomCredentials(respObj: Dictionary<String, Any>) -> ZoomCredentials {
        
        let zoomCredentials = ZoomCredentials()
        
        if let teleHelth = respObj["telehealth"] as? Dictionary<String,Any>
        {
            zoomCredentials.platform = teleHelth.getString("platform")
            zoomCredentials.isConsentFormAvailable = teleHelth.getBoolean("is_consent_form_available") ?? false

            if zoomCredentials.platform.isNilOrBlank() {
                zoomCredentials.platform = "ZOOM"
            }
            
            if zoomCredentials.isConsentFormAvailable {
                zoomCredentials.consentFormIdList = teleHelth.getAsStringArray("consent_form_ids")
            }
            
            if zoomCredentials.platform == "OPENTOK" {
                zoomCredentials.webURL = teleHelth.getString("join_url") ?? ""
                zoomCredentials.password = teleHelth.getString("meeting_password") ?? ""
            }
            else if zoomCredentials.platform == "ZOOM" {
                if let videoConsultDict = teleHelth["meeting"] as? Dictionary<String,Any>{
                    zoomCredentials.userType = videoConsultDict["USER_TYPE"] as? String
                    zoomCredentials.zoomToken = videoConsultDict["TOKEN"] as? String
                    zoomCredentials.userId = videoConsultDict["USER_ID"] as? String
                    zoomCredentials.zak = videoConsultDict["ZAK"] as? String
                    zoomCredentials.webDomain = videoConsultDict["ZOOM_DOMAIN"] as? String
                    zoomCredentials.jwtToken = videoConsultDict["SDK_JWT"] as? String
                    zoomCredentials.memberName = videoConsultDict["MEMBER_NAME"] as? String
                    zoomCredentials.meetingId = videoConsultDict.getString("ID")
                }
            }
            else{
                
            }
            

        }
        
        return zoomCredentials
    }
    
    static func formSupportAttachmentId(respObj: Dictionary<String,Any>) -> String? {
        
        if let attachmentList = respObj["attachments"] as? [Dictionary<String,Any>]
        {
            
            if let attchmentObj = attachmentList.firstOrNil(){
                if let attachment = attchmentObj.getString("file_id") {
                    return attachment
                }
            }
                    
        }
        return nil
    }
}
