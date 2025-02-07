//
//  OnboardingViewModel.swift
//  Cogito
//
//  Created by Prince Yadav on 08/12/24.
//
import SwiftUI
import Combine

// MARK: - ViewModel
class OnboardingViewModel: ObservableObject {
    @Published private(set) var pages: [OnboardingPageModel]
    @Published var currentPage: Int = 0
    @Published var isOnboardingComplete: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.pages = [
            OnboardingPageModel(
                title: "Welcome to Cogito",
                subtitle: "AI-Powered Task Management",
                description: "Revolutionize your productivity with intelligent task management",
                iconName: "brain.head.profile",
                backgroundColor: .blue.opacity(0.6)
            ),
            OnboardingPageModel(
                title: "Smart AI Suggestions",
                subtitle: "Intelligent Task Planning",
                description: "Get dynamic, context-aware recommendations for task optimization",
                iconName: "lightbulb.fill",
                backgroundColor: .purple.opacity(0.6)
            ),
            OnboardingPageModel(
                title: "Personalized Workflows",
                subtitle: "Adaptive Task Management",
                description: "Create custom workflows that learn and adapt to your work style",
                iconName: "chart.bar.doc.horizontal.fill",
                backgroundColor: .green.opacity(0.6)
            ),
            OnboardingPageModel(
                title: "Get Started",
                subtitle: "Your Productivity Companion",
                description: "Transform the way you manage tasks with Cogito's intelligent system",
                iconName: "rocket.fill",
                backgroundColor: .orange.opacity(0.6)
            )
        ]
    }
    
    func moveToNextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            completeOnboarding()
        }
    }
    
    func moveToPreviousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    private func completeOnboarding() {
        // Persist onboarding completion
        UserDefaults.standard.set(true, forKey: "OnboardingComplete")
        isOnboardingComplete = true
    }
    
    var isFirstPage: Bool {
        currentPage == 0
    }
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
}
