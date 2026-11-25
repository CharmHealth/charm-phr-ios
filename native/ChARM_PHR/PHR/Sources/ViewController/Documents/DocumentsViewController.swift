//
//  DocumentsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 29/11/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import QuickLook
import MobileCoreServices
import PhotosUI

class DocumentsViewController: CustomViewControllerWithTableView , CharmConnectionHandlerDelegate , UITableViewDataSource , CharmConnectionHandlerDataDelegate, CharmConnectionV2HandlerDelegate , UIDocumentPickerDelegate , UINavigationControllerDelegate, DocumentShareVCDelegate, PHPickerViewControllerDelegate, PDFImageVCDelegate, AddDocumentVCDelegate {
    
    var isDocumentSharedByMe: Bool = false
    var selectedDocumentArray: [Document] = []
    
    var charmConnectionHandler : CharmConnectionHandler?
    var arrayOfDocument : [Document] = []
    var selectedDocumentCategory : DocumentCategory?
    var previewItem : URL?
    var isMultipleSelect = false
    var selectedIndexArray: [Int] = []
    var isShareEnableForPractice = false
    var viewToTableViewCellMap: [Int: Int] = [:]
    var tagNo = 100
    var tagList: [Int] = []
    var selectedIndex: Int? = nil
    
    var documentPageNo = 1
    var hasMoreDocument = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        self.navigationItem.title = selectedDocumentCategory?.name
        
        customTableView.delegate = self
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(DocumentTableViewCell.self, forCellReuseIdentifier: "DocumentTableViewCell")
        let lpgr = UILongPressGestureRecognizer(target: self,action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        customTableView.addGestureRecognizer(lpgr)
        
        customTableView.addInfiniteScrolling {
            self.fetchDocuments(fromScroll: true)
        }
        
        if RbacUtil.checkPrivilege(privilege: .ADD_DOCUMENTS){
            if isSharedByMe()
            {
                self.navigationItem.rightBarButtonItem = nil
            }
            else if selectedDocumentCategory?.name == getString(key: "com.charmphr.Documents.type.sharedWithMe.title")
            {
                self.navigationItem.rightBarButtonItem = nil
            }
            else
            {
                setRightBarButton()
            }
        }
        fetchDocuments()
    }
    
    @objc func onUIRefreshChange(){
        hideSwipeActionButtons()
        fetchDocuments()
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        if !isSharedByMe(){
            isMultipleSelect = true
            setRightBarButton()
            let p = gestureRecognizer?.location(in: customTableView)
            
            let indexPath = customTableView.indexPathForRow(at: p ?? CGPoint.zero)
            
            if gestureRecognizer?.state == .began, let indexPath{
                tableView(customTableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    @objc private func onClickShare(){
        shareFunction(vc: self, fileId: nil)
    }
    
    func shareFunction(vc: UIViewController, fileId: String?){
        let documentShareViewController = DocumentShareViewController()
        documentShareViewController.delegate = self
        selectedDocumentArray = []
        if let fileId{
            if let document = arrayOfDocument.first(where: { document in
                return document.fileId == fileId
            }){
                selectedDocumentArray.append(document)
            }
        }
        else if selectedIndexArray.count > 0{
            for index in selectedIndexArray {
                selectedDocumentArray.append(arrayOfDocument[index])
            }
            isMultipleSelect = false
            setRightBarButton()
            selectedIndexArray = []
        }
        isDocumentSharedByMe = isSharedByMe()
        if !selectedDocumentArray.isEmpty{
            vc.navigationController?.pushViewController(documentShareViewController, animated: true)
        }
    }
    
    func setRightBarButton(){
        self.navigationItem.rightBarButtonItem = nil
        
        if isMultipleSelect{
            let shareBtn = UIButton(type: .custom)
            shareBtn.setProperties(titleStrKey: getString(key: "com.charmphr.Document.rightBarButton.title", with: ["\(selectedIndexArray.count)"]), fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: THEME_COLOR)
            shareBtn.addTarget(self, action: #selector(onClickShare), for: .touchUpInside)
            let rightBarBtn = UIBarButtonItem(customView: shareBtn)
            self.navigationItem.setRightBarButton(rightBarBtn, animated: true)
        }
        else{
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocumentsClicked)), animated: true)
        }
    }
    
    func fetchDocuments(fromScroll: Bool = false)
    {
        
        var pageNo = 1
        
        if fromScroll {
            pageNo = documentPageNo + 1
        }
        
        documentPageNo = pageNo
        
        if refreshControl.isRefreshing != true && !fromScroll{
            showActivityIndicator()
        }
        
        if charmConnectionHandler == nil
        {
            charmConnectionHandler = CharmConnectionHandler(delegate: self)
            charmConnectionHandler?.dataDelegate = self
            charmConnectionHandler?.v2Delegate = self
        }
        if !isNilOrEmpty(string: selectedDocumentCategory?.categoryId)
        {
            charmConnectionHandler?.fetchDocuments(pageNo:pageNo,categoryId: selectedDocumentCategory?.categoryId ?? "",isHealthPassport: false ,identificationKey: "fetchDocuments")
        }
        else
        {
            if isSharedByMe()
            {
                charmConnectionHandler?.fetchDocumentByFilter(pageNo:pageNo, filter: "Sharedbyme", identificationKey: "fetchDocuments")
            }
            else if selectedDocumentCategory?.name == getString(key: "com.charmphr.Documents.type.sharedWithMe.title")
            {
                charmConnectionHandler?.fetchDocumentByFilter(pageNo:pageNo, filter: "Sharedtome", identificationKey: "fetchDocuments")
            }
            else
            {
                charmConnectionHandler?.fetchDocuments(pageNo:pageNo, identificationKey: "fetchDocuments")
            }
        }
    }
    
    @objc func addDocumentsClicked(_ btn: UIBarButtonItem)
    {
        self.view.endEditing(true)
                
        CharmUtil.showPhotoOrDocumentSelectionAlert(barButton: btn) {
            var configuration = PHPickerConfiguration()
                    //0 - unlimited 1 - default
            configuration.selectionLimit = 1
            //configuration.filter = .any(of: [.videos])
            let pickerViewController = PHPickerViewController(configuration: configuration)
            pickerViewController.delegate = self
            self.present(pickerViewController, animated: true)
        } documentSelected: {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .png, .pdf, .movie] , asCopy: true)
            documentPicker.allowsMultipleSelection = false
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    
//MARK: - DocumentShare delegate methods
    
    func documentShareSuccess() {
        selectedDocumentArray = []
        selectedIndexArray = []
        CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.sharedocuments.success.message"), seconds: 2)
        fetchDocuments()
    }
    
    func reloadTableView() {
        customTableView.reloadData()
    }
    
// MARK: - Tableviewdelegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrayOfDocument.isEmpty
        {
            if !isCustomApp()
            {
                if isSharedByMe()
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
                else if selectedDocumentCategory?.name == getString(key: "com.charmphr.Documents.type.sharedWithMe.title")
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
                else
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.Documents.NoDocuments.message"))")
                }
            }else
            {
                self.noDataBackGroundView.backgroundColor =  UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
        }else
        {
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfDocument.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell") as! DocumentTableViewCell
        let document = arrayOfDocument[indexPath.row]
        if selectedIndexArray.count == 0{
            tableviewCell.documentItemView.backgroundColor = .white
        }
        else{
            if selectedIndexArray.contains(indexPath.row){
                tableviewCell.documentItemView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_BLUE_BACKGROUND_COLOR)
            }
            else{
                tableviewCell.documentItemView.backgroundColor = .white
            }
        }
        tableviewCell.setTableViewCell(data: document)
        
        let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
        swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
        tableviewCell.documentItemView.addGestureRecognizer(swiftLeft)

        let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
        swiftRight.direction = UISwipeGestureRecognizer.Direction.right
        tableviewCell.documentItemView.addGestureRecognizer(swiftRight)
        
        tableviewCell.documentItemView.tag = tagNo
        tagList.append(tagNo)
        tagNo += 1
        
        tableviewCell.tag = tagNo
        tagList.append(tagNo)
        tagNo += 1
        viewToTableViewCellMap[tableviewCell.documentItemView.tag] = tableviewCell.tag
        
        tableviewCell.documentItemView.shareLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel)))
        tableviewCell.documentItemView.unShareLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel)))
        tableviewCell.documentItemView.deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel)))
        
        if let selectedIndex = selectedIndex{
            if indexPath.row == selectedIndex{
                let document = arrayOfDocument[indexPath.row]
                tableviewCell.documentItemView.setRowActionForSwipeLeft(duration: 0, isSentBy: !document.sentby.isNilOrBlank(), isSharedByMe: isSharedByMe())
            }
            else{
                tableviewCell.documentItemView.setRowActionForSwipeRight(duration: 0)
            }
        }
        
        if document.readStatus{
            tableviewCell.readDocument()
        }
        else{
            tableviewCell.unreadDocument()
        }
        return tableviewCell
    }
  
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if let currentCell = tableView.cellForRow(at: indexPath) as? DocumentTableViewCell {
            hideSwipeActionButtons()
            
            if isMultipleSelect && !isSharedByMe(){
                if selectedIndexArray.contains(indexPath.row){
                    let index: Int = selectedIndexArray.firstIndex(of: indexPath.row) ?? 0
                    selectedIndexArray.remove(at: index)
                    currentCell.documentItemView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
                }
                else{
                    if selectedIndexArray.count < 10{
                        selectedIndexArray.append(indexPath.row)
                        currentCell.documentItemView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_BLUE_BACKGROUND_COLOR)
                    }
                    else{
                        CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.Document.multipleSelect.maximum.toast.message"), seconds: 2)
                    }
                }
                if selectedIndexArray.isEmpty{
                    isMultipleSelect = false
                    setRightBarButton()
                }
                else{
                    isMultipleSelect = true
                    setRightBarButton()
                }
                setRightBarButton()
            }
            else{
                let document = arrayOfDocument[indexPath.row]
                if !document.readStatus{
                    document.readStatus = true
                    currentCell.readDocument()
                }
                
                if let fileData = document.fileData{
                    let pdfImageVC = PDFImageViewController(fileName: document.fileName, data: fileData, delegate: self, fileId: document.fileId)
                    self.navigationController?.pushViewController(pdfImageVC, animated: true)
                }
                else{
                    self.activityIndicatorView.startAnimating()
                    self.view.isUserInteractionEnabled = false
                    charmConnectionHandler?.downloadDocument(patientId: Patient.selectedPatientInstance?.patientId ?? "", documentId: document.fileId ?? "", identificationKey: "downloadDocument_\(indexPath.row)")
                }
            }
        }
    }

//MARK: - Other functions
    
    func isSharedByMe() -> Bool{
        
        if let selectedDocumentCategory{
            return  selectedDocumentCategory.categoryId.isNilOrBlank() && (selectedDocumentCategory.name == getString(key: "com.charmphr.Documents.type.sharedByMe.title"))
        }
       return false
    }
    
    func deleteTableviewCellCalled(at indexpath : IndexPath)
    {
        if self.charmConnectionHandler == nil
        {
            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
            charmConnectionHandler?.v2Delegate = self
        }
        activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.charmConnectionHandler?.deleteDocument(patientId: Patient.selectedPatientInstance?.patientId ?? "", documentId: arrayOfDocument[indexpath.row].fileId ?? "", identificationKey: "deleteDocument_\(indexpath.row)")
    }
    
    func hideSwipeActionButtons(){
        if let prebSelectedTVIndex = selectedIndex {
            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
            if let prevDocTableViewCell = customTableView.cellForRow(at: indexpath) as? DocumentTableViewCell {
                prevDocTableViewCell.documentItemView.setRowActionForSwipeRight(duration: 0.4)
                selectedIndex = nil
            }
        }
    }
    
//MARK: - Target Funcions
    
    @objc func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        if let documentItemView = sender.view as? DocumentItemView{
            let tableViewCellTag: Int = viewToTableViewCellMap[documentItemView.tag] ?? -1
            if let tableViewCell = self.view.viewWithTag(tableViewCellTag) as? DocumentTableViewCell{
                for tag in tagList{
                    if tag == tableViewCellTag && !isMultipleSelect{
                        let index: Int = customTableView.indexPath(for: tableViewCell)?.row ?? -1
                        let document = arrayOfDocument[index]
                        switch sender.direction {
                        case UISwipeGestureRecognizer.Direction.left:
                            selectedIndex = index
                            documentItemView.setRowActionForSwipeLeft(duration: 0.4, isSentBy: !document.sentby.isNilOrBlank() , isSharedByMe: isSharedByMe())
                        case UISwipeGestureRecognizer.Direction.right:
                            selectedIndex = nil
                            documentItemView.setRowActionForSwipeRight(duration: 0.4)
                        default:
                            break
                        }
                    }
                    else{
                        if let documentItemView = self.view.viewWithTag(tag) as? DocumentItemView{
                            documentItemView.setRowActionForSwipeRight(duration: 0.4)
                        }
                    }
                }
            }
        }
    }
    
   
    
    @objc func onTouchLabel(sender: UITapGestureRecognizer){
        if let uiLabel = sender.view as? UILabel{
            if let documentItemView = uiLabel.superview as? DocumentItemView{
                if let tableViewCell = documentItemView.superview?.superview as? DocumentTableViewCell{
                    let indexPath: IndexPath = customTableView.indexPath(for: tableViewCell) ?? [0,0]
                    if selectedIndex != nil{
                        documentItemView.setRowActionForSwipeRight()
                    }
                    selectedIndex = nil
                    if uiLabel.text == SHARE_LABEL{
                        selectedIndexArray.append(indexPath.row)
                        shareFunction(vc: self, fileId: nil)
                    }
                    else if uiLabel.text == UNSHARE_LABEL{
                        //Code to be write
                    }
                    else if uiLabel.text == DELETE_LABEL{
                        CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.Documents.alert.delete.Documents"), deleteClicked: {
                                self.deleteTableviewCellCalled(at: indexPath)
                        })
                    }
                }
            }
        }
    }
    
//MARK: - imagepicker and document delegate methods
    

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL){
        controller.dismiss(animated: true) {
            self.createTempFileAndPushDocumentVC(url: url)
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        for url in urls{
            controller.dismiss(animated: true) {

                self.createTempFileAndPushDocumentVC(url: url)
            }
        }
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        if let result = results.firstOrNil() {
            
            let itemProvider = result.itemProvider
            var typeIdenti = UTType.image.identifier
            var  tempFileName = "filename.jpeg"
            if(result.itemProvider.hasItemConformingToTypeIdentifier(UTType.video.identifier) ){
                    typeIdenti = UTType.video.identifier
                    tempFileName = "video_file.mp4"
            }
            else if(result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) ){
                typeIdenti = UTType.movie.identifier
                tempFileName = "video_file.mov"
            }
            
            
            if itemProvider.hasItemConformingToTypeIdentifier(typeIdenti){
                
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdenti , completionHandler: {data, error in
                    if let data = data {
                        self.createTempFileAndPushDocumentVC(url: data, tempFileName: tempFileName , toCompress: true)
                    }
                })
            }
//            else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier){
//                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier, completionHandler: {data, error in
//                    if let data = data {
//                        DispatchQueue.main.async {
//                            self.pushDocumentVC(url: data)
//                        }
//                    }
//                })
//            }
        }
    }
    
    
    
    func createTempFileAndPushDocumentVC(url : URL, tempFileName:String? = nil , toCompress: Bool = false)
    {
        if let tempFile =  FileUtil.createTempFile(fileUrl: url, tempFileName: tempFileName , toCompress: toCompress){
            DispatchQueue.main.async {
                //self.pushDocumentVC(url: tempFile)
                let addDocumentVC = AddDocumentViewController()
                addDocumentVC.selectedFileUrl = tempFile
                addDocumentVC.delegate = self
                addDocumentVC.isHealthPassport = false
                addDocumentVC.selectedFolder = self.selectedDocumentCategory
                self.navigationController?.pushViewController(addDocumentVC, animated: true)
            }
            
        }
        else{
            DispatchQueue.main.async {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.Document.select.error"), msg: nil)
            }
            debugPrintLog("TempFileCreationFailed")
        }
    }
    
    
    override func noDataViewRetryBtnClicked() {
        fetchDocuments()
    }
        
//MARK: - Charm Delegate functions
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        hideActivityIndicator()

        if identificationKey.hasPrefix("deleteDocument")
        {
            activityIndicatorView.stopAnimating()
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                arrayOfDocument.remove(at: row)
                self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
            }
            CharmUtil.showToast(controller: self, message: jsonObject.getString("message"), seconds: 2)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
        self.hideActivityIndicator()
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String)
    {
        if identificationKey.hasPrefix("downloadDocument")
        {
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                
                hideActivityIndicator()
                
                let document = arrayOfDocument[row]
                document.fileData = data
                let pdfImageVC = PDFImageViewController(fileName: document.fileName, data: data, delegate: self, fileId: document.fileId)
                self.navigationController?.pushViewController(pdfImageVC, animated: true)
            }
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchDocuments"{
            if let documentList = response as? [Document]{
//                hideActivityIndicator()
//                arrayOfDocument = resp
//                customTableView.reloadData()
                
                if documentPageNo == 1{
                    
                    hideActivityIndicator()
                    arrayOfDocument = documentList
                    customTableView.reloadData()
                }
                else{
                    
                    if !documentList.isEmpty {
                        
                        var indexPathArr:[IndexPath] = []
                        let finalCount = arrayOfDocument.count + documentList.count
                        for startIndex in (arrayOfDocument.count...finalCount-1 ){
                            indexPathArr.append(IndexPath(row: startIndex, section: 0))
                        }
                        
                        customTableView.beginUpdates()
                        arrayOfDocument.append(contentsOf: documentList)
                        customTableView.insertRows(at: indexPathArr, with: .top)
                        customTableView.endUpdates()
                    }
                    customTableView.infiniteScrollingView.stopAnimating()
                }
                hasMoreDocument = documentList.count == listPerPageCount &&  getEnabledPractices(moduleId: documentModelId).count == 1
                customTableView.showsInfiniteScrolling = hasMoreDocument
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "fetchDocuments"{
            if refreshControl.isRefreshing == true{
                refreshControl.endRefreshing()
            }
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
//MARK: - AddDocumentVC Delegate
    
    func onAddDocumentSuccess(message: String, documentObj: Document) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        arrayOfDocument = []
        fetchDocuments()
        
        CharmUtil.createYesAndNoAlertWith(title: getString(key: "com.charmphr.addDocuments.success.alert.success.message"), msg: nil) {
            self.pushToShareDocumentVC(documentObj: documentObj)
        }
    }
    
    private func pushToShareDocumentVC(documentObj: Document){
        let documentShareVC = DocumentShareViewController()
        documentShareVC.delegate = self
        isDocumentSharedByMe = false
        selectedDocumentArray = [documentObj]
        self.navigationController?.pushViewController(documentShareVC, animated: true)
    }
}
