//
//  AnnouncementsDetailViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 15/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import WebKit

class AnnouncementsDetailViewController: UIViewController , CharmConnectionHandlerDelegate, WKNavigationDelegate{

    var announcement : Announcement!
    
    var charmConnectionHandler : CharmConnectionHandler!
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        self.navigationItem.title = getString(key: "com.charmphr.common.details")
        self.navigationItem.largeTitleDisplayMode = .never
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        fetchAnnouncementDetail()
    }
    
    func fetchAnnouncementDetail()
    {
        showActivityIndicator()
        charmConnectionHandler.fetchAnnouncementDetial(announcement: announcement, identificationKey: "fetchAnnouncementDetail")
    }

    func createSubViews()
    {
        let containerScrollView = UIScrollView()
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerScrollView)
        
        containerScrollView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        containerScrollView.layer.borderWidth = BORDER_WIDTH
        containerScrollView.addCornerRadius(.SMALL)
        
        let containerView = UIView()
        
        let subjectView = KeyAndValueLabelView()
        subjectView.keyLabel.text = getString(key: "com.charmphr.Announcement.subject.title")
        subjectView.valueLabel.text = announcement.subject
        containerView.addSubview(subjectView)
        
        let horizontalLine1 = UIView()
        horizontalLine1.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR)
        containerView.addSubview(horizontalLine1)
        
        horizontalLine1.setLeft(offSet: 0)
        horizontalLine1.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        horizontalLine1.setHeight(constant: 0.25)
        horizontalLine1.setTopRelatedToView(offSet: 0, relatedView: subjectView, relatedAttribute: .bottom)
        
        let announcementOnView = KeyAndValueLabelView()
        announcementOnView.keyLabel.text = getString(key: "com.charmphr.AnnouncementOn.title")
        announcementOnView.valueLabel.text = CharmUtil.getDateStringWith(date: announcement.time, dateFormat: PHR_DATE_DISPLAY_FORMAT)
        containerView.addSubview(announcementOnView)
        
        let horizontalLine2 = UIView()
        horizontalLine2.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR)
        containerView.addSubview(horizontalLine2)
        
        horizontalLine2.setLeft(offSet: 0)
        horizontalLine2.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        horizontalLine2.setHeight(constant: 0.25)
        horizontalLine2.setTopRelatedToView(offSet: 0, relatedView: announcementOnView, relatedAttribute: .bottom)
    
        //TODO: want to check do we want to use a another api for content ..
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
        
        if let content = announcement.content{
            if content.isValidHtmlString(){
                
                let htmlString: String = """
                <!doctype html>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <html>
                    <body style="background-color: #FFFFFF;">
                        \(announcement.content ?? "")
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
            }
            else{
                let label = UILabel()
                
                label.font = .systemFont(ofSize: FONT_SIZE_VALUE_LABEL, Weight: .regular)
                label.numberOfLines = 0
                label.backgroundColor = .clear
                label.text = announcement.content
                
                contentView.addArrangedSubview(label)
                label.setLeft(offSet: 0)
                label.setRight(offSet: 0)
            }
        }
        containerView.addSubview(contentView)
        
        subjectView.setTop(offSet: 0)
        subjectView.setLeft(offSet: 8)
        subjectView.setWidth(constant: applicationFrame.width - (2 * X_SPACE) - (2 * PADDING_8))
        subjectView.layoutChange()

        announcementOnView.setLeft(offSet: 8)
        announcementOnView.setWidth(constant: applicationFrame.width - (2 * X_SPACE) - (2 * PADDING_8))
        announcementOnView.setTopRelatedToView(offSet: 0, relatedView: horizontalLine1, relatedAttribute: .bottom)
        announcementOnView.layoutChange()
        
        contentView.setLeft(offSet: 8)
        contentView.setWidth(constant: applicationFrame.width - (2 * X_SPACE) - (2 * PADDING_8))
        contentView.setTopRelatedToView(offSet: 8, relatedView: horizontalLine2, relatedAttribute: .bottom)
        contentView.setBottom(offSet: -PADDING)
        
        containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        containerScrollView.addSubview(containerView)
        
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        containerView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        containerScrollView.setRight(offSet: -X_SPACE)
        containerScrollView.setLeft(offSet: X_SPACE)
        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.isLoading == false {
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] (result, error) in
                if let height = result as? CGFloat {
                    webView.setHeight(constant: height + CARD_PADDING)
                }
            })
        }
    }
    
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator()
    {
        self.view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchAnnouncementDetail"
        {
            hideActivityIndicator()
            if let outputString = jsonObject["output_string"] as? Dictionary<String,Any>
            {
                announcement.content = outputString["ANNOUNCEMENT_CONTENT"] as? String
                createSubViews()
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createRetryAndCancelAlertWith(error: error) {
            self.fetchAnnouncementDetail()
        } cancelClicked: {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
