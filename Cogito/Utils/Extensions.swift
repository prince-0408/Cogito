import SwiftUI

extension Color {
    static let primaryColor = Color("Primary")
    static let secondaryColor = Color("Secondary")
    static let backgroundColor = Color("Background")
    static let foregroundColor = Color("Foreground")
    static let textPrimaryColor = Color("TextPrimary")
    static let cardBackgroundColor = Color("CardBackground")
    
    static let lowPriorityColor = Color("LowPriority")
    static let mediumPriorityColor = Color("MediumPriority")
    static let highPriorityColor = Color("HighPriority")
    static let urgentPriorityColor = Color("UrgentPriority")
    
    static let lowIntensityColor = Color("LowIntensity")
    static let mediumIntensityColor = Color("MediumIntensity")
    static let highIntensityColor = Color("HighIntensity")
    static let zeroIntensityColor = Color("ZeroIntensity")
}

extension Date {
    func startOfDay() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func endOfDay() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfDay()) ?? self
    }
    
    func isInSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

