//
//  ReminderHandler.swift
//  phr
//
//  Created by prathi-13964 on 24/05/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import CoreData


class ReminderHandler: NSObject, CharmConnectionV2HandlerDelegate{
    
    private static var reminderHandler: ReminderHandler!
    static var sharedInstance: ReminderHandler {
        if reminderHandler == nil {
            reminderHandler = ReminderHandler()
        }
        return reminderHandler
    }
    private var charmConnectionHandler : CharmConnectionHandler? = nil
    
    func fetchReminderList(){
        
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        
        ///We are fetching only reminder to update because if the medication or supplement is deleted, the assosiated reminder will alse gets deleted automatically
        Patient.patientList?.forEach { patientObj in
            charmConnectionHandler?.fetchReminderList(identificationKey: "fetchReminder_\(patientObj.patientId ?? "")", patientId: patientObj.patientId)
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey.hasPrefix("fetchReminder"){
            if let reminderList = response as? [Reminder], let patientId = identificationKey.components(separatedBy: "_").last{
                ReminderHandler.addOrUpdateReminderToDB(reminderArray: reminderList, patientId: patientId)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
    }
    
//MARK: - Reminder add, update and delete
    
    static func addOrUpdateNotificationForReminder(reminderArray: [Reminder], patientId: String?){
        reminderArray.forEach({ reminderObj in
            if let reminderMObj = getReminderObj(reminderId: reminderObj.reminderId, patientId: patientId){
                if reminderObj.isReminderDeleted{
                    deleteNotification(reminderObj: reminderObj)
                }
                else{
                    if reminderMObj.modifiedTime != nil{
                        if reminderObj.modifiedTime != reminderMObj.modifiedTime{
                            updateNotification(reminderObj: reminderObj)
                        }
                    }
                }
            }
            else{
                if !reminderObj.isReminderDeleted{
                    addNotification(reminderObj: reminderObj)
                }
            }
            if let patientMObj = PatientDataHandler.getPatient(patientId: patientId), let arrayOfMedication = patientMObj.medicationPOJOArr, let arrayOfSupplement = patientMObj.supplementPOJOArr{
                
                if reminderObj.reminderType == MEDICATION{
                    if !arrayOfMedication.contains(where: { medicationPOJO in
                        
                        if let patientMedication = medicationPOJO.patientMedication{
                            if patientMedication.addedByPatient{
                                return medicationPOJO.patientMedication?.patientMedicationId == reminderObj.moduleId
                            }
                            else{
                                return medicationPOJO.patientMedication?.patientMedicationId == reminderObj.moduleId && patientMedication.isActive
                            }
                        }
                        return false
                    }){
                        deleteReminderAndNotification(reminderObj: reminderObj)
                    }
                }
                else{
                    if !arrayOfSupplement.contains(where: { supplementPOJO in
                        if let patientSupplement = supplementPOJO.patientSupplement{
                            if patientSupplement.isAddedByPatient{
                                return patientSupplement.patientSupplementId == reminderObj.moduleId
                            }
                            else{
                                return patientSupplement.patientSupplementId == reminderObj.moduleId && patientSupplement.isActive
                            }
                        }
                        return false
                        
                    }){
                        deleteReminderAndNotification(reminderObj: reminderObj)
                    }
                }
            }
        })
    }
    
    static func addOrUpdateReminderToDB(reminderArray: [Reminder], patientId: String?){
        
        addOrUpdateNotificationForReminder(reminderArray: reminderArray, patientId: patientId)
        
        var reminderList: [Reminder] = []
        
        reminderArray.forEach({ reminderObj in
            if reminderObj.isReminderDeleted == false{
                reminderList.append(reminderObj)
            }
        })
        
        if let patientMObj = PatientDataHandler.getPatient(patientId: patientId){
            patientMObj.reminderArr = reminderList
            mPHRCoreDataUtil.sharedInstance.updatePatient(patientMObj: patientMObj)
        }
    }
    
    static private func addNotification(reminderObj: Reminder){
        LocalNotificationUtil.sharedInstance.addOrUpdateNotification(reminderObj: reminderObj)
    }
    
    static private func updateNotification(reminderObj: Reminder){
        deleteNotification(reminderObj: reminderObj)
        addNotification(reminderObj: reminderObj)
    }
    
    static private func deleteNotification(reminderObj: Reminder){
        LocalNotificationUtil.sharedInstance.removeReminderNotification(reminderObj: reminderObj)
    }
    
    static func addReminderAndNotification(reminderObj: Reminder){
        
        let coreDataUtil = mPHRCoreDataUtil.sharedInstance
        
        if let patientMObj = PatientDataHandler.getPatient(patientId: reminderObj.patientId){
            
            var reminderArr: [Reminder] = []
            
            if var reminderList = patientMObj.reminderArr{
                reminderList.append(reminderObj)
                reminderArr = reminderList
            }
            else{
                reminderArr.append(reminderObj)
            }
            patientMObj.reminderArr = reminderArr
            
            coreDataUtil.updatePatient(patientMObj: patientMObj)
            addNotification(reminderObj: reminderObj)
        }
    }
    
    static func updateReminderAndNotification(reminderObj: Reminder)
    {
        deleteReminderAndNotification(reminderObj: reminderObj)
        addReminderAndNotification(reminderObj: reminderObj)
    }
    
    static func deleteReminderAndNotification(reminderObj: Reminder){
       
        deleteNotification(reminderObj: reminderObj)
        deleteReminder(reminderObj: reminderObj)
    }
    
    static private func deleteReminder(reminderObj: Reminder){
        if let patientMObj = PatientDataHandler.getPatient(patientId: reminderObj.patientId), var reminderList = patientMObj.reminderArr{
            if let index = reminderList.firstIndex(where: { reminder in
                return reminder.reminderId == reminderObj.reminderId
            }){
                reminderList.remove(at: index)
                patientMObj.reminderArr = reminderList
                mPHRCoreDataUtil.sharedInstance.updatePatient(patientMObj: patientMObj)
            }
        }
    }
    
    static func getReminderObj(reminderId: String?, patientId: String?) -> Reminder?{
        
        var reminderObj: Reminder? = nil
        
        if let patientMObj = PatientDataHandler.getPatient(patientId: patientId), let reminderList = patientMObj.reminderArr{
            reminderObj = reminderList.first(where: { reminder in
                return reminder.reminderId == reminderId
            })
        }
        return reminderObj
    }
    
    static func getReminderObj(moduleId: String?, patientId: String?) -> [Reminder]{
        
        var reminderObjArr: [Reminder] = []
        
        if let patientMObj = PatientDataHandler.getPatient(patientId: patientId), let reminderList = patientMObj.reminderArr{
            reminderObjArr = reminderList.filter({ reminder in
                return reminder.moduleId == moduleId
            })
        }
        return reminderObjArr
    }
    
    static func getReminderObjList(patientId: String?) -> [Reminder]{
        var reminderObjArr: [Reminder] = []
        
        if let patientMObj = PatientDataHandler.getPatient(patientId: patientId), let reminderList = patientMObj.reminderArr{
            reminderObjArr = reminderList
        }
        return reminderObjArr
    }
}
