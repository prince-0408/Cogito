import Foundation
import Combine
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var selectedCategory: TaskCategory?
    @Published var selectedPriority: TaskPriority?
    @Published var searchText: String = ""
    @Published var calendarData: [MonthData] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSampleTasks()
        setupSubscribers()
        generateCalendarData()
    }
    
    private func setupSubscribers() {
        // Combine publishers to filter tasks based on multiple criteria
        Publishers.CombineLatest3($tasks, $selectedCategory, $selectedPriority)
            .combineLatest($searchText)
            .map { combined, searchText in
                let (tasks, category, priority) = combined
                
                return tasks.filter { task in
                    let categoryMatch = category == nil || task.category == category
                    let priorityMatch = priority == nil || task.priority == priority
                    let searchMatch = searchText.isEmpty || 
                        task.title.lowercased().contains(searchText.lowercased()) ||
                        task.description.lowercased().contains(searchText.lowercased())
                    
                    return categoryMatch && priorityMatch && searchMatch
                }
            }
            .assign(to: \.filteredTasks, on: self)
            .store(in: &cancellables)
    }
    
    
    func getTasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { task in
            calendar.isDate(task.dueDate, inSameDayAs: date)
        }
    }
    
    func getCompletedTasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard let completedDate = task.completedDate else { return false }
            return calendar.isDate(completedDate, inSameDayAs: date) && task.isCompleted
        }
    }
    // Sample data for preview
    private func loadSampleTasks() {
        let today = Date()
        let calendar = Calendar.current
        
        let task1 = Task(
            title: "Team Meeting",
            description: "Weekly team sync to discuss project progress",
            category: .work,
            priority: .medium,
            dueDate: calendar.date(byAdding: .hour, value: 3, to: today)!
        )
        
        let task2 = Task(
            title: "Gym Session",
            description: "Cardio and strength training",
            category: .health,
            priority: .low,
            dueDate: calendar.date(byAdding: .day, value: 1, to: today)!
        )
        
        let task3 = Task(
            title: "Pay Rent",
            description: "Transfer monthly rent payment",
            category: .finance,
            priority: .high,
            dueDate: calendar.date(byAdding: .day, value: 2, to: today)!
        )
        
        let task4 = Task(
            title: "Project Deadline",
            description: "Submit final project deliverables",
            category: .work,
            priority: .urgent,
            dueDate: calendar.date(byAdding: .day, value: -1, to: today)!,
            isCompleted: true,
            completedDate: calendar.date(byAdding: .day, value: -1, to: today)!
        )
        
        let task5 = Task(
            title: "Call Parents",
            description: "Weekly family catch-up",
            category: .personal,
            priority: .medium,
            dueDate: calendar.date(byAdding: .day, value: 3, to: today)!
        )
        
        tasks = [task1, task2, task3, task4, task5]
        
        // Add more sample tasks for the calendar
        for i in -15...15 {
            if i % 3 == 0 { continue } // Skip some days for variety
            
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                let isCompleted = Bool.random()
                let task = Task(
                    title: "Sample Task \(i)",
                    description: "This is a sample task",
                    category: TaskCategory.allCases.randomElement()!,
                    priority: TaskPriority.allCases.randomElement()!,
                    dueDate: date,
                    isCompleted: isCompleted,
                    completedDate: isCompleted ? date : nil
                )
                tasks.append(task)
            }
        }
    }
}

