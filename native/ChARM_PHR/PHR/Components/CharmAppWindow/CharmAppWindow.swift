//
//  CharmAppWindow.swift
//  phr
//
//  Created by Sankar Saravanan on 27/11/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol CharmAppWindowDelegate : AnyObject{
    func charmAppWindowIdeltimeEnded()
}

class CharmAppWindow: UIWindow {
    
    // in min
    var autoLockTime : Int?
    var idelTimer : Timer!
    weak var delegate : CharmAppWindowDelegate?

    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if event.allTouches != nil
        {
            let allTouches : Set<UITouch> = event.allTouches!
            
            if allTouches.count > 0
            {
                let phase : UITouch.Phase = allTouches.randomElement()!.phase
                if phase == .began || phase == .ended
                {
                    self.resetIdleTimer()
                }
            }
        }

    }
    
    
    func resetIdleTimer()
    {
        if (self.idelTimer != nil)
        {
            self.idelTimer.invalidate()
        }
        
        self.idelTimer = Timer.scheduledTimer(timeInterval:TimeInterval((self.autoLockTime == nil ? 10 : self.autoLockTime! )*60), target: self, selector: #selector(self.lockTheApplication), userInfo: nil, repeats: false)
        
    }
    
    @objc func lockTheApplication()
    {
        debugPrintLog("lockTheApplication called")
        
        if isMeetingInProgress() {
            resetIdleTimer()
        }
        else{
            delegate?.charmAppWindowIdeltimeEnded()
            resetIdleTimer()
        }
        
    }
}
