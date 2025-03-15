//
//  ThemeSelectionView.swift
//  Cogito
//
//  Created by Prince Yadav on 10/03/25.
//
import SwiftUI

struct ThemeSelectionView: View {
    @Binding var appTheme: String
    @Binding var isDarkMode: Bool

    let themes = [
        ("Blue", Color.blue),
        ("Green", Color.green),
        ("Purple", Color.purple),
        ("Orange", Color.orange),
        ("Red", Color.red)
    ]

    var body: some View {
        VStack(spacing: 15) {
            ForEach(themes, id: \.0) { theme in
                ThemeButton(
                    title: theme.0,
                    color: theme.1,
                    isSelected: appTheme == theme.0.lowercased(),
                    action: { appTheme = theme.0.lowercased() }
                )
            }
            
            Toggle(isOn: $isDarkMode) {
                Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.1))
            )
            .toggleStyle(SwitchToggleStyle(tint: .orange))
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
                    .font(.headline)
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
                    .fill(color.opacity(0.2))
            )
        }
    }
}
