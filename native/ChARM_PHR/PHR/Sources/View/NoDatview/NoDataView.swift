//
//  NoDataView.swift
//  phr
//
//  Created by Sankar Saravanan on 01/06/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol NoDataViewDelegate: AnyObject {
    func noDataViewRetryBtnClicked()
}

class NoDataView: UIView {
    
    
    enum NoDataImageEnum {
        case noData
        case appointment
        case prescription
//        case noInternet
        case oops
        case healthKit
    }
    
    let stackView : UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.center
        
        return stackView
    }()
    
    private var noDataImageViewWidthConst : NSLayoutConstraint!
    private var noDataImageViewHeightConst : NSLayoutConstraint!
    let noDataImageview = UIImageView()
    let noDataMsgLabelOne = UILabel()
    let noDataMsgLabelTwo = UILabel()
    let tryAgainBtn = UIButton()
    
    private var tryAgainBtnWidthConstraint : NSLayoutConstraint!

    
    weak var delegate : NoDataViewDelegate?
    
    init() {
        super.init(frame: .zero)
        
        let tryAgainBtnHeight: CGFloat = 32
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        noDataMsgLabelOne.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        noDataMsgLabelOne.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        noDataMsgLabelOne.numberOfLines = 0
        noDataMsgLabelOne.textAlignment = .center
        
        noDataMsgLabelTwo.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        noDataMsgLabelTwo.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_MEDIUM_LIGHT)
        noDataMsgLabelTwo.numberOfLines = 0
        noDataMsgLabelTwo.textAlignment = .center
        
        tryAgainBtn.addTarget(self, action: #selector(retryBtnClicked), for: .touchUpInside)
        

        tryAgainBtn.setTitle(getString(key: "com.charmphr.action.tryAgain"), for: .normal)
        tryAgainBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        tryAgainBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE), for: .normal)
        tryAgainBtn.setBackgroundColor(bgColor: THEME_COLOR)
        tryAgainBtn.addPillCornerRadiusAndShadow(height: tryAgainBtnHeight)
        
        tryAgainBtnWidthConstraint = tryAgainBtn.titleLabel?.setAndReturnWidth(constant: 0)

        tryAgainBtn.setHeight(constant: tryAgainBtnHeight)
        tryAgainBtn.titleLabel?.textAlignment = .center
        tryAgainBtnWidthConstraint.constant = (tryAgainBtn.titleLabel?.sizeThatFits(CGSize(width: 200, height: 100)).width ?? 0) + 30
        noDataImageViewWidthConst = NSLayoutConstraint(item: noDataImageview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200)
        noDataImageview.addConstraint(noDataImageViewWidthConst)
        
        noDataImageViewHeightConst = NSLayoutConstraint(item: noDataImageview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)
        noDataImageview.addConstraint(noDataImageViewHeightConst)
        setImage(enum: .noData)
        
        self.addSubview(stackView)
        
        stackView.setLeft(offSet: 0)
        stackView.setRight(offSet: 0)
        stackView.setTop(offSet: 30)
        stackView.setBottom(offSet: -30)
        
        rearrangeViewsInStackView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideSubView(bool : Bool)
    {
        noDataImageview.isHidden = bool
        noDataMsgLabelOne.isHidden = bool
        noDataMsgLabelTwo.isHidden = bool
        tryAgainBtn.isHidden = bool
        self.isHidden = bool
        rearrangeViewsInStackView()
    }
    
    func hideTryAgainBtn(bool : Bool)
    {
        tryAgainBtn.isHidden = bool
        rearrangeViewsInStackView()
    }
    
    func setTryAgainBtnTxt(string : String)
    {
        tryAgainBtn.setTitle(string, for: .normal)
        
       // tryAgainBtnWidthConstraint.constant = 120
        tryAgainBtnWidthConstraint.constant = (tryAgainBtn.titleLabel?.sizeThatFits(CGSize(width: 200, height: 100)).width   ?? 0) + 10
        
        debugPrintLog("tryAgainWidth \(tryAgainBtnWidthConstraint.constant)")

        rearrangeViewsInStackView()
    }
    
    func setTitle(string : String)
    {
        noDataMsgLabelOne.text = string
        rearrangeViewsInStackView()
    }
    
    func setMessage(string : String?)
    {
        
        if string != nil
        {
            noDataMsgLabelTwo.isHidden = false
            
            let atributtedStr = NSMutableAttributedString(string: string!)
            atributtedStr.addAttribute(.foregroundColor, value: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), range: (string! as NSString).range(of: "+"))
            atributtedStr.addAttribute(.font, value: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular), range: (string! as NSString).range(of: "+"))
            
            noDataMsgLabelTwo.attributedText = atributtedStr
        }else
        {
            noDataMsgLabelTwo.attributedText = nil
        }
        rearrangeViewsInStackView()
    }
    
    func setImage(enum noDataImageEnum : NoDataImageEnum, title : String , message : String?)
    {
        setImage(enum: noDataImageEnum)
        
        setTitle(string: title)
        setMessage(string: message)
        hideSubView(bool: false)
        if noDataImageEnum == .oops
        {
            hideTryAgainBtn(bool: false)
        }else
        {
            hideTryAgainBtn(bool: true)
        }
        rearrangeViewsInStackView()
    }
    
    func setImage(enum noDataImageEnum : NoDataImageEnum)
    {
        switch noDataImageEnum {
            case .noData :
                noDataImageview.image = #imageLiteral(resourceName: "NoData")
                noDataImageViewWidthConst.constant = 200
                noDataImageViewHeightConst.constant = 200
            case .appointment :
                noDataImageview.image = #imageLiteral(resourceName: "NoAppointment")
                noDataImageViewWidthConst.constant = 114
                noDataImageViewHeightConst.constant = 105.65
            case .prescription :
                noDataImageview.image = #imageLiteral(resourceName: "NoMedication")
                noDataImageViewWidthConst.constant = 175
                noDataImageViewHeightConst.constant = 135
            case .oops :
                noDataImageview.image = #imageLiteral(resourceName: "OopsImage")
                noDataImageViewWidthConst.constant = 200
                noDataImageViewHeightConst.constant = 200
        case .healthKit:
            noDataImageview.image = UIImage(named: "healthkit-empty-icon")
            noDataImageViewWidthConst.constant = 161
            noDataImageViewHeightConst.constant = 161
            
        }
        
        if noDataImageEnum == .oops
        {
            hideTryAgainBtn(bool: false)
        }else
        {
            hideTryAgainBtn(bool: true)
        }
    }
    
    @objc func retryBtnClicked()
    {
        delegate?.noDataViewRetryBtnClicked()
    }
    
    private func rearrangeViewsInStackView()
    {
        for view in stackView.subviews
        {
            stackView.removeArrangedSubview(view)
        }
        
        
        var  prevViewForButton: UILabel? = nil
        stackView.addArrangedSubview(noDataImageview)
        stackView.setCustomSpacing(20, after: noDataImageview)
        if !isNilOrEmpty(string: noDataMsgLabelOne.text)
        {
            stackView.addArrangedSubview(noDataMsgLabelOne)
            noDataMsgLabelOne.setLeft(offSet: 10)
            noDataMsgLabelOne.setWidth(constant: applicationFrame.width - 20)
            prevViewForButton = noDataMsgLabelOne
        }
        if !isNilOrEmpty(string: noDataMsgLabelTwo.text)
        {
            stackView.addArrangedSubview(noDataMsgLabelTwo)
            noDataMsgLabelTwo.setLeft(offSet: 10)
            noDataMsgLabelTwo.setWidth(constant: applicationFrame.width - 20)
            stackView.setCustomSpacing(6, after: noDataMsgLabelOne)
            prevViewForButton = noDataMsgLabelTwo
        }
        if !tryAgainBtn.isHidden
        {
            stackView.addArrangedSubview(tryAgainBtn)
            stackView.setCustomSpacing(10, after: tryAgainBtn)
            
            if let prevViewForButton = prevViewForButton {
                stackView.setCustomSpacing(10, after: prevViewForButton )
            }
        }
        
    }
    
    
    
}
