//
//  TaskViewModel.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//


import Foundation
import CoreData

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDynamicIsland = false
    @Published var dynamicIslandTask: Task?
    @Published var filter = TaskFilter()
    @Published var selectedTask: Task?
    
    private let openAIKey = "YOUR_OPENAI_KEY"
    
    func generateTask(from prompt: String) async {
        isLoading = true
        
        _ = [
            ["role": "system", "content": "You are a helpful task planning assistant. Create a structured task based on the user's input."],
            ["role": "user", "content": prompt]
        ]
        
        // Add OpenAI API call implementation here
        // This is a placeholder for the actual API implementation
        do {
            // Simulated API response
            let newTask = Task(
                title: "AI Generated Task",
                description: "Description based on prompt: \(prompt)",
                isCompleted: false,
                dueDate: Date().addingTimeInterval(86400),
                priority: .medium,
                aiGenerated: true,
                categories: ["AI Generated"],
                createdAt: Date()
            )
            
            DispatchQueue.main.async {
                self.tasks.append(newTask)
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            // Add persistence logic here
        }
    }
}


extension TaskViewModel {
    func updateTask(_ task: Task, newTitle: String, newDescription: String,
                    newDueDate: Date, newPriority: Task.Priority,
                   newCategories: [String]) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTitle
            tasks[index].description = newDescription
            tasks[index].dueDate = newDueDate
            tasks[index].priority = newPriority
            tasks[index].categories = newCategories
            // Add persistence logic here
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        // Add persistence logic here
    }
    
    func getAllCategories() -> [String] {
        Array(Set(tasks.flatMap { $0.categories })).sorted()
    }
}

extension TaskViewModel {
    func completionRate(for timeFrame: DashboardView.TimeFrame) -> Double {
        let filteredTasks = filterTasks(for: timeFrame)
        guard !filteredTasks.isEmpty else { return 0 }
        let completedTasks = filteredTasks.filter { $0.isCompleted }
        return Double(completedTasks.count) / Double(filteredTasks.count) * 100
    }
    
    func tasksCreated(for timeFrame: DashboardView.TimeFrame) -> Int {
        filterTasks(for: timeFrame).count
    }
    
    func aiGeneratedTasks(for timeFrame: DashboardView.TimeFrame) -> Int {
        filterTasks(for: timeFrame).filter { $0.aiGenerated }.count
    }
    
    func overdueTasks() -> Int {
        tasks.filter { !$0.isCompleted && $0.dueDate < Date() }.count
    }
    
    private func filterTasks(for timeFrame: DashboardView.TimeFrame) -> [Task] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch timeFrame {
        case .day:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        }
        
        return tasks.filter { $0.createdAt >= startDate }
    }
}
// 
//extension TaskViewModel {
//    func addTask(_ task: Task) {
//        tasks.append(task)
//        saveTasks()
//        generateSuggestions(for: task)
//        NotificationManager.shared.scheduleNotification(for: task)
//    }
//    
//    func deleteTask(_ task: Task) {
//        tasks.removeAll(where: { $0.id == task.id })
//        saveTasks()
//        NotificationManager.shared.cancelNotification(for: task)
//    }
//}


