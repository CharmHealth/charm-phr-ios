//
//  FlowsheetListViewController.swift
//  phr
//
//  Created by prathi-13964 on 04/07/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit


class FlowsheetListViewController: CustomViewControllerWithTableView, UITableViewDataSource, CharmConnectionHandlerDelegate {
    
    var charmConnectionHandler : CharmConnectionHandler?
    var flowsheetListArray: [Flowsheets] = []
    private let flowsheetTVId = "FlowsheetTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLargeTitle(enable: false)
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        self.title = getString(key: "com.charmphr.flowsheet.title")
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        
        customTableView.delegate = self
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(FlowsheetTableViewCell.self, forCellReuseIdentifier: flowsheetTVId)
        
        fetchFlowsheet()
    }
    
    func fetchFlowsheet(){
        
        if refreshControl.isRefreshing != true{
            showActivityIndicator()
        }
        charmConnectionHandler?.getFlowsheetList(identificationKey: "fetchFlowsheets")
    }
    
    func refreshList(){
        fetchFlowsheet()
    }
    
    override func noDataViewRetryBtnClicked() {
        refreshList()
    }
    
//MARK: - Action calls
    
    @objc func onTryAgainBtnClick(_  btn: UIButton) {
        refreshList()
    }
    
    @objc func onUIRefreshChange(_ sender: UIRefreshControl) {
        refreshList()
    }
    
//MARK: - TableView Delegate functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flowsheetListArray.count == 0
        {
            bottomImageView.isHidden = true
            self.noDataBackGroundView.backgroundColor =  UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
        }else
        {
            bottomImageView.image = UIImage(named: "Flowsheet_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return flowsheetListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: flowsheetTVId, for: indexPath) as! FlowsheetTableViewCell
        
        let flowsheet = flowsheetListArray[indexPath.row]
        
        cell.setTableViewCell(data: flowsheet)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let flowsheetEntriesViewController = FlowsheetEntriesViewController()
        let flowsheet = flowsheetListArray[indexPath.row]
        flowsheetEntriesViewController.flowsheet = flowsheet
        
        self.navigationController?.pushViewController(flowsheetEntriesViewController, animated: true)
    }
    
//MARK: - CharmConnectionHandler Delegate functions
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        
        if (identificationKey == "fetchFlowsheets")
        {
            hideActivityIndicator()
            flowsheetListArray = ParsingHelper.formFlowsheetList(respObj:jsonObject)
            customTableView.reloadData()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        
        hideActivityIndicator()
        if (identificationKey == "fetchFlowsheets")
        {
            if refreshControl.isRefreshing == true{
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

