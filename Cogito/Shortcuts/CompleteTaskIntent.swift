import AppIntents
import SwiftUI

struct CompleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete a Task"
    static var description = IntentDescription("Mark a task as completed in Cogito.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult {
        // In a real implementation, this would find and complete the task
        // For now, we'll post a notification that the app can listen to
        NotificationCenter.default.post(name: NSNotification.Name("CompleteTaskFromSiri"), object: nil)
        
        return .result()
    }
}
