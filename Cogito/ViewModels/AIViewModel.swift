import Foundation
import Combine

class AIViewModel: ObservableObject {
    @Published var taskSuggestions: [AITaskSuggestion] = []
    @Published var insights: [AIInsight] = []
    @Published var isProcessing: Bool = false
    @Published var isEnabled: Bool = true
    @Published var errorMessage: String? = nil
    
    private var mistralAIService = MistralAIService()
    private var cancellables = Set<AnyCancellable>()
    
    // Retry configuration
    private let maxRetries = 3
    private var currentRetryCount = 0
    private let retryDelay: TimeInterval = 2.0
    
    func generateTaskSuggestions(basedOn tasks: [Task]) {
        guard isEnabled else {
            taskSuggestions = []
            return
        }
        
        isProcessing = true
        errorMessage = nil
        currentRetryCount = 0
        
        mistralAIService.generateTaskSuggestions(basedOn: tasks)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isProcessing = false
                    
                    if case .failure(let error) = completion {
                        self.handleError(error, context: "generating task suggestions")
                        // Fallback to simulated suggestions on error
                        self.taskSuggestions = AITaskSuggestion.generateSuggestions(basedOn: tasks)
                    }
                },
                receiveValue: { [weak self] suggestions in
                    if suggestions.isEmpty {
                        // If API returned empty results, use simulated suggestions
                        self?.taskSuggestions = AITaskSuggestion.generateSuggestions(basedOn: tasks)
                    } else {
                        self?.taskSuggestions = suggestions
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func generateInsights(from tasks: [Task]) {
        guard isEnabled else {
            insights = []
            return
        }
        
        isProcessing = true
        errorMessage = nil
        currentRetryCount = 0
        
        mistralAIService.generateInsights(from: tasks)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isProcessing = false
                    
                    if case .failure(let error) = completion {
                        self.handleError(error, context: "generating insights")
                        // Fallback to simulated insights on error
                        self.insights = AIInsight.generateInsights(from: tasks)
                    }
                },
                receiveValue: { [weak self] insights in
                    if insights.isEmpty {
                        // If API returned empty results, use simulated insights
                        self?.insights = AIInsight.generateInsights(from: tasks)
                    } else {
                        self?.insights = insights
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func processNaturalLanguageInput(_ input: String) -> AnyPublisher<Task?, Never> {
        guard isEnabled else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        isProcessing = true
        errorMessage = nil
        
        return mistralAIService.processNaturalLanguageInput(input)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    if case .failure(let error) = completion {
                        self?.handleError(error, context: "processing natural language")
                    }
                }
            )
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    private func handleError(_ error: Error, context: String) {
        print("Error \(context): \(error)")
        
        if let mistralAIError = error as? MistralAIError {
            switch mistralAIError {
            case .unauthorized:
                errorMessage = "Authentication error with Mistral AI. Please try again later."
            case .rateLimited:
                errorMessage = "Rate limit exceeded. Please try again later."
            case .serverError:
                errorMessage = "Mistral AI server error. Please try again later."
            case .apiError(let message):
                errorMessage = "API error: \(message)"
            case .decodingFailed:
                errorMessage = "Failed to process AI response. Please try again."
            default:
                errorMessage = "An error occurred while \(context). Please try again."
            }
        } else {
            errorMessage = "An error occurred while \(context). Please try again."
        }
        
        // Auto-dismiss error message after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.errorMessage = nil
        }
    }
    
    func toggleAI(enabled: Bool) {
        isEnabled = enabled
        if !isEnabled {
            taskSuggestions = []
            insights = []
        }
    }
}


