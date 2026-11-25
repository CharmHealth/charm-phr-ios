//
//  InvoiceViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 30/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import WebKit
import Razorpay
import QuickLook

fileprivate let PATIENT_NAME_WIDTH: CGFloat = 100
fileprivate let INVOICE_NO_WIDTH:CGFloat = 55
fileprivate let PAYMENT_REQUESTED_WIDTH: CGFloat = 130
fileprivate let DUE_AT_PRESENT_WIDTH: CGFloat = 95
fileprivate let INVOICE_AMOUNT_WIDTH: CGFloat = 100

class InvoiceViewController: UIViewController , CharmConnectionHandlerDelegate,CharmConnectionV2HandlerDelegate,CharmConnectionHandlerDataDelegate , WKNavigationDelegate, RazorpayPaymentCompletionProtocol , PaymentViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, PDFImageVCPopDelegate {
    
    weak var delegate : AddViewControllerDelegate?
    
    var activityIndicator = UIActivityIndicatorView()
    var charmConnectionHandler : CharmConnectionHandler?
    
    let colorFilledBtn = UIButton(type: .custom)
    lazy var paymentRequestedView = KeyAndValueLabelView()

    
    var razorpay : RazorpayCheckout!
    
    var facilityId : String!
    var memberId : String!
    
    var previewItem : URL!
    
    var invoice : PHRBills!
    var invoicePdfUrl : String = ""
    
    var phrBillStatements: PHRBillStatements?
    
    var receiptId: String = ""
    
    var statementTableView: UITableView? = nil
    private var statementTableHeightConstraint: NSLayoutConstraint?
    let statementView = UIView()
    
   // var isRazorPay : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.navigationItem.title = getString(key: "com.charmphr.common.details")
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.dataDelegate = self
        charmConnectionHandler?.v2Delegate = self
        
        if !invoice.isStatement
        {
            showActivityIndicator()
            charmConnectionHandler?.fetchInvoiceDetail(patientId: getSelectedPatientId(), phrBillId: invoice.phrBillId ?? "", identificationKey: "invoiceDeatils")
        }else
        {
            showActivityIndicator()
            charmConnectionHandler?.getStatementDetails(statementId: invoice?.statementId ?? "", identificationKey: "getStatementDetails")
        }
        view.bringSubviewToFront(activityIndicator)
        
    }
    
    func createViews()
    {
//        let containerScrollView = UIScrollView()
//        self.view.addSubview(containerScrollView)
        
//        containerScrollView.layer.borderWidth = BORDER_WIDTH
//        containerScrollView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
//        containerScrollView.layer.cornerRadius = CORNER_RADIUS_5

        let containerView = UIView()
        self.view.addSubview(containerView)
        
        let invoiceView = BillingItemView()
        containerView.addSubview(invoiceView)
        
        invoiceView.setInvoice(bill: invoice)
        invoiceView.addShadowAndCornerRadius(.SMALL)
        
        invoiceView.setLeft(offSet: 16)
        invoiceView.setRight(offSet: -16)
        invoiceView.setTop(offSet: 10)
        
        if invoice.isStatement{
            createStatementView(parentView: containerView, topRelatedView: invoiceView, invoiceViewHeight: invoiceView.invoiceItemViewHeight + 10)
        }
        
//        containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
       // containerView.layer.cornerRadius = CORNER_RADIUS_5
//        containerScrollView.addSubview(containerView)
        
        // Safe-area edges (instead of the launch-time applicationFrame.width) so the cards follow
        // fold/unfold and rotation and stay clear of the iOS 27.1 landscape side bar.
        containerView.setSafeAreaTop(offset: 0)
        containerView.setBottom(offSet: 0)
        containerView.setSafeAreaLeft(offset: 0)
        containerView.setSafeAreaRight(offset: 0)

        colorFilledBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        colorFilledBtn.setTitleColor(.white, for: .normal)
        colorFilledBtn.addPillCornerRadiusAndShadow(height: PILL_BTN_HEIGHT)
        self.view.addSubview(colorFilledBtn)

        colorFilledBtn.setHeight(constant: PILL_BTN_HEIGHT)
        colorFilledBtn.setSafeAreaLeft(offset: X_SPACE)
        colorFilledBtn.setSafeAreaRight(offset: -X_SPACE)

        if invoice.isStatement {
            // The statement card never extends under the buttons; beyond that its table scrolls.
            statementView.bottomAnchor.constraint(lessThanOrEqualTo: colorFilledBtn.topAnchor, constant: -Y_SPACE).isActive = true
        }

        if invoice.isStatement {
            if let statement = phrBillStatements {
                if !isAmountValid(amount: statement.paymentRequest) || statement.isPaid || invoice.billType == billTypeCreditNote || invoice.gateway == "RAZORPAY" {
                    createViewPDFButton(isStatement: true)
                }
                else{
                    createPaymentButton(isStatement: true)
                }
            }
        }
        else{
            if !isAmountValid(amount: invoice.amount)  || invoice.isPaid == true || invoice.billType == billTypeCreditNote
                {
                createViewPDFButton(isStatement: false)
                }else
                {
                    
                    createPaymentButton(isStatement: false)
                }
        }
    }
    
    func createStatementView(parentView: UIView, topRelatedView: UIView, invoiceViewHeight: CGFloat){
        
        let statementScrollView = UIScrollView()
        let statementCardView = UIView()
        let statementHeadingView = UIStackView()
        statementTableView = UITableView()
        
        parentView.addSubview(statementView)
        statementView.addSubview(statementScrollView)
        statementScrollView.addSubview(statementCardView)
        statementCardView.addSubview(statementHeadingView)
        
        statementView.setLeft(offSet: 16)
        statementView.setRight(offSet: -16)
        statementView.setTopRelatedToView(offSet: 8, relatedView: topRelatedView, relatedAttribute: .bottom)
//        statementView.setBottom(offSet: -10)
        
        statementScrollView.setLeft(offSet: 0)
        statementScrollView.setRight(offSet: 0)
        statementScrollView.setTop(offSet: 0)
        statementScrollView.setBottom(offSet: 0)

        statementCardView.setLeft(offSet: 0)
        statementCardView.setRight(offSet: 0)
        statementCardView.setTop(offSet: 0)
        statementCardView.setBottom(offSet: 0)

        statementHeadingView.setLeft(offSet: 8)
        statementHeadingView.setRight(offSet: -8)
        statementHeadingView.setTop(offSet: 8)
        statementHeadingView.setHeight(constant: 18)

        // Height: the card hugs its content (heading + all rows) but never grows past the visible
        // scroll area, which in turn is capped above the buttons (see createViews). When capped, the
        // table gives up height (its row-count height is only .defaultHigh) and scrolls internally.
        // Replaces the old launch-time applicationFrame.height maths.
        let hugContent = statementScrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: statementScrollView.contentLayoutGuide.heightAnchor)
        hugContent.priority = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue - 1)
        NSLayoutConstraint.activate([
            hugContent,
            statementCardView.heightAnchor.constraint(lessThanOrEqualTo: statementScrollView.frameLayoutGuide.heightAnchor)
        ])

        statementView.addShadowAndCornerRadius(.SMALL)

        statementHeadingView.axis = .horizontal
        statementHeadingView.alignment = .fill
        statementHeadingView.spacing = 28

        let patientNameLabel = UILabel()
        statementHeadingView.addArrangedSubview(patientNameLabel)
        
        let invoiceNoLabel = UILabel()
        statementHeadingView.addArrangedSubview(invoiceNoLabel)
        
        if invoice.isPaymentRequestedShown{
            let paymentRequestedLabel = UILabel()
            statementHeadingView.addArrangedSubview(paymentRequestedLabel)
            
            paymentRequestedLabel.setProperties(textKey: "Payment Requested", fontsize: 13, weight: .semibold, fontcolor: THEME_COLOR)
            
            paymentRequestedLabel.setTop(offSet: 0)
            paymentRequestedLabel.setBottom(offSet: 0)
            paymentRequestedLabel.setWidth(constant: PAYMENT_REQUESTED_WIDTH)
        }
        
        let dueAtPresentLabel = UILabel()
        statementHeadingView.addArrangedSubview(dueAtPresentLabel)
        
        let invoiceAmountLabel = UILabel()
        statementHeadingView.addArrangedSubview(invoiceAmountLabel)

        patientNameLabel.setProperties(textKey: "Patient Name", fontsize: 13, weight: .semibold, fontcolor: THEME_COLOR)
        invoiceNoLabel.setProperties(textKey: "Invoice#", fontsize: 13, weight: .semibold, fontcolor: THEME_COLOR)
        dueAtPresentLabel.setProperties(textKey: "Due at Present", fontsize: 13, weight: .semibold, fontcolor: THEME_COLOR)
        invoiceAmountLabel.setProperties(textKey: "Invoice Amount", fontsize: 13, weight: .semibold, fontcolor: THEME_COLOR)

        patientNameLabel.setTop(offSet: 0)
        patientNameLabel.setBottom(offSet: 0)
        patientNameLabel.setWidth(constant: PATIENT_NAME_WIDTH)

        invoiceNoLabel.setTop(offSet: 0)
        invoiceNoLabel.setBottom(offSet: 0)
        invoiceNoLabel.setWidth(constant: INVOICE_NO_WIDTH)

        dueAtPresentLabel.setTop(offSet: 0)
        dueAtPresentLabel.setBottom(offSet: 0)
        dueAtPresentLabel.setWidth(constant: DUE_AT_PRESENT_WIDTH)

        invoiceAmountLabel.setTop(offSet: 0)
        invoiceAmountLabel.setBottom(offSet: 0)
        invoiceAmountLabel.setWidth(constant: INVOICE_AMOUNT_WIDTH)
        
        if let statementTableView = statementTableView{
            statementCardView.addSubview(statementTableView)

            statementTableView.setTopRelatedToView(offSet: 8, relatedView: statementHeadingView, relatedAttribute: .bottom)
            statementTableView.setLeft(offSet: 8)
            statementTableView.setRight(offSet: -8)
            statementTableView.setBottom(offSet: -10)

            let tableHeight = statementTableView.heightAnchor.constraint(equalToConstant: 0)
            tableHeight.priority = .defaultHigh
            tableHeight.isActive = true
            statementTableHeightConstraint = tableHeight

            statementTableView.separatorColor = .clear
            statementTableView.delegate = self
            statementTableView.dataSource = self
            statementTableView.register(StatementTableViewCell.self, forCellReuseIdentifier: "StatementTableViewCell")

            statementTableView.reloadData()
        }
    }
    
    private func createViewPDFButton(isStatement: Bool){
        if isStatement {
            colorFilledBtn.setTitle(getString(key: "com.charmphr.statement.viewStatement.title"), for: .normal)
        }
        else{
            colorFilledBtn.setTitle(getString(key: "com.charmphr.invoice.viewInvoice.title"), for: .normal)
        }
        colorFilledBtn.setSafeAreaBottom(offset: -Y_SPACE)
        paymentRequestedView.isHidden = true
        colorFilledBtn.addTarget(self, action: #selector(viewInvoiceBtnClicked), for: .touchUpInside)
    }
    
    private func createPaymentButton(isStatement: Bool){
        paymentRequestedView.isHidden = false

        colorFilledBtn.setTitle(getString(key: "com.charmphr.invoice.pay.title"), for: .normal)
        colorFilledBtn.addTarget(self, action: #selector(paynowClicked(_:)), for: .touchUpInside)

        let invoiceBtn = UIButton(type: .custom)
        invoiceBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xE5E5EAFF)
        invoiceBtn.addPillCornerRadiusAndShadow(height: PILL_BTN_HEIGHT)
        if isStatement {
            invoiceBtn.setTitle(getString(key: "com.charmphr.statement.viewStatement.title"), for: .normal)
        }
        else{
            invoiceBtn.setTitle(getString(key: "com.charmphr.invoice.viewInvoice.title"), for: .normal)
        }
        invoiceBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for: .normal)
        invoiceBtn.addTarget(self, action: #selector(viewInvoiceBtnClicked), for: .touchUpInside)
        self.view.addSubview(invoiceBtn)
        
        colorFilledBtn.setBottomRelatedToView(offSet: -Y_SPACE, relatedView: invoiceBtn ,relatedAttribute: .top)
        
        invoiceBtn.setHeight(constant: PILL_BTN_HEIGHT)
        invoiceBtn.setSafeAreaLeft(offset: X_SPACE)
        invoiceBtn.setSafeAreaRight(offset: -X_SPACE)
        invoiceBtn.setSafeAreaBottom(offset: -Y_SPACE)
    }
    
    private func showInvoicePDF(){
        
        //AppDataHandler.sharedInstance().refreshInvoice = true
        showActivityIndicator()
        charmConnectionHandler?.fetchPDF(urlString: invoicePdfUrl , identificationKey: "invoicePDF")
    }
    
    private func showReceiptPDF(){
        
        AppDataHandler.sharedInstance().refreshInvoice = true
        showActivityIndicator()
        charmConnectionHandler?.downloadReceiptPDF(patientId: Patient.selectedPatientInstance!.patientId, phrReceiptId: receiptId, identificationKey: "downloadPdf")
    }
    
//MARK: - TableView Delegate functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let phrbillsList = phrBillStatements?.phrBills{
            // Preferred (full) height only; the layout caps it to the space above the buttons.
            statementTableHeightConstraint?.constant = CGFloat(phrbillsList.count * 44) + 4
            return phrbillsList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "StatementTableViewCell") as? StatementTableViewCell{
            if let phrBills = phrBillStatements?.phrBills[indexPath.row]{
                tableViewCell.setTableViewCellData(data: phrBills, invoice: invoice)
            }
            return tableViewCell
        }
        
        return UITableViewCell()
    }
    
//MARK: - CharmConnectionHandler Delegate function
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "invoiceDeatils"
        {
            let outputDict : Dictionary<String,Any> = jsonObject["output_string"] as! Dictionary<String,Any>
            let historyArr : Array<Dictionary<String,Any>>  = outputDict["history"] as! Array<Dictionary<String,Any>>
            
            invoice?.paymentInfo = ParsingHelper.fillPaymentWithDictFromInvoiceDetail(dict: jsonObject, gateway: invoice.gateway ?? "" )
            
            invoice?.paymentInfo?.chargeAmount = invoice.dueAmount
            
            invoice?.storeCardInFile = outputDict.getBoolean("save_card_details") ?? false
            
            if let facility = outputDict["facility"] as? Dictionary<String,Any>
            {
                facilityId = facility["facility_id"] as? String
            }
            if let sharedBy = outputDict["shared_by"]  as? Dictionary<String,Any>
            {
                memberId = sharedBy["member_id"] as? String
                
                if invoice.memberId.isNilOrBlank() {
                    invoice.memberId = memberId
                }
            }
            
            invoicePdfUrl = charmConnectionHandler?.getInvoicePdfUrl(patientId: Patient.selectedPatientInstance!.patientId!, phrBillId: invoice!.phrBillId!, phrBillDataId: historyArr.last!["phr_bill_data_id"] as! String) ?? ""
            
            debugPrintLog(historyArr.last!["phr_bill_data_id"] as! String)
            
//            if invoice?.paymentInfo?.transactionInfo?.gateway == "RAZORPAY"
//            {
//                isRazorPay = true
//            }else
//            {
//                isRazorPay = false
//            }
            hideActivityIndicator()
            createViews()

        }
        else if identificationKey == "cretaeTranstion"
        {
            invoice!.paymentInfo = ParsingHelper.updatePaymentDetailWithDictionary(paymentInfo: invoice.paymentInfo ?? PaymentInfo(), dict: jsonObject)
            openRazorPay(paymentInfo: invoice.paymentInfo ?? PaymentInfo(), facilityName: invoice.facility?.facilityName ?? "")
        }
        else if identificationKey == "updatPayment"
        {
            let outputDict : Dictionary<String,Any> = jsonObject["output_string"] as! Dictionary<String,Any>
            let receiptDetailsDict = outputDict["receipt_details"] as! [Dictionary<String,Any>]
            receiptId = (receiptDetailsDict[0]["phr_receipt_id"]) as! String
            
            showReceiptPDF()
        }
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey.hasPrefix("downloadPdf")
        {
            hideActivityIndicator()
            let pdfImageVC = PDFImageViewController(fileName: "\(invoice.billNumber ?? "").pdf", data: data)
            pdfImageVC.popDelegate = self
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
        else if identificationKey == "invoicePDF"{
            
            hideActivityIndicator()
            let pdfImageVC = PDFImageViewController(fileName: "\(invoice.billNumber ?? "").pdf", data: data)
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
    }
     
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
        hideActivityIndicator()
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "getCardList"{
            hideActivityIndicator()
            if let cardMetaObj = response as? [CardMetaObj] {
                
                let paymentVC = PaymentViewController()
                paymentVC.delegate = self
                paymentVC.cardList  = cardMetaObj.firstOrNil()?.cardList.filter({tempCard in
                    !tempCard.hasCardExpired
                }) ?? []
//                cardList.filter({tempCard in
//                    //tempCard.merchantAccountId == invoice?.acc
//                })

                
                
                
                let paymentInfo = invoice.paymentInfo
                
                if !invoice.isStatement {
                    paymentVC.amountPayableStr = invoice.amount ?? ""
                    paymentVC.currencySymbol = invoice.practiceCurrencySymbol ?? ""
                    paymentInfo?.transactionInfo?.facilityId = invoice.facilityId
                    paymentInfo?.transactionInfo?.practiceId = invoice.practiceId
                    paymentInfo?.transactionInfo?.service = paymentServiceBilling
                    paymentInfo?.transactionInfo?.paymentAmount = paymentVC.amountPayableStr
                    paymentInfo?.transactionInfo?.memberId = invoice!.memberId
                    paymentInfo?.transactionInfo?.billId = invoice.phrBillId
                    paymentInfo?.transactionInfo?.ehrBillId = invoice.ehrBillId
                    paymentInfo?.transactionInfo?.billNum = invoice.billNumber ?? ""
                    paymentInfo?.chargeAmount = paymentVC.amountPayableStr
                    
                    if invoice.storeCardInFile {
                        paymentInfo?.chargeProcessingType = appointmentCardProcessingTypeStoreCharge
                        paymentInfo?.transactionType = appointmentTransactionTypeAuthorization
                    }
                    else{
                        paymentInfo?.chargeProcessingType = appointmentCardProcessingTypeChargeOnly
                        paymentInfo?.transactionType = appointmentTransactionTypeSale
                    }
                    
     
                }
                else{
                    paymentVC.amountPayableStr = phrBillStatements?.paymentRequest ?? ""
                    paymentVC.currencySymbol = invoice.practiceCurrencySymbol ?? ""
                    //paymentVC.currencySymbol = phrBillStatements
                }
                
                paymentVC.paymentInfo = paymentInfo
                self.navigationController?.pushViewController(paymentVC, animated: true)
            }
        }
        else if identificationKey == "getStatementDetails" {
            hideActivityIndicator()
            if let statement = response as? PHRBillStatements {
                phrBillStatements = statement
                statement.practiceId = invoice?.practiceId
                invoice?.paymentInfo = ParsingHelper.formPaymentInfo(from: statement)
                invoice?.paymentInfo?.transactionInfo?.gateway = invoice?.gateway
                createViews()
                invoicePdfUrl = charmConnectionHandler?.getStatementPdfUrl(patientId: Patient.selectedPatientInstance!.patientId!, statementId: invoice.statementId!) ?? ""
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
        hideActivityIndicator()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator()
    }
    
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }


    @objc func paynowClicked(_ sender: Any) {
        
        debugPrintLog("invoice Detail pay clicked ")
        //&& (isRazorPay != nil && isRazorPay == true)
        if isAmountValid(amount: invoice.amount)
        {
            if invoice?.paymentInfo != nil
            {
                //TODO: check for crt value for gateWay
                if invoice?.paymentInfo?.transactionInfo?.gateway == "RAZORPAY"
                {
                    var json = JsonBuilder.createJsonFromCreateTransaction(paymentInfo: invoice.paymentInfo ?? PaymentInfo(), service: paymentServiceBilling, practiceId: invoice.practiceId ?? "", facilityId: facilityId, memberid: memberId)
                    json.updateValue("\(invoice!.phrBillId ?? "")", forKey: "bill_id")
                    showActivityIndicator()
                    charmConnectionHandler!.createTransaction(patientId: Patient.selectedPatientInstance!.patientId, json: json, identificationKey: "cretaeTranstion")
                }
                else{
                   fetchStoredCards()
                   // performSegue(withIdentifier: "PaymentVC", sender: self)
                }
            }
        }else
        {
            viewInvoiceBtnClicked()
        }
        
    }
    
    func fetchStoredCards(){
        showActivityIndicator()
        charmConnectionHandler?.getCardList(identificationKey: "getCardList",selectedPractice: invoice?.practiceId ?? "", merchantId: invoice?.paymentInfo?.transactionInfo?.merchantAccountId ?? "")
    }
    
    @objc func viewInvoiceBtnClicked()
    {
        debugPrintLog("invoice Detail clicked")
       // performSegue(withIdentifier: "pdfVC", sender: self)
        showInvoicePDF()
    }
    
    //MARK: - razor pay methods & delgate methods
    func openRazorPay(paymentInfo : PaymentInfo , facilityName : String)
    {
        self.razorpay = RazorpayCheckout.initWithKey("\(paymentInfo.transactionInfo?.publicToken ?? "")", andDelegate: self)
        
        let options: [String:Any] = [
            "amount": "\((paymentInfo.chargeAmount?.toFloatOrNil() ?? 0.0 ) * 100)", //This is in currency subunits. 100 = 100 paise= INR 1.
            "currency": "\("INR")",
            "description": "Billing payment ",
            "order_id": "\(paymentInfo.transactionInfo?.razorPayOrderId ?? "")",
            "image": "", //TODO: can give image
            "name": facilityName,
            "prefill": [
                "contact": "\(paymentInfo.transactionInfo?.mobile ?? "")",
                "email": "\(paymentInfo.transactionInfo?.emailId ?? "")"
            ],
            "theme": [
                "color": "\(THEME_COLOR)"
            ]
        ]
        
        razorpay.open(options)
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alertVC = UIAlertController(title: nil, message:"\(getString(key: "com.charmphr.addAppointments.payment.alert.error"))", preferredStyle: .alert)
        let okAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.addAppointments.payment.paynow"), style: .default, handler: { (UIAlertAction) in
            self.openRazorPay(paymentInfo: self.invoice.paymentInfo ?? PaymentInfo(), facilityName: self.invoice.facilityName ?? "")
        })
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .default, handler: { (UIAlertAction) in

        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        alertVC.show()
    }

    func onPaymentSuccess(_ payment_id: String) {
        showActivityIndicator()
        charmConnectionHandler!.updateTransaction(patientId: invoice!.paymentInfo?.transactionInfo?.patientId ?? "" , practiceId : invoice!.practiceId ?? "", gateway:invoice.paymentInfo?.transactionInfo?.gateway ?? "", transactionId: invoice!.paymentInfo?.transactionInfo?.transactionId ?? "", identificationKey: "updatPayment")
    }
    
    func onReceiptIdCreated(receiptId: String) {
        self.receiptId = receiptId
        showReceiptPDF()
    }
    
    func popPDFImageVC() {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers as? [UIViewController]{
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3 ], animated: true)
        }
        delegate?.addViewControllerDataAdded(message: nil)
    }
}

//MARK: - StatementTableViewCell

class StatementTableViewCell: UITableViewCell{
    
    let statementItemView = StatementItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        contentView.addSubview(statementItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        statementItemView.setLeft(offSet: 0)
        statementItemView.setRight(offSet: 0)
        statementItemView.setTop(offSet: 4)
        statementItemView.setBottom(offSet: -4)
        statementItemView.setHeight(constant: 36)
    }
    
    func setTableViewCellData(data: PHRBills, invoice: PHRBills){
        statementItemView.setStatementView(data: data, invoice: invoice)
    }
}

//MARK:  - StatementItemView

class StatementItemView: UIView{
    
    let horizontalStackView = UIStackView()
    let patientNameView = UIView()
    let patientNameLabel = UILabel()
    let patientIdLabel = UILabel()
    let invoiceNoLabel = UILabel()
    let paymentRequestedLabel = UILabel()
    let dueAtPresentLabel = UILabel()
    let invoiceAmountLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        setSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubviews(){
        self.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(patientNameView)
        patientNameView.addSubview(patientNameLabel)
        patientNameView.addSubview(patientIdLabel)
        horizontalStackView.addArrangedSubview(invoiceNoLabel)
        horizontalStackView.addArrangedSubview(paymentRequestedLabel)
        horizontalStackView.addArrangedSubview(dueAtPresentLabel)
        horizontalStackView.addArrangedSubview(invoiceAmountLabel)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        horizontalStackView.setLeft(offSet: 0)
        horizontalStackView.setRight(offSet: 0)
        horizontalStackView.setTop(offSet: 0)
        horizontalStackView.setBottom(offSet: 0)
        
        patientNameView.setTop(offSet: 0)
        patientNameView.setBottom(offSet: 0)
        patientNameView.setWidth(constant: PATIENT_NAME_WIDTH)
        
        patientNameLabel.setLeft(offSet: 0)
        patientNameLabel.setRight(offSet: 0)
        patientNameLabel.setTop(offSet: 0)
        
        patientIdLabel.setLeft(offSet: 0)
        patientIdLabel.setRight(offSet: 0)
        patientIdLabel.setTopRelatedToView(offSet: 2, relatedView: patientNameLabel, relatedAttribute: .bottom)
        patientIdLabel.setBottom(offSet: 0)
        
        invoiceNoLabel.setTop(offSet: 0)
        invoiceNoLabel.setBottom(offSet: 0)
        invoiceNoLabel.setWidth(constant: INVOICE_NO_WIDTH)
        
        paymentRequestedLabel.setTop(offSet: 0)
        paymentRequestedLabel.setBottom(offSet: 0)
        paymentRequestedLabel.setWidth(constant: PAYMENT_REQUESTED_WIDTH)
        
        dueAtPresentLabel.setTop(offSet: 0)
        dueAtPresentLabel.setBottom(offSet: 0)
        dueAtPresentLabel.setWidth(constant: DUE_AT_PRESENT_WIDTH)
        
        invoiceAmountLabel.setTop(offSet: 0)
        invoiceAmountLabel.setBottom(offSet: 0)
        invoiceAmountLabel.setWidth(constant: INVOICE_AMOUNT_WIDTH)
    }
    
    private func addProperties(){
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .fill
        horizontalStackView.spacing = 30
        
        setLabelProperties(uiLabel: patientNameLabel)
        setLabelProperties(uiLabel: patientIdLabel)
        setLabelProperties(uiLabel: invoiceNoLabel)
        setLabelProperties(uiLabel: paymentRequestedLabel)
        setLabelProperties(uiLabel: dueAtPresentLabel)
        setLabelProperties(uiLabel: invoiceAmountLabel)
    }
    
    private func setLabelProperties(uiLabel: UILabel){
        uiLabel.font = UIFont.systemFont(ofSize: 13, Weight: .regular)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        uiLabel.textAlignment = .left
        uiLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setStatementView(data: PHRBills, invoice: PHRBills){
        patientNameLabel.text = data.patient?.fullName ?? ""
        patientIdLabel.text = "[\(data.patient?.patRecordId ?? "")]"
        invoiceNoLabel.text = data.billNumber
        invoiceNoLabel.removeConstraint(attribute: .height)
        invoiceNoLabel.wrapHeight(maxHeight: 50)
        
        if invoice.isPaymentRequestedShown{
            paymentRequestedLabel.text = "\(invoice.practiceCurrencySymbol ?? "") \(data.amount ?? "")"
            paymentRequestedLabel.isHidden = false
            paymentRequestedLabel.removeConstraint(attribute: .height)
            paymentRequestedLabel.wrapHeight(maxHeight: 50)
        }
        else{
            paymentRequestedLabel.isHidden = true
        }
        
        var dueAmt = data.dueAmount ?? ""
        if invoice.billType == billTypeCreditNote {
            dueAmt = "0.00"
        }
        dueAtPresentLabel.text = "\(invoice.practiceCurrencySymbol ?? "") \(dueAmt)"
        dueAtPresentLabel.removeConstraint(attribute: .height)
        dueAtPresentLabel.wrapHeight(maxHeight: 50)
        
        invoiceAmountLabel.text = "\(invoice.practiceCurrencySymbol ?? "") \(data.billAmount ?? "")"
        invoiceAmountLabel.removeConstraint(attribute: .height)
        invoiceAmountLabel.wrapHeight(maxHeight: 50)
    }
}
