//
//  SwiftUI_Extension.swift
//  PHR
//
//  Created by Prathiba M on 15/09/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

import SwiftUI


extension Color {
    init(rgba: UInt) {
        let r = Double((rgba >> 24) & 0xFF) / 255.0
        let g = Double((rgba >> 16) & 0xFF) / 255.0
        let b = Double((rgba >> 8) & 0xFF) / 255.0
        let a = Double(rgba & 0xFF) / 255.0
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

extension Font {
    static func systemFont(size: CGFloat, weight: UIFont.FontWeight) -> Font {
        return Font(UIFont.systemFont(ofSize: size, Weight: weight))
    }
}

extension Text {
    func setProperties(fontSize: CGFloat, weight: Font.Weight, textColor: UInt) -> some View {
        self
            .font(.system(size: fontSize, weight: weight))
            .foregroundColor(Color(rgba: textColor))
    }
}


extension View {
    func listRowStyle(vertical: CGFloat, horizontal: CGFloat) -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .padding(.vertical, vertical)
            .padding(.horizontal, horizontal)
    }
    
    func addBorder(borderColor: UInt, width: CGFloat, cornerRadius: CGFloat) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(rgba: borderColor), lineWidth: width)
            )
    }
    
    func addCornerRadius(bgColor: UInt, radius: CGFloat) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(Color(rgba: bgColor))
            )
    }
    
    func addCustomCornerRadiusWithBorder(_ radius: CGFloat, corners: UIRectCorner, bgColor: UInt, borderColor: UInt, lineWidth: CGFloat) -> some View {
        self
            .clipShape(RoundedCorners(radius: radius, corners: corners))
            .background(
                RoundedCorners(radius: radius, corners: corners)
                    .fill(Color(rgba: bgColor))
            )
            .overlay(
                RoundedCorners(radius: radius, corners: corners)
                    .stroke(Color(rgba: borderColor), lineWidth: lineWidth)
            )
    }
}

extension View {
    func showToast(isShowing: Binding<Bool>, message: String, duration: Double = 1.5) -> some View {
        self.modifier(ToastView(isShowing: isShowing, message: message, duration: duration))
    }
}

fileprivate struct RoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

