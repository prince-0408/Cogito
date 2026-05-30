import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case oceanic = "Oceanic"
    case mint = "Mint Green"
    case lavender = "Lavender"
    case sunset = "Sunset Peach"
    case royal = "Indigo Royal"
    case coral = "Coral Red"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .oceanic: return Color(red: 0.06, green: 0.65, blue: 0.85) // Sleek neon cyan-blue
        case .mint: return Color(red: 0.08, green: 0.72, blue: 0.48) // Modern vibrant mint emerald
        case .lavender: return Color(red: 0.62, green: 0.44, blue: 0.92) // Rich, refined lavender
        case .sunset: return Color(red: 0.98, green: 0.54, blue: 0.28) // Warm sunrise peach-tangerine
        case .royal: return Color(red: 0.35, green: 0.4, blue: 0.9) // Deep regal purple-indigo
        case .coral: return Color(red: 0.95, green: 0.28, blue: 0.36) // Sleek high-end coral-red
        }
    }
    
    var displayName: String {
        self.rawValue
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("appTheme") private var savedTheme: String = "Oceanic"
    @AppStorage("isDarkMode") private var savedDarkMode: Bool = false
    
    @Published var currentTheme: AppTheme = .oceanic
    @Published var isDarkMode: Bool = false
    
    init() {
        // Load initial values from persistence with graceful legacy mapping
        let raw = savedTheme
        if let theme = AppTheme(rawValue: raw) {
            self.currentTheme = theme
        } else {
            // Graceful migration from old scheme
            switch raw.lowercased() {
            case "blue": self.currentTheme = .oceanic
            case "green": self.currentTheme = .mint
            case "purple": self.currentTheme = .royal
            case "orange": self.currentTheme = .sunset
            case "red": self.currentTheme = .coral
            default: self.currentTheme = .oceanic
            }
            // Update saved theme to new value
            savedTheme = self.currentTheme.rawValue
        }
        self.isDarkMode = savedDarkMode
    }
    
    func setTheme(_ theme: AppTheme) {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentTheme = theme
            savedTheme = theme.rawValue
        }
    }
    
    func toggleDarkMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
            savedDarkMode = isDarkMode
        }
    }
    
    func setDarkMode(_ enabled: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode = enabled
            savedDarkMode = enabled
        }
    }
}
