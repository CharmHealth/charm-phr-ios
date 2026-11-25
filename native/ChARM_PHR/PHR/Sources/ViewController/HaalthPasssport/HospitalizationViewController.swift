////
////  HospitalizationViewController.swift
////  phr
////
////  Created by Sankar Saravanan on 30/08/20.
////  Copyright © 2020 Dhanuprasanya P. All rights reserved.
////
//
//import UIKit
//
//class HospitalizationViewController: CustomViewControllerWithTableView, CharmConnectionHandlerDelegate, UITableViewDataSource, AddViewControllerDelegate
//{
//
//    var charmConnectionHandler : CharmConnectionHandler!
//    var arrayOfProcedure : [ProceduresList] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.changeBackGroundColor(color: APPLICATION_BACKGROUND_COLOR)
//        self.createTableviewAndSubViews(tableViewStyle: .plain)
//        self.navigationItem.title = NSLocalizedString("com.charmphr.Hospitalization.title", comment: "")
//        self.navigationItem.backBarButtonItem?.title = NSLocalizedString("com.charmphr.healthPassport.back.title", comment: "")
//        
//        charmConnectionHandler = CharmConnectionHandler(delegate: self)
//        fetchHospitalization()
//        
//        customTableView.delegate = self
//        customTableView.dataSource = self
//        customTableView.tableFooterView = UIView()
//        customTableView.register(UINib(nibName: "KeyValueAndDateLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "KeyValueAndDateLabelTableViewCell")
//        
//        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
//        
//        //TODO: change image
//    }
//    
//    //MARK: uitableview delegate
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if arrayOfProcedure.count > 4 || arrayOfProcedure.count == 0
//        {
//            if arrayOfProcedure.count == 0
//            {
//                self.noDataBackGroundView.setImage(enum: .noData, title: NSLocalizedString("com.charmphr.action.noData.title", comment: ""), message: "\(NSLocalizedString("com.charmphr.action.noData.message", comment: ""))\(NSLocalizedString("com.charmphr.Hospitalization.noData.title", comment: ""))")
//            }
//            else
//            {
//                self.noDataBackGroundView.hideSubView(bool: true)
//            }
//        }else
//        {
//            self.noDataBackGroundView.hideSubView(bool: true)
//        }
//        return arrayOfProcedure.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyValueAndDateLabelTableViewCell") as! KeyValueAndDateLabelTableViewCell
//        
//        let procedure = arrayOfProcedure[indexPath.row]
//        cell.keyLabel.text = procedure.procedureName
//        cell.valueLabel.text = procedure.procedureType ?? ""
//        cell.dateLabel.text = CharmUtil.getDateStringWith(date: procedure.fromDate, dateFormat: PHR_DATE_DISPLAY_FORMAT)
//        
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        super.tableView(tableView, didSelectRowAt: indexPath)
//        let editProcedure = arrayOfProcedure[indexPath.row]
//        let addHospitalizationVC = AddHospitalizationViewController()
//        addHospitalizationVC.delegate = self
//        addHospitalizationVC.editProcedure = editProcedure
//        self.navigationController?.pushViewController(addHospitalizationVC, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        
//        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("com.charmphr.action.delete", comment: "")) { action, index in
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            
//            alertController.message = NSLocalizedString("com.charmphr.Procedures.alert.delete", comment: "")
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
//            alertController.message = NSLocalizedString("com.charmphr.Procedures.alert.edit", comment: "")
//            
//            let editAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.edit", comment: ""), style: .destructive) { (deleteAction) in
//                self.editMedicalConditionInRow(at: indexPath)
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
//    func fetchHospitalization()
//    {
//        showActivityIndicator()
//        charmConnectionHandler.fetchProcedureList(patientId: Patient.selectedPatientInstance!.patientId,isHealthPassport: true, identificationKey: "fetchProcedureList")
//    }
//    
//    @objc func addButtonClicked()
//    {
//        let addHospitalizationVC = AddHospitalizationViewController()
//        addHospitalizationVC.delegate = self
//        self.navigationController?.pushViewController(addHospitalizationVC, animated: true)
//    }
//    
//    func addViewControllerDataAdded() {
//        fetchHospitalization()
//    }
//    
//    func editMedicalConditionInRow(at indexPath : IndexPath)
//    {
//        let editProcedure = arrayOfProcedure[indexPath.row]
//        let addHospitalizationVC = AddHospitalizationViewController()
//        addHospitalizationVC.delegate = self
//        addHospitalizationVC.editProcedure = editProcedure
//        self.navigationController?.pushViewController(addHospitalizationVC, animated: true)
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
//        charmConnectionHandler.deleteProcedure(patientId: Patient.selectedPatientInstance!.patientId, isHealthPassport: true, procedureMapId: arrayOfProcedure[indexpath.row].procedureMapId, identificationKey: "deleteProcedure_\(indexpath.row)")
//    }
//    
//    // MARK: charm connection Handler delegate
//    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
//        if identificationKey == "fetchProcedureList"
//        {
//            let parsingHelper = ParsingHelper()
//            arrayOfProcedure = parsingHelper.fillArrayOfProceduresWithDictionary(dict: (jsonObject["output_string"] as? [Dictionary<String,Any>])!)
//            hideActivityIndicator()
//            customTableView.reloadData()
//        }
//        else if identificationKey.hasPrefix("deleteProcedure")
//        {
//            activityIndicatorView.stopAnimating()
//            
//            let row = Int(identificationKey.components(separatedBy: "_").last!)!
//            arrayOfProcedure.remove(at: row)
//            
//            self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
//        }
//    }
//    
//    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
//        if identificationKey == "fetchProcedureList"
//        {
//            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(forCode: CharmUtil.getErrorCode(error: error)), message: nil)
//        }
//        else
//        {
//            CharmUtil.createOkayAlertWith(error: error)
//        }
//        
//        self.hideActivityIndicator()
//    }
//
//}
