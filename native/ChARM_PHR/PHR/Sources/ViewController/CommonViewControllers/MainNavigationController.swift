//
//  MainNavigationController.swift
//  ChARM Phr
//
//  Created by Sankar Saravanan on 04/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import UIKit


class MainNavigationController: UINavigationController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLargeTitle(enable: false)
        self.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 34, Weight: .bold) ]
        
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 17, Weight: .semibold) ]
        
        self.navigationBar.barTintColor = UIColorFromRGB(rgbValueWithAlpha: LIGHT_GRAY_BG_COLOR)
        self.view.tintColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        
    }
}

extension UIViewController
{
    func setLargeTitle(enable : Bool )
    {
        self.navigationItem.largeTitleDisplayMode = enable ? .automatic : .never
    }
}
