//
//  ShareSectionItemView.swift
//  PHR
//
//  Created by Prathiba M on 25/08/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import SwiftUI

struct ShareSectionItemView: View {
    
    var section: ShareSection

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(section.practiceName ?? "")
                    .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .medium, textColor: TEXT_COLOR_BLACK87)
                    .padding(.leading, 10)
                    .padding(.top, 13)
                    .padding(.bottom, 8)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Image("EditIconBlue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 12)
            }
            Divider()
                .background(Color(rgba: SEPARATOR_COLOR))
            Text(getString(key: "com.charmphr.shareSection.sharedSection.title"))
                .setProperties(fontSize: FONT_SIZE_MEDIUM, weight: .regular, textColor: TEXT_COLOR_LIGHT)
                .padding(.top, 7)
                .padding(.leading, 10)
            let sectionList = section.sectionsList.filter {
                !sectionExcludeList.contains($0)
            }
            Text(sectionList.joined(separator: ", "))
                .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .regular, textColor: TEXT_COLOR_BLACK87)
                .padding(.top, 5)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.bottom, 10)
        }
        .background(Color.white)
        .cornerRadius(CardSize.SMALL.value)
        .shadow(color: Color(rgba: SHADOW_COLOR).opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
