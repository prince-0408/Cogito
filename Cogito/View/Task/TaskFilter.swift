struct TaskFilter {
    var searchText: String = ""
    var priority: Priority?
    var status: TaskStatus = .all
    var sortBy: SortOption = .dueDate
    
    enum TaskStatus {
        case all, pending, completed
    }
    
    enum SortOption {
        case dueDate, priority, title
    }
}