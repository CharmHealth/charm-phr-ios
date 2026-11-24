//
//  DocumentShareViewController.swift
//  phr
//
//  Created by prathi-13964 on 28/10/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit
import QuickLook

protocol DocumentShareVCDelegate: AnyObject{
    var selectedDocumentArray: [Document] { get set }
    var isDocumentSharedByMe: Bool { get set }
    func documentShareSuccess()
    func reloadTableView()
}
class DocumentShareViewController: AddDataUIViewController, CharmConnectionHandlerDelegate, CharmConnectionHandlerDataDelegate, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, SelectValueViewControllerDelagate, AddContactVCDelegate, CustomTextFieldDelegate, PDFImageVCDelegate, CardViewWithCloseBtnDelegate, DocumentAttachmentViewDelegate, CharmConnectionV2HandlerDelegate{
    
    private lazy var documentShareView = DocumentShareView()
    private let activityIndicator = UIActivityIndicatorView()
    var charmConnectionHandler: CharmConnectionHandler?
    var shareDocumentModel = ShareDocumentModel()
    var sharePracticeArray: [ShareDocRestriction] = []
    weak var delegate: DocumentShareVCDelegate?
    var previewItem : URL!
    var isPracticeVisible: Bool = false
    var isfetchContact: Bool = false
    private var selectedDocument: Document? = nil
    private var pdfImageVC: PDFImageViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(activityIndicator)
        activityIndicator.color = .gray
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.dataDelegate = self
        charmConnectionHandler?.v2Delegate = self
        
        self.title = getString(key: "com.charmphr.sharedocuments.title")
        self.navigationItem.largeTitleDisplayMode = .never
        
        fetchShareDocumentRestriction()
    }
    
    private func setDocumentShareView(){
       
        self.view.addSubview(documentShareView)
        
        documentShareView.setSafeAreaLeft(offset: 0)
        documentShareView.setSafeAreaRight(offset: 0)
        documentShareView.setSafeAreaTop(offset: 0)
        documentShareView.setSafeAreaBottom(offset: 0)
        
        documentShareView.shareToSegmentControl.addTarget(self, action: #selector(onSegmentControlChange(_:)), for: .valueChanged)
        documentShareView.documentShareVCdelegate = self
        documentShareView.toPracticeTextField.delegate = self
        documentShareView.toOtherTextField.delegate = self
        documentShareView.toPracticeTextField.textFieldDelegate = self
        documentShareView.toOtherTextField.textFieldDelegate = self
        documentShareView.receiverListTableView.separatorStyle = .singleLine
        documentShareView.receiverListTableView.register(ProviderTableViewCell.self, forCellReuseIdentifier: "ProviderTableViewCell")
        documentShareView.receiverListTableView.register(ShareDocumentTableViewCell.self, forCellReuseIdentifier: "ShareDocumentTableViewCell")
        documentShareView.receiverListTableView.delegate = self
        documentShareView.receiverListTableView.dataSource = self
        documentShareView.addToContactBtn.addTarget(self, action: #selector(onClickAddToContactBtn), for: .touchUpInside)
        documentShareView.expiryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onExpiryViewClick)))
        
        if isPracticeVisible{
            self.title = getString(key: "com.charmphr.sharedocuments.title")
            documentShareView.segmentControlHeightConstraint?.constant = SEGMENTCONTROL_HEIGHT
            documentShareView.shareToSegmentControl.isHidden = false
            fetchProviderList()
        }
        else{
            self.title = getString(key: "com.charmphr.sharedocuments.navigation.title")
            documentShareView.segmentControlHeightConstraint?.constant = 0
            documentShareView.shareToSegmentControl.isHidden = true
            documentShareView.isOthersViewHidden(isHidden: false)
            documentShareView.shareToSegmentControl.selectedSegmentIndex = 1
            documentShareView.informationView.isHidden = false
            fetchPharmacyList()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: getString(key: "com.charmphr.action.share"), style: .plain, target: self, action: #selector(shareOnClick))
        
        loadSelectedAttachments()
    }
    
//MARK: - API calls
    
    func fetchProviderList(){
        fetchPharmacyList()
        charmConnectionHandler?.fetchPatientMembers(identificationKey: "fetchPatientMemberList")
    }
    
    func fetchPharmacyList(){
        showActivityIndicator()
        charmConnectionHandler?.fetchPharmacyListObj(identificationKey: "fetchPharmacyList", searchText: "")
    }
    func fetchProviderPhoto()
    {
        guard !shareDocumentModel.providerArray.isEmpty else { return }
        for (i, provider) in shareDocumentModel.providerArray.enumerated()
        {
            charmConnectionHandler?.fetchProviderPhoto(providerId: provider.memberId ?? "", practiceId: provider.practiceId ?? "" , providerIndex: i , identificationKey: "fetchProviderPhoto")
        }
    }
    
    private func fetchShareDocumentRestriction(){
        showActivityIndicator()
        charmConnectionHandler?.shareDocumentRestriction(identificationKey: "shareDocumentRestriction")
    }
    
//MARK: - CharmConnectionHandler Delegate functions
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey == "fetchProviderPhoto"{
            if let indexPath = indexPath{
                let provider = shareDocumentModel.providerArray[indexPath.row]
                provider.photo = UIImage(data: data)
                documentShareView.receiverListTableView.reloadData()
            }
        }
        else if identificationKey.hasPrefix("downloadDocument")
        {
            pdfImageVC?.createView(newData: data)
        }
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {

        if identificationKey == "fetchPatientMemberList"{
            shareDocumentModel.count += 1
            shareDocumentModel.providerArray = ParsingHelper.formPatientMemberList(respObj: jsonObject)
            fetchProviderPhoto()
        }
        else if identificationKey == "fetchPharmacyList"{
            shareDocumentModel.count += 1
            let pharmacyArray = ParsingHelper.formPharmacyList(respObj: jsonObject)
            for pharmacy in pharmacyArray {
                if ((pharmacy.contactDetails?.emailId.isNilOrBlank()) == false){
                    shareDocumentModel.pharmacyList.append(pharmacy)
                }
            }
        }
        else if identificationKey == "ShareDocumentsToOthers" || identificationKey == "ShareDocumentsToMembers"{
            hideActivityIndicator()
            self.navigationController?.popViewController(animated: true)
            delegate?.documentShareSuccess()
        }
        if shareDocumentModel.count == 2 && isPracticeVisible{
            checkPracticeEnableForShare(providerList: shareDocumentModel.providerArray)
            hideActivityIndicator()
            shareDocumentModel.count = 0
        }
        else if isfetchContact{
            hideActivityIndicator()
        }
        else if !isPracticeVisible{
            hideActivityIndicator()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        pdfImageVC?.navigationController?.popViewController(animated: true)
        pdfImageVC = nil
        if identificationKey == "fetchPatientMemberList" || identificationKey == "fetchPharmacyList"{
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.fetchProviderList()
            }
        }
        else if identificationKey == "ShareDocumentsToOthers" || identificationKey == "ShareDocumentsToMembers"{
            CharmUtil.createOkayAlertWith(error: error)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "shareDocumentRestriction"{
            if let resp = response as? [ShareDocRestriction]{
                sharePracticeArray = resp
                checkShareEnableForPractice()
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
//MARK: - SelectValueVC Delegate method
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        
        let expiryListValue = documentShareView.expiryDaysList[selectedRow]
        shareDocumentModel.expiryDayValue = "\(expiryListValue.getIntFromString() ?? 0)"
        documentShareView.expiryValueLabel.text = expiryListValue
        documentShareView.expiryDaySelectedIndex = selectedRow
    }
    
//MARK: - AddContact Delegate
    
    func addContactValue(createdPharmacyArray: [Pharmacy]?, delegateText: String) {
        if let pharmacyArray = createdPharmacyArray{
            for pharmacyObj in pharmacyArray{
                shareDocumentModel.selectedPharmacyArray.append(pharmacyObj)
                shareDocumentModel.receiverPharmacyNames = ""
                createView(selectedClass: shareDocumentModel.selectedPharmacyArray.last ?? Pharmacy(), index: shareDocumentModel.selectedPharmacyArray.count - 1)
                documentShareView.toOtherTextField.text = ""
                documentShareView.becomeFirstResponder()
            }
            isfetchContact = true
            fetchPharmacyList()
        }
        documentShareView.toOtherTextField.becomeFirstResponder()
        documentShareView.toOtherTextField.text = delegateText
    }
    
//MARK: - CustomTextField delegate
    
    func selectView() {
        setBackGroundColor(isEmpty: true)
    }
    
    func backButtonOnEmptyField() {
        
        var cardViewWithCloseBtn: UIView?
        if isMember(){
            cardViewWithCloseBtn = returnLastProviderCardView()
        }
        else{
            cardViewWithCloseBtn = returnLastPharmacyCardView()
        }
        
        if let cardViewWithCloseBtn = cardViewWithCloseBtn as? CardViewWithCloseBtn{
            onCloseBtnTapped(cardViewWithCloseBtn)
        }
        
    }
    
    func setBackGroundColor(isEmpty: Bool){
        
        var cardViewWithCloseBtn: UIView?
        if isMember(){
            cardViewWithCloseBtn = returnLastProviderCardView()
        }
        else{
            cardViewWithCloseBtn = returnLastPharmacyCardView()
        }
        if isEmpty{
            cardViewWithCloseBtn?.setBackgroundColor(bgColor: LIGHT_BLUE_BACKGROUND_COLOR)
        }
        else{
            cardViewWithCloseBtn?.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
        }
    }
    
    func returnLastProviderCardView() -> UIView?{
        let viewTag: Int = shareDocumentModel.providerViewTagArr.last ?? -1
        if let cardView = self.view.viewWithTag(viewTag) as? CardViewWithCloseBtn{
            return cardView
        }
        else{
            return nil
        }
    }
    
    func returnLastPharmacyCardView() -> UIView?{
        let viewTag: Int = shareDocumentModel.pharmacyViewTagArr.last ?? -1
        if let cardView = self.view.viewWithTag(viewTag) as? CardViewWithCloseBtn{
            return cardView
        }
        else{
            return nil
        }
    }
    
//MARK: - TableView Delegate functions
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shareDocumentModel.isListViewOpened{
            documentShareView.setConerRadiusOnlyUp()
            if isMember(){
                return shareDocumentModel.providerArrayToBeShown.count
            }
            else{
                return shareDocumentModel.pharmacyArrayToBeShown.count
            }
        }else{
            documentShareView.setAllCornerRadius()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isMember(){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderTableViewCell") as? ProviderTableViewCell {
                let provider = shareDocumentModel.providerArrayToBeShown[indexPath.row]
                cell.setTableViewCellData(data: provider)
                return cell
            }
        }
        else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ShareDocumentTableViewCell") as? ShareDocumentTableViewCell{
                let pharmacy = shareDocumentModel.pharmacyArrayToBeShown[indexPath.row]
                cell.setTableViewCell(data: pharmacy)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        setBackGroundColor(isEmpty: false)
        if isMember(){
            shareDocumentModel.receiverProviderNames = ""
            documentShareView.toPracticeTextField.backCount = 0
            let provider: Provider = shareDocumentModel.providerArrayToBeShown[index]
            shareDocumentModel.selectedProviderArray.append(provider)
            
            createView(selectedClass: provider, index: shareDocumentModel.selectedProviderArray.count - 1)
            documentShareView.toPracticeTextField.text = ""
            textFieldDidBeginEditing(documentShareView.toPracticeTextField)
            
        }
        else{
            shareDocumentModel.receiverPharmacyNames = ""
            documentShareView.toOtherTextField.backCount = 0
            let pharmacy: Pharmacy = shareDocumentModel.pharmacyArrayToBeShown[indexPath.row]
            shareDocumentModel.selectedPharmacyArray.append(pharmacy)
            
            createView(selectedClass: pharmacy, index: shareDocumentModel.selectedPharmacyArray.count - 1)
            documentShareView.toOtherTextField.text = ""
            textFieldDidBeginEditing(documentShareView.toOtherTextField)
        }
    }
    
//MARK: - TextField Delegate functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textFieldEndEditing()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        if let textInput = textField.text{
            if textInput.isEmpty{
                if textField == documentShareView.toPracticeTextField || isMember(){
                    documentShareView.hideMemberNoData(isHidden: true)
                    memberListShown()
                }
                else{
                    documentShareView.hideOthersNoData(isHidden: true)
                    pharmacyListShown()
                }
                shareDocumentModel.isListViewOpened = true
                documentShareView.receiverListTableView.reloadData()
            }
            else{
                shareDocumentModel.isListViewOpened = true
                filterReciversListAndReloadTableView(searchStr: textInput)
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if let textInput = textField.text{
            if textInput.isEmpty{
                if textField == documentShareView.toPracticeTextField || isMember(){
                    documentShareView.hideMemberNoData(isHidden: true)
                    memberListShown()
                }
                else{
                    documentShareView.hideOthersNoData(isHidden: true)
                    pharmacyListShown()
                }
                shareDocumentModel.isListViewOpened = true
                documentShareView.receiverListTableView.reloadData()
            }
            else{
                shareDocumentModel.isListViewOpened = true
                filterReciversListAndReloadTableView(searchStr: textInput)
                if textField.text?.count ?? 0 > 0{
                    if textField == documentShareView.toPracticeTextField || isMember(){
                        documentShareView.toPracticeTextField.backCount = 0
                    }
                    else{
                        documentShareView.toOtherTextField.backCount = 0
                    }
                    setBackGroundColor(isEmpty: false)
                }
            }
        }
    }
 
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == documentShareView.toPracticeTextField || isMember(){
            textField.text = shareDocumentModel.receiverProviderNames
        }
        else{
            textField.text = shareDocumentModel.receiverPharmacyNames
        }
        textFieldEndEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        let newText = oldText.replacingCharacters(in: r, with: string)
        
        if textField == documentShareView.toPracticeTextField || isMember()
        {
            shareDocumentModel.receiverProviderNames = newText
            return textFieldShouldChange(textField: textField, receiverString: newText) && newText.count <= 50
        }
        else{
            shareDocumentModel.receiverPharmacyNames = newText
            return textFieldShouldChange(textField: textField, receiverString: newText) && newText.count <= 50
        }
    }
        
    func textFieldShouldChange(textField: UITextField, receiverString: String) -> Bool{
            
        if shareDocumentModel.isListViewOpened
        {
            if textField.text?.count ?? 0 > receiverString.count || receiverString.isEmpty
            {
                filterReciversListAndReloadTableView(searchStr: textField.text ?? "")
            }
        }
        return true
    }

    func textFieldEndEditing(){
        documentShareView.toPracticeTextField.resignFirstResponder()
        documentShareView.toOtherTextField.resignFirstResponder()
        shareDocumentModel.isListViewOpened = false
        documentShareView.receiverListTableView.reloadData()
        documentShareView.hideOthersNoData(isHidden: true)
        documentShareView.hideMemberNoData(isHidden: true)
    }
    
//MARK: - Creating View
    
    // adding the selected Name to the view in a card form
    func createView(selectedClass: Any, index: Int){
        
        let selectedProvider = selectedClass as? Provider
        let selectedPharmacy = selectedClass as? Pharmacy
        var labelText: String
        if isMember(){
            labelText = StringUtil.getNameWithPrefixAndFullName(fullName: selectedProvider?.fullName ?? "", prefix: selectedProvider?.prefix)
        }
        else{
            labelText = selectedPharmacy?.pharmacyName ?? ""
        }
        
        let cardViewWithCloseBtn = CardViewWithCloseBtn(name: labelText, viewWidth: documentShareView.toValueViewWidth, delegate: self)
        cardViewWithCloseBtn.tag = shareDocumentModel.tagNo
        if isMember(){
            shareDocumentModel.providerViewTagArr.append(shareDocumentModel.tagNo)
            cardViewWithCloseBtn.value = selectedProvider
            documentShareView.toPracticeView.addSubview(cardViewWithCloseBtn)
        }
        else{
            shareDocumentModel.pharmacyViewTagArr.append(shareDocumentModel.tagNo)
            cardViewWithCloseBtn.value = selectedPharmacy
            documentShareView.toOtherView.addSubview(cardViewWithCloseBtn)
        }
        shareDocumentModel.tagNo += 1
        documentShareView.removeDeletedViewAndSetConstraints(removedView: nil, isMember: isMember())
    }
    
    // Set selected document in the view by removing all the subview from the superview and add adding the selected document to the view in the format of card view
    
    func loadSelectedAttachments(){
        for subViews in documentShareView.attachmentView.subviews{
            subViews.removeFromSuperview()
        }
        
        if let delegate{
            if delegate.selectedDocumentArray.count > 0{
                let selectedDocumentList = delegate.selectedDocumentArray
                var hasSpace = false
                let viewFrame = SUPPORT_FRAME_WIDTH
                var beforeView: UIView?
                for (i,documentObj) in selectedDocumentList.enumerated(){
                    
                    debugPrintLog("\(i) -> \(documentObj.fileType ?? "")")
                    let attachmentView = DocumentAttachmentView(name: documentObj.fileName ?? "", fileSize: documentObj.fileSize ?? "", delegate: self)
                    documentShareView.attachmentView.addSubview(attachmentView)
                    
                    attachmentView.value = documentObj
                    attachmentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OnClickCardView)))
                    
                    attachmentView.arrangeViews(constant: CARD_PADDING, hasSpace: hasSpace, beforeView: beforeView)
                    beforeView = attachmentView
                    hasSpace = !hasSpace
                    
                    attachmentView.setWidth(constant: (viewFrame / 2) - 10)
                    if i == selectedDocumentList.count - 1{
                        attachmentView.setBottom(offSet: -10)
                    }
                }
            }
        }
    }
    
//MARK: - CardViewWithCloseBtn Delegate
    
    func onCloseBtnTapped(_ view: CardViewWithCloseBtn) {
        setBackGroundColor(isEmpty: false)
        if documentShareView.shareToSegmentControl.selectedSegmentIndex == 0{
            documentShareView.toPracticeTextField.backCount = 0
            let providerIndex: Int = shareDocumentModel.selectedProviderArray.firstIndex(where: {provider in
                return provider.memberId == (view.value as? Provider)?.memberId
            }) ?? 0
            shareDocumentModel.selectedProviderArray.remove(at: providerIndex)
            documentShareView.removeDeletedViewAndSetConstraints(removedView: view, isMember: true)
            shareDocumentModel.providerViewTagArr.removeAll(where: { tag in
                return view.tag == tag
            })
            textFieldDidBeginEditing(documentShareView.toPracticeTextField)
        }
        else{
            documentShareView.toOtherTextField.backCount = 0
            let pharmacyIndex: Int = shareDocumentModel.selectedPharmacyArray.firstIndex(where: {pharmacy in
                return pharmacy.patientPharmaMapId == (view.value as? Pharmacy)?.patientPharmaMapId
            }) ?? 0
            
            shareDocumentModel.selectedPharmacyArray.remove(at: pharmacyIndex)
            shareDocumentModel.pharmacyViewTagArr.removeAll(where: { tag in
                return view.tag == tag
            })
            documentShareView.removeDeletedViewAndSetConstraints(removedView: view, isMember: false)
            textFieldDidBeginEditing(documentShareView.toOtherTextField)
        }
    }
    
//MARK: - DocumentAttachmentView Delegate
    
    func onCloseBtnTapped(_ view: DocumentAttachmentView) {
        if delegate?.selectedDocumentArray.count == 1{
            CharmUtil.createYesAndNoAlertWith(title: nil, msg: getString(key: "com.charmphr.sharedocuments.attachment.close.alert.message"), yesClicked: {
                self.delegate?.reloadTableView()
                self.navigationController?.popViewController(animated: true)
            })
        }
        else{
            let documentIndex: Int = delegate?.selectedDocumentArray.firstIndex(where: {document in
                return document.fileId == (view.value as? Document)?.fileId
            }) ?? -1
            delegate?.selectedDocumentArray.remove(at: documentIndex)
            loadSelectedAttachments()
        }
    }
    
//MARK: - Other functions
    
    func checkShareEnableForPractice(){
        guard let delegate else { return }
        var count = 0
        sharePracticeArray.forEach({shareDocRestriction in
            if shareDocRestriction.isShareAllowed && !delegate.isDocumentSharedByMe{
                isPracticeVisible = true
            }
            else{
                count += 1
                if count == sharePracticeArray.count{
                    isPracticeVisible = false
                }
                else{
                    isPracticeVisible = true
                }
            }
        })
        setDocumentShareView()
    }
    
    func memberListShown(){
        if shareDocumentModel.selectedProviderArray.isEmpty{
            shareDocumentModel.providerArrayToBeShown = shareDocumentModel.providerArray
        }
        else{
            shareDocumentModel.providerArrayToBeShown = shareDocumentModel.providerArray.filter({ (provider) -> Bool in
                return checkIfProviderIsUnSelected(provider: provider)
            })
        }
    }
    
    func pharmacyListShown(){
        if shareDocumentModel.selectedPharmacyArray.isEmpty{
            shareDocumentModel.pharmacyArrayToBeShown = shareDocumentModel.pharmacyList
        }
        else{
            shareDocumentModel.pharmacyArrayToBeShown = shareDocumentModel.pharmacyList.filter({ (pharmacy) -> Bool in
                return checkIfPharmacyIsUnSelected(pharmacy: pharmacy)
            })
        }
    }
    
    // check if practice is enable for share
    func checkPracticeEnableForShare(providerList: [Provider]){
        shareDocumentModel.providerArray = []
        providerList.forEach({provider in
            let sharePractice: ShareDocRestriction = sharePracticeArray.first(where: { sharePractice in
                return sharePractice.practiceId == provider.practiceId
            }) ?? ShareDocRestriction()
            if sharePractice.isShareAllowed{
                shareDocumentModel.providerArray.append(provider)
            }
        })
    }
    
    @objc func OnClickCardView(sender: UITapGestureRecognizer){
        
        selectedDocument = nil
        if let attachmentView = sender.view as? DocumentAttachmentView, let document = attachmentView.value as? Document{
            selectedDocument = document
            
            pdfImageVC = PDFImageViewController(fileName: selectedDocument?.fileName, data: selectedDocument?.fileData, delegate: self, isAllowDownloadFile: true)
            if let pdfImageVC{
                self.navigationController?.pushViewController(pdfImageVC, animated: true)
            }
        }
    }
    
    func downloadFile() {
        charmConnectionHandler?.downloadDocument(patientId: Patient.selectedPatientInstance?.patientId ?? "", documentId: selectedDocument?.fileId ?? "", identificationKey: "downloadDocument")
    }
    
    func cancelPDFImageVC() {
        pdfImageVC = nil
    }
    
    func setTextFieldDelegate(textField: CustomTextField){
        textField.delegate = self
        textField.textFieldDelegate = self
    }
    
    // Fetching (provider or pharmacy) list with filtering selected (provider or pharmacy)
    func filterReciversListAndReloadTableView(searchStr: String)
    {
        let arrayOfSearchStr = searchStr.components(separatedBy: ", ")
        let searchParticularStr = arrayOfSearchStr[arrayOfSearchStr.count - 1]
        
        if isMember(){
            shareDocumentModel.providerArrayToBeShown = shareDocumentModel.providerArray.filter({ (provider) -> Bool in
                if !shareDocumentModel.selectedProviderArray.isEmpty
                {
                    if !isNilOrEmpty(string: searchParticularStr){
                        if ((provider.fullName?.lowercased().contains(searchParticularStr.lowercased())) != false){
                            return checkIfProviderIsUnSelected(provider: provider)
                        }else{
                            return false
                        }
                    }else {
                        return checkIfProviderIsUnSelected(provider: provider)
                    }
                }else {
                    if  provider.fullName?.lowercased().contains(searchParticularStr.lowercased()) ?? false || provider.practiceName?.lowercased().contains(searchParticularStr.lowercased()) ?? false{
                         return true
                    }else{
                         return false
                    }
                }
            })
            
            if shareDocumentModel.providerArrayToBeShown.isEmpty{
                documentShareView.hideMemberNoData(isHidden: false)
            }
            else{
                documentShareView.hideMemberNoData(isHidden: true)
            }
        }
        else{
            shareDocumentModel.pharmacyArrayToBeShown = shareDocumentModel.pharmacyList.filter({ (pharmacy) -> Bool in
                if !shareDocumentModel.selectedPharmacyArray.isEmpty{
                    if !isNilOrEmpty(string: searchParticularStr){
                        if ((pharmacy.pharmacyName?.lowercased().contains(searchParticularStr.lowercased())) == true) || ((pharmacy.contactDetails?.emailId?.lowercased().contains(searchParticularStr.lowercased())) == true){
                            return checkIfPharmacyIsUnSelected(pharmacy: pharmacy)
                        }else{
                            return false
                        }
                    }else{
                        return checkIfPharmacyIsUnSelected(pharmacy: pharmacy)
                    }
                }else{
                    if  ((pharmacy.pharmacyName?.lowercased().contains(searchParticularStr.lowercased())) == true) || ((pharmacy.contactDetails?.emailId?.lowercased().contains(searchParticularStr.lowercased())) == true){
                         return true
                    }else{
                         return false
                    }
                }
            })
            
            if shareDocumentModel.pharmacyArrayToBeShown.isEmpty{
                documentShareView.hideOthersNoData(isHidden: false)
            }
            else{
                documentShareView.hideOthersNoData(isHidden: true)
            }
        }
        documentShareView.receiverListTableView.reloadData()
    }
    
    // check if the provider is selected
    
    func checkIfProviderIsUnSelected(provider : Provider) -> Bool
    {
        if shareDocumentModel.selectedProviderArray.contains(where: { (selectedProvider) -> Bool in
            return selectedProvider.memberId == provider.memberId
        })
        {
           return false
        }else{
           return true
       }
    }
    
    // check if the pharmacy is selected
    
    func checkIfPharmacyIsUnSelected(pharmacy: Pharmacy) -> Bool{
        if shareDocumentModel.selectedPharmacyArray.contains(where: { (selectedPharmacy) -> Bool in
            return selectedPharmacy.patientPharmaMapId == pharmacy.patientPharmaMapId
        })
        {
           return false
        }else{
           return true
       }
    }
    
    func isMember() -> Bool{
        return documentShareView.shareToSegmentControl.selectedSegmentIndex == 0
    }
    
    func showActivityIndicatorFront(){
        self.view.bringSubviewToFront(activityIndicator)
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    func showActivityIndicator(){
        documentShareView.containerScrollView.isHidden = true
        showActivityIndicatorFront()
    }
    func hideActivityIndicator(){
        self.view.isUserInteractionEnabled = true
        documentShareView.containerScrollView.isHidden = false
        activityIndicator.stopAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func addActionForAlertVCOnBackClick(title: String){
        CharmUtil.createYesAndNoAlertWith(title: title, msg: nil, yesClicked: {
            self.delegate?.reloadTableView()
            self.navigationController?.popViewController(animated: true)
        })
    }
    
//MARK: - Target Functions
        
    @objc func onExpiryViewClick(){
        
        let selectValueVC = SelectValueViewController()
        selectValueVC.title = documentShareView.expiryLabel.text
        
        selectValueVC.navigationItem.largeTitleDisplayMode = .never
        selectValueVC.delegate = self
        selectValueVC.arrayOfValueToBeShown = documentShareView.expiryDaysList
        selectValueVC.selectedValueIndex = documentShareView.expiryDaySelectedIndex
        self.navigationController?.pushViewController(selectValueVC, animated: true)
    }
        
    @objc func onSegmentControlChange(_ sender: UISegmentedControl){
        self.view.endEditing(true)
        if sender.selectedSegmentIndex == 0{
            textFieldEndEditing()
            documentShareView.isOthersViewHidden(isHidden: true)
        }
        else{
            textFieldEndEditing()
            documentShareView.isOthersViewHidden(isHidden: false)
        }
    }
        
    @objc func onClickAddToContactBtn(){
        let addContactViewController = AddContactViewController()
        addContactViewController.delegate = self
        
        if let textOtherField = documentShareView.toOtherTextField.text{
            if textOtherField.isNotBlank(){
                addContactViewController.delegateText = textOtherField
            }
        }
        
        documentShareView.hideOthersNoData(isHidden: true)
        self.navigationController?.pushViewController(addContactViewController, animated: true)
    }
        
    @objc func shareOnClick(){
        self.view.endEditing(true)
        if isMember(){
            if shareDocumentModel.selectedProviderArray.isEmpty{
                
                CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.sharedocuments.provider.alert.message"), okClicked: {
                    self.documentShareView.toPracticeTextField.becomeFirstResponder()
                })
            }
            else{
                showActivityIndicatorFront()
                if let selectedDocumentArray = delegate?.selectedDocumentArray{
                    charmConnectionHandler?.shareDocumentToMembers(identificationKey: "ShareDocumentsToMembers", documentList: selectedDocumentArray, memberList: shareDocumentModel.selectedProviderArray)
                }
            }
        }
        else{
            if shareDocumentModel.selectedPharmacyArray.isEmpty{
                CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.sharedocuments.pharmacy.alert.message"), okClicked: {
                    self.documentShareView.toOtherTextField.becomeFirstResponder()
                })
            }
            else{
                showActivityIndicatorFront()
                let expiryDay: Int = shareDocumentModel.expiryDayValue.toIntOrNil() ?? 0
                let expiryDate: Date = Calendar.current.date(byAdding: .day, value: expiryDay, to: Date()) ?? Date()
                if let selectedDocumentArray = delegate?.selectedDocumentArray{
                charmConnectionHandler?.shareDocumentToOthers(identificationKey: "ShareDocumentsToOthers", documentList: selectedDocumentArray, contactList: shareDocumentModel.selectedPharmacyArray, expiryDate: expiryDate)
                }
            }
        }
    }
        
    @objc override func onBackClick() {
        self.view.endEditing(true)
        if (!documentShareView.toOtherTextField.text.isNilOrBlank() || !documentShareView.toPracticeTextField.text.isNilOrBlank() || documentShareView.expiryDaySelectedIndex != 0 || shareDocumentModel.selectedProviderArray.count > 0 || shareDocumentModel.selectedPharmacyArray.count > 0) && delegate?.selectedDocumentArray.count ?? -1 == 1{
            showDiscardChangesDialog {
                self.delegate?.reloadTableView()
            }
        }
        else if delegate?.selectedDocumentArray.count ?? -1 >= 2{
            addActionForAlertVCOnBackClick(title: getString(key: "com.charmphr.sharedocuments.backButton.alert.message"))
        }
        else{
            delegate?.reloadTableView()
            self.navigationController?.popViewController(animated: true)
        }
    }
}
