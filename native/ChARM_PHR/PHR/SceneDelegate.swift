//
//  SceneDelegate.swift
//  phr
//
//  Added to adopt the UIScene lifecycle (required to run on newer iOS/Xcode versions).
//  Mirrors the SceneDelegate pattern used in the ChARM Chart Notes app: window and
//  navigationController are owned here, with AppDelegate proxying to SceneDelegate.shared
//  so the rest of the app can keep reading appDelegate.window / appDelegate.navigationController.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static var shared: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return nil
        }
        return sceneDelegate
    }

    var window: UIWindow?
    var navigationController: UINavigationController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        let charmAppWindow = CharmAppWindow(windowScene: windowScene)
        charmAppWindow.autoLockTime = 10
        charmAppWindow.delegate = appDelegate

        window = charmAppWindow

        AuthenticationUtil.initAuth()

//SSO kit details are not cleared while uninstalling the app. So we have added this check to clear those detail during at first time launch
        if StandardUserDefaults.value(forKey: "appAlreadylaunched") == nil || StandardUserDefaults.bool(forKey: "appAlreadylaunched") == false
        {
            AuthManager.clearAppPasswordFromKeyChain()
            AuthenticationUtil.clearDetailsForFirstLaunch()
            StandardUserDefaults.set(true, forKey: "appAlreadylaunched")
            StandardUserDefaults.synchronize()
        }

        initiateNavigationController()

        appDelegate.screenWidth = windowScene.screen.bounds.width
        appDelegate.screenHeigth = windowScene.screen.bounds.height

        charmAppWindow.makeKeyAndVisible()

        // Cold-launch case: the app was opened directly via a URL scheme (e.g. the CharmAuth SSO
        // redirect) or a universal link, so the context arrives here instead of via the methods below.
        if let urlContext = connectionOptions.urlContexts.first {
            appDelegate.handleOpenURL(urlContext.url, sourceApplication: urlContext.options.sourceApplication, annotation: urlContext.options.annotation)
        }

        if let userActivity = connectionOptions.userActivities.first {
            appDelegate.handleUserActivity(userActivity)
        }
    }

    // Warm-launch case: the app was already running/suspended when the URL scheme redirect or
    // universal link arrived (e.g. returning from the CharmAuth SSO browser sign-in).
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            appDelegate.handleOpenURL(context.url, sourceApplication: context.options.sourceApplication, annotation: context.options.annotation)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        appDelegate.handleUserActivity(userActivity)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }

    //MARK: - Initiate NavigationController

    private func initiateNavigationController()
    {
        if isCustomApp()
        {
            if AuthenticationUtil.isUserSignedIn(){
                initiateLockScreenVC()
            }
            else{
                initiateLoginVC()
            }
        }
        else{
            if AuthenticationUtil.isUserSignedIn() {
                initiateLockScreenVC()
            }
            else{
                initiateLoginVC()
            }
        }
        window?.rootViewController = navigationController
    }

    //MARK: - Initiate ViewControllers

    private func initiateLoginVC(isZohoAuthMigration: Bool = false){
        appDelegate.isUserSignedInAlready = false

        let loginVC = LoginViewController()
        loginVC.isAuthMigration = isZohoAuthMigration
        navigationController = UINavigationController.init(rootViewController: loginVC)
        navigationController?.isNavigationBarHidden = true
    }

    private func initiateLockScreenVC(){
        appDelegate.isUserSignedInAlready = true
        let lockScreenVC = LockScreenViewController(isLockedScreenPresentedAtLaunch: true)
        self.navigationController = UINavigationController(rootViewController: lockScreenVC)
    }

    //MARK: - Show LoginVC

    func showLoginView(animated: Bool){
        UserDefaults.standard.set(true, forKey: hkScopePreferenceKey)
        UserDefaults.standard.synchronize()
        appDelegate.isUserSignedInAlready = false

        if !(navigationController?.topViewController is LoginViewController) {
            let loginViewController = LoginViewController()
            navigationController?.setViewControllers([loginViewController], animated: animated)
        }
    }
}
