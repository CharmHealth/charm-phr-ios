//
//  Reminder.swift
//  phr
//
//  Created by prathi-13964 on 23/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AddReminderVCModel{
    var reminderTime: Date = Date()
    var reminderTimeArray: [Date] = []
    var startDatePickerDate: Date? = nil
    var endDatePickerDate: Date? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil
    let frequencyArray = [Frequency.OneTime,Frequency.Daily,Frequency.Weekly]
//    let intervalArray = ["Day(s)","Week(s)"]
    var selectedFrequency: Frequency = Frequency.Daily
    var alertList: [String] = []
    var tagNo = 20000
    var editReminderTimeArray: [Date] = []
    var editReminderWeekArray: [Int] = []
    var addReminderObj: Reminder? = nil
    var editReminderObj: Reminder? = nil
}

public class Reminder: NSObject, NSSecureCoding{
    
    public static var supportsSecureCoding: Bool = true
    var templateId: String? = nil
    var reminderId: String? = nil
    var notificationType: String? = nil
    var frequencyUnit: String? = nil
    var frequency: String? = nil
    var addedBy: String? = nil
    var isReminderDeleted: Bool = false
    var startDate: Date? = nil
    var modifiedTime: String? = nil
    var endDate: Date? = nil
    var createdTime: Date? = nil
    var reminderFrequencyArray: [ReminderFrequency] = []
    var reminderType: String? = nil
    var practiceId: String? = nil
    var patientId: String? = nil
    var moduleId: String? = nil
    
    override init() {
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(templateId, forKey: "templateId")
        coder.encode(reminderId, forKey: "reminderId")
        coder.encode(notificationType, forKey: "notificationType")
        coder.encode(frequencyUnit, forKey: "frequencyUnit")
        coder.encode(frequency, forKey: "frequency")
        coder.encode(addedBy, forKey: "addedBy")
        coder.encode(isReminderDeleted, forKey: "isReminderDeleted")
        coder.encode(modifiedTime, forKey: "modifiedTime")
        coder.encode(startDate, forKey: "startDate")
        coder.encode(reminderFrequencyArray, forKey: "reminderFrequencyArray")
        coder.encode(practiceId, forKey: "practiceId")
        coder.encode(endDate, forKey: "endDate")
        coder.encode(createdTime, forKey: "createdTime")
        coder.encode(reminderType, forKey: "reminderType")
        coder.encode(moduleId, forKey: "moduleId")
        coder.encode(patientId, forKey: "patientId")
    }
    
    required public init?(coder: NSCoder) {
        templateId = coder.decodeObject(forKey: "templateId") as? String
        reminderId = coder.decodeObject(forKey: "reminderId") as? String
        notificationType = coder.decodeObject(forKey: "notificationType") as? String
        frequencyUnit = coder.decodeObject(forKey: "frequencyUnit") as? String
        frequency = coder.decodeObject(forKey: "frequency") as? String
        addedBy = coder.decodeObject(forKey: "addedBy") as? String
        isReminderDeleted = coder.decodeBool(forKey: "isReminderDeleted")
        modifiedTime = coder.decodeObject(forKey: "modifiedTime") as? String
        startDate = coder.decodeObject(forKey: "startDate") as? Date
        endDate = coder.decodeObject(forKey: "endDate") as? Date
        reminderFrequencyArray = coder.decodeObject(forKey: "reminderFrequencyArray") as? [ReminderFrequency] ?? []
        createdTime = coder.decodeObject(forKey: "createdTime") as? Date
        reminderType = coder.decodeObject(forKey: "reminderType") as? String
        practiceId = coder.decodeObject(forKey: "practiceId") as? String
        patientId = coder.decodeObject(forKey: "patientId") as? String
        moduleId = coder.decodeObject(forKey: "moduleId") as? String
    }
}

class ReminderHistory{
    
    var patientId: String? = nil
    var status: Int? = nil
    var reminderId: String? = nil
    var historyId: String? = nil
    var frequencyMapId: String? = nil
    var isReminderHistoryDeleted: Bool = false
    var statusUpdatedTime: Date? = nil
    var reminderFrequency: ReminderFrequency? = nil
}

public class ReminderFrequency: NSObject, NSSecureCoding {
    
    public static var supportsSecureCoding: Bool = true
    var time: String? = nil
    var frequencyMapId: String? = nil
    var reminderId: String? = nil
    var day: String? = nil
    var timeDayPrimaryKey: String? = nil
    var isReminderFrequencyDeleted: Bool = false
    
    override init(){
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(time, forKey: "time")
        coder.encode(frequencyMapId, forKey: "frequencyMapId")
        coder.encode(reminderId, forKey: "reminderId")
        coder.encode(day, forKey: "day")
        coder.encode(timeDayPrimaryKey, forKey: "timeDayPrimaryKey")
        coder.encode(isReminderFrequencyDeleted, forKey: "isReminderFrequencyDeleted")
    }
    
    required public init?(coder: NSCoder) {
        time = coder.decodeObject(forKey: "time") as? String
        frequencyMapId = coder.decodeObject(forKey: "frequencyMapId") as? String
        reminderId = coder.decodeObject(forKey: "reminderId") as? String
        day = coder.decodeObject(forKey: "day") as? String
        timeDayPrimaryKey = coder.decodeObject(forKey: "timeDayPrimaryKey") as? String
        isReminderFrequencyDeleted = coder.decodeBool(forKey: "isReminderFrequencyDeleted")
    }
}

class PatientReminderPOJO{
    var reminderArray: [Reminder] = []
    var arrayOfSupplement : [SupplementPOJO] = []
    var arrayOfMedication : [MedicationPOJO] = []
}

class TodayReminderPOJO{
    var time: Date?
    var reminderPOJOList: [ReminderPOJO] = []
}

class ReminderPOJO {
    var reminderDetails : ReminderDetails? = nil
    var reminderHistoryDetail: ReminderHistoryDetail? = nil
}

class ReminderDetails{
    var moduleType: ReminderModuleEnum? = nil
    var title: String? = nil //medication/supplement name
    var descripiton: String? = nil
    var hasEndDate: Bool = false
    var reminder: Reminder? = nil
    var isActive: Bool = false
    var isCompleted: Bool = false
    var isUpcoming: Bool = false
}

class ReminderHistoryDetail{
    var reminderHistory: ReminderHistory? = nil
    var reminderHistoryPrimaryKey: String? = nil
}

class AddReminderTransformModel{
    var title: String? = nil
    var instruction: String? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil
    var practiceId: String? = nil
    var moduleId: String? = nil
    var type: String? = nil
    var hasEndDate: Bool = false
    var selectedFrequency: Frequency = Frequency.Daily
}

class ReminderHistoryGroupPOJO{
    var date: Date? = nil
    var reminderHistoryTranformList: [ReminderHistoryTranformPOJO] = []
}

class ReminderHistoryTranformPOJO{
    var time: Date? = nil
    var reminderHistoryStatus: ReminderHistoryStatus? = nil
    var reminderHistory: ReminderHistory? = nil
    var reminderFrequency: ReminderFrequency? = nil
    var reminder: Reminder? = nil
}

public enum ReminderHistoryStatus{
    case isTaken
    case isSkipped
    case isUnMarked
}

class ReminderNotification: Codable{
    var frequencyDay: String?
    var fromDate: Date?
    var notificationId: String?
    var reminderIdList: String?
    var createdDate: Date?
}

public enum ReminderModuleEnum {
    case medication
    case supplement
    case appointment
}

public enum WeekDays : Int, CaseIterable{
    case Sunday = 0
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
}

public enum Frequency: String{
    case OneTime = "One Time"
    case Daily = "Daily"
    case Weekly = "Weekly"
}

class ListDataResponse{
    var data: Any? = nil
    var page: Int = 1
    var perPage: Int = 0
    var hasMore: Bool = false
}
