//
//  ReminderViewController.swift
//  phr
//
//  Created by prathi-13964 on 23/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ReminderViewController: CustomViewControllerWithTableView , UITableViewDataSource, AddReminderDelegate, CharmConnectionV2HandlerDelegate, SelectValueViewControllerDelagate, ReminderDetailDelegate, ReminderHistroryItemEditDelegate{
    
    private var charmConnectionHandler: CharmConnectionHandler? = nil
    
    private let filterTypeArr  = [ReminderFilterType.All, ReminderFilterType.Upcoming , ReminderFilterType.Active, ReminderFilterType.Completed]
    private var selectedFilter : ReminderFilterType = .All
    
    //varaibles to hold api data
    private var patientReminderPOJO: PatientReminderPOJO? = nil
    private var todayReminderHisoryList: [ReminderHistory] = []
    
    //varaibles for view handling
    private var todayReminderArray: [TodayReminderPOJO] = []
    private var reminderArrayToLoad: [ReminderPOJO] = []
    
    //filtered varaibles for reminderArrayToLoad
    private var upcomingReminderPOJOArray: [ReminderPOJO] = []
    private var activeReminderPOJOArray: [ReminderPOJO] = []
    private var completedReminderPOJOArray: [ReminderPOJO] = []
    private var selectedIndex: Int? = nil
        
    private var reminderSegmentControl = UISegmentedControl(items: ["",""])
    
    private var responseCount = 0
    private var isFetchReminderInProgress: Bool = false
    private var isFetchReminderSuccess: Bool = false
    private var isUpdateFrequency: Bool = false
    private var futureDateAlert: NSError? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        
        self.title = getString(key: "com.charmphr.reminder.title")
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
        
        createView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep the base class's scroll offset maths in sync with the content-driven header height.
        topViewHeight = titleCustomView.frame.height
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationHandler.requestNotificationAuthorise { [weak self] isAuthorised in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if isAuthorised{
                    fetchReminderListMedicationsAndSupplements()
                }
                else{
                    presentNotificationPermissionAlert()
                }
            }
        }
    }
   
    func presentNotificationPermissionAlert(){
        CharmUtil.createCancelAndSettingsAlertWith(title: getString(key: "com.charmphr.reminder.notification.permission.notAllowed.alert.title"), msg: getString(key: "com.charmphr.reminder.notification.permission.notAllowed.alert.message"), settingsClicked: {
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }
        }, cancelClicked: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    //MARK: - Create Views
    
    private func createView()
    {
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        
        let noteView = InformationView(infoLocalisedKey: "com.charmphr.reminder.notification.10days.info.message")
        self.titleCustomView.addSubview(noteView)
        self.titleCustomView.addSubview(reminderSegmentControl)
        
        noteView.setTop(offSet: PADDING)
        noteView.setSafeAreaLeft(offset: X_SPACE)
        noteView.setSafeAreaRight(offset: -X_SPACE)
        
        self.titleCustomView.layoutIfNeeded()
        
        reminderSegmentControl.setTitle(getString(key: "com.charmphr.reminder.segment.today.title"), forSegmentAt: 0)
        reminderSegmentControl.setTitle(getString(key: "com.charmphr.reminder.segment.all.title"), forSegmentAt: 1)
        reminderSegmentControl.addTarget(self, action: #selector(reminderSegmentControlOnClick(_:)), for: .valueChanged)
        
        reminderSegmentControl.addProperties(fontSize: FONT_SIZE_NORMAL)
        reminderSegmentControl.selectedSegmentIndex = 0
        
        reminderSegmentControl.setTopRelatedToView(offSet: SEGMENTCONTROL_CUSTOMVIEW_TOP_SPACING, relatedView: noteView, relatedAttribute: .bottom)
        reminderSegmentControl.setBottom(offSet:0)
        reminderSegmentControl.setSafeAreaLeft(offset: X_SPACE)
        reminderSegmentControl.setSafeAreaRight(offset: -X_SPACE)
        reminderSegmentControl.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        
        // No fixed height: the header is sized by its content (note top → segment bottom), so the
        // info message can wrap to more lines when the width shrinks (iPhone Duo fold, rotation, side bar).
        titleCustomView.removeConstraint(attribute: .height)


        self.customTableView.delegate = self
        self.customTableView.dataSource = self
        customTableView.separatorColor = .clear
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(ReminderTodayTableViewCell.self, forCellReuseIdentifier: "ReminderTodayTableViewCell")
        customTableView.register(ReminderAllTableViewCell.self, forCellReuseIdentifier: "ReminderAllTableViewCell")
    }
    
    //MARK: - API call
    
    private func fetchReminderListMedicationsAndSupplements(){
        isFetchReminderSuccess = false
        if !isFetchReminderInProgress{
            isFetchReminderInProgress = true
            if refreshControl.isRefreshing != true{
                showActivityIndicator()
            }
            responseCount = 0
            charmConnectionHandler?.fetchReminderWithMeta(identificationKey: "fetchReminderWithMeta", patientId: getSelectedPatientId())
            charmConnectionHandler?.fetchTodayReminderHistory(identificationKey: "fetchTodayReminderHistory")
        }
    }
    
    private func fetchReminder(){
        isFetchReminderSuccess = false
        responseCount = 0
        if refreshControl.isRefreshing != true{
            showActivityIndicator()
        }
        charmConnectionHandler?.fetchReminderList(identificationKey: "fetchReminder", patientId: getSelectedPatientId())
        charmConnectionHandler?.fetchTodayReminderHistory(identificationKey: "fetchTodayReminderHistory")
    }
    
    //MARK: - Target functions
    
    @objc private func addButtonClicked(_ barButton: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let medication = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.reminder.actionSheet.medication.title"), style: .default,handler: {_ in
            self.pushSelectPrescriptionVC(isMedication: true)
        })
        let supplement = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.reminder.actionSheet.supplement.title"), style: .default,handler: {_ in
            self.pushSelectPrescriptionVC(isMedication: false)
        })
        
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: nil)
        
        alertController.addAction(medication)
        alertController.addAction(supplement)
        alertController.addAction(cancelAction)
        if let popover = alertController.popoverPresentationController {
            popover.barButtonItem = barButton
            popover.permittedArrowDirections = .up
        }
        self.navigationController?.present(alertController, animated: true)
    }
    
    @objc private func reminderSegmentControlOnClick(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            self.navigationItem.rightBarButtonItems?.removeLast()
        }
        else if sender.selectedSegmentIndex == 1{
            let filter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(filterViewClicked))
            self.navigationItem.rightBarButtonItems?.append(filter)
        }
        customTableView.reloadData()
        
        hideSwipeActionButtons()
    }
    
    @objc private func onUIRefreshChange(){
        fetchReminder()
    }
    
    @objc private func filterViewClicked()
    {
        if reminderSegmentControl.selectedSegmentIndex == 1{
            let selectValueViewController = SelectValueViewController()
            selectValueViewController.delegate = self
            selectValueViewController.title = getString(key: "com.charmphr.prescriptions.FilteredBy.title")
            selectValueViewController.arrayOfValueToBeShown  = filterTypeArr.map({filter in
                filter.rawValue
            })
            selectValueViewController.selectedValueIndex = filterTypeArr.firstIndex(of: selectedFilter)
            navigationController?.pushViewController(selectValueViewController, animated: true)
        }
    }
    
    override func noDataViewRetryBtnClicked() {
        isFetchReminderInProgress = false
        fetchReminderListMedicationsAndSupplements()
    }
    
    //MARK: - CharmConnectionHandler Delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        ///fetching reminderMeta and today reminder history while entering this module
        ///fetching reminder and today reminder history on refresh
        
        if identificationKey == "fetchReminderWithMeta"{
            responseCount += 1
            isFetchReminderSuccess = true
            if let reminderGroupList = response as? PatientReminderPOJO{
                patientReminderPOJO = reminderGroupList
                PatientDataHandler.setPatientDataObjects(medicationPOJOList: reminderGroupList.arrayOfMedication, supplementPOJOList: reminderGroupList.arrayOfSupplement, reminderList: reminderGroupList.reminderArray, patientId: getSelectedPatientId())
                ReminderHandler.addOrUpdateNotificationForReminder(reminderArray: reminderGroupList.reminderArray, patientId: getSelectedPatientId())
            }
        }
        else if identificationKey == "fetchTodayReminderHistory"{
            responseCount += 1
            futureDateAlert = nil
            if let reminderHistoryList = response as? [ReminderHistory]{
                todayReminderHisoryList = reminderHistoryList
            }
        }
        else if identificationKey == "fetchReminder"{
            responseCount += 1
            if let reminderList = response as? [Reminder]{
                patientReminderPOJO?.reminderArray = reminderList
                ReminderHandler.addOrUpdateReminderToDB(reminderArray: reminderList, patientId: getSelectedPatientId())
            }
        }
        else if identificationKey.hasPrefix("deleteReminder"){
            if reminderSegmentControl.selectedSegmentIndex == 1{
                
                trackEvent(eventName: "DeleteReminderOnSuccess", withGroupName: "Reminder")
                hideActivityIndicator()
                
                if let index = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                    
                    if let reminderObj = reminderArrayToLoad[index].reminderDetails?.reminder{
                        ReminderHandler.deleteReminderAndNotification(reminderObj: reminderObj)
                    }
                    reminderArrayToLoad.remove(at: index)
                    self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: index, section: 0)])
                }
                CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.reminder.delete.successfull.message"), seconds: 2)
                fetchReminder()
            }
        }
        
        if responseCount == 2{
            hideActivityIndicator()
            
            if let reminderArray = patientReminderPOJO?.reminderArray{
                patientReminderPOJO?.reminderArray = reminderArray.filter({ reminderObj in
                    return !reminderObj.isReminderDeleted
                })
            }
            
            groupTodayReminder()
            groupReminderUnderAllCategory()
            responseCount = 0
            isUpdateFrequency = false
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        let nsError = error as NSError
        if identificationKey == "fetchReminder"{
            isFetchReminderSuccess = false
            todayReminderArray = []
            reminderArrayToLoad = []
            customTableView.reloadData()
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else if identificationKey == "fetchTodayReminderHistory"{
            if isFetchReminderSuccess{
                if nsError.code == CUSTOM_ERROR_CODE{
                    futureDateAlert = nsError
                    customTableView.reloadData()
                }
                else{
                    CharmUtil.createOkayAlertWith(error: error)
                }
            }
        }
        else if identificationKey == "fetchReminderWithMeta"{
            isFetchReminderSuccess = false
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            if identificationKey.hasPrefix("deleteReminder"){
                trackEvent(eventName: "DeleteReminderOnFailure", withGroupName: "Reminder")
            }
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let futureDateAlert = futureDateAlert{
            self.noDataBackGroundView.setImage(enum: .oops, title: futureDateAlert.domain, message: nil)
            todayReminderArray = []
        }
        else{
            if reminderSegmentControl.selectedSegmentIndex == 0{
                if todayReminderArray.count == 0
                {
                    self.noDataBackGroundView.backgroundColor =  UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.reminder.noReminders.alert.title"), message: getString(key: "com.charmphr.reminder.noReminders.alert.message"))
                }else
                {
                    self.noDataBackGroundView.hideSubView(bool: true)
                }
                return todayReminderArray.count
            }
            else{
                if reminderArrayToLoad.count == 0
                {
                    self.noDataBackGroundView.backgroundColor =  UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
                    if selectedFilter == .Active || selectedFilter == .All{
                        self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.reminder.noReminders.alert.title"), message: getString(key: "com.charmphr.reminder.noReminders.alert.message"))
                    }
                    else if selectedFilter == .Completed{
                        self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.reminder.noCompeletedReminders.alert.title"), message: nil)
                    }
                    else if selectedFilter == .Upcoming{
                        self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.reminder.noUpcomingReminders.alert.title"), message: nil)
                    }
                }else
                {
                    self.noDataBackGroundView.hideSubView(bool: true)
                }
                return reminderArrayToLoad.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if reminderSegmentControl.selectedSegmentIndex == 0{
            if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReminderTodayTableViewCell") as? ReminderTodayTableViewCell{
                if !todayReminderArray.isEmpty{
                    let groupedReminder = todayReminderArray[indexPath.row]
                    tableViewCell.vcDelegate = self
                    tableViewCell.setTableViewCell(data: groupedReminder, indexPath: indexPath)
                }
                return tableViewCell
            }
        }
        else{
            if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReminderAllTableViewCell") as? ReminderAllTableViewCell{
                if !reminderArrayToLoad.isEmpty{
                    let reminderPOJO = reminderArrayToLoad[indexPath.row]
                    tableViewCell.delegate = self
                    if let reminderDetails = reminderPOJO.reminderDetails{
                        tableViewCell.setTableViewCell(data: reminderDetails, indexPath: indexPath)
                    }
                    
                    let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
                    swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
                    tableViewCell.reminderAllItemView.addGestureRecognizer(swiftLeft)
                    
                    let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
                    swiftRight.direction = UISwipeGestureRecognizer.Direction.right
                    tableViewCell.reminderAllItemView.addGestureRecognizer(swiftRight)
                    
                    tableViewCell.reminderAllItemView.deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))
                    tableViewCell.reminderAllItemView.historyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))
                    if let selectedIndex = selectedIndex{
                        if indexPath.row == selectedIndex{
                            tableViewCell.reminderAllItemView.setRowActionForSwipeLeft(duration: 0, reminderPOJO: reminderPOJO)
                        }
                        else{
                            tableViewCell.reminderAllItemView.setRowActionForSwipeRight(duration: 0)
                        }
                    }
                }
                return tableViewCell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideSwipeActionButtons()
        if reminderSegmentControl.selectedSegmentIndex == 1{
            let selectedReminderPOJO = reminderArrayToLoad[indexPath.row]
            if selectedReminderPOJO.reminderDetails?.isCompleted == false{
                pushEditVc(reminderPOJO: selectedReminderPOJO)
            }
        }
    }
    
    //MARK: - Swipe Target functions
    
    private func hideSwipeActionButtons(){
        if let prebSelectedTVIndex = selectedIndex {
            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? ReminderAllTableViewCell {
                prevTableViewCell.reminderAllItemView.setRowActionForSwipeRight(duration: 0.4)
                selectedIndex = nil
            }
        }
    }
    
    @objc private func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        if let reminderAllItemView = sender.view as? ReminderAllItemView{
            if let tableViewCell = reminderAllItemView.superview?.superview as? ReminderAllTableViewCell{
                if let index: Int = customTableView.indexPath(for: tableViewCell)?.row{
                    switch sender.direction {
                    case UISwipeGestureRecognizer.Direction.left:
                        
                        var allowLeftSwipe = true
                        if let prebSelectedTVIndex = selectedIndex {
                            if prebSelectedTVIndex == index {
                                allowLeftSwipe = false
                            }
                            else{
                                let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
                                if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? ReminderAllTableViewCell {
                                    prevTableViewCell.reminderAllItemView.setRowActionForSwipeRight(duration: 0.4)
                                    selectedIndex = nil
                                }
                            }
                        }
                        if allowLeftSwipe{
                            let reminderPOJO = reminderArrayToLoad[index]
                            selectedIndex = index
                            reminderAllItemView.setRowActionForSwipeLeft(duration: 0.4, reminderPOJO: reminderPOJO)
                        }
                    case UISwipeGestureRecognizer.Direction.right:
                        if selectedIndex == index {
                            selectedIndex = nil
                            reminderAllItemView.setRowActionForSwipeRight(duration: 0.4)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @objc private func onTouchLabel(sender: UITapGestureRecognizer){
        if let uiLabel = sender.view as? UILabel{
            if let reminderAllItemView = uiLabel.superview as? ReminderAllItemView{
                if let tableViewCell = reminderAllItemView.superview?.superview as? ReminderAllTableViewCell{
                    if let indexPath: IndexPath = customTableView.indexPath(for: tableViewCell){
                        if selectedIndex != nil{
                            reminderAllItemView.setRowActionForSwipeRight(duration: 0)
                        }
                        selectedIndex = nil
                        if uiLabel.text == DELETE_LABEL{
                            CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.reminder.delete.alert.title"), deleteClicked: {
                                self.deleteReminder(index: indexPath.row)
                            })
                        }
                        else if uiLabel.text == HISTORY_LABEL{
                            let selectedReminder = reminderArrayToLoad[indexPath.row]
                            pushHistoryVC(reminderPOJO: selectedReminder)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteReminder(index: Int){
        let selectedReminderPOJO = reminderArrayToLoad[index]
        showActivityIndicatorFront()
        charmConnectionHandler?.deleteReminder(reminderObj: selectedReminderPOJO.reminderDetails?.reminder, identificationKey: "deleteReminder_\(index)")
    }
    
//MARK: - GroupReminder
    
/// Grouping the reminder and medication/supplement based on the start date of the reminder (active, upcoming, completed)
    private func groupReminderUnderAllCategory(){
        
        activeReminderPOJOArray = []
        upcomingReminderPOJOArray = []
        completedReminderPOJOArray = []
        
        let todayDate = Date().startOfDay
        
        patientReminderPOJO?.reminderArray.forEach { reminderObj in
            
            if let reminderDetails = formReminderDetailsObj(reminderObj: reminderObj),
               let startDate = reminderObj.startDate?.startOfDay,
               let endDate = reminderObj.endDate?.startOfDay{
                
                let reminderPOJO = ReminderPOJO()
                
                if startDate <= todayDate && endDate >= todayDate{
                    reminderDetails.isActive = true
                    
                    reminderPOJO.reminderDetails = reminderDetails
                    activeReminderPOJOArray.append(reminderPOJO)
                }
                else if startDate > todayDate{
                    reminderDetails.isUpcoming = true
                    
                    reminderPOJO.reminderDetails = reminderDetails
                    upcomingReminderPOJOArray.append(reminderPOJO)
                }
                else if endDate < todayDate{
                    reminderDetails.isCompleted = true
                    
                    reminderPOJO.reminderDetails = reminderDetails
                    completedReminderPOJOArray.append(reminderPOJO)
                }
            }
        }
        
        activeReminderPOJOArray = FilterHandler.sortReminder(arrayOfReminder: activeReminderPOJOArray)
        upcomingReminderPOJOArray = FilterHandler.sortReminder(arrayOfReminder: upcomingReminderPOJOArray)
        completedReminderPOJOArray = FilterHandler.sortReminder(arrayOfReminder: completedReminderPOJOArray)
        
        reloadReminderTableView()
    }
    
    /// Grouping the reminder for today segment based on time
    private func groupTodayReminder(){
        
        var timeArray: [String] = []
        todayReminderArray = []
        
        let todayDate = Date().startOfDay
        
        patientReminderPOJO?.reminderArray.forEach({ reminderObj in
            
            if let startDate = reminderObj.startDate?.startOfDay{
                
                if let endDate = reminderObj.endDate?.startOfDay{
                    if startDate <= todayDate && endDate >= todayDate{
                        timeArray.append(contentsOf: groupReminderUnderTimeAndReturnTimeArr(reminderObj: reminderObj, timeArray: timeArray))
                    }
                }
                else if startDate <= todayDate && reminderObj.endDate == nil{
                    timeArray.append(contentsOf: groupReminderUnderTimeAndReturnTimeArr(reminderObj: reminderObj, timeArray: timeArray))
                }
            }
        })
        
        todayReminderArray = FilterHandler.sortTodayReminder(arrayOfTodayReminder: todayReminderArray)
        
        customTableView.reloadData()
    }
    
    //For today only:
    //This method groups reminders based on time.
    //A single TIME may have multiple REMINDERS, and similarly,
    //a single REMINDER can be mapped to multiple TIMES.
    
    private func groupReminderUnderTimeAndReturnTimeArr(reminderObj: Reminder, timeArray: [String]) -> [String]{
        
        var timeArray = timeArray
        
        let reminderDetails = formReminderDetailsObj(reminderObj: reminderObj)
        if reminderDetails != nil{
            reminderObj.reminderFrequencyArray.forEach { reminderFrequency in
                
                if let dayInt = reminderFrequency.day?.toIntOrNil(),
                    let timeString = reminderFrequency.time,
                    (dayInt == -1) || dayInt == (Date().weekday - 1){
                    
                    if !timeArray.contains(timeString){
                        timeArray.append(timeString)
                        
                        let todayReminderPOJO = TodayReminderPOJO()
                        todayReminderPOJO.time = CharmUtil.getDateObjectWith(dateString: timeString, dateFormat: "HH:mm")
                        
                        let reminderPOJO = formReminderPOJOObj(reminderObj: reminderObj, reminderFrequency: reminderFrequency)
                        
                        reminderPOJO.reminderDetails = reminderDetails
                        todayReminderPOJO.reminderPOJOList.append(reminderPOJO)
                        todayReminderArray.append(todayReminderPOJO)
                    }
                    else{
                        if let todayReminderPOJO = todayReminderArray.first(where: { reminderGroup in
                            return timeString == reminderGroup.time?.getStringFromDate(dateFormat: "HH:mm")
                        }){
                            let reminderPOJO = formReminderPOJOObj(reminderObj: reminderObj, reminderFrequency: reminderFrequency)
                            
                            reminderPOJO.reminderDetails = reminderDetails
                            todayReminderPOJO.reminderPOJOList.append(reminderPOJO)
                        }
                    }
                }
            }
        }
        return timeArray
    }
    
//MARK: - Form ReminderPOJO and ReminderDetails
    
///This function search the medication/supplement from moduleId given in Reminder and set the title and descripiton for the reminder and return the new ReminderDetails object
    private func formReminderDetailsObj(reminderObj: Reminder) -> ReminderDetails?{
        let reminderDetails = ReminderDetails()
        
        if reminderObj.reminderType == MEDICATION{
            if let medicationPOJO = patientReminderPOJO?.arrayOfMedication.first(where: { medicationPOJO in
                
                if let patientMedication = medicationPOJO.patientMedication{
                    if patientMedication.addedByPatient{
                        return medicationPOJO.patientMedication?.patientMedicationId == reminderObj.moduleId
                    }
                    else{
                        return medicationPOJO.patientMedication?.patientMedicationId == reminderObj.moduleId && patientMedication.isActive
                    }
                }
                return false
            }){
                reminderDetails.reminder = reminderObj
                reminderDetails.moduleType = ReminderModuleEnum.medication
                reminderDetails.title = medicationPOJO.getMedicationDisplayName()
                reminderDetails.descripiton = medicationPOJO.getIntakeName(separator: ", ")
                
                if medicationPOJO.patientMedication?.toDate != nil{
                    reminderDetails.hasEndDate = true
                }
                else{
                    reminderDetails.hasEndDate = false
                }
                return reminderDetails
            }
        }
        else{
            if let supplementPOJO = patientReminderPOJO?.arrayOfSupplement.first(where: { supplementPOJO in
                if let patientSupplement = supplementPOJO.patientSupplement{
                    if patientSupplement.isAddedByPatient{
                        return patientSupplement.patientSupplementId == reminderObj.moduleId
                    }
                    else{
                        return patientSupplement.patientSupplementId == reminderObj.moduleId && patientSupplement.isActive
                    }
                }
                return false
                
            }){
                reminderDetails.reminder = reminderObj
                reminderDetails.moduleType = ReminderModuleEnum.supplement
                reminderDetails.title = supplementPOJO.getSupplementDisplayName()
                reminderDetails.descripiton = supplementPOJO.getIntakeName(separator: ", ")
                
                if supplementPOJO.patientSupplement?.toDate != nil{
                    reminderDetails.hasEndDate = true
                }
                else{
                    reminderDetails.hasEndDate = false
                }
                return reminderDetails
            }
        }
        return nil
    }
    
    private func formReminderPOJOObj(reminderObj: Reminder, reminderFrequency: ReminderFrequency) -> ReminderPOJO{
        let reminderPOJO = ReminderPOJO()
        let reminderHistoryDetail = ReminderHistoryDetail()
        
        ///The reminder history is provided by a separate API based on date. We need to combine this history with the reminder frequency, which includes both the day (e.g., Monday, Tuesday) and the time (e.g., 11:00 AM).
        /// getting history from the todayHistory list and mapping to the reminderPOJO
        if let reminderHistory = todayReminderHisoryList.first(where: { reminderHistoryObj in
            if reminderHistoryObj.reminderId == reminderObj.reminderId{
                return reminderFrequency.timeDayPrimaryKey == reminderHistoryObj.reminderFrequency?.timeDayPrimaryKey
            }
            return false
        }){
            reminderHistoryDetail.reminderHistory = reminderHistory
        }
        if let reminderId = reminderObj.reminderId, let time = reminderFrequency.time{
            reminderHistoryDetail.reminderHistoryPrimaryKey = "\(time)-\(reminderId)"
        }
        reminderPOJO.reminderHistoryDetail = reminderHistoryDetail
        return reminderPOJO
    }
    
    //MARK: - Other functions
    
    func presentReminderDetailDialogVC(btn: UIButton){
        
        let todayReminderArray = todayReminderArray[btn.tag]
        let reminderDetailDialogViewController = ReminderDetailDialogViewController(todayReminderPOJO: todayReminderArray, isFromNotification: false, timeObj: todayReminderArray.time)
        reminderDetailDialogViewController.delegate = self
        reminderDetailDialogViewController.historyDelegate = self
        reminderDetailDialogViewController.modalPresentationStyle = .overCurrentContext
        reminderDetailDialogViewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(reminderDetailDialogViewController, animated: true)
    }
    
    private func pushSelectPrescriptionVC(isMedication: Bool){
        let selectPrescriptionViewController = SelectPrescriptionViewController()
        selectPrescriptionViewController.delegate = self
        selectPrescriptionViewController.isMedication = isMedication
        
        ///Need to uncomment this code once isActive status is properly provided in api
//        if isMedication{
//            if let medicationArr = patientReminderPOJO?.arrayOfMedication.filter({ medicationPOJO in
//                return medicationPOJO.patientMedication?.isActive == true
//            }){
//                selectPrescriptionViewController.arrayOfMedication = medicationArr
//            }
//        }
//        else{
//            if let supplementArr = patientReminderPOJO?.arrayOfSupplement.filter({ supplementPOJO in
//                return supplementPOJO.patientSupplement?.isActive == true
//            }){
//                selectPrescriptionViewController.arrayOfSupplement = supplementArr
//            }
//        }
        
        self.navigationController?.pushViewController(selectPrescriptionViewController, animated: true)
    }
    
    private func reloadReminderTableView(){
        reminderArrayToLoad = []
        if selectedFilter == ReminderFilterType.All{
            reminderArrayToLoad.append(contentsOf: upcomingReminderPOJOArray)
            reminderArrayToLoad.append(contentsOf: activeReminderPOJOArray)
            reminderArrayToLoad.append(contentsOf: completedReminderPOJOArray)
        }
        else if selectedFilter == ReminderFilterType.Upcoming{
            reminderArrayToLoad.append(contentsOf: upcomingReminderPOJOArray)
        }
        else if selectedFilter == ReminderFilterType.Completed{
            reminderArrayToLoad.append(contentsOf: completedReminderPOJOArray)
        }
        else if selectedFilter == ReminderFilterType.Active{
            reminderArrayToLoad.append(contentsOf: activeReminderPOJOArray)
        }
        customTableView.reloadData()
    }
    
//MARK: - Add Or Update HistoryStatus
    
    private func addOrUpdateHistoryStatus(reminderHistoryArray: [ReminderHistory]){
        
        for reminderHistoryObj in reminderHistoryArray{
            if let todayReminderPOJO = todayReminderArray.first(where: { todayReminderPOJO in
                return todayReminderPOJO.time?.getStringFromDate(dateFormat: "HH:mm") == reminderHistoryObj.reminderFrequency?.time
            }){
                if let reminderPOJO = todayReminderPOJO.reminderPOJOList.first(where: { reminderPOJO in
                    if let time = reminderHistoryObj.reminderFrequency?.time, let reminderId = reminderHistoryObj.reminderId{
                        return reminderPOJO.reminderHistoryDetail?.reminderHistoryPrimaryKey == "\(time)-\(reminderId)"
                    }
                    return false
                }){
                    if reminderPOJO.reminderHistoryDetail?.reminderHistory == nil{
                        reminderPOJO.reminderHistoryDetail?.reminderHistory = reminderHistoryObj
                    }
                    else{
                        reminderPOJO.reminderHistoryDetail?.reminderHistory?.status = reminderHistoryObj.status
                    }
                    customTableView.reloadData()
                }
            }
        }
    }
   
    //MARK: - SelectValueVC Delegate
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        setFilteredBy(filter: filterTypeArr[selectedRow])
    }
    
    //MARK: - AddReminder Delegate
    
    func reminderAdded(msg: String) {
        //We are updating frequency IDs for reminders added through the app when refreshing the reminder list from the API.
        isUpdateFrequency = true
        fetchReminder()
        CharmUtil.showToast(controller: self, message: msg, seconds: 2)
    }
    
    //MARK: - Reminder History Update Delegate
    
    func updateHistorySuccess(msg: String, addedOrUpdatedHistoryArray: [ReminderHistory]){
        CharmUtil.showToast(controller: self, message: msg, seconds: 2)
        addOrUpdateHistoryStatus(reminderHistoryArray: addedOrUpdatedHistoryArray)
    }
    
    //MARK: - Reminder Detail Delegate
    
    func pushEditVc(reminderPOJO: ReminderPOJO){
        activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let addReminderVC = AddReminderViewController()
        addReminderVC.editReminderPOJO = reminderPOJO
        addReminderVC.delegate = self
        self.navigationController?.pushViewController(addReminderVC, animated: true, completion: {
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
        })
    }
    
    func pushHistoryVC(reminderPOJO: ReminderPOJO){
        activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let reminderHistoryVC = ReminderHistoryViewController()
        reminderHistoryVC.reminderPOJO = reminderPOJO
        self.navigationController?.pushViewController(reminderHistoryVC, animated: true, completion: {
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
        })
    }
    
    private func setFilteredBy(filter : ReminderFilterType?)
    {
        if let filter = filter{
            selectedFilter = filter
        }
        reloadReminderTableView()
    }
}

fileprivate enum ReminderFilterType : String
{
    case All = "All"
    case Upcoming = "Upcoming"
    case Active = "Active"
    case Completed = "Completed"
}

extension UINavigationController {
    public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping () -> Void) {
            pushViewController(viewController, animated: animated)
            guard animated, let coordinator = transitionCoordinator else {
                DispatchQueue.main.async { completion() }
                return
            }
            coordinator.animate(alongsideTransition: nil) { _ in completion() }
        }
}
