//
//  TelehealthUtil.swift
//  PHR
//
//  Created by Prathiba M on 23/12/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import MobileRTC

protocol TelehealthUtilDelegate: AnyObject{
    func showActivityIndicator()
    func hideActivityIndicator()
}

class TelehealthUtil: NSObject, CharmConnectionV2HandlerDelegate, VideoCallInfoViewControllerDelegate, VideoCallConsentFormDelegate, MobileRTCAuthDelegate {
    
    private lazy var charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
    private var videoInfoVC: VideoCallInfoViewController? = nil
    private var rootPopUpVC: UIViewController? = nil
    private var selectedAppointment: Appointment? = nil
    private var zoomCredentials: ZoomCredentials? = nil
    private var rootVC: UIViewController? = nil
    private var questionnaireList: [PhysicianTemplates] = []
    private weak var delegate: TelehealthUtilDelegate? = nil
    
    init(rootVC: UIViewController?, questionnaireList: [PhysicianTemplates],  delegate: TelehealthUtilDelegate?, rootPopUpVC: UIViewController?){
        self.rootVC = rootVC
        self.questionnaireList = questionnaireList
        self.delegate = delegate
        self.rootPopUpVC = rootPopUpVC
    }
    
    func onTapJoinBtn(appointment: Appointment?){
        selectedAppointment = appointment
        fetchAppointmentRestriction()
    }
    
    //MARK: - api calls
    
    private func fetchAppointmentRestriction(){
        delegate?.showActivityIndicator()
        charmConnectionHandler.fetchAppointmentRestriction(practiceId: selectedAppointment?.practiceId, identificationKey: "appointmentRestriction")
    }
    
    private func fetchVideoConsultation(){
        guard let appointment  = selectedAppointment else { return }
        delegate?.showActivityIndicator()
        charmConnectionHandler.fetchVideoConsultation(appointment: appointment, identificationKey: "videoConsult")
    }
    
    func fetchQuestionnaireListForConsentForm() {
        delegate?.showActivityIndicator()
        charmConnectionHandler.getQuestionnaireList(type: questionnaireCurrentValue, identificationKey: "fetchQuestionnaireList")
    }
    
    //MARK: - Other functions
    
    private func checkApptRestrictAndFetchVideoCall(appointmentRestriction: AppointmentRestriction?){
        guard let appointmentStartTime = selectedAppointment?.appointmentDeviceStartTime, let appointmentEndTime = selectedAppointment?.appointmentDeviceEndTime else { return }
        
        guard let earlyCheckinInMinutes = appointmentRestriction?.earlyCheckinInMinutes, let expiryInMinutes = appointmentRestriction?.expiryInMinutes else { return }
        
        let startMinutesBetween: Int = Date().getMinutesBetween(date: appointmentStartTime)
     //   let endMinutesBetween: Int = Date().getMinutesBetween(date: appointmentEndTime)
        
        if startMinutesBetween >= 0{
            if startMinutesBetween <= earlyCheckinInMinutes{
                fetchVideoConsultation()
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.appointment.videoCall.earlyCheckIn.alert.title", with: ["\(earlyCheckinInMinutes)"]), msg: nil)
            }
        }
        else{
            let minutesAfterAppointmentStartTime = abs(startMinutesBetween)
            
            if minutesAfterAppointmentStartTime <= expiryInMinutes{
                fetchVideoConsultation()
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.appointment.videoCall.expiry.alert.title"), msg: nil)
            }
            
        }
    }
    
    func dismissVideoCallVC(){
        if let videoInfoVC = videoInfoVC {
            videoInfoVC.dismiss(animated: false)
        }
        videoInfoVC = nil
    }
    
    private func pushToConsentForm(physicianTemplate:PhysicianTemplates ){
        let questionnaireAnswerVC = QuestionnaireAnswerViewController()
        questionnaireAnswerVC.physicianTemplate = physicianTemplate
        questionnaireAnswerVC.consentFormDelegate = self
        rootVC?.navigationController?.pushViewController(questionnaireAnswerVC, animated: true)
    }
    
    //MARK: - Join VideoCall functions
    
    private func onVideoConsultRespSuccess(){
        let alertVC = UIAlertController(title: nil, message: NSLocalizedString("com.charmphr.appointment.startMeeting.alert", comment: ""), preferredStyle: .alert)
        
        let cancelAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.cancel", comment: ""), style: .cancel) { (action) in
        }
        
        let okAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.common.yes", comment: ""), style: .default, handler: { (UIAlertAction) in
        
            self.checkConsentFormAndJoinVideoCall()
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        alertVC.show()
    }
    
    private func checkConsentFormAndJoinVideoCall(){
        
        if let zoomCredentials = zoomCredentials {
            if zoomCredentials.isConsentFormAvailable && zoomCredentials.consentFormIdList?.isEmpty == false {
                if let consentFormId = zoomCredentials.consentFormIdList?.firstOrNil() {
                    if let physicianTemplate = questionnaireList.first(where: {tempPhysicianTemplate in
                        return tempPhysicianTemplate.patientQuesMap?.patientQuesMapId == consentFormId
                    }) {
                        pushToConsentForm(physicianTemplate:physicianTemplate )
                    }
                    else{
                        fetchQuestionnaireListForConsentForm()
                    }
                }
            }
            else{
                joinVideoCall()
            }
        }
    }
    
    private func joinVideoCall(){
        
        if let zoomCredentials = zoomCredentials {
            
            if zoomCredentials.platform == "OPENTOK" {
                
                let password = zoomCredentials.password ?? ""
                if password.isNotBlank() {
                    
                    let videoCallInfo = VideoCallInfoViewController()
                    videoCallInfo.zoomCredentials = zoomCredentials
                    videoCallInfo.delegate = self
                    videoCallInfo.modalTransitionStyle = .crossDissolve
                    videoCallInfo.modalPresentationStyle = .overFullScreen
                    rootVC?.present(videoCallInfo, animated: true)
                    
                    self.videoInfoVC = videoCallInfo
                }
                else{
                    proceedToVideoCall()
                }
            }
            else if zoomCredentials.platform == "ZOOM" {
                
                let jwtToken = zoomCredentials.jwtToken ?? ""
                let domain = zoomCredentials.webDomain ?? ""
                
                if (!isNilOrEmpty(string: domain) && !isNilOrEmpty(string: jwtToken))
                {
                    let context = MobileRTCSDKInitContext()
                    context.domain = domain
                    context.enableLog = true;
                    context.locale = .default;
                    context.bundleResPath = Bundle.main.bundlePath
                    MobileRTC.shared().initialize(context);
                    
                    delegate?.showActivityIndicator()
                    
                    let authService = MobileRTC.shared().getAuthService()
                    
                    authService?.delegate = self
                    authService?.jwtToken = jwtToken
                    //authService?.clientSecret =  self.videoConsultDict!["SDK_SECRET"] as? String
                    
                    authService?.sdkAuth()
                    
                    debugPrintLog("MobileRTC Version: \(MobileRTC.shared().mobileRTCVersion() ?? "error in rct mobile version")")
                }
            }
        }
    }
    
    //MARK: - VideoCallInfoViewControllerDelegate
    
    func proceedToVideoCall() {
        videoInfoVC = nil
        let urlString = self.zoomCredentials?.webURL ?? ""
        
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url)
            }
            else{
                CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.opentok.invalidURL"))
            }
        }
    }
    
    func videoCallInfoDismissed() {
        videoInfoVC = nil
    }
    
    //MARK: - VideoCallConsentFormDelegate
    
    func onConsentFormSubmitted(patQuesMapId: String) {
        self.zoomCredentials?.consentFormIdList?.removeAll(where: {tempPhysicianTemplate in
            return tempPhysicianTemplate == patQuesMapId
        })
        
        let consentFormList = self.zoomCredentials?.consentFormIdList ?? []
        
        if consentFormList.isEmpty {
            popConsentFormVC()
            joinVideoCall()
        }
        else{
            if let physicianTemplate = questionnaireList.first(where: {tempPhysicianTemplate in
                return tempPhysicianTemplate.patientQuesMap?.patientQuesMapId == consentFormList.firstOrNil()
            }) {
                pushToConsentForm(physicianTemplate: physicianTemplate)
            }
            else{
                CharmUtil.createOkayAlertWith(title: "Some Consent Form is not available to fill", msg: "Please refresh the page and try again to fill the consent form.") {
                    self.popConsentFormVC()
                }
            }
        }
    }
    
    func popConsentFormVC() {
        guard let rootPopUpVC = rootPopUpVC else { return }
        rootVC?.navigationController?.popToViewController(rootPopUpVC, animated: true)
    }
    
    //MARK: - VideoCall functions
    
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        delegate?.showActivityIndicator()
        if (returnValue == .success)
        {
            let ms = MobileRTC.shared().getMeetingService()
            
            if let zoomCredentials = zoomCredentials {
                let userType = zoomCredentials.userType ?? ""
                        
                var meetingSucces : MobileRTCMeetError!
                
                if userType == "HOST"
                {
                    let user = MobileRTCMeetingStartParam4WithoutLoginUser()
                    user.userType = .apiUser;
                    user.meetingNumber = zoomCredentials.meetingId ?? ""
                    user.userName = Patient.selectedPatientInstance?.firstName ?? ""
                    user.zak = zoomCredentials.zak ?? "" // videoConsultDict["ZAK"] as! String;
                    
                    meetingSucces = ms!.startMeeting(with: user)
                }
                else
                {
                    let joinParam = MobileRTCMeetingJoinParam()
                    joinParam.userName = Patient.selectedPatientInstance?.firstName ?? ""
                    joinParam.meetingNumber = zoomCredentials.meetingId ?? ""
                    meetingSucces = ms!.joinMeeting(with: joinParam)
                }
                
                debugPrintLog(meetingSucces!)
                
                if Int(meetingSucces.rawValue) != 0 && Int(meetingSucces.rawValue) != 101
                {
                    let alertVC = UIAlertController(title: nil, message: NSLocalizedString("com.charmphr.common.error", comment: ""), preferredStyle: .alert)
                    
                    let retryAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.retry", comment: ""), style: .cancel) { (action) in
                    }
                    
                    alertVC.addAction(retryAction)
                    alertVC.show()
                }
            }
            delegate?.hideActivityIndicator()
                
        }else
        {
            let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.common.error"), preferredStyle: .alert)

            let retryAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .cancel) { (action) in
            }
            
            alertVC.addAction(retryAction)
            alertVC.show()
            
            delegate?.hideActivityIndicator()
        }
    }
    
    //MARK: - ConnectionHandler Delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        delegate?.hideActivityIndicator()
        if identificationKey == "videoConsult" {
            if let zoomCredentials = response as? ZoomCredentials {
                self.zoomCredentials = zoomCredentials
                onVideoConsultRespSuccess()
            }
        }
        else if identificationKey == "appointmentRestriction"{
            if let appointmentRestriction = response as? AppointmentRestriction {
                checkApptRestrictAndFetchVideoCall(appointmentRestriction: appointmentRestriction)
            }
        }
        else if identificationKey == "fetchQuestionnaireList"{
            self.questionnaireList = response as? [PhysicianTemplates] ?? []
            checkConsentFormAndJoinVideoCall()
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        delegate?.hideActivityIndicator()
        if identificationKey == "videoConsult" {
            if (error as NSError).code == appointmentVideoNotStartedErrorCode {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.appointment.meeting.start.error"), msg: "")
            }
            else{
                CharmUtil.createOkayAlertWith(error: error)
            }
        }
        else if identificationKey == "appointmentRestriction"{
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.fetchAppointmentRestriction()
            }
        }
        else if identificationKey == "fetchQuestionnaireList" {
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.fetchQuestionnaireListForConsentForm()
            })
        }
    }
}
