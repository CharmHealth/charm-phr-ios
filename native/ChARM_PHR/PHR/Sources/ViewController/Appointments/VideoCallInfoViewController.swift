//
//  VideoCallInfoViewController.swift
//  phr
//
//  Created by Raghul D on 10/09/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

class VideoCallInfoViewController: UIViewController {
    
    @objc lazy var videoCallInfoView: VideoCallInfoView = VideoCallInfoView(delegate: self)
    
    var zoomCredentials:ZoomCredentials? = nil
    weak var delegate:VideoCallInfoViewControllerDelegate? = nil
    
    private var isCopied = false
    private var isWarningShowed = false
    
    override func viewDidLoad() {
        self.view.addSubview(videoCallInfoView)
        videoCallInfoView.addConstraintPostViewLoad()
        
        videoCallInfoView.proceedBtn.addTarget(self, action: #selector(proceedToVideoCall), for: .touchUpInside)
        videoCallInfoView.copyBtn.addTarget(self, action: #selector(copyPasscode), for: .touchUpInside)
        
        self.view.setBackgroundColor(bgColor: 0x00000066)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
        videoCallInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doNothing)))
        
    }
    
    @objc func doNothing(){// It does nothing. Popup dismissal should not happen while clicking videoCallInfoView hence adding this gesture listener
        
    }
    @objc func dismissView(){
        dismiss(animated: true)
        delegate?.videoCallInfoDismissed()
    }
    
    @objc func proceedToVideoCall(){
        
        if isCopied || isWarningShowed {
            dismiss(animated: true)
            delegate?.proceedToVideoCall()
            return
        }
        
        isWarningShowed = true
        CharmUtil.showToast(controller: self, message: getString(key: "com.charmphr.opentok.error"), seconds: 2)

    }
    
    @objc func copyPasscode(){
        let pwd = zoomCredentials?.password ?? ""
        
        if pwd.isNotBlank() {
            isCopied = true
            UIPasteboard.general.string = pwd
            videoCallInfoView.onPasscodeCopied()
        }
    }
}

protocol VideoCallInfoViewControllerDelegate: AnyObject {
    func proceedToVideoCall()
    func videoCallInfoDismissed()
}
