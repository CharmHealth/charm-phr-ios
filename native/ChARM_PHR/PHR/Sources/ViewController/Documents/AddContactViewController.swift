//
//  AddContactViewController.swift
//  phr
//
//  Created by prathi-13964 on 03/11/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol AddContactVCDelegate: AnyObject{
    func addContactValue(createdPharmacyArray: [Pharmacy]?, delegateText: String)
}

class AddContactViewController: AddDataUIViewController, CharmConnectionHandlerDelegate{
    
    weak var delegate: AddContactVCDelegate?
    var charmConnectionHandler: CharmConnectionHandler?
    lazy var addContactView = AddContactView()
    var tagNo = 27832492408201
    var buttonToViewMap: [Int: Int] = [:]
    var alertList: [String] = []
    var pharmacyArray: [Pharmacy] = []
    var delegateText: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        addContactView = AddContactView()
        self.view = addContactView
        
        self.navigationItem.title = getString(key: "com.charmphr.sharedocuments.addcontact.title")
        self.navigationItem.largeTitleDisplayMode = .never
        
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onClickAddBtn))
        
        if delegateText.lowercased().isValidEmail(){
            addContactView.initialView.emailField.text = delegateText
        }
        else{
            addContactView.initialView.fullNameField.text = delegateText
        }
        
        addContactView.addmoreButton.addTarget(self, action: #selector(onClickAddMoreBtn), for: .touchUpInside)
        addContactView.initialView.removeBtn.tag = tagNo
        tagNo += 1
        addContactView.initialView.tag = tagNo
        tagNo += 1
        buttonToViewMap[addContactView.initialView.removeBtn.tag] = addContactView.initialView.tag
        addContactView.initialView.removeBtn.addTarget(self, action: #selector(onClickRemoveBtn(_:)), for: .touchUpInside)
    }
    
//MARK: - Delegate functions
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "addMultipleContacts"{
            hideActivityIndicator()
            addPharmacyId(resp: jsonObject)
            delegate?.addContactValue(createdPharmacyArray: pharmacyArray, delegateText: "")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "addMultipleContacts"{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
//MARK: - Target functions
    
    override func onBackClick() {
        alertList = []
        for subViews in addContactView.addContactStackView.subviews{
            if let contactView = subViews as? CommonAddContactView{
                if !contactView.fullNameField.text.isNilOrBlank(){
                    alertList.append("FullName")
                }
                if !contactView.emailField.text.isNilOrBlank(){
                    alertList.append("EmailId")
                }
            }
        }
        if alertList.isEmpty{
            delegateText = ""
            setDelegateText()
            self.navigationController?.popViewController(animated: true)
        }
        else{
            showDiscardChangesDialog()
        }
    }
    
    @objc func onClickRemoveBtn(_ btn: UIButton){
        let contactViewTag = buttonToViewMap[btn.tag] ?? -1
        if let contactView = self.view.viewWithTag(contactViewTag) as? CommonAddContactView{
            contactView.removeFromSuperview()
        }
        checkForRemoveButtonView()
    }
    @objc func onClickAddMoreBtn(){
        let contactView = CommonAddContactView.init()
        addContactView.addContactStackView.addArrangedSubview(contactView)
        contactView.setConstraints()
        contactView.tag = tagNo
        tagNo += 1
        contactView.removeBtn.tag = tagNo
        tagNo += 1
        buttonToViewMap[contactView.removeBtn.tag] = contactView.tag
        contactView.removeBtn.addTarget(self, action: #selector(onClickRemoveBtn(_:)), for: .touchUpInside)
        checkForRemoveButtonView()
    }
    
    @objc func onClickAddBtn(){
        
        let pharmacyList = validate()
        if alertList.isEmpty{
            pharmacyArray = pharmacyList
            showActivityIndicator()
            charmConnectionHandler?.addMultipleContacts(identificationKey: "addMultipleContacts", pharmacyList: pharmacyList)
        }
        else{
            CharmUtil.createOkayAlertWith(title: nil, msg: alertList.first ?? "")
        }
    }
//MARK: - Other functions
    
    func validate() -> [Pharmacy]{
        var pharmacyList: [Pharmacy] = []
        alertList = []
        for subViews in addContactView.addContactStackView.subviews{
            let pharmacyObj = Pharmacy()
            if let contactView = subViews as? CommonAddContactView{
                if contactView.fullNameField.text.isNilOrBlank(){
                    alertList.append(getString(key: "com.charmphr.sharedocuments.addcontact.fullName.alert.message"))
                }
                else{
                    pharmacyObj.pharmacyName = contactView.fullNameField.text
                }
                let emailText = contactView.emailField.text
                if emailText.isNilOrBlank(){
                    alertList.append(getString(key: "com.charmphr.sharedocuments.addcontact.email.alert.message"))
                }
                else{
                    if !emailText!.lowercased().isValidEmail(){
                        alertList.append(getString(key: "com.charmphr.sharedocuments.addcontact.alert.validEmail.message"))
                    }
                    else{
                        let contactDetails = ContactDetails()
                        contactDetails.emailId = emailText?.lowercased()
                        pharmacyObj.contactDetails = contactDetails
                    }
                }
            }
            pharmacyObj.patientId = Patient.selectedPatientInstance?.patientId
            pharmacyList.append(pharmacyObj)
        }
        return pharmacyList
    }
    
    func checkForRemoveButtonView(){
        
        let viewCount = addContactView.addContactStackView.subviews.count
        for subViews in addContactView.addContactStackView.subviews{
            if let contactView = subViews as? CommonAddContactView{
                if viewCount >= 2{
                    contactView.removeBtnView.isHidden = false
                }
                else if viewCount == 1{
                    contactView.removeBtnView.isHidden = true
                }
            }
        }
    }
    
    func addPharmacyId(resp: [String: Any]){
        
        if let outputString = resp["output_string"] as? [String:Any]{
            if let newContacts = outputString["new_contacts"] as? [String]{
                for i in 0..<pharmacyArray.count{
                    pharmacyArray[i].patientPharmaMapId = newContacts[i]
                }
            }
        }
    }
    
    func showActivityIndicator(){
        self.view.bringSubviewToFront(addContactView.activityIndicator)
        self.view.isUserInteractionEnabled = false
        addContactView.activityIndicator.startAnimating()
    }
    func hideActivityIndicator(){
        self.view.isUserInteractionEnabled = true
        addContactView.activityIndicator.stopAnimating()
    }
    
    func setDelegateText(){
        delegate?.addContactValue(createdPharmacyArray: nil, delegateText: delegateText)
    }
}

