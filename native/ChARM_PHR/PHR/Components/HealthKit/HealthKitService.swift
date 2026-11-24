//
//  HealthKitService.swift
//  phr
//
//  Created by Raghul D on 11/06/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import Foundation
import HealthKit

final class HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    func requestAuthorization(types:[HealthMetric] = HealthMetric.allCases  ,completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            let error = NSError(
                domain: "HealthKitService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]
            )
            completion(false, error)
            return
        }
        
        let typesToRead = Set(types.map { $0.objectType })
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Authorization
       func requestProfileAuthorization(completion: @escaping (Bool, Error?) -> Void) {

           guard HKHealthStore.isHealthDataAvailable() else {
               let error = NSError(
                   domain: "HealthKitService",
                   code: 0,
                   userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]
               )
               completion(false, error)
               return
           }
           
           let readTypes: Set<HKObjectType> = [
               HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
           ]

           healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
               completion(success , error)
           }
       }

    
    func authorizationStatus(for type: HealthMetric) -> Bool {
        
        return healthStore.authorizationStatus(for: type.objectType) == .sharingAuthorized
    }
    
    func authorizationStatus(objectType: HKObjectType) -> HKAuthorizationStatus {
        return healthStore.authorizationStatus(for: objectType)
    }
    
    enum DOBFetchResult {
        case success(Date)
        case notAvailable
        //case authDenied
    }

    func fetchDateOfBirth() -> DOBFetchResult {
        do {
            let components = try healthStore.dateOfBirthComponents()
            if let date = components.date {
                return .success(date)
            }
            return .notAvailable
        } catch {
//            let hkError = error as NSError
//            if hkError.code == HKError.Code.errorAuthorizationDenied.rawValue ||
//               hkError.code == HKError.Code.errorAuthorizationNotDetermined.rawValue {
//                return .authDenied
//            }
            return .notAvailable
        }
    }

    func fetchBloodPressureData(from startDate: Date,
                                           to endDate: Date,
                                completion: @escaping ([BPHistory]) -> Void) {
            guard let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
                  let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
                completion([])
                return
            }

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

            let sampleType = HKObjectType.correlationType(forIdentifier: .bloodPressure)!

        
            let query = HKSampleQuery(sampleType: sampleType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sortDescriptor]) { (_, samples, error) in

                guard let correlations = samples as? [HKCorrelation], error == nil else {
                    debugPrintLog("Error fetching BP: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }

                let results: [BPHistory] = correlations.compactMap { correlation in
                    
                    
                    
                    let systolic = correlation.objects(for: systolicType).first as? HKQuantitySample
                    let diastolic = correlation.objects(for: diastolicType).first as? HKQuantitySample
                    
                    let bpMetric = BPHistory()
                    
                    if let systolic {
                        let systol = MetricHistory()

                        systol.trackedValue = (systolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury())).roundToTwoStr()
                        systol.trackedValueUnit = HKUnit.millimeterOfMercury().unitString
                        systol.dateOfEntry = correlation.startDate
                        systol.uniqueId = correlation.uuid
                        bpMetric.systolic = systol
                    }
                    
                    if let diastolic {
                        let diastol = MetricHistory()
                       
                        diastol.trackedValue = (diastolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury())).roundToTwoStr()
                        diastol.trackedValueUnit = HKUnit.millimeterOfMercury().unitString
                        diastol.dateOfEntry = correlation.startDate
                        diastol.uniqueId = correlation.uuid
                        
                        bpMetric.diastolic = diastol
                        
                    }
                    return bpMetric
                }

                completion(results)
            }

            healthStore.execute(query)
        }
    
    func fetchHealthKitData(for type: HealthMetric, from startDate: Date,
                            to endDate: Date,selectedVitalUnit: String?,
                            completion: @escaping ([MetricHistory]) -> Void) {
        
        if type == .sleep {
            fetchSleepSessions(from: startDate, to: endDate, completion: completion)
        }
        else if type == .steps {
            getDailySteps(from: startDate, to: endDate, completion: completion)
        }
        else {
            
            let sampleType = type.quantityType
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            
            
            
            let query = HKSampleQuery(sampleType: sampleType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sortDescriptor]) { (_, samples, error) in
                
                var historyList: [MetricHistory] = []
                
                guard let results = samples as? [HKQuantitySample], error == nil else {
                    debugPrintLog("Error fetching BP: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                
                
                results.forEach{result in
                    
                    let history = MetricHistory()
                    
                    if type.getUnit() == HKUnit.count().unitDivided(by: HKUnit.minute()) {
                        history.trackedValueUnit = "bpm"
                    }
                    else if type == .bmi {
                        history.trackedValueUnit = ""
                    }
                    else{
                        history.trackedValueUnit = type.getUnit(selectedUnitMetric: selectedVitalUnit).unitString
                    }
                    
                    history.trackedValue = (result.quantity.doubleValue(for: type.getUnit(selectedUnitMetric: selectedVitalUnit))).roundToTwoStr()
                    history.dateOfEntry = result.startDate
                    history.uniqueId  = result.uuid
                    //history.notes = result.me
                    
                    if type == .bloodGlucose {
                        if let mealTime =  result.metadata?.getInt("HKBloodGlucoseMealTime") {
                            if mealTime == HKBloodGlucoseMealTime.preprandial.rawValue {
                                history.notes = wellnessBeforeMealModelId
                            }
                            else{
                                history.notes = wellnessAfterMealModelId
                            }
                        }
                        else{
                            history.notes = wellnessRandomMealModelId
                        }
                    }
                    
                    
                    historyList.append(history)
                    
                }
                //have to set UUID here once the API is available.
                
                
                
                completion(historyList)
            }
            
            healthStore.execute(query)
        }
    }
    
    
    private func isBloodPressureMetric(_ metric: HealthMetric) -> Bool {
        return metric == .bloodPressureSystolic || metric == .bloodPressureDiastolic
    }
    
    private func getDailySteps(from startDate: Date, to endDate: Date, completion: @escaping ([MetricHistory]) -> Void) {
            guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                debugPrintLog("Error fetching Steps: Unknown error")
                completion([])
                //completion(nil, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"]))
                return
            }
            
            // Create calendar and normalize dates to start/end of day
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            let normalizedStartDate = calendar.startOfDay(for: startDate)
            let normalizedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
            
            // Create predicate for date range
            let predicate = HKQuery.predicateForSamples(withStart: normalizedStartDate, end: normalizedEndDate, options: .strictStartDate)
            
            // Create statistics collection query with daily intervals
            let interval = DateComponents(day: 1)
            let anchorDate = calendar.startOfDay(for: normalizedStartDate)
            
            let query = HKStatisticsCollectionQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { query, results, error in
               
                DispatchQueue.main.async {
                    
                    guard let results = results else {
                        if let error {
                            debugPrintLog("Error fetching Steps: \(error.localizedDescription)")
                        }
                        completion([])
                        return
                    }
                    
                    var dailyStepsArray: [MetricHistory] = []
                    
                    results.enumerateStatistics(from: normalizedStartDate, to: normalizedEndDate) { statistics, stop in
                        let stepCount: Double = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0.0
                        
                        if stepCount != 0 {
                            
                            let metric = MetricHistory()
                            metric.trackedValue = stepCount.roundToTwoStr()
                            metric.trackedValueUnit = "steps" //KUnit.costeunt().unitString
                            metric.dateOfEntry = statistics.startDate
                            metric.uniqueId = UUID() //UUID(uuidString: statistics.startDate.getStringFromDate(dateFormat: sqlTimeStampFormat))

                            
                            dailyStepsArray.append(metric)
                        }
                    }
                    
                    // Sort by date
                    dailyStepsArray.sort { ($0.dateOfEntry ?? Date()) < ($1.dateOfEntry ?? Date()) }
                    completion(dailyStepsArray)
                }
            }
            
            healthStore.execute(query)
        }
    
    
    private func fetchSleepData(from startDate: Date, to endDate: Date, completion: @escaping ([SleepData], Error?) -> Void) {
            guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
                completion([], NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create sleep analysis type"]))
                return
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion([], error)
                    }
                    return
                }
                
                guard let samples = samples as? [HKCategorySample] else {
                    DispatchQueue.main.async {
                        completion([], NSError(domain: "HealthKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not cast samples to HKCategorySample"]))
                    }
                    return
                }
                
                let sleepData = samples.map { sample in
                    
                    SleepData(
                        startDate: sample.startDate,
                        endDate: sample.endDate,
                        duration: sample.endDate.timeIntervalSince(sample.startDate),
                        sleepAnalysis: HKCategoryValueSleepAnalysis(rawValue: sample.value) ?? .inBed,
                        source: sample.sourceRevision.source.name,
                        uuid: sample.uuid
                    )
                }
                
                DispatchQueue.main.async {
                    completion(sleepData, nil)
                }
            }
            
            healthStore.execute(query)
        }
    
    private func fetchSleepSessions(from startDate: Date, to endDate: Date, completion: @escaping ([MetricHistory]) -> Void) {
           fetchSleepData(from: startDate, to: endDate) { sleepData, error in
               if let error = error {
                   completion([])
                   return
               }
               
               let sessions = self.generateSleepSessions(from: sleepData)
               completion(sessions)
           }
       }
       
    private func generateSleepSessions(from sleepData: [SleepData]) -> [MetricHistory] {
           let calendar = Calendar.current
           
           // Group by sleep session (considering cross-midnight scenarios)
           let groupedBySleepDate = Dictionary(grouping: sleepData) { data in
               getSleepDate(for: data.startDate, calendar: calendar)
           }
           
        
           let sessions: [MetricHistory] = groupedBySleepDate.compactMap { sleepDate, sessionData in
               let inBedData = sessionData.filter { $0.sleepAnalysis == .inBed }
               
               let asleepData = sessionData.filter {
                   var isSleepAnalysis = $0.sleepAnalysis == .asleep
                   
                   
                   if #available(iOS 16.0, *) {
                       
                       isSleepAnalysis = isSleepAnalysis || $0.sleepAnalysis == .asleepREM || $0.sleepAnalysis == .asleepCore || $0.sleepAnalysis == .asleepDeep || $0.sleepAnalysis == .asleepUnspecified
                       
                   }
                   
                   return isSleepAnalysis
               }
               
               guard let earliestBedtime = inBedData.min(by: { $0.startDate < $1.startDate })?.startDate,
                     let latestWakeTime = inBedData.max(by: { $0.endDate < $1.endDate })?.endDate else {
                   return nil
               }
               
               
               
               let totalTimeInBed = inBedData.reduce(0) { $0 + $1.duration }
               let totalSleepTime = asleepData.reduce(0) { $0 + $1.duration }
               let sleepEfficiency = totalTimeInBed > 0 ? totalSleepTime / totalTimeInBed : 0
               
               // Check if sleep crosses midnight
               let bedtimeDay = calendar.startOfDay(for: earliestBedtime)
               let wakeTimeDay = calendar.startOfDay(for: latestWakeTime)
               let crossesMidnight = !calendar.isDate(bedtimeDay, inSameDayAs: wakeTimeDay)
                
               let history = MetricHistory()
               
               
               history.trackedValue = (totalSleepTime / 3600.0).roundToTwoStr()
               history.trackedValueUnit = "hrs"
               history.dateOfEntry = earliestBedtime
               history.uniqueId = UUID()
               //history.uniqueId = UUID()
               
               
               return history
//
//               return SleepSession(
//                   sleepDate: sleepDate,
//                   bedtime: earliestBedtime,
//                   wakeTime: latestWakeTime,
//                   totalSleepHours: totalSleepTime / 3600.0,
//                   totalTimeInBedHours: totalTimeInBed / 3600.0,
//                   sleepEfficiency: sleepEfficiency,
//                   crossesMidnight: crossesMidnight
//               )
           }
            
        return sessions.filter{$0.trackedValue?.toDoubleOrNil() ?? 0 != 0}.sorted { $0.dateOfEntry ?? Date() < $1.dateOfEntry  ?? Date()}
       }
    
    // Helper function to determine the sleep date
    // If sleep starts after 6 PM (18:00), attribute it to that day
    // If sleep starts before 6 PM, it's likely a nap or continuation, attribute to that day
    private func getSleepDate(for date: Date, calendar: Calendar) -> Date {
        let startDate = date
        let hour = calendar.component(.hour, from: startDate)
            
            // If sleep starts at 6 PM or later (18:00-23:59), it's nighttime sleep for that day
            // If sleep starts before 6 PM but after midnight (00:00-17:59), check if it's likely continuation
        if hour >= 18 {
            // Evening sleep - attribute to current day
            return calendar.startOfDay(for: startDate)
        } else if hour < 12 {
                // Early morning sleep (00:00-11:59) - likely continuation from previous night
            // Attribute to previous day
            let previousDay = calendar.date(byAdding: .day, value: -1, to: startDate)!
            return calendar.startOfDay(for: previousDay)
        } else {
            // Afternoon sleep (12:00-17:59) - likely a nap, attribute to current day
            return calendar.startOfDay(for: startDate)
        }
    }
    func processBackgroundData(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Implementation for background processing
        completion(.success(true))
    }
}



enum HealthMetric: CaseIterable {
    case steps
    case heartRate
    case activeEnergy
    case distance
    case weight
    case height
    case bmi
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case temperature
    case bloodGlucose
    case sleep

    
    var objectType: HKObjectType {
        switch self {
        case .steps:
            return HKObjectType.quantityType(forIdentifier: .stepCount)!
        case .heartRate:
            return HKObjectType.quantityType(forIdentifier: .heartRate)!
        case .weight:
            return HKObjectType.quantityType(forIdentifier: .bodyMass)!
        case .height:
            return HKObjectType.quantityType(forIdentifier: .height)!
        case .activeEnergy:
            return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        case .distance:
            return HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        case .bloodPressureSystolic:
            return HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!
        case .bloodPressureDiastolic:
            return HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        case .temperature:
            return HKObjectType.quantityType(forIdentifier: .bodyTemperature)!
        case .bloodGlucose:
            return HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
        case .sleep:
            return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        case .bmi:
            return HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
        }
    }
    
    var quantityType: HKQuantityType {
        switch self {
        case .steps:
            return HKObjectType.quantityType(forIdentifier: .stepCount)!
        case .heartRate:
            return HKObjectType.quantityType(forIdentifier: .heartRate)!
        case .weight:
            return HKObjectType.quantityType(forIdentifier: .bodyMass)!
        case .height:
            return HKObjectType.quantityType(forIdentifier: .height)!
        case .activeEnergy:
            return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        case .distance:
            return HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        case .bloodPressureSystolic:
            return HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!
        case .bloodPressureDiastolic:
            return HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        case .temperature:
            return HKObjectType.quantityType(forIdentifier: .bodyTemperature)!
        case .bloodGlucose:
            return HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
        case .sleep:
            return HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
        case .bmi:
            return HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
        }
    }
    
    
    func getUnit(selectedUnitMetric: String? = nil) -> HKUnit {
        
        switch self {
        case .steps:
            return .count()
        case .heartRate:
            return HKUnit.count().unitDivided(by: .minute())
        case .weight:
            if VitalUtil.getPatientVitalUnit() == vitalUnitMetric || selectedUnitMetric == vitalUnitMetric {
                return .gramUnit(with: .kilo)
            }
            else{
                return .pound()
            }
        case .height:
            if VitalUtil.getPatientVitalUnit() == vitalUnitMetric || selectedUnitMetric == vitalUnitMetric{
                return .meterUnit(with: .centi)
            }
            else{
                return .inch()
            }
        case .activeEnergy:
            return .kilocalorie()
        case .distance:
            return .meter()
        case .bloodPressureSystolic, .bloodPressureDiastolic:
            return .millimeterOfMercury()
        case .temperature:
            if VitalUtil.getPatientVitalUnit() == vitalUnitMetric || selectedUnitMetric == vitalUnitMetric {
                return .degreeCelsius()
            }
            else{
                return .degreeFahrenheit()
            }
        case .bloodGlucose:
            return .gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
        case .sleep:
            return .hour()
        case .bmi:
            return .count()
        }
    
    }

    static func getAllHealthMetric() -> [HealthMetric] {
        var metricList:[HealthMetric] = []
        metricList.append(.weight)
        metricList.append(.height)
        metricList.append(.bmi)
        metricList.append(.bloodPressureSystolic)
        metricList.append(.bloodPressureDiastolic)
        metricList.append(.temperature)
        metricList.append(.heartRate)
        metricList.append(.bloodGlucose)
        metricList.append(.sleep)
        metricList.append(.steps)
        return metricList
    }
    static func getHealthMetric(from modelId: String) -> [HealthMetric]? {
        var metricList:[HealthMetric] = []
        
        if modelId == wellnessGeneralModelId {
            metricList.append(.weight)
            metricList.append(.height)
            metricList.append(.bmi)
        }
        else if modelId == wellnessBPModelId {
            metricList.append(.bloodPressureSystolic)
            metricList.append(.bloodPressureDiastolic)
        }
        else if modelId == wellnessTemperatureModelId {
            metricList.append(.temperature)
        }
        else if modelId == wellnessPulseModelId {
            metricList.append(.heartRate)
        }
        else if modelId == wellnessBloodGlucoseModelId {
            metricList.append(.bloodGlucose)
        }
        else if modelId == wellnessSleepModelId {
            metricList.append(.sleep)
        }
        else if modelId == wellnessStepModelId {
            metricList.append(.steps)
        }
        
        else{
            return nil
        }
        
        
        return metricList
    }
    
    func getTrackerName() -> String {
        
        switch self {
        case .steps:
            return wellnessOtherModelId
        case .heartRate:
            return wellnessPulseModelId
        case .weight:
            return wellnessGeneralModelId
        case .height:
            return wellnessGeneralModelId
        case .activeEnergy:
            return ""
        case .distance:
            return ""
        case .bloodPressureSystolic, .bloodPressureDiastolic:
            return wellnessBPModelId
        case .temperature:
            return wellnessTemperatureModelId
        case .bloodGlucose:
            return wellnessBloodGlucoseModelId
        case .sleep:
            return wellnessOtherModelId
        case .bmi:
            return wellnessGeneralModelId
        }
    }
    
    func getMetricName() -> String {
        
        switch self {
        case .steps:
            return wellnessStepModelId
        case .heartRate:
            return wellnessPulseModelId
        case .weight:
            return wellnessWeightModelId
        case .height:
            return wellnessHeightModelId
        case .activeEnergy:
            return ""
        case .distance:
            return ""
        case .bloodPressureSystolic:
            return wellnessSystolicModelId
        case .bloodPressureDiastolic:
            return wellnessDiastolicModelId
        case .temperature:
            return wellnessTemperatureModelId
        case .bloodGlucose:
            return ""
        case .sleep:
            return wellnessSleepModelId
        case .bmi:
            return wellnessBMIModelId
        }
    }
    

    
    static func unit(for quantityType: HKQuantityType) -> HKUnit {
        let metric = HealthMetric.allCases.first { $0.quantityType.identifier == quantityType.identifier }
        return metric?.getUnit() ??  .count()
    }
}


struct SleepData {
        let startDate: Date
        let endDate: Date
        let duration: TimeInterval
        let sleepAnalysis: HKCategoryValueSleepAnalysis
        let source: String
        let uuid: UUID
        
        var durationInHours: Double {
            return duration / 3600.0
        }
        
        var sleepType: String {
            switch sleepAnalysis {
            case .inBed:
                return "In Bed"
            case .asleep , .asleepREM , .asleepCore , .asleepDeep:
                return "Asleep"
            case .awake:
                return "Awake"
             default:
                return "Unknown"
            }
        }
    }
