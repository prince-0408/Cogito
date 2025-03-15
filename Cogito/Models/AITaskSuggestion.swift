import Foundation

struct AITaskSuggestion: Identifiable {
    var id = UUID()
    var title: String
    var category: TaskCategory
    var priority: TaskPriority
    var dueDate: Date
    var confidence: Double // 0.0 to 1.0 representing AI confidence
    
    // Simulated AI response
    static func generateSuggestions(basedOn tasks: [Task], count: Int = 3) -> [AITaskSuggestion] {
        let categories = TaskCategory.allCases
        let priorities = TaskPriority.allCases
        
        // Sample task titles based on categories
        let taskTitles: [TaskCategory: [String]] = [
            .work: ["Weekly team meeting", "Project deadline", "Client presentation", "Update documentation", "Code review", "Send progress report", "Prepare quarterly review", "Team brainstorming session"],
            .personal: ["Call family", "Plan weekend", "Organize photos", "Home cleaning", "Shopping", "Birthday gift for friend", "Schedule haircut", "Plan vacation"],
            .health: ["Morning workout", "Doctor appointment", "Meditation session", "Prepare healthy meal", "Evening walk", "Yoga class", "Refill prescription", "Schedule dental checkup"],
            .finance: ["Pay bills", "Review budget", "Tax preparation", "Investment research", "Expense tracking", "Check credit score", "Update financial plan", "Review insurance policies"],
            .education: ["Online course", "Study session", "Research paper", "Reading assignment", "Practice coding", "Watch tutorial", "Complete quiz", "Review notes"],
            .other: ["Miscellaneous task", "Check emails", "Plan vacation", "Car maintenance", "Home repairs", "Backup computer files", "Organize digital documents", "Update software"]
        ]
        
        var suggestions: [AITaskSuggestion] = []
        
        // Analyze existing tasks to make more relevant suggestions
        var mostCommonCategory: TaskCategory = .other
        var categoryCount: [TaskCategory: Int] = [:]
        
        for task in tasks {
            categoryCount[task.category, default: 0] += 1
        }
        
        if let mostCommon = categoryCount.max(by: { $0.value < $1.value }) {
            mostCommonCategory = mostCommon.key
        }
        
        // Generate suggestions with a bias toward the most common category
        for i in 0..<count {
            // For variety, make some suggestions from the most common category
            // and others from random categories
            let useCommonCategory = i < count / 2 + 1
            let randomCategory = useCommonCategory ? mostCommonCategory : categories.randomElement() ?? .work
            let randomPriority = priorities.randomElement() ?? .medium
            
            // Get titles for the selected category
            let titlesForCategory = taskTitles[randomCategory] ?? taskTitles[.other]!
            let randomTitle = titlesForCategory.randomElement() ?? "New Task"
            
            // Generate due date between tomorrow and next week
            let daysToAdd = Int.random(in: 1...7)
            let dueDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
            
            let suggestion = AITaskSuggestion(
                title: randomTitle,
                category: randomCategory,
                priority: randomPriority,
                dueDate: dueDate,
                confidence: Double.random(in: 0.75...0.95)
            )
            
            suggestions.append(suggestion)
        }
        
        return suggestions
    }
}

struct AIInsight: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var type: InsightType
    
    enum InsightType {
        case productivity
        case pattern
        case suggestion
    }
    
    static func generateInsights(from tasks: [Task]) -> [AIInsight] {
        // If there are no tasks, return generic insights
        if tasks.isEmpty {
            return [
                AIInsight(
                    title: "Getting Started",
                    description: "Start by adding tasks to get personalized insights about your productivity patterns.",
                    type: .suggestion
                ),
                AIInsight(
                    title: "Task Categories",
                    description: "Organize your tasks into categories to better understand where you spend most of your time.",
                    type: .suggestion
                ),
                AIInsight(
                    title: "Priority Management",
                    description: "Use priorities to focus on what matters most and improve your productivity.",
                    type: .suggestion
                ),
                AIInsight(
                    title: "Regular Reviews",
                    description: "Check your insights regularly to identify patterns and improve your workflow.",
                    type: .productivity
                )
            ]
        }
        
        // Calculate some basic statistics
        let completedTasks = tasks.filter { $0.isCompleted }
        let completionRate = tasks.isEmpty ? 0 : Double(completedTasks.count) / Double(tasks.count)
        
        // Find most common category
        var categoryCount: [TaskCategory: Int] = [:]
        for task in tasks {
            categoryCount[task.category, default: 0] += 1
        }
        let mostCommonCategory = categoryCount.max(by: { $0.value < $1.value })?.key ?? .other
        
        // Find most common priority
        var priorityCount: [TaskPriority: Int] = [:]
        for task in tasks {
            priorityCount[task.priority, default: 0] += 1
        }
        let mostCommonPriority = priorityCount.max(by: { $0.value < $1.value })?.key ?? .medium
        
        // Generate insights based on the data
        var insights: [AIInsight] = []
        
        // Completion rate insight
        let completionRateInsight = AIInsight(
            title: "Task Completion Rate",
            description: "Your overall completion rate is \(Int(completionRate * 100))%. " +
                        (completionRate >= 0.7 ? "Great job staying on top of your tasks!" :
                         completionRate >= 0.4 ? "You're making good progress on your tasks." :
                         "Consider breaking down tasks into smaller steps to improve completion."),
            type: .productivity
        )
        insights.append(completionRateInsight)
        
        // Category insight
        let categoryInsight = AIInsight(
            title: "Most Active Category",
            description: "You have the most tasks in the \(mostCommonCategory.rawValue) category (\(categoryCount[mostCommonCategory] ?? 0) tasks). " +
                        "This suggests this area is a significant focus for you.",
            type: .pattern
        )
        insights.append(categoryInsight)
        
        // Priority insight
        let priorityInsight = AIInsight(
            title: "Priority Distribution",
            description: "Most of your tasks are set to \(mostCommonPriority.rawValue) priority. " +
                        (mostCommonPriority == .high || mostCommonPriority == .urgent ?
                         "Consider if all these tasks truly need high priority status." :
                         "Make sure to properly prioritize important tasks."),
            type: .suggestion
        )
        insights.append(priorityInsight)
        
        // Time management insight
        let timeInsight = AIInsight(
            title: "Upcoming Deadlines",
            description: "You have \(tasks.filter { !$0.isCompleted && $0.dueDate < Date().addingTimeInterval(86400 * 3) }.count) tasks due in the next 3 days. " +
                        "Plan your time accordingly to meet these deadlines.",
            type: .suggestion
        )
        insights.append(timeInsight)
        
        return insights
    }
}

