//
//  QuestionnaireAnswerView.swift
//  phr
//
//  Created by prathi-13964 on 26/03/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import UIKit

class QuestionnaireAnswerView: UIView, UIScrollViewDelegate, SelectValueViewControllerDelagate, MultiValueSelectViewControllerDelagate, UIViewControllerTransitioningDelegate, SelectValueViewControllerSearchStringDelagate, SelectValueViewControllerValueDelagate{
    
    private var questionnaireAnswerModel: QuestionnaireAnswerModel? = nil
    private var physicianTemplate : PhysicianTemplates? = nil
    private weak var delegate: QuestionnaireAnswerViewController? = nil

    // Safe-area width of the screen when the questionnaire is built, so widgets fit the current
    // iPhone Duo posture instead of the launch-time screen size.
    private var contentWidth: CGFloat {
        if let hostView = delegate?.view, hostView.bounds.width > 0 {
            return hostView.bounds.inset(by: hostView.safeAreaInsets).width
        }
        return applicationFrame.width
    }
    var isDataEditAllowed = false
   
    private let containerScrollView = TPKeyboardAvoidingScrollView()
    private let containerView = UIStackView()
    
    var sectionViewToStackDic:[Int:Int] = [:]
    var sectionViewToSeparatorDic:[Int:Int] = [:]
    var sectionViewToButtonDic:[Int:Int] = [:]
    
    var country = ""
    private var selectedTF: MDFLTextField? = nil
    
    private var tagNo = 13000
    private var insuranceTag = -1
    private var personalWidgetTag = -1
    private var patContactTag = -1
    
    var tagList :[Int] = []
    var idList :[String] = []//Kept separate list and not using dictionary because we need to validate data in order
    private var soapTagList: [Int] = []
    private var soapIdList: [String] = []

    var signatureAddedMap :[Int:Bool] = [:]
    private var prevSection: UIStackView?
    private let primaryDataHandler = PrimaryDataHandler.sharedInstance
    
    override init(frame : CGRect){
        super.init(frame: .zero)
    }
    
    func initView(physicianTemplate : PhysicianTemplates, questionnaireAnswerModel: QuestionnaireAnswerModel, delegate : QuestionnaireAnswerViewController) {
        self.physicianTemplate = physicianTemplate
        self.questionnaireAnswerModel = questionnaireAnswerModel
        self.delegate = delegate
        
        renderFeedbackView()
    }
    
    private func renderFeedbackView(){
        
        containerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        var submitBtn: UIButton? = nil
        var saveDraftBtn: UIButton? = nil
        let submitBtnHeight: CGFloat = 56
        
        if let patQuesMap = physicianTemplate?.patientQuesMap {
            if let allowPhrEditing = questionnaireAnswerModel?.questionnaireDetailPOJO?.patientQuesMap?.allowPhrEditing{
                isDataEditAllowed = allowPhrEditing
            }
            else if let allowPhrEditing = patQuesMap.allowPhrEditing{
                isDataEditAllowed = (allowPhrEditing && (questionnaireAnswerModel?.isPast == false))
            }
            
            if RbacUtil.checkPrivilege(privilege: .SUBMIT_QUESTIONNAIRE) && isDataEditAllowed {
                
                submitBtn = UIButton()
                
                submitBtn?.addPillCornerRadiusAndShadow(height: submitBtnHeight)
                submitBtn?.clipsToBounds = true
                
                submitBtn?.addTarget(self, action: #selector(onSubmitClicked), for: .touchUpInside)
                
                if(patQuesMap.isSubmitted){
                    if physicianTemplate?.questionnaireType == QUESTIONNAIRE_TYPE_ConsentForm{
                        submitBtn = nil
                        self.isUserInteractionEnabled = false
                    }
                    else{
                        submitBtn?.setTitle(getString(key: "com.charmphr.questionnaire.submitagain"), for: .normal)
                    }
                }
                else{
                    submitBtn?.setTitle(getString(key: "com.charmphr.action.submit"), for: .normal)
                    if physicianTemplate?.questionnaireType != QUESTIONNAIRE_TYPE_ConsentForm{
                        // Draft save sits beside Submit at the bottom so it stays put in every orientation
                        // (a text bar item would not move to the iOS 27.1 landscape side bar).
                        let draftBtn = UIButton()
                        draftBtn.setTitle(getString(key: "com.charmphr.questionnaire.savedraft"), for: .normal)
                        draftBtn.addTarget(self, action: #selector(onSaveClicked), for: .touchUpInside)
                        saveDraftBtn = draftBtn
                    }
                }
            }
        }
        
        self.addSubview(containerScrollView)
        containerScrollView.addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.spacing = CARD_PADDING
        containerView.alignment = .fill
        
        containerScrollView.setSafeAreaTop(offset: Y_SPACE)
        containerScrollView.setSafeAreaLeft(offset: 0)
        containerScrollView.setSafeAreaRight(offset: 0)

        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: X_SPACE)
        containerView.setRight(offSet: -X_SPACE)
        // Edge pins inside a scroll view only set content bounds; this ties the width to the visible area.
        containerView.widthAnchor.constraint(equalTo: containerScrollView.frameLayoutGuide.widthAnchor, constant: -(X_SPACE * 2)).isActive = true
        
        if let submitBtn = submitBtn {
            
            submitBtn.setBackgroundColor(bgColor: THEME_COLOR)
            submitBtn.setTitleColor(.white, for: .normal)
            submitBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)

            let actionStack = UIStackView(arrangedSubviews: [submitBtn])
            actionStack.axis = .horizontal
            actionStack.distribution = .fillEqually
            actionStack.spacing = CARD_PADDING

            if let saveDraftBtn = saveDraftBtn {
                // Secondary (outlined) style so Submit remains the primary action.
                saveDraftBtn.addPillCornerRadiusAndShadow(height: submitBtnHeight)
                saveDraftBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
                saveDraftBtn.layer.borderWidth = 1.5
                let themeColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
                saveDraftBtn.layer.borderColor = themeColor.cgColor
                saveDraftBtn.setTitleColor(themeColor, for: .normal)
                saveDraftBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
                actionStack.insertArrangedSubview(saveDraftBtn, at: 0)
            }

            self.addSubview(actionStack)

            actionStack.setSafeAreaLeft(offset: X_SPACE)
            actionStack.setSafeAreaRight(offset: -X_SPACE)
            actionStack.setSafeAreaBottom(offset: -Y_SPACE)
            actionStack.setHeight(constant: submitBtnHeight)

            containerScrollView.setBottomRelatedToView(offSet: -Y_SPACE, relatedView: actionStack, relatedAttribute: .top)
        }
        else{
            containerScrollView.setSafeAreaBottom(offset: -Y_SPACE)
        }
        if let questionnaireDetailPOJO = questionnaireAnswerModel?.questionnaireDetailPOJO{
            
            if delegate?.consentFormDelegate != nil {
                let infoView = InformationView(infoLocalisedKey: "com.charmphr.consentform.info")
                containerView.addArrangedSubview(infoView)
            }
                                                      
            var prevSectionTag: Int? = nil
            
            questionnaireDetailPOJO.questionnairEntryPOJOList.forEach { feedBackPOJO in
                
                switch (feedBackPOJO.questionnaireEntry.notesType) {
                case questionnaireNotesTypeSection :
                    prevSectionTag = createSection(questionnaireEntryPOJO: feedBackPOJO)
                case questionnaireNotesTypeLabel :
                    createLabel(questionnaireEntryPOJO: feedBackPOJO)
                case questionnaireNotesTypeSimpleQuestion :
                    createQuestionAnswer(feedbackPOJO: feedBackPOJO, soapWidgetPOJO: nil, isSingleLine: true)
                case questionnaireNotesTypeQuestion :
                    createQuestionAnswer(feedbackPOJO: feedBackPOJO, soapWidgetPOJO: nil, isSingleLine: false)
                case questionnaireNotesTypeOption :
                    createOptions(feedbackPOJO: feedBackPOJO, allowOthers: false)
                case questionnaireNotesTypeYesOrNoOption :
                    createOptions(feedbackPOJO: feedBackPOJO, allowOthers: false)
                case questionnaireNotesTypeOptionWithOthers :
                    createOptions(feedbackPOJO: feedBackPOJO, allowOthers: true)
                case questionnaireNotesTypeRatingScale :
                    createRatingScale(feedbackPOJO: feedBackPOJO, soapWidgetPOJO: nil)
                case questionnaireNotesTypeRating :
                    createRating(feedbackPOJO: feedBackPOJO)
                case questionnaireNotesTypeDate :
                    createDate(feedbackPOJO: feedBackPOJO)
                case questionnaireNotesTypeAllergy :
                    createAllergyWidget(feedbackPOJO: feedBackPOJO)
                case questionnaireNotesTypeMedication :
                    createPrescriptionWidget(entryType: .Medication, feedbackPOJO: feedBackPOJO)
                case questionnaireNotesTypeSupplement :
                    createPrescriptionWidget(entryType: .Supplement, feedbackPOJO: feedBackPOJO)
                case questionnaireNotesTypeSignature :
                    createSignatureWidget(feedbackPOJO:   feedBackPOJO)
                case questionnaireNotesTypePersonalDetails :
                    createPersonalDetailsWidget(feedbackPOJO: feedBackPOJO)
                case questionnaireNotesTypePrimaryContactDetail :
                    createPatContactDetailWidget(feedbackPOJO: feedBackPOJO)
                case questionnaireNotesTypeInsurance :
                    createPatInsuranceWidget(feedbackPOJO: feedBackPOJO)
                default:
                    
                    if questionnaireDetailPOJO.questionnairEntryPOJOList.firstIndex(where: { questionnaireEntryPOJO in
                        return questionnaireEntryPOJO.questionnaireEntry.entryId == feedBackPOJO.questionnaireEntry.entryId
                    }) != nil{
                        if (questionnaireSOAPTypeList.contains(feedBackPOJO.questionnaireEntry.notesType ?? "")){
                            renderSOAPEntry(questionnaire: feedBackPOJO)
                        }
                    }
                }
                if let prevSectionTag = prevSectionTag{
                    if feedBackPOJO.questionnaireEntry.notesType != questionnaireNotesTypeSection {
                        feedBackPOJO.sectionTag = prevSectionTag
                    }
                }
            }
        }
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        containerView.addArrangedSubview(spacerView)
    }
    
//MARK: - Section
        
    private func isSectionPresent() -> Bool{
        return prevSection != nil
    }
         
    private func createSection(questionnaireEntryPOJO: QuestionnaireEntryPOJO) -> Int{
        
        let sectionView = SectionView(questionnaireEntryPOJO: questionnaireEntryPOJO, delegate: self)
        
        containerView.addArrangedSubview(sectionView)
        sectionView.setConstraints()
        
        sectionView.tag = tagNo
        tagNo = tagNo + 1
                
        self.prevSection = sectionView.stackView
        return sectionView.tag
    }
        
//MARK: - Label Widget
        
    private func createLabel(questionnaireEntryPOJO: QuestionnaireEntryPOJO)  {
        let questionLabel = questionnaireEntryPOJO.questionnaireLabel
        
        let label = UILabel()
        
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(label)
        }
        else{
            containerView.addArrangedSubview(label)
        }
        
        label.textAlignment = questionLabel.textAlign
        label.font = questionLabel.fontStyle
        label.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x071F3DAD)
        label.numberOfLines = 0
        
        if questionLabel.textDecoration == questionnaireLabelAlignmentUnderline {
            let attributedString = NSMutableAttributedString.init(string: questionnaireEntryPOJO.questionnaireEntry.notes ?? "")
            // Add Underline Style Attribute.
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
                                            NSRange.init(location: 0, length: attributedString.length));
            label.attributedText = attributedString
        }
        else{
            label.text = questionnaireEntryPOJO.questionnaireEntry.notes
        }
    }
        
//MARK: - Options Widget
        
    private func createOptions(feedbackPOJO: QuestionnaireEntryPOJO, allowOthers: Bool) {
        let questionnaireLayout = CommonQuestionnaireLayout(notes: feedbackPOJO.questionnaireEntry.notes, addShadow: !isSectionPresent())
        
        var width: CGFloat = 0
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(questionnaireLayout)
            width = contentWidth - (2 * X_SPACE) - (2 * CARD_PADDING)
        }
        else{
            containerView.addArrangedSubview(questionnaireLayout)
        }
        
        if feedbackPOJO.questionnaireEntry.isMandatory {
            questionnaireLayout.commonQuestionnaireLabel.makeMandatory()
            width = contentWidth - (2 * X_SPACE)
        }
        
        let questionnaireOptionView =  QuestionnaireOptionView(question: feedbackPOJO, isFixedOption: !allowOthers, width: width)
        questionnaireLayout.commonQuestionnaireMainLayout.addSubview(questionnaireOptionView)
        
        questionnaireOptionView.setTop(offSet: 0)
        questionnaireOptionView.setLeft(offSet: 0)
        questionnaireOptionView.setRight(offSet: 0)
        questionnaireOptionView.setBottom(offSet: 0)
        
        if (isDataEditAllowed) {
            questionnaireOptionView.tag = tagNo
            tagList.append(tagNo)
            idList.append(feedbackPOJO.questionnaireEntry.entryId)
            tagNo = tagNo + 1
            questionnaireOptionView.isUserInteractionEnabled  = true
        }
        else{
            questionnaireOptionView.isUserInteractionEnabled  = false
        }
    }
        
//MARK: - Rating Scale Widget
        
    private func createRatingScale(feedbackPOJO: QuestionnaireEntryPOJO?, soapWidgetPOJO: SOAPWidgetEntry?){
        
        var questionnaireLayout: CommonQuestionnaireLayout?
        if let feedbackPOJO = feedbackPOJO{
            questionnaireLayout = CommonQuestionnaireLayout(notes: feedbackPOJO.questionnaireEntry.notes, addShadow: !isSectionPresent())
            
            if feedbackPOJO.questionnaireEntry.isMandatory {
                questionnaireLayout?.commonQuestionnaireLabel.makeMandatory()
            }
        }
        else if let soapWidgetPOJO = soapWidgetPOJO{
            questionnaireLayout = CommonQuestionnaireLayout(notes: soapWidgetPOJO.entryName, addShadow: !isSectionPresent())
            if soapWidgetPOJO.isMandatory {
                questionnaireLayout?.commonQuestionnaireLabel.makeMandatory()
            }
        }
        let ratingScale = RatingScale(feedbackPOJO: feedbackPOJO, soapWidgetPOJO: soapWidgetPOJO)
        
        
        if isDataEditAllowed {
            ratingScale.tag = tagNo
            
            if let feedbackPOJO = feedbackPOJO{
                tagList.append(tagNo)
                idList.append(feedbackPOJO.questionnaireEntry.entryId)
            }
            else if let soapWidgetPOJO = soapWidgetPOJO{
                soapTagList.append(tagNo)
                soapIdList.append(soapWidgetPOJO.entryId ?? "")
            }
            tagNo = tagNo + 1
            
            ratingScale.isUserInteractionEnabled = true
        }
        else{
            ratingScale.isUserInteractionEnabled = false
        }
        
        if let questionnaireLayout = questionnaireLayout{
            if let prevSection = prevSection {
                prevSection.addArrangedSubview(questionnaireLayout)
            }
            else{
                containerView.addArrangedSubview(questionnaireLayout)
            }
            questionnaireLayout.commonQuestionnaireMainLayout.addSubview(ratingScale)
        }
        
        ratingScale.setLeft(offSet: CARD_PADDING)
        ratingScale.setRight(offSet:-CARD_PADDING)
        ratingScale.setTop(offSet: CARD_PADDING)
        ratingScale.setBottom(offSet: -CARD_PADDING)
    }
        
//MARK: - Rating Widget
        
    private func createRating(feedbackPOJO: QuestionnaireEntryPOJO){
        
        let questionnaireLayout = CommonQuestionnaireLayout(notes: feedbackPOJO.questionnaireEntry.notes, addShadow: !isSectionPresent())
        
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(questionnaireLayout)
        }
        else{
            containerView.addArrangedSubview(questionnaireLayout)
        }
        
        if feedbackPOJO.questionnaireEntry.isMandatory {
            questionnaireLayout.commonQuestionnaireLabel.makeMandatory()
        }
        
        let ratingBar = RatingView()
        ratingBar.createElements()
        
        let valueStr = feedbackPOJO.questionnaireEntry.answersList?.firstOrNil() ?? ""
        
        if let value = Int(valueStr){
            ratingBar.rating = value
        }
        
        if isDataEditAllowed {
            ratingBar.tag = tagNo
            tagList.append(tagNo)
            idList.append(feedbackPOJO.questionnaireEntry.entryId)
            tagNo = tagNo + 1
            ratingBar.isUserInteractionEnabled = true
        }
        else{
            ratingBar.isUserInteractionEnabled = false
        }
        
        questionnaireLayout.commonQuestionnaireMainLayout.addSubview(ratingBar)
        
        ratingBar.setLeft(offSet: CARD_PADDING)
        ratingBar.setTop(offSet: CARD_PADDING)
        ratingBar.setRight(offSet: -CARD_PADDING)
        ratingBar.setBottom(offSet: -CARD_PADDING)
    }
        
//MARK: - Date Widget
        
    private func createDate(feedbackPOJO: QuestionnaireEntryPOJO){
        
        let questionnaireLayout = CommonQuestionnaireLayout(notes: feedbackPOJO.questionnaireEntry.notes, addShadow: !isSectionPresent())
        
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(questionnaireLayout)
        }
        else{
            containerView.addArrangedSubview(questionnaireLayout)
        }
        
        if feedbackPOJO.questionnaireEntry.isMandatory {
            questionnaireLayout.commonQuestionnaireLabel.makeMandatory()
        }
        
        let dateView = DateView(feedbackPOJO: feedbackPOJO)
        questionnaireLayout.commonQuestionnaireMainLayout.addSubview(dateView)
        
        dateView.layer.borderWidth = 1
        dateView.layer.cornerRadius = CardSize.SMALL.value
        dateView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: 0x7070701A).cgColor
        dateView.layer.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xB2B2B20B).cgColor
        
        dateView.setLeft(offSet: CARD_PADDING)
        dateView.setTop(offSet: CARD_PADDING)
        dateView.setRight(offSet: -CARD_PADDING)
        dateView.setBottom(offSet: -CARD_PADDING)
        dateView.setHeight(constant: 45)
        
        if isDataEditAllowed {
            dateView.tag = tagNo
            tagList.append(tagNo)
            idList.append(feedbackPOJO.questionnaireEntry.entryId)
            tagNo = tagNo + 1
            dateView.isUserInteractionEnabled = true
        }
        else{
            dateView.isUserInteractionEnabled = false
        }
    }
    
//MARK: - Soap Widget
        
    func renderSOAPEntry(questionnaire: QuestionnaireEntryPOJO){
        
        tagList.append(tagNo)
        idList.append(questionnaire.questionnaireEntry.entryId)
        tagNo += 1
        
        questionnaire.soapWidget?.widgetEntries.forEach({soapWidgetEntry in
            
            if soapWidgetEntry.entryType == soapWidgetTypeHeading {
                
                let headerLabel = UILabel()
                
                if let prevSection = prevSection {
                    prevSection.addArrangedSubview(headerLabel)
                }
                else{
                    containerView.addArrangedSubview(headerLabel)
                }
                
                headerLabel.numberOfLines = 0
                headerLabel.lineBreakMode = .byTruncatingTail
                
                if let properties = soapWidgetEntry.customText?.components(separatedBy: "^^"){
                    var propList: [String] = []
                    properties.forEach { prop in
                        propList.append("\(prop);")
                    }
                    let cssProperties = propList.joined()
                    let htmlString: String = """
                                <html>
                                    <body>
                                        <div style = \(cssProperties)>
                                            \(soapWidgetEntry.entryName ?? "")
                                        </div>
                                    </body>
                                </html>
                            """
                    headerLabel.attributedText = htmlString.convertHtmlToNSAttributedString
                }
                headerLabel.wrapHeight(maxHeight: applicationFrame.height)
                
                headerLabel.tag = tagNo
                soapTagList.append(tagNo)
                soapIdList.append(soapWidgetEntry.entryId ?? "" )
                tagNo = tagNo + 1
            }
            else if soapWidgetEntry.entryType == soapWidgetTypeSimpleQuestion {
                
                if let isMultiLine = Bool(soapWidgetEntry.customText?.components(separatedBy: ":").last ?? ""){
                    if !isMultiLine{
                        createQuestionAnswer(feedbackPOJO: nil, soapWidgetPOJO: soapWidgetEntry, isSingleLine: true)
                    }
                    else{
                        createQuestionAnswer(feedbackPOJO: nil, soapWidgetPOJO: soapWidgetEntry, isSingleLine: false)
                    }
                }
                else{
                    createQuestionAnswer(feedbackPOJO: nil, soapWidgetPOJO: soapWidgetEntry, isSingleLine: true)
                }
            }
            else if soapWidgetEntry.entryType == soapWidgetTypeTextbox {
                
                let questionnaireLayout = CommonQuestionnaireLayout(notes: getString(key: "com.charmphr.questionnairevc.soapNotesType.textBox.title"), addShadow: !isSectionPresent())
                
                if let prevSection = prevSection {
                    prevSection.addArrangedSubview(questionnaireLayout)
                }
                else{
                    containerView.addArrangedSubview(questionnaireLayout)
                }
                
                let textView = MDTextView()
                textView.addCornerRadius(.SMALL)
                textView.layer.borderWidth = 1
                textView.maxLength = MULTILINE_MAXLENGHT
                textView.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                textView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BORDER_COLOR).cgColor
                textView.isScrollEnabled = true
                
                questionnaireLayout.commonQuestionnaireMainLayout.addSubview(textView)
                
                textView.setTop(offSet: 8)
                textView.setLeft(offSet: 8)
                textView.setRight(offSet: -8)
                textView.setBottom(offSet: -8)
                
                textView.setHeight(constant: 60, relatedBy: .greaterThanOrEqual)
                
                if isDataEditAllowed {
                    textView.tag = tagNo
                    soapTagList.append(tagNo)
                    soapIdList.append(soapWidgetEntry.entryId ?? "" )
                    tagNo = tagNo + 1
                }
                else{
                    textView.isUserInteractionEnabled = false
                }
                
                if soapWidgetEntry.questionnaireSOAPEntry?.value.isNilOrBlank() == true{
                    
                    if soapWidgetEntry.defaultValue.isNilOrBlank(){
                        textView.text = soapWidgetEntry.entryName ?? ""
                    }
                    else{
                        textView.text = soapWidgetEntry.defaultValue ?? ""
                    }
                }
                else{
                    textView.text = soapWidgetEntry.questionnaireSOAPEntry?.value ?? ""
                }
                
                if textView.text.isValidHtmlString(){
                    questionnaireLayout.isUserInteractionEnabled = false
                }
                else{
                    questionnaireLayout.isUserInteractionEnabled = true
                }
                
                if soapWidgetEntry.isMandatory {
                    questionnaireLayout.commonQuestionnaireLabel.makeMandatory()
                }
            }
            else if soapWidgetEntry.entryType == soapWidgetTypeTable {
                
                let soapTableView = SOAPTableView()
                
                var width: CGFloat = 0
                
                if let prevSection = prevSection {
                    prevSection.addArrangedSubview(soapTableView)
                    width = contentWidth - (2 * X_SPACE) - (2 * CARD_PADDING)
                }
                else{
                    containerView.addArrangedSubview(soapTableView)
                    width =  contentWidth - (2 * X_SPACE)
                }
                
                soapTableView.initView(isSectionPresent: isSectionPresent(), soapWidgetEntry: soapWidgetEntry, viewWidth: contentWidth - (2 * X_SPACE))
                
                soapTableView.backgroundColor = .white
                if !isSectionPresent(){
                    soapTableView.addShadowAndCornerRadius(.SMALL)
                }
                
                let soapWidgetTableStackView = soapTableView.getTableStackView()
                if isDataEditAllowed {
                    soapWidgetTableStackView.tag = tagNo
                    soapTagList.append(tagNo)
                    soapIdList.append(soapWidgetEntry.entryId ?? "" )
                    tagNo = tagNo + 1
                    
                    soapWidgetTableStackView.isUserInteractionEnabled = true
                }
                else{
                    soapWidgetTableStackView.isUserInteractionEnabled = false
                }
            }
            else if soapWidgetEntry.entryType == soapWidgetTypeYesOrNo || soapWidgetEntry.entryType == soapWidgetTypeCheckList || soapWidgetEntry.entryType == soapWidgetTypeRadio || soapWidgetEntry.entryType == soapWidgetTypeCheckbox{
                
                var notes = ""
                
                if soapWidgetEntry.entryType == soapWidgetTypeCheckList{
                    notes = "Choose at least one option from the list below "
                }
                else{
                    notes = soapWidgetEntry.entryName ?? ""
                }
                let questionnaireLayout = CommonQuestionnaireLayout(notes: notes, addShadow: !isSectionPresent())
                var width: CGFloat = 0
                if let prevSection = prevSection {
                    prevSection.addArrangedSubview(questionnaireLayout)
                    width = contentWidth - (2 * X_SPACE) - (2 * CARD_PADDING)
                }
                else{
                    containerView.addArrangedSubview(questionnaireLayout)
                    width = contentWidth - (2 * X_SPACE)
                }
                
                if soapWidgetEntry.isMandatory{
                    questionnaireLayout.commonQuestionnaireLabel.makeMandatory()
                }
                let questionnaireSoapOptionView = QuestionnaireSoapOptionView(soapWidget: soapWidgetEntry, delegate: delegate, width: width, isDataEditAllowed: isDataEditAllowed)
                questionnaireLayout.commonQuestionnaireMainLayout.addSubview(questionnaireSoapOptionView)
                
                questionnaireSoapOptionView.setLeft(offSet: 0)
                questionnaireSoapOptionView.setRight(offSet: 0)
                questionnaireSoapOptionView.setTop(offSet: 0)
                questionnaireSoapOptionView.setBottom(offSet: 0)
                
                if isDataEditAllowed {
                    questionnaireSoapOptionView.tag = tagNo
                    soapTagList.append(tagNo)
                    soapIdList.append(soapWidgetEntry.entryId ?? "" )
                    tagNo = tagNo + 1
                }
                else{
                }
            }
            else if soapWidgetEntry.entryType == soapWidgetTypeRatingScale {
                createRatingScale(feedbackPOJO: nil, soapWidgetPOJO: soapWidgetEntry)
            }
        })
    }
        
//MARK: - Question Widget
        
    private func createQuestionAnswer(feedbackPOJO: QuestionnaireEntryPOJO?, soapWidgetPOJO: SOAPWidgetEntry?, isSingleLine: Bool) {
        
        var questionnaireLayout: CommonQuestionnaireLayout?
        if let feedbackPOJO = feedbackPOJO{
            questionnaireLayout = CommonQuestionnaireLayout(notes: feedbackPOJO.questionnaireEntry.notes, addShadow: !isSectionPresent())
            
            if feedbackPOJO.questionnaireEntry.isMandatory {
                questionnaireLayout?.commonQuestionnaireLabel.makeMandatory()
            }
        }
        else if let soapWidgetPOJO = soapWidgetPOJO{
            questionnaireLayout = CommonQuestionnaireLayout(notes: soapWidgetPOJO.entryName, addShadow: !isSectionPresent())
            if soapWidgetPOJO.isMandatory {
                questionnaireLayout?.commonQuestionnaireLabel.makeMandatory()
            }
        }
        
        let questionView = QuestionView(isSingleLine: isSingleLine, feedbackPOJO: feedbackPOJO, soapWidgetPOJO: soapWidgetPOJO)
        
        if isDataEditAllowed {
            questionView.tag = tagNo
            
            if let feedbackPOJO = feedbackPOJO{
                tagList.append(tagNo)
                idList.append(feedbackPOJO.questionnaireEntry.entryId)
            }
            else if let soapWidgetPOJO = soapWidgetPOJO{
                soapTagList.append(tagNo)
                soapIdList.append(soapWidgetPOJO.entryId ?? "")
            }
            tagNo = tagNo + 1
            
            questionView.isUserInteractionEnabled = true
        }
        else{
            questionView.isUserInteractionEnabled = false
        }
        
        if let questionnaireLayout = questionnaireLayout{
            if let prevSection = prevSection {
                prevSection.addArrangedSubview(questionnaireLayout)
            }
            else{
                containerView.addArrangedSubview(questionnaireLayout)
            }
            questionnaireLayout.commonQuestionnaireMainLayout.addSubview(questionView)
        }
        
        questionView.setLeft(offSet: CARD_PADDING)
        questionView.setRight(offSet: -CARD_PADDING)
        questionView.setTop(offSet: CARD_PADDING)
        questionView.setBottom(offSet: -CARD_PADDING)
    }
    
//MARK: - Allergy Widget functions
        
    private func createAllergyWidget(feedbackPOJO: QuestionnaireEntryPOJO){
        
        let width: CGFloat = prevSection == nil ? contentWidth - (2 * X_SPACE) : contentWidth - (2 * X_SPACE) - (2 * CARD_PADDING)
        let addShadow: Bool = prevSection == nil ? true : false
        
        let allergyWidgetLayout = AllergiesWidgetView(feedbackPOJO: feedbackPOJO, addShadow: addShadow, width: width, isDataEditAllowed: isDataEditAllowed, delegate: delegate)
        
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(allergyWidgetLayout)
        }
        else{
            containerView.addArrangedSubview(allergyWidgetLayout)
        }
        
        if isDataEditAllowed {
            allergyWidgetLayout.tag = tagNo
            tagList.append(tagNo)
            idList.append(feedbackPOJO.questionnaireEntry.entryId)
            tagNo = tagNo + 1
        }
    }
    
//MARK: - Prescription Widget functions

    private func createPrescriptionWidget(entryType: QuestEntryWidgetType, feedbackPOJO: QuestionnaireEntryPOJO){
        
        let width: CGFloat = prevSection == nil ? contentWidth - (2 * X_SPACE) : contentWidth - (2 * X_SPACE) - (2 * CARD_PADDING)
        let addShadow: Bool = prevSection == nil ? true : false
        
        let medicationWidgetLayout = PrescriptionWidgetView(entryType: entryType, feedbackPOJO: feedbackPOJO, addShadow: addShadow, isDataEditAllowed: isDataEditAllowed, width: width, delegate: delegate)
        
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(medicationWidgetLayout)
        }
        else{
            containerView.addArrangedSubview(medicationWidgetLayout)
        }
        
        if isDataEditAllowed {
            medicationWidgetLayout.tag = tagNo
            tagList.append(tagNo)
            idList.append(feedbackPOJO.questionnaireEntry.entryId)
            tagNo = tagNo + 1
        }
    }
        
//MARK: - Signature Widget functions
        
    private func createSignatureWidget(feedbackPOJO: QuestionnaireEntryPOJO){
        
        let questionnaireLayout = CommonQuestionnaireLayout(notes: feedbackPOJO.questionnaireEntry.notes, addShadow: !isSectionPresent())
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(questionnaireLayout)
        }
        else{
            containerView.addArrangedSubview(questionnaireLayout)
        }
        let signatureView = SignatureView()
        questionnaireLayout.commonQuestionnaireMainLayout.addSubview(signatureView)
        
        signatureView.tag = tagNo
        tagList.append(tagNo)
        idList.append(feedbackPOJO.questionnaireEntry.entryId)
        tagNo = tagNo + 1
        
        if feedbackPOJO.questionnaireEntry.isMandatory {
            questionnaireLayout.commonQuestionnaireLabel.makeMandatory()
        }
        
        downloadSingnatureInView(signatureView: signatureView, feedbackPOJO: feedbackPOJO)
        
        signatureView.setTop(offSet: 0)
        signatureView.setLeft(offSet: 0)
        signatureView.setBottom(offSet: 0)
        signatureView.setRight(offSet: 0)
    }
    
    private func downloadSingnatureInView(signatureView : SignatureView , feedbackPOJO: QuestionnaireEntryPOJO)
    {
        if isDataEditAllowed {
            signatureView.signatureLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAddSignatureClick(_:))))
            
            signatureView.editOrSaveBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAddSignatureClick(_:))))
        }
        else{
            signatureView.signatureLabel.setTitle(getString(key: "com.charmphr.questionnairevc.signature.empty.txt"), for: .normal)
        }
        
        if (feedbackPOJO.questionnaireEntry.answersList?.isEmpty != true) {
            signatureAddedMap[signatureView.tag] = true
            signatureView.showActivityIndicator()
            delegate?.getSignatureImage(feedbackPOJO: feedbackPOJO, tag: signatureView.tag)
            
            if !isDataEditAllowed{
                signatureView.btnLayout.isHidden = true
            }
        }
        else{
            signatureView.signatureImgView.isHidden = true
            signatureView.signatureLabel.isHidden = false
            signatureView.btnLayout.isHidden = true
        }
    }
    
    @objc func onAddSignatureClick(_ sender: UITapGestureRecognizer?) {
        delegate?.onAddSignatureClick(sender)
    }
    
//MARK: - PersonalDetails Widget functions
       
    private func createPersonalDetailsWidget(feedbackPOJO: QuestionnaireEntryPOJO){
        
        var width = contentWidth
        var addShadow = true
        
        if prevSection != nil{
            width = contentWidth - (2 * X_SPACE)
            addShadow = false
        }
        
        if let patientObj = questionnaireAnswerModel?.patientObj{
            let personalWidget = PersonalDetailsView(patient: patientObj, width: width, addShadow: addShadow)
            
            if let prevSection = prevSection {
                prevSection.addArrangedSubview(personalWidget)
            }
            else{
                containerView.addArrangedSubview(personalWidget)
            }
            
            if isDataEditAllowed {
                
                personalWidget.languageMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onLanguageClicked)))
                
                personalWidget.raceMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRaceClicked)))
                
                personalWidget.genderIdentityMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onGenderIdentityClicked)))
                
                personalWidget.ethnicityMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onEthnicityClicked)))
                
                personalWidget.tag = tagNo
                tagList.append(tagNo)
                idList.append(feedbackPOJO.questionnaireEntry.entryId)
                personalWidgetTag = tagNo
                tagNo = tagNo + 1
            }
            else{
                personalWidget.isUserInteractionEnabled = false
            }
        }
    }
        
    @objc func onLanguageClicked(_ tapGestureRecognizer : UITapGestureRecognizer){
        
        if let languageTF = tapGestureRecognizer.view as? MDFLTextField {
            let vc = SelectValueViewController()
            
            selectedTF = languageTF
            vc.isSearchBarNeeded = true
            vc.arrayOfValueToBeShown = primaryDataHandler.languageArr ?? []
            vc.selectedValueIndex = primaryDataHandler.languageArr?.firstIndex(of: languageTF.text ?? "")
            vc.delegate = self
            delegate?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func onRaceClicked(_ tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.endEditing(true)
        if let raceET = tapGestureRecognizer.view as? MDFLTextField {
            
            delegate?.bgView.isHidden = false
            
            let selectedInput = raceET.text?.components(separatedBy: ",").filter{ race in
                race.isNotBlank() && race.lowercased().trim() != questionnairePersonalDetailDeclineToSpecify.lowercased()
            }.map {race in
                race.trim()
            } ?? []
            delegate?.multiSelectPopVC = MultiselectValueViewController(inputArray: primaryDataHandler.raceArr ?? [], selectedInputs: selectedInput, includeDeniedToSpecifyInput: true, titleString: "Select Race", identificationKey: "race")
            if let mc = delegate?.multiSelectPopVC{
                mc.delegate = self
                mc.modalPresentationStyle = .custom
                mc.transitioningDelegate = self
                delegate?.present(mc, animated: true, completion: nil)
            }
        }
    }
        
    @objc func onGenderIdentityClicked(_ tapGestureRecognizer: UITapGestureRecognizer){
        self.endEditing(true)
        if let genderET = tapGestureRecognizer.view as? MDFLTextField {
            
            delegate?.bgView.isHidden = false
            
            let genderInput =  genderET.text ?? ""
            var genderInputArr: [String] = []
            if genderInput.isNotBlank() && genderInput.lowercased().trim() != questionnairePersonalDetailDeclineToSpecify.lowercased(){
                genderInputArr.append(genderInput.trim())
            }
            
            delegate?.multiSelectPopVC = MultiselectValueViewController(inputArray: primaryDataHandler.genderIdentityArr ?? [], selectedInputs: genderInputArr, includeDeniedToSpecifyInput: true, titleString: "Select Gender Identity", identificationKey: "Gender Identity", makeSingleSelect: true)
            if let mc = delegate?.multiSelectPopVC{
                mc.delegate = self
                mc.modalPresentationStyle = .custom
                mc.transitioningDelegate = self
                delegate?.present(mc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func onEthnicityClicked(_ tapGestureRecognizer: UITapGestureRecognizer){
        self.endEditing(true)
        if let ethnicityET = tapGestureRecognizer.view as? MDFLTextField {
            
            delegate?.bgView.isHidden = false
            
            let ethnicityInput = ethnicityET.text ?? ""
            var ethnicityInputArr: [String] = []
            if ethnicityInput.isNotBlank() && ethnicityInput.lowercased().trim() != questionnairePersonalDetailDeclineToSpecify.lowercased(){
                ethnicityInputArr.append(ethnicityInput.trim())
            }
            delegate?.multiSelectPopVC = MultiselectValueViewController(inputArray: primaryDataHandler.ethnicityArr ?? [], selectedInputs: ethnicityInputArr, includeDeniedToSpecifyInput: true, titleString: "Select Ethnicity", identificationKey: "Ethnicity", makeSingleSelect: true)
            if let mc = delegate?.multiSelectPopVC{
                mc.delegate = self
                mc.modalPresentationStyle = .custom
                mc.transitioningDelegate = self
                delegate?.present(mc, animated: true, completion: nil)
            }
        }
    }
    
    func selectedIndexArr(selectedInputs: Array<String>?, identificationKey: String) {
        delegate?.multiSelectPopVC = nil
        delegate?.bgView.isHidden = true
        
        if let selectedInputs = selectedInputs{
            if let personalWidget = self.viewWithTag(personalWidgetTag) as? PersonalDetailsView {
                
                if identificationKey == "race"{
                    personalWidget.raceMDTF?.text = selectedInputs.joined(separator: ", ")
                }
                else if identificationKey == "Gender Identity"{
                    personalWidget.genderIdentityMDTF?.text = selectedInputs.joined(separator: ", ")
                    personalWidget.setGenderIdentity()
                }
                else if identificationKey == "Ethnicity"{
                    personalWidget.ethnicityMDTF?.text = selectedInputs.joined(separator: ", ")
                }
            }
        }
    }
        
//MARK: - PatContact Widget functions

    private func createPatContactDetailWidget(feedbackPOJO: QuestionnaireEntryPOJO){
        
        var width = contentWidth
        var addShadow = true
        
        if prevSection != nil{
            width = contentWidth - (2 * X_SPACE)
            addShadow = false
        }
        
        let patContactWidget = PatContactDetailView(width: width, addShadow: addShadow)
        
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(patContactWidget)
        }
        else{
            containerView.addArrangedSubview(patContactWidget)
        }
        
        if let patientObj = questionnaireAnswerModel?.patientObj{
            patContactWidget.updateValues(patientObj: patientObj)
        }
        if let countrykey = patContactWidget.onCountryChange(isMakeEmpty: false){
            delegate?.fetchStatesAfterCountryChange(countryName: countrykey)
        }
        
        if isDataEditAllowed {
            
            patContactWidget.tag = tagNo
            tagList.append(tagNo)
            idList.append(feedbackPOJO.questionnaireEntry.entryId)
            patContactTag = tagNo
            tagNo = tagNo + 1
            
            patContactWidget.stateMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStateClicked(tapGestureRecognizer:))))
            
            patContactWidget.countryMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryClicked(tapGestureRecognizer:))))
        }
        else{
            patContactWidget.isUserInteractionEnabled = false
        }
    }
        
    @objc func onStateClicked(tapGestureRecognizer : UITapGestureRecognizer){
        if let stateET = tapGestureRecognizer.view as? MDFLTextField {
            if let patContactView = stateET.superview?.superview as? PatContactDetailView {
                
                let country = patContactView.countryMDTF?.text?.lowercased() ?? ""
                
                if country == INDIA || country == UNITED_STATES || country == AUSTRALIA{
                    selectedTF = stateET
                    
                    delegate?.selectViewController = SelectValueViewController()
                    var stateList = primaryDataHandler.inStatesArr ?? []
                    
                    if country == UNITED_STATES {
                        stateList = primaryDataHandler.usStatesArr ?? []
                    }
                    else if country == AUSTRALIA{
                        stateList = primaryDataHandler.auStatesArr ?? []
                    }
                    if let vc = delegate?.selectViewController{
                        vc.isSearchBarNeeded = true
                        vc.arrayOfValueToBeShown = stateList
                        vc.selectedValueIndex = stateList.firstIndex(of: stateET.text ?? "")
                        vc.delegate = self
                        delegate?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else{
                    stateET.becomeFirstResponder()
                }
            }
            else if let patInsuranceView = stateET.superview?.superview?.superview as? PatInsuranceView {
                
                let country = patInsuranceView.countryMDTF?.text?.lowercased() ?? ""
                
                if country == INDIA || country == UNITED_STATES || country == AUSTRALIA{
                    selectedTF = stateET
                    
                    let vc = SelectValueViewController()
                    var stateList = primaryDataHandler.inStatesArr ?? []
                    
                    if country == UNITED_STATES {
                        stateList = primaryDataHandler.usStatesArr ?? []
                    }
                    else if country == AUSTRALIA{
                        stateList = primaryDataHandler.auStatesArr ?? []
                    }
                    vc.isSearchBarNeeded = true
                    vc.arrayOfValueToBeShown = stateList
                    vc.selectedValueIndex = stateList.firstIndex(of: stateET.text ?? "")
                    vc.delegate = self
                    delegate?.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    stateET.becomeFirstResponder()
                }
            }
        }
    }
        
    @objc func onCountryClicked(tapGestureRecognizer : UITapGestureRecognizer)
    {
        if let countryET = tapGestureRecognizer.view as? MDFLTextField {
            let vc = SelectValueViewController()
            
            selectedTF = countryET
            let countryList = primaryDataHandler.countriesArr?.map{country in country.value } ?? []
            
            vc.isSearchBarNeeded = true
            vc.arrayOfValueToBeShown = countryList
            vc.selectedValueIndex = countryList.firstIndex(of: countryET.text ?? "")
            vc.delegate = self
            delegate?.navigationController?.pushViewController(vc, animated: true)
        }
    }
       
    //MARK:  - PatInsurance Widget functions

    private func createPatInsuranceWidget(feedbackPOJO: QuestionnaireEntryPOJO){
        var width = contentWidth
        var addShadow = true
        
        if prevSection != nil{
            width = contentWidth - (2 * X_SPACE)
            addShadow = false
        }
        
        let patInsuranceWidget = PatInsuranceView(insurance: questionnaireAnswerModel?.patientInsuranceDetails, insuranceCommonData: questionnaireAnswerModel?.insuranceCommonData, width: width, addShadow: addShadow, isQuestionnaireInsurance: true)
        
        if let prevSection = prevSection {
            prevSection.addArrangedSubview(patInsuranceWidget)
        }
        else{
            containerView.addArrangedSubview(patInsuranceWidget)
        }
        
        let answer = feedbackPOJO.questionnaireEntry.answersList?.firstOrNil()
        
        if !answer.isNilOrBlank() {
            if answer == questionnaireNoInsuranceResp {
                patInsuranceWidget.hasMoreNoBtn?.isSelected = true
                patInsuranceWidget.patInsuranceMainView.isHidden = true
            }
            else{
                patInsuranceWidget.hasMoreYesBtn?.isSelected = true
            }
        }
        else{
            patInsuranceWidget.hasMoreYesBtn?.isSelected = true
        }
        
        if let insurance = questionnaireAnswerModel?.patientInsuranceDetails {
            
            patInsuranceWidget.updateValues(insurance: insurance , isDataEditAvailable: isDataEditAllowed)
            patInsuranceWidget.insuranceCardView?.delegate = delegate
        }
        
        if isDataEditAllowed {
            patInsuranceWidget.delegate = delegate
            patInsuranceWidget.tag = tagNo
            tagList.append(tagNo)
            idList.append(feedbackPOJO.questionnaireEntry.entryId)
            insuranceTag = tagNo
            tagNo = tagNo + 1
            
            patInsuranceWidget.payerNameTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPayerNameClicked(tapGestureRecognizer:))))
            
            patInsuranceWidget.stateMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStateClicked(tapGestureRecognizer:))))
            
            patInsuranceWidget.countryMDTF?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryClicked(tapGestureRecognizer:))))
            
            patInsuranceWidget.isUserInteractionEnabled = true
            
        }
        else{
            patInsuranceWidget.insuranceCardView?.hideActionButtons()
            if patInsuranceWidget.hasMoreYesBtn?.isSelected == true{
                patInsuranceWidget.hasMoreYesBtn?.setImage(#imageLiteral(resourceName: "RadioBtnSelected"), for: .normal)
            }
            patInsuranceWidget.hasMoreYesBtn?.isEnabled = false
            
            if patInsuranceWidget.hasMoreNoBtn?.isSelected == true{
                patInsuranceWidget.hasMoreNoBtn?.setImage(#imageLiteral(resourceName: "RadioBtnSelected"), for: .normal)
            }
            patInsuranceWidget.hasMoreNoBtn?.isEnabled = false
            
            patInsuranceWidget.isUserInteractionEnabled = false
        }
    }
        
    func onPatientDetailInsuranceSuccess(){
        
        if let patInsuranceWidget = self.viewWithTag(insuranceTag) as? PatInsuranceView {
            patInsuranceWidget.patient = questionnaireAnswerModel?.patientObj
            patInsuranceWidget.onPatientFetchSuccess()
        }
    }
    
    func onInsuranceCardDeleteSuccess(type: String){
        
        if let patInsuranceWidget = self.viewWithTag(insuranceTag) as? PatInsuranceView {
            if let insuranceCard = patInsuranceWidget.insuranceCardView{
                insuranceCard.onCardDeleteSuccess(type: type)
            }
        }
    }
    
    func onInsuranceCardUploadSuccess(type: String , fileName: String?){
        
        if let patInsuranceWidget = self.viewWithTag(insuranceTag) as? PatInsuranceView {
            if let insuranceCard = patInsuranceWidget.insuranceCardView{
                insuranceCard.onCardUploadSuccess(type: type, fileName: fileName)
            }
        }
    }
    
    @objc func onPayerNameClicked(tapGestureRecognizer : UITapGestureRecognizer){
        
        if let payerNameET = tapGestureRecognizer.view as? MDFLTextField {
            
            selectedTF = payerNameET
            delegate?.selectViewController = SelectValueViewController()
            if let vc = delegate?.selectViewController{
                vc.isSearchBarNeeded = true
                vc.searchStrDelegate = self
                vc.delegate = self
                vc.searchLocally = false
                vc.isSearchOn3Char = true
                
                if let patientInsuranceDetails = questionnaireAnswerModel?.patientInsuranceDetails{
                    
                    if patientInsuranceDetails.isAddNewPayerAllowed{
                        vc.valueDelegate = self
                        vc.addSearchTextAsValue = true
                    }
                    else{
                        
                    }
                }
                if let isAddNewPayerAllowed = questionnaireAnswerModel?.patientInsuranceDetails?.isAddNewPayerAllowed{
                    if isAddNewPayerAllowed{
                        vc.valueDelegate = self
                        vc.addSearchTextAsValue = true
                    }
                }
                else{
                    vc.valueDelegate = self
                    vc.addSearchTextAsValue = true
                }
                
                delegate?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
//MARK: - SelectValueVCSearchStringDelagate
        
    func onSearchStringChanged(searchStr: String) {
        delegate?.getPayerList(searchStr: searchStr)
    }
    
//MARK: - SelectValueVCDelagate
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        
        if let selectedTF = selectedTF {
            if let personalWidget = self.viewWithTag(personalWidgetTag) as? PersonalDetailsView
            {
                if selectedTF == personalWidget.languageMDTF {
                    selectedTF.text = primaryDataHandler.languageArr?[selectedRow]
                }
            }
            if let patContactWidget = self.viewWithTag(patContactTag) as? PatContactDetailView
            {
                if selectedTF == patContactWidget.countryMDTF {
                    selectedTF.text = primaryDataHandler.countriesArr?[selectedRow].value
                    if let countryKey = patContactWidget.onCountryChange(){
                        delegate?.fetchStatesAfterCountryChange(countryName: countryKey)
                    }
                }
                else if selectedTF == patContactWidget.stateMDTF {
                    
                    let country = patContactWidget.countryMDTF?.text?.lowercased() ?? ""
                    
                    if country == INDIA {
                        selectedTF.text = primaryDataHandler.inStatesArr?[selectedRow]
                    }
                    else if country == UNITED_STATES{
                        selectedTF.text = primaryDataHandler.usStatesArr?[selectedRow]
                    }
                    else if country == AUSTRALIA{
                        selectedTF.text = primaryDataHandler.auStatesArr?[selectedRow]
                    }
                }
            }
            if let patInsuranceWidget = self.viewWithTag(insuranceTag) as? PatInsuranceView
            {
                if selectedTF == patInsuranceWidget.countryMDTF {
                    selectedTF.text = primaryDataHandler.countriesArr?[selectedRow].value
                    patInsuranceWidget.onCountryChange()
                }
                else if selectedTF == patInsuranceWidget.stateMDTF {
                    
                    let country = patInsuranceWidget.countryMDTF?.text?.lowercased() ?? ""
                    
                    if country == INDIA{
                        selectedTF.text = primaryDataHandler.inStatesArr?[selectedRow]
                    }
                    else if country == UNITED_STATES{
                        selectedTF.text = primaryDataHandler.usStatesArr?[selectedRow]
                    }
                    else if country == AUSTRALIA{
                        selectedTF.text = primaryDataHandler.auStatesArr?[selectedRow]
                    }
                }
                else if selectedTF == patInsuranceWidget.payerNameTF {
                    if let payer = questionnaireAnswerModel?.practicePayerList[selectedRow]{
                        patInsuranceWidget.setInsuranceCompanyDetails(payer: payer)
                    }
                }
            }
        }
    }
    
    func selectValueViewControllerDidSelectCustomString(customString: String) {
        if let patInsuranceWidget = self.viewWithTag(insuranceTag) as? PatInsuranceView
        {
            if selectedTF == patInsuranceWidget.payerNameTF {
                selectedTF?.text = customString
                patInsuranceWidget.payerIdTF?.text = ""
            }
        }
    }
    
//MARK: - Action calls
    
    @objc func onSubmitClicked(){
        updateQuestionnaire(isSubmitted: true)
    }
    
    @objc func onSaveClicked(){
        updateQuestionnaire(isSubmitted: false)
    }
    
//MARK: - Submit call
    
    func updateQuestionnaire(isSubmitted: Bool) {
    
        if let onSubmitFeedback = onSubmitFeedback(isSubmitted: isSubmitted), let questionnaireAnswerModel = questionnaireAnswerModel {
            
            physicianTemplate?.patientQuesMap?.isSubmitted = isSubmitted

            if questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.first(where: { (questionnaireEntryPOJO) -> Bool in
                return questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypePersonalDetails || questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypePrimaryContactDetail || questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeInsurance
            }) != nil
            {
                if questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.first(where: { (questionnaireEntryPOJO) -> Bool in
                    return questionnaireEntryPOJO.questionnaireEntry.notesType != questionnaireNotesTypePersonalDetails && questionnaireEntryPOJO.questionnaireEntry.notesType != questionnaireNotesTypePrimaryContactDetail && questionnaireEntryPOJO.questionnaireEntry.notesType != questionnaireNotesTypeInsurance && questionnaireEntryPOJO.questionnaireEntry.notesType != questionnaireNotesTypeLabel && questionnaireEntryPOJO.questionnaireEntry.notesType != questionnaireNotesTypeSignature
                }) != nil
                {
                    delegate?.onUpdateQuestionnaire = onSubmitFeedback
                }
                else{
                    delegate?.onUpdateQuestionnaire = nil
                }
                
                delegate?.updateQuestionnaireWidgets(onSubmitFeedback: onSubmitFeedback)
            }
            
            else{
                delegate?.onUpdateQuestionnaire = onSubmitFeedback
                delegate?.updateQuestionnaireAnswers()

            }
        }
    }
    
    func onSubmitFeedback(isSubmitted: Bool)-> QuestionnaireDetailPOJO?{
        
        if let questionnaireAnswerModel = questionnaireAnswerModel{
            var isFeedbackGiven = false
            
            var questionnaireEntryList:[QuestionnaireEntryPOJO] = []
            var isTextFieldPresent = false
            
            if !tagList.isEmpty{
                
                for (index,tag) in tagList.enumerated()
                {
                    let entryId = idList[index]
                    
                    if let feedbackPOJO = questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.first(where: { (questionnaireEntryPOJO) -> Bool in
                        return questionnaireEntryPOJO.questionnaireEntry.entryId == entryId
                    })
                    {
                        let notesType = feedbackPOJO.questionnaireEntry.notesType
                        
                        if !isTextFieldPresent && notesType != questionnaireNotesTypeLabel && notesType != questionnaireNotesTypeSignature{
                            isTextFieldPresent = true
                        }
                        
                        if notesType == questionnaireNotesTypeYesOrNoOption || notesType == questionnaireNotesTypeOption || notesType == questionnaireNotesTypeOptionWithOthers
                        {
                            var choiceList: [String] = []
                            
                            if let questionOptionView = self.viewWithTag(tag) as? QuestionnaireOptionView
                            {
                                choiceList = questionOptionView.getSelectedOptionsAnswer()
                            }
                            
                            if feedbackPOJO.questionnaireEntry.isMandatory && (choiceList.count ) == 0 && isSubmitted
                            {
                                showMandatoryAlert(tag: tag, sectionTag: feedbackPOJO.sectionTag)
                                return nil
                            }
                            else if !choiceList.isEmpty  {
                                isFeedbackGiven = true
                                feedbackPOJO.questionnaireEntry.answersList = choiceList
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                            else if choiceList.isEmpty {
                                feedbackPOJO.questionnaireEntry.answersList = nil
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypeDate{
                            var answer: String? = nil
                            if let dateView = self.viewWithTag(tag) as? DateView
                            {
                                answer = dateView.dateText
                            }
                            
                            if feedbackPOJO.questionnaireEntry.isMandatory && answer.isNilOrBlank() && isSubmitted {
                                showMandatoryAlert(tag: tag, sectionTag: feedbackPOJO.sectionTag)
                                return nil
                            }
                            else if !answer.isNilOrBlank()  {
                                isFeedbackGiven = true
                                feedbackPOJO.questionnaireEntry.answersList = [answer ?? ""]
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                            else if answer.isNilOrBlank() {
                                feedbackPOJO.questionnaireEntry.answersList = nil
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypeSimpleQuestion || notesType == questionnaireNotesTypeQuestion{
                            
                            var answer: String? = nil
                            
                            if let questionView = self.viewWithTag(tag) as? QuestionView
                            {
                                answer = questionView.value
                            }
                            
                            if feedbackPOJO.questionnaireEntry.isMandatory && answer.isNilOrBlank() && isSubmitted {
                                showMandatoryAlert(tag: tag, sectionTag: feedbackPOJO.sectionTag)
                                return nil
                            }
                            else if !answer.isNilOrBlank()  {
                                isFeedbackGiven = true
                                feedbackPOJO.questionnaireEntry.answersList = [answer ?? ""]
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                            else if answer.isNilOrBlank() {
                                feedbackPOJO.questionnaireEntry.answersList = nil
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypeRatingScale {
                            var answer: String? = nil
                            
                            if let ratingScale = self.viewWithTag(tag) as? RatingScale{
                                answer = ratingScale.value
                            }
                            
                            if feedbackPOJO.questionnaireEntry.isMandatory && answer.isNilOrBlank() && isSubmitted {
                                showMandatoryAlert(tag: tag, sectionTag: feedbackPOJO.sectionTag)
                                return nil
                            }
                            else if !answer.isNilOrBlank()  {
                                isFeedbackGiven = true
                                feedbackPOJO.questionnaireEntry.answersList = [answer ?? ""]
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                            else if answer.isNilOrBlank() {
                                feedbackPOJO.questionnaireEntry.answersList = nil
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypeRating {
                            var answer: String? = nil
                            
                            if let ratingView = self.viewWithTag(tag) as? RatingView
                            {
                                let value = ratingView.rating
                                
                                if value != 0 {
                                    answer = "\(value)"
                                }
                            }
                            
                            if feedbackPOJO.questionnaireEntry.isMandatory && answer.isNilOrBlank() && isSubmitted {
                                showMandatoryAlert(tag: tag, sectionTag: feedbackPOJO.sectionTag)
                                return nil
                            }
                            else if !answer.isNilOrBlank()  {
                                isFeedbackGiven = true
                                feedbackPOJO.questionnaireEntry.answersList = [answer ?? ""]
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                            else if answer.isNilOrBlank() {
//                                feedbackPOJO.questionnaireEntry.answersList = ["0"]
//                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypeAllergy {
                            
                            if let allergyWidgetView = self.viewWithTag(tag) as? AllergiesWidgetView
                            {                                
                                let intakeQuestAllergyEntryList = allergyWidgetView.getAllergyEntriesList()
                                
                                if !intakeQuestAllergyEntryList.isEmpty {
                                    isFeedbackGiven = true
                                }
                                else if allergyWidgetView.nkda || allergyWidgetView.nkea || allergyWidgetView.nkfa {
                                    isFeedbackGiven = true
                                }
                                feedbackPOJO.nkda = allergyWidgetView.nkda
                                feedbackPOJO.nkfa = allergyWidgetView.nkfa
                                feedbackPOJO.nkea = allergyWidgetView.nkea
                                feedbackPOJO.questionnaireAllergyList = intakeQuestAllergyEntryList
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypeMedication ||  notesType == questionnaireNotesTypeSupplement{
                            if let prescriptionWidgetView = self.viewWithTag(tag) as? PrescriptionWidgetView
                            {
                                let intakeList = prescriptionWidgetView.getPrescriptionList()
                                if !intakeList.isEmpty {
                                    isFeedbackGiven = true
                                }
                                else if prescriptionWidgetView.nam{
                                    isFeedbackGiven = true
                                }
                                
                                if notesType == questionnaireNotesTypeMedication{
                                    feedbackPOJO.nam = prescriptionWidgetView.nam
                                    feedbackPOJO.questionnaireMedicationList = intakeList
                                }
                                else{
                                    feedbackPOJO.questionnaireSupplementList = intakeList
                                }
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypeSignature {
                            
                            if feedbackPOJO.questionnaireEntry.isMandatory && isSubmitted{
                                
                                let isAdded = signatureAddedMap[tag] ?? false
                                
                                if !isAdded {
                                    showMandatoryAlert(tag: tag, sectionTag: feedbackPOJO.sectionTag)
                                    return nil
                                }
                            }
                        }
                        else if notesType == questionnaireNotesTypePersonalDetails {
                            if let personalDetailView = self.viewWithTag(tag) as? PersonalDetailsView
                            {
                                let sectionTag = feedbackPOJO.sectionTag
                                
                                let validateDict = personalDetailView.validatePersonalDetails(isSubmitted: isSubmitted)
                                if !validateDict.isEmpty{
                                    if let firstVal = validateDict.first{
                                        showAlertDialog(titleKey: firstVal.key, textField: firstVal.value, sectionTag: sectionTag)
                                        return nil
                                    }
                                }
                                else if let patientObj = questionnaireAnswerModel.patientObj{
                                    let patient = personalDetailView.getPatientData(patient: patientObj)
                                    patient.patientId = patientObj.patientId
                                    feedbackPOJO.questionnairePersonalDetails = patient
                                }
                                isFeedbackGiven = true
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypePrimaryContactDetail {
                            
                            if let patContactView = self.viewWithTag(tag) as? PatContactDetailView
                            {
                                let sectionTag = feedbackPOJO.sectionTag
                                
                                let validateDict = patContactView.validateContactDetails(isSubmitted: isSubmitted)
                                if !validateDict.isEmpty{
                                    if let firstVal = validateDict.first{
                                        showAlertDialog(titleKey: firstVal.key, textField: firstVal.value, sectionTag: sectionTag)
                                        return nil
                                    }
                                }
                                else if let patientObj = questionnaireAnswerModel.patientObj{
                                    
                                    let patient = patContactView.getPatientData(patient: patientObj)
                                    patient.contactDetail?.contactDetailsId = patientObj.contactDetail?.contactDetailsId
                                    patient.postalAddress?.postalAddressId = patientObj.postalAddress?.postalAddressId
                                    patient.patientId = patientObj.patientId
                                    feedbackPOJO.questionnairePatContacts = patient
                                }
                                isFeedbackGiven = true
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if notesType == questionnaireNotesTypeInsurance{
                            if let patInsuranceView = self.viewWithTag(tag) as? PatInsuranceView
                            {
                                let sectionTag = feedbackPOJO.sectionTag
                                
                                let validateDict = patInsuranceView.validatePatientInsuranceDetails(isAddInsurance: false, isSubmitted: isSubmitted)
                                if !validateDict.isEmpty{
                                    if let firstVal = validateDict.first{
                                        if let mdFLTextField = firstVal.value as? MDFLTextField{
                                            showAlertDialog(titleKey: firstVal.key, textField: mdFLTextField, sectionTag: sectionTag)
                                            return nil
                                        }
                                        else if let uiView = firstVal.value as? UIView{
                                            self.endEditing(true)
                                            CharmUtil.createOkayAlertWith(title: nil, msg: getString(key: firstVal.key)) {
                                                self.containerScrollView.setContentOffset(CGPoint(x: 0, y: uiView.frame.minY), animated: true)
                                            }
                                        }
                                    }
                                }
                                else{
                                    let insurance = patInsuranceView.getPatientInsuranceDetails()
                                    insurance.practiceId = physicianTemplate?.practiceId
                                    insurance.patientInsuranceDetailsId = questionnaireAnswerModel.patientInsuranceDetails?.patientInsuranceDetailsId
                                    
                                    feedbackPOJO.questionnaireInsurance = insurance
                                }
                                isFeedbackGiven = true
                                questionnaireEntryList.append(feedbackPOJO)
                            }
                        }
                        else if questionnaireSOAPTypeList.contains(notesType ?? ""){
                            
                            var widgetEntries:[SOAPWidgetEntry] = []
                            
                            if !soapTagList.isEmpty{
                                
                                for (index,soaptag) in soapTagList.enumerated(){
                                    
                                    let soapEntryId = soapIdList[index]
                                    
                                    if let soapWidget = feedbackPOJO.soapWidget?.widgetEntries.first(where: { (soapWidgetPOJO) -> Bool in
                                        return soapWidgetPOJO.questionnaireSOAPEntry?.soapEntryId == soapEntryId
                                    })
                                    {
                                        let soapEntryType = soapWidget.entryType ?? ""
                                        
                                        if soapEntryType == soapWidgetTypeHeading{
                                            var answer: String? = nil
                                            if let label = self.viewWithTag(soaptag) as? UILabel{
                                                answer = label.text
                                            }
                                            
                                            if !answer.isNilOrBlank()  {
                                                isFeedbackGiven = true
                                                soapWidget.questionnaireSOAPEntry?.value = answer
                                                widgetEntries.append(soapWidget)
                                            }
                                            else if answer.isNilOrBlank() {
                                                soapWidget.questionnaireSOAPEntry?.value = nil
                                                widgetEntries.append(soapWidget)
                                            }
                                        }
                                        else if soapEntryType == soapWidgetTypeTable{
                                            
                                            if let soapTableView = self.viewWithTag(soaptag)?.superview?.superview?.superview as? SOAPTableView, let soapTableSubView = self.viewWithTag(soaptag) as? UIStackView{
                                                
                                                var tableStr = soapWidget.questionnaireSOAPEntry?.value ?? ""
                                                
                                                if tableStr.isBlank() {
                                                    tableStr = soapWidget.entryName ?? ""
                                                }
                                                
                                                var table = soapTableView.convertToArrayOfDictionary(text: tableStr)
                                                
                                                var answer: String? = nil
                                                
                                                if table != nil {
                                                    
                                                    let lastIndex = (table?.count ?? 0 ) - 1
                                                    for rowIndex in 0...lastIndex {
                                                        
                                                        let rowView = soapTableSubView.subviews[rowIndex]
                                                        let colLastIndex =  table![rowIndex].count - 1
                                                        
                                                        for colIndex in 0...colLastIndex {
                                                            
                                                            if let textView = rowView.subviews[colIndex].subviews.first(where: { subView in
                                                                return subView is UITextView
                                                            }) as? UITextView{
                                                                table![rowIndex][colIndex].addProperty("value", textView.text ?? "")
                                                            }
                                                            else if let uiLabel = rowView.subviews[colIndex].subviews.first(where: { subView in
                                                                return subView is UILabel
                                                            }) as? UILabel{
                                                                table![rowIndex][colIndex].addProperty("value", uiLabel.text ?? "")
                                                            }
                                                        }
                                                    }
                                                    answer = soapTableView.convertToString(json: table!)
                                                }
                                                
                                                if !answer.isNilOrBlank()  {
                                                    isFeedbackGiven = true
                                                    soapWidget.questionnaireSOAPEntry?.value = answer
                                                    widgetEntries.append(soapWidget)
                                                }
                                                else if answer.isNilOrBlank() {
                                                    soapWidget.questionnaireSOAPEntry?.value = nil
                                                    widgetEntries.append(soapWidget)
                                                }
                                            }
                                        }
                                        else if soapEntryType == soapWidgetTypeSimpleQuestion{
                                            var answer: String? = nil
                                            
                                            if let questionView = self.viewWithTag(soaptag) as? QuestionView
                                            {
                                                answer = questionView.value
                                            }
                                            
                                            if soapWidget.isMandatory && answer.isNilOrBlank() && isSubmitted {
                                                showMandatoryAlert(tag: soaptag, sectionTag: feedbackPOJO.sectionTag)
                                                return nil
                                            }
                                            else if !answer.isNilOrBlank()  {
                                                isFeedbackGiven = true
                                                soapWidget.questionnaireSOAPEntry?.value = answer
                                                widgetEntries.append(soapWidget)
                                            }
                                            else if answer.isNilOrBlank() {
                                                soapWidget.questionnaireSOAPEntry?.value = nil
                                                widgetEntries.append(soapWidget)
                                            }
                                        }
                                        else if soapEntryType == soapWidgetTypeTextbox{
                                            var answer: String? = nil
                                            
                                            if let textView = self.viewWithTag(soaptag) as? MDTextView
                                            {
                                                answer = textView.text
                                            }
                                            if soapWidget.isMandatory && answer.isNilOrBlank() && isSubmitted {
                                                showMandatoryAlert(tag: soaptag, sectionTag: feedbackPOJO.sectionTag)
                                                return nil
                                            }
                                            else if !answer.isNilOrBlank()  {
                                                isFeedbackGiven = true
                                                soapWidget.questionnaireSOAPEntry?.value = answer
                                                widgetEntries.append(soapWidget)
                                            }
                                            else if answer.isNilOrBlank() {
                                                soapWidget.questionnaireSOAPEntry?.value = nil
                                                widgetEntries.append(soapWidget)
                                            }
                                        }
                                        else if soapEntryType == soapWidgetTypeRadio || soapEntryType == soapWidgetTypeCheckbox || soapEntryType == soapWidgetTypeYesOrNo || soapEntryType == soapWidgetTypeCheckList{
                                            
                                            var answer: String? = nil
                                            if let questionnaireSoapOptionView = self.viewWithTag(soaptag) as? QuestionnaireSoapOptionView{
                                                answer = questionnaireSoapOptionView.getSelectedOptionsAnswer(soapEntryType: soapEntryType)
                                            }
                                            
                                            if soapWidget.isMandatory && answer.isNilOrBlank() && isSubmitted {
                                                showMandatoryAlert(tag: soaptag, sectionTag: feedbackPOJO.sectionTag)
                                                return nil
                                            }
                                            else if !answer.isNilOrBlank()  {
                                                isFeedbackGiven = true
                                                soapWidget.questionnaireSOAPEntry?.value = answer
                                                widgetEntries.append(soapWidget)
                                            }
                                            else if answer.isNilOrBlank() {
                                                soapWidget.questionnaireSOAPEntry?.value = nil
                                                widgetEntries.append(soapWidget)
                                            }
                                        }
                                        else if soapEntryType == soapWidgetTypeRatingScale{
                                            var answer: String? = nil
                                            
                                            if let ratingScale = self.viewWithTag(soaptag) as? RatingScale{
                                                answer = ratingScale.value
                                            }
                                            
                                            if soapWidget.isMandatory && answer.isNilOrBlank() && isSubmitted {
                                                showMandatoryAlert(tag: soaptag, sectionTag: feedbackPOJO.sectionTag)
                                                
                                                return nil
                                            }
                                            else if !answer.isNilOrBlank()  {
                                                isFeedbackGiven = true
                                                soapWidget.questionnaireSOAPEntry?.value = answer
                                                widgetEntries.append(soapWidget)
                                            }
                                            else if answer.isNilOrBlank() {
                                                soapWidget.questionnaireSOAPEntry?.value = nil
                                                widgetEntries.append(soapWidget)
                                            }
                                        }
                                    }
                                }
                            }
                            feedbackPOJO.soapWidget?.widgetEntries = widgetEntries
                            questionnaireEntryList.append(feedbackPOJO)
                        }
                    }
                }
            }
            
            if !isFeedbackGiven && physicianTemplate?.patientQuesMap?.isFilled == false && isTextFieldPresent {
                CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.questionnaire.empty.error"), msg: nil)
                return nil
            }
            
            let questionnaireDetailPOJOTemp = QuestionnaireDetailPOJO()
            questionnaireDetailPOJOTemp.patientQuesMap = questionnaireAnswerModel.questionnaireDetailPOJO?.patientQuesMap
            questionnaireDetailPOJOTemp.patientQuesMap?.isSubmitted = isSubmitted
            questionnaireDetailPOJOTemp.questionnairEntryPOJOList = questionnaireEntryList
            return questionnaireDetailPOJOTemp
        }
        return nil
    }
    
//MARK: - Scroll to the view
    
    private func scrollToViewWithTag(tag : Int? , sectionTag: Int?)
    {
        if let sectionTag = sectionTag, let sectionView = self.viewWithTag(sectionTag) as? SectionView{
            sectionView.onAnimateSectionView(toHide: false, tag: tag)
            
        }
        else if let tag{
            if let view = self.containerView.viewWithTag(tag)
            {
                scrollToViewWithTag(view: view)
            }
        }
    }
    
    func scrollToViewWithTag(view:UIView, isSectionScroll: Bool = false, y_point: CGFloat? = nil)
    {
        var superView_Y_Point: CGFloat? = nil
        if isSectionScroll{
            superView_Y_Point = view.superview?.frame.minY
        }
        else{
            superView_Y_Point = view.superview?.superview?.frame.minY
        }
        
        if let y_point = y_point{
            superView_Y_Point = (superView_Y_Point ?? 0) + y_point
        }
        
        if (self.containerScrollView.contentSize.height <= self.containerScrollView.frame.size.height)
        {
           self.containerScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        else if (superView_Y_Point ?? 0 >= (self.containerScrollView.contentSize.height - self.containerScrollView.frame.size.height))
        {
            self.containerScrollView.setContentOffset(CGPoint(x: 0, y: self.containerScrollView.contentSize.height - self.containerScrollView.frame.size.height), animated: true)
        }
        else
        {
            self.containerScrollView.setContentOffset(CGPoint(x: 0, y: superView_Y_Point ?? 0), animated: true)
        }
    }
    
//MARK: - Alert dialog related functions
    
    private func showMandatoryAlert(tag: Int, sectionTag: Int? = nil)
    {
        CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.questionnaire.mandatory.error"), msg: nil) {
            self.scrollToViewWithTag(tag: tag, sectionTag: sectionTag)
        }
    }
    
    private func showAlertDialog(titleKey: String, tag: Int? = nil, sectionTag: Int? = nil) {
        CharmUtil.createOkayAlertWith(title: getString(key: titleKey), msg: nil) {
            self.scrollToViewWithTag(tag: tag, sectionTag: sectionTag)
        }
    }
    
    private func showAlertDialog(titleKey: String, textField: MDFLTextField?, sectionTag:  Int?){
        CharmUtil.createOkayAlertWith(title: getString(key: titleKey), msg: nil) {
            if let textField = textField{
                if let sectionTag = sectionTag, let sectionView = self.viewWithTag(sectionTag) as? SectionView{
                    sectionView.onAnimateSectionView(toHide: false)
                }
                textField.becomeFirstResponder()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
