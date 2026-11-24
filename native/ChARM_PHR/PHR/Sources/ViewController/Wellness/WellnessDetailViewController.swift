//
//  UsefulInfoViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 03/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class WellnessDetailViewController: CustomViewControllerWithTableView , UITableViewDataSource , CharmConnectionHandlerDelegate, AddViewControllerDelegate{
    
    var charmConnectionHandler : CharmConnectionHandler!
    
    var metricHistoryArr : Array<MetricHistory> = []
    
    var patientVitalArr : Array<PatientVitals> = []
    
    var metricButton : UIButton?
    var tracker : Tracker?
    var metric : Metric?
    
    var selectedType: String? = nil
    
    let fetchTrackerDetailidentificationKey = "fetchTrackerDetail"
    let fetchMetricDetailidentificationKey = "fetchMetricDetail"
    
    let isAddWellness = RbacUtil.checkPrivilege(privilege: .ADD_WELLNESS)
    let isDeleteWellness = RbacUtil.checkPrivilege(privilege: .DELETE_WELLNESS)
    
    lazy var healthKitService = HealthKitService.shared
    private lazy var healthKitAdd = UIBarButtonItem(image: UIImage(named: "health-kit-add")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onHealthKitAddBtnPressed))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLargeTitle(enable: false)
        
        if(tracker != nil && metric == nil)
        {
            self.navigationItem.title = tracker?.trackerName
        }
        else if (tracker != nil && metric != nil){
            self.navigationItem.title = metric?.metricName
        }
        
        var rightBtnItems: [UIBarButtonItem] = []
        
       
        
        if isAddWellness{
            rightBtnItems.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)))
        }
        
        if let hkPatient = CharmUtil.getHealthKitPreference() {
            if hkPatient.patientId == getSelectedPatientId() {
                if HealthMetric.getHealthMetric(from: tracker?.trackerName ?? "") != nil && tracker?.isDefaultTracker == true {
                    if !rightBtnItems.isEmpty {
                        rightBtnItems.append(UIBarButtonItem.fixedSpace(8))
                    }
                    
                    rightBtnItems.append(healthKitAdd)
                }
                else if HealthMetric.getHealthMetric(from: metric?.metricName ?? "") != nil &&  metric?.isDefaultMetric == true {
                    if !rightBtnItems.isEmpty {
                        rightBtnItems.append(UIBarButtonItem.fixedSpace(8))
                    }
                    rightBtnItems.append(healthKitAdd)
                }
            }
        }
        
      
        
        if !rightBtnItems.isEmpty {
            self.navigationItem.setRightBarButtonItems(rightBtnItems, animated: true)
        }
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        
        fetchVitalDetails()
        
        customTableView.removeConstraint(attribute: .left)
        customTableView.removeConstraint(attribute: .right)
        customTableView.setHorizontal(offSet: X_SPACE)
        customTableView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        customTableView.layer.borderWidth = 0.5
        customTableView.addCornerRadius(.SMALL)
        
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        customTableView.register(UINib(nibName: "KeyAndDateLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "KeyAndDateLabelTableViewCell")
        
        customTableView.addInfiniteScrolling{
            self.fetchVitalDetails(infinityScroll: true)
        }
        
    }
    
    //MARK: - action
    
    @objc private func addButtonClicked()
    {
        
        let vc = AddWellnessViewController()
        vc.delegate = self
        if(tracker != nil && metric == nil){
            vc.tracker = tracker
        }
        else if(metric != nil){
            vc.metric = metric
            vc.tracker = tracker
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
 
    @objc private func onHealthKitAddBtnPressed(){
        if let types = HealthMetric.getHealthMetric(from: tracker?.trackerName ?? "") , tracker?.isDefaultTracker == true {
            //checkAndStartHKSync(types: [.bloodPressureSystolic , .bloodPressureDiastolic])
            requestPermission(types: types)
        }
        else if let types = HealthMetric.getHealthMetric(from: metric?.metricName ?? "") , metric?.isDefaultMetric == true {
            //checkAndStartHKSync(types: [.bloodPressureSystolic , .bloodPressureDiastolic])
            requestPermission(types: types)
        }
    }
    
    private func requestPermission(types:[HealthMetric]){
        
        showActivityIndicatorFront()
        HealthKitService.shared.requestAuthorization(types: types, completion: { success , failure in
            
            DispatchQueue.main.async {
                
                self.hideActivityIndicator()
                
                if(success){
                    self.pushToHKManualVC(type: types)
                }
                else{
                    if let failure {
                        CharmUtil.createOkayAlertWith(error: failure , errorDescription: failure.localizedDescription)
                    }
                }
            }
            
        })
    }
    
    private func pushToHKManualVC(type: [HealthMetric]){
        
        let hkManual = HKManualAddViewController()
        hkManual.tracker = tracker
        hkManual.metric = metric
        hkManual.typesList = type
        hkManual.delegate = self
        
        self.navigationController?.pushViewController(hkManual, animated: true)
    }
    
    @objc private func showMetricOptionList(){
        showBloodSugarOptions(arr: patientVitalArr)
    }
    
    // MARK: - connection establishment methods
    private func fetchVitalDetails(infinityScroll: Bool = false)
    {
        if charmConnectionHandler == nil
        {
            charmConnectionHandler = CharmConnectionHandler(delegate: self)
        }
        
        if !infinityScroll {
            showActivityIndicator()
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        
        if(tracker != nil && metric == nil){
            charmConnectionHandler.fetchVitalTrackerDetailList(identificationKey:fetchTrackerDetailidentificationKey, trackerId: tracker!.trackerId!)
        }
        else if(metric != nil){
            charmConnectionHandler.fetchVitalMetricDetailList(identificationKey: fetchMetricDetailidentificationKey, metricId:metric?.metricId ?? "")
        }
    }
    
    // MARK: - tableviewdelegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if metricHistoryArr.isEmpty
        {
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key:"com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.wellnessmetric.noWellness.message"))")
        }
        return metricHistoryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "KeyAndDateLabelTableViewCell") as! KeyAndDateLabelTableViewCell
        
        let metricHistory = metricHistoryArr[indexPath.row]
        if(tracker?.trackerType == .temperature){
            let floatVal = metricHistory.trackedValue?.toFloatOrNil()
            var metricValstr = ""
            if(floatVal != nil){
                metricValstr = String(format: "%.2f", floatVal!)
            }
            let str = (metricValstr) + "°" + (metricHistory.trackedValueUnit ?? "" )
            tableviewCell.keyLabel.text = str
        }
        else{
            tableviewCell.keyLabel.text = "\(metricHistory.trackedValue ?? "") \(metricHistory.trackedValueUnit ?? "" )"
        }
        if(metricHistory.dateOfEntry != nil){
            tableviewCell.dateLabel.text = CharmUtil.getDisplayDateString(date: metricHistory.dateOfEntry!)
        }
        tableviewCell.arrowImageView.isHidden = true
        tableviewCell.selectionStyle = .none
        return tableviewCell
    }
    
    // MARK: - charm connection handler delegate methods
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == fetchTrackerDetailidentificationKey
        {
            customTableView.infiniteScrollingView.stopAnimating()
            if let outputArr = jsonObject["output_string"] as? Dictionary<String,Any>?
            {
                let patientVitalArr = ParsingHelper.formPatientVitalsDetailsList(outputDict: outputArr!)
                self.patientVitalArr = patientVitalArr
                
                if(tracker?.trackerType == .bloodPressure && tracker?.isDefaultTracker == true)
                {
                    showBloodPressureList()
                }
                else{
                    //for multiple metric case
                    if(self.patientVitalArr.count > 1){
                        addTitleView()
                    }
                    
                    if self.patientVitalArr.isEmpty
                    {
                        self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.wellnessmetric.noWellness.message"))")
                    }else
                    {
                        self.noDataBackGroundView.hideSubView(bool: true)
                        
                        if selectedType.isNilOrBlank(){
                            showSelectedMetricHistoryList( patientVital: patientVitalArr.first!)
                        }
                        else{
                            
                            if let patVital = self.patientVitalArr.first(where: {patVitals in
                                patVitals.metric?.metricName?.lowercased() == selectedType?.lowercased()
                            }){
                                showSelectedMetricHistoryList( patientVital: patVital)
                            }
                            else{
                                showSelectedMetricHistoryList( patientVital: patientVitalArr.first!)
                            }
                        }
                    }
                }
            }
        }
        else if identificationKey == fetchMetricDetailidentificationKey{
            customTableView.infiniteScrollingView.stopAnimating()
            if let outputDict = jsonObject["output_string"] as? Dictionary<String,Any>?
            {
                let patientVital = ParsingHelper.formPatientVital(dict: outputDict!,metricId: metric?.metricId ?? "")
                if(patientVital.metricHistoryArr?.count == 0)
                {
                    self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.wellnessmetric.noWellness.message"))")
                }
                else
                {
                    self.noDataBackGroundView.hideSubView(bool: true)
                    showSelectedMetricHistoryList( patientVital: patientVital)
                }
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        customTableView.infiniteScrollingView.stopAnimating()
        self.hideActivityIndicator()
        self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
    }
    
    // MARK: - other methods
    override func noDataViewRetryBtnClicked() {
        fetchVitalDetails()
    }
    
    private func addTitleView()
    {
        self.metricButton = UIButton()
        guard let metricButton else { return }
        
        metricButton.configuration = nil
        metricButton.setProperties(titleStrKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: THEME_COLOR, bgcolor: WHITE_COLOR)
        metricButton.setImage(UIImage(named: "Arrow_Down_Small_Blue") ,for: .normal)
        metricButton.setImage(UIImage(named: "Arrow_Down_Small_Blue") ,for: .highlighted)
        
        metricButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        metricButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        metricButton.semanticContentAttribute = .forceRightToLeft
        metricButton.addPillCornerRadiusAndShadow(height: 36)
        metricButton.addTarget(self, action: #selector(showMetricOptionList), for: .touchUpInside)
        
        self.titleCustomView.addSubview(metricButton)
        metricButton.setLeft(offSet: X_SPACE)
        metricButton.setTop(offSet: 12)
        metricButton.setBottom(offSet: -8)
        metricButton.setHeight(constant: 36)
        
        changeCustomTitleViewHeight(height: HEADER_HEIGHT)
    }
    
    private func showSelectedMetricHistoryList(patientVital : PatientVitals)
    {
        self.metricHistoryArr = patientVital.metricHistoryArr ?? []
        if let metricButton{
            metricButton.setTitle(patientVital.metric?.metricName, for: .normal)
            metricButton.removeConstraint(attribute: .width)
            metricButton.setWidth(constant: metricButton.sizeThatFits(CGSize(width: 500, height: 36)).width + 30)
        }
        customTableView.reloadData()
    }
    
    private func showBloodPressureList()
    {
        if(self.patientVitalArr.count == 2){
            let systolicArr = self.patientVitalArr[0].metricHistoryArr ?? []
            let diastolicArr = self.patientVitalArr[1].metricHistoryArr ?? []
            if(systolicArr.isEmpty && diastolicArr.isEmpty){
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.wellnessmetric.noWellness.message"))")
            }
            else{
                if systolicArr.count >= diastolicArr.count{
                    for systolicMetric in systolicArr
                    {
                        let diastolicMetric = diastolicArr.first { diastolicMetricObj in
                            return diastolicMetricObj.dateOfEntry == systolicMetric.dateOfEntry
                        }
                        systolicMetric.trackedValue = (systolicMetric.trackedValue ?? "") + " / " + (diastolicMetric?.trackedValue ?? "")
                    }
                    self.metricHistoryArr = systolicArr
                    customTableView.reloadData()
                    self.noDataBackGroundView.hideSubView(bool: true)
                }
                else if diastolicArr.count >= systolicArr.count{
                    for diastolicMetric in diastolicArr
                    {
                        let systolicMetric = systolicArr.first { systolicMetricObj in
                            return systolicMetricObj.dateOfEntry == diastolicMetric.dateOfEntry
                        }
                        diastolicMetric.trackedValue = (systolicMetric?.trackedValue ?? "") + " / " + (diastolicMetric.trackedValue ?? "")
                    }
                    self.metricHistoryArr = diastolicArr
                    customTableView.reloadData()
                    self.noDataBackGroundView.hideSubView(bool: true)
                }
            }
        }
        else{
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.wellnessmetric.noWellness.message"))")
        }
    }
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        fetchVitalDetails()
    }
    
    private func showBloodSugarOptions(arr: [PatientVitals]) {
        
        let vc = BottomSheetFloatingController()
        vc.modalPresentationStyle = .overFullScreen
        vc.items = arr
        vc.selectedRow = arr.firstIndex(where: { patVital in
            return metricButton?.titleLabel?.text == patVital.metric?.metricName
        }) ?? 0
        vc.titleText = self.navigationItem.title ?? ""
        vc.onSelect = { patVitals in
            self.showSelectedMetricHistoryList(patientVital: patVitals)
        }
        present(vc, animated: false)
    }
}

//MARK: - BottomSheetFloatingController

fileprivate class BottomSheetFloatingController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var titleText: String = ""
    var items: [PatientVitals] = []
    var selectedRow: Int = 0
    var onSelect: ((PatientVitals) -> Void)?
    private let buttonSize: CGFloat = 30
    
    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        v.alpha = 0
        return v
    }()

    private let sheetView: UIView = {
        let v = UIView()
        v.addCornerRadius(.LARGE)
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.12
        v.layer.shadowRadius = 12
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: FONT_SIZE_EIGHTEEN, Weight: .semibold)
        lbl.textAlignment = .left
        return lbl
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "Close_Gray_Small"), for: .normal)
        btn.setPadding(vertical: 6, horizontal: 8)
        btn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SUPPORT_SEGMENT_BG_COLOR)
        return btn
    }()
    
    private let horizontalSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        return v
    }()

    private let tableView = UITableView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateIn()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(dimView)
        view.addSubview(sheetView)

        dimView.frame = view.bounds
        
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        let bottomInset = window?.safeAreaInsets.bottom ?? 0
        let height: CGFloat = CGFloat(50 + items.count * 55) + bottomInset
        let width: CGFloat = view.frame.width

        sheetView.frame = CGRect(x: 0, y: view.frame.height, width: width, height: min(height, 420))

        titleLabel.text = titleText
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(closeButton)
        sheetView.addSubview(horizontalSeparator)
        sheetView.addSubview(tableView)

        titleLabel.setLeft(offSet: X_SPACE)
        titleLabel.setTop(offSet: X_SPACE)
        titleLabel.wrapWidth(maxWidth: width - 100)
        
        closeButton.setRight(offSet: -X_SPACE)
        closeButton.setCenterY(view: titleLabel)
        closeButton.setWidth(constant: buttonSize)
        closeButton.setHeight(constant: buttonSize)
        
        horizontalSeparator.setLeft(offSet: 0)
        horizontalSeparator.setRight(offSet: 0)
        horizontalSeparator.setTopRelatedToView(offSet: X_SPACE, relatedView: titleLabel, relatedAttribute: .bottom)
        horizontalSeparator.setHeight(constant: 0.5)
        
        tableView.setLeft(offSet: 0)
        tableView.setRight(offSet: 0)
        tableView.setTopRelatedToView(offSet: 10, relatedView: horizontalSeparator, relatedAttribute: .bottom)
        tableView.setBottom(offSet: 0)
        
        closeButton.layer.cornerRadius = buttonSize / 2
        closeButton.addTarget(self, action: #selector(closeSheet), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(closeSheet))
        dimView.addGestureRecognizer(tap)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(closeSheet))
        swipeDown.direction = .down
        sheetView.addGestureRecognizer(swipeDown)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    private func animateIn() {
        UIView.animate(withDuration: 0.25) { self.dimView.alpha = 1 }
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: [.curveEaseOut]) {
            self.sheetView.frame.origin.y = self.view.frame.height - self.sheetView.frame.height
        }
    }

    @objc private func closeSheet() {
        UIView.animate(withDuration: 0.3) {
            self.dimView.alpha = 0
            self.sheetView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let btnTitle = items[indexPath.row].metric?.metricName ?? ""
        let uiButton = UIButton()
        uiButton.setImage(UIImage(named: "RadioBtnSelected"), for: .selected)
        uiButton.setImage(UIImage(named: "RadioBtnUnselected"), for: .normal)
        uiButton.setProperties(titleStrKey: btnTitle, fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        uiButton.isSelected = selectedRow == indexPath.row
        uiButton.titleLabel?.textAlignment = .left
        uiButton.setInsets(imageTitlePadding: 8)
        
        let uiView = UIView()
        uiView.backgroundColor = .clear
        
        cell.contentView.addSubview(uiButton)
        cell.contentView.addSubview(uiView)
        
        uiButton.setLeft(offSet: X_SPACE)
        uiButton.setTop(offSet: 12)
        uiButton.setBottom(offSet: -12)
        uiButton.setHeight(constant: BTN_SIZE_24)
        
        uiView.setLeftRelatedToView(offSet: 0, relatedView: uiButton, relatedAttribute: .left)
        uiView.setRight(offSet: -X_SPACE)
        uiView.setHeight(constant: BTN_SIZE_24)
        uiView.setCenterY(view: uiButton)
        
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let previousButton = getButton(index: selectedRow)
        previousButton?.isSelected = false
        
        selectedRow = indexPath.row
        let currentButton = getButton(index: selectedRow)
        currentButton?.isSelected = true
        
        onSelect?(items[indexPath.row])
        closeSheet()
    }
    
    private func getButton(index: Int) -> UIButton? {
        
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
        if let cell = cell, let uiButton = cell.subviews.first(where: { $0 is UIButton }) as? UIButton {
            return uiButton
        }
        return nil
    }
}
