import SwiftUI
import Combine

enum CoachmarkArrowDirection {
    case up
    case down
    case left
    case right
    case none
}

struct TutorialStep: Identifiable, Equatable {
    let id: String // Matches Spotlight identifier
    let title: String
    let description: String
    let arrowDirection: CoachmarkArrowDirection
}

class TutorialManager: ObservableObject {
    @AppStorage("hasCompletedTutorial") var hasCompletedTutorial: Bool = false
    @Published var isTutorialActive: Bool = false
    @Published var currentStepIndex: Int = 0
    
    let steps: [TutorialStep] = [
        TutorialStep(
            id: "create_button",
            title: "Quick Creation",
            description: "Tap the '+' button to schedule a new task. You can enter details manually or use our powerful AI natural language prompt tool!",
            arrowDirection: .up
        ),
        TutorialStep(
            id: "ai_suggestions",
            title: "AI Smart Suggestions",
            description: "Based on your workflow habits, Cogito suggests smart recommendations here. Tap 'Add' to instantly add it to your schedule!",
            arrowDirection: .up
        ),
        TutorialStep(
            id: "category_filters",
            title: "Smart Filters",
            description: "Tap any category capsule to immediately organize your view and filter tasks by Work, Personal, Health, or Education.",
            arrowDirection: .up
        ),
        TutorialStep(
            id: "task_list",
            title: "Manage Tasks",
            description: "Check the circle to complete tasks instantly. Tap the card body to view details and edit, or enter Edit Mode to delete tasks.",
            arrowDirection: .down
        )
    ]
    
    var currentStep: TutorialStep? {
        guard steps.indices.contains(currentStepIndex) else { return nil }
        return steps[currentStepIndex]
    }
    
    init() {
        // Automatically activate tutorial on first cold launch after onboarding
        if !hasCompletedTutorial {
            // Give the app home screen a tiny layout fraction to settle before launching overlay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startTutorial()
            }
        }
    }
    
    func startTutorial() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            currentStepIndex = 0
            isTutorialActive = true
        }
        
        // Success haptic pop
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func nextStep() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if currentStepIndex < steps.count - 1 {
                currentStepIndex += 1
            } else {
                finishTutorial()
            }
        }
    }
    
    func previousStep() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if currentStepIndex > 0 {
                currentStepIndex -= 1
            }
        }
    }
    
    func finishTutorial() {
        withAnimation(.easeOut(duration: 0.3)) {
            isTutorialActive = false
            hasCompletedTutorial = true
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func skipTutorial() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.easeOut(duration: 0.3)) {
            isTutorialActive = false
            hasCompletedTutorial = true
        }
    }
}
