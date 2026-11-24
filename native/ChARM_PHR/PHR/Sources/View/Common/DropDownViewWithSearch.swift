//
//  DropDownViewWithSearch.swift
//  PHR
//
//  Created by prathi-13964 on 03/07/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

protocol DropDownViewDelegate: AnyObject {
    func didSelectValue(_ value: SelectValueModel)
    func onClickClose()
}

class DropDownViewWithSearch: UIStackView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    private let valueStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    private let valueView: UIView = {
        let uiView = UIView()
        uiView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR).cgColor
        uiView.addCornerRadius(.SMALL)
        uiView.layer.borderWidth = 1
        uiView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: TEXTFIELD_BACKGROUND_COLOR)
        return uiView
    }()
    
    private let valueLabel: UILabel = {
       let uiLabel = UILabel()
        uiLabel.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        uiLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        uiLabel.numberOfLines = 0
        return uiLabel
    }()
    
    private let textField: CutCopyPasteDisabledField = {
        let textField = CutCopyPasteDisabledField()
        
        textField.textAlignment = .left
        textField.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_DARK)
        textField.returnKeyType = .done
        textField.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .regular)
        
        textField.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR).cgColor
        textField.addCornerRadius(.SMALL)
        textField.layer.borderWidth = 1
        textField.backgroundColor = .white
        
        textField.setPadding(width: 10, height: 10)
        
        return textField
    }()
    
    private let dropDownStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        stackView.layer.masksToBounds = true
        stackView.layer.cornerRadius = CardSize.SMALL.value
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColorFromRGB(rgbValueWithAlpha: LINE_COLOR).cgColor
        return stackView
    }()
    private let spaceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let mdTableView = MDAutoGrowingTableView()
    private let noDataView = UIView()
    private let noDataLabel = UILabel()
    
    private let delegate: DropDownViewDelegate
    private let renderingList: [SelectValueModel]
    private var searchRenderingList: [SelectValueModel] = []
    private var isEditable: Bool = true
    
    init(placeHolderKey: String, renderingList: [SelectValueModel], delegate: DropDownViewDelegate){
        self.renderingList = renderingList
        self.delegate = delegate
        super.init(frame: .zero)
        
        self.addSubview(valueStackView)
        valueStackView.addArrangedSubview(textField)
        self.addSubview(dropDownStackView)
        dropDownStackView.addArrangedSubview(spaceView)
        dropDownStackView.addArrangedSubview(mdTableView)
        dropDownStackView.addArrangedSubview(noDataView)
        noDataView.addSubview(noDataLabel)
        
        self.axis = .vertical
        self.alignment = .fill
        self.spacing = 0
        
        textField.delegate = self
        textField.placeholder = getString(key: placeHolderKey)
        textField.isUserInteractionEnabled = true
        
        let closeButton = UIButton()
        
        valueStackView.addArrangedSubview(valueView)
        valueView.addSubview(valueLabel)
        valueView.addSubview(closeButton)
        
        closeButton.setImage(UIImage(named: "dustBin_Gray"), for: .normal)
        closeButton.setPadding(vertical: 5, horizontal: 6)
        closeButton.addTarget(self, action: #selector(onClickCloseBtn), for: .touchUpInside)

        valueLabel.setLeft(offSet: 8)
        valueLabel.setTop(offSet: 8)
        valueLabel.setBottom(offSet: -8)
        
        closeButton.setRight(offSet: 0)
        closeButton.setCenterY()
        closeButton.setHeight(constant: 24 + 10)
        closeButton.setWidth(constant: 24 + 10)
        
        valueLabel.setRightRelatedToView(offSet: 0, relatedView: closeButton, relatedAttribute: .left)
        
        valueView.isHidden = true
        
        mdTableView.separatorStyle = .singleLine
        mdTableView.isScrollEnabled = true
        mdTableView.maxHeight = 200
        
        mdTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        mdTableView.delegate = self
        mdTableView.dataSource = self
        mdTableView.sectionHeaderTopPadding = BORDER_WIDTH
        
        noDataView.backgroundColor = .white
        
        noDataLabel.text = getString(key: "com.charmphr.sharedocuments.member.noDataLabel.title")
        noDataLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        noDataLabel.textColor = UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87)
        
        valueStackView.setLeft(offSet: 0)
        valueStackView.setRight(offSet: 0)
        valueStackView.setTop(offSet: 0)
        
        textField.setHeight(constant: 38)
        
        dropDownStackView.setLeft(offSet: 0)
        dropDownStackView.setRight(offSet: 0)
        dropDownStackView.setTopRelatedToView(offSet: -6, relatedView: valueStackView, relatedAttribute: .bottom)
        dropDownStackView.setBottom(offSet: 0)
        
        spaceView.setHeight(constant: 6)
        mdTableView.heightConstraint = mdTableView.setAndReturnHeight(constant: 0)
        noDataView.setHeight(constant: 70)
        
        noDataLabel.setCenterX()
        noDataLabel.setCenterY()
        
        hideNoData(isHidden: true)
        mdTableView.reloadData()
        
        self.bringSubviewToFront(valueStackView)
    }
    
    private func hideNoData(isHidden: Bool){
        if !isHidden{
            self.bringSubviewToFront(noDataView)
        }
        noDataView.isHidden = isHidden
        noDataLabel.isHidden = isHidden
    }
    
    private func filterArrayList(textInput: String){
        if textInput.count > 0{
            
            searchRenderingList = renderingList.filter({ selectValueModel in
                return selectValueModel.name.lowercased().contains(textInput.lowercased()) == true
            })
            
            if searchRenderingList.isEmpty{
                hideNoData(isHidden: false)
            }
            else{
                hideNoData(isHidden: true)
            }
        }
        else{
            hideNoData(isHidden: true)
            searchRenderingList = renderingList
        }
        if isEditable{
            mdTableView.reloadData()
        }
    }
    
    func becomeTextFieldFirstResponder(){
        textField.becomeFirstResponder()
    }
    
    private func setLabelValue(value: String?){
        valueLabel.text = value
        valueView.isHidden = false
        textField.isHidden = true
        isEditable = false
    }
    
    //MARK: Target functions
    
    @objc private func onClickCloseBtn(){
        valueView.isHidden = true
        textField.text = nil
        textField.isHidden = false
        isEditable = true
        delegate.onClickClose()
    }
    
    //MARK: TextField Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldEndEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldEndEditing()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditable
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textInput = textField.text{
            filterArrayList(textInput: textInput)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        let newText = oldText.replacingCharacters(in: r, with: string)
        filterArrayList(textInput: newText)
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let textInput = textField.text{
            filterArrayList(textInput: textInput)
        }
    }
    
    private func textFieldEndEditing(){
        searchRenderingList = []
        textField.resignFirstResponder()
        mdTableView.reloadData()
        hideNoData(isHidden: true)
    }
    
    //MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        spaceView.isHidden = searchRenderingList.isEmpty
        return searchRenderingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = searchRenderingList[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
        cell.textLabel?.numberOfLines = 0
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedValue = searchRenderingList[indexPath.row]
        textFieldEndEditing()
        setLabelValue(value: selectedValue.name)
        delegate.didSelectValue(selectedValue)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct SelectValueModel: Identifiable, Equatable {
    let id: String
    let name: String
}
