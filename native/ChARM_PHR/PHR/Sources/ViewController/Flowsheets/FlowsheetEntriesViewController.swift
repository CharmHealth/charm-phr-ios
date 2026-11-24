//
//  FlowsheetEntriesViewController.swift
//  phr
//
//  Created by prathi-13964 on 04/07/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class FlowsheetEntriesViewController: CustomViewControllerWithTableView, CharmConnectionHandlerDelegate, UITableViewDataSource, AddViewControllerDelegate{
    
    var charmConnectionHandler : CharmConnectionHandler?
    var flowsheetEntriesList: [PHRFlowsheets] = []
    var flowsheet: Flowsheets?
    private let flowsheetEntriesTVId = "FlowsheetEntriesTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLargeTitle(enable: false)
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        
        self.navigationItem.title = flowsheet?.name
        
        if let flowsheet = flowsheet{
            if RbacUtil.checkPrivilege(privilege: .ADD_FLOWSHEETDATA) && flowsheet.allowEdit{
                self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
            }
        }
        
        customTableView.delegate = self
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(FlowsheetEntriesTableViewCell.self, forCellReuseIdentifier: flowsheetEntriesTVId)
        
        if flowsheetEntriesList.isEmpty{
            fetchFlowsheetEntry()
        }
        else{
            customTableView.reloadData()
        }
    }
    
    func fetchFlowsheetEntry(){
        
        if refreshControl.isRefreshing != true {
            showActivityIndicator()
        }
        if let flowsheet = flowsheet{
            charmConnectionHandler?.getFlowsheetEntryList( flowsheets: flowsheet, identificationKey: "fetchFlowsheetsEntry")
        }
    }
    
//MARK: - Target functions
    
    @objc func addButtonClicked(){
        pushAddFlowseetEntryVC()
    }
    
    @objc func onTryAgainBtnClick(_  btn: UIButton) {
        refreshList()
    }
    
    @objc func onUIRefreshChange(_ sender: UIRefreshControl) {
        refreshList()
    }

    override func noDataViewRetryBtnClicked() {
        refreshList()
    }
    
//MARK: - Other functions
    
    func pushAddFlowseetEntryVC(phrFlowsheets: PHRFlowsheets? = nil){
        
        let addFlowsheetEntryViewController = AddFlowsheetEntryViewController()
        addFlowsheetEntryViewController.phrFlowsheet = phrFlowsheets
        addFlowsheetEntryViewController.flowsheet = flowsheet
        addFlowsheetEntryViewController.delegate = self
        
        self.navigationController?.pushViewController(addFlowsheetEntryViewController, animated: true)
    }
    
    func refreshList(){
        fetchFlowsheetEntry()
    }
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        refreshList()
    }

//MARK: - TableView Delegate functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if flowsheetEntriesList.count == 0{
            bottomImageView.isHidden = true
            self.noDataBackGroundView.backgroundColor =  UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.flowsheetentry.noFlowsheetEntry.message"))")
        }
        else{
            bottomImageView.image = UIImage(named: "Flowsheet_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return flowsheetEntriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: flowsheetEntriesTVId, for: indexPath) as! FlowsheetEntriesTableViewCell
        let flowsheetEntry = flowsheetEntriesList[indexPath.row]
        cell.setTableViewCell(data: flowsheetEntry)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        let phrFlowsheet = flowsheetEntriesList[indexPath.row]
        pushAddFlowseetEntryVC(phrFlowsheets: phrFlowsheet)
    }

//MARK: - CharmConnectionHandler Delegate functions
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        
        if (identificationKey == "fetchFlowsheetsEntry")
        {
            hideActivityIndicator()
            flowsheetEntriesList = ParsingHelper.formFlowsheetListEntry(respObj:jsonObject)
            customTableView.reloadData()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        if (identificationKey == "fetchFlowsheetsEntry")
        {
            if refreshControl.isRefreshing == true {
                refreshControl.endRefreshing()
            }
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
}
