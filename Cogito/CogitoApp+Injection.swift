import SwiftUI

extension CogitoApp {
   func setupDependencies() -> (TaskViewModel, AIViewModel) {
       // Create services
       let taskDataService = TaskDataService()
       let mistralAIService = MistralAIService()
       
       // Create view models with dependencies
       let taskViewModel = TaskViewModel(taskDataService: taskDataService)
       let aiViewModel = AIViewModel()
       
       return (taskViewModel, aiViewModel)
   }
}

// Update TaskViewModel to use TaskDataService
extension TaskViewModel {
   convenience init(taskDataService: TaskDataService) {
       self.init()
       self.taskDataService = taskDataService
       
       // Load tasks from data service
       self.tasks = taskDataService.fetchAllTasks()
       
       // Generate calendar data
       self.calendarData = taskDataService.generateCalendarData()
   }
}
