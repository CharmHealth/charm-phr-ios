//
//  DropDownWithSearchView.swift
//  PHR
//
//  Created by Prathiba M on 01/09/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import SwiftUI

struct DropDownWithSearchView: View {
    let placeholder: String
    let renderingList: [SelectValueModel]
    let onSelect: (SelectValueModel) -> Void
    let onClose: () -> Void
    
    @State private var searchText: String = ""
    @State private var selectedValue: SelectValueModel? = nil
    @State private var isEditable: Bool = true
    @FocusState private var isTextFieldFocused: Bool
    @Binding private var isFocused: Bool
    private let cornerRadius: CGFloat = CardSize.SMALL.value
    private let minHeight: CGFloat = 40
    
    init(placeholder: String, selectedValue: SelectValueModel?, renderingList: [SelectValueModel], onSelect: @escaping (SelectValueModel) -> Void, onClose: @escaping () -> Void, isFocused: Binding<Bool>){
        self.placeholder = placeholder
//        self.selectedValue = selectedValue
        self.renderingList = renderingList
        self.onSelect = onSelect
        self.onClose = onClose
        _isFocused = isFocused
        _selectedValue = State(initialValue: selectedValue)

        guard let selectedValue else { return }
        _isEditable = State(initialValue: false)
        _searchText = State(initialValue: selectedValue.name)
    }
    
    private var filteredList: [SelectValueModel] {
        if searchText.isEmpty {
            return renderingList
        } else {
            return renderingList.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                let bgColor: Color = isEditable ? .white : Color(rgba: LIGHT_GRAY_BG_COLOR)
                VStack(alignment: .leading, spacing: 0) {
                    if isEditable{
                        TextField(placeholder, text: $searchText)
                            .disabled(!isEditable)
                            .focused($isTextFieldFocused)
                            .padding(.horizontal, 10)
                            .frame(height: minHeight)
                            .font(.systemFont(size: FONT_SIZE_NORMAL, weight: .regular))
                            .foregroundColor(Color(rgba: TEXT_COLOR_BLACK87))
                            .onChange(of: isTextFieldFocused) { newValue in
                                isFocused = newValue       // update parent
                            }
                            .onChange(of: isFocused) { newValue in
                                isTextFieldFocused = newValue      // update internal state
                            }
                    }
                    else{
                        HStack(alignment: .center) {
                            Text(searchText)
                                .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .regular, textColor: TEXT_COLOR_BLACK87)
                                .padding(.leading, 8)
                                .padding(.vertical, 10)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            
                            if !isEditable {
                                Button(action: {
                                    searchText = ""
                                    selectedValue = nil
                                    isEditable = true
                                    onClose()
                                }) {
                                    Image("dustBin_Gray")
                                }
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 6)
                                .padding(.vertical, 8)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
                    }
                }
                .background(bgColor)
                .cornerRadius(cornerRadius)
                .addBorder(borderColor: BORDER_COLOR, width: 1, cornerRadius: CardSize.SMALL.value)
                .shadow(color: Color(rgba: SHADOW_COLOR).opacity(0.1), radius: 5, x: 0, y: 0)
                .zIndex(1)
                
                if isFocused && isEditable {
                    if filteredList.isEmpty {
                        VStack {
                            Spacer()
                            Text(getString(key: "com.charmphr.sharedocuments.member.noDataLabel.title"))
                                .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .semibold, textColor: TEXT_COLOR_BLACK87)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 70 + cornerRadius)
                        .addCustomCornerRadiusWithBorder(cornerRadius, corners: [.bottomLeft, .bottomRight], bgColor: WHITE_COLOR, borderColor: LINE_COLOR, lineWidth: 0.5)
                        .offset(y: -cornerRadius)
                        .zIndex(0)
                    } else {
                        AutoHeightList(items: filteredList, totalHeight: cornerRadius, topPadding: cornerRadius) { item in
                            selectedValue = item
                            searchText = item.name
                            isEditable = false
                            isFocused = false
                            isTextFieldFocused = false
                            onSelect(item)
                        }
                        .addCustomCornerRadiusWithBorder(cornerRadius, corners: [.bottomLeft, .bottomRight], bgColor: WHITE_COLOR, borderColor: LINE_COLOR, lineWidth: 0.5)
                        .offset(y: -cornerRadius)
                        .zIndex(0)
                    }
                }
            }
        }
    }
}
