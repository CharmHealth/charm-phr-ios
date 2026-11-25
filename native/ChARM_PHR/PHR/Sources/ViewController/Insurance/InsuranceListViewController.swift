//
//  InsuranceListViewController.swift
//  phr
//
//  Created by Raghul D on 31/05/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation

class InsuranceListViewController: CustomViewControllerWithTableView, CharmConnectionV2HandlerDelegate, UITableViewDataSource , AddViewControllerDelegate
{
    var charmConnectionHandler : CharmConnectionHandler?
    var insuranceList : [PatientInsuranceDetails] = []
    var selectedInsurance: PatientInsuranceDetails?
    var selectedIndex: Int? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)

        setLargeTitle(enable: false)
        
        self.navigationItem.title = getString(key: "com.charmphr.insurance.title")
        self.navigationItem.backBarButtonItem?.title = getString(key: "com.charmphr.healthPassport.back.title")
        if RbacUtil.checkPrivilege(privilege: .ADD_INSURANCE){
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
        }
        
        let noteView = InformationView(infoLocalisedKey: "com.charmphr.insurance.information.title")
        self.titleCustomView.addSubview(noteView)
        
        noteView.setSafeAreaLeft(offset: X_SPACE)
        noteView.setSafeAreaRight(offset: -X_SPACE)
        noteView.setTop(offSet: PADDING)
        noteView.setBottom(offSet: 0)
        
        // No fixed height: the header is sized by the note (top PADDING → bottom 0), so the message wraps to
        // more lines when the width shrinks (iPhone Duo fold, rotation, iOS 27.1 side bar). Was measured once at load.
        titleCustomView.removeConstraint(attribute: .height)
        
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.estimatedRowHeight = UITableView.automaticDimension
        customTableView.tableFooterView = UIView()
        customTableView.register(InsuranceTableViewCell.self, forCellReuseIdentifier: "InsuranceTableViewCell")
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        getInsurance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep the base class's scroll offset maths in sync with the content-driven header height.
        topViewHeight = titleCustomView.frame.height
    }

    func getInsurance() {
        
        if refreshControl.isRefreshing != true {
            showActivityIndicator()
        }
        charmConnectionHandler?.getInsuranceList(identificationKey: "getInsurance")
    }
    
//MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if insuranceList.count == 0
        {
            
            self.noDataBackGroundView.backgroundColor =  UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.insurance.title"))")
        }else
        {
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return insuranceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "InsuranceTableViewCell") as? InsuranceTableViewCell
        
        if let tableviewCell = tableviewCell{
            let insurance = insuranceList[indexPath.row]
            tableviewCell.setValues(insurance: insurance)
            
            let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
            tableviewCell.insuranceItemView.addGestureRecognizer(swiftLeft)
            
            let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftRight.direction = UISwipeGestureRecognizer.Direction.right
            tableviewCell.insuranceItemView.addGestureRecognizer(swiftRight)
            
            tableviewCell.insuranceItemView.deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))
            
            if let selectedIndex = selectedIndex{
                if indexPath.row == selectedIndex{
                    tableviewCell.insuranceItemView.setRowActionForSwipeLeft(duration: 0)
                }
                else{
                    tableviewCell.insuranceItemView.setRowActionForSwipeRight(duration: 0)
                }
            }
            return tableviewCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        hideSwipeActionButtons()
        let insurance = insuranceList[indexPath.row]
        let addInsuranceView = AddInsuranceViewController()
        addInsuranceView.insurance = insurance
        addInsuranceView.delegate = self
        if RbacUtil.checkPrivilege(privilege: .EDIT_INSURANCE){
            self.navigationController?.pushViewController(addInsuranceView, animated: true)
        }
    }
    
//MARK: - Other Functions
        
    func deleteInsurance(at indexPath: IndexPath) {
        
        selectedInsurance = insuranceList[indexPath.row]
        if let insurance = selectedInsurance {
            showActivityIndicatorFront()
            charmConnectionHandler?.deleteInsurance(insurance: insurance, identificationKey: "deleteInsurance_\(indexPath.row)")
        }
    }
    
    func hideSwipeActionButtons(){
        if let prebSelectedTVIndex = selectedIndex {
            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? InsuranceTableViewCell {
                prevTableViewCell.insuranceItemView.setRowActionForSwipeRight(duration: 0.4)
                selectedIndex = nil
            }
        }
    }
    
    private func refreshList() {
        getInsurance()
    }
    
    func addViewControllerDataAdded(message: String?) {
        if let message = message{
            CharmUtil.showToast(controller: self, message: message, seconds: 2)
        }
        refreshList()
    }
    
//MARK: - Action Calls
    
    override func noDataViewRetryBtnClicked() {
        refreshList()
    }
    
    @objc private func addButtonClicked(){
        let addInsuranceView = AddInsuranceViewController()
        addInsuranceView.delegate = self
        self.navigationController?.pushViewController(addInsuranceView, animated: true)
    }
    
    @objc func onUIRefreshChange(_ sender: UIRefreshControl) {
        hideSwipeActionButtons()
        refreshList()
    }
    @objc func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        if let insuranceItemView = sender.view as? InsuranceItemView{
            if let tableViewCell = insuranceItemView.superview?.superview as? InsuranceTableViewCell{
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
                            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? InsuranceTableViewCell {
                                prevTableViewCell.insuranceItemView.setRowActionForSwipeRight(duration: 0.4)
                                selectedIndex = nil
                            }
                        }
                    }
                    if allowLeftSwipe{
                        selectedIndex = index
                        insuranceItemView.setRowActionForSwipeLeft(duration: 0.4)
                    }
                case UISwipeGestureRecognizer.Direction.right:
                    if selectedIndex == index {
                        selectedIndex = nil
                        insuranceItemView.setRowActionForSwipeRight(duration: 0.4)
                    }
                default:
                    break
                }
            }
        }
    }
    
    @objc func onTouchLabel(sender: UITapGestureRecognizer){
        if let uiLabel = sender.view as? UILabel{
            if let insuranceItemView = uiLabel.superview as? InsuranceItemView{
                if let tableViewCell = insuranceItemView.superview?.superview as? InsuranceTableViewCell{
                    let indexPath: IndexPath = customTableView.indexPath(for: tableViewCell) ?? [0,0]
                    if selectedIndex != nil{
                        insuranceItemView.setRowActionForSwipeRight(duration: 0)
                    }
                    selectedIndex = nil
                    CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.insurance.delete.confirm.msg"), deleteClicked: {
                        self.deleteInsurance(at: indexPath)
                    })
                }
            }
        }
    }
    
// MARK: - charm connection Handler delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey == "getInsurance"{
            hideActivityIndicator()
            if let tempInsuranceList = response as? [PatientInsuranceDetails] {
                insuranceList = tempInsuranceList
                customTableView.reloadData()
            }
        }
        else if identificationKey.hasPrefix("deleteInsurance"){
            if response is Bool {
                hideActivityIndicator()
                if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                    self.insuranceList.remove(at: row)
                    removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
                }
                CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.insurance.delete.success.msg"), seconds: 2)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        if identificationKey == "getInsurance"
        {
            if refreshControl.isRefreshing == true {
                refreshControl.endRefreshing()
            }
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
}
