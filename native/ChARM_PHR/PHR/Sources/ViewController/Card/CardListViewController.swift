//
//  CardListViewController.swift
//  phr
//
//  Created by Raghul D on 19/01/23.
//  Copyright © 2023 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit

class CardListViewController: UIViewController,CharmConnectionV2HandlerDelegate, UITableViewDataSource , UITableViewDelegate , NoDataViewDelegate , AddViewControllerDelegate, SelectValueViewControllerDelagate, CardItemViewDelegate
{

    var cardListView: CardListView?

    var charmConnectionHandler : CharmConnectionHandler?
    var cardMetaList : [CardMetaObj] = []
    var patientCardList : [PaymentGatewayToken] = []
    
    var practiceCardList: [PaymentGatewayToken] = []
    
    var isCurrentListFetched = false
    var isCurrentFetchComplete = false
    var isCurrentFetchError: Error? = nil
    
    var selectedPractice: Practice? = nil
    
    var selectedAppointment: Appointment?

    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        cardListView = CardListView.init(delegate: self)
        charmConnectionHandler = CharmConnectionHandler(delegate: nil)
        charmConnectionHandler?.v2Delegate = self
        self.view = cardListView
        removeSelectVC()
                
//        self.changeBackGroundColor(color: APPLICATION_BACKGROUND_COLOR)
//        self.createTableviewAndSubViews(tableViewStyle: .plain)

        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = getString(key: "com.charmphr.card.title")
        self.navigationItem.backBarButtonItem?.title = getString(key: "com.charmphr.healthPassport.back.title")
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCardClicked)), animated: true)
//
// charmConnectionHandler = CharmConnectionHandler(delegate: self)
//        fetchQuestionnaireList()
//
//        customTableView.delegate = self
//        customTableView.dataSource = self
//        customTableView.tableFooterView = UIView()
//        customTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//
//        //TODO: change image
//        bottomImageView.image = #imageLiteral(resourceName: "Questionnaires_HP_BG")
        
        cardListView?.cardSegmentControl.addTarget(self, action: #selector(cardSegmentChanged(_:)), for: .valueChanged)
        
        cardListView?.cardListTableView.delegate = self
        cardListView?.cardListTableView.dataSource = self
        
        cardListView?.cardRefreshControl.addTarget(self, action: #selector(self.onUIRefreshChange(_:)), for: .valueChanged)

        cardListView?.cardListTableView.register(CardTableViewCell.self, forCellReuseIdentifier: "CardTableViewCell")
        
        cardSegmentChanged(cardListView!.cardSegmentControl)
        
        cardListView?.cardNoData.tryAgainBtn.addTarget(self, action: #selector(onTryAgainBtnClick(_:)), for: .touchUpInside)
        
        cardListView?.cardNoData.delegate = self
        
        if getBluefinEnabledPractices().count > 1 {
            let filter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(intentToPracticeListPage))
            self.navigationItem.rightBarButtonItems?.append(filter)
        }
    }
    
    //MARK: Action Calls

    @objc func onTryAgainBtnClick(_  btn: UIButton) {
        refreshList()
    }
    
    @objc func onUIRefreshChange(_ sender: UIRefreshControl) {
        refreshList()
    }
    
    @objc func cardSegmentChanged(_ sender: UISegmentedControl) {
    
        if isCurrentListFetched {
            
            if isCurrentFetchComplete {
                if let error = isCurrentFetchError {
                    cardListView?.showErrorPage(error: error)
                }
                else{
                    
                    cardListView?.hideActivityIndicator()
                    cardListView?.cardListTableView.reloadData()
                    
                    
                    if (sender.selectedSegmentIndex == 0 && patientCardList.isEmpty) {
                        cardListView?.showNoDataPage(withMessage: true)
                    }
                    else if (sender.selectedSegmentIndex == 1 && practiceCardList.isEmpty) {
                        cardListView?.showNoDataPage()
                    }
                    else{
                        cardListView?.cardNoData.isHidden = true
                    }
                }
            }
            else{
                cardListView?.showActivityIndicator()
            }
        }
        else{
            isCurrentListFetched = true
            fetchCardList()
        }
    }
    

    
    //MARK: uitableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if cardListView?.cardSegmentControl.selectedSegmentIndex == 0 {
            return patientCardList.count
        }
        else{
            return practiceCardList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell") as! CardTableViewCell
        
        
        let card: PaymentGatewayToken!
        
        if cardListView?.cardSegmentControl.selectedSegmentIndex == 0 {
            card =  patientCardList[indexPath.row]
        }
        else{
            card = practiceCardList[indexPath.row]
        }
        
        cell.setValues(card: card, delegate: self)
        
        return cell
    }
        
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let card: PhysicianTemplates!
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireTableViewCell") as! QuestionnaireTableViewCell
//        cell.setSelected(false, animated: true)
//
//        let cardAnswerVC = QuestionnaireAnswerViewController()
//
//        if cardListView?.cardSegmentControl.selectedSegmentIndex == 0 {
//            card = cardCurrentList[indexPath.row]
//        }
//        else{
//            cardAnswerVC.isPast = true
//            card = cardPastList[indexPath.row]
//        }
////        cardAnswerVC.modalPresentationStyle = .custom
////        cardAnswerVC.modalTransitionStyle = .crossDissolve
////        //cardAnswerVC.modalPresentationStyle = .formSheet
//
//        cardAnswerVC.physicianTemplate = card
//        cardAnswerVC.delegate = self
//       // self.navigationController?.present(cardAnswerVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(cardAnswerVC, animated: true)
    }
    
    //MARK: other methods

    
    // MARK: charm connection Handler delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "getCardList"{
            if let cardMetaList = response as? [CardMetaObj] {
        
                isCurrentFetchComplete = true
                patientCardList.removeAll()
                practiceCardList.removeAll()
                self.cardMetaList.removeAll()
                self.cardMetaList.append(contentsOf: cardMetaList)
                
                cardMetaList.forEach({cardMeta in
                    cardMeta.cardList.forEach({card in
                        if card.isPHRCard{
                            patientCardList.append(card)
                        }
                        else{
                            practiceCardList.append(card)
                        }
                    })
                })
                
                cardSegmentChanged(cardListView!.cardSegmentControl)
            }
            
        }
        else if identificationKey == "DeleteCard"{
            refreshList()
            if let resp = response as? [String: Any]{
                CharmUtil.showToast(controller: self, message: resp.getString("message"), seconds: 2)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        
        if identificationKey == "getCardList"{
            if cardListView?.cardRefreshControl.isRefreshing == true {
                cardListView?.cardRefreshControl.endRefreshing()
            }
            isCurrentFetchComplete = true
            isCurrentFetchError = error
            cardListView?.showErrorPage(error: error)
        }
        else
        {
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    func fetchCardList() {
        
        if cardListView?.cardRefreshControl.isRefreshing != true && cardListView?.activityIndicatorView.isAnimating != true {
            cardListView?.showActivityIndicator()
        }
        charmConnectionHandler?.getCardList(identificationKey: "getCardList" , selectedPractice: selectedPractice?.practiceId ?? "")
    }
    
    @objc func addCardClicked()
    {
        let addCardVC = AddCardViewController()
        if let cardMeta =  cardMetaList.firstOrNil() {
            addCardVC.patientAddress = cardMeta.patientAddress
        }
        addCardVC.selectedPractice = selectedPractice
        addCardVC.delegate = self
        navigationController?.pushViewController(addCardVC, animated: true)
    }
    
    func editCardClicked(card: PaymentGatewayToken)
    {
        let addCardVC = AddCardViewController()
        if let cardMeta =  cardMetaList.firstOrNil() {
        //    addCardVC.patientAddress = cardMeta.patientAddress
        }
        
        addCardVC.selectedPractice = selectedPractice
        addCardVC.delegate = self
        addCardVC.editCard = card
        navigationController?.pushViewController(addCardVC, animated: true)
    }
    
    func deleteCardClicked(card: PaymentGatewayToken)
    {
        CharmUtil.createDeleteAndCancelAlertWith(title: nil, msg: getString(key: "com.charmphr.card.alert.delete"), deleteClicked: {
            self.deleteCard(card: card)
        })
        
    }
    
    func deleteCard(card: PaymentGatewayToken){
        
        cardListView?.showActivityIndicator(hideTableView: false)
        charmConnectionHandler?.deleteCard(paymentGatewayToken: card, identificationKey: "DeleteCard")
    }
    
    
    
    
    //MARK: No data delegate
    
  
    
    func noDataViewRetryBtnClicked() {
        refreshList()
    }
    
    
    
    //MARK: Other functions
    
    private func refreshList() {
        isCurrentListFetched = true
        isCurrentFetchComplete = false
        isCurrentFetchError = nil
        fetchCardList()
    }
    
    private func removeSelectVC(){
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        if let selectValueVC = navigationArray.getElement(at: navigationArray.count - 2) {
            if selectValueVC is SelectValueViewController{
                navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
                self.navigationController?.viewControllers = navigationArray
            }
        }
    }
    
    @objc private func intentToPracticeListPage(){
        let selectValueVC = SelectValueViewController()
        selectValueVC.title = getString(key:"com.charmphr.common.selectPractice")
        
        selectValueVC.navigationItem.largeTitleDisplayMode = .never
        selectValueVC.delegate = self
        let bluefinPracticeList = getBluefinEnabledPractices()
        selectValueVC.arrayOfValueToBeShown = bluefinPracticeList.map({practice in
            return practice.practiceName ?? ""
        })
        
        selectValueVC.selectedValueIndex = bluefinPracticeList.firstIndex(where: {$0.practiceId == selectedPractice?.practiceId}) ?? 0
        self.navigationController?.pushViewController(selectValueVC, animated: true)
    }
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        refreshList()
    }
    
    func selectValueViewControllerDidSelectValue(selectedRow: Int) {
        selectedPractice = getBluefinEnabledPractices().getElement(at: selectedRow)
        refreshList()
    }
    
    func onCardEdit(card: PaymentGatewayToken) {
        editCardClicked(card: card)
    }
    
    func onCardDelete(card: PaymentGatewayToken) {
        deleteCardClicked(card: card)
        //delete functionality to be implemented
    }
}
