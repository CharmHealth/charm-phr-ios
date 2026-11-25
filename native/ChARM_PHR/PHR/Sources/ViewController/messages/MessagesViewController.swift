//
//  MessagesViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 01/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

class MessagesViewController: CustomViewControllerWithTableView , UITableViewDataSource , CharmConnectionHandlerDelegate, CharmConnectionV2HandlerDelegate, AddViewControllerDelegate, MessageUnreadCountDelegate {
    
    var inboxAndSentSegmentControl: UISegmentedControl = UISegmentedControl(items: ["","",""])
    
    var charmConnectionHandler : CharmConnectionHandler? = nil
    
    let totalNumberOfListWantToBeShowed = 100
    var numberOfUnreadMessage = 0
    
    var arrayOfMessageRestriction : [MessageRestriction] = []
    var numberOfpraticeDataGotForMessageRestriction = 0
    var arrayOfUnread: [Messages] = []
    var arrayOfInbox : [Messages] = []
    var arrayOfSent : [Messages] = []

    var messageUnreadPageNo = 1
    var messageInboxPageNo = 1
    var messageSentPageNo = 1
    
    var selectMessage : Messages?
    var allowMessaging : Bool = false
    var selectedIndex: Int? = nil
    
    let sentMessageHandler = MDPaginationHandler<Messages>(moduleId: messageModuleId)
    let inboxMessageHandler = MDPaginationHandler<Messages>(moduleId: messageModuleId)
    let unreadMessageHandler = MDPaginationHandler<Messages>(moduleId: messageModuleId)
    
    var appDataHandler = AppDataHandler.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.title = getString(key: "com.charmphr.message.title")
        createTableviewAndSubViews(tableViewStyle: .plain)
        appDataHandler.messageUnreadCountDelegate = self
        self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        self.charmConnectionHandler?.v2Delegate = self
        if !appDataHandler.arrayOfMessageRestriction.isEmpty
        {
            arrayOfMessageRestriction = appDataHandler.arrayOfMessageRestriction
            allowMessaging = canAllowComposeMessage()
            createView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if appDataHandler.reloadMessage{
            if numberOfUnreadMessage > 0{
                inboxAndSentSegmentControl.selectedSegmentIndex = 0
            }
            else{
                inboxAndSentSegmentControl.selectedSegmentIndex = 1
            }
            self.loadRequest()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDataHandler.messageUnreadCountDelegate = nil
    }
    
    func createView()
    {
        self.titleCustomView.addSubview(inboxAndSentSegmentControl)

        if numberOfUnreadMessage > 0{
            inboxAndSentSegmentControl.selectedSegmentIndex = 0
        }
        else{
            inboxAndSentSegmentControl.selectedSegmentIndex = 1
        }
        inboxAndSentSegmentControl.setTitle(getString(key: "com.charmphr.message.unread.title"), forSegmentAt: 0)
        inboxAndSentSegmentControl.setTitle(getString(key: "com.charmphr.message.inbox.title"), forSegmentAt: 1)
        inboxAndSentSegmentControl.setTitle(getString(key: "com.charmphr.message.sent.title"), forSegmentAt: 2)
        
        inboxAndSentSegmentControl.addTarget(self, action: #selector(inboxAnsSentSegmentValueChanged(_:)), for: .valueChanged)
        inboxAndSentSegmentControl.addProperties(fontSize: FONT_SIZE_NORMAL)
        
        self.inboxAndSentSegmentControl.setCenterY()
        self.inboxAndSentSegmentControl.setSafeAreaLeft(offset: X_SPACE)
        self.inboxAndSentSegmentControl.setSafeAreaRight(offset: -X_SPACE)
        self.inboxAndSentSegmentControl.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        
        changeCustomTitleViewHeight(height: HEADER_HEIGHT)
        
        customTableView.separatorColor = .clear
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        
        customTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        customTableView.dataSource = self
        customTableView.tableFooterView =  UIView()
        
        self.customTableView.addInfiniteScrolling {
            self.infiniteScrollingAction()
        }
        if !appDataHandler.reloadMessage{
            self.loadRequest()
        }
        
        if canAllowAddEntry && allowMessaging
        {
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeMessageBtnClicked)), animated: true)
        }
        setUnreadCount()
    }
    
    @objc func onUIRefreshChange(){
        hideSwipeActionButtons()
        pullToRefeashAction()
    }
    
    func setUnreadCount()
    {
        let title = getString(key: "com.charmphr.message.unread.title")
        if numberOfUnreadMessage == 0{
            inboxAndSentSegmentControl.setTitle(title, forSegmentAt: 0)
        }
        else{
            inboxAndSentSegmentControl.setTitle("\(title) (\(numberOfUnreadMessage))", forSegmentAt: 0)
        }
    }
    
    func canAllowComposeMessage() -> Bool
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
    
    //MARK: - action calls
    @objc func inboxAnsSentSegmentValueChanged(_ sender: UISegmentedControl) {
        
        scrollTableViewToTop()
        
        if sender.selectedSegmentIndex == 0{
            if !arrayOfUnread.isEmpty
            {
                customTableView.showsInfiniteScrolling = unreadMessageHandler.allowInfinityScroll()
                customTableView.reloadData()
                hideActivityIndicator()
            }else{
                loadRequest()
            }
        }
        else if sender.selectedSegmentIndex == 1
        {
            if !arrayOfInbox.isEmpty
            {
                customTableView.showsInfiniteScrolling = inboxMessageHandler.allowInfinityScroll()
                customTableView.reloadData()
                hideActivityIndicator()
            }else{
                loadRequest()
            }
            
        }else if sender.selectedSegmentIndex == 2{
            if !arrayOfSent.isEmpty
            {
                customTableView.showsInfiniteScrolling = sentMessageHandler.allowInfinityScroll()
                customTableView.reloadData()
                hideActivityIndicator()
            }
            else{
                loadRequest()
            }
        }
    }
    
    @objc func composeMessageBtnClicked()
    {
        let array = arrayOfMessageRestriction.filter { (messageRestriction) -> Bool in
            if messageRestriction.isMessageRestrict == false && messageRestriction.allowMessaging == true{
                return true
            }else{
                return false
            }
        }
        
        if array.count > 0
        {
            pushComposeMessageVC()
        }else
        {
            let alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.message.alert.MessageRestrict.message"), preferredStyle: .alert)
            let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: { (UIAlertAction) in
                
            })
            alertVC.addAction(okAction)
            alertVC.show()
        }
    }
    
    func infiniteScrollingAction()
    {
        loadRequest(fromScroll: true)
    }
    
    func pullToRefeashAction()
    {
        loadRequest()
    }
    
//MARK: - Api calls
    
    func loadRequest(fromScroll: Bool = false)
    {
        var page = 1
        
        
        if inboxAndSentSegmentControl.selectedSegmentIndex == 0
        {
            if fromScroll {
                page = messageUnreadPageNo + 1
            }
            
            messageUnreadPageNo = page
            
            if refreshControl.isRefreshing != true && !fromScroll{
                showActivityIndicator()
            }
            
            let practiceList = unreadMessageHandler.getPracticeIdHasData(isFirst: !fromScroll)
            
            if !practiceList.isEmpty {
                charmConnectionHandler?.fetchMessageList(page:page, messageType: "unread",practiceList: practiceList , identificationKey: "fetchUnreadMessage")
                appDataHandler.fetchUnReadCount()
            }
            else{
                getNextUnreadData()
            }
        }
        else if inboxAndSentSegmentControl.selectedSegmentIndex == 1
        {
            if fromScroll {
                page = messageInboxPageNo + 1
            }
            
            messageInboxPageNo = page
            
            if refreshControl.isRefreshing != true && !fromScroll{
                showActivityIndicator()
            }
            
            let practiceList = inboxMessageHandler.getPracticeIdHasData(isFirst: !fromScroll)
            
            if !practiceList.isEmpty {
                charmConnectionHandler?.fetchMessageList(page:page, messageType: "inbox",practiceList: practiceList , identificationKey: "fetchInboxMessage")
            }
            else{
                getNextInboxData()
            }
            
        }else if inboxAndSentSegmentControl.selectedSegmentIndex == 2
        {
            if fromScroll {
                page = messageSentPageNo + 1
            }
            
            messageSentPageNo = page
            
            if refreshControl.isRefreshing != true && !fromScroll{
                showActivityIndicator()
            }
            
            let practiceList = sentMessageHandler.getPracticeIdHasData(isFirst: !fromScroll)
            
            if !practiceList.isEmpty {
                charmConnectionHandler?.fetchMessageList(page:page, messageType: "sent",practiceList: practiceList , identificationKey: "fetchSentMessage")
            }
            else{
                getNextSentData()
            }
        }
    }
    
    func deleteTableviewCellCalled(indexpath:IndexPath)
    {
        if self.charmConnectionHandler == nil
        {
            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        }
        if inboxAndSentSegmentControl.selectedSegmentIndex == 0{
            activityIndicatorView.startAnimating()
            self.charmConnectionHandler?.deleteMessageDetail(message: arrayOfUnread[indexpath.row], identificationKey: "deleteUnreadMessage_\(indexpath.row)")
        }
        else if inboxAndSentSegmentControl.selectedSegmentIndex == 1
        {
            activityIndicatorView.startAnimating()
            self.charmConnectionHandler?.deleteMessageDetail(message: arrayOfInbox[indexpath.row], identificationKey: "deleteInboxMessage_\(indexpath.row)")
        }else if inboxAndSentSegmentControl.selectedSegmentIndex == 2
        {
            activityIndicatorView.startAnimating()
            self.charmConnectionHandler?.deleteMessageDetail(message: arrayOfSent[indexpath.row], identificationKey: "deleteSentMessage_\(indexpath.row)")
        }
    }
    
    //TODO: adding temporary fix, need to do proper date string conversion for whole app
    
    
    
    
    //MARK: - tableview delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inboxAndSentSegmentControl.selectedSegmentIndex == 0{
            if arrayOfUnread.isEmpty
            {
                if allowMessaging
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }else
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfUnread.count
        }
        else if inboxAndSentSegmentControl.selectedSegmentIndex == 1
        {
            if arrayOfInbox.isEmpty
            {
                if allowMessaging
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }else
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfInbox.count
        }else
        {
            if arrayOfSent.isEmpty
            {
                if allowMessaging
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }else
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfSent.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as? MessageTableViewCell
        if let tableviewCell = tableviewCell{
            if inboxAndSentSegmentControl.selectedSegmentIndex == 0{
                if !arrayOfUnread.isEmpty
                {
                    let message = arrayOfUnread[indexPath.row]
                    tableviewCell.setTableViewCell(data: message, isInbox: true)
                }
            }
            else if inboxAndSentSegmentControl.selectedSegmentIndex == 1{
                if !arrayOfInbox.isEmpty
                {
                    let message = arrayOfInbox[indexPath.row]
                    tableviewCell.setTableViewCell(data: message, isInbox: true)
                }
            }else if inboxAndSentSegmentControl.selectedSegmentIndex == 2{
                if !arrayOfSent.isEmpty
                {
                    let message = arrayOfSent[indexPath.row]
                    tableviewCell.setTableViewCell(data: message, isInbox: false)
                }
            }
            let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
            tableviewCell.messageItemView.addGestureRecognizer(swiftLeft)
            
            let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftRight.direction = UISwipeGestureRecognizer.Direction.right
            tableviewCell.messageItemView.addGestureRecognizer(swiftRight)
            
            tableviewCell.messageItemView.deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchLabel(sender:))))
            
            if let selectedIndex = selectedIndex{
                if indexPath.row == selectedIndex{
                    tableviewCell.messageItemView.setRowActionForSwipeLeft(duration: 0)
                }
                else{
                    tableviewCell.messageItemView.setRowActionForSwipeRight(duration: 0)
                }
            }
            return tableviewCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        hideSwipeActionButtons()
        if inboxAndSentSegmentControl.selectedSegmentIndex == 0{
            if arrayOfUnread.count > 0
            {
                let cell = tableView.cellForRow(at: indexPath) as? MessageTableViewCell
                
                let message = arrayOfUnread[indexPath.row]
                cell?.messageItemView.setfontWeight(isRead: true)
                numberOfUnreadMessage -= 1
                setUnreadCount()
                message.messageReceipients?.status = "1"
                appDataHandler.refreshMessage = true
                selectMessage = message
                
                pushToMessageDetailVC()
                arrayOfUnread.remove(at: indexPath.row)
                customTableView.reloadData()
            }
        }
        if inboxAndSentSegmentControl.selectedSegmentIndex == 1
        {
            if arrayOfInbox.count > 0
            {
                let cell = tableView.cellForRow(at: indexPath) as? MessageTableViewCell
                
                let message = arrayOfInbox[indexPath.row]
                
                if message.messageReceipients?.status == "0" {
                    cell?.messageItemView.setfontWeight(isRead: true)
                    numberOfUnreadMessage -= 1
                    setUnreadCount()
                    message.messageReceipients?.status = "1"
                    appDataHandler.refreshMessage = true
                }
                selectMessage = message
                pushToMessageDetailVC()
            }
        }else
        {
            if arrayOfSent.count > 0
            {
                selectMessage = arrayOfSent[indexPath.row]
                pushToMessageDetailVC()
            }
        }
    }
    
    //MARK: - Other functions
    
    func hideSwipeActionButtons(){
        
        if let prebSelectedTVIndex = selectedIndex {
            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? MessageTableViewCell {
                prevTableViewCell.messageItemView.setRowActionForSwipeRight(duration: 0.4)
                selectedIndex = nil
            }
        }
    }
    
    @objc func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        if let messageItemView = sender.view as? MessageItemView{
            if let tableViewCell = messageItemView.superview?.superview as? MessageTableViewCell{
                let index: Int = customTableView.indexPath(for: tableViewCell)?.row ?? -1
                switch sender.direction {
                case UISwipeGestureRecognizer.Direction.left:
                    var allowLeftSwipe = true
                    if let prebSelectedTVIndex = selectedIndex {
                        if prebSelectedTVIndex == index {
                            allowLeftSwipe = false
                        }
                        else{
                            let indexpath = IndexPath(row: prebSelectedTVIndex, section: 0)
                            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? MessageTableViewCell {
                                prevTableViewCell.messageItemView.setRowActionForSwipeRight(duration: 0.4)
                                selectedIndex = nil
                            }
                        }
                    }
                    if allowLeftSwipe{
                        selectedIndex = index
                        messageItemView.setRowActionForSwipeLeft(duration: 0.4)
                    }
                case UISwipeGestureRecognizer.Direction.right:
                    if selectedIndex == index {
                        selectedIndex = nil
                        messageItemView.setRowActionForSwipeRight(duration: 0.4)
                    }
                default:
                    break
                }
            }
        }
    }
    
    @objc func onTouchLabel(sender: UITapGestureRecognizer){
        if let uiLabel = sender.view as? UILabel{
            if let messageItemView = uiLabel.superview as? MessageItemView{
                if let tableViewCell = messageItemView.superview?.superview as? MessageTableViewCell{
                    let indexPath: IndexPath = customTableView.indexPath(for: tableViewCell) ?? [0,0]
                    if selectedIndex != nil{
                        messageItemView.setRowActionForSwipeRight(duration: 0)
                    }
                    selectedIndex = nil
                    CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.message.alert.delete.message"), deleteClicked: {
                        self.deleteTableviewCellCalled(indexpath: indexPath)
                    })
                }
            }
        }
    }
    
    //MARK: - AppDataHandler delegate
    
    func messageUnreadCountDidReceiveData(isSuccess: Bool, error: (any Error)?) {
        if isSuccess{
            if let messageModule = appDataHandler.moduleSectionArr.first(where: { (module) -> Bool in
                return module.moduleId == messageModuleId
            }) {
                numberOfUnreadMessage = messageModule.unreadCount
            }
            else{
                numberOfUnreadMessage = 0
            }
            setUnreadCount()
        }
        else if let error{
            CharmUtil.createOkayAlertWith(error: error)
            hideActivityIndicator()
        }
    }
    
    //MARK: - charmconnection handler delegate methods
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey.hasPrefix("deleteUnreadMessage"){
            activityIndicatorView.stopAnimating()
            appDataHandler.refreshMessage = true
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                NotificationHandler.deleteDeliveredNotification(moduleId: messageModuleId, id: arrayOfUnread[row].messageId)
                arrayOfUnread.remove(at: row)
                
                if inboxAndSentSegmentControl.selectedSegmentIndex == 0
                {
                    removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
                }
            }
            numberOfUnreadMessage -= 1
            setUnreadCount()
            CharmUtil.showToast(controller: self, message: jsonObject.getString("message"), seconds: 2)
        }
        else if identificationKey.hasPrefix("deleteInboxMessage")
        {
            activityIndicatorView.stopAnimating()
            appDataHandler.refreshMessage = true
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                let message = arrayOfInbox[row]
                if message.messageReceipients?.status == "0"{
                    numberOfUnreadMessage -= 1
                    setUnreadCount()
                }
                NotificationHandler.deleteDeliveredNotification(moduleId: messageModuleId, id: message.messageId)
                arrayOfInbox.remove(at: row)
                
                if inboxAndSentSegmentControl.selectedSegmentIndex == 1
                {
                    removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
                }
            }
            CharmUtil.showToast(controller: self, message: jsonObject.getString("message"), seconds: 2)
        }
        else if identificationKey.hasPrefix("deleteSentMessage")
        {
            activityIndicatorView.stopAnimating()
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                arrayOfSent.remove(at: row)
                
                if inboxAndSentSegmentControl.selectedSegmentIndex == 2
                {
                    removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
                }
            }
            CharmUtil.showToast(controller: self, message: jsonObject.getString("message"), seconds: 2)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey.contains("fetchSentMessage") || identificationKey.contains("fetchInboxMessage") || identificationKey.contains("fetchUnreadMessage") || identificationKey.contains("fetchRestriction")
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        self.hideActivityIndicator()
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey == "fetchUnreadMessage"{
            appDataHandler.reloadMessage = false
            if let messageResp = response as? MDPagiationDataResponse<Messages> {
                unreadMessageHandler.updatePaginationResponse(pagination: messageResp)
                messageUnreadPageNo = messageResp.page
                
                if messageUnreadPageNo == 1{
                    hideActivityIndicator()
                }
                getNextUnreadData()
            }
        }
        if identificationKey == "fetchInboxMessage" {
            appDataHandler.reloadMessage = false
            if let messageResp = response as? MDPagiationDataResponse<Messages> {
                inboxMessageHandler.updatePaginationResponse(pagination: messageResp)
                messageInboxPageNo = messageResp.page
                
                if messageInboxPageNo == 1{
                    hideActivityIndicator()
                }
                getNextInboxData()
            }
        }
        else  if identificationKey == "fetchSentMessage" {
            if let messageResp = response as? MDPagiationDataResponse<Messages> {
                sentMessageHandler.updatePaginationResponse(pagination: messageResp)
                messageSentPageNo = messageResp.page
                if messageSentPageNo == 1{
                    hideActivityIndicator()
                }
                getNextSentData()
            }
        }
    }
    
    private func getNextUnreadData(){
        let messageList = unreadMessageHandler.getNextElements()
        
        if messageUnreadPageNo == 1 {
            arrayOfUnread = messageList
            customTableView.reloadData()
        }
        else{
            if !messageList.isEmpty {
                var indexPathArr:[IndexPath] = []
                let finalCount = arrayOfUnread.count + messageList.count
                for startIndex in (arrayOfUnread.count...finalCount-1 ){
                    indexPathArr.append(IndexPath(row: startIndex, section: 0))
                }
                
                customTableView.beginUpdates()
                arrayOfUnread.append(contentsOf: messageList)
                customTableView.insertRows(at: indexPathArr, with: .top)
                customTableView.endUpdates()
            }
            customTableView.infiniteScrollingView.stopAnimating()
        }
        customTableView.showsInfiniteScrolling = unreadMessageHandler.allowInfinityScroll()
    }
    
    private func getNextInboxData(){
        
        let messageList = inboxMessageHandler.getNextElements()
        
        if messageInboxPageNo == 1 {
            arrayOfInbox = messageList
            customTableView.reloadData()
        }
        else{
            if !messageList.isEmpty {
                var indexPathArr:[IndexPath] = []
                let finalCount = arrayOfInbox.count + messageList.count
                for startIndex in (arrayOfInbox.count...finalCount-1 ){
                    indexPathArr.append(IndexPath(row: startIndex, section: 0))
                }
                
                customTableView.beginUpdates()
                arrayOfInbox.append(contentsOf: messageList)
                customTableView.insertRows(at: indexPathArr, with: .top)
                customTableView.endUpdates()
            }
            customTableView.infiniteScrollingView.stopAnimating()
        }
        customTableView.showsInfiniteScrolling = inboxMessageHandler.allowInfinityScroll()
    }
    
    private func getNextSentData(){
        
        let messageList = sentMessageHandler.getNextElements()
        
        if messageSentPageNo == 1 {
            arrayOfSent = messageList
            customTableView.reloadData()
        }
        else{
            
            if !messageList.isEmpty {
                var indexPathArr:[IndexPath] = []
                let finalCount = arrayOfSent.count + messageList.count
                for startIndex in (arrayOfSent.count...finalCount-1 ){
                    indexPathArr.append(IndexPath(row: startIndex, section: 0))
                }
                
                customTableView.beginUpdates()
                arrayOfSent.append(contentsOf: messageList)
                customTableView.insertRows(at: indexPathArr, with: .top)
                customTableView.endUpdates()
            }
        }
        customTableView.infiniteScrollingView.stopAnimating()
        customTableView.showsInfiniteScrolling = sentMessageHandler.allowInfinityScroll()
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        charmConnectionHandlerDidFailWithError(error: error, identificationKey: identificationKey)
    }
    
    override func noDataViewRetryBtnClicked() {
        loadRequest()
    }
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        arrayOfSent = []
        if inboxAndSentSegmentControl.selectedSegmentIndex == 2 {
            loadRequest()
        }
    }
    
    // MARK: - prepare for segue
    
    private func pushToMessageDetailVC(){
        let vc = MessageDetailViewController(message: selectMessage, delegate: self)
        if inboxAndSentSegmentControl.selectedSegmentIndex == 0 || inboxAndSentSegmentControl.selectedSegmentIndex == 1
        {
            vc.isInboxMessage = true
        }else
        {
            vc.isInboxMessage = false
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushComposeMessageVC(){
        let messageRestictionList = arrayOfMessageRestriction.filter { (messageRestriction) -> Bool in
            if messageRestriction.isMessageRestrict == false && messageRestriction.allowMessaging == true
            {
                return true
            }else
            {
                return false
            }
        }
        
        let composeMsgVc = ComposeMessageViewController(enabledMessageRestictionList: messageRestictionList, delegate: self)
        
        self.navigationController?.pushViewController(composeMsgVc, animated: true)
    }
}

class MessageRestriction
{
    var practice : Practice? = nil
    var allowMessaging : Bool = true
    var isMessageRestrict : Bool = false
    var numberOfCharAllowed : Int = 0
}
