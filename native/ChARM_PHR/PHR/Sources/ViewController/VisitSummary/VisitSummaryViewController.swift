//
//  VisitSummaryViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 29/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import QuickLook


class VisitSummaryViewController: CustomViewControllerWithTableView , UITableViewDataSource, CharmConnectionV2HandlerDelegate, CharmConnectionHandlerDataDelegate
{
    var charmConnectionHandler : CharmConnectionHandler?
    
    var arrayOfPatientEncounter : [PatientEncounterList] = []
    
    var pageNo = 1
    var hasMoreVisitSummary = false
        
    var previewItem: URL?
    
    var selectedVisitSummary: PatientEncounterList?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        customTableView.delegate = self
        customTableView.register(VisitSummaryTableViewCell.self, forCellReuseIdentifier: "VisitSummaryTableViewCell")
        customTableView.addInfiniteScrolling {
            self.fetchVisitSummaryList(fromScroll: true)
        }
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        
        self.navigationItem.title = getString(key: "com.charmphr.visitSummary.title")
        fetchVisitSummaryList()
    }
    
    @objc func onUIRefreshChange(){
        fetchVisitSummaryList()
    }
    
    func fetchVisitSummaryList(fromScroll: Bool = false)
    {
        
        if fromScroll {
            pageNo = pageNo + 1
        }
        else{
            pageNo = 1
        }
        
        
        if charmConnectionHandler == nil
        {
            charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
            charmConnectionHandler?.dataDelegate = self
        }
        
        if refreshControl.isRefreshing != true && !fromScroll{
            showActivityIndicator()
        }
        
        charmConnectionHandler?.fetchVisitSummaryList(pageNo:pageNo, identificationKey: "fetchVisitsummary")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfPatientEncounter.isEmpty
        {
            bottomImageView.image = nil
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
        }
        else
        {
            bottomImageView.image = #imageLiteral(resourceName: "VisitSummary_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfPatientEncounter.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "VisitSummaryTableViewCell") as! VisitSummaryTableViewCell
        let visitSummary = arrayOfPatientEncounter[indexPath.row]
        tableviewCell.setTableViewCell(data: visitSummary)
        return tableviewCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if arrayOfPatientEncounter.count > 0
        {
            self.selectedVisitSummary = arrayOfPatientEncounter[indexPath.row]
            
            if let selectedVisitSummary = selectedVisitSummary {
                let patientEncounter = arrayOfPatientEncounter[indexPath.row]
                let cell = tableView.cellForRow(at: indexPath) as? VisitSummaryTableViewCell
                patientEncounter.readStatus = true
                cell?.visitSummaryItemView.setFontWeight(isRead: patientEncounter.readStatus)
                
                showActivityIndicatorFront()
                charmConnectionHandler?.getVisitSummaryPDF(selectedPatientEncounter: selectedVisitSummary, identificationKey: "visitSummaryPDF")
                
                //performSegue(withIdentifier: "pdfVC", sender: self)
            }
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "fetchVisitsummary"
        {
            if let visitSummaryList = response as? [PatientEncounterList]{
                
                
//                arrayOfPatientEncounter = visitSummaryList
//                arrayOfPatientEncounter = FilterHandler.filterAndSortVisitSummary(arrayOfVisitSummary: arrayOfPatientEncounter)
//                customTableView.reloadData()
//
                if pageNo == 1{
                    
                    arrayOfPatientEncounter = visitSummaryList
                    customTableView.reloadData()
                    
                }
                else{
                    
                    if !visitSummaryList.isEmpty {
                        var indexPathArr:[IndexPath] = []
                        let finalCount = arrayOfPatientEncounter.count + visitSummaryList.count
                        for startIndex in (arrayOfPatientEncounter.count...finalCount-1 ){
                            indexPathArr.append(IndexPath(row: startIndex, section: 0))
                        }
                        
                        customTableView.beginUpdates()
                        arrayOfPatientEncounter.append(contentsOf: visitSummaryList)
                        customTableView.insertRows(at: indexPathArr, with: .top)
                        customTableView.endUpdates()
                    }
                    customTableView.infiniteScrollingView.stopAnimating()
                }

                hasMoreVisitSummary = visitSummaryList.count == listPerPageCount &&  getEnabledPractices(moduleId: visitSummaryModelId).count == 1
                
                customTableView.showsInfiniteScrolling = hasMoreVisitSummary
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "fetchVisitsummary"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
        self.hideActivityIndicator()
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        
        if identificationKey == "visitSummaryPDF"{
            
            hideActivityIndicator()
            let pdfImageVC = PDFImageViewController(fileName: getFacilityAndMemberName(visitSummary: selectedVisitSummary), data: data)
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
    }
    
    override func noDataViewRetryBtnClicked() {
        fetchVisitSummaryList()
    }
    
    private func getFacilityAndMemberName(visitSummary: PatientEncounterList?) -> String{
        var facilityAndPhysianName = ""
        
        if let visitSummary = visitSummary {
            if let facilityName = visitSummary.facility?.facilityName{
                if facilityName.isNotBlank()
                {
                    facilityAndPhysianName.append(facilityName)
                    facilityAndPhysianName.append(" - ")
                }
            }
            
            if let physicianName = visitSummary.member?.fullName{
                if physicianName.isNotBlank()
                {
                    facilityAndPhysianName.append(physicianName)
                }
            }
            
        }
        return facilityAndPhysianName
    }
}

