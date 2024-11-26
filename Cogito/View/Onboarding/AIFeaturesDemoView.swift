//
//  AIFeaturesDemoView.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI
// AIFeaturesDemoView.swift
struct AIFeaturesDemoView: View {
    @State private var currentSuggestion = 0
    @State private var isAnimating = false
    @EnvironmentObject var themeManager: ThemeManager
    
    let demoSuggestions = [
        "Break down the task into smaller steps",
        "Set specific milestones and deadlines",
        "Consider dependencies and resources needed"
    ]
    
    var body: some View {
        VStack(spacing: 25) {
            Text("AI-Powered Suggestions")
                .font(.title)
                .bold()
            
            // Animated AI Icon
            Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
            
            // Interactive Suggestion Demo
            VStack(alignment: .leading, spacing: 20) {
                Text("Sample Task: Design Website Homepage")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(demoSuggestions.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(index == currentSuggestion ? .yellow : .gray)
                                .opacity(index == currentSuggestion ? 1 : 0.5)
                            
                            Text(demoSuggestions[index])
                                .font(.body)
                                .opacity(index == currentSuggestion ? 1 : 0.5)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                                .opacity(index == currentSuggestion ? 1 : 0.3)
                        )
                    }
                }
            }
            .padding()
            
            Button(action: {
                withAnimation {
                    currentSuggestion = (currentSuggestion + 1) % demoSuggestions.count
                }
            }) {
                Text("Next Suggestion")
                    .foregroundColor(.white)
                    .frame(width: 150)
                    .padding()
                    .background(themeManager.currentTheme.primaryColor)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
