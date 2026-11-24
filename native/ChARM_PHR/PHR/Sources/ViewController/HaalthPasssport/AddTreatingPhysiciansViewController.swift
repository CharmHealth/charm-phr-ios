////
////  AddTreatingPhysiciansViewController.swift
////  phr
////
////  Created by Sankar Saravanan on 29/08/20.
////  Copyright © 2020 Dhanuprasanya P. All rights reserved.
////
//
//import UIKit
//
//class AddTreatingPhysiciansViewController: UIViewController, CharmConnectionHandlerDelegate
//{
//
//    var delegate : AddViewControllerDelegate!
//    var editTreatingPhysician : Provider?
//
//    let TREATING_PHYSICIAN_NAME_VIEW_TAG = 1001
//    let TREATING_PHYSICIAN_PHONENUMBER_VIEW_TAG = 1002
//
//    var charmconnectionHandler : CharmConnectionHandler!
//
//    let activityIndicator = UIActivityIndicatorView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.setLargeTitle(enable: false)
//        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
//        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
//
//        createSubView()
//        activityIndicator.color = .gray
//        activityIndicator.hidesWhenStopped = true
//        self.view.addSubview(activityIndicator)
//
//        activityIndicator.setCenterX()
//        activityIndicator.setCenterY()
//
//        charmconnectionHandler = CharmConnectionHandler(delegate: self)
//
//        if editTreatingPhysician ==  nil
//        {
//            self.navigationItem.title = NSLocalizedString("com.charmphr.addTreatingPhysicians.title", comment: "")
//        }else
//        {
//            self.navigationItem.title = NSLocalizedString("com.charmphr.editTreatingPhysicians.title", comment: "")
//        }
//
//    }
//
//    func createSubView()
//    {
//
//        let containerScrollView = TPKeyboardAvoidingScrollView()
//
//        let containerView = UIView()
//        containerView.layer.cornerRadius = CORNER_RADIUS_5
//        containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
//
//        let treatingPhysicianNameView = AddModuleKeyAndValueView()
//        treatingPhysicianNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
//        treatingPhysicianNameView.tag = TREATING_PHYSICIAN_NAME_VIEW_TAG
//        treatingPhysicianNameView.keyLabel.text = NSLocalizedString("com.charmphr.addTreatingPhysicians.name.title", comment: "")
//        treatingPhysicianNameView.textField.delegate = self
//        treatingPhysicianNameView.textField.valueType = .none
//        treatingPhysicianNameView.textField.maxLength = 50
//        treatingPhysicianNameView.textField.placeholder = NSLocalizedString("com.charmphr.addTreatingPhysicians.name.placeHolder", comment: "")
//        treatingPhysicianNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
//        treatingPhysicianNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
//        if !isNilOrEmpty(string: editTreatingPhysician?.fullName)
//        {
//            treatingPhysicianNameView.textField.text = editTreatingPhysician!.fullName
//        }
//        containerView.addSubview(treatingPhysicianNameView)
//
//        let treatingPhysicianNumberView = AddModuleKeyAndValueView()
//        treatingPhysicianNumberView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
//        treatingPhysicianNumberView.tag = TREATING_PHYSICIAN_PHONENUMBER_VIEW_TAG
//        treatingPhysicianNumberView.keyLabel.text = NSLocalizedString("com.charmphr.addTreatingPhysicians.phonenumber.title", comment: "")
//        treatingPhysicianNumberView.textField.delegate = self
//        treatingPhysicianNumberView.textField.valueType = .phoneNumber
//        treatingPhysicianNumberView.textField.maxLength = 13
//        treatingPhysicianNumberView.textField.keyboardType = .numberPad
//        treatingPhysicianNumberView.textField.placeholder = NSLocalizedString("com.charmphr.addTreatingPhysicians.phonenumber.placeHolder", comment: "")
//        treatingPhysicianNumberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
//        if !isNilOrEmpty(string: editTreatingPhysician?.phoneNumber)
//        {
//            treatingPhysicianNumberView.textField.text = editTreatingPhysician!.phoneNumber
//        }
//        containerView.addSubview(treatingPhysicianNumberView)
//
//        treatingPhysicianNameView.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CORNER_RADIUS_5)
//        treatingPhysicianNameView.setSafeAreaTop(offset: 0)
//        treatingPhysicianNameView.setLeft(offSet: 0)
//        treatingPhysicianNameView.setRight(offSet: 0)
//        treatingPhysicianNameView.setBottomRelatedToView(offSet: 0, relatedView: treatingPhysicianNumberView, relatedAttribute: .top)
//
//        treatingPhysicianNumberView.setLeft(offSet: 0)
//        treatingPhysicianNumberView.setRight(offSet: 0)
//        treatingPhysicianNumberView.setBottom(offSet: 0)
//        treatingPhysicianNumberView.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CORNER_RADIUS_5)
//
//
//        containerScrollView.addSubview(containerView)
//        self.view.addSubview(containerScrollView)
//
//        containerView.setTop(offSet: 0)
//        containerView.setBottom(offSet: 0)
//        containerView.setLeft(offSet: 0)
//        containerView.setRight(offSet: 0)
//        self.view.addConstraint(NSLayoutConstraint.init(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: -(X_SPACE + X_SPACE)))
//
//        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[containerScrollView]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["containerScrollView":containerScrollView]))
//        containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
//
//    }
//
//    //MARK: - action calles
//    @objc func dismissKeyboard()
//    {
//        self.view.endEditing(true)
//    }
//
//    func showActivityIndicator()
//    {
//        self.view.bringSubviewToFront(activityIndicator)
//        activityIndicator.startAnimating()
//        self.view.isUserInteractionEnabled = false
//    }
//
//    func hideActivityIndicator()
//    {
//        activityIndicator.stopAnimating()
//        self.view.isUserInteractionEnabled = true
//    }
//
//    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
//    {
//        if let addAllergiesKeyAndLabelView = tapGestureRecognizer.view as? AddModuleKeyAndValueView
//        {
//            if !addAllergiesKeyAndLabelView.textField.isHidden
//            {
//                addAllergiesKeyAndLabelView.textField.becomeFirstResponder()
//            }
//        }
//    }
//
//    func showMandatoryAlert(fieldName : String)
//    {
//        let alertController = UIAlertController(title: nil, message: "\(NSLocalizedString("com.charmphr.common.mandatory.alert.msg", comment: ""))\(fieldName)", preferredStyle: .alert)
//        let okAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.Ok", comment: ""), style: .default) { (alert) in
//
//        }
//        alertController.addAction(okAction)
//        alertController.show()
//    }
//
//    @objc func doneBtnClicked()
//    {
//        dismissKeyboard()
//
//        let treatingPhysicianNameView = self.view.viewWithTag(TREATING_PHYSICIAN_NAME_VIEW_TAG) as! AddModuleKeyAndValueView
//        let treatingPhysicianPhoneNumberView = self.view.viewWithTag(TREATING_PHYSICIAN_PHONENUMBER_VIEW_TAG) as! AddModuleKeyAndValueView
//
//        if isNilOrEmpty(string: treatingPhysicianNameView.textField.text)
//        {
//            showMandatoryAlert(fieldName: treatingPhysicianNameView.keyLabel.text!)
//            treatingPhysicianNameView.textField.becomeFirstResponder()
//        }
//        else
//        {
//
//            if charmconnectionHandler == nil
//            {
//                charmconnectionHandler = CharmConnectionHandler(delegate: self)
//            }
//
//            let provider = Provider()
//
//            provider.fullName = treatingPhysicianNameView.textField.text
//
//            if !isNilOrEmpty(string: treatingPhysicianPhoneNumberView.textField.text)
//            {
//                provider.phoneNumber = treatingPhysicianPhoneNumberView.textField.text!
//            }
//
//            if editTreatingPhysician != nil
//            {
//                provider.facilityId = editTreatingPhysician!.facilityId
//            }
//
//            charmconnectionHandler.addTreatingPhysicians(json: JsonBuilder.createJsonFromProviderForTreatingPhysician(provider: provider), identificationKey: "addTreatingPhysician")
//
//            showActivityIndicator()
//        }
//    }
//
//    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String)
//    {
//        if identificationKey == "addTreatingPhysician"
//        {
//            delegate?.addViewControllerDataAdded()
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//
//    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
//        hideActivityIndicator()
//        CharmUtil.createOkayAlertWith(error: error)
//    }
//
//
//}
