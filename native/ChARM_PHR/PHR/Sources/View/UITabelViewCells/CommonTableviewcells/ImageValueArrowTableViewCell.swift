//
//  WellnessTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 06/12/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ImageValueArrowTableViewCell: UITableViewCell {

   
    
    @IBOutlet weak var parentView: UIView!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    
   
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    
    @IBOutlet weak var valueImageView: ImageViewWithInitailsView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        arrowImageView.image = #imageLiteral(resourceName: "ArrowRight")
        nameLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        
        arrowImageView.setWidth(constant: ARROW_IMAGE_VIEW_SIZE.width)
        arrowImageView.setHeight(constant: ARROW_IMAGE_VIEW_SIZE.height)
        
        parentView.addCornerRadius(.SMALL)
        parentView.layer.borderWidth = BORDER_WIDTH
        parentView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: BORDER_COLOR).cgColor
        parentView.backgroundColor = .white
        
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
