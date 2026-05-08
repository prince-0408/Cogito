import ActivityKit
import SwiftUI
import WidgetKit

struct TaskActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var taskTitle: String
        var taskCategory: String
        var dueDate: Date
        var isCompleted: Bool
        var timeRemaining: TimeInterval
    }
    
    var taskId: String
    var taskTitle: String
    var taskCategory: String
    var dueDate: Date
}
