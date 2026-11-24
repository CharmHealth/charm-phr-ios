//
//  HpDocumentsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 26/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

/*import UIKit
import QuickLook
import MobileCoreServices


class HpDocumentsViewController: CustomViewControllerWithTableView , UITableViewDataSource, AddViewControllerDelegate, CharmConnectionHandlerDelegate, CharmConnectionHandlerDataDelegate, UIImagePickerControllerDelegate , UIDocumentPickerDelegate, UINavigationControllerDelegate
{

    var charmConnectionHandler : CharmConnectionHandler!
    var arrayOfDocuments : [Document] = []
        
    var previewItem : URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.changeBackGroundColor(color: APPLICATION_BACKGROUND_COLOR)

        self.createTableviewAndSubViews(tableViewStyle: .plain)
        self.navigationItem.title = getString(key: "com.charmphr.Documents.title")
        self.navigationItem.backBarButtonItem?.title = getString(key: "com.charmphr.healthPassport.back.title")
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler.dataDelegate = self
        fetchDocumentList()
        
        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        customTableView.register(UINib(nibName: "KeyAndValueInVerticalTableViewCell", bundle: nil), forCellReuseIdentifier: "KeyAndValueInVerticalTableViewCell")
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
        
        //TODO: change image
        bottomImageView.image = #imageLiteral(resourceName: "Document_HP_BG")
    }
    
    //MARK: uitableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfDocuments.count > 4 || arrayOfDocuments.isEmpty
        {
            bottomImageView.isHidden = true
            if arrayOfDocuments.isEmpty
            {
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.Documents.nodata.title"))")
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
        }else
        {
            bottomImageView.isHidden = false
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyAndValueInVerticalTableViewCell") as! KeyAndValueInVerticalTableViewCell
        
        cell.keyLabel.text = arrayOfDocuments[indexPath.row].fileName
        if arrayOfDocuments[indexPath.row].categoryName != nil
        {
            cell.valueLabel.text = arrayOfDocuments[indexPath.row].categoryName!
        }else
        {
            cell.valueLabel.text = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let document = arrayOfDocuments[indexPath.row]
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent(document.fileName ?? "")
            if fileManager.fileExists(atPath: fileURL.path)
            {
                showAttachmentWith(fileUrl: fileURL)
            }else
            {
                self.activityIndicatorView.startAnimating()
                charmConnectionHandler.downloadDocument(patientId: Patient.selectedPatientInstance?.patientId ?? "", documentId: document.fileId ?? "", identificationKey: "downloadDocument_\(indexPath.row)")
            }
        }
        catch
        {
            self.activityIndicatorView.startAnimating()
            charmConnectionHandler.downloadDocument(patientId: Patient.selectedPatientInstance?.patientId ?? "", documentId: document.fileId ?? "", identificationKey: "downloadDocument_\(indexPath.row)")
        }

    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: getString(key: "com.charmphr.action.delete")) { action, index in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertController.message = getString(key: "com.charmphr.Documents.alert.delete.Documents")
            
            let deleteAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.delete"), style: .destructive) { (deleteAction) in
                self.deleteTableviewCellCalled(at: indexPath)
            }
            let cancelAction =  CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            alertController.show()
        }
        
        return [deleteAction]
    }
    
    //MARK: other methods
    func fetchDocumentList()
    {
        showActivityIndicator()
        charmConnectionHandler.fetchDocuments(pageNo:1, identificationKey: "fetchDocuments")
    }
    
    @objc func addButtonClicked()
    {
        self.view.endEditing(true)
                
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
        let photoAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.message.compose.photoAndVideo"), style: .default) { (uialertaction) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.mediaTypes = [String(kUTTypeImage),String(kUTTypePDF),String(kUTTypePNG),String(kUTTypeJPEG),String(kUTTypeMovie)]
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }
                
        let documentAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.message.compose.Documents"), style: .default) { (uialertaction) in
                    
        let documentPicker = UIDocumentPickerViewController(documentTypes:[String(kUTTypePDF),String(kUTTypePNG),String(kUTTypeImage),String(kUTTypeMovie)], in: .import)
            documentPicker.allowsMultipleSelection = false
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }
            
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel) { (uialertaction) in
                    
        }
                
        alertController.addAction(photoAction)
        alertController.addAction(documentAction)
        alertController.addAction(cancelAction)
        alertController.show()
    }
    
    func addViewControllerDataAdded(message: String?) {
        fetchDocumentList()
    }
    
    func deleteTableviewCellCalled(at indexpath : IndexPath)
    {
        if self.charmConnectionHandler == nil
        {
            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        }
        
        activityIndicatorView.startAnimating()
        self.charmConnectionHandler?.deleteDocument(patientId: Patient.selectedPatientInstance?.patientId ?? "", documentId: arrayOfDocuments[indexpath.row].fileId ?? "", identificationKey: "deleteDocument_\(indexpath.row)")
    }
    
    //MARK: - imagepicker and document delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let imageURL = info[.imageURL] as? URL
        {
            picker.dismiss(animated: true) {
                let addDocumentVC = AddDocumentViewController()
                addDocumentVC.selectedFileUrl = imageURL
                addDocumentVC.delegate = self
                self.navigationController?.pushViewController(addDocumentVC, animated: true)
            }
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL)
    {
        controller.dismiss(animated: true) {
            let addDocumentVC = AddDocumentViewController()
            addDocumentVC.selectedFileUrl = url
            self.navigationController?.pushViewController(addDocumentVC, animated: true)
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
    {
        for url in urls
        {
            controller.dismiss(animated: true) {
                let addDocumentVC = AddDocumentViewController()
                addDocumentVC.selectedFileUrl = url
                self.navigationController?.pushViewController(addDocumentVC, animated: true)
            }
        }
    }
    
    // MARK: charm connection Handler delegate
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchDocuments"
        {
            let parsingHelper = ParsingHelper()
            
            arrayOfDocuments =  parsingHelper.getArrayOfDocuments(dict: jsonObject)
            hideActivityIndicator()
            customTableView.reloadData()
            
        }
        else if identificationKey.hasPrefix("deleteDocument")
        {
            activityIndicatorView.stopAnimating()
            
            let row = Int(identificationKey.components(separatedBy: "_").last!)!
            arrayOfDocuments.remove(at: row)
            
            self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
        }
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey.hasPrefix("downloadDocument")
        {
            let row = Int(identificationKey.components(separatedBy: "_").last!)!
            let fileManager = FileManager.default
            
            hideActivityIndicator()
            
            do {
                let document = arrayOfDocuments[row]
                let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentDirectory.appendingPathComponent(document.fileName ?? "")
                try data.write(to: fileURL)
                
                showAttachmentWith(fileUrl: fileURL)
                
            } catch let error {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.alert.download.error"), msg: nil)
                debugPrintLog(error)
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        
        if identificationKey == "fetchDocuments"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(forCode: CharmUtil.getErrorCode(error: error)), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }

}

extension HpDocumentsViewController : QLPreviewControllerDelegate , QLPreviewControllerDataSource
{

    func showAttachmentWith(fileUrl : URL)
    {
        previewItem = fileUrl
        
        let previewController = QLPreviewController()
        previewController.delegate = self
        previewController.dataSource = self
        
        self.navigationController?.pushViewController(previewController, animated: true)
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItem as QLPreviewItem
    }
}*/
