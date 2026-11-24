//
//  Section.swift
//  phrUITests
//
//  Created by Sankar Saravanan on 03/03/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import Foundation

class Section
{
    var name : String = ""
    var icon : String = ""
    var moduleGroup : String = ""
    var allowPhrEntry : Bool = false
    var sectionOrder : Int = 0
    var isEnable : Bool = false
    var section : String = ""
    var id : String = ""
    var configurable : Bool = false
    var isDefaultEnabled: Bool = false
    var unreadCount : Int = 0

    
    class func getSectionWithName(name : String) -> Section
    {
        let section = Section()
        section.name = name
        section.moduleGroup = OTHERS
        section.isEnable = true
        return section
    }
}

class SectionConfigList
{
    var sectionConfigMapList: [SectionPracticeMap] = []
}

class SectionPracticeMap
{
        var sectionConfigList: [Section] = []
        var practiceId: String? = nil
}


class Module {
        var moduleId:String =  ""
        var moduleName:String = ""
        //var moduleIconId: Int = 0
        var unreadCount: Int = 0
        var moduleServerId: String? = nil
        var isShown: Bool = true
        var moduleNameFromSection: String? = nil
        var position: Int = 0
        var groupNum:Int = 1
        var changeBg:Bool = false
        var showAsGrid:Bool = false
        var imageName: String? = nil
        var isBilling: Bool? = nil

    class func getModule(moduleID: String , modulekey: String,imageName:String? = nil , groupNum:Int = 0) -> Module{
        let module = Module()
        module.moduleId = moduleID
        module.moduleName = getString(key: modulekey)
        module.groupNum = groupNum
        module.imageName = imageName
        return module
    }
}
