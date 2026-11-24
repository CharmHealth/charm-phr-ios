//
//  AboutTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 23/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AboutFacilityTableViewCell: UITableViewCell{
    
    let aboutFacilityItemView = AboutFacilityItemView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(aboutFacilityItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        aboutFacilityItemView.setHorizontal(offSet: X_SPACE)
        aboutFacilityItemView.setTop(offSet: PADDING_5)
        aboutFacilityItemView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: Facility){
        
        aboutFacilityItemView.facilityNameLabel.text = data.facilityName
        
        if data.direction.isNilOrBlank() || data.direction == "null"{
            aboutFacilityItemView.locationIcon.isHidden = true
        }
        else{
            aboutFacilityItemView.locationIcon.isHidden = false
        }
        
        if let addressLine1 = data.line1{
            if let addressLine2 = data.line2{
                if addressLine1.isNotBlank() && addressLine2.isNotBlank(){
                    aboutFacilityItemView.addressLine1Label.text = "\(addressLine1), \(addressLine2)"
                    aboutFacilityItemView.addressLine1Label.isHidden = false
                }
                else if addressLine1.isBlank() && addressLine2.isBlank(){
                    aboutFacilityItemView.addressLine1Label.isHidden = true
                }
                else{
                    if addressLine1.isNotBlank(){
                        aboutFacilityItemView.addressLine1Label.text = addressLine1
                    }
                    else{
                        aboutFacilityItemView.addressLine1Label.text = addressLine2
                    }
                    aboutFacilityItemView.addressLine1Label.isHidden = false
                }
            }
            else{
                aboutFacilityItemView.addressLine1Label.text = addressLine1
                aboutFacilityItemView.addressLine1Label.isHidden = false
            }
        }
        else{
            aboutFacilityItemView.addressLine1Label.isHidden = true
        }
        
        if let phoneNumber = data.landline{
            if phoneNumber.isNotBlank(){
                aboutFacilityItemView.phoneNumberLabel.text = phoneNumber
                aboutFacilityItemView.phoneNumberView.isHidden = false
            }
            else{
                aboutFacilityItemView.phoneNumberView.isHidden = true
            }
        }
        else{
            aboutFacilityItemView.phoneNumberView.isHidden = true
        }
    }
}

class AboutProviderTableViewCell: UITableViewCell{
    
    let aboutProviderItemView = AboutProviderItemView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(aboutProviderItemView)
        addConstraints()
    }
    
    private func addConstraints(){
        aboutProviderItemView.setHorizontal(offSet: X_SPACE)
        aboutProviderItemView.setTop(offSet: PADDING_5)
        aboutProviderItemView.setBottom(offSet: -PADDING_5)
    }
    
    func setTableViewCell(data: Provider){
        aboutProviderItemView.providerNameLabel.text = data.formMemberNameWithDegree()
        
        if let spepcialization = data.specialization{
            if spepcialization.isNotBlank(){
                aboutProviderItemView.specializationLabel.text = spepcialization
                aboutProviderItemView.specializationLabel.isHidden = false
            }
            else{
                aboutProviderItemView.specializationLabel.isHidden = false
            }
        }
        else{
            aboutProviderItemView.specializationLabel.isHidden = false
        }
    }
}
