//
//  DocumentTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 15/11/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class DocumentTableViewCell: UITableViewCell{
    
    let documentItemView = DocumentItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(documentItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        documentItemView.setHorizontal(offSet: X_SPACE)
        documentItemView.setTop(offSet: PADDING_5)
        documentItemView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: Document){
        
        documentItemView.nameLabel.text = data.fileName
        if data.sharedByMeArr.isEmpty && data.sentby.isNilOrBlank()
        {
            documentItemView.horizontalLine.isHidden = true
            documentItemView.shareToView.isHidden = true
            documentItemView.sharedByView.isHidden = true
            documentItemView.dateLabel.text = CharmUtil.getDateStringWith(date: data.date, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            
        }else
        {
            documentItemView.horizontalLine.isHidden = false
            
            if data.sharedByMeArr.isEmpty{
                documentItemView.shareToView.isHidden = true
                documentItemView.dateLabel.text = CharmUtil.getDateStringWith(date: data.sharedDate ?? data.date, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            }
            else{
                documentItemView.shareToView.isHidden = false
                documentItemView.sharedToValueLabel.text = data.sharedByMeArr.joined(separator: ",")
                documentItemView.dateLabel.text = CharmUtil.getDateStringWith(date: data.date, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            }
            if data.sentby.isNilOrBlank(){
                documentItemView.sharedByView.isHidden = true
            }
            else{
                documentItemView.sharedByView.isHidden = false
                documentItemView.sharedByValueLabel.text = data.sentby
            }
        }
        
        if documentItemView.shareToView.isHidden{
            documentItemView.bottomConstraint?.constant = -CARD_PADDING
        }
        else{
            documentItemView.bottomConstraint?.constant = -PADDING_5
        }
    }
    
    func unreadDocument()
    {
        documentItemView.nameLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        documentItemView.sharedByValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        documentItemView.sharedToValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        documentItemView.dateLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
    }
    
    func readDocument()
    {
        documentItemView.nameLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        documentItemView.sharedByValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        documentItemView.sharedToValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        documentItemView.dateLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
    }
}

//MARK: - Document Item View

class DocumentItemView: UIView{
    
    let shareLabel = UILabel()
    let deleteLabel = UILabel()
    let unShareLabel = UILabel()
    let verticalStackView = UIStackView()
    let dateLabel = UILabel()
    let nameLabelView = UIView()
    let nameLabel = UILabel()
    let horizontalLine = UIView()
    let sharedByView = UIView()
    let sharedByLabel = UILabel()
    let sharedByValueLabel = UILabel()
    let shareToView = UIView()
    let sharedToLabel = UILabel()
    let sharedToValueLabel = UILabel()
    var bottomConstraint: NSLayoutConstraint? = nil
    var shareLabelWidthConstraint: NSLayoutConstraint? = nil
    var unShareLabelWidthConstraint: NSLayoutConstraint? = nil
    var deleteLabelWidthConstraint: NSLayoutConstraint? = nil
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews(){
        self.addSubview(verticalStackView)
        self.addSubview(shareLabel)
        self.addSubview(unShareLabel)
        self.addSubview(deleteLabel)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(nameLabelView)
        nameLabelView.addSubview(nameLabel)
        verticalStackView.addArrangedSubview(horizontalLine)
        verticalStackView.addArrangedSubview(sharedByView)
        sharedByView.addSubview(sharedByLabel)
        sharedByView.addSubview(sharedByValueLabel)
        verticalStackView.addArrangedSubview(shareToView)
        shareToView.addSubview(sharedToLabel)
        shareToView.addSubview(sharedToValueLabel)
        addProperties()
        addConstraints()
    }
    
    private func addProperties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 5
         
        setLabelProperties(uiLabel: dateLabel, text: "", ofSize: FONT_SIZE_MEDIUM, fontWeight: .semibold)
        setLabelProperties(uiLabel: nameLabel, text: "", ofSize: FONT_SIZE_EXTRALARGE, fontWeight: .semibold)
        
        horizontalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        
        setLabelProperties(uiLabel: sharedByLabel, text: getString(key: "com.charmphr.Document.sharedByLabel.title"), ofSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: sharedByValueLabel, text: "", ofSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        sharedByValueLabel.numberOfLines = 0
        setLabelProperties(uiLabel: sharedToLabel, text: getString(key: "com.charmphr.Document.sharedToLabel.title"), ofSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        setLabelProperties(uiLabel: sharedToValueLabel, text: "", ofSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        sharedToValueLabel.numberOfLines = 0
        
        setSwipeLabelProperties(uiLabel: shareLabel, bgColor: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), text: SHARE_LABEL)
        setSwipeLabelProperties(uiLabel: unShareLabel, bgColor: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), text: UNSHARE_LABEL)
        setSwipeLabelProperties(uiLabel: deleteLabel, bgColor: UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR), text: DELETE_LABEL)
    }
    
    private func addConstraints(){
        
        verticalStackView.setLeft(offSet: 0)
        verticalStackView.setTop(offSet: 0)
        verticalStackView.setBottom(offSet: 0)
        
        shareLabel.setLeftRelatedToView(offSet: 0, relatedView: verticalStackView, relatedAttribute: .right)
        shareLabel.setTop(offSet: 0)
        shareLabel.setBottom(offSet: 0)
        shareLabelWidthConstraint = shareLabel.setAndReturnWidth(constant: 0)
        
        unShareLabel.setLeftRelatedToView(offSet: 0, relatedView: shareLabel, relatedAttribute: .right)
        unShareLabel.setTop(offSet: 0)
        unShareLabel.setBottom(offSet: 0)
        unShareLabelWidthConstraint = unShareLabel.setAndReturnWidth(constant: 0)
        
        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: unShareLabel, relatedAttribute: .right)
        deleteLabel.setTop(offSet: 0)
        deleteLabel.setBottom(offSet: 0)
        deleteLabelWidthConstraint = deleteLabel.setAndReturnWidth(constant: 0)
        deleteLabel.setRight(offSet: 0)
        
        dateLabel.setLeft(offSet: CARD_PADDING)
        dateLabel.setTop(offSet: CARD_PADDING)
        dateLabel.setRight(offSet: -CARD_PADDING)
        
        nameLabelView.setLeft(offSet: CARD_PADDING)
        nameLabelView.setRight(offSet: -CARD_PADDING)
        
        nameLabel.setTop(offSet: 0)
        nameLabel.setBottom(offSet: -PADDING_5)
        nameLabel.setLeft(offSet: 0)
        nameLabel.setRight(offSet: 0)
        
        verticalStackView.setCustomSpacing(4, after: dateLabel)
        verticalStackView.setCustomSpacing(0, after: nameLabelView)
        verticalStackView.setCustomSpacing(0, after: sharedByView)
        
        horizontalLine.setLeft(offSet: CARD_PADDING)
        horizontalLine.setRight(offSet: -CARD_PADDING)
        horizontalLine.setHeight(constant: LINE_HEIGHT)
        
        sharedByView.setLeft(offSet: CARD_PADDING)
        sharedByView.setRight(offSet: -CARD_PADDING)
        
        sharedByLabel.setLeft(offSet: 0)
        sharedByLabel.setTop(offSet: 0)
        sharedByLabel.setWidth(constant: sharedByLabel.sizeThatFits(CGSize(width: 200, height: 50)).width)
        
        sharedByValueLabel.setLeft(offSet: 0)
        sharedByValueLabel.setRight(offSet: 0)
        sharedByValueLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: sharedByLabel, relatedAttribute: .bottom)
        bottomConstraint = sharedByValueLabel.setAndReturnBottom(offSet: 0)
        
        shareToView.setLeft(offSet: CARD_PADDING)
        shareToView.setRight(offSet: -CARD_PADDING)
        
        sharedToLabel.setLeft(offSet: 0)
        sharedToLabel.setTop(offSet: 0)
        sharedToLabel.setWidth(constant: sharedToLabel.sizeThatFits(CGSize(width: 200, height: 50)).width)
        
        sharedToValueLabel.setLeft(offSet: 0)
        sharedToValueLabel.setRight(offSet: 0)
        sharedToValueLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: sharedToLabel, relatedAttribute: .bottom)
        sharedToValueLabel.setBottom(offSet: -CARD_PADDING)
        
        shareLabel.setTop(offSet: 0)
        shareLabel.setBottom(offSet: 0)
        
    }
    func setLabelProperties(uiLabel: UILabel, text: String, ofSize fontSize:CGFloat, fontWeight: UIFont.FontWeight){
        uiLabel.text = text
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.textAlignment = .left
        uiLabel.lineBreakMode = .byTruncatingTail
        uiLabel.numberOfLines = 1
    }
    func setSwipeLabelProperties(uiLabel: UILabel, bgColor: UIColor, text: String){
        uiLabel.text = text
        uiLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        uiLabel.backgroundColor = bgColor
        uiLabel.textAlignment = .center
        uiLabel.addCornerRadius(.SMALL)
        uiLabel.isUserInteractionEnabled = true
    }
    func maskCorners(uiLabel: UILabel){
        uiLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    func unmaskCorners(uiLabel: UILabel){
        uiLabel.layer.maskedCorners = []
    }
    
    func setRowActionForSwipeLeft(duration: TimeInterval,isSentBy: Bool, isSharedByMe: Bool){
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            if isSentBy{
                shareLabelWidthConstraint?.constant = 70
                maskCorners(uiLabel: shareLabel)
            }
            else{
                if isSharedByMe{
                    //Code To be Written
                }else{
                    shareLabelWidthConstraint?.constant = 70
                    deleteLabelWidthConstraint?.constant = 70
                    unmaskCorners(uiLabel: shareLabel)
                    maskCorners(uiLabel: deleteLabel)
                }
            }
            self.layoutIfNeeded()
        })
    }
    func setRowActionForSwipeRight(duration: TimeInterval){
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            shareLabelWidthConstraint?.constant = 0
            unShareLabelWidthConstraint?.constant = 0
            deleteLabelWidthConstraint?.constant = 0
            self.layoutIfNeeded()
        })
    }
    
    func isSharedByMe(document: Document) -> Bool{
        return document.categoryId.isNilOrBlank() && (document.categoryName == getString(key: "com.charmphr.Documents.type.sharedByMe.title"))
    }
    
    func setRowActionForSwipeRight(){
        shareLabelWidthConstraint?.constant = 0
        unShareLabelWidthConstraint?.constant = 0
        deleteLabelWidthConstraint?.constant = 0
    }
    func setSelectedBGColor(){
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_BLUE_BACKGROUND_COLOR)
    }
    func setUnSelectedBGColor(){
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
    }
}
