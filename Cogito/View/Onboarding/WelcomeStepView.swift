//
//  WelcomeStepView.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI

// WelcomeStepView.swift
struct WelcomeStepView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 25) {
            LottieView(name: "welcome-animation")
                .frame(width: 250, height: 250)
            
            Text("Welcome to AI Task Manager")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "brain.head.profile",
                    title: "AI-Powered",
                    description: "Get smart suggestions for your tasks"
                )
                
                FeatureRow(
                    icon: "bell.badge",
                    title: "Smart Notifications",
                    description: "Never miss important deadlines"
                )
                
                FeatureRow(
                    icon: "paintpalette",
                    title: "Customizable Themes",
                    description: "Personalize your experience"
                )
            }
            .padding()
            
            Text("Swipe to learn more")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top)
        }
        .padding()
    }
}
