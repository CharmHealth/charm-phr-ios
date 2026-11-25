//
//  QuestionnairesViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 30/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class QuestionnairesViewController: CustomViewControllerWithTableView, CharmConnectionV2HandlerDelegate, UITableViewDataSource , AddViewControllerDelegate
{
    private var questionnaireSegmentControl: UISegmentedControl = UISegmentedControl(items: ["",""])
    private var charmConnectionHandler : CharmConnectionHandler?
    
    private var questionnaireCurrentList : [PhysicianTemplates] = []
    private var questionnairePastList: [PhysicianTemplates] = []
    
    var selectedAppointment: Appointment?
    var selectedIndex: Int = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()

        createTableviewAndSubViews(tableViewStyle: .plain)
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)

        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = getString(key: "com.charmphr.Questionnaire.title")
        
        customTableView.register(QuestionnaireTableViewCell.self, forCellReuseIdentifier: "QuestionnaireTableViewCell")
        
        self.titleCustomView.addSubview(questionnaireSegmentControl)
        
        questionnaireSegmentControl.setTitle(getString(key: "com.charmphr.questionnairevc.current.title"), forSegmentAt: 0)
        questionnaireSegmentControl.setTitle(getString(key: "com.charmphr.questionnairevc.past.title"), forSegmentAt: 1)
        questionnaireSegmentControl.addProperties(fontSize: FONT_SIZE_NORMAL)

        questionnaireSegmentControl.addTarget(self, action: #selector(questionnaireSegmentChanged(_:)), for: .valueChanged)
        
        questionnaireSegmentControl.setCenterY()
        questionnaireSegmentControl.setSafeAreaLeft(offset: X_SPACE)
        questionnaireSegmentControl.setSafeAreaRight(offset: -X_SPACE)
        questionnaireSegmentControl.setHeight(constant: SEGMENTCONTROL_HEIGHT)
        
        changeCustomTitleViewHeight(height: HEADER_HEIGHT)
        
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
                        
        questionnaireSegmentControl.selectedSegmentIndex = selectedIndex
        fetchQuestionnaire()
    }
    
    func fetchQuestionnaire() {
        
        var type: String = ""
        if questionnaireSegmentControl.selectedSegmentIndex == 0 {
            type = questionnaireCurrentValue
            questionnaireCurrentList = []
        }
        else{
            type = questionnairePastValue
            questionnairePastList = []
        }
        if refreshControl.isRefreshing != true {
            showActivityIndicator()
        }
        
        charmConnectionHandler?.getQuestionnaireList(type: type, appointmentId: selectedAppointment?.appointmentId, identificationKey: "fetchQuestionnaire\(type)", isAscOrder: type == questionnaireCurrentValue)
    }
    
    //MARK: Action Calls

    @objc func onTryAgainBtnClick(_  btn: UIButton) {
        fetchQuestionnaire()
    }
    
    @objc func onUIRefreshChange(_ sender: UIRefreshControl) {
        fetchQuestionnaire()
    }
    
    @objc func questionnaireSegmentChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0
        {
            if questionnaireCurrentList.count != 0
            {
                customTableView.reloadData()
                hideActivityIndicator()
            }
            else{
                fetchQuestionnaire()
            }
        }else
        {
            if  questionnairePastList.count != 0
            {
                customTableView.reloadData()
                hideActivityIndicator()
            }else{
                fetchQuestionnaire()
            }
        }
    }
    
    //MARK: uitableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if questionnaireSegmentControl.selectedSegmentIndex == 0 {
            if questionnaireCurrentList.isEmpty {
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
            else{
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return questionnaireCurrentList.count
        }
        else{
            if questionnairePastList.isEmpty {
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.action.noData.title"), message: nil)
            }
            else{
                self.noDataBackGroundView.hideSubView(bool: true)
            }
            return questionnairePastList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireTableViewCell") as? QuestionnaireTableViewCell {
            
            var physicianTemplate: PhysicianTemplates?
            
            var questionnaireType = questionnaireCurrentValue
            if questionnaireSegmentControl.selectedSegmentIndex == 0 {
                if !questionnaireCurrentList.isEmpty{
                    physicianTemplate =  questionnaireCurrentList[indexPath.row]
                }
            }
            else{
                questionnaireType = questionnairePastValue
                if !questionnairePastList.isEmpty{
                    physicianTemplate = questionnairePastList[indexPath.row]
                }
            }
            
            if let physicianTemplate{
                cell.setValues(physicianTemplates: physicianTemplate, type: questionnaireType)
            }
            
            
            return cell
        }
        return UITableViewCell()
    }
        
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var questionnaire: PhysicianTemplates?
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireTableViewCell") as? QuestionnaireTableViewCell{
            cell.setSelected(false, animated: true)
            
            let questionnaireAnswerVC = QuestionnaireAnswerViewController()
            
            if questionnaireSegmentControl.selectedSegmentIndex == 0 {
                questionnaire = questionnaireCurrentList[indexPath.row]
            }
            else{
                questionnaireAnswerVC.questionnaireAnswerModel.isPast = true
                questionnaire = questionnairePastList[indexPath.row]
            }
            questionnaireAnswerVC.physicianTemplate = questionnaire
            questionnaireAnswerVC.delegate = self
            self.navigationController?.pushViewController(questionnaireAnswerVC, animated: true)
        }
    }
    
    // MARK: charm connection Handler delegate
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey.starts(with: "fetchQuestionnaire")
        {
            if let questionnaireList = response as? [PhysicianTemplates]{
                if identificationKey.contains(questionnaireCurrentValue) {
                    questionnaireCurrentList = questionnaireList
                }
                else{
                    questionnairePastList = questionnaireList
                }
            }
            hideActivityIndicator()
            customTableView.reloadData()
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey.starts(with: "fetchQuestionnaire")
        {
            if refreshControl.isRefreshing == true {
                refreshControl.endRefreshing()
            }
            customTableView.reloadData()
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
        else{
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
    //MARK: No data delegate
    
    override func noDataViewRetryBtnClicked() {
        fetchQuestionnaire()
    }
    
    func addViewControllerDataAdded(message: String?) {
        CharmUtil.showToast(controller: self, message: message, seconds: 2)
        fetchQuestionnaire()
    }
}
