import Foundation
import SwiftUI

enum TaskPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: Color {
        switch self {
        case .low:
            return Color("LowPriority")
        case .medium:
            return Color("MediumPriority")
        case .high:
            return Color("HighPriority")
        case .urgent:
            return Color("UrgentPriority")
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case finance = "Finance"
    case education = "Education"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .work:
            return "briefcase.fill"
        case .personal:
            return "person.fill"
        case .health:
            return "heart.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .education:
            return "book.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .work:
            return Color.blue
        case .personal:
            return Color.purple
        case .health:
            return Color.green
        case .finance:
            return Color.yellow
        case .education:
            return Color.orange
        case .other:
            return Color.gray
        }
    }
}

struct Task: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String = ""
    var category: TaskCategory
    var priority: TaskPriority
    var dueDate: Date
    var isCompleted: Bool = false
    var completedDate: Date?
    var createdAt: Date = Date()
    var reminderTime: Date?
    var tags: [String] = []
    
    var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
    
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
}

