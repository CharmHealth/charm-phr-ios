//
//  HKPatientSelectViewController.swift
//  phr
//
//  Created by Raghul D on 17/10/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation
import HealthKit


class HKPatientSelectViewController: UIViewController  , UITableViewDataSource , UITableViewDelegate{
   
    
    @objc lazy private var patientSelectView: HKPatientSelectView = HKPatientSelectView(delegate: self)
    
    var appointment: Appointment? = nil
    var indexPath: IndexPath? = nil
    weak var delegate: HKPatientSelectVCDelegate? = nil
    weak var cancelDelegate: HKPatientSelectCancelDelegate? = nil

    var patientList:[Patient] = []
    
    private var hkDOB: Date? = nil
    private let backButton = UIButton(type: .custom)

    override func loadView() {
        self.view = patientSelectView
    }
    
    override func viewDidLoad() {
        
        patientList = Patient.patientList ?? []
        self.navigationItem.title = getString(key: "com.charmphr.wellness.healthkit.patient.title")

        
        //self.showActivityIndicator()
        HealthKitService.shared.requestProfileAuthorization(completion: {[weak self] success , failure in
            guard let self = self else {return}
            DispatchQueue.main.async {
                
              //  self.hideActivityIndicator()
                if(success){
                    let result = HealthKitService.shared.fetchDateOfBirth()
                    switch result {
                    case .success(let date):
                        self.hkDOB = date
                        self.checkAndUpdateDOB()
                    case .notAvailable:
                        self.checkAndUpdateDOB()
//                    case .authDenied:
//                        self.showAlertForDOBAuthFail()
                    }
                }
                else{
                    if let failure {
                        CharmUtil.createOkayAlertWith(error: failure , errorDescription: failure.localizedDescription)
                    }
                }
            }
            
        })
        
        //self.view.isUserInteractionEnabled = true
      //  self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
        
        //patientSelectView.isUserInteractionEnabled = true
        //patientSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doNothing)))
        setUpBackBtn()
    }
    
    private func setUpBackBtn(){
        let backIconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold, scale: .large)
        let backicon = UIImage(systemName: "chevron.backward", withConfiguration: backIconConfig)?.withRenderingMode(.alwaysTemplate)
        
        if #available (iOS 26.0, *){
            backButton.setImage(backicon, for: .normal)
            backButton.tintColor = .label
        }
        else{
            backButton.setProperties(titleStrKey: getString(key: "com.charmphr.action.back"), fontsize: 17, weight: .regular, fontcolor: THEME_COLOR)
            backButton.setTitleColor(.systemBlue, for: .normal)
            
            let backicon = UIImage(systemName: "chevron.backward", withConfiguration: backIconConfig)?.withRenderingMode(.alwaysOriginal)
            var config = UIButton.Configuration.plain()
            config.image = backicon
            config.imagePadding = 6
            config.contentInsets = .zero
            config.baseForegroundColor = .systemBlue
            backButton.configuration = config
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.addTarget(self, action: #selector(onBackClick), for: .touchUpInside)
    }
    
    private func checkAndUpdateDOB() {
        if hkDOB == nil {
            let appName: String = AppConfig.sharedInstance.appDisplayName ?? "PHR"
            // showNoDOBError()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: { [weak self] in
                
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.wellness.healthkit.patient.no.dob.heading"), msg: getString(key: "com.charmphr.wellness.healthkit.patient.no.dob.info", with: [appName,appName]), okClicked: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
            })
           
        }
    }
    
//    private func showAlertForDOBAuthFail() {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: { [weak self] in
//            
//            CharmUtil.createOkayAlertWith(title: "", msg: getString(key: "com.charmphr.wellness.healthkit.patient.dob.auth.error"), okClicked: { [weak self] in
//                self?.navigationController?.popViewController(animated: true)
//            })
//        })
//    }

    @objc func onBackClick(){
        cancelDelegate?.onHKPatientSelectionCancelled()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func onSelectPatient(index: Int){
        
        
        delegate?.onHKPatientSelected(patient: patientList[index])
       // self.dismiss(animated: true)
    }
    
    
    
    @objc func doNothing(){
        
    }
    
    //MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HKPatientTableViewCell", for: indexPath) as? HKPatientTableViewCell {
            
            let patient  = patientList[indexPath.row]
            cell.setPatientData(patient: patient)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientList.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let patient = patientList.getElement(at: indexPath.row) {
            if let hkDOB {
                if let patDOB = patient.dateOfBirth {
                    if patDOB.isSameDate(date: hkDOB) {
                        patientSelectView.hideErrorView()
                        patientSelectView.updateInfoData()
                    }
                    else {
                        patientSelectView.showErrorView()
                    }
                }
            }
        }
    }
}
 
protocol HKPatientSelectVCDelegate: AnyObject {
    func onHKPatientSelected(patient: Patient)
}

protocol HKPatientSelectCancelDelegate: AnyObject {
    func onHKPatientSelectionCancelled()
}
