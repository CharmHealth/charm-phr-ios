//
//  AnnouncementCollectionViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 11/01/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import UIKit

class AnnouncementCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var practiceDetailHeadingLabel: UILabel!
    @IBOutlet weak var practiceDetailValueLabel: UILabel!
    
    @IBOutlet weak var arrowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR)
        containerView.setWidth(constant: appDelegate.screenWidth - (X_SPACE*2))

        arrowImageView.image = #imageLiteral(resourceName: "ArrowRight")
        arrowHeightConstraint.constant = ARROW_IMAGE_VIEW_SIZE.height
        arrowWidthConstraint.constant = ARROW_IMAGE_VIEW_SIZE.width
        
        datelabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        datelabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        headingLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        headingLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_HEAVYDARK)
        practiceDetailHeadingLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        practiceDetailHeadingLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        practiceDetailValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        practiceDetailValueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: 0x000000CC)
        practiceDetailValueLabel.numberOfLines = 0
        practiceDetailHeadingLabel.text = getString(key: "com.charmphr.Announcement.PracticeDetails.title")
    }
    
    func changeItemToNotRead()  {
        
        headingLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        practiceDetailValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
    }
    
    func changeItemToRead()  {
        
        headingLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        practiceDetailValueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
    }

}
