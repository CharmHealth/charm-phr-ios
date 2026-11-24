//
//  WellnessViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 06/12/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class WellnessViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, CharmConnectionHandlerDelegate , CharmConnectionV2HandlerDelegate , AddViewControllerDelegate , HKPatientSelectVCDelegate
{
    
    var charmConnectionHandler : CharmConnectionHandler!
    
    var tableView : UITableView!
    
    var vitalsArr : Array<Tracker> = []
    
    var fitnessMetricArray : Array<Metric> = []
    var fitnessTracker : Tracker?
    
    var activityIndicator : UIActivityIndicatorView? = nil
    var healthKitStartView: UIView? = nil
    
    private lazy var healthKitAdd = UIBarButtonItem(image: UIImage(named: "health-kit-add")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onHealthKitAddBtnPressed))
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        self.setLargeTitle(enable: false)
        
        if let hkPatient = CharmUtil.getHealthKitPreference() {
            if hkPatient.patientId == getSelectedPatientId() {
                self.navigationItem.rightBarButtonItem = healthKitAdd
            }
        }
        else{
            healthKitStartView = UIView()
        }
        
        createSubView()
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler.v2Delegate = self
        self.navigationItem.title = getString(key: "com.charmphr.wellness.title")
        fetchVitalTracker()
    }
    
    
    private func fetchVitalTracker(){
        showActivityIndicator()
        charmConnectionHandler.fetchVitalTrackersList(identificationKey: "fetchVitalsTrackersList")
    }
    
    func createSubView()
    {
        if let healthKitStartView {
            self.view.addSubview(healthKitStartView)
            
            healthKitStartView.addShadowAndCornerRadius(.LARGE)
            healthKitStartView.backgroundColor = .white
            
            let bgImg = UIImageView(image: UIImage(named: "health-kit-bg"))
            healthKitStartView.addSubview(bgImg)
            
            let charmIV = UIImageView()
            charmIV.image = UIImage(named: "AppIconForLaunchScreen")
            let healthIV = UIImageView(image: UIImage(named: "health-kit"))
            let indicatorImg = UIImageView(image: UIImage(named: "right-arrow"))
            
            let headingLabel = UILabel()
            let msgLabel = UILabel()
            let startedBtn = UIButton()
            
            healthKitStartView.addSubview(healthIV)
            healthKitStartView.addSubview(charmIV)
            healthKitStartView.addSubview(indicatorImg)
            
            healthKitStartView.addSubview(headingLabel)
            healthKitStartView.addSubview(msgLabel)
            healthKitStartView.addSubview(startedBtn)

            headingLabel.setProperties(textKey: "com.charmphr.wellness.healthkit.started.heading", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)

            msgLabel.setProperties(textKey: "com.charmphr.wellness.healthkit.started.msg", fontsize: FONT_SIZE_SMALL, weight: .regular, fontcolor: 0x595654FF)
            msgLabel.numberOfLines = 0
 
            startedBtn.setProperties(titleStrKey: "com.charmphr.wellness.healthkit.started.btn", fontsize: FONT_SIZE_MEDIUM, weight: .semibold, fontcolor: THEME_COLOR)
            startedBtn.addTarget(self, action: #selector(onGettingStartedClicked), for: .touchUpInside)

            headingLabel.setTop(offSet: X_SPACE)
            headingLabel.setLeft(offSet: X_SPACE)
            
            msgLabel.setTopRelatedToView(offSet: 8, relatedView: headingLabel, relatedAttribute: .bottom)
            msgLabel.setLeft(offSet: X_SPACE)
            msgLabel.setRightRelatedToView(offSet: -X_SPACE, relatedView: healthIV, relatedAttribute: .left)
            
            startedBtn.setTopRelatedToView(offSet: 8, relatedView: msgLabel, relatedAttribute: .bottom)
            startedBtn.setLeft(offSet: X_SPACE)
            
            bgImg.setWidth(constant: 114)
            bgImg.setHeight(constant: 114)
            bgImg.setTop(offSet: 6)
            bgImg.setBottom(offSet: -6)
            bgImg.setRight(offSet: -6)
            
            charmIV.setWidth(constant: 28)
            charmIV.setHeight(constant: 28)
            charmIV.setCenterY()
            charmIV.setRight(offSet: -22)
            
            healthIV.setWidth(constant: 28)
            healthIV.setHeight(constant: 28)
            healthIV.setCenterY()
            healthIV.setRightRelatedToView(offSet: -5, relatedView: indicatorImg, relatedAttribute: .left)

            indicatorImg.setWidth(constant: 15)
            indicatorImg.setHeight(constant: 11)
            indicatorImg.setCenterY()
            indicatorImg.setRightRelatedToView(offSet: -5, relatedView: charmIV, relatedAttribute: .left)
            
            healthKitStartView.setSafeAreaTop(offset: 13)
            healthKitStartView.setHorizontal(offSet: X_SPACE)
        }
        
        tableView = UITableView()
        tableView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ImageValueArrowTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageValueArrowTableViewCell")
        
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tableView)
        
//        tableView.contentInset = UIEdgeInsets(top: TOP_SPACE_FROM_NAVIGATION, left: 0, bottom: Y_SPACE, right: 0 )
        
        tableView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        
       // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics:nil, views: ["tableView":tableView!]))
        
        tableView.setHorizontal(offSet: X_SPACE)
        
        if let healthKitStartView {
            tableView.setTopRelatedToView(offSet: 0, relatedView: healthKitStartView, relatedAttribute: .bottom)
        }
        else{
            tableView.setSafeAreaTop(offset: 0)
        }
        tableView.setSafeAreaBottom(offset: 0)
        
    }
    
    
    //MARK: table view delegate methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      //  let headerView = UIView()
        let headerLabel = UILabel()
        headerLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        headerLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        headerLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUMDARK)
        if(section == 0) //Will always be vitals so handling like this
        {
            headerLabel.text = getString(key: "com.charmphr.wellness.vitals")
        }
        else if(section == 1){
            headerLabel.text = getString(key: "com.charmphr.wellness.others")
        }
    //    headerView.addSubview(headerLabel)
//        headerLabel.setTop(offSet: TOP_SPACE_FROM_NAVIGATION + 2)
//        headerLabel.setBottom(offSet: 11)
//        headerLabel.setLeft(offSet: 0)
        return headerLabel
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            let tracker = vitalsArr[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageValueArrowTableViewCell", for: indexPath) as! ImageValueArrowTableViewCell
            cell.backgroundColor = .clear
            if(tracker.isDefaultTracker && isGeneralVitalTracker(tracker: tracker))
            {
                cell.nameLabel.text = "Height & Weight"
            }
            else{
                cell.nameLabel.text = tracker.trackerName
            }
            let img = getImageForCell(trackerType: tracker.trackerType)
            if(img != nil)
            {
                cell.valueImageView.setInitialsAndImage(initials:"V", image: img)
            }
            else{
                
                if let str = tracker.trackerName?.first {
                    cell.valueImageView.layer.cornerRadius = 16
                    cell.valueImageView.layer.masksToBounds = true
                    cell.valueImageView.setInitialsAndImage(initials:"\(str)", image: nil)
                }
                
            }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageValueArrowTableViewCell", for: indexPath) as! ImageValueArrowTableViewCell
            cell.backgroundColor = .clear
            let metric = fitnessMetricArray[indexPath.row]
            cell.nameLabel.text = metric.metricName
            let img = getImageForMetricName(metricName: metric.metricName)
            if(img != nil)
            {
                cell.valueImageView.setInitialsAndImage(initials:"V", image: img)
            }
            else{
                
                if let str = metric.metricName?.first{
                    cell.valueImageView.layer.cornerRadius = 16
                    cell.valueImageView.layer.masksToBounds = true
                    cell.valueImageView.setInitialsAndImage(initials:"\(str)", image: nil)
                }
            }
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount = 0
        if(!vitalsArr.isEmpty){
            sectionCount = sectionCount+1}
        if(!fitnessMetricArray.isEmpty){
            sectionCount = sectionCount+1
        }
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return vitalsArr.count
        }
        else if section == 1
        {
            return fitnessMetricArray.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56  //horizontaltableviewcell -> size 48 + 4topspace+ 4bottomspace
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vC = WellnessDetailViewController()
        if(indexPath.section == 0){
            let tracker = vitalsArr[indexPath.row]
            vC.tracker = tracker
        }
        else{
            let metric = fitnessMetricArray[indexPath.row]
            vC.metric = metric
            vC.tracker = fitnessTracker
        }
        self.navigationController?.pushViewController(vC, animated: true)
        
        
    }
    
    //MARK: charm connection handler delegate methods
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        hideActivityIndicator()
//        if(identificationKey == "fetchVitalsTrackersList")
//        {
//            let parsingHelper = ParsingHelper()
//            if let outputArr = jsonObject["output_string"] as? Array<Dictionary<String,Any>>?
//            {
//                let trackerArr =  parsingHelper.formVitalTrackerList(trackerArr: outputArr!)
//                parseVitalAndFitnessTracker(trackerArr: trackerArr)
//                tableView.reloadData()
//            }
//        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        hideActivityIndicator()
        if(identificationKey == "fetchVitalsTrackersList")
        {
            if let trackerArr = response as? [Tracker] {
                parseVitalAndFitnessTracker(trackerArr: trackerArr)
                tableView.reloadData()
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
            self.fetchVitalTracker()
        }, cancelClicked: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    //MARK: other methods
    
    func parseVitalAndFitnessTracker(trackerArr : Array<Tracker>){
        
        for tracker in trackerArr{
            if tracker.trackerType == .others && tracker.isDefaultTracker
            {
                if(tracker.metricList != nil){
                    fitnessTracker = tracker
                    fitnessMetricArray = tracker.metricList!
                }
            }
            else
            {
                if(tracker.isDefaultTracker){
                    vitalsArr.append(tracker)
                }
            }
        }
        
    }
    
    func isGeneralVitalTracker(tracker:Tracker) -> Bool
    {
        if (tracker.trackerType == .general && tracker.isDefaultTracker)
        {
            return true
        }
        return false
    }
    
    func getImageForCell(trackerType : TrackerType?) -> UIImage?
    {
        if trackerType == .bloodPressure
        {
            return #imageLiteral(resourceName: "BloodPressure")
        }
        else if trackerType == .pulseRate
        {
            return #imageLiteral(resourceName: "PulseRate")
        }
        else if trackerType == .temperature
        {
            return #imageLiteral(resourceName: "Temperature")
        }
        else if trackerType == .bloodSugar
        {
            return #imageLiteral(resourceName: "BloodSugar")
        }
        
        else if trackerType == .general
        {
            return #imageLiteral(resourceName: "General")
        }
        else if trackerType == .cholesterol
        {
            return #imageLiteral(resourceName: "Cholesterol")
        }
        return nil
    }
    
    func getImageForMetricName(metricName : String?) -> UIImage? {
        if metricName == "Walking"
        {
            return #imageLiteral(resourceName: "Walking")
        }
        else if metricName == "Aerobics"
        {
            return #imageLiteral(resourceName: "Aerobic")
        }
        else if metricName == "Calories burned"
        {
            return #imageLiteral(resourceName: "Calories")
        }
        else if metricName == "Calories consumed" {
            return #imageLiteral(resourceName: "CaloriesGained")
        }
        
        else if metricName == "Cycling"
        {
            return #imageLiteral(resourceName: "Cycling")
        }
        else if metricName == "Running" || metricName == "Jogging"
        {
            return #imageLiteral(resourceName: "Running")
        }
        else if metricName == wellnessSleepModelId
        {
            return #imageLiteral(resourceName: "Sleep")
        }
        else if metricName == "Swimming"
        {
            return #imageLiteral(resourceName: "Swimming")
        }
        else if metricName == "Treadmill"
        {
            return #imageLiteral(resourceName: "Treadmill")
        }
        else if metricName == "Water consumption"
        {
            return #imageLiteral(resourceName: "WaterConsumption")
        }
        else if metricName == wellnessStepModelId {
            return #imageLiteral(resourceName: "DailySteps")
        }
        
        return nil
    }
    
    func showActivityIndicator()
    {
        self.view.isUserInteractionEnabled = false
        if(activityIndicator == nil)
        {
            activityIndicator = UIActivityIndicatorView()
            activityIndicator?.color = .gray
        }
        self.view.addSubview(activityIndicator!)
        activityIndicator?.setCenterX()
        activityIndicator?.setCenterY()
        activityIndicator?.startAnimating()
    }
    
    func hideActivityIndicator()
    {
        self.view.isUserInteractionEnabled = true
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
        //tableView.isHidden = false
    }
    
    
    @objc private func onHealthKitAddBtnPressed(){
        requestPermission()
    }
    private func requestPermission(){
        
        let types = HealthMetric.getAllHealthMetric()
        showActivityIndicator()
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
        
        var trackerList:[Tracker] = []
        trackerList.append(contentsOf: self.vitalsArr)
        if let fitnessTracker {
            trackerList.append(fitnessTracker)
        }
        
        let hkManual = HKManualAddViewController()
        hkManual.trackerList = trackerList
        hkManual.typesList = type
        hkManual.delegate = self
        self.navigationController?.pushViewController(hkManual, animated: true)
    }
    
    @objc private func onGettingStartedClicked(){
        if CharmUtil.getHealthKitPreference() == nil {
            presentHKPatientSelectVC()
        }
        else{
            requestPermission()
        }
    }
    
    
    @objc private func presentHKPatientSelectVC(){
        let patientCount =  Patient.patientList?.count ?? 0
        
      //  if patientCount > 1 {
        let patientSelectVC = HKPatientSelectViewController()
        patientSelectVC.delegate = self
        self.navigationController?.pushViewController(patientSelectVC, animated: true)
       // self.present(patientSelectVC, animated: true)
//        }
//        else{
//            onHKPatientSelected(patient: getSelectedPatient())
//        }
    }
    
    
    
    func addViewControllerDataAdded(message: String?) {
        if let message {
            CharmUtil.showToast(controller: self, message: message, seconds: 2)
        }
    }
    
    func onHKPatientSelected(patient: Patient) {
        self.navigationController?.popViewController(animated: false)
        CharmUtil.saveHealthKitPreference(patient: patient)
        if patient.patientId == getSelectedPatientId() {
            self.navigationItem.rightBarButtonItem = healthKitAdd
            requestPermission()
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
}

