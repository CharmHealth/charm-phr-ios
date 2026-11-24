//
//  AboutViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 05/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AboutViewController: CustomViewControllerWithTableView , UITableViewDataSource, CharmConnectionV2HandlerDelegate{
    
     var facilitiesAndProviderSegementView: UISegmentedControl = UISegmentedControl(items: ["",""])
     
     var charmConnectionHandler : CharmConnectionHandler? = nil
             
     var arrayOfFacility : [Facility] = []
     var arrayOfProvider : [Provider] = []
     
     override func viewDidLoad() {
         super.viewDidLoad()
         self.navigationItem.title = getString(key: "com.charmphr.about.title")
         createView()
     }
     
     func createView()
    {
        
        self.setLargeTitle(enable: false)
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        self.titleCustomView.addSubview(facilitiesAndProviderSegementView)
        
        facilitiesAndProviderSegementView.setTitle(getString(key: "com.charmphr.about.facility.title"), forSegmentAt: 0)
        facilitiesAndProviderSegementView.setTitle(getString(key: "com.charmphr.about.provider.title"), forSegmentAt: 1)
        facilitiesAndProviderSegementView.selectedSegmentIndex = 0
        facilitiesAndProviderSegementView.addTarget(self, action: #selector(resultsAndOrdersSegmentValueChanged(_:)), for: .valueChanged)
        facilitiesAndProviderSegementView.addProperties(fontSize: FONT_SIZE_NORMAL)
        
        facilitiesAndProviderSegementView.setCenterY()
        facilitiesAndProviderSegementView.setSafeAreaLeft(offset: X_SPACE)
        facilitiesAndProviderSegementView.setSafeAreaRight(offset: -X_SPACE)
        facilitiesAndProviderSegementView.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        
        changeCustomTitleViewHeight(height: HEADER_HEIGHT)

         self.customTableView.dataSource = self
         customTableView.separatorColor = .clear
         refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
         customTableView.register(AboutFacilityTableViewCell.self, forCellReuseIdentifier: "AboutFacilityTableViewCell")
         customTableView.register(AboutProviderTableViewCell.self, forCellReuseIdentifier: "AboutProviderTableViewCell")
         
         self.charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
         self.loadRequest()
     }
        
     //MARK: - action calls
    
    @objc func onUIRefreshChange(){
        loadRequest()
    }
    
     @objc func resultsAndOrdersSegmentValueChanged(_ sender: UISegmentedControl) {
         if sender.selectedSegmentIndex == 0
         {
             if !arrayOfFacility.isEmpty
             {
                 customTableView.reloadData()
                 hideActivityIndicator()
                 customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
             }else{
                 loadRequest()
             }
             
         }else{
             if !arrayOfProvider.isEmpty
             {
                 customTableView.reloadData()
                 hideActivityIndicator()
                 customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
             }
             else{
                 loadRequest()
             }
         }
    }
        
     func loadRequest()
     {
         if refreshControl.isRefreshing != true{
             showActivityIndicator()
         }
         charmConnectionHandler?.getAboutDetail(identificationKey: "about")
        
     }
        
     //MARK: - tableview delegate methods
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if facilitiesAndProviderSegementView.selectedSegmentIndex == 0
         {
            if arrayOfFacility.isEmpty
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }else
            {
                bottomImageView.image = #imageLiteral(resourceName: "Hospitalization_HP_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
             
            return arrayOfFacility.count
         }else
         {
            if arrayOfProvider.isEmpty
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
            else
            {
                bottomImageView.image = #imageLiteral(resourceName: "TreatingPhysicians_HP_BG")
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfProvider.count
         }
     }
        
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         if facilitiesAndProviderSegementView.selectedSegmentIndex == 0
         {
             if let cell = tableView.dequeueReusableCell(withIdentifier: "AboutFacilityTableViewCell") as? AboutFacilityTableViewCell{
                 let facility = arrayOfFacility[indexPath.row]
                 cell.setTableViewCell(data: facility)
                 
                 return cell
             }
             return UITableViewCell()
         }else
         {
             if let cell = tableView.dequeueReusableCell(withIdentifier: "AboutProviderTableViewCell") as? AboutProviderTableViewCell{
                 
                 let provider = arrayOfProvider[indexPath.row]
                 cell.setTableViewCell(data: provider)
                 return cell
             }
             return UITableViewCell()
         }
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if facilitiesAndProviderSegementView.selectedSegmentIndex == 0
        {
            let facility = arrayOfFacility[indexPath.row]
            
            if facility.direction.isNilOrBlank() || facility.direction == "null"{
                CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.about.noMaps.error.message"), seconds: 2)
            }
            else{
                if let urlString = facility.direction?.trimAllSpaces().lowercased(){
                    if let url: URL = URL(string: urlString){
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
        
     
     //MARK: - charmconnection handler delegate methods
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "about"
        {
            if let resp = response as? About{
                arrayOfFacility = resp.facilityList
                arrayOfProvider = resp.providerList
            }
            customTableView.reloadData()
            hideActivityIndicator()
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "about"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        hideActivityIndicator()
    }
     
     override func noDataViewRetryBtnClicked() {
         loadRequest()
     }
}


//override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    super.tableView(tableView, didSelectRowAt: indexPath)
//    if facilitiesAndProviderSegementView.selectedSegmentIndex == 0
//    {
//       if arrayOfFacility.count > 0
//       {
//           let facilityVC = FacilityDetailViewController()
//           facilityVC.facility = arrayOfFacility[indexPath.row]
//           navigationItem.backBarButtonItem = backButton(withTitle: NSLocalizedString("com.charmphr.about.facility.title", comment: ""))
//           self.navigationController?.pushViewController(facilityVC, animated: true)
//       }
//    }else
//    {
//       if arrayOfProvider.count > 0
//       {
//           let providerVC = ProviderDetailViewController()
//           providerVC.provider = arrayOfProvider[indexPath.row]
//           navigationItem.backBarButtonItem = backButton(withTitle: NSLocalizedString("com.charmphr.about.provider.title", comment: ""))
//           self.navigationController?.pushViewController(providerVC, animated: true)
//       }
//    }
//}
//
