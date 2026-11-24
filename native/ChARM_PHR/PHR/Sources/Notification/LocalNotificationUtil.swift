//
//  LocalNotificationUtil.swift
//  phr
//
//  Created by prathi-13964 on 22/05/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

class LocalNotificationUtil: NSObject, UNUserNotificationCenterDelegate{
    
    private static var instance: LocalNotificationUtil? = nil
    
    static var sharedInstance: LocalNotificationUtil{
        
        if instance == nil {
            instance = LocalNotificationUtil()
        }
        return instance!
    }
    
    private let coreDataUtil = mPHRCoreDataUtil.sharedInstance
    
    private let notificationDays: Int = 10
    
    func resetInstance(){
        LocalNotificationUtil.instance = nil
    }
    
//MARK: - Create Notification
    
    private func createNotification(notificationId: String?, dateTimeObj: Date, patientId: String?){
        
        if let notificationId = notificationId, let patientId = patientId{
            
            var patientFirstName: String?
            
            if let patientMObj = PatientDataHandler.getPatient(patientId: patientId){
                patientFirstName = patientMObj.patientData?.firstName
            }
            
            let time12HoursString = dateTimeObj.getStringFromDate(dateFormat: "hh:mm a")
            
            let content = UNMutableNotificationContent()
            if let patientFirstName = patientFirstName{
                content.body = "Hi \(patientFirstName), its \(time12HoursString), time to take your Medications"
            }
            content.sound = .default
            let dict = ["module": reminderModelId,"patient_id": patientId, "notificationId": notificationId]
            let jsonData = (try? JSONSerialization.data(withJSONObject: dict, options: []))!
            if let addInfo = String(data: jsonData, encoding: .utf8){
                content.userInfo = ["addInfo": addInfo]
            }
            content.interruptionLevel = .timeSensitive
                        
            let dateComponent = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: dateTimeObj)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
            let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request,withCompletionHandler:{ error in
                
            })
            center.delegate = self
        }
    }
    
    private func formNotificationIdString(date: Date, patientId: String?) -> String?{
        if let patientId = patientId{
            let fromDateString = date.getStringFromDate(dateFormat: ReminderDateWithTimeFormat)
            return "\(fromDateString)_\(patientId)"
        }
        return nil
    }
    
//MARK: - Add or Update Notification
    
    func addOrUpdateNotification(reminderList: [Reminder]){
        reminderList.forEach { reminder in
            addOrUpdateNotification(reminderObj: reminder)
        }
    }
    
    func addOrUpdateNotification(reminderObj: Reminder){
        
        if let endDate = reminderObj.endDate, endDate.startOfDay >= Date().startOfDay{
            let notificationDateArr = formNotificationDateArray(startDate: reminderObj.startDate, endDate: reminderObj.endDate, frequencyArray: reminderObj.reminderFrequencyArray)
            
            guard !notificationDateArr.isEmpty else { return }
            for (_, date) in notificationDateArr.enumerated() {
                
                let notificationId = formNotificationIdString(date: date, patientId: reminderObj.patientId)
                
                if let reminderNotificationMObj = coreDataUtil.getReminderNotificationMObj(notificationId: notificationId){
                    
                    if var reminderArray = reminderNotificationMObj.reminderIdList?.components(separatedBy: ","), let reminderId = reminderObj.reminderId{
                        
                        if !reminderArray.contains(reminderId){
                            reminderArray.append(reminderId)
                            
                            coreDataUtil.updateReminderNotificationMObj(reminderNotificationMObj: reminderNotificationMObj, remininderIdArray: reminderArray)
                        }
                        else{
                            break
                        }
                    }
                }
                else{
                    addNotification(notificationId: notificationId, reminderObj: reminderObj, dateTimeObj: date)
                }
            }
        }
    }
        
    private func addNotification(notificationId: String?, reminderObj: Reminder, dateTimeObj: Date){
        createNotification(notificationId: notificationId, dateTimeObj: dateTimeObj, patientId: reminderObj.patientId)
        if let reminderId = reminderObj.reminderId{
            coreDataUtil.addReminderNotificationMObj(notificationId: notificationId, remininderIdArray: [reminderId])
        }
    }

//MARK: - Delete Notification
    
    func cancelAllNotification(){
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removeReminderNotification(reminderObj: Reminder){
        
        let notificationMObjList = coreDataUtil.getReminderNotificationMObjList()
        
        notificationMObjList?.forEach({ reminderNotificationMObj in
            removeReminderNotification(reminderNotificationMObj: reminderNotificationMObj, reminderObj: reminderObj)
        })
    }
    
    private func removeReminderNotification(reminderNotificationMObj: ReminderNotificationMObj, reminderObj: Reminder){
        
        if var reminderIdList = reminderNotificationMObj.reminderIdList?.components(separatedBy: ","),
            let reminderId = reminderObj.reminderId{
            
            if reminderIdList.contains(reminderId){
                if reminderIdList.count == 1{
                    deleteNotification(object: reminderNotificationMObj)
                }
                else{
                    reminderIdList.removeAll { reminderId in
                        return reminderId == reminderObj.reminderId
                    }
                    coreDataUtil.updateReminderNotificationMObj(reminderNotificationMObj: reminderNotificationMObj, remininderIdArray: reminderIdList)
                }
            }
        }
    }
    
    private func deleteNotification(object: ReminderNotificationMObj){
        if let notificationId = object.notificationId{
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationId])
        }
        coreDataUtil.deleteReminderNotification(object: object)
    }

//MARK: - Form Notification DateList
    
    //form date array for 10 days notification
    private func formNotificationDateArray(startDate: Date? ,endDate: Date?, frequencyArray: [ReminderFrequency]) -> [Date]{
        var dateArray: [Date] = []
        if let reminderStartDate: Date = startDate?.startOfDay, let reminderEndDate: Date = endDate?.startOfDay{
            var today: Date = Date().startOfDay
            var notificationMaxDate: Date = today.add(days: notificationDays - 1)
            
            frequencyArray.forEach { reminderFrequency in
                
                var tempDateArr: [Date] = []
                
                if reminderStartDate > today{
                    today = reminderStartDate
                    notificationMaxDate = today.add(days: notificationDays - 1)
                }
                else{
                    if reminderFrequency.time ?? "" > Date().getStringFromDate(dateFormat: Time24HoursFormat){
                        today = Date().startOfDay
                        notificationMaxDate = today.add(days: notificationDays - 1)
                    }
                    else if reminderFrequency.time ?? "" < Date().getStringFromDate(dateFormat: Time24HoursFormat){
                        today = Date().add(days: 1)
                        notificationMaxDate = today.add(days: notificationDays - 1)
                    }
                }
                
                
                let todayString = today.getStringFromDate(dateFormat: PHR_DATE_API_FORMAT)
                let todayDateTimeString = "\(todayString) \(reminderFrequency.time ?? "")"
                
                let toDateString = notificationMaxDate.getStringFromDate(dateFormat: PHR_DATE_API_FORMAT)
                let toDateDateTimeString = "\(toDateString) \(reminderFrequency.time ?? "")"
                
                if let todayDateTimeObj = Date.getDateFromString(dateFormat: ReminderDateWithTimeFormat, dateString: todayDateTimeString),
                   let toDateDateTimeObj = Date.getDateFromString(dateFormat: ReminderDateWithTimeFormat, dateString: toDateDateTimeString){
                    
                    tempDateArr = Date.dates(from: todayDateTimeObj, to: toDateDateTimeObj)
                    
                    if reminderFrequency.day == "-1"{
                        tempDateArr = tempDateArr.filter { date in
                            return date.startOfDay <= reminderEndDate.startOfDay
                        }
                    }
                    else{
                        tempDateArr = tempDateArr.filter { date in
                            return (date.startOfDay <= reminderEndDate) && (date.getStringFromDate(dateFormat: dayDisplayFormat) == "\(WeekDays(rawValue: reminderFrequency.day?.toIntOrNil() ?? 0) ?? WeekDays.Sunday)")
                        }
                    }
                }
                dateArray.append(contentsOf: tempDateArr)
            }
        }
        return dateArray.reversed()
    }
    
//MARK: - UserNotificationCenter Delegate functions
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.sound, .list, .banner])
        return
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let addInfoString = response.notification.request.content.userInfo["addInfo"] as? String{
            let json = NotificationHandler.getNotificationJson(addInfo: addInfoString)
            if !json.isEmpty{
                NotificationHandler.onTapNotification(json: json)
            }
        }
        else{
            setReminderContentFromNotification(json: nil, response: response)
        }
        completionHandler()
    }
    
//MARK: - NotificationSetAndDelete
    
    private func setNotificationForAllReminders(){
        
        var reminderObjList: [Reminder] = []
        let patientMObjList = coreDataUtil.getPatientMObjList()
        patientMObjList?.forEach({ patientMObj in
            reminderObjList.append(contentsOf: ReminderHandler.getReminderObjList(patientId: patientMObj.patientId))
        })
       
        reminderObjList = reminderObjList.filter({ reminderObj in
            if let endDate = reminderObj.endDate{
                return reminderObj.isReminderDeleted == false && endDate.startOfDay >= Date().startOfDay
            }
            return false
        })
        
        reminderObjList.forEach({ reminderObj in
            addOrUpdateNotification(reminderObj: reminderObj)
        })
    }
    
    private func deleteNotificationForCompletedDays(){
        
        let notificationMObjList = coreDataUtil.getReminderNotificationMObjList()
        notificationMObjList?.forEach({ reminderNotificationMObj in
            if let dateString = reminderNotificationMObj.notificationId?.components(separatedBy: "_").first,
               let dateObj = Date.getDateFromString(dateFormat: ReminderDateWithTimeFormat, dateString: dateString){
                if dateObj.startOfDay <= Date().minus(days: notificationDays - 1).startOfDay{
                    deleteNotification(object: reminderNotificationMObj)
                }
            }
        })
    }
    
    func deleteAndSetNotification(){
        deleteNotificationForCompletedDays()
        setNotificationForAllReminders()
    }
    
//MARK: - Set ReminderContent From Notification
        
    func setReminderContentFromNotification(json: [String: Any]?, response: UNNotificationResponse?){
            
        let notificationObj = NotificationObj()
        var patientId: String? = nil
        var notificationId: String? = nil
        
        if let response{
            notificationObj.moduleId = reminderModelId
            notificationId = response.notification.request.identifier
            patientId = notificationId?.components(separatedBy: "_").last
        }
        else if let json{
            notificationObj.moduleId = json.getString("module")
            notificationId = json.getString("notificationId")
            patientId = json.getString("patient_id")
        }
        notificationObj.patientId = patientId
        
        if let reminderNotificationMObj = coreDataUtil.getReminderNotificationMObj(notificationId: notificationId), 
            let reminderIdArray = reminderNotificationMObj.reminderIdList?.components(separatedBy: ","),
           let dateTimeString = notificationId?.components(separatedBy: "_").first{

            let dateTimeObj = Date.getDateFromString(dateFormat: ReminderDateWithTimeFormat, dateString: dateTimeString)
            
            let todayReminderPOJO = TodayReminderPOJO()
            todayReminderPOJO.time = dateTimeObj
            
            let timeString = dateTimeObj?.getStringFromDate(dateFormat: Time24HoursFormat) ?? ""
            
            var reminderPOJOList:[ReminderPOJO] = []
            
            reminderIdArray.forEach({ reminderId in
                if let reminderObj = ReminderHandler.getReminderObj(reminderId: reminderId, patientId: patientId){
                    
                    let reminderPOJO = ReminderPOJO()
                    var reminderDetails: ReminderDetails? = nil
                    let reminderHistoryDetail = ReminderHistoryDetail()
                    
                    if reminderObj.reminderType == SUPPLEMENT{
                                                
                        if let stringArr = PatientDataHandler.formSupplementTitleAndDescription(patientSupplementId: reminderObj.moduleId, patientId: patientId)?.components(separatedBy: "_"){
                            
                            reminderDetails = ReminderDetails()
                            reminderDetails?.moduleType = ReminderModuleEnum.supplement
                            reminderDetails?.title = stringArr.first
                            reminderDetails?.descripiton = stringArr.last
                        }
                    }
                    else if reminderObj.reminderType == MEDICATION{
                        
                        if let stringArr = PatientDataHandler.formMedicationTitleAndDescription(patientMedicationId: reminderObj.moduleId, patientId: patientId)?.components(separatedBy: "_"){
                            
                            reminderDetails = ReminderDetails()
                            reminderDetails?.moduleType = ReminderModuleEnum.medication
                            reminderDetails?.title = stringArr.first
                            reminderDetails?.descripiton = stringArr.last
                        }
                    }
                    if let reminderId = reminderObj.reminderId{
                        reminderHistoryDetail.reminderHistoryPrimaryKey = "\(timeString)-\(reminderId)"
                    }
                    
                    if let reminderDetails = reminderDetails{
                        reminderDetails.reminder = reminderObj
                        reminderPOJO.reminderDetails = reminderDetails
                        reminderPOJO.reminderHistoryDetail = reminderHistoryDetail
                        reminderPOJOList.append(reminderPOJO)
                    }
                }
            })
            todayReminderPOJO.reminderPOJOList = reminderPOJOList
            notificationObj.moduleObj = todayReminderPOJO
            
            appDelegate.notificationObj = notificationObj
        }
        
        if isValidNotificationId(notificationId){
            LocalNotificationUtil.presentReminderDetailDialogOnDidReceiveNotification()
        }
    }
    
    private func isValidNotificationId(_ input: String?) -> Bool {
        guard let input = input else { return false }
        let pattern = "^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}_\\d+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: input)
    }
    
//MARK: - Present Notification methods
    
    static func presentReminderDetailDialogOnDidReceiveNotification(){
        
        appDelegate.dismissPresentedAlertVC()
        appDelegate.dismissAndCatchPresentedVC()
        
        if let topViewController = appDelegate.navigationController?.topViewController{
            
            if let vc = topViewController as? SelectPatientViewController{
                vc.selectPatientForNotification()
            }
            else if !(topViewController is LockScreenViewController) && !(topViewController is LoginViewController){
                presentReminderDetailDialogViewController(vc: topViewController)
            }
        }
    }
    
    static private func presentReminderDetailDialogViewController(vc: UIViewController){
        
        if let notificationObj = appDelegate.notificationObj, notificationObj.moduleId == reminderModelId{
            if let todayReminderPOJO = appDelegate.notificationObj?.moduleObj as? TodayReminderPOJO{
                
                if todayReminderPOJO.reminderPOJOList.isEmpty{
                    CharmUtil.showToast(controller: vc, message: getString(key: "com.charmphr.reminder.notification.noMedication.noSupplement.toast.message"), seconds: 2)
                }
                else{
                    let reminderDetailDialogViewController = ReminderDetailDialogViewController(todayReminderPOJO: todayReminderPOJO, isFromNotification: true, timeObj: todayReminderPOJO.time, patientId: appDelegate.notificationObj?.patientId)
                    
                    if let reminderVC = vc as? ReminderViewController{
                        reminderDetailDialogViewController.historyDelegate = reminderVC
                    }
                    else if let reminderHistoryVC = vc as? ReminderHistoryViewController{
                        reminderDetailDialogViewController.historyDelegate = reminderHistoryVC
                    }
                    reminderDetailDialogViewController.modalPresentationStyle = .overCurrentContext
                    reminderDetailDialogViewController.modalTransitionStyle = .crossDissolve
                    vc.navigationController?.present(reminderDetailDialogViewController, animated: true)
                }
            }
            else{
                CharmUtil.showToast(controller: vc, message: getString(key: "com.charmphr.reminder.notification.noReminder.toast.message"), seconds: 2)
            }
            appDelegate.notificationObj = nil
        }
    }
}

class NotificationObj{
    var moduleId: String? = nil
    var moduleObj: Any? = nil
    var patientId: String? = nil
    var switchPatientObj: Patient? = nil
}
