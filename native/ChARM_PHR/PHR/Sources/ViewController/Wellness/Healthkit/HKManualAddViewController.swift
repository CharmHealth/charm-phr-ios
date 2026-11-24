//
//  HKManualAddViewController.swift
//  phr
//
//  Created by Raghul D on 17/10/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation


class HKManualAddViewController : UIViewController , SelectValueViewControllerDelagate, CharmConnectionV2HandlerDelegate, HKVitalViewDelegate , HKDetailVCDelegate , WellnessMetricViewControllerDelegate , HKSyncConfirmVCDelegate{
    private lazy var manualAddView = HKManualAddView(delegate: self)
    
    private var dateRangeValues:[HKDateRange] = [.oneWeek, .lastWeek , .twoWeeks , .oneMonth , .twoMonths, .sixMonths , .custom]
    private var dateRangeSelectedIndex:Int? = nil
    
    var metricValueList:[MetricValue] = []
    
    var tracker:Tracker? = nil
    var metric:Metric? = nil
    var typesList:[HealthMetric] = []

    var trackerList:[Tracker]? = nil
    
    var selectedRange:HKDateRange? = nil
    
    private var fromDate: Date? = nil
    private var toDate: Date? = nil
    weak var delegate: AddViewControllerDelegate?
    private var selectedVitalUnit:String? = nil

    private lazy var syncButton = UIBarButtonItem(title: getString(key: "com.charmphr.wellness.healthkit.syncall.label"), style: .plain, target: self, action: #selector(onSyncButtonClicked))
    
    private lazy var charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
    
    private var hasToRefresh = false

    override func viewDidLoad() {
        self.view = manualAddView
        self.navigationItem.title = getString(key: "com.charmphr.wellness.healthkit.manualsync.title")
        self.navigationItem.rightBarButtonItem = syncButton
        
        
        if let tracker {
            if tracker.trackerType == .bloodPressure || tracker.trackerType == .general {
                hasToRefresh = true
            }
        }
        else if let trackerList {
            if trackerList.contains(where: { $0.trackerType == .bloodPressure || $0.trackerType == .general }) {
                hasToRefresh = true
            }
        }
        
        if hasToRefresh {
            if VitalUtil.getPatientVitalUnit() == nil {
                fetchVitalUnit()
            }
        }
    }
    
    
    func pushToDateRangeSelectVC() {
        
        let selectValueVC = SelectValueViewController()
        selectValueVC.title = getString(key: "com.charmphr.wellness.healthkit.daterange.label")
        
        selectValueVC.arrayOfValueToBeShown = dateRangeValues.map({ dateRange in
            return dateRange.getLocalisedString()
        })
        selectValueVC.selectedValueIndex = dateRangeSelectedIndex
        selectValueVC.delegate = self
        self.navigationController?.pushViewController(selectValueVC, animated: true)
    }
    //MARK: - Select Valye delegate
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        dateRangeSelectedIndex = selectedRow
        
        if let selectedDateRange  = dateRangeValues.getElement(at: selectedRow) {
            onDateRangeChanged(selectedDateRange: selectedDateRange)
        }
    }
    
    func onDateRangeChanged(selectedDateRange: HKDateRange) {
        manualAddView.setDateRange(dateRange: selectedDateRange)
        self.selectedRange = selectedDateRange
        
        if selectedDateRange == .custom {
            self.manualAddView.removeAllVitalViews()
        }
        else{
            let dateRange = selectedDateRange.getDateRange()
            debugPrintLog(dateRange)
            fetchData(dateRange: dateRange)
        }
    }
    
    func fetchData(dateRange: (Date, Date)) {
        self.manualAddView.removeAllVitalViews()
        metricValueList.removeAll()
        
        let hasBP = typesList.contains(.bloodPressureSystolic) && typesList.contains(.bloodPressureDiastolic)
    
        var totalCount = typesList.count
        if hasBP {
            totalCount -= 1
        }
        
        var respCount = 0
        var hasData = false
        
        typesList.forEach { type in
            if !hasBP || (hasBP && (type != .bloodPressureSystolic && type != .bloodPressureDiastolic)){
                HealthKitService.shared.fetchHealthKitData(for: type , from: dateRange.0, to: dateRange.1, selectedVitalUnit: selectedVitalUnit, completion: { [weak self] modelList in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        debugPrintLog("Response Came: \(modelList)")
                        if !modelList.isEmpty {
                            hasData = true
                            self.insertView(type: type , modelList: modelList)
                        }

                        respCount += 1
                        if respCount == totalCount {
                            if !hasData {
                                self.manualAddView.showNoDataView()
                            }
                        }
                    }
                })
            }
        }

        if hasBP {
            HealthKitService.shared.fetchBloodPressureData(from: dateRange.0, to: dateRange.1, completion: { [weak self] bpModelList in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    debugPrintLog("Response Came: \(bpModelList)")
                    if !bpModelList.isEmpty {
                        
                        var tempBpModelList:[BPHistory] = []
                        var systolList: [MetricHistory] = []
                        var diastolList: [MetricHistory] = []
                        
                        bpModelList.forEach{ bpModel in
                            if bpModel.systolic != nil  && bpModel.diastolic != nil {
                                tempBpModelList.append(bpModel)
                            }
                            else {
                                if let systolic = bpModel.systolic {
                                    systolList.append(systolic)
                                }
                                if let diastolic = bpModel.diastolic {
                                    diastolList.append(diastolic)
                                }
                            }
                        }

                        
                        
                        

                        hasData = true
                        
                        if !tempBpModelList.isEmpty {
                            self.insertView(type: .bloodPressureSystolic , bpModelList: bpModelList)
                        }
                        if !systolList.isEmpty {
                            self.insertView(type: .bloodPressureSystolic , modelList: systolList)
                        }
                        if !diastolList.isEmpty {
                            self.insertView(type: .bloodPressureDiastolic , modelList: diastolList)
                        }
                        
                    }
                    respCount += 1
                    if respCount == totalCount {
                        if !hasData {
                            self.manualAddView.showNoDataView()
                        }
                    }
                }
            })
        }
    }
    
    private func insertView(type: HealthMetric, modelList:[MetricHistory]? = nil , bpModelList:[BPHistory]? = nil){
        if let tracker = getTracker(type: type){
            if let modelList {
                
                if type == .bloodGlucose {
                    var tempMetricValueList:[MetricValue] = []
                    modelList.forEach({model in
                        let metricValue = MetricValue()
                        metricValue.metricHistory = model
                        metricValue.tracker = tracker
                        metricValue.type = type
                        if let metric = getMetric(type: type, glucoseMetric: model.notes) {
                            metricValue.metric = metric
                        }
                        tempMetricValueList.append(metricValue)
                    })
                    self.metricValueList.append(contentsOf: tempMetricValueList)
                    self.manualAddView.insertEntryView(modelList: tempMetricValueList , headingLabel: tracker.trackerName ?? "")
                }
                else{
                    
                    if let metric = getMetric(type: type) {
                        var tempMetricValueList:[MetricValue] = []

                        modelList.forEach({model in
                            let metricValue = MetricValue()
                            metricValue.metricHistory = model
                            metricValue.tracker = tracker
                            metricValue.metric = metric
                            metricValue.type = type
                            tempMetricValueList.append(metricValue)
                        })
                        self.metricValueList.append(contentsOf: tempMetricValueList)
                        self.manualAddView.insertEntryView(modelList: tempMetricValueList ,headingLabel: metric.metricName ?? "")
                    }
                }
            }
            else if let bpModelList {
                if let systol = getMetric(type: .bloodPressureSystolic) ,let diastol = getMetric(type: .bloodPressureDiastolic)  {
                    bpModelList.forEach({bpModel in
                        
                        if let systolic = bpModel.systolic {
                            let metricValue = MetricValue()
                            metricValue.metricHistory = systolic
                            metricValue.tracker = tracker
                            metricValue.metric = systol
                            self.metricValueList.append(metricValue)
                        }
                        
                        if let diastolic = bpModel.diastolic {
                            let metricValue = MetricValue()
                            metricValue.metricHistory = diastolic
                            metricValue.tracker = tracker
                            metricValue.metric = diastol
                            self.metricValueList.append(metricValue)
                        }
                        
                        
                    })
                    self.manualAddView.insertBPView(bpModelList: bpModelList)
                }
            }
        }
        
    }
    
    private func getMetric(type: HealthMetric , glucoseMetric: String? = nil) -> Metric? {
        
        var metricName: String = type.getMetricName()
        
        if type == .bloodGlucose {
            metricName =  glucoseMetric ?? ""
        }
    
        if metricName.isNotBlank() {
            if let tracker {
                return tracker.metricList?.first(where: { $0.metricName == metricName  && $0.isDefaultMetric == true})
            }
            else {
                let trackerName: String = type.getTrackerName()
                return trackerList?.first(where: { $0.trackerName == trackerName  && $0.isDefaultTracker == true})?.metricList?.first(where: { $0.metricName == metricName  && $0.isDefaultMetric == true})
            }
        }
        
        return nil
    }
    
    private func getTracker(type: HealthMetric) -> Tracker? {
        
        
        if let tracker {
            return tracker
        }
        
        let trackerName: String = type.getTrackerName()
    
        if trackerName.isNotBlank() {
            return self.trackerList?.first(where: { $0.trackerName == trackerName  && $0.isDefaultTracker == true})
        }
        return nil
    }

    func onShowMoreClicked() {
        if let fromDate , let toDate {
            if fromDate.isBefore(date: toDate) || fromDate.isSameDate(date: toDate) {
                fetchData(dateRange: (fromDate , toDate))
            }
            else{
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.wellness.healthkit.date.invalidPeriod"), msg: nil)
            }
            
        }
        else {
            if fromDate == nil {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.wellness.healthkit.date.fromDate.error"), msg: nil)
            }
            else if toDate == nil {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.wellness.healthkit.date.toDate.error"), msg: nil)
            }
        }
    }
    
    func onFromDateChanged(fromDate: Date?) {
        self.fromDate = fromDate
    }
    
    func onToDateChanged(toDate: Date?) {
        self.toDate = toDate
    }
    
    private func removeAndUpdateSyncedValues(syncedValues: [MetricValue]){
        let syncedValueIds = syncedValues.map({$0.metricHistory?.uniqueId})
        metricValueList.removeAll(where: { (value) -> Bool in
            return syncedValueIds.contains(value.metricHistory?.uniqueId) && value.metricHistory?.uniqueId != nil
        })
        manualAddView.removeAndUpdateSyncedValues(syncedValues: syncedValues)
    }

    
    func showActivityIndicator()
    {
        self.manualAddView.showActivityIndicator()
        syncButton.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        self.manualAddView.hideActivityIndicator()
        syncButton.isEnabled = true
    }
    
    
    func showVitalMetricVC(countryKey: String? = nil){
        
        let wellnessVC = WellnessMetricViewController()
        
        wellnessVC.countrykey = !countryKey.isNilOrBlank() ? countryKey : nil
        wellnessVC.delegate = self
        wellnessVC.unitChoosed = selectedVitalUnit
        wellnessVC.modalTransitionStyle = .crossDissolve
        wellnessVC.modalPresentationStyle = .overFullScreen
        present(wellnessVC, animated: true)
    }
    
    @objc private func onSyncButtonClicked(){
        checkAndAddVitals()
    }
    
    private func checkAndAddVitals(){
        
        if selectedRange == nil {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.wellness.healthkit.alert.daterange"))
            return
        }
        
        if !metricValueList.isEmpty {
            
            let hpConfirmVC = HKSyncConfirmViewController()
            hpConfirmVC.delegate = self
            if selectedRange == .custom {
                if let fromDate , let toDate {
                    hpConfirmVC.dateRange = CharmUtil.formattedRange(from: fromDate, to: toDate)
                }
            }
            else {
                if let dateRange = selectedRange?.getDateRange() {
                    hpConfirmVC.dateRange = CharmUtil.formattedRange(from: dateRange.0, to: dateRange.1)
                }
            }
            hpConfirmVC.recordCount = metricValueList.count
            hpConfirmVC.vitalName = getVitalName()
            
            
            hpConfirmVC.modalPresentationStyle = .overFullScreen
            hpConfirmVC.modalTransitionStyle = .crossDissolve
            self.present(hpConfirmVC, animated: true)

            
            
            
           
            
//            CharmUtil.createOkayWithCancelAlertWith(title: getString(key: "com.charmphr.wellness.healthkit.add.heading")
//                                                    , msg: getString(key: "com.charmphr.wellness.healthkit.add.msg"), okClicked: { [weak self] in
//                guard let self = self else { return }
//                if let selectedVitalUnit = self.selectedVitalUnit {
//                    self.saveVitalUnit(unitSystem: selectedVitalUnit)
//                }
//                else{
//                    self.addVitals()
//                }
//            } , okString: "com.charmphr.wellness.healthkit.syncnow.title")
            
            
        }
        else{
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.wellness.healthkit.alert.nodata"))
        }
    }

    
    private func addVitals(){
        showActivityIndicator()
        charmConnectionHandler.addVitalsUsingHK(vitalList: metricValueList, identificationKey: "AddVitals")
    }
    
    private func fetchVitalUnit() {
        showActivityIndicator()
        self.charmConnectionHandler.fetchVitalUnit(identificationKey: "vitalUnit")
    }
    
    private func fetchDemographics() {
        showActivityIndicator()
        charmConnectionHandler.fetchDemographics(identificationKey: "fetchDemographics")
    }
    
    private func saveVitalUnit(unitSystem: String) {
        showActivityIndicator()
        charmConnectionHandler.postVitalUnit(unitSystem: unitSystem, identificationKey: "saveVitalUnit")
    }
    
    
    //MARK: - Charm connection handler delegate
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "AddVitals" {
            if let message = response as? String {
                hideActivityIndicator()
                if hasToRefresh {
                    AppDataHandler.sharedInstance().refreshVitals = true
                }
                navigationController?.popViewController(animated: true)
                delegate?.addViewControllerDataAdded(message: message)
            }
            else if let respArr = response as? [MetricValue]{
                removeAndUpdateSyncedValues(syncedValues: respArr)
            }
        }
        else if identificationKey == "vitalUnit" {
            if response is String {
                hideActivityIndicator()
            }
            else {
                //show
                
                let country = getSelectedPatient().postalAddress?.country ?? ""
                
                debugPrintLog("country -> \(country)")
                if country.isNotBlank() {
                    hideActivityIndicator()
                    showVitalMetricVC(countryKey: country)
                    manualAddView.insertVitalUnitView()
                }
                else{
                    fetchDemographics()
                }
            }
        }
        else if identificationKey == "fetchDemographics" {
            hideActivityIndicator()
            if let patient = response as? Patient {
                let country = patient.postalAddress?.country ?? ""
                
                showVitalMetricVC(countryKey: country)
                manualAddView.insertVitalUnitView()
            }
        }
        else if identificationKey == "saveVitalUnit"{
            addVitals()
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        if identificationKey == "AddVitals" {
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: { [weak self] in
                self?.addVitals()
            })
        }
        else if identificationKey == "vitalUnit" {
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: { [weak self] in
                self?.fetchVitalUnit()
            }, cancelClicked: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
        }
        else if identificationKey == "fetchDemographics" {
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: { [weak self] in
                self?.fetchDemographics()
            }, cancelClicked: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
        }
        else if identificationKey == "saveVitalUnit"{
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: { [weak self] in
                self?.checkAndAddVitals()
            })
        }
    }
    
    //MARK: - Vital view delegate
    func onVitalViewMoreClicked(modelList: [MetricValue], heading: String) {
        let wellnessDetail = HKDetailViewController()
        wellnessDetail.metricValueList = modelList
        wellnessDetail.headingStr = heading
        wellnessDetail.delegate = self
        if selectedRange == .custom {
            if let fromDate , let toDate {
                wellnessDetail.dateRange = CharmUtil.formattedRange(from: fromDate, to: toDate)
            }
        }
        else {
            if let dateRange = selectedRange?.getDateRange() {
                wellnessDetail.dateRange = CharmUtil.formattedRange(from: dateRange.0, to: dateRange.1)
            }
        }
        navigationController?.pushViewController(wellnessDetail, animated: true)
    }

    func onBPViewMoreClicked(bpModelList: [BPHistory]) {

        let wellnessDetail = HKDetailViewController()
        wellnessDetail.bpModelList = bpModelList
        wellnessDetail.metricValueList = metricValueList.filter({$0.type == nil}) // type is not filled only for BP
        wellnessDetail.delegate = self
        if selectedRange == .custom {
            if let fromDate , let toDate {
                wellnessDetail.dateRange = CharmUtil.formattedRange(from: fromDate, to: toDate)
            }
        }
        else {
            if let dateRange = selectedRange?.getDateRange() {
                wellnessDetail.dateRange = CharmUtil.formattedRange(from: dateRange.0, to: dateRange.1)
            }
        }
        navigationController?.pushViewController(wellnessDetail, animated: true)
    }
    
    func onVitalViewRemoveClicked(model: MetricValue) {
       // CharmUtil.
        
        createRemoveAlert { [weak self] in
            self?.removeAndUpdateSyncedValues(syncedValues: [model])
        }
    }
    
    func onBPViewRemoveClicked(bpModel: BPHistory) {
        
        createRemoveAlert { [weak self] in
            guard let self = self else {return}
            
            var syncedValueIds:[UUID?] = []
            if let systol = bpModel.systolic?.uniqueId {
                syncedValueIds.append(systol)
            }
            if let diastol = bpModel.diastolic?.uniqueId {
                syncedValueIds.append(diastol)
            }
            
            let syncedValues =  metricValueList.filter({ (value) -> Bool in
                return syncedValueIds.contains(value.metricHistory?.uniqueId) && value.metricHistory?.uniqueId != nil
            })
            
            metricValueList.removeAll(where: { (value) -> Bool in
                return syncedValueIds.contains(value.metricHistory?.uniqueId) && value.metricHistory?.uniqueId != nil
            })
            self.manualAddView.removeAndUpdateSyncedValues(syncedValues: syncedValues)
        }
        
    }
    
    
    private func createRemoveAlert(removeClicked: @escaping () -> Void){
        let alertVC = UIAlertController(title: title, message: getString(key: "com.charmphr.wellness.healthkit.alert.remove"), preferredStyle: .actionSheet)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let deleteAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.wellness.healthkit.remove"), style: .destructive, handler: { (UIAlertAction) in
            removeClicked()
        })
        alertVC.addAction(deleteAction)
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        alertVC.show()
    }
    
    
    func onDetailSynced(modelList: [MetricValue], successMsg: String?) {
        removeAndUpdateSyncedValues(syncedValues: modelList)
        
        
        if let successMsg {
            CharmUtil.showToast(controller: self, message: successMsg, seconds: 2)
        }
        
        if metricValueList.isEmpty {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    //MARK: Wellness Metric delegate
    func onWellnessUnitSelected(unit: String) {
        selectedVitalUnit = unit
        manualAddView.setVitalUnit(unitSystem: unit)
        
        if let selectedRange {
            if selectedRange == .custom {
                if let fromDate  , let toDate {
                    if !metricValueList.isEmpty {
                        fetchData(dateRange: (fromDate , toDate))
                    }
                }
            }
            else{
                onDateRangeChanged(selectedDateRange: selectedRange)
            }
        }
    }
    
    //MARK: OnSyncConfirmed
    
    func onSyncConfirmed(){
        
        if let selectedVitalUnit = self.selectedVitalUnit {
            self.saveVitalUnit(unitSystem: selectedVitalUnit)
        }
        else{
            self.addVitals()
        }
    }
    
    func getVitalName() -> String {
        
        if let tracker {
            if tracker.isDefaultTracker && tracker.trackerType == .general {
                return "Height & Weight"
            }
            else {
                return tracker.trackerName ?? ""
            }
        }
        else if let metric {
            return metric.metricName ?? ""
        }
        
        return "Health Records"
    }
}

enum HKDateRange : String{
    case oneWeek = "com.charmphr.wellness.healthkit.1week.label"
    case lastWeek = "com.charmphr.wellness.healthkit.lastweek.label"
    case twoWeeks = "com.charmphr.wellness.healthkit.2week.label"
    case oneMonth = "com.charmphr.wellness.healthkit.1month.label"
    case twoMonths = "com.charmphr.wellness.healthkit.2months.label"
    case sixMonths = "com.charmphr.wellness.healthkit.6months.label"
    case custom = "com.charmphr.wellness.healthkit.custom.label"

    func getLocalisedString() -> String {
        return getString(key: self.rawValue)
    }
    
    func getDateRange() -> (Date , Date) {
        let toDate = Date()
        let fromDate : Date
        if self == .oneWeek {
            fromDate = toDate.minus(days: 7)
        }
        else if self == .lastWeek {
            fromDate = toDate.startOfWeek
        }
        else if self == .twoWeeks {
            fromDate = toDate.minus(days: 14)
        }
        else if self == .oneMonth {
            fromDate = toDate.minus(days: 30)
        }
        else if self == .twoMonths{
            fromDate = toDate.minus(days: 60)
        }
        else {
            fromDate = toDate.minus(months: 6)
        }
        
        return (fromDate.startOfDay , toDate.endOfDay)
    }
}
