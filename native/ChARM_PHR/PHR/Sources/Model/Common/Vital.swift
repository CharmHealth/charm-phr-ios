//
//  Virtual.swift
//  ChARM Phr
//
//  Created by Sankar Saravanan on 09/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import UIKit

class PatientVitals{
    var metric : Metric?
    var metricHistoryArr : Array<MetricHistory>?
}

class MetricValue{
    var metricHistory: MetricHistory? = nil
    var metric: Metric? = nil
    var tracker: Tracker? = nil
    var type: HealthMetric? = nil
    var name: String? = nil 
}

class MetricHistory{
    var trackedValue : String?
    var trackedValueUnit : String?
    var notes : String?
    var dateOfEntry : Date?
    var uniqueId: UUID?
    var entryId : String?
    
    func getValue() -> String {
        return getString(key: "com.charmphr.wellness.healthkit.entry.value", with: [trackedValue ?? "" , trackedValueUnit ?? ""])
    }
    
    func getDateStr() -> String
    {
        if let dateOfEntry {
            let dateStr:String
            if dateOfEntry.isCurrentYear {
                dateStr = dateOfEntry.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT)
            }
            else{
                dateStr = dateOfEntry.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
            }
            
            return getString(key: "com.charmphr.wellness.healthkit.date.value", with: [dateStr , dateOfEntry.getStringFromDate(dateFormat: charmDisplayTimeFormat)])
        }
      
        return ""
    }
}

class BPHistory {
    var systolic: MetricHistory?
    var diastolic: MetricHistory?
    var historyId: Int? = nil
    
    func getValue() -> String {
        return getString(key: "com.charmphr.wellness.healthkit.bp.value" , with: [systolic?.trackedValue ?? "", diastolic?.trackedValue ?? "" , systolic?.trackedValueUnit ?? ""])
    }
}

class Metric
{
    var metricId: String?
    var metricName: String?
    var metricUnit: String?
    var isDefaultMetric: Bool  = false
}

enum TrackerType
{
    case general
    case pulseRate
    case temperature
    case bloodPressure
    case cholesterol
    case bloodSugar
    case others
}

class Tracker
{
    var trackerId: String?
    var trackerName: String?
    var trackerUnitSystem: String?
    var isDefaultTracker: Bool  = false
    var metricList: Array<Metric>?

    var trackerType : TrackerType?

//        func copy(with zone: NSZone? = nil) -> Any {
//            let copy = Tracker()
//            copy.trackerId = trackerId
//            copy.trackerName = trackerName
//            copy.trackerUnitSystem = trackerUnitSystem
//            copy.isDefaultTracker = isDefaultTracker
//            copy.metricList = metricList
//            return copy
//        }
}




//TODO: have to check and need to merge this with patient vital
//sankar used this in dashboard to show vital
class Vital{
    var healthMetricId : String!
    var trackerId : String!
    var trackerName : String!
    var metricName : String!
    var vitalType : VitalType!
    var vitalValue : String = ""
    var valueUnit : String!
    var date : Date?
}

enum VitalType : String
{
    case Weight
    case Height
    case Blood_pressure = "Blood pressure"
    
    func value () -> String
    {
        return self.rawValue
    }
}

class AddVital {
    var dateStr:String? = nil
    var trackerId:String? = nil
    var notes: String? = nil
    var metricArr:[[String: Any]]? = nil
}
