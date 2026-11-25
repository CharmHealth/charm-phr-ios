//
//  ProceduresViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 02/12/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ProceduresViewController: CustomViewControllerWithTableView , CharmConnectionHandlerDelegate , UITableViewDataSource , AddViewControllerDelegate, CharmConnectionV2HandlerDelegate
{
    var charmConnectionHandler : CharmConnectionHandler?
    var arrayOfProcedures : [ProceduresList] = []
    var selectedProcedures : ProceduresList?
    
    let isAddProcedure = RbacUtil.checkPrivilege(privilege: .ADD_PROCEDURE)
    let isDeleteProcedure = RbacUtil.checkPrivilege(privilege: .DELETE_PROCEDURE)
    
    var selectedIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        self.navigationItem.title = getString(key: "com.charmphr.Procedures.title")
        
        fetchProcedures()
        
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        customTableView.delegate = self
        customTableView.register(ProceduresTableViewCell.self, forCellReuseIdentifier: "ProceduresTableViewCell")
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        
        showActivityIndicator()
        
        if isAddProcedure && !AppConfig.sharedInstance.isCustomBrandApp  && canAllowAddEntry
        {
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProceduresClicked)), animated: true)
        }
    }
    
    @objc func onUIRefreshChange(){
        fetchProcedures()
    }
    
    func fetchProcedures()
    {
        if refreshControl.isRefreshing != true{
            showActivityIndicator()
        }
        
        if charmConnectionHandler == nil
        {
            charmConnectionHandler = CharmConnectionHandler(delegate: self)
            charmConnectionHandler?.v2Delegate = self
        }
        charmConnectionHandler?.fetchProcedureList(identificationKey: "fetchProcedures")
    }
    
    @objc func addProceduresClicked()
    {
        selectedProcedures = nil
        performSegue(withIdentifier: "addProceduresVC", sender: self)
    }
    
// MARK: - tableviewdelegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfProcedures.isEmpty
        {
            if !AppConfig.sharedInstance.isCustomBrandApp
            {
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.Procedures.NoProcedures.message"))")
            }else
            {
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
        }else
        {
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfProcedures.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "ProceduresTableViewCell") as? ProceduresTableViewCell
            
        if let tableviewCell = tableviewCell{
            let procedures = arrayOfProcedures[indexPath.row]
            tableviewCell.setTableViewCell(data: procedures)
            
            let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
            tableviewCell.proceduresItemView.addGestureRecognizer(swiftLeft)
            
            let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftRight.direction = UISwipeGestureRecognizer.Direction.right
            tableviewCell.proceduresItemView.addGestureRecognizer(swiftRight)
            
            tableviewCell.proceduresItemView.deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))
            
            if let selectedIndex = selectedIndex{
                if indexPath.row == selectedIndex{
                    tableviewCell.proceduresItemView.setRowActionForSwipeLeft(duration: 0)
                }
                else{
                    tableviewCell.proceduresItemView.setRowActionForSwipeRight(duration: 0)
                }
            }
            return tableviewCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        hideSwipeActionButtons()
        if arrayOfProcedures.count > 0
        {
            selectedProcedures = arrayOfProcedures[indexPath.row]
            
            let addProceduresViewController = AddProceduresViewController()
            addProceduresViewController.delegate = self
            addProceduresViewController.editProcedureList = selectedProcedures
            self.navigationController?.pushViewController(addProceduresViewController, animated: true)
        }
    }
    
    
    
//MARK: - Other functions
    
    func hideSwipeActionButtons(){
        if let prebSelectedTVIndex = selectedIndex {
            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? ProceduresTableViewCell {
                prevTableViewCell.proceduresItemView.setRowActionForSwipeRight(duration: 0.4)
                selectedIndex = nil
            }
        }
    }
    
    @objc func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        if let proceduresItemView = sender.view as? ProceduresItemView{
            if let tableViewCell = proceduresItemView.superview?.superview as? ProceduresTableViewCell{
                let index: Int = customTableView.indexPath(for: tableViewCell)?.row ?? -1
                switch sender.direction {
                case UISwipeGestureRecognizer.Direction.left:
                    var allowLeftSwipe = true
                    if let prebSelectedTVIndex = selectedIndex {
                        if prebSelectedTVIndex == index {
                            allowLeftSwipe = false
                        }
                        else{
                            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
                            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? ProceduresTableViewCell {
                                prevTableViewCell.proceduresItemView.setRowActionForSwipeRight(duration: 0.4)
                                selectedIndex = nil
                            }
                        }
                    }
                    if allowLeftSwipe{
                        selectedIndex = index
                        proceduresItemView.setRowActionForSwipeLeft(duration: 0.4)
                    }
                case UISwipeGestureRecognizer.Direction.right:
                    if selectedIndex == index{
                        selectedIndex = nil
                        proceduresItemView.setRowActionForSwipeRight(duration: 0.4)
                    }
                default:
                    break
                }
            }
        }
    }
    
    @objc func onTouchLabel(sender: UITapGestureRecognizer){
        if let uiLabel = sender.view as? UILabel{
            if let proceduresItemView = uiLabel.superview as? ProceduresItemView{
                if let tableViewCell = proceduresItemView.superview?.superview as? ProceduresTableViewCell{
                    let indexPath: IndexPath = customTableView.indexPath(for: tableViewCell) ?? [0,0]
                    if selectedIndex != nil{
                        proceduresItemView.setRowActionForSwipeRight(duration: 0.4)
                    }
                    selectedIndex = nil
                    CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.Procedures.alert.delete"), deleteClicked: {
                        self.deleteProcedure(at: indexPath)
                    })
                }
            }
        }
    }
    
    func deleteProcedure(at indexpath : IndexPath)
    {
        if self.charmConnectionHandler == nil
        {
            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        }
        
        activityIndicatorView.startAnimating()
        self.charmConnectionHandler?.deleteProcedure(patientId: Patient.selectedPatientInstance?.patientId ?? "", procedureMapId: arrayOfProcedures[indexpath.row].procedureMapId ?? "", identificationKey: "removeProcedure_\(indexpath.row)")
    }
//MARK: - CharmConnectionHandler Delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchProcedures"{
            hideActivityIndicator()
            if let resp = response as? [ProceduresList]{
                arrayOfProcedures = resp
                customTableView.reloadData()
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if refreshControl.isRefreshing == true{
            refreshControl.endRefreshing()
        }
        if identificationKey == "fetchProcedures"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
        hideActivityIndicator()
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        hideActivityIndicator()

        if identificationKey.hasPrefix("removeProcedure")
        {
            activityIndicatorView.stopAnimating()
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                arrayOfProcedures.remove(at: row)
                self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
            }
            CharmUtil.showToast(controller: self, message: jsonObject.getString("message"), seconds: 2)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {

        CharmUtil.createOkayAlertWith(error: error)
        self.hideActivityIndicator()
    }
    
    override func noDataViewRetryBtnClicked() {
        fetchProcedures()
    }
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        arrayOfProcedures = []
        fetchProcedures()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddProceduresViewController
        {
            vc.delegate = self
            vc.editProcedureList = selectedProcedures
        }
    }
}
