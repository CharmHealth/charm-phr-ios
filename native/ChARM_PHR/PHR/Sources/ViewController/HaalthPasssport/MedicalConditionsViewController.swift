//
//  MedicalConditionsViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 29/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

private let FILTERED_BY_VALUE_TAG = 3001

class MedicalConditionsViewController: CustomViewControllerWithTableView,
    UITableViewDataSource,
    CharmConnectionV2HandlerDelegate,
    AddViewControllerDelegate,
    MedConditionTableViewCellDelegate ,
    SelectValueViewControllerDelagate{

    // MARK: - Properties

    var conditions: [MedicalCondition] = []
    var selectedFilter: String = "Active"
    var selectedIndex: Int? = nil

    var charmConnectionHandler: CharmConnectionHandler?

    private let canAddCondition = RbacUtil.checkPrivilege(privilege: .ADD_PROBLEM)

    private let filteredByLabel = UILabel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        createTableviewAndSubViews(tableViewStyle: .plain)
        self.navigationItem.title = getString(key: "com.charmphr.problem.title")

        var barBtnItems: [UIBarButtonItem] = []
        
        if canAddCondition && !AppConfig.sharedInstance.isCustomBrandApp && canAllowAddEntry {
            barBtnItems.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addConditionClicked)))
        }
        
        let filter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(filterViewClicked))
        barBtnItems.append(filter)
        self.navigationItem.rightBarButtonItems = barBtnItems

        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.separatorColor = .clear
        customTableView.rowHeight = UITableView.automaticDimension
        customTableView.estimatedRowHeight = 80
        customTableView.tableFooterView = UIView()
        customTableView.register(MedConditionTableViewCell.self, forCellReuseIdentifier: "MedConditionTableViewCell")

        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)

        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)

       // createFilterBar()
        loadRequest()
    }

    // MARK: - Filter Bar


//    private func updateFilterLabel() {
//        let label = bottomCustomView.viewWithTag(FILTERED_BY_VALUE_TAG) as? UILabel
//        if selectedFilter.isEmpty {
//            label?.text = getString(key: "com.charmphr.medCondition.filter.all")
//        } else {
//            label?.text = selectedFilter
//        }
//    }

    // MARK: - Actions

    @objc private func addConditionClicked() {
        let vc = AddMedicalConditionViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editConditionClicked(condition: MedicalCondition) {
        let vc = AddMedicalConditionViewController()
        vc.delegate = self
        vc.editMedicalCondition = condition
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func onPullToRefresh() {
        hideSwipeActionButtons()
        conditions = []
        loadRequest()
    }
    
    @objc private func filterViewClicked()
    {
        let selectValueViewController = SelectValueViewController()
        selectValueViewController.delegate = self
        selectValueViewController.title = getString(key: "com.charmphr.prescriptions.FilteredBy.title")
        var filterOptions: [String] = [getString(key: "com.charmphr.medCondition.filter.all")]
        filterOptions.append(contentsOf: problemStatusOptions)
        selectValueViewController.arrayOfValueToBeShown  = filterOptions

        if selectedFilter.isBlank() {
            selectValueViewController.selectedValueIndex = 0
        }
        else{
            selectValueViewController.selectedValueIndex = filterOptions.firstIndex(of: selectedFilter)
        }
        navigationController?.pushViewController(selectValueViewController, animated: true)
    }

    @objc private func filterBarTapped() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        let filterOptions: [(String, String)] = [
            (getString(key: "com.charmphr.medCondition.filter.all"), ""),
            ("Active", "Active"),
            ("Inactive", "Inactive"),
            ("Resolved", "Resolved")
        ]
        for option in filterOptions {
            let action = CharmUtil.getAlertAction(title: option.0, style: .default) { [weak self] _ in
                self?.conditionFilterDidSelect(status: option.1)
            }
            if option.1 == selectedFilter {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = filteredByLabel
            popover.permittedArrowDirections = .down
        }
        //alert.addAction(UIAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - API

    func loadRequest() {
        if conditions.isEmpty && !refreshControl.isRefreshing {
            showActivityIndicator()
        }
        charmConnectionHandler?.fetchMedicalCondition(
            identificationKey: "fetchConditions",
            status: selectedFilter
        )
    }

    // MARK: - Helpers

    func hideSwipeActionButtons() {
        if let prevIndex = selectedIndex {
            let indexPath = IndexPath(row: prevIndex, section: 0)
            if let cell = customTableView.cellForRow(at: indexPath) as? MedConditionTableViewCell {
                cell.medConditionItemView.setRowActionForSwipeRight(duration: 0.4)
                selectedIndex = nil
            }
        }
    }

    // MARK: - TableView DataSource

    private func updateEmptyState() {
        if conditions.isEmpty {
            noDataBackGroundView.setImage(
                enum: .noData,
                title: getString(key: "com.charmphr.action.noData.title"),
                message: nil
            )
        } else {
            noDataBackGroundView.hideSubView(bool: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conditions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedConditionTableViewCell") as? MedConditionTableViewCell
        if let cell = cell {
            cell.delegate = self
            
            if let condition = conditions.getElement(at: indexPath.row) {
                cell.setTableViewCell(data: condition, indexPath: indexPath)
            }

            cell.medConditionItemView.gestureRecognizers?.forEach {
                cell.medConditionItemView.removeGestureRecognizer($0)
            }
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
            swipeLeft.direction = .left
            cell.medConditionItemView.addGestureRecognizer(swipeLeft)

            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
            swipeRight.direction = .right
            cell.medConditionItemView.addGestureRecognizer(swipeRight)

            if let selectedIndex = selectedIndex {
                if indexPath.row == selectedIndex {
                    cell.setRowActionForSwipeLeft(duration: 0, isAddedByPatient: conditions[indexPath.row].allowEdit)
                } else {
                    cell.medConditionItemView.setRowActionForSwipeRight(duration: 0)
                }
            }
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        hideSwipeActionButtons()
        
        if let condition = conditions.getElement(at: indexPath.row) {
            if condition.allowEdit {
                editConditionClicked(condition: condition)
            }
        }
    }

    // MARK: - Swipe

    @objc func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        guard let itemView = sender.view as? MedConditionItemView,
              let cell = itemView.superview?.superview as? MedConditionTableViewCell else { return }

        let index = customTableView.indexPath(for: cell)?.row ?? -1
        guard index >= 0 else { return }

        switch sender.direction {
        case .left:
            let condition = conditions[index]
            guard condition.allowEdit else { return }
            var allowLeftSwipe = true
            if let prevIndex = selectedIndex {
                if prevIndex == index {
                    allowLeftSwipe = false
                } else {
                    let prevIndexPath = IndexPath(row: prevIndex, section: 0)
                    if let prevCell = customTableView.cellForRow(at: prevIndexPath) as? MedConditionTableViewCell {
                        prevCell.medConditionItemView.setRowActionForSwipeRight(duration: 0.4)
                        selectedIndex = nil
                    }
                }
            }
            if allowLeftSwipe {
                selectedIndex = index
                cell.setRowActionForSwipeLeft(duration: 0.4, isAddedByPatient: true)
            }
        case .right:
            if selectedIndex == index {
                selectedIndex = nil
                itemView.setRowActionForSwipeRight(duration: 0.4)
            }
        default:
            break
        }
    }

    // MARK: - MedConditionTableViewCellDelegate

    func onDeleteBtnClicked(tableViewCell: MedConditionTableViewCell, condition: MedicalCondition) {
        if selectedIndex != nil {
            tableViewCell.medConditionItemView.setRowActionForSwipeRight(duration: 0.4)
        }
        selectedIndex = nil

        CharmUtil.createDeleteAndCancelAlertWith(
            title: nil,
            msg: getString(key: "com.charmphr.MedicalCondition.alert.delete"),
            deleteClicked: { [weak self] in
                
                guard let self = self else { return  }
                
                self.showActivityIndicatorFront()
                
                let index = self.conditions.firstIndex(where: { $0.medicalConditionMapId == condition.medicalConditionMapId }) ?? 0
                self.charmConnectionHandler?.deleteMedicalCondition(
                    condition: condition,
                    identificationKey: "deleteCondition_\(index)"
                )
            }
        )
    }

    func onMoreBtnClicked(indexPath: IndexPath) {
        customTableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Filter Selection

    private func conditionFilterDidSelect(status: String) {
        selectedFilter = status
       // updateFilterLabel()
        conditions = []
        loadRequest()
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        
        var filter = ""
        
        let actualSelectedRow = selectedRow - 1
        
        if actualSelectedRow >= 0 {
            filter = problemStatusOptions.getElement(at: actualSelectedRow) ?? ""
        }
        conditionFilterDidSelect(status: filter)
    }

    // MARK: - AddViewControllerDelegate

    func addViewControllerDataAdded(message: String?) {
        
        if let message {
            CharmUtil.showToast(controller: self, message: message, seconds: 2)
        }
        
        conditions = []
        loadRequest()
    }

    // MARK: - CharmConnectionV2HandlerDelegate

    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchConditions" {
            if let conditionList = response as? [MedicalCondition] {
                conditions = conditionList
                updateEmptyState()
                hideActivityIndicator()
                customTableView.reloadData()
            }
        } else if identificationKey.hasPrefix("deleteCondition"){
            hideActivityIndicator()
            
            if let row = identificationKey.components(separatedBy: "_").last?.toIntOrNil(){
                conditions.remove(at: row)
                self.removeCellFromTableViewAt(arrayOfindexPath: [IndexPath(row: row, section: 0)])
            }
            
            if let message = response as? String {
                CharmUtil.showToast(controller: self, message: message, seconds: 2)
            }
            
            
            updateEmptyState()
            
        }
    }

    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        hideActivityIndicator()
        if identificationKey == "fetchConditions" {
            noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        } else {
            CharmUtil.createOkayAlertWith(error: error)
        }
    }

    override func hideActivityIndicator() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        customTableView.isHidden = false
        activityIndicatorView.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
