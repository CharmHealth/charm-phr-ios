//
//  QuestionnaireAnswerViewController.swift
//  phr
//
//  Created by Sankar Saravanan on 30/08/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import UIKit
import MobileCoreServices
import QuickLook
import PhotosUI
import Photos

fileprivate let IMAGE_DATA: String = "imageData"
fileprivate let FILE_NAME: String = "fileName"

class QuestionnaireAnswerViewController: AddDataUIViewController, CharmConnectionHandlerDelegate ,CharmConnectionHandlerTagDelegate, UIViewControllerTransitioningDelegate, SignatureViewControllerDelegate, PatInsuranceViewDelegate, PrimaryDataHandlerDelegate , InsuranceCardViewDelegate , CharmConnectionV2HandlerDelegate , UIImagePickerControllerDelegate ,UINavigationControllerDelegate , PHPickerViewControllerDelegate, CharmConnectionHandlerDataDelegate , DismissModelViewDelegate{
   
    
    private lazy var questionnaireAnswerView = QuestionnaireAnswerView()
    var onUpdateQuestionnaire: QuestionnaireDetailPOJO?
    
    private let activityIndicator = UIActivityIndicatorView()
    let bgView = UIView()
    weak var delegate: AddViewControllerDelegate? = nil
    weak var consentFormDelegate: VideoCallConsentFormDelegate? = nil
    var physicianTemplate : PhysicianTemplates? = nil
    var questionnaireAnswerModel = QuestionnaireAnswerModel()
    var selectViewController: SelectValueViewController? = nil
    var multiSelectPopVC: MultiselectValueViewController? = nil
    private var signaturePopVC: SignatureViewController? = nil
    private var presentedModalVC: UIViewController? = nil
    private weak var allergyDelegate: AllergyFetchDelegate? = nil
    
    private var charmconnectionHandler : CharmConnectionHandler? = nil
    private var modalTransitionAnimator : ModalTransitionAnimator?
    
    private var isAlreadySubmitted = false
    private var isPersonalDetail = false
    private var isPatContact = false
    private var isInsurance = false
    private var callbackCount = 0
    private var isCallbackSent = false
    
    
    private var insuranceFrontCard: Data? = nil
    private var insuranceBackCard: Data? = nil

    
    private var tempInsuranceCard: [String: Any] = [:]
    private var tempInsuranceCardType:String? = nil
    
    private var totalRespCount = 0
    private var session: URLSession?
    
    private var arrayOfActiveAllergies: [AllergiesList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        charmconnectionHandler = CharmConnectionHandler(delegate: self)
        charmconnectionHandler?.tagDelegate = self
        charmconnectionHandler?.v2Delegate = self
        charmconnectionHandler?.dataDelegate = self
        
        getQuestionnaireAnswers()
        initiateView()
    }
    
    func initiateView(){
        self.navigationItem.title = physicianTemplate?.name ?? getString(key: "com.charmphr.Questionnaire.title")
        
        self.view.addSubview(activityIndicator)
        
        activityIndicator.color = .gray
        
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        self.view.addSubview(questionnaireAnswerView)
        
        questionnaireAnswerView.setLeft(offSet: 0)
        questionnaireAnswerView.setRight(offSet: 0)
        questionnaireAnswerView.setTop(offSet: 0)
        questionnaireAnswerView.setBottom(offSet: 0)
        
        self.view.addSubview(bgView)
        
        bgView.setBackgroundColor(bgColor: TEXT_COLOR_BLACK50)
        bgView.isHidden = true
        
        bgView.setLeft(offSet: 0)
        bgView.setRight(offSet: 0)
        bgView.setSafeAreaTop(offset: 0)
        bgView.setSafeAreaBottom(offset: 0)
    }
    
    override func onBackClick(){
        if let consentFormDelegate {
            consentFormDelegate.popConsentFormVC()
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//MARK: - Api Calls
    
    private func getQuestionnaireAnswers(){
        
        isAlreadySubmitted = physicianTemplate?.patientQuesMap?.isSubmitted ?? false
        if let physicianTemplate = physicianTemplate{
            showActivityIndicator()
            charmconnectionHandler?.fetchQuestionnaireAnswers(patientId: Patient.selectedPatientInstance!.patientId, physicianTemplate: physicianTemplate, identificationKey: "fetchQuestionnaireAnswers")
        }
    }
    
    func getSignatureImage(feedbackPOJO: QuestionnaireEntryPOJO, tag: Int){
        if let physicianTemplate = physicianTemplate{
            charmconnectionHandler?.getSignatureImage(physicianTemplates: physicianTemplate, entryPOJO: feedbackPOJO , tag: tag , identificationKey: "getSignature")
        }
    }
    
    func uploadSignatureImage(selectedImg: UIImage, feedbackPOJO: QuestionnaireEntryPOJO, tag: Int){
        if let physicianTemplate = physicianTemplate{
            showActivityIndicator()
            charmconnectionHandler?.uploadSignatureImage(image: selectedImg, physicianTemplates: physicianTemplate, entryPOJO: feedbackPOJO, tag: tag, identificationKey: "uploadSignature")
        }
    }
    
    func fetchStatesAfterCountryChange(countryName: String){
        
        questionnaireAnswerView.country = countryName
        showActivityIndicator()
        charmconnectionHandler?.fetchStates(countryCode: countryName, identificationKey: "fetchStatesAfterCountryChange")
    }
    
    private func fetchstates(country: String){
        charmconnectionHandler?.fetchStates(countryCode: country , identificationKey: "fetchStates")
    }
    
    func getPayerList(searchStr: String) {
                 
        CharmConnectionHandler.updateSession()
        charmconnectionHandler?.getPayerList(searchStr: searchStr, practiceId: physicianTemplate?.practiceId ?? "", identificationKey: "getPayerList")
    }
    
    func updateQuestionnaireAnswers(){
        showActivityIndicator()
        if let physicianTemplate = physicianTemplate, let onUpdateQuestionnaire = onUpdateQuestionnaire{
            charmconnectionHandler?.updateQuestionnaireAnswers(physicianTemplate: physicianTemplate, questionnaireDetailPOJO: onUpdateQuestionnaire, identificationKey: "uploadQuestionnaireAnswers")
        }
    }
    
    func updateQuestionnaireWidgets(onSubmitFeedback: QuestionnaireDetailPOJO){
        showActivityIndicator()
        if let physicianTemplate = physicianTemplate{
            charmconnectionHandler?.updateQuestionnaireWidgets(physicianTemplate: physicianTemplate, questionnaireDetailPOJO: onSubmitFeedback, identificationKey: "uploadQuestionnaireWidgets")
        }
    }
    
    func fetchAllergyList(allergyDelegate: AllergyFetchDelegate){
        if self.allergyDelegate == nil{
            self.allergyDelegate = allergyDelegate
        }
        if arrayOfActiveAllergies.isEmpty{
            showActivityIndicator()
            charmconnectionHandler?.fetchAllergiesList(pageNo: 1, identificationKey: "activeAllergy", allergyType: ACTIVE)
        }
        else{
            allergyDelegate.patientAddedAllergies(allergies: arrayOfActiveAllergies)
        }
    }
    
    private func fetchQuestionnaireAnswersRespCallback(){
        totalRespCount = 0
        isPersonalDetail = false
        isPatContact = false
        isInsurance = false
        callbackCount = 0
        isCallbackSent = false
        
        if questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.first(where: { (questionnaireEntryPOJO) -> Bool in
            return questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypePersonalDetails
        }) != nil
        {
            totalRespCount += 1
            isPersonalDetail = true
        }
        
        if questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.first(where: { (questionnaireEntryPOJO) -> Bool in
            return questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypePrimaryContactDetail
        }) != nil
        {
            isPatContact = true
            totalRespCount += 1
        }
        
        if ((questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.contains(where: { (questionnaireEntryPOJO) -> Bool in
            return questionnaireEntryPOJO.questionnaireEntry.notesType == questionnaireNotesTypeInsurance
        })) == true)
        {
            totalRespCount += 2
            isInsurance = true
        }
        
        if totalRespCount == 0 {
            onQuestionnaireDetailFetchSuccess()
        }
        else if let physicianTemplate = physicianTemplate{
            
            if isPersonalDetail || isInsurance || isPatContact{
                if !PrimaryDataHandler.hasAllData(){
                    let dataHandler = PrimaryDataHandler.sharedInstance
                    dataHandler.delegate = self
                    dataHandler.fetchPrimaryData()
                    totalRespCount += 1
                }
            }
            if isPersonalDetail || isPatContact {
                
                if isPersonalDetail {
                    
                    if PrimaryDataHandler.sharedInstance.languageArr == nil || PrimaryDataHandler.sharedInstance.languageArr?.isEmpty == true{
                        charmconnectionHandler?.fetchLanguages(identificationKey:"fetchLanguages")
                        totalRespCount += 1
                    }
                    
                    charmconnectionHandler?.getPrimaryDetForQuestionnaire(physicianTemplates: physicianTemplate, identificationKey: "questionnairePrimaryDetail")
                }
                
                if isPatContact {
                    charmconnectionHandler?.getPrimaryContactDetForQuestionnaire(physicianTemplates: physicianTemplate, identificationKey: "questionnairePatContact")
                }
            }
            
            if isInsurance {
                charmconnectionHandler?.getInsuranceCommonData(practiceId: physicianTemplate.practiceId ?? "", identificationKey: "getInsuranceCommonData")
                
                charmconnectionHandler?.getPrimaryInsuranceForQuestionnaire(physicianTemplates: physicianTemplate, identificationKey: "questionnaireInsurance")
            }
        }
    }
    
    private func deleteInsuranceCard(insuranceCard: InsuranceCard){
        showActivityIndicator()
        charmconnectionHandler?.deleteInsuranceCard(insuranceCard: insuranceCard, identificationKey: "deleteInsuranceCard")
    }
    
    private func downloadInsuranceCard(insuranceCard: InsuranceCard){
        showActivityIndicator()
        charmconnectionHandler?.getInsuranceCard(insuranceCard: insuranceCard, identificationKey: "downloadInsuranceCard:\(insuranceCard.type  ?? "")")
    }
    
    
    private func uploadInsuranceCard(){
        
        if let cardData = tempInsuranceCard[IMAGE_DATA] as? Data{
            let insuranceCard = InsuranceCard()
            insuranceCard.cardData = cardData
            insuranceCard.type = tempInsuranceCardType
            insuranceCard.practiceId = physicianTemplate?.practiceId
            insuranceCard.patientId = getSelectedPatientId()
            insuranceCard.fileName = tempInsuranceCard[FILE_NAME] as? String
            
            showActivityIndicator()
            charmconnectionHandler?.uploadInsuranceCard(insuranceCard: insuranceCard, identificationKey:  "uploadInsuranceCard:\(tempInsuranceCardType ?? "" )")
        }
    }
    
//MARK: - Primary DataHandler delegate
        
    func primaryDataHandlerDidReceiveData() {
        incrementMetaDataCall()
    }
        
    func primaryDataHandlerDidReceiveError(error: Error) {
        hideActivityIndicator()
        CharmUtil.createRetryAndCancelAlertWith(error: error) {
            self.onQuestionnaireDetailFetchSuccess()
        }
    }
    
//MARK: - PatInsuranceViewDelegate
        
    func getPatientDataForInsurance() {
        
        showActivityIndicator()
        charmconnectionHandler?.fetchDemographics(patientId: Patient.selectedPatientInstance?.patientId ?? "", identificationKey: "getPatientDetailForInsurance")
    }
        
    func onPracticeSelected(index: Int){
        
    }
    
//MARK: - ActivityIndicator functions
    
    func showActivityIndicator()
    {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
//MARK: - Connection Handler Delegate functions
    
    func charmConnectionHandlerDidRecieveData(data: Data, indexPath: IndexPath?, identificationKey: String) {
        if identificationKey.hasPrefix("downloadInsuranceCard"){
            hideActivityIndicator()
            let type = identificationKey.components(separatedBy: ":").lastOrNil() ?? ""
            
            let fileName = type == "front" ? questionnaireAnswerModel.patientInsuranceDetails?.frontCardName ?? "" : questionnaireAnswerModel.patientInsuranceDetails?.backCardName ?? ""
            
            if type == "front"{
                self.insuranceFrontCard = data
            }
            else{
                self.insuranceBackCard = data
            }
            self.onInsuranceCardShowImg(type: type, fileName: fileName)
        }
    }
    
    func charmConnectionHandlerDidRecieveData(image: UIImage, tag: Int, identificationKey: String) {
        if identificationKey == "uploadSignature"{
            hideActivityIndicator()
            questionnaireAnswerView.signatureAddedMap[tag] = true
            if let signatureView = view.viewWithTag(tag) as? SignatureView {
                
                signatureView.signatureImgView.image = image
                
                if signatureView.signatureImgView.isHidden {
                    signatureView.signatureImgView.isHidden = false
                    signatureView.signatureLabel.isHidden = true
                    signatureView.btnLayout.isHidden = false
                }
            }
        }
    }
    
    func charmConnectionHandlerDidRecieveData(data: Data, tag: Int, identificationKey: String) {
        if identificationKey == "getSignature"{
            if let signatureView = view.viewWithTag(tag) as? SignatureView {
                if let image = UIImage(data: data){
                    signatureView.hideActivityIndicator()
                    signatureView.signatureImgView.image = image
                    signatureView.signatureImgView.isHidden = false
                    signatureView.signatureLabel.isHidden = true
                    
                    if questionnaireAnswerView.isDataEditAllowed{
                        signatureView.btnLayout.isHidden = false
                    }
                }
            }
        }
    }
    
    func charmConnectionHandlerDidRecieveJsonObject(jsonObject: Dictionary<String, Any>, identificationKey: String) {
        if identificationKey == "fetchQuestionnaireAnswers"{
            questionnaireAnswerModel.questionnaireDetailPOJO = ParsingHelper.fillQuestionnaireAnswers(respObj: jsonObject)
            fetchQuestionnaireAnswersRespCallback()
        }
        else if identificationKey == "uploadQuestionnaireAnswers"{
            hideActivityIndicator()
            
            if let consentFormDelegate = consentFormDelegate {
                 consentFormDelegate.onConsentFormSubmitted(patQuesMapId: physicianTemplate?.patientQuesMap?.patientQuesMapId ?? "")
            }
            else{
                AppDataHandler.sharedInstance().refreshQuestionnaire = true
                self.navigationController?.popViewController(animated: true)
                
                if physicianTemplate?.patientQuesMap?.isSubmitted == true || isAlreadySubmitted{
                    delegate?.addViewControllerDataAdded(message: getString(key: "com.charmphr.questionnairevc.answer.success.message"))
                }
                if let message = jsonObject.getString("message"){
                    delegate?.addViewControllerDataAdded(message: message)
                }
            }
        }
        else if  identificationKey == "uploadQuestionnaireWidgets"{
            if onUpdateQuestionnaire != nil{
                updateQuestionnaireAnswers()
            }
            else{
                charmConnectionHandlerDidRecieveJsonObject(jsonObject: jsonObject , identificationKey: "uploadQuestionnaireAnswers")
            }
        }
        else if identificationKey == "fetchLanguages" {
            PrimaryDataHandler.sharedInstance.languageArr = ParsingHelper.formLanguageList(respObj: jsonObject)
            incrementMetaDataCall()
        }
        else if identificationKey == "questionnairePrimaryDetail" {
            questionnaireAnswerModel.patientObj = ParsingHelper.formPrimaryDetailForQuestionnaire(patientObj: questionnaireAnswerModel.patientObj ?? Patient(), respObj: jsonObject)
            incrementMetaDataCall()
        }
        else if identificationKey == "questionnairePatContact" {
            questionnaireAnswerModel.patientObj = ParsingHelper.formPrimaryContactDetailForQuestionnaire(patientObj: questionnaireAnswerModel.patientObj ?? Patient(), respObj: jsonObject)
            
            incrementMetaDataCall()
            
            questionnaireAnswerView.country = questionnaireAnswerModel.patientObj?.postalAddress?.country ?? ""
            
            if (PrimaryDataHandler.sharedInstance.inStatesArr == nil || PrimaryDataHandler.sharedInstance.inStatesArr?.isEmpty == true) && questionnaireAnswerView.country == country_in{
                fetchstates(country: questionnaireAnswerView.country)
                totalRespCount += 1
            }
            else if (PrimaryDataHandler.sharedInstance.usStatesArr == nil || PrimaryDataHandler.sharedInstance.usStatesArr?.isEmpty == true) && questionnaireAnswerView.country == country_us{
                fetchstates(country: questionnaireAnswerView.country)
                totalRespCount += 1
            }
            else if (PrimaryDataHandler.sharedInstance.auStatesArr == nil || PrimaryDataHandler.sharedInstance.auStatesArr?.isEmpty == true) && questionnaireAnswerView.country == country_au{
                fetchstates(country: questionnaireAnswerView.country)
                totalRespCount += 1
            }
        }
        else if identificationKey == "fetchStates" || identificationKey == "fetchStatesAfterCountryChange"{
            
            if questionnaireAnswerView.country == country_in {
                PrimaryDataHandler.sharedInstance.inStatesArr = ParsingHelper.formStateList(respObj: jsonObject)
            }
            else if questionnaireAnswerView.country == country_us {
                PrimaryDataHandler.sharedInstance.usStatesArr = ParsingHelper.formStateList(respObj: jsonObject)
            }
            else if questionnaireAnswerView.country == country_au{
                PrimaryDataHandler.sharedInstance.auStatesArr = ParsingHelper.formStateList(respObj: jsonObject)
            }
            
            if identificationKey == "fetchStates" {
                incrementMetaDataCall()
            }
            else{
                hideActivityIndicator()
            }
        }
        
        else if identificationKey == "getInsuranceCommonData"{
            questionnaireAnswerModel.insuranceCommonData = ParsingHelper.formInsuranceCommonData(respObj: jsonObject)
            incrementMetaDataCall()
        }
        else if identificationKey == "questionnaireInsurance" {
            let insurance = ParsingHelper.formPrimaryInsuranceForQuestionnaire(respObj: jsonObject)
            
//            if insurance.isFrontCardAvailable == true {
//                totalRespCount += 1
//            }
            
            questionnaireAnswerModel.patientInsuranceDetails = insurance
            incrementMetaDataCall()
        }
        else if identificationKey == "getPatientDetailForInsurance"{
            hideActivityIndicator()
            questionnaireAnswerModel.patientObj = ParsingHelper.getPatientDetails(patientObj: questionnaireAnswerModel.patientObj ?? Patient(), dict: jsonObject)
            questionnaireAnswerView.onPatientDetailInsuranceSuccess()
        }
        else if identificationKey == "getPayerList"{
            
            questionnaireAnswerModel.practicePayerList =  ParsingHelper.formPayerList(respObj: jsonObject)
            
            selectViewController?.arrayOfValueToBeShown = questionnaireAnswerModel.practicePayerList.map{payer in
                payer.payerName ?? ""
            }
            selectViewController?.filterValueArrayWithSearchText(isFromApi: true)
        }
    }
    
    private func incrementMetaDataCall(){
        callbackCount = callbackCount+1
        if callbackCount == totalRespCount && !isCallbackSent {
            onQuestionnaireDetailFetchSuccess()
        }
    }
    
    func charmConnectionHandlerDidFailWithError(error: Error, identificationKey: String) {
        
        if identificationKey == "fetchQuestionnaireAnswers"
        {
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.getQuestionnaireAnswers()
            }, cancelClicked: {
                self.navigationController?.popViewController(animated: true)
            })
        }
        else if identificationKey == "fetchLanguages" || identificationKey == "questionnairePrimaryDetail" || identificationKey == "questionnairePatContact" || identificationKey == "getInsuranceCommonData" || identificationKey == "questionnaireInsurance" || identificationKey == "fetchStates"{
            hideActivityIndicator()
            
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.onQuestionnaireDetailFetchSuccess()
            }
        }
        
        else if identificationKey == "uploadQuestionnaireAnswers" || identificationKey == "uploadQuestionnaireWidgets"
        
        {
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
        else if identificationKey == "fetchStatesAfterCountryChange"{
            
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.fetchStatesAfterCountryChange(countryName: self.questionnaireAnswerView.country)
            }
        }
        
        else if identificationKey == "getPatientDetailForInsurance"{
            
            hideActivityIndicator()
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.getPatientDataForInsurance()
            }
        }
        else if identificationKey == "getPayerList"{
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
        else{
            
            hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
            
        }
    }
    
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "deleteInsuranceCard"{
            if let type = response as? String {
                if type == "front"{
                    self.insuranceFrontCard = nil
                }
                else{
                    self.insuranceBackCard = nil
                }
                questionnaireAnswerView.onInsuranceCardDeleteSuccess(type: type)
            }
        }
        else if identificationKey.hasPrefix("uploadInsuranceCard"){
            let type = identificationKey.components(separatedBy: ":").last ?? ""
          
            if type == "front"{
                if let imageData = tempInsuranceCard[IMAGE_DATA] as? Data{
                    self.insuranceFrontCard = imageData
                    questionnaireAnswerView.onInsuranceCardUploadSuccess(type: type, fileName: tempInsuranceCard[FILE_NAME] as? String)
                }
            }
            else{
                if let imageData = tempInsuranceCard[IMAGE_DATA] as? Data{
                    self.insuranceBackCard = imageData
                    questionnaireAnswerView.onInsuranceCardUploadSuccess(type: type, fileName: tempInsuranceCard[FILE_NAME] as? String)
                }
            }
            tempInsuranceCard = [:]
        }
        else if identificationKey.contains("activeAllergy")
        {
            if let activeAllergyList = response as? [AllergiesList]{
                arrayOfActiveAllergies = activeAllergyList
                
                arrayOfActiveAllergies = FilterHandler.filterAndSortAllergies(arrayOfAllergies: arrayOfActiveAllergies)
                allergyDelegate?.patientAddedAllergies(allergies: arrayOfActiveAllergies)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "deleteInsuranceCard"{
            CharmUtil.createOkayAlertWith(error: error, okClicked: {
                
            })
        }
        else if identificationKey.hasPrefix("uploadInsuranceCard"){
            CharmUtil.createRetryAndCancelAlertWith(error: error, tryAgainClicked: {
                self.uploadInsuranceCard()
            })
        }
    }
    
//MARK: - action calles
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
//MARK: - onQuestionnaireDetailFetchSuccess
    
    private func onQuestionnaireDetailFetchSuccess(){
        
        hideActivityIndicator()
        
        var isSupported = true
        var isEmpty = false
        if questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.isEmpty == true {
            isEmpty = true
        }
        else{

            if let notesTypeList =  questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.map({questionnairEntryPOJO in
                questionnairEntryPOJO.questionnaireEntry.notesType
            }).filter({notesType in
                !notesType.isNilOrBlank()
            }){
                
                for notesType in notesTypeList {
                    if !questionnaireSupportedWidgets.contains(notesType ?? ""){
                        isSupported = false
                    }
                    
                    if !isSupported {
                        break
                    }
                }
            }
        }

        if isSupported && !isEmpty{
            physicianTemplate?.templateId = questionnaireAnswerModel.questionnaireDetailPOJO?.templateId
            renderQuestionnaireAnswerView()
        }
        else{
            
            let uiLabelView = NoDataView()
            self.view.addSubview(uiLabelView)

            if !isSupported{
                uiLabelView.setImage(enum: .noData, title: getString(key: "com.charmphr.questionnaire.notsupported"), message: "")
            }
            else if isEmpty{
                uiLabelView.setImage(enum: .noData, title: getString(key: "com.charmphr.questionnaire.empty"), message: "")
            }

            uiLabelView.setCenterX()
            uiLabelView.setCenterY()
        }
    }
    
//MARK: - Render QuestionnaireAnswerView
    
    func renderQuestionnaireAnswerView(){
        if let physicianTemplate = physicianTemplate{
            questionnaireAnswerView.initView(physicianTemplate: physicianTemplate, questionnaireAnswerModel: questionnaireAnswerModel, delegate: self)
        }
    }
    
//MARK: - Signature Widget functions
    
    func onAddSignatureClick(_ sender: UITapGestureRecognizer?) {
        
        bgView.isHidden = false
        signaturePopVC = SignatureViewController()
        
        if let mc = signaturePopVC{
            if let signatureView = sender?.view?.superview?.superview?.superview as? SignatureView {
                mc.tag = signatureView.tag
                
                if let commonLayout = signatureView.superview?.superview as? CommonQuestionnaireLayout {
                    mc.titleStr = removeStar(uiLabel: commonLayout.commonQuestionnaireLabel) ?? ""
                }
            }
            mc.delegate = self
            
            mc.modalPresentationStyle = .custom
            mc.transitioningDelegate = self
            self.present(mc, animated: true, completion: nil)
        }
    }
    
    func onImgSelected(selectedImg: UIImage? , tag: Int) {
        signaturePopVC = nil
        bgView.isHidden = true
        
        if let selectedImg = selectedImg{
            let index =  questionnaireAnswerView.tagList.firstIndex(of: tag) ?? -1
            if index != -1 {
                
                let entryId = questionnaireAnswerView.idList[index]
                if let feedbackPOJO = questionnaireAnswerModel.questionnaireDetailPOJO?.questionnairEntryPOJOList.first(where: { (questionnaireEntryPOJO) -> Bool in
                    return questionnaireEntryPOJO.questionnaireEntry.entryId == entryId
                })
                {
                    uploadSignatureImage(selectedImg: selectedImg, feedbackPOJO: feedbackPOJO, tag: tag)
                }
            }
        }
    }
    
    //MARK: - Insurance Card view delegate
    
    func onInsuranceCardCameraClicked(type: String) {
        if questionnaireAnswerView.isDataEditAllowed {
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.tempInsuranceCardType = type
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.mediaTypes = [String(kUTTypeImage),String(kUTTypePNG),String(kUTTypeJPEG)]
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func onInsuranceCardGalleryClicked(type: String) {
        if questionnaireAnswerView.isDataEditAllowed {
            tempInsuranceCardType = type
            
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1 //0 - unlimited 1 - default
            configuration.filter = .images
            let pickerViewController = PHPickerViewController(configuration: configuration)
            pickerViewController.delegate = self
            self.present(pickerViewController, animated: true)
        }
    }
    
    func onInsuranceCardDeleteClicked(type: String) {
        if questionnaireAnswerView.isDataEditAllowed {
            
            CharmUtil.createYesOrNoActionWith(title: getString(key: "com.charmphr.insurance.card.alert.delete.message"), msg: nil, yesClicked: {
                let insuranceCard = InsuranceCard()
                insuranceCard.type = type
                insuranceCard.practiceId = self.physicianTemplate?.practiceId
                insuranceCard.patientId = getSelectedPatientId()
                self.deleteInsuranceCard(insuranceCard: insuranceCard)
            })
        }
    }
    
    func onInsuranceCardShowImg(type:String, fileName: String?){
        var cardImageData: Data? = nil
        
        if type == "front"{
            cardImageData = insuranceFrontCard
        }
        else{
            cardImageData = insuranceBackCard
        }
        
        if let cardImageData{
            let pdfImageVC = PDFImageViewController(fileName: fileName, data: cardImageData)
            self.navigationController?.pushViewController(pdfImageVC, animated: true)
        }
        else{
            let insuranceCard = InsuranceCard()
            insuranceCard.type = type
            insuranceCard.practiceId = self.physicianTemplate?.practiceId
            insuranceCard.patientId = getSelectedPatientId()
            downloadInsuranceCard(insuranceCard: insuranceCard)
        }
    }
    
    //MARK: UIImagePicker delegate
    
    func fetchOriginalImageData(from asset: PHAsset, completion: @escaping (Data?) -> Void) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestImageDataAndOrientation(for: asset, options: options) { (data, _, _, _) in
                completion(data)
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        var data: Data? = nil
        
        if let image = (info[.originalImage] as? UIImage)?.fixedOrientation(){
           
            picker.dismiss(animated: true) { [self] in
                
                data = image.jpegData(compressionQuality: 0.8)
                onImagePicked(data: data, fileName: "insuranceCard\(self.tempInsuranceCardType ?? "").png")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    //MARK: - PHPicker delegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        if let result = results.firstOrNil() {
            
            let itemProvider = result.itemProvider
            let typeIdenti = UTType.image.identifier
            
            if itemProvider.hasItemConformingToTypeIdentifier(typeIdenti){
                
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdenti , completionHandler: {url, error in
                    if let url = url, let data = try? Data(contentsOf: url){
                        DispatchQueue.main.async {
                            self.onImagePicked(data: data, fileName: url.lastPathComponent)
                        }
                    }
                    else{
                        CharmUtil.createOkayAlertWith(title: nil, msg:  getString(key: "com.charmphr.profile.image.failed"))
                        DispatchQueue.main.async {
                            self.hideActivityIndicator()
                        }
                    }
                })
            }
            else{
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    private func onImagePicked(data: Data? ,fileName: String){
        
        if let data {
            let fileSizeInBytes: Int = data.count
            let fileSize: Double = Double(fileSizeInBytes) / (1024 * 1024)
            
            debugPrintLog("File Size: \(fileSize) MB")
            
            if fileSize <= 10.0{
                tempInsuranceCard[IMAGE_DATA] = data
                tempInsuranceCard[FILE_NAME] = fileName
                uploadInsuranceCard()
            }
            else{
                CharmUtil.createOkayAlertWith(title: nil, msg:  getString(key: "com.charmphr.support.fileSize.alert.message.title", with: ["10"]))
            }
        }
        else{
            CharmUtil.createOkayAlertWith(title: "", msg: getString(key: "com.charmphr.profile.image.failed"))
        }
    }
    
//MARK: - Dismiss AllModalVCPresented
    
    func dismissAllModalVCPresented(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(makeDelay), name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(makeDelay), name: Notification.Name("REMINDER_POP_DISMISSED"), object: nil)
        
        if let multiSelectPopVC = multiSelectPopVC{
            presentedModalVC = multiSelectPopVC
            multiSelectPopVC.dismiss(animated: false)
        }
        else if let signaturePopVC = signaturePopVC{
            presentedModalVC = signaturePopVC
            signaturePopVC.dismiss(animated: false)
        }
        
        dismissModelView()
    }
    
    @objc func makeDelay(){
        self.perform(#selector(presentViewController), with: nil, afterDelay: 0.35)
    }
    
    @objc func presentViewController(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SESSION_UN_LOCKED"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("REMINDER_POP_DISMISSED"), object: nil)
        
        if navigationController?.isBeingPresented != true {
            if let multiSelectPopVC = presentedModalVC as? MultiselectValueViewController{
                self.multiSelectPopVC = multiSelectPopVC
                navigationController?.present(multiSelectPopVC, animated: true)
            }
            else if let signaturePopVC = presentedModalVC as? SignatureViewController{
                self.signaturePopVC = signaturePopVC
                navigationController?.present(signaturePopVC, animated: true)
            }
        }
        presentedModalVC = nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
    
    private func removeStar(uiLabel: UILabel) -> String? {
        if uiLabel.text?.hasSuffix("*") == true {
            let str = NSMutableAttributedString(string: uiLabel.text ?? "")
            str.deleteCharacters(in: NSRange(location: str.length - 2, length: 2))
            return str.string
        }
        return uiLabel.text
    }
    
    //MARK: // Dismiss delegate
    
    func dismissModelView() {
        if let vc = self.presentedViewController {
            vc.dismiss(animated: false)
        }
    }
   
}
