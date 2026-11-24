//
//  HKSyncConfirmViewController.swift
//  phr
//
//  Created by Raghul D on 03/03/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

import Foundation

protocol HKSyncConfirmVCDelegate: AnyObject {
    func onSyncConfirmed()
}

class HKSyncConfirmViewController: UIViewController {

    @objc lazy private var syncConfirmView: HKSyncConfirmView = HKSyncConfirmView(delegate: self)

    var vitalName: String = ""
    var recordCount: Int = 0
    var dateRange: String = ""

    weak var delegate: HKSyncConfirmVCDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: POPVC_BG_COLOR)

        self.view.addSubview(syncConfirmView)
        syncConfirmView.configure(vitalName: vitalName, dateRange: dateRange)
        syncConfirmView.addConstraintPostViewLoad()
    }

    // MARK: - HKSyncConfirmViewDelegate

    func onYesSyncClicked() {
        delegate?.onSyncConfirmed()
        self.dismiss(animated: true)
    }

    func onCancelClicked() {
        self.dismiss(animated: true)
    }
}
