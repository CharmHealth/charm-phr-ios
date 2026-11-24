//
//  Messages.swift
//  phr
//
//  Created by Sankar Saravanan on 01/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import Foundation


class Messages : DateDelegate{
    func getDate() -> Date {
        return messageDate ?? Date()
    }
    
    var messageId: String?
    var time: String?
    var subject: String?
    var contentFile: String?
    var type: String?
    var priority: String?
    var hasAttachments: Bool = false
    var practicePatientId: String?
    var messageType : String?
    // added
    var practiceId : String?
    var messageReceipients : MessageReceipients? = nil
    var dateString : String?
    var timeString : String?
    var messageDate: Date?
    var msgAttachmentList : Array<MessagesAttachmentsMap> = []
    var arrayOfRecivers : Array<Provider> = []
    var ownerId: String?
    var senderImg: UIImage? = nil
}

class MessageReceipients {
    var messageRecipientId: String?
    var messageId: String?
    var fromId: String?
    var fromSpace: String?
    var fromName: String?
    var toId: String?
    var toSpace: String?
    var toName: String?
    var status: String?
}

class MessagesAttachmentsMap {
    var attachmentId: String?
    var messageId: String?
    var attachmentName: String?
    var attchmentLocation: String?
    var attachmentLocalURL: URL?
}

class ComposeMessage {
    var subject: String? = nil
    var content: String? = nil
    var patientId: String? = nil
    var practiceId: String? = nil
    var providerList: [Provider] = []
    var memberGroup: MemberGroup? = nil
    var fileIdList:[String] = []
    var ownerId: String? = nil
}

class MDPagiationDataResponse<Element: DateDelegate>{
  
    var data:[Element]? = nil
    var page: Int = 1
    var perPage: Int = 0
    var hasMore: [String:Bool] = [:]
}
