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
class HomeViewController: UIViewController, CharmConnectionHandlerDelegate, HomeViewControllerNavigationDelegate, CharmConnectionHandlerDataDelegate, UITabBarControllerDelegate, DemographicsViewControllerDidChangeValueDelegate, AppDataHandlerDelegate, UIViewControllerTransitioningDelegate, AddViewControllerDelegate, EasyCareBookAppointmentDelegate, SelectValueViewControllerDelagate, NoDataViewDelegate, UIScrollViewDelegate
{
    private var customTopView = UIView()
    private let titleLabel  = UILabel()
    private var imageViewWithInitailsView = ImageViewWithInitailsView()
    private let announcementImgBtn = UIButton()
    private let announcementCountLabel = UILabel()
    
    private var charmconnectionHandler: CharmConnectionHandler?
    private var selectedSectionForNavigation : Module?
    var appDataHandler = AppDataHandler.sharedInstance()
    private var dashboardVC: DashBoardViewController? = nil
    private var sectionVC: SectionsViewController? = nil
    
    private let bottomView = UIView()
    private let dashboardBtn = UIButton()
    private let sectionBtn = UIButton()
    
    private var dashboardNormalBtnConfig: UIButton.Configuration? = nil
    private var dashboardSelectedBtnConfig: UIButton.Configuration? = nil
    private var sectionNormalBtnConfig: UIButton.Configuration? = nil
    private var sectionSelectedBtnConfig: UIButton.Configuration? = nil
    private let ADD_BTN_TAG = 9883267
    
    //MARK: - view creation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = getString(key: "com.charmphr.action.back")
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        createNavigationBar()
        setBottomView()
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

        announcementImgBtn.addTarget(self, action: #selector(pushAnnouncementViewController), for: .touchUpInside)
        announcementImgBtn.isHidden = true
        announcementCountLabel.isHidden = true
        
        self.imageViewWithInitailsView.setInitialsAndImage(initials: "\(isNilOrEmpty(string: patient.firstName) == false ? "\(patient.firstName?.first, default: "")" : "")\(isNilOrEmpty(string: patient.lastName) == false ? "\(patient.lastName.first, default: "")" : "")", image: patient.patientPhoto)
        
        dashboardVC = DashBoardViewController()
        sectionVC = SectionsViewController()
        
        dashboardVC?.dashboardView.scrollView.delegate = self
        sectionVC?.sectionsView.scrollView.delegate = self
        
        guard let dashboardVC, let sectionVC else { return }
        
        self.addChild(dashboardVC)
        self.view.addSubview(dashboardVC.view)
        dashboardVC.didMove(toParent: self)
        
        dashboardVC.view.setLeft(offSet: 0)
        dashboardVC.view.setRight(offSet: 0)
        dashboardVC.view.setTopRelatedToView(offSet: 0, relatedView: customTopView, relatedAttribute: .bottom)
        dashboardVC.view.setBottomRelatedToView(offSet: 0, relatedView: bottomView, relatedAttribute: .top)
        
        self.addChild(sectionVC)
        self.view.addSubview(sectionVC.view)
        sectionVC.didMove(toParent: self)
        
        sectionVC.view.setLeft(offSet: 0)
        sectionVC.view.setRight(offSet: 0)
        sectionVC.view.setTopRelatedToView(offSet: 0, relatedView: customTopView, relatedAttribute: .bottom)
        sectionVC.view.setBottomRelatedToView(offSet: 0, relatedView: bottomView, relatedAttribute: .top)
        
        dashboardVC.delegate = self
        sectionVC.delegate = self
        
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
        
        dashboardBtn.isSelected = false
        onClickDashboardBtn(dashboardBtn)
    }
    
    private func setBottomView(){
        self.view.addSubview(bottomView)
        bottomView.addSubview(dashboardBtn)
        bottomView.addSubview(sectionBtn)
        
        bottomView.setLeft(offSet: 0)
        bottomView.setRight(offSet: 0)
        bottomView.setBottom(offSet: 0)
        bottomView.setHeight(constant: 75)
        
        dashboardBtn.setLeft(offSet: 0)
        dashboardBtn.setWidth(constant: applicationFrame.width / 2)
        dashboardBtn.setTop(offSet: 5)
        dashboardBtn.setBottom(offSet: -10)
        
        sectionBtn.setLeftRelatedToView(offSet: 0, relatedView: dashboardBtn, relatedAttribute: .right)
        sectionBtn.setRight(offSet: 0)
        sectionBtn.setWidth(constant: applicationFrame.width / 2)
        sectionBtn.setTop(offSet: 5)
        sectionBtn.setBottom(offSet: -10)
        
        bottomView.addTopBorder(color: UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR), borderWidth: 1)
        
        dashboardBtn.addTarget(self, action: #selector(onClickDashboardBtn), for: .touchUpInside)
        sectionBtn.addTarget(self, action: #selector(onClickSectionBtn), for: .touchUpInside)
        
        setBottomBtn()
    }
    
    func setBottomBtn() {
        
        if dashboardNormalBtnConfig == nil{
            dashboardNormalBtnConfig = getBottomBtnConfig(titleKey: "com.charmphr.home.Dashboard", imgString: "DashBoard", isSelected: false)
        }
        if dashboardSelectedBtnConfig == nil{
            dashboardSelectedBtnConfig = getBottomBtnConfig(titleKey: "com.charmphr.home.Dashboard", imgString: "DashBoardColorFilled", isSelected: true)
        }
        
        if sectionNormalBtnConfig == nil{
            sectionNormalBtnConfig = getBottomBtnConfig(titleKey: "com.charmphr.home.healthData", imgString: "HealthDataOutLine", isSelected: false)
        }
        
        if sectionSelectedBtnConfig == nil{
            sectionSelectedBtnConfig = getBottomBtnConfig(titleKey: "com.charmphr.home.healthData", imgString: "HealthDataColorFilled", isSelected: true)
        }
       
        if dashboardBtn.isSelected{
            dashboardBtn.configuration = dashboardSelectedBtnConfig
        }
        else{
            dashboardBtn.configuration = dashboardNormalBtnConfig
        }
        
        if sectionBtn.isSelected{
            sectionBtn.configuration = sectionSelectedBtnConfig
        }
        else{
            sectionBtn.configuration = sectionNormalBtnConfig
        }
    }
    
    private func getBottomBtnConfig(titleKey: String, imgString: String, isSelected: Bool) -> UIButton.Configuration{
        
        let font = UIFont.systemFont(ofSize: FONT_SIZE_SMALL, Weight: .medium)
        
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = .clear
        config.image = UIImage(named: imgString)
        
        var title = AttributedString(getString(key: titleKey))
        title.font = font
        if isSelected {
            title.foregroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            config.attributedTitle = title
            
        } else {
            title.foregroundColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREY)
            config.attributedTitle = title
        }
        config.imagePlacement = .top
        config.imagePadding = 8
        config.titleAlignment = .center
        
        return config
    }
    
    @objc private func onClickDashboardBtn(_ btn: UIButton){
        if !btn.isSelected{
            if let scrollView = dashboardVC?.dashboardView.scrollView{
                scrollViewDidScroll(scrollView)
            }
            dashboardBtn.isSelected = true
            sectionBtn.isSelected = false
            setBottomBtn()
            dashboardVC?.view.isHidden = false
            sectionVC?.view.isHidden = true
        }
    }
    
    @objc private func onClickSectionBtn(_ btn: UIButton){
        if !btn.isSelected{
            if let scrollView = sectionVC?.sectionsView.scrollView{
                scrollViewDidScroll(scrollView)
            }
            sectionBtn.isSelected = true
            dashboardBtn.isSelected = false
            setBottomBtn()
            sectionVC?.view.isHidden = false
            dashboardVC?.view.isHidden = true
        }
    }
    
    private func loadAppDataHandler(){
        showActivityIndicator()
        appDataHandler.loadAllData()
    }
    
    func setTitleName(name : String)
    {
        self.titleLabel.text = name
    }
    
    func hideAddBtn(){
        if let addBtnView = self.view.viewWithTag(ADD_BTN_TAG) as? UIButton{
            addBtnView.removeFromSuperview()
        }
    }
    
    private func setAddBtn()
    {
        var addBtnView = self.view.viewWithTag(ADD_BTN_TAG) as? UIButton
        
        if addBtnView == nil
        {
            let addBtnSize: CGFloat = 56
            let addBtn = UIButton(type: .custom)
            addBtn.tag = ADD_BTN_TAG
            addBtn.setImage(#imageLiteral(resourceName: "PlusIcon"), for: .normal )
            addBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            addBtn.layer.cornerRadius = addBtnSize / 2
            addBtn.addTarget(self, action: #selector(addBtnClicked), for: .touchUpInside)
            addBtn.tintColor = .white
            addBtn.setPadding(vertical: 10, horizontal: 10)
            self.view.addSubview(addBtn)
            
            addBtn.setBottomRelatedToView(offSet: -20, relatedView: bottomView, relatedAttribute: .top)
            addBtn.setRight(offSet: -20)
            addBtn.setWidth(constant: addBtnSize)
            addBtn.setHeight(constant: addBtnSize)
            
            addBtnView = addBtn
        }
        else{
            addBtnView?.isHidden = false
        }
        
        if appDataHandler.canAllowAppointment || (appDataHandler.canAllowMessage && canAllowComposeMessage())
        {
            addBtnView?.isHidden = false
        }else
        {
            addBtnView?.isHidden = true
        }
    }
    
    private func createNavigationBar()
    {
        imageViewWithInitailsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileBtnClicked)))
        imageViewWithInitailsView.layer.cornerRadius = 20
        imageViewWithInitailsView.layer.masksToBounds = true
        imageViewWithInitailsView.isUserInteractionEnabled = true
        customTopView.addSubview(imageViewWithInitailsView)
        
        titleLabel.font = .systemFont(ofSize: 34, Weight: .bold)
        customTopView.addSubview(titleLabel)
        announcementImgBtn.setImage(UIImage(named: "Announcement"), for: .normal)
        announcementImgBtn.backgroundColor = .white
        announcementImgBtn.addShadow()
        announcementImgBtn.layer.cornerRadius = 40/2
        
        customTopView.addSubview(announcementImgBtn)
        
        titleLabel.setSafeAreaTop(offset: 10)
        titleLabel.setBottom(offSet: -12)
        titleLabel.setLeft(offSet: X_SPACE)
        titleLabel.setRightRelatedToView(offSet: -X_SPACE, relatedView: announcementImgBtn, relatedAttribute: .left)
        
        let countLabelSize: CGFloat = 23
        announcementCountLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: RED_BG_COLOR)
        announcementCountLabel.text = ""
        announcementCountLabel.textColor = .white
        announcementCountLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .bold)
        announcementCountLabel.textAlignment = .center
        announcementCountLabel.layer.cornerRadius = countLabelSize/2
        announcementCountLabel.layer.masksToBounds = true
        
        customTopView.addSubview(announcementCountLabel)
        announcementCountLabel.isHidden = true
        
        announcementCountLabel.setHeight(constant: countLabelSize)
        announcementCountLabel.setWidth(constant: countLabelSize)
        announcementCountLabel.setSafeAreaTop(offset: 10)
        announcementCountLabel.setRightRelatedToView(offSet: -(10), relatedView: imageViewWithInitailsView, relatedAttribute: .left)
        
        announcementImgBtn.setHeight(constant: 40)
        announcementImgBtn.setWidth(constant: 40)
        announcementImgBtn.setSafeAreaTop(offset: 15)
        announcementImgBtn.setRightRelatedToView(offSet: -(X_SPACE), relatedView: imageViewWithInitailsView, relatedAttribute: .left)
        
        imageViewWithInitailsView.setHeight(constant: 40)
        imageViewWithInitailsView.setWidth(constant: 40)
        imageViewWithInitailsView.setBottom(offSet: -14)
        imageViewWithInitailsView.setSafeAreaTop(offset: 14)
        imageViewWithInitailsView.setRight(offSet: -X_SPACE)
        
        customTopView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_GRAY_BG_COLOR)
        self.view.addSubview(customTopView)
        
        customTopView.setTop(offSet: 0)
        customTopView.setRight(offSet: 0)
        customTopView.setLeft(offSet: 0)
        customTopView.addBottomBorder()
    }
    
    //MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        let isNearBottom = offsetY >= (contentHeight - frameHeight - 20)

        if let addBtn = self.view.viewWithTag(ADD_BTN_TAG) as? UIButton{
            UIView.animate(withDuration: 0.3) {
                addBtn.alpha = isNearBottom ? 0 : 1
                addBtn.transform = isNearBottom ? CGAffineTransform(scaleX: 0.8, y: 0.8) : .identity
            }
            addBtn.isUserInteractionEnabled = !isNearBottom
        }
    }
    
    //MARK: - chanmconnection handler delegate methods
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey == "downloadPhoto"{
            if let image = UIImage(data: data){
                Patient.selectedPatientInstance?.patientPhoto = image
                imageViewWithInitailsView.setImage(image: image)
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    //MARK: - other methods
    
    @objc private func pushAnnouncementViewController(){
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
    
    @objc private func addBtnClicked(_ btn: UIButton)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addAppointmentAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.home.Add.appointment"), style: .default) { (uialertaction) in
            self.pushBookAppointentViewController()
        }
        
        let composeMsgAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.home.composeMsg.appointment"), style: .default) { (uialertaction) in
            
            let arrayOfMessageRestriction = self.appDataHandler.arrayOfMessageRestriction.filter { (messageRestriction) -> Bool in
                if (messageRestriction.isMessageRestrict == false && messageRestriction.allowMessaging == true)
                {
                    return true
                }
                return false
            }
            if(arrayOfMessageRestriction.count > 0){
                self.pushComposeMessgaeVC()
            }
            else{
                let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.message.alert.MessageRestrict.message"), preferredStyle: .alert)
                let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: nil)
                alertVC.addAction(okAction)
                alertVC.show()
            }
        }
        
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: nil)
        
        if appDataHandler.canAllowAppointment
        {
            alertController.addAction(addAppointmentAction)
        }
        if appDataHandler.canAllowMessage && canAllowComposeMessage()
        {
            alertController.addAction(composeMsgAction)
        }
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = btn
            popover.permittedArrowDirections = .down
        }
        alertController.show()
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
    
    @objc private func profileBtnClicked()
    {
        performSegue(withIdentifier: "ProflieVC", sender: self)
    }
    
    private func finishLoading()
    {
        hideActivityIndicator()
        if AppDataHandler.didReceivedAllData(){
            if appDataHandler.canAllowAnnouncement{
                announcementImgBtn.isHidden = false
                announcementCountLabel.isHidden = false
                if appDataHandler.announcemnetUnreadCount > 0 {
                    announcementCountLabel.text = "\(appDataHandler.announcemnetUnreadCount)"
                    announcementCountLabel.isHidden = false
                }
                else{
                    announcementCountLabel.isHidden = true
                }
            }
            else{
                announcementImgBtn.isHidden = true
                announcementCountLabel.isHidden = true
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
            profileVC.demographicsValueChangedDelegate = self
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
        
        if appDataHandler.announcemnetUnreadCount > 0 {
            announcementCountLabel.text = "\(appDataHandler.announcemnetUnreadCount)"
            announcementCountLabel.isHidden = false
        }
        else{
            announcementCountLabel.isHidden = true
        }
        
        sectionVC?.reloadData()
    }
    
    func demographicsViewControllerDidChangePatientPhoto(photo: UIImage) {
        Patient.selectedPatientInstance?.patientPhoto = photo
        imageViewWithInitailsView.setImage(image: photo)
    }
    
    func demographicsViewControllerDidChangeName() {
        setTitleName(name: "Hi \(Patient.selectedPatientInstance?.firstName ?? "")")
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
        
        if dashboardBtn.isSelected{
            dashboardVC?.refreshDashboardData()
        }
        else{
            onClickDashboardBtn(dashboardBtn)
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
