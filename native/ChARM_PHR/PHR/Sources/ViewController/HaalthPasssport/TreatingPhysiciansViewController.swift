////
////  TreatingPhysiciansViewController.swift
////  phr
////
////  Created by Sankar Saravanan on 29/08/20.
////  Copyright © 2020 Dhanuprasanya P. All rights reserved.
////
//
//import UIKit
//
//class TreatingPhysiciansViewController: CustomViewControllerWithTableView, CharmConnectionHandlerDelegate, UITableViewDataSource, AddViewControllerDelegate
//{
//
//    var charmConnectionHandler : CharmConnectionHandler!
//    var arrayOfTreatingPhysicians : [Provider] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.changeBackGroundColor(color: APPLICATION_BACKGROUND_COLOR)
//        self.createTableviewAndSubViews(tableViewStyle: .plain)
//        self.navigationItem.title = NSLocalizedString("com.charmphr.TreatingPhysicians.title", comment: "")
//        self.navigationItem.backBarButtonItem?.title = NSLocalizedString("com.charmphr.healthPassport.back.title", comment: "")
//
//        charmConnectionHandler = CharmConnectionHandler(delegate: self)
//        fetchTreatingPhysicians()
//
//        customTableView.delegate = self
//        customTableView.dataSource = self
//        customTableView.tableFooterView = UIView()
//        customTableView.register(UINib(nibName: "KeyAndValueInVerticalTableViewCell", bundle: nil), forCellReuseIdentifier: "KeyAndValueInVerticalTableViewCell")
//
//        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
//
//        //TODO: change image
//    }
//
//    //MARK: uitableview delegate
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if arrayOfTreatingPhysicians.count > 4 || arrayOfTreatingPhysicians.count == 0
//        {
//            if arrayOfTreatingPhysicians.count == 0
//            {
//                self.noDataBackGroundView.setImage(enum: .noData, title: NSLocalizedString("com.charmphr.action.noData.title", comment: ""), message: "\(NSLocalizedString("com.charmphr.action.noData.message", comment: ""))\(NSLocalizedString("com.charmphr.TreatingPhysicians.noData.title", comment: ""))")
//            }
//            else
//            {
//                self.noDataBackGroundView.hideSubView(bool: true)
//            }
//        }else
//        {
//            self.noDataBackGroundView.hideSubView(bool: true)
//        }
//        return arrayOfTreatingPhysicians.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyAndValueInVerticalTableViewCell") as! KeyAndValueInVerticalTableViewCell
//
//        let treatingPhysicians = arrayOfTreatingPhysicians[indexPath.row]
//        cell.keyLabel.text = treatingPhysicians.fullName
//        cell.valueLabel.text = treatingPhysicians.phoneNumber ?? ""
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        super.tableView(tableView, didSelectRowAt: indexPath)
//        let editTreatingPhysicians = arrayOfTreatingPhysicians[indexPath.row]
//        let addTreatingPhysiciansVC = AddTreatingPhysiciansViewController()
//        addTreatingPhysiciansVC.delegate = self
//        addTreatingPhysiciansVC.editTreatingPhysician = editTreatingPhysicians
//        self.navigationController?.pushViewController(addTreatingPhysiciansVC, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("com.charmphr.action.delete", comment: "")) { action, index in
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//            alertController.message = NSLocalizedString("com.charmphr.TreatingPhysicians.alert.delete", comment: "")
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
//            alertController.message = NSLocalizedString("com.charmphr.TreatingPhysicians.alert.edit", comment: "")
//
//            let editAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.edit", comment: ""), style: .destructive) { (deleteAction) in
//                self.editPhysicianInRow(at: indexPath)
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
//    func fetchTreatingPhysicians()
//    {
//        showActivityIndicator()
//        charmConnectionHandler.fetchTreatingPhysicians(patientId: Patient.selectedPatientInstance!.patientId, identificationKey: "fetchTreatingPhysicians")
//    }
//
//    @objc func addButtonClicked()
//    {
//        let addTreatingPhysiciansVC = AddTreatingPhysiciansViewController()
//        addTreatingPhysiciansVC.delegate = self
//        self.navigationController?.pushViewController(addTreatingPhysiciansVC, animated: true)
//    }
//
//    func addViewControllerDataAdded() {
//        fetchTreatingPhysicians()
//    }
//
//    func editPhysicianInRow(at indexPath : IndexPath)
//    {
//        let editTreatingPhysician = arrayOfTreatingPhysicians[indexPath.row]
//        let addTreatingPhysiciansVC = AddTreatingPhysiciansViewController()
//        addTreatingPhysiciansVC.delegate = self
//        addTreatingPhysiciansVC.editTreatingPhysician = editTreatingPhysician
//        self.navigationController?.pushViewController(addTreatingPhysiciansVC, animated: true)
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
//        self.charmConnectionHandler?.deleteTreatingPhysician(treatingPhysicianID: arrayOfTreatingPhysicians[indexpath.row].facilityId, identificationKey: "deleteTreatingPhysicians_\(indexpath.row)")
//    }
//
//    // MARK: charm connection Handler delegate
//    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
//        if identificationKey == "fetchTreatingPhysicians"
//        {
//            let parsingHelper = ParsingHelper()
//            arrayOfTreatingPhysicians = parsingHelper.getArrayOfTreatingPhysicians(dict: jsonObject)
//            hideActivityIndicator()
//            customTableView.reloadData()
//        }
//        else if identificationKey.hasPrefix("deleteTreatingPhysicians")
//        {
//            activityIndicatorView.stopAnimating()
//
//            let row = Int(identificationKey.components(separatedBy: "_").last!)!
//            arrayOfTreatingPhysicians.remove(at: row)
//
//            self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
//        }
//    }
//
//    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
//        if identificationKey == "fetchTreatingPhysicians"
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
//
//
//}
