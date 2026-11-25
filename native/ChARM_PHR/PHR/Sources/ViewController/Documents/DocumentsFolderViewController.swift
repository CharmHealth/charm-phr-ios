//
//  DocumentsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 27/11/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import QuickLook
import MobileCoreServices
import PhotosUI

fileprivate enum ViewMode {
    case icons
    case list
}


class DocumentsFolderViewController: UIViewController , UIDocumentPickerDelegate , UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, CharmConnectionHandlerDelegate, NoDataViewDelegate, PHPickerViewControllerDelegate, AddDocumentVCDelegate, DocumentShareVCDelegate
{
    var isDocumentSharedByMe: Bool = false
    var selectedDocumentArray: [Document] = []
    
    private var viewMode: ViewMode = .icons

    var collectionView : UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10

        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    }()
    
    var activityIndicator = UIActivityIndicatorView()
    var charmConnectionHandler : CharmConnectionHandler?
    let noDataBackGroundView = NoDataView()
    var numberOfPracticeDataGotForDocumentFolder = 0
    var arrayOfDocumentCategory : Array<DocumentCategory> = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = getString(key: "com.charmphr.Documents.title")
        self.setLargeTitle(enable: false)
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        setRightBarbuttons()
        
        setSubViews()
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        fetchDocumentFolderList()
    }
    
//MARK: - Set subviews
    
    private func setRightBarbuttons(){
        var newFolder: UIAction? = nil
        if RbacUtil.checkPrivilege(privilege: .ADD_FOLDERS) && RbacUtil.checkPrivilege(privilege: .VIEW_FOLDERS){
            newFolder = UIAction(title: getString(key: "com.charmphr.Document.folder.more.newFolder.title"), image: UIImage(systemName: "folder.badge.plus")) { _ in
                self.addFolderBtnClicked()
            }
        }
        
        let icons = UIAction(title: getString(key: "com.charmphr.Document.folder.more.icons.title"), image: UIImage(systemName: "square.grid.2x2"), state: viewMode == .icons ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            if self.viewMode != .icons {
                self.viewMode = .icons
                collectionView.reloadData()
                setRightBarbuttons()
            }
        }

        let list = UIAction(title: getString(key: "com.charmphr.Document.folder.more.list.title"), image: UIImage(systemName: "list.bullet"), state: viewMode == .list ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            if self.viewMode != .list {
                self.viewMode = .list
                collectionView.reloadData()
                setRightBarbuttons()
            }
        }
        
        let viewMenu = UIMenu(title: "", options: .displayInline, children: [icons, list])
        var rightBarBtnItems: [UIBarButtonItem] = []
        if let newFolder{
            let mainMenu = UIMenu(children: [newFolder, viewMenu])
            let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: mainMenu)
            rightBarBtnItems = [moreButton]
        }
        else{
            let mainMenu = UIMenu(children: [viewMenu])
            let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: mainMenu)
            rightBarBtnItems = [moreButton]
        }
        
        if RbacUtil.checkPrivilege(privilege: .ADD_DOCUMENTS){
            
            let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
            rightBarBtnItems.append(addBtn)
        }
        navigationItem.rightBarButtonItems = rightBarBtnItems
    }
    
    func setSubViews()
    {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        
        collectionView.register(DocumentsSquareCollectionViewCell.self, forCellWithReuseIdentifier: "DocumentsSquareCollectionViewCell")
        collectionView.register(DocumentsHorizontalCollectionViewCell.self, forCellWithReuseIdentifier: "DocumentsHorizontalCollectionViewCell")
        self.view.addSubview(collectionView)
        
        collectionView.setBottom(offSet: 0)
        // Safe-area edges keep the folders clear of the Dynamic Island and the iOS 27.1 landscape side bar.
        collectionView.setSafeAreaRight(offset: 0)
        collectionView.setSafeAreaLeft(offset: 0)
        collectionView.setSafeAreaTop(offset: 24)
        
        let tableviewBgView = UIView()
        noDataBackGroundView.delegate = self
        tableviewBgView.addSubview(noDataBackGroundView)
        
        noDataBackGroundView.setCenterY()
        noDataBackGroundView.setCenterX()
        noDataBackGroundView.setLeft(offSet: 0)
        noDataBackGroundView.setRight(offSet: 0)
        noDataBackGroundView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.noDataBackGroundView.hideSubView(bool: true)
        collectionView.backgroundView = tableviewBgView
    }
    
    //MARK: - Api calls
    
    func fetchDocumentFolderList()
    {
        showActivityIndicator()
        numberOfPracticeDataGotForDocumentFolder = 0
        arrayOfDocumentCategory = []
        for practice in Patient.selectedPatientInstance!.practiceList
        {
            if RbacUtil.checkPrivilege(privilege: .VIEW_FOLDERS){
                charmConnectionHandler?.fetchDocumentsCategory(patientId: Patient.selectedPatientInstance!.patientId, practiceId: practice.practiceId ?? "", identificationKey: "fetchFolderList")
            }
            else{
                let allDocumentCategory = DocumentCategory()
                allDocumentCategory.name = "All"
                arrayOfDocumentCategory.append(allDocumentCategory)
                    
                let sharedWithMeDocumentCategory = DocumentCategory()
                sharedWithMeDocumentCategory.name = getString(key: "com.charmphr.Documents.type.sharedByMe.title")
                arrayOfDocumentCategory.append(sharedWithMeDocumentCategory)
                    
                let sharedByMeDocumentCategory = DocumentCategory()
                sharedByMeDocumentCategory.name = getString(key: "com.charmphr.Documents.type.sharedWithMe.title")
                arrayOfDocumentCategory.append(sharedByMeDocumentCategory)
                    
                hideActivityIndicator()
                collectionView.reloadData()
            }
        }
    }
    
    private func addNewFolder(name: String){
        showActivityIndicator()
        charmConnectionHandler?.addDocumentFolder(json: ["name":"\(name)","description":""], identificationKey: "addFolder")
    }
    
    //MARK: - CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if arrayOfDocumentCategory.isEmpty
        {
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.Procedures.NoProcedures.message"))")
        }else
        {
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfDocumentCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let documentCategory = arrayOfDocumentCategory[indexPath.row]
        
        if viewMode == .icons
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentsSquareCollectionViewCell", for: indexPath) as! DocumentsSquareCollectionViewCell
            cell.nameLabel.text = "\(documentCategory.name!)"
            return cell
        }else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentsHorizontalCollectionViewCell", for: indexPath) as! DocumentsHorizontalCollectionViewCell
            cell.nameLabel.text = "\(documentCategory.name!)"
            return cell
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewMode == .icons
        {
            return CGSize(width: 80, height: 100)
        }else
        {
            // Full row = visible width minus the 16pt section insets, so rows follow rotation / fold.
            let width = collectionView.bounds.width - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right - 32
            return CGSize(width: max(width, 0), height: 52)
        }
    }

    private var lastCollectionWidth: CGFloat = 0

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Item sizes depend on the width (list mode), so re-layout when it changes (rotation, fold/unfold, side bar).
        let width = collectionView.bounds.width
        if width > 0, width != lastCollectionWidth {
            lastCollectionWidth = width
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if viewMode == .icons
        {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }else
        {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let documentsVC = DocumentsViewController()
        documentsVC.selectedDocumentCategory = arrayOfDocumentCategory[indexPath.row]
        self.navigationController?.pushViewController(documentsVC, animated: true)
    }
    
    //MARK: - Action calls
    
    @objc func addButtonClicked(_ btn: UIBarButtonItem)
    {
        self.view.endEditing(true)
        CharmUtil.showPhotoOrDocumentSelectionAlert(barButton: btn) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
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
    
    @objc func addFolderBtnClicked()
    {
        let alertController = UIAlertController(title: getString(key: "com.charmphr.Document.newFolder.title"), message: getString(key: "com.charmphr.Document.newFolder.message"), preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = getString(key: "com.charmphr.Document.newFolder.placeHolder")
            textField.maxLength = 50
        }
        
        // ADD action (initially disabled)
        let addAction = UIAlertAction(
            title: getString(key: "com.charmphr.action.add"),
            style: .default
        ) { _ in
            if let name = alertController.textFields?.first?.text?.trim(), name.isNotBlank() {
                self.addNewFolder(name: name)
            }
        }
        
        // Disable initially
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(
            title: getString(key: "com.charmphr.action.cancel"),
            style: .cancel
        )
        
        // ENABLE addAction only when text is valid
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields?.first, queue: .main) { _ in
            let text = alertController.textFields?.first?.text?.trim() ?? ""
            addAction.isEnabled = !text.isEmpty
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.present(alertController, animated: true)
    }
    
    //MARK: - ActivityIndicator
    
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        collectionView.isHidden = true
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        collectionView.isHidden = false
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    //MARK: - imagepicker and document delegate methods
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL)
    {
        controller.dismiss(animated: true) {
            self.createTempFileAndPushDocumentVC(url: url)
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
    {
        
        
        for url in urls
        {
            controller.dismiss(animated: true) {
                
                self.createTempFileAndPushDocumentVC(url: url)
            }
        }
    }
    
    //MARK: - Picker delegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        // User tapped Close/Cancel without picking anything - nothing to do.
        guard let result = results.firstOrNil() else {
            return
        }

        DispatchQueue.main.async {
            self.showActivityIndicator()
        }

        let itemProvider = result.itemProvider
        var typeIdenti = UTType.image.identifier

        //debugPrintLog("typeInde -> \(itemProvider.iden)")
        debugPrintLog("typeIndeImg -> \(UTType.image.identifier)")
        debugPrintLog("typeIndeMp4 -> \(UTType.video.identifier)")
        debugPrintLog("typeIndeMov -> \(UTType.movie.identifier  )")

        debugPrintLog("typeMp4 -> \(result.itemProvider.hasItemConformingToTypeIdentifier(UTType.video.identifier))")
        debugPrintLog("typeMov -> \(result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier))")

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
                else{
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                    }
                }
            })
        }
        else{
            DispatchQueue.main.async {
                self.hideActivityIndicator()
            }
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
    
//MARK: - CharmConnectionHandler Delegate
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchFolderList" 
        {
            numberOfPracticeDataGotForDocumentFolder += 1
            
            let arrayOfDocumentCategory = ParsingHelper.fillArrayOfDocumentCategory(dict: jsonObject)
            
            for documentCategory in arrayOfDocumentCategory
            {
                if (self.arrayOfDocumentCategory.firstIndex { (selfDocumentCategory) -> Bool in
                    if documentCategory.name == selfDocumentCategory.name
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }) == nil
                {
                    self.arrayOfDocumentCategory.append(documentCategory)
                }
            }
            
            if numberOfPracticeDataGotForDocumentFolder == Patient.selectedPatientInstance!.practiceList.count
            {
                let sharedWithMeDocumentCategory = DocumentCategory()
                sharedWithMeDocumentCategory.name = getString(key: "com.charmphr.Documents.type.sharedByMe.title")
                self.arrayOfDocumentCategory.append(sharedWithMeDocumentCategory)
                
                let sharedByMeDocumentCategory = DocumentCategory()
                sharedByMeDocumentCategory.name = getString(key: "com.charmphr.Documents.type.sharedWithMe.title")
                self.arrayOfDocumentCategory.append(sharedByMeDocumentCategory)
                
                
                if RbacUtil.checkPrivilege(privilege: .VIEW_FOLDERS){
                    
                }
                                
                hideActivityIndicator()
                collectionView.reloadData()
            }
        }
        else if identificationKey == "addFolder"
        {
            hideActivityIndicator()
            fetchDocumentFolderList()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "fetchFolderList"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }
    
    func noDataViewRetryBtnClicked() {
        fetchDocumentFolderList()
    }
    
//MARK: - AddDocumentVC Delegate
    
    func onAddDocumentSuccess(message: String, documentObj: Document) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        CharmUtil.createYesAndNoAlertWith(title: getString(key: "com.charmphr.addDocuments.success.alert.success.message"), msg: nil) {
            self.pushToShareDocumentVC(documentObj: documentObj)
        }
    }
    
    private func pushToShareDocumentVC(documentObj: Document){
        let documentShareVC = DocumentShareViewController()
        documentShareVC.delegate = self
        selectedDocumentArray = [documentObj]
        self.navigationController?.pushViewController(documentShareVC, animated: true)
    }
    
//MARK: - ShareDocumentVC Delegate
    
    func documentShareSuccess() {
        CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.sharedocuments.success.message"), seconds: 2)
    }
    
    func reloadTableView() {}

//MARK: - Document Picker function
    
    func createTempFileAndPushDocumentVC(url : URL, tempFileName: String? = nil , toCompress: Bool = false)
    {

        if let tempFile =  FileUtil.createTempFile(fileUrl: url, tempFileName: tempFileName , toCompress: toCompress){
            DispatchQueue.main.async {
                self.hideActivityIndicator()
                let addDocumentVC = AddDocumentViewController()
                addDocumentVC.selectedFileUrl = tempFile
                addDocumentVC.delegate = self
                self.navigationController?.pushViewController(addDocumentVC, animated: true)
            }
        }
        else{
            DispatchQueue.main.async {
                self.hideActivityIndicator()
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.Document.select.error"), msg: nil)
            }
            debugPrintLog("TempFileCreationFailed")
        }
    }
}
