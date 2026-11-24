//
//  InsuranceListView.swift
//  phr
//
//  Created by Raghul D on 31/05/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit

class InsuranceListView: UIView{
    
//    let insuranceListTableView = UITableView()
//    let insuranceRefreshControl = UIRefreshControl()
//    let insuranceNoData = NoDataView()
//
//    let activityIndicatorView = UIActivityIndicatorView()
//
//    let bottomImageView = UIImageView()
//
//    init() {
//        super.init(frame: .zero)
//        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
//        setSubViews()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setSubViews() {
//
//        self.addSubview(bottomImageView)
//        self.addSubview(insuranceListTableView)
//        self.addSubview(activityIndicatorView)
//        self.addSubview(insuranceNoData)
//
//        insuranceListTableView.addSubview(insuranceRefreshControl)
//
//
//        //Property
//
//      //  insuranceNoData.backgroundColor =
//
////
//        insuranceListTableView.separatorStyle = .none
//        insuranceListTableView.backgroundColor = .clear
//        bottomImageView.image = #imageLiteral(resourceName: "insurance_healthPassport")
//        //constraints
//
//
////        headerLayout.setTop(offSet: 64)
//
//
//        bottomImageView.setLeft(offSet: 0)
//        bottomImageView.setRight(offSet: 0)
//        bottomImageView.setSafeAreaBottom(offset: 0)
//
//        insuranceListTableView.setRight(offSet: 0)
//        insuranceListTableView.setLeft(offSet: 0)
//        insuranceListTableView.setSafeAreaBottom(offset: 0)
//        insuranceListTableView.setSafeAreaTop(offset: 0)
//      //  insuranceListTableView.contentInset = .init(top: X_SPACE/2, left: 0, bottom: X_SPACE/2, right: 0)
//
//        activityIndicatorView.setCenterX()
//        activityIndicatorView.setCenterY()
//
//        insuranceNoData.setCenterY()
//        insuranceNoData.setCenterX()
//
//        hideActivityIndicator()
//
//    }
//
//
//    func showActivityIndicator()
//    {
//        activityIndicatorView.startAnimating()
//        bottomImageView.isHidden = true
//        insuranceListTableView.isHidden = true
//        insuranceNoData.isHidden = true
//        self.isUserInteractionEnabled = false
//    }
//
//    func showNoDataPage() {
//        hideActivityIndicator()
//        insuranceListTableView.isHidden = true
//        bottomImageView.isHidden = true
//        insuranceNoData.isHidden = false
//        insuranceNoData.setImage(enum: .noData , title: getString(key: "com.charmphr.action.noData.title"), message: nil)
//    }
//
//    func showErrorPage(error: Error) {
//        hideActivityIndicator()
//        insuranceListTableView.isHidden = true
//        bottomImageView.isHidden = true
//        insuranceNoData.isHidden = false
//        insuranceNoData.setImage(enum: .oops, title: CharmUtil.getErrorMsg(forCode: CharmUtil.getErrorCode(error: error)), message: nil)
//    }
//
//    func hideActivityIndicator()
//    {
//
//        if insuranceRefreshControl.isRefreshing {
//            insuranceRefreshControl.endRefreshing()
//        }
//
//        activityIndicatorView.stopAnimating()
//        insuranceListTableView.isHidden = false
//        self.isUserInteractionEnabled = true
//    }

}
