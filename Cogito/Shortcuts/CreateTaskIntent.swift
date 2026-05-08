import AppIntents
import SwiftUI

struct CreateTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Create a New Task"
    static var description = IntentDescription("Create a new task in Cogito with a title, category, and priority.")
    
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Task Title", description: "The title of the task")
    var taskTitle: String
    
    @Parameter(title: "Task Description", default: "")
    var taskDescription: String
    
    @Parameter(title: "Category", default: .other)
    var category: TaskCategoryAppEnum
    
    @Parameter(title: "Priority", default: .medium)
    var priority: TaskPriorityAppEnum
    
    @Parameter(title: "Due Date", default: nil)
    var dueDate: Date?
    
    func perform() async throws -> some IntentResult & ReturnsValue<CreatedTaskValue> {
        // Create the task
        let task = Task(
            title: taskTitle,
            description: taskDescription,
            category: category.toTaskCategory(),
            priority: priority.toTaskPriority(),
            dueDate: dueDate ?? Date()
        )
        
        // Save the task (this would normally use TaskViewModel)
        // For now, we'll use UserDefaults to persist across app launches
        if let encoded = try? JSONEncoder().encode(task),
           let sharedDefaults = UserDefaults(suiteName: "group.com.yourbundle.Cogito") {
            sharedDefaults.set(encoded, forKey: "siri_created_task_\(task.id)")
        }
        
        // Post notification to update UI
        NotificationCenter.default.post(name: NSNotification.Name("TaskCreatedFromSiri"), object: task)
        
        return .result(value: CreatedTaskValue(task: task))
    }
}

struct CreatedTaskValue: AppEntity {
    var task: Task
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation("Task")
    static var defaultQuery = CreatedTaskValueQuery()
    
    var id: String {
        task.id.uuidString
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(task.title)")
    }
}

struct CreatedTaskValueQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CreatedTaskValue] {
        // Fetch tasks from storage
        return []
    }
    
    func suggestedEntities() async throws -> [CreatedTaskValue] {
        return []
    }
}

enum TaskCategoryAppEnum: String, AppEnum {
    case work
    case personal
    case health
    case finance
    case education
    case other
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Category")
    static var caseDisplayRepresentations: [TaskCategoryAppEnum: DisplayRepresentation] = [
        .work: "Work",
        .personal: "Personal",
        .health: "Health",
        .finance: "Finance",
        .education: "Education",
        .other: "Other"
    ]
    
    func toTaskCategory() -> TaskCategory {
        switch self {
        case .work: return .work
        case .personal: return .personal
        case .health: return .health
        case .finance: return .finance
        case .education: return .education
        case .other: return .other
        }
    }
}

enum TaskPriorityAppEnum: String, AppEnum {
    case low
    case medium
    case high
    case urgent
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Priority")
    static var caseDisplayRepresentations: [TaskPriorityAppEnum: DisplayRepresentation] = [
        .low: "Low",
        .medium: "Medium",
        .high: "High",
        .urgent: "Urgent"
    ]
    
    func toTaskPriority() -> TaskPriority {
        switch self {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        case .urgent: return .urgent
        }
    }
}
