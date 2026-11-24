//
//  ShareSectionView.swift
//  PHR
//
//  Created by Prathiba M on 25/08/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import SwiftUI

class ShareSectionViewController: UIViewController, AddViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        self.title = getString(key: "com.charmphr.shareSection.title")
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)), animated: true)
        
        let shareSectionView = ShareSectionView { shareSection in
            self.pushToAddShareSectionVC(shareSection: shareSection)
        }
        
        let hostingController = UIHostingController(rootView: shareSectionView)
        
        addChild(hostingController)
        self.view.addSubview(hostingController.view)
        
        guard let hostView = hostingController.view else { return }
        
        hostView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
    
    @objc private func addButtonClicked(){
        pushToAddShareSectionVC()
    }
    
    private func pushToAddShareSectionVC(shareSection: ShareSection? = nil) {
        let addShareSectionVC = AddShareSectionViewController(shareSection: shareSection, delegate: self)
        self.navigationController?.pushViewController(addShareSectionVC, animated: true)
    }
    
    func addViewControllerDataAdded(message: String?) {
        if let message {
            CharmUtil.showToast(controller: self, message: message, seconds: 2)
        }
    }
}

private struct ShareSectionView: View {
    
    @StateObject private var viewModel = ShareSectionViewModel()
    var onShareSectionSelected: ((ShareSection) -> Void)
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.0)
            } else {
                if viewModel.shareSectionList.isEmpty {
                    
                    VStack(spacing: 20) {
                        Image("NoData")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        Text(getString(key: "com.charmphr.shareSection.list.noData.title"))
                            .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .semibold, textColor: TEXT_COLOR_BLACK87)
                        
                        Text(getNoDataMessage())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(rgba: APPLICATION_BACKGROUND_COLOR))
                }
                else{
                    VStack(alignment: .leading) {
                        HStack {
                            Text(getString(key: "com.charmphr.shareSection.sharedHistory.title"))
                                .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .semibold, textColor: TEXT_COLOR_BLACK87)
                                .padding(.top, 18)
                                .padding(.leading, 18)
                            Spacer()
                        }
                        
                        List(viewModel.shareSectionList) { section in
                            ShareSectionItemView(section: section)
                                .listRowStyle(vertical: 3, horizontal: 16)
                                .onTapGesture {
                                    onTapListItemView(section: section)
                                }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            viewModel.refreshShareSection()
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color(rgba: APPLICATION_BACKGROUND_COLOR))
                }
            }
        }
        .onAppear {
            viewModel.fetchShareSection()
        }
    }
    
    private func getNoDataMessage() -> AttributedString{
        let string = getString(key: "com.charmphr.shareSection.list.noData.message")
        var attributedStr = AttributedString(string)
        
        attributedStr.foregroundColor = Color(rgba: TEXT_COLOR_MEDIUM_LIGHT)
        attributedStr.font = Font.systemFont(size: FONT_SIZE_NORMAL, weight: .regular)
        
        if let plusRange = attributedStr.range(of: "+") {
            attributedStr[plusRange].foregroundColor = Color(rgba: THEME_COLOR)
            attributedStr[plusRange].font = Font.systemFont(size: FONT_SIZE_NORMAL, weight: .regular)
        }
        return attributedStr
    }

    private func onTapListItemView(section: ShareSection){
        onShareSectionSelected(section)
    }
}

fileprivate class ShareSectionViewModel: ObservableObject, CharmConnectionV2HandlerDelegate {
    
    @Published var shareSectionList: [ShareSection] = []
    @Published var isLoading: Bool = false
    
    private var charmConnectionHandler: CharmConnectionHandler?

    init() {
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
    }
    
    func refreshShareSection(){
        charmConnectionHandler?.fetchSharedSectionPracticeList(identificationKey: "FetchShareSectionList")
    }

    func fetchShareSection(){
        showActivityIndicator()
        refreshShareSection()
    }

    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "FetchShareSectionList" {
            if let list = response as? [ShareSection] {
                self.shareSectionList = list
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: any Error, identificationKey: String) {
        hideActivityIndicator()
        if identificationKey == "FetchShareSectionList"{
            CharmUtil.createRetryAndCancelAlertWith(error: error) {
                self.fetchShareSection()
            }
        }
    }
    
    private func showActivityIndicator() {
        self.isLoading = true
    }
    
    private func hideActivityIndicator() {
        self.isLoading = false
    }
}
