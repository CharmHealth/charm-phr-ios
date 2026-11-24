//
//  VaccineTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 08/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit
class VaccineTableViewCell: UITableViewCell{
    
    weak var delegate: VaccineViewController?
    let vaccineItemView = VaccineItemView()
    var vaccineImmunizationPOJO: VaccineImmunizationPOJO? = nil
    var row: Int = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(vaccineItemView)
        vaccineItemView.delegate = self
        addConstraints()
    }
    private func addConstraints(){
        
        vaccineItemView.setHorizontal(offSet: X_SPACE)
        vaccineItemView.setTop(offSet: PADDING_5)
        vaccineItemView.setBottom(offSet: -PADDING_5)
    }
    
    
    func setTableViewCell(data: VaccineImmunizationPOJO, indexPath: IndexPath){
        row = indexPath.row
        vaccineImmunizationPOJO = data
        
        vaccineItemView.isAddedByPatient(val: data.addedByPatient)
        if data.addedByPatient{
            let dateObj = data.patientImmunizationMap?.patientImmunizationHistory?.vaccinesOn
            vaccineItemView.dateLabel.text = dateObj?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            
            vaccineItemView.vaccineNameLabel.text = data.patientImmunizationMap?.immunizationList?.immunizationName
            
            if let ageCategoryText = data.patientImmunizationMap?.immunizationList?.immunizationType?.components(separatedBy: "_").last?.lowercased(){
                vaccineItemView.administeredTypeAndAgeCategoryLabel.text = "\(data.patientImmunizationMap?.patientImmunizationHistory?.howAdministered ?? "")2\(getString(key: "com.charmphr.Immunization.vaccineTaken.title"))\(ageCategoryText)"
            }
            
            if ((data.patientImmunizationMap?.patientImmunizationHistory?.givenBy.isNilOrBlank()) == true){
                vaccineItemView.administeredByView.isHidden = true
            }
            else{
                vaccineItemView.administeredByView.isHidden = false
                vaccineItemView.administeredByValueLabel.text = data.patientImmunizationMap?.patientImmunizationHistory?.givenBy
            }
            
            if (((data.patientImmunizationMap?.patientImmunizationHistory?.manufacturer.isNilOrBlank()) != false) && ((data.patientImmunizationMap?.patientImmunizationHistory?.comments.isNilOrBlank()) != false)){
                vaccineItemView.moreButton.isHidden = true
                vaccineItemView.manufacturerView.isHidden = true
                vaccineItemView.commentsLabel.isHidden = true
            }
            else{
                if data.isViewOpened{
                    vaccineItemView.moreButton.isHidden = true
                    setView(indexPath: indexPath)
                }
                else{
                    vaccineItemView.manufacturerView.isHidden = true
                    vaccineItemView.commentsLabel.isHidden = true
                    vaccineItemView.moreButton.isHidden = false
                    vaccineItemView.moreButton.addTarget(self, action: #selector(onClickMoreBtn), for: .touchUpInside)
                }
            }
        }
        else{

            if let patientVaccineMap = data.patientVaccineMap{

                let dateObj = patientVaccineMap.dateOfVaccination
                vaccineItemView.dateLabel.text = dateObj?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)

                vaccineItemView.vaccineNameLabel.text = patientVaccineMap.vaccine?.vaccineName

                if patientVaccineMap.route.isNilOrBlank() && patientVaccineMap.site.isNilOrBlank(){
                    vaccineItemView.routeAndSiteLabel.isHidden = true
                }
                else{
                    if !patientVaccineMap.route.isNilOrBlank(){
                        if !patientVaccineMap.site.isNilOrBlank(){
                            vaccineItemView.routeAndSiteLabel.text = "\(patientVaccineMap.route!), \(patientVaccineMap.site!)"
                        }
                        else{
                            vaccineItemView.routeAndSiteLabel.text = "\(patientVaccineMap.route!)"
                        }
                    }
                }

                if let fullName = patientVaccineMap.orderingProvider?.fullName, fullName.isNotBlank(){
                        vaccineItemView.prescribedByValueLabel.text = fullName
                        vaccineItemView.prescribedByView.isHidden = false
                }
                else{
                    vaccineItemView.prescribedByView.isHidden = true
                }
                
                if data.isViewOpened{
                    vaccineItemView.practiceMoreBtn.isHidden = true
                    setView(indexPath: indexPath)
                }
                else{
                    vaccineItemView.fromView.isHidden = true
                    vaccineItemView.practiceMoreBtn.isHidden = false
                    vaccineItemView.practiceMoreBtn.addTarget(self, action: #selector(onClickMoreBtn), for: .touchUpInside)
                }
            }
        }
    }
    
    private func setView(indexPath: IndexPath){
        
        if let vaccineImmunizationPOJO = vaccineImmunizationPOJO {
            
            if vaccineImmunizationPOJO.addedByPatient{
                vaccineItemView.moreButton.isHidden = true
                if vaccineImmunizationPOJO.isViewOpened{
                    if ((vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.manufacturer.isNilOrBlank()) != false){
                        vaccineItemView.manufacturerView.isHidden = true
                    }
                    else{
                        vaccineItemView.manufacturerView.isHidden = false
                        vaccineItemView.manufacturerValueLabel.text = vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.manufacturer
                    }
                    
                    if ((vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.comments.isNilOrBlank()) != false){
                        vaccineItemView.commentsLabel.isHidden = true
                    }
                    else{
                        vaccineItemView.commentsLabel.isHidden = false
                        vaccineItemView.commentsLabel.text = vaccineImmunizationPOJO.patientImmunizationMap?.patientImmunizationHistory?.comments
                    }
                }
                else{
                    vaccineItemView.manufacturerView.isHidden = true
                    vaccineItemView.commentsLabel.isHidden = true
                }
            }
            else{
                vaccineItemView.practiceMoreBtn.isHidden = true
                
                if vaccineImmunizationPOJO.isViewOpened{
                    vaccineItemView.fromView.isHidden = false
                    let practice = Patient.selectedPatientInstance?.getPracticeWith(practiceId: vaccineImmunizationPOJO.practiceId ?? "")
                    vaccineItemView.facilityListLabel.text = practice?.practiceName
                }
                else{
                    vaccineItemView.fromView.isHidden = true
                }
            }
        }
    }
    @objc func onClickMoreBtn(){
        vaccineImmunizationPOJO?.isViewOpened = true
        setView(indexPath: IndexPath(row: row, section: 1))
        if let tableView = delegate?.customTableView{
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
