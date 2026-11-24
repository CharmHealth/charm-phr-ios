//
//  CommonSwiftUIView.swift
//  PHR
//
//  Created by Prathiba M on 11/09/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import SwiftUI
import UIKit

struct InfoBoxView: View {
    var infoTextKey: String
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image("info")
                .frame(width: 16, height: 16)
                .padding(.top, 8)
                .padding(.leading, 6)

            Text(getString(key: infoTextKey))
                .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .regular, textColor: TEXT_COLOR_BLACK87)
                .padding(.trailing, 6)
                .padding(.vertical, 6)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .background(Color(rgba: INFO_BG_COLOR))
        .cornerRadius(CardSize.SMALL.value)
    }
}

struct CheckBoxButton: View {
    let selectValueModel: SelectValueModel
    @Binding var isSelected: Bool
    private let padding: CGFloat = 5
    
    var body: some View {
        HStack (alignment: .top) {
            if isSelected {
                Image("CheckboxSelected")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.top, padding)
            }
            else{
                Image("CheckboxUnselected")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.top, padding)
            }
            Text(selectValueModel.name)
                .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .regular, textColor: TEXT_COLOR_BLACK87)
                .padding(.trailing, padding)
                .padding(.top, padding + 2)
                .padding(.bottom, padding)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .onTapGesture {
            isSelected = !isSelected
        }
    }
}

struct AutoHeightList: View {
    let items: [SelectValueModel]
    @State var totalHeight: CGFloat = 0
    let topPadding: CGFloat
    let onSelect: (SelectValueModel) -> Void
    
    private let minItemHeight: CGFloat = 44
    private let maxHeight: CGFloat = 200
    private let verticalSpacing: CGFloat = 8
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: verticalSpacing) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack{
                        Text(item.name)
                            .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .regular, textColor: TEXT_COLOR_BLACK87)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        GeometryReader { geo in
                            Color.white
                                .onAppear {
                                    if index == items.count - 1 {
                                        totalHeight += geo.size.height + (verticalSpacing * 2)
                                    }
                                    else{
                                        totalHeight += geo.size.height + (verticalSpacing * 2) + 1
                                    }
                                }
                        }
                    )
                    .onTapGesture {
                        onSelect(item)
                    }
                    Divider()
                        .background(Color(rgba: LINE_COLOR))
                        .padding(.leading, 15)
                }
            }
            .padding(.top, topPadding + verticalSpacing)
        }
        .frame(height: min(totalHeight, maxHeight))
        .frame(maxWidth: .infinity)
    }
}
