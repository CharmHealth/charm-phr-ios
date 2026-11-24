//
//  PushNotificationHandler.swift
//  phr
//
//  Created by Dhanuprasanya P on 30/01/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

class PushNotificationHandler: CharmConnectionV2HandlerDelegate
{
    private static var pushNotificationHandler: PushNotificationHandler!
    static var sharedInstance: PushNotificationHandler {
        if pushNotificationHandler == nil {
            pushNotificationHandler = PushNotificationHandler()
        }
        return pushNotificationHandler
    }
    
    private lazy var charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        
    private var deviceToken: String?
    private var insId: String?
    
    //MARK: - PN data
    
    private func formPushNotificationObj() -> PushNotificationDetailsPOJO
    {
        let pushNotificationDetailsPOJO = PushNotificationDetailsPOJO()
        pushNotificationDetailsPOJO.nfid = StandardUserDefaults.value(forKey: deviceTokenKey) as? String
        pushNotificationDetailsPOJO.insid = StandardUserDefaults.value(forKey: installationIdKey) as? String
        pushNotificationDetailsPOJO.osInfo = UIDevice.current.systemVersion
        pushNotificationDetailsPOJO.deviceInfo = UIDevice.current.model //returns only iphone
        let apnsMode = Bundle.main.infoDictionary?["APNS_MODE"] as? String
        pushNotificationDetailsPOJO.apnsMode = apnsMode
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        pushNotificationDetailsPOJO.appVersion = appVersion
        let deviceuid = UIDevice.current.identifierForVendor!.uuidString
        pushNotificationDetailsPOJO.deviceuid = deviceuid
        pushNotificationDetailsPOJO.mode = 1 // for iOS 1 
        return pushNotificationDetailsPOJO
    }
    
    //MARK: - Register and UnRegerster methods
    
    func register()
    {
        let isPNRegistered = StandardUserDefaults.bool(forKey: isPushNotificationRegistered)
        debugPrintLog("PN: isPNRegistered: \(isPNRegistered)" )
        if !isPNRegistered{
            NotificationHandler.requestNotificationAuthorise({ isAuthorized in
                debugPrintLog("PN: currentStatus: \(isAuthorized)")
                if isAuthorized{
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        debugPrintLog("PN: calling registerForRemoteNotifications: \n")
                    }
                }
            })
        }
    }
    
    func registerPushNotification(receivedDeviceToken: String?)
    {
        self.deviceToken = StandardUserDefaults.value(forKey: deviceTokenKey) as? String
        self.insId = StandardUserDefaults.value(forKey: installationIdKey) as? String
        let isPNRegistered = StandardUserDefaults.bool(forKey: isPushNotificationRegistered)
        debugPrintLog("\nPN deviceToken " + (receivedDeviceToken ?? "") + "\nself.devicetoken" + (self.deviceToken ?? "") + "\n isPNRegistered:")
        debugPrintLog(isPNRegistered)
        if(receivedDeviceToken != self.deviceToken || !isPNRegistered){
            
            self.deviceToken = receivedDeviceToken
            StandardUserDefaults.set(receivedDeviceToken, forKey: deviceTokenKey)
            StandardUserDefaults.synchronize()
            if(self.insId != nil)
            {
                let str = "\nPN: calling sendRegistrationInfoForPushNotifiations with self.insId"
                debugPrintLog(str)
                sendRegistrationInfoForPushNotifiations()
            }
            else{
                getInsId()
            }
        }
    }
    
    func unRegisterPushNotification(completion: @escaping () -> Void){
        charmConnectionHandler.unregisterPushNotification(pushNotificationDetailsPojo: self.formPushNotificationObj()) { _ in
            StandardUserDefaults.set(false, forKey: isPushNotificationRegistered)
            StandardUserDefaults.synchronize()
            completion()
        } failure: { error in
            debugPrintLog("UnRegister failed")
            completion()
        }
    }
    
    func resetValues()
    {
        PushNotificationHandler.pushNotificationHandler = nil
    }
    
    //MARK: - ConnectionEstablishment methods
    
    private func getInsId()
    {
        charmConnectionHandler.getInstallationId(identificationKey: "getInsId")
    }
    private func sendRegistrationInfoForPushNotifiations()
    {
        let str = "\nPN:sendRegistrationInfoForPushNotifiations called"
        debugPrintLog(str)
        charmConnectionHandler.registerPushNotification(pushNotificationDetailsPojo: self.formPushNotificationObj(), identificationKey: "registerPushNotification")
    }
    private func sendNotification()
    {
        charmConnectionHandler.sendPushNotification(message: "test", additionalInfo: "additional_info", identificationKey: "sendNotification")
    }
    
    //MARK: - CharmConnectionHandler Delegates
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if(identificationKey == "getInsId")
        {
            let respObj = response as? Dictionary<String, Any>
            let opDict = respObj?["output_string"] as? Dictionary<String, Any>
            let insId = opDict?["installation_id"] as? String
            
            if(insId != nil){
                self.insId = insId
                StandardUserDefaults.set(insId, forKey: installationIdKey)
                StandardUserDefaults.synchronize()
                let str = "\nPN:calling registerPushNotification api after receiving insid response"
                debugPrintLog(str)
                sendRegistrationInfoForPushNotifiations()
            }
            else{
                StandardUserDefaults.set(false, forKey: isPushNotificationRegistered)
                StandardUserDefaults.synchronize()
            }
        }
        else if(identificationKey == "registerPushNotification")
        {
            StandardUserDefaults.set(true, forKey: isPushNotificationRegistered)
            StandardUserDefaults.synchronize()
            let registerdStr = "nPN:Registered successfully"
            debugPrintLog(registerdStr)
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if(identificationKey == "getInsId")
        {
            StandardUserDefaults.set(false, forKey: isPushNotificationRegistered)
            StandardUserDefaults.synchronize()
        }
        else if(identificationKey == "registerPushNotification")
        {
            StandardUserDefaults.set(false, forKey: isPushNotificationRegistered)
            StandardUserDefaults.synchronize()
            let registerdStr = "PN:Register failed"
            debugPrintLog(registerdStr)
        }
    }
    
    static func onTapPushNotification(json: [String: Any]){
        
        let notificationObj = NotificationObj()
        let moduleId = json.getString("module")?.lowercased()
        notificationObj.moduleId = moduleId
        notificationObj.patientId = json.getString("patient_id")
        
        if moduleId == messageModuleId{
            let messages = Messages()
            messages.messageId = json.getString("message_id")
            messages.practiceId = json.getString("practice_id")
            
            notificationObj.moduleObj = messages
        }
        
        let selectedPatient = getSelectedPatient()
        if !(selectedPatient.patientId.isNilOrBlank() || selectedPatient.patientId == notificationObj.patientId),
            let patientObj = getPatientObj(patientId: notificationObj.patientId){
            notificationObj.switchPatientObj = patientObj
        }
        appDelegate.notificationObj = notificationObj
        pushToSelectedModule()
    }
    
    static func pushToSelectedModule(){
        
        let moduleId = appDelegate.notificationObj?.moduleId
        let topViewController = appDelegate.navigationController?.topViewController
        if let vc = topViewController as? SelectPatientViewController{
            vc.selectPatientForNotification()
        }
        else if !(topViewController is LockScreenViewController) && !(topViewController is LoginViewController){
            
            let keyWindow = appDelegate.getKeyWindow()
            if keyWindow != nil && keyWindow?.rootViewController != nil && keyWindow?.rootViewController?.presentedViewController != nil
            {
                let presentedController = keyWindow?.rootViewController?.presentedViewController
                presentedController?.dismiss(animated: false)
            }
            
            if let patientObj = appDelegate.notificationObj?.switchPatientObj{
                CharmUtil.createYesAndNoAlertWith(title: getString(key: "com.charmphr.pushNotification.switchPatient.alert.title", with: [patientObj.fullName ?? "", moduleId ?? ""]), msg: getString(key: "com.charmphr.pushNotification.switchPatient.alert.message"), yesClicked: {
                    appDelegate.notificationObj?.switchPatientObj = nil
                    AuthManager.switchPatient(patientObj: patientObj)
                }, noClicked: {
                    appDelegate.notificationObj = nil
                })
            }
            else{
                if moduleId == messageModuleId, let messages = appDelegate.notificationObj?.moduleObj as? Messages{
                    
                    if topViewController is MessageDetailViewController || topViewController is MessagesViewController || topViewController is ComposeMessageViewController{
                        AppDataHandler.sharedInstance().reloadMessage = true
                    }
                    
                    if let vc = topViewController as? MessageDetailViewController{
                        vc.navigationController?.popViewController(animated: false)
                    }
                    
                    let messageDetailVC = MessageDetailViewController(message: messages, delegate: nil)
                    appDelegate.navigationController?.topViewController?.navigationController?.pushViewController(messageDetailVC, animated:  true)
                }
                appDelegate.notificationObj = nil
            }
        }
    }
}

class NotificationHandler{
    
    static func onTapNotification(json: [String: Any], response: UNNotificationResponse? = nil){
        if let response{
            let notificationUtil = LocalNotificationUtil.sharedInstance
            notificationUtil.setReminderContentFromNotification(json: nil, response: response)
        }
        else{
            if json.getString("module") == reminderModelId{
                
                let notificationUtil = LocalNotificationUtil.sharedInstance
                notificationUtil.setReminderContentFromNotification(json: json, response: nil)
            }
            else{
                PushNotificationHandler.onTapPushNotification(json: json)
            }
        }
    }
    
    static func requestNotificationAuthorise(_ completion: @escaping ((Bool) -> Void))
    {
        var authorizationOption: UNAuthorizationOptions = [.alert, .sound,]
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOption) { isAuthorised, _ in
            completion(isAuthorised)
        }
    }
    
    static func presentNotification(){
        if let notificationObj = appDelegate.notificationObj{
            if notificationObj.moduleId == reminderModelId{
                LocalNotificationUtil.presentReminderDetailDialogOnDidReceiveNotification()
            }
            else{
                PushNotificationHandler.pushToSelectedModule()
            }
        }
    }
    
    static func getNotificationJson(addInfo: String?) -> [String: Any]{
        var dict: [String: Any] = [:]
        
        if let addInfo, let data = addInfo.data(using: .utf8){
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    dict = json
                    debugPrintLog("Parsed JSON: \(json)")
                }
            } catch {
                debugPrintLog("Failed to parse JSON: \(error.localizedDescription)")
            }
        }
        return dict
    }
    
    static func deleteDeliveredNotification(moduleId: String, id: String?){
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            for notification in notifications {
                let userInfo = notification.request.content.userInfo
                let json = NotificationHandler.getNotificationJson(addInfo: userInfo["addInfo"] as? String)
                if moduleId == messageModuleId && json.getString("message_id") == id{
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                }
                debugPrintLog("Delivered notification: \(userInfo)")
                debugPrintLog("Identifier: \(notification.request.identifier)")
            }
        }
    }
}
