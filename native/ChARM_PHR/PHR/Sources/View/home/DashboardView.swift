//
//  DashboardView.swift
//  PHR
//
//  Created by prathi-13964 on 09/05/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

class DashboardModel{
    var vitalsList : [Vital] = []
    var trackerList:[Tracker]? = nil
    
    var todayAppointmentList : [Appointment] = []
    var upComingAppointmentList : [[Appointment]] = []
    var medicationList : [MedicationPOJO] = []
    var messageList : [Messages] = []
    var questionnaireList : [PhysicianTemplates] = []
    var invoiceList : [PHRBills] = []
    var allQuestionnaireList : [PhysicianTemplates] = []
}

class DashboardView: UIView{
    
    let scrollView = UIScrollView()
    private let stackView : UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.center
        
        return stackView
    }()
    
    private var upcomingAppointmentView : UIView?
    private var todayAppointmentView : UIView?
    var recentMessageView : UIView?
    var questionnaireView: UIView?
    var activeInvoiceView: UIView?
    var activeMedicationView : UIView?
    
    let upComingAppoinmentstableView = MDAutoGrowingTableView()
    let todayAppoinmentstableView = MDAutoGrowingTableView()
    let recentMessageTableView = MDAutoGrowingTableView()
    let questionnaireTableView = MDAutoGrowingTableView()
    let activeInvoiceTableView = MDAutoGrowingTableView()
    
    private weak var homeVCDelegate: HomeViewControllerNavigationDelegate? = nil
    private weak var delegate: DashBoardViewController? = nil
    private let TOP_AND_BOTTOM_SPACE_BW_SECTIONS = 7
    private let weightBGColor : UInt = 0xD7E9E6FF
    private let heightBGColor : UInt = 0xF2E3DCFF
    private let bpBGColor : UInt = 0xEDD8DBFF
    
    init(){
        super.init(frame: .zero)
        
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.setLeft(offSet: 0)
        scrollView.setRight(offSet: 0)
        scrollView.setTop(offSet: 0)
        scrollView.setBottom(offSet: 0)
        
        stackView.setLeft(offSet: 0)
        stackView.setRight(offSet: 0)
        stackView.setTop(offSet: 0)
        stackView.setBottom(offSet: -8)
        stackView.setWidth(constant: applicationFrame.width)
    }
    
    //MARK: - Create Subviews
    
    func refreshVitals(dashboardModel: DashboardModel, delegate: DashBoardViewController){
        self.delegate = delegate
        let vitalsIndex: Int = stackView.arrangedSubviews.firstIndex(where: { subView in
            return subView.tag == delegate.VITALS_VIEW_TAG
        }) ?? 0
        stackView.arrangedSubviews[vitalsIndex].removeFromSuperview()
        
        if RbacUtil.checkPrivilege(privilege: .VIEW_WELLNESS) && isModuleEnabled(moduleId: wellnessModelId){
            let virtualContainer = createVirtual(vitalsList: dashboardModel.vitalsList)
            virtualContainer.tag = delegate.VITALS_VIEW_TAG
            virtualContainer.translatesAutoresizingMaskIntoConstraints = false
            stackView.insertArrangedSubview(virtualContainer, at: vitalsIndex)
            
            virtualContainer.setRelativeWidth(multiplier: 1, constant: 0)
        }
    }
    
    func createSubViews(appointmentSection: Section?, dashboardModel: DashboardModel, delegate: DashBoardViewController, homeVCDelegate: HomeViewControllerNavigationDelegate?){
        
        self.delegate = delegate
        self.homeVCDelegate = homeVCDelegate
        for subView in self.stackView.subviews
        {
            subView.removeFromSuperview()
        }
        
        if RbacUtil.checkPrivilege(privilege: .VIEW_WELLNESS) && isModuleEnabled(moduleId: wellnessModelId){
            let virtualContainer = createVirtual(vitalsList: dashboardModel.vitalsList)
            virtualContainer.tag = delegate.VITALS_VIEW_TAG
            virtualContainer.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(virtualContainer)
            
            virtualContainer.setRelativeWidth(multiplier: 1, constant: 0)
        }
        
        if RbacUtil.checkPrivilege(privilege: .VIEW_APPOINTMENT) && isModuleEnabled(moduleId: appointmentModelId){
            todayAppointmentView = createTodayAppointment(todayAppointmentList: dashboardModel.todayAppointmentList)
            
            upcomingAppointmentView = createUpcomingAppointments(upComingAppointmentList: dashboardModel.upComingAppointmentList, todayAppointmentList: dashboardModel.todayAppointmentList)
            
            guard let todayAppointmentView, let upcomingAppointmentView else { return }
            
            if let appointmentSection = appointmentSection{
                if appointmentSection.isEnable == true
                {
                    stackView.addArrangedSubview(todayAppointmentView)
                    stackView.addArrangedSubview(upcomingAppointmentView)
                    if dashboardModel.todayAppointmentList.count == 0
                    {
                        upcomingAppointmentView.isHidden = false
                    }
                    else{
                        upcomingAppointmentView.isHidden = true
                    }
                }
            }
            todayAppointmentView.setRelativeWidth(multiplier: 1, constant: -(X_SPACE*2))
            upcomingAppointmentView.setRelativeWidth(multiplier: 1, constant: -(X_SPACE*2))
        }
        
        if RbacUtil.checkPrivilege(privilege: .VIEW_MESSAGES) && isModuleEnabled(moduleId: messageModuleId){
            recentMessageView = createRecentMessageView(messageList: dashboardModel.messageList)
            guard let recentMessageView else { return }
            recentMessageView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(recentMessageView)
            recentMessageView.setRelativeWidth(multiplier: 1, constant: -(X_SPACE*2))
            recentMessageTableView.reloadData()
        }
        
        if RbacUtil.checkPrivilege(privilege: .VIEW_INVOICE) && isModuleEnabled(moduleId: billingModelId){
            
            activeInvoiceView = createActiveInvoiceView(invoiceList: dashboardModel.invoiceList)
            guard let activeInvoiceView else { return }
            activeInvoiceView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(activeInvoiceView)
            activeInvoiceView.setRelativeWidth(multiplier: 1, constant: -(X_SPACE*2))
            activeInvoiceTableView.reloadData()
        }
        
        if RbacUtil.checkPrivilege(privilege: .VIEW_QUESTIONNAIRE) && isModuleEnabled(moduleId: questionnaireModelId){
            questionnaireView = createQuestionnaireView(questionnaireList: dashboardModel.questionnaireList)
            guard let questionnaireView else { return }
            questionnaireView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(questionnaireView)
            questionnaireView.setRelativeWidth(multiplier: 1, constant: -(X_SPACE*2))
            questionnaireTableView.reloadData()
        }
        
        if RbacUtil.checkPrivilege(privilege: .VIEW_MEDICATIONS) && isModuleEnabled(moduleId: medicationModelId){
            activeMedicationView = createActiveMedications(medicationList: dashboardModel.medicationList)
            guard let activeMedicationView else { return }
            activeMedicationView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(activeMedicationView)
            activeMedicationView.setRelativeWidth(multiplier: 1, constant: -(X_SPACE*2))
            
            if dashboardModel.medicationList.isEmpty{
                activeMedicationView.isHidden = true
            }
            else{
                activeMedicationView.isHidden = false
            }
        }
    }
    
    //MARK: - Wellness
    
    private func createVirtual(vitalsList: [Vital]) -> UIView
    {
        
        // x space of starting and space between two vistual containers
        let virtualSigleWidth = (appDelegate.screenWidth - CGFloat((X_SPACE * 2 ) + (11 * 2)))/3
        
        let virtualContainer = UIView()
        
        var previousView = virtualContainer
        
        for vital in vitalsList
        {
            let virtualView = DashBoardVirtualsView()
            if isNilOrEmpty(string: vital.metricName )
            {
                virtualView.virtualsDateLabel.text = "-"
            }else
            {
                virtualView.virtualsDateLabel.text = CharmUtil.getDisplayDateString(date: vital.date ?? Date() ,skipCurrentYear: false)
            }
            
            virtualView.containerView.addCornerRadius(.SMALL)
            virtualView.addCornerRadius(.SMALL)
            
            if let vitalType = vital.vitalType, let delegate{
                if (vitalType == VitalType.Weight)
                {
                    virtualView.tag = delegate.VITAL_WEIGHT_VIEW_TAG
                    virtualView.virtualsNameLabel.text = NSLocalizedString("com.charmphr.dashboard.vitals.Weight", comment: "")
                    virtualView.virtualsImageView.image = #imageLiteral(resourceName: "Weight")
                    virtualView.containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: weightBGColor)
                    
                }
                else if (vitalType == VitalType.Height)
                {
                    virtualView.tag = delegate.VITAL_HEIGHT_VIEW_TAG
                    virtualView.virtualsNameLabel.text = NSLocalizedString("com.charmphr.dashboard.vitals.Height", comment: "")
                    virtualView.virtualsImageView.image = #imageLiteral(resourceName: "Height")
                    virtualView.containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: heightBGColor)
                }
                else if (vitalType == VitalType.Blood_pressure)
                {
                    virtualView.tag = delegate.VITAL_BP_VIEW_TAG
                    virtualView.virtualsNameLabel.text = NSLocalizedString("com.charmphr.dashboard.vitals.BloodPressure", comment: "")
                    virtualView.virtualsImageView.image = #imageLiteral(resourceName: "HeartRate")
                    virtualView.containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: bpBGColor)
                }
            }
            
            virtualView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onVitalClicked(gesture:))))
            
            
            var valueString : NSMutableAttributedString?
            
            let boldFontAtributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .bold)]
            valueString  =  NSMutableAttributedString(string: "\(vital.vitalValue) \(vital.valueUnit ?? "-")")
            
            valueString?.addAttributes(boldFontAtributes, range: NSRange(location: 0, length: vital.vitalValue.count))
            virtualView.virtualsValueLabel.attributedText = valueString!
            
            
            virtualView.translatesAutoresizingMaskIntoConstraints = false
            virtualContainer.addSubview(virtualView)
            virtualContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-TOP_SPACE-[virtualView]-Y_SPACE-|", options: [], metrics:["Y_SPACE":TOP_AND_BOTTOM_SPACE_BW_SECTIONS,"TOP_SPACE":TOP_SPACE_FROM_NAVIGATION], views: ["virtualView":virtualView]))
            
            if previousView == virtualContainer
            {
                virtualContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[virtualView(virtualSigleWidth)]", options: [], metrics: ["virtualSigleWidth":virtualSigleWidth,"X_SPACE":X_SPACE], views: ["virtualView":virtualView]))
            }else
            {
                virtualContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[previousView]-11-[virtualView(virtualSigleWidth)]", options: [], metrics: ["virtualSigleWidth":virtualSigleWidth], views: ["virtualView":virtualView , "previousView":previousView]))
            }
            
            previousView = virtualView
            
            if (vitalsList.last === vital)
            {
                virtualContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[previousView]-X_SPACE-|", options: [], metrics: ["X_SPACE":X_SPACE], views: [ "previousView":previousView]))
            }
        }
        return virtualContainer
    }
    
    //MARK: - Appointment
    
    private func createTodayAppointment(todayAppointmentList: [Appointment]) -> UIView
    {
        let todayAppointmentscontainer = UIView()
        todayAppointmentscontainer.backgroundColor = .clear
        
        if todayAppointmentList.count > 0
        {
            let titleLabel = UILabel()
            titleLabel.text = getString(key: "com.charmphr.dashboard.todayAppointment.title")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            titleLabel.textAlignment = .left
            titleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
            todayAppointmentscontainer.addSubview(titleLabel)
            
            todayAppoinmentstableView.sectionHeaderTopPadding = 0
            todayAppoinmentstableView.addCornerRadius(.LARGE)
            todayAppoinmentstableView.isScrollEnabled = false
            todayAppoinmentstableView.register(AppointmentsTableViewCell.self, forCellReuseIdentifier: "AppointmentsTableViewCell")
           // todayAppoinmentstableView.allowsSelection = false
            todayAppoinmentstableView.separatorStyle = .none
            todayAppoinmentstableView.translatesAutoresizingMaskIntoConstraints = false
            todayAppoinmentstableView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)

            todayAppointmentscontainer.addSubview(todayAppoinmentstableView)
     
            todayAppoinmentstableView.heightConstraint = NSLayoutConstraint.init(item: todayAppoinmentstableView, attribute:.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            todayAppoinmentstableView.addConstraint(todayAppoinmentstableView.heightConstraint)
                
                
            todayAppointmentscontainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics:nil, views: ["titleLabel":titleLabel]))
            todayAppointmentscontainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics:nil, views: ["tableView":todayAppoinmentstableView]))
                
            todayAppointmentscontainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-Y_SPACE-[titleLabel]-8-[tableView]-Y_SPACE-|", options: [], metrics: ["Y_SPACE":TOP_AND_BOTTOM_SPACE_BW_SECTIONS], views: ["titleLabel":titleLabel , "tableView":todayAppoinmentstableView]))
        }
        return todayAppointmentscontainer
    }
    
    private func createUpcomingAppointments(upComingAppointmentList: [[Appointment]], todayAppointmentList: [Appointment]) -> UIView
    {
        let upcomingAppointmentscontainer = UIView()
        upcomingAppointmentscontainer.backgroundColor = .clear
        
        if (upComingAppointmentList.count > 0 && todayAppointmentList.count > 0 )||( todayAppointmentList.count == 0 && upComingAppointmentList.count > 0 ) || (upComingAppointmentList.count == 0 && todayAppointmentList.count == 0)
        {
            let titleLabel = UILabel()
            titleLabel.text = getString(key: "com.charmphr.dashboard.upcomingAppointment.title")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            titleLabel.textAlignment = .left
            titleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
            upcomingAppointmentscontainer.addSubview(titleLabel)
            
            upComingAppoinmentstableView.sectionHeaderTopPadding = 0
            upComingAppoinmentstableView.addCornerRadius(.LARGE)
            upComingAppoinmentstableView.backgroundColor = .white
            upComingAppoinmentstableView.isScrollEnabled = false
            
            upComingAppoinmentstableView.register(AppointmentsTableViewCell.self, forCellReuseIdentifier: "AppointmentsTableViewCell")

            upComingAppoinmentstableView.register(UINib(nibName: "NoUpcomingAppointmentsTableViewCell", bundle: nil), forCellReuseIdentifier: "NoUpcomingAppointmentsTableViewCell")
        
            upComingAppoinmentstableView.separatorStyle = .none
            upComingAppoinmentstableView.translatesAutoresizingMaskIntoConstraints = false
          //  upComingAppoinmentstableView.allowsSelection = false
            upcomingAppointmentscontainer.addSubview(upComingAppoinmentstableView)

            upComingAppoinmentstableView.heightConstraint = NSLayoutConstraint.init(item: upComingAppoinmentstableView, attribute:.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            upComingAppoinmentstableView.addConstraint(upComingAppoinmentstableView.heightConstraint)
            
            for i in 0 ..< upComingAppointmentList.count{
                delegate?.upComingAppointmentSectionTotalCount += upComingAppointmentList[i].count
            }
            
            upcomingAppointmentscontainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics:nil, views: ["titleLabel":titleLabel]))
            upcomingAppointmentscontainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics:nil, views: ["tableView":upComingAppoinmentstableView]))
            
            // -8- space between title label and table view
            upcomingAppointmentscontainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-Y_SPACE-[titleLabel]-8-[tableView]-Y_SPACE-|", options: [], metrics: ["Y_SPACE":TOP_AND_BOTTOM_SPACE_BW_SECTIONS], views: ["titleLabel":titleLabel , "tableView":upComingAppoinmentstableView]))
        }
        
        return upcomingAppointmentscontainer
    }
    
    func reloadTodayAppointmentView(todayAppointmentList: [Appointment]) {
        
        todayAppointmentView?.clipsToBounds = true
        let newView = createTodayAppointment(todayAppointmentList: todayAppointmentList)
        guard let todayAppointmentView else { return }
        todayAppointmentView.addSubview(newView)
        newView.setLeft(offSet: 0)
        newView.setRight(offSet: 0)
        newView.setTop(offSet: 0)
        newView.setBottom(offSet: 0)
        
        if todayAppointmentList.count == 0{
            upcomingAppointmentView?.isHidden = false
        }
        else{
            upcomingAppointmentView?.isHidden = true
        }
    }
    
    //MARK: - Messages
    
    private func createRecentMessageView(messageList: [Messages]) -> UIView
    {
        let recentMessageContainer = UIView()
        recentMessageContainer.backgroundColor = .clear
        
        if !messageList.isEmpty{
            
            let titleLabel = UILabel()
            titleLabel.text = getString(key: "com.charmphr.dashboard.recentMessage.title")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            titleLabel.textAlignment = .left
            titleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
            recentMessageContainer.addSubview(titleLabel)
            
            
            let recentMessageTableViewLayout = UIView()
            
            recentMessageTableView.sectionHeaderTopPadding = 0
            recentMessageTableView.addCornerRadius(.LARGE)
            recentMessageTableView.backgroundColor = .white
            recentMessageTableView.isScrollEnabled = false
            recentMessageTableView.register(RecentMessageTableViewCell.self, forCellReuseIdentifier: "RecentMessageTableViewCell")
           // todayAppoinmentstableView.allowsSelection = false
            recentMessageTableView.separatorStyle = .none
            recentMessageTableView.translatesAutoresizingMaskIntoConstraints = false
            recentMessageTableViewLayout.addShadowAndCornerRadius(.LARGE)

            recentMessageTableViewLayout.addSubview(recentMessageTableView)
            recentMessageContainer.addSubview(recentMessageTableViewLayout)
     
            recentMessageTableView.heightConstraint = NSLayoutConstraint.init(item: recentMessageTableView, attribute:.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            recentMessageTableView.addConstraint(recentMessageTableView.heightConstraint)
            
            
            titleLabel.setTop(offSet: CGFloat(TOP_AND_BOTTOM_SPACE_BW_SECTIONS))
            titleLabel.setLeft(offSet: 0)
            titleLabel.setRight(offSet: 0)
            
            
            recentMessageTableViewLayout.setLeft(offSet: 0)
            recentMessageTableViewLayout.setRight(offSet: 0)
            recentMessageTableViewLayout.setTopRelatedToView(offSet: 8, relatedView: titleLabel, relatedAttribute: .bottom)
            recentMessageTableViewLayout.setBottom(offSet: CGFloat(-TOP_AND_BOTTOM_SPACE_BW_SECTIONS))
                
            
            if messageList.count > 2{
                let showMoreBtn = UIButton()
                showMoreBtn.setTitle(getString(key: "com.charmphr.dashboard.activeMedication.action.showmore"), for: .normal)
                showMoreBtn.translatesAutoresizingMaskIntoConstraints = false;
                showMoreBtn.backgroundColor = UIColor.clear
                showMoreBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for: .normal)
                showMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
                showMoreBtn.addTarget(self, action: #selector(showMoreMessageClicked), for: .touchUpInside)
                
                recentMessageTableViewLayout.addSubview(showMoreBtn)
                
                recentMessageTableView.setTop(offSet: 5)
                recentMessageTableView.setLeft(offSet: 0)
                recentMessageTableView.setRight(offSet: -5)
                
                showMoreBtn.setTopRelatedToView(offSet: 0, relatedView: recentMessageTableView, relatedAttribute: .bottom)
                showMoreBtn.setBottom(offSet: -CARD_PADDING)
                showMoreBtn.setCenterX()
            }
            else{
                recentMessageTableView.equalsTheContainerView(constant: 5)
            }
        }
        return recentMessageContainer
    }
    
    //MARK: - Invoices
    
    private func createActiveInvoiceView(invoiceList: [PHRBills]) -> UIView
    {
        let invoiceContainer = UIView()
        invoiceContainer.backgroundColor = .clear
        
        if !invoiceList.isEmpty{
            
            let titleLabel = UILabel()
            titleLabel.text = getString(key: "com.charmphr.dashboard.invoice.title")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            titleLabel.textAlignment = .left
            titleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
            invoiceContainer.addSubview(titleLabel)
            
            let invoiceTableViewLayout = UIView()
            
            activeInvoiceTableView.sectionHeaderTopPadding = 0
            activeInvoiceTableView.addCornerRadius(.LARGE)
            activeInvoiceTableView.backgroundColor = .white
            activeInvoiceTableView.isScrollEnabled = false
            activeInvoiceTableView.register(ActiveInvoiceTableViewCell.self, forCellReuseIdentifier: "ActiveInvoiceTableViewCell")
           // todayAppoinmentstableView.allowsSelection = false
            activeInvoiceTableView.separatorStyle = .none
            activeInvoiceTableView.translatesAutoresizingMaskIntoConstraints = false
            invoiceTableViewLayout.addShadowAndCornerRadius(.LARGE)

            invoiceTableViewLayout.addSubview(activeInvoiceTableView)
            invoiceContainer.addSubview(invoiceTableViewLayout)
     
            activeInvoiceTableView.heightConstraint = NSLayoutConstraint.init(item: activeInvoiceTableView, attribute:.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            activeInvoiceTableView.addConstraint(activeInvoiceTableView.heightConstraint)
            
            
            titleLabel.setTop(offSet: CGFloat(TOP_AND_BOTTOM_SPACE_BW_SECTIONS))
            titleLabel.setLeft(offSet: 0)
            titleLabel.setRight(offSet: 0)
            
            invoiceTableViewLayout.setLeft(offSet: 0)
            invoiceTableViewLayout.setRight(offSet: 0)
            invoiceTableViewLayout.setTopRelatedToView(offSet: 8, relatedView: titleLabel, relatedAttribute: .bottom)
            invoiceTableViewLayout.setBottom(offSet: CGFloat(-TOP_AND_BOTTOM_SPACE_BW_SECTIONS))
                
            
            if invoiceList.count > 2{
                let showMoreBtn = UIButton()
                showMoreBtn.setTitle(getString(key: "com.charmphr.dashboard.activeMedication.action.showmore"), for: .normal)
                showMoreBtn.translatesAutoresizingMaskIntoConstraints = false;
                showMoreBtn.backgroundColor = UIColor.clear
                showMoreBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for: .normal)
                showMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
                showMoreBtn.addTarget(self, action: #selector(showMoreInvoiceClicked), for: .touchUpInside)
                
                invoiceTableViewLayout.addSubview(showMoreBtn)
                
                activeInvoiceTableView.setTop(offSet: 5)
                activeInvoiceTableView.setLeft(offSet: 5)
                activeInvoiceTableView.setRight(offSet: -5)
                
                showMoreBtn.setTopRelatedToView(offSet: 0, relatedView: activeInvoiceTableView, relatedAttribute: .bottom)
                showMoreBtn.setBottom(offSet: -CARD_PADDING)
                showMoreBtn.setCenterX()
            }
            else{
                activeInvoiceTableView.equalsTheContainerView(constant: 5)
            }
            
        }
        return invoiceContainer
    }
    
    //MARK: - Questionnaire
    
    private func createQuestionnaireView(questionnaireList: [PhysicianTemplates]) -> UIView
    {
        let questionnaireContainer = UIView()
        questionnaireContainer.backgroundColor = .clear
        
        if !questionnaireList.isEmpty{
            
            let titleLabel = UILabel()
            titleLabel.text = getString(key: "com.charmphr.dashboard.questionnaire.title")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
            titleLabel.textAlignment = .left
            titleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
            questionnaireContainer.addSubview(titleLabel)
            
            let questionnaireTableViewLayout = UIView()
            
            questionnaireTableView.sectionHeaderTopPadding = 0
            questionnaireTableView.addCornerRadius(.LARGE)
            questionnaireTableView.backgroundColor = .white
            questionnaireTableView.isScrollEnabled = false
            questionnaireTableView.register(HomeQuestionnaireTableView.self, forCellReuseIdentifier: "HomeQuestionnaireTableView")
           // todayAppoinmentstableView.allowsSelection = false
            questionnaireTableView.separatorStyle = .none
            questionnaireTableView.translatesAutoresizingMaskIntoConstraints = false
            questionnaireTableViewLayout.addShadowAndCornerRadius(.LARGE)

            questionnaireTableViewLayout.addSubview(questionnaireTableView)
            questionnaireContainer.addSubview(questionnaireTableViewLayout)
     
            questionnaireTableView.heightConstraint = NSLayoutConstraint.init(item: questionnaireTableView, attribute:.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            questionnaireTableView.addConstraint(questionnaireTableView.heightConstraint)
            
            
            
            titleLabel.setTop(offSet: CGFloat(TOP_AND_BOTTOM_SPACE_BW_SECTIONS))
            titleLabel.setLeft(offSet: 0)
            titleLabel.setRight(offSet: 0)
                
            questionnaireTableViewLayout.setLeft(offSet: 0)
            questionnaireTableViewLayout.setRight(offSet: 0)
            questionnaireTableViewLayout.setTopRelatedToView(offSet: 8, relatedView: titleLabel, relatedAttribute: .bottom)
            questionnaireTableViewLayout.setBottom(offSet: CGFloat(-TOP_AND_BOTTOM_SPACE_BW_SECTIONS))
            
            if questionnaireList.count > 2{
                let showMoreBtn = UIButton()
                showMoreBtn.setTitle(getString(key: "com.charmphr.dashboard.activeMedication.action.showmore"), for: .normal)
                showMoreBtn.translatesAutoresizingMaskIntoConstraints = false;
                showMoreBtn.backgroundColor = UIColor.clear
                showMoreBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for: .normal)
                showMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
                showMoreBtn.addTarget(self, action: #selector(showMoreQuestionnaireClicked), for: .touchUpInside)
                
                questionnaireTableViewLayout.addSubview(showMoreBtn)
                
                questionnaireTableView.setTop(offSet: 5)
                questionnaireTableView.setLeft(offSet: 5)
                questionnaireTableView.setRight(offSet: -5)
                
                showMoreBtn.setTopRelatedToView(offSet: 0, relatedView: questionnaireTableView, relatedAttribute: .bottom)
                showMoreBtn.setBottom(offSet: -CARD_PADDING)
                showMoreBtn.setCenterX()
            }
            else{
                questionnaireTableView.equalsTheContainerView(constant: 5)
            }
            
        }
        return questionnaireContainer
    }
    
    //MARK: Medications
    
    private func createActiveMedications(medicationList: [MedicationPOJO]) -> UIView
    {
        let activeMedicationscontainer = UIView()
        activeMedicationscontainer.backgroundColor = .clear
        
        
        let titleLabel = UILabel()
        titleLabel.text = getString(key: "com.charmphr.dashboard.activeMedication.title")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        activeMedicationscontainer.addSubview(titleLabel)
        
        let activeMedicationsViewContainer = UIView()
        activeMedicationscontainer.addSubview(activeMedicationsViewContainer)
        
        activeMedicationsViewContainer.setTopRelatedToView(offSet: 8, relatedView: titleLabel, relatedAttribute: .bottom)
        activeMedicationsViewContainer.setBottom(offSet: 0)
        activeMedicationsViewContainer.setLeft(offSet: 0)
        activeMedicationsViewContainer.setRight(offSet: 0)
        
        let activeMedicationsStackView = UIStackView()
        activeMedicationsViewContainer.addSubview(activeMedicationsStackView)
        
        activeMedicationsStackView.axis = .vertical
        activeMedicationsStackView.spacing = 0
        activeMedicationsStackView.alignment = .fill
    
        activeMedicationsViewContainer.addShadowAndCornerRadius(.LARGE)
            
        var i = 0

        for activeMedicationPOJO in medicationList
        {
            let activeMedicationsView = ActiveMedicationsView()
            i = i + 1
            activeMedicationsView.setValues(activeMedicationPOJO: activeMedicationPOJO)
            
            activeMedicationsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMedicationClicked)))
            
            activeMedicationsView.translatesAutoresizingMaskIntoConstraints = false
            activeMedicationsView.backgroundColor = .clear
            activeMedicationsStackView.addArrangedSubview(activeMedicationsView)
            
            activeMedicationsView.setLeft(offSet: 0)
            activeMedicationsView.setRight(offSet: 0)

            if medicationList.last === activeMedicationPOJO || i == 5
            {
                if i == 5
                {
                    let showMoreBtn = UIButton()
                    showMoreBtn.setTitle(getString(key: "com.charmphr.dashboard.activeMedication.action.showmore"), for: .normal)
                    showMoreBtn.translatesAutoresizingMaskIntoConstraints = false;
                    showMoreBtn.backgroundColor = UIColor.clear
                    showMoreBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for: .normal)
                    showMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
                    showMoreBtn.addTarget(self, action: #selector(showMoreMedicationClicked), for: .touchUpInside)
                    activeMedicationsStackView.addArrangedSubview(showMoreBtn)
                    
                    showMoreBtn.setCenterX()
                    break
                }
            }
        }
        
        titleLabel.setTop(offSet: 5)
        titleLabel.setLeft(offSet: 0)
        titleLabel.setRight(offSet: 0)
        
        activeMedicationsStackView.setTop(offSet: 10)
        activeMedicationsStackView.setLeft(offSet: 5)
        activeMedicationsStackView.setRight(offSet: -5)
        activeMedicationsStackView.setBottom(offSet: -5)
        
        return activeMedicationscontainer
    }
    
    func reloadActiveMedicationsView(medicationList: [MedicationPOJO]) {
        //TODO: have to change this to tableview and reload data like appointments
        if let activeMedicationView
        {
            for view in activeMedicationView.subviews
            {
                view.removeFromSuperview()
            }
        }
        activeMedicationView?.clipsToBounds = true
        let newView = createActiveMedications(medicationList: medicationList)
        activeMedicationView?.addSubview(newView)
        newView.setLeft(offSet: 0)
        newView.setRight(offSet: 0)
        newView.setTop(offSet: 0)
        newView.setBottom(offSet: 0)
    }
    
//MARK: - Action calls
    
    @objc func onVitalClicked(gesture : UITapGestureRecognizer){
        if let tag = gesture.view?.tag as? Int {
            delegate?.onVitalClicked(tag: tag)
        }
    }
    
    @objc func showMoreMessageClicked()
    {
        homeVCDelegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: "Messages")
    }
    
    @objc func showMoreInvoiceClicked()
    {
        homeVCDelegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: "Billing")
    }
    
    @objc func showMoreQuestionnaireClicked()
    {
        homeVCDelegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: questionnaireModelId)
    }
    
    @objc func showMoreMedicationClicked()
    {
        homeVCDelegate?.homeViewControllerNavigationPushViewController(selectedSection: nil, identifier: "Prescriptions")
    }
    
    @objc func onMedicationClicked(){
        showMoreMedicationClicked()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
