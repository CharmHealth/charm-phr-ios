////
////  CurrentMedicationsViewController.swift
////  phr
////
////  Created by Sankar Saravanan on 26/08/20.
////  Copyright © 2020 Dhanuprasanya P. All rights reserved.
////
//
//import UIKit
//
//class CurrentMedicationsViewController: CustomViewControllerWithTableView, CharmConnectionHandlerDelegate , UITableViewDataSource, AddViewControllerDelegate
//{
//
//    var charmConnectionHandler : CharmConnectionHandler!
//    var arrayOfMedication : [MedicationPOJO] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.changeBackGroundColor(color: APPLICATION_BACKGROUND_COLOR)
//        self.createTableviewAndSubViews(tableViewStyle: .plain)
//        self.navigationItem.title = NSLocalizedString("com.charmphr.cureentMedication.title", comment: "")
//        self.navigationItem.backBarButtonItem?.title = NSLocalizedString("com.charmphr.healthPassport.back.title", comment: "")
//
//        charmConnectionHandler = CharmConnectionHandler(delegate: self)
//        fetchCurrentMedications()
//
//        customTableView.delegate = self
//        customTableView.dataSource = self
//        customTableView.tableFooterView = UIView()
//        customTableView.register(UINib(nibName: "KeyAndValueInVerticalTableViewCell", bundle: nil), forCellReuseIdentifier: "KeyAndValueInVerticalTableViewCell")
//
//        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
//
//        //TODO: change image
//        bottomImageView.image = #imageLiteral(resourceName: "Medication_HP_BG")
//    }
//
//    //MARK: uitableview delegate
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if arrayOfMedication.count > 4 || arrayOfMedication.count == 0
//        {
//            bottomImageView.isHidden = true
//            if arrayOfMedication.count == 0
//            {
//                self.noDataBackGroundView.setImage(enum: .noData, title: NSLocalizedString("com.charmphr.action.noData.title", comment: ""), message: "\(NSLocalizedString("com.charmphr.action.noData.message", comment: ""))\(NSLocalizedString("com.charmphr.prescriptions.nomedications.title", comment: ""))")
//            }
//            else
//            {
//                self.noDataBackGroundView.hideSubView(bool: true)
//            }
//        }else
//        {
//            bottomImageView.isHidden = false
//            self.noDataBackGroundView.hideSubView(bool: true)
//        }
//        return arrayOfMedication.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyAndValueInVerticalTableViewCell") as! KeyAndValueInVerticalTableViewCell
//
//        cell.keyLabel.text = arrayOfMedication[indexPath.row].prescriptionName
//        if arrayOfMedication[indexPath.row].isActive
//        {
//            cell.valueLabel.text = "Active"
//        }else
//        {
//            cell.valueLabel.text = "Inactive"
//        }
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        super.tableView(tableView, didSelectRowAt: indexPath)
//        let editMedication = arrayOfMedication[indexPath.row]
//        let addMedicationVC = AddMedicationViewController()
//        addMedicationVC.delegate = self
//        addMedicationVC.editMedication = editMedication
//        self.navigationController?.pushViewController(addMedicationVC, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("com.charmphr.action.delete", comment: "")) { action, index in
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//            alertController.message = NSLocalizedString("com.charmphr.prescriptions.alert.delete.medication", comment: "")
//
//            let deleteAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.delete", comment: ""), style: .destructive) { (deleteAction) in
//                self.deleteTableviewCellCalled(at: indexPath)
//            }
//            let cancelAction =  CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.cancel", comment: ""), style: .cancel, handler: nil)
//            alertController.addAction(deleteAction)
//            alertController.addAction(cancelAction)
//            alertController.show()
//        }
//        let editAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("com.charmphr.action.edit", comment: "")) { action, index in
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//            alertController.message = NSLocalizedString("com.charmphr.prescriptions.alert.edit.medication", comment: "")
//
//            let editAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.edit", comment: ""), style: .destructive) { (deleteAction) in
//                self.editPrescriptionInRow(at: indexPath)
//            }
//            let cancelAction =  CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.cancel", comment: ""), style: .cancel, handler: nil)
//            alertController.addAction(editAction)
//            alertController.addAction(cancelAction)
//            alertController.show()
//        }
//
//        return [deleteAction,editAction]
//    }
//
//    //MARK: other methods
//    func fetchCurrentMedications()
//    {
//        showActivityIndicator()
//        charmConnectionHandler.fetchPrescrition(patientId: Patient.selectedPatientInstance!.patientId,isHealthCard: true, identificationKey: "FetchMedication")
//    }
//
//    @objc func addButtonClicked()
//    {
//        let addMedicationVC = AddMedicationViewController()
//        addMedicationVC.delegate = self
//        addMedicationVC.isHealthPassport = true
//        self.navigationController?.pushViewController(addMedicationVC, animated: true)
//    }
//
//    func addViewControllerDataAdded() {
//        fetchCurrentMedications()
//    }
//
//    func editPrescriptionInRow(at indexPath : IndexPath)
//    {
//        let editMedication = arrayOfMedication[indexPath.row]
//        let addMedicationVC = AddMedicationViewController()
//        addMedicationVC.delegate = self
//        addMedicationVC.editMedication = editMedication
//        self.navigationController?.pushViewController(addMedicationVC, animated: true)
//    }
//
//    func deleteTableviewCellCalled(at indexpath : IndexPath)
//    {
//        if self.charmConnectionHandler == nil
//        {
//            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
//        }
//
//        activityIndicatorView.startAnimating()
//        self.charmConnectionHandler?.deleteMedication(patientId: Patient.selectedPatientInstance!.patientId, prescriptionHistoryId: arrayOfMedication[indexpath.row].prescriptionHistoryId,isHealthPassport: true , identificationKey: "deleteMedication_\(indexpath.row)")
//    }
//
//    // MARK: charm connection Handler delegate
//    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
//        if identificationKey == "FetchMedication"
//        {
//            let parsingHelper = ParsingHelper()
//            arrayOfMedication = parsingHelper.fillArrayOfMedicationsWithDictionary(dict: jsonObject["output_string"] as! Dictionary<String,Any>, practiceId:"")
//            hideActivityIndicator()
//            customTableView.reloadData()
//        }
//        else if identificationKey.hasPrefix("deleteMedication")
//        {
//            activityIndicatorView.stopAnimating()
//
//            let row = Int(identificationKey.components(separatedBy: "_").last!)!
//            arrayOfMedication.remove(at: row)
//
//            self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
//
//            AppDataHandler.sharedInstance().refreshMedication = true
//        }
//    }
//
//    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
//        if identificationKey == "FetchMedication"
//        {
//            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(forCode: CharmUtil.getErrorCode(error: error)), message: nil)
//            self.noDataBackGroundView.hideTryAgainBtn(bool: false)
//        }
//        else
//        {
//            CharmUtil.createOkayAlertWith(error: error)
//        }
//
//        self.hideActivityIndicator()
//    }
//
//
//
//}
