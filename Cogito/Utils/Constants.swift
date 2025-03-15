import SwiftUI

struct Constants {
    // App Information
    static let appName = "Cogito"
    static let appVersion = "1.0.0"
    static let appDescription = "AI-Powered Task Manager & Scheduler"
    
    // UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let iconSize: CGFloat = 24
        static let spacing: CGFloat = 15
        static let padding: CGFloat = 16
        static let animationDuration: Double = 0.3
    }
    
    // AI Constants
    struct AI {
        static let confidenceThreshold: Double = 0.65
        static let suggestionCount: Int = 3
        static let processingDelay: Double = 1.5
    }
    
    // Notification Constants
    struct Notifications {
        static let defaultReminderTime: Int = 30 // minutes before due date
        static let categoryIdentifier = "TASK_REMINDER"
        static let actionIdentifier = "VIEW_TASK"
    }
    
    // Storage Keys
    struct StorageKeys {
        static let isDarkMode = "isDarkMode"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let aiEnabled = "aiEnabled"
        static let lastSyncDate = "lastSyncDate"
    }
    
    // Error Messages
    struct ErrorMessages {
        static let taskCreationFailed = "Failed to create task. Please try again."
        static let taskUpdateFailed = "Failed to update task. Please try again."
        static let taskDeletionFailed = "Failed to delete task. Please try again."
        static let aiProcessingFailed = "AI processing failed. Please try again."
        static let dataLoadFailed = "Failed to load data. Please restart the app."
    }
}

