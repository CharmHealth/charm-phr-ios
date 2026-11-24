//
//  KeyAndValueInVerticalTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 26/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class KeyAndValueInVerticalTableViewCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        valueLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        valueLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHTGRAY)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
