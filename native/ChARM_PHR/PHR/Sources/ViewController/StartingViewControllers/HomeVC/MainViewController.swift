//
//  MainViewController.swift
//  PHR
//
//  Created by Prathiba Murugesan on 12/11/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, DemographicsViewControllerDidChangeValueDelegate {

    private let homeVC: HomeViewController

    private var customTopView = UIView()
    private let titleLabel = UILabel()
    let imageViewWithInitailsView = ImageViewWithInitailsView()
    let announcementImgBtn = UIButton()
    let announcementCountLabel = UILabel()

    let addBtn = UIButton()
    private let ADD_BTN_SIZE: CGFloat = 56

    init(homeVC: HomeViewController) {
        self.homeVC = homeVC
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)

        createNavigationBar()
        embedHomeVC()
        setupAddButton()

        self.view.bringSubviewToFront(customTopView)
        self.view.bringSubviewToFront(addBtn)
    }

    private func embedHomeVC(){
        addChild(homeVC)
        view.addSubview(homeVC.view)
        homeVC.didMove(toParent: self)

        homeVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            homeVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeVC.view.topAnchor.constraint(equalTo: customTopView.bottomAnchor),
            homeVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createNavigationBar()
    {
        imageViewWithInitailsView.addGestureRecognizer(UITapGestureRecognizer(target: homeVC, action: #selector(HomeViewController.profileBtnClicked)))
        imageViewWithInitailsView.layer.cornerRadius = 20
        imageViewWithInitailsView.layer.masksToBounds = true
        imageViewWithInitailsView.isUserInteractionEnabled = true
        customTopView.addSubview(imageViewWithInitailsView)

        titleLabel.font = .systemFont(ofSize: 34, Weight: .bold)
        customTopView.addSubview(titleLabel)
        announcementImgBtn.setImage(UIImage(named: "Announcement"), for: .normal)
        announcementImgBtn.backgroundColor = .white
        announcementImgBtn.addShadow()
        announcementImgBtn.layer.cornerRadius = 40/2

        customTopView.addSubview(announcementImgBtn)

        titleLabel.setSafeAreaTop(offset: 10)
        titleLabel.setBottom(offSet: -12)
        titleLabel.setLeft(offSet: X_SPACE)
        titleLabel.setRightRelatedToView(offSet: -X_SPACE, relatedView: announcementImgBtn, relatedAttribute: .left)

        let countLabelSize: CGFloat = 23
        announcementCountLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: RED_BG_COLOR)
        announcementCountLabel.text = ""
        announcementCountLabel.textColor = .white
        announcementCountLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .bold)
        announcementCountLabel.textAlignment = .center
        announcementCountLabel.layer.cornerRadius = countLabelSize/2
        announcementCountLabel.layer.masksToBounds = true

        customTopView.addSubview(announcementCountLabel)
        announcementCountLabel.isHidden = true

        announcementCountLabel.setHeight(constant: countLabelSize)
        announcementCountLabel.setWidth(constant: countLabelSize)
        announcementCountLabel.setSafeAreaTop(offset: 10)
        announcementCountLabel.setRightRelatedToView(offSet: -(10), relatedView: imageViewWithInitailsView, relatedAttribute: .left)

        announcementImgBtn.setHeight(constant: 40)
        announcementImgBtn.setWidth(constant: 40)
        announcementImgBtn.setSafeAreaTop(offset: 15)
        announcementImgBtn.setRightRelatedToView(offSet: -(X_SPACE), relatedView: imageViewWithInitailsView, relatedAttribute: .left)

        imageViewWithInitailsView.setHeight(constant: 40)
        imageViewWithInitailsView.setWidth(constant: 40)
        imageViewWithInitailsView.setBottom(offSet: -14)
        imageViewWithInitailsView.setSafeAreaTop(offset: 14)
        imageViewWithInitailsView.setRight(offSet: -X_SPACE)

        customTopView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_GRAY_BG_COLOR)
        self.view.addSubview(customTopView)

        customTopView.setTop(offSet: 10)
        customTopView.setSafeAreaRight(offset: 0)
        customTopView.setSafeAreaLeft(offset: 0)
        customTopView.addBottomBorder()
    }

    private func setupAddButton(){
        // iOS 27+ shows the Add action as a prominent native tab instead of this floating button.
        if #available(iOS 27.0, *) {
            return
        }

        self.view.addSubview(addBtn)

        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus")
        config.baseBackgroundColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        config.cornerStyle = .capsule
        addBtn.configuration = config
        addBtn.tintColor = .white
        addBtn.automaticallyUpdatesConfiguration = false

        addBtn.addTarget(homeVC, action: #selector(HomeViewController.addBtnClicked(_:)), for: .touchUpInside)

        addBtn.setWidth(constant: ADD_BTN_SIZE)
        addBtn.setHeight(constant: ADD_BTN_SIZE)
        addBtn.setSafeAreaBottom(offset: -60)
        addBtn.setRight(offSet: -20)
    }

    func setTitleName(name: String)
    {
        self.titleLabel.text = name
    }

    func hideAddBtn(){
        guard #unavailable(iOS 27.0) else { return }
        addBtn.isHidden = true
    }

    func setAddButtonHidden(_ hidden: Bool){
        guard #unavailable(iOS 27.0) else { return }
        addBtn.isHidden = hidden
    }

    func loadSubView(){
        homeVC.loadSubView()
    }

    func dismissAllModalVCPresented(){
        homeVC.dismissAllModalVCPresented()
    }

    var appDataHandler: AppDataHandler {
        get { homeVC.appDataHandler }
        set { homeVC.appDataHandler = newValue }
    }

    //MARK: - DemographicsViewControllerDidChangeValueDelegate

    func demographicsViewControllerDidChangePatientPhoto(photo: UIImage) {
        Patient.selectedPatientInstance?.patientPhoto = photo
        imageViewWithInitailsView.setImage(image: photo)
    }

    func demographicsViewControllerDidChangeName() {
        setTitleName(name: "Hi \(Patient.selectedPatientInstance?.firstName ?? "")")
    }
}
