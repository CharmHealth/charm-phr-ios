//
//  SelectPrescriptionViewController.swift
//  phr
//
//  Created by prathi-13964 on 23/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

class SelectPrescriptionViewController: CustomViewControllerWithTableView, UITableViewDataSource, AddReminderDelegate, CharmConnectionV2HandlerDelegate, SupplementItemDelegate, MedicationItemDelegate{
    
    var isMedication: Bool = true
    private var charmConnectionHandler: CharmConnectionHandler?
    private var arrayOfSupplement : [SupplementGroupPOJO] = []
    private var arrayOfMedication : [MedicationGroupPOJO] = []
    weak var delegate: AddReminderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isMedication{
            self.navigationItem.title = getString(key: "com.charmphr.reminder.selectPrescription.medication.title")
        }
        else{
            self.navigationItem.title = getString(key: "com.charmphr.reminder.selectPrescripiton.supplement.title")
        }
        
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        
        self.navigationItem.backButtonDisplayMode = .default
       
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        customTableView.separatorColor = .clear
        customTableView.tableFooterView =  UIView()
        customTableView.register(MedicationTableViewCell.self, forCellReuseIdentifier: "MedicationTableViewCell")
        customTableView.register(SupplementTableViewCell.self, forCellReuseIdentifier: "SupplementTableViewCell")
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.dataSource = self
        
        if isMedication{
            fetchMedication()
        }
        else{
            fetchSupplement()
        }
    }
    
    @objc private func onUIRefreshChange(){
        if isMedication{
            fetchMedication()
        }
        else{
            fetchSupplement()
        }
    }
    
//MARK: - API calls
    
    private func fetchMedication(){
        if !refreshControl.isRefreshing{
            showActivityIndicator()
        }
        charmConnectionHandler?.fetchMedicationList(viewType: PrescriptionFilterType.Active.rawValue, patientId: getSelectedPatientId(), identificationKey: "fetchMedication")
    }
    
    private func fetchSupplement(){
        if !refreshControl.isRefreshing{
            showActivityIndicator()
        }
        charmConnectionHandler?.fetchSupplementList(viewType: PrescriptionFilterType.Active.rawValue, identificationKey: "fetchSupplement", patientId: getSelectedPatientId())
    }
    
//MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMedication{
            if arrayOfMedication.isEmpty
            {
                if !AppConfig.sharedInstance.isCustomBrandApp
                {
                    bottomImageView.image = nil
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }else
                {
                    bottomImageView.isHidden = true
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
            }
            else
            {
                bottomImageView.image = #imageLiteral(resourceName: "Medication_HP_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfMedication.count
        }
        else{
            if arrayOfSupplement.isEmpty
            {
                if !AppConfig.sharedInstance.isCustomBrandApp
                {
                    bottomImageView.image = nil
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }else
                {
                    bottomImageView.isHidden = true
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
            }
            else
            {
                bottomImageView.image = #imageLiteral(resourceName: "Medication_HP_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfSupplement.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if isMedication{
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "MedicationTableViewCell") as? MedicationTableViewCell
            if let tableViewCell = tableViewCell{
                tableViewCell.delegate = self
                tableViewCell.isFromReminderSelect = true
                let medication = arrayOfMedication[indexPath.row]
                tableViewCell.setTableViewCell(data: medication , indexPath: indexPath)
                cell = tableViewCell
            }
        }else{
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "SupplementTableViewCell") as? SupplementTableViewCell
            if let tableViewCell = tableViewCell{
                tableViewCell.delegate = self
                tableViewCell.isFromReminderSelect = true
                let supplement = arrayOfSupplement[indexPath.row]
                tableViewCell.setTableViewCell(data: supplement)
                cell = tableViewCell
            }
        }
        return cell ?? UITableViewCell()
    }
    
    func supplementAction(action: PrescriptionAction, supplementPOJO: SupplementPOJO?, viewTag: Int?) {
        if action == .DID_SELECT, let supplementPOJO{
            let addReminderVC = AddReminderViewController()
            addReminderVC.delegate = self
            addReminderVC.addReminderTransformModel = TransformUtil.transformSupplementToReminderModel(supplementPOJO: supplementPOJO)
            self.navigationController?.pushViewController(addReminderVC, animated: true)
        }
    }
    
    func medicationAction(action: PrescriptionAction, medicationPOJO: MedicationPOJO?, viewTag: Int?) {
        if action == .DID_SELECT, let medicationPOJO{
            let addReminderVC = AddReminderViewController()
            addReminderVC.delegate = self
            addReminderVC.addReminderTransformModel = TransformUtil.transformMedicationToReminderModel(medicationPOJO: medicationPOJO)
            self.navigationController?.pushViewController(addReminderVC, animated: true)
        }
    }
    
    func beginUpdates() {
        customTableView.beginUpdates()
    }
    
    func endUpdates() {
        customTableView.endUpdates()
    }
    
    func reloadData(at indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            self.customTableView.beginUpdates()
            self.customTableView.reloadRows(at: [indexPath], with: .none)
            self.customTableView.endUpdates()
        }
    }
    
//MARK: - AddReminder Delegate
    
    func addReminderFailed(msg: String) {
        CharmUtil.createOkayAlertWith(title: nil, msg: "\(msg). \(getString(key: "com.charmphr.reminder.addReminder.duplicateReminder.error.title"))")
    }
    
    func reminderAdded(msg: String) {
        delegate?.reminderAdded(msg: msg)
    }
    
//MARK: - ConnectionHandler delegate functions
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "fetchMedication"{
            if let list = response as? [MedicationPOJO]{
                arrayOfMedication = PatientDataHandler.groupMedication(medicationArr: list)
            }
        }
        else if identificationKey == "fetchSupplement"{
            if let list = response as? [SupplementPOJO]{
                arrayOfSupplement = PatientDataHandler.groupSupplement(supplementArr: list)
            }
        }
        customTableView.reloadData()
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
}

