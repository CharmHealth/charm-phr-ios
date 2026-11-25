//
//  QuickAddSheetViewController.swift
//  PHR
//
//  Created by Prathiba Murugesan on 17/11/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

import UIKit

struct QuickAddOption {
    let title: String
    let image: UIImage?
    let handler: () -> Void
}

// Shared "+" options UI. Presented as a bottom sheet so it needs no source view, which lets the
// iOS 27 UITab and the pre-iOS 27 floating UIButton trigger exactly the same UI.
final class QuickAddSheetViewController: UIViewController {

    private let options: [QuickAddOption]

    private let contentStack = UIStackView()

    private let ROW_MIN_HEIGHT: CGFloat = 56
    private let HORIZONTAL_INSET: CGFloat = 20
    private let TOP_INSET: CGFloat = 28
    private let BOTTOM_INSET: CGFloat = 16

    init(options: [QuickAddOption]) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupContent()
        configureSheet()
    }

    private func setupContent(){
        contentStack.axis = .vertical
        contentStack.spacing = 8

        for (index, option) in options.enumerated() {
            contentStack.addArrangedSubview(makeRow(for: option, index: index))
        }

        view.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.topAnchor, constant: TOP_INSET),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: HORIZONTAL_INSET),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -HORIZONTAL_INSET),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -BOTTOM_INSET)
        ])
    }

    private func makeRow(for option: QuickAddOption, index: Int) -> UIButton {
        var config = UIButton.Configuration.gray()
        config.image = option.image
        config.imagePlacement = .leading
        config.imagePadding = 14
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(textStyle: .title3)
        let iconColor = UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR)
        config.baseForegroundColor = iconColor
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in iconColor }
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        config.attributedTitle = AttributedString(option.title, attributes: AttributeContainer([
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label
        ]))

        let row = UIButton(configuration: config)
        row.contentHorizontalAlignment = .leading
        row.tag = index
        row.accessibilityLabel = option.title
        row.addTarget(self, action: #selector(rowTapped(_:)), for: .touchUpInside)
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: ROW_MIN_HEIGHT).isActive = true

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = iconColor
        chevron.isUserInteractionEnabled = false
        row.addSubview(chevron)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16)
        ])

        return row
    }

    private func configureSheet(){
        guard let sheet = sheetPresentationController else { return }

        if #available(iOS 16.0, *) {
            sheet.detents = [.custom(identifier: .init("quickAddFitted")) { [weak self] context in
                guard let self else { return context.maximumDetentValue * 0.4 }
                return min(self.fittedContentHeight(), context.maximumDetentValue)
            }]
        } else {
            sheet.detents = [.medium()]
        }
        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 24
    }

    private func fittedContentHeight() -> CGFloat {
        let width = (view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width) - HORIZONTAL_INSET * 2
        let stackHeight = contentStack.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return TOP_INSET + stackHeight + BOTTOM_INSET
    }

    @objc private func rowTapped(_ sender: UIButton){
        let option = options[sender.tag]
        // Run the action after the sheet is gone so pushes/presents start from a clean state.
        dismiss(animated: true) {
            option.handler()
        }
    }
}
