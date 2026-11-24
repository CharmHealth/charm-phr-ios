//
//  AppointmentsTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 03/12/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol AppointmentListViewDelegate: AnyObject{
    func mapBtnViewToAppointment(joinBtn: UIButton, questionnaireBtn: UIButton, appointment: Appointment)
}

class AppointmentsTableViewCell: UITableViewCell{
    
    let appointmentListView = AppointmentListView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(appointmentListView)
    }
    
    func setPastAppointmentTableViewCell(appointment: Appointment){
        
        appointmentListView.setHorizontal(offSet: X_SPACE)
        appointmentListView.setTop(offSet: 4)
        appointmentListView.setBottom(offSet: -4)
        
        appointmentListView.providerName.text = appointment.member?.formMemberName()
        appointmentListView.setProviderPhoto(image: appointment.member?.photo)
        
        if !(appointment.visitTypeDetail?.visitType.isNilOrBlank() ?? true){
            appointmentListView.visitTypeOrSpecializationName.text = appointment.visitTypeDetail?.visitType
        }
        else{
            if !appointment.specialization.isNilOrBlank(){
                appointmentListView.visitTypeOrSpecializationName.text = appointment.specialization
            }
            else{
                appointmentListView.visitTypeOrSpecializationName.text = " "
            }
        }
        
        if appointment.isQuestionnairePresent{
            appointmentListView.fillQuestionnaireView(questionnaireCount: appointment.questionnaireCount, questionnaireText: "Questionnaire")
        }
        else{
            appointmentListView.questionnaireView.isHidden = true
            appointmentListView.rebookBtn.removeConstraint(attribute: .centerY)
            appointmentListView.rebookBtn.setTop(offSet: 0)
            appointmentListView.rebookBtn.setBottom(offSet: 0)
        }
        
        let practiceId = appointment.practiceId
        let practice = getActivePractice().first(where: {practice in
            return practice.practiceId == practiceId
        })
        
        if practice?.easycareURL.isNilOrBlank() ?? true {
            appointmentListView.rebookBtn.isHidden = false
        }
        else{
            appointmentListView.rebookBtn.isHidden = true
        }
        
        appointmentListView.setDateLabelValue(date: appointment.appointmentDeviceStartTime)
        appointmentListView.setTimeLabelValue(timeString: appointment.appointmentDeviceStartTime?.getStringFromDate(dateFormat: "hh:mm a"), timeZone: TimeZone.current.identifier)
        appointmentListView.setAppointmentTypeLable(appointment: appointment)
    }
    
    func setTableViewCell(appointment: Appointment, segmentIndex: Int? = nil, delegate: AppointmentListViewDelegate, isLast: Bool = false){
        if segmentIndex != nil{
            appointmentListView.setLeft(offSet: 0)
            appointmentListView.setRight(offSet: 0)
            appointmentListView.setTop(offSet: 4)
            appointmentListView.setBottom(offSet: -4)
        }
        else{
            appointmentListView.setLeft(offSet: 0)
            appointmentListView.setRight(offSet: 0)
            appointmentListView.setTop(offSet: 0)
            appointmentListView.setBottom(offSet: 0)
        }
        appointmentListView.rebookBtn.isHidden = true
        appointmentListView.setAppointmentItemValues(appointment: appointment, segmentIndex: segmentIndex, delegate: delegate, isLast: isLast)
    }
}

class AppointmentListView: UIView{
    
    let deleteLabel = UILabel()
    let verticalStackView = UIStackView()
    let providerDetailView = UIView()
    let imageContainerView = UIView()
    let initialLabel = UILabel()
    var personImage = UIImageView()
    let providerAndFacilityNameView = UIView()
    let providerName = UILabel()
    let visitTypeOrSpecializationName = UILabel()
    let joinBtn = UIButton()
    let appointmentTypeView = UIView()
    let appointmentTypeIcon = UIImageView()
    let appointmentTypeLabel = UILabel()
    let questionnaireAndRebookView = UIView()
    let questionnaireView = UIView()
    let questionnaireBtn = UIButton()
    let questionnaireCountView = UIView()
    let questionnaireCountLabel = UILabel()
    let rebookBtn = UIButton()
    let reasonView = UIView()
    let reasonLabel = UILabel()
    let reasonValueLabel = UILabel()
    let instructionView = UIView()
    let instructionLabel = UILabel()
    let instructionValueLabel = UILabel()
    let dateAndTimeViewContainerView = UIView()
    let dateAndTimeViewVerticalStackView = UIStackView()
    let dateAndTimeView = UIStackView()
    let dateView = UIView()
    let dateIcon = UIImageView(image: UIImage(named: "Appointment_Calender"))
    let dateLabel = UILabel()
    let timeView = UIView()
    let timeIcon = UIImageView(image: UIImage(named: "Appointment_Time"))
    let timeLabel = UILabel()
    let dateAndTimeViewRenew = UIStackView()
    let dateViewRenew = UIView()
    let dateIconRenew = UIImageView(image: UIImage(named: "Appointment_Calender"))
    let dateLabelRenew = UILabel()
    let dayLabelRenew = UILabel()
    let timeViewRenew = UIView()
    let timeIconRenew = UIImageView(image: UIImage(named: "Appointment_Time"))
    let timeLabelRenew = UILabel()
    let timeZoneLabelRenew = UILabel()
    let separatorLineContainerView = UIView()
    let separatorLine = UIView()
    
    var deleteLabelConstraint: NSLayoutConstraint? = nil
    private let questionnaireCountViewSize: CGFloat = 16
    private let joinBtnHeight: CGFloat = 36
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }

    private func setSubViews(){
        
        self.addSubview(deleteLabel)
        self.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(providerDetailView)
        providerDetailView.addSubview(imageContainerView)
        imageContainerView.addSubview(initialLabel)
        imageContainerView.addSubview(personImage)
        providerDetailView.addSubview(providerAndFacilityNameView)
        providerAndFacilityNameView.addSubview(providerName)
        providerAndFacilityNameView.addSubview(visitTypeOrSpecializationName)
        providerDetailView.addSubview(joinBtn)
        providerDetailView.addSubview(appointmentTypeView)
        appointmentTypeView.addSubview(appointmentTypeIcon)
        appointmentTypeView.addSubview(appointmentTypeLabel)
        verticalStackView.addArrangedSubview(questionnaireAndRebookView)
        questionnaireAndRebookView.addSubview(questionnaireView)
        questionnaireView.addSubview(questionnaireBtn)
        questionnaireView.addSubview(questionnaireCountView)
        questionnaireCountView.addSubview(questionnaireCountLabel)
        questionnaireAndRebookView.addSubview(rebookBtn)
        verticalStackView.addArrangedSubview(reasonView)
        reasonView.addSubview(reasonLabel)
        reasonView.addSubview(reasonValueLabel)
        verticalStackView.addArrangedSubview(instructionView)
        instructionView.addSubview(instructionLabel)
        instructionView.addSubview(instructionValueLabel)
        verticalStackView.addArrangedSubview(dateAndTimeViewContainerView)
        dateAndTimeViewContainerView.addSubview(dateAndTimeViewVerticalStackView)
        dateAndTimeViewVerticalStackView.addArrangedSubview(dateAndTimeView)
        dateAndTimeView.addArrangedSubview(dateView)
        dateView.addSubview(dateIcon)
        dateView.addSubview(dateLabel)
        dateAndTimeView.addArrangedSubview(timeView)
        timeView.addSubview(timeIcon)
        timeView.addSubview(timeLabel)
        dateAndTimeViewVerticalStackView.addArrangedSubview(dateAndTimeViewRenew)
        dateAndTimeViewRenew.addArrangedSubview(dateViewRenew)
        dateViewRenew.addSubview(dateIconRenew)
        dateViewRenew.addSubview(dateLabelRenew)
        dateViewRenew.addSubview(dayLabelRenew)
        dateAndTimeViewRenew.addArrangedSubview(timeViewRenew)
        timeViewRenew.addSubview(timeIconRenew)
        timeViewRenew.addSubview(timeLabelRenew)
        timeViewRenew.addSubview(timeZoneLabelRenew)
        verticalStackView.addArrangedSubview(separatorLineContainerView)
        separatorLineContainerView.addSubview(separatorLine)
        
        setProperties()
        setConstraints()
    }
    
    private func setConstraints(){
        
        verticalStackView.setLeft(offSet: 12)
        verticalStackView.setTop(offSet: 0)
        verticalStackView.setBottom(offSet: -12)
        
        deleteLabel.setLeftRelatedToView(offSet: 0, relatedView: verticalStackView, relatedAttribute: .right)
        deleteLabel.setRight(offSet: 0)
        deleteLabel.setTop(offSet: 0)
        deleteLabel.setBottom(offSet: 0)
        deleteLabelConstraint = deleteLabel.setAndReturnWidth(constant: 0)
        
        imageContainerView.setLeft(offSet: 0)
        imageContainerView.setTop(offSet: 11)
        imageContainerView.setHeight(constant: 42)
        imageContainerView.setWidth(constant: 42)
        
        initialLabel.setCenterY()
        initialLabel.setCenterX()
        
        personImage.setCenterY()
        personImage.setCenterX()
        personImage.setHeight(constant: 42)
        personImage.setWidth(constant: 42)
        
        providerAndFacilityNameView.setLeftRelatedToView(offSet: 12, relatedView: imageContainerView, relatedAttribute: .right)
        providerAndFacilityNameView.setTop(offSet: 10)
        providerAndFacilityNameView.setBottom(offSet: 0)
        
        providerName.setLeft(offSet: 0)
        providerName.setRight(offSet: 0)
        providerName.setTop(offSet: 0)
        
        visitTypeOrSpecializationName.setLeft(offSet: 0)
        visitTypeOrSpecializationName.setRight(offSet: 0)
        visitTypeOrSpecializationName.setTopRelatedToView(offSet: 2, relatedView: providerName, relatedAttribute: .bottom)
        visitTypeOrSpecializationName.setBottom(offSet: 0)
        
        joinBtn.setRight(offSet: -12)
        joinBtn.setCenterY(view: imageContainerView)
        joinBtn.setWidth(constant: 79)
        joinBtn.setHeight(constant: joinBtnHeight)
        
        appointmentTypeView.setRight(offSet: -12)
        appointmentTypeView.setCenterY(view: imageContainerView)
        
        appointmentTypeIcon.setLeft(offSet: 0)
        appointmentTypeIcon.setRightRelatedToView(offSet: -4, relatedView: appointmentTypeLabel, relatedAttribute: .left)
        appointmentTypeIcon.setCenterY()
        
        appointmentTypeLabel.setRight(offSet: 0)
        appointmentTypeLabel.setCenterY(view: appointmentTypeIcon)
        
        questionnaireView.setLeft(offSet: 0)
        questionnaireView.setTop(offSet: 0)
        questionnaireView.setBottom(offSet: 0)
        
        questionnaireBtn.setLeft(offSet: 0)
        questionnaireBtn.setTop(offSet: 0)
        questionnaireBtn.setBottom(offSet: 0)
        questionnaireBtn.setHeight(constant: 20)
        
        questionnaireCountView.setLeftRelatedToView(offSet: 4, relatedView: questionnaireBtn, relatedAttribute: .right)
        questionnaireCountView.setRight(offSet: 0)
        questionnaireCountView.setTopRelatedToView(offSet: 2, relatedView: questionnaireBtn, relatedAttribute: .top)
        questionnaireCountView.setWidth(constant: questionnaireCountViewSize)
        questionnaireCountView.setHeight(constant: questionnaireCountViewSize)
        
        questionnaireCountLabel.setCenterX()
        questionnaireCountLabel.setTop(offSet: 0.5)
        
        rebookBtn.setRight(offSet: -12)
        rebookBtn.wrapWidth(maxWidth: 200)
        rebookBtn.setHeight(constant: 20)
        
        reasonLabel.setLeft(offSet: 0)
        reasonLabel.setTop(offSet: 0)
        reasonLabel.wrapWidth(maxWidth: 200)
        
        reasonValueLabel.setLeftRelatedToView(offSet: 8, relatedView: reasonLabel, relatedAttribute: .right)
        reasonValueLabel.setRight(offSet: -12)
        reasonValueLabel.setTop(offSet: 0)
        reasonValueLabel.setBottom(offSet: 0)

        instructionLabel.setLeft(offSet: 0)
        instructionLabel.setTop(offSet: 0)
        instructionLabel.wrapWidth(maxWidth: 200)

        instructionValueLabel.setLeftRelatedToView(offSet: 8, relatedView: instructionLabel, relatedAttribute: .right)
        instructionValueLabel.setRight(offSet: -12)
        instructionValueLabel.setTop(offSet: 0)
        instructionValueLabel.setBottom(offSet: 0)

        dateAndTimeViewVerticalStackView.setLeft(offSet: 0)
        dateAndTimeViewVerticalStackView.setRight(offSet: -12)
        dateAndTimeViewVerticalStackView.setTop(offSet: 0)
        dateAndTimeViewVerticalStackView.setBottom(offSet: 0)
        
        dateAndTimeView.setHeight(constant: 44)
        
        dateIcon.setLeft(offSet: 12)
        dateIcon.setCenterY()
        dateIcon.setWidth(constant: 20)
        dateIcon.setHeight(constant: 20)
        
        dateLabel.setLeftRelatedToView(offSet: 4, relatedView: dateIcon, relatedAttribute: .right)
        dateLabel.setRight(offSet: 0)
        dateLabel.setCenterY(view: dateIcon)
        
        timeIcon.setLeft(offSet: 12)
        timeIcon.setRightRelatedToView(offSet: -4, relatedView: timeLabel, relatedAttribute: .left)
        timeIcon.setCenterY()
        timeIcon.setWidth(constant: 20)
        timeIcon.setHeight(constant: 20)
        
        timeLabel.setRight(offSet: -12)
        timeLabel.setCenterY(view: timeIcon)
        
        dateIconRenew.setLeft(offSet: 12)
        dateIconRenew.setTop(offSet: 12)
        dateIconRenew.setWidth(constant: 20)
        dateIconRenew.setHeight(constant: 20)
        
        dateLabelRenew.setLeftRelatedToView(offSet: 4, relatedView: dateIconRenew, relatedAttribute: .right)
        dateLabelRenew.setRight(offSet: -4)
        dateLabelRenew.setTop(offSet: 12)
        
        dayLabelRenew.setLeftRelatedToView(offSet: 4, relatedView: dateIconRenew, relatedAttribute: .right)
        dayLabelRenew.setRight(offSet: -4)
        dayLabelRenew.setTopRelatedToView(offSet: 2, relatedView: dateLabelRenew, relatedAttribute: .bottom)
        dayLabelRenew.setBottom(offSet: -12)
        
        timeIconRenew.setRightRelatedToView(offSet: -4, relatedView: timeLabelRenew, relatedAttribute: .left)
        timeIconRenew.setLeft(offSet: 0)
        timeIconRenew.setTop(offSet: 12)
        timeIconRenew.setWidth(constant: 20)
        timeIconRenew.setHeight(constant: 20)
        
        timeLabelRenew.setRight(offSet: -12)
        timeLabelRenew.setTop(offSet: 12)
        
        //        timeZoneLabelRenew.setLeft(offSet: 0)
        timeZoneLabelRenew.setRight(offSet: -12)
        timeZoneLabelRenew.setTopRelatedToView(offSet: 2, relatedView: timeLabelRenew, relatedAttribute: .bottom)
        timeZoneLabelRenew.setBottom(offSet: -12)
        
        separatorLine.setLeft(offSet: 0)
        separatorLine.setRight(offSet: -12)
        separatorLine.setTop(offSet: 0)
        separatorLine.setBottom(offSet: -5)
        separatorLine.setHeight(constant: 1)
    }
    
    private func setProperties(){
        
        self.backgroundColor = .white
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 12
        verticalStackView.alignment = .fill
        
        dateAndTimeViewVerticalStackView.axis = .vertical
        dateAndTimeViewVerticalStackView.spacing = 0
        dateAndTimeViewVerticalStackView.alignment = .fill
        
        dateAndTimeView.axis = .horizontal
        dateAndTimeView.spacing = 4
        dateAndTimeView.alignment = .fill
        
        dateAndTimeViewRenew.axis = .horizontal
        dateAndTimeViewRenew.spacing = 4
        dateAndTimeViewRenew.alignment = .fill
        
        imageContainerView.layer.cornerRadius = 12
        imageContainerView.layer.masksToBounds = true
        imageContainerView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xF3F5FAFF )
        
        personImage.layer.cornerRadius = 12
        
        initialLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x7399E3FF)
        initialLabel.font = UIFont.systemFont(ofSize: 16, Weight: .semibold)
        initialLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xF3F5FAFF)
        
        providerName.setProperties(textKey: "", fontsize: 14, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        visitTypeOrSpecializationName.setProperties(textKey: "", fontsize: 13, weight: .regular, fontcolor: TEXT_COLOR_HEAVYDARK)
        
        joinBtn.addPillCornerRadiusAndShadow(height: joinBtnHeight)
        joinBtn.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR)
        joinBtn.setImage(UIImage(named: "Appointment_Video"), for: .normal)
        joinBtn.setProperties(titleStrKey: "Join", fontsize: 15, weight: .semibold, fontcolor: TEXT_COLOR_WHITE)
        
        joinBtn.imageView?.contentMode = .scaleAspectFit
        joinBtn.contentHorizontalAlignment = .fill
        joinBtn.contentVerticalAlignment = .fill
        joinBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 2, right: 0)
        joinBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: -5, bottom: 3, right: 0)
        
        joinBtn.clipsToBounds = true
        
        appointmentTypeLabel.setProperties(textKey: "", fontsize: 13, weight: .regular, fontcolor: 0x262626DB)
        
        questionnaireCountView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: BLUE_BTN_COLOR)
        questionnaireCountView.layer.cornerRadius = questionnaireCountViewSize / 2
        questionnaireCountLabel.setProperties(textKey: "", fontsize: 11, weight: .semibold, fontcolor: TEXT_COLOR_WHITE)
        questionnaireCountLabel.textAlignment = .center
        
        rebookBtn.setProperties(titleStrKey: "com.charmphr.appointment.list.rebook.title", fontsize: 14, weight: .semibold, fontcolor: 0x4074D9FF)
        
        reasonLabel.setProperties(textKey: "com.charmphr.appointment.list.reason.title", fontsize: 15, weight: .regular, fontcolor: 0x555555FF)
        reasonValueLabel.setProperties(textKey: "", fontsize: 15, weight: .regular, fontcolor: 0x000607FF)
        reasonValueLabel.numberOfLines = 0

        instructionLabel.setProperties(textKey: "com.charmphr.appointment.list.instruction.title", fontsize: 15, weight: .regular, fontcolor: 0x555555FF)
        instructionValueLabel.setProperties(textKey: "", fontsize: 15, weight: .regular, fontcolor: 0x000607FF)
        instructionValueLabel.numberOfLines = 0
        
        dateAndTimeViewVerticalStackView.layer.cornerRadius = CardSize.MEDIUM.value
        setDateTimeViewBorder()
        
        dateLabel.setProperties(textKey: "", fontsize: 14, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        timeLabel.setProperties(textKey: "", fontsize: 14, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        timeLabel.numberOfLines = 1
        
        dateLabelRenew.setProperties(textKey: "", fontsize: 14, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        dayLabelRenew.setProperties(textKey: "", fontsize: 12, weight: .regular, fontcolor: TEXT_COLOR_HEAVYDARK)
        timeLabelRenew.setProperties(textKey: "", fontsize: 14, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        timeZoneLabelRenew.setProperties(textKey: "", fontsize: 12, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        timeZoneLabelRenew.textAlignment = .right
        
        dateLabelRenew.setProperties(textKey: "", fontsize: 14, weight: .semibold, fontcolor: TEXT_COLOR_HEAVYDARK)
        dayLabelRenew.setProperties(textKey: "", fontsize: 12, weight: .regular, fontcolor: TEXT_COLOR_HEAVYDARK)
        timeLabelRenew.setProperties(textKey: "", fontsize: 14, weight: .semibold, fontcolor: TEXT_COLOR_BLACK87)
        timeZoneLabelRenew.setProperties(textKey: "", fontsize: 12, weight: .regular, fontcolor: TEXT_COLOR_BLACK87)
        timeZoneLabelRenew.textAlignment = .right
        
        separatorLine.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xE3E3E3FF)
        
        deleteLabel.text = getString(key: "com.charmphr.action.delete")
        deleteLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        deleteLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_WHITE)
        deleteLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DELETE_SWIPE_BG_COLOR)
        deleteLabel.textAlignment = .center
        deleteLabel.addCornerRadius(.SMALL)
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        appointmentTypeView.isHidden = true
        joinBtn.isHidden = true
        reasonView.isHidden = true
        instructionView.isHidden = true
        separatorLineContainerView.isHidden = true
        dateAndTimeView.isHidden = true
        dateAndTimeViewRenew.isHidden = true
    }
    
    func setTimeLabelValue(timeString: String?, timeZone: String? = nil){
        
        timeView.isHidden = false
        timeLabel.removeConstraint(attribute: .width)
        if let timeZone = timeZone{
            
            guard let timeString else { return }
            
            let attributeString = NSMutableAttributedString(string: "\(timeString) ", attributes: [.font: UIFont.systemFont(ofSize: 14, Weight: .semibold)])
            attributeString.append(NSMutableAttributedString(string: timeZone, attributes: [.font: UIFont.systemFont(ofSize: 14, Weight: .regular)]))
            
            
            if dateView.isHidden{
                
                timeLabel.attributedText = attributeString
                
                timeView.isHidden = false
                dateAndTimeView.isHidden = false
                dateAndTimeViewRenew.isHidden = true
                
                timeLabel.removeConstraint(attribute: .width)
                //                timeLabel.wrapWidth(maxWidth: applicationFrame.width - (2 * X_SPACE) - (12 * 4) - 20 - 4)
                
            }
            else{
                timeView.isHidden = true
                dateAndTimeView.isHidden = true
                dateAndTimeViewRenew.isHidden = false
                timeLabelRenew.text = timeString
                timeZoneLabelRenew.text = timeZone
                timeLabelRenew.removeConstraint(attribute: .width)
                timeLabelRenew.wrapWidth(maxWidth: 300)
                timeZoneLabelRenew.removeConstraint(attribute: .width)
                timeZoneLabelRenew.wrapWidth(maxWidth: 300)
            }
        }
        else{
            if dateLabel.text == Any_Date{
                timeLabel.text = timeString
                timeZoneLabelRenew.text = " "
                timeLabel.removeConstraint(attribute: .width)
                timeLabel.wrapWidth(maxWidth: 400)
                dateAndTimeView.isHidden = false
                dateAndTimeViewRenew.isHidden = true
            }
            else{
                timeLabelRenew.text = timeString
                timeZoneLabelRenew.text = " "
                timeLabelRenew.removeConstraint(attribute: .width)
                timeLabelRenew.wrapWidth(maxWidth: 400)
                dateAndTimeView.isHidden = true
                dateAndTimeViewRenew.isHidden = false
            }
        }
        if !dateAndTimeView.isHidden{
            dateView.setRightRelatedToView(offSet: -4, relatedView: timeView, relatedAttribute: .left)
        }
        else{
            dateViewRenew.setRightRelatedToView(offSet: -4, relatedView: timeViewRenew, relatedAttribute: .left)
        }
    }
    
    func setDateLabelValue(date: Date? = nil, dateString: String? = nil, checkToday: Bool = false, isFromDashboard: Bool = false){
        
        if let date = date{
            if checkToday{
                let calender = Calendar(identifier: .gregorian)
                if calender.isDateInToday(date){
                    if isFromDashboard{
                        dateView.isHidden = true
                    }
                    else{
                        dateLabel.text = CharmUtil.getDisplayDateStringAndToday(date: date)
                        dateLabelRenew.text = CharmUtil.getDisplayDateStringAndToday(date: date)
                        dayLabelRenew.text = " "
                    }
                }
                else{
                    dateView.isHidden = false
                    dateLabel.text = CharmUtil.getDisplayDateStringWithDay(date: date)
                    dateLabelRenew.text = CharmUtil.getDisplayDateString(date: date, skipCurrentYear: true)
                    dayLabelRenew.text = date.getStringFromDate(dateFormat: "EEEE")
                }
            }
            else{
                dateView.isHidden = false
                dateLabel.text = CharmUtil.getDisplayDateStringWithDay(date: date)
                dateLabelRenew.text = CharmUtil.getDisplayDateString(date: date, skipCurrentYear: true)
                dayLabelRenew.text = date.getStringFromDate(dateFormat: "EEEE")
            }
        }
        else if let dateString = dateString{
            dateLabel.text = dateString
            dateLabelRenew.text = dateString
            dayLabelRenew.text = " "
        }
    }
    
    func setProviderPhoto(image: UIImage?){
        
        if let image = image{
            personImage.image = image
        }
        else{
            personImage.image = UIImage(named: "ProviderProfile")
            //            initialLabel.text = provider?.formInitials()
        }
    }
    
    func setDateTimeViewBorder(){
        dateAndTimeViewVerticalStackView.layer.borderWidth = BORDER_WIDTH
        dateAndTimeViewVerticalStackView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: 0x7B729629).cgColor
        dateAndTimeViewVerticalStackView.backgroundColor = .white
    }
    
    func removeDateTimeViewBorder(){
        dateAndTimeViewVerticalStackView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0x335DAE0F)
        dateAndTimeViewVerticalStackView.layer.borderWidth = 0
    }
    
    func setRowActionForSwipeLeft(duration: TimeInterval){
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            deleteLabelConstraint?.constant = SWIPE_LABEL_HEIGHT_CONSTRAINT
            self.layoutIfNeeded()
        })
    }
    
    func setRowActionForSwipeRight(duration: TimeInterval){
        UIView.animate(withDuration: duration, delay: 0, animations: { [self] in
            deleteLabelConstraint?.constant = 0
            self.layoutIfNeeded()
        })
    }
    
    func setAppointmentTypeLable(appointment: Appointment){
        
        joinBtn.isHidden = true
        appointmentTypeView.isHidden = false
        appointmentTypeIcon.removeConstraint(attribute: .width)
        appointmentTypeIcon.removeConstraint(attribute: .height)
        appointmentTypeLabel.removeConstraint(attribute: .width)
        
        if appointment.appointmentType == appointmentTypeVideoCall{
            appointmentTypeIcon.image = UIImage(named: "AppointmentType_Video")
            appointmentTypeLabel.text = "Video Consult"
            
            appointmentTypeIcon.setHeight(constant: 24)
            appointmentTypeIcon.setWidth(constant: 24)
            appointmentTypeLabel.wrapWidth(maxWidth: 400)
        }
        else if appointment.appointmentType == appointmentTypePhoneCall{
            appointmentTypeIcon.image = UIImage(named: "AppointmentType_Call")
            appointmentTypeLabel.text = "Voice Call"
            
            appointmentTypeIcon.setHeight(constant: 24)
            appointmentTypeIcon.setWidth(constant: 24)
            appointmentTypeLabel.wrapWidth(maxWidth: 400)
        }
        else if appointment.appointmentType == appointmentTypeInPerson{
            appointmentTypeIcon.image = UIImage(named: "AppointmentType_InPerson")
            appointmentTypeLabel.text = "In Person"
            
            appointmentTypeIcon.setHeight(constant: 24)
            appointmentTypeIcon.setWidth(constant: 24)
            appointmentTypeLabel.wrapWidth(maxWidth: 400)
        }
        else{
            appointmentTypeView.isHidden = true
        }
        providerAndFacilityNameView.setRightRelatedToView(offSet: -5, relatedView: appointmentTypeView, relatedAttribute: .left)
    }
    
    func fillQuestionnaireView(questionnaireCount: Int, questionnaireText: String){
        questionnaireView.isHidden = false
        questionnaireAndRebookView.isHidden = false
        questionnaireBtn.setProperties(titleStrKey: questionnaireText, fontsize: 14, weight: .regular, fontcolor: BLUE_BTN_COLOR)
        questionnaireBtn.removeConstraint(attribute: .width)
        questionnaireBtn.wrapWidth(maxWidth: 400)
        
        if questionnaireCount > 9{
            questionnaireCountLabel.text = "9+"
            questionnaireCountLabel.font = UIFont.systemFont(ofSize: 10, Weight: .semibold)
        }
        else{
            questionnaireCountLabel.text = "\(questionnaireCount)"
        }
        questionnaireCountLabel.removeConstraint(attribute: .width)
        questionnaireCountLabel.wrapWidth(maxWidth: 40)
        
        if !rebookBtn.isHidden{
            rebookBtn.removeConstraint(attribute: .top)
            rebookBtn.removeConstraint(attribute: .bottom)
            rebookBtn.setCenterY(view: questionnaireView)
        }
    }
    
    func setAppointmentItemValues(appointment: Appointment, segmentIndex: Int? = nil, delegate: AppointmentListViewDelegate?, isLast: Bool, hideVideoBtn: Bool? = nil){
        
        providerName.text = appointment.member?.formMemberName()
        setProviderPhoto(image: appointment.member?.photo)
        
        if !(appointment.visitTypeDetail?.visitType.isNilOrBlank() ?? true){
            visitTypeOrSpecializationName.text = appointment.visitTypeDetail?.visitType
        }
        else{
            if !appointment.specialization.isNilOrBlank(){
                visitTypeOrSpecializationName.text = appointment.specialization
            }
            else{
                if !appointment.facilityName.isNilOrBlank(){
                    visitTypeOrSpecializationName.text = appointment.facilityName
                }
                else{
                    visitTypeOrSpecializationName.text = " "
                }
            }
        }
        if let segmentIndex = segmentIndex{
            
            if segmentIndex == 1 || segmentIndex == 3{
                deleteLabel.text = getString(key: "com.charmphr.action.delete")
            }
            else{
                deleteLabel.text = getString(key: "com.charmphr.action.cancel")
            }
            
            if segmentIndex == 0{
                
                if appointment.isQuestionnairePresent{
                    fillQuestionnaireView(questionnaireCount: appointment.questionnaireCount, questionnaireText: "Fill Questionnaire")
                }
                else{
                    questionnaireAndRebookView.isHidden = true
                }
                setDateLabelValue(date: appointment.appointmentDeviceStartTime, checkToday: true)
                setTimeLabelValue(timeString: appointment.appointmentDeviceStartTime?.getStringFromDate(dateFormat: "hh:mm a"), timeZone: TimeZone.current.identifier)
                removeDateTimeViewBorder()
                reasonView.isHidden = true

                if !appointment.physicanRemark.isNilOrBlank(){
                    instructionValueLabel.text = appointment.physicanRemark
                    instructionView.isHidden = false
                }
                else{
                    instructionView.isHidden = true
                }

                let calender = Calendar(identifier: .gregorian)
                
                if let appointmentDateTime = appointment.appointmentDeviceStartTime,  appointment.appointmentType == appointmentTypeVideoCall && calender.isDateInToday(appointmentDateTime), appointment.teleMode == telemode_PHR
                {
                    if hideVideoBtn != nil {
                        setAppointmentTypeLable(appointment: appointment)
                    }
                    else {
                        joinBtn.isHidden = false
                        appointmentTypeView.isHidden = true
                    }
                }
                else{
                    setAppointmentTypeLable(appointment: appointment)
                }
                delegate?.mapBtnViewToAppointment(joinBtn: joinBtn, questionnaireBtn: questionnaireBtn, appointment: appointment)
            }
            else if segmentIndex == 1{
                if appointment.datePreference == "ANY_DATE"{
                    setDateLabelValue(dateString: getString(key: "com.charmphr.appointments.anyDate"))
                }else{
                    if appointment.dateChoice1 != nil{
                        setDateLabelValue(date: appointment.dateChoice1)
                    }else{
                        setDateLabelValue(date: Date())
                    }
                }
                dateLabel.removeConstraint(attribute: .width)
                
                if appointment.timePreference == "ANY_TIME"{
                    setTimeLabelValue(timeString: getString(key: "com.charmphr.appointments.anyTime"))
                }else{
                    setTimeLabelValue(timeString: appointment.appointmentStartTime)
                }
                
                if !appointment.reason.isNilOrBlank(){
                    reasonValueLabel.text = appointment.reason
                    reasonView.isHidden = false
                }
                else{
                    reasonView.isHidden = true
                }
                instructionView.isHidden = true
                setAppointmentTypeLable(appointment: appointment)
                questionnaireAndRebookView.isHidden = true
                joinBtn.isHidden = true
                setDateTimeViewBorder()
            }
            else if segmentIndex == 2{
                if appointment.datePreference == "ANY_DATE"
                {
                    setDateLabelValue(dateString: getString(key: "com.charmphr.appointments.anyDate"))
                }else
                {
                    if appointment.dateChoice1 != nil
                    {
                        setDateLabelValue(date: appointment.dateChoice1)
                    }else
                    {
                        setDateLabelValue(date: Date())
                    }
                }
                dateLabel.removeConstraint(attribute: .width)
                //                dateLabel.wrapWidth(maxWidth: 600)
                
                if !appointment.reason.isNilOrBlank(){
                    reasonValueLabel.text = appointment.reason
                    reasonView.isHidden = false
                }
                else{
                    reasonView.isHidden = true
                }
                instructionView.isHidden = true
                setAppointmentTypeLable(appointment: appointment)
                questionnaireAndRebookView.isHidden = true
                joinBtn.isHidden = true
                dateAndTimeView.isHidden = false
                dateAndTimeViewRenew.isHidden = true
                timeView.isHidden = true
                setDateTimeViewBorder()
            }
            else if segmentIndex == 3{
                if appointment.datePreference == "ANY_DATE"
                {
                    setDateLabelValue(dateString: getString(key: "com.charmphr.appointments.anyDate"))
                }else
                {
                    if appointment.dateChoice1 != nil
                    {
                        setDateLabelValue(date: appointment.dateChoice1)
                    }else
                    {
                        setDateLabelValue(date: Date())
                    }
                }
                dateLabel.removeConstraint(attribute: .width)
                //                dateLabel.wrapWidth(maxWidth: 600)
                
                if appointment.timePreference == "ANY_TIME"
                {
                    setTimeLabelValue(timeString: getString(key: "com.charmphr.appointments.anyTime"))
                }else
                {
                    setTimeLabelValue(timeString: appointment.appointmentStartTime)
                }
                
                if !appointment.physicanRemark.isNilOrBlank(){
                    reasonValueLabel.text = appointment.physicanRemark
                    reasonView.isHidden = false
                }
                else{
                    reasonView.isHidden = true
                }
                instructionView.isHidden = true
                setAppointmentTypeLable(appointment: appointment)
                questionnaireAndRebookView.isHidden = true
                joinBtn.isHidden = true
                setDateTimeViewBorder()
            }
            verticalStackView.removeConstraint(attribute: .bottom)
            verticalStackView.setBottom(offSet: -12)
        }
        else{
            
            if appointment.isQuestionnairePresent{
                fillQuestionnaireView(questionnaireCount: appointment.questionnaireCount, questionnaireText: "com.charmphr.appointment.fillQuestionnaire.title")
            }
            else{
                questionnaireAndRebookView.isHidden = true
            }
            
            setDateLabelValue(date: appointment.appointmentDeviceStartTime, checkToday: true, isFromDashboard: true)
            setTimeLabelValue(timeString: appointment.appointmentDeviceStartTime?.getStringFromDate(dateFormat: "hh:mm a"), timeZone: TimeZone.current.identifier)
            removeDateTimeViewBorder()
            if !appointment.physicanRemark.isNilOrBlank(){
                instructionValueLabel.text = appointment.physicanRemark
                instructionView.isHidden = false
            }
            else{
                instructionView.isHidden = true
            }

            let calender = Calendar(identifier: .gregorian)
            
            if let appointmentDateTime = appointment.appointmentDeviceStartTime,  appointment.appointmentType == appointmentTypeVideoCall && calender.isDateInToday(appointmentDateTime), appointment.teleMode == telemode_PHR
            {
                if hideVideoBtn != nil {
                    setAppointmentTypeLable(appointment: appointment)
                }
                else {
                    joinBtn.isHidden = false
                    appointmentTypeView.isHidden = true
                }
            }
            else{
                setAppointmentTypeLable(appointment: appointment)
            }
            
            if isLast{
                separatorLineContainerView.isHidden = true
                verticalStackView.removeConstraint(attribute: .bottom)
                verticalStackView.setBottom(offSet: -12)
            }
            else{
                separatorLineContainerView.isHidden = false
                verticalStackView.removeConstraint(attribute: .bottom)
                verticalStackView.setBottom(offSet: 0)
            }
            delegate?.mapBtnViewToAppointment(joinBtn: joinBtn, questionnaireBtn: questionnaireBtn, appointment: appointment)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
