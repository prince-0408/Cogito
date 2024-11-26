//
//  InteractiveOnboardingView.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI
// InteractiveOnboardingView.swift
struct InteractiveOnboardingView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            TabView(selection: $onboardingManager.currentStep) {
                WelcomeStepView()
                    .tag(0)
                
                TaskCreationTutorialView()
                    .tag(1)
                
                AIFeaturesDemoView()
                    .tag(2)
                
                ThemeCustomizationView()
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                
                HStack {
                    if onboardingManager.currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                onboardingManager.previousStep()
                            }
                        }) {
                            Text("Previous")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if onboardingManager.currentStep == onboardingManager.totalSteps - 1 {
                            hasCompletedOnboarding = true
                        } else {
                            withAnimation {
                                onboardingManager.nextStep()
                            }
                        }
                    }) {
                        Text(onboardingManager.currentStep == onboardingManager.totalSteps - 1 ? "Get Started" : "Next")
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding()
                            .background(themeManager.currentTheme.primaryColor)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}
