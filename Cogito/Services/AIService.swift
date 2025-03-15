import Foundation
import Combine

class AIService {
    // In a real app, this would connect to an actual AI service
    // For this demo, we'll simulate AI functionality
    
    private let processingDelay: Double = Constants.AI.processingDelay
    
    func generateTaskSuggestions(basedOn tasks: [Task], count: Int = Constants.AI.suggestionCount) -> AnyPublisher<[AITaskSuggestion], Error> {
        return Future<[AITaskSuggestion], Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + self.processingDelay) {
                // Generate suggestions based on existing tasks
                let suggestions = AITaskSuggestion.generateSuggestions(basedOn: tasks, count: count)
                promise(.success(suggestions))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func generateInsights(from tasks: [Task]) -> AnyPublisher<[AIInsight], Error> {
        return Future<[AIInsight], Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + self.processingDelay) {
                // Generate insights based on task data
                let insights = AIInsight.generateInsights(from: tasks)
                promise(.success(insights))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func processNaturalLanguageInput(_ input: String) -> AnyPublisher<Task?, Error> {
        return Future<Task?, Error> { promise in
            // Simulate processing delay
            DispatchQueue.main.asyncAfter(deadline: .now() + self.processingDelay) {
                // Simple NLP simulation
                let lowercasedInput = input.lowercased()
                
                // Extract category
                var category: TaskCategory = .other
                for cat in TaskCategory.allCases {
                    if lowercasedInput.contains(cat.rawValue.lowercased()) {
                        category = cat
                        break
                    }
                }
                
                // Extract priority
                var priority: TaskPriority = .medium
                for pri in TaskPriority.allCases {
                    if lowercasedInput.contains(pri.rawValue.lowercased()) {
                        priority = pri
                        break
                    }
                }
                
                // Extract date
                var dueDate = Date()
                
                if lowercasedInput.contains("tomorrow") {
                    dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                } else if lowercasedInput.contains("next week") {
                    dueDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
                } else if lowercasedInput.contains("today") {
                    dueDate = Date()
                } else {
                    // Look for "in X days" pattern
                    let pattern = "in (\\d+) days?"
                    if let regex = try? NSRegularExpression(pattern: pattern) {
                        let nsString = input as NSString
                        let matches = regex.matches(in: input, range: NSRange(location: 0, length: nsString.length))
                        
                        if let match = matches.first, match.numberOfRanges > 1 {
                            let dayRange = match.range(at: 1)
                            if let days = Int(nsString.substring(with: dayRange)) {
                                dueDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
                            }
                        }
                    }
                }
                
                // Create task with extracted information
                let task = Task(
                    title: input,
                    category: category,
                    priority: priority,
                    dueDate: dueDate
                )
                
                promise(.success(task))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Simulate AI-based task categorization
    func categorizeTask(_ taskTitle: String, description: String) -> TaskCategory {
        let combinedText = "\(taskTitle) \(description)".lowercased()
        
        // Simple keyword matching for categories
        let categoryKeywords: [TaskCategory: [String]] = [
            .work: ["work", "project", "meeting", "deadline", "client", "report", "presentation", "email", "call", "conference"],
            .personal: ["personal", "home", "family", "friend", "social", "hobby", "vacation", "birthday", "gift"],
            .health: ["health", "workout", "exercise", "gym", "doctor", "medical", "appointment", "medicine", "diet", "run", "walk"],
            .finance: ["finance", "money", "bill", "payment", "bank", "budget", "tax", "invest", "expense", "income"],
            .education: ["education", "study", "learn", "course", "class", "book", "read", "research", "homework", "assignment"],
            .other: []
        ]
        
        var categoryScores: [TaskCategory: Int] = [:]
        
        // Calculate scores based on keyword matches
        for (category, keywords) in categoryKeywords {
            let score = keywords.reduce(0) { count, keyword in
                combinedText.contains(keyword) ? count + 1 : count
            }
            categoryScores[category] = score
        }
        
        // Find category with highest score
        if let highestCategory = categoryScores.max(by: { $0.value < $1.value }), highestCategory.value > 0 {
            return highestCategory.key
        }
        
        return .other
    }
}

