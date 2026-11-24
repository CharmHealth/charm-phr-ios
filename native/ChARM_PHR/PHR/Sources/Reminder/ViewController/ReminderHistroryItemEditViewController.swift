//
//  ReminderHistroryItemEditViewController.swift
//  phr
//
//  Created by prathi-13964 on 01/02/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation

protocol ReminderHistroryItemEditDelegate: AnyObject{
    func updateHistorySuccess(msg: String, addedOrUpdatedHistoryArray: [ReminderHistory])
}

class ReminderHistroryItemEditViewController: AddDataUIViewController, CharmConnectionV2HandlerDelegate{
    
    private var reminderHistroryItemEditView: ReminderHistroryItemEditView?
    private var charmConnectionHandler: CharmConnectionHandler? = nil
    var reminderHistoryGroup: ReminderHistoryGroupPOJO? = nil
    weak var delegate: ReminderHistroryItemEditDelegate? = nil
    private var updateReminderHistoryArray: [ReminderHistory] = []
    private var addReminderHistoryArray: [ReminderHistory] = []
    private var switchToHistoryTranformMap: [Int:ReminderHistoryTranformPOJO] = [:]
    private var switchToLabelMap: [Int: Int] = [:]
    private var tagNo = 100000
    private var isEditDone: Bool = false
    private var responseCount = 0
    private var responseArray: [ReminderHistory] = []
    private var isUpdateReminder: Bool = false
    private var isAddReminder: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onClickDone))
        reminderHistroryItemEditView = ReminderHistroryItemEditView(delegate: self)
        
        if let reminderHistroryItemEditView = reminderHistroryItemEditView{
            self.view = reminderHistroryItemEditView
            if let reminderHistoryGroup = reminderHistoryGroup{
                self.title = reminderHistoryGroup.date?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT)
                
                reminderHistoryGroup.reminderHistoryTranformList.forEach { reminderHistoryTranformPOJO in
                    reminderHistroryItemEditView.setTimeView(reminderHistoryTranform: reminderHistoryTranformPOJO)
//                    if reminderHistoryTranformPOJO.time?.getStringFromDate(dateFormat: Time24HoursFormat) ?? "" < Date().getStringFromDate(dateFormat: Time24HoursFormat){
//
//                    }
                }
            }
        }
    }
    
//MARK: - Target functions
    
    @objc private func onChangeSwitch(_ sender: UISwitch){
        isEditDone = true
        let labelTag = switchToLabelMap[sender.tag] ?? -1
        if let statusLabel = self.view.viewWithTag(labelTag) as? UILabel{
            if sender.isOn{
                statusLabel.isHidden = false
            }
            else{
                statusLabel.isHidden = true
            }
        }
    }
    
    @objc private func onClickDone(){
        
        reminderHistroryItemEditView?.historyEditStackView.subviews.forEach({ statusItemView in
            if let historyStatusSwitch = statusItemView.subviews.first(where: { uiView in
                return uiView is UISwitch
            }) as? UISwitch{
                let reminderHistoryTranformObj = switchToHistoryTranformMap[historyStatusSwitch.tag]
                if let reminderHistoryObj = reminderHistoryTranformObj?.reminderHistory{
                    let reminderHistory = ReminderHistory()
                    if historyStatusSwitch.isOn{
                        reminderHistory.status = 1
                    }
                    else{
                        reminderHistory.status = 0
                    }
                    reminderHistory.reminderFrequency = reminderHistoryObj.reminderFrequency
                    reminderHistory.statusUpdatedTime = Date()
                    reminderHistory.reminderId = reminderHistoryObj.reminderId
                    reminderHistory.historyId = reminderHistoryObj.historyId
                    
                    updateReminderHistoryArray.append(reminderHistory)
                }
                else{
                    let reminderHistory = ReminderHistory()
                    if historyStatusSwitch.isOn{
                        reminderHistory.status = 1
                    }
                    else{
                        reminderHistory.status = 0
                    }
                    reminderHistory.reminderFrequency = reminderHistoryTranformObj?.reminderFrequency
                    reminderHistory.statusUpdatedTime = Date()
                    reminderHistory.reminderId = reminderHistoryTranformObj?.reminder?.reminderId
                    
                    addReminderHistoryArray.append(reminderHistory)
                }
            }
        })
        
        showActivityIndicator()
        
        responseCount = 0
        responseArray = []
        
        if !updateReminderHistoryArray.isEmpty{
            isUpdateReminder = true
            charmConnectionHandler?.updateReminderHistory(reminderHistoryArray: updateReminderHistoryArray, identificationKey: "UpdateReminderHistory")
        }
        
        if !addReminderHistoryArray.isEmpty{
            isAddReminder = true
            charmConnectionHandler?.addReminderHistory(reminderHistoryArray: addReminderHistoryArray, identificationKey: "AddReminderHistory")
        }
    }
    
    override func onBackClick() {
        
        if isEditDone{
            showDiscardChangesDialog()
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//MARK: - Other functions
    
    func setSwitchToHistoryTranformAndLabelMap(historyStatusSwitch: UISwitch, reminderHistoryTranform: ReminderHistoryTranformPOJO, uiLabel: UILabel){
        historyStatusSwitch.tag = tagNo
        tagNo += 1
        uiLabel.tag = tagNo
        tagNo += 1
        
        switchToHistoryTranformMap[historyStatusSwitch.tag] = reminderHistoryTranform
        switchToLabelMap[historyStatusSwitch.tag] = uiLabel.tag
        historyStatusSwitch.addTarget(self, action: #selector(onChangeSwitch(_:)), for: .valueChanged)
    }
    
    private func showActivityIndicator(){
        reminderHistroryItemEditView?.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
        self.view.bringSubviewToFront( reminderHistroryItemEditView?.activityIndicator ?? UIActivityIndicatorView())
    }
    
    private func hideActivityIndicator(){
        reminderHistroryItemEditView?.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = true
    }
    
//MARK: - CharmConnectionHandler Delegate

    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String){
        if identificationKey == "UpdateReminderHistory"{
            responseCount += 1
            if let respArray = response as? [ReminderHistory]{
                responseArray.append(contentsOf: respArray)
            }
        }
        else if identificationKey == "AddReminderHistory"{
            responseCount += 1
            if let respArray = response as? [ReminderHistory]{
                responseArray.append(contentsOf: respArray)
            }
        }
        if ((responseCount == 2 && isAddReminder && isUpdateReminder) || (responseCount == 1 && isAddReminder) || (responseCount == 1 && isUpdateReminder)){
            hideActivityIndicator()
            if responseArray.count == addReminderHistoryArray.count + updateReminderHistoryArray.count{
                self.navigationController?.popViewController(animated: true)
                delegate?.updateHistorySuccess(msg: getString(key: "com.charmphr.reminder.reminderHistory.addOrUpdate.success.message"), addedOrUpdatedHistoryArray: responseArray)
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.alertError"), msg: "")
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "UpdateReminderHistory" || identificationKey == "AddReminderHistory"{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
}
