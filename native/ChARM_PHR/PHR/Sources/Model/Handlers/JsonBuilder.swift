//
//  JsonBuilder.swift
//  phr
//
//  Created by Sankar Saravanan on 05/12/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

struct JsonBuilder {
    
    //MARK: - patient vitals
    
    static func formPatientVitalPostJson(addvital: AddVital) -> Dictionary<String,Any>
    {
        var json : [String:Any] = [:]
        
        json.updateValue( getSelectedPatientId() ,forKey: "patient_id")
        json.updateValue(addvital.dateStr ?? "", forKey: "date_of_entry")
        if let notes = addvital.notes
        {
            json.updateValue(notes ,forKey: "notes")
        }
        json.updateValue(addvital.trackerId ?? "",forKey: "tracker_id")
        
        if let metricJsonArr = addvital.metricArr {
            json.updateValue(metricJsonArr, forKey: "tracked_entry")
        }
        return json
    }
    
    static func formVitalUnitObj(patientId:String , unitStr: String) -> Dictionary<String,Any> {
        
        var postObj : [String:Any] = [:]

        postObj.addProperty("patient_id", patientId)
        postObj.addProperty("unit_system", unitStr)
        
        return postObj
    }
    
    static func formVitalUsingHK(vitalList:[MetricValue]) -> Dictionary<String,Any> {
        var postObj = Dictionary<String, Any>()
        var postArr:[Dictionary<String, Any>] = []
        
        vitalList.forEach({vital in
            var vitalObj = Dictionary<String,Any>()
            vitalObj.addProperty("date_of_entry", vital.metricHistory?.dateOfEntry?.getStringFromDate(dateFormat: sqlTimeStampFormat))
            vitalObj.addProperty("metric_name", vital.metric?.metricName)
            vitalObj.addProperty("tracked_value", vital.metricHistory?.trackedValue)
            vitalObj.addProperty("tracked_value_unit", vital.metricHistory?.trackedValueUnit)
            vitalObj.addProperty("tracker_name", vital.tracker?.trackerName)
            vitalObj.addProperty("source_id", 2)
            if vital.type != .sleep && vital.type != .steps {
                if let uniqueId = vital.metricHistory?.uniqueId {
                    vitalObj.addProperty("external_id", uniqueId.uuidString)
                }
            }
            postArr.append(vitalObj)
        })
        
        postObj.addProperty("vital_list", postArr)
        return postObj
    }
    
    static func convertPatientMedicationsToJson(medicationPOJO: MedicationPOJO) -> Dictionary<String,Any>
    {
        
        var json : [String:Any] = [:]
        
        //        json.updateValue( Patient.selectedPatientInstance!.patientId! ,forKey: "patient_id")
        //        json.updateValue(Patient.selectedPatientInstance!.firstName! ,forKey: "patient_name")
        json.updateValue(medicationPOJO.patientMedication?.memberId ?? "" ,forKey: "physician_id")
        json.updateValue(medicationPOJO.patientMedication?.practiceId ?? "" ,forKey: "practice_id")
        json.updateValue("Prescription" ,forKey: "refill_type")
        json.updateValue(medicationPOJO.patientMedication?.patientMedicationId ?? "" ,forKey: "refill_id")
        
        json.updateValue(medicationPOJO.patientMedication?.reasonForRefill ?? "" ,forKey: "reason")
        
        return json
    }
    
//    static func convertPatientSupplementToJson(supplement: SupplementPOJO , reason : String) -> Dictionary<String,Any>
//    {
//        
//        var postObj : [String:Any] = [:]
//
//Raghul        postObj.addProperty("physician_id" , supplement.memberId)
//        postObj.addProperty("practice_id" , supplement.practiceId)
//        postObj.addProperty("refill_type" , "Supplement")
//        postObj.addProperty("refill_id" , supplement.patientSupplements.patientSupplementId)
//        if (reason.isNotBlank()){
//            postObj.addProperty("reason" , reason)
//        }
//
//        return postObj
//    }
    
    static func formRefillSupplementObj(supplementPOJO: SupplementPOJO) -> Dictionary<String, Any>{
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("physician_id", supplementPOJO.patientSupplement?.memberId)
        postObj.addProperty("practice_id", supplementPOJO.patientSupplement?.practiceId)
        postObj.addProperty("refill_type", "Supplement")
        postObj.addProperty("refill_id", supplementPOJO.patientSupplement?.patientSupplementId)
        
        if (supplementPOJO.patientSupplement?.reasonForRefill.isNilOrBlank() == false) {
            postObj.addProperty("reason", supplementPOJO.patientSupplement?.reasonForRefill)
        }
        
        return postObj
    }
    
    static func formAddSupplementObj(practiceId: String?, supplementPOJO: SupplementPOJO) -> Dictionary<String, Any>{
        var postObj : [String:Any] = [:]
        
        if let patientSupplement = supplementPOJO.patientSupplement, let supplement = supplementPOJO.supplement{
            
        //    postObj.addProperty("patient_id", patientSupplement.patientId)
            
            postObj.addProperty("dosage_unit_id", patientSupplement.dosageUnitId)
            

            postObj.addProperty("comments", patientSupplement.comments)
            postObj.addProperty("dosage", patientSupplement.dosage)
            postObj.addProperty("from_date", patientSupplement.fromDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
            postObj.addProperty("intake", patientSupplement.intake)
            postObj.addProperty("intake_unit", supplement.intakeUnit)
            postObj.addProperty("intake_when", patientSupplement.intakeWhen)
            postObj.addProperty("number_of_intake", supplement.numberOfIntake)
            postObj.addProperty("to_date", patientSupplement.toDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
            postObj.addProperty("practice_id", practiceId)
        }

        if let supplement = supplementPOJO.supplement {
            postObj.addProperty("supplement_name", supplement.supplementName)
            postObj.addProperty("manufacturer_name", supplement.manufacturerName)
        }
        
        return postObj
    }
    
    static func formEditSupplementObj(supplementPOJO: SupplementPOJO) -> Dictionary<String, Any>{
        var postObj : [String:Any] = [:]
        
        
        
        
        if let patientSupplement = supplementPOJO.patientSupplement, let supplement = supplementPOJO.supplement{
            
         //   postObj.addProperty("patient_id", patientSupplement.patientId)
            postObj.addProperty("dosage_unit_id", patientSupplement.dosageUnitId)
            
            postObj.addProperty("comments", patientSupplement.comments)
            postObj.addProperty("dosage", patientSupplement.dosage)
            postObj.addProperty("from_date", patientSupplement.fromDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
            postObj.addProperty("intake", patientSupplement.intake)
            postObj.addProperty("intake_unit", supplement.intakeUnit)
            postObj.addProperty("intake_when", patientSupplement.intakeWhen)
            postObj.addProperty("number_of_intake", supplement.numberOfIntake)
            postObj.addProperty("to_date", patientSupplement.toDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
            postObj.addProperty("supplement_history_id", patientSupplement.patientSupplementId)
        }
        
        if let supplement = supplementPOJO.supplement{
            postObj.addProperty("manufacturer_name", supplement.manufacturerName)
        }
        
        return postObj
    }
    
    
    
    static func formAppointmentObj(appointmentRequest: AppointmentRequest) -> Dictionary<String, Any>{
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("facility_id" , appointmentRequest.facility?.facilityId)
        postObj.addProperty("practice_id" , appointmentRequest.practiceId)
        postObj.addProperty("reason" , appointmentRequest.reason)
        
        if appointmentRequest.addAsWaitingList {
            postObj.addProperty("patient_id" , appointmentRequest.practicePatientId)
        }
        
        if (!appointmentRequest.receiptId.isNilOrBlank()){
            postObj.addProperty("receipt_id" , appointmentRequest.receiptId)
        }
        
        if appointmentRequest.isEnabled {
            
            if appointmentRequest.addAsWaitingList {
                postObj.addProperty("mode" , appointmentRequest.appointmentType)
                postObj.addProperty("member_id" , appointmentRequest.member?.memberId)
                postObj.addProperty("date_option1", appointmentRequest.dateChoice1?.getStringFromDate(dateFormat:PHR_DATE_API_FORMAT))
            }
            else{
                postObj.addProperty("appointment_type" , appointmentRequest.appointmentType)
                postObj.addProperty("physician_id" , appointmentRequest.member?.memberId)
                
                postObj.addProperty("physician_name", appointmentRequest.member?.formMemberName())
                postObj.addProperty("facility_name", appointmentRequest.facility?.facilityName)
                postObj.addProperty("duration", appointmentRequest.duration)
                postObj.addProperty("repeat_type", "ONETIME")
                postObj.addProperty("double_booking", false)
                postObj.addProperty("appointment_date_str", appointmentRequest.dateChoice1?.getStringFromDate(dateFormat:PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
                postObj.addProperty("appointment_status", "Confirmed")
                postObj.addProperty("start_hour", appointmentRequest.startHour)
                postObj.addProperty("start_minutes", appointmentRequest.startMinutes)
                postObj.addProperty("start_session", appointmentRequest.startSession)
                
            }
            
            if (appointmentRequest.visitType != nil){
                postObj.addProperty("visit_type_id" , appointmentRequest.visitType?.visittypeId)
            }
        }
        else{
            postObj.addProperty("physician_id" , appointmentRequest.member?.memberId)
            postObj.addProperty("appointment_type" , appointmentRequest.appointmentType)
            postObj.addProperty("reminder_type" , appointmentRequest.reminderType)
            postObj.addProperty("date_preference" , appointmentRequest.datePreference)
            
            if appointmentRequest.datePreference == appointmentDatePreferenceSpecificDate{
                postObj.addProperty("date_choice1", appointmentRequest.dateChoice1?.getStringFromDate(dateFormat:PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
            }
            
            postObj.addProperty("time_preference" , appointmentRequest.timePreference)
            
            if appointmentRequest.timePreference == appointmentTimePreferenceTimeRange {
                postObj.addProperty("start_hour" , appointmentRequest.startHour)
                postObj.addProperty("start_minutes" , appointmentRequest.startMinutes)
                postObj.addProperty("start_session" , appointmentRequest.startSession)
                
                postObj.addProperty("end_hour" , appointmentRequest.endHour)
                postObj.addProperty("end_minutes" , appointmentRequest.endMinutes)
                postObj.addProperty("end_session" , appointmentRequest.endSession)
            }
        }
        return postObj
    }
    
    static func convertAddApointmentToJson(addAppointment : AddAppointment , facilityDictArr : [Dictionary<String,Any>] , appointmentType : [String] , providerDictArr : [Dictionary<String,Any>] , arrayOfSlotTimeDict : [Array<Dictionary<String,Any>>]) -> Dictionary<String,Any>
    {
        var json : [String:Any] = [:]
        
        json.updateValue( facilityDictArr[addAppointment.selectedFacilityIndex!]["facility_id"]! ,forKey: "facility_id")
        json.updateValue( Patient.selectedPatientInstance?.patientId ?? "" ,forKey: "patient_id")
        json.updateValue( addAppointment.selectedPractice?.practiceId ?? "" ,forKey: "practice_id")
        json.updateValue( addAppointment.reasonStr! ,forKey: "reason")
        
        if addAppointment.isWaitlistSelected
        {
            json.updateValue( providerDictArr[addAppointment.selectedProviderIndex!]["member_id"]! ,forKey: "member_id")
            json.updateValue( addAppointment.appoimentTypeStr, forKey: "mode")
            json.updateValue( CharmUtil.getDateStringWith(date: addAppointment.selectedDate!, dateFormat: PHR_DATE_API_FORMAT) ,forKey: "date_option1")
            if addAppointment.visitTypeId != nil
            {
                json.updateValue( addAppointment.visitTypeId! ,forKey: "visit_type_id")
            }
        }
        else if addAppointment.isConfigured == false
        {
            //            json.updateValue( "Mail" ,forKey: "reminder_type")
            json.updateValue( providerDictArr[addAppointment.selectedProviderIndex!]["member_id"]! ,forKey: "physician_id")
            json.updateValue( "Mail", forKey: "reminder_type")
            json.updateValue( capitalizFirstLetterInEveryWord(string: addAppointment.appoimentTypeStr), forKey: "appointment_type")
            
            if addAppointment.selectedDateIndex == 0
            {
                json.updateValue( "ANY_DATE" ,forKey: "date_preference")
            }else
            {
                json.updateValue( "SPECIFIC_DATE" ,forKey: "date_preference")
                if addAppointment.spcificDate != nil
                {
                    json.updateValue(addAppointment.spcificDate!,forKey: "date_choice1")
                }
            }
            if addAppointment.selectedTimeIndex == 0
            {
                json.updateValue( "ANY_TIME" ,forKey: "time_preference")
            }else
            {
                json.updateValue( "TIME_RANGE" ,forKey: "time_preference")
                let arrayOfTime = addAppointment.spcificTimeRange!.split(separator: "-")
                if arrayOfTime.count == 2
                {
                    let fromTime = CharmUtil.getDateObjectWith(dateString: "\(arrayOfTime[0])", dateFormat: "hh:mm a ")!
                    let toTime = CharmUtil.getDateObjectWith(dateString: "\(arrayOfTime[1])", dateFormat: " hh:mm a")!
                    
                    json.updateValue( CharmUtil.getDateStringWith(date: fromTime, dateFormat: "hh"),forKey: "start_hour")
                    json.updateValue( CharmUtil.getDateStringWith(date: fromTime, dateFormat: "a"),forKey: "start_session")
                    json.updateValue( CharmUtil.getDateStringWith(date: fromTime, dateFormat: "mm") ,forKey: "start_minutes")
                    
                    json.updateValue( CharmUtil.getDateStringWith(date: toTime, dateFormat: "hh") ,forKey: "end_hour")
                    json.updateValue( CharmUtil.getDateStringWith(date: toTime, dateFormat: "mm") ,forKey: "end_minutes")
                    json.updateValue( CharmUtil.getDateStringWith(date: toTime, dateFormat: "a") ,forKey: "end_session")
                }
            }
        }else
        {
            json.updateValue( providerDictArr[addAppointment.selectedProviderIndex!]["member_id"]! ,forKey: "physician_id")
            
            //TODO : want to know why this is given ..?
            json.updateValue( "Confirmed" ,forKey: "appointment_status")
            //            json.updateValue( "false",forKey: "double_booking")
            json.updateValue( "ONETIME" ,forKey: "repeat_type")
            
            
            json.updateValue( CharmUtil.getDateStringWith(date: addAppointment.selectedDate!, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) ,forKey: "appointment_date_str")
            
            let slotTimeStr =  arrayOfSlotTimeDict[addAppointment.slectedSlotPrefreanceIndex!][addAppointment.selectedSlotTimeIndex!]["start_time"] as! String
            
            let arr = slotTimeStr.split(separator: " ")
            let timeArr = arr[0].split(separator: ":")
            
            //            let slotTime = CharmUtil.getDateObjectWith(dateString:slotTimeStr, dateFormat: "hh:mm a")!
            
            //NOTE: conversion below returns nil when device time is in 24hrs format, hence using split logic here. Need to analyse this case and change
            //
            //let str = "10:10 AM"
            //
            //        let df = DateFormatter()
            //        df.dateFormat = "hh:mm a"
            //
            ////        df.locale = NSLocale.current
            ////        df.timeZone = TimeZone.autoupdatingCurrent
            //
            //        df.setLocalizedDateFormatFromTemplate("jj:mm")
            //
            //        let dateObj = df.date(from: str)
            
            
            if(timeArr.count > 1){
                json.updateValue( timeArr[0],forKey: "start_hour")
                json.updateValue( timeArr[1] ,forKey: "start_minutes")
            }
            if(slotTimeStr.contains("AM")){
                json.updateValue( "AM",forKey: "start_session")
            }
            else if(slotTimeStr.contains("PM")){
                json.updateValue( "PM",forKey: "start_session")
            }
            
            
            json.updateValue( facilityDictArr[addAppointment.selectedFacilityIndex!]["facility_name"]! ,forKey: "facility_name")
            json.updateValue( providerDictArr[addAppointment.selectedProviderIndex!]["full_name"]! ,forKey: "physician_name")
            json.updateValue( "\(addAppointment.interval!)" ,forKey: "duration")
            json.updateValue( capitalizFirstLetterInEveryWord(string: addAppointment.appoimentTypeStr), forKey: "appointment_type")
            
            if addAppointment.visitTypeId != nil
            {
                json.updateValue( addAppointment.visitTypeId! ,forKey: "visit_type_id")
            }
            
            if addAppointment.receiptId != nil
            {
                json.updateValue(addAppointment.receiptId!, forKey: "receipt_id")
            }
        }
        return json
    }
    
    
    private static func capitalizFirstLetterInEveryWord(string : String) -> String
    {
        let arrayOfString = string.components(separatedBy: " ")
        var capitalizArr : [String] = []
        for word in arrayOfString
        {
            capitalizArr.append(word.capitalizingFirstLetter())
        }
        return capitalizArr.joined(separator: " ")
    }
    
    static func formComposeMsgObj(composeMsg: ComposeMessage) -> Dictionary<String,Any> {
        var postObj : [String:Any] = [:]

        postObj.addProperty("patient_id", composeMsg.patientId)
        postObj.addProperty("practice_id", composeMsg.practiceId)
        postObj.addProperty("content", composeMsg.content)
        postObj.addProperty("subject", composeMsg.subject)

        if !composeMsg.fileIdList.isEmpty {
            var attachmentJson : [[String: Any]] = []
            
            for fileId in composeMsg.fileIdList
            {
                attachmentJson.append(["attachment_id": fileId])
            }
            postObj.addProperty("attachments", attachmentJson)
        }
        
        var providerJson : [[String: Any]] = []
        for provider in composeMsg.providerList
        {
            providerJson.append(["member_id":"\(provider.memberId ?? "")"])
        }
        postObj.addProperty("receivers", providerJson)
        
        if let memberGroup = composeMsg.memberGroup {
            postObj.addProperty("group_id", memberGroup.groupId)
            postObj.addProperty("owner_id", composeMsg.ownerId)
        }
        
        return postObj
    }
    
    static func covertMessageToJson(subject:String,contentStr : String , actionContentStr : String? , patientId : String , practiceId : String, providerList : [Provider] , fileIdArray : [String]) -> Dictionary<String,Any>
    {
        var json : [String:Any] = [
            "patient_id": "\(patientId)",
            "practice_id": "\(practiceId)",
            "content": "<div>\(contentStr)</div>\(actionContentStr ?? "")",
            "subject": "\(subject)",
        ]
        
        if fileIdArray.count > 0
        {
            var attachmentJson : [Dictionary<String,Any>] = []
            
            for fileId in fileIdArray
            {
                attachmentJson.append(["attachment_id": fileId])
            }
            
            json.updateValue(attachmentJson, forKey: "attachments")
            
        }
        
        var providerJson : [Dictionary<String,Any>] = []
        
        for provider in providerList
        {
            providerJson.append(["member_id":"\(provider.memberId!)"])
        }
        
        json.updateValue(providerJson, forKey: "receivers")
        
        return json
    }
    
    static func convertAllergyToJson(allergiesList : AllergiesList , isHealthPassport : Bool = false) -> Dictionary<String,Any>
    {
        var json : [String:Any] = [:]
        
        json.updateValue( "\(CharmUtil.getDateStringWith(date: allergiesList.patientAllergyMap?.observedDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))" , forKey: "observed_date")
        json.updateValue( "\(allergiesList.patientAllergyMap?.reactions ?? "")" , forKey: "reactions")
        json.updateValue( "\(allergiesList.patientAllergyMap?.severity ?? "")" , forKey: "severity")
        json.updateValue( "\(Patient.selectedPatientInstance?.patientId ?? "")" , forKey: "patient_id")
        
        if allergiesList.allergyType == OTHERS && !isNilOrEmpty(string: allergiesList.otherType)
        {
            json.updateValue( "\(allergiesList.otherType ?? "")" , forKey: "other_type")
        }
        
        if allergiesList.patientAllergyMap?.resolvedDate != nil
        {
            json.updateValue(CharmUtil.getDateStringWith(date: allergiesList.patientAllergyMap?.resolvedDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), forKey: "resolved_date")
        }
        
        if allergiesList.patientAllergyMap?.allergyMapId != nil
        {
            json.updateValue("\(allergiesList.allergyId ?? "")", forKey: "allergy_id")
            json.updateValue("\(allergiesList.patientAllergyMap?.allergyMapId ?? "")", forKey: "allergy_map_id")
        }else
        {
            json.updateValue( "\(allergiesList.allergy ?? "")" , forKey: "allergy")
            json.updateValue( "\(allergiesList.allergyType ?? "")" , forKey: "allergy_type")
            json.updateValue( "\(allergiesList.patientAllergyMap?.status ?? "")" , forKey: "status")
        }
        
        if isHealthPassport
        {
            json.updateValue("true", forKey: "Health_Passport")
        }
        
        return json
    }
    
    static func convertMedicationToJson(practiceId : String? ,medicationPOJO : MedicationPOJO) -> Dictionary<String,Any>
    {
        //"patient_id": "\(medicationPOJO.patientMedication?.patientId ?? "")",
        var json = [
            
            "dosage": "\(medicationPOJO.patientMedication?.dosage ?? "")",
            "dosage_unit_id": "\(medicationPOJO.patientMedication?.dosageUnitId ?? "")",
            "intake_unit": "\(medicationPOJO.medication?.intakeUnit ?? "")",
            "intake": "\(medicationPOJO.patientMedication?.intake ?? "")",
            "intake_when": "\(medicationPOJO.patientMedication?.intakeWhen ?? "")",
            "intake_route": "\(medicationPOJO.patientMedication?.intakeRoute ?? "")",
            "is_active": "true",
            "from_date": "\(CharmUtil.getDateStringWith(date: medicationPOJO.patientMedication?.fromDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))",
            "to_date": "\(CharmUtil.getDateStringWith(date: medicationPOJO.patientMedication?.toDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))",
            "medical_condition_id": "\(medicationPOJO.patientMedication?.medicalConditionId ?? "")",
            "prescribed_by": "\(medicationPOJO.patientMedication?.prescribedBy ?? "")",
            //TODO: want to know what is "prescription_quantity"
            "prescription_quantity": "",
            "comments": "\(medicationPOJO.patientMedication?.comment ?? "")"
        ]
        
        if  medicationPOJO.medication?.numberOfIntake != nil
        {
            json.updateValue(medicationPOJO.medication?.numberOfIntake ?? "", forKey: "number_of_intake")
        }else
        {
            json.updateValue("", forKey: "number_of_intake")
        }
        
        if medicationPOJO.patientMedication?.refill != nil
        {
            json.updateValue(medicationPOJO.patientMedication?.refill! ?? "", forKey: "refills")
        }else
        {
            json.updateValue("", forKey: "refills")
        }
        
        if medicationPOJO.medication?.medicationName != nil
        {
            json.updateValue("\(medicationPOJO.medication?.medicationName ?? "")", forKey: "medication_name")
        }
        
        if practiceId != nil
        {
            json.updateValue("\(practiceId!)", forKey: "practice_id")
        }
        
        if medicationPOJO.patientMedication?.patientMedicationId != nil
        {
            json.updateValue("\(medicationPOJO.patientMedication?.patientMedicationId ?? "")", forKey: "prescription_history_id")
        }
        return json
    }
    
    static func convertProcedureValueToJson(patientId : String , procedureList : ProceduresList) -> Dictionary<String,Any>
    {
        var json : [String:Any] = [:]
        
        json.updateValue(patientId, forKey: "patient_id")
        json.updateValue("\(procedureList.comments ?? "")", forKey: "notes")
        json.updateValue(CharmUtil.getDateStringWith(date: procedureList.fromDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), forKey: "from_date")
        
        if procedureList.toDate != nil
        {
            json.updateValue(CharmUtil.getDateStringWith(date: procedureList.toDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), forKey: "to_date")
        }
        
        if procedureList.procedureMapId != nil
        {
            json.updateValue("\(procedureList.procedureMapId ?? "")", forKey: "procedure_map_id")
        }else
        {
            json.updateValue("\(procedureList.procedureName ?? "")", forKey: "procedure")
            json.updateValue("\(procedureList.procedureType ?? "")", forKey: "procedure_type")
        }
        
        return json
    }
    
    
    static func formAddVaccineObj(immunizationPOJO: VaccineImmunizationPOJO)-> Dictionary<String,Any> {
        var reqObj = Dictionary<String,Any>()
        
        reqObj.addProperty("immune_name", immunizationPOJO.patientImmunizationMap?.immunizationList?.immunizationName)
        reqObj.addProperty("immune_type", immunizationPOJO.patientImmunizationMap?.immunizationList?.immunizationType)
        reqObj.addProperty("how_administered", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.howAdministered)
        reqObj.addProperty("given_by", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.givenBy)
        reqObj.addProperty("manufacturer", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.manufacturer)
        reqObj.addProperty("comments", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.comments)
        reqObj.addProperty(
            "from_date",
            immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.vaccinesOn?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        
        reqObj.addProperty("patient_id", immunizationPOJO.patientImmunizationMap?.patientId)

        return reqObj
        
    }
    
    static func formEditVaccineObj(immunizationPOJO: VaccineImmunizationPOJO)-> Dictionary<String,Any> {
        var reqObj = Dictionary<String,Any>()
        
        reqObj.addProperty("how_administered", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.howAdministered)
        reqObj.addProperty("given_by", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.givenBy)
        reqObj.addProperty("manufacturer", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.manufacturer)
        reqObj.addProperty("comments", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.comments)
        reqObj.addProperty(
            "from_date",
            immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.vaccinesOn?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        
        reqObj.addProperty("patient_id", immunizationPOJO.patientImmunizationMap?.patientId)
        reqObj.addProperty("immune_history_id", immunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.immunizationHistoryId)

        return reqObj
        
    }
    
    static func convertVaccineToJson(patientId : String , vaccine : Vaccine) -> Dictionary<String,Any>
    {
        var json =
        [
            "patient_id": "\(patientId)",
            "from_date": "\(CharmUtil.getDateStringWith(date:vaccine.immunizationDate , dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))",
            "comments": "\(vaccine.comments ?? "")" ,
            "given_by": "\(vaccine.givenBy ?? "")",
            "how_administered":"\(vaccine.howAdministered ?? "")",
            "manufacturer": "\(vaccine.manufacturer ?? "")"
        ]
        
        if vaccine.immunizationHistoryId != nil
        {
            json.updateValue(vaccine.immunizationHistoryId, forKey: "immune_history_id")
        }else
        {
            json.updateValue(vaccine.immunizationName, forKey: "immune_name")
            json.updateValue("\(vaccine.immunizationType ?? "")", forKey: "immune_type")
        }
        
        return json
    }
    
    static func formCardGroupObj(paymentInfo:PaymentInfo) -> Dictionary<String,Any>{
        var postObj : [String:Any] = [:]
        postObj.addProperty("patient_id", paymentInfo.transactionInfo?.patientId ?? "")
        postObj.addProperty("practice_id", paymentInfo.transactionInfo?.practiceId ?? "")
        
        return postObj
    }
    
    static func formTransactionObj(paymentInfo: PaymentInfo) -> Dictionary<String,Any> {
        
        var postObj : [String:Any] = [:]
        
        
        if let transactionInfo = paymentInfo.transactionInfo {
            //postObj.addProperty("patient_id", transactionInfo.patientId)
            postObj.addProperty("practice_id", transactionInfo.practiceId)
            postObj.addProperty("facility_id", transactionInfo.facilityId)


            if (!transactionInfo.memberId.isNilOrBlank()) {
                postObj.addProperty("member_id", transactionInfo.memberId ?? "")
            }


            if (!transactionInfo.merchantAccountId.isNilOrBlank()) {
                postObj.addProperty("merchant_account_id", transactionInfo.merchantAccountId)
            }

            
            
            if (!transactionInfo.statementId.isNilOrBlank()) {
            //transactionInfo.service = paymentServiceBillingTemp
                postObj.addProperty("statement_id", transactionInfo.statementId)
            }
            else{
                if (!transactionInfo.billId.isNilOrBlank()) {
                    postObj.addProperty("bill_id", transactionInfo.billId)
                }
            }
            
            
            postObj.addProperty("service", transactionInfo.service)
            

            postObj.addProperty("amount", transactionInfo.paymentAmount)
            postObj.addProperty("gateway", transactionInfo.gateway)
            
            
            postObj.addProperty("_", "\(Int(Date().timeIntervalSince1970 * 1000))")
            
            
            var customData = Dictionary<String,String>()
            
            if (!transactionInfo.nickName.isNilOrBlank()) {
                customData.addProperty("card_nick_name", transactionInfo.nickName ?? "")
            }
            
            if let address = paymentInfo.cardDetails?.postalAddress{
                customData.addProperty("street_address1", address.line1 ?? "")
                customData.addProperty("street_address2", address.line2 ?? "")
                customData.addProperty("city", address.city ?? "")
                customData.addProperty("state", address.state ?? "")
                customData.addProperty("country", address.country ?? "")
                customData.addProperty("zip", address.postalCode ?? "")
            }
            
            if !customData.isEmpty{
                postObj.addProperty("custom_data", customData.convertToStringJson())
            }
            
            
//            if (!transactionInfo.nickName.isNilOrBlank()) {
//
//                postObj.addProperty("custom_data", "{\"card_nick_name\":\"\(transactionInfo.nickName ?? "")\",\"street_address1\":\"No206, Bleeker Street\",\"street_address2\":\"Harrington Avenue\",\"city\":\"Buffalo\",\"state\":\"NY\",\"country\":\"us\",\"zip\":\"34242-3232\"}")
//            }
            
            if transactionInfo.gateway == appointmentGatewayTypeBluefin{
                postObj.addProperty("transaction_type", paymentInfo.transactionType)
            }
        }
        return postObj
    }
    
    
    
    static func createJsonFromCreateTransaction(paymentInfo : PaymentInfo? , service : String ,practiceId : String , facilityId : String , memberid : String ) -> Dictionary<String,Any>
    {
        let currentDate = Date()
        var json =
        [
            "patient_id" : "\(paymentInfo?.transactionInfo?.patientId ?? "")",
            "practice_id" : "\(practiceId)",
            "facility_id" : "\(facilityId)",
            "member_id" : "\(memberid)",
            "service" : "\(service)",
            "amount" : paymentInfo?.chargeAmount,
            "_":"\(Int(currentDate.timeIntervalSince1970 * 1000))"
        ]
        
        if paymentInfo?.transactionInfo?.merchantAccountId != nil
        {
            json.updateValue("\(paymentInfo?.transactionInfo?.merchantAccountId ?? "")", forKey: "merchant_account_id")
        }
        return json as Dictionary<String, Any>
    }
    
    static func formPaymentPostObj(paymentInfo: PaymentInfo , responseTransactionObj: Dictionary<String,Any>) -> Dictionary<String, Any>?{
        
        let bluefinReqParams = ["account_id", "hash", "timestamp", "success_url", "decline_url", "transaction_type", "tender_type", "card_number", "card_verification", "first_name", "last_name", "street_address1", "street_address2", "city", "state", "country", "zip", "response_format", "custom_data", "custom_id"] //No I18N
        
        var postObj : [String:Any] = [:]
        
       
        
        if let bluefinTransactionObj = responseTransactionObj["output_string"] as? Dictionary<String,Any>{
            
            if bluefinTransactionObj.isEmpty{
                return nil
            }
            
            bluefinReqParams.forEach{ key in
                if let responseValue =  bluefinTransactionObj[key]{
                    
                    postObj.addProperty(key, responseValue)
                }
            }
            
            postObj.addProperty("account_id" , bluefinTransactionObj.getString("accountId"))
            postObj.addProperty("custom_id" , bluefinTransactionObj.getString("transactionId"))
            
            postObj.addProperty("transaction_type" , paymentInfo.transactionType)
            postObj.addProperty("tender_type" , "CARD")
            
            if (paymentInfo.transactionType == "SALE" || paymentInfo.transactionType == "CAPTURE"){
                postObj.addProperty("transaction_amount" , paymentInfo.chargeAmount)
            }
            else{
                postObj.addProperty("transaction_amount" , "0.00")
            }
            
            if paymentInfo.token.isNilOrBlank(){
                
                postObj.addProperty("card_number" , paymentInfo.cardNumber)
                postObj.addProperty("card_verification" , paymentInfo.cardCvv )

                //     bluefinTransactionObj.addProperty("exp_month" , paymentInfo.cardExpMonth)
                //    bluefinTransactionObj.addProperty("exp_year" , paymentInfo.cardExpYear)
                
                let expiryDate: String =  (paymentInfo.cardExpMonth ?? "") + ((paymentInfo.cardExpYear ?? "").substring(from: 2))
                postObj.addProperty("card_expiration" , expiryDate )
                var caregiverArr =  paymentInfo.cardHolderName?.components(separatedBy: " ") ?? []
                postObj.addProperty("first_name" , caregiverArr[0].trim())
                
                caregiverArr.remove(at: 0)
                postObj.addProperty("last_name" , caregiverArr.joined(separator: " "))
                
                if let postalAddress = paymentInfo.cardDetails?.postalAddress{
                    postObj.addProperty("street_address1" , postalAddress.line1)
                    postObj.addProperty("street_address2" , postalAddress.line2)
                    postObj.addProperty("city" , postalAddress.city)
                    postObj.addProperty("state" , postalAddress.state)
                    postObj.addProperty("country" ,postalAddress.country)
                    postObj.addProperty("zip" , postalAddress.postalCode)

                }
            }
            else{
                var token = paymentInfo.token?.trim() ?? ""
                            
                while token.count < 12 {
                    token = "0\(token)"
                }
                
                postObj.addProperty("token_id", token)
                postObj.addProperty("reissue", true)
            }
        }
        
       if let cardDetails = paymentInfo.cardDetails {
            if let customDataStr = postObj["custom_data"] as? String {
                
                
                if let customDataObj = customDataStr.convertToDictionary() {
                    var updatedCustomData = Dictionary<String,Any>()
                    customDataObj.keys.forEach({ key in
                        updatedCustomData.addProperty(key, customDataObj[key])
                    })
                    updatedCustomData.addProperty("is_phr_card", cardDetails.isPHRCard)
                    updatedCustomData.addProperty("is_primary_card", cardDetails.isPrimaryCard)
                    updatedCustomData.addProperty("group_id", cardDetails.cardGroupId)
                    
                    updatedCustomData.removeValue(forKey: "invoices")

                    postObj.addProperty("custom_data", updatedCustomData.convertToStringJson())
                    

                }
                
              
            }
        }
        
        if !(paymentInfo.transactionInfo?.statementId.isNilOrBlank() ?? true){
            if let customDataStr = postObj["custom_data"] as? String {
                if let customDataObj = customDataStr.convertToDictionary() {
                    
                    
                    let receiptArr =  customDataObj.getAsJsonArray("receipts") ?? []
                    
                    if receiptArr.isEmpty {
                        return nil
                    }
                    else {
                        let invoicesArr =  receiptArr.firstOrNil()?.getAsJsonArray("invoices") ?? []
                        
                        if invoicesArr.isEmpty {
                            return nil
                        }
                    }
                    
                    var updatedCustomData = Dictionary<String,Any>()
                    customDataObj.keys.forEach({ key in
                        updatedCustomData.addProperty(key, customDataObj[key])
                    })
                    updatedCustomData.addProperty("transaction_amount", postObj.getString("transaction_amount") ?? "")
                    postObj.addProperty("custom_data", updatedCustomData.convertToStringJson())
                }
                
              
            }
        }
        else if !(paymentInfo.transactionInfo?.billId.isNilOrBlank() ?? true){
            if let customDataStr = postObj["custom_data"] as? String {
                if let customDataObj = customDataStr.convertToDictionary() {
                    
                    let invoicesArr =  customDataObj.getAsJsonArray("invoices") ?? []
                    
                    if invoicesArr.isEmpty {
                        return nil
                    }
                    
//                    var updatedCustomData = Dictionary<String,Any>()
//                    customDataObj.keys.forEach({ key in
//                        updatedCustomData.addProperty(key, customDataObj[key])
//                    })
//
//
//                    var invoiceObj = Dictionary<String,Any>()
//
//
//                    invoiceObj.addProperty("BILL_ID", paymentInfo.transactionInfo?.ehrBillId ?? "")
//                    invoiceObj.addProperty("BILL_NUMBER", paymentInfo.transactionInfo?.billNum)
//                    invoiceObj.addProperty("CLEAR_AMOUNT", postObj.getString("transaction_amount") ?? "")
//
//                    updatedCustomData.addProperty("invoices", [invoiceObj])
//
//                    postObj.addProperty("custom_data", updatedCustomData.convertToStringJson())
                }
                
              
            }
        }
        
        return postObj
    }
    
    static func formEditCardObj(paymentGatewayToken: PaymentGatewayToken) -> Dictionary<String,Any>{
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("patient_id", paymentGatewayToken.patientId)
        postObj.addProperty("practice_id", paymentGatewayToken.practiceId)
        postObj.addProperty("token_id", paymentGatewayToken.tokenId)
        postObj.addProperty("is_primary_card", paymentGatewayToken.isPrimaryCard)
        postObj.addProperty("nick_name", paymentGatewayToken.cardNickName)
        
        if let postalAddress = paymentGatewayToken.postalAddress {
            postObj.addProperty("street_address1", postalAddress.line1)
            postObj.addProperty("street_address2", postalAddress.line2)
            postObj.addProperty("city", postalAddress.city)
            postObj.addProperty("state", postalAddress.state)
            postObj.addProperty("country", postalAddress.country)
            postObj.addProperty("zipcode", postalAddress.postalCode)
        }
        
        return postObj
    }
    
    static func formDeleteCardObj(paymentGatewayToken: PaymentGatewayToken) -> Dictionary<String,Any>{
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("patient_id", paymentGatewayToken.patientId)
        postObj.addProperty("practice_id", paymentGatewayToken.practiceId)
        postObj.addProperty("token_id", paymentGatewayToken.tokenId)
        
        return postObj
    }
    
    
    static func createJsonFromProviderForTreatingPhysician(provider : Provider) -> Dictionary<String,Any>
    {
        var json : [String:Any] = [:]
        
        json.updateValue(provider.fullName ?? "", forKey: "Pharmacy_Name")
        json.updateValue("true", forKey: "Health_Passport")
        json.updateValue(Patient.selectedPatientInstance!.patientId!, forKey: "patient_id")
        json.updateValue("Doctor", forKey: "Contact_Type")
        if !isNilOrEmpty(string: provider.phoneNumber)
        {
            json.updateValue(provider.phoneNumber!, forKey: "Mobile")
        }
        
        if !isNilOrEmpty(string: provider.facilityId)
        {
            json.updateValue(provider.facilityId!, forKey: "Pharmacy_Id")
        }
        
        return json
    }
    
    static func formMedicalCondtionObj(medicalCondition : MedicalCondition) -> Dictionary<String,Any>
    {
        
        
        var json : [String:Any] = [:]
        
        json.addProperty("from_date", CharmUtil.getDateStringWith(date: medicalCondition.dateOfOnset, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        json.addProperty("patient_id", getSelectedPatientId())
        json.addProperty("condition_status", medicalCondition.status ?? "")
        
        if isNilOrEmpty(string: medicalCondition.medicalConditionMapId)
        {
            json.addProperty("condition_name", medicalCondition.name ?? "")
            if !isNilOrEmpty(string: medicalCondition.medicalConditionId)
            {
                json.addProperty("condition_id", medicalCondition.medicalConditionId ?? "")
            }
        }else
        {
            json.addProperty("cond_map_id", medicalCondition.medicalConditionMapId ?? "")
        }
        json.addProperty("to_date", CharmUtil.getDateStringWith(date: medicalCondition.resolvedDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        json.addProperty("condition_note", medicalCondition.notes ?? "")
        return json
    }
    
    
    static func formQuestionnaireWidgetDetailObj(physicianTemplates: PhysicianTemplates , questionnaireDetailPOJO: QuestionnaireDetailPOJO) -> Dictionary<String , Any>
    {
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("template_id" , physicianTemplates.templateId)
        postObj.addProperty("patient_id" , physicianTemplates.patientQuesMap?.practicePatientId)
        
        postObj.addProperty("is_submitted" , physicianTemplates.patientQuesMap?.isSubmitted)
        postObj.addProperty("ques_map_id" , physicianTemplates.patientQuesMap?.patientQuesMapId)
        postObj.addProperty("practice_id" , physicianTemplates.practiceId)
        
        questionnaireDetailPOJO.questionnairEntryPOJOList.forEach{ questionnaireEntryPOJO in
            
            if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypePersonalDetails {
                
                if let patient = questionnaireEntryPOJO.questionnairePersonalDetails {
                    var personalObj  : [String:Any] = [:]
                    personalObj.addProperty("PER_FIRST_NAME", patient.firstName)
                    personalObj.addProperty("PER_LAST_NAME", patient.lastName)
                    
                    personalObj.addProperty("DOB", CharmUtil.getDateStringWith(date: patient.dateOfBirth, dateFormat: PHR_DATE_API_FORMAT))
                    
                    personalObj.addProperty("PER_GENDER", patient.gender?.lowercased() ?? "")
                    personalObj.addProperty("PER_GENDER_IDENTITY", patient.genderIdentity)
                    personalObj.addProperty("PER_BLOOD_GROUP", patient.bloodGroup)
                    personalObj.addProperty("PER_RACE", patient.race)
                    personalObj.addProperty("PER_ETHNICITY", patient.ethnicity)
                    personalObj.addProperty("PER_EMP_STATUS", patient.employmentStatus)
                    personalObj.addProperty("PER_MARITAL_STATUS", patient.maritalStatus)
                    personalObj.addProperty("PER_SMOKING_STATUS", patient.smokingStatus)
                    personalObj.addProperty("PER_LANGUAGE", patient.language)
                    
                    postObj.addProperty("personal", personalObj)
                }
            }
            
            if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypePrimaryContactDetail {
                if let patient = questionnaireEntryPOJO.questionnairePatContacts {
                    var patContactObj  : [String:Any] = [:]
                    patContactObj.addProperty("PER_EMERGENCY_CONTACT_NAME", patient.emergencyContactName)
                    patContactObj.addProperty("PER_EMERGENCY_CONTACT_NUMBER", patient.emergencyContactNumber)
                    patContactObj.addProperty("PER_EMERGENCY_EXTN", patient.emergencyContactExtn)
                    
                    if let contactDetails = patient.contactDetail {
                        patContactObj.addProperty("PER_EMAILID", contactDetails.emailId)
                        patContactObj.addProperty("PER_LAND_LINE", contactDetails.homePhone)
                        patContactObj.addProperty("PER_MOBILE", contactDetails.mobile)
                        patContactObj.addProperty("PER_WORKPHONE", contactDetails.workPhone)
                        patContactObj.addProperty("PER_WORKPHONE_EXTN", contactDetails.workPhoneExtn)
                        patContactObj.addProperty("PER_FAX", contactDetails.fax)
                        
                        if (!contactDetails.primaryPhone.isNilOrBlank()){
                            patContactObj.addProperty("PER_CONTACT_PREFERENCE", contactDetails.primaryPhone)
                        }
                        else{
                            patContactObj.addProperty("PER_CONTACT_PREFERENCE", "")
                        }
                        patContactObj.addProperty("PER_CONTACTDETAILS_ID", contactDetails.contactDetailsId)
                    }
                    
                    if let postalAddress = patient.postalAddress {
                        patContactObj.addProperty("PER_ADDRESS_LINE1", postalAddress.line1)
                        patContactObj.addProperty("PER_ADDRESS_LINE2", postalAddress.line2)
                        patContactObj.addProperty("PER_CITY", postalAddress.city)
                        patContactObj.addProperty("PER_STATE", postalAddress.state)
                        patContactObj.addProperty("PER_COUNTRY", postalAddress.country)
                        patContactObj.addProperty("PER_POSTALCODE", postalAddress.postalCode)
                        patContactObj.addProperty("PER_POSTBOX_NO", postalAddress.postbox)
                        patContactObj.addProperty("PER_POSTALADDRESS_ID", postalAddress.postalAddressId)
                    }
                    
                    postObj.addProperty("contact", patContactObj)
                }
            }
            if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeInsurance {
                if let patientInsuranceDetails = questionnaireEntryPOJO.questionnaireInsurance {
                    patientInsuranceDetails.practicePatientId = physicianTemplates.patientQuesMap?.practicePatientId
                    
                    if patientInsuranceDetails.isAvailable {
                        postObj.addProperty("insurance", formAddInsuranceObj(insurance: patientInsuranceDetails, sendType: true))
                    }
                    else{
                        postObj.addProperty("no_insurance", true )
                    }
                }
            }
        }
        return postObj
    }
    
    static func formQuestionnaireDetailAnsObj(physicianTemplates: PhysicianTemplates ,questionnaireDetailPOJO: QuestionnaireDetailPOJO)-> Dictionary<String , Any>?{
        var postObj: [String:Any] = [:]
        
        let isFilled = physicianTemplates.patientQuesMap?.isFilled ?? false
        
        postObj.addProperty("template_id" , physicianTemplates.templateId)
        postObj.addProperty("patient_id" , physicianTemplates.patientQuesMap?.practicePatientId)
        
        postObj.addProperty("is_submitted" , physicianTemplates.patientQuesMap?.isSubmitted)
        postObj.addProperty("ques_map_id" , physicianTemplates.patientQuesMap?.patientQuesMapId)
        
        if !physicianTemplates.isHealthPassport {
            postObj.addProperty("practice_id" , physicianTemplates.practiceId)
            postObj.addProperty("member_id" , physicianTemplates.member?.memberId)
            
        }
        
        var answersArr : [Dictionary<String , Any>] = []
        
        questionnaireDetailPOJO.questionnairEntryPOJOList.forEach{questionnaireEntryPOJO in
            
            let entryId = questionnaireEntryPOJO.questionnaireEntry.entryId
            
            if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeSupplement {
                var answerObj: [String:Any] = [:]
                answerObj.addProperty("entry_id" ,  entryId )
                var supplementArr : [Dictionary<String , Any>] = []
                questionnaireEntryPOJO.questionnaireSupplementList.forEach {intakeQuestSupplementEntry in
                    var supplementObj: [String:Any] = [:]
                    supplementObj.addProperty("supplement" , intakeQuestSupplementEntry.name )
                    supplementObj.addProperty("intake_details" , intakeQuestSupplementEntry.intakeDetails )
                    
                    supplementArr.append(supplementObj)
                }
                
                answerObj.addProperty("supplement_entries" , supplementArr)
                if !supplementArr.isEmpty || isFilled {
                    answersArr.append(answerObj)
                }
            }
            else if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeMedication {
                var answerObj: [String:Any] = [:]
                answerObj.addProperty("entry_id" ,  entryId )
                var medicationArr : [Dictionary<String , Any>] = []
                questionnaireEntryPOJO.questionnaireMedicationList.forEach {intakeQuestMedicationEntry in
                    var medicationObj: [String:Any] = [:]
                    medicationObj.addProperty("medication" , intakeQuestMedicationEntry.name )
                    medicationObj.addProperty("intake_details" , intakeQuestMedicationEntry.intakeDetails )
                    
                    medicationArr.append(medicationObj)
                }
                answerObj.addProperty("nam", questionnaireEntryPOJO.nam)
                
                answerObj.addProperty("medication_entries" , medicationArr)
                if !medicationArr.isEmpty || isFilled {
                    answersArr.append(answerObj)
                }
            }
            else if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeAllergy {
                var answerObj: [String:Any] = [:]
                answerObj.addProperty("entry_id" ,  entryId )
                var allergyArr : [Dictionary<String , Any>] = []
                questionnaireEntryPOJO.questionnaireAllergyList.forEach {intakeQuestAllergyEntry in
                    var allergyObj: [String:Any] = [:]
                    allergyObj.addProperty("allergen" , intakeQuestAllergyEntry.allergen )
                    allergyObj.addProperty("type" , intakeQuestAllergyEntry.type?.rawValue)
                    allergyObj.addProperty("severity" , intakeQuestAllergyEntry.severity?.rawValue)
                    allergyObj.addProperty("reactions" , intakeQuestAllergyEntry.reactions )
                    
                    allergyArr.append(allergyObj)
                }
                answerObj.addProperty("nkda", questionnaireEntryPOJO.nkda)
                answerObj.addProperty("nkfa", questionnaireEntryPOJO.nkfa)
                answerObj.addProperty("nkea", questionnaireEntryPOJO.nkea)
                
                answerObj.addProperty("allergy_entries" , allergyArr)
                if !allergyArr.isEmpty || isFilled {
                    answersArr.append(answerObj)
                }
            }
            else if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeSignature {}
            else if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypePersonalDetails {}
            else if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypePrimaryContactDetail {}
            else if questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeInsurance {}
            else if questionnaireSOAPTypeList.contains(questionnaireEntryPOJO.questionnaireEntry.notesType ?? ""){
                
                var answerObj = Dictionary<String,Any>()
                answerObj.addProperty("entry_id", entryId)
                
                if let soapWidget = questionnaireEntryPOJO.soapWidget{
                    
                    var soapEntryDict = Dictionary<String,Any>()
                    soapEntryDict.addProperty("soap_widget_id", soapWidget.widgetId)
                    soapEntryDict.addProperty("soap_template_id", soapWidget.templateId)
                    
                    var entryArr:[Dictionary<String,Any>] = []
                    
                    soapWidget.widgetEntries.forEach({ widgetEntry in
                        
                        let answer = widgetEntry.questionnaireSOAPEntry?.value ?? ""
                        
                        var widgetObj = Dictionary<String,Any>()
                        widgetObj.addProperty("soap_entry_id", widgetEntry.entryId)
                        widgetObj.addProperty("soap_entry_value", answer)
                        entryArr.append(widgetObj)
                    })
                    soapEntryDict.addProperty("soap_widget_answers", entryArr)
                    answerObj.addProperty("soap_entries", soapEntryDict)
                }
                answersArr.append(answerObj)
            }
            else if questionnaireEntryPOJO.questionnaireEntry.isMultiChoice {
                var multipleAnsObj: [String:Any] = [:]
                multipleAnsObj.addProperty("entry_id" ,  entryId )
                var multipleAnsArr: [Dictionary<String ,Any>] = []
                
                questionnaireEntryPOJO.questionnaireEntry.answersList?.forEach{ answer in
                    var answerObj : [String:Any] = [:]
                    answerObj.addProperty("answer" , answer)
                    multipleAnsArr.append(answerObj)
                }
                
                multipleAnsObj.addProperty("multiple_answers" , multipleAnsArr)
                answersArr.append(multipleAnsObj)
            }
            else {
                let answer = questionnaireEntryPOJO.questionnaireEntry.answersList?.firstOrNil() ?? ""
                var answerObj : [String:Any] = [:]
                answerObj.addProperty("entry_id" ,  entryId )
                answerObj.addProperty("answer", answer)
                if (questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeYesOrNoOption || questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeDate || questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeRatingScale){
                    if answer.isNotBlank(){
                        answersArr.append(answerObj)
                    }
                }
                else{
                    answersArr.append(answerObj)
                }
            }
        }
        postObj.addProperty("answers", answersArr)
        
        return postObj
    }
    
    //MARK: -Insurance
    
    static func formAddInsuranceObj(insurance: PatientInsuranceDetails, sendType: Bool = false) -> Dictionary<String,Any> {
        var postObj : [String:Any] = [:]
        
        if let insuredId = insurance.patientInsuranceDetailsId{
            if insuredId.isNotBlank(){
                postObj.addProperty("INSURED_ID" , insuredId)
            }
        }
        if sendType {
            postObj.addProperty("TYPE" , insurance.type)
        }
        else{
            postObj.addProperty("IS_PRIMARY" , insurance.isPrimary)
            postObj.addProperty("practice_id" , insurance.practiceId)
        }
        
        postObj.addProperty("INSURANCE_TYPE" , insurance.insurancePlanType ?? "")
        postObj.addProperty("PLAN_NAME" , insurance.insurancePlanName ?? "")
        postObj.addProperty("ID_NUMBER" , insurance.policyNumber ?? "")
        postObj.addProperty("from_date" ,  CharmUtil.getDateStringWith(date: insurance.policyStartDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)  )
        postObj.addProperty("to_date" ,  CharmUtil.getDateStringWith(date: insurance.policyEndDate, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)  )
        postObj.addProperty("POLICY_GROUP_NUMBER" , insurance.groupNumber ?? "")
        postObj.addProperty("COPAY" , insurance.copay ?? "")
        postObj.addProperty("DEDUCTABLE" , insurance.deductable ?? "")
        postObj.addProperty("COMMENT" , insurance.comment ?? "")
        
        if let payer = insurance.practicePayer {
            postObj.addProperty("COMPANY_NAME" , payer.payerName ?? "")
            postObj.addProperty("COMPANY_CODE" , payer.payerId ?? "")
            
            if let payerAddress = payer.postalAddress {
                postObj.addProperty("PAYER_ADDR_LIINE1" , payerAddress.line1 ?? "")
                postObj.addProperty("PAYER_CITY" , payerAddress.city ?? "")
                postObj.addProperty("PAYERCOUNTRY" , payerAddress.country ?? "")
                postObj.addProperty("PAYERSTATE" , payerAddress.state ?? "")
                postObj.addProperty("PAYERZIP" , payerAddress.postalCode ?? "")
            }
        }
        
        if let insuredAndGuarantorDetails = insurance.insuredAndGuarantorDetails {
            postObj.addProperty("RELATIONSHIP" , insuredAndGuarantorDetails.relationship ?? "")
            postObj.addProperty("FIRST_NAME" , insuredAndGuarantorDetails.firstName ?? "")
            postObj.addProperty("LAST_NAME" , insuredAndGuarantorDetails.lastName ?? "")
            postObj.addProperty("GENDER" , insuredAndGuarantorDetails.gender?.lowercased() ?? "")
            postObj.addProperty("birth_date" ,  CharmUtil.getDateStringWith(date: insuredAndGuarantorDetails.dateOfBirth, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)  )
            
            if let address = insuredAndGuarantorDetails.postalAddress {
                postObj.addProperty("LINE_1" , address.line1 ?? "")
                postObj.addProperty("LINE_2" , address.line2 ?? "")
                postObj.addProperty("COUNTRY" , address.country ?? "")
                postObj.addProperty("STATE" , address.state ?? "")
                postObj.addProperty("CITY" , address.city ?? "")
                postObj.addProperty("POSTALCODE" , address.postalCode ?? "")
            }
            
            if let contact = insuredAndGuarantorDetails.contactDetails {
                postObj.addProperty("LANDLINE" , contact.homePhone ?? "")
                postObj.addProperty("MOBILE" , contact.mobile ?? "")
            }
            
            if let insuredEmployerDetails = insuredAndGuarantorDetails.insuredEmployerDetails {
                postObj.addProperty("EMPLOYER_NAME" , insuredEmployerDetails.name ?? "")
            }
        }
        return postObj
    }
    
    static func formDeleteInsuranceObj(insurance: PatientInsuranceDetails ) -> Dictionary<String,Any> {
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("insured_id" , insurance.patientInsuranceDetailsId ?? "")
        postObj.addProperty("patient_id" , insurance.practicePatientId ?? "")
        
        return postObj
    }
    
    static func formInsuranceCardObj(insuranceCard: InsuranceCard) -> Dictionary<String,Any> {
        var postObj : [String:Any] = [:]

        postObj.addProperty("type" , insuranceCard.type ?? "")
        postObj.addProperty("practice_id" , insuranceCard.practiceId ?? "")

        if let cardData = insuranceCard.cardData {
            postObj.addProperty(insuranceCard.fileName ?? "", cardData)
        }
        return postObj
    }
    
    
    static func formSavePatientObj(demographics : Patient ) -> Dictionary<String,Any>
    {
        var json : [String:Any] = [:]
        
        json.updateValue("true", forKey: "Health_Passport")
        json.updateValue(demographics.firstName ?? "", forKey: "first_name")
        json.updateValue(demographics.lastName ?? "", forKey: "last_name")
        json.updateValue(demographics.gender.lowercased() , forKey: "gender")
        json.updateValue(demographics.bloodGroup ?? "", forKey: "blood_group")
        if demographics.dateOfBirth != nil
        {
            json.updateValue(CharmUtil.getDateStringWith(date: demographics.dateOfBirth, dateFormat: "yyyy"), forKey: "year")
            json.updateValue(CharmUtil.getDateStringWith(date: demographics.dateOfBirth, dateFormat: "M"), forKey: "month")
            json.updateValue(CharmUtil.getDateStringWith(date: demographics.dateOfBirth, dateFormat: "dd"), forKey: "date")
        }
        
        
        if let postalAddress = demographics.postalAddress  {
            json.updateValue(postalAddress.line1 ?? "", forKey: "line_1")
            json.updateValue(postalAddress.line2 ?? "", forKey: "line_2")
            json.updateValue(postalAddress.state ?? "", forKey: "state")
            json.updateValue(postalAddress.country ?? "", forKey: "country")
            json.updateValue(postalAddress.city ?? "", forKey: "city")
            json.updateValue(postalAddress.postalCode ?? "", forKey: "postalcode")
            
        }
        
        
        var contactJson : [String:Any] = [:]
        contactJson.updateValue(demographics.primaryCaregiver?.firstName ?? "", forKey: "first_name")
        contactJson.updateValue(demographics.primaryCaregiver?.lastName ?? "", forKey: "last_name")
        contactJson.updateValue(demographics.primaryCaregiver?.mobile ?? "", forKey: "mobile")
        contactJson.updateValue(demographics.primaryCaregiver?.contactType ?? "", forKey: "contact_type")
        json.updateValue([contactJson], forKey: "contacts")
        
        
        json.updateValue(demographics.contactDetail?.landline ?? "", forKey: "acc_landline")
        json.updateValue(demographics.contactDetail?.mobile ?? "", forKey: "acc_mobile")
        
        json.updateValue(demographics.emergencyContactName ?? "", forKey: "emergency_contact_name")
        json.updateValue(demographics.emergencyContactNumber ?? "", forKey: "emergency_contact_number")
   //     json.updateValue(demographics.patientId ?? "", forKey: "patient_id")
        
        
        return json
    }
    
    //MARK: - Flowsheet
    
    
    static func formFlowsheetEntryObj(phrFlowsheets: PHRFlowsheets)-> Dictionary<String,Any>{
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("flowsheet_id" , phrFlowsheets.flowSheetId)
        
        if let date = phrFlowsheets.date {
            postObj.addProperty("date", CharmUtil.getDateStringWith(date: date, dateFormat: sqlTimeStampFormat))
        }
        
        var entryArr : [Dictionary<String,Any>] = []
        
        phrFlowsheets.flowsheetEntries.filter{entry in
            !entry.value.isNilOrBlank()
        }.forEach{phrFlowsheetEntry in
            var entryObj: [String:Any] = [:]
            entryObj.addProperty("value" , phrFlowsheetEntry.value)
            entryObj.addProperty("unit" , phrFlowsheetEntry.unit)
            entryObj.addProperty("flowsheet_entry_id" , phrFlowsheetEntry.flowSheetEntryId)
            if (!phrFlowsheetEntry.comments.isNilOrBlank()){
                entryObj.addProperty("comments" , phrFlowsheetEntry.comments)
            }
            entryArr.append(entryObj)
        }
        postObj.addProperty("flowsheet_entries" , entryArr)
        
        return postObj
    }
    
    //MARK: - Support
    
    static func formSupportObj(supportDetails: SupportDetails) -> Dictionary<String, Any>{
        
        var postObj: [String: Any] = [:]
        postObj.addProperty("subject", supportDetails.subject)
        postObj.addProperty("msg_content", supportDetails.messageContent)
        postObj.addProperty("category", supportDetails.category)
        let fileIdString = supportDetails.fileIds.joined(separator: ",")
        postObj.addProperty("file_ids",fileIdString )
        postObj.addProperty("msg_content_type", supportDetails.messageContentType)
        postObj.addProperty("is_mobile", "true")
        
        return postObj
    }
    
    //MARK: - Share Documents
    
    static func formShareDocumentToOthersObj(documentList: [Document], contactList: [Pharmacy], expiryDate: Date) -> Dictionary <String, Any> {
        var postObj: [String: Any] = [:]
        
        var documentIdArr: [String] = []
        for document in documentList{
            if !document.fileId.isNilOrBlank(){
                documentIdArr.append(document.fileId!)
            }
        }
        postObj.addProperty("Document_id", documentIdArr)
        
        var pharmacyArr: [String] = []
        contactList.forEach({obj in
            pharmacyArr.append(obj.patientPharmaMapId ?? "")
        })
        postObj.addProperty("Pharmacy_id", pharmacyArr)
        postObj.addProperty("expiry", expiryDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        postObj.addProperty("access_limit", "-1")
        
        return postObj
    }
    
    static func formShareDocumentToMembersObj(documentList: [Document], memberList: [Provider]) -> Dictionary <String, Any>{
        var postObj: [String: Any] = [:]
        
        var documentIdArr: [String] = []
        for document in documentList{
            if !document.fileId.isNilOrBlank(){
                documentIdArr.append(document.fileId!)
            }
        }
        
        postObj.addProperty("document_list", documentIdArr)

        var toListArr: [[String: Any]] = []
        var practiceIdList: [String] = []
        
        memberList.forEach({memberObj in
            practiceIdList.append(memberObj.practiceId ?? "")
        })
        
        let duplicateRemovedPracticeIdList: [String] = practiceIdList.removeDuplicateElements()
        var practiceToProviderMap: [String: Any] = [:]
        
        for practiceId in duplicateRemovedPracticeIdList {
            var memberIdArray: [String] = []
            for memberObj in memberList{
                if practiceId == memberObj.practiceId{
                    memberIdArray.append(memberObj.memberId ?? "")
                    practiceToProviderMap[practiceId] = memberIdArray
                }
            }
        }

        for practiceID in duplicateRemovedPracticeIdList {
            
            var toListObj: [String: Any] = [:]
            toListObj.addProperty("practice_id", practiceID)
            toListObj.addProperty("members_to_notify", practiceToProviderMap[practiceID])
            
            toListArr.append(toListObj)
        }
        postObj.addProperty("to_list", toListArr)
        
        return postObj
    }
    
    static func formContactObjList(pharmacyList: [Pharmacy]) -> Dictionary <String, Any>{

        var postObj: [String: Any] = [:]
        var contactArr: [[String: Any]] = []

        pharmacyList.forEach({pharmacy in
            
            var contactObj: [String: Any] = [:]
            contactObj.addProperty("Contact_Type", "Other")
            contactObj.addProperty("EmailID", pharmacy.contactDetails?.emailId)
            contactObj.addProperty("Pharmacy_Name", pharmacy.pharmacyName)
            //contactObj.addProperty("patient_id", pharmacy.patientId)
            contactArr.append(contactObj)
        })
        postObj.addProperty("contacts", contactArr)

        return postObj
    }
    //MARK: - Reminder
    static func formReminderJson(reminderObj: Reminder) -> [String: Any]{
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("start_date", reminderObj.startDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        if let practiceId = reminderObj.practiceId{
            postObj.addProperty("practice_id", practiceId)
        }
        
        var frequencyObj: [String:Any] = [:]
        frequencyObj.addProperty("frequency_value", reminderObj.frequency?.toIntOrNil() ?? 0)
        
        if let frequencyUnit = reminderObj.frequencyUnit{
            frequencyObj.addProperty("frequency_unit", frequencyUnit)
        }
        else{
            frequencyObj.addProperty("frequency_unit", nil, isAllowNil: true)
        }
        var durationArr: [[String:Any]] = []
        var timeArray: [String] = []
        var reminderFrequencyMap: [String: [String]] = [:]
        reminderObj.reminderFrequencyArray.forEach { reminderFrequencyObj in
            if !timeArray.contains(where: { timeObj in
                return reminderFrequencyObj.time == timeObj
            }){
                timeArray.append(reminderFrequencyObj.time ?? "")
            }
            
            if reminderFrequencyMap.contains(where: { (key: String, value: [String]) in
                return key == reminderFrequencyObj.day
            }){
                reminderFrequencyMap.updateValue(timeArray, forKey: reminderFrequencyObj.day ?? "")
            }
            else{
                reminderFrequencyMap[reminderFrequencyObj.day ?? ""] = timeArray
            }
        }
        
        reminderFrequencyMap.forEach { (key: String, value: [String]) in
            var durationDict: [String: Any] = [:]
            if key == "-1"{
                durationDict.addProperty("day", "not_configured")
            }
            else{
                durationDict.addProperty("day", key)
            }
            
            durationDict.addProperty("time", value)
            durationArr.append(durationDict)
        }
        
        frequencyObj.addProperty("duration", durationArr)
        postObj.addProperty("frequency", frequencyObj)
        if (reminderObj.endDate != nil) {
            postObj.addProperty("end_date", reminderObj.endDate?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        }
        else{
            postObj.addProperty("end_date", nil)
        }
        postObj.addProperty("module_id", reminderObj.moduleId)
        postObj.addProperty("type", reminderObj.reminderType)
        
        return postObj
    }
    
    static func formAddReminderHistoryJson(reminderHistory: ReminderHistory) -> [String:Any]{
        var postObj : [String:Any] = [:]
        
        if let reminderObj = ReminderHandler.getReminderObj(reminderId: reminderHistory.reminderId, patientId: reminderHistory.patientId){
            postObj.addProperty("module_id", reminderObj.moduleId)
            postObj.addProperty("type", reminderObj.reminderType)
        }
        
        postObj.addProperty("status", reminderHistory.status)
        postObj.addProperty("status_updated_time", reminderHistory.statusUpdatedTime?.getStringFromDate(dateFormat: Time24HoursFormat))
        postObj.addProperty("status_updated_date", reminderHistory.statusUpdatedTime?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        
        if let reminderFrequency = reminderHistory.reminderFrequency{
            postObj.addProperty("reminder_time", reminderFrequency.time)
            postObj.addProperty("frequency_id", reminderFrequency.frequencyMapId)
        }
        return postObj
    }
    
    static func formUpdateReminderHistoryJson(reminderHistory: ReminderHistory) -> [String: Any]{
        var postObj : [String:Any] = [:]
        
        postObj.addProperty("status", reminderHistory.status)
        postObj.addProperty("status_updated_time", reminderHistory.statusUpdatedTime?.getStringFromDate(dateFormat: Time24HoursFormat))
        postObj.addProperty("status_updated_date", reminderHistory.statusUpdatedTime?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))
        
        return postObj
    }
    
    //MARK: - Push notification
    
    static func formPushNotificationObj(pushNotificationDetailsPOJO: PushNotificationDetailsPOJO) -> Dictionary<String, Any>{
        
        var postObj: [String: Any] = [:]
        postObj.addProperty("nfid", pushNotificationDetailsPOJO.nfid)
        postObj.addProperty("installation_id", pushNotificationDetailsPOJO.insid)
        postObj.addProperty("os_info", pushNotificationDetailsPOJO.osInfo)
        postObj.addProperty("device_info",pushNotificationDetailsPOJO.deviceInfo )
        postObj.addProperty("apns_mode", pushNotificationDetailsPOJO.apnsMode)
        postObj.addProperty("app_version", pushNotificationDetailsPOJO.appVersion)
        postObj.addProperty("device_uid", pushNotificationDetailsPOJO.deviceuid)
        postObj.addProperty("mode", pushNotificationDetailsPOJO.mode)
        return postObj
    }
    
    //MARK: - ShareSection
    
    static func formShareSectionObj(shareSection: ShareSection) -> [String: Any]{
        var postObj: [String: Any] = [:]
        
        postObj.addProperty("practice_id", shareSection.practiceId)
        postObj.addProperty("sections", shareSection.sectionsList)
        
        return postObj
    }
    
}
