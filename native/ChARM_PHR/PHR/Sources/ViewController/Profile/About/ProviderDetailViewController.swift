//
//  ProviderDetailViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 05/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ProviderDetailViewController: UIViewController {
    
    var provider : Provider!

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
        providerNameView.keyLabel.text = getString(key: "com.charmphr.provider.name.title")
        providerNameView.valueLabel.text = StringUtil.getNameWithPrefixAndFullName(fullName: provider.fullName ?? "", prefix: provider.prefix)
        
        containerView.addSubview(providerNameView)
        
        let degreeView = KeyAndValueLabelView()
        if !isNilOrEmpty(string: provider.degree) &&  provider.degree != "null"
        {
            degreeView.keyLabel.text = getString(key: "com.charmphr.provider.degree.title")
            degreeView.valueLabel.text = provider.degree ?? "-"
        }
        containerView.addSubview(degreeView)
        
        let specializationView = KeyAndValueLabelView()
        if !isNilOrEmpty(string: provider.specialization) && provider.specialization != "null"
        {
            specializationView.keyLabel.text = getString(key: "com.charmphr.provider.Specialization.title")
            specializationView.valueLabel.text = provider.specialization
        }
        containerView.addSubview(specializationView)
        
        let webView = KeyAndValueLabelView()
        if !isNilOrEmpty(string: provider.webUrl) && provider.webUrl != "null"
        {
            webView.keyLabel.text = getString(key: "com.charmphr.provider.Specialization.title")
            webView.valueLabel.text = provider.webUrl
        }
        containerView.addSubview(webView)

        
//        let mailView = KeyAndValueLabelView()
//        if !isNilOrEmpty(string: provider.directMailid) &&  provider.directMailid != "null"
//        {
//            mailView.keyLabel.text = NSLocalizedString("com.charmphr.provider.emailid.title", comment: "")
//            mailView.valueLabel.text = provider.directMailid
//        }
//        containerView.addSubview(mailView)
        
//        let phoneNumberView = KeyAndValueLabelView()
//        if !isNilOrEmpty(string: provider.phoneNumber) && provider.phoneNumber != "null"
//        {
//            phoneNumberView.keyLabel.text = NSLocalizedString("com.charmphr.provider.phonenumber.title", comment: "")
//            phoneNumberView.valueLabel.text = provider.phoneNumber
//            phoneNumberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phonenumberCliked)))
//        }
//        containerView.addSubview(phoneNumberView)
        
        providerNameView.setTop(offSet: 0)
        providerNameView.setLeft(offSet: 0)
        providerNameView.setRight(offSet: 0)
        providerNameView.setBottomRelatedToView(offSet: 0, relatedView: degreeView, relatedAttribute: .top)
        providerNameView.layoutChange()

        degreeView.setLeft(offSet: 0)
        degreeView.setRight(offSet: 0)
        degreeView.setBottomRelatedToView(offSet: 0, relatedView: specializationView, relatedAttribute: .top)
        degreeView.layoutChange()
        
//        mailView.setLeft(offSet: 0)
//        mailView.setRight(offSet: 0)
//        mailView.setBottomRelatedToView(offSet: 0, relatedView: specializationView, relatedAttribute: .top)
//        mailView.layoutChange()
        
        specializationView.setLeft(offSet: 0)
        specializationView.setRight(offSet: 0)
        specializationView.setBottomRelatedToView(offSet: 0, relatedView: webView, relatedAttribute: .top)
        specializationView.layoutChange()
        
        webView.setLeft(offSet: 0)
        webView.setRight(offSet: 0)
        webView.setBottom(offSet: 0)
        webView.layoutChange()

        containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        containerView.addCornerRadius(.SMALL)
        self.view.addSubview(containerView)
        
        containerView.setSafeAreaTop(offset:Y_SPACE)
        containerView.setLeft(offSet: X_SPACE)
        containerView.setRight(offSet: -X_SPACE)
    }
    
    
    @objc func phonenumberCliked()
    {
        if let number = provider.phoneNumber
        {
            if let url = URL(string: "tel://\(number)"){
                if UIApplication.shared.canOpenURL(url)
                {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

}
