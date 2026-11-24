//
//  HpAllergiesViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 30/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//
/*
import UIKit

class HpAllergiesViewController: CustomViewControllerWithTableView, CharmConnectionHandlerDelegate, UITableViewDataSource, AddViewControllerDelegate
{

    var charmConnectionHandler : CharmConnectionHandler!
    var arrayOfAllergies : [AllergiesList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.changeBackGroundColor(color: APPLICATION_BACKGROUND_COLOR)
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        self.navigationItem.title = NSLocalizedString("com.charmphr.hpAllergies.title", comment: "")
        self.navigationItem.backBarButtonItem?.title = NSLocalizedString("com.charmphr.healthPassport.back.title", comment: "")
                
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        fetchAllergies()
        
        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        customTableView.register(UINib(nibName: "HpAllergieTableViewCell", bundle: nil), forCellReuseIdentifier: "HpAllergieTableViewCell")
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
        
        //TODO: change image
        bottomImageView.image = #imageLiteral(resourceName: "Allergies_HP_BG")
    }
    
    //MARK: uitableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfAllergies.count > 4 || arrayOfAllergies.count == 0
        {
            bottomImageView.isHidden = true
            if arrayOfAllergies.count == 0
            {
                self.noDataBackGroundView.setImage(enum: .noData, title: NSLocalizedString("com.charmphr.action.noData.title", comment: ""), message: "\(NSLocalizedString("com.charmphr.action.noData.message", comment: ""))\(NSLocalizedString("com.charmphr.hpAllergies.noData.title", comment: ""))")
            }else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
        }else
        {
            bottomImageView.isHidden = false
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfAllergies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HpAllergieTableViewCell") as! HpAllergieTableViewCell
        
        let allergie = arrayOfAllergies[indexPath.row]
        cell.keyLabel.text = "\(allergie.allergy ?? "") - \(allergie.allergyType ?? "")"
        cell.valueLabel.text = allergie.patientAllergyMap.severity
        cell.dateLabel.text = CharmUtil.getDateStringWith(date: allergie.patientAllergyMap.observedDate, dateFormat: PHR_DATE_DISPLAY_FORMAT)
    
        cell.valueLabel.textAlignment  = .center
        cell.valueLabelWidthConstraint.constant = cell.valueLabel.sizeThatFits(CGSize(width: 1000, height: 2000)).width  + 11
        if allergie.patientAllergyMap.severity == "Mild"
        {
            cell.setSeverityAsMild()
        }
        else if allergie.patientAllergyMap.severity == "Moderate"
        {
            cell.setSeverityAsModerate()
        }
        else if allergie.patientAllergyMap.severity == "Severe"
        {
            cell.setSeverityAsSevere()
        }
        
        cell.dateLabelConstraint.constant = cell.dateLabel.sizeThatFits(CGSize(width: 1000, height: 10000)).width
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let editAllergie = arrayOfAllergies[indexPath.row]
        let hpAddAllergiesVC = HpAddAllergiesViewController()
        hpAddAllergiesVC.delegate = self
        hpAddAllergiesVC.editAlergyList = editAllergie
        self.navigationController?.pushViewController(hpAddAllergiesVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("com.charmphr.action.delete", comment: "")) { action, index in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertController.message = NSLocalizedString("com.charmphr.allergies.alert.delete.allergies", comment: "")
            
            let deleteAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.delete", comment: ""), style: .destructive) { (deleteAction) in
                self.deleteTableviewCellCalled(at: indexPath)
            }
            let cancelAction =  CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            alertController.show()
        }
        let editAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("com.charmphr.action.edit", comment: "")) { action, index in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertController.message = NSLocalizedString("com.charmphr.allergies.alert.edit.allergies", comment: "")
            
            let editAction = CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.edit", comment: ""), style: .destructive) { (deleteAction) in
                self.editMedicalConditionInRow(at: indexPath)
            }
            let cancelAction =  CharmUtil.getAlertAction(title: NSLocalizedString("com.charmphr.action.cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(editAction)
            alertController.addAction(cancelAction)
            alertController.show()
        }
        
        return [deleteAction,editAction]
    }
    
    //MARK: other methods
    func fetchAllergies()
    {
        showActivityIndicator()
        charmConnectionHandler.fetchAllergiesList(patientId: Patient.selectedPatientInstance!.patientId, practiceId: "", allergyType: "Active", identificationKey: "fetchAllergies")
    }
    
    @objc func addButtonClicked()
    {
        let hpAddAllergiesVC = HpAddAllergiesViewController()
        hpAddAllergiesVC.delegate = self
        self.navigationController?.pushViewController(hpAddAllergiesVC, animated: true)
    }
    
    func addViewControllerDataAdded() {
        fetchAllergies()
    }
    
    func editMedicalConditionInRow(at indexPath : IndexPath)
    {
        let editAllergie = arrayOfAllergies[indexPath.row]
        let hpAddAllergiesVC = HpAddAllergiesViewController()
        hpAddAllergiesVC.delegate = self
        hpAddAllergiesVC.editAlergyList = editAllergie
        self.navigationController?.pushViewController(hpAddAllergiesVC, animated: true)
    }
    
    func deleteTableviewCellCalled(at indexpath : IndexPath)
    {
        if self.charmConnectionHandler == nil
        {
            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        }
        
        activityIndicatorView.startAnimating()
        self.charmConnectionHandler?.deleteAllergy(json: ["allergy_map_id":arrayOfAllergies[indexpath.row].patientAllergyMap.allergyMapId!,"patient_id":Patient.selectedPatientInstance!.patientId!],isHealthPassport: true, identificationKey: "deleteInactiveAllergy_\(indexpath.row)")
    }
    
    // MARK: charm connection Handler delegate
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchAllergies"
        {
            let parsingHelper = ParsingHelper()
            arrayOfAllergies = parsingHelper.fillArrayOfAllergiesWithDictionary(arrayOfDict: (jsonObject["output_string"] as? Dictionary<String,Any>)!, status: nil, practiceId: "")
            hideActivityIndicator()
            customTableView.reloadData()
        }
        else if identificationKey.hasPrefix("deleteInactiveAllergy")
        {
            activityIndicatorView.stopAnimating()
            
            let row = Int(identificationKey.components(separatedBy: "_").last!)!
            arrayOfAllergies.remove(at: row)
            
            self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "fetchAllergies"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(forCode: CharmUtil.getErrorCode(error: error)), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }

}
*/
