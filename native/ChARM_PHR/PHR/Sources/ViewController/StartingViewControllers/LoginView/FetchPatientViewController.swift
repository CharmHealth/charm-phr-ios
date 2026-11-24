//
//  FetchPatientViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 04/06/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import SSOKit

class FetchPatientViewController: UIViewController , CharmConnectionV2HandlerDelegate , NoDataViewDelegate
{

    let activityIndicatorView = UIActivityIndicatorView()
    
    let noDataBackGroundView = NoDataView()
    
    var charmConnectionHandler : CharmConnectionHandler? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        noDataBackGroundView.delegate = self
        self.view.addSubview(noDataBackGroundView)
        
        noDataBackGroundView.setCenterX()
        noDataBackGroundView.setCenterY()
        noDataBackGroundView.setLeft(offSet: 20)
        noDataBackGroundView.setRight(offSet: -20)
        
        noDataBackGroundView.hideSubView(bool: true)
        
        activityIndicatorView.style = UIActivityIndicatorView.Style.medium
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.setCenterX()
        activityIndicatorView.setCenterY()
        
        if StandardUserDefaults.value(forKey: "scopeEnhancedForSupport") == nil || StandardUserDefaults.bool(forKey: "scopeEnhancedForSupport") == false
        {

            CharmUtil.createOkayAlertWith(title: "", msg: "We have added some new features with this update. Please authenticate with your password to continue.", ShowAnimated: true, okClicked: {
                ZSSOKit.enhanceScopes({ (success , error) in

                    DispatchQueue.main.async {
                        if let error = error {
                            print("\(error) error occured")
                            StandardUserDefaults.set(true, forKey: "scopeEnhancedForSupport")
                            StandardUserDefaults.synchronize()
                            AuthManager.logoutUserDuringInvalidOAuth()
                        }
                        else{
                            self.proceedToPatientFetch()
                        }
                    }
                })
            })
        }
        else{
            proceedToPatientFetch()
        }
    }
    
    func proceedToPatientFetch(){
        if StandardUserDefaults.value(forKey: "scopeEnhancedForSupport") == nil || StandardUserDefaults.bool(forKey: "scopeEnhancedForSupport") == false
        {
            StandardUserDefaults.set(true, forKey: "scopeEnhancedForSupport")
            StandardUserDefaults.synchronize()
        }

        
        if Patient.patientList == nil || Patient.patientList?.count == 0
        {
            self.charmConnectionHandler = CharmConnectionHandler(v2Delegate: self, session: nil)
            charmConnectionHandler?.fetchPatientList(identificationKey: "fetchPatientList")
        }else
        {
            if Patient.patientList?.count == 1
            {
                Patient.selectedPatientInstance = Patient.patientList?.getElement(at: 0)
                performSegue(withIdentifier: "goToHomeVC", sender: self)
            }else
            {
                performSegue(withIdentifier: "SelectPatientVC", sender: self)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchPatientList"{
            hideActivityIndicator()
            if let patientList = response as? [Patient] {
                Patient.patientList = patientList
                if patientList.count == 1 {
                    Patient.selectedPatientInstance = patientList.firstOrNil()
                    performSegue(withIdentifier: "goToHomeVC", sender: self)
                }
                else {
                    performSegue(withIdentifier: "SelectPatientVC", sender: self)
                }
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "fetchPatientList"
        {
            if let nsError = error as? NSError {
                
                if nsError.code == patientSecondaryAccountErrorCode || nsError.code == patientCustomAppInvalidUserErrorCode  || nsError.code == patientEHRLoginError{
                    
                    var errorMessage = nsError.domain
                    if nsError.code == patientEHRLoginError {
                        errorMessage = getString(key: "com.charmphr.ehr.login.error")
                    }
                    
                    let alertConroller = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                    
                    var actionTitle = getString(key: "com.charmphr.action.Ok")
                    var alertAction = UIAlertAction.Style.default
                    
                    if nsError.code == patientSecondaryAccountErrorCode {
                        actionTitle = getString(key: "com.charmphr.action.logout")
                        alertAction = UIAlertAction.Style.destructive
                    }

                    let action = UIAlertAction(title:actionTitle , style: alertAction) { (action) in
                        self.logoutUser()
                    }
                    alertConroller.addAction(action)
                    alertConroller.show()
                    return
                }
            }
            
            if error.localizedDescription == getString(key: "com.charmphr.dataNotInCorrectFormat")
            {
                let alertConroller = UIAlertController(title: nil, message: getString(key: "com.charmphr.logout.ehr.login"), preferredStyle: .alert)
                let retryAction = UIAlertAction(title: getString(key: "com.charmphr.action.logout"), style: .destructive) { (action) in
                    self.logoutUser()
                }
                alertConroller.addAction(retryAction)
                alertConroller.show()
            }else
            {
                hideActivityIndicator()
                self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMessage(error: error), message: nil)
            }
            
        }else
        {
            hideActivityIndicator()
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(forCode: CharmUtil.getErrorCode(error: error)), message: nil)
        }
    }
    
    func hideActivityIndicator()
    {
        activityIndicatorView.stopAnimating()
    }
    
    func noDataViewRetryBtnClicked() {
        noDataBackGroundView.hideSubView(bool: true)
        activityIndicatorView.startAnimating()
        charmConnectionHandler?.fetchPatientList(identificationKey: "fetchPatientList")
    }
    
    func logoutUser()
    {
        AuthManager.logoutCommon()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectPatientVC = segue.destination as? SelectPatientViewController
        {
            if Patient.patientList != nil
            {
                selectPatientVC.arrayOfPatient = Patient.patientList!
            }
        }
    }
}
