//
//  KeyValueAndDateLabelTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 30/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class KeyValueAndDateLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        valueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
        dateLabel.font = .systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
