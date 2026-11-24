//
//  VaccineViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 10/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class VaccineViewController: CustomViewControllerWithTableView  , UITableViewDataSource, CharmConnectionHandlerDelegate, CharmConnectionV2HandlerDelegate , AddViewControllerDelegate
{
    var charmConnectionHandler : CharmConnectionHandler?
    var arrayOfVaccine : [VaccineImmunizationPOJO] = []
    
    var selectedVaccine: VaccineImmunizationPOJO?
    var selectedIndex: Int? = nil
    
    let isAddImmune = RbacUtil.checkPrivilege(privilege: .ADD_IMMUNE)
    
    var pageNo = 1
    var hasMoreVaccine = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        
        fetchVaccines()
        
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.estimatedRowHeight = UITableView.automaticDimension
        customTableView.tableFooterView = UIView()
        customTableView.register(VaccineTableViewCell.self, forCellReuseIdentifier: "VaccineTableViewCell")
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        
        self.navigationItem.title = getString(key: "com.charmphr.Immunizations.title")
        
        if isAddImmune && !AppConfig.sharedInstance.isCustomBrandApp && canAllowAddEntry{
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVaccineClicked)), animated: true)
        }
        
        customTableView.addInfiniteScrolling{
            self.fetchVaccines(fromScroll: true)
        }
    }
    
//MARK: - API call
    
    func fetchVaccines(fromScroll:Bool = false){
        if refreshControl.isRefreshing != true && !fromScroll{
            showActivityIndicator()
        }
        
        if fromScroll {
            pageNo = pageNo + 1
        }
        else{
            pageNo = 1
        }
        
        if charmConnectionHandler == nil{
            charmConnectionHandler = CharmConnectionHandler(delegate: self)
        }
        charmConnectionHandler?.v2Delegate = self
        charmConnectionHandler?.fetchVaccineList(pageNo:pageNo, identificationKey: "fetchVaccine")
    }
    
    // MARK: - tableviewdelegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfVaccine.isEmpty
        {
            if !AppConfig.sharedInstance.isCustomBrandApp
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.Procedures.NoImmunization.message"))")
            }else
            {
                bottomImageView.isHidden = true
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
        }
        else{
            bottomImageView.image = #imageLiteral(resourceName: "Vaccine_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfVaccine.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "VaccineTableViewCell") as? VaccineTableViewCell
        
        if let tableviewCell = tableviewCell{
            tableviewCell.delegate = self
            let vaccine = arrayOfVaccine[indexPath.row]
            tableviewCell.setTableViewCell(data: vaccine, indexPath: indexPath)
            
            let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
            tableviewCell.vaccineItemView.addGestureRecognizer(swiftLeft)
            
            let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftRight.direction = UISwipeGestureRecognizer.Direction.right
            tableviewCell.vaccineItemView.addGestureRecognizer(swiftRight)
            
            tableviewCell.vaccineItemView.deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))
            
            if let selectedIndex = selectedIndex{
                if indexPath.row == selectedIndex{
                    tableviewCell.vaccineItemView.setRowActionForSwipeLeft(duration: 0, vaccine: vaccine)
                }
                else{
                    tableviewCell.vaccineItemView.setRowActionForSwipeRight(duration: 0)
                }
            }
            
            return tableviewCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        hideSwipeActionButtons()
        let vaccine = arrayOfVaccine[indexPath.row]

        if vaccine.addedByPatient{
            if arrayOfVaccine.count > 0
            {
                selectedVaccine = arrayOfVaccine[indexPath.row]
                
                let editVaccineVC = AddVaccineViewController()
                editVaccineVC.delegate = self
                editVaccineVC.editVaccine = selectedVaccine
                self.navigationController?.pushViewController(editVaccineVC, animated: true)
            }
        }
    }
    
//MARK: - Other functions
    
    func deleteVaccine(at indexpath : IndexPath)
    {
        if self.charmConnectionHandler == nil
        {
            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        }
        
        activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.charmConnectionHandler?.deleteVaccines(patientId: getSelectedPatientId(), immuneHistoryId: arrayOfVaccine[indexpath.row].patientImmunizationMap?.patientImmunizationHistory?.immunizationHistoryId ?? "", identificationKey: "deleteVaccine_\(indexpath.row)")
    }
    
    func editVaccine(at indexpath : IndexPath)
    {
        selectedVaccine = arrayOfVaccine[indexpath.row]
        performSegue(withIdentifier: "AddVaccineVC", sender: self)
    }
    
    func hideSwipeActionButtons(){
        
        if let prebSelectedTVIndex = selectedIndex {
            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? VaccineTableViewCell {
                prevTableViewCell.vaccineItemView.setRowActionForSwipeRight(duration: 0.4)
                selectedIndex = nil
            }
        }
    }
    
//MARK: - Target functions
    
    @objc func onUIRefreshChange(){
        hideSwipeActionButtons()
        fetchVaccines()
    }
    
    @objc func addVaccineClicked(){
        selectedVaccine = nil
        performSegue(withIdentifier: "AddVaccineVC", sender: self)
    }
    
    @objc func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        if let vaccineItemView = sender.view as? VaccineItemView{
            if let tableViewCell = vaccineItemView.superview?.superview as? VaccineTableViewCell{
                
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
                            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? VaccineTableViewCell {
                                prevTableViewCell.vaccineItemView.setRowActionForSwipeRight(duration: 0.4)
                                selectedIndex = nil
                            }
                        }
                    }
                    if allowLeftSwipe{
                        selectedIndex = index
                        let vaccine = arrayOfVaccine[index]
                        vaccineItemView.setRowActionForSwipeLeft(duration: 0.4, vaccine: vaccine)
                    }
                case UISwipeGestureRecognizer.Direction.right:
                    if selectedIndex == index{
                        selectedIndex = nil
                        vaccineItemView.setRowActionForSwipeRight(duration: 0.4)
                    }
                default:
                    break
                }
            }
        }
    }
    
    @objc func onTouchLabel(sender: UITapGestureRecognizer){
        if let uiLabel = sender.view as? UILabel{
            if let vaccineItemView = uiLabel.superview as? VaccineItemView{
                if let tableViewCell = vaccineItemView.superview?.superview as? VaccineTableViewCell{
                    let indexPath: IndexPath = customTableView.indexPath(for: tableViewCell) ?? [0,0]
                    if selectedIndex != nil{
                        vaccineItemView.setRowActionForSwipeRight(duration: 0.4)
                    }
                    selectedIndex = nil
                    CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.Immunizations.alert.delete"), deleteClicked: {
                        self.deleteVaccine(at: indexPath)
                    })
                }
            }
        }
    }
    
    override func noDataViewRetryBtnClicked() {
        fetchVaccines()
    }

//MARK: - AddViewControllerDelegate function
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        fetchVaccines()
    }
    
//MARK: - CharmConnectionHandler Delegate
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {

        if identificationKey.hasPrefix("deleteVaccine")
        {
            activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                self.arrayOfVaccine.remove(at: row)
                
                removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
            }
            CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.Immunization.delete.successfull.message"), seconds: 2)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "fetchVaccine"{
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
        self.hideActivityIndicator()
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        hideActivityIndicator()
        if identificationKey == "fetchVaccine"{
            if let vaccineList = response as? [VaccineImmunizationPOJO] {
                
                if pageNo == 1{
                    
                    arrayOfVaccine = vaccineList
                    customTableView.reloadData()
                    
                }
                else{
                    if !vaccineList.isEmpty {
                        
                        var indexPathArr:[IndexPath] = []
                        let finalCount = arrayOfVaccine.count + vaccineList.count
                        for startIndex in (arrayOfVaccine.count...finalCount-1 ){
                            indexPathArr.append(IndexPath(row: startIndex, section: 0))
                        }
                        
                        customTableView.beginUpdates()
                        arrayOfVaccine.append(contentsOf: vaccineList)
                        customTableView.insertRows(at: indexPathArr, with: .top)
                        customTableView.endUpdates()
                    }
                    customTableView.infiniteScrollingView.stopAnimating()
                }
                
                hasMoreVaccine = vaccineList.count == listPerPageCount &&  getEnabledPractices(moduleId: vaccineModelId).count == 1
                
                customTableView.showsInfiniteScrolling = hasMoreVaccine
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddVaccineViewController
        {
            vc.delegate = self
            vc.editVaccine = selectedVaccine
        }
    }
}
