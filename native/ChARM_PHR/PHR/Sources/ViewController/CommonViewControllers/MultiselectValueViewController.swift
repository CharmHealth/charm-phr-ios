//
//  MultiselectValueViewController.swift
//  phr
//
//  Created by Dhanuprasanya P on 15/12/21.
//  Copyright © 2021 Dhanuprasanya P. All rights reserved.
//

import Foundation

protocol MultiValueSelectViewControllerDelagate: AnyObject {
    func selectedIndexArr(selectedInputs:Array<String>?, identificationKey: String)
}

class MultiselectValueViewController : UIViewController , UITableViewDataSource,UITableViewDelegate {
    private var inputArray: Array<String> = []
    private var selectedInputs: Array<String> = []
    
    private var includeDeniedToSpecifyInput: Bool = true
    
    private var tableview = UITableView()
    
    private var makeSingleSelect: Bool = false
    weak var delegate: MultiValueSelectViewControllerDelagate?
    private var titleString: String = ""
    private var identificationKey: String = ""
    private var selectedValueIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnHeight: CGFloat = 44
                
        let parentView = UIView()
        parentView.layer.cornerRadius = CardSize.LARGE.value
        parentView.backgroundColor = .white
        parentView.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17,weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.text = titleString
        titleLabel.backgroundColor = .white
        titleLabel.addBottomBorder()
        
        
        //bottoview
        let bottomView = UIView()
        let submitBtn = UIButton()
        submitBtn.addPillCornerRadiusAndShadow(height: btnHeight)
        submitBtn.clipsToBounds = true
        submitBtn.addTarget(self, action: #selector(onSubmitClicked), for: .touchUpInside)
        submitBtn.setBackgroundColor(bgColor: THEME_COLOR)
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        submitBtn.setTitle(getString(key: "com.charmphr.action.submit"), for: .normal)
        bottomView.addSubview(submitBtn)
        
        
        let cancelBtn = UIButton()
        cancelBtn.addTarget(self, action: #selector(onCancelClicked), for: .touchUpInside)
        cancelBtn.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_LARGE, Weight: .semibold)
        cancelBtn.setTitle(getString(key: "com.charmphr.action.cancel"), for: .normal)
        bottomView.backgroundColor = .white
        bottomView.addSubview(cancelBtn)
        cancelBtn.addPillCornerRadiusAndShadow(height: btnHeight, shadowOffset: .zero)
        
        cancelBtn.setLeft(offSet: X_SPACE)
        cancelBtn.setCenterY()
        cancelBtn.setHeight(constant: btnHeight)
        
        submitBtn.setLeftRelatedToView(offSet: 10, relatedView: cancelBtn,relatedAttribute: .right)
        submitBtn.setRight(offSet: -X_SPACE)
        submitBtn.setCenterY()
        submitBtn.setHeight(constant: btnHeight)
        
        cancelBtn.setWidth(constant: 0,relatedView: submitBtn)
        //bottomview
        
        //tableview
        self.tableview.register(UINib(nibName: "TextLableWithCheckmarkTableViewCell", bundle: nil), forCellReuseIdentifier: "TextLableWithCheckmarkTableViewCell")
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.separatorColor = UIColorFromRGB(rgbValueWithAlpha: TABLEVIEWCELL_SEPARATOR_COLOR)
        self.tableview.showsVerticalScrollIndicator = false
        self.tableview.showsHorizontalScrollIndicator = false
        
        if selectedInputs.contains(questionnairePersonalDetailDeclineToSpecify) {
            selectedInputs = []
        }
        
        self.view.addSubview(parentView)
        parentView.addSubview(titleLabel)
        parentView.addSubview(tableview)
        parentView.addSubview(bottomView)
        
        parentView.setLeft(offSet: X_SPACE)
        parentView.setRight(offSet: -X_SPACE)
        parentView.setCenterY()
    
        titleLabel.setLeft(offSet: 0)
        titleLabel.setRight(offSet: 0)
        titleLabel.setTop(offSet: 0)
        titleLabel.setHeight(constant: 48)
        
        tableview.setLeft(offSet: 0)
        tableview.setRight(offSet: 0)
        tableview.setTopRelatedToView(offSet: 0, relatedView: titleLabel,relatedAttribute: .bottom)
        tableview.setHeight(constant: applicationFrame.height / 2 - 150)
        
        bottomView.setLeft(offSet: 0)
        bottomView.setRight(offSet: 0)
        bottomView.setHeight(constant: 64)
        bottomView.setBottom(offSet: 0)
        
        if(includeDeniedToSpecifyInput == true)
        {
            let deniedToSpecifyBtn = UIButton()
            deniedToSpecifyBtn.setTitle(getString(key: "com.charmphr.action.deniedToSpecify"), for: .normal)
            deniedToSpecifyBtn.addTarget(self, action: #selector(deniedToSpecifyClicked), for: .touchUpInside)
            deniedToSpecifyBtn.backgroundColor = .white
            deniedToSpecifyBtn.setTitleColor(.black, for: .normal)
            deniedToSpecifyBtn.contentHorizontalAlignment = .left
            deniedToSpecifyBtn.titleLabel?.font = .systemFont(ofSize: FONT_SIZE_NORMAL, Weight: .regular)
            deniedToSpecifyBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            parentView.addSubview(deniedToSpecifyBtn)
            deniedToSpecifyBtn.setTopRelatedToView(offSet: 0, relatedView: tableview,relatedAttribute: .bottom)
            bottomView.setTopRelatedToView(offSet: 0, relatedView: deniedToSpecifyBtn,relatedAttribute: .bottom)
            deniedToSpecifyBtn.setLeft(offSet: 0)
            deniedToSpecifyBtn.setRight(offSet: 0)
            deniedToSpecifyBtn.setHeight(constant: 48)
            deniedToSpecifyBtn.addBottomBorder()
        }
        else{
            bottomView.setTopRelatedToView(offSet: 0, relatedView: tableview,relatedAttribute: .bottom)
        }
    }
    
    @objc init(inputArray: Array<String>, selectedInputs: Array<String>, includeDeniedToSpecifyInput: Bool, titleString: String, identificationKey: String, makeSingleSelect: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        
        self.inputArray = inputArray
        self.selectedInputs = selectedInputs
        self.includeDeniedToSpecifyInput = includeDeniedToSpecifyInput
        self.titleString = titleString
        self.identificationKey = identificationKey
        self.makeSingleSelect = makeSingleSelect
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "TextLableWithCheckmarkTableViewCell") as? TextLableWithCheckmarkTableViewCell
        tableviewCell?.selectionStyle = .none
        
        tableviewCell?.keyLabel.text = inputArray[indexPath.row] == "" ? "-" : inputArray[indexPath.row]
        
        if(selectedInputs.contains(inputArray[indexPath.row]))
        {
            if makeSingleSelect{
                selectedValueIndex = indexPath.row
            }
            tableviewCell?.isCheckmarkHidden(bool: false)
        }
        else{
            tableviewCell?.isCheckmarkHidden(bool: true)
        }
        return tableviewCell ?? TextLableWithCheckmarkTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableviewCell = tableView.cellForRow(at: indexPath) as! TextLableWithCheckmarkTableViewCell
        let text = inputArray[indexPath.row]
        
        if makeSingleSelect{
            if let selectedValueIndex = selectedValueIndex
            {
                if let cell = tableView.cellForRow(at: IndexPath(row: selectedValueIndex, section: 0)) as? TextLableWithCheckmarkTableViewCell
                {
                    if let index = selectedInputs.firstIndex(of: cell.keyLabel.text ?? ""){
                        selectedInputs.remove(at: index)
                    }
                    cell.isCheckmarkHidden(bool: true)
                }
            }
            selectedValueIndex = indexPath.row
            
            if let selectedValueIndex = selectedValueIndex {
                if let cell = tableView.cellForRow(at: IndexPath(row: selectedValueIndex, section: 0)) as? TextLableWithCheckmarkTableViewCell
                {
                    selectedInputs.append(text)
                    cell.isCheckmarkHidden(bool: false)
                }
            }
        }
        else{
            if(selectedInputs.contains(text))
            {
                if let index = selectedInputs.firstIndex(of: text){
                    selectedInputs.remove(at: index)
                }
                tableviewCell.isCheckmarkHidden(bool: true)
            }
            else{
                selectedInputs.append(text)
                tableviewCell.isCheckmarkHidden(bool: false)
            }
        }
    }
    
    @objc private func onSubmitClicked(){
        self.delegate?.selectedIndexArr(selectedInputs: selectedInputs, identificationKey: identificationKey)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onCancelClicked(){
        self.delegate?.selectedIndexArr(selectedInputs: nil, identificationKey: identificationKey)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func deniedToSpecifyClicked()
    {
        selectedInputs = [getString(key: "com.charmphr.action.deniedToSpecify")]
        tableview.reloadData()
        self.delegate?.selectedIndexArr(selectedInputs: selectedInputs, identificationKey: identificationKey)
        self.dismiss(animated: true, completion: nil)
    }
    
}

protocol SignatureViewControllerDelegate: AnyObject {
    func onImgSelected(selectedImg:UIImage? , tag: Int)
}
class SignatureViewController : UIViewController{
    
    let signaturePad = SmoothedBIView()
    
    var titleStr = ""
    var tag = -1
    
    var currentImg: UIImage?
    weak var delegate: SignatureViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let parentView = UIView()
        
        parentView.addCornerRadius(.LARGE)
        parentView.clipsToBounds = true
        
        let titleView = UIView()
        titleView.backgroundColor = .white
        titleView.addBottomBorder(color: UIColorFromRGB(rgbValueWithAlpha: 0x3C3C435C))
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_EXTRALARGE,weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        titleLabel.text = titleStr
        
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "Close_Gray"), for: .normal)
        closeBtn.addTarget(self, action: #selector(onCloseBtnClicked), for: .touchUpInside)
        
        let bottomView = UIView()
        bottomView.addTopBorder(color: UIColorFromRGB(rgbValueWithAlpha: 0x3C3C435C))
        
        let clearBtn = UIButton()
        clearBtn.addTarget(self, action: #selector(onClearBtnClicked), for: .touchUpInside)
        clearBtn.setProperties(titleStrKey: "com.charmphr.questionnairevc.signature.clear.txt", fontsize: FONT_SIZE_VALUE_LABEL, weight: .regular, fontcolor: 0x202020FF)
        
        let verticalSeparator = UIView()
        verticalSeparator.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: 0x3C3C435C)
        
        let saveBtn = UIButton()
        saveBtn.addTarget(self, action: #selector(onSaveBtnClicked), for: .touchUpInside)
        saveBtn.setProperties(titleStrKey: getString(key: "com.charmphr.questionnairevc.signature.save.txt"), fontsize: FONT_SIZE_VALUE_LABEL, weight: .semibold, fontcolor: THEME_COLOR)
        
        if let currentImg = currentImg {
            signaturePad.incrementalImage = currentImg
        }
        clearBtn.setWidth(constant: 0,relatedView: saveBtn)
        bottomView.backgroundColor = .white
        
        self.view.addSubview(parentView)
        parentView.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(closeBtn)
        parentView.addSubview(signaturePad)
        parentView.addSubview(bottomView)
        bottomView.addSubview(clearBtn)
        bottomView.addSubview(verticalSeparator)
        bottomView.addSubview(saveBtn)
        
        parentView.setLeft(offSet: X_SPACE)
        parentView.setRight(offSet: -X_SPACE)
        parentView.setTop(offSet: 0)
        parentView.setBottom(offSet: 0)
        
        titleView.setLeft(offSet: 0)
        titleView.setRight(offSet: 0)
        titleView.setTop(offSet: 0)
    
        titleLabel.setLeft(offSet: 18)
        titleLabel.setRightRelatedToView(offSet: -PADDING_4, relatedView: closeBtn, relatedAttribute: .left)
        titleLabel.setTop(offSet: 18)
        titleLabel.setBottom(offSet: -18)
        
        closeBtn.setRight(offSet: -18)
        closeBtn.setWidth(constant: 24)
        closeBtn.setHeight(constant: 24)
        closeBtn.setCenterY()
        
        signaturePad.setLeft(offSet: 0)
        signaturePad.setRight(offSet: 0)
        signaturePad.setTopRelatedToView(offSet: 0, relatedView: titleView,relatedAttribute: .bottom)
        
        bottomView.setLeft(offSet: 0)
        bottomView.setRight(offSet: 0)
        bottomView.setHeight(constant: 48)
        bottomView.setBottom(offSet: 0)
        bottomView.setTopRelatedToView(offSet: 0, relatedView: signaturePad,relatedAttribute: .bottom)
        
        clearBtn.setLeft(offSet: 0)
        clearBtn.setTop(offSet: 0)
        clearBtn.setBottom(offSet: 0)
        clearBtn.setWidth(constant: (applicationFrame.width - (X_SPACE * 4)) / 2)
        
        verticalSeparator.setLeftRelatedToView(offSet: 0, relatedView: clearBtn, relatedAttribute: .right)
        verticalSeparator.setTop(offSet: 0)
        verticalSeparator.setBottom(offSet: 0)
        verticalSeparator.setWidth(constant: 0.5)
        
        saveBtn.setLeftRelatedToView(offSet: 0, relatedView: verticalSeparator, relatedAttribute: .right)
        saveBtn.setRight(offSet: 0)
        saveBtn.setTop(offSet: 0)
        saveBtn.setBottom(offSet: 0)
        saveBtn.setWidth(constant: (applicationFrame.width - (X_SPACE * 4) - 0.5) / 2)
    }
    
    @objc private func onSaveBtnClicked(){
     //   self.delegate?.selectedIndexArr(selectedInputs: selectedInputs)
        
        if let image = signaturePad.incrementalImage {
            
            delegate?.onImgSelected(selectedImg: image , tag: tag)
            self.dismiss(animated: true, completion: nil)
        }
        else{
            
        }
    }
    
    @objc private func onClearBtnClicked(){
        signaturePad.clear()
    }
    
    @objc private func onCloseBtnClicked(){
        delegate?.onImgSelected(selectedImg: nil , tag: tag)
        self.dismiss(animated: true, completion: nil)
    }
}

class CustomPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        return CGRect(x: X_SPACE, y: bounds.height / 4, width: bounds.width-2*X_SPACE, height: bounds.height / 2)
    }
}
