//
//  AllergiesViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 19/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AllergiesViewController: CustomViewControllerWithTableView , UITableViewDataSource , CharmConnectionHandlerDelegate , AddViewControllerDelegate, CharmConnectionV2HandlerDelegate , AllergiesTableViewCellDelegate{//Added tvcell delegate
    
    var activeAndInactiveSegementView: UISegmentedControl = UISegmentedControl(items: ["",""])
    
    var arrayOfActiveAllergies : Array<AllergiesList> = []
    var arrayOfInactiveAllergies : Array<AllergiesList> = []
    var arrayOfResolvedAllergies : Array<AllergiesList> = []
    var numberOfPracticeDataGotForResolvedAllergies = 0
        
    var charmConnectionHandler : CharmConnectionHandler? = nil
    
    var hasMoreActiveAllergies : Bool = true
    var hasMoreInactiveAllergies : Bool = true
    
    var selectedAllergie : AllergiesList?
    var selectedIndex: Int? = nil
    
    let isAddAllergy = RbacUtil.checkPrivilege(privilege: .ADD_ALLERGIES)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        changeCustomTitleViewHeight(height: HEADER_HEIGHT)
        
        self.navigationItem.title = getString(key: "com.charmphr.allergies.title")
        
        if  isAddAllergy && !AppConfig.sharedInstance.isCustomBrandApp && canAllowAddEntry{
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAllergiesClicked)), animated: true)
        }
        titleCustomView.addSubview(activeAndInactiveSegementView)
        
        self.activeAndInactiveSegementView.setTitle(getString(key: "com.charmphr.allergies.active.title"), forSegmentAt: 0)
        self.activeAndInactiveSegementView.setTitle(getString(key: "com.charmphr.allergies.inactive.title"), forSegmentAt: 1)

        activeAndInactiveSegementView.addTarget(self, action: #selector(activeAndInactiveSegmentChanged(_:)), for: .valueChanged)
        activeAndInactiveSegementView.addProperties(fontSize: FONT_SIZE_NORMAL)
        activeAndInactiveSegementView.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        
        activeAndInactiveSegementView.selectedSegmentIndex = 0
        
        activeAndInactiveSegementView.setCenterY()
        activeAndInactiveSegementView.setLeft(offSet: X_SPACE)
        activeAndInactiveSegementView.setRight(offSet: -X_SPACE)

        self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        self.charmConnectionHandler?.v2Delegate = self
        
        
        self.customTableView.addInfiniteScrolling {
            self.infiniteScrollingAction()
        }
        
        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.separatorColor = .clear
        customTableView.rowHeight = UITableView.automaticDimension
        customTableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(AllergiesTableViewCell.self, forCellReuseIdentifier: "AllergiesTableViewCell")
        
        activityIndicatorView.hidesWhenStopped = true

        loadRequest()
    }

    
    //MARK: - action calls
    
    @objc func onUIRefreshChange(){
        hideSwipeActionButtons()
        pullToRefeashAction()
    }
    
    @objc func activeAndInactiveSegmentChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0
        {
            if !arrayOfActiveAllergies.isEmpty
            {
                customTableView.showsInfiniteScrolling = hasMoreActiveAllergies
                customTableView.reloadData()
                hideActivityIndicator()
            }else
            {
                loadRequest()
            }
        }else if sender.selectedSegmentIndex == 1
        {
            if !arrayOfInactiveAllergies.isEmpty
            {
                customTableView.showsInfiniteScrolling = hasMoreInactiveAllergies
                customTableView.reloadData()
                hideActivityIndicator()
            }
            else{
                loadRequest()
            }
        }
        else
        {
            if !arrayOfResolvedAllergies.isEmpty
            {
                customTableView.showsInfiniteScrolling = hasMoreInactiveAllergies
                customTableView.reloadData()
                hideActivityIndicator()
            }
            else{
                loadRequest()
            }
        }
    }
    
    @objc func addAllergiesClicked()
    {
        selectedAllergie = nil
        performSegue(withIdentifier: "AddAllergieVC", sender: nil)
    }
       
    func infiniteScrollingAction()
    {
        loadRequest()
    }
       
    func pullToRefeashAction()
    {
        if activeAndInactiveSegementView.selectedSegmentIndex == 0
        {
            arrayOfActiveAllergies = []
        }else if activeAndInactiveSegementView.selectedSegmentIndex == 1
        {
            arrayOfInactiveAllergies = []
        }else
        {
            arrayOfResolvedAllergies = []
        }
        loadRequest()
    }
       
    func loadRequest()
    {
        if activeAndInactiveSegementView.selectedSegmentIndex == 0
        {
            if arrayOfActiveAllergies.isEmpty
            {
                if refreshControl.isRefreshing != true{
                    showActivityIndicator()
                }
            }
            
            
            charmConnectionHandler?.fetchAllergiesList(pageNo: 1, identificationKey: "activeAllergy", allergyType: ACTIVE)
        }
        else if activeAndInactiveSegementView.selectedSegmentIndex == 1
        {
            if arrayOfInactiveAllergies.isEmpty
            {
                if refreshControl.isRefreshing != true{
                    showActivityIndicator()
                }
            }
            
            charmConnectionHandler?.fetchAllergiesList(pageNo: 1, identificationKey: "InActiveAllergy", allergyType: INACTIVE)
        }
//        else
//        {
//            if arrayOfResolvedAllergies.count == 0
//            {
//                numberOfPracticeDataGotForResolvedAllergies = 0
//                showActivityIndicator()
//            }
//
//            for practice in Patient.selectedPatientInstance!.practiceList
//            {
//                charmConnectionHandler!.fetchAllergiesList(patientId: Patient.selectedPatientInstance!.patientId, practiceId: practice.practiceId , allergyType : "Resolved", identificationKey: "ResolvedAllergy practiceId=\(practice.practiceId!)")
//            }
//        }
    }
    
    func deleteTableviewCellCalled(indexpath:IndexPath)
    {
        if self.charmConnectionHandler == nil
        {
            self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        }
        if activeAndInactiveSegementView.selectedSegmentIndex == 0
        {
            self.charmConnectionHandler?.deleteAllergy(json: ["allergy_map_id":arrayOfActiveAllergies[indexpath.row].patientAllergyMap?.allergyMapId ?? "","patient_id":Patient.selectedPatientInstance?.patientId ?? ""], identificationKey: "deleteActiveAllergy_\(indexpath.row)")
            activityIndicatorView.startAnimating()
        }else if activeAndInactiveSegementView.selectedSegmentIndex == 1
        {
            self.charmConnectionHandler?.deleteAllergy(json: ["allergy_map_id":arrayOfActiveAllergies[indexpath.row].patientAllergyMap?.allergyMapId ?? "","patient_id":Patient.selectedPatientInstance?.patientId ?? ""], identificationKey: "deleteInactiveAllergy_\(indexpath.row)")
            activityIndicatorView.startAnimating()
        }else
        {
            self.charmConnectionHandler?.deleteAllergy(json: ["allergy_map_id":arrayOfActiveAllergies[indexpath.row].patientAllergyMap?.allergyMapId ?? "","patient_id":Patient.selectedPatientInstance?.patientId ?? ""], identificationKey: "deleteResolvedAllergy_\(indexpath.row)")
            activityIndicatorView.startAnimating()
        }
    }
    
    func editAllergiesInRow(at indexPath : IndexPath)
    {
        if activeAndInactiveSegementView.selectedSegmentIndex == 0
        {
            selectedAllergie = arrayOfActiveAllergies[indexPath.row]
        }
        else if activeAndInactiveSegementView.selectedSegmentIndex == 1
        {
            selectedAllergie = arrayOfInactiveAllergies[indexPath.row]
        }else
        {
            selectedAllergie = arrayOfResolvedAllergies[indexPath.row]
        }
        performSegue(withIdentifier: "AddAllergieVC", sender: self)
    }
       
    override func hideActivityIndicator()
    {
        if refreshControl.isRefreshing{
            refreshControl.endRefreshing()
        }
        customTableView.isHidden = false
        activityIndicatorView.stopAnimating()
        customTableView.infiniteScrollingView.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
//        customTableView.pullToRefreshView.stopAnimating()
    }
    
//MARK: - TableView Delegate
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeAndInactiveSegementView.selectedSegmentIndex == 0
        {
            if arrayOfActiveAllergies.isEmpty
            {
                if !AppConfig.sharedInstance.isCustomBrandApp
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.allergies.noAllergy.title"))")
                }else
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfActiveAllergies.count
        }
        else if activeAndInactiveSegementView.selectedSegmentIndex == 1
        {
            if arrayOfInactiveAllergies.isEmpty
            {
                if !AppConfig.sharedInstance.isCustomBrandApp
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }else
                {
                    self.noDataBackGroundView.backgroundColor =  UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return arrayOfInactiveAllergies.count
        }
        else
        {
            if arrayOfResolvedAllergies.isEmpty
            {
                if !AppConfig.sharedInstance.isCustomBrandApp
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.allergies.noAllergy.title"))")
                }else
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
                }
            }
            return arrayOfResolvedAllergies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "AllergiesTableViewCell") as? AllergiesTableViewCell
        if let tableviewCell = tableviewCell{
            tableviewCell.delegate = self
            
            var allergy: AllergiesList?
            if activeAndInactiveSegementView.selectedSegmentIndex == 0 && !arrayOfActiveAllergies.isEmpty{
                allergy = arrayOfActiveAllergies[indexPath.row]
            }
            else if activeAndInactiveSegementView.selectedSegmentIndex == 1 && !arrayOfInactiveAllergies.isEmpty{
                allergy = arrayOfInactiveAllergies[indexPath.row]
            }
            if let allergy = allergy{
                tableviewCell.setTableViewCell(data: allergy, indexPath: indexPath)
            }
            
            let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftLeft.direction = UISwipeGestureRecognizer.Direction.left
            tableviewCell.allergiesItemView.addGestureRecognizer(swiftLeft)
            
            let swiftRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGuesture(_:)))
            swiftRight.direction = UISwipeGestureRecognizer.Direction.right
            tableviewCell.allergiesItemView.addGestureRecognizer(swiftRight)
            
            //removed tap gesture recognizer and move to tableviewcell and changed to protocol handling.
            if let selectedIndex = selectedIndex{
                if indexPath.row == selectedIndex{
                    tableviewCell.setRowActionForSwipeLeft(duration: 0, isAddedByPatient: allergy?.patientAllergyMap?.isAddedByPatient ?? false)
                }
                else{
                    tableviewCell.allergiesItemView.setRowActionForSwipeRight(duration: 0)
                }
            }
            
            return tableviewCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            super.tableView(tableView, didSelectRowAt: indexPath)
            
            hideSwipeActionButtons()
            
            if activeAndInactiveSegementView.selectedSegmentIndex == 0 && arrayOfActiveAllergies.count > 0
            {
                selectedAllergie = arrayOfActiveAllergies[indexPath.row]
            }
            else if activeAndInactiveSegementView.selectedSegmentIndex == 2 && arrayOfResolvedAllergies.count > 0
            {
                selectedAllergie = arrayOfResolvedAllergies[indexPath.row]
            }
            else if activeAndInactiveSegementView.selectedSegmentIndex == 1 && arrayOfInactiveAllergies.count > 0
            {
                selectedAllergie = arrayOfInactiveAllergies[indexPath.row]
            }
            
            let addAllergieViewController = AddAllergieViewController()
            addAllergieViewController.delegate = self
            if let selectedAllergie = selectedAllergie, let patientAllergyMap = selectedAllergie.patientAllergyMap
            {
                addAllergieViewController.editAlergyList = selectedAllergie
                if patientAllergyMap.isAddedByPatient{
                    self.navigationController?.pushViewController(addAllergieViewController, animated: true)
                }
            }
    //        performSegue(withIdentifier: "AllergiesDetailVC", sender: self)
        }
        
    
//MARK: - Other Functions
    func hideSwipeActionButtons(){
        
        if let prevSelectedTVIndex = selectedIndex {
            let indexpath = IndexPath(row: prevSelectedTVIndex, section: 0)
            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? AllergiesTableViewCell {
                prevTableViewCell.allergiesItemView.setRowActionForSwipeRight(duration: 0.4)
                selectedIndex = nil
            }
        }
    }
    
    @objc func swipeGuesture(_ sender: UISwipeGestureRecognizer){
        
        if let allergiesItemView = sender.view as? AllergiesItemView{
            if let tableViewCell = allergiesItemView.superview?.superview as? AllergiesTableViewCell{
                
                let index: Int = customTableView.indexPath(for: tableViewCell)?.row ?? -1
                switch sender.direction {
                case UISwipeGestureRecognizer.Direction.left:
                    var allergy: AllergiesList
                    if activeAndInactiveSegementView.selectedSegmentIndex == 0{
                        allergy = arrayOfActiveAllergies[index]
                    }else{
                        allergy = arrayOfInactiveAllergies[index]
                    }
                    var allowLeftSwipe = true
                    if let prevSelectedTVIndex = selectedIndex {
                        if prevSelectedTVIndex == index {
                            allowLeftSwipe = false
                        }
                        else{
                            let indexpath = IndexPath(row: prevSelectedTVIndex, section: 0)
                            if let prevTableViewCell = customTableView.cellForRow(at: indexpath) as? AllergiesTableViewCell {
                                prevTableViewCell.allergiesItemView.setRowActionForSwipeRight(duration: 0.4)
                                selectedIndex = nil
                            }
                        }
                    }
                    if allowLeftSwipe{
                        selectedIndex = index
                        tableViewCell.setRowActionForSwipeLeft(duration: 0.4, isAddedByPatient: allergy.patientAllergyMap?.isAddedByPatient ?? false)
                    }
                case UISwipeGestureRecognizer.Direction.right:
                    if selectedIndex == index{
                        selectedIndex = nil
                        allergiesItemView.setRowActionForSwipeRight(duration: 0.4)
                    }
                default:
                    break
                }
            }
        }
    }
    
    
    
    //MARK: Allergy itemview delegate
    //Removed onTouchLabel gesture and updated to protocol
    func onDeleteBtnClicked(tableViewCell: AllergiesTableViewCell, indexPath: IndexPath) {
        if selectedIndex != nil{
            tableViewCell.allergiesItemView.setRowActionForSwipeRight(duration: 0.4)
        }
        selectedIndex = nil
        
        CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.allergies.alert.delete.allergies"), deleteClicked: {
            self.deleteTableviewCellCalled(indexpath: indexPath)
        })
    }
    
    func onMoreBtnClicked(indexPath: IndexPath) {
        customTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
//MARK: - CharmConnectionHandler Delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey.contains("activeAllergy")
        {
            if let activeAllergyList = response as? [AllergiesList]{
                arrayOfActiveAllergies = activeAllergyList
                
                customTableView.showsInfiniteScrolling = false
                hasMoreActiveAllergies = false
                
                arrayOfActiveAllergies = FilterHandler.filterAndSortAllergies(arrayOfAllergies: arrayOfActiveAllergies)
                
                if self.activeAndInactiveSegementView.selectedSegmentIndex == 0
                {
                    hideActivityIndicator()
                    customTableView.reloadData()
                }
            }
        }
        else if identificationKey.contains("InActiveAllergy")
        {
            if let inActiveAllergyList = response as? [AllergiesList]{
                arrayOfInactiveAllergies = inActiveAllergyList
                customTableView.showsInfiniteScrolling = false
                hasMoreInactiveAllergies = false
                
                arrayOfInactiveAllergies = FilterHandler.filterAndSortAllergies(arrayOfAllergies: arrayOfInactiveAllergies)
                
                if self.activeAndInactiveSegementView.selectedSegmentIndex == 1
                {
                    hideActivityIndicator()
                    customTableView.reloadData()
                }
            }
        }
        else if identificationKey.contains("ResolvedAllergy")
        {
            numberOfPracticeDataGotForResolvedAllergies += 1

            if let resolveAllergyList = response as? [AllergiesList]{
                arrayOfResolvedAllergies = resolveAllergyList
                customTableView.showsInfiniteScrolling = false
                hasMoreInactiveAllergies = false
                
                if Patient.selectedPatientInstance?.practiceList.count == numberOfPracticeDataGotForResolvedAllergies
                {
                    arrayOfResolvedAllergies = FilterHandler.filterAndSortAllergies(arrayOfAllergies: arrayOfResolvedAllergies)
                    if self.activeAndInactiveSegementView.selectedSegmentIndex == 2
                    {
                        hideActivityIndicator()
                        customTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        if refreshControl.isRefreshing == true{
            refreshControl.endRefreshing()
        }
        if identificationKey.contains("activeAllergy") || identificationKey.contains("ResolvedAllergy") || identificationKey.contains("InActiveAllergy")
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }
       
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {

        if identificationKey.hasPrefix("deleteActiveAllergy")
        {
            activityIndicatorView.stopAnimating()
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                arrayOfActiveAllergies.remove(at: row)
                
                if activeAndInactiveSegementView.selectedSegmentIndex == 0
                {
                    self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
                }
            }
            CharmUtil.showToast(controller: self, message: jsonObject.getString("message"), seconds: 2)
        }
        else if identificationKey.hasPrefix("deleteInactiveAllergy")
        {
            activityIndicatorView.stopAnimating()
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                arrayOfInactiveAllergies.remove(at: row)
                
                if activeAndInactiveSegementView.selectedSegmentIndex == 1
                {
                    self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
                }
            }
            CharmUtil.showToast(controller: self, message: jsonObject.getString("message"), seconds: 2)
        }
        else if identificationKey.hasPrefix("deleteResolvedAllergy")
        {
            activityIndicatorView.stopAnimating()
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                arrayOfResolvedAllergies.remove(at: row)
                
                if activeAndInactiveSegementView.selectedSegmentIndex == 1
                {
                    self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
                }
            }
            CharmUtil.showToast(controller: self, message: jsonObject.getString("message"), seconds: 2)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {

        CharmUtil.createOkayAlertWith(error: error)
        self.hideActivityIndicator()
    }
    
    override func noDataViewRetryBtnClicked() {
        loadRequest()
    }
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        arrayOfActiveAllergies = []
        arrayOfInactiveAllergies = []
//        arrayOfResolvedAllergies = []
//        numberOfPracticeDataGotForResolvedAllergies = 0
        loadRequest()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAllergieVC"
        {
            if let vc = segue.destination as? AddAllergieViewController{
                vc.delegate = self
                if selectedAllergie != nil
                {
                    vc.editAlergyList = selectedAllergie
                }
            }
        }
    }

}
