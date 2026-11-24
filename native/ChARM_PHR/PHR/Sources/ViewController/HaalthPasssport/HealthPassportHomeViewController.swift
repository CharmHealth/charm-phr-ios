//
//  HealthPassportHomeViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 26/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import QuickLook

class HealthPassportHomeViewController: UIViewController , CharmConnectionHandlerDelegate , CharmConnectionHandlerDataDelegate , CharmConnectionV2HandlerDelegate
{

    
    var charmConnectionHandler : CharmConnectionHandler!
    var activityIndicator = UIActivityIndicatorView()
    let backgroundView = UIView()
    var patient : Patient!
    
    var healthUrl : String!
    var passcodeString : String!
    var urlQr : String!
    
    var isDemoFetched : Bool = false
    var isUrlFetched : Bool = false
    
    var healthPassportDetailView : HealthPassportDetailView!
    
    var previewItem : URL!
    
    var containerScrollView = TPKeyboardAvoidingScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patient = Patient.selectedPatientInstance!
        
        self.setLargeTitle(enable: false)
        self.navigationItem.title = getString(key: "com.charmphr.healthPassport.title")
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
                
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()

        showActivityIndicator()
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.v2Delegate = self
        charmConnectionHandler.fetchDemographics(patientId: getSelectedPatientId(), identificationKey: "fetchDemographics")
        charmConnectionHandler.fetchPatientHealthPassportUrl(patientId: Patient.selectedPatientInstance!.patientId, identificationKey: "fetchHPUrl")
    }
    
    func createSubViews()
    {
        let containerScrollView = TPKeyboardAvoidingScrollView()
        
        let containerView = UIView()
        containerView.addCornerRadius(.SMALL)
        containerView.backgroundColor = .clear
        
//        healthPassportDetailView = HealthPassportDetailView(frame: .zero, patient: patient, passcode: passcodeString, healthUrl: healthUrl, canShowPasscode: false)
        healthPassportDetailView = HealthPassportDetailView(frame: .zero, patient: patient, passcode: passcodeString)
        
        healthPassportDetailView.addShadowAndCornerRadius(.SMALL)
        
       // healthPassportDetailView.passcodeView.isUserInteractionEnabled = false
//        self.healthPassportDetailView.healthUrlView.isUserInteractionEnabled = true
//        healthPassportDetailView.healthUrlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(healthUrlClicked)))
//        healthPassportDetailView.viewPassCodeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPasscodeClicked)))
//        healthPassportDetailView.viewHealthData.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPasscodeClicked)))

        containerView.addSubview(healthPassportDetailView)
        
       // healthPassportDetailView.setTop(offSet: Y_SPACE)
        healthPassportDetailView.setHorizontal(offSet: X_SPACE)
//        healthPassportDetailView.setBottom(offSet: 0)
        
        let healthUrlView = UIView()
        healthUrlView.translatesAutoresizingMaskIntoConstraints = false
        healthUrlView.backgroundColor = .white
        containerView.addSubview(healthUrlView)
        
        healthUrlView.addShadowAndCornerRadius(.SMALL)
        
        let healthUrlLabel = UILabel()
        healthUrlLabel.translatesAutoresizingMaskIntoConstraints = false
        healthUrlLabel.text = getString(key: "com.charmphr.Demographics.HealthURL.title")
        healthUrlLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
        healthUrlLabel.textColor = .black
        healthUrlView.addSubview(healthUrlLabel)
        
        let urlView = UIView()
        urlView.translatesAutoresizingMaskIntoConstraints = false
        let urlViewColor: UInt = 0xF0F0F0FF
        urlView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: urlViewColor)
        healthUrlView.addSubview(urlView)
        
        urlView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        urlView.layer.borderWidth = BORDER_WIDTH
        urlView.addCornerRadius(.SMALL)
        
        let urlValueLabel = UILabel()
        urlValueLabel.translatesAutoresizingMaskIntoConstraints = false
        urlValueLabel.text = healthUrl
        urlValueLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
        let urlColor : UInt = 0x0000EEFF
        urlValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: urlColor)
        urlValueLabel.backgroundColor = .clear
        urlView.addSubview(urlValueLabel)
        
        let shareBtn = UIButton()
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        shareBtn.setTitle(getString(key: "com.charmphr.action.share"), for: .normal)
        shareBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for:.normal)
        shareBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        shareBtn.setImage(#imageLiteral(resourceName: "Share"), for:.normal )
        urlView.addSubview(shareBtn)
        shareBtn.setCenterY()
        shareBtn.titleEdgeInsets = UIEdgeInsets(top: 0,left: 8,bottom: 0,right: -8)
        shareBtn.contentEdgeInsets = UIEdgeInsets(top: 0,left: 8,bottom: 0,right: 8)
        shareBtn.addTarget(self, action:#selector(shareHealthURL), for:.touchUpInside)
       // shareBtn.imageEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        
        
        
        let viewpasscodeBtn = UIButton()
        viewpasscodeBtn.translatesAutoresizingMaskIntoConstraints = false
        healthUrlView.addSubview(viewpasscodeBtn)
        viewpasscodeBtn.setTitle(getString(key: "com.charmphr.Demographics.ViewPasscode.title"), for:.normal)
        viewpasscodeBtn.addTarget(self, action: #selector(viewPasscodeClicked), for: .touchUpInside)
        viewpasscodeBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for:.normal)
        viewpasscodeBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        
        
        viewpasscodeBtn.setCenterX()
        
        urlView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[urlValueLabel]", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS], views: ["urlValueLabel":urlValueLabel]))
        urlView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[shareBtn]-X_SPACE-|", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS], views: ["shareBtn":shareBtn]))
        urlView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-Y_SPACE-[urlValueLabel]-Y_SPACE-|", options: [], metrics:["Y_SPACE":Y_SPACE], views: ["urlValueLabel":urlValueLabel]))
        urlView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-Y_SPACE-[shareBtn]-Y_SPACE-|", options: [], metrics:["Y_SPACE":Y_SPACE], views: ["shareBtn":shareBtn]))
        
        
        healthUrlView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[healthUrlLabel]-X_SPACE-|", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS], views: ["healthUrlLabel":healthUrlLabel]))
        healthUrlView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[urlView]-X_SPACE-|", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS], views: ["urlView":urlView]))
        
        healthUrlView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-Y_SPACE-[healthUrlLabel]-6-[urlView]-12-[viewpasscodeBtn]-12-|", options: [], metrics:["Y_SPACE":SPACE_TO_BORDERS], views: ["healthUrlLabel":healthUrlLabel,"urlView":urlView,"viewpasscodeBtn":viewpasscodeBtn]))
        
        
        healthUrlView.setHorizontal(offSet: X_SPACE)
       // containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[healthUrlView]|", options: [], metrics:nil, views: ["healthUrlView":healthUrlView]))
        
        
        
        
        
                
        let viewHealthPassportPdfView = UIView()
        viewHealthPassportPdfView.backgroundColor = .white
        viewHealthPassportPdfView .addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadHpPDFClicked)))
        viewHealthPassportPdfView.addCornerRadius(.SMALL)
        containerView.addSubview(viewHealthPassportPdfView)
        
        
        let viewHealthPassportLabel = UILabel()
        viewHealthPassportLabel.translatesAutoresizingMaskIntoConstraints = false
        viewHealthPassportLabel.text = getString(key: "com.charmphr.healthPassport.download.hp.title")
        viewHealthPassportLabel.textColor = .black
        viewHealthPassportLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        viewHealthPassportPdfView.addSubview(viewHealthPassportLabel)
        
        let arrowImg = UIImageView()
        arrowImg.setWidth(constant: 6)
        arrowImg.setHeight(constant: 11)
        
        arrowImg.image = #imageLiteral(resourceName: "ArrowRightBlue")
        viewHealthPassportPdfView.addSubview(arrowImg)
        
        arrowImg.setCenterY()
        viewHealthPassportPdfView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[viewHealthPassportLabel]-X_SPACE-[arrowImg]-X_SPACE-|", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS], views: ["viewHealthPassportLabel":viewHealthPassportLabel,"arrowImg":arrowImg]))
        viewHealthPassportPdfView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[viewHealthPassportLabel]-12-|", options: [], metrics:nil, views: ["viewHealthPassportLabel":viewHealthPassportLabel]))
        
        viewHealthPassportPdfView.addShadowAndCornerRadius(.SMALL)
        
        viewHealthPassportPdfView.setTopRelatedToView(offSet: SPACE_BW_TWO_SECTIONS, relatedView: healthUrlView, relatedAttribute: .bottom)
       // viewHealthPassportPdfView.setBottom(offSet: -SPACE_BW_TWO_SECTIONS)
        viewHealthPassportPdfView.setHorizontal(offSet: X_SPACE)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-Y_SPACE-[healthPassportDetailView]-SPACE_BW_TWO_SECTIONS-[healthUrlView]-SPACE_BW_TWO_SECTIONS-[viewHealthPassportPdfView]-Y_SPACE-|", options: [], metrics:["SPACE_BW_TWO_SECTIONS":SPACE_BW_TWO_SECTIONS , "Y_SPACE": Y_SPACE], views: ["healthPassportDetailView":healthPassportDetailView! ,"healthUrlView":healthUrlView,"viewHealthPassportPdfView":viewHealthPassportPdfView]))

        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)
        
        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setWidth(constant: applicationFrame.width)
        //containerView.setRight(offSet: 0)
        
        containerScrollView.setSafeAreaTop(offset: 0)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[containerScrollView]-X_SPACE-|", options: [], metrics:["X_SPACE":0], views: ["containerScrollView":containerScrollView]))
        containerScrollView.setSafeAreaBottom(offset: 0)
    }
    
    
    
    
    //MARK: - action calles
    
    @objc func shareHealthURL()
    {
        let items = [healthUrl]
        let ac = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }

    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    @objc func didTappedOnBackgroundView()
    {
        UIView.transition(
        with: self.view,
        duration: 0.5,
        options: .curveLinear /*change to whatever animation you like */,
        animations: {
            self.backgroundView.removeFromSuperview()
            self.healthPassportDetailView.passcodeView!.removeFromSuperview()
        })
    }
    
    @objc func viewPasscodeClicked()
    {
        backgroundView.frame = self.view.frame
        backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.6
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        
        
        self.healthPassportDetailView.passcodeView?.isHidden = false
        
        UIView.transition(
            with: self.view,
            duration: 0.5,
            options: .curveLinear /*change to whatever animation you like */,
            animations: {
                self.view.addSubview(self.backgroundView)
                self.view.addSubview(self.healthPassportDetailView.passcodeView)
                self.view.bringSubviewToFront(self.healthPassportDetailView.passcodeView!)
                self.healthPassportDetailView.passcodeView?.setCenterY()
                self.healthPassportDetailView.passcodeView?.setCenterX()
            })
        self.healthPassportDetailView.passcodeView?.setLeft(offSet: X_SPACE)
        self.healthPassportDetailView.passcodeView?.setRight(offSet: -X_SPACE)
//        healthPassportDetailView.passcodeView.showAsModalView(animated: true)
//        if self.healthPassportDetailView.patientDetailContainerView.isUserInteractionEnabled
//        {
//            UIView.transition(from: healthPassportDetailView.patientDetailContainerView, to: healthPassportDetailView.passcodeView,
//                          duration: 2, options: [.transitionFlipFromRight,
//                                                   .showHideTransitionViews]) { _ in
//                self.healthPassportDetailView.patientDetailContainerView.isUserInteractionEnabled.toggle()
//                self.healthPassportDetailView.passcodeView.isUserInteractionEnabled.toggle()
//                self.healthPassportDetailView.healthUrlView.isUserInteractionEnabled = false
//            }
//        }else
//        {
//            UIView.transition(from: healthPassportDetailView.passcodeView, to: healthPassportDetailView.patientDetailContainerView,
//                          duration: 2, options: [.transitionFlipFromRight,
//                                                   .showHideTransitionViews]) { _ in
//                self.healthPassportDetailView.patientDetailContainerView.isUserInteractionEnabled.toggle()
//                self.healthPassportDetailView.passcodeView.isUserInteractionEnabled.toggle()
//                self.healthPassportDetailView.healthUrlView.isUserInteractionEnabled = true
//            }
//        }
    }
    
    @objc func downloadHpPDFClicked()
    {
        showActivityIndicator()
        charmConnectionHandler.downloadHealthPassportPdf(patientId: patient.patientId, identificationKey: "downloadPatientHP")
        charmConnectionHandler.dataDelegate = self
    }

    
    //MARK: charmConnectionHandler Delegate
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String)
    {
        if identificationKey == "fetchHPUrl"
        {
            if let outputString = jsonObject["output_string"] as? Dictionary<String,Any>
            {
                if outputString["health_url"] != nil
                {
                    healthUrl =  outputString["health_url"] as? String
                }
                
                if outputString["passcode"] != nil
                {
                    passcodeString =  outputString["passcode"] as? String
                }
                
                if outputString["url_qr"] != nil
                {
                    urlQr =  outputString["url_qr"] as? String
                }
            }
            isUrlFetched = true
            hideActivityIndicator()
            
            if isUrlFetched && isDemoFetched
            {
                createSubViews()
                hideActivityIndicator()
            }
        }
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        
        if identificationKey.hasPrefix("downloadPatientHP")
        {
            
            hideActivityIndicator()
            
            var name = ""
            if !isNilOrEmpty(string: patient.firstName)
            {
                name.append(patient.firstName)
            }
            if !isNilOrEmpty(string: patient.lastName)
            {
                name.append(" ")
                name.append(patient.lastName)
            }
            
            let pdfImageVC = PDFImageViewController(fileName: "\(name)-HealthPassport.pdf", data: data)
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        
        if identificationKey == "fetchDemographics"
        {
            if let patient = response as? Patient {
                self.patient.fill(using: patient)
                
                Patient.selectedPatientInstance?.firstName = patient.firstName
                Patient.selectedPatientInstance?.lastName = patient.lastName
                Patient.selectedPatientInstance?.gender = patient.gender
            }
            if self.navigationController != nil
            {
                for viewConstroller in self.navigationController?.viewControllers ?? []
                {
                    if let homeViewController = viewConstroller as? HomeViewController
                    {
                        homeViewController.setTitleName(name: "Hi \(Patient.selectedPatientInstance?.firstName ?? "")")
                    }
                }
            }
            isDemoFetched = true
            
            if isUrlFetched && isDemoFetched && PrimaryDataHandler.hasAllData()
            {
                createSubViews()
                hideActivityIndicator()
            }
        }
        
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        CharmUtil.createOkayAlertWith(error: error)
    }
    
    @objc func healthUrlClicked()
    {
        if let url = URL(string: "\(healthUrl!)/")
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
