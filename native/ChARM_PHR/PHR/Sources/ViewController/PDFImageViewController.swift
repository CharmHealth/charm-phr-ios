//
//  PDFImageViewController.swift
//  PHR
//
//  Created by prathi-13964 on 24/03/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import PDFKit
import WebKit

@objc protocol PDFImageVCDelegate: AnyObject {
    @objc optional func cancelPDFImageVC()
    @objc optional func shareFunction(vc: UIViewController, fileId: String?)
    @objc optional func downloadFile()
}

protocol PDFImageVCPopDelegate: AnyObject {
    func popPDFImageVC()
}

class PDFImageViewController: AddDataUIViewController, UIScrollViewDelegate, WKNavigationDelegate{
    
    private var pdfView: PDFView? = nil
    private var imageView: UIImageView? = nil
    private var webView: WKWebView? = nil
    private let activityIndicator = UIActivityIndicatorView()
    
    private var fileName: String? = nil
    private var data: Data? = nil
    private var url: URL? = nil
    private weak var delegate: PDFImageVCDelegate? = nil
    weak var popDelegate: PDFImageVCPopDelegate? = nil
    private var isAllowDownloadFile: Bool = false
    private var fileId: String? = nil
    
    private var tempFileURL: URL? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(fileName: String?, data: Data?, url: URL? = nil, delegate: PDFImageVCDelegate? = nil, isAllowDownloadFile: Bool = false, fileId: String? = nil){
        super.init(nibName: nil, bundle: nil)
        
        self.fileName = fileName
        self.data = data
        self.url = url
        self.delegate = delegate
        self.isAllowDownloadFile = isAllowDownloadFile
        self.fileId = fileId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.navigationItem.title = fileName
        if let fileId {
            
            let forwardAction = UIAction(title: getString(key: "com.charmphr.action.forward"), image: UIImage(systemName: "arrowshape.turn.up.forward")) { [weak self] _ in
                guard let self else { return }
                delegate?.shareFunction?(vc: self, fileId: fileId)
            }
            
            let shareAction = UIAction(title: getString(key: "com.charmphr.action.share"), image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
                self?.onClickShare()
            }
            
            let menu = UIMenu(title: "", options: .displayInline, children: [forwardAction, shareAction])
            
            let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
            navigationItem.rightBarButtonItem = moreButton
        }
        else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(onClickShare))
        }
        
        self.view.addSubview(activityIndicator)
        activityIndicator.color = .gray
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        createView()
    }
    
    func createView(newData: Data? = nil){
        hideActivityIndicator()
        if let newData{
            self.data = newData
        }
        if let data{
            if let image = UIImage(data: data){
                let targetSize = CGSize(width: applicationFrame.width, height: applicationFrame.height)
                let scaledImage = image.scalePreservingAspectRatio(targetSize: targetSize)
                
                imageView = UIImageView(image: scaledImage)
            }
            else if let pdfDocument = PDFDocument(data: data){
                pdfView = PDFView()
                pdfView?.document = pdfDocument
            }
            else{
                do{
                    let fileManager = FileManager.default
                    let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let fileURL = documentDirectory.appendingPathComponent(fileName ?? "")
                    if !fileManager.fileExists(atPath: fileURL.path){
                        try data.write(to: fileURL)
                    }
                    
                    webView = WKWebView()
                    let urlRequest = URLRequest(url: fileURL)
                    webView?.load(urlRequest)
                }
                catch{
                    CharmUtil.createOkayAlertWith(error: error, errorDescription: getString(key: "com.charmphr.alert.download.error"))
                    debugPrintLog(error)
                }
            }
        }
        else if let url{
            webView = WKWebView()
            let urlRequest = URLRequest(url: url)
            webView?.load(urlRequest)
        }
        else{
            let fileManager = FileManager.default
            do{
                let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentDirectory.appendingPathComponent(fileName ?? "")
                if fileManager.fileExists(atPath: fileURL.path){
                    webView = WKWebView()
                    let urlRequest = URLRequest(url: fileURL)
                    webView?.load(urlRequest)
                }
                else{
                    if isAllowDownloadFile{
                        showActivityIndicator()
                        delegate?.downloadFile?()
                    }
                    else{
                        CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.alert.unsupported.error"), msg: nil) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            catch{
                if isAllowDownloadFile{
                    showActivityIndicator()
                    delegate?.downloadFile?()
                }
                else{
                    CharmUtil.createOkayAlertWith(error: error, errorDescription: getString(key: "com.charmphr.alert.download.error"))
                    debugPrintLog(error)
                }
            }
        }
        
        if let imageView{
            let scrollView = UIScrollView()
            self.view.addSubview(scrollView)
            scrollView.addSubview(imageView)
            
            self.view.backgroundColor = .black
            
            let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
            let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 4.0
            
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.layer.masksToBounds = true
            
            scrollView.setSafeAreaLeft(offset: 0)
            scrollView.setSafeAreaRight(offset: 0)
            scrollView.setSafeAreaTop(offset: 0)
            scrollView.setSafeAreaBottom(offset: 0)
            
            imageView.setLeft(offSet: 0)
            imageView.setRight(offSet: 0)
            imageView.setTop(offSet: 0)
            imageView.setHeight(constant: applicationFrame.height - safeAreaTop - safeAreaBottom)
            imageView.setWidth(constant: applicationFrame.width)
        }
        else if let pdfView{
            self.view.addSubview(pdfView)
            
            pdfView.autoScales = false
            pdfView.displayDirection = .vertical
            pdfView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
            
            pdfView.setSafeAreaLeft(offset: 0)
            pdfView.setSafeAreaRight(offset: 0)
            pdfView.setSafeAreaTop(offset: 0)
            pdfView.setSafeAreaBottom(offset: 0)
            
            self.view.layoutIfNeeded()
            
            if let page = pdfView.document?.page(at: 0) {
                let pageWidth = page.bounds(for: .mediaBox).size.width
                let viewWidth = pdfView.bounds.size.width - 10
                
                pdfView.scaleFactor = viewWidth / pageWidth
            }
        }
        else if let webView{
            
            webView.backgroundColor = .clear
            webView.navigationDelegate = self
            webView.scrollView.isScrollEnabled = true
            webView.scrollView.bounces = true
            self.view.addSubview(webView)
            
            webView.setLeft(offSet: 0)
            webView.setRight(offSet: 0)
            webView.setSafeAreaTop(offset: 0)
            webView.setSafeAreaBottom(offset: 0)
        }
    }
    
    override func onBackClick() {
        
        if let popDelegate{
            popDelegate.popPDFImageVC()
        }
        else{
            self.navigationController?.popViewController(animated: true)
            delegate?.cancelPDFImageVC?()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc private func onClickShare(){
        if let pdfData = pdfView?.document?.dataRepresentation() {
            do {
                if tempFileURL == nil{
                    let tempDirectory = FileManager.default.temporaryDirectory
                    tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
                }
                
                if let tempFileURL{
                    try pdfData.write(to: tempFileURL)
                    
                    let activityController = UIActivityViewController(activityItems: [tempFileURL], applicationActivities: nil)
                    
                    activityController.excludedActivityTypes = [
                        .markupAsPDF,
                    ]
                    present(activityController, animated: true, completion: nil)
                }
            } catch {
                debugPrintLog("Error creating temporary file: \(error.localizedDescription)")
            }
        }
        else if let image = imageView?.image{
            
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [
                .assignToContact,
                .addToReadingList,
            ]
            present(activityViewController, animated: true, completion: nil)
        }
        else if let url = webView?.url{
            
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    func showActivityIndicator(){
        self.view.bringSubviewToFront(activityIndicator)
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator(){
        self.view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
