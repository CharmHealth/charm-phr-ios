//
//  CustomObjectValueTransformer.swift
//  phr
//
//  Created by prathi-13964 on 07/12/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import UIKit
import Security

// Example usage: Generate a 256-bit (32-byte) key

@objc(CustomObjectTransformer)
class CustomObjectTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSObject.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value else { return nil }

        var data: Data?

        if let nsObject = value as? NSObject {
            data = try? NSKeyedArchiver.archivedData(withRootObject: nsObject, requiringSecureCoding: true)
        }else {
            data = nil
        }

        let encryptionKey: String? = mPHRCoreDataUtil.sharedInstance.encryptionKey

        if let encryptionKey =  encryptionKey{
            data = data?.aes256Encrypt(withKey: encryptionKey)
            return data
        }
        return nil
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        
        var data = value as? Data
        
        if let encryptionKey = mPHRCoreDataUtil.sharedInstance.encryptionKey{
            data = data?.aes256Decrypt(withKey: encryptionKey)
        }
        
        guard let data = data else { return nil }
        
        let allowedClasses: [AnyClass] = [PatientData.self, Practice.self, Reminder.self, ReminderFrequency.self, MedicationPOJO.self, Medication.self, PatientMedication.self, SupplementPOJO.self, Supplement.self, PatientSupplement.self, NSDate.self, NSNumber.self, NSString.self, NSArray.self]
        
        if let dateValue = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data){
            return dateValue
        }
        else {
            return nil
        }
    }
}
