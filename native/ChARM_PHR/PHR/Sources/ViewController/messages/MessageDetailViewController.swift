//
//  MessageDetailViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 05/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import WebKit

class MessageDetailViewController: UIViewController , CharmConnectionHandlerDelegate , CharmConnectionHandlerDataDelegate , WKNavigationDelegate, WKUIDelegate, AddViewControllerDelegate, PDFImageVCDelegate, MessageRestrictionDelegate{
    
    var isInboxMessage = true
    var isForwardActionClicked = false
    var isReplyAllMessage = true
    
    let ACTION_BTN_WIDTH = 30
    let senderImageViewWidth = 50
    let xspace = X_SPACE
    let yspace = Y_SPACE
    
    let SENDER_IMAGEVIEW_TAG = 1000
    let TO_VALUE_LABEL_TAG = 1001
    let ATTACHMENT_TAG = 2000
    
    var previewItem : URL?
    
    private let containerView = UIView()
    private let messageContentView = UIView()
    private let attachmentContainer = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    
    private var message : Messages?
    private var arrayOfMessageRestriction : [MessageRestriction] = []
    private weak var delegate: AddViewControllerDelegate?
    private var charmConnectionHandler : CharmConnectionHandler?
    private var allowMessaging : Bool = false
    private var attachmentToBeDownloaded:[MessagesAttachmentsMap] = []
    private var attachmentAddedList: [[String:String]] = []
    private var msgAttachmentsMap: MessagesAttachmentsMap? = nil
    private var pdfImageVC: PDFImageViewController? = nil
    
    private var heightConstraintOfWebView : NSLayoutConstraint?
    private weak var contentWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        self.setLargeTitle(enable: false)
        self.navigationItem.title = getString(key: "com.charmphr.message.detail.title")

        createScrollView()
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.dataDelegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(message: Messages?, delegate: AddViewControllerDelegate?){
        super.init(nibName: nil, bundle: nil)
   
        self.delegate = delegate
        NotificationHandler.deleteDeliveredNotification(moduleId: messageModuleId, id: message?.messageId)
        self.message = message
        if AppDataHandler.sharedInstance().arrayOfMessageRestriction.isEmpty{
            AppDataHandler.sharedInstance().messageRestrictionDelegate = self
            AppDataHandler.sharedInstance().fetchSectionConfiguration()
        }
        else{
            setNavigationBarItems()
        }
        fetchMessageDetails()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - create subviews
    
    private func createScrollView()
    {
        let containerScrollView = UIScrollView()
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerScrollView)
        
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerScrollView.addSubview(containerView)

        containerView.setTop(offSet: 0)
        containerView.setRight(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        // Edge pins inside a scroll view only set content bounds; this ties the width to the visible area.
        containerView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor).isActive = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
               
        self.view.addConstraint(NSLayoutConstraint.init(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func createSubviews(){
                
        let senderImgSize: CGFloat = 48
        let messageReceipients = message?.messageReceipients
        
        let receipientsView = UIView()
        
        let fromView = UIView()
        
        let fromLabel = UILabel()
        fromLabel.text = getString(key: "com.charmphr.message.compose.from")
        fromLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        fromLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        fromView.addSubview(fromLabel)
        
        let fromValueLabel = UILabel()
        fromValueLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        fromValueLabel.text = messageReceipients?.fromName
        fromValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
        fromView.addSubview(fromValueLabel)
        
        receipientsView.addSubview(fromView)
        
        let toView = UIView()
        
        let toLabel = UILabel()
        toLabel.text = getString(key: "com.charmphr.message.compose.to")
        toLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        toLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        toView.addSubview(toLabel)
        
        let toValueLabel = UILabel()
        toValueLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        toValueLabel.text = messageReceipients?.toName
        toValueLabel.tag = TO_VALUE_LABEL_TAG
        toValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
        toValueLabel.numberOfLines = 0
        toView.addSubview(toValueLabel)
        
        receipientsView.addSubview(toView)
         
        let senderImageView = ImageViewWithInitailsView(initials: getIntialsFromSenderName(name: message?.messageReceipients?.fromName ?? ""), image: nil)
        senderImageView.tag = SENDER_IMAGEVIEW_TAG
        senderImageView.layer.masksToBounds = true
        senderImageView.layer.cornerRadius = senderImgSize / 2
        receipientsView.addSubview(senderImageView)
                
        fromLabel.setLeft(offSet: 0)
        fromLabel.setTop(offSet: 0)
        fromLabel.setBottom(offSet: 0)
        fromLabel.setWidth(constant: fromLabel.sizeThatFits(CGSize(width: 500, height: 500)).width)
        
        fromValueLabel.setLeftRelatedToView(offSet: 10, relatedView: fromLabel, relatedAttribute: .right)
        fromValueLabel.setCenterY()
        fromValueLabel.setRight(offSet: 0)
        
        fromView.setSafeAreaTop(offset: 16)
        fromView.setLeft(offSet: 0)
        fromView.setRightRelatedToView(offSet: -5, relatedView: senderImageView, relatedAttribute: .left)
            
        toLabel.setLeft(offSet: 0)
        toLabel.setWidth(constant: toLabel.sizeThatFits(CGSize(width: 500, height: 500)).width)
        
        toValueLabel.setLeftRelatedToView(offSet: 10, relatedView: toLabel, relatedAttribute: .right)
        toValueLabel.setTop(offSet: 0)
        toValueLabel.setBottom(offSet: 0)
        toValueLabel.setRight(offSet: 0)
        
        toLabel.setCenterY(view: toValueLabel)
        
        toView.setLeft(offSet: 0)
        toView.setRightRelatedToView(offSet: -5, relatedView: senderImageView, relatedAttribute: .left)
        toView.setTopRelatedToView(offSet: 8, relatedView: fromView, relatedAttribute: .bottom)
        toView.setBottom(offSet: -16)
        
        senderImageView.setWidth(constant: senderImgSize)
        senderImageView.setHeight(constant: senderImgSize)
        senderImageView.setRight(offSet: 0)
        senderImageView.setCenterY()
        
        
        let messageDetailView = UIView()
        
        let subjectLabel = UILabel()
        subjectLabel.numberOfLines = 0
        subjectLabel.text = message?.subject
        subjectLabel.font = .systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        messageDetailView.addSubview(subjectLabel)
        
        //TODO: want to show date differently ref : ui
        let dateLabel = UILabel()
        dateLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        dateLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        var dateString = message?.dateString
        if message?.timeString != nil
        {
            dateString?.append(" at ")
            dateString?.append(message?.timeString ?? "")
        }
        dateLabel.text = dateString
        messageDetailView.addSubview(dateLabel)
        
        subjectLabel.setLeft(offSet: 0)
        subjectLabel.setTop(offSet: PADDING_6)
        subjectLabel.setRight(offSet: 0)
        
        dateLabel.setTopRelatedToView(offSet: PADDING_3, relatedView: subjectLabel, relatedAttribute: .bottom)
        dateLabel.setLeft(offSet: 0)
        dateLabel.setRight(offSet: 0)
        dateLabel.setBottom(offSet: -PADDING_8)
    
        messageDetailView.addBottomBorder()
        messageDetailView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(messageDetailView)
        
        receipientsView.addBottomBorder()
        receipientsView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(receipientsView)
        
        messageContentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(messageContentView)
        
        receipientsView.setTop(offSet: 0)
        receipientsView.setLeft(offSet: xspace)
        receipientsView.setRight(offSet: -xspace)
                
        messageDetailView.setTopRelatedToView(offSet: 0, relatedView: receipientsView, relatedAttribute: .bottom)
        messageDetailView.setLeft(offSet: xspace)
        messageDetailView.setRight(offSet: -xspace)
                
        messageContentView.setTopRelatedToView(offSet: yspace, relatedView: messageDetailView, relatedAttribute: .bottom)
        messageContentView.setLeft(offSet: xspace)
        messageContentView.setRight(offSet: -xspace)
        messageContentView.setBottom(offSet: -10)
        
        loadContentView()
    }
    
    private func setNavigationBarItems() {
        arrayOfMessageRestriction = AppDataHandler.sharedInstance().arrayOfMessageRestriction
        allowMessaging = canAllowComposeMessage()
        if allowMessaging{
            let allowedArray = arrayOfMessageRestriction.filter {
                $0.isMessageRestrict == false && $0.allowMessaging == true && $0.practice?.practiceId == self.message?.practiceId
            }
            if allowedArray.isEmpty{
                self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(showReplyBtnError)), animated: true)
            }
            else{
                let menuButton = UIBarButtonItem(systemItem: .reply, menu: makeRightBarMenu())
                self.navigationItem.rightBarButtonItem = menuButton
            }
        }
    }
    
    //MARK: - MessageRestrictionDelegate
    
    func messageRestrictionDidReceiveData(isSuccess: Bool, error: (any Error)?) {
        if isSuccess{
            setNavigationBarItems()
        }
    }
    
    //MARK: - API calls
    
    private func fetchMessageDetails(){
        showActivityIndicator()
        charmConnectionHandler?.fetchMessageDetail(message: message ?? Messages(), identificationKey: "fetchMessageDetail")
    }
    
    private func canAllowComposeMessage() -> Bool
    {
        var canAllow = false
        for messageRestriction in arrayOfMessageRestriction
        {
            if messageRestriction.allowMessaging
            {
                canAllow = messageRestriction.allowMessaging
            }
        }
        return canAllow
    }
    
    private func fetchSenderPhoto()
    {
        if charmConnectionHandler == nil
        {
            charmConnectionHandler = CharmConnectionHandler(delegate: self)
            charmConnectionHandler?.dataDelegate = self
        }
        if isInboxMessage
        {
            charmConnectionHandler?.dataDelegate = self
            charmConnectionHandler?.fetchProviderPhoto(providerId: message?.messageReceipients?.fromId ?? "", practiceId: message?.practiceId ?? "", providerIndex: nil, identificationKey: "fetchSenderImage")
        }else
        {
            if let imageView = self.view.viewWithTag(SENDER_IMAGEVIEW_TAG) as? ImageViewWithInitailsView
            {
                if  let photo = Patient.selectedPatientInstance?.patientPhoto
                {
                    imageView.setImage(image: photo)
                }
            }
        }
    }
    
    //MARK: - Set MessageContent
    
    private func loadContentView()
    {
        let contantWebView = WKWebView()
        contantWebView.translatesAutoresizingMaskIntoConstraints = false
        contantWebView.scrollView.showsVerticalScrollIndicator = false
        contantWebView.scrollView.showsHorizontalScrollIndicator = true
        contantWebView.uiDelegate = self
        contantWebView.navigationDelegate = self
        contantWebView.scrollView.isScrollEnabled = true
        
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        contantWebView.loadHTMLString("<div id='div1'>\(headerString + (message?.contentFile ?? ""))</div>", baseURL: nil)
        messageContentView.addSubview(contantWebView)
        contentWebView = contantWebView

        
        attachmentContainer.translatesAutoresizingMaskIntoConstraints = false
        messageContentView.addSubview(attachmentContainer)
        
        contantWebView.setLeft(offSet: 0)
        contantWebView.setRight(offSet: 0)
        contantWebView.setTop(offSet: 0)
        heightConstraintOfWebView = NSLayoutConstraint(item: contantWebView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        if let heightConstraintOfWebView = heightConstraintOfWebView{
            contantWebView.addConstraint(heightConstraintOfWebView)
        }
            
        contantWebView.setBottomRelatedToView(offSet: -7, relatedView: attachmentContainer, relatedAttribute: .top)
        
        attachmentContainer.setLeft(offSet: 0)
        attachmentContainer.setRight(offSet: 0)
        attachmentContainer.setBottom(offSet: -Y_SPACE)
    }
    
    private func setDocumentsView(){
        if message?.msgAttachmentList.count ?? -1 > 0
        {
            if let msgAttachmentList = message?.msgAttachmentList{
                
                var previousView: UIView? = nil
                var hasSpace = false
                
                for (i,attachment) in msgAttachmentList.enumerated(){
                    
                    let attachmentView = DocumentAttachmentView(name: attachment.attachmentName ?? "", fileSize: nil, delegate: nil)
                    attachmentView.tag = ATTACHMENT_TAG + i
                    
                    attachmentContainer.addSubview(attachmentView)
                    
                    attachmentView.arrangeViews(constant: CARD_PADDING, hasSpace: hasSpace, beforeView: previousView)
                    previousView = attachmentView
                    hasSpace = !hasSpace
                    attachmentView.widthAnchor.constraint(equalTo: attachmentContainer.widthAnchor, multiplier: 0.5, constant: -CARD_PADDING / 2).isActive = true
                    
                    if i == msgAttachmentList.count - 1
                    {
                        attachmentView.setBottom(offSet: -PADDING_5)
                    }
                    
                    attachmentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewAttachmentClicked(tapGesture:))))
                }
            }

        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.getElementById(\"div1\").offsetHeight;") { [self] (result, error) in
            if let height = result as? CGFloat{
                hideActivityIndicator()
                heightConstraintOfWebView?.constant = height + 30
                setDocumentsView()
            }
        }
    }

    // The message text reflows to the new width on rotation and fold/unfold, so its height is measured again.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.contentWebView?.evaluateJavaScript("document.getElementById(\"div1\").offsetHeight;") { result, _ in
                if let height = result as? CGFloat {
                    self?.heightConstraintOfWebView?.constant = height + 30
                }
            }
        }
    }
    
    //MARK: - Action calls
    
    @objc private func viewAttachmentClicked(tapGesture : UITapGestureRecognizer)
    {
        msgAttachmentsMap = nil
        if let view =  tapGesture.view as? DocumentAttachmentView
        {
            msgAttachmentsMap = message?.msgAttachmentList[view.tag - ATTACHMENT_TAG]
            pdfImageVC = PDFImageViewController(fileName: msgAttachmentsMap?.attachmentName, data: nil, delegate: self, isAllowDownloadFile: true)
            if let pdfImageVC{
                self.navigationController?.pushViewController(pdfImageVC, animated: true)
            }
        }
    }
    
//MARK: - ReplyBtn Click
    
    private func makeRightBarMenu() -> UIMenu {

        let replyAction = UIAction(title: getString(key: "com.charmphr.message.reply.title"), image: UIImage(systemName: "arrowshape.turn.up.left")) { [weak self] _ in
            guard let self else { return }
            self.isForwardActionClicked = false
            self.isReplyAllMessage = false
            self.pushComposeMessageVC()
        }

        let replyAllAction = UIAction(title: getString(key: "com.charmphr.message.replyAll.title"), image: UIImage(systemName: "arrowshape.turn.up.left.2")) { [weak self] _ in
            guard let self else { return }
            self.isForwardActionClicked = false
            self.isReplyAllMessage = true
            self.pushComposeMessageVC()
        }

        let forwardAction = UIAction(title: getString(key: "com.charmphr.action.forward"), image: UIImage(systemName: "arrowshape.turn.up.right")) { [weak self] _ in
            self?.checkForForwardMsg()
        }

        return UIMenu(title: "",children: [replyAction, replyAllAction, forwardAction])
    }
    
    @objc private func showReplyBtnError(button:UIButton)
    {
        let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.message.alert.MessageRestrict.message"), preferredStyle: .alert)
        let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: nil)
        alertVC.addAction(okAction)
        alertVC.show()
    }
    
    private func checkForForwardMsg(){
        
        if let message = message{
            
            if message.msgAttachmentList.isEmpty{
                segueToComposeMessage()
            }
            else{
                let fileManager = FileManager.default
                
                attachmentToBeDownloaded = []
                
                for attachment in message.msgAttachmentList  { //checking the attachment is already downloaded. If attachment is not downloaded , then we are downloading the attachment
                    
                    do {
                        let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        let fileURL = documentDirectory.appendingPathComponent(attachment.attachmentName ?? "")
                        if fileManager.fileExists(atPath: fileURL.path)
                        {
                            
                            attachment.attachmentLocalURL = fileURL
                            //showAttachmentWith(fileUrl: fileURL)
                        }else
                        {
                            attachmentToBeDownloaded.append(attachment)
                            //                        showActivityIndicator()
                            //                        charmConnectionHandler.getAttachement(messageId: message.messageId, attachmentId: attachment.attachmentId, identificationKey: attachment.attachmentName)
                        }
                    }
                    catch
                    {
                        
                        attachmentToBeDownloaded.append(attachment)
                    }
                }
                
                
                if attachmentToBeDownloaded.isEmpty {//when every attachment found is downloaded
                    hideActivityIndicator()
                    segueToComposeMessage()
                }
                else{//downloading the attachment
                    downloadForwardedAttachment()
                }
            }
        }
    
    }
    
    private func downloadForwardedAttachment(){
        var isCallSent = false
        
        for attachment in  attachmentToBeDownloaded {
            
            if attachment.attachmentLocalURL == nil {//downloaded attachment's URL is stored in this property
                isCallSent = true
                if !activityIndicator.isAnimating{
                    showActivityIndicator()
                }
                charmConnectionHandler?.getAttachement(message: message, attachmentId: attachment.attachmentId ?? "", identificationKey: "getAttachment:\(attachment.attachmentName ?? "")")
            }
        }
        
        if !isCallSent {//when all attachments are downloaded
            hideActivityIndicator()
            segueToComposeMessage()
        }
    
    }

    //MARK: - UpdateToValue
    
    private func updateToValueLabelText()
    {
        if let message = message{
            if message.arrayOfRecivers.count > 0
            {
                if let toValueLabel = self.view.viewWithTag(TO_VALUE_LABEL_TAG) as? UILabel
                {
                    toValueLabel.text = ""
                    if isInboxMessage
                    {
                        toValueLabel.text?.append(message.messageReceipients?.toName ?? "")
                    }
                    for provider in message.arrayOfRecivers
                    {
                        if toValueLabel.text != ""
                        {
                            toValueLabel.text?.append(", ")
                        }
                        toValueLabel.text?.append(provider.fullName ?? "")
                    }
                }
            }
        }
    }
    
    //MARK: - PDFImageVCDelegate
    
    func downloadFile() {
        charmConnectionHandler?.getAttachement(message: message, attachmentId: msgAttachmentsMap?.attachmentId ?? "", identificationKey: msgAttachmentsMap?.attachmentName ?? "")
    }
        
    func cancelPDFImageVC() {
        pdfImageVC = nil
    }
    
//MARK: - AddViewControllerDelegate
    
    func addViewControllerDataAdded(message: String?) {
        delegate?.addViewControllerDataAdded(message: message)
    }
    
    //MARK: - PushTo ComposeMsgVC
    
    private func segueToComposeMessage(){
        hideActivityIndicator()
        isForwardActionClicked = true
        isReplyAllMessage = false
        pushComposeMessageVC()
    }
    
    func pushComposeMessageVC(){
        var contentStringBuilder = ""
        contentStringBuilder.append("<div><br/></div>")
        contentStringBuilder.append("<div><br/></div>")
        contentStringBuilder.append("<div style=\"float:left; text-align:left; padding-left:10px;\">---- On \(message?.dateString ?? "") \(message?.timeString ?? "")  &lt; \(message?.messageReceipients?.fromName ?? "") &gt;  wrote ---<br></div>")
        contentStringBuilder.append("<div><br/></div>")
        contentStringBuilder.append("<div><br/></div>")
        contentStringBuilder.append("<div><br/></div>")
        contentStringBuilder.append("<blockquote style=\"border-left: 1px solid #0000FF; padding-left: 6px;\"><div style=\"margin-left: 10px;\">\(message?.contentFile ?? "")</div></blockquote>")
        
        let enabledMessageRestictionList = arrayOfMessageRestriction.filter { (messageRestriction) -> Bool in
            if messageRestriction.isMessageRestrict == false && messageRestriction.allowMessaging == true
            {
                return true
            }else
            {
                return false
            }
        }
        
        let composeMsgVC = ComposeMessageViewController(messageObj: message, contentFile: contentStringBuilder, enabledMessageRestictionList: enabledMessageRestictionList, delegate: self, isForwardMessage: isForwardActionClicked, isReplyAllMessage: isReplyAllMessage)
        
        self.navigationController?.pushViewController(composeMsgVC, animated: true)
    }
    
    // MARK: - charmconnectionhandeler delegate methods
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchMessageDetail"
        {
            if let outputString = jsonObject["output_string"] as? Dictionary<String, Any>, let message = message{
                self.message = ParsingHelper.updateMessageObjWithMessageDeatilDict(dict: outputString, message: message)
            }
            createSubviews()
            fetchSenderPhoto()
            updateToValueLabelText()
        }
        else if identificationKey.hasPrefix("addAttachment")
        {
            
            let name = "\(identificationKey.split(separator: "-").last ?? "file")"
            
            if let attachment = jsonObject["attachment"] as? Dictionary<String,Any>
            {
                attachmentAddedList.append(["name":"\(name)","id":"\(attachment["attachment_id"] ?? "")"])
                
                if message?.msgAttachmentList.count == attachmentAddedList.count {//all attachmments are uploaded
                    hideActivityIndicator()
                    segueToComposeMessage()
                }
            }
        }
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey == "fetchSenderImage"
        {
            if let imageView = self.view.viewWithTag(SENDER_IMAGEVIEW_TAG) as? ImageViewWithInitailsView
            {
                if let image = UIImage(data: data)
                {
                    imageView.setImage(image: image)
                }
            }
        }
        
        else if identificationKey.hasPrefix("getAttachment"){
            let name = "\(identificationKey.split(separator: ":").last ?? "file")"
            
            let fileManager = FileManager.default
            
            
            do {
                let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentDirectory.appendingPathComponent(name)
            
                try data.write(to: fileURL)
                
                
                if let attachment = attachmentToBeDownloaded.first(where: {attachment in
                    
                     attachment.attachmentName == name
                }){
                    attachment.attachmentLocalURL = fileURL
                }
                
                var isDownloadDone = true
                
                for attachment in attachmentToBeDownloaded {
                    
                    if attachment.attachmentLocalURL == nil{
                        isDownloadDone = false
                    }
                }
                
                if isDownloadDone{
                    segueToComposeMessage()
                }
            }
            catch _ {
                CharmUtil.createRetryAndCancelAlertWith(title: getString(key: "com.charmphr.message.forward.error.msg"), msg: nil, tryAgainClicked: { [self] in
                    
                    let name = "\(identificationKey.split(separator: ":").last ?? "file")"
                    if let attachment =  attachmentToBeDownloaded.first(where: {attachment in
                        attachment.attachmentName == name
                    }) {
                        
                        if !self.activityIndicator.isAnimating {
                            self.showActivityIndicator()
                        }
                        charmConnectionHandler?.getAttachement(message: message, attachmentId: attachment.attachmentId ?? "", identificationKey: "getAttachment:\(attachment.attachmentName ?? "")")
                    }
                })
            }
        }
        else
        {
            pdfImageVC?.createView(newData: data)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        
        if identificationKey == "fetchMessageDetail"{
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.fetchMessageDetails()
            } cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            }

        }
        else if identificationKey.hasPrefix("getAttachment")
        {
            CharmUtil.createRetryAndCancelAlertWith(title: getString(key: "com.charmphr.message.forward.error.msg"), msg: nil, tryAgainClicked: { [self] in
                
                let name = "\(identificationKey.split(separator: ":").last ?? "file")"
                if let attachment =  attachmentToBeDownloaded.first(where: {attachment in
                    attachment.attachmentName == name
                }) {
                    
                    if !self.activityIndicator.isAnimating {
                        self.showActivityIndicator()
                    }
                    charmConnectionHandler?.getAttachement(message: message, attachmentId: attachment.attachmentId ?? "", identificationKey: "getAttachment:\(attachment.attachmentName ?? "")")
                }
            })
        }
        else if identificationKey != "fetchSenderImage"
        {
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
        else{
            pdfImageVC?.navigationController?.popViewController(animated: true)
            pdfImageVC = nil
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    //MARK: - ActivityIndicator
    
    private func hideActivityIndicator(){
        activityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = true
        self.view.isUserInteractionEnabled = true
    }
    
    private func showActivityIndicator(){
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
        self.view.isUserInteractionEnabled = false
    }
}
