

import UIKit

let problemStatusOptions = ["Active","Inactive" , "Resolved"]


class AddMedicalConditionViewController: AddDataUIViewController,
    SelectValueViewControllerDelagate,
    CharmConnectionV2HandlerDelegate,
    UITextViewDelegate,
    MDTextFieldDelegate,
    UITextFieldDelegate
{
    let CONDITION_NAME_TAG = 2000
    let STATUS_TAG         = 2001
    let ONSET_DATE_TAG     = 2002
    let RESOLVED_DATE_TAG  = 2003
    let NOTES_TAG          = 2004

    let activityIndicator = UIActivityIndicatorView()

    var charmConnectionHandler: CharmConnectionHandler?
    var conditionCommonData: [DataWithId] = []
    private var conditionNames: [String] = []
    private var selectedCondition: DataWithId?
    var isCommonDataFetched = false
    var selectedAddModuleKeyAndLabelView: AddModuleKeyAndValueView?

    let onsetDatePicker = UIDatePicker()
    let resolvedDatePicker = UIDatePicker()

    var editMedicalCondition: MedicalCondition?
    weak var delegate: AddViewControllerDelegate?

    
    
    private let conditionNameView = AddModuleKeyAndValueView()
    private let statusView = AddModuleKeyAndValueView()
    private let onsetDateView = AddModuleKeyAndValueView(isDateField: true)
    private let resolvedDateView = AddModuleKeyAndValueView(isDateField: true)
    private let notesView = AddModuleKeyAndValueWithTextView()
    
    private lazy var currentDate = Date()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        createSubViews()

        self.navigationItem.setRightBarButton(
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)),
            animated: true
        )

        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()

        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)

        self.navigationItem.title = editMedicalCondition == nil
            ? getString(key: "com.charmphr.addMedicalCondition.title")
            : getString(key: "com.charmphr.editMedicalCondition.title")

        if editMedicalCondition != nil {
            conditionNameView.isUserInteractionEnabled = false
            conditionNameView.alpha = 0.5
        }

        fetchCommonData()
    }

    // MARK: - UI Setup

    func createSubViews() {
        let containerScrollView = TPKeyboardAvoidingScrollView()
        let containerView = UIView()
        containerView.backgroundColor = .clear

        // Fields
        if editMedicalCondition == nil {
            conditionNameView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        }
        else{
            conditionNameView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: false)
        }
        conditionNameView.tag = CONDITION_NAME_TAG
        conditionNameView.keyLabel.text = getString(key: "com.charmphr.addMedicalCondition.name.title")
        conditionNameView.keyLabel.makeMandatory()
        if editMedicalCondition == nil {
            conditionNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        }
        conditionNameView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)

        statusView.setSubviews(isArrowImageNeeded: true, isTextFieldShouldBeShown: false)
        statusView.tag = STATUS_TAG
        statusView.keyLabel.text = getString(key: "com.charmphr.addMedicalCondition.Status.title")
       // statusView.addShadowAndCornerRadius(.SMALL)
        statusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        statusView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)

        onsetDatePicker.preferredDatePickerStyle = .wheels
        onsetDatePicker.datePickerMode = .date
        onsetDatePicker.addTarget(self, action: #selector(onsetDatePickerValueChanged(datePicker:)), for: .valueChanged)

        onsetDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        onsetDateView.tag = ONSET_DATE_TAG
        onsetDateView.keyLabel.text = getString(key: "com.charmphr.addMedicalCondition.Date.title")
        onsetDateView.textField.tintColor = .clear
        onsetDateView.textField.inputView = onsetDatePicker
        onsetDateView.setPlaceholderForTextField(text: getString(key: "com.charmphr.common.dateField.placeholder"))
      //  onsetDateView.addShadowAndCornerRadius(.SMALL)
        onsetDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        onsetDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)

        resolvedDatePicker.preferredDatePickerStyle = .wheels
        resolvedDatePicker.datePickerMode = .date
        resolvedDatePicker.addTarget(self, action: #selector(resolvedDatePickerValueChanged(datePicker:)), for: .valueChanged)

        resolvedDateView.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
        resolvedDateView.tag = RESOLVED_DATE_TAG
        resolvedDateView.keyLabel.text = getString(key: "com.charmphr.addMedicalCondition.resolvedDate.title")
        resolvedDateView.textField.tintColor = .clear
        resolvedDateView.textField.inputView = resolvedDatePicker
        resolvedDateView.setPlaceholderForTextField(text: getString(key: "com.charmphr.common.dateField.placeholder"))
     //   resolvedDateView.addShadowAndCornerRadius(.SMALL)
        resolvedDateView.isHidden = true
        resolvedDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked(tapGestureRecognizer:))))
        resolvedDateView.addBottomBorder(borderWidth: SEPARATOR_HEIGHT)

        notesView.KeyLabel.text = getString(key: "com.charmphr.addMedicalCondition.notes.title")
        notesView.textView.tag = NOTES_TAG
        notesView.textView.maxLength = 255
        notesView.textView.delegate = self
        notesView.addShadowAndCornerRadius(.SMALL)

        // Stack — hidden views collapse automatically
        let stackView = UIStackView(arrangedSubviews: [
            conditionNameView, statusView, onsetDateView, resolvedDateView, notesView
        ])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        containerView.addSubview(stackView)

        // Container constraints
        containerScrollView.addSubview(containerView)
        self.view.addSubview(containerScrollView)

        containerView.setTop(offSet: 0)
        containerView.setBottom(offSet: 0)
        containerView.setLeft(offSet: 0)
        containerView.setWidth(constant: applicationFrame.width)

        containerScrollView.setSafeAreaTop(offset: 0)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerScrollView]-0-|", options: [], metrics: nil, views: ["containerScrollView": containerScrollView]))
        containerScrollView.setSafeAreaBottom(offset: 0)

        // Stack constraints
        stackView.setTop(offSet: Y_SPACE)
        stackView.setHorizontal(offSet: X_SPACE)
        stackView.setBottom(offSet: -Y_SPACE)
        
        stackView.addShadowAndCornerRadius(.SMALL)
    }

    // MARK: - Data Fetch

    func fetchCommonData() {
        showActivityIndicator()
        charmConnectionHandler?.fetchCommonDataForMedicalCondition(identificationKey: "fetchCommonData")
    }

    // MARK: - Actions

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    @objc func onsetDatePickerValueChanged(datePicker: UIDatePicker) {
        
        onsetDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
        
    }

    @objc func resolvedDatePickerValueChanged(datePicker: UIDatePicker) {
        resolvedDateView.textField.text = CharmUtil.getDisplayDateStringWithYear(date: datePicker.date)
    }

    @objc func viewClicked(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let tappedView = tapGestureRecognizer.view as? AddModuleKeyAndValueView else { return }

        if tappedView.tag == STATUS_TAG {
            selectedAddModuleKeyAndLabelView = tappedView
            dismissKeyboard()
            navigateToSelectValueVC()
        } else if tappedView.tag == CONDITION_NAME_TAG {
            if isCommonDataFetched {
                selectedAddModuleKeyAndLabelView = tappedView
                dismissKeyboard()
                navigateToSelectValueVC()
            }
        } else if tappedView.tag == ONSET_DATE_TAG || tappedView.tag == RESOLVED_DATE_TAG {
            tappedView.textField.becomeFirstResponder()
        }
    }

    @objc func doneBtnClicked() {
        dismissKeyboard()

        if isNilOrEmpty(string: conditionNameView.valueLabel.text) {
            showMandatoryAlert(fieldName: getString(key: "com.charmphr.addMedicalCondition.name.title"))
        } else if isNilOrEmpty(string: statusView.valueLabel.text) {
            showMandatoryAlert(fieldName: getString(key: "com.charmphr.addMedicalCondition.Status.title"))
        } else {
            let condition = MedicalCondition()
            condition.name = conditionNameView.valueLabel.text
            condition.medicalConditionId = selectedCondition?.key

//            if let index = conditionCommonData.firstIndex(where: { $0.value == conditionNameView.valueLabel.text }) {
//                condition.medicalConditionId = conditionCommonData[index].key
//            }

            if let edit = editMedicalCondition {
                condition.medicalConditionMapId = edit.medicalConditionMapId
            }

            condition.status = statusView.valueLabel.text

            if !isNilOrEmpty(string: onsetDateView.textField.text) {
                condition.dateOfOnset = onsetDatePicker.date
            }

            if !resolvedDateView.isHidden {
                if !isNilOrEmpty(string: resolvedDateView.textField.text) {
                    condition.resolvedDate = resolvedDatePicker.date
                }
            }
        
            condition.notes = notesView.textView.text

            showActivityIndicator()
            charmConnectionHandler?.addMedicalCondition(
                condition: condition,
                identificationKey: "addCondition",
                isEdit: editMedicalCondition != nil
            )
        }
    }

    private func updateResolvedDateVisibility(status: String?) {
        let show = status?.lowercased() == "resolved"
        resolvedDateView.isHidden = !show
        if show {
            let text  = resolvedDateView.textField.text ?? ""
            if text.isBlank() {
                resolvedDatePicker.date = Date()
                resolvedDatePickerValueChanged(datePicker: resolvedDatePicker)
            }
        }
    }

    func showMandatoryAlert(fieldName: String?) {
        CharmUtil.createOkayAlertWith(title: nil, msg: "\(getString(key: "com.charmphr.common.mandatory.alert.msg"))\(fieldName ?? "")")
    }

    // MARK: - Back

    @objc override func onBackClick() {
        if checkDataIsAvailable() {
            showDiscardChangesDialog()
            return
        }
        self.navigationController?.popViewController(animated: true)
    }

    private func checkDataIsAvailable() -> Bool {
        
        if let editMedicalCondition  {
            if editMedicalCondition.status != statusView.valueLabel.text {
                return true
            }
            
            if editMedicalCondition.dateOfOnset?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) != onsetDateView.textField.text {
                return true
            }
            
            
            if let resolvedDate = editMedicalCondition.resolvedDate {
                if resolvedDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) != resolvedDateView.textField.text {
                    return true
                }
            }
            
            if editMedicalCondition.notes != notesView.textView.text {
                return true
            }
        }
        else {
            
            if !conditionNameView.valueLabel.text.isNilOrBlank() {
                return true
            }
            
            if problemStatusOptions.getElement(at: 0) != statusView.valueLabel.text {
                return true
            }
            
            if currentDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR) != onsetDateView.textField.text {
                return true
            }
            
            
            if !resolvedDateView.textField.text.isNilOrBlank() {
                return true
            }
            
            if !notesView.textView.text.isNilOrBlank() {
                return true
            }
        }
        
        return false
    }

    // MARK: - Navigation

    func navigateToSelectValueVC() {
        let vc = SelectValueViewController()
        vc.delegate = self

        guard let selectedField = selectedAddModuleKeyAndLabelView else { return }
        vc.title = selectedField.keyLabel.text

        if selectedField.tag == CONDITION_NAME_TAG {
            vc.isSearchBarNeeded = true
            vc.arrayOfValueToBeShown = conditionNames
            vc.selectedValueIndex = conditionNames.firstIndex(of: selectedField.valueLabel.text ?? "")
        } else if selectedField.tag == STATUS_TAG {
            vc.isSearchBarNeeded = false
            vc.arrayOfValueToBeShown = problemStatusOptions
            vc.selectedValueIndex = problemStatusOptions.firstIndex(of: selectedField.valueLabel.text ?? "")
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - SelectValueViewControllerDelagate

    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        if selectedAddModuleKeyAndLabelView?.tag == CONDITION_NAME_TAG {
            selectedCondition = conditionCommonData.getElement(at: selectedRow)
            if let selectedCondition {
                conditionNameView.valueLabel.text = selectedCondition.value
            }
            
        } else if selectedAddModuleKeyAndLabelView?.tag == STATUS_TAG {
            let selected = problemStatusOptions.getElement(at: selectedRow)
            statusView.valueLabel.text = selected
            updateResolvedDateVisibility(status: selected)
        }
    }

    // MARK: - Activity Indicator

    func showActivityIndicator() {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    // MARK: - CharmConnectionV2HandlerDelegate

    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "fetchCommonData" {
            if let commonData = response as? [DataWithId] {
                conditionCommonData = commonData
                conditionNames = commonData.map { $0.value }
            }
            isCommonDataFetched = true

            if let edit = editMedicalCondition {
                populateFieldsForEdit(edit)
            }
            else{
                statusView.valueLabel.text = problemStatusOptions.getElement(at: 0)
                onsetDatePicker.date = currentDate
                onsetDatePickerValueChanged(datePicker: onsetDatePicker)
            }

            hideActivityIndicator()
        } else if identificationKey == "addCondition" {
            hideActivityIndicator()
            if let msg = response as? String {
                delegate?.addViewControllerDataAdded(message: msg)
            }
            navigationController?.popViewController(animated: true)
        }
    }

    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "fetchCommonData" {
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.fetchCommonData()
            }, cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            CharmUtil.createOkayAlertWith(error: error)
        }
    }

    // MARK: - Edit Mode Population

    private func populateFieldsForEdit(_ condition: MedicalCondition) {
        
        conditionNameView.valueLabel.text = condition.name
        
        if !condition.status.isNilOrBlank() {
            statusView.valueLabel.text = condition.status
        }
        else{
            statusView.keyLabel.makeMandatory()
        }
        
        updateResolvedDateVisibility(status: condition.status)
        

        if let onsetDate = condition.dateOfOnset {
            onsetDatePicker.date = onsetDate
            onsetDatePickerValueChanged(datePicker: onsetDatePicker)
        }

        if let resolvedDate = condition.resolvedDate {
            resolvedDatePicker.date = resolvedDate
            resolvedDatePickerValueChanged(datePicker: resolvedDatePicker)
        }

        notesView.textView.text = condition.notes
    }
}
