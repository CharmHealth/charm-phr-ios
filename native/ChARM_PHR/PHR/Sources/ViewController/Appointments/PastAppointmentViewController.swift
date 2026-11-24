//
//  PastAppointmentViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 09/02/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit

class PastAppointmentViewController: CustomViewControllerWithTableView, UITableViewDataSource, CharmConnectionHandlerDelegate, CharmConnectionHandlerDataDelegate{
    
    var tagNo = 10000
    var btnToAppointmentMap:[Int:Appointment] = [:]
    var charmConnectionHandler: CharmConnectionHandler? = nil
    var arrayOfPastAppointment : [Appointment] = []
    var numberOfPracticeDataGotForPastAppointment = 0
    var isPastAppointmentFetched = false
    weak var delegate: AddViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = getString(key: "com.charmphr.appointments.pastappointment.VC.title")
        
        charmConnectionHandler = CharmConnectionHandler(delegate: self)
        charmConnectionHandler?.dataDelegate = self
        
        self.createTableviewAndSubViews(tableViewStyle: .plain)
        customTableView.separatorColor = .clear
        customTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(onUIRefreshChange), for: .valueChanged)
        customTableView.register(AppointmentsTableViewCell.self, forCellReuseIdentifier: "AppointmentsTableViewCell")
        
        fetchPastAppointment()
    }
    
    @objc func onUIRefreshChange(){
        fetchPastAppointment()
    }
    
    
    func fetchPastAppointment(){
        numberOfPracticeDataGotForPastAppointment = 0
        if refreshControl.isRefreshing != true{
            noDataBackGroundView.isHidden = true
            showActivityIndicatorFront()
        }
        arrayOfPastAppointment  = []
        isPastAppointmentFetched = false
        if isCustomApp()
        {
            for practice in Patient.selectedPatientInstance!.practiceList
            {
                charmConnectionHandler?.fetchPastAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: practice.practiceId ?? "", identificationKey: "fetchPastAppointment")
            }
        }else
        {
            charmConnectionHandler?.fetchPastAppointment(patientId: Patient.selectedPatientInstance!.patientId, practiceId: "", identificationKey: "fetchPastAppointment")
        }
    }
    
    func tableView(_ TableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let customTableViewCell = TableView.dequeueReusableCell(withIdentifier: "AppointmentsTableViewCell") as! AppointmentsTableViewCell
        customTableViewCell.appointmentListView.addShadowAndCornerRadius(.MEDIUM)
        if !arrayOfPastAppointment.isEmpty{
            let appointment = arrayOfPastAppointment[indexPath.row]
            customTableViewCell.setPastAppointmentTableViewCell(appointment: appointment)
            
            if !customTableViewCell.appointmentListView.questionnaireView.isHidden{
                customTableViewCell.appointmentListView.questionnaireBtn.tag = tagNo
                tagNo += 1
                btnToAppointmentMap[customTableViewCell.appointmentListView.questionnaireBtn.tag] = appointment
                customTableViewCell.appointmentListView.questionnaireBtn.addTarget(self, action: #selector(onClickQuestionnaire), for: .touchUpInside)
            }
            
            customTableViewCell.appointmentListView.rebookBtn.tag = tagNo
            tagNo += 1
            btnToAppointmentMap[customTableViewCell.appointmentListView.rebookBtn.tag] = appointment
            customTableViewCell.appointmentListView.rebookBtn.addTarget(self, action: #selector(onClickRebookBtn), for: .touchUpInside)

            if let provider = appointment.member, isPastAppointmentFetched{
                charmConnectionHandler?.downloadProviderPhoto(provider: provider, indexPath: indexPath, identificationKey: "downloadPastProviderPhoto")
            }
        }
        
        return customTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if isPastAppointmentFetched{
            if arrayOfPastAppointment.count == 0
            {
                self.noDataBackGroundView.setImage(enum: .noData, title: getString(key: "com.charmphr.nopastAppointments.title"), message: nil)
            }
            else
            {
                self.noDataBackGroundView.hideSubView(bool: true)
            }
        }
        return arrayOfPastAppointment.count
    }
    @objc func onClickQuestionnaire(btn: UIButton){
        if let appointment = btnToAppointmentMap[btn.tag]{
            pushToQuestionnaireViewController(appointment: appointment)
        }
    }
    
    @objc func onClickRebookBtn(btn: UIButton){
        if let appointment = btnToAppointmentMap[btn.tag]{
            pushToRebookViewController(appointment: appointment)
        }
    }
    
    func pushToQuestionnaireViewController(appointment: Appointment)  {
        
        let questionnaireViewController = QuestionnairesViewController()
        questionnaireViewController.selectedAppointment = appointment
        questionnaireViewController.selectedIndex = 1
        self.navigationController?.pushViewController(questionnaireViewController, animated: true)
    }
    
    func pushToRebookViewController(appointment: Appointment){
        let reBookAppointmentVC = BookAppointmentViewController()
        reBookAppointmentVC.reBookAppointment = appointment
        reBookAppointmentVC.delegate = delegate
        self.navigationController?.pushViewController(reBookAppointmentVC, animated: true)
    }
    

//MARK: - ConnectionHandler Delegate functions
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchPastAppointment"
        {
            numberOfPracticeDataGotForPastAppointment += 1
            for appointmentDict in  jsonObject["output_string"] as! [Dictionary<String,Any>]
            {
                arrayOfPastAppointment.append( ParsingHelper.fillAppointmentWithDictionary(dictionary: appointmentDict))
            }
            if (isCustomApp() && Patient.selectedPatientInstance!.practiceList.count == numberOfPracticeDataGotForPastAppointment ) || (!isCustomApp())
            {
                isPastAppointmentFetched = true
                customTableView.reloadData()
                hideActivityIndicator()
            }
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "fetchPastAppointment"{
            self.noDataBackGroundView.setImage(enum: .oops, title: CharmUtil.getErrorMsg(error: error), message: nil)
        }
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey == "downloadPastProviderPhoto"{
            if let indexPath = indexPath {
                if let cell =  customTableView.cellForRow(at: indexPath) as? AppointmentsTableViewCell{
                    if let image = UIImage(data: data), isPastAppointmentFetched{
                        arrayOfPastAppointment[indexPath.row].member?.photo = image
                        cell.appointmentListView.setProviderPhoto(image: image)
                    }
                }
            }
        }
    }
}
