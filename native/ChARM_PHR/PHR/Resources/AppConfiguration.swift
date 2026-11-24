//
//  AppConfiguration.swift
//  phr
//
//  Created by Sankar Saravanan on 11/05/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

public class AppConfig{

    private static var config: AppConfig!
    static var sharedInstance: AppConfig {
        if config == nil {
            config = AppConfig()
            config?.setAppConfig()
        }
        return config
    }
    
    var appDisplayName : String!
    var isCustomBrandApp : Bool = false
    var customAppPracticeId : String!
    var welcomeScreenName : String!
    var appicon : UIImage!

    func setAppConfig()
    {
        self.appDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Charm mPHR"
        self.welcomeScreenName = Bundle.main.infoDictionary?["WELCOME_SCREEN_DISPLAY_NAME"] as? String ?? "Charm Patient Portal"
        if Bundle.main.infoDictionary?["IS_CUSTOM_BRAND_APP"] as? String == "true"
        {
            self.isCustomBrandApp = true
        }else
        {
            self.isCustomBrandApp = false
        }
        
        self.customAppPracticeId = Bundle.main.infoDictionary?["PRACTICE_ID"] as? String ?? ""
        
        self.appicon = UIImage(named: "OnBoardingWelcome") ?? #imageLiteral(resourceName: "OnBoardingWelcome")
    }
}
