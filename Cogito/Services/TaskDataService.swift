import Foundation
import Combine
import CoreData

class TaskDataService {
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.context = persistenceController.container.viewContext
    }
    
    // MARK: - CRUD Operations
    
    func fetchAllTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "TaskEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        
        do {
            let taskEntities = try context.fetch(fetchRequest)
            return taskEntities.map { entityToTask($0) }
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func fetchTasks(for date: Date) -> [Task] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "TaskEntity")
        fetchRequest.predicate = NSPredicate(format: "dueDate >= %@ AND dueDate < %@", startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        
        do {
            let taskEntities = try context.fetch(fetchRequest)
            return taskEntities.map { entityToTask($0) }
        } catch {
            print("Error fetching tasks for date: \(error)")
            return []
        }
    }
    
    func fetchCompletedTasks(for date: Date) -> [Task] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "TaskEntity")
        fetchRequest.predicate = NSPredicate(format: "isCompleted == YES AND completedDate >= %@ AND completedDate < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let taskEntities = try context.fetch(fetchRequest)
            return taskEntities.map { entityToTask($0) }
        } catch {
            print("Error fetching completed tasks for date: \(error)")
            return []
        }
    }
    
    func saveTask(_ task: Task) -> Task {
        // Check if task already exists
        if let existingEntity = fetchTaskEntity(with: task.id) {
            updateEntity(existingEntity, from: task)
            print("Updated existing task: \(task.title)")
        } else {
            createEntity(from: task)
            print("Created new task: \(task.title)")
        }
        
        persistenceController.save()
        
        // Schedule reminder if needed
        if let reminderTime = task.reminderTime {
            NotificationManager.shared.scheduleTaskReminder(for: task)
        }
        
        return task
    }
    
    func deleteTask(id: UUID) {
        if let taskEntity = fetchTaskEntity(with: id) {
            // Cancel any pending notifications
            NotificationManager.shared.cancelTaskReminder(for: id)
            
            // Delete from CoreData
            context.delete(taskEntity)
            persistenceController.save()
            print("Deleted task with ID: \(id)")
        }
    }
    
    func markTaskAsCompleted(_ task: Task) -> Task {
        var updatedTask = task
        updatedTask.isCompleted = true
        updatedTask.completedDate = Date()
        
        // Cancel any pending notifications
        NotificationManager.shared.cancelTaskReminder(for: task.id)
        
        return saveTask(updatedTask)
    }
    
    func deleteAllTasks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TaskEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            persistenceController.save()
            
            // Cancel all notifications
            NotificationManager.shared.cancelAllTaskReminders()
            print("All tasks deleted successfully")
        } catch {
            print("Error deleting all tasks: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func fetchTaskEntity(with id: UUID) -> NSManagedObject? {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "TaskEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching task entity: \(error)")
            return nil
        }
    }
    
    private func createEntity(from task: Task) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "TaskEntity", into: context)
        updateEntity(entity, from: task)
    }
    
    private func updateEntity(_ entity: NSManagedObject, from task: Task) {
        entity.setValue(task.id, forKey: "id")
        entity.setValue(task.title, forKey: "title")
        entity.setValue(task.description, forKey: "taskDescription")
        entity.setValue(task.category.rawValue, forKey: "categoryRaw")
        entity.setValue(task.priority.rawValue, forKey: "priorityRaw")
        entity.setValue(task.dueDate, forKey: "dueDate")
        entity.setValue(task.isCompleted, forKey: "isCompleted")
        entity.setValue(task.completedDate, forKey: "completedDate")
        entity.setValue(task.createdAt, forKey: "createdAt")
        entity.setValue(task.reminderTime, forKey: "reminderTime")
        entity.setValue(task.tags.joined(separator: ","), forKey: "tagsRaw")
    }
    
    private func entityToTask(_ entity: NSManagedObject) -> Task {
        let categoryRaw = entity.value(forKey: "categoryRaw") as? String ?? "other"
        let priorityRaw = entity.value(forKey: "priorityRaw") as? String ?? "medium"
        let tagsRaw = entity.value(forKey: "tagsRaw") as? String ?? ""
        
        return Task(
            id: entity.value(forKey: "id") as? UUID ?? UUID(),
            title: entity.value(forKey: "title") as? String ?? "",
            description: entity.value(forKey: "taskDescription") as? String ?? "",
            category: TaskCategory(rawValue: categoryRaw) ?? .other,
            priority: TaskPriority(rawValue: priorityRaw) ?? .medium,
            dueDate: entity.value(forKey: "dueDate") as? Date ?? Date(),
            isCompleted: entity.value(forKey: "isCompleted") as? Bool ?? false,
            completedDate: entity.value(forKey: "completedDate") as? Date,
            createdAt: entity.value(forKey: "createdAt") as? Date ?? Date(),
            reminderTime: entity.value(forKey: "reminderTime") as? Date,
            tags: tagsRaw.components(separatedBy: ",").filter { !$0.isEmpty }
        )
    }
    
    // MARK: - Calendar Data Generation
    
    func generateCalendarData() -> [MonthData] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Generate data for current month and next month
        var monthsData: [MonthData] = []
        
        for monthOffset in 0...1 {
            if let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: currentDate) {
                var monthData = MonthData.generateEmptyMonth(for: monthDate)
                
                // Fill in task data for each day
                for i in 0..<monthData.days.count {
                    let date = monthData.days[i].date
                    let tasksForDay = fetchTasks(for: date)
                    let completedTasks = tasksForDay.filter { $0.isCompleted }
                    
                    monthData.days[i].taskCount = tasksForDay.count
                    monthData.days[i].completedCount = completedTasks.count
                }
                
                monthsData.append(monthData)
            }
        }
        
        return monthsData
    }
}

