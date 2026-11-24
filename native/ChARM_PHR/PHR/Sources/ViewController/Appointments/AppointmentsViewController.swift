//
//  AppointmentsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 02/12/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import MobileRTC

class AppointmentsViewController: CustomViewControllerWithTableView , UITableViewDataSource, CharmConnectionHandlerDelegate, CharmConnectionHandlerDataDelegate, AddViewControllerDelegate , EasyCareBookAppointmentDelegate, CancelAppointmentViewControllerDelegate, AppointmentListViewDelegate, TelehealthUtilDelegate{
    
    var appointmentSegmentControl: UISegmentedControl = UISegmentedControl(items: ["","","",""])
    
    lazy var charmConnectionHandler = CharmConnectionHandler(delegate: self)
    private var telehealthUtil: TelehealthUtil? = nil
    var arrayOfUpComingAppointment : [Appointment] = []
    var arrayOfRequestedAppointment : [Appointment] = []
    var arrayOfDeniedAppointment : [Appointment] = []
    var arrayOfWaitingListAppointment : [Appointment] = []
    
    var numberOfPracticeDataGotForUpcomingAppointment = 0
    var numberOfPracticeDataGotForRequestedAppointment = 0
    var numberOfPracticeDataGotForDeniedAppointment = 0
    var numberOfPracticeDataGotForWaitingListAppointment = 0
    
    var isUpComingAppointmentFetched = false
    var isRequestedAppointmentFetched = false
    var isDeniedAppointmentFetched = false
    var isWaitingListAppointmentFetched = false
    var touchedTableViewItemIndex: Int? = nil
    
    private var cancelAppointmentVC: CancelAppointmentViewController?
    private var presentedVC: UIViewController?

    var tableViewHeaderView = UIView()
    var tableViewFooterView = UIView()
    var pastAppointmentView : UIView!
    var upComingAppointmentLabelView: UIView!
        
    let isAddAppointment = RbacUtil.checkPrivilege(privilege: .ADD_APPOINTMENT)
    
    var tagNo = 10000
    var viewToAppointmentMap:[Int:Appointment] = [:]
    var btnToAppointmentMap:[Int:Appointment] = [:]
    
    var questionnaireList:[PhysicianTemplates]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        activityIndicatorView.startAnimating()
        
        charmConnectionHandler.dataDelegate = self
        
        self.titleCustomView.addSubview(appointmentSegmentControl)
        
        appointmentSegmentControl.selectedSegmentIndex = 0
        appointmentSegmentControl.addTarget(self, action: #selector(appointmentSegmentValueChanged(_:)), for: .valueChanged)
        appointmentSegmentControl.addProperties(fontSize: FONT_SIZE_SMALL)
        
        appointmentSegmentControl.setTitle(getString(key: "com.charmphr.appointments.Appointments.title"), forSegmentAt: 0)
        appointmentSegmentControl.setTitle(getString(key: "com.charmphr.appointments.Requested.title"), forSegmentAt: 1)
        appointmentSegmentControl.setTitle(getString(key: "com.charmphr.appointments.Waitinglist.title"), forSegmentAt: 2)
        appointmentSegmentControl.setTitle(getString(key: "com.charmphr.appointments.Denied.title"), forSegmentAt: 3)
        
        appointmentSegmentControl.setTop(offSet: Y_SPACE)
        appointmentSegmentControl.setLeft(offSet: X_SPACE)
        appointmentSegmentControl.setRight(offSet: -X_SPACE)
        appointmentSegmentControl.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        
        changeCustomTitleViewHeight(height: HEADER_HEIGHT)
        
        customTableView.separatorColor = .clear
        customTableView.tableHeaderView = tableViewHeaderView
        customTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(AppointmentsTableViewCell.self, forCellReuseIdentifier: "AppointmentsTableViewCell")
        customTableView.register(UINib(nibName: "NoUpcomingAppointmentsTableViewCell", bundle: nil), forCellReuseIdentifier: "NoUpcomingAppointmentsTableViewCell")
        customTableView.layer.masksToBounds = true
        
        customTableView.removeConstraint(attribute: .left)
        customTableView.removeConstraint(attribute: .right)
        
        customTableView.setHorizontal(offSet: X_SPACE)

        pastAppointmentView = pastAppintmentView()
        upComingAppointmentLabelView = upComingAppointmentLabel()
        
        self.navigationItem.title = getString(key: "com.charmphr.appointments.title")
        
        if canAllowAddEntry
        {
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAppointmentClicked)), animated: true)
        }
        
        loadRequest()
    }
    
    private func pastAppintmentView() -> UIView
    {
        let pastAppointmentView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 54))
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        contentView.addCornerRadius(.SMALL)
        contentView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        contentView.layer.borderWidth = BORDER_WIDTH
        pastAppointmentView.addSubview(contentView)
        
        contentView.setTop(offSet: Y_SPACE)
        contentView.setLeft(offSet: 0)
        contentView.setRight(offSet: 0)
        contentView.setBottom(offSet: 0)
        
        let label = UILabel()
        label.text = getString(key: "com.charmphr.appointments.pastappointment.title")
        label.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        label.setLeft(offSet: 10)
        label.setCenterY()
        
        let accessoryView = UIImageView()
        accessoryView.image = #imageLiteral(resourceName: "ArrowRight")
        accessoryView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(accessoryView)
        
        accessoryView.setWidth(constant: ARROW_IMAGE_VIEW_SIZE.width)
        accessoryView.setHeight(constant: ARROW_IMAGE_VIEW_SIZE.height)
        accessoryView.setRight(offSet: -10)
        accessoryView.setCenterY()
        
        let touchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pastAppointmentClicked))
        pastAppointmentView.addGestureRecognizer(touchGestureRecognizer)
        
        return pastAppointmentView
    }
    
    private func changeInTableViewHeaderView(){
        if appointmentSegmentControl.selectedSegmentIndex == 0{
            customTableView.tableHeaderView = upComingAppointmentLabelView
        }else{
            customTableView.tableHeaderView = tableViewHeaderView
        }
    }
    
    private func changeTableviewFooterView(){
        if appointmentSegmentControl.selectedSegmentIndex == 0{
            customTableView.tableFooterView = pastAppointmentView
        }else{
            customTableView.tableFooterView = tableViewFooterView
        }
    }
    
    private func upComingAppointmentLabel() -> UIView{
        
        let hearderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        
        let headerLabel = UILabel()
        headerLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        headerLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        headerLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_HEAVYDARK)
        headerLabel.text = getString(key: "com.charmphr.appointments.upcomingAppointment.title")
        headerLabel.textAlignment = .left
        
        hearderView.addSubview(headerLabel)
        headerLabel.setLeft(offSet: 5)
        headerLabel.setWidth(constant: headerLabel.sizeThatFits(CGSize(width: applicationFrame.width, height: 200)).width)
        headerLabel.setCenterY()
        
        return hearderView
    }
    
    //MARK: - action calls
    
    @objc private func onUIRefreshChange(){
        hideSwipeActionButtons()
        if appointmentSegmentControl.selectedSegmentIndex == 0{
            isUpComingAppointmentFetched = false
            fetchUpComingAppointment()
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 1{
            isRequestedAppointmentFetched = false
            fetchRequestedAppointment()
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 2{
            isWaitingListAppointmentFetched = false
            fetchWaitingListAppointment()
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 3{
            isDeniedAppointmentFetched = false
            fetchDeniedAppointment()
        }
    }
    
    @objc private func appointmentSegmentValueChanged(_ sender: UISegmentedControl) {
        hideSwipeActionButtons()
        loadRequest()
    }
    
    private func refetchAppointments(){
        isUpComingAppointmentFetched = false
        isRequestedAppointmentFetched = false
        isWaitingListAppointmentFetched = false
        isDeniedAppointmentFetched = false
        loadRequest()
    }
    
    private func refetchUpcomingAppointments(){
        isUpComingAppointmentFetched = false
        loadRequest()
    }
    
    private func loadRequest()
    {
        changeInTableViewHeaderView()
        changeTableviewFooterView()
        
        if appointmentSegmentControl.selectedSegmentIndex == 0
        {
            //TODO: need to properly change this -> did a hack by removing border as of now
            if isUpComingAppointmentFetched
            {
                reloadTableViewAndScrollToTop()
            }else
            {
                
                fetchUpComingAppointment()
            }
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 1
        {
            self.customTableView.tableFooterView = UIView()
            if isRequestedAppointmentFetched
            {
                reloadTableViewAndScrollToTop()
            }else
            {
                fetchRequestedAppointment()
            }
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 2
        {
            self.customTableView.tableFooterView = UIView()
            if isWaitingListAppointmentFetched
            {
                reloadTableViewAndScrollToTop()
            }else
            {
                fetchWaitingListAppointment()
            }
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 3
        {
            self.customTableView.tableFooterView = UIView()
            if isDeniedAppointmentFetched
            {
                reloadTableViewAndScrollToTop()
            }else
            {
                fetchDeniedAppointment()
            }
        }
    }
    
    private func reloadTableViewAndScrollToTop()
    {
        if !customTableView.isHidden == false
        {
            hideActivityIndicator()
        }
        customTableView.reloadData()
        
        if appointmentSegmentControl.selectedSegmentIndex == 0{
            if !arrayOfUpComingAppointment.isEmpty{
                //                customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 1{
            if !arrayOfRequestedAppointment.isEmpty{
                customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 2{
            if !arrayOfWaitingListAppointment.isEmpty{
                customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 3{
            if !arrayOfDeniedAppointment.isEmpty{
                customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    @objc private func addAppointmentClicked()
    {
        
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
        // performSegue(withIdentifier: "addAppointmentVC", sender: self)
    }
    
    @objc private func pastAppointmentClicked()
    {
        pushPastAppointment()
    }
    
    private func pushPastAppointment(){
        let pastAppointmentVC = PastAppointmentViewController()
        pastAppointmentVC.delegate = self
        self.navigationController?.pushViewController(pastAppointmentVC, animated: true)
    }
    
    private func deleteAppointment(at indexPath : IndexPath)
    {
        if appointmentSegmentControl.selectedSegmentIndex == 1
        {
            let appointment = arrayOfRequestedAppointment[indexPath.row]
            showActivityIndicator()
            charmConnectionHandler.deleteAppointment(id: appointment.requestId, practiceId: appointment.practiceId, identificationKey: "deleteRequestedAppointment_\(indexPath.row)")
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 2
        {
            let appointment = arrayOfWaitingListAppointment[indexPath.row]
            showActivityIndicator()
            charmConnectionHandler.deleteWaitlistAppointment(id: appointment.requestId, practiceId: appointment.practiceId ?? "", identificationKey: "deleteWaitlistAppointment_\(indexPath.row)")
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 3
        {
            let appointment = arrayOfDeniedAppointment[indexPath.row]
            showActivityIndicator()
            charmConnectionHandler.deleteAppointment(id: appointment.requestId, practiceId: appointment.practiceId, identificationKey: "deleteDeniedAppointment_\(indexPath.row)")
        }
    }
    
    private func checkAndPresentCancelAppointment(at indexPath: IndexPath,appointment : Appointment){
        
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
    
    //MARK: - request initialisation methods
    
    private func fetchUpComingAppointment(){
        numberOfPracticeDataGotForUpcomingAppointment = 0
        if refreshControl.isRefreshing != true{
            showActivityIndicatorWithHideView()
            noDataBackGroundView.isHidden = true
        }
        arrayOfUpComingAppointment = []
        if isCustomApp()
        {
            for practice in Patient.selectedPatientInstance!.practiceList
            {
                charmConnectionHandler.fetchAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: practice.practiceId ?? "", identificationKey: "fetchUpComingAppointment")
            }
        }else
        {
            charmConnectionHandler.fetchAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: "", identificationKey: "fetchUpComingAppointment")
        }
    }
    
    private func fetchRequestedAppointment(){
        numberOfPracticeDataGotForRequestedAppointment = 0
        arrayOfRequestedAppointment = []
        if refreshControl.isRefreshing != true{
            showActivityIndicatorWithHideView()
        }
        if isCustomApp()
        {
            for practice in Patient.selectedPatientInstance!.practiceList
            {
                charmConnectionHandler.fetchRequestedAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: practice.practiceId ?? "", identificationKey: "fetchRequestedAppointment")
            }
        }else
        {
            charmConnectionHandler.fetchRequestedAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: "", identificationKey: "fetchRequestedAppointment")
        }
    }
    
    private func fetchWaitingListAppointment(){
        numberOfPracticeDataGotForWaitingListAppointment = 0
        arrayOfWaitingListAppointment = []
        if refreshControl.isRefreshing != true{
            showActivityIndicatorWithHideView()
        }
        if isCustomApp()
        {
            for practice in Patient.selectedPatientInstance!.practiceList
            {
                charmConnectionHandler.fetchWaitlistAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: practice.practiceId ?? "", identificationKey: "fetchWaitingListAppointment")
            }
        }else
        {
            charmConnectionHandler.fetchWaitlistAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: "", identificationKey: "fetchWaitingListAppointment")
        }
    }
    
    private func fetchDeniedAppointment(){
        numberOfPracticeDataGotForDeniedAppointment = 0
        arrayOfDeniedAppointment = []
        if refreshControl.isRefreshing != true{
            showActivityIndicatorWithHideView()
        }
        if isCustomApp()
        {
            for practice in Patient.selectedPatientInstance!.practiceList
            {
                charmConnectionHandler.fetchDeniedAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: practice.practiceId ?? "", identificationKey: "fetchDeniedAppointment")
            }
        }else
        {
            charmConnectionHandler.fetchDeniedAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: "", identificationKey: "fetchDeniedAppointment")
        }
    }
    
    private func pushToQuestionnaireViewController(appointment: Appointment)  {
        
        let questionnaireViewController = QuestionnairesViewController()
        questionnaireViewController.selectedAppointment = appointment
        questionnaireViewController.selectedIndex = 0
        self.navigationController?.pushViewController(questionnaireViewController, animated: true)
    }
    
    //MARK: - customTableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if appointmentSegmentControl.selectedSegmentIndex == 0 && isUpComingAppointmentFetched
        {
            bottomImageView.image = #imageLiteral(resourceName: "Appointment_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
            return arrayOfUpComingAppointment.isEmpty ? 1 : arrayOfUpComingAppointment.count
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 1 && isRequestedAppointmentFetched
        {
            if arrayOfRequestedAppointment.isEmpty
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .appointment, title: getString(key: "com.charmphr.norequestedAppointments.title"), message: nil)
            }
            else
            {
                bottomImageView.image = #imageLiteral(resourceName: "Appointment_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfRequestedAppointment.count
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 2 && isWaitingListAppointmentFetched
        {
            if arrayOfWaitingListAppointment.isEmpty
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .appointment, title: getString(key: "com.charmphr.nowaitlistAppointments.title"), message: nil)
            }
            else
            {
                bottomImageView.image = #imageLiteral(resourceName: "Appointment_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfWaitingListAppointment.count
        }
        else if appointmentSegmentControl.selectedSegmentIndex == 3 && isDeniedAppointmentFetched
        {
            if arrayOfDeniedAppointment.isEmpty
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .appointment, title: getString(key: "com.charmphr.nodeniedAppointments.title"), message: nil)
            }
            else
            {
                bottomImageView.image = #imageLiteral(resourceName: "Appointment_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfDeniedAppointment.count
        }
        else{
            bottomImageView.image = nil
            self.noDataBackGroundView.hideSubView(bool: true)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        if let customTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AppointmentsTableViewCell") as? AppointmentsTableViewCell{
            customTableViewCell.selectionStyle = .none
            customTableViewCell.appointmentListView.addShadowAndCornerRadius(.MEDIUM)
            
            if appointmentSegmentControl.selectedSegmentIndex == 0 && isUpComingAppointmentFetched
            {
                if arrayOfUpComingAppointment.isEmpty
                {
                    if let noUpcomingAppointmentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoUpcomingAppointmentsTableViewCell") as? NoUpcomingAppointmentsTableViewCell{
                        noUpcomingAppointmentTableViewCell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addAppointmentClicked)))
                        
                        noUpcomingAppointmentTableViewCell.tryAgainBtn.addTarget(self, action: #selector(addAppointmentClicked) , for: .touchUpInside)
                        
                        noUpcomingAppointmentTableViewCell.selectionStyle = .none
                        return noUpcomingAppointmentTableViewCell
                    }
                }
                else{
                    let appointment = arrayOfUpComingAppointment[indexPath.row]
                    customTableViewCell.setTableViewCell(appointment: appointment, segmentIndex: 0, delegate: self)
                    
                    if let member = appointment.member, isUpComingAppointmentFetched, appointmentSegmentControl.selectedSegmentIndex == 0, member.photo == nil{
                        charmConnectionHandler.downloadProviderPhoto(provider: member, indexPath: indexPath, identificationKey: "downloadUpcomingProviderPhoto")
                    }
                }
            }
            else if appointmentSegmentControl.selectedSegmentIndex == 1 && isRequestedAppointmentFetched
            {
                if arrayOfRequestedAppointment.isEmpty
                {
                    return noAppointmentTableViewCell()
                }
                else{
                    let appointment = arrayOfRequestedAppointment[indexPath.row]
                    customTableViewCell.setTableViewCell(appointment: appointment, segmentIndex: 1, delegate: self)
                    if let member = appointment.member, isRequestedAppointmentFetched, appointmentSegmentControl.selectedSegmentIndex == 1, member.photo == nil{
                        charmConnectionHandler.downloadProviderPhoto(provider: member, indexPath: indexPath, identificationKey: "downloadRequestedProviderPhoto")
                    }
                }
            }
            else if appointmentSegmentControl.selectedSegmentIndex == 2 && isWaitingListAppointmentFetched
            {
                if arrayOfWaitingListAppointment.isEmpty
                {
                    return noAppointmentTableViewCell()
                }
                else{
                    let appointment = arrayOfWaitingListAppointment[indexPath.row]
                    customTableViewCell.setTableViewCell(appointment: appointment, segmentIndex: 2, delegate: self)
                    if let member = appointment.member, isWaitingListAppointmentFetched, member.photo == nil, appointmentSegmentControl.selectedSegmentIndex == 2{
                        charmConnectionHandler.downloadProviderPhoto(provider: member, indexPath: indexPath, identificationKey: "downloadWaitlistProviderPhoto")
                    }
                }
            }
            else if appointmentSegmentControl.selectedSegmentIndex == 3 && isDeniedAppointmentFetched
            {
                if arrayOfDeniedAppointment.isEmpty
                {
                    return noAppointmentTableViewCell()
                }
                else{
                    let appointment = arrayOfDeniedAppointment[indexPath.row]
                    customTableViewCell.setTableViewCell(appointment: appointment, segmentIndex: 3, delegate: self)
                    if let member = appointment.member, isDeniedAppointmentFetched, member.photo == nil, appointmentSegmentControl.selectedSegmentIndex == 3{
                        charmConnectionHandler.downloadProviderPhoto(provider: member, indexPath: indexPath, identificationKey: "downloadDeniedProviderPhoto")
                    }
                }
            }
            if appointmentSegmentControl.selectedSegmentIndex == 0{
                includeSwipeGestures(customTableViewCell: customTableViewCell, indexPath: indexPath)
            }
            else if appointmentSegmentControl.selectedSegmentIndex == 1 || appointmentSegmentControl.selectedSegmentIndex == 2 || appointmentSegmentControl.selectedSegmentIndex == 3{
                includeSwipeGestures(customTableViewCell: customTableViewCell, indexPath: indexPath)
            }
            else{
                if let recognizerList = customTableViewCell.appointmentListView.gestureRecognizers{
                    for recognizer in recognizerList{
                        customTableViewCell.appointmentListView.removeGestureRecognizer(recognizer)
                    }
                }
            }
            
            return customTableViewCell
        }
        
        return UITableViewCell()
    }
    
    private func includeSwipeGestures(customTableViewCell: AppointmentsTableViewCell , indexPath: IndexPath){
        let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
        swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
        customTableViewCell.appointmentListView.addGestureRecognizer(swiftLeft)

        let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
        swiftRight.direction = UISwipeGestureRecognizer.Direction.right
        customTableViewCell.appointmentListView.addGestureRecognizer(swiftRight)
        

        customTableViewCell.appointmentListView.deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))

        if let touchedTableViewItemIndex = touchedTableViewItemIndex{
            if indexPath.row == touchedTableViewItemIndex{
                customTableViewCell.appointmentListView.setRowActionForSwipeLeft(duration: 0)
            }
            else{
                customTableViewCell.appointmentListView.setRowActionForSwipeRight(duration: 0)
            }
        }
    }
    
    @objc private func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        if let appointmentListView = sender.view as? AppointmentListView{
            if let tableViewCell = appointmentListView.superview?.superview as? AppointmentsTableViewCell{
                
                let index: Int = customTableView.indexPath(for: tableViewCell)?.row ?? -1
                switch sender.direction {
                case UISwipeGestureRecognizer.Direction.left:
                    var allowLeftSwipe = true
                    if let prebSelectedTVIndex = touchedTableViewItemIndex {
                        if prebSelectedTVIndex == index {
                            allowLeftSwipe = false
                        }
                        else{
                            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
                            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? AppointmentsTableViewCell {
                                prevTableViewCell.appointmentListView.setRowActionForSwipeRight(duration: 0.4)
                                touchedTableViewItemIndex = nil
                            }
                        }
                    }
                    if allowLeftSwipe{
                        touchedTableViewItemIndex = index
                        appointmentListView.setRowActionForSwipeLeft(duration: 0.4)
                    }
                case UISwipeGestureRecognizer.Direction.right:
                    if touchedTableViewItemIndex == index{
                        touchedTableViewItemIndex = nil
                        appointmentListView.setRowActionForSwipeRight(duration: 0.4)
                    }
                default:
                    break
                }
            }
        }
    }
    
    @objc private func onTouchLabel(sender: UITapGestureRecognizer){
        if let uiLabel = sender.view as? UILabel{
            
            if let appointmentListView = uiLabel.superview as? AppointmentListView{
                if let tableViewCell = appointmentListView.superview?.superview as? AppointmentsTableViewCell{
                    let indexPath: IndexPath = customTableView.indexPath(for: tableViewCell) ?? [0,0]
                    if touchedTableViewItemIndex != nil{
                        appointmentListView.setRowActionForSwipeRight(duration: 0.4)
                    }
                    touchedTableViewItemIndex = nil
                    
                    if appointmentSegmentControl.selectedSegmentIndex == 0 {
                        let appointment = arrayOfUpComingAppointment[indexPath.row]
                        if appointment.cancelOption != nil && RbacUtil.checkPrivilege(privilege: .CANCEL_APPOINTMENT){
                            self.checkAndPresentCancelAppointment(at: indexPath, appointment: appointment)
                        }
                        else{
                            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.appointments.cancel.error"))
                        }
                    }
                    else{
                        
                        
                        if RbacUtil.checkPrivilege(privilege: .CANCEL_APPOINTMENT) && appointmentSegmentControl.selectedSegmentIndex == 2{
                            CharmUtil.createYesOrNoActionWith(title: nil, msg: getString(key: "com.charmphr.appointment.alert.cancel.appointment"), yesClicked: {
                                self.deleteAppointment(at: indexPath)
                            })
                        }
                        else if appointmentSegmentControl.selectedSegmentIndex == 1 || appointmentSegmentControl.selectedSegmentIndex == 3{
                            CharmUtil.createYesOrNoActionWith(title: nil, msg: getString(key: "com.charmphr.appointment.alert.delete.appointment"), yesClicked: {
                                self.deleteAppointment(at: indexPath)
                            })
                        }
                    }
                }
            }
        }
    }
    
    private func hideSwipeActionButtons(){
        if let prebSelectedTVIndex = touchedTableViewItemIndex {
            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
            if let prevDocTableViewCell = customTableView.cellForRow(at: indexpath) as? AppointmentsTableViewCell {
                prevDocTableViewCell.appointmentListView.setRowActionForSwipeRight(duration: 0.4)
                touchedTableViewItemIndex = nil
            }
        }
    }
    
    func dismissModalViews(){
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
        
        if let cancelVC = presentedVC as? CancelAppointmentViewController{
            if navigationController?.isBeingPresented != true {
                self.cancelAppointmentVC = cancelVC
                navigationController?.present(cancelVC, animated: true)
            }
        }
        presentedVC = nil
    }
    
    private func noAppointmentTableViewCell() -> UITableViewCell
    {
        let customTableViewCell = UITableViewCell()
        customTableViewCell.textLabel?.text = getString(key: "com.charmphr.noappointments.title")
        return customTableViewCell
    }
    
    @objc private func onClickJoinBtn(btn: UIButton){
        if let appointment = btnToAppointmentMap[btn.tag]{
            activityIndicatorView.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            if telehealthUtil == nil{
                telehealthUtil = TelehealthUtil(rootVC: self, questionnaireList: questionnaireList ?? [], delegate: self, rootPopUpVC: self)
            }
            telehealthUtil?.onTapJoinBtn(appointment: appointment)
        }
    }
    
    @objc func onClickQuestionnaire(btn: UIButton){
        if let appointment = btnToAppointmentMap[btn.tag]{
            pushToQuestionnaireViewController(appointment: appointment)
        }
    }
    
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
    
    // MARK: - charmconnectionhandler
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey == "downloadUpcomingProviderPhoto"{
            if let indexPath = indexPath, appointmentSegmentControl.selectedSegmentIndex == 0 {
                if let cell =  customTableView.cellForRow(at: indexPath) as? AppointmentsTableViewCell{
                    if let image = UIImage(data: data), isUpComingAppointmentFetched{
                        arrayOfUpComingAppointment[indexPath.row].member?.photo = image
                        cell.appointmentListView.setProviderPhoto(image: image)
                    }
                }
            }
        }
        else if identificationKey == "downloadRequestedProviderPhoto"{
            
            if let indexPath = indexPath, appointmentSegmentControl.selectedSegmentIndex == 1 {
                if let cell =  customTableView.cellForRow(at: indexPath) as? AppointmentsTableViewCell{
                    if let image = UIImage(data: data), isRequestedAppointmentFetched{
                        arrayOfRequestedAppointment[indexPath.row].member?.photo = image
                        cell.appointmentListView.setProviderPhoto(image: image)
                    }
                }
            }
        }
        else if identificationKey == "downloadWaitlistProviderPhoto"{
            
            if let indexPath = indexPath, appointmentSegmentControl.selectedSegmentIndex == 2 {
                if let cell =  customTableView.cellForRow(at: indexPath) as? AppointmentsTableViewCell{
                    if let image = UIImage(data: data), isWaitingListAppointmentFetched{
                        arrayOfWaitingListAppointment[indexPath.row].member?.photo = image
                        cell.appointmentListView.setProviderPhoto(image: image)
                    }
                }
            }
        }
        else if identificationKey == "downloadDeniedProviderPhoto"{
            
            if let indexPath = indexPath, appointmentSegmentControl.selectedSegmentIndex == 3 {
                if let cell =  customTableView.cellForRow(at: indexPath) as? AppointmentsTableViewCell{
                    if let image = UIImage(data: data), isDeniedAppointmentFetched{
                        arrayOfDeniedAppointment[indexPath.row].member?.photo = image
                        cell.appointmentListView.setProviderPhoto(image: image)
                    }
                }
            }
        }
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchUpComingAppointment"
        {
            numberOfPracticeDataGotForUpcomingAppointment += 1
            for appointmentDict in  jsonObject["output_string"] as! [Dictionary<String,Any>]
            {
                arrayOfUpComingAppointment.append(ParsingHelper.fillAppointmentWithDictionary(dictionary: appointmentDict))
            }
            if (isCustomApp() && Patient.selectedPatientInstance!.practiceList.count == numberOfPracticeDataGotForUpcomingAppointment ) || (!isCustomApp())
            {
                isUpComingAppointmentFetched = true
//                    arrayOfUpComingAppointment = FilterHandler.filterAndSortAppointents(arrayOfAppointment: arrayOfUpComingAppointment)
                if appointmentSegmentControl.selectedSegmentIndex == 0{
                    hideActivityIndicator()
                    reloadTableViewAndScrollToTop()
                }
            }
        }
        else if identificationKey == "fetchRequestedAppointment"
        {
            numberOfPracticeDataGotForRequestedAppointment += 1
            for appointmentDict in  jsonObject["output_string"] as! [Dictionary<String,Any>]
            {
                arrayOfRequestedAppointment.append( ParsingHelper.fillAppointmentWithDictionary(dictionary: appointmentDict))
            }
            if (isCustomApp() && Patient.selectedPatientInstance!.practiceList.count == numberOfPracticeDataGotForRequestedAppointment ) || (!isCustomApp())
            {
                isRequestedAppointmentFetched = true
//                arrayOfRequestedAppointment = FilterHandler.filterAndSortAppointents(arrayOfAppointment: arrayOfRequestedAppointment)
                if appointmentSegmentControl.selectedSegmentIndex == 1
                {
                    hideActivityIndicator()
                    reloadTableViewAndScrollToTop()
                }
            }
        }
        else if identificationKey == "fetchDeniedAppointment"
        {
            numberOfPracticeDataGotForDeniedAppointment += 1
            for appointmentDict in  jsonObject["output_string"] as! [Dictionary<String,Any>]
            {
                arrayOfDeniedAppointment.append( ParsingHelper.fillAppointmentWithDictionary(dictionary: appointmentDict))
            }
            if (isCustomApp() && Patient.selectedPatientInstance!.practiceList.count == numberOfPracticeDataGotForDeniedAppointment ) || (!isCustomApp())
            {
                isDeniedAppointmentFetched = true
//                arrayOfDeniedAppointment = FilterHandler.filterAndSortAppointents(arrayOfAppointment: arrayOfDeniedAppointment)
                if appointmentSegmentControl.selectedSegmentIndex == 3
                {
                    hideActivityIndicator()
                    reloadTableViewAndScrollToTop()
                }
            }
        }
        else if identificationKey == "fetchWaitingListAppointment"
        {
            numberOfPracticeDataGotForWaitingListAppointment += 1
            for appointmentDict in  jsonObject["output_string"] as! [Dictionary<String,Any>]
            {
                arrayOfWaitingListAppointment.append( ParsingHelper.fillAppointmentWithDictionary(dictionary: appointmentDict))
            }
            if (isCustomApp() && Patient.selectedPatientInstance!.practiceList.count == numberOfPracticeDataGotForWaitingListAppointment ) || (!isCustomApp())
            {
                isWaitingListAppointmentFetched = true
//                arrayOfWaitingListAppointment = FilterHandler.filterAndSortAppointents(arrayOfAppointment: arrayOfWaitingListAppointment)
                if appointmentSegmentControl.selectedSegmentIndex == 2
                {
                    hideActivityIndicator()
                    reloadTableViewAndScrollToTop()
                }
            }
        }
        else if identificationKey.hasPrefix("deleteRequestedAppointment")
        {
            hideActivityIndicator()
            
            let row = Int(identificationKey.components(separatedBy: "_").last!)!
            arrayOfRequestedAppointment.remove(at: row)
            
            if appointmentSegmentControl.selectedSegmentIndex == 1
            {
                self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
            }
            if let message = jsonObject.getString("message"){
                CharmUtil.showToast(controller: self, message: message, seconds: 2)
            }
        }
        else if identificationKey.hasPrefix("deleteDeniedAppointment")
        {
            hideActivityIndicator()
            
            let row = Int(identificationKey.components(separatedBy: "_").last!)!
            arrayOfDeniedAppointment.remove(at: row)
            
            if appointmentSegmentControl.selectedSegmentIndex == 3
            {
                self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
            }
            if let message = jsonObject.getString("message"){
                CharmUtil.showToast(controller: self, message: message, seconds: 2)
            }
        }
        else if identificationKey.hasPrefix("deleteWaitlistAppointment")
        {
            hideActivityIndicator()
            
            let row = Int(identificationKey.components(separatedBy: "_").last!)!
            arrayOfWaitingListAppointment.remove(at: row)
            
            if appointmentSegmentControl.selectedSegmentIndex == 2
            {
                self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
            }
            if let message = jsonObject.getString("message"){
                CharmUtil.showToast(controller: self, message: message, seconds: 2)
            }
        }
    }
    
    override func hideActivityIndicator() {
        super.hideActivityIndicator()
    }
    
    override func showActivityIndicator(){
        showActivityIndicatorFront()
    }
    
    private func showActivityIndicatorWithHideView(){
        super.showActivityIndicator()
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "fetchUpComingAppointment" || identificationKey == "fetchPastAppointment" || identificationKey ==
            "fetchRequestedAppointment" || identificationKey == "fetchDeniedAppointment" || identificationKey == "fetchWaitingListAppointment"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }
    
    //TODO: have to check where it is called
    
    override func noDataViewRetryBtnClicked() {
        refetchAppointments()
    }
    
    func addViewControllerDataAdded(message: String?) {
        
        if let message = message {
            CharmUtil.showToast(controller: self, message: message, seconds: 2)
        }
        
        refetchAppointments()
    }
    
    //MARK: - EasyCareBookAppointment Delegate
    
    func onBookAppointmentBackPressed() {
        refetchAppointments()
        AppDataHandler.sharedInstance().refreshAppointments = true
    }
    
    //MARK: - Video Call Cancel delegate
    
    func onAppointmentCancelled(indexPath: IndexPath?) {
        if indexPath != nil {
            refetchUpcomingAppointments()
            AppDataHandler.sharedInstance().refreshAppointments = true
        }
        self.cancelAppointmentVC = nil
    }
    
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if  segue.identifier == "pastAppointmentVC" {
//            let vc = segue.destination as! PastAppointmentViewController
//            vc.appointments = arrayOfPastAppointment
//        }
//        else if segue.identifier == "addAppointmentVC"
//        {
//            let vc = segue.destination as! AddAppointmentViewController
//            vc.delegate = self
//        }
//    }
    
    
}
