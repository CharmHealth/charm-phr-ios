//
//  ReminderHistoryView.swift
//  phr
//
//  Created by prathi-13964 on 05/10/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit

fileprivate let reminderHistoryTimeViewLeftSpacing: CGFloat = 70
class ReminderHistoryView: UIView{
    
    private let activityIndicator = UIActivityIndicatorView()
    let noDataView = NoDataView()
    private let reminderDetailView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let scheduledLabel = UILabel()
    private let reminderHistoryDetailView = UIView()
    private let reminderScrollView = UIScrollView()
    private let reminderHistoryCardView = UIView()
    private let historyTimeView = UIStackView()
    let historyTableView = UITableView()
    private var timeObjToWidthMap: [Date: CGFloat] = [:]
    private var timeStringsWidth: CGFloat = 0
    private weak var delegate: ReminderHistoryViewController?
    private var reminderPOJO: ReminderPOJO?
    // Live layout state so the time columns / table follow width changes (iPhone Duo fold, rotation, side bar).
    private var timeArray: [ReminderHistoryTime] = []
    private var timeLabelWidthConstraints: [NSLayoutConstraint] = []
    private var tableHeightConstraint: NSLayoutConstraint?
    private var lastLayoutWidth: CGFloat = 0
    
    init(reminderPOJO: ReminderPOJO?, delegate: ReminderHistoryViewController?){
        super.init(frame: .zero)
        self.reminderPOJO = reminderPOJO
        self.delegate = delegate
        setSubviews()
    }
    
    private func setSubviews(){
        
        self.addSubview(activityIndicator)
        self.addSubview(noDataView)
        self.addSubview(reminderDetailView)
        reminderDetailView.addSubview(titleLabel)
        reminderDetailView.addSubview(descriptionLabel)
        reminderDetailView.addSubview(scheduledLabel)
        self.addSubview(reminderHistoryDetailView)
        reminderHistoryDetailView.addSubview(reminderScrollView)
        reminderScrollView.addSubview(reminderHistoryCardView)
        reminderHistoryCardView.addSubview(historyTimeView)
        reminderHistoryCardView.addSubview(historyTableView)
        
        addProperties()
        addConstraints()
    }
    
    private func addConstraints(){

        activityIndicator.setCenterY()
        activityIndicator.setCenterX()

        noDataView.setCenterY()
        noDataView.setCenterX()

        // Width comes from the edge pins and label heights from their intrinsic size, so the card
        // re-wraps whenever the available width changes.
        reminderDetailView.setTop(offSet: CARD_PADDING)
        reminderDetailView.setLeft(offSet: SPACING_12)
        reminderDetailView.setRight(offSet: -SPACING_12)

        titleLabel.setLeft(offSet: CARD_PADDING)
        titleLabel.setRight(offSet: -CARD_PADDING)
        titleLabel.setTop(offSet: TOP_SPACE_FROM_NAVIGATION)

        descriptionLabel.setLeft(offSet: CARD_PADDING)
        descriptionLabel.setRight(offSet: -CARD_PADDING)
        descriptionLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: titleLabel, relatedAttribute: .bottom)

        scheduledLabel.setLeft(offSet: CARD_PADDING)
        scheduledLabel.setRight(offSet: -CARD_PADDING)
        scheduledLabel.setTopRelatedToView(offSet: ITEM_VERTICAL_MARGIN, relatedView: descriptionLabel, relatedAttribute: .bottom)
        scheduledLabel.setBottom(offSet: -CARD_PADDING)

        reminderHistoryDetailView.setTopRelatedToView(offSet: CARD_PADDING, relatedView: reminderDetailView, relatedAttribute: .bottom)
        reminderHistoryDetailView.setLeft(offSet: SPACING_12)
        reminderHistoryDetailView.setRight(offSet: -SPACING_12)
        reminderHistoryDetailView.setBottom(offSet: -CARD_PADDING)

        reminderScrollView.setLeft(offSet: 0)
        reminderScrollView.setRight(offSet: 0)
        reminderScrollView.setTop(offSet: 0)
        reminderScrollView.setBottom(offSet: 0)

        reminderHistoryCardView.setLeft(offSet: 0)
        reminderHistoryCardView.setRight(offSet: 0)
        reminderHistoryCardView.setTop(offSet: 0)
        reminderHistoryCardView.setBottom(offSet: 0)
        
        historyTimeView.setLeft(offSet: reminderHistoryTimeViewLeftSpacing)
        historyTimeView.setRight(offSet: -(CARD_PADDING * 2))
        historyTimeView.setTop(offSet: CARD_PADDING)
        historyTimeView.setHeight(constant: BUTTON_HEIGHT_20)

        historyTableView.setTopRelatedToView(offSet: PADDING_3, relatedView: historyTimeView, relatedAttribute: .bottom)
        historyTableView.setLeft(offSet: 0)
        historyTableView.setRight(offSet: 0)
        historyTableView.setBottom(offSet: -PADDING_6)

        // Table wants its full content height but never grows past the visible card; it scrolls
        // internally beyond that. Replaces the old launch-time applicationFrame.height maths.
        let tableHeight = historyTableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeight.priority = .defaultHigh
        tableHeightConstraint = tableHeight
        NSLayoutConstraint.activate([
            tableHeight,
            reminderHistoryCardView.heightAnchor.constraint(lessThanOrEqualTo: reminderScrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    func setHistoryRowCount(_ count: Int, rowHeight: CGFloat){
        tableHeightConstraint?.constant = count > 0 ? (CGFloat(count) * rowHeight) + 3 : 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = reminderScrollView.bounds.width
        guard width > 0, width != lastLayoutWidth, !timeArray.isEmpty else { return }
        lastLayoutWidth = width
        updateTimeColumnWidths()
        // Status icons in each row are sized from the column widths, so rebuild the rows.
        historyTableView.reloadData()
    }

    /// Visible width of the history card; falls back to the host's safe-area width before first layout.
    private var availableCardWidth: CGFloat {
        if reminderScrollView.bounds.width > 0 { return reminderScrollView.bounds.width }
        let hostWidth = delegate?.view.safeAreaLayoutGuide.layoutFrame.width ?? 0
        return (hostWidth > 0 ? hostWidth : applicationFrame.width) - (SPACING_12 * 2)
    }

    private func updateTimeColumnWidths(){
        guard timeArray.count == timeLabelWidthConstraints.count, !timeArray.isEmpty else { return }
        let font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        let gaps = CGFloat(timeArray.count - 1) * X_SPACE
        let fixedSpacing = reminderHistoryTimeViewLeftSpacing + (CARD_PADDING * 2)
        let remainingWidth = availableCardWidth - fixedSpacing - gaps
        let fitsWidth = timeStringsWidth <= remainingWidth + gaps

        for (index, reminderHistoryTime) in timeArray.enumerated(){
            guard let timeObj = reminderHistoryTime.timeobj else { continue }
            let columnWidth: CGFloat
            if fitsWidth{
                // Columns share the visible width equally.
                columnWidth = remainingWidth / CGFloat(timeArray.count)
            }
            else{
                // Too many times to fit: natural widths, the card scrolls horizontally.
                let text = timeObj.getStringFromDate(dateFormat: charmDisplayTimeFormat)
                columnWidth = ceil(text.widthOfString(usingFont: font))
            }
            timeLabelWidthConstraints[index].constant = columnWidth
            delegate?.mapTimeViewAndWidth(timeObj: timeObj, width: columnWidth)
        }
    }
    
    private func addProperties(){

        activityIndicator.color = .gray

        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)

        historyTimeView.axis = .horizontal
        historyTimeView.alignment = .fill
        historyTimeView.spacing = X_SPACE
        
        if let reminderPOJO = reminderPOJO{
            titleLabel.setProperties(textKey: reminderPOJO.reminderDetails?.title ?? "", fontsize: FONT_SIZE_EXTRALARGE, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
            titleLabel.numberOfLines = 0

            descriptionLabel.setProperties(textKey: reminderPOJO.reminderDetails?.descripiton ?? "", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: questionnaireListStatusNotSubmittedTxtColor)
            descriptionLabel.numberOfLines = 0
        }
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: getString(key: "com.charmphr.reminder.all.item.schedule.title"), attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREY)])
        
        if let startDate = reminderPOJO?.reminderDetails?.reminder?.startDate{
            let startDateString = startDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            attributedText.append(NSMutableAttributedString(string: startDateString, attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)]))
        }
        if let endDate = reminderPOJO?.reminderDetails?.reminder?.endDate{
            attributedText.append(NSAttributedString(string: getString(key: "com.charmphr.reminder.all.item.to.title"), attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREY)]))
            let endDateString = endDate.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            attributedText.append(NSMutableAttributedString(string: endDateString, attributes: [.font: UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold), .foregroundColor: UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)]))
        }
        scheduledLabel.attributedText = attributedText
        scheduledLabel.numberOfLines = 0
        
        setViewBorderAndCornerRadius(uiView: reminderDetailView)
        setViewBorderAndCornerRadius(uiView: reminderHistoryDetailView)
    }
    
    func createTimeArr(){
        if let reminderObj = reminderPOJO?.reminderDetails?.reminder{
            var timeList: [ReminderHistoryTime] = []
            
            if let delegate = delegate{
                let dateString = Date().getStringFromDate(dateFormat: PHR_DATE_API_FORMAT)
                reminderObj.reminderFrequencyArray.forEach { reminderFrequency in
                    if !timeList.contains(where: { reminderHistoryTime in
                        reminderHistoryTime.timeString == reminderFrequency.time
                    }){
                        let reminderHistoryTime = ReminderHistoryTime()
                        reminderHistoryTime.timeString = reminderFrequency.time
                        timeList.append(reminderHistoryTime)
                    }
                    delegate.mapTimeAndReminderFrequency(timeObj: Date.getDateFromString(dateFormat: ReminderDateWithTimeFormat, dateString: "\(dateString) \(reminderFrequency.time ?? "")"), reminderFrequency: reminderFrequency, reminder: reminderObj)
                }
                ///Commented for now because api is not supported for inactive time which has history
//                delegate.reminderHistoryArray.forEach { reminderHistory in
//                    if let timeString = reminderHistory.reminderFrequency?.time{
//                        if !timeList.contains(where: { reminderHistoryTime in
//                            reminderHistoryTime.timeString == timeString
//                        }){
//                            let reminderHistoryTime = ReminderHistoryTime()
//                            reminderHistoryTime.isDeleted = true
//                            reminderHistoryTime.timeString = timeString
//                            timeList.append(reminderHistoryTime)
//                        }
//                    }
//                }
                
                timeList = timeList.sorted(by: { reminderHistoryTime1, reminderHistoryTime2 in
                    if let timeString1 = reminderHistoryTime1.timeString, let timeString2 = reminderHistoryTime2.timeString{
                        return timeString1 < timeString2
                    }
                    return false
                })
                
                delegate.addHistoryTime(timeStringArray: timeList)
                setTimeView(timeArray: delegate.timeArray)
                if let startDate = reminderObj.startDate{
                    delegate.formDateArray(fromDate: startDate, toDate: reminderObj.endDate ?? Date(), frequencyArray: reminderObj.reminderFrequencyArray)
                }
            }
            historyTableView.separatorColor = .clear
        }
    }

    private func setTimeView(timeArray: [ReminderHistoryTime]){

        timeStringsWidth = 0
        for i in 0 ..< timeArray.count{
            let reminderHistoryTime = timeArray[i]
            if let timeStringWidth = reminderHistoryTime.timeobj?.getStringFromDate(dateFormat: charmDisplayTimeFormat).widthOfString(usingFont: UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)){
                
                if i == timeArray.count - 1{
                    timeStringsWidth += timeStringWidth
                }
                else{
                    timeStringsWidth = timeStringsWidth + timeStringWidth + X_SPACE
                }
            }
        }

        if !timeArray.isEmpty && historyTimeView.subviews.isEmpty{
            self.timeArray = timeArray
            timeLabelWidthConstraints = []
            timeArray.forEach({ reminderHistoryTime in

                let timeLabel = UILabel()
                historyTimeView.addArrangedSubview(timeLabel)

                if let timeString = reminderHistoryTime.timeobj?.getStringFromDate(dateFormat: charmDisplayTimeFormat){
                    timeLabel.setProperties(textKey: timeString, fontsize: FONT_SIZE_MEDIUM, weight: .regular, fontcolor: TEXT_COLOR_DARK)
                    if reminderHistoryTime.isDeleted{
                        timeLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREY)
                    }
                }
                timeLabel.textAlignment = .center

                timeLabel.setTop(offSet: 0)
                timeLabel.setBottom(offSet: 0)

                // Constant is filled in by updateTimeColumnWidths() and refreshed on every width change.
                let widthConstraint = timeLabel.widthAnchor.constraint(equalToConstant: 0)
                widthConstraint.isActive = true
                timeLabelWidthConstraints.append(widthConstraint)
            })
            lastLayoutWidth = availableCardWidth
            updateTimeColumnWidths()
        }
    }
    
    private func setViewBorderAndCornerRadius(uiView: UIView){
        uiView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        uiView.addCornerRadius(.SMALL)
        uiView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SUPPORT_BORDER_COLOR).cgColor
        uiView.layer.borderWidth = DEFAULT_BORDER_WIDTH
    }
    
    func showActivityIndicator(){
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
        reminderDetailView.isHidden = true
        reminderHistoryDetailView.isHidden = true
        noDataView.isHidden = true
    }
    
    func hideActivityIndicator(){
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true
        reminderDetailView.isHidden = false
        reminderHistoryDetailView.isHidden = false
        noDataView.isHidden = true
    }
    
    func showErrorPage(error: Error){
        hideActivityIndicator()
        reminderDetailView.isHidden = true
        reminderHistoryDetailView.isHidden = true
        noDataView.isHidden = false
        noDataView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ReminderHistoryTime{
    var timeString: String?
    var timeobj: Date?
    var isDeleted: Bool = false
}
