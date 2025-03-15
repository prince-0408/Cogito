import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Request notification permissions
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification authorization granted")
                } else if let error = error {
                    print("Notification authorization denied: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    // Check notification authorization status
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // Schedule a task reminder
    func scheduleTaskReminder(for task: Task) {
        guard let reminderTime = task.reminderTime else { return }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder: \(task.title)"
        content.body = "Due: \(task.formattedDueDate)"
        content.sound = .default
        content.categoryIdentifier = Constants.Notifications.categoryIdentifier
        content.userInfo = ["taskId": task.id.uuidString]
        
        // Create trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "task-reminder-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification for task: \(task.title)")
            }
        }
    }
    
    // Cancel a task reminder
    func cancelTaskReminder(for taskId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["task-reminder-\(taskId.uuidString)"])
    }
    
    // Cancel all task reminders
    func cancelAllTaskReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Setup notification actions
    func setupNotificationActions() {
        // Define actions
        let viewAction = UNNotificationAction(
            identifier: Constants.Notifications.actionIdentifier,
            title: "View Task",
            options: .foreground
        )
        
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Mark as Complete",
            options: .authenticationRequired
        )
        
        // Define category
        let category = UNNotificationCategory(
            identifier: Constants.Notifications.categoryIdentifier,
            actions: [viewAction, completeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Register category
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

