//
//  ReceiptTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 30/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ReceiptTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var facilityNameLabel: UILabel!
    @IBOutlet weak var amountNameLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var receiptNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setFontNormal()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFontNormal()
    {
        dateLabel.font = UIFont.systemFont(ofSize:FONT_SIZE_SMALL, Weight: .regular)
        facilityNameLabel.font = UIFont.systemFont(ofSize:FONT_SIZE_MEDIUM, Weight: .regular)
        amountNameLabel.font = UIFont.systemFont(ofSize:FONT_SIZE_NORMAL, Weight: .regular)
        amountValueLabel.font = UIFont.systemFont(ofSize:FONT_SIZE_NORMAL, Weight: .regular)
        receiptNumberLabel.font = UIFont.systemFont(ofSize:FONT_SIZE_NORMAL, Weight: .regular)
    }
    
    
}
