//
//  AuthManager.swift
//  ChARM PHR
//
//  Created by Sankar Saravanan on 01/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import Foundation
import UIKit

fileprivate let KEYCHAIN_ACCESS_GROUP = "com.charm.phr.mphr"
fileprivate let KEYCHAIN_STORE_SERVICE_USER_INFO = "UserInfo"

fileprivate let KEYCHAIN_APP_PASSWORD_KEY = "appPassword"
fileprivate let KEYCHAIN_ENCRYPTION_KEY = "encryptionkey"

struct AuthManager {

    private static let keyChain = UICKeyChainStore(service: KEYCHAIN_STORE_SERVICE_USER_INFO)

//MARK: - app password in keychain

    static func clearAppPasswordFromKeyChain()
    {
        keyChain.removeItem(forKey: KEYCHAIN_APP_PASSWORD_KEY)
    }

    static func setAppPasswordInKeyChain(appPasword : String)
    {
        keyChain.setData(appPasword.data(using: .utf8), forKey: KEYCHAIN_APP_PASSWORD_KEY)
    }

    static func getAppPasswordInKeyChain( ) -> String?
    {
        if let data = keyChain.data(forKey: KEYCHAIN_APP_PASSWORD_KEY)
        {
            let str = String(data: data, encoding: .utf8)
            if str.isNilOrBlank(){
                return nil
            }
            return str
        }else
        {
            return nil
        }
    }
    
    static private func clearEncrptionkeyFromKeyChain()
    {
        keyChain.removeItem(forKey: KEYCHAIN_ENCRYPTION_KEY)
    }

    static func setEncrptionkeyInKeyChain(encrptionkey : String)
    {
        keyChain.setData(encrptionkey.data(using: .utf8), forKey: KEYCHAIN_ENCRYPTION_KEY)
    }

    static func getEncrptionkeyInKeyChain() -> String?
    {
        if let data = keyChain.data(forKey: KEYCHAIN_ENCRYPTION_KEY)
        {
            let str = String(data: data, encoding: .utf8)
            if str.isNilOrBlank(){
                return nil
            }
            return str
        }else
        {
            return nil
        }
    }
    
    static func switchPatient(patientObj: Patient){
        let topViewController = appDelegate.navigationController?.topViewController
        
        Patient.selectedPatientInstance = patientObj
        CharmConnectionHandler.invalidateSession()
        AppDataHandler.resetInstance()
        
        if let mainVC = topViewController as? MainViewController{
            mainVC.appDataHandler = AppDataHandler.sharedInstance()
            mainVC.hideAddBtn()
            mainVC.loadSubView()
            NotificationHandler.presentNotification()
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "homeVC") as? HomeViewController {
                let mainVC = MainViewController(homeVC: homeVC)
                appDelegate.navigationController?.setViewControllers([mainVC], animated: false)
            }
        }
    }
    
    //MARK: - logout actions
    
    static private func logoutUser(completion: @escaping (_ isLoggedOut: Bool) -> Void)
    {
        if isCustomApp() || AuthenticationUtil.isUserSignedIn() {
            AuthenticationUtil.revokeAccessToken(completion: { (error) in
                DispatchQueue.main.async {
                    if error == nil
                    {
                        trackEvent(eventName: "LogoutOnSuccess", withGroupName: "Account")
                        completion(true)
                    }else
                    {
                        debugPrintLog("revoke access token \(error!)")
                        completion(false)
                    }
                }
            })
        }
    }
    
    static private func logoutUserDuringInvalidOAuth()
    {
        if isCustomApp() {
            AuthenticationUtil.checkAndLogout{  (logoutError) in
                DispatchQueue.main.async {
                    AuthenticationUtil.clearDetailsForFirstLaunch()
                    afterLogoutOperations()
                    let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.logout.session.expired"), preferredStyle: .alert)
                    alertVC.alertViewPriority = AlertViewPriorityMedium
                    let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.logout"), style: .default, handler: { (UIAlertAction) in
                        appDelegate.showLoginView(animated: true)
                    })
                    alertVC.addAction(okAction)
                    alertVC.show()
                }
            }
            
        }
    }
    
    static func logoutUserForMigration( completion: @escaping (() -> Void)) {
        unregisterPushNotification {
            logoutUser { [self] isLoggedOut in
                afterLogoutOperations()
                AuthenticationUtil.clearDetailsForFirstLaunch()
                completion()
            }
        }
    }
    
    static func logoutUser(isInvalidOAuth: Bool, completion: (() -> Void)? = nil){
        
        debugPrintLog("Logout Called")
        let isUserSignedIn: Bool = AuthenticationUtil.isUserSignedIn()
        
        if isUserSignedIn{
            if isInvalidOAuth{
                logoutUserDuringInvalidOAuth()
                completion?()
            }
            else{
                unregisterPushNotification {
                    logoutUser { [self] isLoggedOut in
                        afterLogoutOperations()
                        if !isLoggedOut{
                            AuthenticationUtil.clearDetailsForFirstLaunch()
                        }
                    }
                    appDelegate.showLoginView(animated: true)
                    completion?()
                }
            }
        }
        else{
            afterLogoutOperations()
            completion?()
        }
    }
    
    static private func unregisterPushNotification(completion: @escaping () -> Void){
        let isPNRegistered = StandardUserDefaults.bool(forKey: isPushNotificationRegistered)
        if(isPNRegistered){
            PushNotificationHandler.sharedInstance.unRegisterPushNotification {
                completion()
            }
        }
        else{
            completion()
        }
    }
    
    static private func afterLogoutOperations()
    {
        resetDBAndNotification()
        
        CharmConnectionHandler.invalidateSession()
        Patient.selectedPatientInstance = nil
        Patient.patientList = nil
        AppDataHandler.resetInstance()
        PrimaryDataHandler.resetInstance()
        RbacUtil.resetInstance()

        PushNotificationHandler.sharedInstance.resetValues()
        clearAppPasswordFromKeyChain()
        clearEncrptionkeyFromKeyChain()
        
        StandardUserDefaults.removeObject(forKey: isStandardVitalUnitKey)
        StandardUserDefaults.removeObject(forKey: laPrefShownKey)
        StandardUserDefaults.removeObject(forKey: deviceTokenKey)
        StandardUserDefaults.removeObject(forKey: installationIdKey)
        StandardUserDefaults.removeObject(forKey: isPushNotificationRegistered)
        StandardUserDefaults.removeObject(forKey: rbacPreferenceKey)
        StandardUserDefaults.removeObject(forKey: hkPreferenceKey)
        StandardUserDefaults.synchronize()
    }
    
    static private func resetDBAndNotification(){
        
        LocalNotificationUtil.sharedInstance.cancelAllNotification()
        LocalNotificationUtil.sharedInstance.resetInstance()
        
        mPHRCoreDataUtil.sharedInstance.deletemPHRCoreDataValues()
        mPHRCoreDataUtil.sharedInstance.resetInstance()
    }
}
