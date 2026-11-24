//
//  ReminderHistoryViewController.swift
//  phr
//
//  Created by prathi-13964 on 30/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

fileprivate let reminderHistoryItemHeight: CGFloat = 44

class ReminderHistoryViewController: AddDataUIViewController, CharmConnectionV2HandlerDelegate, UITableViewDelegate, UITableViewDataSource, ReminderHistroryItemEditDelegate, NoDataViewDelegate{
    
    private var reminderHistoryView: ReminderHistoryView?
    var reminderPOJO: ReminderPOJO?
    private var charmConnectionHandler: CharmConnectionHandler? = nil
    var reminderHistoryArray: [ReminderHistory] = []
    private var reminderHistoryGroupArray: [ReminderHistoryGroupPOJO] = []
    var timeObjToWidthMap: [Date: CGFloat] = [:]
    private var timeObjToReminderFrequencyMap: [Date: ReminderFrequency] = [:]
    private var timeObjToReminderMap: [Date: Reminder] = [:]
    var timeArray: [ReminderHistoryTime] = []
    private var dateArray: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reminderHistoryView = ReminderHistoryView(reminderPOJO: reminderPOJO, delegate: self)
        self.title = getString(key: "com.charmphr.reminder.reminderHistory.title")
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        if let reminderHistoryView = reminderHistoryView{
            self.view.addSubview(reminderHistoryView)
            reminderHistoryView.setSafeAreaTop(offset: 0)
            reminderHistoryView.setBottom(offSet: -CARD_PADDING)
            reminderHistoryView.setLeft(offSet: 0)
            reminderHistoryView.setRight(offSet: 0)
            reminderHistoryView.historyTableView.delegate = self
            reminderHistoryView.historyTableView.dataSource = self
            reminderHistoryView.noDataView.delegate = self
            reminderHistoryView.historyTableView.register(ReminderHistoryTableViewCell.self, forCellReuseIdentifier: "ReminderHistoryTableViewCell")
            charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
            loadRequest()
        }
    }
    
    private func loadRequest(){
        if let reminderObj = reminderPOJO?.reminderDetails?.reminder{
            reminderHistoryView?.showActivityIndicator()
            charmConnectionHandler?.fetchReminderHistory(reminderObj: reminderObj, identificationKey: "fetchReminderHistory")
        }
    }
    
    internal func noDataViewRetryBtnClicked() {
        loadRequest()
    }
    
//MARK: - Other functions
    
    func addHistoryTime(timeStringArray: [ReminderHistoryTime]){
        timeArray = []
        let dateString = Date().getStringFromDate(dateFormat: PHR_DATE_API_FORMAT)
        timeStringArray.forEach { reminderHistoryTime in
            if let timeString = reminderHistoryTime.timeString{
                let timeObj = Date.getDateFromString(dateFormat: ReminderDateWithTimeFormat, dateString: "\(dateString) \(timeString)") ?? Date()
                
                reminderHistoryTime.timeobj = timeObj
                timeArray.append(reminderHistoryTime)
            }
        }
    }
    
    func formDateArray(fromDate: Date, toDate: Date, frequencyArray: [ReminderFrequency]){
        dateArray = []
        if frequencyArray.first?.day == "-1"{
            if Date().startOfDay < toDate.startOfDay{
                dateArray = Date.dates(from: fromDate, to: Date())
            }
            else{
                dateArray = Date.dates(from: fromDate, to: toDate)
            }
        }
        else{
            if Date().startOfDay < toDate.startOfDay{
                let tempDateArray =  Date.dates(from: fromDate, to: Date())
                frequencyArray.forEach { reminderFrequency in
                    dateArray.append(contentsOf: getFilteredDateArray(tempDateArray: tempDateArray, reminderFrequency: reminderFrequency))
                }
            }
            else{
                let tempDateArray =  Date.dates(from: fromDate, to: toDate)
                frequencyArray.forEach { reminderFrequency in
                    dateArray.append(contentsOf: getFilteredDateArray(tempDateArray: tempDateArray, reminderFrequency: reminderFrequency))
                }
            }
            dateArray = dateArray.removeDuplicateElements()
            dateArray = dateArray.sorted(by: { $0.compare($1) == .orderedAscending })
        }
    }
    
    private func getFilteredDateArray(tempDateArray: [Date], reminderFrequency: ReminderFrequency) -> [Date]{
        let dateArray = tempDateArray.filter({ tempDate in
            return tempDate.getStringFromDate(dateFormat: dayDisplayFormat) == "\(WeekDays(rawValue: reminderFrequency.day?.toIntOrNil() ?? 0) ?? WeekDays.Sunday)"
        })
        return dateArray
    }
    
    func mapTimeViewAndWidth(timeObj: Date, width: CGFloat){
        timeObjToWidthMap[timeObj] = width
    }
    
    func mapTimeAndReminderFrequency(timeObj: Date?, reminderFrequency: ReminderFrequency, reminder: Reminder?){
        if let timeObj = timeObj, let reminder = reminder{
            timeObjToReminderFrequencyMap[timeObj] = reminderFrequency
            timeObjToReminderMap[timeObj] = reminder
        }
    }
    
//MARK: - CharmConnectionHandler Delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchReminderHistory"{
            reminderHistoryView?.hideActivityIndicator()
            if let response = response as? [ReminderHistory]{
                reminderHistoryArray = response
                reminderHistoryView?.createTimeArr()
                groupReminderHistory()
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "fetchReminderHistory"{
            reminderHistoryView?.showErrorPage(error: error)
        }
        else{
            reminderHistoryView?.hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
//MARK: - GroupReminderHistory
    
    private func groupReminderHistory(){
        
        reminderHistoryGroupArray = []
        dateArray.forEach({ dateObj in
            
            let reminderHistoryGroupPOJO = ReminderHistoryGroupPOJO()
            var reminderHistoryTranformArray: [ReminderHistoryTranformPOJO] = []
            
            timeArray.forEach({ reminderHistoryTime in
                
                if let timeObj = reminderHistoryTime.timeobj{
                    let reminderFrequency = timeObjToReminderFrequencyMap[timeObj]
                    let reminder = timeObjToReminderMap[timeObj]
                    
                    let reminderHistoryTranformPOJO = ReminderHistoryTranformPOJO()
                    reminderHistoryTranformPOJO.time = timeObj
                    
                    let reminderHistory = reminderHistoryArray.first { reminderHistoryPOJO in
                        return (reminderHistoryPOJO.reminderFrequency?.time == timeObj.getStringFromDate(dateFormat: Time24HoursFormat)) && (reminderHistoryPOJO.statusUpdatedTime?.isSameDate(date: dateObj) == true)
                    }
                    
                    if let reminderHistory = reminderHistory{
                        reminderHistoryTranformPOJO.reminderHistory = reminderHistory
                        if reminderHistory.status == 0{
                            reminderHistoryTranformPOJO.reminderHistoryStatus = ReminderHistoryStatus.isSkipped
                        }
                        else{
                            reminderHistoryTranformPOJO.reminderHistoryStatus = ReminderHistoryStatus.isTaken
                        }
                    }
                    else{
                        reminderHistoryTranformPOJO.reminderHistoryStatus = ReminderHistoryStatus.isUnMarked
                        reminderHistoryTranformPOJO.reminderFrequency = reminderFrequency
                        reminderHistoryTranformPOJO.reminder = reminder
                        
//                        if timeObj > Date() && dateObj.startOfDay == Date().startOfDay{
//                            
//                        }
//                        else{
//                            if dateObj.startOfDay < Date().startOfDay{
//                                reminderHistoryTranformPOJO.isSkipped = true
//                            }
//                            else{
//                                reminderHistoryTranformPOJO.reminderFrequency = reminderFrequency
//                                reminderHistoryTranformPOJO.isUnMarked = true
//                            }
//                        }
                    }
                    reminderHistoryTranformArray.append(reminderHistoryTranformPOJO)
                }
            })
            reminderHistoryGroupPOJO.date = dateObj
            reminderHistoryGroupPOJO.reminderHistoryTranformList = reminderHistoryTranformArray
            
            reminderHistoryGroupArray.append(reminderHistoryGroupPOJO)
        })
        reminderHistoryView?.historyTableView.reloadData()
        reminderHistoryView?.historyTableView.scrollToRow(at: IndexPath(row: reminderHistoryGroupArray.count - 1, section: 0), at: .bottom, animated: true)
    }
    
//MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        reminderHistoryView?.historyTableView.removeConstraint(attribute: .height)
        let tableViewHeight = CGFloat(reminderHistoryGroupArray.count * 44)
        if let reminderHistoryView = reminderHistoryView{
            let remainingHeight = applicationFrame.height - reminderHistoryView.scrollViewContainerHeight
            if tableViewHeight > remainingHeight{
                reminderHistoryView.historyTableView.setHeight(constant: remainingHeight)
            }
            else{
                reminderHistoryView.historyTableView.setHeight(constant: tableViewHeight + 3)
            }
        }
        return reminderHistoryGroupArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReminderHistoryTableViewCell") as? ReminderHistoryTableViewCell

        if let tableViewCell = tableViewCell{
            let reminderHistoryGroup = reminderHistoryGroupArray[indexPath.row]
            tableViewCell.delegate = self
            tableViewCell.setTableViewCellData(data: reminderHistoryGroup)
            return tableViewCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return reminderHistoryItemHeight
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let selectedReminderHistory = reminderHistoryGroupArray[indexPath.row]
//
//        if selectedReminderHistory.date?.startOfDay == Date().startOfDay{
//
//            let reminderHistroryItemEditVC = ReminderHistroryItemEditViewController()
//            reminderHistroryItemEditVC.reminderHistoryGroup = selectedReminderHistory
//            reminderHistroryItemEditVC.delegate = self
//            self.navigationController?.pushViewController(reminderHistroryItemEditVC, animated: true)
//
////            if selectedReminderHistory.reminderHistoryTranformList.contains(where: { reminderHistoryTranformPOJO in
////                return reminderHistoryTranformPOJO.time?.getStringFromDate(dateFormat: Time24HoursFormat) ?? "" <= Date().getStringFromDate(dateFormat: Time24HoursFormat)
////            }){
////
////            }
////            else{
////                CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.reminder.reminderHistory.edit.error.message.futureTime.title"), seconds: 2)
////            }
//        }
//        else{
//            CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.reminder.reminderHistory.edit.error.message.futureDate.title"), seconds: 1)
//        }
//    }
    
//MARK: - ReminderHistroryItemEditDelegate
    
    func updateHistorySuccess(msg: String, addedOrUpdatedHistoryArray: [ReminderHistory]) {
        CharmUtil.showToast(controller: self, message: msg, seconds: 2)
        
        if addedOrUpdatedHistoryArray.contains(where: { reminderHistory in
            return reminderHistory.reminderId == reminderPOJO?.reminderDetails?.reminder?.reminderId
        }){
            loadRequest()
        }
    }
    
    override func onBackClick() {
        self.navigationController?.popViewController(animated: true)
    }
}
