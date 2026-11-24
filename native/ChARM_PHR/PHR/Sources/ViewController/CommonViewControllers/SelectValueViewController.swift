//
//  SelectValueViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 28/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

protocol SelectValueViewControllerDelagate: AnyObject {
    func selectValueViewControllerDidSelectValue(selectedRow:Int)
}

protocol SelectValueViewControllerValueDelagate: AnyObject {
    func selectValueViewControllerDidSelectCustomString(customString:String)
}

protocol SelectValueViewControllerSearchStringDelagate: AnyObject {
    func onSearchStringChanged(searchStr:String)
}

class SelectValueViewController : CustomViewControllerWithTableView , UITableViewDataSource, UISearchBarDelegate {
        
    var arrayOfValueToBeShown : Array<String> = []
    var filteredArray : Array<String> = []
    var selectedValueIndex : Int?
    
    var searchLocally: Bool = true
    
    weak var delegate : SelectValueViewControllerDelagate?
    weak var valueDelegate : SelectValueViewControllerValueDelagate?
    weak var searchStrDelegate: SelectValueViewControllerSearchStringDelagate?
    
    var searchBar = UISearchBar()
    var isSearchBarNeeded: Bool = false
    var addSearchTextAsValue : Bool = false
    var isSearchOn3Char: Bool = false
    private var searchText: String = ""
    private var isCustomTextAdded: Bool = false
    
    var popVC = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableviewAndSubViews(tableViewStyle: .plain)
        customTableView.register(UINib(nibName: "TextLableWithCheckmarkTableViewCell", bundle: nil), forCellReuseIdentifier: "TextLableWithCheckmarkTableViewCell")
               customTableView.dataSource = self
        if isSearchBarNeeded
        {
            searchBar.backgroundImage = UIImage()
            searchBar.autocorrectionType = .no
            searchBar.autocapitalizationType = .none
            searchBar.placeholder = getString(key: "com.charmphr.search.placeholder")
            searchBar.delegate = self
            self.titleCustomView.addSubview(searchBar)

            self.searchBar.setTop(offSet: Y_SPACE)
            self.searchBar.setBottom(offSet:0)
            self.searchBar.setSafeAreaLeft(offset: 7)
            self.searchBar.setSafeAreaRight(offset: -7)
            self.searchBar.setHeight(constant: 40)
            changeCustomTitleViewHeight(height: 40 + Y_SPACE )
//            customTableView.backgroundColor = .white
//            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
            
            if !arrayOfValueToBeShown.isEmpty {
                self.customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
//    @objc func dismissKeyboard()()
//    {
//        self.view.endEditing(true)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
//MARK: - TableView Delegate functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearchBarNeeded
        {
            return arrayOfValueToBeShown.count
        }
        else if filteredArray.isEmpty && (searchBar.text == nil || searchBar.text == "")
        {
            return arrayOfValueToBeShown.count
        }
        else
        {
            if isSearchOn3Char{
                return filteredArray.count == 0 ? 0 : filteredArray.count
            }
            else{
                return filteredArray.count == 0 ? 1 : filteredArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableviewCell = tableView.dequeueReusableCell(withIdentifier: "TextLableWithCheckmarkTableViewCell") as? TextLableWithCheckmarkTableViewCell
        
        if !isSearchBarNeeded || (filteredArray.isEmpty && (searchBar.text == nil || searchBar.text == ""))
        {
            tableviewCell?.keyLabel.text = arrayOfValueToBeShown[indexPath.row] == "" ? "-" : arrayOfValueToBeShown[indexPath.row]
            
            if selectedValueIndex == indexPath.row
            {
                tableviewCell?.isCheckmarkHidden(bool: false)
            }else
            {
                tableviewCell?.isCheckmarkHidden(bool: true)
            }
        }
        else if filteredArray.isEmpty
        {
            let cell = UITableViewCell()
            cell.textLabel?.text = getString(key: "com.charmphr.common.no.searchResulut")
            cell.isUserInteractionEnabled = false
            return cell
        }
        else
        {
            let stringToBeShown = filteredArray[indexPath.row] == "" ? "-" : filteredArray[indexPath.row]
            let arr = stringToBeShown.components(separatedBy: "_")
            if arr.count == 2{
                tableviewCell?.keyLabel.text = arr.first
                tableviewCell?.keyLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .semibold)
            }
            else{
                tableviewCell?.keyLabel.text = stringToBeShown
                tableviewCell?.keyLabel.font = UIFont.systemFont(ofSize: FONT_SIZE_NORMAL, weight: .regular)

            }
            
            if selectedValueIndex != nil
            {
                let selectedString = arrayOfValueToBeShown[selectedValueIndex!]
                
                if stringToBeShown == selectedString
                {
                    tableviewCell?.isCheckmarkHidden(bool: false)
                }
                else
                {
                    tableviewCell?.isCheckmarkHidden(bool: true)
                }
            }
        }
        
        if tableviewCell != nil
        {
            return tableviewCell!
        }else
        {
           return  UITableViewCell()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if let selectedValueIndex = selectedValueIndex
        {
            if let cell = tableView.cellForRow(at: IndexPath(row: selectedValueIndex, section: 0)) as? TextLableWithCheckmarkTableViewCell
            {
                cell.isCheckmarkHidden(bool: true)
            }
        }
        
        selectedValueIndex = indexPath.row
        
        
        if let selectedValueIndex = selectedValueIndex {
            if let cell = tableView.cellForRow(at: IndexPath(row: selectedValueIndex, section: 0)) as? TextLableWithCheckmarkTableViewCell
            {
                cell.isCheckmarkHidden(bool: false)
            }
        }
       
        if let selectedValueIndex = selectedValueIndex
        {
            if !isSearchBarNeeded || (filteredArray.isEmpty && (searchBar.text.isNilOrBlank()))
            {
                delegate?.selectValueViewControllerDidSelectValue(selectedRow: selectedValueIndex)
            }
            else
            {
                if isCustomTextAdded && selectedValueIndex == 0{
                    valueDelegate?.selectValueViewControllerDidSelectCustomString(customString: filteredArray[0].components(separatedBy: "_").first ?? "")
                }
                else{
                    if let selectedIndex = arrayOfValueToBeShown.firstIndex(of: filteredArray[selectedValueIndex]){
                        delegate?.selectValueViewControllerDidSelectValue(selectedRow: selectedIndex)
                    }
                }
            }
        }
        
        if popVC {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//
//    }
//

//MARK: - SearchBar Delegate functions
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != nil && searchLocally
        {
            if let textInput = searchBar.text{
                self.searchText = textInput
                filterValueArrayWithSearchText()
            }
        }
        else if(searchBar.text != nil)
        {
            self.searchText = searchText
            if searchBar.text!.count >= 3{
                showActivityIndicator()
                searchStrDelegate?.onSearchStringChanged(searchStr: searchText)
            }
            else{
                arrayOfValueToBeShown = []
                filteredArray = []
                customTableView.reloadData()
            }
        }
    }
    
    override func showActivityIndicator() {
        self.view.bringSubviewToFront(activityIndicatorView)
        activityIndicatorView.startAnimating()
        noDataBackGroundView.isHidden = true
        customTableView.isHidden = true
    }
//MARK: - Other functions
    
    func filterValueArrayWithSearchText(isFromApi: Bool = false)
    {
        let text = searchText
        filteredArray = []
        if addSearchTextAsValue{
            if !text.isEmpty {
                var validateInput = true
                if text.trimmingCharacters(in: .whitespaces).isEmpty == false{
                    for data in arrayOfValueToBeShown{
                        if data.lowercased() == text.lowercased(){
                            validateInput = false
                        }
                    }
                    if validateInput{
                        filteredArray.append("\(text.trim())_semibold")
                        isCustomTextAdded = true
                    }
                    else{
                        isCustomTextAdded = false
                    }
                }
            }
        }
        if isFromApi{
            filteredArray.append(contentsOf: arrayOfValueToBeShown)
        }
        else{
            filteredArray.append(contentsOf:
                                    arrayOfValueToBeShown.filter({ (value) -> Bool in
                if value.lowercased().contains(text.lowercased()){
                    return true
                }
                else{
                    return false
                }
            })
            )
        }
        reloadData()
    }
    
    func reloadData()
    {
        hideActivityIndicator()
        customTableView.reloadData()
    }

}
