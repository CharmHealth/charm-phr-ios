//
//  UsefulInfoDetailViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 03/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import WebKit

class UsefulInfoDetailViewController: UIViewController , CharmConnectionHandlerDelegate, WKNavigationDelegate{

    var usefulInfo : UsefulInfo?
        
    var charmConnectionHandler : CharmConnectionHandler?
    let activityIndicator = UIActivityIndicatorView()
    private weak var contentWebView: WKWebView?
    private var webViewHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        self.navigationItem.title = getString(key: "com.charmphr.common.details")
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        fetchUsefulInfoDetail()
        
    }
    
    func fetchUsefulInfoDetail()
    {
        showActivityIndicator()
        charmConnectionHandler?.fetchUsefulInfoDetial(infoId: usefulInfo?.infoId ?? "", practiceId: usefulInfo?.practiceId ?? "", identificationKey: "fetchUsefulInfoDetail")
    }

    func createSubViews()
    {
            
        let containerScrollView = UIScrollView()
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerScrollView)
        
        containerScrollView.layer.borderWidth = BORDER_WIDTH
        containerScrollView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        containerScrollView.addCornerRadius(.SMALL)
        
        let containerView = UIView()
        
        let categoryView = KeyAndValueLabelView()
        categoryView.keyLabel.text = getString(key: "com.charmphr.Announcement.subject.title")
        categoryView.valueLabel.text = usefulInfo?.category
        containerView.addSubview(categoryView)
        
        
        let horizontalLine = UIView()
        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR)
        containerView.addSubview(horizontalLine)
        
        horizontalLine.setLeft(offSet: 0)
        horizontalLine.setRight(offSet: 0)
        horizontalLine.setHeight(constant: 0.25)
        horizontalLine.setTopRelatedToView(offSet: 0, relatedView: categoryView, relatedAttribute: .bottom)
        
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .leading
        contentView.spacing = 0

        let keyLabel = UILabel()

        keyLabel.text = getString(key: "com.charmphr.Announcement.content.title")
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.backgroundColor = .clear
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUM_LIGHT)
        contentView.addArrangedSubview(keyLabel)

        keyLabel.setLeft(offSet: 0)
        keyLabel.setRight(offSet: 0)

        if let content = usefulInfo?.detailInfo{
            if content.isValidHtmlString(){

                let htmlString: String = """
                <!doctype html>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <html>
                    <body>
                        \(content)
                    </body>
                </html>
            """

                let webView = WKWebView()

                webView.scrollView.isScrollEnabled = true
                webView.navigationDelegate = self
                webView.loadHTMLString(htmlString, baseURL: nil)

                contentView.addArrangedSubview(webView)

                webView.setLeft(offSet: 0)
                webView.setRight(offSet: 0)
                contentWebView = webView
            }
            else{
                let label = UILabel()

                label.font = .systemFont(ofSize: FONT_SIZE_VALUE_LABEL, Weight: .regular)
                label.numberOfLines = 0
                label.backgroundColor = .clear
                label.text = usefulInfo?.detailInfo

                contentView.addArrangedSubview(label)
                label.setLeft(offSet: 0)
                label.setRight(offSet: 0)
            }
        }

        containerView.addSubview(contentView)
            
        categoryView.setTop(offSet: 0)
        categoryView.setLeft(offSet: 8)
        categoryView.setRight(offSet: -8)
        categoryView.layoutChange()
            
        contentView.setLeft(offSet: 8)
        contentView.setRight(offSet: -8)
        contentView.setTopRelatedToView(offSet: 8, relatedView: horizontalLine, relatedAttribute: .bottom)
        contentView.setBottom(offSet: 0)
        
        containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        containerScrollView.addSubview(containerView)
        
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        // Edge pins inside a scroll view only set content bounds; tie the width to the visible area so
        // the card follows fold/unfold and rotation.
        containerView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor).isActive = true

        // Safe-area edges keep the card clear of the Dynamic Island and the iOS 27.1 landscape side bar.
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        containerScrollView.setSafeAreaLeft(offset: X_SPACE)
        containerScrollView.setSafeAreaRight(offset: -X_SPACE)
        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.isLoading == false {
            measureWebViewHeight(webView)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Text re-wraps at the new width, so the HTML height changes after rotation / fold / unfold.
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self, let webView = self.contentWebView else { return }
            self.measureWebViewHeight(webView)
        }
    }

    /// Measures the rendered body height (not scrollHeight, which never shrinks below the current
    /// web view height) and updates a single stored height constraint.
    private func measureWebViewHeight(_ webView: WKWebView) {
        let script = "(function(){var b=document.body,s=getComputedStyle(b);return Math.ceil(b.getBoundingClientRect().height+parseFloat(s.marginTop)+parseFloat(s.marginBottom));})()"
        webView.evaluateJavaScript(script) { [weak self] result, _ in
            guard let self, let height = (result as? NSNumber).map({ CGFloat(truncating: $0) }) else { return }
            if let constraint = self.webViewHeightConstraint {
                constraint.constant = height + 20
            } else {
                let constraint = webView.heightAnchor.constraint(equalToConstant: height + 20)
                constraint.isActive = true
                self.webViewHeightConstraint = constraint
            }
        }
    }
    
    func showActivityIndicator()
    {
        self.view.isUserInteractionEnabled = false
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchUsefulInfoDetail"
        {
            if let outputString = jsonObject["output_string"] as? Dictionary<String,Any>
            {
                usefulInfo?.detailInfo = outputString["DTAILED_INFO"] as? String
                createSubViews()
                hideActivityIndicator()
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createRetryAndCancelAlertWith(error: error) {
            self.fetchUsefulInfoDetail()
        } cancelClicked: {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
