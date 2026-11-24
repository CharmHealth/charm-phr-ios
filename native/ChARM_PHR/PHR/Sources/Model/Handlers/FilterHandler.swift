//
//  FilterHandler.swift
//  phr
//
//  Created by Sankar Saravanan on 28/01/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import Foundation

class FilterHandler {

//MARK: - Appointments
    
    static func filterAndSortAppointents( arrayOfAppointment : [Appointment]) -> [Appointment]
    {
        var filteredArr : [Appointment] = arrayOfAppointment
        filteredArr = filteredArr.sorted(by: {
            let appointmentDate0 = $0.appointmentDate
            let appointmentDate1 = $1.appointmentDate
            if let appointmentDate0 = appointmentDate0, let appointmentDate1 = appointmentDate1{
                return appointmentDate0 > appointmentDate1
            }
            return false
        })
        return filteredArr
    }
    
//MARK: - Messages
    
    static func sortMessages( arrayOfMessages : [Messages]) -> [Messages]
    {
        var filteredArr : [Messages] = arrayOfMessages
        filteredArr.sort(by: { (message1, message2) -> Bool in
            
            let dateObj1 = message1.messageDate
            let dateObj2 = message2.messageDate
            
            if let dateObj1 = dateObj1, let dateObj2 = dateObj2{
                return dateObj1 > dateObj2
            }
            return false
        })
        return filteredArr
    }
    
    static func filterMessages(arrayOfMessages : [Messages]) -> [Messages]{
        var filteredArr : [Messages] = []
        for message in arrayOfMessages
        {
            if !filteredArr.contains(where: { filteredObj in
                return filteredObj.messageId == message.messageId
            }){
                filteredArr.append(message)
            }
        }
        return filteredArr
    }
    //MARK: - Medical Conditions
    
    
        static func filterAndSortConditions(conditionList : [MedicalCondition]) -> [MedicalCondition]
        {
            // this checks are done for fliter muliti parctice duplicate records
            var filteredArr : [MedicalCondition] = []
            for condition in conditionList
            {
                if !condition.allowEdit{
                    filteredArr.append(condition)
                }
                else{
                    if !filteredArr.contains(where: { filteredObj in
                        return filteredObj.allowEdit && filteredObj.medicalConditionId == condition.medicalConditionId
                    }){
                        filteredArr.append(condition)
                    }
                }
            }
            //Sort by start date

            filteredArr = sortConditions(conditionList: filteredArr)
                
            return filteredArr
        }
        
        static private func sortConditions(conditionList : [MedicalCondition]) -> [MedicalCondition]{
            var filteredArr : [MedicalCondition] = conditionList
            
            filteredArr = filteredArr.sorted(by: {
                let fromDate0 = $0.dateOfOnset
                let fromDate1 = $1.dateOfOnset
                
                if let fromDate0 = fromDate0, let fromDate1 = fromDate1{
                    return fromDate0 > fromDate1
                }
                return false
            })
                
            return filteredArr
        }
        
    
//MARK: - Medications
    
    static func filterAndSortMedication(arrayOfMedicationPOJO : [MedicationPOJO]) -> [MedicationPOJO]
    {
        // this checks are done for fliter muliti parctice duplicate records
        var filteredArr : [MedicationPOJO] = []
        for medicationPOJO in arrayOfMedicationPOJO
        {
            if medicationPOJO.patientMedication?.addedByPatient == false{
                filteredArr.append(medicationPOJO)
            }
            else{
                if !filteredArr.contains(where: { filteredObj in
                    return filteredObj.patientMedication?.patientMedicationId == medicationPOJO.patientMedication?.patientMedicationId
                }){
                    filteredArr.append(medicationPOJO)
                }
            }
        }
        //Sort by start date

        filteredArr = sortMedication(arrayOfMedicationPOJO: filteredArr)
            
        return filteredArr
    }
    
    static private func sortMedication(arrayOfMedicationPOJO : [MedicationPOJO]) -> [MedicationPOJO]{
        var filteredArr : [MedicationPOJO] = arrayOfMedicationPOJO
        
        filteredArr = filteredArr.sorted(by: {
            let fromDate0 = $0.patientMedication?.fromDate
            let fromDate1 = $1.patientMedication?.fromDate
            
            if let fromDate0 = fromDate0, let fromDate1 = fromDate1{
                return fromDate0 > fromDate1
            }
            return false
        })
            
        return filteredArr
    }
    
//MARK: - Supplement
    
    static func filterAndSortSupplement(arrayOfSupplemenPOJO : [SupplementPOJO]) -> [SupplementPOJO]
    {
        // this checks are done for fliter muliti parctice duplicate records
        var filteredArr : [SupplementPOJO] = []
        for supplementPOJO in arrayOfSupplemenPOJO
        {
            
            if supplementPOJO.patientSupplement?.isAddedByPatient == false{
                filteredArr.append(supplementPOJO)
            }
            else{
                if !filteredArr.contains(where: { filteredObj in
                    return filteredObj.patientSupplement?.patientSupplementId == supplementPOJO.patientSupplement?.patientSupplementId
                }){
                    filteredArr.append(supplementPOJO)
                }
            }
        }
              
        //Sort by start date

        filteredArr = sortSupplement(arrayOfSupplemenPOJO: filteredArr)
            
        return filteredArr
    }
    
    static private func sortSupplement(arrayOfSupplemenPOJO : [SupplementPOJO]) -> [SupplementPOJO]{
        var filteredArr : [SupplementPOJO] = arrayOfSupplemenPOJO
        
        filteredArr = filteredArr.sorted(by: {
            let fromDate0 = $0.patientSupplement?.fromDate
            let fromDate1 = $1.patientSupplement?.fromDate
            
            if let fromDate0 = fromDate0, let fromDate1 = fromDate1{
                return fromDate0 > fromDate1
            }
            return false
        })
            
        return filteredArr
    }
    
//MARK: - Allergies
    
    static func filterAndSortAllergies( arrayOfAllergies : [AllergiesList]) -> [AllergiesList]
    {
        // this checks are done for fliter muliti parctice duplicate records
        var filteredArr : [AllergiesList] = []
        for allergies in arrayOfAllergies
        {
            if (filteredArr.firstIndex(where: { (objectAtIndex) -> Bool in
                if allergies.patientAllergyMap?.isAddedByPatient == true
                {
                    if objectAtIndex.allergyId != allergies.allergyId
                    {
                        return false
                    }
                    else
                    {
                        return true
                    }
                }
                return false
            }) == nil)
            {
                filteredArr.append(allergies)
            }
        }
        
        filteredArr = filteredArr.sorted(by: {
            let observedDate0 = $0.patientAllergyMap?.observedDate
            let observedDate1 = $1.patientAllergyMap?.observedDate
            
            if let observedDate0 = observedDate0, let observedDate1 = observedDate1{
                return observedDate0 > observedDate1
            }
            return false
        })
        
        return filteredArr
    }
    
//MARK: - Lab results
    
    static func filterAndSortLabResults( arrayOfResults : [MedicalRecordGroup]) -> [MedicalRecordGroup]
    {
        var filteredArr : [MedicalRecordGroup] = arrayOfResults
        filteredArr = filteredArr.sorted(by: {
            let date0 = $0.medicalRecordEntryList[0].date
            let date1 = $1.medicalRecordEntryList[0].date
            
            if let date0 = date0, let date1 = date1{
                return date0 > date1
            }
            return false
        })
        return filteredArr
    }
    
//MARK: - Images
    
    static func sortImagesResults(arrayOfResults: [ImagesResult]) -> [ImagesResult] {
        
        var filteredArr: [ImagesResult] = arrayOfResults
        filteredArr = filteredArr.sorted(by: {
            if let date0 = $0.date, let date1 = $1.date{
                return date0 > date1
            }
            return false
        })
        return filteredArr
    }
    
//MARK: - Visit Summary
    
    static func filterAndSortVisitSummary( arrayOfVisitSummary : [PatientEncounterList]) -> [PatientEncounterList]
    {
        var filteredArr : [PatientEncounterList] = arrayOfVisitSummary
        filteredArr = filteredArr.sorted(by: {
            let date0 = $0.date
            let date1 = $1.date
            
            if let date0 = date0, let date1 = date1{
                return date0 > date1
            }
            return false
        })
        return filteredArr
    }
    
//MARK: - Vaccine
    
    static func filterAndSortVaccine( arrayOfVaccine : [VaccineImmunizationPOJO]) -> [VaccineImmunizationPOJO]
    {
        // this checks are done for fliter muliti parctice duplicate records
              
        let filteredArr = arrayOfVaccine.sorted(by: {
            
            var firstDate: Date? = nil
            var secondDate: Date? = nil
            
            if $0.addedByPatient {
                firstDate = $0.patientImmunizationMap?.patientImmunizationHistory?.vaccinesOn
            }
            else{
                firstDate = $0.patientVaccineMap?.dateOfVaccination
            }
            
            if $1.addedByPatient {
                secondDate = $1.patientImmunizationMap?.patientImmunizationHistory?.vaccinesOn
            }
            else{
                secondDate = $1.patientVaccineMap?.dateOfVaccination
            }
            
            if let firstDate = firstDate, let secondDate = secondDate{
                return firstDate > secondDate
            }
            return false
        })
        
        return filteredArr
    }
    
//MARK: - Receipts
    
    static func sortReceipts(arrayOfReceipts: [PHRReceipts]) -> [PHRReceipts]{
        var filteredArr : [PHRReceipts] = arrayOfReceipts
        
        filteredArr.sort(by: {
            
            let receiptDate0 = $0.receiptDate
            let receiptDate1 = $1.receiptDate
            
            if let receiptDate0 = receiptDate0, let receiptDate1 = receiptDate1{
                return receiptDate0 > receiptDate1
            }
            return false
        })
        
        return filteredArr
    }
    
//MARK: - Bills
        
    static func sortBills(arrayOfBills: [PHRBills]) -> [PHRBills]{
        var filteredArr : [PHRBills] = arrayOfBills
        
        filteredArr.sort(by: {
            
            let billDate0 = $0.billDate
            let billDate1 = $1.billDate
            
            if let billDate0 = billDate0, let billDate1 = billDate1{
                return billDate0 > billDate1
            }
            return false
        })
        
        return filteredArr
    }

//MARK: - Reminder
    
    static func sortReminder(arrayOfReminder: [ReminderPOJO]) -> [ReminderPOJO]{
        
        var filteredArr : [ReminderPOJO] = arrayOfReminder
        
        filteredArr.sort { reminder0, reminder1 in
            
            let startDate0 = reminder0.reminderDetails?.reminder?.startDate
            let startDate1 = reminder1.reminderDetails?.reminder?.startDate
            
            if let startDate0 = startDate0, let startDate1 = startDate1{
                return startDate0 > startDate1
            }
            return false
        }
        return filteredArr
    }
    
    static func sortTodayReminder(arrayOfTodayReminder: [TodayReminderPOJO]) -> [TodayReminderPOJO]{
        
        var filteredArr : [TodayReminderPOJO] = arrayOfTodayReminder
        
        filteredArr.sort { todayReminder0, todayReminder1 in
            
            let time0 = todayReminder0.time
            let time1 = todayReminder1.time
            
            if let time0 = time0, let time1 = time1{
                return time0 < time1
            }
            return false
        }
        return filteredArr
    }
}
