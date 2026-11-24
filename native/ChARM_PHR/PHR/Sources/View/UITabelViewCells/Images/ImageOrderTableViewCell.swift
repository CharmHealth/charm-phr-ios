//
//  ImageOrderTableViewCell.swift
//  PHR
//
//  Created by Prathiba M on 11/05/26.
//  Copyright © 2026 Dhanuprasanya P. All rights reserved.
//

class ImageOrdersTableViewCell: UITableViewCell {
    
    private let itemView = ImageOrdersItemView()
    
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
    
    func setValues(data: ImagesOrder){
        itemView.dateLabel.text = data.date?.getStringFromDate(dateFormat: PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        itemView.fileNameLabel.text = data.fileName
        itemView.practiceNameLabel.text = data.practice?.practiceName
        
        itemView.isRead = data.readStatus
    }
    
    var isRead: Bool = false {
        didSet {
            itemView.isRead = isRead
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class ImageOrdersItemView: UIView{
    
    let dateLabel = UILabel()
    let fileNameLabel = UILabel()
    let seperatorView = UIView()
    let fromLabel = UILabel()
    let practiceNameLabel = UILabel()
    
    init(){
        super.init(frame: .zero)
        
        self.addSubview(dateLabel)
        self.addSubview(fileNameLabel)
        self.addSubview(seperatorView)
        self.addSubview(fromLabel)
        self.addSubview(practiceNameLabel)
        
        self.addShadowAndCornerRadius(.SMALL)
        
        dateLabel.setProperties(fontsize: FONT_SIZE_MEDIUM, weight: .medium, fontcolor: TEXT_COLOR_DARK)
        fileNameLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        fileNameLabel.numberOfLines = 0
        
        seperatorView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR)
        
        fromLabel.setProperties(textKey: "com.charmphr.images.item.from.title", fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        practiceNameLabel.setProperties(fontsize: FONT_SIZE_NORMAL, weight: .regular, fontcolor: TEXT_COLOR_DARK)
        practiceNameLabel.numberOfLines = 0
        
        dateLabel.setLeft(offSet: CARD_PADDING)
        dateLabel.setRight(offSet: -CARD_PADDING)
        dateLabel.setTop(offSet: CARD_PADDING)
        
        fileNameLabel.setLeft(offSet: CARD_PADDING)
        fileNameLabel.setRight(offSet: -CARD_PADDING)
        fileNameLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: dateLabel, relatedAttribute: .bottom)
        
        seperatorView.setLeft(offSet: CARD_PADDING)
        seperatorView.setRight(offSet: -CARD_PADDING)
        seperatorView.setTopRelatedToView(offSet: PADDING_8, relatedView: fileNameLabel, relatedAttribute: .bottom)
        seperatorView.setHeight(constant: 1)
        
        fromLabel.setLeft(offSet: CARD_PADDING)
        fromLabel.setRight(offSet: -CARD_PADDING)
        fromLabel.setTopRelatedToView(offSet: PADDING_8, relatedView: seperatorView, relatedAttribute: .bottom)
        
        practiceNameLabel.setLeft(offSet: CARD_PADDING)
        practiceNameLabel.setRight(offSet: -CARD_PADDING)
        practiceNameLabel.setTopRelatedToView(offSet: PADDING_6, relatedView: fromLabel, relatedAttribute: .bottom)
        practiceNameLabel.setBottom(offSet: -CARD_PADDING)
    }
    
    var isRead: Bool = false {
        didSet {
            if isRead{
                dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, weight: .medium)
                fileNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .regular)
                fromLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .regular)
                practiceNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .regular)
            }
            else{
                dateLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, weight: .semibold)
                fileNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .semibold)
                fromLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .semibold)
                practiceNameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .semibold)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
