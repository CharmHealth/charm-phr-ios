//
//  CustomViewControllerWithTableViewViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 09/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//
//

import UIKit

class CustomViewControllerWithTableView: UIViewController , UITableViewDelegate , NoDataViewDelegate
{
    let defaultCustomViewheight: CGFloat = 0
    var topViewHeight: CGFloat = 0
    var heightConstraintOfBottomView : NSLayoutConstraint?
    
    var tableviewCellInsets = TABLEVIEWCELL_INSETS
    
    var isFooterViewRequired = true
    
    var customTableView : TPKeyboardAvoidingTableView!
    let refreshControl = UIRefreshControl()
    let titleCustomView = UIView()
    var spaceBwTitleCustomViewAndCustomTableView = SPACE_BW_TWO_SECTIONS
    //To add any custom bottom view below tableview eg: filter by view in prescription
    //by default height of this view is 0 (defaultCustomViewheight)
    //If we add this view, call this method changeBottomViewHeight to adjust height
    //heightConstraintOfBottomView defines the height constraint of bottomCustomView
    let bottomCustomView = UIView()
    
    var previousNavigationToolBarYPosition : CGFloat? = nil
    var filterToolbarTopConstraint : NSLayoutConstraint!
    
    let activityIndicatorView = UIActivityIndicatorView()
    
    var cellBackgroundColor : UInt = APPLICATION_FOREGROUND_COLOR
    
    var backGroundColor = APPLICATION_BACKGROUND_COLOR
    
    //TODO: noDataBackGroundView show and hide method should be here
    let noDataBackGroundView = NoDataView()

    var canAllowAddEntry = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
    }
    
    func createTableviewAndSubViews(tableViewStyle: UITableView.Style)
    {
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: backGroundColor)
        
        customTableView = TPKeyboardAvoidingTableView(frame: CGRect.zero, style: tableViewStyle)
        customTableView.addCornerRadius(.SMALL)
        customTableView.backgroundColor = .clear
        if tableViewStyle == .grouped
        {
            customTableView.separatorColor = .clear
        }else
        {
            customTableView.separatorColor = UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR)
        }
       // customTableView.scrollIndicatorInsets
        customTableView.delegate = self
        customTableView.translatesAutoresizingMaskIntoConstraints = false
        customTableView.showsVerticalScrollIndicator = false
        customTableView.showsHorizontalScrollIndicator = false
        self.view.addSubview(customTableView)
        customTableView.addSubview(refreshControl)
        // Safe area keeps cards clear of the Dynamic Island and the landscape vertical bar (iOS 27.1+).
        customTableView.setSafeAreaLeft(offset: 0)
        customTableView.setSafeAreaRight(offset: 0)
        
        bottomCustomView.translatesAutoresizingMaskIntoConstraints = false
        bottomCustomView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.view.addSubview(bottomCustomView)

        bottomCustomView.setTopRelatedToView(offSet: 0, relatedView: customTableView, relatedAttribute: .bottom)
        bottomCustomView.setSafeAreaLeft(offset: 0)
        bottomCustomView.setSafeAreaRight(offset: 0)
        bottomCustomView.setSafeAreaBottom(offset: 0)
        heightConstraintOfBottomView = bottomCustomView.setAndReturnHeight(constant: 0)
        
        titleCustomView.backgroundColor = self.view.backgroundColor
        self.view.addSubview(titleCustomView)
                
        customTableView.setTopRelatedToView(offSet: Y_SPACE, relatedView: titleCustomView, relatedAttribute: .bottom)
        
        var safeAreaTop : CGFloat = 0.00
        safeAreaTop = self.view.safeAreaInsets.top
        
//        self.customTableView.contentInset = UIEdgeInsets(top: defaultCustomViewheight, left: 0, bottom: 0, right: 0)
//
        titleCustomView.setSafeAreaLeft(offset: 0)
        titleCustomView.setSafeAreaRight(offset: 0)
        
        filterToolbarTopConstraint = NSLayoutConstraint(item: self.titleCustomView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: safeAreaTop)
        self.view.addConstraint(filterToolbarTopConstraint)
        
        self.view.bringSubviewToFront(self.titleCustomView)
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = .lightGray
        self.view.addSubview(activityIndicatorView)
        
        view.bringSubviewToFront(activityIndicatorView)
    
        activityIndicatorView.setCenterY()
        activityIndicatorView.setCenterX()
        
        //no Data view for tableviewBG
        let tableviewBgView = UIView()
        noDataBackGroundView.delegate = self
        tableviewBgView.addSubview(noDataBackGroundView)
        
        tableviewBgView.clipsToBounds = false
        customTableView.clipsToBounds = true

        noDataBackGroundView.setCenterY()
        noDataBackGroundView.setCenterX()
        noDataBackGroundView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: backGroundColor)
        self.noDataBackGroundView.hideSubView(bool: true)
        customTableView.backgroundView = tableviewBgView
        
    }
    
    func addBorder()
    {
        customTableView.layer.borderWidth = BORDER_WIDTH
        customTableView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
    }
    
    func removeBorder(){
        customTableView.layer.borderWidth = 0
    }
    func changeBackGroundColor(color : UInt)
    {
        backGroundColor = color
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: backGroundColor)
        if customTableView != nil
        {
         customTableView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: backGroundColor)
        }
        noDataBackGroundView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: backGroundColor)
    }
    
    open func noDataViewRetryBtnClicked() {
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if customTableView.tableFooterView == nil
//        {
//            customTableView.tableFooterView = UIView()
//        }
//
//        if customTableView.tableHeaderView == nil
//        {
//            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Y_SPACE))
//            customTableView.tableHeaderView = headerView
//        }
//    }
    
    func changeCustomTitleViewHeight(height : CGFloat)
    {
//        self.customTableView.contentInset = UIEdgeInsets(top: height + SPACE_BW_TWO_SECTIONS, left: 0, bottom: 0, right: 0)
        titleCustomView.removeConstraint(attribute: .height)
        titleCustomView.setHeight(constant: height)
        topViewHeight = height
    }
    
    func scrollTableViewToTop()
    {
        self.customTableView.setContentOffset(CGPoint(x: 0, y: -self.view.safeAreaInsets.top   ), animated: true)
    }
    
    func changeBottomViewHeight(height : CGFloat)
    {
        heightConstraintOfBottomView?.constant = height
//        bottomCustomView.sizeThatFits(CGSize(width: 1000, height: 1000))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available (iOS 11.0, *) {

            let navigationBarAdjustedHeight = self.view.safeAreaInsets.top

            let originalScrollViewInsetY = scrollView.contentOffset.y + topViewHeight;

            var calculatedY : CGFloat = 0.0

            if (originalScrollViewInsetY < -navigationBarAdjustedHeight) {
                calculatedY = -scrollView.contentOffset.y-scrollView.contentInset.top;
            } else {
                calculatedY = navigationBarAdjustedHeight
            }

            if(previousNavigationToolBarYPosition != calculatedY)
            {
                filterToolbarTopConstraint.constant = calculatedY;
                previousNavigationToolBarYPosition = calculatedY;
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if customTableView.style == .grouped
        {
            if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1
            {
                let bottomBorder = CALayer()
                bottomBorder.frame = CGRect(x: tableviewCellInsets.left, y: cell.bounds.height - 0.3, width: cell.contentView.frame.size.width - (tableviewCellInsets.left + tableviewCellInsets.right), height: 0.3)
                bottomBorder.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR).cgColor
                cell.layer.addSublayer(bottomBorder)
            }
        }else
        {
            cell.separatorInset = tableviewCellInsets
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
            }
        }
        
        if tableView.numberOfRows(inSection: indexPath.section) > 1
        {
            if indexPath.row == 0
            {
                cell.roundCorners(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CardSize.SMALL.value)
            }else
            {
                cell.roundCorners(corners: [], radius: CardSize.SMALL.value)
            }
            
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            {
                cell.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner], radius: CardSize.SMALL.value)
            }
        }else
        {
            cell.roundCorners(corners: [.layerMaxXMaxYCorner , .layerMinXMaxYCorner,.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: CardSize.SMALL.value)
        }
        
        cell.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: cellBackgroundColor)
    }

    // only for plain tableview not for grouped and with many sections
    func removeCellFromTableViewAt(arrayOfindexPath: [IndexPath])
    {
        customTableView.beginUpdates()
        customTableView.deleteRows(at: arrayOfindexPath, with: .left)
        customTableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath)
        {
            cell.setSelected(false, animated: true)
        }
    }
    
    func showActivityIndicatorFront(){
        self.view.bringSubviewToFront(activityIndicatorView)
        activityIndicatorView.startAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.view.isUserInteractionEnabled = false
    }
    
    func showActivityIndicator(){
        showActivityIndicatorFront()
        customTableView.isHidden = true
    }
    
    func hideActivityIndicator()
    {
        if refreshControl.isRefreshing{
            refreshControl.endRefreshing()
        }
        activityIndicatorView.stopAnimating()
        customTableView.isHidden = false
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
