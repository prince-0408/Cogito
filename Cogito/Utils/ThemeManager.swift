import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case blue
    case green
    case purple
    case orange
    case red
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .orange: return .orange
        case .red: return .red
        }
    }
    
    var displayName: String {
        self.rawValue.capitalized
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("appTheme") private var savedTheme: String = "blue"
    @AppStorage("isDarkMode") private var savedDarkMode: Bool = false
    
    @Published var currentTheme: AppTheme = .blue
    @Published var isDarkMode: Bool = false
    
    init() {
        // Load initial values from persistence
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .blue
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
