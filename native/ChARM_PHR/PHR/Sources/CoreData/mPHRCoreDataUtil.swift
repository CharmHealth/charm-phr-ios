//
//  mPHRCoreDataUtil.swift
//  phr
//
//  Created by prathi-13964 on 20/11/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import CoreData
import UIKit

///We do not use NSPredicate to query from the DB because the values are encrypted and stored in DB

class mPHRCoreDataUtil: NSObject{
    
    private let patientFetchErrorCode: Int = 556900433
    private let patientFetchAllErrorCode: Int = 556900434
    private let reminderNotificationFetchAllErrorCode: Int = 556900435
    var patientMObjDict: [String: PatientMObj] = [:]
    var encryptionKey: String? = nil
    private static var instance: mPHRCoreDataUtil? = nil
    
    static var sharedInstance: mPHRCoreDataUtil{
        
        if instance == nil {
            instance = mPHRCoreDataUtil()
            instance?.setEncryptionKey()
            instance?.setPatientMObjList()
        }
        return instance!
    }
    
    private func setEncryptionKey(){
        if let key = AuthManager.getEncrptionkeyInKeyChain(){
            encryptionKey = key
        }
        else{
            encryptionKey = CharmUtil.generateRandomKey(length: 32)
            if let encryptionKey = encryptionKey{
                AuthManager.setEncrptionkeyInKeyChain(encrptionkey: encryptionKey)
            }
        }
    }
    
    func resetInstance(){
        mPHRCoreDataUtil.instance = nil
    }

    //MARK: - PatientMObj
    
    private func setPatientMObjList(){
        if let patientMObjList = getPatientMObjList(){
            patientMObjList.forEach { patientMObj in
                if let patientId = patientMObj.patientId{
                    patientMObjDict[patientId] = patientMObj
                }
            }
        }
    }
    
    func addPatientMObj(patient: Patient){
        let patientMObj = PatientMObj(context: getContext())
        patientMObj.fillWithPropertiesFromPatientObj(patient: patient)
        updatePatient(patientMObj: patientMObj)
    }
    
    func updatePatientMObj(patient: Patient){
        
        if let patientId = patient.patientId, let patientMObj = patientMObjDict[patientId]{
            
            patientMObj.fillWithPropertiesFromPatientObj(patient: patient)
            updatePatient(patientMObj: patientMObj)
        }
    }
    
    func updatePatient(patientMObj: PatientMObj){
        if let patientId = patientMObj.patientId{
            
            patientMObjDict[patientId] = patientMObj
            saveContext()
        }
    }
    
    func deletePatientMObj(object: PatientMObj){
        if let patientId = object.patientId{
            patientMObjDict.removeValue(forKey: patientId)
            getContext().delete(object)
            saveContext()
        }
    }
    
    func getPatientMObjList() -> [PatientMObj]?{
        if patientMObjDict.isEmpty{
            do{
                let context = getContext()
                let patientMObjArray = try context.fetch(PatientMObj.fetchRequest())
                return patientMObjArray
            }
            catch{
                showError(errorCode: patientFetchAllErrorCode)
            }
        }
        else{
            return Array(patientMObjDict.values)
        }
        return nil
    }
    
    
//    private func getPatientEquals(key: String, val: String?, success: @escaping ([PatientMObj]) -> Void){
//        let request = PatientMObj.fetchRequest()
//        if let val = val{
//            let predicate = NSPredicate(format: "\(key) like %@", "\(val)")
//            request.predicate = predicate
//            do{
//                let items = try getContext().fetch(request)
//                success(items)
//            }
//            catch{
//                showError(errorCode: patientFetchErrorCode)
//            }
//        }
//    }
    
    //MARK: - ReminderNotificationMObj
    
    func addReminderNotificationMObj(notificationId: String?, remininderIdArray: [String]){
        
        let reminderNotificationMObj = ReminderNotificationMObj(context: getContext())
        
        reminderNotificationMObj.fillWithProperties(notificationId: notificationId, remininderIdArray: remininderIdArray)
        saveContext()
    }
    
    func updateReminderNotificationMObj(reminderNotificationMObj: ReminderNotificationMObj, remininderIdArray: [String]){
        
        reminderNotificationMObj.updateProperties(remininderIdArray: remininderIdArray)
        saveContext()
    }
    
    func deleteReminderNotification(object: ReminderNotificationMObj){
        getContext().delete(object)
        saveContext()
    }
    
    func getReminderNotificationMObj(notificationId: String?) -> ReminderNotificationMObj?{
        if let reminderNotificationMObj = getReminderNotificationMObjList()?.first(where: { obj in
            return obj.notificationId == notificationId
        }){
            return reminderNotificationMObj
        }
        return nil
    }
    
    func getReminderNotificationMObjList() -> [ReminderNotificationMObj]?{
        do{
            let reminderNotificationArr = try getContext().fetch(ReminderNotificationMObj.fetchRequest())
            return reminderNotificationArr
        }
        catch{
            showError(errorCode: reminderNotificationFetchAllErrorCode)
        }
        return nil
    }
    
//MARK: - delete mPHRCoreDataValues
    
    func deletemPHRCoreDataValues() {
        
        let entityNames = patientPersistentContainer.managedObjectModel.entities.compactMap { $0.name }

        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try getContext().execute(deleteRequest)
            } catch {
                CharmUtil.createOkayAlertWith(title: nil, msg: "\(getString(key: "com.charmphr.reminder.coreData.delete.error.title")) \(entityName): \(error)")
            }
            saveContext()
        }
    }
    
    func showError(errorCode: Int){
        CharmUtil.createOkayAlertWith(title: nil, msg: "\(getString(key: "com.charmphr.alertError")): \(errorCode)")
    }
    
    //MARK: - Context
    
    private func getContext() -> NSManagedObjectContext{
        return patientPersistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    
    private lazy var patientPersistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "mPHRCoreData")
        
        let description = NSPersistentStoreDescription()
        description.type = NSSQLiteStoreType // Set the type of the store, e.g., SQLite
        description.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("mPHRCoreData.sqlite")
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                debugPrintLog(error)
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    private func saveContext() {
        let context = getContext()
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
               debugPrintLog(error)
            }
        }
    }
}
