//
//  ComposeMessageViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 17/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import MobileCoreServices
import PDFKit
import QuickLook
import PhotosUI
import UniformTypeIdentifiers

let GROUP: String = "Group"

protocol DismissModelViewDelegate: AnyObject {
    func dismissModelView()
}

///Commented Pagination in member fetch in this file because --> Restricted provider list api is not available. Member fetch list will show only non restricted providers. In Reply, Reply All, Forward Cases, if the sent provider or received provider is restricted have to find only with the member list but can't achieve this with the pagination.

class ComposeMessageViewController: AddDataUIViewController , CharmConnectionHandlerDelegate,CharmConnectionV2HandlerDelegate, CharmConnectionHandlerDataDelegate , UITableViewDelegate , UITableViewDataSource  , UINavigationControllerDelegate , UIDocumentPickerDelegate, UITextFieldDelegate, CustomTextFieldDelegate , PHPickerViewControllerDelegate, CardViewWithCloseBtnDelegate, DocumentAttachmentViewDelegate{
    
    private var composeMessageView: ComposeMessageView!
   
    private var charmConnectionHandler : CharmConnectionHandler?
    
    private var enabledMsgRestrictList: [MessageRestriction] = []
    private var messageObj : Messages?
    private var contentFile: String = ""
    private weak var delegate : AddViewControllerDelegate?
    private var isForwardMessage : Bool = false
    private var isReplyAllMessage : Bool = false
    private var selectedPractice: Practice? = nil
    
    private var practiceArray : [Practice] = []
    private var providerArray : [Provider] = []
    private var providerArrayToBeShown : [Provider] = []
    private var selectedProviderArray : [Provider] = []
    
    private var groupArray : [MemberGroup] = []
    private var groupArrayToBeShown: [MemberGroup] = []
    private var selectedGroup: MemberGroup? = nil
    
//    private var listPageNumber: Int = 1
//    private var hasMoreProvider: Bool = true

    private let ATTACHMENT_VIEW_TAG = 111111
    private var tagNo: Int = 2973826782
    private var toSubViewTagArr: [Int] = []
    private var hasspace = false
    private var viewframe: CGFloat = 0
    private var beforeCardView: UIView?
    private var attachmentDictArray: Array<[String: Any]> = []
    private var attachmentDetailsArray: [[String: Any]] = []
    private var fileIdArray: [String] = []
//    private var searchText: String? = nil

    private var groupId: String? = nil
    private var ownerId: String? = nil
    
    init(enabledMessageRestictionList: [MessageRestriction], delegate : AddViewControllerDelegate){
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = delegate
        self.enabledMsgRestrictList = enabledMessageRestictionList
        
        practiceArray = getPracticeList(msgRestictionList: enabledMsgRestrictList)
        
        composeMessageView = ComposeMessageView(contentFile: "", practiceList: practiceArray, delegate: self)
    }
    
    init(messageObj: Messages?, contentFile: String, enabledMessageRestictionList: [MessageRestriction], delegate : AddViewControllerDelegate, isForwardMessage : Bool = false, isReplyAllMessage : Bool = false){
        
        super.init(nibName: nil, bundle: nil)
        
        self.messageObj = messageObj
        self.contentFile = contentFile
        self.enabledMsgRestrictList = enabledMessageRestictionList
        self.delegate = delegate
        self.isForwardMessage = isForwardMessage
        self.isReplyAllMessage = isReplyAllMessage
        self.groupId = messageObj?.messageReceipients?.fromId
        self.ownerId = messageObj?.ownerId
                
        practiceArray = getPracticeList(msgRestictionList: enabledMsgRestrictList)
        selectedPractice = practiceArray.first { practice in
            return practice.practiceId == messageObj?.practiceId
        }
        
        composeMessageView = ComposeMessageView(contentFile: contentFile, practiceList: practiceArray, delegate: self, selectedPractice: selectedPractice)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = composeMessageView
        composeMessageView.toValueView.onWidthChange = { [weak self] in
            guard let self, self.composeMessageView.toValueView.subviews.contains(where: { $0 is CardViewWithCloseBtn }) else { return }
            self.removeDeletedViewAndSetConstraints(removedView: nil)
        }

        self.navigationItem.title = getString(key: "com.charmphr.message.compose.title")
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.dataDelegate = self
        charmConnectionHandler?.v2Delegate = self

        createNavigationBar()
        createSubView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        
        if let messageObj = messageObj {
            debugPrintLog("Attachments found ah; \(messageObj.msgAttachmentList.count)")
            
            if isForwardMessage {
                if !messageObj.msgAttachmentList.isEmpty {
                    var attachmentURLs:[URL] = []
                    messageObj.msgAttachmentList.forEach({let attachment = $0.attachmentLocalURL
                        if let attachment = attachment {
                            attachmentURLs.append(attachment)
                        }
                    })
                    
                    for url in attachmentURLs
                    {
                        onURLPicked(tempUrl: url)
                    }
                   // setToAttachment(urls: attachmentURLs)
                }
            }
        }
        if practiceArray.count == 1{
            fetchMemberList(practice: practiceArray.first)
        }
        else if let selectedPractice{
            fetchMemberList(practice: selectedPractice)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isBeingDismissed{
            debugPrintLog("Support Dissmissed called")
//            self.attachmentDetailsArray.forEach({attachmentObj in
//                if let url = attachmentObj["url"] as? URL {
//                    FileUtil.removeTempFile(fileUrl: url)
//                }
//            })
        }
    }
    
    private func createNavigationBar(){
        let attachmentBtn = UIBarButtonItem(image: UIImage(systemName: "paperclip"), style: .plain, target: self, action: #selector(attachmentBtnClicked))
        let sendBtn = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(sendBtnClicked))
        self.navigationItem.rightBarButtonItems = [sendBtn, attachmentBtn]
    }
    
    private func createSubView()
    {
        composeMessageView.toValueTextField.delegate = self
        composeMessageView.toValueTextField.textFieldDelegate = self
        
        composeMessageView.providerListTableView.delegate = self
        composeMessageView.providerListTableView.dataSource = self
        composeMessageView.providerListTableView.register(ComposeMemberTableViewCell.self, forCellReuseIdentifier: "ComposeMemberTableViewCell")
        composeMessageView.providerListTableView.register(MemberGroupTableViewCell.self, forCellReuseIdentifier: "MemberGroupTableViewCell")
//        composeMessageView.providerListTableView.addInfiniteScrolling(actionHandler: infiniteScrollingTargetAction)
        
        
        if isForwardMessage{
            loadDocumentListView()
        }
    }
    
    private func getPracticeList(msgRestictionList: [MessageRestriction]) -> [Practice]{
        var practiceList: [Practice] = []
        msgRestictionList.forEach { messageRestriction in
            if let practice = messageRestriction.practice{
                practiceList.append(practice)
            }
        }
        return practiceList.sorted { practice_0, practice_1 in
            return practice_0.practiceName?.lowercased() ?? "" < practice_1.practiceName?.lowercased() ?? ""
        }
    }
    
//    @objc private func infiniteScrollingTargetAction()
//    {
//        if composeMessageView.providerListTableView.showsInfiniteScrolling == true && providerArrayToBeShown.count >= 20 && hasMoreProvider{
//            listPageNumber += 1
//            fetchMemberList(practice: selectedPractice, infinityScroll: true)
//        }
//        else{
//            hideActivityIndicator()
//        }
//    }
    
    func getMessageRestriction(practiceId: String?) -> MessageRestriction?{
        return enabledMsgRestrictList.first { msgRestriction in
            return msgRestriction.practice?.practiceId == practiceId
        }
    }
    
//MARK:  - API calls
    
    func fetchMemberList(practice: Practice?, infinityScroll: Bool = false){
        selectedPractice = practice
        var identificationKey: String = ""
//        if !infinityScroll{
//            hasMoreProvider = true
//            listPageNumber = 1
//        }
//        
//        if !hasMoreProvider{
//            hideActivityIndicator()
//        }
        guard let practice/*, hasMoreProvider*/ else { return }
        
//        if infinityScroll{
//            composeMessageView.providerListTableView.infiniteScrollingView.startAnimating()
//            identificationKey = "InfiniteScrollProviderList"
//        }
//        else if !searchText.isNilOrBlank(){
//            identificationKey = "SearchProviderList"
//        }
//        else{
            showActivityIndicator()
            providerArray = []
            identificationKey = "providerList"
//        }
        charmConnectionHandler?.getProviderListForComposeMessage(practice: practice, groupId: groupId, ownerId: ownerId, identificationKey: identificationKey)
//        charmConnectionHandler?.getProviderListForComposeMessage(practice: practice, pageNo: listPageNumber, perPageCount: 20, searchText: searchText, identificationKey: identificationKey)
    }
    
    private func addAttachments(){
        
        if attachmentDictArray.count > 0{
            if attachmentDictArray.count == attachmentDetailsArray.count{
                showActivityIndicator()
                charmConnectionHandler?.addAttachments(attachmentList: attachmentDictArray, identificationKey: "addAttachment")
            }
        }
        else{
            sendMessage()
        }
    }
    
    private func sendMessage()
    {
        showActivityIndicator()
        
        let content = composeMessageView.contentTextView.text?.replacingOccurrences(of: "\n", with: "<br/>") ?? ""
        
        let composeMsg = ComposeMessage()
        composeMsg.subject = composeMessageView.subjectValueTextView.text ?? ""
        composeMsg.content = "<div>\(content)</div>\(contentFile)"
        composeMsg.patientId = getSelectedPatientId()
        composeMsg.providerList = selectedProviderArray
        composeMsg.memberGroup = selectedGroup
        composeMsg.fileIdList = fileIdArray
        composeMsg.practiceId = selectedPractice?.practiceId
        composeMsg.ownerId = messageObj?.ownerId
        
        charmConnectionHandler?.postComposeMessage(composeMsg: composeMsg, identificationKey: "composeMessageSent")
    }
    
//MARK: - LoadDocumentListView
    
    private func loadDocumentListView()
    {
        for view in composeMessageView.documentContainerView.subviews
        {
            view.removeFromSuperview()
        }
        
        if attachmentDetailsArray.count >= 1
        {
            var hasSpace = false
            var beforeView: UIView?
            
            for (i,attachmentDict) in attachmentDetailsArray.enumerated()
            {
                let attachmentView = DocumentAttachmentView(name: attachmentDict["name"] as? String ?? "", fileSize: attachmentDict["fileSize"] as? String ?? "", delegate: self)
                attachmentView.tag = ATTACHMENT_VIEW_TAG + i
                
                composeMessageView.documentContainerView.addSubview(attachmentView)

                attachmentView.arrangeViews(constant: CARD_PADDING, hasSpace: hasSpace, beforeView: beforeView)
                beforeView = attachmentView
                hasSpace = !hasSpace
                attachmentView.widthAnchor.constraint(equalTo: composeMessageView.documentContainerView.widthAnchor, multiplier: 0.5, constant: -CARD_PADDING / 2).isActive = true

                attachmentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewAttachmentClicked(tapGesture:))))
                
                if i == attachmentDetailsArray.count - 1
                {
                    attachmentView.setBottom(offSet: -PADDING_5)
                }
            }
        }
    }
    
    private func viewSelectedAttachment(parentView: DocumentAttachmentView){
        if attachmentDetailsArray.count >= 1
        {
            if let attachmentDetail = attachmentDetailsArray.getElement(at: parentView.tag - ATTACHMENT_VIEW_TAG) {
                if let fileURL = attachmentDetail["url"] as? URL{
                    let pdfImageVC = PDFImageViewController(fileName: fileURL.lastPathComponent, data: nil, url: fileURL)
                    self.navigationController?.pushViewController(pdfImageVC, animated: true)
                }
            }
        }
    }
    
//MARK: - DocumentAttachmentView Delegate
    
    func onCloseBtnTapped(_ view: DocumentAttachmentView) {
        attachmentDetailsArray.remove(at: (view.tag - ATTACHMENT_VIEW_TAG))
        attachmentDictArray.remove(at: (view.tag - ATTACHMENT_VIEW_TAG))
        loadDocumentListView()
    }
    
    // MARK: - action call
    
    @objc private func viewAttachmentClicked(tapGesture : UITapGestureRecognizer){
        
        if let view = tapGesture.view as? DocumentAttachmentView{
            viewSelectedAttachment(parentView: view)
        }
    }
    
    override func onBackClick() {
        if composeMessageView.isValueNotChanged() && selectedProviderArray.isEmpty && selectedGroup == nil && (selectedPractice == nil || practiceArray.count == 1) && attachmentDictArray.isEmpty
        {
            removeTempFiles()
            self.navigationController?.popViewController(animated: true)
        }else
        {
            showDiscardChangesDialog {
                self.removeTempFiles()
            }
        }
    }
    
    @objc private func attachmentBtnClicked(_ btn: UIBarButtonItem)
    {
        //TODO: attactments
        
        self.view.endEditing(true)
        if attachmentDetailsArray.count >= 5{
            CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.support.attachment.limit.errorMessage.title"), seconds: 2)
        }
        else{
            CharmUtil.showPhotoOrDocumentSelectionAlert(barButton: btn) {
                var configuration = PHPickerConfiguration()
                //0 - unlimited 1 - default
                configuration.selectionLimit = 1
                //configuration.filter = .any(of: [.videos])
                let pickerViewController = PHPickerViewController(configuration: configuration)
                pickerViewController.delegate = self
                self.present(pickerViewController, animated: true)
            } documentSelected: {
                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .png, .image, .movie], asCopy: true)
                documentPicker.delegate = self
                self.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func sendBtnClicked()
    {
        self.view.endEditing(true)
        if selectedPractice == nil{
            CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.common.selectPractice"), msg: nil, okClicked: {
                self.composeMessageView.practiceValueView?.becomeTextFieldFirstResponder()
            })
        }
        else if selectedProviderArray.count == 0 && selectedGroup == nil
        {
            CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.message.compose.no.sender.alert.msg"), msg: nil, okClicked: {
                self.composeMessageView.toValueTextField.becomeFirstResponder()
            })
        }else if composeMessageView.subjectValueTextView.text == nil || composeMessageView.subjectValueTextView.text == ""
        {
            CharmUtil.createOkAndCancelAlertWith(title: getString(key: "com.charmphr.message.compose.no.subject.alert.msg"), msg: nil, okClicked: {
                self.addAttachments()
            })
        }
        else{
            self.addAttachments()
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification)
    {
        if notification.userInfo != nil
        {
            if let keyboardRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            {
                composeMessageView.changeHeightOfTextView(KeyboardFrame: keyboardRect)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification)
    {
        composeMessageView.changeHeightOfTextView(KeyboardFrame: .zero)
    }
    
    //MARK: - imagepicker and document delegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let imageURL = info[.imageURL] as? URL
        {

            var fileSize: Double = 0.0
            if let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)?.fixedOrientation(){
                let imgData = NSData(data: image.jpegData(compressionQuality: 0.8) ?? Data())
                let imageSize: Int = imgData.count
                fileSize = Double(imageSize) / (1024 * 1024)
            }
            let imageName = imageURL.lastPathComponent
            
            do {
                let data = try? Data(contentsOf: imageURL)
              
                if attachmentDetailsArray.contains(where: { attachmentDetailName in
                    if let newName = attachmentDetailName["url"] as? URL{
                        return "\(newName)" == "\(imageURL)"
                    }
                    return false
                }){
                    showDuplicateFilesAlert()
                }
                else{
                    if (fileSize <= 20.0){
                        var fileSizeString: String = ""
                        if fileSize < 1.0{
                            let fileSizeCount = 1000 * fileSize
                            fileSizeString = "\(Double(round(100 * fileSizeCount) / 100)) KB"
                        }
                        else{
                            fileSizeString = "\(Double(round(100 * fileSize) / 100)) MB"
                        }
                        
                        if let data{
                            attachmentDictArray.append(["\(imageName)" : data])
                        }
                        attachmentDetailsArray.append(["name": imageName, "fileSize": fileSizeString, "url": imageURL])
                        loadDocumentListView()
                    }
                    else{
                        showMaximumFileSizeAlert()
                    }
                }
            }
        }
        picker.dismiss(animated: true) {
            self.loadDocumentListView()
        }
    }
    
    private func onURLPicked(tempUrl: URL ,fileName: String? = nil , toCompress: Bool = false){
        if let url = FileUtil.createTempFile(fileUrl: tempUrl, tempFileName: fileName , toCompress: toCompress) {
            
            if let data = try? Data(contentsOf: url){
                let fileName = url.lastPathComponent
                
                let fileSizeInBytes: Int = data.count
                let fileSize: Double = Double(fileSizeInBytes) / (1024 * 1024)
                
                
                
                debugPrintLog("File Size: \(fileSize)")
                
                if attachmentDetailsArray.contains(where: { attachmentDetailUrl in
                    if let newURL = attachmentDetailUrl["url"] as? URL{
                        return newURL.absoluteString == url.absoluteString
                    }
                    return false
                }){
                    showDuplicateFilesAlert()
                }
                else{
                    
                    if fileSize <= 20.0{
                        var fileSizeString: String = ""
                        if fileSize < 1.0{
                            let fileSizeCount = 1000 * fileSize
                            fileSizeString = "\(Double(round(100 * fileSizeCount) / 100)) KB"
                        }
                        else{
                            fileSizeString = "\(Double(round(100 * fileSize) / 100)) MB"
                        }
                        attachmentDictArray.append(["\(fileName)" : data])
                        attachmentDetailsArray.append(["name": fileName, "fileSize": fileSizeString, "url": url])
                        
                        attachmentDetailsArray.forEach({attachment in
                            debugPrintLog("Name -> \(attachment.getString("name") ?? "")")
                            debugPrintLog("URL -> \((attachment["url"] as? URL)?.absoluteString ?? "")")
                        })
                        loadDocumentListView()
                    }
                    else{
                        FileUtil.removeTempFile(fileUrl: url)
                        showMaximumFileSizeAlert()
                    }
                }
            }
        }
        else{
            DispatchQueue.main.async {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.message.attachment.select.error"), msg: nil)
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        if let result = results.firstOrNil() {
            
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
                        DispatchQueue.main.async {
                            self.onURLPicked(tempUrl: data, fileName: tempFileName , toCompress: true)
                        }
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
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL)
    {
        onURLPicked(tempUrl: url)
        
        controller.dismiss(animated: true) {
            self.loadDocumentListView()
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
    {
        for url in urls
        {
            onURLPicked(tempUrl: url)
        }
        controller.dismiss(animated: true) {
            self.loadDocumentListView()
        }
    }
    
    private func showMaximumFileSizeAlert(){
        CharmUtil.createOkayAlertWith(title: nil, msg:  getString(key: "com.charmphr.support.fileSize.alert.message.title", with: ["20"]))
    }
    
    private func showDuplicateFilesAlert(){
        CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.suppport.duplicateFiles.alert.message.title"))
    }
    
    private func removeTempFiles(){
        self.attachmentDetailsArray.forEach({attachmentObj in
            if let url = attachmentObj["url"] as? URL {
                FileUtil.removeTempFile(fileUrl: url)
            }
        })
    }
    
//MARK: - CustomField Delegate
    
    func selectView() {
        setBackGroundColor(isEmpty: true)
    }
    
    func backButtonOnEmptyField() {
        let cardViewWithCloseBtn = returnLastProviderCardView()
        
        if let cardViewWithCloseBtn = cardViewWithCloseBtn as? CardViewWithCloseBtn{
            onCloseBtnTapped(cardViewWithCloseBtn)
        }
    }
    
    private func setBackGroundColor(isEmpty: Bool ){
        
        let cardViewWithCloseBtn = returnLastProviderCardView()
        if isEmpty{
            cardViewWithCloseBtn?.setBackgroundColor(bgColor: LIGHT_BLUE_BACKGROUND_COLOR)
        }
        else{
            composeMessageView.toValueTextField.backCount = 0
            cardViewWithCloseBtn?.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
        }
    }
    
    private func returnLastProviderCardView() -> UIView?{
        let viewTag: Int = toSubViewTagArr.last ?? -1
        if let cardView = self.view.viewWithTag(viewTag) as? CardViewWithCloseBtn{
            return cardView
        }
        else{
            return nil
        }
    }
    
//MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textFieldEndEditing()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textInput = textField.text{
//            if textInput != searchText{
//                searchText = textInput
//            }
//            if !textInput.isEmpty{
//                fetchMemberList(practice: selectedPractice)
//            }
//            else{
                filterReciversListAndReloadTableView(searchStr: textInput)
//            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let textInput = textField.text{
//            if textInput != searchText{
//                searchText = textInput
//            }
//            if !textInput.isEmpty{
//                fetchMemberList(practice: selectedPractice)
//            }
//            else{
                filterReciversListAndReloadTableView(searchStr: textInput)
//            }
            if textField.text?.count ?? 0 > 0{
                setBackGroundColor(isEmpty: false)
            }
        }
    }
 
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldEndEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        let newText = oldText.replacingCharacters(in: r, with: string)
        
        return textFieldShouldChange(textField: textField, receiverString: newText)
    }
        
    func textFieldShouldChange(textField: UITextField, receiverString: String) -> Bool{
        if textField.text?.count ?? 0 > receiverString.count || receiverString.isEmpty
        {
//            searchText = receiverString
//            hasMoreProvider = true
//            listPageNumber = 1
//            if !searchText.isNilOrBlank(){
//                fetchMemberList(practice: selectedPractice)
//            }
//            else{
                filterReciversListAndReloadTableView(searchStr: textField.text ?? "")
//            }
        }
        return true
    }

    private func textFieldEndEditing(){
        self.view.endEditing(true)
        hideTableView()
        composeMessageView.hideMemberNoData(isHidden: true)
        setBackGroundColor(isEmpty: false)
    }
    
//MARK: - Create ProviderView
    
    private func createProviderView(selectedProvider: Provider){
        
        let labelText = StringUtil.getNameWithPrefixAndFullName(fullName: selectedProvider.fullName ?? "", prefix: selectedProvider.prefix)
        let cardViewWithCloseBtn = CardViewWithCloseBtn(name: labelText, viewWidth: composeMessageView.toValueViewWidth, delegate: self)
        cardViewWithCloseBtn.value = selectedProvider
        
        cardViewWithCloseBtn.tag = tagNo
        toSubViewTagArr.append(tagNo)
        tagNo += 1
        
        composeMessageView.toValueView.addSubview(cardViewWithCloseBtn)
        removeDeletedViewAndSetConstraints(removedView: nil)
    }
    
    private func createGroupView(isHideCloseBtn: Bool = false){
        guard let selectedGroup else { return }
        
        let cardViewWithCloseBtn = CardViewWithCloseBtn(name: selectedGroup.groupName ?? "", viewWidth: composeMessageView.toValueViewWidth, delegate: self)
        cardViewWithCloseBtn.value = selectedGroup
        
        if isHideCloseBtn{
            cardViewWithCloseBtn.hideCloseBtn()
        }
        
        cardViewWithCloseBtn.tag = tagNo
        toSubViewTagArr.append(tagNo)
        tagNo += 1
        
        composeMessageView.toValueView.addSubview(cardViewWithCloseBtn)
        removeDeletedViewAndSetConstraints(removedView: nil)
        
        if isHideCloseBtn{
            composeMessageView.toValueView.subviews.forEach({ view in
                if let textField = view as? UITextField{
                    textField.removeConstraints()
                    textField.removeFromSuperview()
                    cardViewWithCloseBtn.setBottom(offSet: 0)
                }
            })
        }
    }
    
    private func removeDeletedViewAndSetConstraints(removedView: CardViewWithCloseBtn?){
        
        hasspace = false
        viewframe = composeMessageView.toValueViewWidth
        beforeCardView = nil
        
        let index: Int = composeMessageView.toValueView.subviews.firstIndex(where: { cardView in
            if let cardViewWithCloseBtn = cardView as? CardViewWithCloseBtn{
                return removedView == cardViewWithCloseBtn
            }
            else{
                return false
            }
        }) ?? -1
        removedView?.removeFromSuperview()
        removeAndSetSubViewsFromSuperView(index: index)
    }
    
    private func removeAndSetSubViewsFromSuperView(index: Int){
        for (i,view) in composeMessageView.toValueView.subviews.enumerated(){
            if let cardViewWithCloseBtn = view as? CardViewWithCloseBtn{
                let width = cardViewWithCloseBtn.getViewWidth()
                if i >= index{
                    cardViewWithCloseBtn.removeConstraints()
                    if i == 1{
                        hasspace = false
                    }
                    else{
                        if width <= viewframe{
                            hasspace = true
                        }
                        else{
                            hasspace = false
                            viewframe = composeMessageView.toValueViewWidth
                        }
                    }
                    setConstraintsToView(uiView: cardViewWithCloseBtn, viewWidth: width)
                }
                else{
                    if i == 1{
                        hasspace = false
                    }
                    else{
                        if width <= viewframe{
                            hasspace = true
                        }
                        else{
                            hasspace = false
                            viewframe = composeMessageView.toValueViewWidth
                        }
                    }
                    beforeCardView = cardViewWithCloseBtn
                    viewframe = viewframe - width
                }
            }
            else{
                if composeMessageView.toValueView.subviews.count == 1{
                    viewframe = 0
                }
            }
        }
        var width: CGFloat = 0
        if viewframe > 75{
            width = viewframe - 10
        }
        else{
            width = composeMessageView.toValueViewWidth
        }

        composeMessageView.setToTextFieldConstraint(hasSpace: viewframe > 75, beforeView: beforeCardView, width: width)

        // A locked group recipient has no text field, so the last chip must close off the field's height.
        if !composeMessageView.toValueView.subviews.contains(where: { $0 is UITextField }) {
            beforeCardView?.setBottom(offSet: 0)
        }
    }
    
    private func setConstraintsToView(uiView: UIView, viewWidth: CGFloat){
        
        uiView.arrangeViews(constant: 8, hasSpace: hasspace, beforeView: beforeCardView)
        beforeCardView = uiView
        viewframe = viewframe - viewWidth
        
        uiView.setWidth(constant: viewWidth)
        uiView.setHeight(constant: 32)
        
    }

//MARK: - Empty SelectedValues
    
    func emptySelectedValues(){
//        hasMoreProvider = true
        selectedGroup = nil
        selectedPractice = nil
        selectedProviderArray = []
        hideTableView()
    }
    
    private func hideTableView(){
        providerArrayToBeShown = []
        groupArrayToBeShown = []
        composeMessageView.providerListTableView.reloadData()
    }
    
//MARK: - Rendering list functions
   
    private func filterReciversListAndReloadTableView(searchStr: String){
        
        if searchStr.isEmpty{
            composeMessageView.hideMemberNoData(isHidden: true)
            
            if selectedProviderArray.isEmpty{
                providerArrayToBeShown = providerArray
            }
            else{
                providerArrayToBeShown = providerArray.filter({ (provider) -> Bool in
                    return checkIfProviderIsUnSelected(provider: provider)
                })
            }
            
            if let selectedGroup = selectedGroup{
                groupArrayToBeShown = groupArray.filter({ (group) -> Bool in
                    return !(group.groupId == selectedGroup.groupId)
                })
            }
            else{
                groupArrayToBeShown = groupArray
            }
            composeMessageView.providerListTableView.reloadData()
        }
        else{
            providerArrayToBeShown = providerArray.filter({ (provider) -> Bool in
                
                if selectedProviderArray.isEmpty{
                    return provider.fullName?.lowercased().contains(searchStr.lowercased()) ?? false
                }
                else{
                    if searchStr.isNotBlank()
                    {
                        if ((provider.fullName?.lowercased().contains(searchStr.lowercased())) != false)
                        {
                            return checkIfProviderIsUnSelected(provider: provider)
                        }
                        return false
                    }
                    return checkIfProviderIsUnSelected(provider: provider)
                }
            })
            
            groupArrayToBeShown = groupArray.filter({ memberGroup in
                if let selectedGroup{
                    return memberGroup.groupName?.lowercased().contains(searchStr.lowercased()) ?? false && !(selectedGroup.groupId == memberGroup.groupId)
                }
                else{
                    return memberGroup.groupName?.lowercased().contains(searchStr.lowercased()) ?? false
                }
            })
            
            if groupArrayToBeShown.isEmpty && providerArrayToBeShown.isEmpty{
                composeMessageView.hideMemberNoData(isHidden: false)
            }
            else{
                composeMessageView.hideMemberNoData(isHidden: true)
            }
            composeMessageView.providerListTableView.reloadData()
        }
    }
   
    private func checkIfProviderIsUnSelected(provider: Provider) -> Bool
    {
        return !(selectedProviderArray.contains { selectedProvider in
            return selectedProvider.memberId == provider.memberId
        })
    }
    
//MARK: - Set MessageDetailView
    
    private func setMessageDetailsView() {
        
        guard let messageObj else { return }
        
        composeMessageView.actionMessageWebView.loadHTMLString(contentFile, baseURL: nil)
        
        if !isForwardMessage
        {
            composeMessageView.subjectValueTextView.text = "Re: \(messageObj.subject ?? "")"
            
            if messageObj.messageType == "sent"
            {
                if messageObj.type == GROUP{
                    selectedGroup = groupArray.first(where: { memberGroup in
                        return memberGroup.groupId == messageObj.messageReceipients?.toId
                    })
                }
                else{
                    let receiverMemberIdList = messageObj.arrayOfRecivers.map({member in
                        return member.memberId ?? ""
                    })
                    
                    for provider in providerArray
                    {
                        if  !provider.memberId.isNilOrBlank() && receiverMemberIdList.contains(provider.memberId ?? ""){
                            selectedProviderArray.append(provider)
                        }
                    }
                }
            }
            else
            {
                if messageObj.type == GROUP{
                    selectedGroup = groupArray.first(where: { memberGroup in
                        return memberGroup.groupId == messageObj.messageReceipients?.fromId
                    })
                }
                else{
                    for provider in providerArray
                    {
                        if provider.memberId == messageObj.messageReceipients?.fromId
                        {
                            selectedProviderArray.append(provider)
                            break
                        }
                    }
                    
                    if isReplyAllMessage
                    {
                        let receiverMemberIdList = messageObj.arrayOfRecivers.map({member in
                            return member.memberId ?? ""
                        })
                        
                        var selectedProviderIdArray = selectedProviderArray.map({member in
                            return member.memberId ?? ""
                        })
                        
                        for provider in providerArray{
                            
                            if  !provider.memberId.isNilOrBlank() && receiverMemberIdList.contains(provider.memberId ?? "")  && !selectedProviderIdArray.contains(provider.memberId ?? "")
                            {
                                selectedProviderArray.append(provider)
                                selectedProviderIdArray.append(provider.memberId ?? "")
                            }
                        }
                    }
                }
            }
        }else{
            composeMessageView.subjectValueTextView.text = "Fwd: \(messageObj.subject ?? "")"
        }
        
        if !isForwardMessage && (!selectedProviderArray.isEmpty || selectedGroup != nil){
            setToMemberView(isHideCloseBtn: selectedGroup != nil)
        }
    }
    
    private func setToMemberView(isHideCloseBtn: Bool){
        
        setBackGroundColor(isEmpty: false)
        if !selectedProviderArray.isEmpty{
            for i in 0 ... selectedProviderArray.count - 1{
                let provider = selectedProviderArray[i]
                createProviderView(selectedProvider: provider)
            }
        }
        else{
            createGroupView(isHideCloseBtn: isHideCloseBtn)
        }
        composeMessageView.toValueTextField.text = ""
    }
    
//MARK: - CardViewWithCloseBtn Delegate
    
    func onCloseBtnTapped(_ view: CardViewWithCloseBtn) {
        setBackGroundColor(isEmpty: false)
        if selectedGroup != nil{
            self.selectedGroup = nil
        }
        else{
            let providerIndex: Int = selectedProviderArray.firstIndex(where: {provider in
                return provider.memberId == (view.value as? Provider)?.memberId
            }) ?? 0
            selectedProviderArray.remove(at: providerIndex)
        }
        
        toSubViewTagArr.removeAll { tag in
            return view.tag == tag
        }
        
        removeDeletedViewAndSetConstraints(removedView: view)
        textFieldDidBeginEditing(composeMessageView.toValueTextField)
    }
    
    //MARK: - Tableview delegate methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !groupArrayToBeShown.isEmpty && !providerArrayToBeShown.isEmpty{
            let uiView = UIView()
            let icon = UIImageView()
            let titleLabel = UILabel()
            
            uiView.addSubview(icon)
            uiView.addSubview(titleLabel)
            
            uiView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xEBF1FBFF)
            titleLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK70)
            if section == 0 && !groupArrayToBeShown.isEmpty{
                icon.image = UIImage(named: "Group_Icon")
                titleLabel.text = getString(key: "com.charmphr.message.compose.groups.title")
            }
            else{
                icon.image = UIImage(named: "Member_Icon")
                titleLabel.text = getString(key: "com.charmphr.message.compose.members.title")
            }
            
            icon.setLeft(offSet: X_SPACE)
            icon.setCenterY()
            icon.setWidth(constant: 24)
            icon.setHeight(constant: 24)
            
            titleLabel.setLeftRelatedToView(offSet: PADDING_6, relatedView: icon, relatedAttribute: .right)
            titleLabel.setRight(offSet: -X_SPACE)
            titleLabel.setCenterY()
            
            return uiView
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount = 0
        if(!groupArrayToBeShown.isEmpty){
            sectionCount = sectionCount+1
        }
        if(!providerArrayToBeShown.isEmpty){
            sectionCount = sectionCount+1
        }
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupArrayToBeShown.isEmpty && providerArrayToBeShown.isEmpty{
            tableView.isHidden = true
            return 0
        }
        else{
            tableView.isHidden = false
            if section == 0 && !groupArrayToBeShown.isEmpty{
                return groupArrayToBeShown.count
            }
            else{
                return providerArrayToBeShown.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && !groupArrayToBeShown.isEmpty{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MemberGroupTableViewCell") as? MemberGroupTableViewCell{
                let group = groupArrayToBeShown[indexPath.row]
                
                cell.setTableViewCellData(data: group)
                
                return cell
            }
        }
        else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ComposeMemberTableViewCell") as? ComposeMemberTableViewCell{
                let provider = providerArrayToBeShown[indexPath.row]
                cell.setTableViewCellData(data: provider)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        if indexPath.section == 0 && !groupArrayToBeShown.isEmpty{
            if selectedGroup == nil{
                if selectedProviderArray.isEmpty{
                    selectedGroup = groupArrayToBeShown[indexPath.row]
                    createGroupView()
                }
                else{
                    CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.message.compose.group.selectProvider.error.title"), msg: nil)
                }
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.message.compose.group.selectGroup.error.title"), msg: nil)
            }
            self.view.endEditing(true)
        }
        else{
            if selectedGroup == nil{
                let provider: Provider = providerArrayToBeShown[index]
                selectedProviderArray.append(provider)
                createProviderView(selectedProvider: provider)
                textFieldDidBeginEditing(composeMessageView.toValueTextField)
            }
            else{
                self.view.endEditing(true)
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.message.compose.group.selectProvider.error.title"), msg: nil)
            }
        }
        
        composeMessageView.toValueTextField.text = ""
        setBackGroundColor(isEmpty: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !groupArrayToBeShown.isEmpty && !providerArrayToBeShown.isEmpty{
            return 35
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - Charmconnection handeler delegate
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey == "fetchProviderPhoto" {
            if let indexPath = indexPath {
                let provider = providerArray[indexPath.row]
                provider.photo = UIImage(data: data)
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        self.hideActivityIndicator()
        if identificationKey != "fetchProviderPhoto"{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
        
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey ==  "providerList"{
            hideActivityIndicator()
            composeMessageView.subContainerView.isHidden = false
            if let providerAndGroup = response as? ProviderAndGroup{
                providerArray = providerAndGroup.memberList
                groupArray = providerAndGroup.groupList
//                hasMoreProvider = !providerAndGroup.memberList.isEmpty
                
                setMessageDetailsView()
                loadDocumentListView()
            }
        }
//        else if identificationKey == "InfiniteScrollProviderList" || identificationKey == "SearchProviderList"{
//            
//            if let providerAndGroup = response as? ProviderAndGroup{
//                if identificationKey == "InfiniteScrollProviderList"{
//                    hideActivityIndicator()
//                    hasMoreProvider = !providerAndGroup.memberList.isEmpty
//                }
//                
//                let memberList = providerAndGroup.memberList.filter { provider in
//                    return !providerArray.contains(where: { $0.memberId == provider.memberId })
//                }
//                providerArray.append(contentsOf: memberList)
//            }
//            filterReciversListAndReloadTableView(searchStr: searchText ?? "")
//        }
        else if identificationKey == "addAttachment"{
            if let attachmentList = response as? [String] {
                fileIdArray.append(contentsOf: attachmentList)
                sendMessage()
            }
        }
        else if identificationKey == "composeMessageSent" {
            hideActivityIndicator()
            removeTempFiles()
            trackEvent(eventName: "SendMessageOnSuccess", withGroupName: "Message")
            if messageObj == nil{
                self.navigationController?.popViewController(animated: true)
            }
            else{
                if let viewControllers: [UIViewController] = self.navigationController?.viewControllers as? [UIViewController]{
                    self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3 ], animated: true)
                }
            }
            
            if let message = response as? String {
                delegate?.addViewControllerDataAdded(message: message)
            }
            else{
                delegate?.addViewControllerDataAdded(message: "")
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        if identificationKey == "providerList"{
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(title: getString(key: "com.charmphr.message.compose.fetchProvider.error.title"), msg: nil, tryAgainClicked: { [self] in
                fetchMemberList(practice: composeMessageView.selectedPractice)
            }, cancelClicked: {
                self.removeTempFiles()
                self.navigationController?.popViewController(animated: true)
            })
        }
        else if identificationKey == "composeMessageSent"{
            hideActivityIndicator()
            trackEvent(eventName: "SendMessageOnFailure", withGroupName: "Message")
            CharmUtil.createOkayAlertWith(error: error)
            fileIdArray = []
        }
        else if identificationKey == "addAttachment"{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
            fileIdArray = []
        }
        else{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    //MARK: - ActivityIndicator
    
    private func showActivityIndicator(){
        composeMessageView.showActivityIndicator()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func hideActivityIndicator(){
        composeMessageView.hideActivityIndicator()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
