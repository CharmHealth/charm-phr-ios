//
//  PrimaryDataHandler.swift
//  phr
//
//  Created by Sankar Saravanan on 01/09/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

protocol PrimaryDataHandlerDelegate: AnyObject {
    func primaryDataHandlerDidReceiveData()
    func primaryDataHandlerDidReceiveError(error : Error)
}

import UIKit

class PrimaryDataHandler : CharmConnectionHandlerDelegate {
    
    private static var instance : PrimaryDataHandler!
    
    weak var delegate : PrimaryDataHandlerDelegate?
    
    var employmentStausArr : [String]?
    var countriesArr : [DataWithId]?
    var maritalStatusArr : [String]?
    var smokingStatusArr : [String]?
    var raceArr : [String]?
    var genderIdentityArr : [String]?
    var bloodGroupArr : [String]?
    var ethnicityArr : [String]?
    var birthSexArr: [String]?
    var inStatesArr : [String]?
    var usStatesArr: [String]?
    var auStatesArr: [String]?
    var languageArr : [String]?
    
    var isDemographicsDataReceived : Bool = false
    
    init() {}
    
    static var sharedInstance: PrimaryDataHandler
    {
        if instance == nil
        {
            instance = PrimaryDataHandler()
        }
        return instance
    }
    
    func fetchPrimaryData()
    {
        let charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler.fetchDemographicRealtedStatic(identificationKey: "fetchDemographicRealtedStatic")
    }
    
    class func resetInstance (){
        PrimaryDataHandler.instance = nil
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if PrimaryDataHandler.instance == nil{
            PrimaryDataHandler.instance = PrimaryDataHandler()
        }
        if identificationKey == "fetchDemographicRealtedStatic"
        {
            if let dict = jsonObject.getAsJsonObject("output_string"){
                
                PrimaryDataHandler.sharedInstance.birthSexArr = dict.getAsStringArray("BIRTH_SEX")
                PrimaryDataHandler.sharedInstance.employmentStausArr = dict["EMPLOYMENT_STATUS"] as? [String]
                PrimaryDataHandler.sharedInstance.maritalStatusArr = dict.getAsStringArray("MARITAL_STATUS")
                PrimaryDataHandler.sharedInstance.smokingStatusArr = dict.getAsStringArray("SMOKING_STATUS")
                PrimaryDataHandler.sharedInstance.raceArr = dict.getAsStringArray("RACE")
                PrimaryDataHandler.sharedInstance.genderIdentityArr = dict.getAsStringArray("GENDER_IDENTITY")
                PrimaryDataHandler.sharedInstance.bloodGroupArr = dict.getAsStringArray("BLOOD_GROUP")
                PrimaryDataHandler.sharedInstance.ethnicityArr = dict.getAsStringArray("ETHNICITY")
                
                if let countryObj = dict.getAsJsonObject("COUNTRY"){
                    PrimaryDataHandler.sharedInstance.countriesArr = []
                    for (key,value) in countryObj  {
                        let countryObj = DataWithId()
                        countryObj.value = key
                        if let value = value as? String {
                            countryObj.key = value
                            PrimaryDataHandler.sharedInstance.countriesArr?.append(countryObj)
                        }
                    }
                    
                    PrimaryDataHandler.sharedInstance.countriesArr?.sort{
                        $0.value < $1.value
                    }
                }
                PrimaryDataHandler.sharedInstance.isDemographicsDataReceived = true
            }
        }

        if PrimaryDataHandler.hasAllData()
        {
            PrimaryDataHandler.instance?.delegate?.primaryDataHandlerDidReceiveData()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        delegate?.primaryDataHandlerDidReceiveError(error: error)
    }
    
    class func hasAllData() -> Bool
    {
        if let primaryDataHandler = PrimaryDataHandler.instance {
            return primaryDataHandler.isDemographicsDataReceived
        }
        return false
    }
}
