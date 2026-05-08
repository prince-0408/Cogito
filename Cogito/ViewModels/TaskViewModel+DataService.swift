import Foundation
import Combine

// Extension to connect TaskViewModel with TaskDataService
extension TaskViewModel {
    var taskDataService: TaskDataService? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.taskDataService) as? TaskDataService }
        set { objc_setAssociatedObject(self, &AssociatedKeys.taskDataService, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private struct AssociatedKeys {
        static var taskDataService = "taskDataService"
    }
    
    // Override methods to use TaskDataService
    func addTask(_ task: Task) {
        if let dataService = taskDataService {
            let savedTask = dataService.saveTask(task)
            tasks.append(savedTask)
            generateCalendarData()
            
            // Start Live Activity for the new task
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.startLiveActivity(for: savedTask)
            }
        } else {
            // Fallback to in-memory storage
            tasks.append(task)
            generateCalendarData()
            
            // Start Live Activity for the new task
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.startLiveActivity(for: task)
            }
        }
    }
    
    func updateTask(_ task: Task) {
        if let dataService = taskDataService {
            let updatedTask = dataService.saveTask(task)
            if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                tasks[index] = updatedTask
            }
            generateCalendarData()
        } else {
            // Fallback to in-memory storage
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
                generateCalendarData()
            }
        }
    }
    
    func deleteTask(id: UUID) {
        if let dataService = taskDataService {
            dataService.deleteTask(id: id)
            tasks.removeAll(where: { $0.id == id })
            generateCalendarData()
            
            // End Live Activity for deleted task
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.endLiveActivity(for: id)
            }
        } else {
            // Fallback to in-memory storage
            tasks.removeAll(where: { $0.id == id })
            generateCalendarData()
            
            // End Live Activity for deleted task
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.endLiveActivity(for: id)
            }
        }
    }
    
    func markTaskAsCompleted(_ task: Task) {
        if let dataService = taskDataService {
            var updatedTask = task
            updatedTask.isCompleted = true
            updatedTask.completedDate = Date()
            let savedTask = dataService.saveTask(updatedTask)
            if let index = tasks.firstIndex(where: { $0.id == savedTask.id }) {
                tasks[index] = savedTask
            }
            generateCalendarData()
            
            // Update and then end Live Activity
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.updateLiveActivity(for: savedTask)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    LiveActivityManager.shared.endLiveActivity(for: savedTask.id)
                }
            }
        } else {
            // Fallback to in-memory storage
            var updatedTask = task
            updatedTask.isCompleted = true
            updatedTask.completedDate = Date()
            updateTask(updatedTask)
            
            // Update and then end Live Activity
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.updateLiveActivity(for: updatedTask)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    LiveActivityManager.shared.endLiveActivity(for: updatedTask.id)
                }
            }
        }
    }
    
    func generateCalendarData() {
        if let dataService = taskDataService {
            calendarData = dataService.generateCalendarData()
        } else {
            // Use the original implementation for in-memory storage
            let calendar = Calendar.current
            let currentDate = Date()
            
            // Generate data for current month and next month
            let currentMonth = MonthData.generateEmptyMonth(for: currentDate)
            
            if let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                let nextMonth = MonthData.generateEmptyMonth(for: nextMonthDate)
                calendarData = [currentMonth, nextMonth]
            } else {
                calendarData = [currentMonth]
            }
            
            // Fill in task data
            for i in 0..<calendarData.count {
                for j in 0..<calendarData[i].days.count {
                    let date = calendarData[i].days[j].date
                    let tasksForDay = getTasksForDate(date)
                    let completedTasks = tasksForDay.filter { $0.isCompleted }
                    
                    calendarData[i].days[j].taskCount = tasksForDay.count
                    calendarData[i].days[j].completedCount = completedTasks.count
                }
            }
        }
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        
        // Update data service if available
        if let dataService = taskDataService {
            // Re-save all tasks to maintain order
            for task in tasks {
                _ = dataService.saveTask(task)
            }
        }
    }
}

