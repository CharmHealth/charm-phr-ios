//
//  PrescriptionsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 20/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol AddReminderAlertDelegate: AnyObject{
    func showAddReminderAlert(transformModel: AddReminderTransformModel)
}

class PrescriptionsViewController: CustomViewControllerWithTableView , UITableViewDataSource , AddViewControllerDelegate, SelectValueViewControllerDelagate, CharmConnectionV2HandlerDelegate, CharmConnectionHandlerDelegate, AddReminderAlertDelegate, AddReminderDelegate,MedicationItemDelegate, SupplementItemDelegate{
    
    let canAllowMedication = RbacUtil.checkPrivilege(privilege: .VIEW_MEDICATIONS)
    let canAllowSupplement = RbacUtil.checkPrivilege(privilege: .VIEW_SUPPLEMENTS)

    let isAddMedications = RbacUtil.checkPrivilege(privilege: .ADD_MEDICATIONS) && RbacUtil.checkPrivilege(privilege: .VIEW_MEDICATIONS)

    let isAddSupplements = RbacUtil.checkPrivilege(privilege: .ADD_SUPPLEMENTS) && RbacUtil.checkPrivilege(privilege: .VIEW_SUPPLEMENTS)

    let isDeleteMedication = RbacUtil.checkPrivilege(privilege: .DELETE_MEDICATIONS) && RbacUtil.checkPrivilege(privilege: .VIEW_MEDICATIONS)

    let isDeleteSupplement = RbacUtil.checkPrivilege(privilege: .DELETE_SUPPLEMENTS) && RbacUtil.checkPrivilege(privilege: .VIEW_SUPPLEMENTS)

    let isEditMedication = RbacUtil.checkPrivilege(privilege: .EDIT_MEDICATIONS) && RbacUtil.checkPrivilege(privilege: .VIEW_MEDICATIONS)

    let isEditSupplement = RbacUtil.checkPrivilege(privilege: .EDIT_SUPPLEMENTS) && RbacUtil.checkPrivilege(privilege: .VIEW_SUPPLEMENTS)
    
    var medicationsAndSupplementsSegementView: UISegmentedControl?
    
    var charmConnectionHandler : CharmConnectionHandler? = nil
       
    var arrayOfSupplementPOJO : [SupplementGroupPOJO] = []
    var arrayOfMedicationPOJO : [MedicationGroupPOJO] = []
    
    var editMedicationPOJOSelected : MedicationPOJO?
    var editSupplementPOJOSelected : SupplementPOJO?
    
    let FILTERED_BY_LABEL_TAG = 1000
    let filterTypeArr  = [PrescriptionFilterType.All.rawValue, PrescriptionFilterType.Active.rawValue , PrescriptionFilterType.Inactive.rawValue]
    private var selectedFilter : PrescriptionFilterType = .All
    
    private var medicationSection : Section?
    private var supplementSection : Section?
    private var selectedIndex: Int? = nil
    
    private var btnToMedicationPOJOMap: [Int: MedicationPOJO] = [:]
    private var btnToSupplementPOJOMap: [Int: SupplementPOJO] = [:]
    
    private var swipedEntryViewTag: Int? = nil

    var supplementRefillTag: Int = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = getString(key: "com.charmphr.prescriptions.title")
        
        self.setLargeTitle(enable: false)
        
        let medicationSection = AppDataHandler.findSectionWithName(string: "Medications")
        let supplementSection = AppDataHandler.findSectionWithName(string: "Supplements")
        
        if medicationSection != nil && medicationSection?.isEnable ?? false
        {
            self.medicationSection = medicationSection
        }
        if supplementSection != nil && supplementSection?.isEnable ?? false
        {
            self.supplementSection = supplementSection
        }
        createView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editMedicationPOJOSelected = nil
        editSupplementPOJOSelected = nil
    }
    
    private func createView()
    {
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        
        if (medicationSection == nil || !canAllowMedication) || (supplementSection == nil || !canAllowSupplement)
        {
            medicationsAndSupplementsSegementView = UISegmentedControl(items: [""])
            medicationsAndSupplementsSegementView?.isHidden = true
            
            if (medicationSection != nil && canAllowMedication)
            {
                self.navigationItem.title = getString(key: "com.charmphr.prescriptions.medications.title")
                showRightBarButton(isAdd: isAddMedications)
                
            }else if(supplementSection != nil && canAllowSupplement)
            {
                self.navigationItem.title = getString(key: "com.charmphr.prescriptions.supplements.title")
                showRightBarButton(isAdd: isAddSupplements)
            }
        }else
        {
            self.navigationItem.title = getString(key: "com.charmphr.prescriptions.title")
            
            medicationsAndSupplementsSegementView = UISegmentedControl(items: ["",""])
            medicationsAndSupplementsSegementView?.isHidden = false
            changeCustomTitleViewHeight(height: HEADER_HEIGHT)
            medicationsAndSupplementsSegementView?.setTitle(getString(key: "com.charmphr.prescriptions.medications.title"), forSegmentAt: 0)
            medicationsAndSupplementsSegementView?.setTitle(getString(key: "com.charmphr.prescriptions.supplements.title"), forSegmentAt: 1)
        }
        
        if let medicationsAndSupplementsSegementView{
            self.titleCustomView.addSubview(medicationsAndSupplementsSegementView)
            
            medicationsAndSupplementsSegementView.addTarget(self, action: #selector(medicationAndSupplementSegmentValueChanged(_:)), for: .valueChanged)
            
            medicationsAndSupplementsSegementView.addProperties(fontSize: FONT_SIZE_NORMAL)
            medicationsAndSupplementsSegementView.setHeight(constant: SEGMENTCONTROL_HEIGHT)
            
            medicationsAndSupplementsSegementView.selectedSegmentIndex = 0
            medicationsAndSupplementsSegementView.setCenterY()
            medicationsAndSupplementsSegementView.setSafeAreaLeft(offset: X_SPACE)
            medicationsAndSupplementsSegementView.setSafeAreaRight(offset: -X_SPACE)
        }
        
        self.customTableView.delegate = self
        self.customTableView.dataSource = self
        customTableView.separatorStyle = .none
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(MedicationTableViewCell.self, forCellReuseIdentifier: "MedicationTableViewCell")
        customTableView.register(SupplementTableViewCell.self, forCellReuseIdentifier: "SupplementTableViewCell")
        customTableView.rowHeight = UITableView.automaticDimension
        customTableView.estimatedRowHeight = 400
           
        self.charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.v2Delegate = self
        self.setFilteredBy(filter: .Active)
    }
       
    private func createBottomView(){
        
        let bottomView = UIView()
        
        let filteredByLabel = UILabel()
        filteredByLabel.text = getString(key: "com.charmphr.prescriptions.FilteredBy.title")
        filteredByLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        bottomView.addSubview(filteredByLabel)
        
        let filteredByValueLabel = UILabel()
        filteredByValueLabel.text = ""
        filteredByValueLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        filteredByValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
        filteredByValueLabel.tag = FILTERED_BY_LABEL_TAG
        bottomView.addSubview(filteredByValueLabel)
        
        self.bottomCustomView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.bottomCustomView.addSubview(bottomView)
        
        filteredByLabel.setTop(offSet: 6)
        filteredByLabel.setCenterX()
        filteredByLabel.setBottomRelatedToView(offSet: -1, relatedView: filteredByValueLabel,relatedAttribute: .top)
        
        filteredByValueLabel.setCenterX()
        
        bottomView.setTop(offSet: 0)
        bottomView.setLeft(offSet: 0)
        bottomView.setRight(offSet: 0)
        bottomView.setSafeAreaBottom(offset: 0)
        bottomView.addTopBorder()
        
        bottomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterViewClicked)))
        
        self.changeBottomViewHeight(height: 35 + 6 + 6 + 2)
    }
    
    //MARK: - API calls
        
    private func deleteMedication(patientMedication: PatientMedication?, viewTag: Int){
        activityIndicatorView.startAnimating()
        self.charmConnectionHandler?.deleteMedication(patientMedicationId: patientMedication?.patientMedicationId ?? "", identificationKey: "deleteMedication_\(viewTag)")
    }
    
    private func deleteSupplement(patientSupplement: PatientSupplement?, viewTag: Int){
        activityIndicatorView.startAnimating()
        self.charmConnectionHandler?.deleteSupplement(patientSupplementId: patientSupplement?.patientSupplementId ?? "", identificationKey: "deleteSupplement_\(viewTag)")
    }
        
    private func loadSupplement(){
        if refreshControl.isRefreshing != true {
            showActivityIndicator()
        }
        
        charmConnectionHandler?.fetchSupplementList(viewType: selectedFilter == .All ? nil : selectedFilter.rawValue ,identificationKey: "fetchSupplements", patientId: getSelectedPatientId())
    }
        
    private func loadMedication(){
        if refreshControl.isRefreshing != true{
            showActivityIndicator()
        }
        
        charmConnectionHandler?.fetchMedicationList(viewType: selectedFilter == .All ? nil : selectedFilter.rawValue, patientId: getSelectedPatientId(), identificationKey: "fetchMedication")
    }
    
    private func loadRequest()
    {
        if isIndexAllowMedicationOrSupplement()
        {
            if canAllowMedication{
                showRightBarButton(isAdd: isAddMedications)
                loadMedication()
            }
            else if canAllowSupplement{
                showRightBarButton(isAdd: isAddSupplements)
                loadSupplement()
            }
        }
        else if isIndex1AllowSupplement(){
            if canAllowSupplement{
                showRightBarButton(isAdd: isAddSupplements)
                loadSupplement()
            }
        }
        else{
            if canAllowMedication{
                showRightBarButton(isAdd: isAddMedications)
                loadMedication()
            }
            else if canAllowSupplement{
                showRightBarButton(isAdd: isAddSupplements)
                loadSupplement()
            }
        }
    }
    
    //MARK: - action calls
    
    override func noDataViewRetryBtnClicked() {
        loadRequest()
    }
    
    @objc private func onUIRefreshChange(){
        loadRequest()
    }
    
    @objc private func medicationAndSupplementSegmentValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 && medicationSection != nil
        {
            showRightBarButton(isAdd: isAddMedications)

            if arrayOfMedicationPOJO.count != 0
            {
                customTableView.reloadData()
                hideActivityIndicator()
            }
            else{
                loadRequest()
            }
        }else{
            
            showRightBarButton(isAdd: isAddSupplements)

            if  arrayOfSupplementPOJO.count != 0
            {
                customTableView.reloadData()
                hideActivityIndicator()
            }else{
                loadRequest()
            }
        }
    }
       
    func pullToRefeashAction()
    {
        loadRequest()
    }
    
    @objc private func addButtonClicked()
    {
        if (medicationSection == nil || !isAddMedications) || (supplementSection == nil || !isAddSupplements)
        {
            medicationsAndSupplementsSegementView = UISegmentedControl(items: [""])
            
            if (medicationSection != nil && isAddMedications)
            {
                pushAddMedicationVC(isEdit: false)
            }
            else if(supplementSection != nil && isAddSupplements)
            {
                pushAddSupplementVC(isEdit: false)
            }
        }else
        {
            if medicationsAndSupplementsSegementView?.selectedSegmentIndex == 0 && medicationSection != nil && medicationSection?.allowPhrEntry == true && isAddMedications
            {
                pushAddMedicationVC(isEdit: false)
            }else
            {
                pushAddSupplementVC(isEdit: false)
            }
        }
    }
    
//MARK: - Filter related functions
    
    @objc private func filterViewClicked()
    {
        let selectValueViewController = SelectValueViewController()
        selectValueViewController.delegate = self
        selectValueViewController.title = getString(key: "com.charmphr.prescriptions.FilteredBy.title")
        selectValueViewController.arrayOfValueToBeShown  = filterTypeArr
        selectValueViewController.selectedValueIndex = filterTypeArr.firstIndex(of: selectedFilter.rawValue)
        navigationController?.pushViewController(selectValueViewController, animated: true)
    }
    
    private func setFilteredBy(filter : PrescriptionFilterType?)
    {
        if let filter = filter{
            if let unreadCountLabel = self.view.viewWithTag(FILTERED_BY_LABEL_TAG) as? UILabel
            {
                unreadCountLabel.text = filter.rawValue
            }
            
            selectedFilter = filter
        }
        loadRequest()
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        setFilteredBy(filter: PrescriptionFilterType(rawValue: filterTypeArr[selectedRow]))
    }
    
    //MARK: - tableview delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isIndexAllowMedicationOrSupplement()
        {
            if canAllowMedication{
                return medicationArrayCount()
            }
            else{
                return supplmentArrayCount()
            }
        }else if isIndex1AllowSupplement()
        {
            return supplmentArrayCount()
        }
        else{
            if canAllowMedication{
                return medicationArrayCount()
            }
            else{
                return supplmentArrayCount()
            }
        }
    }
          
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
        if isIndexAllowMedicationOrSupplement()
        {
            return tableViewCell(tableView: tableView, at: indexPath)
        }
        else if isIndex1AllowSupplement()
        {
            if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "SupplementTableViewCell") as? SupplementTableViewCell{
                if !arrayOfSupplementPOJO.isEmpty{
                    tableViewCell.delegate = self
                    let supplement = arrayOfSupplementPOJO[indexPath.row]
                    tableViewCell.setTableViewCell(data: supplement)
                    return tableViewCell
                }
            }
        }
        else{
            return tableViewCell(tableView: tableView, at: indexPath)
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if let cell = tableView.cellForRow(at: indexPath) as? MedicationTableViewCell{
            cell.onTableViewDidSelect()
        }
        
        else if let cell = tableView.cellForRow(at: indexPath) as? SupplementTableViewCell{
            cell.onTableViewDidSelect()
        }
    }
      
//MARK: - Delegate functions
    
    func supplementAction(action: PrescriptionAction, supplementPOJO: SupplementPOJO?, viewTag: Int?) {
        if action == .SWIPE_LEFT || action == .SWIPE_RIGHT{
            
            if let swipedEntryViewTag, let supplementEntryView = self.view.viewWithTag(swipedEntryViewTag) as? SupplementEntryView{
                supplementEntryView.swipeRightAction()
            }
            if action == .SWIPE_LEFT{
                swipedEntryViewTag = viewTag
            }
            else{
                swipedEntryViewTag = nil
            }
        }
        else if action == .REFILL, let supplementPOJO{
            let alertController = UIAlertController(title: getString(key: "com.charmphr.medication.ResoneForrefill.title"), message: nil, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = getString(key: "com.charmphr.medication.resone.Placeholder")
            }
            
            let refillAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.medication.Refill.title"), style: .default, handler: { (UIAlertAction) in
                
                if let textField = alertController.textFields?[0]
                {
                    if !textField.text.isNilOrBlank()
                    {
                        
                        self.view.isUserInteractionEnabled = false
                        self.activityIndicatorView.startAnimating()
                        
                        supplementPOJO.patientSupplement?.reasonForRefill = textField.text
                        self.charmConnectionHandler?.postRefillMedications(json: JsonBuilder.formRefillSupplementObj(supplementPOJO: supplementPOJO), identificationKey: "supplementRefillReq")
                    }
                }
            })
            
            let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .default, handler: { (UIAlertAction) in
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(refillAction)
            
            self.navigationController?.present(alertController, animated: true)
        }
        else if action == .DID_SELECT{
            editSupplementPOJOSelected = supplementPOJO
            if editSupplementPOJOSelected?.patientSupplement?.isAddedByPatient ?? false{
                pushAddSupplementVC(isEdit: true)
            }
        }
        else if action == .DELETE, let viewTag = viewTag, let supplementPOJO{
            
            let patientSupplement = supplementPOJO.patientSupplement
            if patientSupplement?.isReminderPresent == true{
                CharmUtil.createOkAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.prescriptions.reminderAlert.delete.supplement")) {
                    self.deleteSupplement(patientSupplement: patientSupplement, viewTag: viewTag)
                }
            }
            else{
                deleteSupplement(patientSupplement: patientSupplement, viewTag: viewTag)
            }
        }
    }
    
    //MARK: Medication entry delegate

    func medicationAction(action: PrescriptionAction, medicationPOJO: MedicationPOJO?, viewTag: Int?) {
        if action == .SWIPE_LEFT || action == .SWIPE_RIGHT{
            
            if let swipedEntryViewTag, let medicationEntryView = self.view.viewWithTag(swipedEntryViewTag) as? MedicationEntryView{
                medicationEntryView.swipeRightAction()
            }
            if action == .SWIPE_LEFT{
                swipedEntryViewTag = viewTag
            }
            else{
                swipedEntryViewTag = nil
            }
        }
        else if action == .REFILL, let medicationPOJO{
            let alertController = UIAlertController(title: getString(key: "com.charmphr.medication.ResoneForrefill.title"), message: nil, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = getString(key: "com.charmphr.medication.resone.Placeholder")
            }
            
            let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .default, handler: { (UIAlertAction) in
                
            })
            let refillAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.medication.Refill.title"), style: .default, handler: { (UIAlertAction) in
                
                if let textField = alertController.textFields?[0]
                {
                    if textField.text != nil
                    {
                        medicationPOJO.patientMedication?.reasonForRefill = textField.text
                        self.view.isUserInteractionEnabled = false
                        self.activityIndicatorView.startAnimating()
                        self.charmConnectionHandler?.postRefillMedications(json: JsonBuilder.convertPatientMedicationsToJson(medicationPOJO: medicationPOJO), identificationKey: "medicationRefillReq")
                    }
                }
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(refillAction)
            
            self.navigationController?.present(alertController, animated: true)
        }
        else if action == .DID_SELECT{
            editMedicationPOJOSelected = medicationPOJO
            if editMedicationPOJOSelected?.patientMedication?.addedByPatient ?? false{
                pushAddMedicationVC(isEdit: true)
            }
        }
        else if action == .DELETE, let viewTag = viewTag, let medicationPOJO{
            
            let patientMedication = medicationPOJO.patientMedication
            if patientMedication?.isReminderPresent == true{
                CharmUtil.createOkAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.prescriptions.reminderAlert.delete.medication")) {
                    self.deleteMedication(patientMedication: patientMedication, viewTag: viewTag)
                }
            }
            else{
                deleteMedication(patientMedication: patientMedication, viewTag: viewTag)
            }
        }
    }
      
    func beginUpdates() {
        customTableView.beginUpdates()
    }
    
    func endUpdates() {
        customTableView.endUpdates()
    }
    
    //MARK: Medication item delegate
//    func reloadData(at indexPath: IndexPath) {
//        UIView.performWithoutAnimation {
//            self.customTableView.beginUpdates()
//            self.customTableView.reloadRows(at: [indexPath], with: .none)
//            self.customTableView.endUpdates()
//        }
//    }
    
//MARK: - charmconnectionHandler delegate methods
    
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "medicationRefillReq"
        {
            self.view.isUserInteractionEnabled = true
            activityIndicatorView.stopAnimating()
            debugPrintLog(jsonObject)
            CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.medication.refill.success"), seconds: 2)
        }
        else if identificationKey == "supplementRefillReq"{
            
            self.view.isUserInteractionEnabled = true
            activityIndicatorView.stopAnimating()
            debugPrintLog(jsonObject)
            CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.supplements.refill.success"), seconds: 2)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "medicationRefillReq" || identificationKey == "supplementRefillReq"
        {
            self.view.isUserInteractionEnabled = true
            activityIndicatorView.stopAnimating()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchSupplements" {
            if let supplementPOJOList = response as? [SupplementPOJO] {
                
                hideActivityIndicator()
                arrayOfSupplementPOJO = PatientDataHandler.groupSupplement(supplementArr: supplementPOJOList)
                customTableView.reloadData()
            }
        }
        else if identificationKey == "fetchMedication"{
            if let medicationList = response as? [MedicationPOJO] {
                hideActivityIndicator()
                arrayOfMedicationPOJO = PatientDataHandler.groupMedication(medicationArr: medicationList)
                customTableView.reloadData()
            }
        }
        else if identificationKey.hasPrefix("deleteSupplement")
        {
            hideActivityIndicator()
            
            if let viewTag = identificationKey.components(separatedBy: "_").last?.toIntOrNil(), let supplementEntryView = self.view.viewWithTag(viewTag) as? SupplementEntryView{
                
                if let supplementPOJO = supplementEntryView.supplementPOJO{
                    PatientDataHandler.deleteSupplementPOJO(supplementPOJO: supplementPOJO)
                    
                    if let index = arrayOfSupplementPOJO.firstIndex(where: { obj in
                        return obj.supplementId == supplementPOJO.supplement?.supplementId
                    }){
                        let supplementGroup = arrayOfSupplementPOJO[index]
                        if supplementGroup.supplementArr.count == 1{
                            
                            arrayOfSupplementPOJO.remove(at: index)
                            removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: index, section: 0)])
                        }
                        else{
                            if let subIndex = supplementGroup.supplementArr.firstIndex(where: { obj in
                                return obj.patientSupplement?.patientSupplementId == supplementPOJO.patientSupplement?.patientSupplementId
                            }){
                                customTableView.beginUpdates()
                                supplementGroup.supplementArr.remove(at: subIndex)
                                supplementEntryView.removeFromSuperview()
                                customTableView.endUpdates()
                                customTableView.reloadData()
                            }
                        }
                    }
                }
                
                if let resp = response as? [String: Any]{
                    CharmUtil.showToast(controller: self, message: resp.getString("message"), seconds: 2)
                }
            }
        }
        else if identificationKey.hasPrefix("deleteMedication"){
            hideActivityIndicator()
            if let viewTag = identificationKey.components(separatedBy: "_").last?.toIntOrNil(), let medicationEntryView = self.view.viewWithTag(viewTag) as? MedicationEntryView{
                
                if let medicationPOJO = medicationEntryView.medicationPOJO{
                    PatientDataHandler.deleteMedicationPOJO(medicationPOJO: medicationPOJO)
                    
                    if let index = arrayOfMedicationPOJO.firstIndex(where: { obj in
                        return obj.medicationId == medicationPOJO.medication?.medicationId
                    }){
                        let medicationgroup = arrayOfMedicationPOJO[index]
                        if medicationgroup.medicationArr.count == 1{
                            
                            arrayOfMedicationPOJO.remove(at: index)
                            removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: index, section: 0)])
                        }
                        else{
                            if let subIndex = medicationgroup.medicationArr.firstIndex(where: { obj in
                                return obj.patientMedication?.patientMedicationId == medicationPOJO.patientMedication?.patientMedicationId
                            }){
                                customTableView.beginUpdates()
                                medicationgroup.medicationArr.remove(at: subIndex)
                                medicationEntryView.removeFromSuperview()
                                customTableView.endUpdates()
                                customTableView.reloadData()
                            }
                        }
                    }
                }
                
                if let resp = response as? [String: Any]{
                    CharmUtil.showToast(controller: self, message: resp.getString("message"), seconds: 2)
                }
                AppDataHandler.sharedInstance().refreshMedication = true
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey.contains("fetchMedication") || identificationKey.contains("fetchSupplements")
        {
            customTableView.reloadData()
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        
        self.hideActivityIndicator()
    }
    
//MARK: - AddVCDelegate function
    
    func addViewControllerDataAdded(message: String?) {
        if let message = message{
            CharmUtil.showToast(controller: self, message: message, seconds: 2)
        }
        
        if medicationsAndSupplementsSegementView?.selectedSegmentIndex == 0 && (isAddMedications || isAddSupplements || isEditMedication || isEditSupplement)
        {
            addViewArray()
        }else if medicationsAndSupplementsSegementView?.selectedSegmentIndex == 1 && isAddSupplements
        {
            arrayOfSupplementPOJO = []
        }
        else{
            addViewArray()
        }
        loadRequest()
    }
    
//MARK: - AddReminderAlertDelegate function
    
    func showAddReminderAlert(transformModel: AddReminderTransformModel){
        CharmUtil.createYesAndNoAlertWith(title: "\(getString(key: "com.charmphr.prescription.addReminder.alert.title"))\(transformModel.type ?? "")", msg: nil) {
            let addReminderVC = AddReminderViewController()
            addReminderVC.delegate = self
            addReminderVC.addReminderTransformModel = transformModel
            addReminderVC.isFromPrescription = true
            self.navigationController?.pushViewController(addReminderVC, animated: true)
        }
    }
    
//MARK: - AddReminderDelegate functions
    
    func reminderAdded(msg: String) {
        CharmUtil.showToast(controller: self, message: msg, seconds: 2)
        ReminderHandler.sharedInstance.fetchReminderList()
        loadRequest()
    }
    
// MARK: - Optimize Functions

    private func isIndexAllowMedicationOrSupplement() -> Bool{
        return (medicationsAndSupplementsSegementView?.selectedSegmentIndex == 0 && (canAllowMedication || canAllowSupplement) && (medicationSection != nil || supplementSection != nil))
    }
    
    private func isIndex1AllowSupplement() -> Bool{
        return (medicationsAndSupplementsSegementView?.selectedSegmentIndex == 1 && canAllowSupplement && supplementSection != nil)
    }

    private func isIndex0EditMedicationOrSupplement() -> Bool{
        return (medicationsAndSupplementsSegementView?.selectedSegmentIndex == 0 && (isEditMedication || isEditSupplement) && (medicationSection != nil || supplementSection != nil))
    }
    
    private func isIndex1EditSupplement() -> Bool{
        return (medicationsAndSupplementsSegementView?.selectedSegmentIndex == 1 && isEditSupplement && supplementSection != nil)
    }

    private func isIndex0DeleteMedicationOrSupplement() -> Bool{
        return (medicationsAndSupplementsSegementView?.selectedSegmentIndex == 0 && (isDeleteMedication || isDeleteSupplement) && (medicationSection != nil || supplementSection != nil))
    }
    
    private func isIndex1DeleteSupplement() -> Bool{
        return (medicationsAndSupplementsSegementView?.selectedSegmentIndex == 1 && isDeleteSupplement && supplementSection != nil)
    }
    
    private func medicationArrayCount() -> Int{

        if arrayOfMedicationPOJO.count == 0
        {
            if !AppConfig.sharedInstance.isCustomBrandApp
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.prescriptions.nomedications.title"))")
            }else
            {
                bottomImageView.isHidden = true
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
        }
        else
        {
            bottomImageView.image = #imageLiteral(resourceName: "Medication_HP_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfMedicationPOJO.count
    }
    
    private func supplmentArrayCount() -> Int{

        if arrayOfSupplementPOJO.count == 0
        {
            if !AppConfig.sharedInstance.isCustomBrandApp
            {
                bottomImageView.image = nil
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.prescriptions.nosupplements.title"))")
            }else
            {
                bottomImageView.isHidden = true
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
        }
        else
        {
            bottomImageView.image = #imageLiteral(resourceName: "Medication_HP_BG")
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfSupplementPOJO.count
    }
       
    private func addViewArray(){
        if isAddMedications || isEditMedication{
            arrayOfMedicationPOJO = []
        }
        else if isAddSupplements || isEditSupplement{
            arrayOfSupplementPOJO = []
        }
    }
    
    private func tableViewCell(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell{
        
        var cell: UITableViewCell?
        if canAllowMedication{
            if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "MedicationTableViewCell") as? MedicationTableViewCell{
                if !arrayOfMedicationPOJO.isEmpty{
                    tableViewCell.delegate = self
                    let medication = arrayOfMedicationPOJO[indexPath.row]
                    tableViewCell.setTableViewCell(data: medication, indexPath: indexPath)
                    cell = tableViewCell
                }
            }
        }else{
            if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "SupplementTableViewCell") as? SupplementTableViewCell{
                if !arrayOfSupplementPOJO.isEmpty{
                    tableViewCell.delegate = self
                    let supplement = arrayOfSupplementPOJO[indexPath.row]
                    tableViewCell.setTableViewCell(data: supplement)
                    cell = tableViewCell
                }
            }
        }
        return cell ?? UITableViewCell()
    }
    
    private func pushAddMedicationVC(isEdit: Bool){
        let vc = AddMedicationViewController()
        vc.delegate = self
        vc.addReminderAlertDelegate = self
        if isEdit{
            vc.editMedicationPOJO = editMedicationPOJOSelected
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushAddSupplementVC(isEdit: Bool){
        let vc = AddSupplementViewController()
        vc.delegate = self
        vc.addReminderAlertDelegate = self
        if isEdit{
            vc.editSupplementPOJO = editSupplementPOJOSelected
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showRightBarButton(isAdd: Bool){
        var barBtnItems: [UIBarButtonItem] = []
        if !AppConfig.sharedInstance.isCustomBrandApp && isAdd{
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
            barBtnItems = [add]
        }
        let filter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(filterViewClicked))
        barBtnItems.append(filter)
        self.navigationItem.rightBarButtonItems = barBtnItems
    }
}

enum PrescriptionFilterType : String
{
    case All = "All"
    case Active = "Active"
    case Inactive = "Inactive"
}


