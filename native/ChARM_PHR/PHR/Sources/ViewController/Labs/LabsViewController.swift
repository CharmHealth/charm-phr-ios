//
//  LabsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 08/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import QuickLook

class LabsViewController: CustomViewControllerWithTableView , UITableViewDataSource, CharmConnectionV2HandlerDelegate, CharmConnectionHandlerDataDelegate{
    
    var resultsAndOrderSegmentView: UISegmentedControl = UISegmentedControl(items: ["",""])
    
    var charmConnectionHandler : CharmConnectionHandler? = nil
    var previewItem : URL?
    let totalNumberOfListWantToBeShowed = 20
    
    var arrayOfResults : [MedicalRecordGroup] = []
    var arrayOfOrders : [UploadesFiles] = []
    
    var resultPageNo = 1
    
    var hasMoreResults : Bool = true
    var hasMoreOrders : Bool = true
    
    var selectMedicalRecordGroup : MedicalRecordGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = getString(key: "com.charmphr.labs.title")
        
        self.setLargeTitle(enable: false)
        
        createView()
    }
    
    
    func createView()
    {

        self.createTableviewAndSubViews(tableViewStyle: .plain)
            
        self.titleCustomView.addSubview(resultsAndOrderSegmentView)
        resultsAndOrderSegmentView.setTitle(NSLocalizedString("com.charmphr.labs.results.title", comment: ""), forSegmentAt: 0)
        resultsAndOrderSegmentView.setTitle(NSLocalizedString("com.charmphr.labs.orders.title", comment: ""), forSegmentAt: 1)
        resultsAndOrderSegmentView.selectedSegmentIndex = 0
        
        resultsAndOrderSegmentView.addProperties(fontSize: FONT_SIZE_NORMAL)
        resultsAndOrderSegmentView.addTarget(self, action: #selector(resultsAndOrdersSegmentValueChanged(_:)), for: .valueChanged)
        
        resultsAndOrderSegmentView.setCenterY()
        resultsAndOrderSegmentView.setSafeAreaLeft(offset: X_SPACE)
        resultsAndOrderSegmentView.setSafeAreaRight(offset: -X_SPACE)
        resultsAndOrderSegmentView.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        
        changeCustomTitleViewHeight(height: HEADER_HEIGHT )
        
        self.charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        charmConnectionHandler?.dataDelegate = self
        
        customTableView.separatorColor = .clear
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(LabResultTableViewCell.self, forCellReuseIdentifier: "LabResultTableViewCell")
        customTableView.register(LabOrdersTableViewCell.self, forCellReuseIdentifier: "LabOrdersTableViewCell")
        customTableView.delegate  = self
        customTableView.dataSource = self

//        self.customTableView.addInfiniteScrolling {
//            self.infiniteScrollingAction()
//        }
//        self.customTableView.addPullToRefresh {
//            self.pullToRefeashAction()
//        }
        
        self.loadRequest()
        activityIndicatorView.hidesWhenStopped = true
        self.showActivityIndicator()
    }
    
//MARK: - Api calls
    
    func loadRequest(fromScroll:Bool = false)
    {
        
        if fromScroll{
            resultPageNo += 1
        }
        else{
            resultPageNo = 1
        }
        if refreshControl.isRefreshing != true && !fromScroll{
            showActivityIndicator()
        }
        if resultsAndOrderSegmentView.selectedSegmentIndex == 0{
            charmConnectionHandler?.fetchLabsList(pageNo: resultPageNo, listPerPageCount: totalNumberOfListWantToBeShowed, identificationKey: "fetchResults")
        }
        else{
            charmConnectionHandler?.fetchLabOrders(identificationKey: "fetchOrders")
        }
    }
    
    //MARK: - action calls
    
    @objc func onUIRefreshChange(){
        loadRequest()
    }
    
    @objc func resultsAndOrdersSegmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0
        {
            if  !arrayOfResults.isEmpty
            {
                customTableView.showsInfiniteScrolling = hasMoreResults
                customTableView.reloadData()
                hideActivityIndicator()
                customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }else{
                loadRequest()
            }
            
        }else{
            if !arrayOfOrders.isEmpty
            {
                customTableView.reloadData()
                hideActivityIndicator()
                customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            else{
                loadRequest()
            }
        }
    }

    override func hideActivityIndicator()
    {
        if refreshControl.isRefreshing{
            refreshControl.endRefreshing()
        }
        customTableView.isHidden = false
        activityIndicatorView.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    override func noDataViewRetryBtnClicked() {
        loadRequest()
    }
    
//    func infiniteScrollingAction()
//    {
//        loadRequest(fromScroll: true)
//    }
//
//    func pullToRefeashAction()
//    {
//        if resultsAndOrderSegmentView.selectedSegmentIndex == 0
//        {
//            arrayOfResults = []
//        }else{
//            arrayOfOrders = []
//        }
//        loadRequest()
//    }
    
    //MARK: - tableview delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultsAndOrderSegmentView.selectedSegmentIndex == 0
        {
            if arrayOfResults.isEmpty
            {
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfResults.count
        }else
        {
            if arrayOfOrders.count == 0
            {
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfOrders.count
        }
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if resultsAndOrderSegmentView.selectedSegmentIndex == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LabResultTableViewCell") as? LabResultTableViewCell{
                
                if !arrayOfResults.isEmpty{
                    let medicalRecordGroup = arrayOfResults[indexPath.row]
                    cell.setTableViewCell(data: medicalRecordGroup, indexPath: indexPath)
                }
                return cell
            }
        }
        else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LabOrdersTableViewCell") as? LabOrdersTableViewCell{
                
                if !arrayOfOrders.isEmpty{
                    let labOrders = arrayOfOrders[indexPath.row]
                    cell.setTableViewCell(data: labOrders, indexPath: indexPath)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if resultsAndOrderSegmentView.selectedSegmentIndex == 0
        {
            if arrayOfResults.count > 0
            {
                let cell = tableView.cellForRow(at: indexPath) as? LabResultTableViewCell
                let medicalRecordGroup = arrayOfResults[indexPath.row]
                
                if !medicalRecordGroup.isRead{
                    cell?.isRead = true
                    medicalRecordGroup.isRead = true
                }
                selectMedicalRecordGroup = medicalRecordGroup
                performSegue(withIdentifier: "labResultsDetailsVC", sender: self)
            }
        }else
        {
            let cell = tableView.cellForRow(at: indexPath) as? LabOrdersTableViewCell
            let selectedLabOrder = arrayOfOrders[indexPath.row]
            
            if selectedLabOrder.phrFileMap?.readStatus == false {
                cell?.isRead = true
                selectedLabOrder.phrFileMap?.readStatus = true
            }
            
            self.view.isUserInteractionEnabled = false
            activityIndicatorView.startAnimating()
            charmConnectionHandler?.downloadLabOrders(fileId: selectedLabOrder.fileId ?? "", identificationKey: "downloadLabOrder_\(selectedLabOrder.fileName ?? "")")
        }
    }
    
    //MARK: - charmconnection handler delegate methods
   
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey == "fetchResults"{
            hideActivityIndicator()
            if let resp = response as? [MedicalRecordGroup]{
                arrayOfResults = resp
                customTableView.reloadData()
            }
        }
        else if identificationKey == "fetchOrders"{
            hideActivityIndicator()
            if let resp = response as? [UploadesFiles]{
                arrayOfOrders = resp
                customTableView.reloadData()
            }
        }
//        customTableView.infiniteScrollingView.stopAnimating()
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "fetchResults" || identificationKey == "fetchOrders"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey.hasPrefix("downloadLabOrder"){
            
            self.view.isUserInteractionEnabled = true
            activityIndicatorView.stopAnimating()
                        
            if let fileName = identificationKey.components(separatedBy: "_").last{
                let pdfImageVC = PDFImageViewController(fileName: fileName, data: data)
                self.navigationController?.pushViewController(pdfImageVC, animated: true)
            }
        }
    }
    
    // MARK: - prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "labResultsDetailsVC"
        {
            if let vc = segue.destination as? LabResultsViewController{
                vc.medicalRecordGroup = selectMedicalRecordGroup
            }
        }
    }
}

