//
//  ColorExe.swift
//  Cogito
//
//  Created by Prince Yadav on 08/12/24.
//

import SwiftUI

extension Color {
    // Light Mode Colors
    static let lightBackground = Color(hex: "F0F4F8")
    static let lightPrimary = Color(hex: "4A90E2")
    static let lightSecondary = Color(hex: "5E72E4")
    static let lightAccent = Color(hex: "11CDEF")
    
    // Dark Mode Colors
    static let darkBackground = Color(hex: "121212")
    static let darkPrimary = Color(hex: "2196F3")
    static let darkSecondary = Color(hex: "7C4DFF")
    static let darkAccent = Color(hex: "00BCD4")
    
    // Utility method to create color from hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Dynamic color based on color scheme
    func dynamicColor(lightMode: Color, darkMode: Color) -> Color {
        return self == .primary ?
            (UITraitCollection.current.userInterfaceStyle == .dark ? darkMode : lightMode) :
            self
    }
}
