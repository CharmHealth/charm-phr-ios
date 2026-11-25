//
//  MedConditionTableViewCell.swift
//  phr
//
//  Created by Raghul D on 21/04/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

import UIKit


// MARK: - Cell

class MedConditionTableViewCell: UITableViewCell {

    weak var delegate: MedConditionTableViewCellDelegate?
    let medConditionItemView = MedConditionItemView()
    private var medCondition: MedicalCondition? = nil
    private var indexPath: IndexPath? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(medConditionItemView)
        medConditionItemView.setHorizontal(offSet: X_SPACE)
        medConditionItemView.setTop(offSet: PADDING_5)
        medConditionItemView.setBottom(offSet: -PADDING_5)
    }

    func setTableViewCell(data: MedicalCondition, indexPath: IndexPath) {
        self.indexPath = indexPath
        medCondition = data
        medConditionItemView.setConditionValues(data: data)
        medConditionItemView.moreButton?.removeTarget(nil, action: nil, for: .touchUpInside)
        if !data.isViewOpened {
            medConditionItemView.moreButton?.addTarget(self, action: #selector(onClickMoreBtn), for: .touchUpInside)
        }
    }

    func setRowActionForSwipeLeft(duration: TimeInterval, isAddedByPatient: Bool) {
        medConditionItemView.setRowActionForSwipeLeft(duration: duration, isAddedByPatient: isAddedByPatient)
        medConditionItemView.deleteLabel?.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onClickDeleteBtn))
        )
    }

    @objc private func onClickDeleteBtn() {
        if let indexPath , let medCondition {
            delegate?.onDeleteBtnClicked(tableViewCell: self, condition: medCondition)
        }
    }

    @objc private func onClickMoreBtn() {
        medCondition?.isViewOpened = true
        if let indexPath {
            delegate?.onMoreBtnClicked(indexPath: indexPath)
        }
    }
}

protocol MedConditionTableViewCellDelegate: AnyObject {
    func onDeleteBtnClicked(tableViewCell: MedConditionTableViewCell, condition: MedicalCondition)
    func onMoreBtnClicked(indexPath: IndexPath)
}

// MARK: - Item View

class MedConditionItemView: UIView {

    private let verticalStackView = UIView()
    var deleteLabel: UILabel? = nil

    // Date row: "Start [date]"  /  "End [date]"
    private let startDateLabel = UILabel()
    private let endDateLabel = UILabel()

    // Name row: condition name + status badge
    private let conditionNameLabel = UILabel()
    private let severityLabel = UILabel()

    // Notes row: notes text + edit icon (lazy)
    private let notesLabel = UILabel()
    private var editIcon: UIImageView? = nil

    // More / fromView — lazy, created only when needed
    var moreButton: UIButton? = nil
    private var fromView: UIView? = nil
    private var horizontalLine: UIView? = nil
    private var fromLabel: UILabel? = nil
    private var facilityListLabel: UILabel? = nil

    private var deleteLabelConstraint: NSLayoutConstraint? = nil
    private var severityLabelWidthConstraint: NSLayoutConstraint? = nil
    private var severityLabelTopConstraint: NSLayoutConstraint? = nil
    private var sepatorHeightConstraint: NSLayoutConstraint? = nil
    private var nameTopConstraint: NSLayoutConstraint? = nil
    private var cardBottomConstraint: NSLayoutConstraint? = nil

    
    private var editIconTopConstraint: NSLayoutConstraint? = nil
    private var editIconBottomConstraint: NSLayoutConstraint? = nil
    private var fromViewTopConstraint: NSLayoutConstraint? = nil

    init() {
        super.init(frame: .zero)
        setSubViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setSubViews() {
        self.addSubview(verticalStackView)

        verticalStackView.addSubview(startDateLabel)
        verticalStackView.addSubview(endDateLabel)

        verticalStackView.addSubview(conditionNameLabel)
        verticalStackView.addSubview(severityLabel)
        
        verticalStackView.addSubview(notesLabel)

        addProperties()
        addConstraints()
        checkAndCreateDeleteLabel()
    }

    private func addConstraints() {
        verticalStackView.setLeft(offSet: CARD_PADDING)
        verticalStackView.setTop(offSet: CARD_PADDING)
        verticalStackView.setBottom(offSet: -CARD_PADDING)
        // Width comes from the card: stack right == deleteLabel left, deleteLabel right == card right
        // (see checkAndCreateDeleteLabel). Was a launch-time width, which left the card half empty when unfolded/rotated.

        // Date row — top=0, no bottom (height driven by single-line intrinsic content)
        startDateLabel.setLeft(offSet: 0)
        startDateLabel.setTop(offSet: 0)

        endDateLabel.setRight(offSet: -CARD_PADDING)
        endDateLabel.setTop(offSet: 0)

        // Name + Status — top managed dynamically via nameTopConstraint
        conditionNameLabel.setLeft(offSet: 0)
        conditionNameLabel.setRightRelatedToView(offSet: -CARD_PADDING, relatedView: severityLabel, relatedAttribute: .left)

        severityLabel.setRight(offSet: -CARD_PADDING)
        severityLabelTopConstraint = severityLabel.setAndReturnTopRelatedToView(offSet: 0, relatedView: conditionNameLabel, relatedAttribute: .top)
        severityLabelWidthConstraint = severityLabel.setAndReturnWidth(constant: 0)

        // Notes row — always below conditionNameLabel; bottom managed dynamically via cardBottomConstraint
        notesLabel.setLeft(offSet: 0)
        notesLabel.setTopRelatedToView(offSet: STACKVIEW_VERTICAL_PADDING, relatedView: conditionNameLabel, relatedAttribute: .bottom)
        notesLabel.setRight(offSet: -10)

        // Default state: no date, no notes
        setDateVisible(false)
        updateCardBottom()
    }

    private func addProperties() {
        self.addShadowAndCornerRadius(.SMALL)

        

        // Date labels
        setLabelProperties(uiLabel: startDateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold)
        startDateLabel.numberOfLines = 1

        setLabelProperties(uiLabel: endDateLabel, fontSize: FONT_SIZE_MEDIUM, fontWeight: .semibold)
        endDateLabel.textAlignment = .right
        endDateLabel.numberOfLines = 1

        // Condition name
        setLabelProperties(uiLabel: conditionNameLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)

        // Status badge
        setSeverityLabel(uiLabel: severityLabel)

        // Notes
        setLabelProperties(uiLabel: notesLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)

        // Initial visibility managed via constraints in addConstraints()
    }

    // MARK: - Dynamic constraint helpers

    private func setDateVisible(_ visible: Bool) {
        startDateLabel.isHidden = !visible
        nameTopConstraint?.isActive = false
        nameTopConstraint = visible
            ? conditionNameLabel.setAndReturnTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: startDateLabel, relatedAttribute: .bottom)
            : conditionNameLabel.setAndReturnTop(offSet: 0)
    }

    private func updateCardBottom() {
        cardBottomConstraint?.isActive = false
        if let fromView, !fromView.isHidden {
            cardBottomConstraint = fromView.setAndReturnBottom(offSet: 0)
        } else if let moreButton, !moreButton.isHidden {
            cardBottomConstraint = moreButton.setAndReturnBottom(offSet: 0)
        } else if !notesLabel.isHidden {
            cardBottomConstraint = notesLabel.setAndReturnBottom(offSet: 0)
        }
        else if let editIcon, !editIcon.isHidden {
            // editIconBottomConstraint handles card bottom in this case
        }
        else {
            cardBottomConstraint = conditionNameLabel.setAndReturnBottom(offSet: 0)
        }
    }

    // MARK: - Helper label styling

    private static let startDatePrefix = getString(key: "com.charmphr.MedicalCondition.startDate.label")
    private static let endDatePrefix   = getString(key: "com.charmphr.MedicalCondition.endDate.label")

    private func makeDateAttributedString(prefix: String, value: String) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: prefix,
            attributes: [
                .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT),
            .font: UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, weight: .regular)
            ]
        )
        result.append(NSAttributedString(
            string: value,
            attributes: [
                .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87),
                .font: UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, weight: .semibold)
            ]
        ))
        return result
    }

    private func setSeverityLabel(uiLabel: UILabel) {
        uiLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
        uiLabel.textAlignment = .center
    }

    private func setSeverityLabelProperties(uiLabel: UILabel, bgColor: UInt, textColor: UInt) {
        uiLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: bgColor)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: textColor)
        uiLabel.layer.cornerRadius = 2
        uiLabel.layer.masksToBounds = true
    }

    private func setLabelProperties(uiLabel: UILabel, fontSize: CGFloat, fontWeight: UIFont.FontWeight) {
        uiLabel.font = UIFont.systemFont(ofSize: fontSize, Weight: fontWeight)
        uiLabel.textAlignment = .left
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        uiLabel.numberOfLines = 0
        uiLabel.lineBreakMode = .byTruncatingTail
    }

    private func setSeverityAsActive() {
        setSeverityLabelProperties(uiLabel: severityLabel, bgColor: SEVERE_BG_COLOR, textColor: SEVERE_TEXT_COLOR)
    }

    private func setSeverityAsInactive() {
        setSeverityLabelProperties(uiLabel: severityLabel, bgColor: INACTIVE_BG_COLOR, textColor: INACTIVE_TEXT_COLOR)
    }

    private func setSeverityAsResolved() {
        setSeverityLabelProperties(uiLabel: severityLabel, bgColor: RESOLVED_BG_COLOR, textColor: RESOLVED_TEXT_COLOR)
    }

    private func checkAndCreateEditIcon() {
        guard editIcon == nil else { return }
        let icon = UIImageView(image: UIImage(named: "EditIconBlue"))
        verticalStackView.addSubview(icon)
        notesLabel.removeConstraint(attribute: .right)
        notesLabel.setRightRelatedToView(offSet: -10, relatedView: icon, relatedAttribute: .left)
        icon.setRight(offSet: -10)
        icon.setWidth(constant: 20)
        icon.setHeight(constant: 20)
        
        editIcon = icon
    }

    private func setEditIconVisible(_ val: Bool) {
        if val {
            checkAndCreateEditIcon()
            editIcon?.isHidden = false
        } else {
            editIcon?.isHidden = true
        }
    }

    // MARK: - Lazy creation

    private func checkAndCreateMoreButton() {
        guard moreButton == nil else { return }
        let btn = UIButton()
        btn.setProperties(
            titleStrKey: getString(key: "com.charmphr.Immunization.more.title"),
            fontsize: FONT_SIZE_NORMAL,
            weight: .regular,
            fontcolor: BLUE_BTN_COLOR
        )
        btn.contentHorizontalAlignment = .left
        verticalStackView.addSubview(btn)
        btn.setLeft(offSet: 0)
        btn.setRight(offSet: 0)
        btn.setTopRelatedToView(offSet: STACKVIEW_VERTICAL_PADDING, relatedView: notesLabel, relatedAttribute: .bottom)
        btn.setHeight(constant: ITEM_MORE_BUTTON_HEIGHT)
        moreButton = btn
    }

    private func checkAndCreateFromView() {
        guard fromView == nil else { return }

        let fView = UIView()
        let hLine = UIView()
        let fLabel = UILabel()
        let facilityLabel = UILabel()

        fView.addSubview(hLine)
        fView.addSubview(fLabel)
        fView.addSubview(facilityLabel)

        hLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR)
        hLine.setLeft(offSet: 0)
        hLine.setRight(offSet: -CARD_PADDING)
        hLine.setTop(offSet: PADDING_5)
        sepatorHeightConstraint = hLine.setAndReturnHeight(constant: 0)

        fLabel.text = getString(key: "com.charmphr.allergies.itemView.from.title")
        setLabelProperties(uiLabel: fLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .regular)
        fLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: hLine, relatedAttribute: .bottom)
        fLabel.setLeft(offSet: 0)
        fLabel.setRight(offSet: -CARD_PADDING)

        setLabelProperties(uiLabel: facilityLabel, fontSize: FONT_SIZE_NORMAL, fontWeight: .semibold)
        facilityLabel.setTopRelatedToView(offSet: PADDING_5, relatedView: fLabel, relatedAttribute: .bottom)
        facilityLabel.setLeft(offSet: 0)
        facilityLabel.setRight(offSet: -CARD_PADDING)
        facilityLabel.setBottom(offSet: 0)

        horizontalLine = hLine
        fromLabel = fLabel
        facilityListLabel = facilityLabel
        fromView = fView
        verticalStackView.addSubview(fView)
        fView.setHorizontal()
        // Top constraint set dynamically in setConditionValues via fromViewTopConstraint
    }

    // MARK: - Data Binding

    func setConditionValues(data: MedicalCondition) {

        // Date row
        if let onsetDate = data.dateOfOnset {
            startDateLabel.attributedText = makeDateAttributedString(
                prefix: MedConditionItemView.startDatePrefix,
                value: onsetDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            )
            setDateVisible(true)
        } else {
            setDateVisible(false)
        }

        if let resolvedDate = data.resolvedDate {
            endDateLabel.attributedText = makeDateAttributedString(
                prefix: MedConditionItemView.endDatePrefix,
                value: resolvedDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            )
            endDateLabel.isHidden = false
        } else {
            endDateLabel.isHidden = true
        }

        // Condition name
        conditionNameLabel.text = data.name

        // Status badge
        let status = data.status ?? ""
        severityLabel.text = status
        severityLabelWidthConstraint?.constant = severityLabel.intrinsicContentSize.width + 10

        switch status {
        case "Active":
            setSeverityAsActive()
        case "Resolved":
            setSeverityAsResolved()
        default:
            setSeverityAsInactive()
        }

        // Notes + edit icon
        setEditIconVisible(data.allowEdit)

        let hasNotes = !(data.notes.isNilOrBlank())
        notesLabel.text = hasNotes ? data.notes : nil
        notesLabel.isHidden = !hasNotes

        // More btn / fromView — only created for EHR-sourced conditions
        if data.allowEdit {
            moreButton?.isHidden = true
            fromView?.isHidden = true
            
            if let editIconTopConstraint {
                verticalStackView.removeConstraint(editIconTopConstraint)
            }
            
            if let editIconBottomConstraint {
                verticalStackView.removeConstraint(editIconBottomConstraint)
            }
            
            editIconTopConstraint = nil
            editIconBottomConstraint = nil
            
            if let editIcon  {
                
                if hasNotes {
                    editIconTopConstraint = editIcon.setAndReturnCenterYWithOffset(view: notesLabel)
                }
                else {
                    editIconBottomConstraint = editIcon.setAndReturnBottom(offSet: 0)
                    
                    if !severityLabel.isHidden {
                        editIconTopConstraint = editIcon.setAndReturnTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: severityLabel, relatedAttribute: .bottom)
                    }
                }
            }
        } else {
            
            //checkAndCreateMoreButton()
            checkAndCreateFromView()
            if data.isViewOpened {
                moreButton?.isHidden = true
                fromView?.isHidden = false
                sepatorHeightConstraint?.constant = LINE_HEIGHT
                let practice = Patient.selectedPatientInstance?.getPracticeWith(practiceId: data.practiceId ?? "")
                facilityListLabel?.text = practice?.practiceName

                if let fromView {
                    fromViewTopConstraint?.isActive = false
                    let anchor: UIView = hasNotes ? notesLabel : (editIcon?.isHidden == false ? editIcon! :  conditionNameLabel)
                    fromViewTopConstraint = fromView.setAndReturnTopRelatedToView(
                        offSet: STACKVIEW_VERTICAL_PADDING,
                        relatedView: anchor,
                        relatedAttribute: .bottom
                    )
                }
            } else {
                moreButton?.isHidden = false
                fromView?.isHidden = true
                sepatorHeightConstraint?.constant = 0
            }
            
            
            if let editIconTopConstraint {
                verticalStackView.removeConstraint(editIconTopConstraint)
            }

            if let editIconBottomConstraint {
                verticalStackView.removeConstraint(editIconBottomConstraint)
            }

            editIconTopConstraint = nil
            editIconBottomConstraint = nil
        }

        updateCardBottom()
    }

    // MARK: - Swipe actions

    func setRowActionForSwipeLeft(duration: TimeInterval, isAddedByPatient: Bool) {
        if isAddedByPatient {
            checkAndCreateDeleteLabel()
            UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
                deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
                self.layoutIfNeeded()
            })
        }
    }

    func setRowActionForSwipeRight(duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            deleteLabelConstraint?.constant = 0
            self.layoutIfNeeded()
        })
    }

    private func checkAndCreateDeleteLabel() {
        if deleteLabel == nil {
            deleteLabel = UILabel()
            if let deleteLabel {
                self.addSubview(deleteLabel)
                deleteLabel.text = getString(key: "com.charmphr.action.delete")
                deleteLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
                deleteLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
                deleteLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
                deleteLabel.textAlignment = .center
                deleteLabel.addCornerRadius(.SMALL)
                deleteLabel.isUserInteractionEnabled = true
                deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]

                deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: verticalStackView, relatedAttribute: .right)
                deleteLabel.setRight(offSet: 0)
                deleteLabel.setTop(offSet: 0)
                deleteLabel.setBottom(offSet: 0)
                deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
            }
        } else {
            deleteLabelConstraint?.constant = 0
        }
    }
}
