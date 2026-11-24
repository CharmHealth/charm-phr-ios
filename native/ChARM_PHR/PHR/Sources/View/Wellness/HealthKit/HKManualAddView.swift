//
//  HKManualAddView.swift
//  phr
//
//  Created by Raghul D on 18/10/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

fileprivate let indicatorSideSpace:CGFloat =  7

class HKManualAddView: UIView {
    
    private let scrollView = TPKeyboardAvoidingScrollView()
    private let containerView = UIStackView()

    private let baseInfoView = UIView()

    private weak var delegate: HKManualAddViewController?
    
    private let dateRangeView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
    private let fromDateView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true, icon: "Calendar")
    private let toDateView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true, icon: "Calendar")
    
    private var vitalUnitView: TextFieldLabelItemView?
    
    private let dateCardView = UIView()
    private let showResultBtn = UIButton()
    private var isDataAvailable = false
    
    let fromDatePickerView = UIDatePicker()
    let toDatePickerView = UIDatePicker()

    private let activityIndicator = UIActivityIndicatorView()

    private let vitalLabel = UILabel()
    
    private let noDataView = NoDataView()

    init(delegate: HKManualAddViewController){
        super.init(frame: .zero)
        self.delegate = delegate
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews(){
        
        let charmIVWrapper = UIView()
        let healthIV = UIImageView(image: UIImage(named: "health-kit"))
        let healthIVWrapper = UIView()
        let charmIV = UIImageView()
        charmIV.image = UIImage(named: "AppIconForLaunchScreen")
        
        let syncInfo = UILabel()
        
//        let indicatorOne = createIndicator(width: 1)
//        let indicatorTwo = createIndicator(width: 1.5)
//        let indicatorThree = createIndicator(width: 2)
//        let indicatorFour = createIndicator(width: 2.5)
//        let indicatorFive = createIndicator(width: 3)
        
        let indicatorImg = UIImageView(image: UIImage(named: "right-arrow"))
        
        let periodLabel = UILabel()
        
        
        let profileImageView = ImageViewWithInitailsView()
          
        scrollView.setBackgroundColor(bgColor: APPLICATION_BACKGROUND_COLOR)
        
        
        self.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        
     //   containerView.spac
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.spacing = 12
        containerView.alignment = .center
        
        containerView.addArrangedSubview(baseInfoView)
        
        baseInfoView.addSubview(healthIVWrapper)
        healthIVWrapper.addSubview(healthIV)
        baseInfoView.addSubview(indicatorImg)
        baseInfoView.addSubview(charmIVWrapper)
        charmIVWrapper.addSubview(charmIV)
        baseInfoView.addSubview(syncInfo)
        baseInfoView.addSubview(periodLabel)
        baseInfoView.addSubview(profileImageView)

        containerView.addArrangedSubview(dateRangeView)
        containerView.addArrangedSubview(dateCardView)
        containerView.addArrangedSubview(showResultBtn)
        containerView.addArrangedSubview(noDataView)
        containerView.addArrangedSubview(vitalLabel)
        noDataView.setImage(enum: .healthKit, title: getString(key: "com.charmphr.action.noData.title"), message: "")

        
        containerView.setCustomSpacing(6, after: baseInfoView)
        containerView.setCustomSpacing(6, after: dateRangeView)
        containerView.setCustomSpacing(6, after: vitalLabel)
        
        

        
        let patient = Patient.selectedPatientInstance ?? Patient()
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleToFill
      
        
        profileImageView.setInitialsAndImage(initials: patient.fullName?.formInitials() ?? "", image: patient.patientPhoto)
        profileImageView.initialLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDNORM, Weight: .bold)
        profileImageView.layer.cornerRadius = 25 / 2
        profileImageView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)

     

        dateCardView.addSubview(fromDateView)
        dateCardView.addSubview(toDateView)
        
        dateRangeView.addShadowAndCornerRadius(.SMALL)
        dateRangeView.keyLabel.text = getString(key: "com.charmphr.wellness.healthkit.daterange.label")
        dateRangeView.backgroundColor = .white
        dateRangeView.hideSeparator()
        dateRangeView.textField?.isUserInteractionEnabled = false
        dateRangeView.isUserInteractionEnabled = true
        dateRangeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDateRangeClicked)))
        
       
        
        dateCardView.addShadowAndCornerRadius(.SMALL)
        dateCardView.backgroundColor = .white
        fromDateView.keyLabel.text = getString(key: "com.charmphr.wellness.healthkit.fromdate.label")
        
        let currentDate = Date()
        let minDate = currentDate.minus(years: 1)
        
        fromDatePickerView.preferredDatePickerStyle = .wheels
        fromDatePickerView.datePickerMode = .date
        fromDatePickerView.minimumDate = minDate
        fromDatePickerView.date = currentDate
        fromDatePickerView.maximumDate = currentDate
        fromDatePickerView.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        let fromDateViewToolBar = MDDateToolbarWithDone(textField: fromDateView.textField, parent: self)
        fromDateViewToolBar.done?.action = #selector(dismissKeyBoard)
        fromDateView.textField?.inputView = fromDatePickerView
        fromDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))


        
        toDateView.keyLabel.text = getString(key: "com.charmphr.wellness.healthkit.todate.label")
        toDateView.hideSeparator()
        
        toDatePickerView.preferredDatePickerStyle = .wheels
        toDatePickerView.datePickerMode = .date
        toDatePickerView.minimumDate = minDate
        toDatePickerView.date = currentDate
        toDatePickerView.maximumDate = currentDate
        toDatePickerView.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
        let toDateViewToolBar = MDDateToolbarWithDone(textField: toDateView.textField, parent: self)
        toDateViewToolBar.done?.action = #selector(dismissKeyBoard)
        toDateView.textField?.inputView = toDatePickerView
        toDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        
       

        if #available(iOS 26, *) {
            showResultBtn.configuration  = .prominentGlass()
            showResultBtn.configuration?.baseBackgroundColor = UIColorFromRGB(rgbValueWithAlpha: HK_CUSTOM_BG)
            
            
        
            
            let attrTxt = AttributedString(getString(key: "com.charmphr.wellness.healthkit.showresult.label"), attributes: AttributeContainer([NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR) , NSAttributedString.Key.font : UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .medium)]))
            
           // attrTxt.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .medium)
            showResultBtn.configuration?.attributedTitle = attrTxt

        }
        else {
            showResultBtn.setProperties(titleStrKey: "com.charmphr.wellness.healthkit.showresult.label", fontsize: FONT_SIZE_EXTRALARGE, weight: .medium, fontcolor: THEME_COLOR)
            showResultBtn.layer.cornerRadius = 8
            //showResultBtn.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR).cgColor
           // showResultBtn.layer.borderWidth = 1
            showResultBtn.layer.masksToBounds = true
            showResultBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            showResultBtn.setTitleColor(.white, for: .normal)

        }
        //videoCallBtn.titleLabel?.textAlignment = .center

       
        showResultBtn.addTarget(self, action: #selector(onShowResultBtnClicked), for: .touchUpInside)
        
//        showResultBtn.setRight(offSet: -16)
//        showResultBtn.setCenterY()
//        showResultBtn.setHeight(constant: 32)
//        showResultBtn.wrapWidth(maxWidth: 200 , maxHeight: 32 , extraSpacing: 20)
//        
        
        syncInfo.setProperties(textKey: "com.charmphr.wellness.healthkit.manualsync.info", fontsize: FONT_SIZE_EXTRALARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        syncInfo.numberOfLines = 0
        syncInfo.textAlignment = .center
        
        let vitalName = delegate?.getVitalName() ?? ""
        
        syncInfo.setText(key: "com.charmphr.wellness.healthkit.manualsync.info", with: [vitalName])
        
        charmIVWrapper.addShadowAndCornerRadius(.SMALL)
        charmIV.layer.cornerRadius = 12
        charmIV.layer.masksToBounds = true

        healthIVWrapper.addShadowAndCornerRadius(.SMALL)
        healthIV.layer.cornerRadius = 12
        healthIV.layer.masksToBounds = true
        
        periodLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        periodLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUM_LIGHT)
        periodLabel.setText(key: "com.charmphr.wellness.healthkit.syncperiod.title")
        
        vitalLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        vitalLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUM_LIGHT)
        vitalLabel.setText(key: "com.charmphr.wellness.vitals")
        //vitalLabel.textAlignment = .left
        
        
        
        scrollView.setTop(offSet: 0)
        scrollView.setHorizontal()
        scrollView.setBottom(offSet: 0)
        
        
        
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setWidth(constant: applicationFrame.width)
        
        baseInfoView.setWidth(constant: applicationFrame.width)
        noDataView.setWidth(constant: applicationFrame.width)
        
//        indicatorOne.setRightRelatedToView(offSet: -indicatorSideSpace, relatedView: indicatorTwo, relatedAttribute: .left)
//        indicatorTwo.setRightRelatedToView(offSet: -indicatorSideSpace, relatedView: indicatorThree, relatedAttribute: .left)
//        indicatorThree.setCenterX()
//        indicatorFour.setLeftRelatedToView(offSet: indicatorSideSpace, relatedView: indicatorThree, relatedAttribute: .right)
//        indicatorFive.setLeftRelatedToView(offSet: indicatorSideSpace, relatedView: indicatorFour, relatedAttribute: .right)
//        
//        
//        indicatorFive.setTopRelatedToView(offSet: 27.5, relatedView: charmIV, relatedAttribute: .top)
//        indicatorFour.setTopRelatedToView(offSet: 0.25, relatedView: indicatorFive, relatedAttribute: .top)
//        indicatorThree.setTopRelatedToView(offSet: 0.5, relatedView: indicatorFive, relatedAttribute: .top)
//        indicatorTwo.setTopRelatedToView(offSet: 0.75, relatedView: indicatorFive, relatedAttribute: .top)
//        indicatorOne.setTopRelatedToView(offSet: 1, relatedView: indicatorFive, relatedAttribute: .top)

        indicatorImg.setWidth(constant: 26)
        indicatorImg.setHeight(constant: 21)
        indicatorImg.setCenterX()
        indicatorImg.setTopRelatedToView(offSet: 17, relatedView: charmIV, relatedAttribute: .top)
        
        charmIVWrapper.setLeftRelatedToView(offSet: 17, relatedView: indicatorImg, relatedAttribute: .right)
        charmIVWrapper.setTop(offSet: 33)
        charmIVWrapper.setWidth(constant: 56)
        charmIVWrapper.setHeight(constant: 56)
        charmIV.setTop(offSet: 0)
        charmIV.setLeft(offSet: 0)
        charmIV.setRight(offSet: 0)
        charmIV.setBottom(offSet: 0)

        profileImageView.setWidth(constant: 25)
        profileImageView.setHeight(constant: 25)
        profileImageView.setLeftRelatedToView(offSet: -12.5, relatedView: charmIVWrapper, relatedAttribute: .right)
        profileImageView.setTopRelatedToView(offSet: -15, relatedView: charmIVWrapper, relatedAttribute: .bottom)

        healthIVWrapper.setWidth(constant: 56)
        healthIVWrapper.setHeight(constant: 56)
        healthIVWrapper.setTop(offSet: 33)
        healthIVWrapper.setRightRelatedToView(offSet: -17, relatedView: indicatorImg, relatedAttribute: .left)
        healthIV.setTop(offSet: 0)
        healthIV.setLeft(offSet: 0)
        healthIV.setRight(offSet: 0)
        healthIV.setBottom(offSet: 0)

        syncInfo.setHorizontal(offSet: X_SPACE)
        syncInfo.setTopRelatedToView(offSet: X_SPACE, relatedView: charmIVWrapper, relatedAttribute: .bottom)
        
        periodLabel.setTopRelatedToView(offSet: 24, relatedView: syncInfo, relatedAttribute: .bottom)
        periodLabel.setLeft(offSet: X_SPACE)
        periodLabel.setBottom(offSet: 0)
        
        dateRangeView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        dateCardView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))

        showResultBtn.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        vitalLabel.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        showResultBtn.setHeight(constant: 42)
        
        fromDateView.setHorizontal()
        fromDateView.setTop(offSet: 0)
        
        toDateView.setTopRelatedToView(offSet: 0, relatedView: fromDateView, relatedAttribute: .bottom)
        toDateView.setHorizontal()
        toDateView.setBottom(offSet: 0)
        
        dateCardView.hideView()
        showResultBtn.hideView()
        containerView.setCustomSpacing(24, after: dateRangeView)
        vitalLabel.hideView()
        noDataView.hideView()
    }
    
    func showNoDataView() {
        vitalLabel.hideView()
        noDataView.showView()
    }
    
    func insertVitalUnitView() {
        
        vitalUnitView = TextFieldLabelItemView(isArrowImageNeeded: true, isTextFieldShouldBeShown: true)
        
        if let vitalUnitView = vitalUnitView {

            containerView.insertArrangedSubview(vitalUnitView, at: 1)
            
            vitalUnitView.keyLabel.text = getString(key: "com.charmphr.wellnessmetric.option.label")
            vitalUnitView.textField?.isUserInteractionEnabled = false
            vitalUnitView.isUserInteractionEnabled = true
            vitalUnitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onvitalUnitClicked(tapGestureRecognizer:))))
            
            vitalUnitView.addShadowAndCornerRadius(.SMALL)
            vitalUnitView.backgroundColor = .white
            
            vitalUnitView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        }
    }
    
    private func createIndicator(width: CGFloat) -> UIView {
        
        let indicator = UIView()
        indicator.setBackgroundColor(bgColor: 0x969696FF)
        
        baseInfoView.addSubview(indicator)
        
        indicator.layer.cornerRadius = width/2
        
        indicator.setWidth(constant: width)
        indicator.setHeight(constant: width)
        return indicator
    }
    
    func setDateRange(dateRange: HKDateRange) {
        dateRangeView.textField?.text = dateRange.getLocalisedString()
        
        if dateRange == .custom {
            dateCardView.showView()
            showResultBtn.showView()
            //dateRangeView.
            containerView.setCustomSpacing(6, after: dateRangeView)
            containerView.setCustomSpacing(24, after: showResultBtn)
        }
        else{
            dateCardView.hideView()
            showResultBtn.hideView()
            containerView.setCustomSpacing(24, after: dateRangeView)
            containerView.setCustomSpacing(0, after: showResultBtn)
        }
    }
    
    @objc func viewClicked(tapGestureRecognizer:UITapGestureRecognizer)
    {
        if let dateview = tapGestureRecognizer.view as? TextFieldLabelItemView {
            dateview.textField?.becomeFirstResponder()
        }
    }
    
    @objc private func onDateRangeClicked(){
        if let vitalUnitView {
            if (vitalUnitView.textField?.text).isNilOrBlank() {
                CharmUtil.createOkayAlertWith(title: "", msg: "Please select a vital unit")
            }
            else{
                delegate?.pushToDateRangeSelectVC()
            }
        }
        else{
            delegate?.pushToDateRangeSelectVC()
        }
    }
    
    @objc private func onShowResultBtnClicked(){
        delegate?.onShowMoreClicked()
    }
    
    @objc func onvitalUnitClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        delegate?.showVitalMetricVC()
    }
    
    
    @objc func datePickerValueChanged(datePicker : UIDatePicker)
    {
        
        if fromDateView.textField?.isFirstResponder == true
        {
            let fromDate = datePicker.date
            
            fromDateView.textField?.text = fromDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            
            delegate?.onFromDateChanged(fromDate: fromDate)
            let currentDate = Date()
            let minAvailableDate = currentDate.minus(years: 1)
            
            
            var maxToDate = fromDate.add(months: 6)
            if maxToDate.isAfter(date: currentDate.startOfDay) {
                maxToDate = Date()
            }
            
            var minDate = fromDate
            
            if minDate.isBefore(date: minAvailableDate.startOfDay) {
                minDate = minAvailableDate
            }
            
            let toDateStr = toDateView.textField?.text ?? ""
            if toDateStr.isNotBlank() {
                if let toDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: toDateStr)?.startOfDay {
                    if toDate.isBefore(date: minDate) || toDate.isAfter(date: maxToDate){
                        toDateView.textField?.text = ""
                        delegate?.onToDateChanged(toDate: nil)
                        toDatePickerView.minimumDate = nil
                        toDatePickerView.maximumDate = Date()
                        toDatePickerView.date = maxToDate
                    }
                }
            }
            
            toDatePickerView.minimumDate = minDate
            toDatePickerView.maximumDate = maxToDate
        }
        else if toDateView.textField?.isFirstResponder == true {
            let toDate = datePicker.date
            toDateView.textField?.text = toDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            delegate?.onToDateChanged(toDate: toDate)
            
            let currentDate = Date()
            let minAvailableDate = currentDate.minus(years: 1)
            
            
            var minFromDate = toDate.minus(months: 6)
            if minFromDate.isBefore(date: minAvailableDate.startOfDay) {
                minFromDate = minAvailableDate
            }
            
            let fromDateStr = fromDateView.textField?.text ?? ""
            if fromDateStr.isNotBlank() {
                if let fromDate = Date.getDateFromString(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR, dateString: fromDateStr)?.startOfDay {
                    if fromDate.isBefore(date: minFromDate) || fromDate.isAfter(date: toDate){
                        fromDateView.textField?.text = ""
                        delegate?.onFromDateChanged(fromDate: nil)
                        fromDatePickerView.minimumDate = nil
                        fromDatePickerView.maximumDate = Date()
                        fromDatePickerView.date = minFromDate
                    }
                }
            }
            
            fromDatePickerView.minimumDate = minFromDate
            fromDatePickerView.maximumDate = toDate
        }

    }
    
    @objc func dismissKeyBoard()
    {
        if fromDateView.textField?.isFirstResponder == true
        {
            datePickerValueChanged(datePicker: fromDatePickerView)
        }
        else{
            datePickerValueChanged(datePicker: toDatePickerView)
        }
        self.endEditing(true)
    }
    
    func removeAllVitalViews() {
        containerView.arrangedSubviews
            .filter { $0 is HKVitalView }
            .forEach { $0.removeFromSuperview() }
        isDataAvailable = false
        vitalLabel.hideView()
        noDataView.hideView()
    }
    
    func insertBPView(bpModelList: [BPHistory]){
        vitalLabel.showView()
        noDataView.hideView()
        let bpView = HKVitalView(bpModelList: bpModelList)
        bpView.showAllData = delegate?.trackerList == nil
        bpView.delegate = delegate
        bpView.initSubViews()
        containerView.addArrangedSubview(bpView)
        
        bpView.addShadowAndCornerRadius(.SMALL)
        bpView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        
        isDataAvailable = true
    }
    
    func insertEntryView(modelList: [MetricValue] , headingLabel: String){
        vitalLabel.showView()
        noDataView.hideView()
        let entryView = HKVitalView(modelList: modelList, headingLabelStr: headingLabel)
        entryView.showAllData = delegate?.trackerList == nil
        entryView.delegate = delegate
        entryView.initSubViews()
        containerView.addArrangedSubview(entryView)
        
        entryView.addShadowAndCornerRadius(.SMALL)
        entryView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        isDataAvailable = true
    }
    
    func removeAndUpdateSyncedValues(syncedValues: [MetricValue]){
        containerView.arrangedSubviews
            .forEach { view in
                if let vitalView = view as? HKVitalView {
                    vitalView.removeAndUpdateSyncedValues(syncedValues: syncedValues)
                    if vitalView.getTotalCount() == 0 {
                        vitalView.removeFromSuperview()
                    }
                }
            }
    }
    
    func setVitalUnit(unitSystem: String) {
        
        if unitSystem == vitalUnitStandard {
            vitalUnitView?.textField?.text = getString(key: "com.charmphr.wellnessmetric.standard.option")
        }
        else{
            vitalUnitView?.textField?.text = getString(key: "com.charmphr.wellnessmetric.metric.option")
        }
    }
    
    func showActivityIndicator()
    {
        self.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true
    }
}

protocol HKVitalViewDelegate: AnyObject {
    func onVitalViewMoreClicked(modelList: [MetricValue] , heading: String)
    func onBPViewMoreClicked(bpModelList: [BPHistory] )
    func onVitalViewRemoveClicked(model: MetricValue)
    func onBPViewRemoveClicked(bpModel: BPHistory)
}

class HKVitalView: UIView , UITableViewDataSource , UITableViewDelegate{
    

    weak var delegate: HKVitalViewDelegate?
    private var isBP = false
    private var bpModelList: [BPHistory]? = nil
    private var modelList: [MetricValue]? = nil

    var showAllData = false
    
    private var headingStr = ""
    private let headingLabel = UILabel()
    private let separator = UIView()
    //private let vitalImg = UIImageView()
    private let vitalTableView: MDAutoGrowingTableView = MDAutoGrowingTableView()
    
    private var showMoreBtn: UIButton? = nil
    private var bottomContraint: NSLayoutConstraint? = nil

    init(bpModelList: [BPHistory]){
        super.init(frame: .zero)
        self.bpModelList = bpModelList
        isBP = true
        headingStr = getString(key: "com.charmphr.dashboard.vitals.BloodPressure")
    }
    
    init(modelList: [MetricValue]  , headingLabelStr: String){
        super.init(frame: .zero)
        self.modelList = modelList
        isBP = false
        headingStr = headingLabelStr
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews(){
        
        self.addSubview(headingLabel)
       // self.addSubview(vitalImg)
        self.addSubview(separator)
        self.addSubview(vitalTableView)
        
        self.backgroundColor = .white
        
        headingLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        headingLabel.text = headingStr
        
        separator.setBackgroundColor(bgColor: SEPARATOR_COLOR)
        
      //  vitalImg.image = #imageLiteral(resourceName: "Weight")
        
        if #available(iOS 15.0, *) {
            vitalTableView.sectionHeaderTopPadding = 0
        }
        
        vitalTableView.separatorStyle = .singleLine
        vitalTableView.register(HKVitalTVCell.self, forCellReuseIdentifier: "HKVitalTVCell")
        vitalTableView.isScrollEnabled = true
        vitalTableView.dataSource = self
        vitalTableView.delegate = self
        vitalTableView.separatorColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        vitalTableView.tableFooterView = UIView(frame: .zero)

        vitalTableView.layer.cornerRadius = 8
        vitalTableView.setBackgroundColor(bgColor: 0xFAFAFAFF)
        
        vitalTableView.heightConstraint = NSLayoutConstraint.init(item: vitalTableView, attribute:.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        vitalTableView.addConstraint(vitalTableView.heightConstraint)
        
        
        headingLabel.setTop(offSet: 11)
        headingLabel.setLeft(offSet: 8)
        //headingLabel.setLeftRelatedToView(offSet: 8, relatedView: vitalImg, relatedAttribute: .right)
        
//        vitalImg.setTop(offSet: 11)
//        vitalImg.setLeft(offSet: 8)
//        vitalImg.setWidth(constant: 24)
//        vitalImg.setHeight(constant: 24)
        
        separator.setTopRelatedToView(offSet: 11, relatedView: headingLabel, relatedAttribute: .bottom)
        separator.setHorizontal()
        separator.setHeight(constant: 1)
        
        vitalTableView.setHorizontal(offSet: 4)
        vitalTableView.setTopRelatedToView(offSet: 11, relatedView: separator, relatedAttribute: .bottom)
        bottomContraint = vitalTableView.setAndReturnBottom(offSet: -8)
        
        reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let totalCount = getTotalCount()
        return (totalCount > 2 && !showAllData) ? 2 : totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isBP {
            
            if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "HKVitalTVCell") as? HKVitalTVCell, let bpModel = bpModelList?.getElement(at: indexPath.row){
                tableViewCell.setTableViewCell(data: bpModel)
                return tableViewCell
            }
        }
        else{
            if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "HKVitalTVCell") as? HKVitalTVCell, let model = modelList?.getElement(at: indexPath.row){
                tableViewCell.setTableViewCell(metricValue: model)
                return tableViewCell
            }
        }
        
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var swipeActions:[UIContextualAction] = []
        if isBP {
            
            if let bpModel = bpModelList?.getElement(at: indexPath.row){
                let deleteAction = UIContextualAction(style: .destructive, title: getString(key: "com.charmphr.wellness.healthkit.remove"), handler: { [weak self] (action, view, completionHandler) in
                        //
                    self?.delegate?.onBPViewRemoveClicked(bpModel: bpModel)
                    completionHandler(true)
                })
                deleteAction.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
                swipeActions.append(deleteAction)
            }
        }
        else{
            if let model = modelList?.getElement(at: indexPath.row){
                let deleteAction = UIContextualAction(style: .destructive, title: getString(key: "com.charmphr.wellness.healthkit.remove"), handler: { [weak self] (action, view, completionHandler) in
                        //
                    self?.delegate?.onVitalViewRemoveClicked(model: model)
                    completionHandler(true)
                })
                deleteAction.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
                swipeActions.append(deleteAction)
            }
        }
        
        
        if !swipeActions.isEmpty {
            return UISwipeActionsConfiguration(actions: swipeActions)
        }
        
       return nil
            
        
        
    }
    
    func removeAndUpdateSyncedValues(syncedValues: [MetricValue]){
        if isBP {
            let syncedValues = syncedValues.filter({$0.metric?.metricName == wellnessSystolicModelId}).map({$0.metricHistory?.uniqueId})
            
            bpModelList?.removeAll(where: {syncedValues.contains($0.systolic?.uniqueId) && $0.systolic?.uniqueId != nil})
            reloadData()
        }
        else{
            let syncedValues = syncedValues.map({$0.metricHistory?.uniqueId})
            modelList?.removeAll(where: {syncedValues.contains($0.metricHistory?.uniqueId) && $0.metricHistory?.uniqueId != nil})
            reloadData()
        }
    }
    
    func getTotalCount() -> Int {
        if isBP {
            return bpModelList?.count ?? 0
        }
        else{
            return modelList?.count ?? 0
        }
    }
    
    private func reloadData(){
        
        if !showAllData {
            if getTotalCount() > 2 {
                createShowMoreBtn()
            }
            else{
                hideShowMoreBtn()
            }
        }
        else {
            hideShowMoreBtn()
        }
        vitalTableView.reloadData()
    }
    
    private func createShowMoreBtn(){
        if showMoreBtn == nil {
            let moreBtn = UIButton()
           
            moreBtn.setProperties(titleStrKey: "com.charmphr.wellness.healthkit.viewmore", fontsize: FONT_SIZE_EXTRALARGE, weight: .regular, fontcolor: THEME_COLOR)
            //moreBtn.backgroundColor = .white
            
            self.addSubview(moreBtn)
            moreBtn.addTarget(self, action: #selector(onViewMoreClicked), for: .touchUpInside)
            moreBtn.setHorizontal(offSet: 4)
            moreBtn.setHeight(constant: 32)
            moreBtn.setTopRelatedToView(offSet: 8, relatedView: vitalTableView, relatedAttribute: .bottom)
           
            showMoreBtn = moreBtn
            moreBtn.hideView()
        }
        
        
        if let showMoreBtn {
            if showMoreBtn.isHidden {
                if let bottomContraint {
                    self.removeConstraint(bottomContraint)
                }
                
                bottomContraint = showMoreBtn.setAndReturnBottom(offSet: -8)
                showMoreBtn.showView()
            }
        }
    }
    
    private func hideShowMoreBtn(){
        if let showMoreBtn {
            if !showMoreBtn.isHidden {
                if let bottomContraint {
                    self.removeConstraint(bottomContraint)
                }
                bottomContraint = vitalTableView.setAndReturnBottom(offSet: -8)
                showMoreBtn.hideView()
            }
        }
    }
    @objc private func onViewMoreClicked(){
        if let bpModelList {
            delegate?.onBPViewMoreClicked(bpModelList: bpModelList)
        }
        else {
            if let modelList {
                delegate?.onVitalViewMoreClicked(modelList: modelList, heading: self.headingLabel.text ?? "")
            }
        }
    }
}

class HKVitalTVCell: UITableViewCell{
    
    private let valueLabel = UILabel()
    private let dateLabel = UILabel()
    private var helperLabel:UILabel? = nil
    
    private var bottomConstraint: NSLayoutConstraint? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
       // contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        self.layoutMargins = .zero
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        
     
        
        contentView.addSubview(valueLabel)
        contentView.addSubview(dateLabel)
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        addProperties()
        addConstraints()
    }
    private func addProperties(){
        valueLabel.setProperties(fontsize: FONT_SIZE_EXTRALARGE, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        dateLabel.setProperties(fontsize: 13, weight: .regular, fontcolor: TEXT_COLOR_LIGHTGRAY)
    }
    private func addConstraints(){
        
        valueLabel.setTop(offSet: 12)
        bottomConstraint = valueLabel.setAndReturnBottom(offSet: -12)
        valueLabel.setLeft(offSet: 8)
        valueLabel.setRightRelatedToView(offSet: -8, relatedView: dateLabel, relatedAttribute: .right)
        
        dateLabel.setRight(offSet: -8)
        dateLabel.setTop(offSet: 12)
        
    }
    func setTableViewCell(data: BPHistory){
        
        valueLabel.text = data.getValue()
        dateLabel.text =  data.systolic?.getDateStr() ?? ""//CharmUtil.getDisplayDateStringAndToday(date: data.systolic?.dateOfEntry ?? Date() , showTimeForToday: false)
    }
    
    func setTableViewCell(metricValue: MetricValue){
         
        if let metric = metricValue.metricHistory {
            valueLabel.text = metric.getValue()
            dateLabel.text =  metric.getDateStr()
            
            
            if metric.notes.isNilOrBlank() {
                if let helperLabel {
                    if !helperLabel.isHidden {
                        helperLabel.hideView()
                        if let bottomConstraint {
                            contentView.removeConstraint(bottomConstraint)
                        }
                        bottomConstraint = valueLabel.setAndReturnBottom(offSet: -12)
                    }
                }
            }
            else{
                createHelperLabel()
                if let helperLabel {
                    helperLabel.text = metric.notes
                    if helperLabel.isHidden {
                        helperLabel.showView()
                        if let bottomConstraint {
                            contentView.removeConstraint(bottomConstraint)
                        }
                        bottomConstraint = helperLabel.setAndReturnBottom(offSet: -12)
                    }
                }
            }
        }
    }
    
    
    private func createHelperLabel() {
        
        if helperLabel == nil {
            let label = UILabel()
            label.setProperties(fontsize: 13, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)

            contentView.addSubview(label)
            
            label.hideView()
            
            label.setLeft(offSet: 8)
            label.setTopRelatedToView(offSet: 4, relatedView: valueLabel, relatedAttribute: .bottom)

            helperLabel = label
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
}
