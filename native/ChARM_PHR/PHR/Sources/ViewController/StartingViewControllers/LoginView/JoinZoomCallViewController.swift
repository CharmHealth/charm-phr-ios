//
//  JoinZoomCallViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 04/01/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import UIKit
import MobileRTC
import MobileCoreServices

class JoinZoomCallViewController: UIViewController, MobileRTCMeetingServiceDelegate, MobileRTCAuthDelegate {

    let MEETING_ID_VIEW_TAG = 10001
    let PASSWORD_ID_VIEW_TAG = 10002
    let USER_NAME_ID_VIEW_TAG = 10003
    
    var meetingUrl : URL!
    let activityIndicator = UIActivityIndicatorView()
    
//    let zoomSDKKey = "RU2Jw0ziUtAufU0Dalk6l6KnuOBqUJ1Tyq2i"
//    let zoomSDKSecret = "vXBly8cR9KFkQPjhVpQOZmK0TZrSeqQ9zI24"
    let zoomDomain = "zoom.us"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLargeTitle(enable: true)
        self.navigationItem.title = getString(key: "com.charmphr.zoomCall.joinMeeting.placeholder")
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        let barButtonItem = UIBarButtonItem(title: getString(key: "com.charmphr.action.close"), style: .plain, target: self, action: #selector(closeViewController))
        self.navigationItem.setRightBarButton(barButtonItem, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        createView()
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated: true)
        if meetingUrl != nil
        {
            fillValuesInTextField(url: meetingUrl)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.setLargeTitle(enable: true)
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
    
    func createView()
    {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let meetingIdTF = getTextFieldView(placeHolder: getString(key: "com.charmphr.zoomCall.meetingId.placeholder"), text: "")
        meetingIdTF.tag = MEETING_ID_VIEW_TAG
        containerView.addSubview(meetingIdTF)
        
//        let passwordTF = getTextFieldView(placeHolder: NSLocalizedString("com.charmphr.zoomCall.password.placeholder", comment: ""), text: "")
//        passwordTF.tag = PASSWORD_ID_VIEW_TAG
//        containerView.addSubview(passwordTF)
        
        let userNameTF = getTextFieldView(placeHolder: getString(key: "com.charmphr.zoomCall.userName.placeholder"), text: "")
        userNameTF.tag = USER_NAME_ID_VIEW_TAG
        containerView.addSubview(userNameTF)
        
        let joinMeetingBtn = UIButton(type: .custom)
        joinMeetingBtn.setTitle(getString(key: "com.charmphr.zoomCall.joinMeeting.title"), for: .normal)
        joinMeetingBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR)
        joinMeetingBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .bold)
        joinMeetingBtn.addTarget(self, action: #selector(joinMeeting), for: .touchUpInside)
        joinMeetingBtn.addCornerRadius(.SMALL)
        containerView.addSubview(joinMeetingBtn)
        
        
        meetingIdTF.setTop(offSet: 0)
        meetingIdTF.setLeft(offSet: 0)
        meetingIdTF.setRight(offSet: 0)
        meetingIdTF.setHeight(constant: 56)
        
//        passwordTF.setTopRelatedToView(offSet: 8, relatedView: meetingIdTF, relatedAttribute: .bottom)
//        passwordTF.setLeft(offSet: 0)
//        passwordTF.setRight(offSet: 0)
//        passwordTF.setHeight(constant: 56)
        
        userNameTF.setTopRelatedToView(offSet: 8, relatedView: meetingIdTF, relatedAttribute: .bottom)
        userNameTF.setLeft(offSet: 0)
        userNameTF.setRight(offSet: 0)
        userNameTF.setHeight(constant: 56)
        
        joinMeetingBtn.setTopRelatedToView(offSet: 8, relatedView: userNameTF, relatedAttribute: .bottom)
        joinMeetingBtn.setLeft(offSet: 0)
        joinMeetingBtn.setRight(offSet: 0)
        joinMeetingBtn.setHeight(constant: 46)
        joinMeetingBtn.setBottom(offSet: 0)
        
        self.view.addSubview(containerView)
        
        containerView.setSafeAreaTop(offset: Y_SPACE)
        containerView.setLeft(offSet: X_SPACE)
        containerView.setRight(offSet: -X_SPACE)

    }
    
    func getTextFieldView(placeHolder : String , text : String) -> UITextField
    {
        let textField = UITextField()
        
        textField.placeholder = placeHolder
        textField.text = text
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.addCornerRadius(.SMALL)
        textField.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        
        return textField
    }
    
    func fillValuesInTextField(url:URL)
    {        
        if let meetingIdTF = self.view.viewWithTag(MEETING_ID_VIEW_TAG) as? UITextField
        {
            meetingIdTF.text = getValueForQuery(name: "ID", url: url)
        }
        
        if let pwdTF = self.view.viewWithTag(PASSWORD_ID_VIEW_TAG) as? UITextField
        {
            pwdTF.text = getValueForQuery(name: "PWD", url: url)
        }
        
        if let nameTf = self.view.viewWithTag(USER_NAME_ID_VIEW_TAG) as? UITextField
        {
            let nameFromUrl = getValueForQuery(name: "NAME", url: url)
            
            if nameFromUrl == nil && Patient.selectedPatientInstance != nil
            {
                let patient = Patient.selectedPatientInstance!
                nameTf.text = "\(isNilOrEmpty(string: patient.firstName) == false ? String(patient.firstName.first!) : "")\(isNilOrEmpty(string: patient.lastName) == false ? String(patient.lastName.first!) : "")"
            }else
            {
                nameTf.text = nameFromUrl ?? ""
            }
        }
    }
    
    func getValueForQuery(name:String,url:URL) -> String?
    {
        let urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if urlComponent!.queryItems != nil
        {
            for queryItem in urlComponent!.queryItems!
            {
                if queryItem.name == name
                {
                    return queryItem.value
                }
            }
        }
        
        return nil
    }
    
    //MARK: - action calles
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func closeViewController()
    {
        let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.zoomCall.alert.close"), preferredStyle: .alert)
        
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel) { (action) in
        }
        
        let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.common.yes"), style: .default, handler: { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        alertVC.show()
    }

    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    
    
    
    @objc func joinMeeting()
    {
        showActivityIndicator()
        
        let context = MobileRTCSDKInitContext()
        context.domain = zoomDomain
        context.enableLog = true;
        context.locale = .default;
        context.bundleResPath = Bundle.main.bundlePath
        MobileRTC.shared().initialize(context);
                
        let authService = MobileRTC.shared().getAuthService()
        
        authService?.delegate = self
//        authService?.clientKey = zoomSDKKey
//        authService?.clientSecret =  zoomSDKSecret
//        authService?.sdkAuth()
    
        debugPrintLog("MobileRTC Version: \(MobileRTC.shared().mobileRTCVersion() ?? "error in rct mobile version")")
    }
    
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        debugPrintLog(returnValue)
        hideActivityIndicator()
        
        if (returnValue == .success)
        {
            let meetingIdTF = self.view.viewWithTag(MEETING_ID_VIEW_TAG) as! UITextField
//            let pwdTF = self.view.viewWithTag(PASSWORD_ID_VIEW_TAG) as! UITextField
            let nameTf = self.view.viewWithTag(USER_NAME_ID_VIEW_TAG) as! UITextField
            
            let meetingId = meetingIdTF.text
//            let password = pwdTF.text
            let userName = nameTf.text
            
            
            let joinParam = MobileRTCMeetingJoinParam()
            joinParam.userName = userName
            joinParam.meetingNumber = meetingId
            
//            let paramDict : Dictionary<String,Any> =
//                [
//                    kMeetingParam_Username : userName ?? "",
//                    kMeetingParam_MeetingNumber : meetingId ?? "",
////                    kMeetingParam_MeetingPassword : password ?? ""
//            ]

            let ms = MobileRTC.shared().getMeetingService()
            let meetingSucces = ms!.joinMeeting(with: joinParam)

            debugPrintLog(meetingSucces)

            
            if Int(meetingSucces.rawValue) != 0 && Int(meetingSucces.rawValue) != 101
            {
                let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.common.error"), preferredStyle: .alert)

                let retryAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.retry"), style: .cancel) { (action) in
                    }

                alertVC.addAction(retryAction)
                alertVC.show()
            }
        }
        else
        {
            let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.common.error"), preferredStyle: .alert)

            let retryAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.retry"), style: .cancel) { (action) in
                }

            alertVC.addAction(retryAction)
            alertVC.show()
        }
    }
    
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
       debugPrintLog("\(state)")
    }
    
}

