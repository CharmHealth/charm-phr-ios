//
//  HomeQuestionnaireListView.swift
//  phr
//
//  Created by Raghul D on 03/03/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation

class HomeQuestionnaireListView : UIView{
    
    

    static let cardPadding:CGFloat = 10.0
    static let itemVerticalMargin: CGFloat = 4.0
    static let itemTextSpacing: CGFloat = 6.0
    static let statusHeight: CGFloat = 17
    static let normalTVHeight: CGFloat = 19

//contentInset
    
    //needsLayout
    
    let questionnaireNameLabel = UILabel()
    let questionnaireStatusLabel = UILabel()
    let questionnaireFacilityHintLabel = UILabel()
    let questionnaireFacilityLabel = UILabel()
    let questionnaireMemberHintLabel = UILabel()
    let questionnaireMemberLabel = UILabel()

    
    var questionnaireStatusWidthConstraint: NSLayoutConstraint?
    
    var questionnaireFacilityHintHeightConstraint: NSLayoutConstraint!
    var questionnaireFacilityHeightConstraint: NSLayoutConstraint!
    var questionnaireFacilityHintTopConstraint: NSLayoutConstraint!

    var questionnaireMemberHintHeightConstraint: NSLayoutConstraint!
    var questionnaireMemberHeightConstraint: NSLayoutConstraint!
    var questionnaireMemberHintTopConstraint: NSLayoutConstraint!

    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.addSubview(questionnaireNameLabel)
        self.addSubview(questionnaireStatusLabel)
        self.addSubview(questionnaireFacilityHintLabel)
        self.addSubview(questionnaireFacilityLabel)
        self.addSubview(questionnaireMemberHintLabel)
        self.addSubview(questionnaireMemberLabel)
        
        setProperties()
        addConstraints()
    }

    private func setProperties()  {
        
        questionnaireStatusLabel.textAlignment = .center
        questionnaireStatusLabel.layer.cornerRadius = 3
        questionnaireStatusLabel.layer.masksToBounds = true

        questionnaireStatusLabel.setProperties(textKey: "", fontsize: FONT_SIZE_MEDIUM, weight: .semibold, fontcolor: questionnaireListStatusNewTxtColor )
        questionnaireStatusLabel.setBackgroundColor(bgColor: questionnaireListStatusNewBg)
        
        questionnaireNameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        questionnaireNameLabel.numberOfLines = 0
        
        questionnaireFacilityLabel.numberOfLines = 1
        questionnaireFacilityLabel.lineBreakMode = .byTruncatingTail
        questionnaireFacilityLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)

        questionnaireFacilityHintLabel.setProperties(textKey: getString(key: "com.charmphr.questionnaire.facility.hint"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)

        questionnaireMemberLabel.numberOfLines = 1
        questionnaireMemberLabel.lineBreakMode = .byTruncatingTail
        questionnaireMemberLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)

        questionnaireMemberHintLabel.setProperties(textKey: getString(key: "com.charmphr.questionnaire.member.hint"), fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK70)

        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0,leading: 0,bottom: -QuestionnaireItemView.cardPadding,trailing: 0)
        questionnaireStatusLabel.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5,leading: 5,bottom: 5,trailing: 5)
    }
    
    private func addConstraints() {
        
        questionnaireStatusLabel.setRight(offSet: -QuestionnaireItemView.cardPadding)
        questionnaireStatusLabel.setSafeAreaTop(offset: QuestionnaireItemView.cardPadding)
        questionnaireStatusLabel.setHeight(constant: QuestionnaireItemView.statusHeight)
        
        
        questionnaireNameLabel.setSafeAreaTop(offset: QuestionnaireItemView.cardPadding)
        questionnaireNameLabel.setLeft(offSet: QuestionnaireItemView.cardPadding)
        questionnaireNameLabel.setRightRelatedToView(offSet: -QuestionnaireItemView.cardPadding, relatedView: questionnaireStatusLabel, relatedAttribute: .left)

        questionnaireFacilityHintTopConstraint =  questionnaireFacilityHintLabel.setAndReturnTopRelatedToView(offSet: QuestionnaireItemView.itemVerticalMargin, relatedView: questionnaireNameLabel, relatedAttribute: .bottom)
        questionnaireFacilityHintLabel.setLeft(offSet: QuestionnaireItemView.cardPadding)
        questionnaireFacilityHintHeightConstraint = questionnaireFacilityHintLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)
        questionnaireFacilityHintLabel.setWidth(constant: questionnaireFacilityHintLabel.sizeThatFits(CGSize(width: 200, height: QuestionnaireItemView.normalTVHeight)).width)

        questionnaireFacilityLabel.setTopRelatedToView(offSet: 0, relatedView: questionnaireFacilityHintLabel, relatedAttribute: .top)
        questionnaireFacilityLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: questionnaireFacilityHintLabel , relatedAttribute: .right)
        questionnaireFacilityLabel.setRight(offSet: -QuestionnaireItemView.cardPadding)
        questionnaireFacilityHeightConstraint = questionnaireFacilityLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)


        questionnaireMemberHintTopConstraint =  questionnaireMemberHintLabel.setAndReturnTopRelatedToView(offSet: QuestionnaireItemView.itemVerticalMargin, relatedView: questionnaireFacilityLabel, relatedAttribute: .bottom)
        questionnaireMemberHintLabel.setLeft(offSet: QuestionnaireItemView.cardPadding)
        questionnaireMemberHintHeightConstraint = questionnaireMemberHintLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)
        questionnaireMemberHintLabel.setWidth(constant: questionnaireMemberHintLabel.sizeThatFits(CGSize(width: 200, height: QuestionnaireItemView.normalTVHeight)).width)
        
        questionnaireMemberLabel.setTopRelatedToView(offSet: 0, relatedView: questionnaireMemberHintLabel, relatedAttribute: .top)
        questionnaireMemberLabel.setLeftRelatedToView(offSet: QuestionnaireItemView.itemTextSpacing, relatedView: questionnaireMemberHintLabel , relatedAttribute: .right)
        questionnaireMemberLabel.setRight(offSet: -QuestionnaireItemView.cardPadding)
        questionnaireMemberLabel.setBottom(offSet: -QuestionnaireItemView.cardPadding)
        questionnaireMemberHeightConstraint = questionnaireMemberLabel.setAndReturnHeight(constant: QuestionnaireItemView.normalTVHeight)

    }
    
    func setValues(physicianTemplate: PhysicianTemplates , type: String) {
        
        questionnaireNameLabel.text = physicianTemplate.name ?? ""
        
        if let patQuesMap = physicianTemplate.patientQuesMap {
            
    
            let memberName = physicianTemplate.member?.formMemberName()

            if !memberName.isNilOrBlank() {
                questionnaireMemberHintTopConstraint.constant = QuestionnaireItemView.itemVerticalMargin
                questionnaireMemberHeightConstraint.constant = QuestionnaireItemView.normalTVHeight
                questionnaireMemberHintHeightConstraint.constant = QuestionnaireItemView.normalTVHeight
                questionnaireMemberLabel.text = memberName
            }
            else{
                questionnaireMemberHintTopConstraint.constant = 0
                questionnaireMemberHeightConstraint.constant = 0
                questionnaireMemberHintHeightConstraint.constant = 0
            }
            
            let facilityName = patQuesMap.appointment?.facilityName

            if !facilityName.isNilOrBlank() {
                questionnaireFacilityHintTopConstraint.constant = QuestionnaireItemView.itemVerticalMargin
                questionnaireFacilityHeightConstraint.constant = QuestionnaireItemView.normalTVHeight
                questionnaireFacilityHintHeightConstraint.constant = QuestionnaireItemView.normalTVHeight
                questionnaireFacilityLabel.text = facilityName
            }
            else{
                questionnaireFacilityHintTopConstraint.constant = 0
                questionnaireFacilityHeightConstraint.constant = 0
                questionnaireFacilityHintHeightConstraint.constant = 0
            }
            
            self.setNeedsLayout()
            
                
            if patQuesMap.isFilled && patQuesMap.isSubmitted {
                questionnaireStatusLabel.setBackgroundColor(bgColor: questionnaireListStatusSubmittedBg)
                questionnaireStatusLabel.setTextColor(fontcolor: questionnaireListStatusSubmittedTxtColor)
                questionnaireStatusLabel.text = getString(key: "com.charmphr.questionnaire.status.submitted")
            }
            else if !patQuesMap.isFilled && !patQuesMap.isSubmitted {
                    
                if type == questionnaireCurrentValue {

                    questionnaireStatusLabel.setBackgroundColor(bgColor: questionnaireListStatusNewBg)
                    questionnaireStatusLabel.setTextColor(fontcolor: questionnaireListStatusNewTxtColor)
                    questionnaireStatusLabel.text = getString(key: "com.charmphr.questionnaire.status.new")
                }
                else{
                    questionnaireStatusLabel.setBackgroundColor(bgColor: questionnaireListStatusNotSubmittedBg)
                    questionnaireStatusLabel.setTextColor(fontcolor: questionnaireListStatusNotSubmittedTxtColor)
                    questionnaireStatusLabel.text = getString(key: "com.charmphr.questionnaire.status.notsubmitted")
                }
            }
            else {
                questionnaireStatusLabel.setBackgroundColor(bgColor: questionnaireListStatusDraftBg)
                questionnaireStatusLabel.setTextColor(fontcolor: questionnaireListStatusDraftTxtColor)
                questionnaireStatusLabel.text = getString(key: "com.charmphr.questionnaire.status.draft")
            }
            
            if let statusWidthConstraint = questionnaireStatusWidthConstraint {
                self.removeConstraint(statusWidthConstraint)
            }
            
            questionnaireStatusWidthConstraint = questionnaireStatusLabel.setAndReturnWidth(constant: questionnaireStatusLabel.sizeThatFits(CGSize(width: 200, height: QuestionnaireItemView.statusHeight)).width + 10)
        }

    }
}
