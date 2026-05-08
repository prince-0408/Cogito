import ActivityKit
import Foundation
import SwiftUI

typealias AppTask = Task

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private init() {}
    
    func startLiveActivity(for task: AppTask) {
        // Check if Live Activities are available
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        // Check if there's already an activity for this task
        let existingActivities = Activity<TaskActivityAttributes>.activities
        for activity in existingActivities {
            if activity.attributes.taskId == task.id.uuidString {
                // Update existing activity instead of creating a new one
                updateLiveActivity(for: task)
                return
            }
        }
        
        let attributes = TaskActivityAttributes(
            taskId: task.id.uuidString,
            taskTitle: task.title,
            taskCategory: task.category.rawValue,
            dueDate: task.dueDate
        )
        
        let initialState = TaskActivityAttributes.ContentState(
            taskTitle: task.title,
            taskCategory: task.category.rawValue,
            dueDate: task.dueDate,
            isCompleted: task.isCompleted,
            timeRemaining: task.dueDate.timeIntervalSinceNow
        )
        
        do {
            let activity = try Activity<TaskActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            print("Live Activity started: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateLiveActivity(for task: AppTask) {
        Swift.Task {
            for activity in Activity<TaskActivityAttributes>.activities {
                if activity.attributes.taskId == task.id.uuidString {
                    let updatedState = TaskActivityAttributes.ContentState(
                        taskTitle: task.title,
                        taskCategory: task.category.rawValue,
                        dueDate: task.dueDate,
                        isCompleted: task.isCompleted,
                        timeRemaining: task.dueDate.timeIntervalSinceNow
                    )
                    
                    await activity.update(ActivityContent(state: updatedState, staleDate: nil))
                    print("Live Activity updated: \(activity.id)")
                }
            }
        }
    }
    
    func endLiveActivity(for taskId: UUID, dismissalPolicy: ActivityUIDismissalPolicy = .default) {
        Swift.Task {
            for activity in Activity<TaskActivityAttributes>.activities {
                if activity.attributes.taskId == taskId.uuidString {
                    await activity.end(using: nil, dismissalPolicy: dismissalPolicy)
                    print("Live Activity ended: \(activity.id)")
                }
            }
        }
    }
    
    func endAllLiveActivities() {
        Swift.Task {
            for activity in Activity<TaskActivityAttributes>.activities {
                await activity.end(using: nil, dismissalPolicy: .default)
            }
        }
    }
    
    func getActiveLiveActivities() -> [Activity<TaskActivityAttributes>] {
        return Activity<TaskActivityAttributes>.activities
    }
}
