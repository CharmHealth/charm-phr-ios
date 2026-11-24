//
//  CardListView.swift
//  phr
//
//  Created by Raghul D on 19/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation

class CardListView: UIView {

    var cardSegmentControl: UISegmentedControl = UISegmentedControl(items: ["",""])
    let cardListTableView = UITableView()
    let cardRefreshControl = UIRefreshControl()
    let cardNoData = NoDataView()

    let activityIndicatorView = UIActivityIndicatorView()

    weak var delegate : CardListViewController?
    
    init(delegate: CardListViewController) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubViews() {
        
        
        let headerLayout = UIView()
        headerLayout.addSubview(cardSegmentControl)
        self.addSubview(headerLayout)
        
        
        let mainLayout = UIView()
        self.addSubview(mainLayout)
        mainLayout.addSubview(cardListTableView)
        mainLayout.addSubview(activityIndicatorView)
        mainLayout.addSubview(cardNoData)
        cardListTableView.addSubview(cardRefreshControl)
        
        //Property
        
        headerLayout.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        headerLayout.setHeight(constant: HEADER_HEIGHT)
        cardListTableView.backgroundColor = .clear
        cardListTableView.separatorStyle = .none

        cardSegmentControl.setTitle(getString(key: "com.charmphr.card.patient.title"), forSegmentAt: 0)
        cardSegmentControl.setTitle(getString(key: "com.charmphr.card.practice.title"), forSegmentAt: 1)
        cardSegmentControl.selectedSegmentIndex = 0
        cardSegmentControl.addProperties(fontSize: 13)
        
        headerLayout.setSafeAreaTop(offset: 0)
        headerLayout.setRight(offSet: 0)
        headerLayout.setLeft(offSet: 0)
       
        cardSegmentControl.setRight(offSet: -16)
        cardSegmentControl.setLeft(offSet: 16)
        cardSegmentControl.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        cardSegmentControl.setCenterY()

        mainLayout.setRight(offSet: 0)
        mainLayout.setLeft(offSet: 0)
        mainLayout.setTopRelatedToView(offSet: 0, relatedView: headerLayout , relatedAttribute: .bottom)
        mainLayout.setSafeAreaBottom(offset: 0)
        
        cardListTableView.setRight(offSet: 0)
        cardListTableView.setLeft(offSet: 0)
        cardListTableView.setSafeAreaBottom(offset: 0)
        cardListTableView.setTop(offSet: 0)
      //  cardListTableView.contentInset = .init(top: X_SPACE/2, left: 0, bottom: X_SPACE/2, right: 0)
        
        activityIndicatorView.setCenterX()
        activityIndicatorView.setCenterY()
        
        cardNoData.setCenterY()
        cardNoData.setCenterX()
        
        hideActivityIndicator()
    }

    
    func showActivityIndicator(hideTableView: Bool = true)
    {
        activityIndicatorView.startAnimating()
        if hideTableView {
            cardListTableView.isHidden = true
            cardNoData.isHidden = true
        }
        self.isUserInteractionEnabled = false
    }
    
    func showNoDataPage(withMessage:Bool = false) {
        hideActivityIndicator()
        cardListTableView.isHidden = true
        cardNoData.isHidden = false
        var message:String? = nil
        if withMessage {
            message = "\(getString(key: "com.charmphr.action.noData.message"))\(getString(key: "com.charmphr.card.nodata.message"))"
        }
        //cardNoData.setImage(enum: .noData , title: getString(key: "com.charmphr.action.noData.title"), message: nil)
        cardNoData.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: message)

    }
    
    func showErrorPage(error: Error) {
        hideActivityIndicator()
        cardListTableView.isHidden = true
        cardNoData.isHidden = false
        cardNoData.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
    }
    
    func hideActivityIndicator()
    {
        
        if cardRefreshControl.isRefreshing {
            cardRefreshControl.endRefreshing()
        }
        
        activityIndicatorView.stopAnimating()
        cardListTableView.isHidden = false
        self.isUserInteractionEnabled = true
    }
}

