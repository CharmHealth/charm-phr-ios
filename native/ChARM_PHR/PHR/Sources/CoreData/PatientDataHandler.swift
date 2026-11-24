//
//  PatientDataHandler.swift
//  phr
//
//  Created by prathi-13964 on 21/08/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

protocol PatientDataHandlerDelegate: AnyObject {
    func patientDataHandlerDidReceiveData()
    func patientDataHandlerDidReceiveError(error : Error)
}

class PatientDataHandler: NSObject, CharmConnectionV2HandlerDelegate{
    
    weak private var delegate : PatientDataHandlerDelegate?
    private var charmConnectionHandler: CharmConnectionHandler? = nil
    
    init(delegate: PatientDataHandlerDelegate){
        super.init()
        self.delegate = delegate
    }
    
//MARK: - Patient
    
    func fetchPatientList(){
        if charmConnectionHandler == nil{
            charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        }
        charmConnectionHandler?.fetchPatientList(identificationKey: "fetchPatientList")
    }
    
    func fetchReminderMetaData(){
        
        if charmConnectionHandler == nil{
            charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        }
        Patient.patientList?.forEach { patientObj in
            charmConnectionHandler?.fetchReminderWithMeta(identificationKey: "fetchReminderMeta_\(patientObj.patientId ?? "")", patientId: patientObj.patientId)
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchPatientList"{
            if let patientList = response as? [Patient] {
                Patient.patientList = patientList
                delegate?.patientDataHandlerDidReceiveData()
            }
        }
        else if identificationKey.hasPrefix("fetchReminderMeta"){
            if let patientId = identificationKey.components(separatedBy: "_").last,
               let reminderGroupList = response as? PatientReminderPOJO{
                PatientDataHandler.setPatientDataObjects(medicationPOJOList: reminderGroupList.arrayOfMedication, supplementPOJOList: reminderGroupList.arrayOfSupplement, reminderList: reminderGroupList.reminderArray, patientId: patientId)
                let filteredArr = reminderGroupList.reminderArray.filter({ reminder in
                    return reminder.isReminderDeleted == false && reminder.endDate?.startOfDay ?? Date().startOfDay >= Date().startOfDay
                })
                if !filteredArr.isEmpty{
                    LocalNotificationUtil.sharedInstance.addOrUpdateNotification(reminderList: filteredArr)
                }
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        if identificationKey == "fetchPatientList"{
            delegate?.patientDataHandlerDidReceiveError(error: error)
        }
    }
    
    static func getPatient(patientId: String?) -> PatientMObj?{
        
        let coreDataUtil = mPHRCoreDataUtil.sharedInstance
        
        if let patientId = patientId, let patientMObj = coreDataUtil.patientMObjDict[patientId]{
            return patientMObj
        }
        else{
            let patientMObjList = coreDataUtil.getPatientMObjList()
            return patientMObjList?.first(where: { patientMObj in
                return patientMObj.patientId == patientId
            })
        }
    }
    
//MARK: - Set PatientDataObjects
    
    static func setPatientDataObjects(medicationPOJOList: [MedicationPOJO], supplementPOJOList: [SupplementPOJO], reminderList: [Reminder], patientId: String?){
        
        if let patientMObj = getPatient(patientId: patientId){
            
            patientMObj.medicationPOJOArr = medicationPOJOList
            patientMObj.supplementPOJOArr = supplementPOJOList
            patientMObj.reminderArr = reminderList
            
            mPHRCoreDataUtil.sharedInstance.updatePatient(patientMObj: patientMObj)
        }
    }
    
//MARK: - Medication
    
    static func addMedication(medicationPOJO: MedicationPOJO, patientId: String?){
        if let patientMObj = getPatient(patientId: patientId){
            
            if var medicationPOJOArr = patientMObj.medicationPOJOArr{
                medicationPOJOArr.append(medicationPOJO)
                patientMObj.medicationPOJOArr = medicationPOJOArr
            }
            else{
                patientMObj.medicationPOJOArr = [medicationPOJO]
            }
            mPHRCoreDataUtil.sharedInstance.updatePatient(patientMObj: patientMObj)
        }
    }
    
    static func getMedicationPOJO(patientMedicationId: String?, patientId: String?) -> MedicationPOJO?{
        
        var medicationPOJO: MedicationPOJO? = nil
        
        if let patientMObj = getPatient(patientId: patientId), let medicationPOJOList = patientMObj.medicationPOJOArr{
            medicationPOJO = medicationPOJOList.first(where: { medication in
                return medication.patientMedication?.patientMedicationId == patientMedicationId
            })
        }
        return medicationPOJO
    }
    
    static func deleteMedicationPOJO(medicationPOJO: MedicationPOJO){
        
        let coreDataUtil = mPHRCoreDataUtil.sharedInstance
        let patientId = medicationPOJO.patientMedication?.patientId
        let reminderObjList = ReminderHandler.getReminderObj(moduleId: medicationPOJO.patientMedication?.patientMedicationId, patientId: patientId)
        
        reminderObjList.forEach { reminderObj in
            ReminderHandler.deleteReminderAndNotification(reminderObj: reminderObj)
        }
        
        if let patientMObj = getPatient(patientId: patientId), var medicationPOJOList = patientMObj.medicationPOJOArr{
            if let index = medicationPOJOList.firstIndex(where: { medication in
                return medication.patientMedication?.patientMedicationId == medicationPOJO.patientMedication?.patientMedicationId
            }){
                medicationPOJOList.remove(at: index)
                patientMObj.medicationPOJOArr = medicationPOJOList
                coreDataUtil.updatePatient(patientMObj: patientMObj)
            }
        }
    }
    
    static func formMedicationTitleAndDescription(patientMedicationId: String?, patientId: String?) -> String?{
                
        var title: String? = nil
        var description: String? = nil
        
        if let medicationPOJO = getMedicationPOJO(patientMedicationId: patientMedicationId, patientId: patientId){
            
            description = medicationPOJO.getIntakeName(separator: ", ")
            title = medicationPOJO.getMedicationDisplayName()
        }
        if let title = title, let description = description{
            return "\(title)_\(description)"
        }
        return nil
    }
    
//MARK: - Supplement
    
    static func addSupplement(supplementPOJO: SupplementPOJO, patientId: String?){
        if let patientMObj = getPatient(patientId: patientId){
            
            if var supplementPOJOArr = patientMObj.supplementPOJOArr{
                supplementPOJOArr.append(supplementPOJO)
                patientMObj.supplementPOJOArr = supplementPOJOArr
            }
            else{
                patientMObj.supplementPOJOArr = [supplementPOJO]
            }
            mPHRCoreDataUtil.sharedInstance.updatePatient(patientMObj: patientMObj)
        }
    }
    
    static func getSupplementPOJO(patientSupplementId: String?, patientId: String?) -> SupplementPOJO?{
        
        var supplementPOJO: SupplementPOJO? = nil
        
        if let patientMObj = getPatient(patientId: patientId), let supplementPOJOList = patientMObj.supplementPOJOArr{
            supplementPOJO = supplementPOJOList.first(where: { supplement in
                return supplement.patientSupplement?.patientSupplementId == patientSupplementId
            })
        }
        return supplementPOJO
    }
    
    static func deleteSupplementPOJO(supplementPOJO: SupplementPOJO){
        
        let coreDataUtil = mPHRCoreDataUtil.sharedInstance
        let patientId = supplementPOJO.patientSupplement?.patientId
        
        let reminderObjList = ReminderHandler.getReminderObj(moduleId: supplementPOJO.patientSupplement?.patientSupplementId, patientId: supplementPOJO.patientSupplement?.patientId)
        
        reminderObjList.forEach { reminderObj in
            ReminderHandler.deleteReminderAndNotification(reminderObj: reminderObj)
        }
        
        if let patientMObj = getPatient(patientId: patientId), var supplementPOJOList = patientMObj.supplementPOJOArr{
            if let index = supplementPOJOList.firstIndex(where: { supplement in
                return supplement.patientSupplement?.patientSupplementId == supplementPOJO.patientSupplement?.patientSupplementId
            }){
                supplementPOJOList.remove(at: index)
                patientMObj.supplementPOJOArr = supplementPOJOList
                coreDataUtil.updatePatient(patientMObj: patientMObj)
            }
        }
    }
    
    static func formSupplementTitleAndDescription(patientSupplementId: String?, patientId: String?) -> String?{
                
        var title: String? = nil
        var description: String? = nil
        
        if let supplementPOJO = getSupplementPOJO(patientSupplementId: patientSupplementId, patientId: patientId){
            
            description = supplementPOJO.getIntakeName(separator: ", ")
            title = supplementPOJO.getSupplementDisplayName()
        }
        if let title = title, let description = description{
            return "\(title)_\(description)"
        }
        return nil
    }
    
    static func groupMedication(medicationArr: [MedicationPOJO]) -> [MedicationGroupPOJO]{
        
        var medicationGroupArr: [MedicationGroupPOJO] = []
        
        medicationArr.forEach { medicationPOJO in
            if let medicationGroupPOJO = medicationGroupArr.first(where: { medicationGroup in
                return medicationGroup.medicationId == medicationPOJO.medication?.medicationId
            }){
                medicationGroupPOJO.medicationArr.append(medicationPOJO)
            }
            else{
                let medicationGroupPOJO = MedicationGroupPOJO()
                medicationGroupPOJO.medicationId = medicationPOJO.medication?.medicationId
                medicationGroupPOJO.medicationName = medicationPOJO.getMedicationDisplayName()
                medicationGroupPOJO.medicationArr.append(medicationPOJO)
                
                medicationGroupArr.append(medicationGroupPOJO)
            }
        }
        return medicationGroupArr
    }
    
    static func groupSupplement(supplementArr: [SupplementPOJO]) -> [SupplementGroupPOJO]{
        
        var supplementGroupArr: [SupplementGroupPOJO] = []
        
        supplementArr.forEach { supplementPOJO in
            if let supplementGroupPOJO = supplementGroupArr.first(where: { supplementGroup in
                return supplementGroup.supplementId == supplementPOJO.supplement?.supplementId
            }){
                supplementGroupPOJO.supplementArr.append(supplementPOJO)
            }
            else{
                let supplementGroupPOJO = SupplementGroupPOJO()
                supplementGroupPOJO.supplementId = supplementPOJO.supplement?.supplementId
                supplementGroupPOJO.supplementName = supplementPOJO.getSupplementDisplayName()
                supplementGroupPOJO.supplementArr.append(supplementPOJO)
                
                supplementGroupArr.append(supplementGroupPOJO)
            }
        }
        return supplementGroupArr
    }
}
