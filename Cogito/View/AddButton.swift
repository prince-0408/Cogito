//
//  AddButton.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//
import SwiftUI

struct AddButton: View {
    let tab: TabBarItem
    @Binding var selectedTab: Tab
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab.tab
            }
        } label: {
            ZStack {
                Circle()
//                    .fill(themeManager.currentTheme.primaryColor)
                    .frame(width: 50, height: 50)
//                    .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3),
//                radius;: 8, x: 0, y: 4)
                
                Image(systemName: tab.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .offset(y: -20)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: { isPressed = true },
                    onRelease: { isPressed = false })
    }
}
