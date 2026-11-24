//
//  UpComingAppointmentsTableViewCell.swift
//  ChARM Phr
//
//  Created by Sankar Saravanan on 10/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import UIKit

class UpComingAppointmentsTableViewCell: UITableViewCell {
    
    

//    let FONT_SIZE_EXTRALARGE  : CGFloat = 18
//    @IBOutlet weak var dateContainer: UIView!
//    @IBOutlet weak var dateLable: UILabel!
//    @IBOutlet weak var dayLabel: UILabel!
//    @IBOutlet weak var doctoeNameLabel: UILabel!
//    @IBOutlet weak var facilityNameLabel: UILabel!
//    @IBOutlet weak var timeZoneLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
    
    
    let upComingAppointmentsIndividualView = UpComingAppointmentsIndividualView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        contentView.addSubview(upComingAppointmentsIndividualView)
        addConstraints()
    }
    
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
////        self.layer.cornerRadius = CORNER_RADIUS_5
//
//        dateContainer.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_BLUE_BACKGROUND_COLOR)
//        dateContainer.layer.cornerRadius = CORNER_RADIUS_5
//        dateLable.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
//        dayLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
//
//
//        dateLable.font = UIFont.systemFont(ofSize: 20, Weight: .bold)
//        dayLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
//        doctoeNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
//        facilityNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
//        facilityNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
//        timeZoneLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
//        timeZoneLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
//
//        timeLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
//
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
    
    private func addConstraints(){
        upComingAppointmentsIndividualView.equalsTheContainerView()
    }
    
    func setValues(appointment: Appointment){
        upComingAppointmentsIndividualView.setValues(appointment: appointment)
    }
}

class UpComingAppointmentsIndividualView: UIView {
    
    let dateContainer: UIView = UIView()
    let dateLabel = UILabel()
    let dayLabel: UILabel = UILabel()
    let doctorNameLabel = UILabel()
    let facilityNameLabel: UILabel = UILabel()
    let timeZoneLabel: UILabel = UILabel()
    let timeLabel: UILabel = UILabel()
    let questionnaireButton =  UIButton()
    
    private var timelabelWidthConstraint: NSLayoutConstraint!
    private var questionnaireBtnWidthConstraint: NSLayoutConstraint!
    private var questionnaireBtnHeightConstraint: NSLayoutConstraint!

    
    private let sideMargin: CGFloat = 12
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.addSubview(dateContainer)
        dateContainer.addSubview(dateLabel)
        dateContainer.addSubview(dayLabel)
        self.addSubview(doctorNameLabel)
        self.addSubview(facilityNameLabel)
        self.addSubview(timeZoneLabel)
        self.addSubview(timeLabel)
        self.addSubview(questionnaireButton)
        
        setProperties()
        addConstraints()
    }
    
    private func setProperties(){
        
        dateContainer.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_BLUE_BACKGROUND_COLOR)
        dateContainer.addCornerRadius(.SMALL)
        dateLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
        dayLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE)
        

        dateLabel.font = UIFont.systemFont(ofSize: 20, Weight: .bold)
        dayLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
        doctorNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        facilityNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        facilityNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        timeZoneLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        timeZoneLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        
        timeLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        
        questionnaireButton.titleLabel?.textAlignment = .center
        questionnaireButton.setProperties(titleStrKey:"com.charmphr.dashboard.activeMedication.action.fillQuestionnaire" , fontsize: 12, weight: .regular, fontcolor: TEXT_COLOR_WHITE, bgcolor: THEME_COLOR)

    }
    
    private func addConstraints(){
        
        dateContainer.setWidth(constant: 44)
        dateContainer.setHeight(constant: 62)
        dateContainer.setTop(offSet: 2.5)
        dateContainer.setLeft(offSet: sideMargin)
        
        doctorNameLabel.setTop(offSet: 0)
        doctorNameLabel.setLeftRelatedToView(offSet: sideMargin, relatedView: dateContainer, relatedAttribute: .right)
        doctorNameLabel.setRightRelatedToView(offSet: -sideMargin, relatedView: timeLabel, relatedAttribute: .left)
        
        timeLabel.setTop(offSet: 0)
        timeLabel.setRight(offSet: -sideMargin)
        timelabelWidthConstraint = timeLabel.setAndReturnWidth(constant: 0)
        
        questionnaireButton.isUserInteractionEnabled = false
        questionnaireButton.setTopRelatedToView(offSet: 6, relatedView: facilityNameLabel, relatedAttribute: .top)
        //questionnaireButton.setBottomRelatedToView(offSet: 0, relatedView: timeZoneLabel, relatedAttribute: .bottom)
        questionnaireButton.setRight(offSet: -sideMargin)
        questionnaireBtnWidthConstraint = questionnaireButton.setAndReturnWidth(constant: 0)
        questionnaireBtnHeightConstraint = questionnaireButton.setAndReturnHeight(constant: 0)
        
        let questionnaireBtnSizeFit = questionnaireButton.sizeThatFits(CGSize(width: 200 , height: 80))
        questionnaireBtnWidthConstraint.constant = questionnaireBtnSizeFit.width + 20
        questionnaireBtnHeightConstraint.constant = questionnaireBtnSizeFit.height
        
        facilityNameLabel.setTopRelatedToView(offSet: 2, relatedView: doctorNameLabel, relatedAttribute: .bottom)
        facilityNameLabel.setLeftRelatedToView(offSet: sideMargin, relatedView: dateContainer, relatedAttribute: .right)
        facilityNameLabel.setRightRelatedToView(offSet: -sideMargin, relatedView: questionnaireButton, relatedAttribute: .left)
        
        timeZoneLabel.setTopRelatedToView(offSet: 2, relatedView: facilityNameLabel, relatedAttribute: .bottom)
        timeZoneLabel.setLeftRelatedToView(offSet: sideMargin, relatedView: dateContainer, relatedAttribute: .right)
        timeZoneLabel.setRightRelatedToView(offSet: -sideMargin, relatedView: questionnaireButton, relatedAttribute: .left)
        timeZoneLabel.setBottom(offSet: -10)
        
        dateLabel.setCenterX()
        dayLabel.setCenterX()
        
        dateLabel.setTop(offSet: 4)
        dayLabel.setBottom(offSet: -8)
        
    }
    
    func setValues(appointment: Appointment){
        
        dateLabel.text = CharmUtil.getDateStringWith(date: appointment.appointmentDate, dateFormat: "dd")
        dayLabel.text = CharmUtil.getDateStringWith(date: appointment.appointmentDate, dateFormat: "E")
        doctorNameLabel.text = appointment.appointmentDoctorName
        facilityNameLabel.text = appointment.facilityName
        timeLabel.text = appointment.appointmentStartTime
        timeZoneLabel.text = appointment.timeZone ?? ""
        timelabelWidthConstraint.constant = timeLabel.sizeThatFits(CGSize(width: 200 , height: 50)).width
        
        
        if appointment.isQuestionnairePresent{
            questionnaireButton.isHidden = false
        }
        else{
            questionnaireButton.isHidden = true
        }
    }
}
