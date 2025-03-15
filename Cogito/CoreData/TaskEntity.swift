import Foundation
import CoreData

class TaskEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String
    @NSManaged public var categoryRaw: String
    @NSManaged public var priorityRaw: String
    @NSManaged public var dueDate: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completedDate: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var reminderTime: Date?
    @NSManaged public var tagsRaw: String
    
    var category: TaskCategory {
        get {
            return TaskCategory(rawValue: categoryRaw) ?? .other
        }
        set {
            categoryRaw = newValue.rawValue
        }
    }
    
    var priority: TaskPriority {
        get {
            return TaskPriority(rawValue: priorityRaw) ?? .medium
        }
        set {
            priorityRaw = newValue.rawValue
        }
    }
    
    var tags: [String] {
        get {
            return tagsRaw.components(separatedBy: ",").filter { !$0.isEmpty }
        }
        set {
            tagsRaw = newValue.joined(separator: ",")
        }
    }
    
    // Convert to Task model
    func toTask() -> Task {
        return Task(
            id: id,
            title: title,
            description: taskDescription,
            category: category,
            priority: priority,
            dueDate: dueDate,
            isCompleted: isCompleted,
            completedDate: completedDate,
            createdAt: createdAt,
            reminderTime: reminderTime,
            tags: tags
        )
    }
    
    // Update from Task model
    func update(from task: Task) {
        self.id = task.id
        self.title = task.title
        self.taskDescription = task.description
        self.category = task.category
        self.priority = task.priority
        self.dueDate = task.dueDate
        self.isCompleted = task.isCompleted
        self.completedDate = task.completedDate
        self.createdAt = task.createdAt
        self.reminderTime = task.reminderTime
        self.tags = task.tags
    }
}

extension TaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
    
    // Create a new TaskEntity from a Task model
    static func create(from task: Task, in context: NSManagedObjectContext) -> TaskEntity {
        let entity = TaskEntity(context: context)
        entity.update(from: task)
        return entity
    }
}

