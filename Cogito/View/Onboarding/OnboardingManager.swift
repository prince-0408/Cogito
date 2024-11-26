//
//  OnboardingManager.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//


import SwiftUI

// OnboardingManager.swift
class OnboardingManager: ObservableObject {
    @Published var currentStep = 0
    @Published var showTutorialOverlay = false
    @Published var completedSteps: Set<Int> = []
    
    let totalSteps = 4
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            completedSteps.insert(currentStep)
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
}