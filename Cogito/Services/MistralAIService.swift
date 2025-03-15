//
//  MistralAIError.swift
//  Cogito
//
//  Created by Prince Yadav on 12/03/25.
//

import Foundation
import Combine

enum MistralAIError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case decodingFailed(Error)
    case apiError(String)
    case unauthorized
    case rateLimited
    case serverError
    case unknown
}

class MistralAIService {
    // Built-in API key - in a real app, this would be more securely stored
    // or retrieved from a backend service
    private let apiKey = "7HqXeQFbL2oZuPcC9UWsX7DM91Siin85" // Mistral AI API key
    private let baseURL = "https://api.mistral.ai/v1"
    private let model = "mistral-medium" // Mistral AI model
    
    // Retry configuration
    private let maxRetries = 3
    private let initialBackoffDelay: TimeInterval = 1.0
    
    init() {
        // No need to get API key from user settings
    }
    
    // MARK: - Task Generation
    
    func generateTaskSuggestions(basedOn tasks: [Task], count: Int = 3) -> AnyPublisher<[AITaskSuggestion], Error> {
        let prompt = createTaskSuggestionPrompt(from: tasks, count: count)
        
        return makeCompletionRequestWithRetry(prompt: prompt)
            .map { response -> [AITaskSuggestion] in
                return self.parseTaskSuggestions(from: response, count: count)
            }
            .eraseToAnyPublisher()
    }
    
    func generateInsights(from tasks: [Task]) -> AnyPublisher<[AIInsight], Error> {
        let prompt = createInsightsPrompt(from: tasks)
        
        return makeCompletionRequestWithRetry(prompt: prompt)
            .map { response -> [AIInsight] in
                return self.parseInsights(from: response)
            }
            .eraseToAnyPublisher()
    }
    
    func processNaturalLanguageInput(_ input: String) -> AnyPublisher<Task?, Error> {
        let prompt = createNLPPrompt(input: input)
        
        return makeCompletionRequestWithRetry(prompt: prompt)
            .map { response -> Task? in
                return self.parseTaskFromNLP(response: response, originalInput: input)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - API Request with Retry
    
    private func makeCompletionRequestWithRetry(prompt: String, retryCount: Int = 0) -> AnyPublisher<String, Error> {
        return makeCompletionRequest(prompt: prompt)
            .tryCatch { error -> AnyPublisher<String, Error> in
                // If rate limited and we haven't exceeded max retries, retry with exponential backoff
                if case MistralAIError.rateLimited = error, retryCount < self.maxRetries {
                    let backoffDelay = self.initialBackoffDelay * pow(2.0, Double(retryCount))
                    print("Rate limited, retrying in \(backoffDelay) seconds (attempt \(retryCount + 1)/\(self.maxRetries))")
                    
                    return Just(())
                        .delay(for: .seconds(backoffDelay), scheduler: DispatchQueue.global())
                        .flatMap { _ in
                            self.makeCompletionRequestWithRetry(prompt: prompt, retryCount: retryCount + 1)
                        }
                        .eraseToAnyPublisher()
                }
                
                // For other errors or if we've exceeded max retries, propagate the error
                throw error
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - API Request
    
    private func makeCompletionRequest(prompt: String) -> AnyPublisher<String, Error> {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            return Fail(error: MistralAIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Mistral AI request format
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are an AI assistant for a task management app called Cogito."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw MistralAIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw MistralAIError.unauthorized
                case 429:
                    throw MistralAIError.rateLimited
                case 500...599:
                    throw MistralAIError.serverError
                default:
                    throw MistralAIError.apiError("Status code: \(httpResponse.statusCode)")
                }
            }
            .tryMap { data -> String in
                do {
                    // Parse Mistral AI response format
                    let response = try JSONDecoder().decode(MistralAIResponse.self, from: data)
                    guard let choice = response.choices.first,
                          let content = choice.message.content else {
                        return ""
                    }
                    return content
                } catch {
                    throw MistralAIError.decodingFailed(error)
                }
            }
            .mapError { error -> Error in
                if let mistralAIError = error as? MistralAIError {
                    return mistralAIError
                }
                if error is DecodingError {
                    return MistralAIError.decodingFailed(error)
                }
                return MistralAIError.requestFailed(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Prompt Creation
    
    private func createTaskSuggestionPrompt(from tasks: [Task], count: Int) -> String {
        var prompt = "Based on the following tasks, suggest \(count) new tasks that would be relevant and helpful for the user. "
        prompt += "For each task, provide a title, category (Work, Personal, Health, Finance, Education, or Other), priority (Low, Medium, High, or Urgent), and due date (relative to today).\n\n"
        
        // Add existing tasks as context
        prompt += "Current tasks:\n"
        for (index, task) in tasks.prefix(10).enumerated() {
            prompt += "\(index + 1). \(task.title) - Category: \(task.category.rawValue), Priority: \(task.priority.rawValue), Due: \(task.formattedDueDate)\n"
        }
        
        prompt += "\nProvide your suggestions in the following JSON format:\n"
        prompt += """
        [
          {
            "title": "Task title",
            "category": "Category name",
            "priority": "Priority level",
            "dueDate": "Number of days from today",
            "confidence": 0.85
          }
        ]
        """
        
        return prompt
    }
    
    private func createInsightsPrompt(from tasks: [Task]) -> String {
        var prompt = "Analyze the following task data and provide 4 meaningful insights about the user's productivity patterns, task completion rates, and habits. "
        prompt += "For each insight, provide a title, a detailed description, and categorize it as either 'productivity', 'pattern', or 'suggestion'.\n\n"
        
        // Add task data as context
        prompt += "Task data:\n"
        
        // Completed vs. total tasks
        let completedTasks = tasks.filter { $0.isCompleted }
        prompt += "Completed tasks: \(completedTasks.count) out of \(tasks.count) total tasks\n\n"
        
        // Tasks by category
        prompt += "Tasks by category:\n"
        for category in TaskCategory.allCases {
            let categoryTasks = tasks.filter { $0.category == category }
            let completedCategoryTasks = categoryTasks.filter { $0.isCompleted }
            prompt += "- \(category.rawValue): \(completedCategoryTasks.count) completed out of \(categoryTasks.count) total\n"
        }
        prompt += "\n"
        
        // Tasks by priority
        prompt += "Tasks by priority:\n"
        for priority in TaskPriority.allCases {
            let priorityTasks = tasks.filter { $0.priority == priority }
            let completedPriorityTasks = priorityTasks.filter { $0.isCompleted }
            prompt += "- \(priority.rawValue): \(completedPriorityTasks.count) completed out of \(priorityTasks.count) total\n"
        }
        
        prompt += "\nProvide your insights in the following JSON format:\n"
        prompt += """
        [
          {
            "title": "Insight title",
            "description": "Detailed description of the insight",
            "type": "productivity|pattern|suggestion"
          }
        ]
        """
        
        return prompt
    }
    
    private func createNLPPrompt(input: String) -> String {
        let prompt = """
        Parse the following natural language task description and extract structured information.
        
        Task description: "\(input)"
        
        Extract the following information:
        1. Task title (use the original input if no clear title is found)
        2. Category (Work, Personal, Health, Finance, Education, or Other)
        3. Priority (Low, Medium, High, or Urgent)
        4. Due date (relative to today, e.g., today, tomorrow, in X days, next week)
        
        Return the information in JSON format:
        {
          "title": "Task title",
          "category": "Category name",
          "priority": "Priority level",
          "dueDate": "Number of days from today"
        }
        """
        
        return prompt
    }
    
    // MARK: - Response Parsing
    
    private func parseTaskSuggestions(from response: String, count: Int) -> [AITaskSuggestion] {
        // Try to extract JSON from the response
        guard let jsonData = extractJSON(from: response) else {
            print("Failed to extract JSON from response, using fallback suggestions")
            return [] // Return empty array, AIViewModel will handle fallback
        }
        
        do {
            let decoder = JSONDecoder()
            let suggestions = try decoder.decode([TaskSuggestionResponse].self, from: jsonData)
            
            return suggestions.map { suggestion in
                // Calculate due date based on days from today
                let daysToAdd = Int(suggestion.dueDate) ?? 1
                let dueDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
                
                // Parse category and priority
                let category = TaskCategory(rawValue: suggestion.category) ?? .other
                let priority = TaskPriority(rawValue: suggestion.priority) ?? .medium
                
                return AITaskSuggestion(
                    title: suggestion.title,
                    category: category,
                    priority: priority,
                    dueDate: dueDate,
                    confidence: suggestion.confidence
                )
            }
        } catch {
            print("Error parsing task suggestions: \(error)")
            return [] // Return empty array, AIViewModel will handle fallback
        }
    }
    
    private func parseInsights(from response: String) -> [AIInsight] {
        // Try to extract JSON from the response
        guard let jsonData = extractJSON(from: response) else {
            print("Failed to extract JSON from response, using fallback insights")
            return [] // Return empty array, AIViewModel will handle fallback
        }
        
        do {
            let decoder = JSONDecoder()
            let insights = try decoder.decode([InsightResponse].self, from: jsonData)
            
            return insights.map { insight in
                let type: AIInsight.InsightType
                switch insight.type.lowercased() {
                case "productivity":
                    type = .productivity
                case "pattern":
                    type = .pattern
                case "suggestion":
                    type = .suggestion
                default:
                    type = .productivity
                }
                
                return AIInsight(
                    id: UUID(),
                    title: insight.title,
                    description: insight.description,
                    type: type
                )
            }
        } catch {
            print("Error parsing insights: \(error)")
            return [] // Return empty array, AIViewModel will handle fallback
        }
    }
    
    private func parseTaskFromNLP(response: String, originalInput: String) -> Task? {
        // Try to extract JSON from the response
        guard let jsonData = extractJSON(from: response) else {
            print("Failed to extract JSON from response")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let taskInfo = try decoder.decode(TaskNLPResponse.self, from: jsonData)
            
            // Calculate due date based on days from today
            let daysToAdd = Int(taskInfo.dueDate) ?? 0
            let dueDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
            
            // Parse category and priority
            let category = TaskCategory(rawValue: taskInfo.category) ?? .other
            let priority = TaskPriority(rawValue: taskInfo.priority) ?? .medium
            
            return Task(
                title: taskInfo.title.isEmpty ? originalInput : taskInfo.title,
                description: "",
                category: category,
                priority: priority,
                dueDate: dueDate
            )
        } catch {
            print("Error parsing NLP task: \(error)")
            return nil
        }
    }
    
    // Helper to extract JSON from a text response
    private func extractJSON(from text: String) -> Data? {
        // Look for JSON content between curly braces or square brackets
        let pattern = "\\[\\s*\\{.*\\}\\s*\\]|\\{.*\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return nil
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = matches.first {
            let jsonString = nsString.substring(with: match.range)
            return jsonString.data(using: .utf8)
        }
        
        return nil
    }
}

// MARK: - Response Models

struct MistralAIResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    
    struct Choice: Decodable {
        let index: Int
        let message: Message
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Decodable {
        let role: String
        let content: String?
    }
}

struct TaskSuggestionResponse: Decodable {
    let title: String
    let category: String
    let priority: String
    let dueDate: String
    let confidence: Double
}

struct InsightResponse: Decodable {
    let title: String
    let description: String
    let type: String
}

struct TaskNLPResponse: Decodable {
    let title: String
    let category: String
    let priority: String
    let dueDate: String
}

