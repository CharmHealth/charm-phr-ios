//
//  KeyAndDateLabelTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 02/03/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import UIKit

class KeyAndDateLabelTableViewCell: UITableViewCell {

    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    @IBOutlet weak var arrowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        keyLabel.numberOfLines = 0
        dateLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        dateLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        arrowImageView.image = #imageLiteral(resourceName: "ArrowRight")
        
        arrowHeightConstraint.constant = ARROW_IMAGE_VIEW_SIZE.height
        arrowWidthConstraint.constant = ARROW_IMAGE_VIEW_SIZE.width
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
