//
//  HKPatientSelectView.swift
//  phr
//
//  Created by Raghul D on 17/10/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

class HKPatientSelectView: UIView , MDTextViewDelegate , UITextViewDelegate {
    
    weak var delegate: HKPatientSelectViewController?
    
    private let patientTableView = UITableView()
    private let infoLabel = InformationView(infoLocalisedKey: "com.charmphr.wellness.healthkit.patient.info")
    
    private var errorLabel: ErrorView? = nil
    private let saveBtn = UIButton()

    private let toView = UIView()
    private var toViewBottomConstraint: NSLayoutConstraint? = nil


    init(delegate: HKPatientSelectViewController){
        super.init(frame: .zero)
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.delegate = delegate
        initSubViews()
    }
    
    private func initSubViews(){
        
        
        let fromLabel = UILabel()
        let fromView = UIView()
        
        addSubview(fromLabel)
        addSubview(fromView)
        
        let healthIVWrapper = UIView()
        let healthIV = UIImageView(image: UIImage(named: "health-kit"))
        let healthHeading = UILabel()
        let healthSubHeading = UILabel()

        fromView.addSubview(healthIVWrapper)
        healthIVWrapper.addSubview(healthIV)
        fromView.addSubview(healthHeading)
        fromView.addSubview(healthSubHeading)
        
        let toLabel = UILabel()
        
        addSubview(toLabel)
        addSubview(toView)
        
        let charmIVWrapper = UIView()
        let charmHeading = UILabel()
        let charmSubHeading = UILabel()
        let charmIV = UIImageView()
        charmIV.image = UIImage(named: "AppIconForLaunchScreen")

        toView.addSubview(charmIVWrapper)
        charmIVWrapper.addSubview(charmIV)
        toView.addSubview(charmHeading)
        toView.addSubview(charmSubHeading)
        toView.addSubview(patientTableView)

        fromLabel.setProperties(textKey: "com.charmphr.allergies.itemView.from.title", fontsize: FONT_SIZE_MEDNORM, weight: .medium, fontcolor: TEXT_COLOR_BLACK70)
        healthHeading.setProperties(textKey: "com.charmphr.wellness.healthkit.apple.title", fontsize: FONT_SIZE_MEDNORM, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        healthSubHeading.setProperties(textKey: "com.charmphr.wellness.healthkit.apple.info", fontsize: FONT_SIZE_MEDNORM, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)

        fromView.addShadowAndCornerRadius(.MEDIUM)
        fromView.layer.cornerRadius = 18
        fromView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: 0xD0D5DDFF).cgColor
        fromView.layer.borderWidth = 0.5
        fromView.setBackgroundColor(bgColor: 0xFAFBFCFF)
        
        toLabel.setProperties(textKey: "com.charmphr.sharedocuments.toLabel.title", fontsize: FONT_SIZE_MEDNORM, weight: .medium, fontcolor: TEXT_COLOR_BLACK70)
        charmHeading.setProperties(textKey: "com.charmphr.wellness.healthkit.charm.title", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        charmSubHeading.setProperties(textKey: "com.charmphr.wellness.healthkit.charm.info", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        charmHeading.numberOfLines = 0
        charmSubHeading.numberOfLines = 0
        toView.addShadowAndCornerRadius(.MEDIUM)
        
        toView.layer.cornerRadius = 18

        


        let indicatorImg = UIImageView(image: UIImage(named: "right-arrow"))

        addSubview(infoLabel)
        addSubview(saveBtn)
        

        
        addSubview(indicatorImg)
      
        indicatorImg.transform = CGAffineTransform(rotationAngle: .pi / 2)
        

      
        patientTableView.addCornerRadius(.MEDIUM)
        patientTableView.layer.masksToBounds = true
        patientTableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        patientTableView.separatorColor = .clear
        patientTableView.register(HKPatientTableViewCell.self, forCellReuseIdentifier: "HKPatientTableViewCell")
        patientTableView.dataSource = delegate
        patientTableView.delegate = delegate
        
        
        var saveTitleKey = "com.charmphr.Payment.storeCard.title"
        if CharmUtil.getHealthKitPreference() != nil {
            saveTitleKey = "com.charmphr.action.save"
        }
        
        if #available(iOS 26, *) {
            saveBtn.configuration  = .prominentGlass()
            saveBtn.tintColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            
            
        
            
            let attrTxt = AttributedString(getString(key: saveTitleKey), attributes: AttributeContainer([NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font : UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .medium)]))
            
           // attrTxt.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .medium)
            saveBtn.configuration?.attributedTitle = attrTxt

        }
        else {
            saveBtn.setProperties(titleStrKey: saveTitleKey, fontsize: FONT_SIZE_EXTRALARGE, weight: .medium, fontcolor: THEME_COLOR)
            saveBtn.layer.cornerRadius = 8
            //showResultBtn.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR).cgColor
           // showResultBtn.layer.borderWidth = 1
            saveBtn.layer.masksToBounds = true
            saveBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            saveBtn.setTitleColor(.white, for: .normal)
        }
      //
        saveBtn.addTarget(self, action: #selector(onSaveClicked), for: .touchUpInside)
         
        charmIVWrapper.addShadowAndCornerRadius(.SMALL)
        charmIV.layer.cornerRadius = CardSize.SMALL.value
        charmIV.layer.masksToBounds = true

        healthIVWrapper.addShadowAndCornerRadius(.SMALL)
        healthIV.layer.cornerRadius = CardSize.SMALL.value
        healthIV.layer.masksToBounds = true
        
        if let selectedPatient = CharmUtil.getHealthKitPreference() {
            if let selectedIndex = delegate?.patientList.firstIndex(where: { $0.patientId == selectedPatient.patientId }) {
                patientTableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
            }
        }
        
        
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
         
        fromLabel.setLeft(offSet: 20)
        fromLabel.setSafeAreaTop(offset: 20)
        
        fromView.setHorizontal(offSet: 20)
        fromView.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: fromLabel, relatedAttribute: .bottom)
        fromView.setHeight(constant: 72)
        
        
        healthIVWrapper.setWidth(constant: 48)
        healthIVWrapper.setHeight(constant: 48)
        healthIVWrapper.setCenterY()
        healthIVWrapper.setLeft(offSet: 12)
        healthIV.setTop(offSet: 0)
        healthIV.setLeft(offSet: 0)
        healthIV.setRight(offSet: 0)
        healthIV.setBottom(offSet: 0)

        healthHeading.setLeftRelatedToView(offSet: 12, relatedView: healthIVWrapper, relatedAttribute: .right)
        healthHeading.setRight(offSet: -12)
        healthHeading.setTopRelatedToView(offSet: 2, relatedView: healthIVWrapper, relatedAttribute: .top)


        healthSubHeading.setLeftRelatedToView(offSet: 12, relatedView: healthIVWrapper, relatedAttribute: .right)
        healthSubHeading.setRight(offSet: -12)
        healthSubHeading.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: healthHeading, relatedAttribute: .bottom)
       
        
        toLabel.setLeft(offSet: 20)
        toLabel.setTopRelatedToView(offSet: 32, relatedView: fromView, relatedAttribute: .bottom)
        
        toView.setHorizontal(offSet: 20)
        toView.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: toLabel, relatedAttribute: .bottom)
        toViewBottomConstraint =  toView.setAndReturnBottomRelatedToView(offSet: -12, relatedView: infoLabel, relatedAttribute: .top)
        
        charmIVWrapper.setWidth(constant: 48)
        charmIVWrapper.setHeight(constant: 48)
        charmIVWrapper.setTop(offSet: 13)
        charmIVWrapper.setLeft(offSet: 12)
        charmIV.setTop(offSet: 0)
        charmIV.setLeft(offSet: 0)
        charmIV.setRight(offSet: 0)
        charmIV.setBottom(offSet: 0)

        charmHeading.setLeftRelatedToView(offSet: 12, relatedView: charmIVWrapper, relatedAttribute: .right)
        charmHeading.setRight(offSet: -12)
        charmHeading.setTopRelatedToView(offSet: 2, relatedView: charmIVWrapper, relatedAttribute: .top)


        charmSubHeading.setLeftRelatedToView(offSet: 12, relatedView: charmIVWrapper, relatedAttribute: .right)
        charmSubHeading.setRight(offSet: -12)
        charmSubHeading.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: charmHeading, relatedAttribute: .bottom)
       

        patientTableView.setTopRelatedToView(offSet: 24, relatedView: charmSubHeading, relatedAttribute: .bottom)
        patientTableView.setHorizontal()
        patientTableView.setBottom(offSet: 0)
        
        
        infoLabel.setBottomRelatedToView(offSet: -ITEM_VERTICAL_MARGIN, relatedView: saveBtn, relatedAttribute: .top)
        infoLabel.setLeft(offSet: X_SPACE)
        infoLabel.setRight(offSet: -X_SPACE)
     
        
        
        saveBtn.setLeft(offSet: X_SPACE)
        saveBtn.setRight(offSet: -X_SPACE)
        saveBtn.setSafeAreaBottom(offset: -Y_SPACE)
        saveBtn.setHeight(constant: 42)
        
       
        indicatorImg.setWidth(constant: 20)
        indicatorImg.setHeight(constant: 14.5)
        indicatorImg.setTopRelatedToView(offSet: 14, relatedView: fromView, relatedAttribute: .bottom)
        indicatorImg.setCenterX()
        
        saveBtn.hideView()
    }
    
    func showErrorView() {
        if errorLabel == nil {
            let errorView = ErrorView(infoLocalisedKey: "com.charmphr.wellness.healthkit.patient.invalid.error")
            
            addSubview(errorView)
            
            
            errorView.setBottomRelatedToView(offSet: -ITEM_VERTICAL_MARGIN, relatedView: saveBtn, relatedAttribute: .top)
            errorView.setLeft(offSet: X_SPACE)
            errorView.setRight(offSet: -X_SPACE)
            
            errorLabel = errorView
        }
        
        if let errorLabel {
            saveBtn.hideView()
            errorLabel.showView()
            infoLabel.hideView()
            
            if let toViewBottomConstraint {
                self.removeConstraint(toViewBottomConstraint)
            }
            toViewBottomConstraint = toView.setAndReturnBottomRelatedToView(offSet: -12, relatedView: errorLabel, relatedAttribute: .top)
        }
    }
    
    func hideErrorView() {
        saveBtn.showView()
        if let errorLabel {
            errorLabel.hideView()
            infoLabel.showView()
            
            if let toViewBottomConstraint {
                self.removeConstraint(toViewBottomConstraint)
            }
            toViewBottomConstraint = toView.setAndReturnBottomRelatedToView(offSet: -12, relatedView: infoLabel, relatedAttribute: .top)
        }
    }
    
    func updateInfoData(){
        infoLabel.setInfoText(infoLocalisedKey: "com.charmphr.wellness.healthkit.patient.info.2")
    }
    
    func addConstraintPostViewLoad(){
        
        setLeft(offSet: X_SPACE)
        setRight(offSet: -X_SPACE)
        setHeight(constant: 505)
        setCenterY()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    
    @objc func onSaveClicked(){
        
        if let selectedIndex = patientTableView.indexPathForSelectedRow {
            delegate?.onSelectPatient(index: selectedIndex.row)
            return
        }
        
        CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.wellness.healthkit.patient.error"))
        
        
        //delegate?.dismiss(animated: true)
    }
    
}


class HKPatientTableViewCell : UITableViewCell {
    
    private let patientImage = ImageViewWithInitailsView()
    private let patientNameLabel = UILabel()
    private let patientDetailLabel = UILabel()
    let selectBtn = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initViews(){
        let separator = UIView()

        contentView.addSubview(patientImage)
        contentView.addSubview(patientNameLabel)
        contentView.addSubview(patientDetailLabel)
        contentView.addSubview(selectBtn)
        contentView.addSubview(separator)
        

        //properties
        patientImage.layer.cornerRadius = 46 / 2
        patientImage.layer.masksToBounds = true
        patientImage.contentMode = .scaleToFill
        
        patientNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        patientNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        
        patientDetailLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        patientDetailLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_SELECTPATIENT_VC_LIGHT)
        separator.setBackgroundColor(bgColor: SEPARATOR_COLOR)
        
        selectBtn.image = #imageLiteral(resourceName: "RadioBtnUnselected")
//        selectBtn.setImage(#imageLiteral(resourceName: "RadioBtnUnselected"), for: .normal)
//        selectBtn.setImage(#imageLiteral(resourceName: "RadioBtnSelected"), for: .selected)


        //constraints
        
        
        patientImage.setLeft(offSet: X_SPACE)
        patientImage.setTop(offSet: 12)
        patientImage.setWidth(constant: 46)
        patientImage.setHeight(constant: 46)
        
        patientNameLabel.setLeftRelatedToView(offSet: 12, relatedView: patientImage, relatedAttribute: .right)
        patientNameLabel.setRightRelatedToView(offSet: -12, relatedView: selectBtn, relatedAttribute: .left)
        patientNameLabel.setTop(offSet: 12)
        
        patientDetailLabel.setLeftRelatedToView(offSet: 12, relatedView: patientImage, relatedAttribute: .right)
        patientDetailLabel.setRightRelatedToView(offSet: -12, relatedView: selectBtn, relatedAttribute: .left)
        patientDetailLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: patientNameLabel, relatedAttribute: .bottom)
        patientDetailLabel.setBottom(offSet: -12)
        
        separator.setRight(offSet: -X_SPACE)
        separator.setLeft(offSet: X_SPACE + 18)
        separator.setHeight(constant: SEPARATOR_HEIGHT)
        separator.setBottom(offSet: 0)
        
        selectBtn.setRight(offSet: -X_SPACE)
        selectBtn.setCenterY()
        selectBtn.setWidth(constant: 24)
        selectBtn.setHeight(constant: 24)
    }
    

    func setPatientData(patient: Patient) {
        patientImage.setInitialsAndImage(initials: patient.fullName?.formInitials() ?? "", image: patient.patientPhoto)
        patientNameLabel.text = patient.fullName
    
        if (patient.age > 0){
            patientDetailLabel.text = "\(patient.gender.capitalizingFirstLetter()) , \(patient.age ?? 0)"
        }
        else{
            patientDetailLabel.text = patient.gender.capitalizingFirstLetter()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            selectBtn.image = #imageLiteral(resourceName: "RadioBtnSelected")
        }
        else{
            selectBtn.image = #imageLiteral(resourceName: "RadioBtnUnselected")
        }
        contentView.backgroundColor = .white
    }
}
