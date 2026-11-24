//
//  BillingViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 29/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import QuickLook

class BillingViewController: CustomViewControllerWithTableView, CharmConnectionV2HandlerDelegate , UITableViewDataSource , AddViewControllerDelegate,CharmConnectionHandlerDataDelegate
{

    var charmConnectionHandler : CharmConnectionHandler? = nil
    
    var previewItem: URL!
    
    var selectedModule = 0

    var invoicesArray : Array<PHRBills> = []
    var receiptArray : Array<PHRReceipts> = []
    
    var selectedCellObject : Any?
    
    let invoiceHandler = MDPaginationHandler<PHRBills>(moduleId: billingModelId)
    let receiptHandler = MDPaginationHandler<PHRReceipts>(moduleId: billingModelId)

    var startingSelectedIndex = 0
    
    var invoicePageNum = 1
    var receiptPageNum = 1

    var receiptDetailRespCount: Int = 0
    
    let canAllowInvoice = RbacUtil.checkPrivilege(privilege: .VIEW_INVOICE)
    let canAllowReceipt = RbacUtil.checkPrivilege(privilege: .VIEW_RECEIPT)
    //MARK: - view creations
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.createTableviewAndSubViews(tableViewStyle: .plain)

        createView()
    }
    
    func createView(){
    
        if selectedModule == 0{
            self.navigationItem.title = getString(key: "com.charmphr.billing.invoice.title")
        }
        else {
            self.navigationItem.title = getString(key: "com.charmphr.billing.receipt.title")
        }

        self.charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        charmConnectionHandler?.dataDelegate = self
        
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        self.customTableView.register(BillingTableViewCell.self, forCellReuseIdentifier: "BillingTableViewCell")
        self.customTableView.addInfiniteScrolling {
            self.infiniteScrollingAction()
        }
 
        
    }
    
    func initiateRequest() {
        self.loadRequest()
        self.showActivityIndicator()
    }
    
    @objc func onUIRefreshChange(){
        pullToRefeashAction()
    }
    
    func fetchReceiptDetail(receipt: PHRReceipts) {
        showActivityIndicatorFront()
        receiptDetailRespCount = 0
        charmConnectionHandler?.downloadReceiptPDF(patientId: getSelectedPatientId(), phrReceiptId: receipt.phrReceiptId, identificationKey: "receiptPDF")
        charmConnectionHandler?.updateReadStatusForReceipts(patientId: getSelectedPatientId(), phrReceiptId: receipt.phrReceiptId, identificationKey: "updateReceiptReadStatus")
    }
    
    //MARK: - tableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedModule == 0 {
            return invoiceArrayCount()
        }
        else{
            return receiptArrayCount()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if selectedModule == 0{
            return invoiceTableViewCell(tableView: tableView, at: indexPath)
        }
        else{
            return receiptTableViewCell(tableView: tableView, at: indexPath)
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if selectedModule == 0{
            tableViewDidSelect(at: indexPath)
        }
        else{
            if let receipt = receiptArray.getElement(at: indexPath.row) {
                receipt.isRead = true
                selectedCellObject = receipt
                if let cell = tableView.cellForRow(at: indexPath) as? BillingTableViewCell {
                    cell.billingItemView.setFontWeight(isRead: receipt.isRead)
                }
                fetchReceiptDetail(receipt: receipt)
            }
         
        }
    }
    
    //MARK: - action calls
    
    func infiniteScrollingAction()
    {
        loadRequest(fromScroll: true)
    }
    
    func pullToRefeashAction()
    {
        loadRequest()
    }
    
    private func loadRequest(fromScroll: Bool = false)
    {
        var page = 1
       
        if selectedModule == 0 {
            if fromScroll {
                page = invoicePageNum + 1
            }
            loadInvoice(pageNum: page)
        }
        else{
            if fromScroll {
                page = receiptPageNum + 1
            }
            else{
                receiptDetailRespCount = 0 // NOTE: Do not handle this type of handling in vc. move it to handler.
            }
            loadReceipt(pageNum: page)
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
        customTableView.infiniteScrollingView.stopAnimating()
    }

    //MARK: - charmconnectionhandler delegate methods
   
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey == "fetchInvoice"{
            hideActivityIndicator()
            if let invoiceResp = response as? MDPagiationDataResponse<PHRBills> {
                invoiceHandler.updatePaginationResponse(pagination: invoiceResp)
                invoicePageNum = invoiceResp.page
                
                if invoicePageNum == 1{
                    hideActivityIndicator()
                }
                getNextInvoiceData()
              
            }
            
        }
        else if identificationKey == "fetchReceipts"{
            hideActivityIndicator()
            if let receiptResp = response as? MDPagiationDataResponse<PHRReceipts> {
                
                receiptHandler.updatePaginationResponse(pagination: receiptResp)
                receiptPageNum = receiptResp.page
                
                if receiptPageNum == 1{
                    hideActivityIndicator()
                }
                getNextReceiptData()
              
            }
        }
        
        else if identificationKey == "updateReceiptReadStatus"{
            receiptDetailRespCount += 1
        }
        
        if receiptDetailRespCount == 2{
            hideActivityIndicator()
            
            let receipt = selectedCellObject as? PHRReceipts

            let receiptName = receipt?.receiptNumber ?? "Receipt"
            let pdfImageVC = PDFImageViewController(fileName: "\(receiptName).pdf", data: receipt?.pdfData)
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey.contains("fetchInvoice") || identificationKey.contains("fetchReceipts")
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else if identificationKey == "receiptPDF" || identificationKey == "updateReceiptReadStatus"{
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                if let receipt = self.selectedCellObject as? PHRReceipts {
                    self.fetchReceiptDetail(receipt: receipt)
                }
            })
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        
        if identificationKey == "receiptPDF"{
            receiptDetailRespCount += 1
            (selectedCellObject as? PHRReceipts)?.pdfData = data
        }
        
        if receiptDetailRespCount == 2{
            hideActivityIndicator()
            
            let receipt = selectedCellObject as? PHRReceipts

            let receiptName = receipt?.receiptNumber ?? "Receipt"
            let pdfImageVC = PDFImageViewController(fileName: "\(receiptName).pdf", data: receipt?.pdfData)
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
    }
    
    override func noDataViewRetryBtnClicked() {
        loadRequest()
    }
    
    func addViewControllerDataAdded(message: String?) {
        loadRequest()
    }
            
    //MARK: - other methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "invoiceVC"{
            let invoiceVc = segue.destination as! InvoiceViewController
            invoiceVc.delegate = self
            invoiceVc.invoice = selectedCellObject as? PHRBills
        }
    }
//MARK: - Optimized Functions
    
    func loadInvoice(pageNum: Int){
        if refreshControl.isRefreshing != true && pageNum == 1{
            showActivityIndicator()
        }
        invoicePageNum = pageNum
        
        let practiceList = invoiceHandler.getPracticeIdHasData(isFirst: pageNum == 1)
        
        if !practiceList.isEmpty {
            charmConnectionHandler?.fetchInvoiceList(pageNo: pageNum,practiceList: practiceList, identificationKey: "fetchInvoice")
        }
        else{
            getNextInvoiceData()
        }
    }
    
    func loadReceipt(pageNum: Int){
        if refreshControl.isRefreshing != true && pageNum == 1{
            showActivityIndicator()
        }
        receiptPageNum = pageNum
        
        let practiceList = receiptHandler.getPracticeIdHasData(isFirst: pageNum == 1)

        if !practiceList.isEmpty {
            charmConnectionHandler?.fetchReceiptList(pageNo: pageNum,practiceList: practiceList ,identificationKey: "fetchReceipts")
        }
        else{
            getNextReceiptData()
        }
    }
    func invoiceArrayCount() -> Int{
        if invoicesArray.isEmpty
        {
            bottomImageView.image = nil
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
        }
        else
        {
            bottomImageView.image = #imageLiteral(resourceName: "Billing_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return invoicesArray.count
    }
    func receiptArrayCount() -> Int{
        if receiptArray.isEmpty
        {
            bottomImageView.image = nil
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
        }
        else
        {
            bottomImageView.image = #imageLiteral(resourceName: "Billing_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return receiptArray.count
    }
    func tableViewDidSelect(at indexPath: IndexPath){
        if canAllowInvoice && invoicesArray.count > 0{
            selectedCellObject = invoicesArray[indexPath.row]
            performSegue(withIdentifier: "invoiceVC", sender: self)
        }
    }
    func invoiceTableViewCell(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillingTableViewCell") as! BillingTableViewCell
        let invoice = invoicesArray[indexPath.row]

        cell.fetchInvoiceTableViewCell(data: invoice)
      
        return cell
    }
    
    func receiptTableViewCell(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillingTableViewCell") as! BillingTableViewCell
        let receipt = receiptArray[indexPath.row]
        
        cell.fetchReceiptTableViewCell(data: receipt)
        return cell
    }
    
    private func getNextInvoiceData(){
        
        let invoiceList = invoiceHandler.getNextElements()
        
        if invoicePageNum == 1 {
            invoicesArray = invoiceList
            customTableView.reloadData()
        }
        else{
            
            if !invoiceList.isEmpty {
                var indexPathArr:[IndexPath] = []
                let finalCount = invoicesArray.count + invoiceList.count
                for startIndex in (invoicesArray.count...finalCount-1 ){
                    indexPathArr.append(IndexPath(row: startIndex, section: 0))
                }
                
                customTableView.beginUpdates()
                invoicesArray.append(contentsOf: invoiceList)
                customTableView.insertRows(at: indexPathArr, with: .top)
                customTableView.endUpdates()
            }
        }
        customTableView.infiniteScrollingView.stopAnimating()
        customTableView.showsInfiniteScrolling = invoiceHandler.allowInfinityScroll()
    }
    
    private func getNextReceiptData(){
        
        let receiptList = receiptHandler.getNextElements()
        
        if receiptPageNum == 1 {
            receiptArray = receiptList
            customTableView.reloadData()
        }
        else{
            
            if !receiptList.isEmpty {
                var indexPathArr:[IndexPath] = []
                let finalCount = receiptArray.count + receiptList.count
                for startIndex in (receiptArray.count...finalCount-1 ){
                    indexPathArr.append(IndexPath(row: startIndex, section: 0))
                }
                
                customTableView.beginUpdates()
                receiptArray.append(contentsOf: receiptList)
                customTableView.insertRows(at: indexPathArr, with: .top)
                customTableView.endUpdates()
            }
        }
        customTableView.infiniteScrollingView.stopAnimating()
        customTableView.showsInfiniteScrolling = receiptHandler.allowInfinityScroll()
    }
    
}
