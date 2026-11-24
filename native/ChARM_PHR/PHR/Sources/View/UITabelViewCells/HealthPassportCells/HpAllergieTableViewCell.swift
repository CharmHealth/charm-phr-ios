//
//  HpAllergieTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 30/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class HpAllergieTableViewCell: UITableViewCell {
    
    let MILD_TEXT_COLOR : UInt = 0xF6C001FF
    let MILD_BG_COLOR : UInt = 0xF6C0011A
    
    let MODERATE_TEXT_COLOR : UInt = 0xF68903FF
    let MODERATE_BG_COLOR : UInt = 0xF689030D
    
    let SEVERE_TEXT_COLOR : UInt = 0xD60100FF
    let SEVERE_BG_COLOR : UInt = 0xD601001F

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var valueLabelWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        valueLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        valueLabel.addCornerRadius(.SMALL)
        dateLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSeverityAsMild()
    {
        valueLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: MILD_BG_COLOR)
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: MILD_TEXT_COLOR)
    }
    func setSeverityAsModerate()
    {
        valueLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: MODERATE_BG_COLOR)
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: MODERATE_TEXT_COLOR)
    }
    func setSeverityAsSevere()
    {
        valueLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: SEVERE_BG_COLOR)
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: SEVERE_TEXT_COLOR)
    }
    
}
