//
//  LockScreenViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 27/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import CharmAuthKit

public enum LockMode {
  case validate
  case create
  case reAuth
}

class LockScreenViewController: UIViewController, CharmConnectionV2HandlerDelegate, PatientDataHandlerDelegate {
    
    private let LIGHT_GRAY_BG_COLOR : UInt = 0x0000001A
    @IBOutlet weak var mPinView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnContainerView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    private let logoutLayout = UIView()
    private var passwordTF:UITextField? = nil
    
    private let acitivityIndicator = UIActivityIndicatorView()
    private var charmConnectionHandler : CharmConnectionHandler?
    private var patientDataHandler : PatientDataHandler?
    
    private var numberOfTimeMPinEntered = 0
    private let NUMBER_OF_PIN = 5
    
    private var lockscreenMode : LockMode?
    private var isLockedScreenPresentedAtLaunch : Bool = true
    private var mPHRPin : String? = nil
    private var mPinEntered = ""
    private var isLAShown = false
    private var isPatientFetched: Bool? = nil
    private var isUnlocked: Bool? = nil
    private var patientFetchError: Error? = nil
    private var shouldLogoutAfterPatientFetch = false
    private let appName: String = AppConfig.sharedInstance.appDisplayName ?? "PHR"
    
    init(lockscreenMode : LockMode? = nil , isLockedScreenPresentedAtLaunch : Bool) {
        super.init(nibName: nil, bundle: nil)
        self.mPHRPin = AuthManager.getAppPasswordInKeyChain()
        self.lockscreenMode = lockscreenMode
        self.isLockedScreenPresentedAtLaunch = isLockedScreenPresentedAtLaunch
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrintLog("ViewWillAppear")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debugPrintLog("ViewWillDisappear")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        debugPrintLog("ViewDidDisappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyUser()
    }
    
    private func verifyUser(){
        
        LocalNotificationUtil.sharedInstance.deleteAndSetNotification()

        if lockscreenMode == nil{
            lockscreenMode = getLockScreenMode()
        }
        
        if lockscreenMode == .reAuth {
            reAuthPage()
        }
        else{
            if PermissionUtil.hasLocalAuthentication(){
                isLAShown = true
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
                
                validateLocalAuthPage()
                fetchPatientList()
                
                let isScopeEnhanced = UserDefaults.standard.bool(forKey: hkScopePreferenceKey) // If you want to enhance the scope , then change the value of this key
                
                if isScopeEnhanced {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6, execute: {
                        let state = UIApplication.shared.applicationState
                        
                        if state == .active {
                            self.onUnlockClicked()
                            debugPrintLog("load: foreground")
                        }
                        else{
                            debugPrintLog("load: background")
                        }
                    })
                }
                else{
                    enhanceScope()
                }
            }
            else{
                if lockscreenMode == .create {
                    createMPinPage()
                }
                else{
                    validateMPinPage()
                    let isScopeEnhanced = UserDefaults.standard.bool(forKey: hkScopePreferenceKey)

                    if !isScopeEnhanced {
                        enhanceScope()
                    }
                }
            }
        }
    }
    
    private func enhanceScope(){
        CharmUtil.createOkayAlertWith(title: "", msg: getString(key: "com.charmphr.scope.enhancement.msg"), okClicked: {
            self.showActivityIndicator()
            AuthenticationUtil.enhanceScopes{ accesstoken , error in
                DispatchQueue.main.async(execute: {
                    self.hideActivityIndicator()
//                    if let error {
//                        if (error as NSError).code == 1006 {
//                            UserDefaults.standard.set(true, forKey: hkScopePreferenceKey)
//                            UserDefaults.standard.synchronize()
//                            self.onUserVerificationSuccess()
//                        }
//                        else{
//                            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
//                                self.enhanceScope()
//                            }, cancelClicked: {
//                                if Patient.patientList != nil && Patient.patientList?.count ?? 0 > 0 {
//                                    AuthManager.logoutUser(isInvalidOAuth: false)
//                                } else {
//                                    self.shouldLogoutAfterPatientFetch = true
//                                    self.fetchPatientList()
//                                }
//                            })
//                        }
//                    }
//                    else{
                    if accesstoken != nil {
                        UserDefaults.standard.set(true, forKey: hkScopePreferenceKey)
                        UserDefaults.standard.synchronize()
                        self.onUserVerificationSuccess()
                    }
                    else{
                        CharmUtil.createRetryAndCancelAlertWith(error: error ?? CharmAuthError.other("Unexpected response"), tryAgainClicked: {
                            self.enhanceScope()
                        }, cancelClicked: {
                            if Patient.patientList != nil && Patient.patientList?.count ?? 0 > 0 {
                                AuthManager.logoutUser(isInvalidOAuth: false)
                            } else {
                                self.shouldLogoutAfterPatientFetch = true
                                self.fetchPatientList()
                            }
                        })
                    }
                })
            }
        })
    }
    
    private func getLockScreenMode() -> LockMode{
        
        if PermissionUtil.hasLocalAuthentication(){
            return.validate
        }
        else if !isNilOrEmpty(string: AuthManager.getAppPasswordInKeyChain())
        {
            return .validate
        }
        else{
            return .reAuth
        }
    }
    
//MARK: - Api call methods
    
    private func fetchPatientList()
    {
        if Patient.patientList == nil || Patient.patientList?.count == 0
        {
            showActivityIndicator()
            
            patientFetchError = nil
            isPatientFetched = nil
            
            patientDataHandler = PatientDataHandler(delegate: self)
            patientDataHandler?.fetchPatientList()
        }
        else{
            isPatientFetched = true
            validatePatientDataAndUnlock()
        }
    }
    
//MARK: - Validate mPin
    
    private func validateMPin()
    {
        if mPinEntered == mPHRPin
        {
            if lockscreenMode == LockMode.create{
                AuthManager.setAppPasswordInKeyChain(appPasword: mPinEntered)
            }
            mPinEnteredCorrectly()
        }else
        {
            if LockMode.validate == lockscreenMode
            {
                numberOfTimeMPinEntered += 1
            }
            incorrectPinAnimation()
        }
    }
    
    private func incorrectPinAnimation() {
        mPinView.shake()
        mPinEntered = ""
        
        unSelectAllDot()
        
        if numberOfTimeMPinEntered >= 1 {
            cancelBtn.isHidden = false
        }
        
        if numberOfTimeMPinEntered >= 3 && lockscreenMode == LockMode.validate
        {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.lockscreen.passwordExceeded")) {
                self.logoutUser()
                self.view.isUserInteractionEnabled = false
            }
        }
    }
    
    private func mPinEnteredCorrectly()
    {
        isUnlocked = true
        validatePatientDataAndUnlock()
    }
    
    private func validatePatientDataAndUnlock(){
        if let isUnlocked = isUnlocked, let isPatientFetched = isPatientFetched{
            if isUnlocked && isPatientFetched{
                onUserVerificationSuccess()
            }
            else if !isUnlocked && isPatientFetched{
                CharmUtil.createRetryAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.local.authentication.failed.message"), tryAgainClicked: {
                    self.onUnlockClicked()
                })
            }
            else if isUnlocked && !isPatientFetched{
                patientFailureHandler(error: patientFetchError)
            }
            else if !isUnlocked && !isPatientFetched{
                CharmUtil.createRetryAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.local.authentication.failed.message"), tryAgainClicked: {
                    self.onUnlockClicked()
                })
            }
        }
    }
    
//MARK: - On UserVerification Success methods
    
    private func onUserVerificationSuccess(){
        
        appDelegate.isAppUnLocked = true
        NotificationHandler.requestNotificationAuthorise { [weak self] isAuthorised in
            if isAuthorised{
                if appDelegate.isUserSignedInAlready{
                    ReminderHandler.sharedInstance.fetchReminderList()
                }else{
                    self?.patientDataHandler?.fetchReminderMetaData()
                }
                PushNotificationHandler.sharedInstance.register()
            }
        }
        
        if isLockedScreenPresentedAtLaunch{
            FileUtil.removeAllTempFile()
            showPatientSelectVCorDashboardVC()
        }
        else{
            self.navigationController?.popViewController(animated: true)
            NotificationHandler.presentNotification()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SESSION_UN_LOCKED"), object: nil)
    }
    
    private func showPatientSelectVCorDashboardVC(){
        if Patient.patientList?.count == 1{
            Patient.selectedPatientInstance = Patient.patientList?.getElement(at: 0)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "homeVC") as? HomeViewController {
                self.navigationController?.setViewControllers([homeVC], animated: true)
            }
        }
        else{
            if let patientList = Patient.patientList{
                let selectPatientVC = SelectPatientViewController()
                selectPatientVC.arrayOfPatient = patientList
                self.navigationController?.pushViewController(selectPatientVC, animated: true)
            }
        }
    }
    
//MARK: - Other methods
    
    private func onPasswordVerificationSuccess(){
        logoutLayout.removeFromSuperview()
        self.lockscreenMode = .create
        createMPinPage()
    }
    
    private func logoutUser(){
        AuthManager.logoutUser(isInvalidOAuth: false) {
            self.hideActivityIndicator()
        }
    }
    
//MARK: - Target functions
    
    @objc private func onPasswordVerifyClicked(){
        
        let pwd = passwordTF?.text ?? ""
        if pwd.isNotBlank() {
            if charmConnectionHandler == nil {
                charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
            }
            showActivityIndicator()
            charmConnectionHandler?.verifyUser(password: pwd, identificationKey: "verifyPassword")
        }
        else{
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.lockscreen.password.placeHolder"))
        }
    }
    
    @objc private func onUnlockClicked(){
        
        if isUnlocked == nil || isUnlocked == false{
            isUnlocked = nil
            PermissionUtil.evaluateAuthentication(success: {
                
                let isLAPrefShown = StandardUserDefaults.bool(forKey: laPrefShownKey)
                if !isLAPrefShown{
                    StandardUserDefaults.setValue(true, forKey: laPrefShownKey)
                    StandardUserDefaults.synchronize()
                    AuthManager.clearAppPasswordFromKeyChain()
                }
                self.mPinEnteredCorrectly()
            }, failure: { [self]error in
                if error != .cancelled {
                    isUnlocked = false
                    validatePatientDataAndUnlock()
                }
            })
        }
        else{
            fetchPatientList()
        }
    }
    
    @objc private func appMovedToForeground(){
        verifyUser()
    }
    
    func appMovedToBackground(){
        isUnlocked = nil
        isPatientFetched = nil
    }
    
    @objc private func deleteBtnClicked()
    {
        if mPinEntered.count > 0
        {
            if let dotView = mPinView.viewWithTag(mPinEntered.count) as? DotSelectionView
            {
                mPinEntered.removeLast()
                dotView.isSelected = false
            }
        }
    }
        
    @objc private func cancelBtnClicked()
    {
        cancelBtn.isHidden = true
        mPHRPin = nil
        mPinEntered = ""
        titleLabel.text = getString(key: "com.charmphr.lockscreen.enternewpassword")
        unSelectAllDot()
    }
    
    @objc private func logoutBtnClicked(){
        self.showActivityIndicator()
        self.logoutUser()
    }
        
    @objc private func btnClicked(button : UIButton)
    {
        if let title = button.title(for: .normal)
        {
            mPinEntered.append(title)
            setDotSelected(int: mPinEntered.count)
            if mPinEntered.count == NUMBER_OF_PIN
            {
                if LockMode.validate == lockscreenMode
                {
                    validateMPin()
                }
                else if LockMode.create == lockscreenMode
                {
                    if mPHRPin.isNilOrBlank(){
                        mPHRPin = mPinEntered
                        mPinEntered = ""
                        cancelBtn.isHidden = false
                        
                        titleLabel.text = getString(key: "com.charmphr.lockscreen.reenterpassword")
                        unSelectAllDot()
                    }
                    else{
                        validateMPin()
                    }
                }
            }
        }
    }
    
    private func unSelectAllDot(){
        for dot in mPinView.subviews {
            (dot as? DotSelectionView)?.isSelected = false
        }
    }
        
    private func setDotSelected(int : Int){
        if let dotView = mPinView.viewWithTag(int) as? DotSelectionView
        {
            dotView.isSelected = true
        }
    }

//MARK: - Create View methods
    
    private func validateLocalAuthPage(){
        
        let iconLayoutSize: CGFloat = 90
        let indicatorLayout = UIView()
        indicatorLayout.setBackgroundColor(bgColor: TEXT_COLOR_WHITE)
        self.view.addSubview(indicatorLayout)
        
        indicatorLayout.setSafeAreaTop(offset: 0)
        indicatorLayout.setSafeAreaBottom(offset: 0)
        indicatorLayout.setLeft(offSet: 0)
        indicatorLayout.setRight(offSet: 0)
        
        let iconLayout = UIView()
        let iconView = UIImageView()
        
        
        let laHeading = UILabel()
        let laInfo = UILabel()
        
        let unlockBtn = UIButton()
        
        acitivityIndicator.hidesWhenStopped = true
        acitivityIndicator.style = .medium
        self.view.addSubview(acitivityIndicator)
        
        acitivityIndicator.setCenterX()
        acitivityIndicator.setCenterY()
        
        indicatorLayout.addSubview(iconLayout)
        indicatorLayout.addSubview(laHeading)
        indicatorLayout.addSubview(laInfo)
        indicatorLayout.addSubview(unlockBtn)
        
        iconLayout.addSubview(iconView)
        
        iconView.tintColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        iconLayout.layer.cornerRadius = iconLayoutSize / 2
        iconLayout.setBackgroundColor(bgColor: 0xf0f0f0FF)
        iconLayout.layer.masksToBounds = true
        
        laHeading.setProperties(textKey: getString(key: "com.charmphr.local.authentication.verify.heading", with: [appName]), fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        laInfo.setProperties(textKey: getString(key: "com.charmphr.local.authentication.message", with: [appName]), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        laInfo.numberOfLines = 0
        laInfo.textAlignment = .center
        
        unlockBtn.addPillCornerRadiusAndShadow(height: PILL_BTN_HEIGHT)
        unlockBtn.clipsToBounds = true
        unlockBtn.setTitle(getString(key: "com.charmphr.local.authentication.unlock"), for: .normal)
        unlockBtn.addTarget(self, action: #selector(onUnlockClicked), for: .touchUpInside)
        
        unlockBtn.setBackgroundColor(bgColor: THEME_COLOR)
        unlockBtn.setTitleColor(.white, for: .normal)
        unlockBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        
        iconLayout.setWidth(constant: iconLayoutSize)
        iconLayout.setHeight(constant: iconLayoutSize)
        iconLayout.setTop(offSet: 40)
        iconLayout.setCenterX()
        
        iconView.setWidth(constant: 50)
        iconView.setHeight(constant: 50)
        iconView.setCenterY()
        iconView.setCenterX()
        
        laHeading.setTopRelatedToView(offSet: CARD_PADDING, relatedView: iconLayout, relatedAttribute: .bottom)
        laHeading.setCenterX()
        laHeading.setHeight(constant: 40)
        
        laInfo.setTopRelatedToView(offSet: PADDING, relatedView: laHeading, relatedAttribute: .bottom)
        laInfo.setLeft(offSet: X_SPACE)
        laInfo.setRight(offSet: -X_SPACE)
        
        unlockBtn.setLeft(offSet: X_SPACE)
        unlockBtn.setRight(offSet: -X_SPACE)
        unlockBtn.setSafeAreaBottom(offset: -Y_SPACE)
        unlockBtn.setHeight(constant: PILL_BTN_HEIGHT)
        
        
        if let image = UIImage(systemName: "lock.fill") {
            iconView.image = image
        }
        
        
        if !StandardUserDefaults.bool(forKey: laPrefShownKey) {
            laInfo.text = getString(key: "com.charmphr.local.authentication.info.message", with: [appName])
            laHeading.text = getString(key: "com.charmphr.local.authentication.info.heading", with: [appName])
        }
        laInfo.wrapHeight(maxHeight: 500,maxWidth: applicationFrame.width - (2 * X_SPACE))
    }
        
    private func createMPinPage(){
        titleLabel.text = getString(key: "com.charmphr.lockscreen.enternewpassword")
        mPHRPin = nil
        mPinPage()
        
        cancelBtn.isHidden = true
        cancelBtn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
    }
        
    private func validateMPinPage(){
        titleLabel.text = getString(key: "com.charmphr.lockscreen.enterpassword", with: [appName])
        mPinPage()
        
        cancelBtn.isHidden = true
        cancelBtn.setTitle(getString(key: "com.charmphr.action.logout"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(logoutBtnClicked), for: .touchUpInside)
    }
    
    private func mPinPage(){
        titleLabel.font = .systemFont(ofSize: X_SPACE, Weight: .semibold)
        for subView in btnContainerView.subviews
        {
            if let btn = subView as? UIButton
            {
                if btn.title(for: .normal) != "Delete" && btn.title(for: .normal) != "Cancel"
                {
                    btn.titleLabel?.font = .systemFont(ofSize: 40, Weight: .semibold)
                    btn.layer.masksToBounds = true
                    btn.layer.cornerRadius = btn.layer.bounds.width / 2
                    btn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_GRAY_BG_COLOR)
                    btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
                }
                else if btn.title(for: .normal) == "Delete"
                {
                    btn.addTarget(self, action: #selector(deleteBtnClicked), for: .touchUpInside)
                }
               
            }
        }
        createDotView()
        
        acitivityIndicator.hidesWhenStopped = true
        acitivityIndicator.color = .gray
        self.view.addSubview(acitivityIndicator)
        
        acitivityIndicator.setCenterX()
        acitivityIndicator.setCenterY()
        fetchPatientList()
    }
    
    private func reAuthPage(){
        
        logoutLayout.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
        self.view.addSubview(logoutLayout)
        
        let logoutScroll = TPKeyboardAvoidingScrollView()
        logoutScroll.isUserInteractionEnabled = true
        
        let logoutView = UIView()
        logoutView.clipsToBounds = true
        logoutLayout.addSubview(logoutScroll)
        logoutScroll.addSubview(logoutView)
        
        logoutLayout.setSafeAreaTop(offset: 0)
        logoutLayout.setSafeAreaBottom(offset: 0)
        logoutLayout.setLeft(offSet: 0)
        logoutLayout.setRight(offSet: 0)
        
        logoutView.setTop(offSet: 0)
        logoutView.setBottom(offSet: 0)
        logoutView.setLeft(offSet: 0)
        logoutView.setWidth(constant: applicationFrame.width)
        //logoutView.setRight(offSet: 0)
        
        let iconView = UIImageView()
        iconView.image = UIImage(named: "OnBoardingWelcome")
        
        let laHeading = UILabel()
        let laInfo = UILabel()
        
        //let usernameLabel = UILabel()
        let pwdLabel = UITextField()
        
        let unlockBtn = UIButton()
        
        logoutView.addSubview(iconView)
        logoutView.addSubview(laHeading)
        logoutView.addSubview(laInfo)
        logoutLayout.addSubview(unlockBtn)
       // logoutView.addSubview(usernameLabel)
        logoutView.addSubview(pwdLabel)
        logoutView.addSubview(acitivityIndicator)
        
        passwordTF = pwdLabel
        
        acitivityIndicator.hidesWhenStopped = true
        acitivityIndicator.style = .medium
        
        laHeading.setProperties(textKey: getString(key: "com.charmphr.local.authentication.verify.heading", with: [appName]), fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        laInfo.setProperties(textKey: "com.charmphr.local.authentication.removed.info.message", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        
//        usernameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_VALUE_LABEL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
//        
//        if isCustomApp(){
//            usernameLabel.text = ""
//        }
//        else{
//            usernameLabel.text = "   \(ZSSOKit.getCurrentUser()?.profile?.displayName ?? "")" //Update this place with ZohoAuth equivalent function once it is available.
//        }
//        
//        usernameLabel.addCornerRadius(.SMALL)
//        usernameLabel.layer.borderWidth = BORDER_WIDTH
//        usernameLabel.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
//        usernameLabel.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
//        
        pwdLabel.setPadding(width: TEXTFIELD_PADDING_8)
        pwdLabel.font = .systemFont(ofSize: FONT_SIZE_VALUE_LABEL, Weight: .regular)
        pwdLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        pwdLabel.addCornerRadius(.SMALL)
        pwdLabel.layer.borderWidth = BORDER_WIDTH
        pwdLabel.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
        pwdLabel.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
        pwdLabel.isSecureTextEntry = true
        pwdLabel.placeholder = getString(key: "com.charmphr.zoomCall.password.placeholder")
        
        laInfo.numberOfLines = 0
        laInfo.textAlignment = .center
        
        unlockBtn.addPillCornerRadiusAndShadow(height: PILL_BTN_HEIGHT)
        unlockBtn.clipsToBounds = true
        unlockBtn.setTitle(getString(key: "com.charmphr.local.authentication.unlock"), for: .normal)
        unlockBtn.addTarget(self, action: #selector(onPasswordVerifyClicked), for: .touchUpInside)
        
        unlockBtn.setBackgroundColor(bgColor: THEME_COLOR)
        unlockBtn.setTitleColor(.white, for: .normal)
        unlockBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        
        iconView.setWidth(constant: 90)
        iconView.setHeight(constant: 110)
        iconView.setTop(offSet: 40)
        iconView.setCenterX()
        
        laHeading.setTopRelatedToView(offSet: 10, relatedView: iconView, relatedAttribute: .bottom)
        laHeading.setCenterX()
        laHeading.setHeight(constant: 40)
        
        laInfo.setTopRelatedToView(offSet: 5, relatedView: laHeading, relatedAttribute: .bottom)
        laInfo.setLeft(offSet: X_SPACE)
        laInfo.setRight(offSet: -X_SPACE)
        
//        usernameLabel.setTopRelatedToView(offSet: 5, relatedView: laInfo, relatedAttribute: .bottom)
//        usernameLabel.setLeft(offSet: X_SPACE)
//        usernameLabel.setRight(offSet: -X_SPACE)
//        usernameLabel.setHeight(constant: 56)
        
      //  pwdLabel.setTopRelatedToView(offSet: 5, relatedView: usernameLabel, relatedAttribute: .bottom)
        pwdLabel.setTopRelatedToView(offSet: 5, relatedView: laInfo, relatedAttribute: .bottom)
        pwdLabel.setLeft(offSet: X_SPACE)
        pwdLabel.setRight(offSet: -X_SPACE)
        pwdLabel.setHeight(constant: 56)
        pwdLabel.setBottom(offSet: 0)
        
        unlockBtn.setLeft(offSet: X_SPACE)
        unlockBtn.setRight(offSet: -X_SPACE)
        unlockBtn.setBottom(offSet: -Y_SPACE)
        unlockBtn.setHeight(constant: PILL_BTN_HEIGHT)
        
        logoutScroll.setTop(offSet: 0)
        logoutScroll.setLeft(offSet: 0)
        logoutScroll.setRight(offSet: 0)
        logoutScroll.setBottomRelatedToView(offSet: 10, relatedView: unlockBtn, relatedAttribute: .top)
        
        acitivityIndicator.setCenterX()
        acitivityIndicator.setCenterY()
        
        laInfo.wrapHeight(maxHeight: 500,maxWidth: applicationFrame.width - (2 * X_SPACE))
    }
    
    private func createDotView()
    {
        var previousView : UIView = mPinView
        
        for i in 0 ..< NUMBER_OF_PIN {
            let dotCircle = DotSelectionView()
            dotCircle.tag = i + 1
            dotCircle.isSelected = false
            mPinView.addSubview(dotCircle)
            
            dotCircle.setWidth(constant: 16)
            dotCircle.setHeight(constant: 16)
            dotCircle.setTop(offSet: 0)
            
            if previousView == mPinView
            {
                dotCircle.setLeft(offSet: 0)
            }else
            {
                dotCircle.setLeftRelatedToView(offSet: 27, relatedView: previousView, relatedAttribute: .right)
            }
            if i == NUMBER_OF_PIN - 1
            {
                dotCircle.setRight(offSet: 0)
            }
            previousView = dotCircle
        }
    }
    
//MARK: - Connection Handler methods
        
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        hideActivityIndicator()
    
        if identificationKey == "verifyPassword"{
            if let isSuccess = response as? Bool {
                if isSuccess {
                    onPasswordVerificationSuccess()
                }
                else{
                    let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.local.authentication.removed.pwd.failed.message"), preferredStyle: .alert)
                    alertVC.alertViewPriority =  AlertViewPriorityMedium
                    let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: { (UIAlertAction) in
                        
                    })
                    alertVC.addAction(okAction)
                    
                    let logoutAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.logout"), style: .default, handler: { (UIAlertAction) in
                        self.showActivityIndicator()
                        self.logoutUser()
                    })
                    alertVC.addAction(logoutAction)
                    
                    alertVC.show()
                }
            }
        }
    }
        
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
//MARK: - PatientDataHandler Delegate
    
    func patientDataHandlerDidReceiveData() {
        hideActivityIndicator()

        isPatientFetched = true
        if let patientList = Patient.patientList{
            addOrUpdatePatient(patientArray: patientList)
        }

        if shouldLogoutAfterPatientFetch {
            shouldLogoutAfterPatientFetch = false
            AuthManager.logoutUser(isInvalidOAuth: false)
            return
        }

        validatePatientDataAndUnlock()
    }
    
    func patientDataHandlerDidReceiveError(error: any Error) {
        hideActivityIndicator()

        if shouldLogoutAfterPatientFetch {
            shouldLogoutAfterPatientFetch = false
            AuthManager.logoutUser(isInvalidOAuth: false)
            return
        }

        isPatientFetched = false
        patientFetchError = error
        validatePatientDataAndUnlock()
    }
    
//MARK: - CoreData related functions
    
    func addOrUpdatePatient(patientArray: [Patient]){
        let coreDataUtil = mPHRCoreDataUtil.sharedInstance
        
        patientArray.forEach({ patient in
            
            if PatientDataHandler.getPatient(patientId: patient.patientId) != nil{
                coreDataUtil.updatePatientMObj(patient: patient)
            }
            else{
                coreDataUtil.addPatientMObj(patient: patient)
            }
        })
                
//        Deleting patient from the DB if the patient is deleted on api
        if let patientMObjArray = coreDataUtil.getPatientMObjList(){
            patientMObjArray.forEach({ patientMObj in
                if !patientArray.contains(where: { patientObj in
                    return patientObj.patientId == patientMObj.patientId
                }){
                    //Delete reminder and notification associated with patient
                    let reminderObjArr = ReminderHandler.getReminderObjList(patientId: patientMObj.patientId)
                    reminderObjArr.forEach { reminderObj in
                        LocalNotificationUtil.sharedInstance.removeReminderNotification(reminderObj: reminderObj)
                    }
                    coreDataUtil.deletePatientMObj(object: patientMObj)
                }
            })
        }
    }
        
//MARK: - PatientFailureHandler
        
    private func patientFailureHandler(error: Error?){
        if let nsError = error as? NSError {
            
            if nsError.code == patientSecondaryAccountErrorCode || nsError.code == patientCustomAppInvalidUserErrorCode  || nsError.code == patientEHRLoginError || nsError.code == patientPHRPracticeError {
                
                var errorMessage = nsError.domain
                if nsError.code == patientEHRLoginError {
                    errorMessage = getString(key: "com.charmphr.ehr.login.error")
                }
                let alertConroller = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                alertConroller.alertViewPriority = AlertViewPriorityVeryLow
                
                var actionTitle = getString(key: "com.charmphr.action.Ok")
                var alertAction = UIAlertAction.Style.default
                
                if nsError.code == patientSecondaryAccountErrorCode {
                    actionTitle = getString(key: "com.charmphr.action.logout")
                    alertAction = UIAlertAction.Style.destructive
                }
                
                let action = CharmUtil.getAlertAction(title:actionTitle , style: alertAction) { (action) in
                    self.logoutUser()
                }
                alertConroller.addAction(action)
                alertConroller.show()
                return
            }
        }
        if let error = error{
            if error.localizedDescription == getString(key: "com.charmphr.dataNotInCorrectFormat")
            {
                let alertConroller = UIAlertController(title: nil, message: getString(key: "com.charmphr.ehr.login.error"), preferredStyle: .alert)
                alertConroller.alertViewPriority = AlertViewPriorityVeryLow
                let logoutAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.logout"), style: .destructive) { (action) in
                    self.logoutUser()
                }
                alertConroller.addAction(logoutAction)
                alertConroller.show()
            }else
            {
                CharmUtil.createRetryAndCancelAlertWith(error: error, alertViewPriority: AlertViewPriorityVeryLow) { /// Using AlertViewPriorityVeryLow here because we are reinitiating when the app when comes to foreground
                    self.fetchPatientList()
                } cancelClicked: { [self] in
                    if !isLAShown{
                        mPinEntered = ""
                        
                        unSelectAllDot()
                    }
                }
            }
        }
    }
    
//MARK: - ActivityIndicator methods
    
    private func showActivityIndicator(){
        acitivityIndicator.startAnimating()
        acitivityIndicator.superview?.bringSubviewToFront(acitivityIndicator)
        self.view.isUserInteractionEnabled = false
    }
    
    private func hideActivityIndicator(){
        acitivityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
}

//MARK: - Dot SelectionView

class DotSelectionView : UIView
{
    var isSelected: Bool = false {
        didSet {
            if isSelected == true {
                self.backgroundColor = .black
            }
            else {
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = frame.height/2.0
        layer.borderWidth = 1.5
        layer.masksToBounds = true
    }
}
