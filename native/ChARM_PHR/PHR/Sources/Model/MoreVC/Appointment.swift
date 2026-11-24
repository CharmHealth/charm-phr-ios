//
//  Appointment.swift
//  phr
//
//  Created by Sankar Saravanan on 12/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit
import JTAppleCalendar

class Appointment: NSObject ,DateDelegate{
    func getDate() -> Date {
        return appointmentDate ?? Date()
    }
    
    var appointmentId : String?
    var practicePatientId : Int?
    var appointmentDate : Date?
    var appointmentEndTime : Date?
    var appointmentDeviceStartTime : Date?
    var appointmentDeviceEndTime : Date?
    var timeZone : String?
    var appointmentType : String?
    var appointmentStatus : String?
    var reminderOption : String?
    var reminderType : String?
    var physicanRemark : String?
    var patientRemark : String?
    var reason : String?
    var physicanId : Int?
    // added
    var appointmentDoctorName : String?
    var facilityName : String?
    var facilityId: String?
    var appointmentStartTime : String?
    
    var datePreference : String?
    var timePreference : String?
    var requestId : String?
    var specialization : String?
    var practiceId : String?
    var teleMode: String?
    var dateChoice1 : Date?
    
    var member:Provider?
    
    var questionnaireCount: Int = 0
    var cancelOption: String? = nil
    var isQuestionnairePresent = false
    
    var startTimeUTC: String? = nil
    var endTimeUTC: String? = nil
    
    var visitTypeDetail: VisitTypes? = nil
}

class AppointmentRestriction: NSObject {
    var earlyCheckinInMinutes: Int? = nil
    var expiryInMinutes: Int? = nil
    var practice: Practice? = nil
}

//TODO: split this class into two as per web
//appointment config and appointmentrequest

class AddAppointment {
    
    //practice
    var selectedPractice : Practice?
    
    //facilty
    var selectedFacilityIndex : Int?
    
    //provider
    var selectedProviderIndex : Int?
    
    //visit types
    var selectedVisitTypeIndex : Int?
    var visitTypeId : String?
    var interval : Int?
    
    //date preference
    var spcificDate : String?
    var selectedDateIndex : Int = 0
    
    //time preference
    var spcificTimeRange : String?
    var selectedTimeIndex : Int = 0
    
    //slot date
    var selectedDate : Date?
    
    //slot pref
    var slectedSlotPrefreanceIndex : Int?
    
    //slot time
    var selectedSlotTimeIndex : Int?
    
    //appointment type
    var selectedAppointmentTypeIndex : Int = 0
    var appoimentTypeStr : String = ""
    
    //reason
    var reasonStr : String?
    
    //for selected facility current date and time
    var todayDate : Date?
    var facilityTime : Date?
    var timeZone : String?
    
    // for payment gateway
    var paymentInfo : PaymentInfo?
    
    //appointment config variables
    var isConfigured : Bool = false
    var isTelehealthEnabled : Bool = false
    var onlineBookingDaysLimit : Int?
    var slotsOpeningPriorHours : Int?
    var isWaitlistSelected : Bool = false
    var showWaitList : Bool = false
    var showVisitDuration : Bool = false
    var visitTypeDictArr : [Dictionary<String,Any>] = [] //Temporarily adding these.. Have to remove soon
    
    
    var paymentCurrencySymbol: String?
    var paymentCurrency: String?
    var isCardProcessing: Bool?
    
    var receiptId: String?
}

class AppointmentConfig{ //OnlineAppConfiguration
        var appointmentConfigId: String? = nil
        var providerId: String? = nil
        var facilityId: String? = nil
        var appSlotNewPatient: String? = nil
        var appSlotOldPatient: String? = nil
        var appApprovalPreferences: String? = nil
        var isEnabled: Bool = true
        var visitTypeIds: String? = nil
        var showVisittype: Bool? = nil
        var showVisitDuration: Bool = false
        var isCardProcessingEnabled: Bool = false
        var cardProcessingType: String? = nil
        var chargeType: String? = nil
        var chargeAmount: String? = nil
        var patientNote: String? = nil
        var allowAddWaitlist: Bool? = nil
        var isTokenBased: Bool? = nil
        var slotsOpeningPriorHours: Int? = nil
        var onlineBookingDaysLimit: Int? = nil
        var questionnaireId: String? = nil
        var paymentGateway: String? = nil

        var currentFacilityTimezone: Date? = nil
        var facilityTimezone: String? = nil
        var isTelehealthEnabled:Bool = false
        var visitTypeList: [VisitTypes] = []
        var interval: Int = 0
        var memberWorkTimingList: [MemberWorkTiming] = []
        var merchantAccountId: String? = nil
        var paymentCurrencySymbol: String? = "Rs"
        var paymentCurrency: String? = "INR"
    
    var showAppOnPatientTimezone: Bool = false

}

class AppointmentRequest {//
        var requestId: String? = nil
        var practicePatientId: String? = nil
        var physicianId: String? = nil
        var reason: String? = nil
        var appointmentType: String? = nil
        var appointmentStatus: String? = nil
        var timezone: String? = nil
        var physicianRemark: String? = nil
        var reminderOptions: String? = nil
        var reminderType: String? = nil
        var datePreference: String? = nil
        var dateChoice1: Date? = nil
        var dateChoice2: Date? = nil
        var dateChoice3: Date? = nil
        var timePreference: String? = nil
        var startHour: String? = nil
        var startMinutes: String? = nil
        var startSession: String? = nil
        var endHour: String? = nil
        var endMinutes: String? = nil
        var endSession: String? = nil
        var addAsWaitingList: Bool = false
        var facility: Facility? = nil
        var member: Provider? = nil
        var isEnabled: Bool = false
        var visitType: VisitTypes? = nil
        var duration: Int? = nil
        var practiceId: String? = nil
        var receiptId: String? = nil


        var paymentInfo: PaymentInfo? = nil

}


class VisitTypes {//
        var visittypeId: String? = nil
        var visitType: String? = nil
        var duration: Int? = nil
        var visittypeColor: String? = nil
        var charge: String? = nil
        var appointmentMode: String? = nil
        var isDeleted: Bool? = nil
}

class MemberWorkTiming{//
        var memberTimingId: String? = nil
        var memberId: String? = nil
        var facilityId: String? = nil
        var dayOfWeek: Int? = nil
        var isVisiting: Bool? = nil
        var visitNo: String? = nil
        var startTime: String? = nil
        var startSession: String? = nil
        var endTime: String? = nil
        var endSession: String? = nil
        var onlineAppSlot: Bool? = nil
        var tokenCount: Int? = nil
        var isMemberWorking: Bool = true
}

class MemberSlot{//

        var startTime:Date? = nil
        var endTime:Date? = nil

}


class SlotMetaData{
    var memberAvailability: [MemberAvailability] = []
    var showWaitingList:Bool = false 
    var memberWorkTiming: [MemberWorkTiming] = []
}

class MemberAvailability{
    
    var memberSlots: [MemberSlot] = []
    var date: Date? = nil
    
    
    private var sessions: [MemberSession: [MemberSlot]]? = nil
    
    
    func splitSessions() -> [MemberSession: [MemberSlot]] {
        
        if sessions == nil {
        
            sessions = [:]
            
            var morningArr:[MemberSlot] = []
            var noonArr:[MemberSlot] = []
            var eveArr:[MemberSlot] = []
            
            let startOfDay = (date ?? Date()).startOfDay
            
            //let morningStartTime = startOfDay.addHours(hours: 8)
            let noonStartTime = startOfDay.add(hours: 12)
            let eveStartTime = startOfDay.add(hours: 16)

            memberSlots.forEach({memberSlot in
                if let startTime = memberSlot.startTime {
                    
                    if startTime.isAfterOrEqual(date: startOfDay) && startTime.isBefore(date: noonStartTime){
                        morningArr.append(memberSlot)
                    }
                    else if startTime.isAfterOrEqual(date: noonStartTime) && startTime.isBefore(date: eveStartTime){
                        noonArr.append(memberSlot)
                    }
                    else {
                        eveArr.append(memberSlot)
                    }
                }
            })
            
            sessions?[MemberSession.Morning] = morningArr
            sessions?[MemberSession.Noon] = noonArr
            sessions?[MemberSession.Evening] = eveArr
        }

        return sessions!
    }
}

enum MemberSession: Int {
    case Morning = 0;
    case Noon = 1;
    case Evening = 2;
}

class MDCalendarDates{
    var todaysDate: Date? = nil
    var selectedDate: Date? = nil
    
    var startDateCalendar = Date()
    var endDateCalendar = Date()
    
    
    func isDateEnabled(date: Date)-> Bool{
        return( date > startDateCalendar && date < endDateCalendar) || date.getStringFromDate(dateFormat: PHR_DATE_API_FORMAT) == startDateCalendar.getStringFromDate(dateFormat: PHR_DATE_API_FORMAT) || date.getStringFromDate(dateFormat: PHR_DATE_API_FORMAT) == endDateCalendar.getStringFromDate(dateFormat: PHR_DATE_API_FORMAT)
    }
}

class MDCalendarData{
    
    var calendarDates: MDCalendarDates? = nil
    var isAvailable: Bool = false
    var cellState: CellState? = nil
}

@objc class ZoomCredentials: NSObject{
    
    @objc var webDomain: String? = nil
    @objc var sdkKey: String? = nil
    @objc var sdkSecret: String? = nil
    @objc var zoomToken: String? = nil
    @objc var userId: String? = nil
    @objc var userType: String? = nil
    @objc var meetingId: String? = nil
    @objc var displayName: String? = nil
    @objc var platform: String? = nil
    @objc var zak: String? = nil
    @objc var password: String? = nil
    @objc var webURL: String? = nil
    @objc var jwtToken: String? = nil
    @objc var memberName: String? = nil
    @objc var isConsentFormAvailable: Bool = false
    @objc var consentFormIdList: [String]? = nil
}
