//
//  TextLableWithCheckmarkTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 11/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class TextLableWithCheckmarkTableViewCell: UITableViewCell {

    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var keyLabel: UILabel!
    var bgColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        keyLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        keyLabel.numberOfLines = 0
        checkmarkImageView.isHidden = true
        //checkmarkImageView.backgroundColor = .lightGray
        checkmarkImageView.image = #imageLiteral(resourceName: "Tick")
    }
    
    func isCheckmarkHidden(bool:Bool)
    {
        checkmarkImageView.isHidden = bool
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
