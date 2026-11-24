//
//  SectionsViewController.swift
//  phr
//
//  Created by Raghul D on 04/11/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

class SectionsViewController: UIViewController, NoDataViewDelegate  {
    
    private(set) var sectionsView = SectionsView()
    private let noDataView = NoDataView()
    weak var delegate : HomeViewControllerNavigationDelegate?
    private weak var noDataDelegate : NoDataViewDelegate?
    
    var engagementArr:[Module]? = nil
    var billingArr:[Module]? = nil
    var recordArr:[Module]? = nil
    var resourceArr:[Module]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        sectionsView.setSectionViewDelegate(delegate: self)
        self.view.addSubview(sectionsView)
        
        sectionsView.setSafeAreaLeft(offset: 0)
        sectionsView.setSafeAreaRight(offset: 0)
        sectionsView.setSafeAreaTop(offset: 0)
        sectionsView.setBottom(offSet: 0)
        
        self.view.addSubview(noDataView)
        
        noDataView.delegate = self
        noDataView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        noDataView.isHidden = true
        
        noDataView.setCenterY()
        noDataView.setCenterX()
        
        noDataView.hideSubView(bool: true)
        
        if engagementArr != nil {
            reloadData()
        }
        else{
            sectionsView.showActivityIndicator()
        }
    }
    
    
    func reloadData() {
        let moduleSectionArr = AppDataHandler.sharedInstance().moduleSectionArr

        let grouped = Dictionary(grouping: moduleSectionArr, by: { $0.groupNum })

        engagementArr = grouped[0]?.sorted(by: { $0.position < $1.position })
        billingArr = grouped[1]?.sorted(by: { $0.position < $1.position })
        recordArr = grouped[2]?.sorted(by: { $0.position < $1.position })
        resourceArr = grouped[3]?.sorted(by: { $0.position < $1.position })

        sectionsView.reloadData()
    }
    
    func onModuleSelected(module: Module) {
        delegate?.homeViewControllerNavigationPushViewController(selectedSection: module, identifier: module.moduleId)
    }
    
    func showNoDataView(error: Error, noDataDelegate: NoDataViewDelegate?) {
        self.view.bringSubviewToFront(noDataView)
        self.noDataDelegate = noDataDelegate
        noDataView.isHidden = false
        noDataView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
    }
    
    func noDataViewRetryBtnClicked() {
        if let noDataDelegate{
            noDataDelegate.noDataViewRetryBtnClicked()
            self.noDataDelegate = nil
        }
        else{
            sectionsView.showActivityIndicator()
            reloadData()
        }
    }
    
    func showActivityIndicator(){
        noDataView.isHidden = true
        sectionsView.showActivityIndicator()
    }
    
    func hideActivityIndicator(){
        noDataView.isHidden = true
        sectionsView.hideActivityIndicator ()
    }
}
