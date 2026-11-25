//
//  AnnouncementViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 15/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AnnouncementViewController: CustomViewControllerWithTableView, CharmConnectionV2HandlerDelegate, UITableViewDataSource
{
    var charmConnectionHandler : CharmConnectionHandler?
    
    var arrayOfAnnouncement : [Announcement] = []
    var numberOfPracticeDataGotForAnnouncement = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = getString(key: "com.charmphr.Announcement.title")
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
    
        self.createTableviewAndSubViews(tableViewStyle: .plain)
    
        customTableView.separatorColor = .clear
        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        customTableView.register(AnnouncementTableViewCell.self, forCellReuseIdentifier: "AnnouncementTableViewCell")
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        
        activityIndicatorView.hidesWhenStopped = true
        fetchAnnouncement()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customTableView.reloadData()
        if let mainViewController = self.parent as? MainViewController
        {
            mainViewController.setTitleName(name: getString(key: "com.charmphr.Announcement.title"))
        }
    }
    
    override func noDataViewRetryBtnClicked() {
        fetchAnnouncement()
    }
    
    @objc func onUIRefreshChange(){
        fetchAnnouncement()
    }
    
    func fetchAnnouncement()
    {
        if refreshControl.isRefreshing != true{
            showActivityIndicator()
        }
        charmConnectionHandler?.fetchAnnouncement(identificationKey: "announcementList")
    }
    
    // MARK: - collectionview delegate methods
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrayOfAnnouncement.isEmpty
        {
            self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: "")
        }
        else
        {
            self.noDataBackGroundView.hideSubView(bool: true)
        }
        return arrayOfAnnouncement.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementTableViewCell") as? AnnouncementTableViewCell{
            
            let announcement = arrayOfAnnouncement[indexPath.row]
            tableViewCell.setTableViewCell(data: announcement)
            return tableViewCell
        }
        return UITableViewCell()
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !arrayOfAnnouncement.isEmpty
        {
            let announcement = arrayOfAnnouncement[indexPath.row]
            
            if !(announcement.isRead ) {
                announcement.isRead = true
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementTableViewCell") as? AnnouncementTableViewCell
                tableViewCell?.announcementItemView.setFontWeight(isRead: announcement.isRead)
            }
            
            let announcementDetailVC = AnnouncementsDetailViewController()
            announcementDetailVC.announcement = announcement
            self.navigationController?.pushViewController(announcementDetailVC, animated: true)
        }
    }
        
//MARK: - ConnectionHandler delegate methods
        
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        hideActivityIndicator()
        if identificationKey == "announcementList"
        {
            if let resp = response as? [Announcement]{
                arrayOfAnnouncement = resp
                customTableView.reloadData()
            }
        }
    }
        
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "announcementList"
        {
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
        self.hideActivityIndicator()
    }
}
