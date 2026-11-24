//
//  Images.swift
//  PHR
//
//  Created by Prathiba M on 07/05/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

class ImagesResult {
    var member: Provider?
    var practice: Practice?
    var photoOrig: String?
    var phrimageResultGrpId: String?
    var imageResultGrpId: String?
    var imageTestList: [ImageTest]?
    var date: Date?
    var status: String?
    var instruction: String?
    var isReviewed: Bool = false
    var type: String?
}

class ImageTest {
    var testId: String?
    var testCode: String?
    var testName: String?
    var imageTypeId: String?
    var isDeleted: Bool = false
}

class ImagesOrder {
    
    var filesize: String?
    var practice: Practice?
    var patientId: String?
    var date: Date?
    var fileId: String?
    var fileName: String?
    var contentType: String?
    var readStatus: Bool = false
    var fileType: String?
    var fileStatusId: String?
}
