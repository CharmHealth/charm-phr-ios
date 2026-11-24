//
//  AppDataHandler.swift
//  phrUITests
//
//  Created by Sankar Saravanan on 02/03/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import Foundation


protocol AppDataHandlerDelegate: AnyObject {
    func appDataHandlerDidReceiveData()
    func appDataHandlerDidReceiveError(error : Error, isShowAlert: Bool)
    func appDataHandlerDidRefreshUnreadCount()
}

protocol MessageRestrictionDelegate: AnyObject {
    func messageRestrictionDidReceiveData(isSuccess : Bool, error: Error?)
}
protocol MessageUnreadCountDelegate: AnyObject {
    func messageUnreadCountDidReceiveData(isSuccess : Bool, error: Error?)
}

class AppDataHandler : CharmConnectionHandlerDelegate,CharmConnectionV2HandlerDelegate{
  
    private static var instance : AppDataHandler?
    weak var delegate : AppDataHandlerDelegate?
    weak var messageUnreadCountDelegate : MessageUnreadCountDelegate?
    weak var messageRestrictionDelegate : MessageRestrictionDelegate?
    
    var charmconnectionHandler : CharmConnectionHandler!
    
    private var clinicalDataVcNameArr : [Module] = []
    private var healthDataVcNameArr : [Module] = []
    
    private var moduleNameArr : [Module] = []
        
    private var isMenuListFetched : Bool  = false
    private var isUnReadCountFetched : Bool = false
    private var isMessageRestrictionFetched : Bool = false
    private var isSectionConfFetched : Bool = false
    private var isPrivilegeFetched : Bool = false

    var canAllowMessage : Bool = false
    var canAllowAppointment : Bool = false
    var canAllowAnnouncement : Bool = false
    
    var menuListDict : Dictionary<String,Any>!
    var unreadCountDictArr : [Dictionary<String,Any>] = []
    var arrayOfMessageRestriction : [MessageRestriction] = []
    var sectionConfigurationArr : [Section] = []
    

    
    //SectionConfig V2
    
    var selectedPatientSection: SectionConfigList? = nil
    
    var numberOfpraticeDataGotForUnreadCount = 0
    
    var announcemnetUnreadCount = 0
    
    var clinicalDataSectionArr : [Module] = []
    var healthDataSectionArr : [Module] = []

    var moduleSectionArr : [Module] = []

    private var isUnreadCountUpdated : Bool = false
    
    //TODO : Adding this check temporirly. Have to remove this hack soon.
    //need to handle this via proper delegates
    //HomeVC -> AppointmentsVC -> addappointmentVC
    //HomeVC -> addappointmentVC
    var refreshAppointments : Bool = false //appointment cannot be deleted/edited so only newly added upcoming appointment needs to be refreshed in dashboardviewcontroller
    //HomeVC -> PrescriptionVC -> MedicationDetailVC -> AddMedicationVC
    //HomeVC -> PrescriptionVC -> AddMedicationVC
    //As of now adding medication in AddMedicationVC will reflect till PrescriptionVC in both cases
    var refreshMedication: Bool = false //medication add/edit/delete needs to be updated in dashboard.

    var refreshMessage: Bool = false //message add/delete needs to be updated in dashboard.

    var refreshQuestionnaire: Bool = false //Questionnaire add/delete needs to be updated in dashboard.

    var refreshVitals: Bool = false

    var refreshInvoice: Bool = false
    
    var reloadMessage: Bool = false
    

    init() {
    
    }
    
    class func sharedInstance() -> AppDataHandler
    {
        if instance == nil
        {
            instance = AppDataHandler()
        }
        return instance!
    }
    
    class func resetInstance(){
        instance = nil
    }
    
    class func didReceivedAllData() -> Bool
    {
        if let addDataHandler = AppDataHandler.instance {
            if AppConfig.sharedInstance.isCustomBrandApp && addDataHandler.isMenuListFetched
            {
                return false
            }
            else
            {
                if addDataHandler.isUnReadCountFetched && addDataHandler.isSectionConfFetched && addDataHandler.isMessageRestrictionFetched && addDataHandler.isPrivilegeFetched
                {
                    return true
                }else
                {
                    return false
                }
            }
        }
        else{
            return false
        }
      
    }
    
    func loadAllData()
    {
        
        moduleNameArr = [Module.getModule(moduleID: appointmentModelId, modulekey: "com.charmphr.home.listView.Appointments" , imageName: "Appointments"),
                         Module.getModule(moduleID: messageModuleId, modulekey: "com.charmphr.home.listView.Messages", imageName: "Messages"),
                         Module.getModule(moduleID: invoiceModelId, modulekey: "com.charmphr.home.listView.invoice", imageName: "Billing" , groupNum: 1),
                         Module.getModule(moduleID: receiptModelId, modulekey: "com.charmphr.home.listView.receipt", imageName: "Receipt" , groupNum: 1),
                         Module.getModule(moduleID: cardOnFileModelId, modulekey: "com.charmphr.card.title", imageName: "cardonfileIcon" , groupNum: 1),
                         Module.getModule(moduleID: questionnaireModelId, modulekey: "com.charmphr.home.listView.Questionnaire", imageName: "Questionnaire"),
                         Module.getModule(moduleID: flowsheetModelId, modulekey: "com.charmphr.home.listView.Flowsheets", imageName: "Flowsheets"),
                         Module.getModule(moduleID: insuranceModelId, modulekey: "com.charmphr.insurance.title", imageName: "insurance",groupNum: 2),
                         Module.getModule(moduleID: usefulInfoModelId, modulekey: "com.charmphr.home.listView.UsefulInfo" , imageName: "Info", groupNum: 3),
                         Module.getModule(moduleID: aboutModelId, modulekey: "com.charmphr.home.listView.About", imageName: "About" , groupNum: 3) ,
                         Module.getModule(moduleID: wellnessModelId, modulekey: "com.charmphr.wellness.title" , imageName: "Wellness"),
                         Module.getModule(moduleID: prescriptionModelId, modulekey: "com.charmphr.home.listView.Prescriptions",imageName: "Prescriptions" , groupNum: 2),
                         Module.getModule(moduleID: labModelId, modulekey: "com.charmphr.home.listView.Lab",imageName: "Labs" , groupNum: 2),
                         Module.getModule(moduleID: imagesModelId, modulekey: "com.charmphr.images.title",imageName: "Images" , groupNum: 2),
                         Module.getModule(moduleID: visitSummaryModelId, modulekey: "com.charmphr.home.listView.VisitSummary", imageName: "VisitSummary" , groupNum: 2),
                         Module.getModule(moduleID: healthPassportModelId, modulekey: "com.charmphr.profile.healthPassport.title" ,imageName: "Healthpassport", groupNum: 2),
                         Module.getModule(moduleID: procedureModelId, modulekey: "com.charmphr.home.listView.Procedures",imageName: "procedureList" , groupNum: 2),
                         Module.getModule(moduleID: documentModelId, modulekey: "com.charmphr.home.listView.Documents",imageName: "Docs" , groupNum: 2),
                         Module.getModule(moduleID: allergiesModelId, modulekey: "com.charmphr.home.listView.Allergies",imageName: "Allergies" , groupNum: 2),
                         Module.getModule(moduleID: problemListModelId, modulekey: "com.charmphr.problem.title",imageName: "ProblemList" , groupNum: 2),
                         
                         Module.getModule(moduleID: vaccineModelId, modulekey: "com.charmphr.home.listView.Immunization" , imageName: "Immunization" , groupNum: 2),
                         Module.getModule(moduleID: reminderModelId, modulekey: "com.charmphr.reminder.title", imageName: "Reminder" )]
        moduleNameArr.append(Module.getModule(moduleID: shareSectionModelId, modulekey: "com.charmphr.shareSection.title", imageName: "ShareSection"))
        
        clinicalDataVcNameArr = [Module.getModule(moduleID: appointmentModelId, modulekey: "com.charmphr.home.listView.Appointments"),
                                 Module.getModule(moduleID: messageModuleId, modulekey: "com.charmphr.home.listView.Messages"),
                                 Module.getModule(moduleID: billingModelId, modulekey: "com.charmphr.home.listView.Billing"),
                                 Module.getModule(moduleID: questionnaireModelId, modulekey: "com.charmphr.home.listView.Questionnaire"),
                                 Module.getModule(moduleID: flowsheetModelId, modulekey: "com.charmphr.home.listView.Flowsheets"),
                                 Module.getModule(moduleID: insuranceModelId, modulekey: "com.charmphr.insurance.title"),
                                 Module.getModule(moduleID: usefulInfoModelId, modulekey: "com.charmphr.home.listView.UsefulInfo"),
                                 Module.getModule(moduleID: aboutModelId, modulekey: "com.charmphr.home.listView.About")
                                 ]
        
        healthDataVcNameArr = [
            Module.getModule(moduleID: wellnessModelId, modulekey: "com.charmphr.wellness.title"), Module.getModule(moduleID: prescriptionModelId, modulekey: "com.charmphr.home.listView.Prescriptions"),
                               
                               
            Module.getModule(moduleID: labModelId, modulekey: "com.charmphr.home.listView.Lab"),
            Module.getModule(moduleID: imagesModelId, modulekey: "com.charmphr.images.title"),
            Module.getModule(moduleID: visitSummaryModelId, modulekey: "com.charmphr.home.listView.VisitSummary"),
            Module.getModule(moduleID: healthPassportModelId, modulekey: "com.charmphr.profile.healthPassport.title"),
            Module.getModule(moduleID: procedureModelId, modulekey: "com.charmphr.home.listView.Procedures"),
            Module.getModule(moduleID: documentModelId, modulekey: "com.charmphr.home.listView.Documents"),
            Module.getModule(moduleID: allergiesModelId, modulekey: "com.charmphr.home.listView.Allergies"),
            Module.getModule(moduleID: vaccineModelId, modulekey: "com.charmphr.home.listView.Immunization"),
            Module.getModule(moduleID: reminderModelId, modulekey: "com.charmphr.reminder.title")
            ]
        healthDataVcNameArr.append(Module.getModule(moduleID: shareSectionModelId, modulekey: "com.charmphr.shareSection.title"))
        
        isMenuListFetched = false
        isUnReadCountFetched = false
        isSectionConfFetched = false
        isMessageRestrictionFetched = false
        isPrivilegeFetched = false
        
        
        menuListDict = nil
        unreadCountDictArr = []
        arrayOfMessageRestriction = []
        sectionConfigurationArr = []
        
        clinicalDataSectionArr = []
        healthDataSectionArr = []
        
        RbacUtil.updatePrivileges()
        
        numberOfpraticeDataGotForUnreadCount = 0
        
        announcemnetUnreadCount = 0
        
        fetchAppRelatedData()
    }
    
    func fetchAppRelatedData()
    {
        charmconnectionHandler = CharmConnectionHandler(delegate: self)
        charmconnectionHandler?.v2Delegate = self

        if AppConfig.sharedInstance.isCustomBrandApp && isMenuListFetched == false
        {
            charmconnectionHandler.fetchMenulist(practiceId: Patient.selectedPatientInstance?.practiceList[0].practiceId ?? "", identificationKey: "fetchMenulist")
        }
        fetchUnReadCount()
        fetchSectionConfiguration()
        fetchPrivilegeList()
    }
    
    func getRBACPrivilegeFromModuleId(moduleId: String) -> RBACPrivileges{
        
        switch moduleId {
        case documentModelId:
            return .VIEW_DOCUMENTS
        case labModelId:
            return .VIEW_LABRESULTS
        case imagesModelId:
            return .VIEW_IMAGERESULTS
        case visitSummaryModelId:
            return .VIEW_VISITSUMMARY
        case procedureModelId:
            return .VIEW_PROCEDURE
        case wellnessModelId:
            return .VIEW_WELLNESS
        case allergiesModelId:
            return .VIEW_ALLERGIES
        case vaccineModelId:
            return .VIEW_IMMUNE
        case appointmentModelId:
            return .VIEW_APPOINTMENT
        case messageModuleId:
            return .VIEW_MESSAGES
        case flowsheetModelId:
            return .VIEW_FLOWSHEETDATA
        case questionnaireModelId:
            return .VIEW_QUESTIONNAIRE
        case insuranceModelId:
            return .VIEW_INSURANCE
        case usefulInfoModelId:
            return .VIEW_USEFULINFO
        case aboutModelId:
            return .VIEW_PRACTICEDETIALS
        case invoiceModelId:
            return .VIEW_INVOICE
        case receiptModelId:
            return .VIEW_RECEIPT
        case flowsheetModelId:
            return .VIEW_FLOWSHEETDATA
        default: break
        }
        return .NO_ACCESS
    }
    
    func fetchUnReadCount()
    {
        isUnreadCountUpdated = false
        unreadCountDictArr = []
        charmconnectionHandler = CharmConnectionHandler(delegate: self)
        charmconnectionHandler?.v2Delegate = self
        numberOfpraticeDataGotForUnreadCount = 0
        for practiceId in getActivePracticeId()
        {
            charmconnectionHandler.fetchUnreadCount(patientId: getSelectedPatientId(), practiceId: practiceId, identificationKey: "unreadCount")
        }
    }
    
    func fetchRestriction()
    {
        arrayOfMessageRestriction = []
        charmconnectionHandler?.fetchMessageRestriction(identificationKey: "fetchRestriction")
    }
    
    func fetchSectionConfiguration()
    {
        charmconnectionHandler.fetchSectionConfiguration(patientId: getSelectedPatientId(), identificationKey: "fetchSectionConfiguration")
    }
    
    func fetchPrivilegeList() //TODO: handle secondary account
    {
//        charmconnectionHandler.fetchPrivilegeList(identificationKey: "fetchPrivilegeList")
        
        var outputString:[String:Any] = [:]
        var privilegeArr:[String] = []
        privilegeArr.append("full_access")
        outputString.addProperty("privileges", privilegeArr)
         
        var respObj: [String:Any] = [:]
        respObj.addProperty("output_string", outputString)
        charmConnectionHandlerDidRecieveJsonObject(jsonObject:respObj , identificationKey: "fetchPrivilegeList")
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchMenulist"
        {
            isMenuListFetched = true
            menuListDict = jsonObject
            finishLoading()
        }
        else if identificationKey == "fetchPrivilegeList"{
            
            isPrivilegeFetched = true
            RbacUtil.savePrivileges(privilegeList: ParsingHelper.formPrivilegeList(respObj: jsonObject))
            finishLoading()
        }
        else if identificationKey == "fetchSectionConfiguration"
        {
            isSectionConfFetched = true
            
            selectedPatientSection = ParsingHelper.formPatientSection(respObj: jsonObject)
            
            sectionConfigurationArr = ParsingHelper.fillArrayOfSectionsWithDictionary(dictionary: jsonObject)
            
            
            canAllowMessage = (RbacUtil.checkPrivilege(privilege: .ADD_MESSAGES)) && (isModuleEnabled(moduleId: messageModuleId))
            canAllowAppointment = (RbacUtil.checkPrivilege(privilege: .ADD_APPOINTMENT)) && (isModuleEnabled(moduleId: appointmentModelId))
            canAllowAnnouncement = (RbacUtil.checkPrivilege(privilege: .VIEW_ANNOUNCEMENTS)) && (isModuleEnabled(moduleId: announcementModelId))
            
//            let outputStringArr = jsonObject["output_string"] as! Array<Dictionary<String,Any>>
//            if outputStringArr.count > 0
//            {
//                let outputStringDict = outputStringArr[0]
//                if (outputStringDict["ANNOUNCEMENT_ENABLED"] != nil)
//                {
//                    canAllowAnnouncement  = outputStringDict["ANNOUNCEMENT_ENABLED"] as! Bool
//                }
//                if (outputStringDict["APPOINTMENT_ENABLED"] != nil)
//                {
//                    canAllowAppointment  = outputStringDict["APPOINTMENT_ENABLED"] as! Bool
//                }
//                if (outputStringDict["MESSAGE_ENABLED"] != nil)
//                {
//                    canAllowMessage  = outputStringDict["MESSAGE_ENABLED"] as! Bool
//                }
//            }
            
            sectionConfigurationArr.append(Section.getSectionWithName(name: getString(key: "com.charmphr.home.listView.UsefulInfo")))
            sectionConfigurationArr.append(Section.getSectionWithName(name: getString(key: "com.charmphr.home.listView.About")))
            AppDataHandler.sharedInstance().isMessageRestrictionFetched = false
            fetchRestriction()
            finishLoading()
        }
        else if identificationKey == "unreadCount"
        {
            numberOfpraticeDataGotForUnreadCount += 1
            unreadCountDictArr.append(jsonObject)
            if getActivePracticeId().count == numberOfpraticeDataGotForUnreadCount
            {
                if isUnReadCountFetched
                {
                    updateUnreadCount()
                    messageUnreadCountDelegate?.messageUnreadCountDidReceiveData(isSuccess: true, error: nil)
                    delegate?.appDataHandlerDidRefreshUnreadCount()
                }else
                {
                    isUnReadCountFetched = true
                    finishLoading()
                }
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "unreadCount" && AppDataHandler.didReceivedAllData(){
            messageUnreadCountDelegate?.messageUnreadCountDidReceiveData(isSuccess: false, error: error)
            delegate?.appDataHandlerDidReceiveError(error: error, isShowAlert: true)
        }
        else{
            delegate?.appDataHandlerDidReceiveError(error: error, isShowAlert: false)
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchRestriction"{
            if let messageRestrictionList = response as? [MessageRestriction] {
                arrayOfMessageRestriction = messageRestrictionList
                isMessageRestrictionFetched = true
                finishLoading()
                messageRestrictionDelegate?.messageRestrictionDidReceiveData(isSuccess: true, error: nil)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        delegate?.appDataHandlerDidReceiveError(error: error, isShowAlert: false)
        messageRestrictionDelegate?.messageRestrictionDidReceiveData(isSuccess: false, error: error)
    }
    
    func finishLoading()
    {
        if AppDataHandler.didReceivedAllData()
        {
            healthDataSectionArr = []
            clinicalDataSectionArr = []
            moduleSectionArr = []
            var gridModuleList:[Module] = []
            
            for module in moduleNameArr {
                if module.moduleId == healthPassportModelId {
                    if getSelectedPatient().isHealthPassportAvailable {
                        moduleSectionArr.append(module)
                    }
                }
                else if module.moduleId == invoiceModelId || module.moduleId == receiptModelId {
                    module.isBilling = true
                    let selectedModule = getModule(moduleId: billingModelId)
                    
                    module.isShown = RbacUtil.checkPrivilege(privilege: getRBACPrivilegeFromModuleId(moduleId: module.moduleId))  && selectedModule?.isEnable == true
                    module.position = selectedModule?.sectionOrder ?? 0
                    
                    if module.isShown {
                        moduleSectionArr.append(module)
                    }
                }
                else if module.moduleId == cardOnFileModelId  {
                    module.isBilling = true
                    if Patient.selectedPatientInstance?.isBluefinEnabled == true {
                        module.position = 99
                        moduleSectionArr.append(module)
                    }
                }
                else{
                    
                    let selectedModule = getModule(moduleId: module.moduleId)
                    
                    module.isShown = RbacUtil.checkPrivilege(privilege: getRBACPrivilegeFromModuleId(moduleId: module.moduleId))  && isModuleEnabled(moduleId: module.moduleId)
                    module.position = selectedModule?.sectionOrder ?? 0
                    module.moduleNameFromSection = selectedModule?.name
                    
                    if module.moduleId == prescriptionModelId{
                        
                        let medicationModule =  getModule(moduleId: medicationModelId)
                        let supplementmodule = getModule(moduleId: supplementModelId)
                        
                        let isMedicationModule = RbacUtil.checkPrivilege(privilege: .VIEW_MEDICATIONS)
                        let isSupplementModule = RbacUtil.checkPrivilege(privilege: .VIEW_SUPPLEMENTS)
                        
                        if (medicationModule?.isEnable != false && isMedicationModule) && (supplementmodule?.isEnable != false && isSupplementModule){
                            module.isShown = true
                            module.moduleNameFromSection = nil
                            module.position = medicationModule?.sectionOrder ?? 0
                        }
                        else{
                            if medicationModule?.isEnable != false  && isMedicationModule {
                                module.isShown = true
                                module.moduleNameFromSection = medicationModule?.name ?? ""
                                module.position = medicationModule?.sectionOrder ?? 0
                            }
                            else if supplementmodule?.isEnable != false  && isSupplementModule{
                                module.isShown = true
                                module.moduleNameFromSection = supplementmodule?.name ?? ""
                                module.position = supplementmodule?.sectionOrder ?? 0
                            }
                        }
                    }
                    else if module.moduleId == reminderModelId {
                        module.position = 98
                        module.isShown = true
                    }
                    else if module.moduleId == wellnessModelId {
                        module.position = 99
                    }
                    else if module.moduleId == shareSectionModelId{
                        module.position = 100
                        module.isShown = true
                    }
                    else if module.moduleId == aboutModelId || module.moduleId == usefulInfoModelId{
                        module.isShown = true
                    }
                    
                    if module.isShown {
                        moduleSectionArr.append(module)
                    }
                }
            }
            
            for module in healthDataVcNameArr
            {
                if module.moduleId == healthPassportModelId {
                    if getSelectedPatient().isHealthPassportAvailable {
                        healthDataSectionArr.append(module)
                        if gridModuleList.count < 4 {
                            gridModuleList.append(module)
                            module.showAsGrid = true
                        }
                    }
                }
                else{
                    
                    let selectedModule = getModule(moduleId: module.moduleId)
                    
                    module.isShown = RbacUtil.checkPrivilege(privilege: getRBACPrivilegeFromModuleId(moduleId: module.moduleId))  && isModuleEnabled(moduleId: module.moduleId)
                    module.position = selectedModule?.sectionOrder ?? 0
                    module.moduleNameFromSection = selectedModule?.name
                    
                    if module.moduleId == prescriptionModelId{
                        
                        let medicationModule =  getModule(moduleId: medicationModelId)
                        let supplementmodule = getModule(moduleId: supplementModelId)
                        
                        let isMedicationModule = RbacUtil.checkPrivilege(privilege: .VIEW_MEDICATIONS)
                        let isSupplementModule = RbacUtil.checkPrivilege(privilege: .VIEW_SUPPLEMENTS)
                        
                        if (medicationModule?.isEnable != false && isMedicationModule) && (supplementmodule?.isEnable != false && isSupplementModule){
                            module.isShown = true
                            module.moduleNameFromSection = nil
                            module.position = medicationModule?.sectionOrder ?? 0
                        }
                        else{
                            if medicationModule?.isEnable != false  && isMedicationModule {
                                module.isShown = true
                                module.moduleNameFromSection = medicationModule?.name ?? ""
                                module.position = medicationModule?.sectionOrder ?? 0
                            }
                            else if supplementmodule?.isEnable != false  && isSupplementModule{
                                module.isShown = true
                                module.moduleNameFromSection = supplementmodule?.name ?? ""
                                module.position = supplementmodule?.sectionOrder ?? 0
                            }
                        }
                    }
                    
                    if module.moduleId == reminderModelId{
                        module.isShown = true
                    }
                    if module.moduleId == shareSectionModelId{
                        module.isShown = true
                    }
                    
                    if module.isShown {
                        healthDataSectionArr.append(module)
                        if gridModuleList.count < 4 {
                            gridModuleList.append(module)
                            module.showAsGrid = true
                        }
                    }
                }
            }
            
            gridModuleList = []
            for module in clinicalDataVcNameArr
            {
                let selectedModule = getModule(moduleId: module.moduleId)
                
                module.isShown =  RbacUtil.checkPrivilege(privilege: getRBACPrivilegeFromModuleId(moduleId: module.moduleId)) && isModuleEnabled(moduleId: module.moduleId)
                module.position = selectedModule?.sectionOrder ?? 0
                module.moduleNameFromSection = selectedModule?.name
                
                if module.moduleId == billingModelId{
                
                    let isInvoiceModule = RbacUtil.checkPrivilege(privilege: .VIEW_INVOICE)
                    let isReceiptModule = RbacUtil.checkPrivilege(privilege: .VIEW_RECEIPT)
                    
                    if module.isShown && isInvoiceModule && isReceiptModule{
                        module.moduleNameFromSection = nil
                    }else{
                        if isInvoiceModule && module.isShown{
                            module.moduleNameFromSection = "Invoice"
                        }else if isReceiptModule && module.isShown{
                            module.moduleNameFromSection = "Receipt"
                        }
                    }
                }
                
                if module.moduleId == aboutModelId || module.moduleId == usefulInfoModelId{
                    module.isShown = true
                }
                
                if module.isShown {
                    
                    clinicalDataSectionArr.append(module)
                    if gridModuleList.count < 4 {
                        gridModuleList.append(module)
                        module.showAsGrid = true
                    }
                }
            }
            updateUnreadCount()
            delegate?.appDataHandlerDidReceiveData()
            messageUnreadCountDelegate?.messageUnreadCountDidReceiveData(isSuccess: true, error: nil)
        }
    }
    
    func updateUnreadCount()
    {
        for unreadCountDict in unreadCountDictArr
        {
            let outputDict = unreadCountDict["output_string"] as! Dictionary<String,Any>
            
            if !isUnreadCountUpdated
            {
                announcemnetUnreadCount = 0
            }
            
            announcemnetUnreadCount += (outputDict["PRACTICE_ANNOUNCEMENT_COUNT"] as! Int)
            
            for module in clinicalDataSectionArr
            {
                if !isUnreadCountUpdated
                {
                    module.unreadCount = 0
                }
                if module.moduleId == appointmentModelId
                {
                    module.unreadCount += (outputDict["UPCOMING_APPOINTMENT_COUNT"] as! Int)
                }
                if module.moduleId == messageModuleId
                {
                    module.unreadCount += (outputDict["MESSAGE_UNREAD_COUNT"] as! Int)
                }
                if module.moduleId == billingModelId
                {
                    module.unreadCount += (outputDict["BILLING_COUNT"] as! Int)
                }
                if module.moduleId == questionnaireModelId
                {
                    module.unreadCount += (outputDict["QUES_UNFILLED_COUNT"] as! Int)
                }
            }
            for module in healthDataSectionArr
            {
                if !isUnreadCountUpdated
                {
                    module.unreadCount = 0
                }
                if module.moduleId == labModelId
                {
                    module.unreadCount += (outputDict["LAB_UNREAD_COUNT"] as! Int)
                }
                if module.moduleId == documentModelId
                {
                    module.unreadCount += (outputDict["SHARED_FILES_UNREAD_COUNT"] as! Int)
                }
                
                if module.moduleId == visitSummaryModelId
                {
                    module.unreadCount += (outputDict["VISIT_SUMMARY_UNREAD_COUNT"] as! Int)
                }
            }
            
            for module in moduleSectionArr{
                if !isUnreadCountUpdated
                {
                    module.unreadCount = 0
                }
                if module.moduleId == appointmentModelId
                {
                    module.unreadCount += (outputDict["UPCOMING_APPOINTMENT_COUNT"] as! Int)
                }
                if module.moduleId == messageModuleId
                {
                    module.unreadCount += (outputDict["MESSAGE_UNREAD_COUNT"] as! Int)
                }
                if module.moduleId == billingModelId || module.moduleId == invoiceModelId || module.moduleId == receiptModelId || module.moduleId == cardOnFileModelId
                {
                    module.unreadCount += (outputDict["BILLING_COUNT"] as! Int)
                }
                if module.moduleId == questionnaireModelId
                {
                    module.unreadCount += (outputDict["QUES_UNFILLED_COUNT"] as! Int)
                }
                if module.moduleId == labModelId
                {
                    module.unreadCount += (outputDict["LAB_UNREAD_COUNT"] as! Int)
                }
                if module.moduleId == documentModelId
                {
                    module.unreadCount += (outputDict["SHARED_FILES_UNREAD_COUNT"] as! Int)
                }
                
                if module.moduleId == visitSummaryModelId
                {
                    module.unreadCount += (outputDict["VISIT_SUMMARY_UNREAD_COUNT"] as! Int)
                }
            }

            isUnreadCountUpdated = true
        }
    }
    
    class func findSectionWithName(string:String) -> Section?
    {
        let sectionArr = AppDataHandler.instance?.sectionConfigurationArr
        if sectionArr != nil
        {
            let indexOfSectionWithName = sectionArr?.firstIndex(where: { (section) -> Bool in
                if section.name == string
                {
                    return true
                }else
                {
                    return false
                }
            })
            if indexOfSectionWithName != nil
            {
                return sectionArr![indexOfSectionWithName!]
            }
        }
        return nil
    }
}
