//
//  EncryptionValueTransformer.swift
//  phr
//
//  Created by prathi-13964 on 12/08/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation
import CommonCrypto

@objc(EncryptionValueTransformer)
class EncryptionValueTransformer: ValueTransformer {
   
    override class func transformedValueClass() -> AnyClass {
        return NSObject.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let value = value else { return nil }

        var data: Data?

        if let stringValue = value as? String {
            data = stringValue.data(using: .utf8)
        } else if let dateValue = value as? Date {
            data = try? NSKeyedArchiver.archivedData(withRootObject: dateValue, requiringSecureCoding: true)
        } else if let boolValue = value as? Bool {
            data = try? NSKeyedArchiver.archivedData(withRootObject: boolValue, requiringSecureCoding: true)
        } else if let intValue = value as? Int {
            data = try? NSKeyedArchiver.archivedData(withRootObject: intValue, requiringSecureCoding: true)
        } else {
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
        
        if let stringValue = String(data: data, encoding: .utf8) {
            return stringValue
        }
        else if let dateValue = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDate.self, from: data) as Date? {
            return dateValue
        }
        else if let boolValue = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSNumber.self, from: data) as? Bool? {
            return boolValue
        }
        else if let intValue = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSNumber.self, from: data) as? Int? {
            return intValue
        }
        else {
            return nil
        }
    }
}
