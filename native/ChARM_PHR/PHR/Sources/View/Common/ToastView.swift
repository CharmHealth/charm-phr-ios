//
//  ToastView.swift
//  PHR
//
//  Created by Prathiba M on 11/09/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import SwiftUI

struct ToastView: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(!isShowing)
            if isShowing {
                VStack {
                    Spacer()
                    
                    HStack {
                        Text(message)
                            .setProperties(fontSize: FONT_SIZE_NORMAL, weight: .medium, textColor: WHITE_COLOR)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(rgba: TEXT_COLOR_LIGHT))
                    .cornerRadius(CardSize.LARGE.value)
                    .padding(.horizontal, 16) // outer padding
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: isShowing)
                }
            }
        }
        .onChange(of: isShowing) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isShowing = false
                }
            }
        }
    }
}
