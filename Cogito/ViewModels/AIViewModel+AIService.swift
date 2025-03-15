import Foundation
import Combine

// Extension to connect AIViewModel with AIService
extension AIViewModel {
    var aiService: AIService? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.aiService) as? AIService }
        set { objc_setAssociatedObject(self, &AssociatedKeys.aiService, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private struct AssociatedKeys {
        static var aiService = "aiService"
        static var cancellables = "cancellables"
    }
    
    private var cancellables: Set<AnyCancellable> {
        get {
            if let cancellables = objc_getAssociatedObject(self, &AssociatedKeys.cancellables) as? Set<AnyCancellable> {
                return cancellables
            } else {
                let cancellables = Set<AnyCancellable>()
                objc_setAssociatedObject(self, &AssociatedKeys.cancellables, cancellables, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return cancellables
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.cancellables, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func processNaturalLanguageInput(_ input: String) -> Task? {
        guard isEnabled else { return nil }
        
        if let service = aiService {
            var resultTask: Task?
            let semaphore = DispatchSemaphore(value: 0)
            
            service.processNaturalLanguageInput(input)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        semaphore.signal()
                    },
                    receiveValue: { task in
                        resultTask = task
                    }
                )
                .store(in: &cancellables)
            
            // Wait for result (not ideal for production, but works for demo)
            _ = semaphore.wait(timeout: .now() + 3.0)
            return resultTask
        } else {
            // Simple NLP simulation (same as original implementation)
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
            return Task(
                title: input,
                category: category,
                priority: priority,
                dueDate: dueDate
            )
        }
    }
}

