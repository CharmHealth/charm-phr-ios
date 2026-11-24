//
//  WellnessMetricViewController.swift
//  phr
//
//  Created by Dhanuprasanya P on 05/03/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class WellnessMetricViewController: UIViewController ,UITextViewDelegate
{

    let activityIndicator = UIActivityIndicatorView()
        
    let containerView = UIView()
    
    let standardView = UIView()
    let metricView = UIView()
    
    
    let standardImg = UIImageView(image: UIImage(named: "RadioBtnUnselected"))
    let metricImg = UIImageView(image: UIImage(named: "RadioBtnUnselected"))

    var unitChoosed : String? = nil
    var countrykey: String? = nil
    
    weak var delegate: WellnessMetricViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        createSubViews()

        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        self.navigationItem.title = title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func createSubViews()
    {
        self.view.setBackgroundColor(bgColor: PRESENT_VC_BG_COLOR)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addShadowAndCornerRadius(.SMALL)
        
        let measurementLabel = UILabel()
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.backgroundColor = .clear
        measurementLabel.numberOfLines = 2
        measurementLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        measurementLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUMDARK)
        measurementLabel.text = getString(key: "com.charmphr.wellnessmetric.selectunit.key")
        containerView.addSubview(measurementLabel)
        
        //standardview
        
        standardView.translatesAutoresizingMaskIntoConstraints = false
        standardView.backgroundColor = .clear
        containerView.addSubview(standardView)
        standardView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        standardView.layer.borderWidth = BORDER_WIDTH
        standardView.addCornerRadius(.SMALL)
        standardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
       
        
        
        let standardLabel = UILabel()
        standardLabel.translatesAutoresizingMaskIntoConstraints = false
        standardLabel.backgroundColor = .clear
        standardLabel.numberOfLines = 1
        standardLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        standardLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUMDARK)
        standardLabel.text = getString(key: "com.charmphr.wellnessmetric.standard.key")
        standardView.addSubview(standardLabel)
    
        
        let standardUnitLabel = UILabel()
        standardUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        standardUnitLabel.backgroundColor = .clear
        standardUnitLabel.numberOfLines = 1
        standardUnitLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        standardUnitLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUMDARK)
        standardUnitLabel.text = getString(key: "com.charmphr.wellnessmetric.standardunit")
        standardView.addSubview(standardUnitLabel)
        
        
        standardView.addSubview(standardImg)
        
        
        standardImg.setWidth(constant: 18)
        standardImg.setHeight(constant: 18)
        standardImg.setCenterY()
        
        standardImg.setLeft(offSet: 14)
                
       
        
        
        standardLabel.setLeftRelatedToView(offSet: 14, relatedView: standardImg, relatedAttribute: .right)
        standardLabel.setRight(offSet: -SPACE_TO_BORDERS)
        standardLabel.setTop(offSet: SPACE_TO_BORDERS)
        
        standardUnitLabel.setTopRelatedToView(offSet: 0, relatedView: standardLabel, relatedAttribute: .bottom)
        standardUnitLabel.setLeftRelatedToView(offSet: 14, relatedView: standardImg, relatedAttribute: .right)
        standardUnitLabel.setRight(offSet: -SPACE_TO_BORDERS)
        standardUnitLabel.setBottom(offSet: -SPACE_TO_BORDERS)
        
        
//        
//        standardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[standardLabel]-X_SPACE-|", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS], views: ["standardLabel":standardLabel]))
//        standardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[standardUnitLabel]-X_SPACE-|", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS], views: ["standardUnitLabel":standardUnitLabel]))
//        standardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-X_SPACE-[standardLabel(standardLabelHt)][standardUnitLabel(standardUnitLabelHt)]-X_SPACE-|", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS,"standardUnitLabelHt":standardUnitLabelHt,"standardLabelHt": standardLabelHt], views: ["standardLabel":standardLabel,"standardUnitLabel": standardUnitLabel]))
        

        //metricView
        
        metricView.translatesAutoresizingMaskIntoConstraints = false
        metricView.backgroundColor = .clear
        containerView.addSubview(metricView)
        metricView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        metricView.layer.borderWidth = BORDER_WIDTH
        metricView.addCornerRadius(.SMALL)
        metricView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        
        
        
        let metricLabel = UILabel()
        metricLabel.translatesAutoresizingMaskIntoConstraints = false
        metricLabel.backgroundColor = .clear
        metricLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE, Weight: .semibold)
        metricLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUMDARK)
        metricLabel.text = getString(key: "com.charmphr.wellnessmetric.metric.key")
        metricView.addSubview(metricLabel)
    
        
        let metricUnitLabel = UILabel()
        metricUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        metricUnitLabel.backgroundColor = .clear
        metricUnitLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        metricUnitLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUMDARK)
        metricUnitLabel.text = getString(key: "com.charmphr.wellnessmetric.metricunit")
        metricView.addSubview(metricUnitLabel)
    
        metricView.addSubview(metricImg)
        
        
        metricImg.setWidth(constant: 18)
        metricImg.setHeight(constant: 18)
        metricImg.setCenterY()
        
        metricImg.setLeft(offSet: 14)
        
        
        
       
        
        metricLabel.setLeftRelatedToView(offSet: 14, relatedView: metricImg, relatedAttribute: .right)
        metricLabel.setRight(offSet: -SPACE_TO_BORDERS)
        metricLabel.setTop(offSet: SPACE_TO_BORDERS)
        
        metricUnitLabel.setTopRelatedToView(offSet: 0, relatedView: metricLabel, relatedAttribute: .bottom)
        metricUnitLabel.setLeftRelatedToView(offSet: 14, relatedView: metricImg, relatedAttribute: .right)
        metricUnitLabel.setRight(offSet: -SPACE_TO_BORDERS)
        metricUnitLabel.setBottom(offSet: -SPACE_TO_BORDERS)
         
        
        let submitButton = UIButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        //submitButton.backgroundColor = UIColor.yellow
        submitButton.setTitle(getString(key: "com.charmphr.action.done"), for: .normal)
        submitButton.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR), for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        submitButton.addTarget(self, action: #selector(submitButtonClicked), for: .touchUpInside)
        
        containerView.addSubview(submitButton)

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[standardView]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["standardView":standardView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[metricView]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["metricView":metricView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[submitButton]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["submitButton":submitButton]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[measurementLabel]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["measurementLabel":measurementLabel]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-X_SPACE-[measurementLabel]-[standardView]-[metricView]-[submitButton(40)]-X_SPACE-|", options: [], metrics:["X_SPACE":SPACE_TO_BORDERS], views: ["measurementLabel":measurementLabel,"standardView": standardView,"metricView":metricView,"submitButton":submitButton]))
        
        self.view.addSubview(containerView)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-X_SPACE-[containerView]-X_SPACE-|", options: [], metrics:["X_SPACE":X_SPACE], views: ["containerView":containerView]))
       
        containerView.clipsToBounds =  true
        containerView.setCenterY()
        
        if let unitChoosed {
            onUnitSelected(unit: unitChoosed)
        }
        else{
            if let countrykey = countrykey {
                if countrykey == country_us {
                    onUnitSelected(unit: vitalUnitStandard)
                }
                else{
                    onUnitSelected(unit: vitalUnitMetric)
                }
            }
        }
        
    }
   
    //MARK: - action calles

    
    @objc func viewClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if(tapGestureRecognizer.view == standardView)
        {
            onUnitSelected(unit: vitalUnitStandard)
        }
        else{
            onUnitSelected(unit: vitalUnitMetric)
        }
    }
    
    private func onUnitSelected(unit: String){
        unitChoosed = unit
        if unit == vitalUnitStandard {
            standardImg.image = UIImage(named: "RadioBtnSelected")
            metricImg.image = UIImage(named: "RadioBtnUnselected")
        }
        else{
            standardImg.image = UIImage(named: "RadioBtnUnselected")
            metricImg.image = UIImage(named: "RadioBtnSelected")
        }
    }
    
    @objc func submitButtonClicked()
    {
        if(isNilOrEmpty(string: unitChoosed))
        {
            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: "com.charmphr.wellnessmetric.selectunit.error"))
        }
        else{
            debugPrintLog("UNITCHOOSED = \(unitChoosed ?? "")")
            
            delegate?.onWellnessUnitSelected(unit: unitChoosed ?? "")
            self.dismiss(animated: true)

        }
        
    }
    
    
    //MARK: - activity indicators
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

}

protocol WellnessMetricViewControllerDelegate: AnyObject {
    func onWellnessUnitSelected(unit: String)
}
