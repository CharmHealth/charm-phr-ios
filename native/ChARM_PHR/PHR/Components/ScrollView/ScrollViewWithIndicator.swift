//
//  ScrollViewWithIndicator.swift
//  PHR
//
//  Created by prathi-13964 on 30/04/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import UIKit

class ScrollViewWithIndicator: UIScrollView, UIScrollViewDelegate {
    
    private let customIndicator = UIView()
    private let indicatorWidth: CGFloat = 3
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        showsVerticalScrollIndicator = false // Hide the default indicator
        delegate = self
        customIndicator.backgroundColor = .lightGray
        customIndicator.layer.cornerRadius = indicatorWidth / 2
        addSubview(customIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicator()
    }

    private func updateIndicator() {
        guard contentSize.height > bounds.height else {
            customIndicator.isHidden = true
            return
        }

        customIndicator.isHidden = false

        let visibleHeight = bounds.height
        let contentHeight = contentSize.height
        let yOffset = contentOffset.y

        let indicatorHeight = max((visibleHeight / contentHeight) * visibleHeight, 40)
        let maxIndicatorY = visibleHeight - indicatorHeight
        let maxScrollOffset = contentHeight - visibleHeight

        let indicatorY = (yOffset / maxScrollOffset) * maxIndicatorY
        let padding: CGFloat = 2

        customIndicator.frame = CGRect(
            x: bounds.width - indicatorWidth - padding,
            y: indicatorY + contentOffset.y,
            width: indicatorWidth,
            height: indicatorHeight
        )
        bringSubviewToFront(customIndicator)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateIndicator()
    }
}


class TableViewWithIndicator: UITableView, UITableViewDelegate{

    private let customIndicator = UIView()
    private let indicatorWidth: CGFloat = 3

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        showsVerticalScrollIndicator = false // Hide default indicator
        delegate = self
        customIndicator.backgroundColor = .lightGray
        customIndicator.layer.cornerRadius = indicatorWidth / 2
        addSubview(customIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCustomIndicator()
    }

    private func updateCustomIndicator() {
        guard contentSize.height > bounds.height else {
            customIndicator.isHidden = true
            return
        }

        customIndicator.isHidden = false

        let visibleHeight = bounds.height
        let contentHeight = contentSize.height
        let yOffset = contentOffset.y

        let indicatorHeight = max((visibleHeight / contentHeight) * visibleHeight, 40)
        let maxIndicatorY = visibleHeight - indicatorHeight
        let maxScrollOffset = contentHeight - visibleHeight
        let indicatorY = (yOffset / maxScrollOffset) * maxIndicatorY

        
        let padding: CGFloat = 2

        customIndicator.frame = CGRect(
            x: bounds.width - indicatorWidth - padding,
            y: indicatorY + contentOffset.y,
            width: indicatorWidth,
            height: indicatorHeight
        )

        bringSubviewToFront(customIndicator)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCustomIndicator()
    }
}

