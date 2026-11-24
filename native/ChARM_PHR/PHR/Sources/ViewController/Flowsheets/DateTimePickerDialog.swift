//
//  DateTimePickerDialog.swift
//  phr
//
//  Created by prathi-13964 on 04/08/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit

protocol DateTimePickerDelegate: AnyObject{
    func dateTimePickerDelegateDoneAction(datePickerString: String, tag: Int?)
}

class DateTimePickerViewController: UIViewController{
    
    weak var delegate: DateTimePickerDelegate?
    let stackView = UIView()
    let navigationView = UIView()
    let datePickerView = UIView()
    let timePickerView = UIView()
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let cancelBtn = UIButton()
    let doneBtn = UIButton()
    var tagNo = 1
    var tagList: [Int] = []
    
    var delegateTag: Int? = nil
    var buttonToDatePickerMap = Dictionary<Int , Int>()
    var tagToStringMap = Dictionary<Int, String>()
    
    let DATE = "Date"
    let TIME = "Time"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(stackView)
        stackView.addSubview(navigationView)
        stackView.addSubview(datePickerView)
        stackView.addSubview(timePickerView)
        timePickerView.addSubview(timePicker)
        datePickerView.addSubview(datePicker)
        navigationView.addSubview(cancelBtn)
        navigationView.addSubview(doneBtn)
        
        dullParentView()
        stackView.backgroundColor = .white
        stackView.addCornerRadius(.LARGE)
        
        navigationView.addBottomBorder()
        navigationView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        timePicker.preferredDatePickerStyle = .inline
        timePicker.datePickerMode = .time
        
        cancelBtn.addTarget(self, action: #selector(cancelBtnClicked(btn:)), for: .touchUpInside)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE), for: .normal)
        cancelBtn.titleLabel?.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_VALUE_LABEL, weight: .regular)
        
        doneBtn.addTarget(self, action: #selector(doneBtnClicked(btn:)), for: .touchUpInside)
        doneBtn.setTitle(getString(key: "com.charmphr.action.done"), for: .normal)
        doneBtn.titleLabel?.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        doneBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_VALUE_LABEL, weight: .semibold)
        doneBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLUE), for: .normal)
        
        datePicker.tag = tagNo
        tagList.append(tagNo)
        tagToStringMap[tagNo] = DATE
        tagNo = tagNo + 1
        
        timePicker.tag = tagNo
        tagToStringMap[tagNo] = TIME
        tagList.append(tagNo)
        tagNo = tagNo + 1
        
        
        stackView.setCenterY()
        stackView.setCenterX()
        
        navigationView.setLeft(offSet: 0)
        navigationView.setRight(offSet: 0)
        navigationView.setTop(offSet: 0)
        
        datePickerView.setLeft(offSet: 0)
        datePickerView.setRight(offSet: 0)
        datePickerView.setTopRelatedToView(offSet: 0, relatedView: navigationView, relatedAttribute: .bottom)

        timePickerView.setLeft(offSet: 0)
        timePickerView.setRight(offSet: 0)
        timePickerView.setTopRelatedToView(offSet: 0, relatedView: datePickerView, relatedAttribute: .bottom)
        timePickerView.setBottom(offSet: 0)
        
        cancelBtn.setLeft(offSet: 20)
        cancelBtn.setTop(offSet: 10)
        cancelBtn.setBottom(offSet: -4)
        
        doneBtn.setRight(offSet: -20)
        doneBtn.setTop(offSet: 10)
        doneBtn.setBottom(offSet: -4)
        
        datePicker.setLeft(offSet: 0)
        datePicker.setRight(offSet: 0)
        datePicker.setTop(offSet: 0)
        datePicker.setBottom(offSet: 0)
        
        timePicker.setCenterX()
        timePicker.setTop(offSet: 0)
        timePicker.setBottom(offSet: -5)
    }
    
    @objc func cancelBtnClicked(btn: UIButton){
        let superView = self.delegate as? UIViewController
        superView?.view.layer.opacity = 1
        
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.layer.add(transition, forKey: nil)
        self.dismiss(animated: true, completion: nil)
    }
    func setDate(dateObjString: String){
        
        let date = CharmUtil.getDateObjectWith(dateString: dateObjString, dateFormat: FLOWSHEET_DATA_DATE_FORMAT)
        let dateString = date?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        let timeString = date?.getStringFromDate(dateFormat: charmDisplayTimeFormat)
        
        let dateObj = CharmUtil.getDateObjectWith(dateString: dateString ?? "", dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        let timeObj = CharmUtil.getDateObjectWith(dateString: timeString ?? "", dateFormat: charmDisplayTimeFormat)
        
        datePicker.date = dateObj ?? Date()
        timePicker.date = timeObj ?? Date()
        
    }
    @objc func doneBtnClicked(btn: UIButton){
        
        var dateList: [String] = []
        for tagListObj in tagList {
            if let datePicker = self.view.viewWithTag(tagListObj) as? UIDatePicker{
                if (tagToStringMap[tagListObj] == DATE) {
                    let date = datePicker.date.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                    dateList.append(date)
                }
                else if (tagToStringMap[tagListObj] == TIME){
                    let time = datePicker.date.getStringFromDate(dateFormat: charmDisplayTimeFormat)
                    dateList.append(time)
                }
            }
        }
        let dateTime = dateList.joined(separator: " ")
        self.delegate?.dateTimePickerDelegateDoneAction(datePickerString: dateTime, tag: delegateTag)

        let superView = self.delegate as? UIViewController
        superView?.view.layer.opacity = 1
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.layer.add(transition, forKey: nil)
        self.dismiss(animated: true, completion: nil)
    }
    func dullParentView(){
        let superView = self.delegate as? UIViewController
        superView?.view.layer.opacity = 0.5
        self.modalPresentationStyle = .overCurrentContext
    }
}
