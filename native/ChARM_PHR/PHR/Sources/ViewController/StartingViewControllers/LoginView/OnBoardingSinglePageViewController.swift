//
//  OnBoardingSinglePageViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 28/07/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class OnBoardingSinglePageViewController: UIViewController {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    var index : Int!
    
    init(index : Int) {
        super.init(nibName: nil, bundle: nil)
        
        self.index = index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView = UIView()

        containerView.addSubview(imageView)

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 20, Weight: .bold)
        containerView.addSubview(titleLabel)

        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 2
        detailLabel.font = .systemFont(ofSize: 16, Weight: .semibold)
        containerView.addSubview(detailLabel)

        imageView.setTop(offSet: 20)
        imageView.setLeft(offSet: 53)
        imageView.setRight(offSet: -53)
        let htConst : NSLayoutConstraint!
        if isCustomApp()
        {
            htConst = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self.imageView, attribute: .width, multiplier: 1, constant: 0)
        }
        else
        {
            htConst = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self.imageView, attribute: .width, multiplier: 1.18, constant: 0)
        }
        containerView.addConstraint(htConst)
        imageView.setBottomRelatedToView(offSet: -25, relatedView: titleLabel, relatedAttribute: .top)

        titleLabel.setLeft(offSet: 15)
        titleLabel.setRight(offSet: -15)
        titleLabel.setBottomRelatedToView(offSet: -15, relatedView: detailLabel, relatedAttribute: .top)

        detailLabel.setLeft(offSet: 15)
        detailLabel.setRight(offSet: -15)
        detailLabel.setBottom(offSet: -20)

        self.view.addSubview(containerView)

        containerView.setLeft(offSet: 0)
        containerView.setRight(offSet: 0)
        containerView.setCenterY()
        
    }
}
