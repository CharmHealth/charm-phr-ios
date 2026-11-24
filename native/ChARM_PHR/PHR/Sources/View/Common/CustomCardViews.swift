//
//  Untitled.swift
//  PHR
//
//  Created by prathi-13964 on 08/07/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

//MARK: - DocumentAttachmentView

protocol DocumentAttachmentViewDelegate : AnyObject{
    func onCloseBtnTapped(_ view : DocumentAttachmentView)
}

class DocumentAttachmentView : UIView{
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private weak var delegate: DocumentAttachmentViewDelegate? = nil
    var value: Any? = nil
    
    init(name : String, fileSize: String?, delegate: DocumentAttachmentViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        
        self.addSubview(imageView)
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .semibold)
        self.addSubview(nameLabel)
        
        imageView.setLeft(offSet: PADDING_8)
        imageView.setHeight(constant: 20)
        imageView.setWidth(constant: 20)
        
        nameLabel.setLeftRelatedToView(offSet: 10, relatedView: imageView, relatedAttribute: .right)
        
        self.addShadowAndCornerRadius(.SMALL)
        
        if delegate != nil {
            let closeBtn = UIButton(type: .custom)
            let fileSizeLabel = UILabel()
            
            self.addSubview(closeBtn)
            self.addSubview(fileSizeLabel)
            
            closeBtn.setImage(#imageLiteral(resourceName: "CloseWithoutBorder"), for: .normal)
            closeBtn.addTarget(self, action: #selector(onClickCloseBtn), for: .touchUpInside)
            
            fileSizeLabel.text = fileSize
            fileSizeLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_MEDIUM, Weight: .regular)
            
            closeBtn.setWidth(constant: BTN_SIZE_24)
            closeBtn.setHeight(constant: BTN_SIZE_24)
            closeBtn.setCenterY()
            closeBtn.setRight(offSet: 0)
            
            fileSizeLabel.setLeftRelatedToView(offSet: CARD_PADDING, relatedView: imageView, relatedAttribute: .right)
            fileSizeLabel.setRightRelatedToView(offSet: -PADDING_8, relatedView: closeBtn, relatedAttribute: .left)
            fileSizeLabel.setTopRelatedToView(offSet: 2, relatedView: nameLabel, relatedAttribute: .bottom)
            fileSizeLabel.setBottom(offSet: -5)
            
            imageView.setCenterY()
            
            nameLabel.setRightRelatedToView(offSet: -2, relatedView: closeBtn, relatedAttribute: .left)
            nameLabel.setTop(offSet: 5)
        }
        else{
            imageView.setTop(offSet: PADDING_8)
            imageView.setBottom(offSet: -PADDING_8)
            
            nameLabel.setRight(offSet: -PADDING_8)
            nameLabel.setCenterY(view: imageView)
        }
        
        let text = name.lowercased()
        if text.contains(".pdf"){
            imageView.image = #imageLiteral(resourceName: "PdfPlaceHolder")
        }
        else if text.contains(".mp4") || text.contains(".mov"){
            imageView.image = #imageLiteral(resourceName: "video-placeholder")
        }
        else if text.contains(".png") || text.contains(".jpeg") || text.contains(".heic"){
            imageView.image = #imageLiteral(resourceName: "ImagePlaceHolder")
        }
        else{
            imageView.image = UIImage(named: "OtherFilesPlaceHolder")
        }
    }
    
    @objc private func onClickCloseBtn(){
        delegate?.onCloseBtnTapped(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - CardViewWithCloseBtn View

protocol CardViewWithCloseBtnDelegate: AnyObject{
    func onCloseBtnTapped(_ view: CardViewWithCloseBtn)
}

class CardViewWithCloseBtn: UIView{
    
    private let nameLabel = UILabel()
    private let closeBtn = UIButton(type: .custom)
    private let viewWidth: CGFloat
    private let delegate: CardViewWithCloseBtnDelegate
    var value: Any? = nil
    private var isHideClose: Bool = false

    init(name: String, viewWidth: CGFloat, delegate: CardViewWithCloseBtnDelegate){
        self.delegate = delegate
        self.viewWidth = viewWidth
        super.init(frame: .zero)
        
        self.addSubview(nameLabel)
        self.addSubview(closeBtn)
        
        self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: DOCUMENT_TEXTFIELD_BACKGROUND_COLOR)
        self.addCornerRadius(.SMALL)
        self.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: SEPARATOR_COLOR).cgColor
        self.layer.borderWidth = BORDER_WIDTH
        
        nameLabel.text = name
        nameLabel.textAlignment = .left
        nameLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        nameLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .medium)
        nameLabel.numberOfLines = 1
        
        closeBtn.setImage(UIImage(named: "CloseWithoutBorderBlue"), for: .normal)
        closeBtn.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        nameLabel.setLeft(offSet: CARD_PADDING)
        nameLabel.setTop(offSet: 0)
        nameLabel.setBottom(offSet: 0)
        
        closeBtn.setLeftRelatedToView(offSet: 0, relatedView: nameLabel, relatedAttribute: .right)
        closeBtn.setRight(offSet: 0)
        closeBtn.setCenterY()
        closeBtn.setWidth(constant: closeBtnSize)
        closeBtn.setHeight(constant: closeBtnSize)
    }
    
    func getViewWidth() -> CGFloat{
        let nameWidth = nameLabel.sizeThatFits(CGSize(width: applicationFrame.width, height: 100)).width
        let actualWidth = nameWidth + CARD_PADDING + (isHideClose ? CARD_PADDING : closeBtnSize)
        if actualWidth <= viewWidth{
            return actualWidth
        }
        else{
            return viewWidth
        }
    }
    
    @objc private func onClickBackBtn(){
        delegate.onCloseBtnTapped(self)
    }
    
    func hideCloseBtn(){
        isHideClose = true
        closeBtn.removeConstraints()
        closeBtn.removeFromSuperview()
        
        nameLabel.setRight(offSet: -CARD_PADDING)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
