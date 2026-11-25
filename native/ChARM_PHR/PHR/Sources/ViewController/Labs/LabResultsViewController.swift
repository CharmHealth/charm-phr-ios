//
//  LabResultsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 12/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import QuickLook

class LabResultsViewController: UIViewController , CharmConnectionHandlerDelegate, CharmConnectionHandlerDataDelegate
{
    
    let TABLEVIEW_X_SPACE = 10
            
    let medicalRecordEntryTableView = MDAutoGrowingTableView()
    let containerView = UIView()
    let activityIndicatorView  = UIActivityIndicatorView()
    
    var arrayOfSelectedSections : Array<Int> = []
    
    var medicalRecordGroup : MedicalRecordGroup?
    var charmConnectionHandler : CharmConnectionHandler?
    var previewItem : URL?
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.setLargeTitle(enable: false)
        self.navigationItem.title = medicalRecordGroup?.labName
        createScrollView()
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        fetchLabResults()
    }
    
    func fetchLabResults(){
        charmConnectionHandler?.fetchLabResultsDetails(patientId: Patient.selectedPatientInstance?.patientId ?? "", medicalRecordGroup: medicalRecordGroup, identificationKey: "fetchLabResultsDetails")
    }
    
    func createScrollView()
    {
        let containerScrollView = UIScrollView()
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerScrollView)
        // Safe-area edges keep the cards clear of the iOS 27.1 landscape side bar / Dynamic Island.
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerScrollView]|", options: [], metrics: nil, views: ["containerScrollView":containerScrollView]))
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerScrollView.addSubview(containerView)
        
        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setTop(offSet: 0)
        
        // Content width follows the visible (safe-area) width, so it fits on fold/unfold and rotation and only scrolls vertically.
        containerView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor).isActive = true
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .gray
        self.view.addSubview(activityIndicatorView)
        
        self.view.addConstraint(NSLayoutConstraint.init(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func createSubViews()
    {
        var previosview:UIView? = nil

        
        let labDetailView = UIStackView()
        
        labDetailView.axis = .vertical
        labDetailView.distribution = .fill
        labDetailView.spacing = 0
        

        var previousDetailView: UIView? = nil
        
        let reviewerName = medicalRecordGroup?.reviewerName ?? ""
        
        if reviewerName.isNotBlank() {
            
            let reviewerView = AddModuleKeyAndValueView()
            reviewerView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: false)
            reviewerView.keyLabel.text = getString(key: "com.charmphr.labOrders.reviewer.label")
            reviewerView.valueLabel.text = reviewerName
            labDetailView.addArrangedSubview(reviewerView)
            previousDetailView = reviewerView
        }
        
        let intepretationView = AddModuleKeyAndValueView()
        intepretationView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: false)
        intepretationView.keyLabel.text = getString(key: "com.charmphr.labsResults.interpretation")
        if medicalRecordGroup?.isAbnormalResult() == true {
            intepretationView.valueLabel.text = ABNORMAL
            intepretationView.valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: abnormalTxtColor)
        }
        else{
            intepretationView.valueLabel.text = NORMAL
            intepretationView.valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: normalTxtColor)
        }
        
        labDetailView.addArrangedSubview(intepretationView)
        previousDetailView?.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
        previousDetailView = intepretationView
        
        let resultStatus = medicalRecordGroup?.reportStatus ?? ""
        
        if resultStatus.isNotBlank() {
            
            let resultStatusView = AddModuleKeyAndValueView()
            resultStatusView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: false)
            resultStatusView.keyLabel.text = getString(key: "com.charmphr.labOrders.resultstatus.label")
            resultStatusView.valueLabel.text = resultStatus
            labDetailView.addArrangedSubview(resultStatusView)
            previousDetailView?.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            previousDetailView = resultStatusView
        }
        
        
        let dateStr = medicalRecordGroup?.date?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) ?? ""
        
        if dateStr.isNotBlank() {
            
            let dateView = AddModuleKeyAndValueView()
            dateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: false)
            dateView.keyLabel.text = getString(key: "com.charmphr.date.keyField")
            dateView.valueLabel.text = dateStr
            labDetailView.addArrangedSubview(dateView)
            previousDetailView?.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            previousDetailView = dateView
        }
        
        let messageToPatient = medicalRecordGroup?.comments ?? ""
        
        if messageToPatient.isNotBlank() {
            
            let physicianAdviceView = UIView()
            let physicianAdviceLabel = UILabel()
            physicianAdviceLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            physicianAdviceLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
            physicianAdviceLabel.text = getString(key: "com.charmphr.labsResult.physicianadvice")
            physicianAdviceView.addSubview(physicianAdviceLabel)
            
            let physicianAdviceValueLabel = UILabel()
            physicianAdviceValueLabel.text = messageToPatient
            physicianAdviceValueLabel.numberOfLines = 0
            physicianAdviceValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            physicianAdviceView.addSubview(physicianAdviceValueLabel)
            
            physicianAdviceLabel.setTop(offSet: 8)
            physicianAdviceLabel.setLeft(offSet: 8)
            physicianAdviceLabel.setRight(offSet: -8)
            
            physicianAdviceValueLabel.setLeft(offSet: 8)
            physicianAdviceValueLabel.setRight(offSet: -8)
            physicianAdviceValueLabel.setTopRelatedToView(offSet: 4, relatedView: physicianAdviceLabel, relatedAttribute: .bottom)
            physicianAdviceValueLabel.setBottom(offSet: -8)
            
            labDetailView.addArrangedSubview(physicianAdviceView)
            previousDetailView?.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            previousDetailView = physicianAdviceView
        }
        
        containerView.addSubview(labDetailView)
        
        labDetailView.setLeft(offSet: X_SPACE)
        labDetailView.setRight(offSet: -X_SPACE)
        labDetailView.setTop(offSet: 16)
        
        previosview = labDetailView
        
        labDetailView.layer.borderWidth = BORDER_WIDTH
        labDetailView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        labDetailView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        labDetailView.addCornerRadius(.SMALL)
        labDetailView.layer.masksToBounds = true

        
//        if medicalRecordGroup?.isAddedByPatient == false {
//            
//            let practiceDetailView = getPracticeDetailView(string: Patient.selectedPatientInstance?.getPracticeWith(practiceId: medicalRecordGroup?.practiceId ?? "") != nil ? Patient.selectedPatientInstance?.getPracticeWith(practiceId: medicalRecordGroup?.practiceId ?? "")?.facilitiesList ?? "-"  : "-")
//            containerView.addSubview(practiceDetailView)
//            
//            practiceDetailView.setLeft(offSet: X_SPACE)
//            practiceDetailView.setRight(offSet: -X_SPACE)
//            practiceDetailView.setTop(offSet: 16)
//            
//            practiceDetailView.layer.borderWidth = BORDER_WIDTH
//            practiceDetailView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
//            
//            previosview = practiceDetailView
//        }
        
        if let medicalRecordGroup = medicalRecordGroup{
            for medicalRecordEntry in medicalRecordGroup.medicalRecordEntryList
            {
                let medicalRecordEntryContainerView = UIView()
                
                medicalRecordEntryContainerView.layer.borderWidth = BORDER_WIDTH
                medicalRecordEntryContainerView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
                medicalRecordEntryContainerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
                medicalRecordEntryContainerView.addCornerRadius(.SMALL)
                
                let nameLabel = UILabel()
                nameLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
                nameLabel.text = medicalRecordEntry.medicalRecords?.medicalRecordName
                nameLabel.numberOfLines = 0
                medicalRecordEntryContainerView.addSubview(nameLabel)
                
                
                
                let singleEntryView = getSingleLablist(medicalRecordEntry: medicalRecordEntry)
                singleEntryView.addTopBorder(color: UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR), borderWidth: 0.5)
                medicalRecordEntryContainerView.addSubview(singleEntryView)
                
                nameLabel.setTopRelatedToView(offSet: 8, relatedView: medicalRecordEntryContainerView, relatedAttribute: .top)
                nameLabel.setLeft(offSet: 8)
                nameLabel.setRight(offSet: -8)
                nameLabel.setBottomRelatedToView(offSet: -8, relatedView: singleEntryView, relatedAttribute: .top)
                
               
                
                singleEntryView.setLeft(offSet: 0)
                singleEntryView.setRight(offSet: 0)
                singleEntryView.setBottom(offSet: 0)
                
                containerView.addSubview(medicalRecordEntryContainerView)
                
                if let previosview = previosview {
                    medicalRecordEntryContainerView.setTopRelatedToView(offSet: 11, relatedView: previosview, relatedAttribute: .bottom)
                }
                else{
                    medicalRecordEntryContainerView.setTop(offSet: 16)
                }
                
                medicalRecordEntryContainerView.setLeft(offSet: X_SPACE)
                medicalRecordEntryContainerView.setRight(offSet: -X_SPACE)
                
                previosview = medicalRecordEntryContainerView
            }
            
            let physicianAdviceView = getPhysicianAdviceView()
            containerView.addSubview(physicianAdviceView)
            
            physicianAdviceView.layer.borderWidth = BORDER_WIDTH
            physicianAdviceView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
            
            previosview?.setBottomRelatedToView(offSet: -10, relatedView: physicianAdviceView, relatedAttribute: .top)
            
            physicianAdviceView.setBottom(offSet: -Y_SPACE)
            physicianAdviceView.setLeft(offSet: X_SPACE)
            physicianAdviceView.setRight(offSet: -X_SPACE)
        }
        
    }
    
    func getPracticeDetailView(string:String) -> UIView
    {
        let practiceDetailView = UIView()
        practiceDetailView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        practiceDetailView.addCornerRadius(.SMALL)
        
        let headerLabel = UILabel()
        headerLabel.text = getString(key: "com.charmphr.common.PracticeDetails.title")
        headerLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        headerLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        practiceDetailView.addSubview(headerLabel)
        
        let practiceDetailLabel = UILabel()
        practiceDetailLabel.text = string
        practiceDetailLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        practiceDetailLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        practiceDetailLabel.numberOfLines = 0
        practiceDetailView.addSubview(practiceDetailLabel)
        
        headerLabel.setTop(offSet: 4.5)
        headerLabel.setLeft(offSet: 8)
        headerLabel.setRight(offSet: -8)
        
        practiceDetailLabel.setTopRelatedToView(offSet: 6, relatedView: headerLabel, relatedAttribute: .bottom)
        practiceDetailLabel.setLeft(offSet: 8)
        practiceDetailLabel.setRight(offSet: 4)
        practiceDetailLabel.setBottom(offSet: -6)
        
        return practiceDetailView
    }
    
    func getSingleLablist(medicalRecordEntry : MedicalRecordEntry) -> UIView
    {
        let medicalRecordMapContainerView = UIView()
    
        var previousView = medicalRecordMapContainerView
        
        for medicalRecordMap in medicalRecordEntry.medicalRecordMapList
        {
            let medicalRecordMapView = LabResultView()
            
            medicalRecordMapView.nameLabel.text = medicalRecordMap.medicalRecordParams?.parameterName
            medicalRecordMapView.valueLabel.text = "\(medicalRecordMap.medicalRecordValues?.recordvalue ?? "-") \(medicalRecordMap.medicalRecordParams?.recordunit ?? "")"
            
            if medicalRecordMap.medicalRecordValues?.range != nil
            {
                medicalRecordMapView.referenceValueLabel.text = medicalRecordMap.medicalRecordValues?.range?.replacingOccurrences(of: "\t", with: "", options: NSString.CompareOptions.literal, range: nil)
                medicalRecordMapView.referenceValueLabel.text = medicalRecordMapView.referenceValueLabel.text?.replacingOccurrences(of: "\n", with: " ", options: NSString.CompareOptions.literal, range: nil)
            }else
            {
                var range = "\(medicalRecordMap.medicalRecordValues?.referenceMin ?? "")-\(medicalRecordMap.medicalRecordValues?.referenceMax ?? "")"
                if range != "-"
                {
                    range.append(" \(medicalRecordMap.medicalRecordParams?.recordunit ?? "")")
                }
                medicalRecordMapView.referenceValueLabel.text = range
            }
            
            medicalRecordMapView.interpretationValueLabel.text = medicalRecordMap.medicalRecordValues?.interpretation
            medicalRecordMapView.interpretationValueLabel.setWidth(constant: medicalRecordMapView.interpretationValueLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width)
            medicalRecordMapView.interpretationValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
            
            medicalRecordMapContainerView.addSubview(medicalRecordMapView)
            
            if previousView === medicalRecordMapContainerView
            {
                medicalRecordMapView.setTopRelatedToView(offSet: 0, relatedView: previousView, relatedAttribute: .top)
            }else
            {
                medicalRecordMapView.setTopRelatedToView(offSet: 0, relatedView: previousView, relatedAttribute: .bottom)
            }
            
            medicalRecordMapView.setLeft(offSet: 0)
            medicalRecordMapView.setRight(offSet: 0)
            medicalRecordMapView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)
            
            if medicalRecordEntry.medicalRecordMapList.last === medicalRecordMap
            {
                medicalRecordMapView.setBottom(offSet: 0)
            }
        
            previousView = medicalRecordMapView
        }
        
        medicalRecordMapContainerView.backgroundColor = .clear
        
        return medicalRecordMapContainerView
    }
    
    func getPhysicianAdviceView() -> UIView
    {
        let physicianAdviceView = UIView()
        physicianAdviceView.addCornerRadius(.SMALL)
        physicianAdviceView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        
        let viewFullReportBtn = UIButton()
        viewFullReportBtn.setTitle(getString(key: "com.charmphr.labsResults.viewfullreport"), for: .normal)
        viewFullReportBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for: .normal)
        viewFullReportBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        viewFullReportBtn.addTarget(self, action: #selector(viewFullReportClicked), for: .touchUpInside)
        viewFullReportBtn.contentEdgeInsets = UIEdgeInsets(top: 0.00, left: 0.00, bottom: 0.00, right: 0.00)
        viewFullReportBtn.titleEdgeInsets = UIEdgeInsets(top: 0.00, left: 0.00, bottom: 0.00, right: 0.00)
        physicianAdviceView.addSubview(viewFullReportBtn)
    
            viewFullReportBtn.setTop(offSet: 12)
            viewFullReportBtn.setBottom(offSet: -12)
            viewFullReportBtn.setLeft(offSet: 8)
            viewFullReportBtn.setWidth(constant: viewFullReportBtn.sizeThatFits(CGSize(width: 1000, height: 1000)).width)
        
        
        return physicianAdviceView
    }
   
    @objc func viewFullReportClicked()
    {
        charmConnectionHandler?.dataDelegate = self
        activityIndicatorView.startAnimating()
        charmConnectionHandler?.downloadLabResults(patientId: Patient.selectedPatientInstance?.patientId ?? "",medicalRecordGroup: medicalRecordGroup, identificationKey: "downloadPDF_\("\(medicalRecordGroup?.labName ?? "lab")_result.pdf")")
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchLabResultsDetails"
        {
            if let medicalRecordGroup = medicalRecordGroup, let outputString = jsonObject.getAsJsonObject("output_string"){
                self.medicalRecordGroup = ParsingHelper.updateMedicalRecordGroupWithDictionary(dict: outputString, medicalRecordGroup: medicalRecordGroup)
            }
            
            createSubViews()
            
            activityIndicatorView.stopAnimating()
        }
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {

        if identificationKey.hasPrefix("downloadPDF")
        {
            activityIndicatorView.stopAnimating()
            
            let pdfImageVC = PDFImageViewController(fileName: "\(medicalRecordGroup?.labName ?? "lab")_result.pdf", data: data)
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        activityIndicatorView.stopAnimating()
        if identificationKey == "fetchLabResultsDetails"{
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.fetchLabResults()
            } cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
}
