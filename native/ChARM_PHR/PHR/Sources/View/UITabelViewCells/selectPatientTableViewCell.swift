//
//  selectPatientTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 10/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class SelectPatientTableViewCell: UITableViewCell{
    
    let selectPatientItemView = SelectPatientItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(selectPatientItemView)
        addConstraints()
    }
    private func addConstraints(){
        
        selectPatientItemView.setLeft(offSet: X_SPACE)
        selectPatientItemView.setRight(offSet: -X_SPACE)
        selectPatientItemView.setTop(offSet: PADDING_5)
        selectPatientItemView.setBottom(offSet: -PADDING_5)
    }

    func setTableViewCell(data: Patient){
        
        selectPatientItemView.patientNameLabel.text = "\(data.firstName!) \(data.lastName ?? "")"
        if (data.age > 0){
            selectPatientItemView.patientDetailLabel.text = "\(data.gender.capitalizingFirstLetter()) , \(data.age ?? 0)"
        }
        else{
            selectPatientItemView.patientDetailLabel.text = "\(data.gender.capitalizingFirstLetter())"
        }
        
        selectPatientItemView.imageViewWithInitailsView.setInitialsAndImage(initials: "\(isNilOrEmpty(string: data.firstName) == false ? String(data.firstName.first!) : "")\(isNilOrEmpty(string: data.lastName) == false ? String(data.lastName.first!) : "")", image: data.patientPhoto)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            selectPatientItemView.setBackgroundColor(bgColor: LIGHT_BLUE_BACKGROUND_COLOR)
        } else {
            selectPatientItemView.setBackgroundColor(bgColor: APPLICATION_FOREGROUND_COLOR)
        }
    }
}

class SelectPatientItemView: UIView{
    
    let patientNameLabel = UILabel()
    let patientDetailLabel = UILabel()
    let imageViewWithInitailsView = ImageViewWithInitailsView()
    private let imageViewSize: CGFloat = 48
    
    init(){
        super.init(frame: .zero)
        setSubViews()
    }
    
    private func setSubViews(){
        
        self.addSubview(imageViewWithInitailsView)
        self.addSubview(patientNameLabel)
        self.addSubview(patientDetailLabel)
        addProeprties()
        addConstraints()
    }
    
    private func addConstraints(){
        
        imageViewWithInitailsView.setLeft(offSet: 10)
        imageViewWithInitailsView.setTop(offSet: 10)
        imageViewWithInitailsView.setWidth(constant: imageViewSize)
        imageViewWithInitailsView.setHeight(constant: imageViewSize)
        
        patientNameLabel.setLeftRelatedToView(offSet: 15, relatedView: imageViewWithInitailsView, relatedAttribute: .right)
        patientNameLabel.setRight(offSet: -10)
        patientNameLabel.setTop(offSet: 10)
        
        patientDetailLabel.setLeftRelatedToView(offSet: 15, relatedView: imageViewWithInitailsView, relatedAttribute: .right)
        patientDetailLabel.setRight(offSet: -10)
        patientDetailLabel.setTopRelatedToView(offSet: 4, relatedView: patientNameLabel, relatedAttribute: .bottom)
        patientDetailLabel.setBottom(offSet: -10)
    }
    private func addProeprties(){
        
        self.addShadowAndCornerRadius(.SMALL)
        
        imageViewWithInitailsView.layer.cornerRadius = imageViewSize / 2
        imageViewWithInitailsView.layer.masksToBounds = true
        imageViewWithInitailsView.contentMode = .scaleToFill
        
        patientNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_VALUE_LABEL, Weight: .semibold)
        patientNameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        
        patientDetailLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        patientDetailLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_SELECTPATIENT_VC_LIGHT)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
