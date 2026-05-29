import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject private var themeManager: ThemeManager
    
    let tabs = [
        TabItem(icon: "house.fill", title: "Home"),
        TabItem(icon: "calendar", title: "Heatmap"),
        TabItem(icon: "chart.bar.fill", title: "Insights"),
        TabItem(icon: "gearshape.fill", title: "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Spacer()
                TabButton(
                    item: tabs[index],
                    isSelected: selectedTab == index,
                    accentColor: themeManager.currentTheme.color,
                    isDarkMode: themeManager.isDarkMode,
                    action: {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.78)) {
                            selectedTab = index
                        }
                    }
                )
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                // Ultra Thin Glass Backdrop
                Capsule()
                    .fill(.ultraThinMaterial)
                
                // Colored Hue Underlay
                Capsule()
                    .fill(Color("CardBackground").opacity(0.45))
            }
        )
        // High fidelity border gradient
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            Color.white.opacity(0.15),
                            themeManager.currentTheme.color.opacity(0.02),
                            themeManager.currentTheme.color.opacity(0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        // High depth premium shadow
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 6)
        .shadow(color: themeManager.currentTheme.color.opacity(0.04), radius: 20, x: 0, y: 10)
        .frame(height: 56)
        .padding(.horizontal, 24)
        .background(Color.clear)
    }
}

struct TabItem: Equatable {
    let icon: String
    let title: String
}

struct TabButton: View {
    let item: TabItem
    let isSelected: Bool
    let accentColor: Color
    let isDarkMode: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: item.icon)
                    .font(.satoshi(size: 17, weight: .bold))
                    .foregroundColor(isSelected ? accentColor : Color("TextPrimary").opacity(0.55))
                    .shadow(color: isSelected ? accentColor.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                
                if isSelected {
                    Text(item.title)
                        .font(.satoshi(size: 13, weight: .bold))
                        .foregroundColor(accentColor)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? 
                accentColor.opacity(isDarkMode ? 0.16 : 0.08) : 
                Color.clear
            )
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
        .accessibilityLabel("\(item.title) tab")
        .accessibilityHint(isSelected ? "Currently selected tab" : "Double tap to switch to \(item.title) tab")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
