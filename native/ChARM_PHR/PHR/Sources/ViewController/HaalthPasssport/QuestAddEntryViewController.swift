//
//  QuestAddEntryViewController.swift
//  PHR
//
//  Created by prathi-13964 on 10/04/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

fileprivate let DIALOG_SIDE_INSET: CGFloat = 20
fileprivate let DIALOG_MAX_WIDTH: CGFloat = 500
fileprivate let NAME_MAXLENGTH: Int32 = 100
fileprivate let DETAIL_MAXLENGTH: Int32 = 255
fileprivate let btnHeight: CGFloat = 44

protocol QuestAddEntryVCDelegate: AnyObject {
    func questionnaireEditEntries(allergyType: AllergyType?, entryList: [AddWidgetCommonModel], index: Int?, isDeleted: Bool)
}

protocol QuestSelectEntryDelegate: AnyObject{
    func selectEntryList(allergyType: AllergyType?, addedList: [AddWidgetCommonModel])
}

class QuestAddEntryViewController: UIViewController{
    
    private let scrollView = TPKeyboardAvoidingScrollView()
    private var questAddEntryView: QuestAddEntryView? = nil
    private var questSelectEntryView: QuestSelectEntryView? = nil
    
    private var entryWidgetType: QuestEntryWidgetType? = nil
    private var entryList: [AddWidgetCommonModel] = []
    private var index: Int? = nil
    private var allergyType: AllergyType? = nil
    private weak var addDelegate: QuestAddEntryVCDelegate? = nil
    private weak var selectDelegate: QuestSelectEntryDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: POPVC_BG_COLOR)
        
        self.view.addSubview(scrollView)
        
        scrollView.setSafeAreaLeft(offset: 0)
        scrollView.setSafeAreaRight(offset: 0)
        scrollView.setSafeAreaTop(offset: 0)
        scrollView.setSafeAreaBottom(offset: 0)
        
        if let questAddEntryView{
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
            scrollView.addSubview(questAddEntryView)
            
            questAddEntryView.setCenterX()
            questAddEntryView.setCenterY()
            setDialogWidth(questAddEntryView)
            
            questAddEntryView.closeBtn.addTarget(self, action: #selector(onClickCloseBtn), for: .touchUpInside)
            questAddEntryView.doneBtn.addTarget(self, action: #selector(onClickDoneBtn), for: .touchUpInside)
            
            if index != nil{
                questAddEntryView.deleteBtn.addTarget(self, action: #selector(onClickDeleteBtn), for: .touchUpInside)
            }
        }
        else if let questSelectEntryView{
            scrollView.addSubview(questSelectEntryView)
            
            questSelectEntryView.setCenterX()
            questSelectEntryView.setCenterY()
            setDialogWidth(questSelectEntryView)
            
            questSelectEntryView.closeBtn.addTarget(self, action: #selector(onClickCloseBtn), for: .touchUpInside)
            questSelectEntryView.addBtn.addTarget(self, action: #selector(onClickAddBtn), for: .touchUpInside)
        }
    }
    
    // Visible width minus 20 each side (as on iPhone), capped so the dialog doesn't stretch across the unfolded iPhone Duo.
    private func setDialogWidth(_ dialog: UIView){
        let fitsScreen = dialog.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -DIALOG_SIDE_INSET * 2)
        fitsScreen.priority = .defaultHigh
        NSLayoutConstraint.activate([
            fitsScreen,
            dialog.widthAnchor.constraint(lessThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor, constant: -DIALOG_SIDE_INSET * 2),
            dialog.widthAnchor.constraint(lessThanOrEqualToConstant: DIALOG_MAX_WIDTH)
        ])
    }

    init(entryWidgetType: QuestEntryWidgetType?, allergyType: AllergyType? = nil, entryList: [AddWidgetCommonModel], index: Int? = nil, delegate: QuestAddEntryVCDelegate){
        super.init(nibName: nil, bundle: nil)
        
        self.entryWidgetType = entryWidgetType
        self.allergyType = allergyType
        self.entryList = entryList
        self.index = index
        self.addDelegate = delegate
        
        questAddEntryView = QuestAddEntryView(entryWidgetType: entryWidgetType, allergyType: allergyType, entryList: entryList, index: index)
    }
    
    init(entryList: [AddWidgetCommonModel], allergyType: AllergyType? = nil, selectDelegate: QuestSelectEntryDelegate?){
        super.init(nibName: nil, bundle: nil)
        
        self.entryList = entryList
        self.allergyType = allergyType
        self.selectDelegate = selectDelegate
        
        questSelectEntryView = QuestSelectEntryView(entryList: entryList, allergyType: allergyType)
    }
    
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc private func onClickCloseBtn(){
        self.dismiss(animated: true)
    }
    
    @objc private func onClickDoneBtn(){
        
        let nameValue = questAddEntryView?.nameValueField.text
        if nameValue.isNilOrBlank(){
            CharmUtil.createOkayAlertWith(title: getString(key: "com.charmphr.questionnairevc.addEntries.mandatory.alert.title", with: [questAddEntryView?.label ?? ""]), msg: nil) {
                self.questAddEntryView?.nameValueField.becomeFirstResponder()
            }
            return
        }
        
        let entryModel = index == nil ? AddWidgetCommonModel() : entryList[index!]
        
        entryModel.name = nameValue?.trim()
        entryModel.description = questAddEntryView?.detailValueField.text.trim()
        
        if entryWidgetType == .Allergy, let allergyType{
            entryModel.severity = questAddEntryView?.selectedSeverity
            entryModel.type = allergyType
        }
        
        if index == nil{
            entryList.append(entryModel)
            index = entryList.count - 1
        }
        
        addDelegate?.questionnaireEditEntries(allergyType: allergyType, entryList: entryList, index: index, isDeleted: false)
        self.dismiss(animated: true)
    }
    
    @objc private func onClickDeleteBtn() {
        
        if let index{
            entryList.remove(at: index)
            addDelegate?.questionnaireEditEntries(allergyType: allergyType, entryList: entryList, index: index, isDeleted: true)
        }
        self.dismiss(animated: true)
    }
    
    @objc private func onClickAddBtn(){
        if let questSelectEntryView{
            let selectedIndex = questSelectEntryView.selectedIndex
            
            let selectedEntryList = selectedIndex.map { entryList[$0] }
            selectDelegate?.selectEntryList(allergyType: allergyType, addedList: selectedEntryList)
        }
        self.dismiss(animated: true)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class QuestAddEntryView: UIView, UITextFieldDelegate, MDTextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, MDTextViewDelegate{
    
    private let titleLabel = UILabel()
    let closeBtn = UIButton()
    private let separatorLine1 = UIView()
    private let nameView = UIView()
    private let nameLabel = UILabel()
    let nameValueField = MDTextField()
    private let detailView = UIView()
    private let detailLabel = UILabel()
    let detailValueField = MDTextView()
    private let separatorLine2 = UIView()
    let doneBtn = UIButton()
    private lazy var verticalLine = UIButton()
    lazy var deleteBtn = UIButton()
    lazy var severityValueField = MDTextField()
    
    private let severityList:[Severity] = [Severity.Severe , Severity.Moderate , Severity.Mild]
    private let spacing: CGFloat = 10
    private let highlightViewBorderColor: UInt = 0x4074D980
    var selectedSeverity: Severity? = nil
    
    var label: String? {
        return nameLabel.text?.removeStar()
    }
    
    init(entryWidgetType: QuestEntryWidgetType?, allergyType: AllergyType?, entryList: [AddWidgetCommonModel], index: Int?){
        super.init(frame: .zero)
        
        self.addCornerRadius(.LARGE)
        self.backgroundColor = .white
        
        self.addSubview(titleLabel)
        self.addSubview(closeBtn)
        self.addSubview(separatorLine1)
        self.addSubview(nameView)
        nameView.addSubview(nameLabel)
        nameView.addSubview(nameValueField)
        self.addSubview(detailView)
        detailView.addSubview(detailLabel)
        detailView.addSubview(detailValueField)
        self.addSubview(separatorLine2)
        self.addSubview(doneBtn)
        
        titleLabel.setProperties(textKey: "", fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        
        closeBtn.setImage(UIImage(named: "Close_Gray"), for: .normal)
        closeBtn.setPadding(vertical: 12, horizontal: 12)
        
        separatorLine1.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)
        separatorLine2.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)
        
        doneBtn.setProperties(titleStrKey: "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: THEME_COLOR)
        
        titleLabel.setLeft(offSet: SPACING_12)
        titleLabel.setCenterY(view: closeBtn)
        
        closeBtn.setRight(offSet: 0)
        closeBtn.setTop(offSet: 0)
        closeBtn.setWidth(constant: BTN_SIZE_24 * 2)
        closeBtn.setHeight(constant: BTN_SIZE_24 * 2)
        
        separatorLine1.setLeft(offSet: 0)
        separatorLine1.setRight(offSet: 0)
        separatorLine1.setTopRelatedToView(offSet: 0, relatedView: closeBtn, relatedAttribute: .bottom)
        separatorLine1.setHeight(constant: LINE_HEIGHT)
        
        separatorLine2.setLeft(offSet: 0)
        separatorLine2.setRight(offSet: 0)
        separatorLine2.setTopRelatedToView(offSet: SPACING_12, relatedView: detailView, relatedAttribute: .bottom)
        separatorLine2.setHeight(constant: LINE_HEIGHT)
        
        if index != nil{
            doneBtn.setTitle(getString(key: "com.charmphr.action.save"), for: .normal)
            self.addSubview(deleteBtn)
            self.addSubview(verticalLine)
            
            verticalLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)
            
            deleteBtn.setProperties(titleStrKey: "com.charmphr.action.delete", fontsize: FONT_SIZE_EXTRALARGE, weight: .regular, fontcolor: TEXT_COLOR_BRIGHT_RED)
            
            deleteBtn.setLeft(offSet: 0)
            deleteBtn.setTopRelatedToView(offSet: 0, relatedView: separatorLine2, relatedAttribute: .bottom)
            deleteBtn.setBottom(offSet: 0)
            deleteBtn.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -0.5).isActive = true
            deleteBtn.setHeight(constant: btnHeight)
            
            verticalLine.setLeftRelatedToView(offSet: 0, relatedView: deleteBtn, relatedAttribute: .right)
            verticalLine.setTopRelatedToView(offSet: 0, relatedView: separatorLine2, relatedAttribute: .bottom)
            verticalLine.setBottom(offSet: 0)
            verticalLine.setWidth(constant: 1)
            verticalLine.setHeight(constant: btnHeight)
            
            doneBtn.setLeftRelatedToView(offSet: 0, relatedView: verticalLine, relatedAttribute: .right)
            doneBtn.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -0.5).isActive = true
        }
        else{
            doneBtn.setTitle(getString(key: "com.charmphr.action.add"), for: .normal)
            doneBtn.setLeft(offSet: 0)
            doneBtn.setRight(offSet: 0)
        }
        
        doneBtn.setTopRelatedToView(offSet: 0, relatedView: separatorLine2, relatedAttribute: .bottom)
        doneBtn.setBottom(offSet: 0)
        doneBtn.setHeight(constant: btnHeight)
        
        nameView.layer.borderWidth = BORDER_WIDTH
        nameView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        nameView.addCornerRadius(.SMALL)
        nameView.layer.masksToBounds = true
        
        nameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        
        nameValueField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL,Weight: .regular)
        nameValueField.placeholder = getString(key: "com.charmphr.questionnairevc.tapToAnswer.placeholder")
        nameValueField.maxLength = NAME_MAXLENGTH
        nameValueField.delegate = self
        
        detailView.layer.borderWidth = BORDER_WIDTH
        detailView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        detailView.addCornerRadius(.SMALL)
        detailView.layer.masksToBounds = true
        
        detailLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        
        detailValueField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL,Weight: .regular)
        detailValueField.maxLength = DETAIL_MAXLENGTH
        detailValueField.delegate = self
        
        nameView.setLeft(offSet: spacing)
        nameView.setRight(offSet: -spacing)
        nameView.setTopRelatedToView(offSet: SPACING_12, relatedView: separatorLine1, relatedAttribute: .bottom)
        
        nameLabel.setLeft(offSet: PADDING_8)
        nameLabel.setTop(offSet: CARD_PADDING)
        
        nameValueField.setLeft(offSet: PADDING_8)
        nameValueField.setRight(offSet: -PADDING_8)
        nameValueField.setTopRelatedToView(offSet: PADDING_4, relatedView: nameLabel, relatedAttribute: .bottom)
        nameValueField.setBottom(offSet: -CARD_PADDING)
        
        detailView.setLeft(offSet: spacing)
        detailView.setRight(offSet: -spacing)
        
        detailLabel.setLeft(offSet: PADDING_8)
        detailLabel.setTop(offSet: CARD_PADDING)
        
        detailValueField.setLeft(offSet: PADDING_4)
        detailValueField.setRight(offSet: 0)
        detailValueField.setTopRelatedToView(offSet: 0, relatedView: detailLabel, relatedAttribute: .bottom)
        detailValueField.setBottom(offSet: -PADDING_5)
        detailValueField.setHeight(constant: 65)
        
        if entryWidgetType == .Allergy{
            
            let severityView = UIView()
            let severityLabel = UILabel()
            
            self.addSubview(severityView)
            severityView.addSubview(severityLabel)
            severityView.addSubview(severityValueField)
            
            severityView.layer.borderWidth = BORDER_WIDTH
            severityView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
            severityView.addCornerRadius(.SMALL)
            severityView.layer.masksToBounds = true
            
            severityLabel.setProperties(textKey: "com.charmphr.questionnairevc.severity.title", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
            
            severityValueField.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL,Weight: .regular)
            severityValueField.placeholder = getString(key: "com.charmphr.questionnairevc.tapToSelect.placeholder")
            severityValueField.delegate = self
            
            let severityPicker = UIPickerView()
            severityPicker.delegate = self
            severityPicker.dataSource = self
            
            severityValueField.inputView = severityPicker
            
            severityView.setLeft(offSet: spacing)
            severityView.setRight(offSet: -spacing)
            severityView.setTopRelatedToView(offSet: PADDING_6, relatedView: nameView, relatedAttribute: .bottom)
            
            severityLabel.setLeft(offSet: PADDING_8)
            severityLabel.setTop(offSet: CARD_PADDING)
            severityLabel.wrapWidth(maxWidth: 300)
            
            severityValueField.setLeft(offSet: PADDING_8)
            severityValueField.setRight(offSet: -PADDING_8)
            severityValueField.setTopRelatedToView(offSet: PADDING_4, relatedView: severityLabel, relatedAttribute: .bottom)
            severityValueField.setBottom(offSet: -CARD_PADDING)
            
            detailView.setTopRelatedToView(offSet: PADDING_6, relatedView: severityView, relatedAttribute: .bottom)
        }
        else{
            detailView.setTopRelatedToView(offSet: PADDING_6, relatedView: nameView, relatedAttribute: .bottom)
        }
        
        if entryWidgetType == .Allergy{
            
            if allergyType == .DrugAllergy{
                titleLabel.text = getString(key: "com.charmphr.questionnairevc.drugAllergy.title")
            }
            else if allergyType == .FoodAllergy{
                titleLabel.text = getString(key: "com.charmphr.questionnairevc.foodAllergy.title")
            }
            else if allergyType == .EnvironmentalAllergy{
                titleLabel.text = getString(key: "com.charmphr.questionnairevc.environmentAllergy.title")
            }
            nameLabel.text = getString(key: "com.charmphr.questionnairevc.allergen.title")
            detailLabel.text = getString(key: "com.charmphr.questionnairevc.reaction.title")
        }
        else if entryWidgetType == .Medication{
            
            titleLabel.text = getString(key: "com.charmphr.questionnairevc.medication.title", with: [""])
            nameLabel.text = getString(key: "com.charmphr.questionnairevc.medication.medicationName")
            detailLabel.text = getString(key: "com.charmphr.questionnairevc.intakeDetails.title")
        }
        else if entryWidgetType == .Supplement{
            
            titleLabel.text = getString(key: "com.charmphr.questionnairevc.supplement.title", with: [""])
            nameLabel.text = getString(key: "com.charmphr.questionnairevc.supplement.supplementName")
            detailLabel.text = getString(key: "com.charmphr.questionnairevc.intakeDetails.title")
        }
        
        if let index{
            let entryModel = entryList[index]
            if entryWidgetType == .Allergy{
                selectedSeverity =  entryModel.severity
                severityValueField.text = selectedSeverity?.rawValue
            }
            nameValueField.text = entryModel.name
            detailValueField.text = entryModel.description
        }
        
        nameLabel.makeMandatory()
        titleLabel.wrapWidth(maxWidth: 300)
        nameLabel.wrapWidth(maxWidth: 300)
        detailLabel.wrapWidth(maxWidth: 300)
    }
    
//MARK: - TextField and TextView Delegate
    
    func mdTextFieldDidBeginEditing(_ textField: MDTextField!) {
        textField.superview?.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: highlightViewBorderColor).cgColor
    }
    
    func mdTextFieldDidEndEditing(_ textField: MDTextField!) {
        textField.superview?.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
    }
    
    func mdTextFieldShouldReturn(_ textField: MDTextField!) -> Bool {
        textField.resignFirstResponder()
    }
    
    func mdTextViewDidBeginEditing(_ textView: MDTextView!) {
        textView.superview?.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: highlightViewBorderColor).cgColor
    }
    
    func mdTextViewDidEndEditing(_ textView: MDTextView!) {
        textView.superview?.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
    }
  
//MARK: - PickerView Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return severityList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return severityList[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSeverity = severityList[row]
        severityValueField.text = selectedSeverity?.rawValue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate let widgetEntryCellIdentifier = "WidgetEntryTableViewCell"

fileprivate class QuestSelectEntryView: UIView, UITableViewDataSource, UITableViewDelegate {

    private let titleLabel = UILabel()
    let closeBtn = UIButton()
    private let separatorLine1 = UIView()
    private let tableView = UITableView()
    private let separatorLine2 = UIView()
    let addBtn = UIButton()
    var selectedIndex: [Int] = []
    private var entryList: [AddWidgetCommonModel] = []

    init(entryList: [AddWidgetCommonModel], allergyType: AllergyType?){
        super.init(frame: .zero)

        self.entryList = entryList

        self.addCornerRadius(.LARGE)
        self.backgroundColor = .white

        self.addSubview(titleLabel)
        self.addSubview(closeBtn)
        self.addSubview(separatorLine1)
        self.addSubview(tableView)
        self.addSubview(separatorLine2)
        self.addSubview(addBtn)

        titleLabel.setProperties(textKey: getString(key: "com.charmphr.questionnaire.widget.select.title", with: [allergyType?.rawValue ?? ""]), fontsize: FONT_SIZE_LARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)

        closeBtn.setImage(UIImage(named: "Close_Gray"), for: .normal)
        closeBtn.setPadding(vertical: 12, horizontal: 12)

        separatorLine1.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)
        separatorLine2.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)

        addBtn.setProperties(titleStrKey: "com.charmphr.action.add", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: THEME_COLOR)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WidgetEntryTableViewCell.self, forCellReuseIdentifier: widgetEntryCellIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white

        titleLabel.setLeft(offSet: SPACING_12)
        titleLabel.setCenterY(view: closeBtn)

        closeBtn.setRight(offSet: 0)
        closeBtn.setTop(offSet: 0)
        closeBtn.setWidth(constant: BTN_SIZE_24 * 2)
        closeBtn.setHeight(constant: BTN_SIZE_24 * 2)

        separatorLine1.setLeft(offSet: 0)
        separatorLine1.setRight(offSet: 0)
        separatorLine1.setTopRelatedToView(offSet: 0, relatedView: closeBtn, relatedAttribute: .bottom)
        separatorLine1.setHeight(constant: LINE_HEIGHT)

        tableView.setLeft(offSet: 0)
        tableView.setRight(offSet: 0)
        tableView.setTopRelatedToView(offSet: 0, relatedView: separatorLine1, relatedAttribute: .bottom)
        tableView.setHeight(constant: 275)

        separatorLine2.setLeft(offSet: 0)
        separatorLine2.setRight(offSet: 0)
        separatorLine2.setTopRelatedToView(offSet: SPACING_12, relatedView: tableView, relatedAttribute: .bottom)
        separatorLine2.setHeight(constant: LINE_HEIGHT)

        addBtn.setLeft(offSet: 0)
        addBtn.setRight(offSet: 0)
        addBtn.setTopRelatedToView(offSet: 0, relatedView: separatorLine2, relatedAttribute: .bottom)
        addBtn.setBottom(offSet: 0)
        addBtn.setHeight(constant: btnHeight)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: widgetEntryCellIdentifier, for: indexPath) as? WidgetEntryTableViewCell else {
            return UITableViewCell()
        }

        let model = entryList[indexPath.row]
        cell.configure(with: model)
        cell.isEntrySelected = selectedIndex.contains(indexPath.row)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if let cell = tableView.cellForRow(at: indexPath) as? WidgetEntryTableViewCell {
            cell.isEntrySelected = !cell.isEntrySelected
            selectActionOnWidget(index: indexPath.row, isSelected: cell.isEntrySelected)
        }
    }

    private func selectActionOnWidget(index: Int, isSelected: Bool) {
        if isSelected {
            selectedIndex.append(index)
        } else {
            if let idx = selectedIndex.firstIndex(of: index) {
                selectedIndex.remove(at: idx)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - WidgetEntryTableViewCell

fileprivate class WidgetEntryTableViewCell: UITableViewCell {

    private let checkBoxBtn = UIButton()
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private var severityView: SeverityView? = nil
    private var descriptionLabel: UILabel? = nil
    private var bottomConstraint: NSLayoutConstraint? = nil

    private var addWidgetCommonModel: AddWidgetCommonModel? = nil

    var isEntrySelected: Bool = false {
        didSet {
            checkBoxBtn.isSelected = isEntrySelected
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {
        self.selectionStyle = .none
        self.backgroundColor = .white
        contentView.backgroundColor = .white
        
        self.layoutMargins = .zero
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
       

        contentView.addSubview(checkBoxBtn)
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)

        checkBoxBtn.setImage(UIImage(named: "CheckboxUnselected"), for: .normal)
        checkBoxBtn.setImage(UIImage(named: "CheckboxSelected"), for: .selected)
        checkBoxBtn.isUserInteractionEnabled = false

        nameLabel.setProperties(textKey: "", fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_BLACK87)
        nameLabel.numberOfLines = 0

        let btnSize: CGFloat = 40
        checkBoxBtn.setLeft(offSet: PADDING_6)
        checkBoxBtn.setTop(offSet: 0)
        checkBoxBtn.setWidth(constant: btnSize)
        checkBoxBtn.setHeight(constant: btnSize)

        containerView.setLeftRelatedToView(offSet: 0, relatedView: checkBoxBtn, relatedAttribute: .right)
        containerView.setRight(offSet: -CARD_PADDING)
        containerView.setTop(offSet: CARD_PADDING)
        containerView.setBottom(offSet: -CARD_PADDING)

        nameLabel.setLeft(offSet: 0)
        nameLabel.setTop(offSet: 0)
        nameLabel.setRight(offSet: 0)
    }

    func configure(with model: AddWidgetCommonModel) {
        self.addWidgetCommonModel = model
        nameLabel.text = model.name ?? ""

        severityView?.removeFromSuperview()
        severityView = nil
        descriptionLabel?.removeFromSuperview()
        descriptionLabel = nil

        var lastView: UIView = nameLabel

        if let severity = model.severity {
            let sevView = SeverityView(severity: severity)
            containerView.addSubview(sevView)

            sevView.setLeftRelatedToView(offSet: SPACING_12, relatedView: nameLabel, relatedAttribute: .right)
            sevView.setTop(offSet: 0)
            sevView.setWidth(constant: sevView.viewWidth)
            sevView.setHeight(constant: sevView.viewHeight)

            severityView = sevView
        }

        if let description = model.description, !description.isEmpty {
            let descLabel = UILabel()
            descLabel.setProperties(textKey: "", fontsize: FONT_SIZE_SMALL, weight: .regular, fontcolor: TEXT_COLOR_LIGHTGRAY)
            descLabel.text = description
            descLabel.numberOfLines = 0

            containerView.addSubview(descLabel)

            descLabel.setLeft(offSet: 0)
            descLabel.setRight(offSet: 0)
            descLabel.setTopRelatedToView(offSet: PADDING_4, relatedView: nameLabel, relatedAttribute: .bottom)

            descriptionLabel = descLabel
            lastView = descLabel
        }

        if let bottomConstraint = bottomConstraint {
            containerView.removeConstraint(bottomConstraint)
        }
        bottomConstraint = lastView.setAndReturnBottom(offSet: 0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        isEntrySelected = false
        addWidgetCommonModel = nil

        severityView?.removeFromSuperview()
        severityView = nil
        descriptionLabel?.removeFromSuperview()
        descriptionLabel = nil

        if let bottomConstraint = bottomConstraint {
            containerView.removeConstraint(bottomConstraint)
        }
        bottomConstraint = nil
    }
}

enum AllergyType : String{
    case DrugAllergy = "Drug"
    case FoodAllergy = "Food"
    case EnvironmentalAllergy = "Environmental"
}

enum QuestEntryWidgetType{
    case Allergy
    case Medication
    case Supplement
}
