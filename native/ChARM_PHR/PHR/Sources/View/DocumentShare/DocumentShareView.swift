//
//  DocumentShareView.swift
//  phr
//
//  Created by prathi-13964 on 28/10/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

let SHARE_DOCUMENT_FRAME_WIDTH: CGFloat = applicationFrame.width - 32

class DocumentShareView: UIView{
    
    let containerScrollView = TPKeyboardAvoidingScrollView()
    let segmentControlView = UIView()
    let shareToSegmentControl = UISegmentedControl(items: [getString(key: "com.charmphr.sharedocuments.segmentcontrolItem.practice.title"),getString(key: "com.charmphr.sharedocuments.segmentcontrolItem.others.title")])
    let shareToSubView = UIStackView()
    let enterMailLabel = UILabel()
    let toView = UIView()
    let toLabel = UILabel()
    let toValueStackView = UIStackView()
    let toPracticeView = UIView()
    let toPracticeTextField = CustomTextField()
    let toOtherView = UIView()
    let toOtherTextField = CustomTextField()
    let noDataMemberView = UIView()
    let noDataLabel = UILabel()
    let noDataOthersView = UIView()
    let notAvailabelLabel = UILabel()
    let addToContactBtn = UIButton()
    let receiverListTableView = MDAutoGrowingTableView()
    let documentWillShareLabel = UILabel()
    let expiryView = UIView()
    let expiryLabel = UILabel()
    let expiryValueLabel = UILabel()
    let rightArrowIcon = UIImageView(image: UIImage(named: "ArrowRight"))
    let attachmentView = UIView()
    let informationView = InformationView(infoLocalisedKey: "Note: Your practice has disabled document share option. Please contact your practice.")
    var documentShareVCdelegate: DocumentShareViewController?
    let expiryDaysList = ["1 Day","5 Days","10 Days"]
    var expiryDaySelectedIndex = 0
    var hasspace = false
    var viewframe = applicationFrame.width - 90
    var beforeCardView: UIView?
    var segmentControlHeightConstraint: NSLayoutConstraint? = nil
    
    var toValueViewWidth: CGFloat = applicationFrame.width
    
    init(){
        super.init(frame: .zero)
        setSubviews()
    }
    
    //MARK: - setSubviews
    
    private func setSubviews(){
        
        self.addSubview(containerScrollView)
        containerScrollView.addSubview(segmentControlView)
        segmentControlView.addSubview(shareToSegmentControl)
        containerScrollView.addSubview(shareToSubView)
        shareToSubView.addArrangedSubview(enterMailLabel)
        shareToSubView.addArrangedSubview(toView)
        toView.addSubview(toLabel)
        toView.addSubview(toValueStackView)
        toValueStackView.addArrangedSubview(toPracticeView)
        toPracticeView.addSubview(toPracticeTextField)
        toValueStackView.addArrangedSubview(toOtherView)
        toOtherView.addSubview(toOtherTextField)
        shareToSubView.addArrangedSubview(noDataMemberView)
        noDataMemberView.addSubview(noDataLabel)
        shareToSubView.addArrangedSubview(noDataOthersView)
        shareToSubView.addArrangedSubview(receiverListTableView)
        noDataOthersView.addSubview(notAvailabelLabel)
        noDataOthersView.addSubview(addToContactBtn)
        shareToSubView.addArrangedSubview(expiryView)
        shareToSubView.addArrangedSubview(documentWillShareLabel)
        expiryView.addSubview(expiryLabel)
        expiryView.addSubview(expiryValueLabel)
        expiryView.addSubview(rightArrowIcon)
        shareToSubView.addArrangedSubview(attachmentView)
        shareToSubView.addArrangedSubview(informationView)
        
        addProperties()
        addConstraints()
    }
    
    //MARK: - addConstraints
    
    private func addConstraints(){
        
        containerScrollView.setLeft(offSet: 0)
        containerScrollView.setRight(offSet: 0)
        containerScrollView.setSafeAreaTop(offset: CARD_PADDING)
        containerScrollView.setSafeAreaBottom(offset: 0)
        
        segmentControlView.setTop(offSet: 0)
        segmentControlView.setLeft(offSet: X_SPACE)
        segmentControlView.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        
        shareToSegmentControl.setLeft(offSet: 0)
        shareToSegmentControl.setRight(offSet: 0)
        shareToSegmentControl.setTop(offSet: 0)
        shareToSegmentControl.setBottom(offSet: 0)
        segmentControlHeightConstraint = shareToSegmentControl.setAndReturnHeight(constant: 0)
        
        shareToSubView.setLeft(offSet: X_SPACE)
        shareToSubView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: segmentControlView, relatedAttribute: .bottom)
        shareToSubView.setBottom(offSet: 0)
        
        toValueViewWidth -= X_SPACE
        
        enterMailLabel.setLeft(offSet: 0)
        enterMailLabel.setRight(offSet: 0)
        enterMailLabel.setTop(offSet: 2)
        enterMailLabel.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        
        shareToSubView.setCustomSpacing(12, after: enterMailLabel)
        
        toView.setLeft(offSet: 0)
        toView.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        
        toLabel.setLeft(offSet: X_SPACE)
        toLabel.setCenterY()
        let toLabelWidth = toLabel.sizeThatFits(CGSize(width: 100, height: 50)).width
        toLabel.setWidth(constant: toLabelWidth)
        
        toValueViewWidth -= (X_SPACE + toLabelWidth)
        
        toValueStackView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: toLabel, relatedAttribute: .right)
        toValueStackView.setRight(offSet: -CARD_PADDING)
        toValueStackView.setTop(offSet: 6)
        toValueStackView.setBottom(offSet: -6)
        
        toValueViewWidth -= (CARD_PADDING * 2)
        
        toPracticeView.setLeft(offSet: 0)
        toPracticeView.setRight(offSet: 0)
        
        toPracticeTextField.setLeft(offSet: 0)
        toPracticeTextField.setRight(offSet: 0)
        toPracticeTextField.setTop(offSet: 0)
        toPracticeTextField.setBottom(offSet: 0)
        toPracticeTextField.setHeight(constant: 32)
        
        toOtherTextField.setLeft(offSet: 0)
        toOtherTextField.setRight(offSet: 0)
        toOtherTextField.setTop(offSet: 0)
        toOtherTextField.setBottom(offSet: 0)
        toOtherTextField.setHeight(constant: 32)
    
        toOtherView.setLeft(offSet: 0)
        toOtherView.setRight(offSet: 0)
        
        receiverListTableView.setLeft(offSet: 0)
        receiverListTableView.setRight(offSet: 0)
        let receiverListTableViewHeightContranit = NSLayoutConstraint(item: receiverListTableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        receiverListTableView.heightConstraint = receiverListTableViewHeightContranit
        shareToSubView.addConstraint(receiverListTableViewHeightContranit)
        receiverListTableView.maxHeight = 200
        shareToSubView.setCustomSpacing(0, after: toView)
        shareToSubView.setCustomSpacing(0, after: noDataOthersView)
        shareToSubView.setCustomSpacing(0, after: noDataMemberView)
        
        noDataMemberView.setLeft(offSet: 0)
        noDataMemberView.setRight(offSet: 0)
        noDataMemberView.setHeight(constant: 70)
        
        noDataLabel.setCenterX()
        noDataLabel.setCenterY()
        
        noDataOthersView.setLeft(offSet: 0)
        noDataOthersView.setRight(offSet: 0)
        
        notAvailabelLabel.setCenterX()
        notAvailabelLabel.setTop(offSet: CARD_PADDING + 3)
        notAvailabelLabel.setWidth(constant: notAvailabelLabel.sizeThatFits(CGSize(width: applicationFrame.width, height: 50)).width)
        
        addToContactBtn.setCenterX()
        addToContactBtn.setTopRelatedToView(offSet: CARD_PADDING, relatedView: notAvailabelLabel, relatedAttribute: .bottom)
        addToContactBtn.setBottom(offSet: -(CARD_PADDING * 2))
        addToContactBtn.setHeight(constant: CARD_PADDING * 2)
        
        documentWillShareLabel.setLeft(offSet: 0)
        documentWillShareLabel.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        
        expiryView.setLeft(offSet: 0)
        expiryView.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        expiryView.setHeight(constant: ACTION_BTN_HEIGT)
        
        expiryLabel.setLeft(offSet: X_SPACE)
        expiryLabel.setTop(offSet: CARD_PADDING + 2)
        expiryLabel.setBottom(offSet: -(CARD_PADDING + 2))
        expiryLabel.setWidth(constant: expiryLabel.sizeThatFits(CGSize(width: 300, height: 50)).width)
        
        expiryValueLabel.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: expiryLabel, relatedAttribute: .right)
        expiryValueLabel.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: rightArrowIcon, relatedAttribute: .left)
        expiryValueLabel.setTop(offSet: (CARD_PADDING + 2))
        expiryValueLabel.setBottom(offSet: -(CARD_PADDING + 2))
        
        rightArrowIcon.setRight(offSet: -CARD_PADDING)
        rightArrowIcon.setHeight(constant: X_SPACE)
        rightArrowIcon.setWidth(constant: CARD_PADDING + 1)
        rightArrowIcon.setTop(offSet: CARD_PADDING + 4)
        rightArrowIcon.setBottom(offSet: -(CARD_PADDING + 4))
        
        attachmentView.setLeft(offSet: 0)
        attachmentView.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        
        informationView.setLeft(offSet: 0)
        informationView.setWidth(constant: SHARE_DOCUMENT_FRAME_WIDTH)
        informationView.setBottom(offSet: -20)
    }
    
    //MARK: - addProperties
    private func addProperties(){
        
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        shareToSegmentControl.addProperties(fontSize: FONT_SIZE_NORMAL)
        shareToSegmentControl.selectedSegmentIndex = 0
        
        shareToSubView.axis = .vertical
        shareToSubView.spacing = 16
        shareToSubView.alignment = .fill
        
        enterMailLabel.text = getString(key: "com.charmphr.sharedocuments.enterEmail.title")
        enterMailLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        enterMailLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        enterMailLabel.numberOfLines = 0
        enterMailLabel.lineBreakMode = .byTruncatingTail
        enterMailLabel.textAlignment = .left
        enterMailLabel.isHidden = true
        
        toView.addShadowAndCornerRadius(.SMALL)
        
        toValueStackView.axis = .vertical
        toValueStackView.spacing = 0
        toValueStackView.alignment = .fill
        
        toLabel.text = getString(key: "com.charmphr.sharedocuments.toLabel.title")
        toLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        toLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        
        toPracticeTextField.textAlignment = .left
        toPracticeTextField.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        toPracticeTextField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        setAttributedPlaceHolder(textField: toPracticeTextField, str: getString(key: "com.charmphr.sharedocuments.practiceField.placeHolder.title"))
        toPracticeTextField.returnKeyType = .done
        
        toOtherTextField.textAlignment = .left
        toOtherTextField.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        toOtherTextField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        setAttributedPlaceHolder(textField: toOtherTextField, str: getString(key: "com.charmphr.sharedocuments.otherField.placeHolder.title"))
        toOtherTextField.returnKeyType = .done
        
        noDataMemberView.addShadowAndCornerRadius(.SMALL)
        noDataMemberView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        noDataLabel.text = getString(key: "com.charmphr.sharedocuments.member.noDataLabel.title")
        noDataLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        noDataLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        
        hideMemberNoData(isHidden: true)
        noDataOthersView.addShadowAndCornerRadius(.SMALL)
        noDataOthersView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        receiverListTableView.sectionHeaderTopPadding = BORDER_WIDTH
        receiverListTableView.isScrollEnabled = true
        receiverListTableView.backgroundColor = .white
        receiverListTableView.addCornerRadius(.SMALL)
        receiverListTableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        notAvailabelLabel.text = getString(key: "com.charmphr.sharedocuments.notavailabel.title")
        notAvailabelLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        notAvailabelLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        
        addToContactBtn.setProperties(titleStrKey:getString(key: "com.charmphr.sharedocuments.addToContact.title"), fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: THEME_COLOR)
        hideOthersNoData(isHidden: true)
        
        documentWillShareLabel.text = getString(key: "com.charmphr.sharedocuments.documentWillShareLabel.title")
        documentWillShareLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        documentWillShareLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        documentWillShareLabel.textAlignment = .left
        documentWillShareLabel.numberOfLines = 0
        documentWillShareLabel.lineBreakMode = .byTruncatingTail
        
        expiryView.addShadowAndCornerRadius(.SMALL)
        
        expiryLabel.text = getString(key: "com.charmphr.sharedocuments.expiryLabel.title")
        expiryLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        expiryLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        
        expiryValueLabel.text = expiryDaysList[0]
        expiryValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        expiryValueLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        expiryValueLabel.textAlignment = .right
        
        informationView.isHidden = true
        
        isOthersViewHidden(isHidden: true)
    }
    
    //MARK: - Other functions
    
    func isOthersViewHidden(isHidden: Bool){
        enterMailLabel.isHidden = isHidden
        expiryView.isHidden = isHidden
        toOtherView.isHidden = isHidden
        toPracticeView.isHidden = !isHidden
        documentWillShareLabel.isHidden = !isHidden
        if isHidden{
            shareToSubView.setCustomSpacing(24, after: receiverListTableView)
        }
        else{
            shareToSubView.setCustomSpacing(16, after: receiverListTableView)
        }
    }
    
    private func setAttributedPlaceHolder(textField: UITextField, str: String){
        textField.attributedPlaceholder = NSAttributedString(
            string: str,
            attributes: [NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: PLACE_HOLDER_COLOR), NSAttributedString.Key.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)])
    }
    
    func hideMemberNoData(isHidden: Bool){
        if !isHidden{
            setConerRadiusOnlyUp()
        }
        else{
            setAllCornerRadius()
        }
        noDataMemberView.isHidden = isHidden
        noDataLabel.isHidden = isHidden
    }
    
    func hideOthersNoData(isHidden: Bool){
        
        if !isHidden{
            setConerRadiusOnlyUp()
        }
        else{
            setAllCornerRadius()
        }
        noDataOthersView.isHidden = isHidden
        notAvailabelLabel.isHidden = isHidden
        addToContactBtn.isHidden = isHidden
    }
    
    func setConerRadiusOnlyUp(){
        toView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    func setAllCornerRadius(){
        toView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //remove the deleted view and re-arrange the remaining constraints fo the view
    
    func removeDeletedViewAndSetConstraints(removedView: CardViewWithCloseBtn?, isMember: Bool){
        
        hasspace = false
        viewframe = applicationFrame.width - 90
        beforeCardView = nil
        
        let index: Int = toPracticeView.subviews.firstIndex(where: { cardView in
            if let cardViewWithCloseBtn = cardView as? CardViewWithCloseBtn{
                return removedView == cardViewWithCloseBtn
            }
            else{
                return false
            }
        }) ?? -1
        removedView?.removeFromSuperview()
        
        if isMember{
            removeAndSetSubViewsFromSuperView(uiView: toPracticeView, index: index)
        }
        else{
            removeAndSetSubViewsFromSuperView(uiView: toOtherView, index: index)
        }
    }
    
    private func removeAndSetSubViewsFromSuperView(uiView: UIView, index: Int){
        for i in 0..<uiView.subviews.count{
            if let cardViewWithCloseBtn = uiView.subviews[i] as? CardViewWithCloseBtn{
                let width = cardViewWithCloseBtn.getViewWidth()
                if i >= index{
                    cardViewWithCloseBtn.removeConstraints()
                    if i == 1{
                        hasspace = false
                    }
                    else{
                        if width <= viewframe{
                            hasspace = true
                        }
                        else{
                            hasspace = false
                            viewframe = applicationFrame.width - 90
                        }
                    }
                    setConstraintsToView(uiView: cardViewWithCloseBtn, viewWidth: width)
                }
                else{
                    if i == 1{
                        hasspace = false
                    }
                    else{
                        if width <= viewframe{
                            hasspace = true
                        }
                        else{
                            hasspace = false
                            viewframe = applicationFrame.width - 90
                        }
                    }
                    beforeCardView = cardViewWithCloseBtn
                    viewframe = viewframe - width
                }
            }
            else{
                if uiView.subviews.count == 1{
                    viewframe = 0
                }
            }
        }
        for i in 0..<uiView.subviews.count{
            if let textField = uiView.subviews[i] as? UITextField{
                textField.removeConstraints()
                textField.arrangeViews(constant: 10, hasSpace: viewframe > 75, beforeView: beforeCardView)
                textField.setBottom(offSet: 0)
                textField.setHeight(constant: 32)
                if viewframe > 75{
                    textField.setWidth(constant: viewframe - 10)
                }
                else{
                    textField.setWidth(constant: applicationFrame.width - 100)
                }
            }
        }
    }
    
    // setting constraints for the views
    
    private func setConstraintsToView(uiView: UIView, viewWidth: CGFloat){
        
        uiView.arrangeViews(constant: 8, hasSpace: hasspace, beforeView: beforeCardView)
        beforeCardView = uiView
        viewframe = viewframe - viewWidth
        
        uiView.setWidth(constant: viewWidth)
        uiView.setHeight(constant: 32)
        
    }
}
