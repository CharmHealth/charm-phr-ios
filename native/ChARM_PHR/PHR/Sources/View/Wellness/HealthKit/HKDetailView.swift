//
//  HKDetailView.swift
//  phr
//
//  Created by Raghul D on 25/06/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import Foundation


class HKDetailView: UIView , UITableViewDataSource, UITableViewDelegate{
    
    private weak var delegate: HKDetailViewController? = nil
    
    private let scrollView = UIScrollView()
    private let vitalTableView: MDAutoGrowingTableView = MDAutoGrowingTableView()
    private let activityIndicator = UIActivityIndicatorView()
    private var noDataView: NoDataView? = nil

    init(delegate: HKDetailViewController){
        super.init(frame: .zero)
        self.delegate = delegate
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews(){
        
        scrollView.setBackgroundColor(bgColor: APPLICATION_BACKGROUND_COLOR)
    
        let wrapperView = UIStackView()
        self.addSubview(scrollView)
        
        scrollView.addSubview(wrapperView)
        
        wrapperView.addArrangedSubview(vitalTableView)
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        activityIndicator.stopAnimating()
        
        if #available(iOS 15.0, *) {
            vitalTableView.sectionHeaderTopPadding = 0
        }
        
        vitalTableView.separatorStyle = .singleLine
        vitalTableView.register(HKVitalTVCell.self, forCellReuseIdentifier: "HKVitalTVCell")
        vitalTableView.isScrollEnabled = true
        vitalTableView.dataSource = self
        vitalTableView.delegate = self
        vitalTableView.separatorColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        
        vitalTableView.layer.cornerRadius = 8
        vitalTableView.backgroundColor = .white
        
        vitalTableView.heightConstraint = NSLayoutConstraint.init(item: vitalTableView, attribute:.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        vitalTableView.addConstraint(vitalTableView.heightConstraint)
        
        
        wrapperView.setTop(offSet: 0)
        wrapperView.setLeft(offSet: 0)
        wrapperView.setWidth(constant: applicationFrame.width)
        wrapperView.setBottom(offSet: 0)
        
        vitalTableView.setLeft(offSet: X_SPACE)
        vitalTableView.setWidth(constant: applicationFrame.width - (2 * X_SPACE))
        vitalTableView.setTop(offSet: 28)
        
        scrollView.setTop(offSet: 0)
        scrollView.setHorizontal()
        scrollView.setBottom(offSet: 0)
        
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTotalCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "HKVitalTVCell") as? HKVitalTVCell {
            
            if let bpModel = delegate?.bpModelList?.getElement(at: indexPath.row){
                tableViewCell.setTableViewCell(data: bpModel)
                return tableViewCell
            }
            else if let model = delegate?.metricValueList.getElement(at: indexPath.row) {
                tableViewCell.setTableViewCell(metricValue: model)
                return tableViewCell
            }
        }
    
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var swipeActions:[UIContextualAction] = []
            
        if let bpModel = delegate?.bpModelList?.getElement(at: indexPath.row){
            let deleteAction = UIContextualAction(style: .destructive, title: getString(key: "com.charmphr.wellness.healthkit.remove"), handler: { [weak self] (action, view, completionHandler) in
                        //
                self?.delegate?.onBPViewRemoveClicked(bpModel: bpModel)
                completionHandler(true)
            })
            deleteAction.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
            swipeActions.append(deleteAction)
        }
        else if let model = delegate?.metricValueList.getElement(at: indexPath.row){
            let deleteAction = UIContextualAction(style: .destructive, title: getString(key: "com.charmphr.wellness.healthkit.remove"), handler: { [weak self] (action, view, completionHandler) in
                        //
                self?.delegate?.onVitalViewRemoveClicked(model: model)
                completionHandler(true)
            })
            deleteAction.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
            swipeActions.append(deleteAction)
        }
        
        
        
        if !swipeActions.isEmpty {
            return UISwipeActionsConfiguration(actions: swipeActions)
        }
        
       return nil
            
        
        
    }
    
    func getTotalCount() -> Int {
        if let bpModelList = delegate?.bpModelList {
            return bpModelList.count
        }
        else{
            return delegate?.metricValueList.count ?? 0
        }
    }
    
    func reloadData(){
        vitalTableView.reloadData()
    }
    
    func showNoDataView() {
        
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
