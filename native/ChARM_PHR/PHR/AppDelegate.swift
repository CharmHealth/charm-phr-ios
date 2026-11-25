//
//  AppDelegate.swift
//  phr
//
//  Created by Dhanuprasanya P on 11/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//


import UIKit
// TODO(Apptics): disabled until verified; re-enable later
//import Apptics
//import AppticsRateUs
//import AppticsInAppUpdate
import PhotosUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , CharmAppWindowDelegate, UNUserNotificationCenterDelegate
{
    // window/navigationController are owned by SceneDelegate (see SceneDelegate.swift) since the app
    // adopted the UIScene lifecycle; these proxy through to it so the rest of the app can keep reading
    // appDelegate.window / appDelegate.navigationController unchanged.
    var window: UIWindow? {
        get { SceneDelegate.shared?.window }
        set { SceneDelegate.shared?.window = newValue }
    }

    var navigationController: UINavigationController? {
        SceneDelegate.shared?.navigationController
    }

    var screenWidth : CGFloat = 0
    var screenHeigth : CGFloat = 0

    private var presentedNotificationVC: ReminderDetailDialogViewController? = nil
    var isAppUnLocked: Bool = false
    var notificationObj: NotificationObj? = nil
    var isUserSignedInAlready: Bool = false
    private var currentAlert: (title: String?, message: String?, actions: [UIAlertAction])?
    
//    var openJoinZoomCallVC = false
//    var zoomCallUrl : URL!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.
        // NOTE: Window/navigationController creation now happens in SceneDelegate.scene(_:willConnectTo:options:)
        // since the app is registered for the UIScene lifecycle (see Info.plist UIApplicationSceneManifest).

        // TODO(Apptics): disabled until verified; re-enable later
//        AppticsConfig.default.enableRateUs = true
//        AppticsConfig.default.resetOnDCSwitch = true
//        AppticsConfig.default.enableAutomaticEventTracking = true
//
//
//        Apptics.initialize(withVerbose: true)
//
//
//        // Apptics.setTrackingStatus(true)
//
//        debugPrintLog("tracking -> \(Apptics.trackingStatus())")
//        debugPrintLog("crash report -> \(Apptics.crashReportStatus())")
//        debugPrintLog("Personal Info -> \(Apptics.personalInfoTrackingStatus())")

                
        let center = UNUserNotificationCenter.current()
        center.delegate = self

//SSO kit details are not cleared while uninstalling the app. So we have added this check to clear those detail during at first time launch
        if StandardUserDefaults.value(forKey: "appAlreadylaunched") == nil || StandardUserDefaults.bool(forKey: "appAlreadylaunched") == false
        {
            AuthManager.clearAppPasswordFromKeyChain()
            AuthenticationUtil.clearDetailsForFirstLaunch()
            StandardUserDefaults.set(true, forKey: "appAlreadylaunched")
            StandardUserDefaults.synchronize()
        }
        

//        let serial = DispatchQueue(label: "queueeee")
//        serial.sync {
//
//            if openJoinZoomCallVC
//            {
//                navigationController?.pushViewController(getJoinZoomCallViewController(), animated: true)
//            }
//        }

        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_GRAY_BG_COLOR)
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        return true
    }
    
    func getKeyWindow() -> UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }

        if let window {
            return window
        }
        return nil
    }
    
    //MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session. Not used since multiple scenes are not supported.
    }

    //MARK: - Show LoginVC

    func showLoginView(animated: Bool){
        SceneDelegate.shared?.showLoginView(animated: animated)
    }

    //MARK: - CharmAppWindow Delegate method
    
    func charmAppWindowIdeltimeEnded() {
        if navigationController != nil && navigationController?.topViewController != nil
        {
            dismissAndCatchPresentedAlertVC()
            dismissAndCatchPresentedVC()
            
            let topViewController = navigationController?.topViewController
            
            if !(topViewController is LockScreenViewController) && !(topViewController is LoginViewController) && !(topViewController is JoinZoomCallViewController) && !(topViewController is EasyTelecareBookAppointmentWebViewController)
            {
                isAppUnLocked = false
                let lockScreenVC = LockScreenViewController(lockscreenMode: .validate, isLockedScreenPresentedAtLaunch: false)
                self.navigationController?.pushViewController(lockScreenVC, animated: true)
            }
            else if topViewController is LockScreenViewController{
                (topViewController as? LockScreenViewController)?.appMovedToBackground()
            }
        }
    }
    
    func dismissPresentedAlertVC(){
        
        let keyWindow = getKeyWindow()
        if keyWindow != nil && keyWindow?.rootViewController != nil && keyWindow?.rootViewController?.presentedViewController != nil
        {
            let presentedController = keyWindow?.rootViewController?.presentedViewController
            if presentedController is UIAlertController{
                presentedController?.dismiss(animated: false)
            }
        }
    }
    
    private func dismissAndCatchPresentedAlertVC(){
        
        let keyWindow = getKeyWindow()
        if keyWindow != nil && keyWindow?.rootViewController != nil && keyWindow?.rootViewController?.presentedViewController != nil
        {
            let presentedController = keyWindow?.rootViewController?.presentedViewController
            
            if presentedController is UIAlertController{
                
                NotificationCenter.default.addObserver(self, selector: #selector(showAlertView), name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
                if (presentedController as? UIAlertController)?.alertViewPriority == AlertViewPriorityVeryLow{
                    presentedController?.dismiss(animated: false)
                }
                else{
                    if let alertController = presentedController as? UIAlertController {
                        let title = alertController.title
                        let message = alertController.message
                        let actions = alertController.actions
                        
                        currentAlert = (title: title, message: message, actions: actions)
                        alertController.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else if let vc = keyWindow!.rootViewController!.presentedViewController as? ReminderDetailDialogViewController {
                
                NotificationCenter.default.addObserver(self, selector: #selector(showAlertView), name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
                
                presentedNotificationVC = vc
                presentedNotificationVC?.dismiss(animated: false, completion: nil)
            }
            if presentedController is UIActivityViewController{
                presentedController?.dismiss(animated: false)
            }
        }
        else{
            navigationController?.topViewController?.presentedViewController?.dismiss(animated: false)
        }
//        else if !(navigationController?.topViewController is LoginViewController){
//            navigationController?.topViewController?.presentedViewController?.dismiss(animated: false)
//        }
    }
    
    func dismissAndCatchPresentedVC(){
        
        let topViewController = navigationController?.topViewController
        
        if !(topViewController is LockScreenViewController) && !(topViewController is LoginViewController) && !(topViewController is JoinZoomCallViewController)
        {
            if topViewController is MainViewController{
                (topViewController as? MainViewController)?.dismissAllModalVCPresented()
            }
            else if topViewController is QuestionnaireAnswerViewController{
                (topViewController as? QuestionnaireAnswerViewController)?.dismissAllModalVCPresented()
            }
            else if topViewController is AppointmentsViewController{
                (topViewController as? AppointmentsViewController)?.dismissModalViews()
            }
            else if topViewController is DismissModelViewDelegate {
                (topViewController as? DismissModelViewDelegate)?.dismissModelView()
            }
            else{
                let presentedController = getKeyWindow()?.rootViewController?.presentedViewController
                
                presentedController?.dismiss(animated: false)
            }
        }
    }
    
    @objc func showAlertView(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
        
        if presentedNotificationVC != nil{
            if let presentedNotificationVC = presentedNotificationVC{
                navigationController?.topViewController?.navigationController?.present(presentedNotificationVC, animated: true)
            }
            presentedNotificationVC = nil
        }
        else if let alert = currentAlert
        {
            let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
            
            for action in alert.actions {
                alertController.addAction(action)
            }
            
            alertController.show()
            currentAlert = nil
        }
    }
    
//    func getJoinZoomCallViewController() -> UIViewController
//    {
//        let zoomVC = JoinZoomCallViewController()
//        zoomVC.meetingUrl = self.zoomCallUrl
//        return zoomVC
//    }
    
    //MARK: - Application delegate methods
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if !isMeetingInProgress() {
            charmAppWindowIdeltimeEnded()
        }
    }
    
    // NOTE: Since the app registers a UIApplicationSceneManifest (see Info.plist), the system delivers
    // custom URL scheme opens and universal-link continuations to SceneDelegate (scene(_:openURLContexts:)
    // and scene(_:continue:)) instead of these UIApplicationDelegate methods. The two handlers below are
    // kept as the shared implementation - SceneDelegate calls into them - and left in place here as a
    // fallback for any code path that still targets the app-delegate-only URL/activity APIs.

    @discardableResult
    func handleOpenURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return AuthenticationUtil.handleURL(url, sourceApplication: sourceApplication, annotation: annotation as Any)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return AuthenticationUtil.handleURL(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return AuthenticationUtil.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else { return }
        debugPrintLog("open url = \(url)")

//        if url.absoluteString.contains("/mphr/video.sas") && url.absoluteString.contains("ID=")
//        {
//            self.openJoinZoomCallVC = true
//            self.zoomCallUrl = url
//            navigationController?.pushViewController(getJoinZoomCallViewController(), animated: true)
//            return true
//        }else
//        {
        UIApplication.shared.open(url)
        //}
    }

    func application(_ application: UIApplication,continue userActivity: NSUserActivity,restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        handleUserActivity(userActivity)
        return false
    }
    
    //MARK: - Notification receive
    
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
            NotificationHandler.onTapNotification(json: [:], response: response)
        }
        completionHandler()
    }
    
    //MARK:  Notification delegate Methods
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString: String = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        debugPrintLog("\nPN: deviceTokenString response received  \n")
        debugPrintLog(deviceTokenString)
        PushNotificationHandler.sharedInstance.registerPushNotification(receivedDeviceToken: deviceTokenString)
    }
    
    func application(_ app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error:Error)
    {
        debugPrintLog("\nPN: deviceTokenString response failed  \n")
        debugPrintLog("\(error.localizedDescription)")
    }
}
