//
//  ImageViewWithInitailsView.swift
//  phr
//
//  Created by Sankar Saravanan on 09/07/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ImageViewWithInitailsView: UIView {
    
    let imageView = UIImageView()
    let initialLabel = UILabel()

    init() {
        super.init(frame: .zero)
        createSubViews(initials: "", image: nil)
    }
    
    init(initials: String , image : UIImage?) {
        super.init(frame: .zero)
        createSubViews(initials: initials, image: image)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        createSubViews(initials: "", image: nil)
    }
    
    func createSubViews(initials: String , image : UIImage?)
    {
        initialLabel.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .bold)
        initialLabel.textAlignment = .center
        super.addSubview(initialLabel)
        
        super.addSubview(imageView)
        
        initialLabel.setTop(offSet: 0)
        initialLabel.setLeft(offSet: 0)
        initialLabel.setRight(offSet: 0)
        initialLabel.setBottom(offSet: 0)
        
        imageView.setTop(offSet: 0)
        imageView.setLeft(offSet: 0)
        imageView.setRight(offSet: 0)
        imageView.setBottom(offSet: 0)
        
        setInitialsAndImage(initials: initials, image: image)
    }
    
    func setInitialsAndImage(initials: String , image : UIImage?)
    {
        initialLabel.text = initials.uppercased()
        initialLabel.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: PHOTO_INITIAL_BG_COLOR)
        initialLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        imageView.image = image
               
        if image == nil
        {
            imageView.isHidden = true
            initialLabel.isHidden = false
        }else
        {
            imageView.isHidden = false
            initialLabel.isHidden = true
        }
    }
    
    func setImage(image : UIImage)
    {
        setInitialsAndImage(initials: self.initialLabel.text!, image: image)
    }
    
}
