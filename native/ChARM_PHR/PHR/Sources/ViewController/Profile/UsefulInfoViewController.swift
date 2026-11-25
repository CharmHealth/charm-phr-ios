//
//  UsefulInfoViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 03/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class UsefulInfoViewController: CustomViewControllerWithTableView , UITableViewDataSource, CharmConnectionV2HandlerDelegate{
    
    var charmConnectionHandler : CharmConnectionHandler? = nil
    
    var arrayOfUsefulInfo: [UsefulInfo] = []
    
    var numberOfPracticeDataGotForUsefulInfo = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLargeTitle(enable: false)
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        
        fetchUseFulInfo()

        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        customTableView.delegate = self
        customTableView.register(UsefulInfoTableViewCell.self , forCellReuseIdentifier: "UsefulInfoTableViewCell")
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        
        self.navigationItem.title = getString(key: "com.charmphr.UsefulInfo.title")

    }
    @objc func onUIRefreshChange(){
        fetchUseFulInfo()
    }
    
    func fetchUseFulInfo()
    {
        if refreshControl.isRefreshing != true{
            showActivityIndicator()
        }
        
        numberOfPracticeDataGotForUsefulInfo = 0
        if charmConnectionHandler == nil
        {
            charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        }
        charmConnectionHandler?.fetchUsefulInfo(identificationKey: "UsefulInfoList")
    }
    
    // MARK: - tableviewdelegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfUsefulInfo.isEmpty
        {
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
        }else
        {
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfUsefulInfo.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "UsefulInfoTableViewCell") as? UsefulInfoTableViewCell
        if let tableviewCell = tableviewCell{
            
            let usefulInfo = arrayOfUsefulInfo[indexPath.row]
            tableviewCell.setTableViewCell(data: usefulInfo)
            
            return tableviewCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if arrayOfUsefulInfo.count > 0
        {
            let usefulInfoDetailVC = UsefulInfoDetailViewController()
            usefulInfoDetailVC.usefulInfo = arrayOfUsefulInfo[indexPath.row]
            self.navigationController?.pushViewController(usefulInfoDetailVC, animated: true)
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "UsefulInfoList"
        {
            hideActivityIndicator()
            if let resp = response as? [UsefulInfo]{
                arrayOfUsefulInfo = resp
                customTableView.reloadData()
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "UsefulInfoList"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }
    
    override func noDataViewRetryBtnClicked() {
        fetchUseFulInfo()
    }
}

