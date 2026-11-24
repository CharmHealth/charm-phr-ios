//
//  InvoiceTableViewCell.swift
//  phr
//
//  Created by Sankar Saravanan on 29/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import UIKit

class InvoiceTableViewCell: UITableViewCell {

    @IBOutlet weak var facitityNameLable: UILabel!
    @IBOutlet weak var invoiceAmountLable: UILabel!
    @IBOutlet weak var discrepritionLable: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var cancelledLabel: UILabel!
    @IBOutlet weak var cancelledWidthCont: NSLayoutConstraint!
    @IBOutlet weak var arrowHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var arrowWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        facitityNameLable.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        invoiceAmountLable.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        discrepritionLable.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        discrepritionLable.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        dateLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        dateLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_LIGHT)
        dateLabel.textAlignment = .right
        arrowImageView.image = #imageLiteral(resourceName: "ArrowRight")
        
        arrowHeightConstraint.constant = ARROW_IMAGE_VIEW_SIZE.height
        arrowWidthConstraint.constant = ARROW_IMAGE_VIEW_SIZE.width
        
        cancelledLabel.text = getString(key: "com.charmphr.labsResults.cancelled")
        cancelledLabel.font = .systemFont(ofSize: FONT_SIZE_SMALL, Weight: .semibold)
        cancelledLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: 0xD60100FF)
        cancelledLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0xD601001A)
        cancelledLabel.layer.cornerRadius = 2
        cancelledLabel.layer.masksToBounds = true
        cancelledWidthCont.constant = cancelledLabel.sizeThatFits(CGSize(width: 1000, height: 1000)).width + 10
    }
    
    func setAmountLabelBoldAndRed()
    {
        facitityNameLable.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        invoiceAmountLable.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        invoiceAmountLable.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_RED)
    }
    
    func setAmountLabelBoldAndGreen()
    {
        facitityNameLable.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        invoiceAmountLable.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .semibold)
        invoiceAmountLable.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_GREEN)
    }
    
    func setAmountAsDefault()
    {
        facitityNameLable.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        invoiceAmountLable.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        invoiceAmountLable.textColor = .black
    }
    
    func setCancelled(isHidden : Bool)
    {
        cancelledLabel.isHidden = isHidden
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
