//
//  CardItemView.swift
//  phr
//
//  Created by Raghul D on 19/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

class CardItemView: UIView {
    
    static let cardPadding:CGFloat = 16.0
    static let itemGrpVerticalMargin: CGFloat = 30.0
    static let itemVerticalMargin: CGFloat = 4.0
    
//contentInset
    
    //needsLayout
    
    let cardBrandLabel = UILabel()
    let cardNumberLabel = UILabel()
    let cardNickNameLabel = UILabel()
    let cardNickNameValueLabel = UILabel()
    let cardExpiryLabel = UILabel()
    let cardExpiryValueLabel = UILabel()
    
    lazy var editBtn = UIImageView(image: UIImage(named: "editIcon"))
    lazy var deleteBtn = UIImageView(image: UIImage(named: "deleteIcon"))

    lazy var topBg = UIImageView(image: UIImage(named: "topBg"))
    lazy var bottomBg = UIImageView(image: UIImage(named: "bottombg"))

    private var card: PaymentGatewayToken? = nil
    weak var delegate:CardItemViewDelegate? = nil

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        
        self.addSubview(topBg)
        self.addSubview(bottomBg)
        self.addSubview(cardNumberLabel)
        self.addSubview(cardBrandLabel)
        self.addSubview(cardNickNameLabel)
        self.addSubview(cardNickNameValueLabel)
        self.addSubview(cardExpiryLabel)
        self.addSubview(cardExpiryValueLabel)
        self.addSubview(editBtn)
        self.addSubview(deleteBtn)

        setProperties()
        addConstraints()
    }

    private func setProperties()  {
        addShadowAndCornerRadius(.SMALL)
     
        topBg.clipsToBounds = true
        topBg.addCornerRadius(.SMALL)
        topBg.layer.maskedCorners = [.layerMaxXMinYCorner]
        
        bottomBg.clipsToBounds = true
        bottomBg.addCornerRadius(.SMALL)
        bottomBg.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        editBtn.isUserInteractionEnabled = true
        deleteBtn.isUserInteractionEnabled = true

        self.setBackgroundColor(bgColor: 0x374879FF)
        cardBrandLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, textColor: .white )
        cardBrandLabel.numberOfLines = 1

        cardNumberLabel.setProperties(textKey: "", fontsize: FONT_SIZE_TWENTY, weight: .semibold, textColor: .white )
        cardNumberLabel.numberOfLines = 1
        
        cardNickNameLabel.setProperties(textKey: "com.charmphr.card.nickname.label", fontsize: FONT_SIZE_NORMAL, weight: .regular, textColor: .white )
        cardNickNameLabel.numberOfLines = 1
        
        cardNickNameValueLabel.setProperties(textKey: "", fontsize: FONT_SIZE_TWENTY, weight: .semibold, textColor: .white )
        cardNickNameValueLabel.numberOfLines = 1
        cardNickNameValueLabel.lineBreakMode = .byTruncatingTail
        
        cardExpiryLabel.setProperties(textKey: "com.charmphr.card.expiry.label", fontsize: FONT_SIZE_NORMAL, weight: .regular, textColor: .white )
        cardExpiryLabel.numberOfLines = 1
        
        cardExpiryValueLabel.setProperties(textKey: "", fontsize: FONT_SIZE_TWENTY, weight: .semibold, textColor: .white )
        cardExpiryValueLabel.numberOfLines = 1
        cardExpiryValueLabel.lineBreakMode = .byTruncatingTail
        
        

//       // cardNumberLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
//
//        questionnaireFacilityLabel.numberOfLines = 1
//        questionnaireFacilityLabel.lineBreakMode = .byTruncatingTail
//        questionnaireFacilityLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
//
//        questionnaireFacilityHintLabel.setProperties(textKey: NSLocalizedString("com.charmphr.questionnaire.facility.hint", comment: ""), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
//
//        questionnaireMemberLabel.numberOfLines = 1
//        questionnaireMemberLabel.lineBreakMode = .byTruncatingTail
//        questionnaireMemberLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
//
//        questionnaireMemberHintLabel.setProperties(textKey: NSLocalizedString("com.charmphr.questionnaire.member.hint", comment: ""), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
//
//        questionnaireAppointmentDateLabel.numberOfLines = 1
//        questionnaireAppointmentDateLabel.lineBreakMode = .byTruncatingTail
//        questionnaireAppointmentDateLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
//
//        questionnaireAppointmentDateHintLabel.setProperties(textKey: NSLocalizedString("com.charmphr.questionnaire.appointmentdate.hint", comment: ""), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)
//
//        if #available(iOS 11.0, *) {
//            self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0,leading: 0,bottom: -CardItemView.cardPadding,trailing: 0)
//            questionnaireStatusLabel.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5,leading: 5,bottom: 5,trailing: 5)
//        }
//        else{
//            questionnaireStatusLabel.layoutMargins = UIEdgeInsets(top: 5,left: 5,bottom: -5,right: -5)
//            self.layoutMargins = UIEdgeInsets(top: 0,left: 0,bottom: -CardItemView.cardPadding,right: 0)
//        }
    }
    
    private func addConstraints() {
       
        
        topBg.setTop(offSet: 0)
        topBg.setRight(offSet: 0)
        topBg.setWidth(constant: 105)
        topBg.setHeight(constant: 110)
        
        
        bottomBg.setRight(offSet: 0)
        bottomBg.setBottom(offSet: 0)
        bottomBg.setWidth(constant: 34)
        bottomBg.setHeight(constant: 45)
        
        deleteBtn.setRight(offSet: -CardItemView.cardPadding)
        deleteBtn.setSafeAreaTop(offset: CardItemView.cardPadding)
        deleteBtn.setHeight(constant: 27)
        deleteBtn.setWidth(constant: 27)
        
        editBtn.setRight(offSet: -CardItemView.cardPadding)
        editBtn.setSafeAreaBottom(offset: -CardItemView.cardPadding)
        editBtn.setHeight(constant: 27)
        editBtn.setWidth(constant: 27)
        
        cardBrandLabel.setSafeAreaTop(offset: CardItemView.cardPadding)
        cardBrandLabel.setLeft(offSet: CardItemView.cardPadding)
        cardBrandLabel.setRightRelatedToView(offSet: -CardItemView.cardPadding, relatedView: deleteBtn, relatedAttribute: .left)
        
        cardNumberLabel.setTopRelatedToView(offSet: CardItemView.cardPadding, relatedView: cardBrandLabel, relatedAttribute: .bottom)
        cardNumberLabel.setLeft(offSet: CardItemView.cardPadding)
        cardNumberLabel.setRightRelatedToView(offSet: -CardItemView.cardPadding, relatedView: deleteBtn, relatedAttribute: .left)
        
        cardNickNameLabel.setTopRelatedToView(offSet: CardItemView.itemGrpVerticalMargin, relatedView: cardNumberLabel, relatedAttribute: .bottom)
        cardNickNameLabel.setLeft(offSet: CardItemView.cardPadding)
        cardNickNameLabel.setRightRelatedToView(offSet: -CardItemView.cardPadding, relatedView: cardExpiryLabel, relatedAttribute: .left)
        
        cardNickNameValueLabel.setTopRelatedToView(offSet: CardItemView.itemVerticalMargin, relatedView: cardNickNameLabel, relatedAttribute: .bottom)
        cardNickNameValueLabel.setLeft(offSet: CardItemView.cardPadding)
        cardNickNameValueLabel.setRightRelatedToView(offSet: -CardItemView.cardPadding, relatedView: cardExpiryLabel, relatedAttribute: .left)
        cardNickNameValueLabel.setBottom(offSet: -CardItemView.cardPadding)
        
        cardExpiryLabel.setTopRelatedToView(offSet: CardItemView.itemGrpVerticalMargin, relatedView: cardNumberLabel, relatedAttribute: .bottom)
        cardExpiryLabel.setRightRelatedToView(offSet: -CardItemView.cardPadding, relatedView: editBtn, relatedAttribute: .left)
        cardExpiryLabel.setWidth(constant: cardExpiryLabel.sizeThatFits(CGSize(width: 70, height: 20)).width)
        
        cardExpiryValueLabel.setTopRelatedToView(offSet: CardItemView.itemVerticalMargin, relatedView: cardExpiryLabel, relatedAttribute: .bottom)
        cardExpiryValueLabel.setRightRelatedToView(offSet: -CardItemView.cardPadding, relatedView: editBtn, relatedAttribute: .left)
        cardExpiryValueLabel.setBottom(offSet: -CardItemView.cardPadding)
        
        
//        questionnaireFacilityHintTopConstraint =  questionnaireFacilityHintLabel.setAndReturnTopRelatedToView(offSet: CardItemView.itemVerticalMargin, relatedView: questionnaireNameLabel, relatedAttribute: .bottom)
//        questionnaireFacilityHintLabel.setLeft(offSet: CardItemView.cardPadding)
//        questionnaireFacilityHintHeightConstraint = questionnaireFacilityHintLabel.setAndReturnHeight(constant: CardItemView.normalTVHeight)
//        questionnaireFacilityHintLabel.setWidth(constant: questionnaireFacilityHintLabel.sizeThatFits(CGSize(width: 200, height: CardItemView.normalTVHeight)).width)
//
//        questionnaireFacilityLabel.setTopRelatedToView(offSet: 0, relatedView: questionnaireFacilityHintLabel, relatedAttribute: .top)
//        questionnaireFacilityLabel.setLeftRelatedToView(offSet: CardItemView.itemTextSpacing, relatedView: questionnaireFacilityHintLabel , relatedAttribute: .right)
//        questionnaireFacilityLabel.setRight(offSet: -CardItemView.cardPadding)
//        questionnaireFacilityHeightConstraint = questionnaireFacilityLabel.setAndReturnHeight(constant: CardItemView.normalTVHeight)
//
//
//        questionnaireMemberHintTopConstraint =  questionnaireMemberHintLabel.setAndReturnTopRelatedToView(offSet: CardItemView.itemVerticalMargin, relatedView: questionnaireFacilityLabel, relatedAttribute: .bottom)
//        questionnaireMemberHintLabel.setLeft(offSet: CardItemView.cardPadding)
//        questionnaireMemberHintHeightConstraint = questionnaireMemberHintLabel.setAndReturnHeight(constant: CardItemView.normalTVHeight)
//        questionnaireMemberHintLabel.setWidth(constant: questionnaireMemberHintLabel.sizeThatFits(CGSize(width: 200, height: CardItemView.normalTVHeight)).width)
//
//        questionnaireMemberLabel.setTopRelatedToView(offSet: 0, relatedView: questionnaireMemberHintLabel, relatedAttribute: .top)
//        questionnaireMemberLabel.setLeftRelatedToView(offSet: CardItemView.itemTextSpacing, relatedView: questionnaireMemberHintLabel , relatedAttribute: .right)
//        questionnaireMemberLabel.setRight(offSet: -CardItemView.cardPadding)
//        questionnaireMemberHeightConstraint = questionnaireMemberLabel.setAndReturnHeight(constant: CardItemView.normalTVHeight)
//
//        questionnaireDateHintHeightConstraint = questionnaireAppointmentDateHintLabel.setAndReturnHeight(constant: CardItemView.normalTVHeight)
//        questionnaireAppointmentDateHintLabel.setWidth(constant: questionnaireAppointmentDateHintLabel.sizeThatFits(CGSize(width: 200, height: CardItemView.normalTVHeight)).width)
//
//        questionnaireDateHintTopConstraint =  questionnaireAppointmentDateHintLabel.setAndReturnTopRelatedToView(offSet: CardItemView.itemVerticalMargin, relatedView: questionnaireMemberLabel, relatedAttribute: .bottom)
//        questionnaireAppointmentDateHintLabel.setLeft(offSet: CardItemView.cardPadding)
//        questionnaireAppointmentDateHintLabel.setBottom(offSet: -CardItemView.cardPadding)
//
//
//        questionnaireAppointmentDateLabel.setTopRelatedToView(offSet: 0, relatedView: questionnaireAppointmentDateHintLabel, relatedAttribute: .top)
//        questionnaireAppointmentDateLabel.setLeftRelatedToView(offSet: CardItemView.itemTextSpacing, relatedView: questionnaireAppointmentDateHintLabel , relatedAttribute: .right)
//        questionnaireAppointmentDateLabel.setRight(offSet: -CardItemView.cardPadding)
//        questionnaireAppointmentDateLabel.setBottom(offSet: -CardItemView.cardPadding)
//        questionnaireDateHeightConstraint = questionnaireAppointmentDateLabel.setAndReturnHeight(constant: CardItemView.normalTVHeight)

    }
    
    func setValues(card: PaymentGatewayToken) {
        cardBrandLabel.text = card.cardBrand
        cardNumberLabel.setText(key: "com.charmphr.card.number.redacted", with: [card.cardDigit ?? ""])
        
        
        if card.hasCardExpired{
            cardExpiryValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_RED)
        }
        else{
            cardExpiryValueLabel.textColor = .white
        }
        
        if !card.cardNickName.isNilOrBlank(){
            cardNickNameValueLabel.text = card.cardNickName
        }
        else if !card.nameOnCard.isNilOrBlank(){
            cardNickNameValueLabel.text = card.nameOnCard
        }
        else{
            cardNickNameValueLabel.text = "-"
        }
        cardExpiryValueLabel.text = card.expiry
        deleteBtn.isHidden = !card.allowPracticeCardDeletion && !card.isPHRCard
        
        editBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onEditClicked(view:))))
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDeleteClicked(view:))))

        self.card = card
    }
    
    @objc func onEditClicked(view: UIView){
        if let card = card {
            delegate?.onCardEdit(card: card)
        }
    }
    
    @objc func onDeleteClicked(view: UIView){
        if let card = card {
            delegate?.onCardDelete(card: card)
        }
    }
}


protocol CardItemViewDelegate: AnyObject{
    func onCardEdit(card: PaymentGatewayToken)
    func onCardDelete(card: PaymentGatewayToken)
}

