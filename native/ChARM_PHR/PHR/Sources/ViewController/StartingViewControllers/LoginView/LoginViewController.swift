//
//  ViewController.swift
//  ChARM Phr
//
//  Created by Sankar Saravanan on 03/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource
{
    private let MAX_SECCION_ERROR_CODE = 901
    private let SAFARI_DISMISSED  =  908
    
    private var pageViewControllerCurrentIndex = 0
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private let acitivityIndicator = UIActivityIndicatorView()
    
    private var orderedViewControllers: [UIViewController?] = []
    
    private let pageControl = PageControlView(currentPageIndicatorTintColor: UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR), pageIndicatorTintColor: UIColorFromRGB(rgbValueWithAlpha: 0xCFCFCFFF))
    
    private var idelTimer : Timer?
    private var autoNextOnBoardingScreenTime : Int = 5 //sec
    
    var isAuthMigration = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderedViewControllers = Array(repeating: nil, count: 5)
        self.setLargeTitle(enable: false)
        self.view.backgroundColor = .white
        createPageView()
        createSubView()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isAuthMigration else { return }
        isAuthMigration = false
        CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.relogin.migration.message"), msg: nil, okClicked: {
            AuthManager.logoutUserForMigration { [weak self] in
                DispatchQueue.main.async {
                    self?.presentloginView()
                }
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        idelTimer?.invalidate()
        idelTimer = nil
    }
    
//MARK: - Create SubView

    private func createSubView()
    {
        acitivityIndicator.hidesWhenStopped = true
        acitivityIndicator.color = .gray
        acitivityIndicator.style = .large
        
        acitivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(acitivityIndicator)
        acitivityIndicator.setCenterX()
        acitivityIndicator.setCenterY()
        
        hideActivityIndicator()
    }
    
//MARK: - Create PageView
    
    private func createPageView()
    {
        let loginBtn = UIButton()
        loginBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR)
        loginBtn.setTitle(getString(key: "com.charmphr.login.btn.title"), for: .normal)
        loginBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .bold)
        loginBtn.addTarget(self, action: #selector(loginBtnClicked), for: .touchUpInside)
        self.view.addSubview(loginBtn)
        
        loginBtn.setLeft(offSet: 34)
        loginBtn.setRight(offSet: -34)
        loginBtn.setHeight(constant: PILL_BTN_HEIGHT)
        loginBtn.addPillCornerRadiusAndShadow(height: PILL_BTN_HEIGHT)
        loginBtn.setSafeAreaBottom(offset: -30)
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = orderedViewControllers.count - 1
        self.view.addSubview(pageControl)
        
        pageViewController.view.setTop(offSet: 0)
        pageViewController.view.setLeft(offSet: 0)
        pageViewController.view.setRight(offSet: 0)
        pageViewController.view.setBottomRelatedToView(offSet: -20, relatedView: pageControl, relatedAttribute: .top)
        
        pageControl.setCenterX()
        pageControl.setHeight(constant: PAGE_ROUND_VIEW_NORMAL_WIDTH)
        
        sendToNextOnboardingScreen()
        
        loginBtn.setTopRelatedToView(offSet: 20, relatedView: pageControl, relatedAttribute: .bottom)
        
        pageViewController.didMove(toParent: self)
    }
    
    @objc private func viewClicked()
    {
        resetNextOnBoardingScreenTime()
    }
    
    @objc private func sendToNextOnboardingScreen()
    {
        if let currentPage = pageControl.currentPage{
            let nextIndex = (pageControl.currentPage == orderedViewControllers.count - 1) ? 0 : currentPage + 1
            let nextViewController = viewControllerAt(index: nextIndex)
            self.pageControl.currentPage = nextIndex
            pageViewController.setViewControllers([nextViewController],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)
            resetNextOnBoardingScreenTime()
        }
    }
    
    private func resetNextOnBoardingScreenTime()
    {
        idelTimer?.invalidate()
        idelTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(autoNextOnBoardingScreenTime), repeats: false) { [weak self] _ in
            self?.sendToNextOnboardingScreen()
        }
    }
    
//MARK: - PageView SingleViewController
    
    private func pageViewSingleViewController(index : Int) -> OnBoardingSinglePageViewController
    {
        let vc = OnBoardingSinglePageViewController(index: index)
        vc.index = index
        
        switch index {
        case 0:
            vc.titleLabel.text = "\(getString(key: "com.charmphr.login.onboard.welcome.title")) \(AppConfig.sharedInstance.welcomeScreenName ?? "")"
            vc.detailLabel.text = getString(key: "com.charmphr.login.onboard.welcome.message")
            vc.imageView.image = AppConfig.sharedInstance.appicon
        case 1:
            vc.titleLabel.text = getString(key: "com.charmphr.login.onboard.healthPassport.title")
            vc.detailLabel.text = getString(key: "com.charmphr.login.onboard.healthPassport.message")
            vc.imageView.image = #imageLiteral(resourceName: "OnBoardingHealthCard")
        case 2:
            vc.titleLabel.text = getString(key: "com.charmphr.login.onboard.appointments.title")
            vc.detailLabel.text = getString(key: "com.charmphr.login.onboard.appointments.message")
            vc.imageView.image = #imageLiteral(resourceName: "OnBoardingAppointments")
        case 3:
            vc.titleLabel.text = getString(key: "com.charmphr.login.onboard.Messaging.title")
            vc.detailLabel.text = getString(key: "com.charmphr.login.onboard.Messaging.message")
            vc.imageView.image = #imageLiteral(resourceName: "OnBoardingMessages")
        case 4:
            vc.titleLabel.text = getString(key: "com.charmphr.login.onboard.labResultandRx.title")
            vc.detailLabel.text = getString(key: "com.charmphr.login.onboard.labResultandRx.message")
            vc.imageView.image = #imageLiteral(resourceName: "OnBoardingLabs")
        default:
            vc.titleLabel.text = "\(getString(key: "com.charmphr.login.onboard.welcome.title")) \(AppConfig.sharedInstance.welcomeScreenName ?? "")"
            vc.detailLabel.text = getString(key: "com.charmphr.login.onboard.welcome.message")
            vc.imageView.image = AppConfig.sharedInstance.appicon
        }
        return vc
    }
    
    private func viewControllerAt(index: Int) -> OnBoardingSinglePageViewController {
        if let existing = orderedViewControllers[index] as? OnBoardingSinglePageViewController {
            return existing
        }
        let vc = pageViewSingleViewController(index: index)
        orderedViewControllers[index] = vc
        return vc
    }

//MARK: - PageviewController Delegate and Datasource Methods
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageViewControllerCurrentIndex
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers?[0] as? OnBoardingSinglePageViewController
        self.pageControl.currentPage = pageContentViewController?.index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let onBoardingSinglePageViewController = viewController as? OnBoardingSinglePageViewController{
            
            let beforeIndex : Int?
            
            if onBoardingSinglePageViewController.index == 0
            {
                beforeIndex = orderedViewControllers.count - 1
            }else
            {
                beforeIndex = onBoardingSinglePageViewController.index - 1
            }
            
            if let beforeIndex = beforeIndex{
                pageViewControllerCurrentIndex = beforeIndex
                return viewControllerAt(index: beforeIndex)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let onBoardingSinglePageViewController = viewController as? OnBoardingSinglePageViewController{
            
            let afterIndex : Int?
            
            if onBoardingSinglePageViewController.index == orderedViewControllers.count - 1
            {
                afterIndex = 0
            }else
            {
                afterIndex = onBoardingSinglePageViewController.index + 1
            }
            if let afterIndex = afterIndex{
                pageViewControllerCurrentIndex = afterIndex
                return viewControllerAt(index: afterIndex)
            }
        }
        return nil
    }
    
//MARK: - Target methods
    
    @objc private func loginBtnClicked()
    {
        presentloginView()
    }
    
    @objc private func joinMeetingClicked()
    {
        self.navigationController?.pushViewController(JoinZoomCallViewController(), animated: true)
    }
    
    private func presentloginView()
    {
        AuthenticationUtil.presentSignIn { (accountId, error) in
            debugPrintLog("oauth \(accountId ?? "")")
            debugPrintLog("error \(error)")

            DispatchQueue.main.async { [weak self] in
                if (accountId != nil)
                {
                    self?.loginSucces()
                }
                else if case .accessDenied = AuthenticationUtil.charmAuthError(from: error)
                {
                    // Signed in, but the API refuses this user (e.g. missing permissions).
                    CharmUtil.createOkayAlertWith(title: "", msg: getString(key: "com.charmphr.login.select.all.scope.message"), okClicked: { [weak self] in
                        AuthManager.logoutUser(isInvalidOAuth: false)
                    })
                }
                else
                {
                    self?.loginError(error: error)
                }
            }
        }
    }

//MARK: - LoginSuccessFailure methods
    
    private func loginSucces(){
        UserDefaults.standard.set(true, forKey: hkScopePreferenceKey)
        UserDefaults.standard.synchronize()
        trackEvent(eventName: "LoginOnSuccess", withGroupName: "Account")
        let lockScreenVC = LockScreenViewController(lockscreenMode: .create, isLockedScreenPresentedAtLaunch: true)
        self.navigationController?.pushViewController(lockScreenVC, animated: true)
    }
    
    private func loginError(error : Error?)
    {
        if error == nil
        {
            return
            showLoginErrorAlertWithLogoutAction(title: getString(key: "com.charmphr.logout.error.login"))
        }
        else if let error = error as? NSError {
           // var s = 10
            if error.code == MAX_SECCION_ERROR_CODE {
                showLoginErrorAlertWithLogoutAction(title: getString(key: "com.charmphr.logout.max.session.title"), msg: "\(getString(key: "com.charmphr.logout.max.session.msg"))\(AppConfig.sharedInstance.appDisplayName ?? "Charm mPHR")")
            }
            else if error.code == SAFARI_DISMISSED{
                return
            }
            else {
                showLoginErrorAlertWithLogoutAction(title: getString(key: "com.charmphr.logout.error.login"), msg: "\(error.localizedDescription)(Error code : \(error.code))")
            }
        }
    }
    
//MARK: - ShowLoginError functions
    
    private func showLoginErrorAlertWithLogoutAction(title : String , msg : String? = nil)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let retryAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.retry"), style: .default) { (action) in
            self.presentloginView()
        }
        
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel) { (action) in
           
        }
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        alert.show(animated: true)
    }
    
//MARK: - ActivityIndicator methods
    
    private func showActivityIndicator()
    {
        self.view.bringSubviewToFront(acitivityIndicator)
        acitivityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    private func hideActivityIndicator()
    {
        acitivityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
}

//MARK: - PageControlView

private class PageControlView : UIView{
    
    //this view is the container view becoz if numberOfPages changed we should remove every view
    private var containerView : UIView? = nil
    private var selectedViewTag = 0
    private var currentPageIndicatorTintColor : UIColor?
    private var pageIndicatorTintColor : UIColor?
    
    init(currentPageIndicatorTintColor:UIColor,pageIndicatorTintColor : UIColor ) {
        super.init(frame: .zero)
        
        self.pageIndicatorTintColor = pageIndicatorTintColor
        self.currentPageIndicatorTintColor = currentPageIndicatorTintColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentPage : Int? = nil
    {
        didSet
        {
            if let roundView = containerView?.viewWithTag(selectedViewTag) as? RoundPageControlView
            {
                roundView.setUnselected()
            }
            if let currentPage = currentPage{
                selectedViewTag = currentPage + PAGE_ROUND_VIEW_STARTING_TAG
            }
            if let roundView = containerView?.viewWithTag(selectedViewTag) as? RoundPageControlView
            {
                roundView.setSelected()
            }
            if self.superview != nil
            {
                UIView.animate(withDuration: 0.2) {
                    self.superview?.layoutIfNeeded()
                }
            }
        }
    }
    var numberOfPages : Int = 0
    {
        didSet
        {
            if containerView != nil
            {
                containerView?.removeFromSuperview()
            }
            createSubViews()
        }
    }
    
    private func createSubViews()
    {
        containerView = UIView()
        containerView?.backgroundColor = .clear
        
        for i in 0 ..< numberOfPages
        {
            if let currentPageIndicatorTintColor = currentPageIndicatorTintColor, let pageIndicatorTintColor = pageIndicatorTintColor{
                let roundView = RoundPageControlView(frame: .zero, currentPageIndicatorTintColor: currentPageIndicatorTintColor, pageIndicatorTintColor: pageIndicatorTintColor)
                roundView.tag = PAGE_ROUND_VIEW_STARTING_TAG + i
                containerView?.addSubview(roundView)
                
                roundView.setHeight(constant: PAGE_ROUND_VIEW_NORMAL_WIDTH)
                roundView.widthCont = roundView.setAndReturnWidth(constant: PAGE_ROUND_VIEW_NORMAL_WIDTH)
                
                roundView.setCenterY()
                
                if i == 0
                {
                    roundView.setLeft(offSet: 5)
                }else
                {
                    if let view = containerView?.viewWithTag((PAGE_ROUND_VIEW_STARTING_TAG + i)-1)
                    {
                        roundView.setLeftRelatedToView(offSet: 6, relatedView: view, relatedAttribute: .right)
                    }
                }
                if i == numberOfPages - 1
                {
                    roundView.setRight(offSet: -5)
                }
            }
        }
        if let containerView = containerView{
            self.addSubview(containerView)
            containerView.setLeft(offSet: 0)
            containerView.setRight(offSet: 0)
            containerView.setCenterY()
        }
    }
}

fileprivate let PAGE_ROUND_VIEW_NORMAL_WIDTH : CGFloat = 7
fileprivate let PAGE_ROUND_VIEW_SELECTED_WIDTH : CGFloat = 12
fileprivate let PAGE_ROUND_VIEW_STARTING_TAG = 1500

private class RoundPageControlView : UIView
{
    var widthCont : NSLayoutConstraint? = nil
    private var currentPageIndicatorTintColor : UIColor?
    private var pageIndicatorTintColor : UIColor?
    
    init(frame: CGRect , currentPageIndicatorTintColor : UIColor , pageIndicatorTintColor : UIColor) {
        super.init(frame: .zero)
        
        self.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        self.pageIndicatorTintColor = pageIndicatorTintColor
        
        self.backgroundColor = self.pageIndicatorTintColor
        self.layer.cornerRadius = PAGE_ROUND_VIEW_NORMAL_WIDTH / 2
        self.clipsToBounds = true
    }
    
    func setSelected()
    {
        self.backgroundColor = currentPageIndicatorTintColor
        if widthCont != nil
        {
            widthCont?.constant = PAGE_ROUND_VIEW_SELECTED_WIDTH
        }
    }
    
    func setUnselected()
    {
        self.backgroundColor = pageIndicatorTintColor
        if widthCont != nil
        {
            widthCont?.constant = PAGE_ROUND_VIEW_NORMAL_WIDTH
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
