//
//  ThemeManager.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .default
    @Published var isDarkMode: Bool = false

    
    static let shared = ThemeManager()
    
    enum AppTheme: String, CaseIterable {
        case `default` = "Default"
        case dark = "Dark"
        case light = "Light"
        case nature = "Nature"
        case ocean = "Ocean"
        
        var primaryColor: Color {
            switch self {
            case .default: return .blue
            case .dark: return .purple
            case .light: return .orange
            case .nature: return .green
            case .ocean: return .teal
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .default: return Color(.systemBackground)
            case .dark: return Color(.systemGray6)
            case .light: return .white
            case .nature: return Color(.systemGray6).opacity(0.3)
            case .ocean: return Color(.systemBlue).opacity(0.1)
            }
        }
        
        var secondaryColor: Color {
            switch self {
            case .default: return .gray
            case .dark: return .purple.opacity(0.7)
            case .light: return .orange.opacity(0.7)
            case .nature: return .green.opacity(0.7)
            case .ocean: return .teal.opacity(0.7)
            }
        }
    }
}
