//
//  ReminderNotificationMObj+CoreDataClass.swift
//  phr
//
//  Created by prathi-13964 on 13/08/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ReminderNotificationMObj)
public class ReminderNotificationMObj: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReminderNotificationMObj> {
        return NSFetchRequest<ReminderNotificationMObj>(entityName: "ReminderNotificationMObj")
    }
    
    @NSManaged public var createdDate: Date?
    @NSManaged public var notificationId: String?
    @NSManaged public var reminderIdList: String?
    
    func fillWithProperties(notificationId: String?, remininderIdArray: [String]){
        self.notificationId = notificationId
        self.reminderIdList = remininderIdArray.joined(separator: ",")
    }
    
    func updateProperties(remininderIdArray: [String]){
        self.reminderIdList = remininderIdArray.joined(separator: ",")
    }
}
