//
//  AIPreferencesView.swift
//  Cogito
//
//  Created by Prince Yadav on 12/03/25.
//


import SwiftUI

struct AIPreferencesView: View {
    @EnvironmentObject private var aiViewModel: AIViewModel
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "brain")
                            .font(.system(size: 40))
                            .foregroundColor(Color("Primary"))
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color("Primary").opacity(0.2))
                            )
                        
                        Text("AI Preferences")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Foreground"))
                        
                        Text("Configure how Mistral AI works with your tasks")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("TextPrimary"))
                            .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    
                    // AI Features
                    VStack(alignment: .leading, spacing: 15) {
                        Text("AI Features")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Toggle("Enable AI Suggestions", isOn: Binding(
                            get: { aiViewModel.isEnabled },
                            set: { aiViewModel.toggleAI(enabled: $0) }
                        ))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackground"))
                        )
                        
                        if !aiViewModel.isEnabled {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text("AI features are currently disabled")
                                    .font(.caption)
                                    .foregroundColor(Color("TextPrimary"))
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // About Mistral AI
                    VStack(alignment: .leading, spacing: 15) {
                        Text("About Mistral AI")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Mistral AI Integration")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("Foreground"))
                            
                            Text("Cogito uses Mistral AI to provide intelligent task suggestions, insights, and natural language processing. Your data is processed securely and is not stored by Mistral AI.")
                                .font(.caption)
                                .foregroundColor(Color("TextPrimary").opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Link(destination: URL(string: "https://mistral.ai")!) {
                                HStack {
                                    Text("Learn more about Mistral AI")
                                        .font(.caption)
                                        .foregroundColor(Color("Primary"))
                                    
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.caption)
                                        .foregroundColor(Color("Primary"))
                                }
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackground"))
                        )
                    }
                    .padding(.horizontal)
                    
                    // AI Features Explanation
                    VStack(alignment: .leading, spacing: 15) {
                        Text("AI Features Explained")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        FeatureExplanationCard(
                            title: "Smart Task Suggestions",
                            description: "Get personalized task suggestions based on your existing tasks and patterns",
                            icon: "lightbulb.fill",
                            color: .yellow
                        )
                        
                        FeatureExplanationCard(
                            title: "Natural Language Input",
                            description: "Create tasks using natural language like \"Meeting with John tomorrow at 2pm\"",
                            icon: "text.bubble.fill",
                            color: .blue
                        )
                        
                        FeatureExplanationCard(
                            title: "Productivity Insights",
                            description: "Receive AI-powered insights about your productivity patterns and habits",
                            icon: "chart.bar.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("AI Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureExplanationCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("Foreground"))
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color("TextPrimary").opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
        )
    }
}

