//
//  ImageResultTableViewCell.swift
//  PHR
//
//  Created by Prathiba M on 11/05/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

class ImageResultTableViewCell: UITableViewCell {
    
    private let itemView = ImageResultsItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    private func initViews(){
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(itemView)
        addConstraints()
    }
    
    private func addConstraints(){
        itemView.setLeft(offSet: 16)
        itemView.setRight(offSet: -16)
        itemView.setTop(offSet: 3)
        itemView.setBottom(offSet: -3)
    }
    
    func setValues(data: ImagesResult){
        itemView.dateLabel.text = data.date?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        let testNameList: [String] = data.imageTestList?.compactMap { $0.testName ?? ""} ?? []
        itemView.testNameLabel.text = testNameList.joined(separator: "\n")
        itemView.typeValueLabel.text = data.type ?? "-"
        itemView.reviewedByValueLabel.text = data.member?.fullName ?? "-"
        itemView.practiceNameLabel.text = data.practice?.practiceName ?? "-"
        
        if let instruction = data.instruction, instruction.isNotBlank() {
            itemView.instructionValueLabel.text = instruction
            itemView.instructionView.isHidden = false
            itemView.seperatorView.isHidden = false
        }
        else{
            itemView.instructionView.isHidden = true
            itemView.seperatorView.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class ImageResultsItemView: UIView{
    
    let dateLabel = UILabel()
    let testNameLabel = UILabel()
    let typeLabel = UILabel()
    let typeValueLabel = UILabel()
    let reviewedByLabel = UILabel()
    let reviewedByValueLabel = UILabel()
    let fromLabel = UILabel()
    let practiceNameLabel = UILabel()
    let verticalStacView = UIStackView()
    let seperatorView = UIView()
    let instructionView = UIView()
    let instructionLabel = UILabel()
    let instructionValueLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        
        self.addSubview(dateLabel)
        self.addSubview(testNameLabel)
        self.addSubview(typeLabel)
        self.addSubview(typeValueLabel)
        self.addSubview(reviewedByLabel)
        self.addSubview(reviewedByValueLabel)
        self.addSubview(fromLabel)
        self.addSubview(practiceNameLabel)
        self.addSubview(verticalStacView)
        verticalStacView.addArrangedSubview(seperatorView)
        verticalStacView.addArrangedSubview(instructionView)
        instructionView.addSubview(instructionLabel)
        instructionView.addSubview(instructionValueLabel)
        
        self.addShadowAndCornerRadius(.SMALL)
        
        dateLabel.setProperties(fontsize: FONT_SIZE_MEDIUM, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        
        testNameLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        testNameLabel.numberOfLines = 0
        
        typeLabel.setProperties(textKey: "com.charmphr.images.results.item.type.title", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_GREY)
        typeValueLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        typeValueLabel.numberOfLines = 0
        
        reviewedByLabel.setProperties(textKey: "com.charmphr.images.results.item.reviewedBy.title", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_GREY)
        reviewedByValueLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        reviewedByValueLabel.numberOfLines = 0
        
        fromLabel.setProperties(textKey: "com.charmphr.images.item.from.title", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_GREY)
        practiceNameLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        practiceNameLabel.numberOfLines = 0
        
        verticalStacView.axis = .vertical
        verticalStacView.spacing = PADDING_8
        verticalStacView.alignment = .fill
        
        seperatorView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)
        
        instructionLabel.setProperties(textKey: "com.charmphr.images.results.item.instruction.title", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_GREY)
        instructionValueLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        instructionValueLabel.numberOfLines = 0
        
        dateLabel.setLeft(offSet: CARD_PADDING)
        dateLabel.setRight(offSet: -CARD_PADDING)
        dateLabel.setTop(offSet: CARD_PADDING)
        
        testNameLabel.setLeft(offSet: CARD_PADDING)
        testNameLabel.setRight(offSet: -CARD_PADDING)
        testNameLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: dateLabel, relatedAttribute: .bottom)
        
        typeLabel.setLeft(offSet: CARD_PADDING)
        typeLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: testNameLabel, relatedAttribute: .bottom)
        typeLabel.wrapWidth(maxWidth: 100)
        
        typeValueLabel.setLeftRelatedToView(offSet: PADDING_8, relatedView: typeLabel, relatedAttribute: .right)
        typeValueLabel.setRight(offSet: -CARD_PADDING)
        typeValueLabel.setTopRelatedToView(offSet: 0, relatedView: typeLabel, relatedAttribute: .top)
        
        reviewedByLabel.setLeft(offSet: CARD_PADDING)
        reviewedByLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: typeValueLabel, relatedAttribute: .bottom)
        reviewedByLabel.wrapWidth(maxWidth: 200)
        
        reviewedByValueLabel.setLeftRelatedToView(offSet: PADDING_8, relatedView: reviewedByLabel, relatedAttribute: .right)
        reviewedByValueLabel.setRight(offSet: -CARD_PADDING)
        reviewedByValueLabel.setTopRelatedToView(offSet: 0, relatedView: reviewedByLabel, relatedAttribute: .top)
        
        fromLabel.setLeft(offSet: CARD_PADDING)
        fromLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: reviewedByValueLabel, relatedAttribute: .bottom)
        fromLabel.wrapWidth(maxWidth: 100)
        
        practiceNameLabel.setLeftRelatedToView(offSet: PADDING_8, relatedView: fromLabel, relatedAttribute: .right)
        practiceNameLabel.setRight(offSet: -CARD_PADDING)
        practiceNameLabel.setTopRelatedToView(offSet: 0, relatedView: fromLabel, relatedAttribute: .top)
        
        verticalStacView.setLeft(offSet: CARD_PADDING)
        verticalStacView.setRight(offSet: -CARD_PADDING)
        verticalStacView.setTopRelatedToView(offSet: PADDING_8, relatedView: practiceNameLabel, relatedAttribute: .bottom)
        verticalStacView.setBottom(offSet: -2)
        
        seperatorView.setHeight(constant: 1)
        
        instructionLabel.setLeft(offSet: 0)
        instructionLabel.setRight(offSet: 0)
        instructionLabel.setTop(offSet: 0)
        
        instructionValueLabel.setLeft(offSet: 0)
        instructionValueLabel.setRight(offSet: 0)
        instructionValueLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: instructionLabel, relatedAttribute: .bottom)
        instructionValueLabel.setBottom(offSet: -PADDING_8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
