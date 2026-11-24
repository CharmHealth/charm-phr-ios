//
//  AddShareSectionView.swift
//  PHR
//
//  Created by Prathiba M on 25/08/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import SwiftUI
import UIKit

class AddShareSectionViewController: AddDataUIViewController, CharmConnectionV2HandlerDelegate{
    
    private weak var delegate: AddViewControllerDelegate? = nil
    private var shareSection: ShareSection? = nil
    private var hostingController: UIHostingController<AddShareSectionView>?
    private let sharedState = AddShareSectionSharedState() // ✅ Shared between UIKit & SwiftUI
    private let activityIndicator = UIActivityIndicatorView()
    private lazy var charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
    
    init(shareSection: ShareSection?, delegate: AddViewControllerDelegate){
        
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.shareSection = shareSection
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.title = getString(key: "com.charmphr.shareSection.addShareSection.title")
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked)), animated: true)
        
        let addShareSectionView = AddShareSectionView(shareSection: shareSection, sharedState: sharedState, onFetchShareSection: {
            self.fetchShareSectionList()
        })
        
        hostingController = UIHostingController(rootView: addShareSectionView)
        
        guard let hostingController else { return }
        addChild(hostingController)
        self.view.addSubview(hostingController.view)
        self.view.addSubview(activityIndicator)
        
        activityIndicator.color = .gray
        activityIndicator.setCenterX()
        activityIndicator.setCenterY()
        
        guard let hostView = hostingController.view else { return }
        
        hostView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostView.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
    
    //MARK: - Api calls
    
    func addShareSectionList(practiceId: String?, sectionList: [String]){
        
        var shareSection = ShareSection()
        shareSection.practiceId = practiceId
        shareSection.sectionsList = sectionList
        
        showActivityIndicator()
        charmConnectionHandler.addShareSectionPracticeList(patientId: getSelectedPatientId(), shareSection: shareSection, identificationKey: "AddShareSection")
    }
    
    func fetchShareSectionList(){
        guard let practiceId = sharedState.selectedPractice?.practiceId else { return }
        showActivityIndicator()
        charmConnectionHandler.fetchSharedSectionList(practiceId: practiceId, identificationKey: "FetchShareSection")
    }
    
    //MARK: - Target functions
    
    override func onBackClick() {
        if sharedState.isValueChanged{
            showDiscardChangesDialog()
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func doneBtnClicked(){
        addShareSectionList(practiceId: sharedState.selectedPractice?.practiceId, sectionList: sharedState.selectedSections )
    }
    
    //MARK: - ActivityIndicator functions

    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "AddShareSection" {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.addViewControllerDataAdded(message: getString(key: "com.charmphr.shareSection.addShareSection.add.success.message"))
        }
        else if identificationKey == "FetchShareSection"{
            if let shareSection = response as? ShareSection{
                sharedState.selectedSections = shareSection.sectionsList
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "AddShareSection"{
            CharmUtil.createOkayAlertWith(error: error)
        }
        else if identificationKey == "FetchShareSection"{
            CharmUtil.createRetryAndCancelAlertWith(error: error) { [self] in
                fetchShareSectionList()
            }
        }
    }
    
    private func showActivityIndicator() {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
}

fileprivate struct AddShareSectionView: View {
        
    @ObservedObject var sharedState: AddShareSectionSharedState   // ✅ Shared reference
    private let practiceList: [Practice] = getActivePracticeList()
    var onFetchShareSection: (() -> Void)?

    @State private var isShowDropDown: Bool = false
    
    init(shareSection: ShareSection?, sharedState: AddShareSectionSharedState, onFetchShareSection: (() -> Void)?) {
        self.sharedState = sharedState
        self.onFetchShareSection = onFetchShareSection
        
        if let shareSection {
            if let practice = practiceList.first(where: { $0.practiceId == shareSection.practiceId }) {
                sharedState.selectedPractice = practice
            }
            sharedState.selectedSections = shareSection.sectionsList
        }
    }
    
    var body: some View {
        
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                InfoBoxView(infoTextKey: "com.charmphr.shareSection.addShareSection.info.message")
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                
                Text(getString(key: "com.charmphr.sharedocuments.toLabel.title"))
                    .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .regular, textColor: TEXT_COLOR_BLACK87)
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                
                FacilitySelectView(practiceList: practiceList, selectedPractice: $sharedState.selectedPractice, selectedSections: $sharedState.selectedSections, isValueChanged: $sharedState.isValueChanged, isShowDropDown: $isShowDropDown, fetchShareSectionList: fetchShareSectionList)
                
                if sharedState.selectedPractice != nil{
                    SectionSelectView(shareSectionList: shareSectionList, selectedSections: $sharedState.selectedSections, isValueChanged: $sharedState.isValueChanged)
                    Spacer()
                }
            }
            .onAppear(perform: {
                if practiceList.count == 1 && sharedState.selectedPractice == nil{
                    sharedState.selectedPractice = practiceList.first
                    fetchShareSectionList()
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(rgba: APPLICATION_BACKGROUND_COLOR))
        }
    }
    
    private func fetchShareSectionList(){
        onFetchShareSection?()
    }
}

fileprivate struct FacilitySelectView: View {
    
    let practiceList: [Practice]
    @Binding var selectedPractice: Practice?
    @Binding var selectedSections: [String]
    @Binding var isValueChanged: Bool
    @Binding var isShowDropDown: Bool
    let fetchShareSectionList: () -> Void
    

    var body: some View {
        let selectModelList = TransformUtil.transformPracticeToSelectModel(practiceList: practiceList)
        let selectedModel = selectModelList.first { selectModel in
            return selectModel.id == (selectedPractice?.practiceId ?? "")
        } ?? (selectModelList.count == 1 ? selectModelList.first : nil)
        
        DropDownWithSearchView(placeholder: getString(key: "com.charmphr.shareSection.addShareSection.facility.placeholder"), selectedValue: selectedModel, renderingList: selectModelList, onSelect: { selectedValue in
            selectedPractice = practiceList.first(where: { practice in
                return practice.practiceId == selectedValue.id
            })
            fetchShareSectionList()
            isValueChanged = true
        }, onClose: {
            selectedSections = []
            selectedPractice = nil
            isValueChanged = true
        }, isFocused: $isShowDropDown)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
}

fileprivate struct SectionSelectView: View {
    let shareSectionList: [String]
    @Binding var selectedSections: [String]
    @Binding var isValueChanged: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(getString(key: "com.charmphr.shareSection.addShareSection.selectSection.title"))
                .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .semibold, textColor: TEXT_COLOR_BLACK87)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
                .background(Color(rgba: SEPARATOR_COLOR))
            VStack(alignment: .leading, spacing: 12) {
                let selectModelList = TransformUtil.transformStringToSelectValueModel(stringArr: shareSectionList)
                ForEach(selectModelList) { selectValueModel in
                    
                    let binding = Binding(
                        get: { selectedSections.contains(selectValueModel.name) },
                        set: { toggleSelection(section: selectValueModel.name, isSelected: $0) })
                    CheckBoxButton(selectValueModel: selectValueModel, isSelected: binding)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(Color.white)
        .cornerRadius(CardSize.SMALL.value)
        .shadow(color: Color(rgba: SHADOW_COLOR).opacity(0.1), radius: 5, x: 0, y: 0)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    private func toggleSelection(section: String, isSelected: Bool) {
        isValueChanged = true
        if isSelected {
            selectedSections.append(section)
        } else {
            selectedSections.removeAll { $0 == section }
        }
        debugPrintLog("Section Selected: \(selectedSections)")
    }
}

final class AddShareSectionSharedState: ObservableObject {
    @Published var isValueChanged: Bool = false
    @Published var selectedSections: [String] = []
    @Published var selectedPractice: Practice? = nil
}
