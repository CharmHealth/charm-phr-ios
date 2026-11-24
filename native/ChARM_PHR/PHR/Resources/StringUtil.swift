//
//  StringUtil.swift
//  phr
//
//  Created by Sankar Saravanan on 25/01/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import Foundation

struct StringUtil {
    
    static func getNameWithPrefixAndFullName(fullName : String , prefix : String?) -> String
    {
        var name = ""
        if !isNilOrEmpty(string:prefix) && !fullName.hasPrefix(prefix!)
        {
            name.append(prefix!)
            name.append(". ")
        }
        name.append(fullName)
        return name
    }
    
}

