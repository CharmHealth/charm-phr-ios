//
//  Support.swift
//  phr
//
//  Created by prathi-13964 on 30/11/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class SupportDetails{
    var subject: String? = nil
    var messageContent: String? = nil
    var messageContentType: String = "text"
    var category: String? = nil
    var fileIds: Array<String> = []
}

class SupportModel{
    
    var comboArray: [String] = []
    var tagNo: Int = 1
    var tagList: [Int] = []
    var buttonViewToTextViewMap = Dictionary<Int , Int>()
    var textFieldToLabelMap = Dictionary<Int , Int>()
    var textViewToLabelMap = Dictionary<Int, Int>()
    var attachmentArr: Array<[String : Any]> = []
    var fileNameToUrlMap = Dictionary<String, Any>()
    let ATTACHMENT_VIEW_TAG = 1111
    let activityIndicator = UIActivityIndicatorView()
    var alertList: [String] = []
    var attachmentDictArray: Array<[String: Any]> = []
    var attachmentDetailsArray: [[String: Any]] = []
    var fileIdArray: [String] = []
    var urlList: [NSURL] = []
    
    var subejct_0: String?
    var description_0: String?
    var subejct_1: String?
    var description_1: String?
    var subejct_2: String?
    var description_2: String?
    var selectedButtons: [UIButton] = []
    var description_3: String?
    var selectedSegmentName: String?
    let severityArray = ["None","Critical","Major","Minor"]
    var severitySelectedIndex: Int = 0
}
