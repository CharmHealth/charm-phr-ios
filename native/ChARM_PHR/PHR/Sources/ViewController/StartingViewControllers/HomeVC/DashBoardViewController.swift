//
//  DashBoardViewController.swift
//  ChARM Phr
//
//  Created by Sankar Saravanan on 08/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import UIKit

class DashBoardViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , CharmConnectionHandlerDelegate, CharmConnectionV2HandlerDelegate , CharmConnectionHandlerDataDelegate, AddViewControllerDelegate, CancelAppointmentViewControllerDelegate, AppointmentListViewDelegate, NoDataViewDelegate, TelehealthUtilDelegate
{
    
    private let activityIndicator = UIActivityIndicatorView()
    let dashboardView = DashboardView()
    private let noDataView = NoDataView()
    private let dashboardModel = DashboardModel()
    
    private var patient : Patient!
    private var charmConnectionHandler : CharmConnectionHandler?
    weak var delegate : HomeViewControllerNavigationDelegate?
    private var telehealthUtil: TelehealthUtil? = nil
    
    private var cancelAppointmentVC: CancelAppointmentViewController?
    private weak var noDataDelegate : NoDataViewDelegate?
    
    let VITALS_VIEW_TAG = 160100
    let VITAL_WEIGHT_VIEW_TAG = 160200
    let VITAL_HEIGHT_VIEW_TAG = 160300
    let VITAL_BP_VIEW_TAG = 160400
    
    //To avoid multiple calls at a time
    //This needs to be improvised
    private var isAppointmentRequestAlreadySent = false
    private var isMedicationRequestAlreadySent = false
    private var isMessageRequestAlreadySent = false
    private var isQuestionnaireRequestAlreadySent = false
    private var isInvoiceRequestAlreadySent = false
    private var isVitalsRequestAlreadySent = false

    private var isAppointmentFetched = false
    private var isMedicationsFetched = false
    private var isVitalsFetched = false
    private var isQuestionnaireFetched = false
    private var isMessageFetched = false
    private var isInvoiceFetched = false
    
    var selectedInvoice: PHRBills? = nil
    var selectedMessage: Messages? = nil
    var appointmentSection : Section?
    
    var upComingAppointmentSectionTotalCount = 0
    private var upComingAppointmentIndexTotalCount = 0
    private var selectedVitalType = ""
    private var presentedVC: UIViewController?
    private var tagNo = 19078927911
    private var btnToAppointmentMap:[Int:Appointment] = [:]
    private var isApiErrorOccured: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: true)
        
        self.view.addSubview(dashboardView)
        
        dashboardView.setSafeAreaLeft(offset: 0)
        dashboardView.setSafeAreaRight(offset: 0)
        dashboardView.setSafeAreaTop(offset: 0)
        dashboardView.setBottom(offSet: 0)
        debugPrintLog("UserName:-> \(Patient.selectedPatientInstance?.firstName ?? "")")
        self.view.addSubview(activityIndicator)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        self.view.addSubview(noDataView)
        
        noDataView.delegate = self
        noDataView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        noDataView.isHidden = true
        
        noDataView.setCenterY()
        noDataView.setCenterX()
        
        noDataView.hideSubView(bool: true)
        
        AppDataHandler.sharedInstance().refreshAppointments = false
        AppDataHandler.sharedInstance().refreshMedication = false
        AppDataHandler.sharedInstance().refreshQuestionnaire = false
        AppDataHandler.sharedInstance().refreshInvoice = false
        AppDataHandler.sharedInstance().refreshMessage = false
        AppDataHandler.sharedInstance().reloadMessage = false
        AppDataHandler.sharedInstance().refreshVitals = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDashboardData()
    }
    
//MARK: - Api calls
    
    func refreshDashboardData(){
        if let mainViewController = self.parent?.parent as? MainViewController
        {
            mainViewController.demographicsViewControllerDidChangeName()
        }
        
        //TODO: temporarily added, need to change this in proper way
        if(AppDataHandler.sharedInstance().refreshAppointments){
            fetchAppointments()
        }
        if(AppDataHandler.sharedInstance().refreshMedication){
            fetchMedication()
        }
        
        if(AppDataHandler.sharedInstance().refreshInvoice){
            fetchActiveInvoices()
        }
        
        if(AppDataHandler.sharedInstance().refreshQuestionnaire){
            fetchQuestionnaires()
        }
        
        if(AppDataHandler.sharedInstance().refreshMessage){
            fetchMessages()
        }
        
        if(AppDataHandler.sharedInstance().reloadMessage){
            reloadMessageList()
        }
        
        if(AppDataHandler.sharedInstance().refreshVitals){
            fetchVitals()
        }
    }
    
    func fetchDashboardData()
    {
        isApiErrorOccured = false
        self.patient = Patient.selectedPatientInstance!
        
        isAppointmentFetched = false
        isMedicationsFetched  = false
        isVitalsFetched = false
        isMessageFetched = false
        isQuestionnaireFetched = false
        isInvoiceFetched = false
        
        dashboardModel.trackerList = nil
        
        if charmConnectionHandler == nil
        {
            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
            self.charmConnectionHandler?.v2Delegate = self
            self.charmConnectionHandler?.dataDelegate = self
        }
        
        fetchAppointments()
        fetchVitals()
        fetchMessages()
        fetchQuestionnaires()
        fetchActiveInvoices()
        fetchMedication()
    }
    
    private func fetchAppointments()
    {
        if(isAppointmentRequestAlreadySent == false){
            showActivityIndicator()
            
            isAppointmentRequestAlreadySent = true
            dashboardModel.upComingAppointmentList = []
            dashboardModel.todayAppointmentList = []
            self.charmConnectionHandler?.fetchAppointment(patientId: self.patient.patientId, identificationKey: "fetchAppoinments")
        }
    }
    
    private func fetchMedication()
    {
        if(isMedicationRequestAlreadySent == false){
            showActivityIndicator()
            
            isMedicationRequestAlreadySent = true

            dashboardModel.medicationList = []
            charmConnectionHandler?.fetchMedicationList(viewType: PrescriptionFilterType.Active.rawValue, patientId: getSelectedPatientId(), identificationKey: "fetchPrescritions")
        }
    }
    
    private func fetchMessages()
    {
        if(!isMessageRequestAlreadySent){
            showActivityIndicator()
            
            isMessageRequestAlreadySent = true
            dashboardModel.messageList = []
            self.charmConnectionHandler?.fetchMessageList(page:1, messageType: "inbox" , identificationKey: "fetchMessages")
        }
    }
    
    private func fetchQuestionnaires()
    {
        if(!isQuestionnaireRequestAlreadySent){
            showActivityIndicator()
            
            isQuestionnaireRequestAlreadySent = true
            dashboardModel.questionnaireList = []
            dashboardModel.allQuestionnaireList = []
            charmConnectionHandler?.getQuestionnaireList(type: questionnaireCurrentValue, identificationKey: "fetchQuestionnaire")
        }
    }
    
    private func fetchActiveInvoices()
    {
        if(!isInvoiceRequestAlreadySent){
            showActivityIndicator()
            
            isInvoiceRequestAlreadySent = true
            dashboardModel.invoiceList = []
            charmConnectionHandler?.fetchInvoiceList(pageNo: 1, identificationKey: "fetchInvoice")
        }
    }
    
    private func fetchVitals()
    {
        if !isVitalsRequestAlreadySent{
            showActivityIndicator()
            
            isVitalsRequestAlreadySent = true
            dashboardModel.vitalsList = []
            charmConnectionHandler?.fetchVitals(patientId: Patient.selectedPatientInstance!.patientId, identificationKey: "fetchVitals")
        }
    }
    
    private func reloadMessageList(){
        if dashboardModel.messageList.isEmpty{
            fetchMessages()
        }
        else{
            var newMessageList: [Messages] = []
            dashboardModel.messageList.forEach { messages in
                if messages.messageReceipients?.status == "0"{
                    newMessageList.append(messages)
                }
            }
            dashboardModel.messageList = newMessageList
            dashboardView.recentMessageTableView.reloadData()
        }
        AppDataHandler.sharedInstance().reloadMessage = false
    }
    
    private func downloadUpcomingProviderPhoto(member: Provider, indexPath: IndexPath, identificationKey: String){
        charmConnectionHandler?.downloadProviderPhoto(provider: member, indexPath: indexPath, identificationKey: identificationKey)
    }
    
    private func fetchVitalTrackersList(){
        showActivityIndicator(hideView: false)
        charmConnectionHandler?.fetchVitalTrackersList(identificationKey: "fetchVitalTracker")
    }
    
    private func downloadPatientPhoto(patientId: String, indexPath: IndexPath){
        charmConnectionHandler?.downloadPatientPhoto(patientId: patientId, indexpath: indexPath, identificationKey: "downloadPhoto")
    }
    
    private func downloadProviderPhoto(providerId: String?, practiceId: String?, indexPath: IndexPath){
        charmConnectionHandler?.fetchProviderPhoto(providerId: providerId ?? "", practiceId: practiceId ?? "", indexPath: indexPath, identificationKey: "downloadPhoto")
    }
    
//MARK: - Create views
    
    private func refreshVitals(){
        if isVitalsFetched{
            dashboardView.refreshVitals(dashboardModel: dashboardModel, delegate: self)
            hideActivityIndicator()
        }
    }
    
    private func createSubViews(){
        
        if (isAppointmentFetched && isMedicationsFetched && isVitalsFetched && isMessageFetched && isQuestionnaireFetched && isInvoiceFetched)
        {
            dashboardView.createSubViews(appointmentSection: appointmentSection, dashboardModel: dashboardModel, delegate: self, homeVCDelegate: delegate)
            dashboardView.questionnaireTableView.delegate = self
            dashboardView.questionnaireTableView.dataSource = self
            dashboardView.activeInvoiceTableView.delegate = self
            dashboardView.activeInvoiceTableView.dataSource = self
            dashboardView.recentMessageTableView.delegate = self
            dashboardView.recentMessageTableView.dataSource = self
            dashboardView.todayAppoinmentstableView.delegate = self
            dashboardView.todayAppoinmentstableView.dataSource = self
            dashboardView.upComingAppoinmentstableView.delegate = self
            dashboardView.upComingAppoinmentstableView.dataSource = self
            
            hideActivityIndicator()
        }
    }
    
    func showNoDataView(error: Error, noDataDelegate: NoDataViewDelegate?) {
        self.view.bringSubviewToFront(noDataView)
        self.noDataDelegate = noDataDelegate
        noDataView.hideSubView(bool: false)
        noDataView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        dashboardView.isHidden = true
    }
    
    func noDataViewRetryBtnClicked() {
        showActivityIndicator()
        if let noDataDelegate{
            noDataDelegate.noDataViewRetryBtnClicked()
        }
        else{
            fetchDashboardData()
        }
    }
    
//MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == dashboardView.upComingAppoinmentstableView
        {
            if dashboardModel.upComingAppointmentList.count == 0
            {
                return 1
            }
            return dashboardModel.upComingAppointmentList[section].count
        }
        else if tableView == dashboardView.todayAppoinmentstableView
        {
            return dashboardModel.todayAppointmentList.count
        }
        else if tableView == dashboardView.recentMessageTableView
        {
            if dashboardModel.messageList.count == 0{
                dashboardView.recentMessageView?.isHidden = true
            }
            else{
                dashboardView.recentMessageView?.isHidden = false
                if dashboardModel.messageList.count > 2 {
                    return 2
                }
                else{
                    return dashboardModel.messageList.count
                }
            }
        }
        else if tableView == dashboardView.questionnaireTableView
        {
            if dashboardModel.questionnaireList.isEmpty{
                dashboardView.questionnaireView?.isHidden = true
            }
            else{
                dashboardView.questionnaireView?.isHidden = false
                if dashboardModel.questionnaireList.count > 2 {
                    return 2
                }
                else{
                    return dashboardModel.questionnaireList.count
                }
            }
        }
        else if tableView == dashboardView.activeInvoiceTableView
        {
            if dashboardModel.invoiceList.isEmpty{
                dashboardView.activeInvoiceView?.isHidden = true
            }
            else{
                dashboardView.activeInvoiceView?.isHidden = false
                if dashboardModel.invoiceList.count > 2 {
                    return 2
                }
                else{
                    return dashboardModel.invoiceList.count
                }
            }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == dashboardView.upComingAppoinmentstableView
        {
            if dashboardModel.upComingAppointmentList.count == 0
            {
                return 1
            }
            return dashboardModel.upComingAppointmentList.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if RbacUtil.checkPrivilege(privilege: .CANCEL_APPOINTMENT){
            
            if tableView == dashboardView.upComingAppoinmentstableView
            {
                if dashboardModel.upComingAppointmentList.count != 0{
                    if let appointment = dashboardModel.upComingAppointmentList.getElement(at: indexPath.section)?.getElement(at: indexPath.row){
                        let deleteAction = UIContextualAction(style: .destructive, title: getString(key: "com.charmphr.action.cancel"), handler: { (action, view, completionHandler) in
                            //
                            self.checkAndPresentCancelAppointment(at: indexPath, appointment: appointment)
                            completionHandler(true)
                        })
                        
                        deleteAction.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
                        return UISwipeActionsConfiguration(actions: [deleteAction])
                    }
                }
                
            }
            else if tableView == dashboardView.todayAppoinmentstableView {
                if dashboardModel.todayAppointmentList.count != 0{
                    if let appointment = dashboardModel.todayAppointmentList.getElement(at: indexPath.row)  {
                        
                        
                        let deleteAction = UIContextualAction(style: .destructive, title: getString(key: "com.charmphr.action.cancel"), handler: { (action, view, completionHandler) in
                            //
                            self.checkAndPresentCancelAppointment(at: indexPath, appointment: appointment)
                            completionHandler(true)
                        })
                        
                        deleteAction.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
                        return UISwipeActionsConfiguration(actions: [deleteAction])
                    }
                }
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == dashboardView.upComingAppoinmentstableView
        {
            if dashboardModel.upComingAppointmentList.count == 0
            {
                if let noUpcomingAppointmentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoUpcomingAppointmentsTableViewCell") as? NoUpcomingAppointmentsTableViewCell{
                    //  noUpcomingAppointmentTableViewCell.noDataView.backgroundColor = .clear
                    // noUpcomingAppointmentTableViewCell.noDataView.delegate = self
                    noUpcomingAppointmentTableViewCell.selectionStyle = .none
                    
                    if RbacUtil.checkPrivilege(privilege: .ADD_APPOINTMENT) && isPHREntryEnabled(moduleId: appointmentModelId){
                        noUpcomingAppointmentTableViewCell.tryAgainBtn.addTarget(self, action: #selector(bookNowClicked), for: .touchUpInside)
                        noUpcomingAppointmentTableViewCell.tryAgainBtn.isHidden = false
                    }
                    else{
                        noUpcomingAppointmentTableViewCell.tryAgainBtn.isHidden = true
                    }
                    
                    return noUpcomingAppointmentTableViewCell
                }
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentsTableViewCell") as? AppointmentsTableViewCell{
                let appointment = dashboardModel.upComingAppointmentList[indexPath.section][indexPath.row]
                upComingAppointmentIndexTotalCount += 1
                cell.setTableViewCell(appointment: appointment, delegate: self, isLast: (upComingAppointmentSectionTotalCount == upComingAppointmentIndexTotalCount))
                cell.selectionStyle = .none
                
                if let member = appointment.member, !dashboardModel.upComingAppointmentList.isEmpty{
                    downloadUpcomingProviderPhoto(member: member, indexPath: indexPath, identificationKey: "downloadUpcomingProviderPhoto")
                }
                return cell
            }
            return UITableViewCell()
        }
        else if tableView == dashboardView.todayAppoinmentstableView
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentsTableViewCell") as? AppointmentsTableViewCell{
                let appointment = dashboardModel.todayAppointmentList[indexPath.row]
                cell.setTableViewCell(appointment: appointment, delegate: self, isLast: (dashboardModel.todayAppointmentList.count - 1 == indexPath.row))
                cell.selectionStyle = .none
                
                if let member = appointment.member, !dashboardModel.todayAppointmentList.isEmpty{
                    downloadUpcomingProviderPhoto(member: member, indexPath: indexPath, identificationKey: "downloadTodayProviderPhoto")
                }
                
                return cell
            }
            
        }
        else if tableView == dashboardView.recentMessageTableView {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "RecentMessageTableViewCell") as? RecentMessageTableViewCell{
                
                let message = dashboardModel.messageList[indexPath.row]
                cell.setValues(message: message)
                
                if message.senderImg == nil {
                    
                    let patient = Patient.selectedPatientInstance ?? Patient()
                    
                    if message.messageReceipients?.fromId == patient.patientId {
                        if patient.isPhotoAvailable {
                            downloadPatientPhoto(patientId: patient.patientId, indexPath: indexPath)
                        }
                    }
                    else{
                        downloadProviderPhoto(providerId: message.messageReceipients?.fromId, practiceId: message.practiceId, indexPath: indexPath)
                    }
                }
                return cell
            }
        }
        
        else if tableView == dashboardView.questionnaireTableView {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeQuestionnaireTableView") as? HomeQuestionnaireTableView{
                let physicianTemplate = dashboardModel.questionnaireList[indexPath.row]
                
                cell.setValues(physicianTemplate: physicianTemplate, type: questionnaireCurrentValue)
                
                return cell
            }
        }
        else if tableView == dashboardView.activeInvoiceTableView {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveInvoiceTableViewCell") as? ActiveInvoiceTableViewCell{
                let phrBill = dashboardModel.invoiceList[indexPath.row]
                cell.setValues(phrBill: phrBill)
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == dashboardView.activeInvoiceTableView{
            
            let phrBill = dashboardModel.invoiceList[indexPath.row]
            selectedInvoice = phrBill
            delegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: "InvoiceDetail")
        }
        else if tableView == dashboardView.questionnaireTableView{
            
            let questionnaireAnswerVC = QuestionnaireAnswerViewController()
            questionnaireAnswerVC.physicianTemplate = dashboardModel.questionnaireList[indexPath.row]
            questionnaireAnswerVC.delegate = self
            self.navigationController?.pushViewController(questionnaireAnswerVC, animated: true)
        }
        else if tableView == dashboardView.recentMessageTableView {
            
            let message = dashboardModel.messageList[indexPath.row]
            selectedMessage = message
            delegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: "MessageDetailVC")
            if message.messageReceipients?.status == "0" {
                message.messageReceipients?.status = "1"
                AppDataHandler.sharedInstance().reloadMessage = true
            }
        }
        else if tableView == dashboardView.upComingAppoinmentstableView{
            if !dashboardModel.upComingAppointmentList.isEmpty{
                delegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: "Appointments")
            }
        }
        else if tableView == dashboardView.todayAppoinmentstableView{
            if !dashboardModel.todayAppointmentList.isEmpty{
                delegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: "Appointments")
            }
        }
    }
    
//MARK: - Delegate functions
    
    func mapBtnViewToAppointment(joinBtn: UIButton, questionnaireBtn: UIButton, appointment: Appointment){
        
        joinBtn.tag = tagNo
        tagNo += 1
        btnToAppointmentMap[joinBtn.tag] = appointment
        joinBtn.addTarget(self, action: #selector(onClickJoinBtn(btn:)), for: .touchUpInside)
        
        questionnaireBtn.tag = tagNo
        tagNo += 1
        btnToAppointmentMap[questionnaireBtn.tag] = appointment
        questionnaireBtn.addTarget(self, action: #selector(onClickQuestionnaire(btn:)), for: .touchUpInside)
    }
    
    func addViewControllerDataAdded(message: String?) {
        if let message = message{
            CharmUtil.showToast(controller: self, message: message, seconds: 2)
        }
        viewWillAppear(false)
    }
    
//MARK: - Action calls
    
    @objc private func onClickJoinBtn(btn: UIButton){
        if let appointment = btnToAppointmentMap[btn.tag]{
            if telehealthUtil == nil{
                telehealthUtil = TelehealthUtil(rootVC: self, questionnaireList: dashboardModel.allQuestionnaireList, delegate: self, rootPopUpVC: delegate as? UIViewController)
            }
            telehealthUtil?.onTapJoinBtn(appointment: appointment)
        }
    }
    
    @objc private func onClickQuestionnaire(btn: UIButton){
        if let appointment = btnToAppointmentMap[btn.tag]{
            pushToQuestionnaireViewController(appointment: appointment)
        }
    }
    
    private func checkAndPresentCancelAppointment(at indexPath : IndexPath , appointment: Appointment){
        
        if appointment.cancelOption != nil && RbacUtil.checkPrivilege(privilege: .CANCEL_APPOINTMENT){
            if let cancelOption = appointment.cancelOption {
                if cancelOption.isBlank() {
                    
                    let cancelAppointmentVC = CancelAppointmentViewController()
                    cancelAppointmentVC.appointment = appointment
                    cancelAppointmentVC.indexPath = indexPath
                    cancelAppointmentVC.modalTransitionStyle = .crossDissolve
                    cancelAppointmentVC.modalPresentationStyle = .overFullScreen
                    cancelAppointmentVC.delegate = self
                    self.cancelAppointmentVC = cancelAppointmentVC
                    
                    present(cancelAppointmentVC, animated: true)
                }
                else{
                    CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointment.cancel.time.error", with: [cancelOption]))
                }
            }
        }
        else{
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.cancel.error"))
        }
    }
    
    func onVitalClicked(tag: Int){
        var vitalType = wellnessWeightModelId
        
        if tag == VITAL_HEIGHT_VIEW_TAG{
            vitalType = wellnessHeightModelId
        }
        else if tag == VITAL_BP_VIEW_TAG{
            vitalType = wellnessBPModelId
        }
        
        
        selectedVitalType = vitalType
        
        if dashboardModel.trackerList != nil{
            segueToWellnessDetail()
        }
        else{
            fetchVitalTrackersList()
        }
    }
    
//MARK: - Navigate to Functions
    
    private func segueToWellnessDetail(){
        
        if let trackerList = dashboardModel.trackerList {
            let tracker =  trackerList.first(where: { tracker in
                
                if selectedVitalType == wellnessBPModelId{
                    return tracker.isDefaultTracker && tracker.trackerName == wellnessBPModelId
                }
                else{
                    return tracker.isDefaultTracker && tracker.trackerName == wellnessGeneralModelId
                }
            })
            
            if let tracker = tracker {
                var vitalTypeStr = VitalType.Weight
                
                if selectedVitalType == wellnessBPModelId{
                    vitalTypeStr = VitalType.Blood_pressure
                }
                else if selectedVitalType == wellnessHeightModelId{
                    vitalTypeStr = VitalType.Height
                }
                
                var isSegueToWellnessDetail = true
                
                if let vital = dashboardModel.vitalsList.first(where: {vitalEntry in
                    vitalEntry.vitalType == vitalTypeStr
                }) {
                    
                    if vital.vitalValue.isBlank(){
                        isSegueToWellnessDetail = false
                    }
                }
                else{
                    isSegueToWellnessDetail = false
                }
                
                if isSegueToWellnessDetail {
                    let wellnessDetail = WellnessDetailViewController()
                    wellnessDetail.tracker = tracker
                    
                    if selectedVitalType == wellnessHeightModelId{
                        wellnessDetail.selectedType = selectedVitalType
                    }
                    
                    self.navigationController?.pushViewController(wellnessDetail, animated: true)
                }
                else{
                    let addWellness = AddWellnessViewController()
                    addWellness.delegate = self
                    addWellness.tracker = tracker
                    self.navigationController?.pushViewController(addWellness, animated: true)
                }
            }
            else{
                let addWellness = AddWellnessViewController()
                addWellness.delegate = self
                addWellness.tracker = tracker
                self.navigationController?.pushViewController(addWellness, animated: true)
            }
        }
    }
    
    @objc private func bookNowClicked()
    {
        delegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: "addAppointmentFromHome")
    }
    
    private func pushToQuestionnaireViewController(appointment: Appointment)  {
        
        let questionnaireViewController = QuestionnairesViewController()
        questionnaireViewController.selectedAppointment = appointment
        self.navigationController?.pushViewController(questionnaireViewController, animated: true)
    }
    
    //MARK: - charmconnection handler delegate methods
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchAppoinments"
        {
            let todayAppointmentCount = dashboardModel.todayAppointmentList.count
            
            isAppointmentRequestAlreadySent = false
            let calender = Calendar(identifier: .gregorian)

            var arrayOfAppointmentForOneMonth : [Appointment] = []
            
            let jsonObjectArray : [Dictionary<String,Any>] = jsonObject["output_string"] as! [Dictionary<String,Any>]

            var count = 0
            
            for appointment in jsonObjectArray
            {
                count = count + 1
                
                let appointmentObj = ParsingHelper.fillAppointmentWithDictionary(dictionary: appointment)
                
                guard let appointmentDate = appointmentObj.appointmentDeviceStartTime else { return }
                if calender.isDateInToday(appointmentDate)
                {
                    dashboardModel.todayAppointmentList.append(appointmentObj)
                }
                else{
                    if arrayOfAppointmentForOneMonth.count != 0
                    {
                        if calender.dateComponents([.month], from: appointmentDate).month! != calender.dateComponents([.month], from: arrayOfAppointmentForOneMonth[0].appointmentDeviceStartTime ?? Date()).month!
                        {
                            dashboardModel.upComingAppointmentList.append(arrayOfAppointmentForOneMonth)
                            arrayOfAppointmentForOneMonth = []
                            arrayOfAppointmentForOneMonth.append(appointmentObj)
                        }else
                        {
                            arrayOfAppointmentForOneMonth.append(appointmentObj)
                        }
                    }else
                    {
                        arrayOfAppointmentForOneMonth.append(appointmentObj)
                    }
                }
            }
            
            if arrayOfAppointmentForOneMonth.count > 0
            {
                dashboardModel.upComingAppointmentList.append(arrayOfAppointmentForOneMonth)
            }
            
            isAppointmentFetched = true
            
            if(AppDataHandler.sharedInstance().refreshAppointments){
                AppDataHandler.sharedInstance().refreshAppointments = false
                
                upComingAppointmentSectionTotalCount = 0
                upComingAppointmentIndexTotalCount = 0
                
                if todayAppointmentCount != 0{
                    dashboardView.todayAppoinmentstableView.reloadData()
                }
                else if !dashboardModel.todayAppointmentList.isEmpty{
                    dashboardView.reloadTodayAppointmentView(todayAppointmentList: dashboardModel.todayAppointmentList)
                }
                else{
                    dashboardView.upComingAppoinmentstableView.reloadData()
                }
                hideActivityIndicator()
            }
            else{
            createSubViews()
            }
        }
        else if identificationKey == "fetchVitals"
        {
            isVitalsRequestAlreadySent = false
            dashboardModel.vitalsList = ParsingHelper.fillArrayOfVirtasWithDictionary(dictionary: jsonObject["output_string"] as! Dictionary<String,Any>)
            isVitalsFetched = true
            if(AppDataHandler.sharedInstance().refreshVitals){
                AppDataHandler.sharedInstance().refreshVitals = false
                refreshVitals()
            }
            else{
                createSubViews()
            }
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchMessages"{
            
            isMessageRequestAlreadySent = false
            isMessageFetched = true
            
            if let messageArr = (response as? MDPagiationDataResponse<Messages>)?.data {
                dashboardModel.messageList.removeAll()
                dashboardModel.messageList.append(contentsOf: messageArr.filter({ message in
                    message.messageReceipients?.status == "0"
                }))
            }
            
            if(AppDataHandler.sharedInstance().refreshMessage){
                AppDataHandler.sharedInstance().refreshMessage = false
                
                dashboardView.recentMessageTableView.reloadData()
                hideActivityIndicator()
            }
            else{
                createSubViews()
            }
        }
        else if identificationKey == "fetchQuestionnaire"{
            isQuestionnaireRequestAlreadySent = false
            isQuestionnaireFetched = true
            
            if let messageArr = response as? [PhysicianTemplates] {
                dashboardModel.allQuestionnaireList.removeAll()
                dashboardModel.questionnaireList.removeAll()
                dashboardModel.allQuestionnaireList.append(contentsOf: messageArr)
                dashboardModel.questionnaireList.append(contentsOf: messageArr.filter({physicianTemplates in
                    let patientQuesMap = physicianTemplates.patientQuesMap ?? PatientQuesMap()
                    return (patientQuesMap.appointment?.appointmentId.isNilOrBlank() ?? true) && !patientQuesMap.isSubmitted
                }))
            }
        
            if(AppDataHandler.sharedInstance().refreshQuestionnaire){
                AppDataHandler.sharedInstance().refreshQuestionnaire = false
                
                dashboardView.questionnaireTableView.reloadData()
                hideActivityIndicator()
            }
            else{
                createSubViews()
            }
        }
        else if identificationKey == "fetchInvoice"{
            isInvoiceRequestAlreadySent = false
            isInvoiceFetched = true
            
            if let invoiceArr = (response as? MDPagiationDataResponse<PHRBills>)?.data {
                dashboardModel.invoiceList.removeAll()
                dashboardModel.invoiceList.append(contentsOf: invoiceArr.filter({bill in
                    return isAmountValid(amount: bill.amount) && bill.isPaid == false && bill.billType != billTypeCreditNote
                }).sorted(by: { item1 , item2 in
                    let dateObj1 = item1.getDate()
                    let dateObj2 = item2.getDate()
                    return dateObj1 > dateObj2
                }) )
            }
            
            if(AppDataHandler.sharedInstance().refreshInvoice){
                AppDataHandler.sharedInstance().refreshInvoice = false
                
                dashboardView.activeInvoiceTableView.reloadData()
                hideActivityIndicator()
            }
            else{
                createSubViews()
            }
        }
        else if identificationKey == "fetchVitalTracker"{
            
            hideActivityIndicator()
            if let trackerArr = response as? [Tracker] {
                dashboardModel.trackerList = trackerArr
                segueToWellnessDetail()
            }
        }
        else if identificationKey == "fetchPrescritions"
        {
            isMedicationRequestAlreadySent = false
            
            if let arrayOfMedications = response as? [MedicationPOJO]{
                dashboardModel.medicationList = arrayOfMedications
            }
            
            isMedicationsFetched = true
            if(AppDataHandler.sharedInstance().refreshMedication){
                AppDataHandler.sharedInstance().refreshMedication = false
                
                
                if dashboardModel.medicationList.isEmpty{
                    hideActivityIndicator()
                    dashboardView.activeMedicationView?.isHidden = true
                }
                else{
                    dashboardView.activeMedicationView?.isHidden = false
                    showActivityIndicator()
                    dashboardView.reloadActiveMedicationsView(medicationList: dashboardModel.medicationList)
                    hideActivityIndicator()
                }
            }
            else{
                createSubViews()
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        
        if(identificationKey == "fetchAppoinments"){
            isAppointmentRequestAlreadySent = false
            showRetryAlert(error: error)
        }
        else if(identificationKey == "fetchPrescritions"){
            isMedicationRequestAlreadySent = false
            showRetryAlert(error: error)
        }
        else if identificationKey == "fetchVitals"{
            isVitalsRequestAlreadySent = false
            showRetryAlert(error: error)
        }
        else if identificationKey == "fetchMessages"{
            isMessageRequestAlreadySent = false
            showRetryAlert(error: error)
        }
        else if identificationKey == "fetchQuestionnaire"{
            isQuestionnaireRequestAlreadySent = false
            showRetryAlert(error: error)
        }
        else if identificationKey == "fetchInvoice"{
            isInvoiceRequestAlreadySent = false
            showRetryAlert(error: error)
        }
        else if identificationKey == "fetchVitalTracker"{
            hideActivityIndicator()
            var title = (error as NSError).domain
            if title.isBlank() {
                title = getString(key: "com.charmphr.dashboard.vitals.error")
            }
            
            CharmUtil.createRetryAndCancelAlertWith(title: title, msg: nil, tryAgainClicked: {
                self.fetchVitalTrackersList()
            })
        }
        else{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func showRetryAlert(error: Error){
        if !isApiErrorOccured{
            hideActivityIndicator()
            isApiErrorOccured = true
            self.showNoDataView(error: error, noDataDelegate: nil)
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
     
        if identificationKey == "downloadPhoto"
        {
            if let indexPath = indexPath{
                if let cell = dashboardView.recentMessageTableView.cellForRow(at: indexPath) as? RecentMessageTableViewCell
                {
                    if let image = UIImage(data: data)
                    {
                        let message = dashboardModel.messageList[indexPath.row]
                        message.senderImg = image
                        cell.setImage(message: message)
                    }
                }
            }
        }
        else if identificationKey == "downloadTodayProviderPhoto"{
            
            if let indexPath = indexPath{
                if let cell = dashboardView.todayAppoinmentstableView.cellForRow(at: indexPath) as? AppointmentsTableViewCell{
                    if let image = UIImage(data: data), !dashboardModel.todayAppointmentList.isEmpty{
                        dashboardModel.todayAppointmentList[indexPath.row].member?.photo = image
                        cell.appointmentListView.setProviderPhoto(image: image)
                    }
                }
            }
        }
        else if identificationKey.hasPrefix("downloadUpcomingProviderPhoto"){
            
            if let indexPath = indexPath{
                if let cell = dashboardView.upComingAppoinmentstableView.cellForRow(at: indexPath) as? AppointmentsTableViewCell{
                    if let image = UIImage(data: data), !dashboardModel.upComingAppointmentList.isEmpty{
                        dashboardModel.upComingAppointmentList[indexPath.section][indexPath.row].member?.photo = image
                        cell.appointmentListView.setProviderPhoto(image: image)
                    }
                }
            }
        }
    }
    
//MARK: - ActivityIndicator
    
    func showActivityIndicator() {
        showActivityIndicator(hideView: false)
    }
    
    func showActivityIndicator(hideView: Bool = true)
    {
        if !activityIndicator.isAnimating{
            activityIndicator.startAnimating()
        }
        self.view.bringSubviewToFront(activityIndicator)
        dashboardView.isHidden = hideView
        noDataView.hideSubView(bool: true)
        self.view.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator()
    {
        noDataView.hideSubView(bool: true)
        activityIndicator.stopAnimating()
        dashboardView.isHidden = false
        self.view.isUserInteractionEnabled = true
    }

//MARK: - Dismiss presentedVC
    
    func dismissAllModalVCPresented(){
        telehealthUtil?.dismissVideoCallVC()
        
        if let vc = cancelAppointmentVC {
            NotificationCenter.default.addObserver(self, selector: #selector(makeDelay), name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(makeDelay), name: Notification.Name("REMINDER_POP_DISMISSED"), object: nil)

            presentedVC = vc
            vc.dismiss(animated: false)
            cancelAppointmentVC = nil
        }
    }
    
    @objc private func makeDelay(){
        self.perform(#selector(presentViewController), with: nil, afterDelay: 0.35)
    }
    
    @objc private func presentViewController(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("REMINDER_POP_DISMISSED"), object: nil)
        if navigationController?.isBeingPresented != true {
            if let cancelVC = presentedVC as? CancelAppointmentViewController{
                self.cancelAppointmentVC = cancelVC
                navigationController?.present(cancelVC, animated: true)
            }
            presentedVC = nil
        }
    }
    
    //MARK: - Cancel Appointment delegate
    
    func onAppointmentCancelled(indexPath: IndexPath?) {
        if indexPath != nil {
            isAppointmentRequestAlreadySent = false
            isAppointmentFetched = false
            fetchAppointments()
        }
        self.cancelAppointmentVC = nil
    }
}

protocol VideoCallConsentFormDelegate: AnyObject {
    func onConsentFormSubmitted(patQuesMapId: String)
    func popConsentFormVC()
}
