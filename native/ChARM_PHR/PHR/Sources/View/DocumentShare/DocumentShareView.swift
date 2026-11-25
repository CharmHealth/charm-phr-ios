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
    let toPracticeView = WidthObservingView()
    let toPracticeTextField = CustomTextField()
    let toOtherView = WidthObservingView()
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
    var viewframe: CGFloat = 0
    var beforeCardView: UIView?
    var segmentControlHeightConstraint: NSLayoutConstraint? = nil
    private var toLabelWidth: CGFloat = 0
    private let chipSpacing: CGFloat = 8
    
    /// Live width of one chip row in the given "To" container (was applicationFrame.width - 90 at
    /// launch), so recipient chips wrap to the current screen size on the iPhone Duo / in landscape.
    private func chipRowWidth(in container: UIView) -> CGFloat {
        if container.bounds.width > 0 {
            return container.bounds.width
        }
        let visibleWidth = bounds.width > 0 ? bounds.width : applicationFrame.width
        return max(visibleWidth - (X_SPACE * 3) - toLabelWidth - (CARD_PADDING * 3), 0)
    }
    
    /// Maximum width of a single recipient chip (one full row of the visible container).
    var toValueViewWidth: CGFloat {
        return chipRowWidth(in: toPracticeView.isHidden ? toOtherView : toPracticeView)
    }
    
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
        
        // Re-wrap the chips whenever a container's own width changes (rotation, fold/unfold, side bar).
        // Observed on the container itself: its bounds are already updated when its layoutSubviews runs.
        toPracticeView.onWidthChange = { [weak self] in
            guard let self, self.toPracticeView.subviews.contains(where: { $0 is CardViewWithCloseBtn }) else { return }
            self.removeDeletedViewAndSetConstraints(removedView: nil, isMember: true)
        }
        toOtherView.onWidthChange = { [weak self] in
            guard let self, self.toOtherView.subviews.contains(where: { $0 is CardViewWithCloseBtn }) else { return }
            self.removeDeletedViewAndSetConstraints(removedView: nil, isMember: false)
        }
    }
    
    //MARK: - addConstraints
    
    private func addConstraints(){
        
        // Safe-area edges keep the form clear of the Dynamic Island and the iOS 27.1 landscape side bar.
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)
        containerScrollView.setSafeAreaTop(offset: CARD_PADDING)
        containerScrollView.setSafeAreaBottom(offset: 0)
        
        segmentControlView.setTop(offSet: 0)
        segmentControlView.setLeft(offSet: X_SPACE)
        // Visible width minus side margins (was the launch-time SHARE_DOCUMENT_FRAME_WIDTH).
        segmentControlView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor, constant: -(X_SPACE * 2)).isActive = true
        
        shareToSegmentControl.setLeft(offSet: 0)
        shareToSegmentControl.setRight(offSet: 0)
        shareToSegmentControl.setTop(offSet: 0)
        shareToSegmentControl.setBottom(offSet: 0)
        segmentControlHeightConstraint = shareToSegmentControl.setAndReturnHeight(constant: 0)
        
        shareToSubView.setLeft(offSet: X_SPACE)
        shareToSubView.setRight(offSet: -X_SPACE)
        shareToSubView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: segmentControlView, relatedAttribute: .bottom)
        shareToSubView.setBottom(offSet: -20)
        // Edge pins inside a scroll view only set content bounds; tie the width to the visible area.
        // All sections below fill it via the stack's .fill alignment.
        shareToSubView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor, constant: -(X_SPACE * 2)).isActive = true
        
        enterMailLabel.setLeft(offSet: 0)
        enterMailLabel.setRight(offSet: 0)
        enterMailLabel.setTop(offSet: 2)
        
        shareToSubView.setCustomSpacing(12, after: enterMailLabel)
        
        toView.setLeft(offSet: 0)
        
        toLabel.setLeft(offSet: X_SPACE)
        toLabel.setCenterY()
        toLabelWidth = toLabel.sizeThatFits(CGSize(width: 100, height: 50)).width
        toLabel.setWidth(constant: toLabelWidth)
        
        toValueStackView.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: toLabel, relatedAttribute: .right)
        toValueStackView.setRight(offSet: -CARD_PADDING)
        toValueStackView.setTop(offSet: 6)
        toValueStackView.setBottom(offSet: -6)
        
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
        // Wraps within the card instead of a launch-time single-line width.
        notAvailabelLabel.setLeft(offSet: CARD_PADDING, relatedBy: .greaterThanOrEqual)
        
        addToContactBtn.setCenterX()
        addToContactBtn.setTopRelatedToView(offSet: CARD_PADDING, relatedView: notAvailabelLabel, relatedAttribute: .bottom)
        addToContactBtn.setBottom(offSet: -(CARD_PADDING * 2))
        addToContactBtn.setHeight(constant: CARD_PADDING * 2)
        
        documentWillShareLabel.setLeft(offSet: 0)
        
        expiryView.setLeft(offSet: 0)
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
        
        informationView.setLeft(offSet: 0)
        // No bottom pin here: informationView is an arranged subview, so pinning it to the stack's bottom
        // fought the stack's own constraints and shortened the scroll content (the last attachment row
        // could not be scrolled into view). The 20pt bottom padding now lives on shareToSubView instead.
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
        notAvailabelLabel.numberOfLines = 0
        notAvailabelLabel.textAlignment = .center
        
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
        removedView?.removeFromSuperview()
        relayoutChips(in: isMember ? toPracticeView : toOtherView)
    }
    
    /// Flows every chip left-to-right, wrapping to a new line when the next chip (plus the gap) does
    /// not fit, then places the search field after the last chip or on its own line.
    private func relayoutChips(in container: UIView){
        let rowWidth = chipRowWidth(in: container)
        hasspace = false
        viewframe = rowWidth
        beforeCardView = nil
        
        for case let chip as CardViewWithCloseBtn in container.subviews {
            // Clamp to the current row so a chip created on a wider screen still fits after folding.
            let width = min(chip.getViewWidth(), rowWidth)
            chip.removeConstraints()
            
            if beforeCardView != nil, width + chipSpacing <= viewframe {
                hasspace = true                 // same line, after the previous chip
                viewframe -= chipSpacing
            }
            else {
                hasspace = false                // first chip, or wrap to a new line
                viewframe = rowWidth
            }
            setConstraintsToView(uiView: chip, viewWidth: width)
        }
        
        for case let textField as UITextField in container.subviews {
            textField.removeConstraints()
            let fitsOnLastLine = beforeCardView != nil && viewframe > 75
            textField.arrangeViews(constant: 10, hasSpace: fitsOnLastLine, beforeView: beforeCardView)
            textField.setBottom(offSet: 0)
            textField.setHeight(constant: 32)
            textField.setWidth(constant: fitsOnLastLine ? viewframe - 10 : max(rowWidth, 0))
        }
    }
    
    // setting constraints for the views
    
    private func setConstraintsToView(uiView: UIView, viewWidth: CGFloat){
        
        uiView.arrangeViews(constant: chipSpacing, hasSpace: hasspace, beforeView: beforeCardView)
        beforeCardView = uiView
        viewframe = viewframe - viewWidth
        
        uiView.setWidth(constant: viewWidth)
        uiView.setHeight(constant: 32)
        
    }
}
