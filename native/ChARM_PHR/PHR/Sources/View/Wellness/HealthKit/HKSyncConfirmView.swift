//
//  HKSyncConfirmView.swift
//  phr
//
//  Created by Raghul D on 03/03/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

import Foundation



class HKSyncConfirmView: UIView {

    weak var delegate: HKSyncConfirmViewController?

    private let titleLabel = UILabel()
    private let healthKitIconWrapper = UIView()
    private let healthKitIcon = UIImageView(image: UIImage(named: "health-kit"))
    private let arrowIcon = UIImageView(image: UIImage(named: "right-arrow"))
    private let charmIconWrapper = UIView()
    private let charmIcon = UIImageView()
    private let patientImageView = ImageViewWithInitailsView()
    private let dateRangeKeyLabel = UILabel()
    private let dateRangeValueLabel = UILabel()
    private let vitalKeyLabel = UILabel()
    private let vitalValueLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let yesSyncBtn = UIButton()
    private let cancelBtn = UIButton()

    init(delegate: HKSyncConfirmViewController?) {
        super.init(frame: .zero)
        self.delegate = delegate
        
        charmIcon.image = UIImage(named: "AppIconForLaunchScreen")
        
        initSubViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubViews() {

        // MARK: - Subviews & Styling

        let iconContainerView = UIView()
        let infoContainerView = UIView()

        addSubview(titleLabel)
        addSubview(iconContainerView)
        addSubview(infoContainerView)
        addSubview(descriptionLabel)
        addSubview(yesSyncBtn)
        addSubview(cancelBtn)

        iconContainerView.addSubview(healthKitIconWrapper)
        healthKitIconWrapper.addSubview(healthKitIcon)
        iconContainerView.addSubview(arrowIcon)
        iconContainerView.addSubview(charmIconWrapper)
        charmIconWrapper.addSubview(charmIcon)
        iconContainerView.addSubview(patientImageView)

        infoContainerView.addSubview(dateRangeKeyLabel)
        infoContainerView.addSubview(dateRangeValueLabel)
        infoContainerView.addSubview(vitalKeyLabel)
        infoContainerView.addSubview(vitalValueLabel)

        addShadowAndCornerRadius(.LARGE)
        self.layer.cornerRadius = 28

        titleLabel.setProperties(fontsize: FONT_SIZE_TWENTY, weight: .bold, fontcolor: TEXT_COLOR_BLACK87)
        titleLabel.numberOfLines = 0

        healthKitIconWrapper.addShadowAndCornerRadius(.SMALL , shadowOffset: .zero)
        healthKitIconWrapper.layer.shadowRadius = 10
        healthKitIcon.layer.cornerRadius = CardSize.SMALL.value
        healthKitIcon.layer.masksToBounds = true

        charmIconWrapper.addShadowAndCornerRadius(.SMALL , shadowOffset: .zero)
        charmIconWrapper.layer.shadowRadius = 10

        charmIcon.layer.cornerRadius = CardSize.SMALL.value
        charmIcon.layer.masksToBounds = true

        arrowIcon.contentMode = .scaleAspectFit

        patientImageView.layer.cornerRadius = 14
        patientImageView.layer.masksToBounds = true
        patientImageView.contentMode = .scaleToFill
        patientImageView.layer.borderColor = UIColor.white.cgColor
        patientImageView.layer.borderWidth = 1.5

        dateRangeKeyLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
        dateRangeValueLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
        dateRangeValueLabel.textAlignment = .right

        vitalKeyLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
        vitalValueLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
        vitalValueLabel.textAlignment = .right

        descriptionLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        descriptionLabel.numberOfLines = 0

        charmIconWrapper.layer.shadowOffset = .zero
        charmIconWrapper.layer.shadowRadius = 20

        if #available(iOS 26, *) {
            yesSyncBtn.configuration = .prominentGlass()
            yesSyncBtn.configuration?.baseBackgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
           // yesSyncBtn.tintColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            let attrTxt = AttributedString(getString(key: "com.charmphr.wellness.healthkit.sync.confirm.yes"), attributes: AttributeContainer([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .medium)]))
            yesSyncBtn.configuration?.attributedTitle = attrTxt
            
            
            cancelBtn.configuration = .prominentGlass()
            cancelBtn.configuration?.baseBackgroundColor = UIColorFromRGB(rgbValueWithAlpha: FEEDBACK_VIEW_BG_COLOR)
            let cancelAttrTxt = AttributedString(getString(key: "com.charmphr.action.cancel"), attributes: AttributeContainer([NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87) , NSAttributedString.Key.font: UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .medium)]))
            cancelBtn.configuration?.attributedTitle = cancelAttrTxt
        
        } else {
            yesSyncBtn.setProperties(titleStrKey: "com.charmphr.wellness.healthkit.sync.confirm.yes", fontsize: FONT_SIZE_EXTRALARGE, weight: .medium, fontcolor: WHITE_COLOR)
            yesSyncBtn.layer.cornerRadius = 8
            yesSyncBtn.layer.masksToBounds = true
            yesSyncBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
            yesSyncBtn.addPillCornerRadiusAndShadow(height: PILL_BTN_HEIGHT)
            
            cancelBtn.setTitle(getString(key: "com.charmphr.action.cancel"), for: .normal)
            cancelBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87), for: .normal)
            cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .medium)
            cancelBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
            cancelBtn.addPillCornerRadiusAndShadow(height: ACTION_BTN_HEIGT)
        }
        yesSyncBtn.addTarget(self, action: #selector(onYesSyncBtnClicked), for: .touchUpInside)

       
        cancelBtn.addTarget(self, action: #selector(onCancelBtnClicked), for: .touchUpInside)

        // MARK: - Constraints

        titleLabel.setTop(offSet: 24)
        titleLabel.setLeft(offSet: 24)
        titleLabel.setRight(offSet: -24)

        iconContainerView.setTopRelatedToView(offSet: 20, relatedView: titleLabel, relatedAttribute: .bottom)
        iconContainerView.setCenterX()
        iconContainerView.setHeight(constant: 56)
        iconContainerView.setWidth(constant: 172)

        healthKitIconWrapper.setLeft(offSet: 0)
        healthKitIconWrapper.setTop(offSet: 0)
        healthKitIconWrapper.setWidth(constant: 56)
        healthKitIconWrapper.setHeight(constant: 56)
        healthKitIcon.setTop(offSet: 0)
        healthKitIcon.setLeft(offSet: 0)
        healthKitIcon.setRight(offSet: 0)
        healthKitIcon.setBottom(offSet: 0)

        arrowIcon.setCenterX()
        arrowIcon.setCenterY()
        arrowIcon.setWidth(constant: 26)
        arrowIcon.setHeight(constant: 21)

        charmIconWrapper.setRight(offSet: 0)
        charmIconWrapper.setTop(offSet: 0)
        charmIconWrapper.setWidth(constant: 56)
        charmIconWrapper.setHeight(constant: 56)
        charmIcon.setTop(offSet: 0)
        charmIcon.setLeft(offSet: 0)
        charmIcon.setRight(offSet: 0)
        charmIcon.setBottom(offSet: 0)

        patientImageView.setWidth(constant: 28)
        patientImageView.setHeight(constant: 28)
        patientImageView.setLeftRelatedToView(offSet: -14, relatedView: charmIconWrapper, relatedAttribute: .right)
        patientImageView.setTopRelatedToView(offSet: -14, relatedView: charmIconWrapper, relatedAttribute: .bottom)

        infoContainerView.setTopRelatedToView(offSet: 32, relatedView: iconContainerView, relatedAttribute: .bottom)
        infoContainerView.setLeft(offSet: 24)
        infoContainerView.setRight(offSet: -24)

        dateRangeKeyLabel.setTop(offSet: 0)
        dateRangeKeyLabel.setLeft(offSet: 0)

        dateRangeValueLabel.setTop(offSet: 0)
        dateRangeValueLabel.setRight(offSet: 0)

        vitalKeyLabel.setTopRelatedToView(offSet: X_SPACE, relatedView: dateRangeKeyLabel, relatedAttribute: .bottom)
        vitalKeyLabel.setLeft(offSet: 0)
        vitalKeyLabel.setBottom(offSet: 0)

        vitalValueLabel.setTopRelatedToView(offSet: X_SPACE, relatedView: dateRangeValueLabel, relatedAttribute: .bottom)
        vitalValueLabel.setRight(offSet: 0)
      //  vitalValueLabel.setBottom(offSet: 0)

        descriptionLabel.setTopRelatedToView(offSet: X_SPACE, relatedView: infoContainerView, relatedAttribute: .bottom)
        descriptionLabel.setLeft(offSet: 24)
        descriptionLabel.setRight(offSet: -24)

        yesSyncBtn.setTopRelatedToView(offSet: 32, relatedView: descriptionLabel, relatedAttribute: .bottom)
        yesSyncBtn.setLeft(offSet: X_SPACE)
        yesSyncBtn.setRight(offSet: -X_SPACE)
        yesSyncBtn.setHeight(constant: PILL_BTN_HEIGHT)

        cancelBtn.setTopRelatedToView(offSet: SPACING_12, relatedView: yesSyncBtn, relatedAttribute: .bottom)
        cancelBtn.setLeft(offSet: X_SPACE)
        cancelBtn.setRight(offSet: -X_SPACE)
        cancelBtn.setHeight(constant: ACTION_BTN_HEIGT)
        cancelBtn.setBottom(offSet: -20)
    }

    // MARK: - Public API

    func configure(vitalName: String?, dateRange: String) {
        var vitalNewName = vitalName ?? ""
        if vitalNewName.isBlank() {
            vitalNewName = getString(key: "com.charmphr.wellness.vitals")
        }
        let patient = getSelectedPatient()
        titleLabel.text = getString(key: "com.charmphr.wellness.healthkit.sync.confirm.title", with: [vitalNewName, patient.fullName ?? ""])

        dateRangeKeyLabel.text = getString(key: "com.charmphr.wellness.healthkit.sync.confirm.daterange")
        dateRangeValueLabel.text = dateRange

        vitalKeyLabel.text = vitalNewName
        vitalValueLabel.text = getString(key: "com.charmphr.wellness.healthkit.sync.confirm.records", with: ["\(delegate?.recordCount ?? 0)"])

        patientImageView.initialLabel.font = .systemFont(ofSize: FONT_SIZE_MEDNORM, Weight: .bold)

        patientImageView.setInitialsAndImage(initials: patient.fullName?.formInitials() ?? "", image: patient.patientPhoto)

        let appName: String = AppConfig.sharedInstance.appDisplayName ?? "PHR"
        let fullText = getString(key: "com.charmphr.wellness.healthkit.sync.confirm.description", with: [patient.fullName ?? "", appName])
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
            .font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular),
            .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        ])
        
        let patientName = patient.fullName ?? ""
        if let range = fullText.range(of: patientName + "'s") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([.font : UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .bold)], range: nsRange)
        } else if let range = fullText.range(of: patientName) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([.font : UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .bold)], range: nsRange)
        }
        descriptionLabel.attributedText = attributedString
    }

    func addConstraintPostViewLoad() {
        setHorizontal(offSet: X_SPACE)
        setCenterY()
    }

    // MARK: - Actions

    @objc private func onYesSyncBtnClicked() {
        delegate?.onYesSyncClicked()
    }

    @objc private func onCancelBtnClicked() {
        delegate?.onCancelClicked()
    }
}
