//
//  ThemeSettingsView.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        List {
            ForEach(ThemeManager.AppTheme.allCases, id: \.self) { theme in
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.primaryColor)
                        .frame(width: 30, height: 30)
                    
                    Text(theme.rawValue)
                        .padding(.leading)
                    
                    Spacer()
                    
                    if themeManager.currentTheme == theme {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    themeManager.currentTheme = theme
                }
            }
        }
        .navigationTitle("Theme Settings")
    }
}
