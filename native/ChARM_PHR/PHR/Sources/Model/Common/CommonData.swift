//
//  CommonData.swift
//  phr
//
//  Created by Dhanuprasanya P on 29/01/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

//Model for PushNotification Related Data
class PushNotificationDetailsPOJO
{
    var nfid : String?
    var insid : String?
    var osInfo : String?
    var deviceInfo : String?
    var apnsMode : String?
    var appVersion : String?
    var deviceuid : String?
    var mode : Int = 1 //1 for iOS & 0 for android
}
