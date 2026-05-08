import AppIntents
import SwiftUI

struct CogitoAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateTaskIntent(),
            phrases: [
                "Create a task in \(.applicationName)",
                "Add a task to \(.applicationName)",
                "New task in \(.applicationName)",
                "\(.applicationName) create task"
            ],
            shortTitle: "Create Task",
            systemImageName: "plus.circle.fill"
        )
        
        AppShortcut(
            intent: CreateTaskIntent(),
            phrases: [
                "Create a work task in \(.applicationName)",
                "Add a work task to \(.applicationName)"
            ],
            shortTitle: "Create Work Task",
            systemImageName: "briefcase.fill"
        )
        
        AppShortcut(
            intent: CreateTaskIntent(),
            phrases: [
                "Create a high priority task in \(.applicationName)",
                "Add an important task to \(.applicationName)"
            ],
            shortTitle: "Create Urgent Task",
            systemImageName: "exclamationmark.circle.fill"
        )
        
        AppShortcut(
            intent: CompleteTaskIntent(),
            phrases: [
                "Complete a task in \(.applicationName)",
                "Mark task done in \(.applicationName)",
                "\(.applicationName) complete task"
            ],
            shortTitle: "Complete Task",
            systemImageName: "checkmark.circle.fill"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor {
        .blue
    }
}
