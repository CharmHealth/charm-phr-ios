//
//  ImagesViewController.swift
//  PHR
//
//  Created by Prathiba M on 11/05/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

class ImagesViewController: CustomViewControllerWithTableView, UITableViewDataSource, CharmConnectionV2HandlerDelegate, CharmConnectionHandlerDataDelegate{
    
    private var resultsAndOrderSegmentView: UISegmentedControl = UISegmentedControl(items: ["",""])
    
    private lazy var charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
    
    private var resultList: [ImagesResult] = []
    private var orderList: [ImagesOrder] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = getString(key: "com.charmphr.images.title")
        self.setLargeTitle(enable: false)
        
        charmConnectionHandler.dataDelegate = self
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
            
        self.titleCustomView.addSubview(resultsAndOrderSegmentView)
        resultsAndOrderSegmentView.setTitle(NSLocalizedString("com.charmphr.images.results.title", comment: ""), forSegmentAt: 0)
        resultsAndOrderSegmentView.setTitle(NSLocalizedString("com.charmphr.images.orders.title", comment: ""), forSegmentAt: 1)
        resultsAndOrderSegmentView.selectedSegmentIndex = 0
        
        resultsAndOrderSegmentView.addProperties(fontSize: FONT_SIZE_NORMAL)
        resultsAndOrderSegmentView.addTarget(self, action: #selector(resultsAndOrderSegmentValueChanged), for: .valueChanged)
        
        resultsAndOrderSegmentView.setCenterY()
        resultsAndOrderSegmentView.setSafeAreaLeft(offset: X_SPACE)
        resultsAndOrderSegmentView.setSafeAreaRight(offset: -X_SPACE)
        resultsAndOrderSegmentView.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        
        changeCustomTitleViewHeight(height: HEADER_HEIGHT )
        
        customTableView.separatorColor = .clear
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(ImageResultTableViewCell.self, forCellReuseIdentifier: "ImageResultTableViewCell")
        customTableView.register(ImageOrdersTableViewCell.self, forCellReuseIdentifier: "ImageOrdersTableViewCell")
        customTableView.delegate  = self
        customTableView.dataSource = self
        
        loadRequest()
    }
    
    //MARK: - API calls
    
    private func fetchImagesResults() {
        if refreshControl.isRefreshing != true{
            showActivityIndicator()
        }
        charmConnectionHandler.fetchImageResultList(identificationKey: "ImageResults")
    }
    
    private func fetchImagesOrders() {
        if refreshControl.isRefreshing != true{
            showActivityIndicator()
        }
        charmConnectionHandler.fetchImageOrderList(identificationKey: "ImageOrders")
    }
    
    private func downlaodImageResult(result: ImagesResult){
        showActivityIndicatorFront()
        charmConnectionHandler.downloadImageResult(fileId: result.phrimageResultGrpId ?? "", identificationKey: "downloadImageResult")
    }
    
    private func downlaodImageOrder(order: ImagesOrder){
        showActivityIndicatorFront()
        charmConnectionHandler.downloadImageOrder(fileId: order.fileId ?? "", identificationKey: "downloadImageOrder_\(order.fileName ?? "")")
    }
    
    //MARK: - Target action calls
    
    @objc private func resultsAndOrderSegmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            if resultList.isEmpty{
                fetchImagesResults()
            }
            else{
                customTableView.reloadData()
                customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        else{
            if orderList.isEmpty{
                fetchImagesOrders()
            }
            else{
                customTableView.reloadData()
                customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    @objc private func onUIRefreshChange() {
        loadRequest()
    }
    
    override func noDataViewRetryBtnClicked() {
        loadRequest()
    }
    
    private func loadRequest() {
        if resultsAndOrderSegmentView.selectedSegmentIndex == 0{
            fetchImagesResults()
        }
        else{
            fetchImagesOrders()
        }
    }
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultsAndOrderSegmentView.selectedSegmentIndex == 0
        {
            if resultList.isEmpty
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
            else
            {
                bottomImageView.image = #imageLiteral(resourceName: "Images_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return resultList.count
        }else
        {
            if orderList.count == 0
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
            else
            {
                bottomImageView.image = #imageLiteral(resourceName: "Images_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return orderList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if resultsAndOrderSegmentView.selectedSegmentIndex == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageResultTableViewCell") as? ImageResultTableViewCell{
                if !resultList.isEmpty{
                    let imagesResult = resultList[indexPath.row]
                    cell.setValues(data: imagesResult)
                }
                return cell
            }
        }
        else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageOrdersTableViewCell") as? ImageOrdersTableViewCell{
                if !orderList.isEmpty{
                    let imagesOrder = orderList[indexPath.row]
                    cell.setValues(data: imagesOrder)
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
            let imageResult = resultList[indexPath.row]
            downlaodImageResult(result: imageResult)
        }else
        {
            let cell = tableView.cellForRow(at: indexPath) as? ImageOrdersTableViewCell
            let imageOrder = orderList[indexPath.row]
            
            if imageOrder.readStatus == false {
                cell?.isRead = true
                imageOrder.readStatus = true
            }
            downlaodImageOrder(order: imageOrder)
        }
    }
    
    //MARK: - CharmConnectionHandler Delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "ImageResults"{
            guard let resultList = response as? [ImagesResult] else { return }
            self.resultList = resultList
            customTableView.reloadData()
        }
        else if identificationKey == "ImageOrders"{
            guard let orderList = response as? [ImagesOrder] else { return }
            self.orderList = orderList
            customTableView.reloadData()
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "ImageResults" || identificationKey == "ImageOrders" {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey.hasPrefix("downloadImageOrder") {
            if let fileName = identificationKey.components(separatedBy: "_").last{
                let pdfImageVC = PDFImageViewController(fileName: fileName, data: data)
                self.navigationController?.pushViewController(pdfImageVC, animated: true)
            }
        }
        else if identificationKey == "downloadImageResult"{
            let pdfImageVC = PDFImageViewController(fileName: getString(key: "com.charmphr.images.results.preview.title"), data: data)
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
    }
}
