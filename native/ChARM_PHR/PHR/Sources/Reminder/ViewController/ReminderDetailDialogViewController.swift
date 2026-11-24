//
//  ReminderDetailDialogViewController.swift
//  phr
//
//  Created by prathi-13964 on 24/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol ReminderDetailDelegate: AnyObject{
    func pushEditVc(reminderPOJO: ReminderPOJO)
    func pushHistoryVC(reminderPOJO: ReminderPOJO)
}

class ReminderDetailDialogViewController: UIViewController, CharmConnectionV2HandlerDelegate{
    
    lazy var reminderDetailDialogView: ReminderDetailDialogView? = nil
    private var charmConnectionHandler: CharmConnectionHandler? = nil
    
    weak var delegate: ReminderDetailDelegate? = nil
    weak var historyDelegate: ReminderHistroryItemEditDelegate? = nil
    private var reminderPOJO: ReminderPOJO? = nil
    private var todayReminderPOJO: TodayReminderPOJO? = nil
    
    private var selectedReminderPOJOArray: [ReminderPOJO] = []
    private var addReminderHistoryList: [ReminderHistory] = []
    private var updateReminderHistoryList: [ReminderHistory] = []
    private var responseReminderHistoryArray: [ReminderHistory] = []
    
    private var btnToReminderPOJOMap: [Int: ReminderPOJO] = [:]
    private var viewTobtnMap: [Int: Int] = [:]
    var isFromNotification: Bool = false
    private var tagNo = 18000
    private var timeObj: Date?
    private var responseCount = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(reminderPOJO: ReminderPOJO? = nil, todayReminderPOJO: TodayReminderPOJO? = nil, isFromNotification: Bool, timeObj: Date?, patientId: String? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.reminderPOJO = reminderPOJO
        self.todayReminderPOJO = todayReminderPOJO
        self.isFromNotification = isFromNotification
        self.timeObj = timeObj
        
        reminderDetailDialogView = ReminderDetailDialogView(delegate: self, patientId: patientId)
        
        if let reminderDetailDialogView = reminderDetailDialogView{
            self.view.addSubview(reminderDetailDialogView)
            
            reminderDetailDialogView.delegate = self
            reminderDetailDialogView.setLeft(offSet: reminderPopVCPadding)
            reminderDetailDialogView.setRight(offSet: -reminderPopVCPadding)
            reminderDetailDialogView.setCenterY()
            
            reminderDetailDialogView.editButton.addTarget(self, action: #selector(onClickEditBtn), for: .touchUpInside)
            reminderDetailDialogView.historyButton.addTarget(self, action: #selector(OnClickHistoryBtn), for: .touchUpInside)
            reminderDetailDialogView.takenBtn.addTarget(self, action: #selector(onClickTakenBtn), for: .touchUpInside)
            reminderDetailDialogView.skipBtn.addTarget(self, action: #selector(OnClickSkipBtn), for: .touchUpInside)
            
            if isFromNotification{
                reminderDetailDialogView.closeBtn.isEnabled = true
                reminderDetailDialogView.closeBtn.isHidden = false
            }
            else{
                reminderDetailDialogView.closeBtn.isEnabled = false
                reminderDetailDialogView.closeBtn.isHidden = true
                
                self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC(sender:))))
            }
            
            if let reminderPOJO = reminderPOJO{
                reminderDetailDialogView.editButton.isHidden = false
                reminderDetailDialogView.historyButton.isHidden = false
                reminderDetailDialogView.setReminderItems(reminderPOJO: reminderPOJO, isCheckBoxHidden: true)
            }
            else if let todayReminderPOJO = todayReminderPOJO{
                reminderDetailDialogView.editButton.isHidden = true
                reminderDetailDialogView.historyButton.isHidden = true
                
                if isFromNotification && todayReminderPOJO.reminderPOJOList.count == 1{
                    todayReminderPOJO.reminderPOJOList.forEach({ reminderPOJO in
                        reminderDetailDialogView.setReminderItems(reminderPOJO: reminderPOJO, isCheckBoxHidden: true)
                    })
                }
                else{
                    todayReminderPOJO.reminderPOJOList.forEach({ reminderPOJO in
                        reminderDetailDialogView.setReminderItems(reminderPOJO: reminderPOJO, isCheckBoxHidden: false)
                    })
                }
            }
            
            let heightOfButtons = (reminderDetailDialogView.takenBtn.sizeThatFits(CGSize(width: REMINDER_POPVC_WIDTH, height: 100)).height + CELL_PADDING + CELL_PADDING) * 2
            
            if ((applicationFrame.height * 0.75) - reminderPopSubviewHeight - heightOfButtons) > reminderDetailDialogView.reminderItemHeight{
                reminderDetailDialogView.scrollView.setHeight(constant: reminderDetailDialogView.reminderItemHeight)
            }
            else{
                reminderDetailDialogView.scrollView.setHeight(constant: (applicationFrame.height * 0.75) - reminderPopSubviewHeight - heightOfButtons)
            }
            
            reminderDetailDialogView.setTimeLabelText(str: timeObj?.getStringFromDate(dateFormat: charmDisplayTimeFormat))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: POPVC_BG_COLOR)
    }
    
//MARK: - API calls
    
    private func addReminderHistory(){
        if reminderDetailDialogView?.activityIndicator.isAnimating == false{
            showActivityIndicator()
        }
        charmConnectionHandler?.addReminderHistory(reminderHistoryArray: addReminderHistoryList, identificationKey: "AddReminderHistory")
    }
    
    private func updateReminderHistory(){
        if reminderDetailDialogView?.activityIndicator.isAnimating == false{
            showActivityIndicator()
        }
        charmConnectionHandler?.updateReminderHistory(reminderHistoryArray: updateReminderHistoryList, identificationKey: "UpdateReminderHistory")
    }
    
//MARK: - Target functions
        
    @objc private func onTapReminderItemView(sender: UITapGestureRecognizer){
        if let view = sender.view{
            let btnTag = viewTobtnMap[view.tag] ?? -1
            if let btn = self.view.viewWithTag(btnTag) as? UIButton{
                onCLickCheckBox(btn: btn)
            }
        }
    }
        
    @objc private func onCLickCheckBox(btn: UIButton){
        btn.isSelected = !btn.isSelected
        setSelectedReminder(button: btn)
    }
    
    @objc private func onClickEditBtn(){
        self.dismiss(animated: true)
        if let reminderPOJO = reminderPOJO{
            delegate?.pushEditVc(reminderPOJO: reminderPOJO)
        }
    }
        
    @objc private func dismissVC(sender: UITapGestureRecognizer){
        if let view = sender.view{
            let point =  sender.location(in: view)
            if reminderDetailDialogView?.frame.contains(point) == false{
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func OnClickHistoryBtn(){
        self.dismiss(animated: true)
        if let reminderPOJO = reminderPOJO{
            delegate?.pushHistoryVC(reminderPOJO: reminderPOJO)
        }
    }
        
    @objc func OnClickSkipBtn(){
        
        if let timeObj{
            if timeObj.getStringFromDate(dateFormat: Time24HoursFormat) <=  Date().getStringFromDate(dateFormat: Time24HoursFormat){
                formReminderHistoryObj(status: 0)
            }
            else{
                CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.reminder.reminderHistory.edit.error.message.futureTime.title"), seconds: 2)
            }
        }
    }
        
    @objc func onClickTakenBtn(){
        if let timeObj{
            if timeObj.getStringFromDate(dateFormat: Time24HoursFormat) <=  Date().getStringFromDate(dateFormat: Time24HoursFormat){
                formReminderHistoryObj(status: 1)
            }
            else{
                CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.reminder.reminderHistory.edit.error.message.futureTime.title"), seconds: 2)
            }
        }
    }
    
//MARK: - Other functions
    
    func setCheckBoxBtnAction(btn: UIButton, itemView: UIView, reminderPOJO: ReminderPOJO){
        btn.tag = tagNo
        tagNo += 1
        
        itemView.tag = tagNo
        tagNo += 1
        
        btnToReminderPOJOMap[btn.tag] = reminderPOJO
        viewTobtnMap[itemView.tag] = btn.tag
        
        setSelectedReminder(button: btn)
        itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapReminderItemView)))
        btn.addTarget(self, action: #selector(onCLickCheckBox(btn:)), for: .touchUpInside)
    }
    
    private func setSelectedReminder(button: UIButton){
        if let reminder = btnToReminderPOJOMap[button.tag]{
            if button.isSelected{
                selectedReminderPOJOArray.append(reminder)
            }
            else{
                if let index = selectedReminderPOJOArray.firstIndex(where: { reminderPOJO in
                    return reminder.reminderDetails?.reminder?.reminderId == reminderPOJO.reminderDetails?.reminder?.reminderId
                }){
                    selectedReminderPOJOArray.remove(at: index)
                }
            }
        }
    }
    
//MARK: - Form ReminderHistoryObj
    
    private func formReminderHistoryObj(status: Int){
        
        if selectedReminderPOJOArray.isEmpty{
            CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.reminder.detailDialogue.noSelection.error.title"), msg: nil)
        }
        else{
            selectedReminderPOJOArray.forEach { reminderPOJO in
                
                if let reminderHistory = reminderPOJO.reminderHistoryDetail?.reminderHistory{
                    reminderHistory.status = status
                    reminderHistory.statusUpdatedTime = Date()
                    updateReminderHistoryList.append(reminderHistory)
                }
                else{
                    let reminderHistory = ReminderHistory()
                    var reminderFrequency: ReminderFrequency?
                    reminderHistory.reminderId = reminderPOJO.reminderDetails?.reminder?.reminderId
                    reminderHistory.status = status
                    reminderHistory.statusUpdatedTime = Date()
                    reminderHistory.patientId = reminderPOJO.reminderDetails?.reminder?.patientId
                    
                    let day = Date().weekday - 1
                    reminderFrequency = reminderPOJO.reminderDetails?.reminder?.reminderFrequencyArray.first(where: { reminderFrequency in
                        if reminderFrequency.day == "-1"{
                            return reminderFrequency.timeDayPrimaryKey == (timeObj?.getStringFromDate(dateFormat: Time24HoursFormat) ?? "") + "-1"
                        }
                        else{
                            return reminderFrequency.timeDayPrimaryKey == (timeObj?.getStringFromDate(dateFormat: Time24HoursFormat) ?? "") + "\(day)"
                        }
                    })
                    reminderHistory.reminderFrequency = reminderFrequency
                    reminderHistory.frequencyMapId = reminderFrequency?.frequencyMapId
                    
                    addReminderHistoryList.append(reminderHistory)
                }
            }
            addOrUpdateReminderHistory()
        }
    }
    
    private func addOrUpdateReminderHistory(){
        
        responseCount = 0
        responseReminderHistoryArray = []
        
        if !addReminderHistoryList.isEmpty{
            addReminderHistory()
        }
        if !updateReminderHistoryList.isEmpty{
            updateReminderHistory()
        }
    }
    
//MARK: - ConnectionHandler Delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "AddReminderHistory"{
            responseCount += 1
            if let respArray = response as? [ReminderHistory]{
                responseReminderHistoryArray.append(contentsOf: respArray)
            }
        }
        else if identificationKey == "UpdateReminderHistory"{
            responseCount += 1
            if let respArray = response as? [ReminderHistory]{
                responseReminderHistoryArray.append(contentsOf: respArray)
            }
        }
        if (!addReminderHistoryList.isEmpty && !updateReminderHistoryList.isEmpty && responseCount == 2) || (responseCount == 1 && !updateReminderHistoryList.isEmpty && addReminderHistoryList.isEmpty) || (responseCount == 1 && updateReminderHistoryList.isEmpty && !addReminderHistoryList.isEmpty){
            
            hideActivityIndicator()
            if responseReminderHistoryArray.count == addReminderHistoryList.count + updateReminderHistoryList.count{
                
                reminderDetailDialogView?.onClickCloseBtn()
                historyDelegate?.updateHistorySuccess(msg: getString(key: "com.charmphr.reminder.reminderHistory.addOrUpdate.success.message"), addedOrUpdatedHistoryArray: addReminderHistoryList + updateReminderHistoryList)
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.alertError"), msg: "")
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "AddReminderHistory" || identificationKey == "UpdateReminderHistory"{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
//MARK: - ActivityIndicator Related methods
    
    private func showActivityIndicator(){
        self.view.bringSubviewToFront(reminderDetailDialogView?.activityIndicator ?? UIActivityIndicatorView())
        reminderDetailDialogView?.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    private func hideActivityIndicator(){
        reminderDetailDialogView?.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
}
