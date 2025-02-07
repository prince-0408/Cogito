//
//  AIProductivitySuggestionView.swift
//  Cogito
//
//  Created by Prince Yadav on 12/12/24.
//
import SwiftUI

struct AIProductivitySuggestionView: View {
    @State private var suggestion: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("AI Productivity Tip")
                .font(.headline)
            
            Text(suggestion)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            generateProductivityTip()
        }
    }
    
    private func generateProductivityTip() {
        // Implement AI-driven productivity suggestion logic
        suggestion = "Try the Pomodoro technique to improve focus and productivity."
    }
}
