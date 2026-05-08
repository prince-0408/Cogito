import WidgetKit
import SwiftUI

// Simplified task model for widget use
struct WidgetTask: Identifiable, Codable {
    let id: String
    let title: String
    let category: String
    let priority: String
    let dueDate: Date
    let isCompleted: Bool
}

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
    let completedCount: Int
    let totalCount: Int
}

struct TaskProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(
            date: Date(),
            tasks: [],
            completedCount: 0,
            totalCount: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry(
            date: Date(),
            tasks: [],
            completedCount: 0,
            totalCount: 0
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        // In a real app, this would fetch from UserDefaults with App Groups
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Create sample tasks for placeholder
        let sampleTasks = [
            WidgetTask(
                id: UUID().uuidString,
                title: "Team Meeting",
                category: "Work",
                priority: "High",
                dueDate: calendar.date(byAdding: .hour, value: 2, to: currentDate)!,
                isCompleted: false
            ),
            WidgetTask(
                id: UUID().uuidString,
                title: "Review PRs",
                category: "Work",
                priority: "Medium",
                dueDate: calendar.date(byAdding: .hour, value: 4, to: currentDate)!,
                isCompleted: false
            ),
            WidgetTask(
                id: UUID().uuidString,
                title: "Gym",
                category: "Health",
                priority: "Low",
                dueDate: calendar.date(byAdding: .hour, value: 6, to: currentDate)!,
                isCompleted: false
            )
        ]
        
        let entry = TaskEntry(
            date: currentDate,
            tasks: sampleTasks,
            completedCount: 0,
            totalCount: sampleTasks.count
        )
        
        // Update every hour
        let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
