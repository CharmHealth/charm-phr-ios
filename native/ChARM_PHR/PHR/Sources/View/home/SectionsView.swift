//
//  SectionsView.swift
//  phr
//
//  Created by Raghul D on 04/11/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

fileprivate let separatorColor:UInt = 0x00000029
fileprivate let moduleNotificationSize: CGFloat = 23
fileprivate let sectionCellIdentifier = "SectionsTableViewCell"

class SectionsView: UIView, UITableViewDataSource, UITableViewDelegate {

    private weak var delegate: SectionsViewController? = nil

    private let engagementLabel = UILabel()
    private let billingLabelView = UIView()
    private let billingLabel = UILabel()
    private let recordsLabel = UILabel()
    private let resourceLabel = UILabel()

    private let billingNotificationLabel = UILabel()
    private var billingNotificationWidthConstraint:NSLayoutConstraint? = nil

    private let engagementTableView = MDAutoGrowingTableView()
    private let billingTableView = MDAutoGrowingTableView()
    private let recordsTableView = MDAutoGrowingTableView()
    private let resourceTableView = MDAutoGrowingTableView()


    let scrollView = UIScrollView()
    private let sectionStack = UIStackView()

    private let noDataView = NoDataView()

    private let activityIndicator = UIActivityIndicatorView()

    init(){
        super.init(frame: .zero)
        setSubViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setSubViews(){

        let itemWidth = applicationFrame.width - (2 * X_SPACE)
        
        self.addSubview(scrollView)
        self.addSubview(noDataView)
        self.addSubview(activityIndicator)

        scrollView.addSubview(sectionStack)

        sectionStack.axis = .vertical
        sectionStack.alignment = .center
        sectionStack.spacing = 12
        sectionStack.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        sectionStack.isLayoutMarginsRelativeArrangement = true

        sectionStack.addArrangedSubview(engagementLabel)
        sectionStack.addArrangedSubview(engagementTableView)
        sectionStack.addArrangedSubview(billingLabelView)
        sectionStack.addArrangedSubview(billingTableView)
        sectionStack.addArrangedSubview(recordsLabel)
        sectionStack.addArrangedSubview(recordsTableView)
        sectionStack.addArrangedSubview(resourceLabel)
        sectionStack.addArrangedSubview(resourceTableView)
        
        resourceLabel.setProperties(textKey: "com.charmphr.home.subheading.resource", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        setupTableView(resourceTableView)
        
        resourceLabel.setWidth(constant: itemWidth)
        resourceTableView.setWidth(constant: itemWidth)
        resourceTableView.heightConstraint = resourceTableView.setAndReturnHeight(constant: 0)

        billingLabelView.addSubview(billingLabel)
        billingLabelView.addSubview(billingNotificationLabel)

        sectionStack.setCustomSpacing(25, after: engagementTableView)
        sectionStack.setCustomSpacing(25, after: billingTableView)
        sectionStack.setCustomSpacing(25, after: recordsTableView)

        noDataView.setImage(enum: .noData, title: getString(key: "com.charmphr.home.sections.nodata") , message: nil)

        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)

        engagementLabel.setProperties(textKey: "com.charmphr.home.subheading.engagement", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        setupTableView(engagementTableView)

        billingLabel.setProperties(textKey: "com.charmphr.home.subheading.billing", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        setupTableView(billingTableView)

        billingNotificationLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: RED_BG_COLOR)
        billingNotificationLabel.text = ""
        billingNotificationLabel.textColor = .white
        billingNotificationLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .bold)
        billingNotificationLabel.textAlignment = .center
        billingNotificationLabel.layer.cornerRadius = 20/2
        billingNotificationLabel.layer.masksToBounds = true

        recordsLabel.setProperties(textKey: "com.charmphr.home.subheading.record", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        setupTableView(recordsTableView)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        scrollView.setTop(offSet: 0)
        scrollView.setLeft(offSet: 0)
        scrollView.setRight(offSet: 0)
        scrollView.setBottom(offSet: 0)

        sectionStack.setTop(offSet: 0)
        sectionStack.setBottom(offSet: 0)
        sectionStack.setLeft(offSet: 0)
        sectionStack.setWidth(constant: applicationFrame.width)

        engagementLabel.setWidth(constant: itemWidth)
        engagementTableView.setWidth(constant: itemWidth)
        engagementTableView.heightConstraint = engagementTableView.setAndReturnHeight(constant: 0)

        billingLabelView.setWidth(constant: itemWidth)
        billingTableView.setWidth(constant: itemWidth)
        billingTableView.heightConstraint = billingTableView.setAndReturnHeight(constant: 0)

        recordsLabel.setWidth(constant: itemWidth)
        recordsTableView.setWidth(constant: itemWidth)
        recordsTableView.heightConstraint = recordsTableView.setAndReturnHeight(constant: 0)

        activityIndicator.setCenterX()
        activityIndicator.setCenterY()

        noDataView.setCenterX()
        noDataView.setCenterY()

        billingLabel.setTop(offSet: 0)
        billingLabel.setBottom(offSet: 0)
        billingLabel.setLeft(offSet: 0)
        billingLabel.wrapWidth(maxWidth: 300)

        billingNotificationLabel.setLeftRelatedToView(offSet: 8, relatedView: billingLabel, relatedAttribute: .right)
        billingNotificationLabel.setCenterY()
        billingNotificationLabel.setHeight(constant: 20)
        billingNotificationWidthConstraint = billingNotificationLabel.setAndReturnWidth(constant: 20)
    }
    
    func setSectionViewDelegate(delegate: SectionsViewController) {
        self.delegate = delegate
    }

    private func setupTableView(_ tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SectionsTableViewCell.self, forCellReuseIdentifier: sectionCellIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        tableView.separatorInset = .zero
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .white
        tableView.addShadowAndCornerRadius(.LARGE)
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
    }

    func reloadData() {

        hideActivityIndicator()

        let engagementArr = delegate?.engagementArr
        let recordArr = delegate?.recordArr
        let resourceArr = delegate?.resourceArr
        let billingArr = delegate?.billingArr

        let engagementCount = engagementArr?.count ?? 0
        let recordCount = recordArr?.count ?? 0
        let resourceCount = resourceArr?.count ?? 0
        let billingCount = billingArr?.count ?? 0


        if engagementCount == 0 && recordCount == 0 && resourceCount == 0 && billingCount == 0 {
            noDataView.showView()
            scrollView.hideView()
        }
        else{
            noDataView.hideView()
            scrollView.showView()

            if engagementCount != 0 {
                engagementLabel.showView()
                engagementTableView.showView()
                engagementTableView.reloadData()
            }
            else{
                engagementLabel.hideView()
                engagementTableView.hideView()
            }

            if billingCount != 0 {
                billingLabelView.showView()

                let unreadCount = billingArr?.first?.unreadCount ?? 0

                if unreadCount > 0 && unreadCount <= 99
                {
                    billingNotificationLabel.text = "\(unreadCount)"
                    billingNotificationLabel.showView()
                    let widthOfLabel = billingNotificationLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10
                    billingNotificationWidthConstraint?.constant = widthOfLabel > 20 ? widthOfLabel : 20
                }
                else if unreadCount > 99
                {
                    billingNotificationLabel.setText(key: "com.charmphr.home.listView.notification.max")
                    let widthOfLabel = billingNotificationLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10
                    billingNotificationWidthConstraint?.constant = widthOfLabel > 20 ? widthOfLabel : 20

                    billingNotificationLabel.showView()
                }
                else
                {
                    billingNotificationLabel.hideView()
                }

                billingTableView.showView()
                billingTableView.reloadData()
            }
            else{
                billingLabelView.hideView()
                billingTableView.hideView()
            }

            if recordCount != 0 {
                recordsLabel.showView()
                recordsTableView.showView()
                recordsTableView.reloadData()
            }
            else{
                recordsLabel.hideView()
                recordsTableView.hideView()
            }

            if resourceCount != 0 {
                resourceLabel.showView()
                resourceTableView.showView()
                resourceTableView.reloadData()
            }
            else{
                resourceLabel.hideView()
                resourceTableView.hideView()
            }
        }
    }

    private func getModuleList(for tableView: UITableView) -> [Module]? {
        if tableView === engagementTableView {
            return delegate?.engagementArr
        } else if tableView === billingTableView {
            return delegate?.billingArr
        } else if tableView === recordsTableView {
            return delegate?.recordArr
        } else if tableView === resourceTableView {
            return delegate?.resourceArr
        }
        return nil
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getModuleList(for: tableView)?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: sectionCellIdentifier, for: indexPath) as? SectionsTableViewCell,
              let moduleList = getModuleList(for: tableView),
              indexPath.row < moduleList.count else {
            return UITableViewCell()
        }

        cell.setModule(module: moduleList[indexPath.row])
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let moduleList = getModuleList(for: tableView),
              indexPath.row < moduleList.count else { return }

        delegate?.onModuleSelected(module: moduleList[indexPath.row])
    }

    func showActivityIndicator()
    {
        self.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
        activityIndicator.showView()

        scrollView.hideView()
        noDataView.hideView()
    }

    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true
    }
}


class SectionsTableViewCell: UITableViewCell {

    private let moduleIcon = UIImageView()
    private let moduleLabel = UILabel()
    private let goIcon = UIImageView()
    private let moduleNotificationLabel = UILabel()

    private var module: Module? = nil
    private var widthConstraint: NSLayoutConstraint? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews(){
        self.layoutMargins = .zero
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.selectionStyle = .none

        contentView.addSubview(moduleIcon)
        contentView.addSubview(moduleLabel)
        contentView.addSubview(moduleNotificationLabel)
        contentView.addSubview(goIcon)

        goIcon.image = UIImage(named: "section-arrow-right")

        moduleLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)

        moduleNotificationLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: RED_BG_COLOR)
        moduleNotificationLabel.text = ""
        moduleNotificationLabel.textColor = .white
        moduleNotificationLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .bold)
        moduleNotificationLabel.textAlignment = .center
        moduleNotificationLabel.layer.cornerRadius = moduleNotificationSize / 2
        moduleNotificationLabel.layer.masksToBounds = true

        moduleIcon.setWidth(constant: 36)
        moduleIcon.setTop(offSet: 5)
        moduleIcon.setBottom(offSet: -5)
        moduleIcon.setLeft(offSet: 10)

        moduleLabel.setCenterY()
        moduleLabel.setLeftRelatedToView(offSet: 8, relatedView: moduleIcon, relatedAttribute: .right)
        moduleLabel.setRightRelatedToView(offSet: -8, relatedView: moduleNotificationLabel, relatedAttribute: .left)

        goIcon.setCenterY()
        goIcon.setWidth(constant: 24)
        goIcon.setHeight(constant: 24)
        goIcon.setRight(offSet: -8)

        moduleNotificationLabel.setRightRelatedToView(offSet: -16, relatedView: goIcon, relatedAttribute: .left)
        moduleNotificationLabel.setCenterY()
        moduleNotificationLabel.setHeight(constant: moduleNotificationSize)
        widthConstraint = moduleNotificationLabel.setAndReturnWidth(constant: moduleNotificationSize)

        moduleNotificationLabel.hideView()
    }

    func setModule(module: Module) {
        self.module = module
        moduleLabel.text = module.moduleNameFromSection ?? module.moduleName
        moduleIcon.image = UIImage(named: module.imageName ?? "Appointments")

        if module.isBilling != true {
            let unreadCount = module.unreadCount

            if unreadCount > 0 && unreadCount <= 99 {
                moduleNotificationLabel.text = "\(unreadCount)"
                moduleNotificationLabel.showView()
                let widthOfLabel = moduleNotificationLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10
                widthConstraint?.constant = widthOfLabel > 23 ? widthOfLabel : 23
            }
            else if unreadCount > 99 {
                moduleNotificationLabel.setText(key: "com.charmphr.home.listView.notification.max")
                let widthOfLabel = moduleNotificationLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10
                widthConstraint?.constant = widthOfLabel > 23 ? widthOfLabel : 23
                moduleNotificationLabel.showView()
            }
            else {
                moduleNotificationLabel.hideView()
            }
        }
        else {
            moduleNotificationLabel.hideView()
        }
    }

    func getModule() -> Module? {
        return module
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // No-op to prevent selection style changes
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        moduleLabel.text = nil
        moduleIcon.image = nil
        moduleNotificationLabel.hideView()
        module = nil
    }
}


class SectionsItemView: UIView {
    
    private let moduleIcon = UIImageView()
    private let moduleLabel = UILabel()

    private var module:Module? = nil
    
    
    private let moduleNotificationLabel = UILabel()
    
    private var widthConstraint:NSLayoutConstraint? = nil
    
    init() {
        super.init(frame: .zero)
        initSubviews()
    }


    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews(){
        
        let goIcon = UIImageView()
        

  
        
        self.addSubview(moduleIcon)
        self.addSubview(moduleLabel)
        self.addSubview(moduleNotificationLabel)
        self.addSubview(goIcon)
        
        goIcon.image = UIImage(named: "section-arrow-right")
        
        moduleLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        
        moduleNotificationLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: RED_BG_COLOR)
        moduleNotificationLabel.text = ""
        moduleNotificationLabel.textColor = .white
        moduleNotificationLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .bold)
        moduleNotificationLabel.textAlignment = .center
        moduleNotificationLabel.layer.cornerRadius = moduleNotificationSize / 2
        moduleNotificationLabel.layer.masksToBounds = true
       
        moduleIcon.setWidth(constant: 36)
        //moduleIcon.setHeight(constant: 36)
        moduleIcon.setTop(offSet: 5)
        moduleIcon.setBottom(offSet: -5)
        moduleIcon.setLeft(offSet: 10)
        
        moduleLabel.setCenterY()
        moduleLabel.setLeftRelatedToView(offSet: 8, relatedView: moduleIcon, relatedAttribute: .right)
        moduleLabel.setRightRelatedToView(offSet: -8, relatedView: moduleNotificationLabel, relatedAttribute: .left)
        
        
        goIcon.setCenterY()
        goIcon.setWidth(constant: 24)
        goIcon.setHeight(constant: 24)
        goIcon.setRight(offSet: -8)
        
        moduleNotificationLabel.setRightRelatedToView(offSet: -16, relatedView: goIcon, relatedAttribute: .left)
        moduleNotificationLabel.setCenterY()
        moduleNotificationLabel.setHeight(constant: moduleNotificationSize)
        widthConstraint = moduleNotificationLabel.setAndReturnWidth(constant: moduleNotificationSize)

        moduleNotificationLabel.hideView()
    }
    
    func setModule(module: Module) {
        self.module = module
        moduleLabel.text = module.moduleNameFromSection ?? module.moduleName
        moduleIcon.image = UIImage(named: module.imageName ?? "Appointments")
        
        if module.isBilling != true {
            
            let unreadCount = module.unreadCount
            
            if unreadCount > 0 && unreadCount <= 99
            {
                moduleNotificationLabel.text = "\(unreadCount)"
                moduleNotificationLabel.showView()
                let widthOfLabel = moduleNotificationLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10
                widthConstraint?.constant = widthOfLabel > 23 ? widthOfLabel : 23
            }
            else if unreadCount > 99
            {
                moduleNotificationLabel.setText(key: "com.charmphr.home.listView.notification.max")
                let widthOfLabel = moduleNotificationLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10
                widthConstraint?.constant = widthOfLabel > 23 ? widthOfLabel : 23
                
                moduleNotificationLabel.showView()
            }
            else
            {
                moduleNotificationLabel.hideView()
            }
        }
        else{
            moduleNotificationLabel.hideView()
        }
    }
    
    func getModule() -> Module? {
        return module
    }
    
    
    func setModuleLabel(labelKey: String) {
    
        moduleLabel.setText(key: labelKey)
    }
    
    func setModuleTextColor(textcolor: UInt) {
        moduleLabel.setTextColor(fontcolor: textcolor)
    }
    
    func setModuleIcon(namedImage: String) {
        moduleIcon.image = UIImage(named: namedImage)
    }

}
