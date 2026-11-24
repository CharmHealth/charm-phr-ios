//
//  KeyLabelTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 12/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class KeyLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        keyLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        keyLabel.numberOfLines = 0
        arrowImageView.image = #imageLiteral(resourceName: "ArrowRight")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
