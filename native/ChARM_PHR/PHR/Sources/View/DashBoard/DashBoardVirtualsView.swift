//
//  DashBoardTopView.swift
//  ChARM Phr
//
//  Created by Sankar Saravanan on 08/10/19.
//  Copyright © 2019 Sankar Saravanan. All rights reserved.
//

import UIKit

class DashBoardVirtualsView: UIView {

    let FONT_SIZE_VERYSMALL : CGFloat = 10
    
    @IBOutlet var containerView: DashBoardVirtualsView!
    @IBOutlet weak var virtualsImageView: UIImageView!
    @IBOutlet weak var virtualsNameLabel: UILabel!
    @IBOutlet weak var virtualsValueLabel: UILabel!
    @IBOutlet weak var virtualsDateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubViews()
    }

    func initSubViews()
    {
        Bundle.main.loadNibNamed("DashBoardVirtualsView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        virtualsNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_SMALL, Weight: .regular)
        virtualsValueLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        virtualsDateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_VERYSMALL, Weight: .regular)
    }

}

