//
//  ThemeSelectionView.swift
//  Cogito
//
//  Created by Prince Yadav on 10/03/25.
//
import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 15) {
            ForEach(AppTheme.allCases) { theme in
                ThemeButton(
                    title: theme.displayName,
                    color: theme.color,
                    isSelected: themeManager.currentTheme == theme,
                    action: {
                        themeManager.setTheme(theme)
                    }
                )
            }
            
            Toggle(isOn: Binding(
                get: { themeManager.isDarkMode },
                set: { themeManager.setDarkMode($0) }
            )) {
                Label("Dark Mode", systemImage: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.satoshi(.body, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.1))
            )
            .toggleStyle(SwitchToggleStyle(tint: themeManager.currentTheme.color))
        }
        .padding(.horizontal, 40)
    }
}

struct ThemeButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.satoshi(.headline, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isSelected ? 0.25 : 0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
