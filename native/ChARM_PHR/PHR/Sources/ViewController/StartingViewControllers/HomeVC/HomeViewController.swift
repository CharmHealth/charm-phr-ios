//
//  HomeViewController.swift
//  ChARM Phr
//
//  Created by Sankar Saravanan on 03/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import UIKit
import SwiftUI
// TODO(Apptics): disabled until verified; re-enable later
//import Apptics
//import AppticsInAppUpdate

//this methods is used to push a VC with the help of segue using storyboard
//it will be used for only the VC in homeViewController
protocol HomeViewControllerNavigationDelegate: AnyObject {
    func homeViewControllerNavigationPushViewController(selectedSection : Module? ,identifier: String)
}

// this is tabbarVC there will be many VC in this tabController
class HomeViewController: UITabBarController, CharmConnectionHandlerDelegate, HomeViewControllerNavigationDelegate, CharmConnectionHandlerDataDelegate, UITabBarControllerDelegate, AppDataHandlerDelegate, UIViewControllerTransitioningDelegate, AddViewControllerDelegate, EasyCareBookAppointmentDelegate, SelectValueViewControllerDelagate, NoDataViewDelegate
{
    private var charmconnectionHandler: CharmConnectionHandler?
    private var selectedSectionForNavigation : Module?
    var appDataHandler = AppDataHandler.sharedInstance()
    private var dashboardVC: DashBoardViewController? = nil
    private var sectionVC: SectionsViewController? = nil

    //MARK: - view creation

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = getString(key: "com.charmphr.action.back")
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        loadSubView()

        NotificationHandler.presentNotification()
        // TODO(Apptics): disabled until verified; re-enable later
//        APAppUpdateManager.check(forUpdateAvailability: nil, with: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if AppDataHandler.didReceivedAllData()
        {
            appDataHandler.fetchUnReadCount()
        }
    }
    
    func loadSubView(){
        
        guard let patient = Patient.selectedPatientInstance else { return }

        let mainVC = parent as? MainViewController
        mainVC?.announcementImgBtn.addTarget(self, action: #selector(pushAnnouncementViewController), for: .touchUpInside)
        mainVC?.announcementImgBtn.isHidden = true
        mainVC?.announcementCountLabel.isHidden = true

        mainVC?.imageViewWithInitailsView.setInitialsAndImage(initials: "\(isNilOrEmpty(string: patient.firstName) == false ? "\(patient.firstName?.first, default: "")" : "")\(isNilOrEmpty(string: patient.lastName) == false ? "\(patient.lastName.first, default: "")" : "")", image: patient.patientPhoto)

        dashboardVC = DashBoardViewController()
        sectionVC = SectionsViewController()

        guard let dashboardVC, let sectionVC else { return }

        dashboardVC.delegate = self
        sectionVC.delegate = self

        setupTabs(dashboardVC: dashboardVC, sectionVC: sectionVC)

        if charmconnectionHandler == nil{
            charmconnectionHandler = CharmConnectionHandler(delegate: self)
        }
        
        if patient.isPhotoAvailable && patient.patientPhoto == nil
        {
            charmconnectionHandler?.dataDelegate = self
            charmconnectionHandler?.downloadPatientPhoto(patientId: patient.patientId, indexpath: nil, identificationKey: "downloadPhoto")
        }
        appDataHandler.delegate = self
        loadAppDataHandler()
    }
    
    private func setupTabs(dashboardVC: DashBoardViewController, sectionVC: SectionsViewController){
        if #available(iOS 18.0, *) {
            setupNativeTabs(dashboardVC: dashboardVC, sectionVC: sectionVC)
        } else {
            setupLegacyTabs(dashboardVC: dashboardVC, sectionVC: sectionVC)
        }
    }

    @available(iOS 18.0, *)
    private func setupNativeTabs(dashboardVC: DashBoardViewController, sectionVC: SectionsViewController){
        let dashboardTab = UITab(title: getString(key: "com.charmphr.home.Dashboard"), image: UIImage(named: "DashBoard")?.withRenderingMode(.alwaysTemplate), identifier: "dashboard") { _ in dashboardVC }
        let healthTab = UITab(title: getString(key: "com.charmphr.home.healthData"), image: UIImage(named: "HealthDataOutLine")?.withRenderingMode(.alwaysTemplate), identifier: "myhealth") { _ in sectionVC }

        self.tabs = [dashboardTab, healthTab]
        self.selectedTab = dashboardTab
        self.tabBar.tintColor = .systemBlue

        if #available(iOS 27.0, *) {
            self.delegate = self
        }
    }

    @available(iOS 27.0, *)
    private func makeAddTab() -> UITab {
        return UITab(title: getString(key: "com.charmphr.action.add"), image: UIImage(systemName: "plus"), identifier: "add") { _ in UIViewController() }
    }

    @available(iOS 18.0, *)
    func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
        if #available(iOS 27.0, *), tab.identifier == "add" {
            presentQuickAddSheet()
            return false
        }
        return true
    }

    @available(iOS 27.0, *)
    private func updateNativeAddTab(isVisible: Bool){
        let hasAddTab = self.tabs.contains { $0.identifier == "add" }
        if isVisible && !hasAddTab {
            self.tabs.append(makeAddTab())
            self.prominentTabIdentifier = "add"
        } else if !isVisible && hasAddTab {
            self.tabs.removeAll { $0.identifier == "add" }
            self.prominentTabIdentifier = nil
        }
    }

    private func setupLegacyTabs(dashboardVC: DashBoardViewController, sectionVC: SectionsViewController){
        dashboardVC.tabBarItem = UITabBarItem(title: getString(key: "com.charmphr.home.Dashboard"), image: UIImage(named: "DashBoard")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "DashBoardColorFilled")?.withRenderingMode(.alwaysOriginal))
        sectionVC.tabBarItem = UITabBarItem(title: getString(key: "com.charmphr.home.healthData"), image: UIImage(named: "HealthDataOutLine")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "HealthDataColorFilled")?.withRenderingMode(.alwaysOriginal))

        self.viewControllers = [dashboardVC, sectionVC]
        self.selectedViewController = dashboardVC
        self.tabBar.tintColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
    }

    private func loadAppDataHandler(){
        showActivityIndicator()
        appDataHandler.loadAllData()
    }
    
    private func setAddBtn()
    {
        let canShowAdd = appDataHandler.canAllowAppointment || (appDataHandler.canAllowMessage && canAllowComposeMessage())

        if #available(iOS 27.0, *) {
            updateNativeAddTab(isVisible: canShowAdd)
        } else {
            guard let mainVC = parent as? MainViewController else { return }
            mainVC.setAddButtonHidden(!canShowAdd)
        }
    }

    //MARK: - chanmconnection handler delegate methods

    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
    }

    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey == "downloadPhoto"{
            if let image = UIImage(data: data){
                Patient.selectedPatientInstance?.patientPhoto = image
                (parent as? MainViewController)?.imageViewWithInitailsView.setImage(image: image)
            }
        }
    }

    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
    }

    //MARK: - other methods

    @objc func pushAnnouncementViewController(){
        performSegue(withIdentifier: "AnnouncementList", sender: self)
    }
    
    private func pushWellnessViewController()
    {
        let wellnessVC = WellnessViewController()
        self.navigationController?.pushViewController(wellnessVC, animated: true)
    }
    //TODO:raghul
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
    
    // iOS 26 and below: triggered by MainViewController's floating Add button (target-action).
    @objc func addBtnClicked(_ sender: UIButton) {
        presentQuickAddSheet()
    }

    private func makeQuickAddOptions() -> [QuickAddOption] {
        var options: [QuickAddOption] = []

        if appDataHandler.canAllowAppointment
        {
            options.append(QuickAddOption(title: getString(key: "com.charmphr.home.Add.appointment"),
                                          image: UIImage(systemName: "calendar.badge.plus")) { [weak self] in
                self?.pushBookAppointentViewController()
            })
        }

        if appDataHandler.canAllowMessage && canAllowComposeMessage()
        {
            options.append(QuickAddOption(title: getString(key: "com.charmphr.home.composeMsg.appointment"),
                                          image: UIImage(systemName: "square.and.pencil")) { [weak self] in
                self?.composeMessageTapped()
            })
        }

        return options
    }

    private func presentQuickAddSheet(){
        let options = makeQuickAddOptions()
        guard !options.isEmpty else { return }

        let sheetVC = QuickAddSheetViewController(options: options)
        present(sheetVC, animated: true)
    }

    private func composeMessageTapped(){
        let arrayOfMessageRestriction = appDataHandler.arrayOfMessageRestriction.filter { (messageRestriction) -> Bool in
            if (messageRestriction.isMessageRestrict == false && messageRestriction.allowMessaging == true)
            {
                return true
            }
            return false
        }
        if(arrayOfMessageRestriction.count > 0){
            pushComposeMessgaeVC()
        }
        else{
            let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.message.alert.MessageRestrict.message"), preferredStyle: .alert)
            let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: nil)
            alertVC.addAction(okAction)
            alertVC.show()
        }
    }

    private func canAllowComposeMessage() -> Bool
    {
        var canAllow = false
        for messageRestriction in appDataHandler.arrayOfMessageRestriction
        {
            if messageRestriction.allowMessaging
            {
                canAllow = messageRestriction.allowMessaging
            }
        }
        return canAllow
    }
    
    @objc func profileBtnClicked()
    {
        performSegue(withIdentifier: "ProflieVC", sender: self)
    }

    private func finishLoading()
    {
        hideActivityIndicator()
        if AppDataHandler.didReceivedAllData(){
            let mainVC = parent as? MainViewController
            if appDataHandler.canAllowAnnouncement{
                mainVC?.announcementImgBtn.isHidden = false
                mainVC?.announcementCountLabel.isHidden = false
                if appDataHandler.announcemnetUnreadCount > 0 {
                    mainVC?.announcementCountLabel.text = "\(appDataHandler.announcemnetUnreadCount)"
                    mainVC?.announcementCountLabel.isHidden = false
                }
                else{
                    mainVC?.announcementCountLabel.isHidden = true
                }
            }
            else{
                mainVC?.announcementImgBtn.isHidden = true
                mainVC?.announcementCountLabel.isHidden = true
            }

            sectionVC?.reloadData()
            dashboardVC?.appointmentSection = AppDataHandler.findSectionWithName(string: getString(key: "com.charmphr.home.listView.Appointments"))
            dashboardVC?.fetchDashboardData()
            
            
            setAddBtn()
        }
    }
    
    private func showActivityIndicator(){
        dashboardVC?.showActivityIndicator()
        sectionVC?.showActivityIndicator()
    }
    
    private func hideActivityIndicator(){
        dashboardVC?.hideActivityIndicator()
        sectionVC?.hideActivityIndicator()
    }
    
    func homeViewControllerNavigationPushViewController(selectedSection : Module? ,identifier: String) {
        selectedSectionForNavigation = selectedSection
        if selectedSection?.moduleId == aboutModelId
        {
            let aboutVC = AboutViewController()
            self.navigationController?.pushViewController(aboutVC, animated: true)
        }
        else if identifier == announcementModelId
        {
            let announcementVC = AnnouncementViewController()
            self.navigationController?.pushViewController(announcementVC, animated: true)
        }
        else if selectedSection?.moduleId == usefulInfoModelId
        {
            let usefulInfoVC = UsefulInfoViewController()
            self.navigationController?.pushViewController(usefulInfoVC, animated: true)
        }
        else if selectedSection?.moduleId == documentModelId
        {
            let documentsVC = DocumentsFolderViewController()
            self.navigationController?.pushViewController(documentsVC, animated: true)
        }
        else if selectedSection?.moduleId == questionnaireModelId || identifier == questionnaireModelId
        {
            let questionnaireVC = QuestionnairesViewController()
            self.navigationController?.pushViewController(questionnaireVC, animated: true)
        }
        else if selectedSection?.moduleId == flowsheetModelId
        {
            let flowsheetVC = FlowsheetListViewController()
            self.navigationController?.pushViewController(flowsheetVC, animated: true)
        }
        else if selectedSection?.moduleId == problemListModelId
        {
            let medicalConditionVC = MedicalConditionsViewController()
            medicalConditionVC.canAllowAddEntry = getModule(moduleId: selectedSection?.moduleId ?? "")?.allowPhrEntry ?? true
            self.navigationController?.pushViewController(medicalConditionVC, animated: true)
        }
        else if selectedSection?.moduleId == reminderModelId{
            let reminderVC = ReminderViewController()
            self.navigationController?.pushViewController(reminderVC, animated: true)
        }
        else if selectedSection?.moduleId == imagesModelId{
            let imagesVC = ImagesViewController()
            self.navigationController?.pushViewController(imagesVC, animated: true)
        }

        else if selectedSection?.moduleId == healthPassportModelId {
            let hpVC = HealthPassportHomeViewController()
            self.navigationController?.pushViewController(hpVC, animated: true)
        }
        else if selectedSection?.moduleId == cardOnFileModelId {
            checkAndIntentToPracticeListPage()
        }
        else if  selectedSection?.moduleId == wellnessModelId
        {
            pushWellnessViewController()
        }
        else if selectedSection?.moduleId == shareSectionModelId{
            let shareSectionVC = ShareSectionViewController()
            self.navigationController?.pushViewController(shareSectionVC, animated: true)
        }
        else
        {
            if  selectedSection?.moduleId == labModelId
            {
                self.performSegue(withIdentifier: "LabsVC", sender: self)
            }
            else if  selectedSection?.moduleId == billingModelId || selectedSection?.moduleId == invoiceModelId || selectedSection?.moduleId == receiptModelId
            {
                self.performSegue(withIdentifier: "BillingVC", sender: self)
            }
            else if  selectedSection?.moduleId == messageModuleId
            {
                self.performSegue(withIdentifier: "MessagesVC", sender: self)
            }
            else if  selectedSection?.moduleId == allergiesModelId
            {
                self.performSegue(withIdentifier: "AllergiesVC", sender: self)
            }
            else if  selectedSection?.moduleId == prescriptionModelId
            {
                self.performSegue(withIdentifier: "PrescriptionsVC", sender: self)
            }
            else if  selectedSection?.moduleId == visitSummaryModelId
            {
                self.performSegue(withIdentifier: "VisitSummaryVC", sender: self)
            }
            else if  selectedSection?.moduleId == procedureModelId
            {
                self.performSegue(withIdentifier: "ProceduresVC", sender: self)
            }
            else if  selectedSection?.moduleId == appointmentModelId
            {
                self.performSegue(withIdentifier: "AppointmentsVC", sender: self)
            }
            else if  selectedSection?.moduleId == vaccineModelId
            {
                self.performSegue(withIdentifier: "ImmunizationsVC", sender: self)
            }
            else if  selectedSection?.moduleId == insuranceModelId
            {
                let insuranceVC = InsuranceListViewController()
                self.navigationController?.pushViewController(insuranceVC, animated: true)
            }
            else if identifier == "InvoiceDetail"{
                self.performSegue(withIdentifier: "InvoiceDetail", sender: self)
            }
            else if identifier == "addAppointmentFromHome"{
                pushBookAppointentViewController()
            }
            else if identifier == "MessageDetailVC"{
                
                var messages: Messages? = nil
                messages = dashboardVC?.selectedMessage
                
                let vc = MessageDetailViewController(message: messages, delegate: self)
                vc.isInboxMessage = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                self.performSegue(withIdentifier: "\(identifier.replacingOccurrences(of: " ", with: ""))VC", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let messageVc = segue.destination as? MessagesViewController
        {
            messageVc.canAllowAddEntry = appDataHandler.canAllowMessage
            
            
            if let messageModule = appDataHandler.moduleSectionArr.first(where: { (module) -> Bool in
                return module.moduleId == messageModuleId
            }) {
                messageVc.numberOfUnreadMessage = messageModule.unreadCount
            }
            else{
                messageVc.numberOfUnreadMessage = 0
            }
            return
        }
        else if let appointmentsVC = segue.destination as? AppointmentsViewController
        {
            appointmentsVC.canAllowAddEntry = appDataHandler.canAllowAppointment
        }
        else if let billingVC = segue.destination as? BillingViewController
        {
            if selectedSectionForNavigation?.moduleId == receiptModelId{
                billingVC.selectedModule = 1
            }
            billingVC.initiateRequest()
        }
        else if let profileVC = segue.destination as? ProfileViewController
        {
            profileVC.demographicsValueChangedDelegate = parent as? MainViewController
        }
        else if let invoiceVC = segue.destination as? InvoiceViewController
        {
            invoiceVC.invoice = dashboardVC?.selectedInvoice
            invoiceVC.delegate = self
        }
        else if let customViewControllerWithTableView = segue.destination as? CustomViewControllerWithTableView
        {
            customViewControllerWithTableView.canAllowAddEntry =  getModule(moduleId: selectedSectionForNavigation?.moduleId ?? "")?.allowPhrEntry ?? true
        }
    }
    
    func showNoDataView(error: Error) {
        dashboardVC?.showNoDataView(error: error, noDataDelegate: self)
        sectionVC?.showNoDataView(error: error, noDataDelegate: self)
    }
    
    
    // MARK: - delegate methods
    
    func appDataHandlerDidReceiveData(){
        finishLoading()
    }
    
    func appDataHandlerDidReceiveError(error : Error, isShowAlert: Bool){
        if isShowAlert{
            CharmUtil.createRetryAndCancelAlertWith(error: error) { [self] in
                if AppDataHandler.didReceivedAllData(){
                    appDataHandler.fetchUnReadCount()
                }
                else{
                    showActivityIndicator()
                    self.appDataHandler.loadAllData()
                }
            }
        }
        else{
            hideActivityIndicator()
            self.showNoDataView(error: error)
        }
    }
    
    func noDataViewRetryBtnClicked() {
        loadAppDataHandler()
    }
    
    func appDataHandlerDidRefreshUnreadCount() {

        let mainVC = parent as? MainViewController
        if appDataHandler.announcemnetUnreadCount > 0 {
            mainVC?.announcementCountLabel.text = "\(appDataHandler.announcemnetUnreadCount)"
            mainVC?.announcementCountLabel.isHidden = false
        }
        else{
            mainVC?.announcementCountLabel.isHidden = true
        }

        sectionVC?.reloadData()
    }

    func addViewControllerDataAdded(message: String?) {
        if let message = message{
            CharmUtil.showToast(controller: self, message: message, seconds: 2)
        }
    }
    
    func dismissAllModalVCPresented(){
        dashboardVC?.dismissAllModalVCPresented()
    }
    
    private func pushComposeMessgaeVC(){
        let messageRestrictionList = appDataHandler.arrayOfMessageRestriction.filter { (messageRestriction) -> Bool in
            if messageRestriction.isMessageRestrict == false && messageRestriction.allowMessaging == true
            {
                return true
            }else
            {
                return false
            }
        }
        let composeMsgVc = ComposeMessageViewController(enabledMessageRestictionList: messageRestrictionList, delegate: self)
        self.navigationController?.pushViewController(composeMsgVc, animated: true)
    }
    
    private func pushBookAppointentViewController(){
        var callEasyCareURL = false
        
        let practiceList = getPHREntryEnabledPractices(moduleId: appointmentModelId)
        if practiceList.count == 1 {
            let easyTelecareURL = practiceList.firstOrNil()?.easycareURL ?? ""
            if easyTelecareURL.isNotBlank() {
                callEasyCareURL = true
                
                let bookAppointmentVC = EasyTelecareBookAppointmentWebViewController()
                bookAppointmentVC.urlString = easyTelecareURL
                bookAppointmentVC.delegate = self
                self.navigationController?.pushViewController(bookAppointmentVC, animated: true)
            }
        }
        
        if !callEasyCareURL {
            let bookAppointmentVC = BookAppointmentViewController()
            bookAppointmentVC.delegate = self
            self.navigationController?.pushViewController(bookAppointmentVC, animated: true)
        }
    }
    
    //MARK: - EasyCareBookAppointment delegate
    
    func onBookAppointmentBackPressed() {
        AppDataHandler.sharedInstance().refreshAppointments = true

        if #available(iOS 18.0, *) {
            if selectedTab?.identifier == "dashboard" {
                dashboardVC?.refreshDashboardData()
            } else {
                selectedTab = tab(forIdentifier: "dashboard")
            }
        } else {
            if selectedViewController === dashboardVC {
                dashboardVC?.refreshDashboardData()
            } else {
                selectedViewController = dashboardVC
            }
        }
    }
    
    //MARK: - Select Value delegate
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        intentToCardListView(practice: getBluefinEnabledPractices().getElement(at: selectedRow))
    }
    
    //MARK: - Card on File methods
    
    func checkAndIntentToPracticeListPage(){
        
        let bluefinEnabledPracticeList = getBluefinEnabledPractices()

        if bluefinEnabledPracticeList.count > 1 {
            
            let selectValueVC = SelectValueViewController()
            selectValueVC.title = getString(key:"com.charmphr.common.selectPractice")
            
            selectValueVC.navigationItem.largeTitleDisplayMode = .never
            selectValueVC.delegate = self
            selectValueVC.popVC = false
            selectValueVC.arrayOfValueToBeShown = bluefinEnabledPracticeList.map({practice in
                return practice.practiceName ?? ""
            })
            self.navigationController?.pushViewController(selectValueVC, animated: true)
        }
        else{
            intentToCardListView(practice: bluefinEnabledPracticeList.firstOrNil())
        }
    }
    
    private func intentToCardListView(practice:Practice? = nil){
        let supportVC = CardListViewController()
        supportVC.selectedPractice = practice
        self.navigationController?.pushViewController(supportVC, animated: true)
    }
}

protocol AddViewControllerDelegate: AnyObject {
    func addViewControllerDataAdded(message: String?)
}
