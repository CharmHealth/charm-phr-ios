//
//  ReminderTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 23/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ReminderTodayTableViewCell: UITableViewCell{
    
    private let reminderTodayItemView = ReminderTodayItemView()
    var vcDelegate: ReminderViewController?
    private var todayReminderArray: TodayReminderPOJO? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(reminderTodayItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        reminderTodayItemView.setHorizontal(offSet: X_SPACE)
        reminderTodayItemView.setTop(offSet: PADDING_5)
        reminderTodayItemView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: TodayReminderPOJO, indexPath: IndexPath){
        
        todayReminderArray = data
        reminderTodayItemView.tableViewCellDelegate = self
        reminderTodayItemView.timeLabel.text = data.time?.getStringFromDate(dateFormat: charmDisplayTimeFormat)
        
        if data.reminderPOJOList.count == 1{
            reminderTodayItemView.selectAllBtn.isHidden = true
        }
        else{
            reminderTodayItemView.selectAllBtn.isHidden = false
            reminderTodayItemView.selectAllBtn.tag = indexPath.row
            reminderTodayItemView.selectAllBtn.addTarget(self, action: #selector(onClickSelectAllBtn(btn:)), for: .touchUpInside)

        }
        reminderTodayItemView.removePreviousViews()
        
        guard !data.reminderPOJOList.isEmpty else { return }
        for (i,reminderPOJO) in data.reminderPOJOList.enumerated(){
            reminderTodayItemView.setDrugView(reminderPOJO: reminderPOJO, index: i)
        }
    }
    
    @objc private func onClickSelectAllBtn(btn: UIButton){
        vcDelegate?.presentReminderDetailDialogVC(btn: btn)
    }
    
    func presentReminderDetailDialogVC(uiView: UIView){
        
        if let reminderPOJO = todayReminderArray?.reminderPOJOList[uiView.tag]{
            let timeObj = Date.getDateFromString(dateFormat: charmDisplayTimeFormat, dateString: reminderTodayItemView.timeLabel.text ?? "")
            let reminderDetailDialogViewController = ReminderDetailDialogViewController(reminderPOJO: reminderPOJO, isFromNotification: false, timeObj: timeObj)
            reminderDetailDialogViewController.delegate = vcDelegate
            reminderDetailDialogViewController.historyDelegate = vcDelegate
            reminderDetailDialogViewController.modalPresentationStyle = .overCurrentContext
            reminderDetailDialogViewController.modalTransitionStyle = .crossDissolve
            vcDelegate?.navigationController?.present(reminderDetailDialogViewController, animated: true)
        }
    }
}

class ReminderAllTableViewCell: UITableViewCell{
    
    let reminderAllItemView = ReminderAllItemView()
    weak var delegate: ReminderViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(reminderAllItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        reminderAllItemView.delegate = self
        reminderAllItemView.setHorizontal(offSet: X_SPACE)
        reminderAllItemView.setTop(offSet: PADDING_5)
        reminderAllItemView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: ReminderDetails, indexPath: IndexPath){
        
        reminderAllItemView.titleLabel.text = data.title
        reminderAllItemView.descriptionLabel.text = data.descripiton
        reminderAllItemView.setIconAndScheduleValues(reminderDetails: data)
        
        var status: String = ""
        if data.isActive{
            status = ACTIVE
        }
        else if data.isUpcoming{
            status = UPCOMING
        }
        else if data.isCompleted{
            status = COMPLETED
        }
        reminderAllItemView.setStatusLabel(status: status)
    }
}

