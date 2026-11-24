//
//  CharmConnectionHandler.swift
//  ChARM Phr
//
//  Created by Sankar Saravanan on 04/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import UIKit


protocol CharmConnectionHandlerDelegate: AnyObject {
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject  : Dictionary<String,Any> , identificationKey : String )
    func charmConnectionHandlerDidFailWithError(error : Error  , identificationKey : String )
//    func charmConnectionHandlerDidRecieveData(data : Data , identificationKey : String )
}
protocol CharmConnectionHandlerTagDelegate: AnyObject {
    func charmConnectionHandlerDidRecieveData(data: Data, tag: Int, identificationKey: String)
    func charmConnectionHandlerDidRecieveData(image  : UIImage, tag: Int, identificationKey: String)

}

protocol CharmConnectionV2HandlerDelegate: AnyObject {
    func charmConnectionV2HandlerDidRecieve(response  : Any , identificationKey : String )
    func charmConnectionV2HandlerDidFailWithError(error : Error  , identificationKey : String )
//    func charmConnectionHandlerDidRecieveData(data : Data , identificationKey : String )
}


protocol CharmConnectionHandlerDataDelegate: AnyObject
{
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String)
}

class CharmConnectionHandler {
    private static let healthPassportServerName = "https://passport.charmtracker.com"
    private let INVALID_OAUTH_ERROR_CODE = 401

    /// URLs.plist. Each API endpoint's full path, keyed by name, with `{name}` placeholders
    /// that the caller fills in through `params`.
    private static let urlPlistDict: [String: String] = {
        guard let filePath = Bundle.main.path(forResource: "URLs", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: filePath) as? [String: String] else { return [:] }
        return dict
    }()

    static func getUrlFromPlist(key: String) -> String {
        guard let actionPath = urlPlistDict[key], let serverName = Bundle.main.infoDictionary?["SERVER"] as? String else {
            return ""
        }
        
        return joinUrl(serverName, actionPath)
    }

    /// Joins a server and a URLs.plist path with exactly one "/" between them.
    private static func joinUrl(_ server: String, _ path: String) -> String {
        var base = server.trimmingCharacters(in: .whitespacesAndNewlines)
        while base.hasSuffix("/") { base.removeLast() }
        return "\(base)/\(path)"
    }

    func getUrlFromPlist(keyValue: String) -> String {
        return CharmConnectionHandler.getUrlFromPlist(key: keyValue)
    }

    static func getHealthPassportUrlFromPlist(key: String) -> String {
        guard let actionPath = urlPlistDict[key] else { return "" }
        return joinUrl(healthPassportServerName, actionPath)
    }

    func getHealthPassportUrlFromPlist(keyValue: String) -> String {
        return CharmConnectionHandler.getHealthPassportUrlFromPlist(key: keyValue)
    }

    func getUrlFromPlist(keyValue: String, params: [String: Any]) -> String {
        return CharmConnectionHandler.fillParams(getUrlFromPlist(keyValue: keyValue), key: keyValue, params: params)
    }

    func getHealthPassportUrlFromPlist(keyValue: String, params: [String: Any]) -> String {
        return CharmConnectionHandler.fillParams(getHealthPassportUrlFromPlist(keyValue: keyValue), key: keyValue, params: params)
    }

    private static func fillParams(_ template: String, key: String, params: [String: Any]) -> String {
        var url = template
        for (name, value) in params {
            assert(template.contains("{\(name)}"), "URLs.plist \(key): no {\(name)} in \(template)")
            url = url.replacingOccurrences(of: "{\(name)}", with: "\(value)")
        }
        assert(template.components(separatedBy: "{").count - 1 == params.count, "URLs.plist \(key): placeholder not filled in \(template)")
        return url
    }
    
    private weak var delegate : CharmConnectionHandlerDelegate?
    weak var dataDelegate : CharmConnectionHandlerDataDelegate?
    weak var v2Delegate: CharmConnectionV2HandlerDelegate?
    weak var tagDelegate : CharmConnectionHandlerTagDelegate?
    
//MARK: - Sessions
    
    static private var urlSession: URLSession?
    static private var sharedUrlSession: URLSession{
        
        if let urlSession {
            return urlSession
        }
        let newSession = getSession()
        urlSession = newSession
        return newSession
    }
    
    static func updateSession() {
        urlSession?.invalidateAndCancel()
        urlSession = getSession()
    }
    
    static func invalidateSession(){
        urlSession?.invalidateAndCancel()
        urlSession = nil
    }
    
    static private func getSession() -> URLSession
    {
        let sessionConf = URLSessionConfiguration.default
        let hTTPAdditionalHeaders = ["Mobile-User-Agent": AuthenticationUtil.getUserAgent()]
        debugPrintLog(hTTPAdditionalHeaders)
        sessionConf.httpAdditionalHeaders = hTTPAdditionalHeaders
        let session : URLSession = URLSession(configuration: sessionConf, delegate: nil, delegateQueue: OperationQueue.main)
        return session
    }
    
    // MARK: - init methods
    
    init(delegate : CharmConnectionHandlerDelegate?)
    {
        self.delegate = delegate
    }
    
    init(v2Delegate : CharmConnectionV2HandlerDelegate?)
    {
        self.v2Delegate = v2Delegate
    }
    
    // MARK: - common apis
    
    func fetchPDF(urlString: String, identificationKey: String){
        initiateRequestWithIndexpath(indexPath: nil, urlString: urlString, identificationKey: identificationKey)
    }

    func getInvoicePdfUrl(patientId: String, phrBillId: String, phrBillDataId: String) -> String {
        return getUrlFromPlist(keyValue: "InvoicePDF", params: ["id": patientId, "phrBillId": phrBillId, "phrBillDataId": phrBillDataId])
    }

    func getStatementPdfUrl(patientId: String, statementId: String) -> String {
        return getUrlFromPlist(keyValue: "StatementPDF", params: ["id": patientId, "statementId": statementId])
    }
    
    func fetchUnreadCount(patientId : String , practiceId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "UnreadCount", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchSectionConfiguration( patientId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "SectionConfiguration", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchPrivilegeList( identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "UserPrivileges"), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchMenulist(practiceId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "MenuList", params: ["practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    
    
    // MARK: - profile
    
//    func fetchFacility(practiceId : String , identificationKey : String )
//    {
//        initiateWithUrlString(urlString: "\(CharmConnectionHandler.serverName)/api/phr/v1/practices/\(practiceId)/facilities?patient_id=\(Patient.selectedPatientInstance!.patientId!)", dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
//    }
    
    
    func verifyUser(password: String , identificationKey: String){//remove this function
        var userName =  "demo"
        
        //Update this place with ZohoAuth equivalent function once it is available.
        
        
        let urlString = getUrlFromPlist(keyValue: "VerifyUser", params: ["userName": userName, "password": password])
        
        initiateWithUrlStringV2(urlString: urlString.urlEncode(), httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: ParsingHelper.isPasswordVerified(respObj: respObj), identificationKey: identificationKey)
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    
    // MARK: - Vitals
    
    //method to fetch vitals to show in dashboard
    
    func fetchVitalUnit (identificationKey : String)
    {
        
        initiateWithUrlStringV2(urlString: getUrlFromPlist(keyValue: "VitalUnit", params: ["id": getSelectedPatientId()]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard let self = self else { return }

            if let unitStr = ParsingHelper.getVitalUnit(respObj: respObj) {
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: unitStr, identificationKey: identificationKey)
            }
            else{
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: false, identificationKey: identificationKey)
            }

        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    func fetchVitals( patientId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "Vitals", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    //method to fetch wellness list
    func fetchVitalTrackersList(identificationKey : String)
    {
        initiateWithUrlStringV2(urlString: getUrlFromPlist(keyValue: "VitalTrackerList", params: ["id": getSelectedPatientId()]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard let self = self else { return }

            let trackerList:[Tracker] = ParsingHelper.formVitalTrackerList(respObj: respObj)

            if !trackerList.isEmpty {
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: trackerList, identificationKey: identificationKey)
            }
            else{
                let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.wellness.tracker.empty.error")
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            }
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
        
    //    initiateWithUrlString(urlString: "\(CharmConnectionHandler.serverName)/api/phr/v2/patients/\(getSelectedPatientId())/tracker", dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    //method to fetch individual wellness detail
    func fetchVitalTrackerDetailList(identificationKey : String, trackerId : String)
    {
        //api/phr/v2/patients/{patient_id}/tracker/{tracker_id}
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "VitalTrackerDetail", params: ["id": getSelectedPatientId(), "trackerId": trackerId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    //method to fetch individual metric detail
    func fetchVitalMetricDetailList(identificationKey : String, metricId : String)
    {
        //api/phr/v2/patients/{patient_id}/tracker/{tracker_id}
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "VitalMetricDetail", params: ["id": getSelectedPatientId(), "metricId": metricId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    //method to post tracker detail
    func addVital(addVital: AddVital , identificationKey : String)
    {
        let postObj = JsonBuilder.formPatientVitalPostJson(addvital: addVital)

        if let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: [])){
            
            let urlString = getUrlFromPlist(keyValue: "AddVital")
            
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
                guard let self = self else { return }
                let message = respObj.getString("message") ?? ""
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: message, identificationKey: identificationKey)

            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    private let vitalCount: Int = 50
    func addVitalsUsingHK(vitalList:[MetricValue] , identificationKey: String) {
        internalAddVitalsUsingHK(vitalList: vitalList, identificationKey: identificationKey)
    }
    
    private func internalAddVitalsUsingHK(vitalList:[MetricValue] , identificationKey: String) {
        var vitalList = vitalList
        var vitalsToBeAdded:[MetricValue] = vitalList.removeFirst(count: vitalCount)
        
        if vitalsToBeAdded.last?.metric?.metricName == wellnessSystolicModelId {
            if vitalList.first?.metric?.metricName == wellnessDiastolicModelId {
                vitalsToBeAdded.append(contentsOf: vitalList.removeFirst(count: 1))
            }
        }
        
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute:  {
//            if vitalList.isEmpty {
//                let message = "Added successfully" //respObj.getString("message") ?? ""
//                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: message, identificationKey: identificationKey)
//            }
//            else{
//                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: vitalsToBeAdded, identificationKey: identificationKey)
//                self.internalAddVitalsUsingHK(vitalList: vitalList, identificationKey: identificationKey)
//            }
//        })
        
        let postObj = JsonBuilder.formVitalUsingHK(vitalList: vitalsToBeAdded)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: [])){
            
            let urlString = getUrlFromPlist(keyValue: "AddVitalsHK", params: ["id": getSelectedPatientId()])
            initiateWithUrlStringV2(urlString: urlString,dataToPost: jsonData ,httpMethod: .HTTP_METHOD_POST, success: { respObj in
                
                
                if vitalList.isEmpty {
                    let message = respObj.getString("message") ?? ""
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: message, identificationKey: identificationKey)
                }
                else{
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: vitalsToBeAdded, identificationKey: identificationKey)
                    self.internalAddVitalsUsingHK(vitalList: vitalList, identificationKey: identificationKey)
                }
            }, failure: {apiError in
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    func postVitalUnit(unitSystem: String , patientId: String? = nil,identificationKey : String)
    {
        let selectedPatientId = patientId ?? getSelectedPatientId()
        
        let postObj = JsonBuilder.formVitalUnitObj(patientId: selectedPatientId, unitStr: unitSystem)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: [])) {
            let urlString = getUrlFromPlist(keyValue: "PostVitalUnit")
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
                guard let self = self else { return }
                VitalUtil.savePatientVitalUnit(vitalUnit: unitSystem, selectedPatientId: selectedPatientId)
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: unitSystem, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
// - MARK: about
    
    func  getAboutDetail(identificationKey: String){
        
        let patientId = getSelectedPatientId()
        
        let practiceList = getActivePracticeId()
        let practiceSize = practiceList.count
            
        let about  = About()
        var respCount = 0
            
        var isCallbackSent = false
            
        practiceList.forEach({practiceId in
            let urlString = getUrlFromPlist(keyValue: "About", params: ["practiceId": practiceId, "id": patientId])
            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
            success:{ [weak self] respObj in
                guard let self = self else { return }
                respCount+=1
                let aboutTemp = ParsingHelper.formAboutDetail(respObj: respObj)
                about.facilityList.append(contentsOf: aboutTemp.facilityList)
                about.providerList.append(contentsOf: aboutTemp.providerList)
                if respCount == practiceSize && !isCallbackSent{

                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: about, identificationKey: identificationKey)
                    isCallbackSent = true
                }

            }, failure: { [weak self] apiError in
                guard let self = self else { return }

                respCount+=1
                if !isCallbackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                    isCallbackSent = true
                }
            })
        })
    }
    
    
    func fetchAbout(practiceId : String , identificationKey : String )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "About", params: ["practiceId": practiceId, "id": getSelectedPatientId()]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
//    func fetchFacilityDetails(practiceId : String , facilityId : String , identificationKey : String )
//    {
//        initiateWithUrlString(urlString: "\(CharmConnectionHandler.serverName)api/phr/v1/practices/\(practiceId)/facilities/\(facilityId)", dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
//    }
    
    // MARK: announcement
    
    
    func  fetchAnnouncement(identificationKey : String){
        let patientId = getSelectedPatientId()
        if patientId.isNotBlank(){
            let practiceList = getEnabledPractices(moduleId: announcementModelId)
            let practiceSize = practiceList.count
            
            var announcementList: [Announcement] = []
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                let urlString = getUrlFromPlist(keyValue: "Announcement", params: ["id": patientId, "practiceId": practiceId])
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard let self = self else { return }
                    respCount+=1
                    let announcementTempList = ParsingHelper.formAnnouncementList(dict: respObj)
                    announcementList.append(contentsOf: announcementTempList)
                    if respCount == practiceSize && !isCallbackSent{

                        announcementList = announcementList.sorted(by: { (item1, item2) -> Bool in
                            if item1.time == nil || item2.time == nil
                            {
                                return true
                            }else
                            {
                                return item1.time ?? Date() > item2.time ?? Date()
                            }
                        })

                        self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: announcementList, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                }, failure: { [weak self] apiError in
                    guard let self = self else { return }

                    respCount+=1
                    if !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        isCallbackSent = true
                    }
                })
            })
        }
    }
    func fetchAnnouncement(patientId : String , practiceId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "Announcement", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchAnnouncementDetial(announcement : Announcement, identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AnnouncementDetail", params: ["announcementId": announcement.announcementId ?? "", "practiceId": announcement.practiceId ?? ""]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    //MARK: useful info
    
    func fetchUsefulInfo(identificationKey : String){
        let patientId = getSelectedPatientId()
        if patientId.isNotBlank(){
            
            let practiceList = getActivePracticeId()
            let practiceSize = practiceList.count
            
            var usefulInfoList: [UsefulInfo] = []
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                let urlString = getUrlFromPlist(keyValue: "UsefulInfo", params: ["id": patientId, "practiceId": practiceId])
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard let self = self else { return }
                    respCount+=1
                    let usefulInfoTempList = ParsingHelper.formUsefulInfo(dict: respObj)
                    usefulInfoList.append(contentsOf: usefulInfoTempList)
                    if respCount == practiceSize && !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: usefulInfoList, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                }, failure: { [weak self] apiError in
                    guard let self = self else { return }

                    respCount+=1
                    if !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        isCallbackSent = true
                    }
                })
            })
        }
    }
    
    func fetchUsefulInfo(patientId : String , practiceId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "UsefulInfo", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchUsefulInfoDetial(infoId : String , practiceId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "UsefulInfoDetail", params: ["infoId": infoId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    // MARK: - Patients
    func fetchPatientList(identificationKey : String )
    {
        initiateWithUrlStringV2(urlString: getUrlFromPlist(keyValue: "PatientList"), httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard let self = self else { return }

            let patientResp = ParsingHelper.fillArrayOfPatientWithDictionary(dictionary: respObj)

            if let patientList = patientResp as? [Patient]{
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patientList, identificationKey: identificationKey)
            }
            else{
                if let error = patientResp as? NSError {
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
                }
            }

        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    func downloadPatientPhoto(patientId : String , indexpath : IndexPath? , identificationKey : String)
    {
        initiateRequestWithIndexpath(indexPath: indexpath, urlString: getUrlFromPlist(keyValue: "PatientPhoto", params: ["id": patientId]), identificationKey: identificationKey)
    }
    
    //MARK: - appointment
    
    func fetchAppointmentRestriction(practiceId : String?, identificationKey : String){
        
        let patient = getSelectedPatient()
        let patientId = getSelectedPatientId()
        
        let urlString = getUrlFromPlist(keyValue: "AppointmentRestriction", params: ["id": patientId, "practiceId": practiceId ?? ""])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success:{ [weak self] respObj in
            guard let self = self else { return }
            let appointmentRestriction = ParsingHelper.formAppointmentRestriction(practice: patient.getPracticeWith(practiceId: practiceId ?? ""), respObj: respObj)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: appointmentRestriction , identificationKey: identificationKey)
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    //?practice_id=\(practiceId) add it for fetching single practice data
    func fetchAppointment(patientId : String , practiceId : String? = nil  , identificationKey : String )
    {
        if isCustomApp()
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "UpcomingAppointmentByPractice", params: ["id": patientId, "practiceId": practiceId ?? ""]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "UpcomingAppointment", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func fetchPastAppointment(patientId : String , practiceId : String  , identificationKey : String )
    {
        if isCustomApp()
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "PastAppointmentByPractice", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "PastAppointment", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func fetchWaitlistAppointment(patientId : String , practiceId : String  , identificationKey : String )
    {
        if isCustomApp()
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "WaitlistAppointmentByPractice", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "WaitlistAppointment", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func fetchDeniedAppointment(patientId : String , practiceId : String , identificationKey : String )
    {
        if isCustomApp()
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "DeniedAppointmentByPractice", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "DeniedAppointment", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func fetchRequestedAppointment(patientId : String , practiceId : String , identificationKey : String )
    {
        if isCustomApp()
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "RequestedAppointmentByPractice", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "RequestedAppointment", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func downloadProviderPhoto(provider: Provider, indexPath: IndexPath, identificationKey: String){
        let urlString = getUrlFromPlist(keyValue: "ProviderPhoto", params: ["memberId": provider.memberId ?? "", "practiceId": provider.practiceId ?? ""])
        initiateRequestWithIndexpath(indexPath: indexPath, urlString: urlString, identificationKey: identificationKey)
    }
    
    func getFacilityList(selectedPractice: Practice, identificationKey : String ){
        
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            let practiceId = selectedPractice.practiceId ?? ""

            let urlString = getUrlFromPlist(keyValue: "FacilityList", params: ["practiceId": practiceId, "id": patientId])
            
            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
            success:{ [weak self] respObj in
                guard let self = self else { return }

                let facilityList = ParsingHelper.formFacilityListForAppointment(respObj: respObj, practiceId: practiceId)
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: facilityList, identificationKey: identificationKey)


            }, failure: { [weak self] apiError in
                guard let self = self else { return }

                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

            })
            
        }
        
    }
    
//    func getMembersList(facility: Facility , identificationKey : String){
//
//        let facilityId = facility.facilityId ?? ""
//
//        if facilityId.isNotBlank() {
//            let practiceId = facility.practiceId ?? ""
//            let patientId = getSelectedPatientId()
//
//            let urlString = "\(CharmConnectionHandler.serverName)/api/phr/v1/practices/\(practiceId)/providers?is_app_booking=true&facility_id=\(facilityId)&patient_id=\(patientId)"
//
//            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
//            success:{ [weak self] respObj in
//guard let self = self else { return }
//
//                let memberList = ParsingHelper.formMemberListForAppointment(respObj: respObj, practiceId: practiceId)
//                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: memberList, identificationKey: identificationKey)
//
//
//            }, failure: { [weak self] apiError in
//guard let self = self else { return }
//
//                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
//
//            })
//
//        }
//        else{
//            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: NSError(domain: "Facility Id not found", code: CUSTOM_ERROR_CODE), identificationKey: identificationKey)
//        }
//    }
    
    func getMemberListForBookAppointment(facility: Facility , identificationKey: String){
        
        getMemberListForBookAppointment(facility: facility, page: 1, count: 50, masterProviderList: [], success: { [weak self] providerList in
            guard let self = self else { return }

            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: providerList, identificationKey: identificationKey)


        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

        })
    }
    
    private func getMemberListForBookAppointment(facility: Facility,page:Int , count: Int,masterProviderList:[Provider] , success: @escaping ([Provider]) -> Void, failure: @escaping (Error) -> Void){
        
        let startIndex = (page - 1 ) * count
        var masterProviderList = masterProviderList
        
        let urlString = getUrlFromPlist(keyValue: "BookAppointmentProviders", params: ["practiceId": facility.practiceId ?? "", "id": getSelectedPatientId(), "facilityId": facility.facilityId ?? "", "startIndex": startIndex, "count": count])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard let self = self else { return }

            let providerList = ParsingHelper.formMemberListForAppointment(respObj: respObj, practiceId: facility.practiceId ?? "")

//            providerList.forEach({provider in
//                provider.practiceId = facility.practiceId
//               // provider.practiceName = practice.practiceName
//            })


            debugPrintLog("practice -> \(facility.practiceId ?? "");\npage -> \(page);\n currentCount-> \(providerList.count);\n")

            providerList.forEach({provider in
                if !masterProviderList.contains(where: { masterProvider in
                    return masterProvider.memberId == provider.memberId
                }){
                    masterProviderList.append(provider)
                }
            })

            if !providerList.isEmpty { // hasMore
                self.getMemberListForBookAppointment(facility: facility, page: page + 1, count: count, masterProviderList: masterProviderList, success: success, failure: failure)
            }
            else{
                success(masterProviderList)
            }

        }, failure: { [weak self] apiError in
            guard self != nil else { return }
            failure(apiError)
        })
    }
    
    func getAppointmentConfig(memberId: String , facility: Facility, identificationKey: String){
        let facilityId = facility.facilityId ?? ""
        let practiceId = facility.practiceId ?? ""
        let patientId = getSelectedPatientId()
        
        let urlString = getUrlFromPlist(keyValue: "AppointmentConfig", params: ["memberId": memberId, "practiceId": practiceId, "facilityId": facilityId, "id": patientId])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
        success:{ [weak self] respObj in
            guard let self = self else { return }

            let appointmentConfig = ParsingHelper.formAppointmentConfig(respObj: respObj)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: appointmentConfig, identificationKey: identificationKey)


        }, failure: { [weak self] apiError in
            guard let self = self else { return }

            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

        })

    }
    
    func getApoointmentSlots(memberId: String , facility: Facility , startDate: Date, endDate: Date , visitTypeId:String = "" ,interval: Int ,identificationKey: String) {
        
        
        let startDateStr = startDate.getStringFromDate(dateFormat: charmDateFormatForGettingSlots)
        let endDateStr = endDate.getStringFromDate(dateFormat: charmDateFormatForGettingSlots)

        let facilityId = facility.facilityId ?? ""
        let practiceId = facility.practiceId ?? ""
        let patientId = getSelectedPatientId()
        
        var urlString = getUrlFromPlist(keyValue: "AppointmentSlots", params: ["memberId": memberId, "practiceId": practiceId, "facilityId": facilityId, "id": patientId, "startDateStr": startDateStr, "endDateStr": endDateStr, "interval": interval])
        if visitTypeId.isNotBlank() {
            urlString += "&visit_type_id=\(visitTypeId)"
        }
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
        success:{ [weak self] respObj in
            guard let self = self else { return }

            let slotMetaData = ParsingHelper.formSlotsList(respObj: respObj)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: slotMetaData, identificationKey: identificationKey)


        }, failure: { [weak self] apiError in
            guard let self = self else { return }

            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

        })
        
    }
    
    func bookAppointment(appointmentRequest: AppointmentRequest, identificationKey : String ) {
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank() {
            appointmentRequest.practicePatientId = patientId
            
            let postObj = JsonBuilder.formAppointmentObj(appointmentRequest: appointmentRequest)
            
            let urlString: String

            if appointmentRequest.addAsWaitingList {
                urlString = getUrlFromPlist(keyValue: "RequestWaitlistAppointment")
            }
            else if appointmentRequest.isEnabled {
                urlString = getUrlFromPlist(keyValue: "AddAppointment", params: ["id": patientId])
            }
            else{
                urlString = getUrlFromPlist(keyValue: "RequestAppointment", params: ["id": patientId])
            }
            let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: []))!
            
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST,
            success:{ [weak self] respObj in
                guard let self = self else { return }

            //    AppticsExten
                trackEvent(eventName: "BookAppointmentOnSuccess", withGroupName: "Appointment")
                let resp: String = ParsingHelper.formBookAppointmentResp(respObj: respObj)
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: resp, identificationKey: identificationKey)


            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                trackEvent(eventName: "BookAppointmentOnFailure", withGroupName: "Appointment")

                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

            })
        }
    }
    
    func cancelAppointment(appointment: Appointment , reason: String , identificationKey: String) {
        let urlString = getUrlFromPlist(keyValue: "CancelAppointment", params: ["appointmentId": appointment.appointmentId ?? "", "practiceId": appointment.practiceId ?? "", "id": getSelectedPatientId(), "reason": reason])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: true, identificationKey: identificationKey)
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    func fetchFacilityForAppointment(practiceId : String , patientId : String , identificationKey : String )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "FacilityList", params: ["practiceId": practiceId, "id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchProviderName( practiceId : String , facilityId : String , identificationKey : String )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AppointmentProviders", params: ["practiceId": practiceId, "facilityId": facilityId, "id": Patient.selectedPatientInstance!.patientId!]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchAppointmenConfig( practiceId : String , memberId : String , facilityId : String , identificationKey : String )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AppointmentConfigV1", params: ["memberId": memberId, "practiceId": practiceId, "facilityId": facilityId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchAppointmentSlot( practiceId : String  , memberId : String , facilityId : String , fromDate: String , toDate : String ,visitTypeId : String? , interval : Int, identificationKey : String )
    {
        
        if visitTypeId != nil
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AppointmentSlotV1WithVisitType", params: ["memberId": memberId, "practiceId": practiceId, "facilityId": facilityId, "fromDate": fromDate, "toDate": toDate, "visitTypeId": visitTypeId!, "interval": interval]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)

        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AppointmentSlotV1", params: ["memberId": memberId, "practiceId": practiceId, "facilityId": facilityId, "fromDate": fromDate, "toDate": toDate, "interval": interval]),dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func requestAddAppointment( patientId : String,json : Dictionary<String,Any> , identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "RequestAppointment", params: ["id": patientId]), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func requestWaitlistAppointment(json : Dictionary<String,Any> , identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "RequestWaitlistAppointment"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    
    }
    
    func addNewAppointment( patientId : String ,json : Dictionary<String,Any> , identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AddAppointment", params: ["id": patientId]), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func fetchVideoConsultation(appointment: Appointment , identificationKey: String){
        
        let urlString = getUrlFromPlist(keyValue: "VideoConsultation", params: ["id": getSelectedPatientId(), "appointmentId": appointment.appointmentId ?? "", "practiceId": appointment.practiceId ?? ""])
        
        initiateWithUrlStringV2(urlString: urlString, dataToPost: nil, httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard let self = self else { return }

            let zoomCredentials = ParsingHelper.formZoomCredentials(respObj: respObj)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: zoomCredentials, identificationKey: identificationKey)

        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    func fetchAppointmentVideoConsultValues(appointmentId:String , practiceId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "VideoConsultation", params: ["id": getSelectedPatientId(), "appointmentId": appointmentId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
        
    func deleteAppointment(id : String? , practiceId : String? , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "DeleteAppointmentRequest", params: ["id": id ?? "", "practiceId": practiceId ?? ""]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
    }
    
    func deleteWaitlistAppointment(id : String? , practiceId : String?, identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "DeleteWaitlistAppointment", params: ["practiceId": practiceId ?? "", "id": id ?? ""]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    //MARK: - Billing
    func fetchInvoices(patientId : String , practiceId : String  , identificationKey : String , fromRange : Int , toRange : Int )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "Invoices", params: ["id": patientId, "practiceId": practiceId, "fromRange": fromRange, "toRange": toRange]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchInvoiceList(pageNo: Int,practiceList tempPracticeList: [String]? = nil,identificationKey : String ){
        
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            
            let fromRange: Int =  ((pageNo - 1)  *  newlistPerPageCount) + 1
            
            let practiceList = tempPracticeList ?? getEnabledPractices(moduleId: billingModelId)
            let practiceSize = practiceList.count
            
            let dataResp = MDPagiationDataResponse<PHRBills>()
            var phrBillList:[PHRBills] = []
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                let urlString = getUrlFromPlist(keyValue: "InvoiceList", params: ["id": patientId, "practiceId": practiceId, "fromRange": fromRange, "listPerPageCount": listPerPageCount])
                
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard let self = self else { return }
                    respCount+=1
                    let invoiceList = ParsingHelper.formInvoiceList(dictionary: respObj, practiceId: practiceId)
                    phrBillList.append(contentsOf: invoiceList)

                    dataResp.hasMore[practiceId] = phrBillList.count == newlistPerPageCount

                    if respCount == practiceSize && !isCallbackSent {

                        dataResp.data = phrBillList
                        dataResp.perPage = newlistPerPageCount
                        dataResp.page = pageNo


                        self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: dataResp, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                }, failure: { [weak self] apiError in
                    guard let self = self else { return }

                    respCount+=1
                    if !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                })
            })
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
    func fetchInvoiceDetail(patientId : String , phrBillId: String , identificationKey : String )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "InvoiceDetail", params: ["id": patientId, "phrBillId": phrBillId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func getStatementDetails(statementId: String, identificationKey: String){
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "StatementDetail", params: ["id": patientId, "statementId": statementId])
        
        initiateWithUrlStringV2(urlString: urlString,httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard let self = self else { return }
            let statement = ParsingHelper.formStatementDetail(respObj: respObj)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: statement, identificationKey: identificationKey)
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    func fetchReceipts(patientId : String , practiceId : String , identificationKey : String , fromRange : Int , toRange : Int )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "Receipts", params: ["id": patientId, "practiceId": practiceId, "fromRange": fromRange, "toRange": toRange]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    
    func fetchReceiptList(pageNo: Int,practiceList tempPracticeList: [String]? = nil, identificationKey : String ){
        
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            
            let fromRange: Int =  ((pageNo - 1)  *  newlistPerPageCount) + 1
            
            let practiceList = tempPracticeList ?? getEnabledPractices(moduleId: billingModelId)
            let practiceSize = practiceList.count
            
            var phrReceiptList:[PHRReceipts] = []
            let dataResp = MDPagiationDataResponse<PHRReceipts>()
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                let urlString = getUrlFromPlist(keyValue: "ReceiptList", params: ["id": patientId, "practiceId": practiceId, "fromRange": fromRange, "newlistPerPageCount": newlistPerPageCount])
                
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard let self = self else { return }
                    respCount+=1
                    let receiptList = ParsingHelper.formReceiptList(dictionary: respObj, practiceId: practiceId)
                    phrReceiptList.append(contentsOf: receiptList)

                    dataResp.hasMore[practiceId] = receiptList.count == newlistPerPageCount

                    if respCount == practiceSize && !isCallbackSent {

                        dataResp.data = phrReceiptList
                        dataResp.page = pageNo
                        dataResp.perPage = newlistPerPageCount

                        self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: dataResp, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                }, failure: { [weak self] apiError in
                    guard let self = self else { return }

                    respCount+=1
                    if !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                })
            })
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
    func downloadReceiptPDF(patientId: String, phrReceiptId: String?, identificationKey: String)
    {
        
        initiateRequestWithIndexpath(indexPath: nil, urlString: getUrlFromPlist(keyValue: "ReceiptDownload", params: ["id": patientId, "phrReceiptId": phrReceiptId ?? ""]), identificationKey:identificationKey)
    }
    
    func updateReadStatusForReceipts(patientId: String, phrReceiptId: String?, identificationKey: String){
        let urlString = getUrlFromPlist(keyValue: "ReceiptReadStatus", params: ["id": patientId, "phrReceiptId": phrReceiptId ?? ""])
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: resp, identificationKey: identificationKey)
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    
    //MARK: - messages
    
    func fetchMessageRestriction(identificationKey: String){
        
        let patient = getSelectedPatient()
        let patientId = patient.patientId ?? ""
        
        if patientId.isNotBlank(){
            
            let practiceList = getEnabledPractices(moduleId: messageModuleId)
            let practiceSize = practiceList.count
            var patientMessageRestrictionList:[MessageRestriction] = []
             
            if practiceSize != 0 {
                var respCount = 0
                var isCallbackSent = false
              
                practiceList.forEach({practiceId in
                    let urlString = getUrlFromPlist(keyValue: "MessageRestriction", params: ["id": patientId, "practiceId": practiceId])
                    
                    initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                                            success:{ [weak self] respObj in
                        guard let self = self else { return }
                        respCount+=1


                        let messageRestriction = ParsingHelper.formMessageRestriction(practice: patient.getPracticeWith(practiceId: practiceId), respObj: respObj)
                        patientMessageRestrictionList.append(messageRestriction)

                        if respCount == practiceSize && !isCallbackSent{
                            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patientMessageRestrictionList , identificationKey: identificationKey)
                            isCallbackSent = true
                        }

                    }, failure: { [weak self] apiError in
                        guard let self = self else { return }

                        respCount+=1
                        if !isCallbackSent{
                            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                            isCallbackSent = true
                        }

                    })
                })
            }
            else{
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patientMessageRestrictionList , identificationKey: identificationKey)
            }
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
    func fetchMessages(patientId : String , practiceId : String , identificationKey : String , fromRange : Int , toRange : Int , messageType : String )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "MessageList", params: ["id": patientId, "practiceId": practiceId, "messageType": messageType, "fromRange": fromRange, "toRange": toRange]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchMessageList(page:Int, messageType: String,practiceList tempPracticeList: [String]? = nil ,identificationKey : String ){
        
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            
            let practiceList = tempPracticeList ?? getEnabledPractices(moduleId: messageModuleId)
            let practiceSize = practiceList.count
            
            let respData = MDPagiationDataResponse<Messages>()
            var patientMessageList:[Messages] = []
            var respCount = 0
            
            let fromRange: Int =  ((page - 1)  *  newlistPerPageCount) + 1

            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                let urlString = getUrlFromPlist(keyValue: "MessageListPage", params: ["id": patientId, "practiceId": practiceId, "messageType": messageType, "fromRange": fromRange, "newlistPerPageCount": newlistPerPageCount])
                
//                if let isRead = isRead {
//                    urlString += "&is_read=\(isRead)"
//                }
//                
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard let self = self else { return }
                    respCount+=1
                    let messageList = ParsingHelper.formMessageList(respObj: respObj, messageType: messageType, practiceId: practiceId)
                    patientMessageList.append(contentsOf: messageList)

                    respData.hasMore[practiceId] = messageList.count == newlistPerPageCount

                    if respCount == practiceSize && !isCallbackSent{

                        //TODO: Have to remove once the api bug is fixed
                        if messageType == "unread"{
                            patientMessageList = FilterHandler.filterMessages(arrayOfMessages: patientMessageList)
                        }

                        patientMessageList = FilterHandler.sortMessages(arrayOfMessages: patientMessageList)

                        respData.data = patientMessageList
                        respData.page = page
                        respData.perPage = newlistPerPageCount


                        self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respData , identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                }, failure: { [weak self] apiError in
                    guard let self = self else { return }

                    respCount+=1
                    if !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                })
            })
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
    func fetchMessageDetail(message : Messages , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "MessageDetail", params: ["messageId": message.messageId ?? "", "practiceId": message.practiceId ?? "", "id": getSelectedPatientId()]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func getProviderListForComposeMessage(practice: Practice, groupId: String?, ownerId: String?, identificationKey: String){

        var urlString = getUrlFromPlist(keyValue: "MessageProviders", params: ["id": getSelectedPatientId(), "practiceId": practice.practiceId ?? ""])

        if let groupId, let ownerId{
            urlString.append("&group_id=\(groupId)&owner_id=\(ownerId)")
        }
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET) { [weak self] respObj in
            guard let self = self else { return }
            let providerList = ParsingHelper.formProviderForComposeMessage(dict: respObj)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: providerList, identificationKey: identificationKey)
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    func getProviderListForComposeMessage(practice: Practice, pageNo: Int, perPageCount: Int, searchText: String?, identificationKey: String){

        let startIndex = ((pageNo - 1) * perPageCount) + 1
        var urlString = getUrlFromPlist(keyValue: "MessageProvidersPage", params: ["id": getSelectedPatientId(), "practiceId": practice.practiceId ?? "", "startIndex": startIndex, "perPageCount": perPageCount])

        if let searchText{
            urlString.append("&searchString=\(searchText)")
        }

        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET) { [weak self] respObj in
            guard let self = self else { return }
            let providerList = ParsingHelper.formProviderForComposeMessage(dict: respObj)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: providerList, identificationKey: identificationKey)
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    func fetchProviderList(practiceId : String , identificationKey : String )
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "MessagePreferenceProviders", params: ["practiceId": practiceId, "id": Patient.selectedPatientInstance!.patientId!]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func deleteMessageDetail(message : Messages , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "MessageDetail", params: ["messageId": message.messageId ?? "", "practiceId": message.practiceId ?? "", "id": getSelectedPatientId()]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
    }
        
    func postComposeMessage(composeMsg: ComposeMessage, identificationKey : String)
    {
        let urlString = getUrlFromPlist(keyValue: "Messages")
        
        let postObj = JsonBuilder.formComposeMsgObj(composeMsg: composeMsg)
        
        if let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: [])){
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
                guard let self = self else { return }
                let message = respObj.getString("message") ?? ""
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: message, identificationKey: identificationKey)

            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    func addAttachments(attachmentList : [Dictionary<String,Any>], identificationKey : String){
        let urlString = getUrlFromPlist(keyValue: "MessageAttachmentFile")
        
        let totalCount = attachmentList.count
        
        var attachmentIdList:[String] = []
        var isRespSent = false
        
        attachmentList.forEach({ attachmentObj in
            initiateRequestWithData(param: attachmentObj, urlString: urlString, fileKeyPath: "file" , success: { [weak self] respObj in
                guard let self = self else { return }
                attachmentIdList.append(ParsingHelper.getAttachmentId(respObj: respObj))
                if !isRespSent && attachmentIdList.count == totalCount {
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: attachmentIdList, identificationKey: identificationKey)
                }
            } , failure: { [weak self] apiError in
                guard let self = self else { return }
                if !isRespSent {
                    isRespSent = true
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                }
            })
        })
    }
    
    func addAttachment( param : Dictionary<String,Any>, identificationKey : String )
    {
        initiateRequestWithData(param: param, urlString: getUrlFromPlist(keyValue: "MessageAttachmentFile"), fileKeyPath: "file", identificationKey: identificationKey)
    }
    
    func getAttachement(message : Messages? , attachmentId : String , identificationKey : String )
    {
        initiateRequestWithIndexpath(indexPath: nil, urlString: getUrlFromPlist(keyValue: "MessageAttachmentDownload", params: ["messageId": message?.messageId ?? "", "attachmentId": attachmentId, "practiceId": message?.practiceId ?? "", "id": getSelectedPatientId()]), identificationKey: identificationKey)
    }
    
    func fetchProviderPhoto(providerId : String , practiceId : String , providerIndex : Int?, identificationKey : String)
    {
        if providerIndex == nil
        {
            initiateRequestWithIndexpath(indexPath: nil, urlString: getUrlFromPlist(keyValue: "MessageProviderPhoto", params: ["providerId": providerId, "practiceId": practiceId]), identificationKey: identificationKey)
        }else
        {
            initiateRequestWithIndexpath(indexPath: IndexPath(row: providerIndex!, section: 0), urlString: getUrlFromPlist(keyValue: "MessageProviderPhoto", params: ["providerId": providerId, "practiceId": practiceId]), identificationKey: identificationKey)
        }
    }
    
    func fetchProviderPhoto(providerId : String , practiceId : String , indexPath: IndexPath, identificationKey : String)
    {
        
        initiateRequestWithIndexpath(indexPath: indexPath, urlString: getUrlFromPlist(keyValue: "MessageProviderPhoto", params: ["providerId": providerId, "practiceId": practiceId]), identificationKey: identificationKey)
        
    }
    
    //MARK: - labs
    
    func fetchLabsList(pageNo:Int, listPerPageCount: Int, identificationKey : String ){
        
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            
            let fromRange: Int =  ((pageNo - 1)  *  listPerPageCount) + 1
            
            let practiceList = getEnabledPractices(moduleId: labModelId)
            let practiceSize = practiceList.count
            
            var labList:[MedicalRecordGroup] = []
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                let urlString = getUrlFromPlist(keyValue: "Labs", params: ["id": patientId, "practiceId": practiceId, "fromRange": fromRange, "listPerPageCount": listPerPageCount])
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard let self = self else { return }
                    respCount+=1
                    let labTempList = ParsingHelper.formLabList(respObj: respObj)
                
                    for labResult in labTempList{
                        if labResult.medicalRecordEntryList.firstOrNil()?.isImportedByPatient == false {
                            labResult.practiceId = practiceId
                            labList.append(labResult)
                        }
                        else{
                            if !labList.contains(where: {lab in
                                return lab.groupId == labResult.groupId
                            }) {
                                labList.append(labResult)
                            }
                        }
                    }
                    
                    if respCount == practiceSize && !isCallbackSent{
                    
                        self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: FilterHandler.filterAndSortLabResults(arrayOfResults: labList), identificationKey: identificationKey)
                        isCallbackSent = true
                    }
                    
                }, failure: { [weak self] apiError in
                    
                         guard let self = self else { return }
                    
                    respCount+=1
                    if !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                })
            })
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
    func fetchLabResultsDetails(patientId : String, medicalRecordGroup : MedicalRecordGroup? , identificationKey : String)
    {
        var urlString = getUrlFromPlist(keyValue: "LabResultDetail", params: ["id": patientId, "groupId": medicalRecordGroup?.groupId ?? ""])
        
        if medicalRecordGroup?.isAddedByPatient == false {
            urlString += "?practice_id=\(medicalRecordGroup?.practiceId ?? "")"
        }
        
        initiateWithUrlString(urlString: urlString, dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func downloadLabResults(patientId : String, medicalRecordGroup: MedicalRecordGroup?, identificationKey : String)
    {
        var urlString = getUrlFromPlist(keyValue: "LabResultDownload", params: ["id": patientId, "groupId": medicalRecordGroup?.groupId ?? "", "labName": medicalRecordGroup?.labName ?? "lab"])
        
        if medicalRecordGroup?.isAddedByPatient == false {
            urlString += "&practice_id=\(medicalRecordGroup?.practiceId ?? "")"
        }
        
        initiateRequestWithIndexpath(indexPath: nil, urlString: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", identificationKey: identificationKey)
    }
    
    func fetchLabOrders(identificationKey: String, fromDate: Date? = nil, toDate: Date? = nil){
        let patientId = getSelectedPatientId()
        
        var urlString = ""
        if let fromDate = fromDate, let toDate = toDate{
            let fromMills = fromDate.millisecondsSince1970
            let toMills = toDate.millisecondsSince1970
            urlString = getUrlFromPlist(keyValue: "LabOrderByDate", params: ["id": patientId, "fromMills": fromMills, "toMills": toMills])
        }
        else{
            urlString = getUrlFromPlist(keyValue: "LabOrder", params: ["id": patientId])
        }
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET) { [self] resp in
            let labOrdersList = ParsingHelper.formLabOrderList(dict: resp)
            v2Delegate?.charmConnectionV2HandlerDidRecieve(response: labOrdersList, identificationKey: identificationKey)
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    func downloadLabOrders(fileId: String, identificationKey: String){
        let patientId = getSelectedPatientId()
        
        let urlString = getUrlFromPlist(keyValue: "LabOrderFile", params: ["id": patientId, "fileId": fileId])
        initiateRequestWithIndexpath(indexPath: nil, urlString: urlString, identificationKey: identificationKey, callV2: true)
    }
    
    //MARK: - Allergies
    
    func fetchAllergiesList(pageNo:Int, identificationKey: String, allergyType : String, isHealthPassport : Bool = false){
        
        let patientId = getSelectedPatientId()
        if isHealthPassport
        {
            initiateWithUrlStringV2(urlString: getHealthPassportUrlFromPlist(keyValue: "Allergy", params: ["id": patientId, "allergyType": allergyType]), httpMethod: .HTTP_METHOD_GET, success: { [weak self]resp in
                
                     guard let self = self else { return }
                
                let allergyList = ParsingHelper.formAllergyList(dict: resp, status: nil)
                v2Delegate?.charmConnectionV2HandlerDidRecieve(response: allergyList, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }else
        {
            if patientId.isNotBlank(){
                let practiceList = getEnabledPractices(moduleId: allergiesModelId)
                let practiceSize = practiceList.count
                
                let fromRange: Int =  ((pageNo - 1)  *  listPerPageCount) + 1

                
                var allergiesList: [AllergiesList] = []
                var respCount = 0
                
                var isCallbackSent = false
                
                practiceList.forEach({practiceId in
                    let urlString = getUrlFromPlist(keyValue: "AllergyList", params: ["id": patientId, "practiceId": practiceId, "allergyType": allergyType, "fromRange": fromRange, "listPerPageCount": listPerPageCount])
                    
                    initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                    success:{ [weak self] respObj in
                        guard let self = self else { return }
                        respCount+=1
                        let allergiesTempList = ParsingHelper.formAllergyList(dict: respObj, status: nil)
                    
                        for allergiesTemp in allergiesTempList{
                            if !(allergiesTemp.patientAllergyMap?.isAddedByPatient ?? false) {
                                allergiesList.append(allergiesTemp)
                            }
                            else{
                                if !allergiesList.contains(where: {allergies in
                                    return allergies.allergyId == allergiesTemp.allergyId
                                }) {
                                    allergiesList.append(allergiesTemp)
                                }
                            }
                        }
                        
                        if respCount == practiceSize && !isCallbackSent{
                        
                            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: allergiesList, identificationKey: identificationKey)
                            isCallbackSent = true
                        }
                        
                    }, failure: { [weak self] apiError in
                        
                             guard let self = self else { return }
                        
                        respCount+=1
                        if !isCallbackSent{
                            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                            isCallbackSent = true
                        }
                    })
                })
            }
            
        }
    }
    
    func fetchAllergiesList(patientId : String , isHealthPassport : Bool = false , practiceId : String , allergyType : String , identificationKey : String)
    {
        if isHealthPassport
        {
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "Allergy", params: ["id": patientId, "allergyType": allergyType]), identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AllergyByPractice", params: ["id": patientId, "practiceId": practiceId, "allergyType": allergyType]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func fetchAllergiesRelatedData(patientId : String, isHealthPassport : Bool = false , practiceId : String , identificationKey : String)
    {
        if isHealthPassport
        {
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "AllergyCommonData", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
        else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AllergyCommonDataByPractice", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func addAllergy(jsonObject : Dictionary<String,Any>, identificationKey : String , httpMedthod : HTTP_METHOD)
    {
         let jsonData = (try? JSONSerialization.data(withJSONObject: jsonObject, options: []))!
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AllergyMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: httpMedthod)
    }

    //TODO: want to check url of delete allergy 
    func deleteAllergy(json : Dictionary<String,Any> , isHealthPassport : Bool = false , identificationKey : String)
    {
        if isHealthPassport
        {
            let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "AllergyMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
        }
        else
        {
            let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "AllergyMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
        }
    }
    
    //MARK: - Prescription
    
    private func fetchMedicationList(viewType : String? = nil, patientId: String, success: @escaping ([MedicationPOJO]) -> Void, failure: @escaping (Error) -> Void){
        
        if patientId.isNotBlank(){
            
            let practiceList = getEnabledPractices(moduleId: medicationModelId)
            let practiceSize = practiceList.count
            
            var medicationPOJOList:[MedicationPOJO] = []
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                var urlString = getUrlFromPlist(keyValue: "Prescriptions", params: ["id": patientId, "practiceId": practiceId])
                
                if let viewType = viewType {
                    urlString = urlString + "&view=\(viewType)"
                }
                
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard self != nil else { return }
                    respCount+=1
                    let tempList = ParsingHelper.formMedicationList(respObj: respObj)
                    medicationPOJOList.append(contentsOf: tempList)
                    
                    if respCount == practiceSize && !isCallbackSent {
                        
                        medicationPOJOList = FilterHandler.filterAndSortMedication(arrayOfMedicationPOJO: medicationPOJOList)
                        
                        success(medicationPOJOList)
                        isCallbackSent = true
                    }
                    
                }, failure: { [weak self] apiError in
                    
                         guard self != nil else { return }
                    
                    respCount+=1
                    if !isCallbackSent{
                        failure(apiError)
                        isCallbackSent = true
                    }

                })
            })
        }
        else{
            failure(CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error"))
        }
    }
    
    func fetchMedicationList(viewType : String? = nil, patientId: String, identificationKey : String ){
        fetchMedicationList(viewType: viewType, patientId: patientId, success: { [weak self] patientMedicationList in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patientMedicationList, identificationKey: identificationKey)
            
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    
    func postRefillMedications(json : Dictionary<String,Any> , identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "MedicationRefill", params: ["id": Patient.selectedPatientInstance!.patientId!]), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func fetchCommonDataForAddMedication(practiceId : String , isHealthCard : Bool ,identificationKey : String)
    {
        let patientId = getSelectedPatientId()
        if isHealthCard
        {
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "MedicationCommonData", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "MedicationCommonDataByPractice", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func addMedication(practiceId: String? ,medicationPOJO: MedicationPOJO ,identificationKey: String){
        
        let json = JsonBuilder.convertMedicationToJson( practiceId: practiceId, medicationPOJO: medicationPOJO)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])){
            let urlString = getUrlFromPlist(keyValue: "Medications", params: ["id": getSelectedPatientId()])
            initiateWithUrlStringV2(urlString: urlString,dataToPost: jsonData ,httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
                
                     guard let self = self else { return }
                
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
        }
    }
    
    func editMedication(practiceId: String? ,medicationPOJO: MedicationPOJO ,identificationKey: String){
        
        let json =  JsonBuilder.convertMedicationToJson(practiceId: practiceId, medicationPOJO: medicationPOJO)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])){
        
            let urlString = getUrlFromPlist(keyValue: "MedicationsV1", params: ["id": getSelectedPatientId()])
            initiateWithUrlStringV2(urlString: urlString,dataToPost: jsonData ,httpMethod: .HTTP_METHOD_PUT, success: { [weak self] respObj in
                
                     guard let self = self else { return }
                
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
        }
    }
    
    func addMedication(json : Dictionary<String,Any> , patientId : String, identificationKey : String , isHealthPassport : Bool = false , httpMedthod : HTTP_METHOD)
    {
        if isHealthPassport
        {
            let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "MedicationsV1", params: ["id": patientId]), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: httpMedthod)
        }else
        {
            let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "MedicationsV1", params: ["id": patientId]), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: httpMedthod)
        }
    }
    
    func deleteMedication( patientMedicationId : String , identificationKey : String)
    {
        if let jsonData = (try? JSONSerialization.data(withJSONObject: ["prescription_history_id":"\(patientMedicationId)"], options: [])){
                
            let urlString = getUrlFromPlist(keyValue: "MedicationsV1", params: ["id": getSelectedPatientId()])
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_DELETE, success: { [weak self] respObj in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.error.createRequest.title")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
//    func deleteMedication(patientId : String, isHealthPassport: Bool = false, prescriptionHistoryId : String , identificationKey : String)
//    {
//        if isHealthPassport
//        {
//            let jsonData = (try? JSONSerialization.data(withJSONObject: ["patient_id":"\(patientId)","prescription_history_id":"\(prescriptionHistoryId)"], options: []))!
//            initiateWithUrlString(urlString: "\(healthPassportServerName)/api/phr/v1/patients/\(patientId)/medications", dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
//        }
//        else
//        {
//            let jsonData = (try? JSONSerialization.data(withJSONObject: ["patient_id":"\(patientId)","prescription_history_id":"\(prescriptionHistoryId)"], options: []))!
//            initiateWithUrlString(urlString: "\(CharmConnectionHandler.serverName)/api/phr/v1/patients/\(patientId)/medications", dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
//        }
//    }
    
    private func fetchSupplementList(viewType : String? = nil, patientId: String, success: @escaping ([SupplementPOJO]) -> Void, failure: @escaping (Error) -> Void){
        
        if patientId.isNotBlank(){
                        
            let practiceList = getEnabledPractices(moduleId: supplementModelId)
            let practiceSize = practiceList.count
            
            var supplementPOJOList:[SupplementPOJO] = []
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                var urlString = getUrlFromPlist(keyValue: "Supplements", params: ["id": patientId, "practiceId": practiceId])
                
                if let viewType = viewType {
                    urlString = urlString + "&view=\(viewType)"
                }
                
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard self != nil else { return }
                    respCount+=1
                    let tempList = ParsingHelper.formSupplementList(respObj: respObj, practiceId: practiceId)
                    supplementPOJOList.append(contentsOf: tempList)
                    
                    if respCount == practiceSize && !isCallbackSent {
                        
                        supplementPOJOList = FilterHandler.filterAndSortSupplement(arrayOfSupplemenPOJO: supplementPOJOList)
                        success(supplementPOJOList)

                        isCallbackSent = true
                    }
                    
                }, failure: { [weak self] apiError in
                    
                         guard self != nil else { return }
                    
                    respCount+=1
                    if !isCallbackSent{
                        failure(apiError)
                        isCallbackSent = true
                    }
                })
            })
        }
        else{
            failure(CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error"))
        }
    }
    
    func fetchSupplementList(viewType : String? = nil, identificationKey : String, patientId: String){
        
        fetchSupplementList(viewType: viewType, patientId: patientId, success: { [weak self] supplementList in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: supplementList, identificationKey: identificationKey)
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    func fetchCommonDataForAddSupplement(patientId : String , practiceId : String ,identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "SupplementCommonData", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }

    func fetchCommonDataForAddSupplement(practiceId : String ,identificationKey : String)
    {
        let urlString = getUrlFromPlist(keyValue: "SupplementCommonData", params: ["id": getSelectedPatientId(), "practiceId": practiceId])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    
    
    func addSupplement(practiceId: String?, supplementPOJO: SupplementPOJO , identificationKey: String){
        supplementPOJO.patientSupplement?.patientId = getSelectedPatientId()
        let json = JsonBuilder.formAddSupplementObj(practiceId: practiceId, supplementPOJO: supplementPOJO)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])){
        
            let urlString = getUrlFromPlist(keyValue: "SupplementsV2", params: ["id": getSelectedPatientId()])
            initiateWithUrlStringV2(urlString: urlString,dataToPost: jsonData ,httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
                
                     guard let self = self else { return }
                
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
        }

    }
    
    func editSupplement(supplementPOJO: SupplementPOJO , identificationKey: String){
        supplementPOJO.patientSupplement?.patientId = getSelectedPatientId()
        let json =  JsonBuilder.formEditSupplementObj(supplementPOJO: supplementPOJO)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])){
        
            let urlString = getUrlFromPlist(keyValue: "SupplementsV1", params: ["id": getSelectedPatientId()])
            initiateWithUrlStringV2(urlString: urlString,dataToPost: jsonData ,httpMethod: .HTTP_METHOD_PUT, success: { [weak self] respObj in
                
                     guard let self = self else { return }
                
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
        }

    }
    
//    func addSupplement(json : Dictionary<String,Any> , patientId : String, identificationKey : String , httpMedthod : HTTP_METHOD)
//    {
//        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
//        initiateWithUrlString(urlString: "\(CharmConnectionHandler.serverName)/api/phr/v1/patients/\(patientId)/supplement", dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: httpMedthod)
//    }
    
    
    func deleteSupplement(patientSupplementId: String, identificationKey: String){
        
        if let jsonData = (try? JSONSerialization.data(withJSONObject: ["supplement_history_id":"\(patientSupplementId)"], options: [])){
                
            let urlString = getUrlFromPlist(keyValue: "SupplementsV1", params: ["id": getSelectedPatientId()])
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_DELETE, success: { [weak self] respObj in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.error.createRequest.title")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
//    func deleteSupplements(patientId : String , supplementHistoryId : String , identificationKey : String)
//    {
//        let jsonData = (try? JSONSerialization.data(withJSONObject: ["patient_id":"\(patientId)","supplement_history_id":"\(supplementHistoryId)"], options: []))!
//        initiateWithUrlString(urlString: "\(CharmConnectionHandler.serverName)/api/phr/v1/patients/\(patientId)/supplement", dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
//    }
    
    //MARK: - visit summary
    
    func fetchVisitSummaryList(pageNo: Int, identificationKey:String){
        
        let fromRange: Int =  ((pageNo - 1)  *  listPerPageCount) + 1

        var urlString = getUrlFromPlist(keyValue: "VisitSummaryList", params: ["id": getSelectedPatientId(), "fromRange": fromRange, "listPerPageCount": listPerPageCount])

        if isCustomApp() {
            urlString = urlString + "&practice_id=\(AppConfig.sharedInstance.customAppPracticeId ?? "")"
        }

        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self]respObj in
            guard let self = self else { return }
            
            let visitSummaryList = ParsingHelper.formVisitSummaryList(respObj: respObj)
            
            debugPrintLog("visitsummary count -> \(visitSummaryList.count)")

            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response:FilterHandler.filterAndSortVisitSummary(arrayOfVisitSummary: visitSummaryList) , identificationKey: identificationKey)

        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    
    func fetchVisitSummaryList(patientId : String , practiceId : String? = nil  , identificationKey : String)
    {
        if practiceId == nil
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "VisitSummaryDetail", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "VisitSummaryByPractice", params: ["id": patientId, "practiceId": practiceId!]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    
    func getVisitSummaryPDF(selectedPatientEncounter : PatientEncounterList, identificationKey : String)
    {
        initiateRequestWithIndexpath(indexPath: nil, urlString: getUrlFromPlist(keyValue: "VisitSummaryDownload", params: ["id": getSelectedPatientId(), "patientEncounterId": selectedPatientEncounter.patientEncounterId ?? "", "practiceId": selectedPatientEncounter.practiceId ?? ""]), identificationKey: identificationKey , callV2: true)
    }
    
    //MARK: - procedure
    
    func fetchProcedureList(isHealthPassport : Bool = false , identificationKey : String){
        let patientId = getSelectedPatientId()
        
        if isHealthPassport
        {
            initiateWithUrlStringV2(urlString: getHealthPassportUrlFromPlist(keyValue: "Procedures", params: ["id": patientId]), httpMethod: .HTTP_METHOD_GET, success: { [weak self]resp in
                guard let self = self else { return }
                let procedureList = ParsingHelper.formProcedureList(resp: resp)
                v2Delegate?.charmConnectionV2HandlerDidRecieve(response: procedureList, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }else
        {
            initiateWithUrlStringV2(urlString: getUrlFromPlist(keyValue: "Procedures", params: ["id": patientId]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                guard let self = self else { return }
                let procedureList = ParsingHelper.formProcedureList(resp: resp)
                v2Delegate?.charmConnectionV2HandlerDidRecieve(response: procedureList, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    func fetchProcedureList(patientId : String, isHealthPassport : Bool = false , identificationKey : String)
    {
        if isHealthPassport
        {
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "Procedures", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "Procedures", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func fetchCommonDataForProcedure(patientId : String, isHealthPassport : Bool =  false, practiceId : String? = nil , identificationKey : String)
    {
        if isHealthPassport
        {
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "ProcedureCommonData", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "ProcedureCommonData", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func addProcedure(json : Dictionary<String,Any>, isHealthPassport : Bool = false , identificationKey : String , httpMedthod : HTTP_METHOD)
    {
        if isHealthPassport
        {
            let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "ProcedureMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: httpMedthod)
        }else
        {
            let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "ProcedureMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: httpMedthod)
        }
    }
    
    func deleteProcedure(patientId : String , isHealthPassport : Bool = false , procedureMapId : String , identificationKey : String)
    {
        if isHealthPassport
        {
            let jsonData = (try? JSONSerialization.data(withJSONObject: ["patient_id":"\(patientId)","procedure_map_id":"\(procedureMapId)"], options: []))!
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "ProcedureMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
        }else
        {
            let jsonData = (try? JSONSerialization.data(withJSONObject: ["patient_id":"\(patientId)","procedure_map_id":"\(procedureMapId)"], options: []))!
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "ProcedureMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
        }
    }
    
    //MARK: - vaccine
    func fetchVaccines(patientId : String , practiceId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "Immunizations", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchVaccineList(pageNo:Int, identificationKey : String ){
        
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            
            let fromRange: Int =  ((pageNo - 1)  *  listPerPageCount) + 1
            
            let practiceList = getEnabledPractices(moduleId: vaccineModelId)
            let practiceSize = practiceList.count
            
            var vaccineList: [VaccineImmunizationPOJO] = []
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                let urlString = getUrlFromPlist(keyValue: "ImmunizationList", params: ["id": patientId, "practiceId": practiceId, "fromRange": fromRange, "listPerPageCount": listPerPageCount])
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard let self = self else { return }
                    respCount+=1
                    let vaccineTempList = ParsingHelper.formVaccineList(respObj: respObj , practiceId: practiceId)
                
                    for vaccineTemp in vaccineTempList{
                        if !vaccineTemp.addedByPatient {
                            vaccineList.append(vaccineTemp)
                        }
                        else{
                            if !vaccineList.contains(where: {vaccine in
                                return vaccine.patientImmunizationMap?.patientImmunizationHistory?.immunizationHistoryId == vaccineTemp.patientImmunizationMap?.patientImmunizationHistory?.immunizationHistoryId
                            }) {
                                vaccineList.append(vaccineTemp)
                            }
                        }
                    }
                    
                    if respCount == practiceSize && !isCallbackSent{
                    
                        self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: FilterHandler.filterAndSortVaccine(arrayOfVaccine: vaccineList), identificationKey: identificationKey)
                        isCallbackSent = true
                    }
                    
                }, failure: { [weak self] apiError in
                    
                         guard let self = self else { return }
                    
                    respCount+=1
                    if !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                })
            })
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
        
    }
       
    func deleteVaccines(patientId : String , immuneHistoryId : String , identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: ["patient_id":"\(patientId)","immune_history_id":"\(immuneHistoryId)"], options: []))!
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "ImmunizationMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
    }
    
    func addVaccine(json : Dictionary<String,Any> , identificationKey : String , httpMedthod : HTTP_METHOD)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "ImmunizationMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: httpMedthod)
    }
    
    func addOrUpdateVaccine(vaccine: VaccineImmunizationPOJO, identificationKey : String , toUpdate: Bool = false){
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            vaccine.patientImmunizationMap?.patientId = patientId
            
            
            
            let reqObj: Dictionary<String,Any>
            var httpMethod: HTTP_METHOD = .HTTP_METHOD_POST
            if toUpdate{
                reqObj = JsonBuilder.formEditVaccineObj(immunizationPOJO: vaccine)
                httpMethod = .HTTP_METHOD_PUT
            }
            else{
                reqObj = JsonBuilder.formAddVaccineObj(immunizationPOJO: vaccine)
            }

            if let jsonData = (try? JSONSerialization.data(withJSONObject: reqObj, options: [])){
                initiateWithUrlStringV2(urlString: getUrlFromPlist(keyValue: "ImmunizationMutate"), dataToPost: jsonData, httpMethod: httpMethod,
                success: { [weak self] respObj in
                    guard let self = self else { return }
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
                    
                }, failure: { [weak self] error in
                    guard let self = self else { return }
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
                })
            }
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
    func fetchCommonDataForVaccine(patientId : String , practiceId : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "ImmunizationCommonData", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    
    //MARK: - Insurance
    
    func getInsuranceList(identificationKey : String ){
        
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){

            let urlString = getUrlFromPlist(keyValue: "Insurance", params: ["id": patientId])
            
            
           
            
            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
            success:{ [weak self] respObj in
                guard let self = self else { return }
                
                let insuranceList = ParsingHelper.formInsuranceList(respObj: respObj)
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: insuranceList, identificationKey: identificationKey)
                 
                
            }, failure: { [weak self] apiError in
            
                 guard let self = self else { return }
            
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

            })
            
        }
        
    }
    
    func addOrUpdateInsurance(insurance: PatientInsuranceDetails,identificationKey : String ){
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            
            insurance.practicePatientId = patientId
            
            var method: HTTP_METHOD = .HTTP_METHOD_POST
            
            if !insurance.patientInsuranceDetailsId.isNilOrBlank(){
                method = .HTTP_METHOD_PUT
            }
            
            let postBody = JsonBuilder.formAddInsuranceObj(insurance: insurance)
            let jsonData = (try? JSONSerialization.data(withJSONObject: postBody, options: []))!
            let urlString = getUrlFromPlist(keyValue: "Insurance", params: ["id": patientId])
            
            initiateWithUrlStringV2(urlString: urlString,dataToPost: jsonData , httpMethod: method,
            success:{ [weak self] respObj in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
                
            }, failure: { [weak self] apiError in
            
                 guard let self = self else { return }
            
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

            })
            
        }
    }
    
    func deleteInsurance(insurance: PatientInsuranceDetails,identificationKey : String ){
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            
            insurance.practicePatientId = patientId
            
            
            let postBody = JsonBuilder.formDeleteInsuranceObj(insurance: insurance)
            let jsonData = (try? JSONSerialization.data(withJSONObject: postBody, options: []))!
            let urlString = getUrlFromPlist(keyValue: "InsuranceMutate")
            
            initiateWithUrlStringV2(urlString: urlString,dataToPost: jsonData , httpMethod: .HTTP_METHOD_DELETE,
            success:{ [weak self] respObj in
                guard let self = self else { return }
                
                //let insuranceList = ParsingHelper.formInsuranceList(respObj: respObj)
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: true, identificationKey: identificationKey)
                 
                
            }, failure: { [weak self] apiError in
            
                 guard let self = self else { return }
            
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

            })
            
        }
    }
    
    //MARK: - Payments
    func createTransaction( patientId : String ,json : Dictionary<String,Any> , identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "PaymentTransaction", params: ["id": patientId]), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func updateTransaction( patientId : String , practiceId : String , gateway : String , transactionId : String , identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: ["practice_id":"\(practiceId)","gateway":"\(gateway)"], options: []))!
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "PaymentTransactionUpdate", params: ["id": patientId, "transactionId": transactionId]), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_PUT)
    }
    
    func checkTransactionStatus(paymentInfo: PaymentInfo ,identificationKey : String ) {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "PaymentTransactionStatus", params: ["id": paymentInfo.transactionInfo?.patientId ?? "", "transactionId": paymentInfo.transactionInfo?.transactionId ?? "", "practiceId": paymentInfo.transactionInfo?.practiceId ?? "", "gateway": paymentInfo.transactionInfo?.gateway ?? ""]), identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func postBluefinAPI(json : Dictionary<String,Any> ,bluefinURL: String ,identificationKey : String)  {
        
//        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
//
//        let form =  json.map { (key: String , value: Any) in
//            "\(key)=\(value)"
//        }.joined(separator: " \\ ")
//
//        debugPrintLog("dictionary \(json)")

        let _ = "Boundary-\(UUID().uuidString)"

        var data = Data()
        var body: [String] = []
    //    var error: NSError? = nil

 //       let boundaryStartStr = "--\(boundary)\r\n"
  //      let boundaryEndStr = "--\(boundary)--\r\n"
        
        for (key,value) in json
        {
            
            body.append("\(key)=\(value)")
//                body.appendString(string: boundaryStartStr)
//                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//                body.appendString(string: "\(value)\r\n")
            
        }
        
        data.appendString(string: body.joined(separator: "&"))

        debugPrintLog("bluefin Post -> \n \(body.joined(separator: "&"))")
        
        initiateBluefinCall(urlString: bluefinURL, dataToPost:  data, identificationKey: identificationKey)
     //   initiateWithUrlString(urlString: bluefinURL, dataToPost: body, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST , skipSuccessCheck: true , isFormData: true)
    }
    
//    func temp(){
//        let parameters = [
//          [
//            "key": "card_expiration",
//            "value": "1221",
//            "type": "text"
//          ],
//          [
//            "key": "first_name",
//            "value": "Demo",
//            "type": "text"
//          ],
//          [
//            "key": "success_url",
//            "value": "https://phr2.charmtracker.com/phr/careteam/bluefinsuccess/3211000024699407",
//            "type": "text"
//          ],
//          [
//            "key": "response_format",
//            "value": "JSON",
//            "type": "text"
//          ],
//          [
//            "key": "transaction_type",
//            "value": "SALE",
//            "type": "text"
//          ],
//          [
//            "key": "timestamp",
//            "value": "1640759998",
//            "type": "text"
//          ],
//          [
//            "key": "card_number",
//            "value": "4111111111111111",
//            "type": "text"
//          ],
//          [
//            "key": "transaction_amount",
//            "value": "13.00",
//            "type": "text"
//          ],
//          [
//            "key": "account_id",
//            "value": "220614964941",
//            "type": "text"
//          ],
//          [
//            "key": "custom_id",
//            "value": "3211000024699407",
//            "type": "text"
//          ],
//          [
//            "key": "tender_type",
//            "value": "CARD",
//            "type": "text"
//          ],
//          [
//            "key": "custom_data",
//            "value": "{\"invoices\":[{\"BILL_ID\":\"43118000005397001\",\"CLEAR_AMOUNT\":\"13.00\",\"BILL_NUMBER\":\"INV729\"}],\"custom_id\":\"3211000024699407\"}",
//            "type": "text"
//          ],
//          [
//            "key": "hash",
//            "value": "f7aab450063fcf7f908922f3e7ea925ae6038b101a05d80541a864dcc76d00af",
//            "type": "text"
//          ],
//          [
//            "key": "decline_url",
//            "value": "https://phr2.charmtracker.com/phr/careteam/bluefinerror/3211000024699407",
//            "type": "text"
//          ]] as [[String : Any]]
//
//        let boundary = "Boundary-\(UUID().uuidString)"
//        var body = ""
//        var error: Error? = nil
//        for param in parameters {
//          if param["disabled"] == nil {
//            let paramName = param["key"]!
//            body += "--\(boundary)\r\n"
//            body += "Content-Disposition:form-data; name=\"\(paramName)\""
//
//            let paramType = param["type"] as! String
//            if paramType == "text" {
//              let paramValue = param["value"] as! String
//              body += "\r\n\r\n\(paramValue)\r\n"
//            }
//          }
//        }
//        body += "--\(boundary)--\r\n";
//        let postData = body.data(using: .utf8)
//
//        var request = URLRequest(url: URL(string: "https://cert.payconex.net/api/qsapi/3.8.1/")!,timeoutInterval: Double.infinity)
//        request.addValue("Basic cm9oaW5pOmNoYXJtZG9j", forHTTPHeaderField: "Authorization")
//        request.addValue("BLUEFINA=rd4o00000000000000000000ffffac128122o443", forHTTPHeaderField: "Cookie")
//        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        request.httpMethod = "POST"
//        request.httpBody = postData
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//          guard let data = data else {
//            debugPrintLog(String(describing: error))
//            semaphore.signal()
//            return
//          }
//          debugPrintLog(String(data: data, encoding: .utf8)!)
//          semaphore.signal()
//        }
//
//        task.resume()
//    }
    
    
    func addCard(paymentInfo: PaymentInfo , identificationKey: String){
        
        getMerchantAccountList(practiceId: paymentInfo.transactionInfo?.practiceId ?? "", success: { [weak self] merchantAccountList in
            
                 guard let self = self else { return }
            
            let paymentInfoList =  ParsingHelper.formPaymentInfoList(primaryPaymentInfo: paymentInfo, merchantAccountList: merchantAccountList)
            
            self.getCardGroup(paymentInfo: paymentInfo, success: { [weak self] groupId in
                
                     guard let self = self else { return }
                
                let totalCount = paymentInfoList.count
                var respCount = 0
                var isSuccessAvailable = false
                
                paymentInfoList.forEach({tempPaymentInfo in
                    tempPaymentInfo.cardDetails?.cardGroupId = groupId
                    
                    self.makePayment(paymentInfo: tempPaymentInfo, success: { [weak self] success in
                        guard let self = self else { return }
                        respCount += 1
                        isSuccessAvailable = true
                        if respCount == totalCount {
                            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: true, identificationKey: identificationKey)
                        }
                        
                    }, failure: { [weak self] apiError in
                        guard let self = self else { return }
                        respCount += 1
                        if respCount == totalCount {
                            if isSuccessAvailable {
                                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: true, identificationKey: identificationKey)
                            }
                            else{
                                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                            }
                        }
                    })
                })
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
            
             
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    
    func updateCard(paymentGatewayToken: PaymentGatewayToken, identificationKey: String){
        let urlString = getUrlFromPlist(keyValue: "Card")
        let postObj = JsonBuilder.formEditCardObj(paymentGatewayToken: paymentGatewayToken)
        
        if let data = (try? JSONSerialization.data(withJSONObject: postObj, options: [])){
            initiateWithUrlStringV2(urlString: urlString,dataToPost: data, httpMethod: .HTTP_METHOD_PUT, success: { [weak self] respObj in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: true, identificationKey: identificationKey)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
        }
    }
    
    
    func deleteCard(paymentGatewayToken: PaymentGatewayToken, identificationKey: String){
        let urlString = getUrlFromPlist(keyValue: "Card")
        let postObj = JsonBuilder.formDeleteCardObj(paymentGatewayToken: paymentGatewayToken)
        
        if let data = (try? JSONSerialization.data(withJSONObject: postObj, options: [])){
            initiateWithUrlStringV2(urlString: urlString,dataToPost: data, httpMethod: .HTTP_METHOD_DELETE, success: { [weak self] respObj in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            })
        }
    }
    
//    private func addCard(paymentinfoList:[PaymentInfo],index: Int ,identificationKey: String){
//
//    }
    
    
    private func getMerchantAccountList(practiceId: String,success: @escaping ([MerchantAccountInfo]) -> Void, failure: @escaping (Error) -> Void){
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "MerchantAccount", params: ["id": patientId, "practiceId": practiceId])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard self != nil else { return }
            let merchantAccountList = ParsingHelper.getMerchantAccountList(respObj: respObj)
            success(merchantAccountList)
        }, failure: { [weak self] error in
            guard self != nil else { return }
            failure(error)
        })
    }
    
    private func getCardGroup(paymentInfo:PaymentInfo,success: @escaping (String) -> Void, failure: @escaping (Error) -> Void){
        
        let urlString = getUrlFromPlist(keyValue: "CardGroup")
        
        
        let postObj = JsonBuilder.formCardGroupObj(paymentInfo: paymentInfo)
        if let data = (try? JSONSerialization.data(withJSONObject: postObj, options: [])){
            initiateWithUrlStringV2(urlString: urlString,dataToPost: data, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
                guard self != nil else { return }
                let cardGroupId = ParsingHelper.getCardGroupId(respObj: respObj)
                paymentInfo.cardDetails?.cardGroupId = cardGroupId
                success(cardGroupId)
            }, failure: { [weak self] error in
                guard self != nil else { return }
                failure(error)
            })
        }
      
    }
    

    func makePayment(paymentInfo: PaymentInfo , identificationKey: String){
        makePayment(paymentInfo: paymentInfo, success: { [weak self] receiptId in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: receiptId, identificationKey: identificationKey)
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    
    private func makePayment(paymentInfo: PaymentInfo ,success: @escaping (String) -> Void, failure: @escaping (Error) -> Void){
        
        
//        if paymentInfo.token.isNilOrBlank() {
//            if paymentInfo.chargeProcessingType == appointmentCardProcessingTypeChargeOnly {
//                paymentInfo.transactionType = appointmentTransactionTypeSale
//            }
//            else{
//                paymentInfo.transactionType = appointmentTransactionTypeAuthorization
//            }
//        }
//        else{
//            paymentInfo.transactionType = appointmentTransactionTypeCapture
//        }
//
        if paymentInfo.chargeProcessingType == appointmentCardProcessingTypeChargeOnly {
            paymentInfo.transactionType = appointmentTransactionTypeSale
        }
        else{
            if paymentInfo.token.isNilOrBlank() {
                paymentInfo.transactionType = appointmentTransactionTypeAuthorization
            }
            else{
                paymentInfo.transactionType = appointmentTransactionTypeSale
            }
        }
        payTransaction(paymentInfo: paymentInfo, paymentResponse: { resp in
            if resp is Dictionary<String, Any> {
                debugPrintLog("Bluefin Response: \(resp)")
                if paymentInfo.chargeProcessingType == appointmentCardProcessingTypeStoreCharge && paymentInfo.transactionType == appointmentTransactionTypeAuthorization && paymentInfo.chargeAmount?.toDoubleOrNil() ?? 0.0 != 0.0 {
                    paymentInfo.transactionType = appointmentTransactionTypeSale
                    
                    self.payTransaction(paymentInfo: paymentInfo, paymentResponse: { resp2 in
                        if resp2 is Dictionary<String, Any> {
                            //checkTransaction
                            self.checkTransactionStatus(paymentInfo: paymentInfo, success: { [weak self] receiptId in
                                guard self != nil else { return }
                                success(receiptId)
                            }, failure: { [weak self] error in
                                guard self != nil else { return }
                                failure(error)
                            })
                        }
                        else{
                            if let error = resp2 as? Error {
                                failure(error)
                            }
                        }
                    })
                }
                else{
                    
                    if paymentInfo.chargeProcessingType == appointmentCardProcessingTypeStoreCharge && paymentInfo.transactionType == appointmentTransactionTypeAuthorization && paymentInfo.chargeAmount?.toDoubleOrNil() ?? 0.0 == 0.0 {
                        paymentInfo.chargeProcessingType = appointmentCardProcessingTypeStoreOnly
                    }
                    
                    
                    self.checkTransactionStatus(paymentInfo: paymentInfo, success: { [weak self] receiptId in
                        guard self != nil else { return }
                        success(receiptId)
                    }, failure: { [weak self] error in
                        guard self != nil else { return }
                        failure(error)
                    })
                    //checkTransaction
                }
            }
            else if let error = resp as? Error {
                failure(error)
            }
        })
    }
    
    private func postBluefinAPI(json : Dictionary<String,Any> ,bluefinURL: String ,success: @escaping (Dictionary<String,Any>) -> Void, failure: @escaping (Error) -> Void)  {



        let _ = "Boundary-\(UUID().uuidString)"
        var data = Data()
        var body: [String] = []
        
        for (key,value) in json
        {
            body.append("\(key)=\(value)")
        }
        
        data.appendString(string: body.joined(separator: "&"))
        debugPrintLog("bluefin Post -> \n \(body.joined(separator: "&"))")
        
        initiateBluefinCall(urlString: bluefinURL, dataToPost: data, success: success, failure: failure)
    }
    
    private func payTransaction(paymentInfo: PaymentInfo , paymentResponse:@escaping (Any) -> Void) {
        createTransaction(paymentInfo: paymentInfo, paymentResponse: { resp in
                
            if let transactionResp =  resp as? Dictionary<String,Any> {
                if let postObj = JsonBuilder.formPaymentPostObj(paymentInfo: paymentInfo, responseTransactionObj: transactionResp){
                    let bluefinURL = ParsingHelper.getBluefinURLFromTransaction(respObj: transactionResp)
                        
                    debugPrintLog("BluefinPost ->\n \(postObj)")
                    debugPrintLog("BluefinURL ->\n \(bluefinURL)")
                        
                    self.postBluefinAPI(json: postObj, bluefinURL: bluefinURL, success: { [weak self] resp in
                        guard self != nil else { return }
                        paymentResponse(resp)
                    }, failure: { [weak self] error in
                        guard self != nil else { return }
                        paymentResponse(error)
                    })
                }
                else{
                    paymentResponse(CharmUtil.getCustomError(domainKey: "com.charmphr.error.transactionFailed.title"))
                }
            }
            else if let error =  resp as? Error{
                debugPrintLog("transactionRespError -> \(error)")
                paymentResponse(error)
            }
        })
    }
    
    private func createTransaction(paymentInfo: PaymentInfo, paymentResponse:@escaping (Any) -> Void){
        let patientId = getSelectedPatientId()
        
        paymentInfo.transactionInfo?.patientId = getSelectedPatientId()
        let postObj = JsonBuilder.formTransactionObj(paymentInfo: paymentInfo)
        let urlString = getUrlFromPlist(keyValue: "PaymentTransaction", params: ["id": patientId])
        
        debugPrintLog(postObj)
        
        if let data = (try? JSONSerialization.data(withJSONObject: postObj, options: [])){
            initiateWithUrlStringV2(urlString: urlString,dataToPost:data , httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
                guard self != nil else { return }
                _ = ParsingHelper.onCreateTransactionSuccess(respObj: respObj, paymentInfo: paymentInfo)
                paymentResponse(respObj)
            }, failure: { [weak self] error in
                guard self != nil else { return }
                paymentResponse(error)
            })
        }
    }
    
    private func checkTransactionStatus(paymentInfo: PaymentInfo,count:Int = 1,success: @escaping (String) -> Void, failure: @escaping (Error) -> Void){
        let urlString = getUrlFromPlist(keyValue: "PaymentTransactionStatus", params: ["id": paymentInfo.transactionInfo?.patientId ?? "", "transactionId": paymentInfo.transactionInfo?.transactionId ?? "", "practiceId": paymentInfo.transactionInfo?.practiceId ?? "", "gateway": paymentInfo.transactionInfo?.gateway ?? ""])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
        
             guard let self = self else { return }
        
            if paymentInfo.chargeProcessingType == appointmentCardProcessingTypeStoreOnly{
                let isSuccess = ParsingHelper.isTransactionSuccessForBluefin(respObj: respObj)
                if isSuccess {
                    success("")
                }
                else{
                    
                    if count > 6 {
                        let nsError = NSError(domain: "Error Occured", code: errorPaymentSuccessButReceiptFailedCode)
                        failure(nsError)
                    }
                    else{
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                            self.checkTransactionStatus(paymentInfo: paymentInfo,count: count+1 , success: success, failure: failure)
                        })
                    }
                }
            }
            else{
                let isEHRReceipt = paymentInfo.transactionInfo?.service == paymentServiceAppointment
                let resp = ParsingHelper.getReceiptIdForBluefin(respObj: respObj, isEHRReceipt: isEHRReceipt)
                
                if let string = resp as? String {
                    success(string)
                }
                else if let error = resp as? NSError{
                    if count > 6 {
                        failure(error)
                    }
                    else{
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                            self.checkTransactionStatus(paymentInfo: paymentInfo,count: count+1 , success: success, failure: failure)
                        })
                    }
                    
                }
            }
        }, failure: { [weak self] error in
            guard let self = self else { return }
            if count > 6 {
                let nsError = NSError(domain: "Error Occured", code: errorPaymentSuccessButReceiptFailedCode)
                failure(nsError)
            }
            else{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.checkTransactionStatus(paymentInfo: paymentInfo,count: count+1 , success: success, failure: failure)
                })
            }
        })
    }
    
    
    
    //MARK: - Card On File
    
    func getCardList(identificationKey: String , selectedPractice: String? = nil, merchantId: String? = nil){
        
        let patientId = getSelectedPatientId()
        let practiceList = selectedPractice.isNilOrBlank() ?  getBluefinEnabledPracticeId() : [selectedPractice ?? ""] //Ternary Operator
        let practiceSize = practiceList.count
        var respCount = 0
        var isCallBackSent = false
        var cardList: [CardMetaObj] = []
        practiceList.forEach({practiceId in
            var urlString = getUrlFromPlist(keyValue: "Cards", params: ["id": patientId, "practiceId": practiceId])
            
            if let merchantId = merchantId {
                urlString = urlString+"&merchant_id=\(merchantId)"
            }
            
            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                guard let self = self else { return }
                respCount += 1
             //   cardList.append(contentsOf: ParsingHelper.getCardList(respObj: resp, practiceId: practiceId))
    
                cardList.append(ParsingHelper.getCardList(respObj: resp, practiceId: practiceId))
                if respCount == practiceSize && !isCallBackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: cardList, identificationKey: identificationKey)
                    isCallBackSent = true
                }
            }, failure: { [weak self] error in
                guard let self = self else { return }
                respCount += 1
                if !isCallBackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
                }
                
            })
        })
    }
    
    
    //MARK: - Health Passport
    func downloadHealthPassportPdf(patientId : String,identificationKey : String)
    {
        initiateRequestWithIndexpath(indexPath: nil, urlString: getHealthPassportUrlFromPlist(keyValue: "HealthPassportPdf", params: ["id": patientId]), identificationKey: identificationKey)
    }
    
    //MARK: - Documents
    func fetchDocumentsCategory(patientId : String, practiceId : String ,isHealthPassport : Bool = false ,identificationKey : String)
    {
        if isHealthPassport
        {
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "DocumentCategory", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else{
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "DocumentCategory", params: ["id": patientId, "practiceId": practiceId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func addDocumentFolder(json : Dictionary<String,Any>, identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "DocumentCategoryMutate"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func shareDocumentRestriction(identificationKey: String){
        let practiceList = getEnabledPractices(moduleId: documentModelId)
        let practiceSize = practiceList.count
        var respCount = 0
        var isCallBackSent = false
        var sharePracticeList: [ShareDocRestriction] = []
        practiceList.forEach({practiceId in
            let urlString = getUrlFromPlist(keyValue: "DocumentRestriction", params: ["id": getSelectedPatientId(), "practiceId": practiceId])
            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                guard let self = self else { return }
                respCount += 1
                sharePracticeList.append(ParsingHelper.getShareDocRestriction(resp: resp, practiceId: practiceId))
                if respCount == practiceSize && !isCallBackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: sharePracticeList, identificationKey: identificationKey)
                    isCallBackSent = true
                }
            }, failure: { [weak self] error in
                guard let self = self else { return }
                respCount += 1
                if !isCallBackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
                }
                
            })
        })
    }

    func fetchDocuments(pageNo:Int,categoryId : String? = nil,isHealthPassport : Bool = false ,identificationKey : String)
    {
        let patientId = getSelectedPatientId()
        let fromRange: Int =  ((pageNo - 1)  *  listPerPageCount) + 1
        
        if isHealthPassport
        {
            if isNilOrEmpty(string: categoryId)
            {
                initiateWithUrlStringV2(urlString: getHealthPassportUrlFromPlist(keyValue: "Documents", params: ["id": patientId, "fromRange": fromRange, "listPerPageCount": listPerPageCount]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                    guard let self = self else { return }
                    let documentList = ParsingHelper.getArrayOfDocuments(dict: resp)
                    v2Delegate?.charmConnectionV2HandlerDidRecieve(response: documentList, identificationKey: identificationKey)
                }, failure: { [weak self] apiError in
                    guard let self = self else { return }
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                })
            }else
            {
                initiateWithUrlStringV2(urlString: getHealthPassportUrlFromPlist(keyValue: "DocumentsByCategory", params: ["id": patientId, "categoryId": categoryId ?? "", "fromRange": fromRange, "listPerPageCount": listPerPageCount]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                    guard let self = self else { return }
                    let documentList = ParsingHelper.getArrayOfDocuments(dict: resp)
                    v2Delegate?.charmConnectionV2HandlerDidRecieve(response: documentList, identificationKey: identificationKey)
                }, failure: { [weak self] apiError in
                    guard let self = self else { return }
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                })
            }
        }else
        {
            if isNilOrEmpty(string: categoryId)
            {
                initiateWithUrlStringV2(urlString: getUrlFromPlist(keyValue: "Documents", params: ["id": patientId, "fromRange": fromRange, "listPerPageCount": listPerPageCount]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                    guard let self = self else { return }
                    let documentList = ParsingHelper.getArrayOfDocuments(dict: resp)
                    v2Delegate?.charmConnectionV2HandlerDidRecieve(response: documentList, identificationKey: identificationKey)
                }, failure: { [weak self] apiError in
                    guard let self = self else { return }
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                })
                
            }else
            {
                initiateWithUrlStringV2(urlString: getUrlFromPlist(keyValue: "DocumentsByCategory", params: ["id": patientId, "categoryId": categoryId ?? "", "fromRange": fromRange, "listPerPageCount": listPerPageCount]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                    guard let self = self else { return }
                    let documentList = ParsingHelper.getArrayOfDocuments(dict: resp)
                    v2Delegate?.charmConnectionV2HandlerDidRecieve(response: documentList, identificationKey: identificationKey)
                }, failure: { [weak self] apiError in
                    guard let self = self else { return }
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                })
            }
        }
    }
    
    func fetchDocumentByFilter(pageNo:Int,filter : String,isHealthPassport : Bool = false ,identificationKey : String)
    {
        let patientId = getSelectedPatientId()
        let fromRange: Int =  ((pageNo - 1)  *  listPerPageCount) + 1

        if isHealthPassport
        {
            initiateWithUrlStringV2(urlString: getHealthPassportUrlFromPlist(keyValue: "DocumentsFiltered", params: ["id": patientId, "filter": filter, "fromRange": fromRange, "listPerPageCount": listPerPageCount]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                guard let self = self else { return }
                let documentList = ParsingHelper.getArrayOfDocuments(dict: resp)
                v2Delegate?.charmConnectionV2HandlerDidRecieve(response: documentList, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }else
        {
            initiateWithUrlStringV2(urlString: getUrlFromPlist(keyValue: "DocumentsFiltered", params: ["id": patientId, "filter": filter, "fromRange": fromRange, "listPerPageCount": listPerPageCount]), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                guard let self = self else { return }
                let documentList = ParsingHelper.getArrayOfDocuments(dict: resp)
                v2Delegate?.charmConnectionV2HandlerDidRecieve(response: documentList, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    func downloadDocument(patientId : String, documentId : String,isHealthPassport : Bool = false ,identificationKey : String)
    {
        if isHealthPassport
        {
            initiateRequestWithIndexpath(indexPath: nil, urlString: getHealthPassportUrlFromPlist(keyValue: "DocumentFile", params: ["id": patientId, "documentId": documentId]), identificationKey: identificationKey)
        }else
        {
            initiateRequestWithIndexpath(indexPath: nil, urlString: getUrlFromPlist(keyValue: "DocumentFile", params: ["id": patientId, "documentId": documentId]), identificationKey: identificationKey)
        }
    }
    
    func deleteDocument(patientId : String, documentId : String ,isHealthPassport : Bool = false,identificationKey : String)
    {
        if isHealthPassport
        {
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "DocumentDelete", params: ["id": patientId, "documentId": documentId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "DocumentDelete", params: ["id": patientId, "documentId": documentId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
        }
    }
    
    func fetchCommonDataForDocument(patientId : String, isHealthPassport : Bool = false ,identificationKey : String)
    {
        if isHealthPassport
        {
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "DocumentCategoryList", params: ["id": patientId]), identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }else
        {
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "DocumentCategoryList", params: ["id": patientId]), identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func uploadDocument( patientId : String , param : Dictionary<String,Any>,isHealthPassport : Bool = false,identificationKey : String )
    {
        if isHealthPassport
        {
            initiateRequestWithData(param: param, urlString: getHealthPassportUrlFromPlist(keyValue: "DocumentUpload", params: ["id": patientId]), fileKeyPath: "document", identificationKey: identificationKey)
        }else
        {
            initiateRequestWithData(param: param, urlString: getUrlFromPlist(keyValue: "DocumentUpload", params: ["id": patientId]), fileKeyPath: "document", identificationKey: identificationKey)
        }
    }
    
//MARK: - Share Documents
   
    func shareDocumentToOthers(identificationKey: String, documentList: [Document], contactList: [Pharmacy], expiryDate: Date){
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "ShareDocuments", params: ["id": patientId])
        let param = JsonBuilder.formShareDocumentToOthersObj(documentList: documentList, contactList: contactList, expiryDate: expiryDate)
        let jsonData = (try? JSONSerialization.data(withJSONObject: param, options: []))!
        
        initiateWithUrlString(urlString: urlString, dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func shareDocumentToMembers(identificationKey: String, documentList: [Document], memberList: [Provider]){
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "ShareRecords", params: ["id": patientId])
        let param = JsonBuilder.formShareDocumentToMembersObj(documentList: documentList, memberList: memberList)
        let jsonData = (try? JSONSerialization.data(withJSONObject: param, options: []))!
        
        initiateWithUrlString(urlString: urlString, dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func addMultipleContacts(identificationKey: String, pharmacyList: [Pharmacy]){
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "MultipleContacts", params: ["id": patientId])
        let param = JsonBuilder.formContactObjList(pharmacyList: pharmacyList)
        let jsonData = (try? JSONSerialization.data(withJSONObject: param, options: []))!
        
        initiateWithUrlString(urlString: urlString,dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func fetchPharmacyListObj(identificationKey: String, searchText: String){
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "PharmacyDetails", params: ["id": patientId, "searchText": searchText])
        initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchPatientMembers(identificationKey: String){
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "FamilyMembers", params: ["id": patientId])
        initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    //MARK: - Treating Physicians
    func fetchTreatingPhysicians(patientId : String, identificationKey : String)
    {
        initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "TreatingPhysicians", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func deleteTreatingPhysician(treatingPhysicianID : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "DeleteTreatingPhysician", params: ["id": getSelectedPatientId(), "treatingPhysicianID": treatingPhysicianID]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
    }
    
    func addTreatingPhysicians(json : Dictionary<String,Any> , identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "AddContact"),dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    //MARK:- Medical Condition
    
    func  fetchMedicalCondition(identificationKey : String , status: String){
        let patientId = getSelectedPatientId()
        if patientId.isNotBlank(){
            let practiceList = getEnabledPractices(moduleId: problemListModelId)
            let practiceSize = practiceList.count
            
            var conditionList: [MedicalCondition] = []
            var respCount = 0
            
            var isCallbackSent = false
            
            practiceList.forEach({practiceId in
                let urlString = getUrlFromPlist(keyValue: "Conditions", params: ["id": patientId, "practiceId": practiceId, "status": status])
                initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
                success:{ [weak self] respObj in
                    guard let self = self else { return }
                    respCount+=1
                    let conditionTempList = ParsingHelper.formMedicalConditionList(dict: respObj, practiceId: practiceId)
                    conditionList.append(contentsOf: conditionTempList)
                    if respCount == practiceSize && !isCallbackSent{

                        conditionList = FilterHandler.filterAndSortConditions(conditionList: conditionList)
                        self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: conditionList, identificationKey: identificationKey)
                        isCallbackSent = true
                    }

                }, failure: { [weak self] apiError in
                    guard let self = self else { return }

                    respCount+=1
                    if !isCallbackSent{
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        isCallbackSent = true
                    }
                })
            })
        }
    }

    
    
    func fetchMedicalCondition(patientId : String, identificationKey : String)
    {
        
        initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "ActiveConditions", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func deleteMedicalCondition(condition: MedicalCondition , identificationKey : String)
    {
        
        let urlString = getUrlFromPlist(keyValue: "ConditionMutate")
        if let jsonData = (try? JSONSerialization.data(withJSONObject: ["cond_map_id":"\(condition.medicalConditionMapId ?? "")","patient_id":"\(getSelectedPatientId())"], options: [])) {
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_DELETE, success: {[weak self] respObj in
                let message = respObj.getString("message") ?? ""
                self?.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: message, identificationKey: identificationKey)
            }, failure: {[weak self] apiError in
                self?.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    
    func fetchCommonDataForMedicalCondition(identificationKey : String)
    {
        let urlString = getUrlFromPlist(keyValue: "ConditionCommonData", params: ["id": getSelectedPatientId()])
        
        initiateWithUrlStringV2(urlString: urlString,
                                httpMethod: .HTTP_METHOD_GET,
                                success: {[weak self] respObj in
            
            let commonData = ParsingHelper.formConditionCommonData(respObj: respObj)
            self?.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: commonData, identificationKey: identificationKey)
        },failure: {[weak self] apiError in
            self?.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })        
    }
    
    func addMedicalCondition(condition: MedicalCondition , identificationKey : String ,isEdit: Bool = false)
    {
        
        let urlString = getUrlFromPlist(keyValue: "ConditionMutateV2")
        let json = JsonBuilder.formMedicalCondtionObj(medicalCondition: condition)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])) {
            var httpMethod: HTTP_METHOD = .HTTP_METHOD_POST
            if isEdit {
                httpMethod = .HTTP_METHOD_PUT
            }
            
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: httpMethod, success: {[weak self] respObj in
                
                let msg = respObj.getString("message") ?? ""
                self?.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: msg, identificationKey: identificationKey)
                
            }, failure: {[weak self] apiError in
                self?.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    //MARK:- Questionnaire
    func fetchQuestionnaire(patientId : String, identificationKey : String)
    {
        initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "Questionnaire", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    
    func getQuestionnaireList(type: String, appointmentId: String? = nil, identificationKey: String, isAscOrder: Bool = true)
    {
        
        let patientId = getSelectedPatientId()
        
        if patientId.isNotBlank(){
            let urlString = getUrlFromPlist(keyValue: "FormsList", params: ["id": patientId, "type": type])
            
            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
                guard let self = self else { return }
                let questionnaireList = ParsingHelper.formQuestionnaireList(respObj: respObj, practiceId: nil, appointmentId: appointmentId, isAscOrder: isAscOrder)
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: questionnaireList, identificationKey: identificationKey)
                
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError , identificationKey: identificationKey)
            })
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.patientid.error")
            v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
    func populateQuestionnaire(patientId : String, identificationKey : String)
    {
        initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "PopulateQuestionnaire", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func fetchQuestionnaireAnswers(patientId : String, physicianTemplate: PhysicianTemplates ,identificationKey : String)
    {
        
        if physicianTemplate.isHealthPassport{
            initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "QuestionnairePersonalAnswer", params: ["id": patientId, "patientQuesMapId": physicianTemplate.patientQuesMap?.patientQuesMapId ?? ""]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
        else{
            let urlString = getUrlFromPlist(keyValue: "FormsAnswer", params: ["id": patientId, "patientQuesMapId": physicianTemplate.patientQuesMap?.patientQuesMapId ?? "", "practiceId": physicianTemplate.practiceId ?? ""])
            
            initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
        }
    }
    
    func updateQuestionnaireAnswers(physicianTemplate: PhysicianTemplates , questionnaireDetailPOJO: QuestionnaireDetailPOJO ,identificationKey : String )  {
        
        debugPrintLog("uploadQuestionnaireAnswerStart")
        
        physicianTemplate.patientQuesMap?.practicePatientId = Patient.selectedPatientInstance?.patientId
       
        if let builderObj = JsonBuilder.formQuestionnaireDetailAnsObj(physicianTemplates: physicianTemplate, questionnaireDetailPOJO: questionnaireDetailPOJO) {
            let jsonData = (try? JSONSerialization.data(withJSONObject: builderObj, options: []))!
            
            debugPrintLog(jsonData)
            
            initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "FormsAnswersSubmit"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
        }
        else{
            delegate?.charmConnectionHandlerDidRecieveJsonObject(jsonObject: [:], identificationKey: identificationKey)
        }
    }
    
    func updateQuestionnaireWidgets(physicianTemplate: PhysicianTemplates , questionnaireDetailPOJO: QuestionnaireDetailPOJO ,identificationKey : String )  {
        
        debugPrintLog("uploadQuestionnaireWidgetsStart")

        physicianTemplate.patientQuesMap?.practicePatientId = Patient.selectedPatientInstance?.patientId
        let jsonData = (try? JSONSerialization.data(withJSONObject: JsonBuilder.formQuestionnaireWidgetDetailObj(physicianTemplates: physicianTemplate, questionnaireDetailPOJO: questionnaireDetailPOJO), options: []))!
        
        debugPrintLog(jsonData)
        
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "FormsSecondaryAnswersSubmit"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func uploadQuestionnaireAnswers(json : Dictionary<String,Any> ,identificationKey : String)
    {
        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: []))!
        initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "QuestionnairePersonalAnswersSubmit"), dataToPost: jsonData, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
    func getPrimaryInsuranceForQuestionnaire(physicianTemplates: PhysicianTemplates , identificationKey: String) {
        let patientId = Patient.selectedPatientInstance?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "PrimaryInsurance", params: ["id": patientId, "practiceId": physicianTemplates.practiceId ?? ""])
        
        initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func getPayerList(searchStr: String , practiceId: String , identificationKey: String ){
        let patientId = Patient.selectedPatientInstance?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "PayerName", params: ["id": patientId, "practiceId": practiceId, "searchStr": searchStr])
        
        initiateWithUrlString(urlString: urlString.urlEncode(), identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func uploadInsuranceCard(insuranceCard: InsuranceCard , identificationKey: String)  {
        let urlString = getUrlFromPlist(keyValue: "InsuranceUpload", params: ["id": insuranceCard.patientId ?? ""])
        let postObj = JsonBuilder.formInsuranceCardObj(insuranceCard: insuranceCard)
        
        initiateRequestWithData(param: postObj, urlString: urlString, fileKeyPath: "document", success: { [weak self] _ in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: true, identificationKey: identificationKey)
            
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    func deleteInsuranceCard(insuranceCard: InsuranceCard , identificationKey: String) {

        let urlString = getUrlFromPlist(keyValue: "InsuranceCardDelete", params: ["id": insuranceCard.patientId ?? "", "practiceId": insuranceCard.practiceId ?? "", "type": insuranceCard.type ?? ""])

        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_DELETE, success: { [weak self] _ in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: insuranceCard.type ?? "", identificationKey: identificationKey)
            
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    
    func getInsuranceCard(insuranceCard: InsuranceCard , identificationKey: String) {

        let urlString = getUrlFromPlist(keyValue: "InsuranceCardDownload", params: ["id": insuranceCard.patientId ?? "", "practiceId": insuranceCard.practiceId ?? "", "type": insuranceCard.type ?? ""])

        initiateRequestWithIndexpath(indexPath: nil, urlString: urlString, identificationKey: identificationKey, callV2: true)
    }
    
    
    func getPrimaryContactDetForQuestionnaire(physicianTemplates: PhysicianTemplates , identificationKey: String) {
        let patientId = Patient.selectedPatientInstance?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "PrimaryContact", params: ["id": patientId, "practiceId": physicianTemplates.practiceId ?? ""])
        
        initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func getPrimaryDetForQuestionnaire(physicianTemplates: PhysicianTemplates , identificationKey: String) {
        let patientId = Patient.selectedPatientInstance?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "PersonalDetail", params: ["id": patientId, "practiceId": physicianTemplates.practiceId ?? ""])
        
        initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    
    func getInsuranceCommonData(practiceId: String , identificationKey: String) {
        
        let patientId = Patient.selectedPatientInstance?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "InsuranceCommonData", params: ["practiceId": practiceId, "id": patientId])
        
        initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func getSignatureImage(physicianTemplates: PhysicianTemplates , entryPOJO: QuestionnaireEntryPOJO , tag: Int , identificationKey: String)  {
        
        let patientId = Patient.selectedPatientInstance?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "FormsSignature", params: ["id": patientId, "patientQuesMapId": physicianTemplates.patientQuesMap?.patientQuesMapId ?? "", "entryId": entryPOJO.questionnaireEntry.entryId, "practiceId": physicianTemplates.practiceId ?? ""])

        initiateRequestWithTag(tag: tag, urlString: urlString, identificationKey: identificationKey)
    }
    
    func uploadSignatureImage(image: UIImage ,physicianTemplates: PhysicianTemplates , entryPOJO: QuestionnaireEntryPOJO, tag: Int , identificationKey: String ) {
        let patientId = Patient.selectedPatientInstance?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "FormsSignature", params: ["id": patientId, "patientQuesMapId": physicianTemplates.patientQuesMap?.patientQuesMapId ?? "", "entryId": entryPOJO.questionnaireEntry.entryId, "practiceId": physicianTemplates.practiceId ?? ""])

        initiateRequestUploadRequestWith(image: image, urlString: urlString, identificationKey: identificationKey , tag: tag)
    }
    
    //MARK:- Demographics
    func fetchDemographicRealtedStatic(identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "StaticContent"), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchLanguages(identificationKey : String) {
        
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "Languages"), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)

    }
    
    func fetchStates(countryCode : String , identificationKey : String)
    {
        initiateWithUrlString(urlString: getUrlFromPlist(keyValue: "Country", params: ["countryCode": countryCode]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchDemographics(patientId tempId : String? = nil, identificationKey : String)
    {
        let patientId = tempId ?? getSelectedPatientId()
        
        let urlString = getUrlFromPlist(keyValue: "Demographics", params: ["id": patientId])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            
                 guard let self = self else { return }
            
            let patient = ParsingHelper.getDemographics(dict: respObj)
            
        
            if patientId == getSelectedPatientId() {
                getSelectedPatient().fill(using: patient)
            }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patient, identificationKey: identificationKey)
            
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
        
        initiateWithUrlString(urlString: urlString, dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func fetchPatientHealthPassportUrl(patientId : String, identificationKey : String)
    {
        initiateWithUrlString(urlString: getHealthPassportUrlFromPlist(keyValue: "HealthPassportUrl", params: ["id": patientId]), dataToPost: nil, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func saveDemographics(patient:Patient, identificationKey : String)
    {
        
        let postObj = JsonBuilder.formSavePatientObj(demographics: patient)
        
        if let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: [])) {
            let urlString = getUrlFromPlist(keyValue: "Demographics", params: ["id": patient.patientId ?? ""])
            
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
                
                     guard let self = self else { return }
                
                let coreDataUtil = mPHRCoreDataUtil.sharedInstance
                Patient.selectedPatientInstance?.fill(using: patient)
                if let patientObj = Patient.selectedPatientInstance{
                    coreDataUtil.updatePatientMObj(patient: patientObj)
                }
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patient, identificationKey: identificationKey)
                
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    func uploadPatientImage(param : Dictionary<String,Any> , patientId : String, identificationKey : String )
    {
        initiateRequestWithData(param: param, urlString: getUrlFromPlist(keyValue: "ProfilePhotoUpload", params: ["id": patientId]), fileKeyPath: "photo", identificationKey: identificationKey)
    }
    
    // MARK: - Flowsheet

    func getFlowsheetList( identificationKey : String){
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "Flowsheets", params: ["id": patientId])
        initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    }
    
    func getFlowsheetEntryList(flowsheets: Flowsheets, identificationKey : String) {
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "FlowsheetEntries", params: ["id": patientId, "practiceId": flowsheets.practiceId ?? "", "flowSheetId": flowsheets.flowSheetId ?? ""])
        initiateWithUrlString(urlString: urlString, identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_GET)
    
    }
    
    func addFlowsheetEntry( phrFlowsheet: PHRFlowsheets, identificationKey : String) {
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "FlowsheetsByPractice", params: ["id": patientId, "practiceId": phrFlowsheet.practiceId ?? ""])
        
        let param = JsonBuilder.formFlowsheetEntryObj(phrFlowsheets: phrFlowsheet)
        let jsonData = (try? JSONSerialization.data(withJSONObject: param, options: []))!

        initiateWithUrlString(urlString: urlString,dataToPost: jsonData , identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    
    }
    
    func editFlowsheetEntry(phrFlowsheet: PHRFlowsheets, identificationKey : String) {
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "FlowsheetDetail", params: ["id": patientId, "practiceId": phrFlowsheet.practiceId ?? "", "phrFlowsheetId": phrFlowsheet.phrFlowsheetId ?? ""])
        
        let param = JsonBuilder.formFlowsheetEntryObj(phrFlowsheets: phrFlowsheet)
        let jsonData = (try? JSONSerialization.data(withJSONObject: param, options: []))!

        initiateWithUrlString(urlString: urlString,dataToPost: jsonData , identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_PUT)
    }
    
    func deleteFlowsheetEntry(phrFlowsheet: PHRFlowsheets, identificationKey : String) {
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "FlowsheetEntry", params: ["id": patientId, "practiceId": phrFlowsheet.practiceId ?? "", "flowSheetId": phrFlowsheet.flowSheetId ?? "", "phrFlowsheetId": phrFlowsheet.phrFlowsheetId ?? ""])

        initiateWithUrlString(urlString: urlString , identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_DELETE)
    }
    
//MARK: - Add Support
    
    func getAttachmentFileIds(param : Dictionary<String,Any>, identificationKey: String){
        let urlString = getUrlFromPlist(keyValue: "SecureSharing")
        
        initiateRequestWithData(param: param, urlString: urlString, fileKeyPath: "file", identificationKey: identificationKey)
    }
    
    func addAttachmentFile(paramList : [Dictionary<String,Any>], identificationKey: String) {
        
        let totalCount = paramList.count
        var fileIdList:[String] = []
        var isRespSent = false
        let urlString = getUrlFromPlist(keyValue: "SecureSharing")

        paramList.forEach({param in
            
            initiateRequestWithData(param: param, urlString: urlString, fileKeyPath: "file" , success: { [weak self] respObj in
                
                     guard let self = self else { return }
                
                fileIdList.append(ParsingHelper.formSupportAttachmentId(respObj: respObj) ?? "")
                
                if !isRespSent && fileIdList.count == totalCount {
                    isRespSent = true
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: fileIdList, identificationKey: identificationKey)
                }
                
            } , failure: { [weak self] apiError in
                
                     guard let self = self else { return }
                
                if !isRespSent {
                    isRespSent = true
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                }
            })
        })
        
        
    }
    
    
    func addSupportDetails(supportDetails: SupportDetails, identificationKey: String){
        let urlString = getUrlFromPlist(keyValue: "Support")
        let param = JsonBuilder.formSupportObj(supportDetails: supportDetails)
        let jsonData = (try? JSONSerialization.data(withJSONObject: param, options: []))!
//        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        initiateWithUrlString(urlString: urlString,dataToPost: jsonData , identificationKey: identificationKey, httpMedthod: .HTTP_METHOD_POST)
    }
    
//MARK: - Reminder
    
    func fetchReminderList(identificationKey: String, type: String = "", moduleId: String = "", patientId: String){
        fetchReminderList(type: type, moduleId: moduleId, patientId: patientId, success: { [weak self] reminderList in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: reminderList, identificationKey: identificationKey)
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    private func fetchReminderList(type: String, moduleId: String, patientId: String ,success: @escaping ([Reminder]) -> Void, failure: @escaping (Error) -> Void){
        
        let urlString = getUrlFromPlist(keyValue: "Reminders", params: ["id": patientId])
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET, success: { [weak self] respObj in
            guard self != nil else { return }
            let reminderList = ParsingHelper.formReminderList(respObj: respObj, patientId: patientId)
            success(reminderList)
        }, failure: { [weak self] apiError in
            guard self != nil else { return }
            failure(apiError)
        })
    }
    
    func fetchReminderWithMeta(identificationKey:String, type: String = "", moduleId: String = "", patientId: String){
        
        let patientReminderPOJO = PatientReminderPOJO()
        
        var isCallbackSent = false
        var respCount = 0
        
        let totalCount = 3
        
        fetchReminderList(type: type, moduleId: moduleId, patientId: patientId, success: { [weak self] arrayOfreminder in
            guard let self = self else { return }
            patientReminderPOJO.reminderArray.append(contentsOf: arrayOfreminder)
            respCount += 1
            if respCount == totalCount && !isCallbackSent{
                
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patientReminderPOJO, identificationKey: identificationKey)
                isCallbackSent = true
            }
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            if !isCallbackSent{
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                isCallbackSent = true
            }
        })
        fetchMedicationList(patientId: patientId, success: { [weak self] arrayOfPatientMedication in
            guard let self = self else { return }
            patientReminderPOJO.arrayOfMedication.append(contentsOf: arrayOfPatientMedication)
            respCount += 1
            if respCount == totalCount && !isCallbackSent{
                
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patientReminderPOJO, identificationKey: identificationKey)
                isCallbackSent = true
            }
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            if !isCallbackSent{
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                isCallbackSent = true
            }
        })
        fetchSupplementList(patientId: patientId, success: { [weak self] arrayOfPatientSupplement in
            guard let self = self else { return }
            patientReminderPOJO.arrayOfSupplement.append(contentsOf: arrayOfPatientSupplement)
            respCount += 1
            if respCount == totalCount && !isCallbackSent{
                
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: patientReminderPOJO, identificationKey: identificationKey)
                isCallbackSent = true
            }
        }, failure: { [weak self] apiError in
            
                 guard let self = self else { return }
            
            if !isCallbackSent{
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                isCallbackSent = true
            }
        })
    }
    
    func addReminder(reminderObj: Reminder, identificationKey: String){
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "AddReminder", params: ["id": patientId])
        let json = JsonBuilder.formReminderJson(reminderObj: reminderObj)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])){
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] resp in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: resp, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    func editReminder(reminderObj: Reminder, identificationKey: String){
        
        let patientId = getSelectedPatientId()
        
        let urlString = getUrlFromPlist(keyValue: "ReminderDetail", params: ["id": patientId, "reminderId": reminderObj.reminderId ?? ""])
        let json = JsonBuilder.formReminderJson(reminderObj: reminderObj)
        if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])){
            initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_PUT, success: { [weak self] resp in
                guard let self = self else { return }
                let message = ParsingHelper.getMessageFromDict(resp)
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: message, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    func deleteReminder(reminderObj: Reminder?, identificationKey: String){
        
        if let reminderObj = reminderObj{
            let urlString = getUrlFromPlist(keyValue: "ReminderUpdate", params: ["id": reminderObj.patientId ?? "", "reminderId": reminderObj.reminderId ?? "", "moduleId": reminderObj.moduleId ?? "", "practiceId": reminderObj.practiceId ?? ""])
            
            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_DELETE, success: { [weak self] resp in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: resp, identificationKey: identificationKey)
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
        }
    }
    
    func addReminderHistory(reminderHistoryArray: [ReminderHistory], identificationKey: String){
        
        var isCallbackSent = false
        var respCount = 0
        var respArray: [ReminderHistory] = []
        
        reminderHistoryArray.forEach { reminderHistory in
            addReminderHistory(reminderHistory: reminderHistory, success: { [weak self] resp in
                guard let self = self else { return }
                respArray.append(resp)
                respCount += 1
                if respCount == reminderHistoryArray.count && !isCallbackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respArray, identificationKey: identificationKey)
                    isCallbackSent = true
                }
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                if !isCallbackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                    isCallbackSent = true
                }
            })
        }
    }
    
    private func addReminderHistory(reminderHistory: ReminderHistory, success: @escaping (ReminderHistory) -> Void, failure: @escaping (Error) -> Void){

        if let patientId = reminderHistory.patientId{
            let urlString = getUrlFromPlist(keyValue: "ReminderHistory", params: ["id": patientId, "reminderId": reminderHistory.reminderId ?? ""])
            
            let json = JsonBuilder.formAddReminderHistoryJson(reminderHistory: reminderHistory)
            if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])){
                initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] resp in
                    
                         guard self != nil else { return }
                    
                    let reminderHistoryId = ParsingHelper.getReminderHistoryId(resp)
                    reminderHistory.historyId = reminderHistoryId
                    success(reminderHistory)
                    
                }, failure: { [weak self] apiError in
                    guard self != nil else { return }
                    failure(apiError)
                })
            }
        }
    }
    
    func updateReminderHistory(reminderHistoryArray: [ReminderHistory], identificationKey: String){
        
        var isCallbackSent = false
        var respCount = 0
        var respArray: [ReminderHistory] = []
        
        reminderHistoryArray.forEach { reminderHistory in
            updateReminderHistory(reminderHistory: reminderHistory, success: { [weak self] resp in
                guard let self = self else { return }
                respArray.append(resp)
                respCount += 1
                if respCount == reminderHistoryArray.count && !isCallbackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respArray, identificationKey: identificationKey)
                    isCallbackSent = true
                }
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                if !isCallbackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                    isCallbackSent = true
                }
            })
        }
    }
    
    private func updateReminderHistory(reminderHistory: ReminderHistory, success: @escaping (ReminderHistory) -> Void, failure: @escaping (Error) -> Void){
        
        if let patientId = reminderHistory.patientId{
            let urlString = getUrlFromPlist(keyValue: "ReminderHistoryDetail", params: ["id": patientId, "reminderId": reminderHistory.reminderId ?? "", "historyId": reminderHistory.historyId ?? ""])
            
            let json = JsonBuilder.formUpdateReminderHistoryJson(reminderHistory: reminderHistory)
            if let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: [])){
                
                initiateWithUrlStringV2(urlString: urlString, dataToPost: jsonData, httpMethod: .HTTP_METHOD_PUT, success: { [weak self] resp in
                    guard self != nil else { return }
                    success(reminderHistory)
                }, failure: { [weak self] apiError in
                    guard self != nil else { return }
                    failure(apiError)
                })
            }
        }
    }
    
    func fetchTodayReminderHistory(identificationKey: String){
        
        let patientId = getSelectedPatientId()
        
        let urlString = getUrlFromPlist(keyValue: "ReminderHistoryByType", params: ["id": patientId, "fromDate": Date().getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), "toDate": Date().getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), "type": MEDICATION])
        
        initiateWithUrlStringV2(urlString: urlString.urlEncode(), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
            guard let self = self else { return }
            var reminderHistoryList = ParsingHelper.formTodayReminderHistoryList(respObj: resp)
            
            let urlString = getUrlFromPlist(keyValue: "ReminderHistoryByType", params: ["id": patientId, "fromDate": Date().getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), "toDate": Date().getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR), "type": SUPPLEMENT])
            
            initiateWithUrlStringV2(urlString: urlString.urlEncode(), httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
                
                     guard let self = self else { return }
                
                reminderHistoryList.append(contentsOf: ParsingHelper.formTodayReminderHistoryList(respObj: resp))
                v2Delegate?.charmConnectionV2HandlerDidRecieve(response: reminderHistoryList, identificationKey: identificationKey)
                
            }, failure: { [weak self] apiError in
                guard let self = self else { return }
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
            })
            
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    func fetchReminderHistory(reminderObj: Reminder, identificationKey: String){
        
        fetchReminderHistory(reminderObj: reminderObj, fromRange: 1, toCount: 50, parentHistoryList: [], success: { [weak self] historyList in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: historyList, identificationKey: identificationKey)
        }, failure: { [weak self] apiError in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        })
    }
    
    private func fetchReminderHistory(reminderObj: Reminder, fromRange: Int, toCount: Int, parentHistoryList: [ReminderHistory], success: @escaping ([ReminderHistory]) -> Void, failure: @escaping (Error) -> Void){
        
        var parentHistoryList = parentHistoryList
        
        let urlString = getUrlFromPlist(keyValue: "ReminderHistoryRange", params: ["id": reminderObj.patientId ?? "", "reminderId": reminderObj.reminderId ?? "", "moduleId": reminderObj.moduleId ?? "", "fromRange": fromRange, "toCount": toCount, "practiceId": reminderObj.practiceId ?? ""])
        
        initiateWithUrlStringV2(urlString: urlString.urlEncode() , httpMethod: .HTTP_METHOD_GET, success: { [weak self] resp in
            guard let self = self else { return }
            let historyList = ParsingHelper.formReminderHistoryList(respObj: resp, reminderId: reminderObj.reminderId)
            if historyList.isEmpty{
                success(parentHistoryList)
            }
            else{
                parentHistoryList.append(contentsOf: historyList)
                self.fetchReminderHistory(reminderObj: reminderObj, fromRange: toCount + fromRange, toCount: toCount, parentHistoryList: parentHistoryList, success: success, failure: failure)
            }
        }, failure: { [weak self] apiError in
            guard self != nil else { return }
            failure(apiError)
        })
    }

    //MARK: - Push Notification
    
    func getInstallationId( identificationKey : String){
        let patientId = Patient.patientList?.first?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "NotificationInsId", params: ["id": patientId])
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET,
        success:{ [weak self] respObj in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
        }, failure: { [weak self] apiError in
        
             guard let self = self else { return }
        
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)

        })
    }
    
    func unregisterPushNotification(pushNotificationDetailsPojo: PushNotificationDetailsPOJO, success: @escaping (Any) -> Void, failure: @escaping (Error) -> Void){
        var patientId = getSelectedPatientId()
        
        if patientId.isBlank() {
            patientId = Patient.patientList?.firstOrNil()?.patientId ?? ""
        }
        
        let urlString = getUrlFromPlist(keyValue: "NotificationUnregister", params: ["id": patientId])
        
        let postObj = JsonBuilder.formPushNotificationObj(pushNotificationDetailsPOJO: pushNotificationDetailsPojo)
        let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: []))!
        
        initiateWithUrlStringV2(urlString: urlString.urlEncode(),dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
            guard self != nil else { return }
            success(respObj)
        }, failure: { [weak self] error in
            guard self != nil else { return }
            failure(error)
        })
    }
    
    func registerPushNotification(pushNotificationDetailsPojo: PushNotificationDetailsPOJO, identificationKey: String){
        
        let patientId = Patient.patientList?.first?.patientId ?? ""
        let urlString = getUrlFromPlist(keyValue: "NotificationRegister", params: ["id": patientId])
        
        let postObj = JsonBuilder.formPushNotificationObj(pushNotificationDetailsPOJO: pushNotificationDetailsPojo)
        let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: []))!
        
        initiateWithUrlStringV2(urlString: urlString.urlEncode(),dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    
    func sendPushNotification(message:String, additionalInfo:String, identificationKey:String)
    {
        let patientId = getSelectedPatientId()
        //TODO: temp remove
        //307000000002003//1962000005028001//getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "NotificationSend", params: ["id": patientId])
        var postObj: [String: Any] = [:]
        postObj.addProperty("message", message)
        postObj.addProperty("additional_info", additionalInfo)
        postObj.addProperty("mode", 0)
        postObj.addProperty("module_id", "test message")
        let jsonData = (try? JSONSerialization.data(withJSONObject: postObj, options: []))!
        
        initiateWithUrlStringV2(urlString: urlString.urlEncode(), dataToPost: jsonData, httpMethod: .HTTP_METHOD_POST, success: { [weak self] respObj in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: respObj, identificationKey: identificationKey)
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        })
    }
    
//MARK: - Share Section
    
    func fetchSharedSectionPracticeList(identificationKey: String){
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "ShareHistory", params: ["id": patientId])
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET) { resp in
            let shareSectionList = ParsingHelper.getSharedSectionPracticeList(dict: resp)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: shareSectionList, identificationKey: identificationKey)
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    func fetchSharedSectionList(practiceId: String, identificationKey: String){
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "ShareSections", params: ["id": patientId, "practiceId": practiceId])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET) { resp in
            let shareSection = ParsingHelper.getPracticeShareSection(dict: resp)
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: shareSection, identificationKey: identificationKey)
            
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    func addShareSectionPracticeList(patientId: String, shareSection: ShareSection, identificationKey: String){
        let urlString = getUrlFromPlist(keyValue: "UpdateShareSections", params: ["id": patientId])
        let json = JsonBuilder.formShareSectionObj(shareSection: shareSection)
        let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        initiateWithUrlStringV2(urlString: urlString, dataToPost: data, httpMethod: .HTTP_METHOD_POST) { resp in
            self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: resp, identificationKey: identificationKey)
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    //MARK: - Images
    
    func fetchImageResultList(identificationKey: String){
        let patientId = getSelectedPatientId()
        
        let practiceList = getEnabledPractices(moduleId: imagesModelId)
        let practiceSize = practiceList.count
        
        var imageResultList: [ImagesResult] = []
        var respCount = 0
        
        var isCallbackSent = false
        
        practiceList.forEach({practiceId in
            let urlString = getUrlFromPlist(keyValue: "ImageResult", params: ["id": patientId, "practiceId": practiceId])
            initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET) { [weak self] respObj in
                
                guard let self = self else { return }
                respCount+=1
                let imgResultTempList = ParsingHelper.formImagesResultList(resp: respObj, practice: getPractice(practiceId: practiceId))
                imageResultList.append(contentsOf: imgResultTempList)
                
                if respCount == practiceSize && !isCallbackSent{
                    
                    self.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: FilterHandler.sortImagesResults(arrayOfResults: imageResultList), identificationKey: identificationKey)
                    isCallbackSent = true
                }
                
            } failure: { [weak self] apiError in
                guard let self = self else { return }
                
                respCount+=1
                if !isCallbackSent{
                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                    isCallbackSent = true
                }
            }
        })
    }
    
    func downloadImageResult(fileId: String, identificationKey: String){
        
        let patientId = getSelectedPatientId()

        let urlString = getUrlFromPlist(keyValue: "ImageResultFile", params: ["id": patientId, "fileId": fileId])
        
        initiateRequestWithIndexpath(indexPath: nil, urlString: urlString, identificationKey: identificationKey, callV2: true)
    }
    
    func fetchImageOrderList(identificationKey: String){
        
        let patientId = getSelectedPatientId()
        let urlString = getUrlFromPlist(keyValue: "ImageOrder", params: ["id": patientId])
        
        initiateWithUrlStringV2(urlString: urlString, httpMethod: .HTTP_METHOD_GET) { [weak self] resp in
            
            let imageOrderList: [ImagesOrder] = ParsingHelper.formImagesOrderList(resp: resp)
            self?.v2Delegate?.charmConnectionV2HandlerDidRecieve(response: imageOrderList, identificationKey: identificationKey)
            
        } failure: { [weak self] error in
            self?.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    func downloadImageOrder(fileId: String, identificationKey: String){
        
        let patientId = getSelectedPatientId()

        let urlString = getUrlFromPlist(keyValue: "ImageOrderFile", params: ["id": patientId, "fileId": fileId])
        
        initiateRequestWithIndexpath(indexPath: nil, urlString: urlString, identificationKey: identificationKey, callV2: true)
    }
    
// MARK: - Connection establishment methods
    
    private func initiateBluefinCall(urlString : String , dataToPost: Data ,identificationKey : String){
        
        if let url = URL(string: urlString) {
            
            var request = URLRequest(url: url)
            // request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
            
            request.httpMethod = "POST"
            request.httpBody = dataToPost
            
            let currentTask = CharmConnectionHandler.sharedUrlSession.dataTask(with: request, completionHandler: { (returnOfData, response, error) in
                if error == nil{
                    do{
                        if let returnOfData = returnOfData {
                            let str = String(decoding: returnOfData, as: UTF8.self)
                            debugPrintLog("return Data -> \(str)")
                            if let dict = try JSONSerialization.jsonObject(with: returnOfData, options: .allowFragments) as? [String:Any] {
                                
                                debugPrintLog("\(identificationKey) success")
                                self.delegate?.charmConnectionHandlerDidRecieveJsonObject(jsonObject: dict, identificationKey: identificationKey)
                            }
                            else{
                                let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.alertError")
                                self.delegate?.charmConnectionHandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                            }
                        }
                        else{
                            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.alertError")
                            self.delegate?.charmConnectionHandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
                        }
                    }
                    catch let errorOfJsonConversion {
                        
                        self.delegate?.charmConnectionHandlerDidFailWithError(error: errorOfJsonConversion, identificationKey: identificationKey)
                    }
                }else if let error{
                    self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                }
            })
            currentTask.resume()
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.error.noUrl.title")
            self.delegate?.charmConnectionHandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    private func initiateBluefinCall(urlString : String , dataToPost: Data ,success: @escaping (Dictionary<String,Any>) -> Void, failure: @escaping (Error) -> Void){
        
        if let url = URL(string: urlString){
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
            request.httpMethod = "POST"
            request.httpBody = dataToPost
            
            let currentTask = CharmConnectionHandler.sharedUrlSession.dataTask(with: request, completionHandler: { (returnOfData, response, error) in
                if error == nil{
                    do{
                        if let returnOfData = returnOfData {
                            let str = String(decoding: returnOfData, as: UTF8.self)
                            debugPrintLog("return Data -> \(str)")
                            if let dict = try JSONSerialization.jsonObject(with: returnOfData, options: .allowFragments) as? [String:Any] {
                                if dict.getBoolean("error") != true {
                                    success(dict)
                                }
                                else{
                                    failure(CharmUtil.getCustomError(domainKey: "com.charmphr.common.error"))
                                }
                            }
                            else{
                                failure(CharmUtil.getCustomError(domainKey: "com.charmphr.alertError"))
                            }
                        }
                        else{
                            failure(CharmUtil.getCustomError(domainKey: "com.charmphr.alertError"))
                        }
                    }
                    catch let errorOfJsonConversion {
                        failure(errorOfJsonConversion)
                    }
                }
                else if let error = error {
                    failure(error)
                }
            })
            currentTask.resume()
        }
        else{
            failure(CharmUtil.getCustomError(domainKey: "com.charmphr.error.noUrl.title"))
        }
    }

    private func initiateWithUrlStringV2(urlString : String , dataToPost : Data? = nil, httpMethod : HTTP_METHOD , success: @escaping (Dictionary<String,Any>) -> Void, failure: @escaping (Error) -> Void ){
        if let url = URL(string: urlString){
            
            var urlRequest = URLRequest(url: url)
            if httpMethod == .HTTP_METHOD_GET {
                urlRequest.httpMethod = "GET"
            }
            else if httpMethod == .HTTP_METHOD_DELETE{
                if let dataToPost, let jsonString = String(data: dataToPost, encoding: .utf8) {
                    debugPrintLog(jsonString)
                    urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
                }
                urlRequest.httpMethod = "DELETE"
            }
            else if httpMethod == .HTTP_METHOD_POST || httpMethod == .HTTP_METHOD_PUT
            {
                if httpMethod == .HTTP_METHOD_POST{
                    urlRequest.httpMethod = "POST"
                }else if httpMethod == .HTTP_METHOD_PUT{
                    urlRequest.httpMethod = "PUT"
                }
                
                if let dataToPost, let jsonString = String(data: dataToPost, encoding: .utf8) {
                    debugPrintLog("postBody -> \(jsonString)")
                    urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
                }else
                {
                    // to send a empty post object (example: check delete waitlist appointment)
                    let bodyString = ""
                    let bodyData = bodyString.data(using: .utf8)
                    urlRequest.httpBody = bodyData
                }
            }
            debugPrintLog("URL-String: \(urlString)")
            
            AuthenticationUtil.getToken { token, error in
                if let error {
                    failure(error)
                }
                else{
                    urlRequest.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
                    
                    let currentTask = CharmConnectionHandler.sharedUrlSession.dataTask(with: urlRequest) { (returnOfData, response, error) in
                        if error == nil{
                            do{
                                if let returnOfData, let dict = try JSONSerialization.jsonObject(with: returnOfData, options: .allowFragments) as? [String:Any] {                                 debugPrintLog(urlString)
                                    debugPrintLog(dict)
                                    if dict.getInt("code") == 0{
                                        success(dict)
                                    }
                                    else if dict.getBoolean("isSuccess") == true {
                                        if let outputString = dict.getAsJsonObject("output_string"), let result = outputString.getString("result"){
                                            if result == "Success"{
                                                success(dict)
                                            }
                                            else if result == "Error"{
                                                if let message = outputString.getString("message"){
                                                    let error = CharmUtil.getCustomError(domainKey: message, userInfo: dict)
                                                    failure(error)
                                                }
                                            }
                                            else{
                                                let error = CharmUtil.getCustomError(domainKey: "com.charmphr.alertError")
                                                failure(error)
                                            }
                                        }
                                        else{
                                            success(dict)
                                        }
                                    }
                                    else
                                    {
                                        let error = NSError(domain: "\(dict.getString("message") == nil ? "error" : dict.getString("message") ?? "")" , code: (dict.getInt("code") == nil ? (dict.getString("code") == nil ? 1000 : Int(dict.getString("code") ?? "") ?? 1000) :  dict.getInt("code")) ?? 1000, userInfo: dict)
                                        failure(error)
                                    }
                                }
                            }
                            catch let errorOfJsonConversion {
                                
                                debugPrintLog("conversion error in \n \n \(url.absoluteString)")
                                if let responseStatus = response as? HTTPURLResponse, responseStatus.statusCode == self.INVALID_OAUTH_ERROR_CODE
                                {
                                    debugPrintLog("V2 logout")
                                    AuthManager.logoutUser(isInvalidOAuth: true)
                                }else
                                {
                                    failure(errorOfJsonConversion)
                                }
                            }
                        }else if let error = error {
                            if (error as NSError).code != NSURLErrorCancelled {
                                failure(error)
                            }
                        }
                    }
                    currentTask.resume()
                }
            }
        }
        else{
            failure(CharmUtil.getCustomError(domainKey: "com.charmphr.error.noUrl.title"))
        }
    }
    
    private func initiateWithUrlString(urlString : String , dataToPost : Data? = nil, identificationKey : String , httpMedthod : HTTP_METHOD)
    {
        if let url = URL(string: urlString){
            
            var urlRequest = URLRequest(url: url)
            if httpMedthod == .HTTP_METHOD_GET {
                urlRequest.httpMethod = "GET"
            }
            else if httpMedthod == .HTTP_METHOD_DELETE{
                if let dataToPost, let jsonString = String(data: dataToPost, encoding: .utf8)
                {
                    debugPrintLog(jsonString)
                    urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
                }
                urlRequest.httpMethod = "DELETE"
            }
            else if httpMedthod == .HTTP_METHOD_POST || httpMedthod == .HTTP_METHOD_PUT
            {
                if httpMedthod == .HTTP_METHOD_POST{
                    urlRequest.httpMethod = "POST"
                }else if httpMedthod == .HTTP_METHOD_PUT{
                    urlRequest.httpMethod = "PUT"
                }
                
                if let dataToPost, let jsonString = String(data: dataToPost, encoding: .utf8)
                {
                    debugPrintLog("postBody -> \(jsonString)")
                    urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
                }
                else{
                    // to send a empty post object (example: check delete waitlist appointment)
                    let bodyString = ""
                    let bodyData = bodyString.data(using: .utf8)
                    urlRequest.httpBody = bodyData
                }
                
            }
            
            AuthenticationUtil.getToken { token, error in
                if let error {
                    self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                }
                else{
                    urlRequest.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
                    debugPrintLog(urlString)
                    let currentTask = CharmConnectionHandler.sharedUrlSession.dataTask(with: urlRequest) { (returnOfData, response, error) in
                        if error == nil{
                            do{
                                if let returnOfData, let dict = try JSONSerialization.jsonObject(with: returnOfData, options: .allowFragments) as? [String:Any]{
                                    
                                    debugPrintLog(urlString)
                                    debugPrintLog(dict)
                                    if dict.getInt("code") == 0
                                    {
                                        debugPrintLog("\(identificationKey) success")
                                        self.delegate?.charmConnectionHandlerDidRecieveJsonObject(jsonObject: dict, identificationKey: identificationKey)
                                    }
                                    else if dict.getBoolean("isSuccess") == true {
                                        
                                        if let outputString = dict.getAsJsonObject("output_string"), let result = outputString.getString("result"){
                                            if result == "Success"{
                                                debugPrintLog("\(identificationKey) success")
                                                self.delegate?.charmConnectionHandlerDidRecieveJsonObject(jsonObject: dict, identificationKey: identificationKey)
                                                debugPrintLog(dict)
                                            }
                                            else if result == "Error"{
                                                if let message = outputString.getString("message"){
                                                    let error = CharmUtil.getCustomError(domainKey: message, userInfo: dict)
                                                    self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                                }
                                            }
                                            else{
                                                let error = CharmUtil.getCustomError(domainKey: "com.charmphr.alertError")
                                                self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                            }
                                        }
                                        else{
                                            self.delegate?.charmConnectionHandlerDidRecieveJsonObject(jsonObject: dict, identificationKey: identificationKey)
                                        }
                                    }
                                    else
                                    {
                                        let error = NSError(domain: "\(dict.getString("message") == nil ? "error" : dict.getString("message") ?? "")" , code: dict.getInt("code") == nil ? (dict.getString("code") == nil ? 1000 : Int(dict.getString("code") ?? "") ?? 1000) :  dict.getInt("code") ?? 1000, userInfo: dict)
                                        self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                    }
                                }
                                else{
                                    let error = CharmUtil.getCustomError(domainKey: "com.charmphr.alertError")
                                    self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                }
                            }
                            catch let errorOfJsonConversion {
                                debugPrintLog("conversion error in \n \n \(url.absoluteString)")
                                if let responseStatus = response as? HTTPURLResponse
                                {
                                    if responseStatus.statusCode == self.INVALID_OAUTH_ERROR_CODE {
                                        debugPrintLog("V1 logout")
                                        AuthManager.logoutUser(isInvalidOAuth: true)
                                    }
                                    else{
                                        self.delegate?.charmConnectionHandlerDidFailWithError(error: errorOfJsonConversion, identificationKey: identificationKey)
                                    }
                                }
                            }
                        }
                        else if let error = error {
                            debugPrintLog("error in \n \n \(url.absoluteString)")
                            if (error as NSError).code != NSURLErrorCancelled{
                                self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                            }
                        }
                    }
                    currentTask.resume()
                }
            }
        }
        else{
            let apiError = CharmUtil.getCustomError(domainKey: "com.charmphr.error.noUrl.title")
            self.delegate?.charmConnectionHandlerDidFailWithError(error: apiError, identificationKey: identificationKey)
        }
    }
    
    private func initiateRequestWithIndexpath(indexPath :IndexPath? , urlString : String , identificationKey : String , callV2: Bool = false)
    {
        if let url = URL(string: urlString){
            
            AuthenticationUtil.getToken { token, error in
                if let error {
                    if callV2 {
                        self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
                    }
                    else{
                        self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                    }
                }
                else{
                    var urlRequest = URLRequest(url: url)
                    urlRequest.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
                    urlRequest.httpMethod = "GET"
                    debugPrintLog(urlString)
                    let currentTask = CharmConnectionHandler.sharedUrlSession.dataTask(with: urlRequest) { (returnOfData, response, error) in
                        
                        if let error = error {
                            if (error as NSError).code != NSURLErrorCancelled{
                                if callV2 {
                                    self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                }
                                else{
                                    self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                }
                            }
                        }
                        else{
                            if let returnOfData = returnOfData {
                                debugPrintLog("\(identificationKey) success")
                                self.dataDelegate?.charmConnectionHandlerDidRecieveData(data: returnOfData, indexPath: indexPath, identificationKey: identificationKey)
                            }
                            else{
                                let error = CharmUtil.getCustomError(domainKey: "com.charmphr.error.fileEmpty.title")
                                self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                            }
                        }
                    }
                    currentTask.resume()
                }
            }
        }
        else{
            let error = CharmUtil.getCustomError(domainKey: "com.charmphr.error.noUrl.title")
            if callV2 {
                self.v2Delegate?.charmConnectionV2HandlerDidFailWithError(error: error, identificationKey: identificationKey)
            }
            else{
                self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
            }
        }
    }
    
    private func initiateRequestWithTag(tag :Int , urlString : String , identificationKey : String )
    {
        if let url = URL(string: urlString){
            
            AuthenticationUtil.getToken { token, error in
                if let error {
                    self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                }
                else{
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "GET"
                    urlRequest.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
                    debugPrintLog(urlString)
                    let currentTask = CharmConnectionHandler.sharedUrlSession.dataTask(with: urlRequest) { (returnOfData, response, error) in
                        if let returnOfData, error == nil{
                            debugPrintLog("\(identificationKey) success")
                            self.tagDelegate?.charmConnectionHandlerDidRecieveData(data: returnOfData, tag: tag, identificationKey: identificationKey)
                        }
                        else if let error = error {
                            if (error as NSError).code != NSURLErrorCancelled {
                                self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                            }
                        }
                    }
                    currentTask.resume()
                }
            }
        }
        else{
            let error = CharmUtil.getCustomError(domainKey: "com.charmphr.error.noUrl.title")
            self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    private func initiateRequestUploadRequestWith( image : UIImage , urlString : String , identificationKey : String , tag: Int? = nil )
    {
        if let url = URL(string: urlString), let imageData = image.pngData(){
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST";
            let boundary = "Boundary-\(NSUUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            AuthenticationUtil.getToken { [self] token, error in
                if let error {
                    delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                }
                else{
                    urlRequest.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
                    urlRequest.httpBody = convertImageToDataWith(filePathKey: "attachment", imageDataKey: imageData as NSData, boundary: boundary) as Data
                    debugPrintLog(urlString)
                    let currentTask = CharmConnectionHandler.sharedUrlSession.dataTask(with: urlRequest) { (returnOfData, response, error) in
                        if error == nil{
                            do{
                                if let returnOfData, let dict = try JSONSerialization.jsonObject(with: returnOfData, options: .allowFragments) as? [String:Any] {
                                    if dict.getInt("code") == 0
                                    {
                                        if let tag{
                                            self.tagDelegate?.charmConnectionHandlerDidRecieveData(image: image, tag: tag, identificationKey: identificationKey)
                                        }
                                        else{
                                            self.delegate?.charmConnectionHandlerDidRecieveJsonObject(jsonObject: dict, identificationKey: identificationKey)
                                        }
                                        
                                    }else{
                                        let error = NSError(domain: "\(dict.getString("message") ?? "")" , code:dict.getInt("code") ?? 1000  , userInfo: dict)
                                        self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                    }
                                }
                            }
                            catch let errorOfJsonConversion {
                                self.delegate?.charmConnectionHandlerDidFailWithError(error: errorOfJsonConversion, identificationKey: identificationKey)
                            }
                        }
                        else if let error = error {
                            if (error as NSError).code != NSURLErrorCancelled {
                                self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                            }
                        }
                    }
                    currentTask.resume()
                }
            }
        }
        else{
            let error = CharmUtil.getCustomError(domainKey: "com.charmphr.error.noUrl.title")
            self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
        }
    }
    
    private func convertImageToDataWith(filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData
    {
        let body = NSMutableData()
        let filename = "file.png"
        let mimetype = "png"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey ?? "")\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        return body
    }
    
    private func initiateRequestWithData( param : Dictionary<String,Any> , urlString : String, fileKeyPath : String ,identificationKey : String? = nil, success: ((Dictionary<String,Any>) -> Void)? = nil, failure: ((Error) -> Void)? = nil )
    {
        //stirctly only for png,jpeg,pdf
        if let url = URL(string: urlString){
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            let boundary = "Boundary-\(NSUUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            AuthenticationUtil.getToken { [self] token, error in
                if let error {
                    failure?(error)
                }
                else{
                    urlRequest.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
                    urlRequest.httpBody = convertDataToPostDataWith(param: param, boundary: boundary, fileKeyPath: fileKeyPath)
                    
                    debugPrintLog(urlString)
                    
                    
                    let currentTask = CharmConnectionHandler.sharedUrlSession.dataTask(with: urlRequest, completionHandler: { (returnOfData, response, error) in
                        if error == nil{
                            do{
                                if let returnOfData, let dict = try JSONSerialization.jsonObject(with: returnOfData, options: .allowFragments) as? [String:Any] {

                                    if dict.getInt("code") == 0
                                    {
                                        debugPrintLog(dict)
                                        if let identificationKey = identificationKey {
                                            debugPrintLog("\(identificationKey) success")
                                            self.delegate?.charmConnectionHandlerDidRecieveJsonObject(jsonObject: dict, identificationKey: identificationKey)
                                        }
                                        else{
                                            success?(dict)
                                        }
                                    }
                                    else
                                    {
                                        let error = NSError(domain: "\(dict.getString("message") == nil ? "error" : dict.getString("message") ?? "")" , code: dict.getInt("code") == nil ? 1000 :  dict.getInt("code") ?? 1000, userInfo: dict)
                                        
                                        if let identificationKey = identificationKey {
                                            self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                        }
                                        else{
                                            failure?(error)
                                        }
                                    }
                                }
                            }
                            catch let errorOfJsonConversion {
                                if let responseStatus = response as? HTTPURLResponse, responseStatus.statusCode == self.INVALID_OAUTH_ERROR_CODE
                                {
                                    AuthManager.logoutUser(isInvalidOAuth: true)
                                }else
                                {
                                    if let identificationKey = identificationKey {
                                        self.delegate?.charmConnectionHandlerDidFailWithError(error: errorOfJsonConversion, identificationKey: identificationKey)
                                    }
                                    else{
                                        failure?(errorOfJsonConversion)
                                    }
                                }
                            }
                        }else if let error = error {
                            if (error as NSError).code != NSURLErrorCancelled {
                                if let identificationKey = identificationKey {
                                    self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
                                }
                                else{
                                    failure?(error)
                                }
                            }
                        }
                    })
                    currentTask.resume()
                }
            }
        }
        else{
            let error = CharmUtil.getCustomError(domainKey: "com.charmphr.error.noUrl.title")
            if let identificationKey = identificationKey {
                self.delegate?.charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
            }
            else{
                failure?(error)
            }
        }
    }
    
    // MARK: - Other methods
    
    private func convertDataToPostDataWith( param : Dictionary<String,Any> , boundary: String ,fileKeyPath : String , contentType: String? = nil)-> Data
    {
        //give filename with type
        var body = Data()
        
        let boundaryStartStr = "--\(boundary)\r\n"
        let boundaryEndStr = "--\(boundary)--\r\n"
        
        for (key,value) in param
        {
            if value is String
            {
                if let value = value as? String{
                    
                    body.appendString(string: boundaryStartStr)
                    body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\";\r\n\r\n")
                    body.appendString(string: "\(value)\r\n")
                }
            }
            else if value is Data
            {
                if let valueData = value as? Data{
                    body.appendString(string: boundaryStartStr)
                    //                let mimeType = "\(key.split(separator: ".").last ?? "png")"
                    body.appendString(string: "Content-Disposition: form-data; name=\"\(fileKeyPath)\"; filename=\"\(key)\"\r\n")
                    if UIImage(data: valueData) != nil
                    {
                        body.appendString(string: "Content-Type: \(contentType ?? "image/jpeg")\r\n\r\n")
                    }
                    else
                    {
                        body.appendString(string: "Content-Type: video/quicktime\r\n\r\n")
                    }
                    body.append(valueData)
                    body.appendString(string: "\r\n")
                }
            }
            else 
            {
                debugPrintLog("this type file will not be posted ")
            }
        }
        body.appendString(string: boundaryEndStr)
        
        
        if let jsonString = String(data: body, encoding: .ascii){
            debugPrint(jsonString)
        }
        else{
            debugPrint("Cannot print Formdata \(body.count)")
        }
        return body
    }
}
