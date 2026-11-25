//
//  SelectPatientViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 12/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
//import ZAnalytics

class SelectPatientViewController: CustomViewControllerWithTableView , UITableViewDataSource , CharmConnectionHandlerDelegate , CharmConnectionHandlerDataDelegate{
    
    var arrayOfPatient : [Patient] = []
    var selectedPatient : Patient?
    var charmConnectionHandler : CharmConnectionHandler? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = getString(key: "com.charmphr.selectpatient.title")
        self.navigationItem.hidesBackButton = true
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.dataDelegate = self
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        customTableView.dataSource = self
        customTableView.separatorColor = .clear
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(SelectPatientTableViewCell.self, forCellReuseIdentifier: "selectPatientTableViewCell")
        
        self.cellBackgroundColor = 0xFFFFFFFF
        self.tableviewCellInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        selectPatientForNotification()
    }
    
    func selectPatientForNotification(){
        if let notificationObj = appDelegate.notificationObj{
            if let index = arrayOfPatient.firstIndex(where: { patient in
                return patient.patientId == notificationObj.patientId
            }){
                tableView(customTableView, didSelectRowAt: IndexPath(row: index, section: 0))
            }
        }
    }
    
    @objc func onUIRefreshChange(){
        if refreshControl.isRefreshing{
            refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfPatient.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "selectPatientTableViewCell") as? SelectPatientTableViewCell{
            let patient = arrayOfPatient[indexPath.row]
            cell.setTableViewCell(data: patient)
            cell.selectedBackgroundView = UIView()
            if patient.isPhotoAvailable
            {
                charmConnectionHandler?.downloadPatientPhoto(patientId: patient.patientId, indexpath: indexPath, identificationKey: "downloadPhoto")
            }
            
            //        let backgroundView = UIView()
            //        backgroundView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            //        cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedPatient = arrayOfPatient[indexPath.row]
        Patient.selectedPatientInstance = selectedPatient
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "homeVC") as? HomeViewController {
            let mainVC = MainViewController(homeVC: homeVC)
            if appDelegate.notificationObj == nil{
                self.navigationController?.setViewControllers([mainVC], animated: true)
            }
            else{
                self.navigationController?.setViewControllers([mainVC], animated: false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {

    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey == "downloadPhoto"
        {
            if let indexPath = indexPath, let cell = customTableView.cellForRow(at: indexPath) as? SelectPatientTableViewCell{
                if let image = UIImage(data: data)
                {
                    arrayOfPatient[indexPath.row].patientPhoto = image
                    cell.selectPatientItemView.imageViewWithInitailsView.setImage(image: image)
                }
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

