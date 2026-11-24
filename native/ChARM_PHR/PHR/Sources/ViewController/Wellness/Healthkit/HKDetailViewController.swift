//
//  HKDetailViewController.swift
//  phr
//
//  Created by Raghul D on 25/06/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import Foundation

class HKDetailViewController: AddDataUIViewController , CharmConnectionV2HandlerDelegate , HKSyncConfirmVCDelegate{
  
    
    var metricValueList:[MetricValue] = []
    var bpModelList: [BPHistory]? = nil
    var headingStr: String? = nil
    var dateRange: String = ""
    private var isSyncSuccess = false
    var syncedMetricValueList:[MetricValue] = []

    weak var delegate : HKDetailVCDelegate?
    private lazy var detailView = HKDetailView(delegate: self)

    private lazy var syncButton = UIBarButtonItem(title: getString(key: "com.charmphr.wellness.healthkit.syncall.label"), style: .plain, target: self, action: #selector(onSyncButtonClicked))
    
    private lazy var charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)

    override func viewDidLoad() {
        self.view = detailView
        
        self.navigationItem.title = headingStr
        self.navigationItem.rightBarButtonItem = syncButton
    }
    
    override func onBackClick() {
        super.onBackClick()
        self.navigationController?.popViewController(animated: true)
        var successMsg: String? = nil
        
        if metricValueList.isEmpty && isSyncSuccess {
            successMsg = getString(key: "com.charmphr.wellness.healthkit.success.msg", with: [headingStr ?? ""])
        }
        delegate?.onDetailSynced(modelList: syncedMetricValueList, successMsg: successMsg)
    }
    
    func showActivityIndicator()
    {
        self.detailView.showActivityIndicator()
        syncButton.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        self.detailView.hideActivityIndicator()
        syncButton.isEnabled = true
    }
    
    
    @objc private func onSyncButtonClicked(){
        checkAndAddVitals()
    }

    private func checkAndAddVitals(){
        if !metricValueList.isEmpty {
            let hpConfirmVC = HKSyncConfirmViewController()
            hpConfirmVC.delegate = self
            hpConfirmVC.dateRange = dateRange
            hpConfirmVC.recordCount = metricValueList.count
            hpConfirmVC.vitalName = headingStr ?? ""
            hpConfirmVC.modalPresentationStyle = .overFullScreen
            hpConfirmVC.modalTransitionStyle = .crossDissolve
            self.present(hpConfirmVC, animated: true)
        }
        else{
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.wellness.healthkit.alert.nodata"))
        }
    }

    //MARK: OnSyncConfirmed

    func onSyncConfirmed(){
        self.addVitals()
    }

    private func addVitals(){
        showActivityIndicator()
        charmConnectionHandler.addVitalsUsingHK(vitalList: metricValueList, identificationKey: "AddVitals")
    }
    
    //MARK: - Charm connection handler delegate
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "AddVitals" {
            if let message = response as? String {
                hideActivityIndicator()
                syncedMetricValueList.append(contentsOf: metricValueList)
                metricValueList = []
                isSyncSuccess = true
                onBackClick()
            }
            else if let respArr = response as? [MetricValue]{
                removeAndUpdateSyncedValues(syncedValues: respArr)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        if identificationKey == "AddVitals" {
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.addVitals()
            })
        }
    }

    
    private func removeAndUpdateSyncedValues(syncedValues: [MetricValue]){
        syncedMetricValueList.append(contentsOf: syncedValues)
        let syncedValueIds = syncedValues.map({$0.metricHistory?.uniqueId})
        metricValueList.removeAll(where: { (value) -> Bool in
            return syncedValueIds.contains(value.metricHistory?.uniqueId) && value.metricHistory?.uniqueId != nil
        })
        
        if bpModelList != nil {
            let syncedValues = syncedValues.filter({$0.metric?.metricName == wellnessSystolicModelId}).map({$0.metricHistory?.uniqueId})
            
            bpModelList?.removeAll(where: {syncedValues.contains($0.systolic?.uniqueId) && $0.systolic?.uniqueId != nil})
        }
        detailView.reloadData()
    }
    
    func onVitalViewRemoveClicked(model: MetricValue) {
       // CharmUtil.
        
        createRemoveAlert { [weak self] in
            guard let self = self else {return}
            self.removeAndUpdateSyncedValues(syncedValues: [model])
            self.delegate?.onDetailSynced(modelList: syncedMetricValueList, successMsg: nil)
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
            
            if bpModelList != nil {
                let syncedValues = syncedValues.filter({$0.metric?.metricName == wellnessSystolicModelId}).map({$0.metricHistory?.uniqueId})
                
                bpModelList?.removeAll(where: {syncedValues.contains($0.systolic?.uniqueId) && $0.systolic?.uniqueId != nil})
            }
            self.syncedMetricValueList.append(contentsOf: syncedValues)
            self.detailView.reloadData()
            self.delegate?.onDetailSynced(modelList: syncedMetricValueList, successMsg: nil)
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
}

protocol HKDetailVCDelegate: AnyObject {
    func onDetailSynced(modelList:[MetricValue] , successMsg: String?)
}
