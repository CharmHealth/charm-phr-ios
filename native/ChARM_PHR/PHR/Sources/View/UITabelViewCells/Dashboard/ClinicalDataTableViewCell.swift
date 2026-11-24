//
//  ClinicalDataTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 17/01/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ClinicalDataTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabelWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailImgeView: UIImageView!
    @IBOutlet weak var numbersLabel: UILabel!
    
    let redColor : UInt = 0xF25369FF
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        valueLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        
        numbersLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: redColor)
        numbersLabel.text = ""
        numbersLabel.textColor = .white
        numbersLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .bold)
        numbersLabel.textAlignment = .center
        numbersLabel.layer.cornerRadius = numbersLabel.frame.width / 2
        numbersLabel.layer.masksToBounds = true
        
        
    }
    
    func hideNumberLabel()
    {
        numbersLabel.text = ""
        numbersLabel.isHidden = true
    }
    
    func showNumberLabel(string : String)
    {
        numbersLabel.text = string
        numbersLabel.isHidden = false
        valueLabelWidthContraint.constant = numbersLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10 >= 23 ? numbersLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10 : 23
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
