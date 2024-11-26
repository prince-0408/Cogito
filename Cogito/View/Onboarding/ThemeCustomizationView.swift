//
//  ThemeCustomizationView.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//
import SwiftUI

struct ThemeCustomizationView: View {
    @State private var selectedTheme = ThemeManager.AppTheme.default
    @State private var showingPreview = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Personalize Your Experience")
                .font(.title)
                .bold()
            
            // Theme Preview
            VStack(spacing: 15) {
                Text("Choose Your Theme")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(ThemeManager.AppTheme.allCases, id: \.self) { theme in
                            ThemePreviewCard(theme: theme, isSelected: selectedTheme == theme)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTheme = theme
                                        showingPreview = true
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
            
            if showingPreview {
                // Live Preview
                VStack(spacing: 15) {
                    Text("Preview")
                        .font(.headline)
                    
                    // Sample Task List Preview
                    VStack {
                        SampleTaskRow(
                            title: "Important Meeting",
                            priority: .high,
                            theme: selectedTheme
                        )
                        
                        SampleTaskRow(
                            title: "Project Review",
                            priority: .medium,
                            theme: selectedTheme
                        )
                    }
                    .padding()
                    .background(selectedTheme.backgroundColor)
                    .cornerRadius(15)
                }
                .padding()
                .transition(.scale)
            }
            
            Button(action: {
                themeManager.currentTheme = selectedTheme
            }) {
                Text("Apply Theme")
                    .foregroundColor(.white)
                    .frame(width: 150)
                    .padding()
                    .background(selectedTheme.primaryColor)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// Supporting Views
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ThemePreviewCard: View {
    let theme: ThemeManager.AppTheme
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Circle()
                .fill(theme.primaryColor)
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )
            
            Text(theme.rawValue)
                .font(.caption)
        }
        .padding()
        .background(theme.backgroundColor)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(theme.primaryColor, lineWidth: isSelected ? 2 : 0)
        )
    }
}

struct SampleTaskRow: View {
    let title: String
    let priority: Task.Priority
    let theme: ThemeManager.AppTheme
    
    var body: some View {
        HStack {
            Circle()
                .stroke(theme.primaryColor, lineWidth: 2)
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
//            PriorityBadge(priority: priority)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
