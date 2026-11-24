//
//  FacilityDetailViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 05/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class FacilityDetailViewController: UIViewController {
    
    var facility : Facility!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.navigationItem.title = getString(key: "com.charmphr.common.details")
        createSubViews()

    }
    
    func createSubViews()
    {
        
        let containerView = UIView()
        
        containerView.layer.borderWidth = BORDER_WIDTH
        containerView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        
        let providerNameView = KeyAndValueLabelView()
        providerNameView.keyLabel.text = getString(key: "com.charmphr.facility.name.title")
        providerNameView.valueLabel.text = "\(facility.facilityName!)"
        containerView.addSubview(providerNameView)
    
        
        let addressView = KeyAndValueLabelView()
        if !isNilOrEmpty(string: facility.line1)
        {
            addressView.addTopBorder()
            addressView.keyLabel.text = getString(key: "com.charmphr.facility.address.title")
            addressView.valueLabel.text = facility.line1
            if facility.line2 != nil
            {
                addressView.valueLabel.text?.append(",\(facility.line2!)")
            }
        }
        containerView.addSubview(addressView)
        
//        let addressView2 = KeyAndValueLabelView()
//        if !isNilOrEmpty(string: facility.line2)
//        {
//            addressView2.keyLabel.text = NSLocalizedString("com.charmphr.facility.address.title", comment: "")
//            addressView2.valueLabel.text = facility.line2
//        }
//        containerView.addSubview(addressView2)
        
        let mailView = KeyAndValueLabelView()
        if !isNilOrEmpty(string: facility.directMailid) && facility.directMailid != "null"
        {
            mailView.addTopBorder()
            mailView.keyLabel.text = getString(key: "com.charmphr.facility.emailid.title")
            mailView.valueLabel.text = facility.directMailid ?? "-"
        }
        containerView.addSubview(mailView)
        
        
        let phoneNumberView = KeyAndValueLabelView()
        phoneNumberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phonenumberCliked)))
        if !isNilOrEmpty(string: facility.landline)
        {
            phoneNumberView.addTopBorder()
            phoneNumberView.keyLabel.text = getString(key: "com.charmphr.facility.phonenumber.title")
            phoneNumberView.valueLabel.text = facility.landline
        }
        containerView.addSubview(phoneNumberView)
        
        let webView = KeyAndValueLabelView()
        webView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(weburlClicked)))
        if !isNilOrEmpty(string: facility.weburl) && facility.weburl != "null"
        {
            webView.addTopBorder()
            webView.keyLabel.text = getString(key: "com.charmphr.facility.web.title")
            webView.valueLabel.text = facility.weburl ?? "-"
        }
        containerView.addSubview(webView)
        
        
        providerNameView.setTop(offSet: 0)
        providerNameView.setLeft(offSet: 0)
        providerNameView.setRight(offSet: 0)
        providerNameView.setBottomRelatedToView(offSet: 0, relatedView: addressView, relatedAttribute: .top)
        providerNameView.layoutChange()

        addressView.setLeft(offSet: 0)
        addressView.setRight(offSet: 0)
        addressView.setBottomRelatedToView(offSet: 0, relatedView: mailView, relatedAttribute: .top)
        addressView.layoutChange()
        
        mailView.setLeft(offSet: 0)
        mailView.setRight(offSet: 0)
        mailView.setBottomRelatedToView(offSet: 0, relatedView: phoneNumberView, relatedAttribute: .top)
        mailView.layoutChange()
        
        phoneNumberView.setLeft(offSet: 0)
        phoneNumberView.setRight(offSet: 0)
        phoneNumberView.setBottomRelatedToView(offSet: 0, relatedView: webView, relatedAttribute: .top)
        phoneNumberView.layoutChange()
        
        webView.setLeft(offSet: 0)
        webView.setRight(offSet: 0)
        webView.setBottom(offSet: 0)
        webView.layoutChange()

        containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        containerView.addCornerRadius(.SMALL)
        self.view.addSubview(containerView)
        
        if !isNilOrEmpty(string: facility.weburl)
        {
            let locationView = UIView()
                   
            
            locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationClicked)))
            
            
            let locationLabel = UILabel()
            locationLabel.text = getString(key: "com.charmphr.facility.location.title")
            locationLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
            locationLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
            locationView.addSubview(locationLabel)
                
            locationLabel.setLeft(offSet: Y_SPACE)
            locationLabel.setTop(offSet: 12)
            locationLabel.setBottom(offSet: -12)
            locationLabel.setRight(offSet: Y_SPACE)
                
            locationView.backgroundColor = containerView.backgroundColor
            locationView.addCornerRadius(.SMALL)
            self.view.addSubview(locationView)
                   
            containerView.setSafeAreaTop(offset:Y_SPACE)
            containerView.setLeft(offSet: X_SPACE)
            containerView.setRight(offSet: -X_SPACE)
            containerView.setBottomRelatedToView(offSet: -8, relatedView: locationView, relatedAttribute: .top)

            locationView.setLeft(offSet: X_SPACE)
            locationView.setRight(offSet: -X_SPACE)
                   
        }else
        {
            containerView.setSafeAreaTop(offset:Y_SPACE)
            containerView.setLeft(offSet: X_SPACE)
            containerView.setRight(offSet: -X_SPACE)
        }
    }

    
    @objc func weburlClicked()
    {
        if let url = URL(string: facility.weburl ?? "")
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func locationClicked()
    {
        if let url = URL(string: facility.direction ?? "")
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func phonenumberCliked()
    {
        if let url = URL(string: "tel://\(facility.phoneNumber ?? "")"){
            if UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
}
