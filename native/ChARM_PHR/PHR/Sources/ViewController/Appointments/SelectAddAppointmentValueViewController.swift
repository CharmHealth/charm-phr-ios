//
//  SelectAddAppointmentValueViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 19/12/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol selectAddAppointmentValueViewControllerDelegate: AnyObject {
    func selectAddAppointmentValueViewControllerDidSelectValue(indexPath : IndexPath,valueString : String?)
}

class SelectAddAppointmentValueViewController: CustomViewControllerWithTableView , UITableViewDataSource , UITextFieldDelegate, MDTextFieldDelegate {
        
    
    let datePicker = UIDatePicker()
    let fromTimeDatePicker = UIDatePicker()
    let toTimeDatePicker = UIDatePicker()
    
    
    private let TAG_FOR_TEXTFIELD = 5001
    private let TAG_FOR_FROM_TIME_TF = 1001
    private let TAG_FOR_TO_TIME_TF = 1002
    
    private var numberOfSection = 1
    
    //only for secific time
    private var secondNumberSectionValueArray : Array<String> = []
    private var fromTime : Date?
    private var toTime : Date?
    
    var selectedValueIndex : Int?
    var arrayOfValues : [Dictionary<String,Any>] = []
    var keyString : String?
    var secondKeyString : String?
    var valueString : String?
    weak var delegate : selectAddAppointmentValueViewControllerDelegate?
    
    var popViewControllerWhenValueChanged : Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLargeTitle(enable: false)
        // Do any additional setup after loading the view.
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        self.activityIndicatorView.stopAnimating()
        
        customTableView.sectionHeaderTopPadding = 0
        customTableView.dataSource = self
        customTableView.register(UINib(nibName: "TextLableWithCheckmarkTableViewCell", bundle: nil), forCellReuseIdentifier: "TextLableWithCheckmarkTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfValues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            if arrayOfValues[indexPath.row]["preference"] != nil
            {
                let preference = arrayOfValues[indexPath.row]["preference"]
                
                if preference as? String != nil && (preference as! String).lowercased() == "disabled"
                {
                    
                    let tableViewCell = AddAppointmentTableViewCell(style: .default, reuseIdentifier: "AddAppointmentTableViewCell")
                    tableViewCell.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
                    tableViewCell.textField.tag = TAG_FOR_TEXTFIELD
                    tableViewCell.textField.tintColor = .clear
                    tableViewCell.keyLabel.text = arrayOfValues[indexPath.row][keyString!] as? String
                    tableViewCell.textField.text = arrayOfValues[indexPath.row]["value"] as? String
                    tableViewCell.keyLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                    tableViewCell.textField.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
                    tableViewCell.keyLabel.textColor = .black
                    tableViewCell.isUserInteractionEnabled = false
                    return tableViewCell
                }
                if preference as? String != nil && (preference as! String).lowercased() == "date"
                {
                    
                    let tableViewCell = AddAppointmentTableViewCell(style: .default, reuseIdentifier: "AddAppointmentTableViewCell")
                    tableViewCell.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
                    tableViewCell.textField.tag = TAG_FOR_TEXTFIELD
                    tableViewCell.textField.tintColor = .clear
                    tableViewCell.keyLabel.text = arrayOfValues[indexPath.row][keyString!] as? String
                    
                    datePicker.preferredDatePickerStyle = .wheels
                    datePicker.datePickerMode = .date
                    tableViewCell.textField.isUserInteractionEnabled = true
                    
                    datePicker.addTarget(self, action: #selector(datePickerValueChanged(datePicker:)), for: .valueChanged)
                    
                                    
                    if !isNilOrEmpty(string: arrayOfValues[indexPath.row]["minimum"] as? String)
                    {
                        datePicker.minimumDate = CharmUtil.getDateObjectWith(dateString: arrayOfValues[indexPath.row]["minimum"] as! String, dateFormat: arrayOfValues[indexPath.row]["format"] as! String)
                    }
                    if !isNilOrEmpty(string: arrayOfValues[indexPath.row]["maximum"] as? String)
                    {
                        datePicker.maximumDate = CharmUtil.getDateObjectWith(dateString: arrayOfValues[indexPath.row]["maximum"] as! String, dateFormat: arrayOfValues[indexPath.row]["format"] as! String)
                    }
                    
                    if !isNilOrEmpty(string: arrayOfValues[indexPath.row]["value"] as? String)
                    {
                        if let date = CharmUtil.getDateObjectWith(dateString: arrayOfValues[indexPath.row]["value"] as! String, dateFormat: arrayOfValues[indexPath.row]["format"] as! String)
                        {
                            datePicker.date = date
                            tableViewCell.textField.text = arrayOfValues[indexPath.row]["value"] as? String
                            valueString = arrayOfValues[indexPath.row]["value"] as? String
                        }
                    }
                    else if datePicker.minimumDate != nil {
                        datePicker.date = datePicker.minimumDate!
                        valueString = arrayOfValues[indexPath.row]["minimum"] as? String
                    }
                    tableViewCell.textField.inputView = datePicker
                    
                    tableViewCell.textField.delegate = self
                    return tableViewCell
                }else if preference as? String != nil && (preference as! String).lowercased() == "time"
                {
                    let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "TextLableWithCheckmarkTableViewCell") as! TextLableWithCheckmarkTableViewCell
                    tableViewCell.keyLabel.text = arrayOfValues[indexPath.row][keyString!] as? String
                    if selectedValueIndex != nil && selectedValueIndex == indexPath.row
                    {
                        tableViewCell.isCheckmarkHidden(bool: false)
                        
                        let value = arrayOfValues[indexPath.row]["value"] as? String
                        
                        if value != nil && value != ""
                        {
                            let arrayOfTime = value!.split(separator: "-")
                            if arrayOfTime.count == 2
                            {
                                fromTime = CharmUtil.getDateObjectWith(dateString: "\(arrayOfTime[0])", dateFormat: charmDisplayTimeFormat)
                                toTime = CharmUtil.getDateObjectWith(dateString: "\(arrayOfTime[1])", dateFormat: charmDisplayTimeFormat)
                            }
                        }else
                        {
                            
                            if arrayOfValues[indexPath.row]["currentTime"] as? String != nil && arrayOfValues[indexPath.row]["currentTime"] as? String != ""
                            {
                                fromTime = CharmUtil.getDateObjectWith(dateString: arrayOfValues[indexPath.row]["currentTime"] as! String , dateFormat: charmDisplayTimeFormat)
                            }else
                            {
                                fromTime = Date()
                            }
                            let calendar = Calendar.current
                            fromTime = calendar.date(byAdding: .minute, value: 5-(calendar.component(.minute, from: fromTime!)%5), to: fromTime!)
                    
                            toTime = fromTime!.addingTimeInterval(60.0 * 15.0)
                        }
                            
                        rangedTimeIsClicked()
                    }
                    return tableViewCell
                }
            }else{
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "TextLableWithCheckmarkTableViewCell") as! TextLableWithCheckmarkTableViewCell
                
                
                if selectedValueIndex != nil && selectedValueIndex == indexPath.row && indexPath.section == 0
                {
                    tableViewCell.isCheckmarkHidden(bool: false)
                }else
                {
                    tableViewCell.isCheckmarkHidden(bool: true)
                }
                
                var text = ""
                
                if keyString != nil && arrayOfValues[indexPath.row][keyString!] != nil && arrayOfValues[indexPath.row][keyString!] as? String != nil
                {
                    text.append(arrayOfValues[indexPath.row][keyString!] as! String)
                    
                    if text != "" && secondKeyString != nil && ((arrayOfValues[indexPath.row][secondKeyString!] as? String) != "")
                    {
                        text.append(".")
                    }
                }
                
                if secondKeyString != nil && arrayOfValues[indexPath.row][secondKeyString!] != nil && arrayOfValues[indexPath.row][secondKeyString!] as? String != nil
                {
                    //NOTE: this second string is only used for provider full name. Hence removing DR. prefix here when both prefix is DR. and also full name contains DR. as prefix. This whole logic needs to be changed.
                    let secondText = arrayOfValues[indexPath.row][secondKeyString!] as! String
                    if(secondText.hasPrefix(text)){
                        text = secondText}
                      else{
                       text.append(secondText)
                        }
                }
                tableViewCell.keyLabel.text = text
                
                return tableViewCell
            }
        }
        else if indexPath.section == 1
        {
            let tableViewCell = AddAppointmentTableViewCell(style: .default, reuseIdentifier: "AddAppointmentTableViewCell")
            tableViewCell.setSubviews(isArrowImageNeeded: false, isTextFieldShouldBeShown: true)
            tableViewCell.textField.tintColor = .clear
            
            
            fromTimeDatePicker.datePickerMode = .time
            fromTimeDatePicker.minuteInterval  = 5
            toTimeDatePicker.datePickerMode = .time
            toTimeDatePicker.minuteInterval  = 5
            
            fromTimeDatePicker.preferredDatePickerStyle = .wheels
            toTimeDatePicker.preferredDatePickerStyle = .wheels
            
            tableViewCell.keyLabel.text = secondNumberSectionValueArray[indexPath.row]
            
            if tableViewCell.keyLabel.text == "From"  && fromTime != nil
            {
                tableViewCell.textField.tag = TAG_FOR_FROM_TIME_TF
                tableViewCell.textField.inputView = fromTimeDatePicker
                tableViewCell.textField.delegate = self
                fromTimeDatePicker.addTarget(self, action: #selector(fromTimeDatePickerValueChanged(datePicker:)), for: .valueChanged)
                fromTimeDatePicker.date = fromTime ?? Date()
                tableViewCell.textField.text = CharmUtil.getDateStringWith(date: fromTime!, dateFormat: charmDisplayTimeFormat)
                
            }else if tableViewCell.keyLabel.text == "To" && toTime != nil
            {
                tableViewCell.textField.tag = TAG_FOR_TO_TIME_TF
                tableViewCell.textField.inputView = toTimeDatePicker
                tableViewCell.textField.delegate = self
                toTimeDatePicker.addTarget(self, action: #selector(toTimeDatePickerValueChanged(datePicker:)), for: .valueChanged)
                tableViewCell.textField.text = CharmUtil.getDateStringWith(date: toTime!, dateFormat: charmDisplayTimeFormat)
                toTimeDatePicker.date = toTime ?? Date()
            }
            tableViewCell.textField.isUserInteractionEnabled = true

            return tableViewCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let preference = arrayOfValues[indexPath.row]["preference"]
        if preference as? String != nil && (preference as! String).lowercased() == "disabled" {
            if let cell = tableView.cellForRow(at: indexPath)
            {
                cell.setSelected(false, animated: true)
            }
            return
        }
    
        
        
        if let selectedVal = selectedValueIndex
        {
            if let cell = tableView.cellForRow(at: IndexPath(row: selectedVal, section: 0)) as? TextLableWithCheckmarkTableViewCell
            {
                if indexPath.section == 0
                {
                    cell.isCheckmarkHidden(bool: true)
                }
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath)
        {
            cell.setSelected(false, animated: true)
        }
        
        if indexPath.section == 0
        {

            if let tableViewCell = customTableView.cellForRow(at: indexPath) as? AddAppointmentTableViewCell
            {
                if valueString == nil{
                    tableViewCell.textField.text = CharmUtil.getDateStringWith(date: datePicker.date, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
                }else
                {
                    tableViewCell.textField.text = valueString
                }
                tableViewCell.textField.becomeFirstResponder()
            }
            else if let tableViewCell = customTableView.cellForRow(at: indexPath) as? TextLableWithCheckmarkTableViewCell
            {
                
                if tableViewCell.keyLabel.text == "Specific time"
                {
                    
                    if selectedValueIndex == nil {
                        tableViewCell.isCheckmarkHidden(bool: false)
                    }
                    
                    rangedTimeIsClicked()
                }
                else if tableViewCell.keyLabel.text == "Any Time"
                {
                    if selectedValueIndex == nil {
                        tableViewCell.isCheckmarkHidden(bool: false)
                    }
                    
//                    if let cell = customTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TextLableWithCheckmarkTableViewCell{
//                        cell.isCheckmarkHidden(bool: true)
//                    }
                    
                    numberOfSection = 1
                    if secondNumberSectionValueArray.count > 0
                    {
                        secondNumberSectionValueArray = []
                        customTableView.reloadData()
                    }
                }
                else{
                    tableViewCell.isCheckmarkHidden(bool: false)
                }
                
            }
            
            selectedValueIndex = indexPath.row
        }else
        {
            if let tableViewCell = customTableView.cellForRow(at: indexPath) as? AddAppointmentTableViewCell
            {
                let datePicker = tableViewCell.textField.inputView as! UIDatePicker
                if tableViewCell.keyLabel.text == "From" && fromTime != nil
                {
                    datePicker.date = fromTime!
                    datePicker.minimumDate = nil
                    datePicker.maximumDate = nil
                }else if tableViewCell.keyLabel.text == "To"
                {
                    if toTime != nil
                    {
                        datePicker.date = toTime!
                    }else if fromTime != nil
                    {
                        datePicker.date = fromTime!.addingTimeInterval(60.0 * 15.0)
                        toTime = fromTime!.addingTimeInterval(60.0 * 15.0)
                    }
                    datePicker.minimumDate = fromTime!
                }
                
                tableViewCell.textField.becomeFirstResponder()
            }
        }
        
        if popViewControllerWhenValueChanged
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func numberOfSections(in customTableView: UITableView) -> Int {
        return numberOfSection
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if selectedValueIndex != nil{
            
            if let cell = customTableView.cellForRow(at: IndexPath(row: selectedValueIndex!, section: 0)) as? AddAppointmentTableViewCell
            {
                delegate?.selectAddAppointmentValueViewControllerDidSelectValue(indexPath: IndexPath(row: selectedValueIndex!, section: 0), valueString: cell.textField.text)

            }else if numberOfSection == 2{
                if fromTime != nil && toTime != nil
                {
                    delegate?.selectAddAppointmentValueViewControllerDidSelectValue(indexPath: IndexPath(row: selectedValueIndex!, section: 0), valueString: "\(CharmUtil.getDateStringWith(date: fromTime!, dateFormat: charmDisplayTimeFormat)) - \(CharmUtil.getDateStringWith(date: toTime!, dateFormat: charmDisplayTimeFormat))")
                }else
                {
                    
                }
            }
            else if let cell = customTableView.cellForRow(at: IndexPath(row: selectedValueIndex!, section: 0)) as? TextLableWithCheckmarkTableViewCell{
                delegate?.selectAddAppointmentValueViewControllerDidSelectValue(indexPath: IndexPath(row: selectedValueIndex!, section: 0), valueString: cell.keyLabel.text)
            }
            else
            {
                delegate?.selectAddAppointmentValueViewControllerDidSelectValue(indexPath: IndexPath(row: selectedValueIndex!, section: 0), valueString: nil)
            }
        }
    }
    
    func rangedTimeIsClicked()
    {
        numberOfSection = 2
        if secondNumberSectionValueArray.isEmpty
        {
            secondNumberSectionValueArray = ["From","To"]
            customTableView.reloadData()
        }
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func datePickerValueChanged(datePicker :UIDatePicker)
    {
        if let tableViewCell = customTableView.cellForRow(at: IndexPath(row: selectedValueIndex!, section: 0)) as? AddAppointmentTableViewCell
        {
            tableViewCell.textField.text = "\(CharmUtil.getDateStringWith(date: datePicker.date, dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR))"
        }
    }
    
    @objc func fromTimeDatePickerValueChanged(datePicker :UIDatePicker)
    {
        if let tf = self.view.viewWithTag(TAG_FOR_FROM_TIME_TF) as? UITextField
        {
            
            fromTime = datePicker.date
            let calender = Calendar.current
            if fromTime != nil && toTime != nil{
                if let minute = calender.dateComponents([.minute], from: fromTime!, to: toTime!).minute
                {
                    if minute <= 0
                    {
                        toTime = fromTime?.addingTimeInterval(60.0 * 15.0)
                        if let tf = self.view.viewWithTag(TAG_FOR_TO_TIME_TF) as? UITextField
                        {
                            tf.text = CharmUtil.getDateStringWith(date: toTime!, dateFormat: charmDisplayTimeFormat)
                        }
                    }
                }
            }
            tf.text = "\(CharmUtil.getDateStringWith(date: datePicker.date, dateFormat: charmDisplayTimeFormat))"
        }
    }
    
    @objc func toTimeDatePickerValueChanged(datePicker :UIDatePicker)
    {
        if let tf = self.view.viewWithTag(TAG_FOR_TO_TIME_TF) as? UITextField
        {
            toTime = datePicker.date
            tf.text = "\(CharmUtil.getDateStringWith(date: datePicker.date, dateFormat: charmDisplayTimeFormat))"
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func mdTextFieldDidBeginEditing(_ textField: MDTextField!) {
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        }
    }
    
    func mdTextFieldDidEndEditing(_ textField: MDTextField!) {
        if textField.inputView is UIDatePicker{
            textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        }
    }
    
}
