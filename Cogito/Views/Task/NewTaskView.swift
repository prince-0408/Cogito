import SwiftUI
import Combine

struct NewTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var aiViewModel: AIViewModel
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: TaskCategory = .work
    @State private var priority: TaskPriority = .medium
    @State private var dueDate: Date = Date()
    @State private var reminderTime: Date? = nil
    @State private var enableReminder: Bool = false
    @State private var showingNLPInput = false
    @State private var nlpInput: String = ""
    @State private var isProcessingNLP = false
    @State private var aiSuggestions: [String] = []
    @State private var showingPromptSheet = false
    @State private var promptInput: String = ""
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if showingNLPInput {
                            // NLP Input
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Describe your task in natural language")
                                    .font(.headline)
                                    .foregroundColor(Color("TextPrimary"))
                                
                                Text("Example: \"Schedule team meeting for work tomorrow at 2pm with high priority\"")
                                    .font(.caption)
                                    .foregroundColor(Color("TextPrimary").opacity(0.7))
                                
                                TextEditor(text: $nlpInput)
                                    .frame(minHeight: 100)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("CardBackground"))
                                    )
                                
                                // AI Prompt Suggestions
                                if !aiSuggestions.isEmpty {
                                    Text("Suggestions")
                                        .font(.headline)
                                        .foregroundColor(Color("TextPrimary"))
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(aiSuggestions, id: \.self) { suggestion in
                                                Button(action: {
                                                    nlpInput = suggestion
                                                }) {
                                                    Text(suggestion)
                                                        .font(.caption)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .fill(Color("Primary").opacity(0.2))
                                                        )
                                                        .foregroundColor(Color("Primary"))
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    showingPromptSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "text.bubble.fill")
                                        Text("Use AI Prompt")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Secondary").opacity(0.2))
                                    .foregroundColor(Color("Secondary"))
                                    .cornerRadius(12)
                                }
                                
                                Button(action: processNLPInput) {
                                    HStack {
                                        if isProcessingNLP {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                        } else {
                                            Image(systemName: "wand.and.stars")
                                        }
                                        
                                        Text("Process with AI")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Primary"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .disabled(nlpInput.isEmpty || isProcessingNLP)
                                
                                Button(action: {
                                    showingNLPInput = false
                                }) {
                                    Text("Switch to Manual Input")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("CardBackground"))
                                        .foregroundColor(Color("TextPrimary"))
                                        .cornerRadius(12)
                                }
                            }
                        } else {
                            // Manual Input
                            VStack(alignment: .leading, spacing: 20) {
                                // Title
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Title")
                                        .font(.headline)
                                        .foregroundColor(Color("TextPrimary"))
                                    
                                    TextField("Task title", text: $title)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color("CardBackground"))
                                        )
                                }
                                
                                // Description
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description")
                                        .font(.headline)
                                        .foregroundColor(Color("TextPrimary"))
                                    
                                    TextEditor(text: $description)
                                        .frame(height: 100)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color("CardBackground"))
                                        )
                                }
                                
                                // Category
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Category")
                                        .font(.headline)
                                        .foregroundColor(Color("TextPrimary"))
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(TaskCategory.allCases, id: \.self) { cat in
                                                CategoryButton(
                                                    category: cat,
                                                    isSelected: category == cat
                                                ) {
                                                    category = cat
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Priority
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Priority")
                                        .font(.headline)
                                        .foregroundColor(Color("TextPrimary"))
                                    
                                    HStack(spacing: 10) {
                                        ForEach(TaskPriority.allCases, id: \.self) { pri in
                                            PriorityButton(
                                                priority: pri,
                                                isSelected: priority == pri
                                            ) {
                                                priority = pri
                                            }
                                        }
                                    }
                                }
                                
                                // Due Date
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Due Date")
                                        .font(.headline)
                                        .foregroundColor(Color("TextPrimary"))
                                    
                                    DatePicker("", selection: $dueDate)
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color("CardBackground"))
                                        )
                                }
                                
                                // Reminder
                                VStack(alignment: .leading, spacing: 8) {
                                    Toggle(isOn: $enableReminder) {
                                        Text("Set Reminder")
                                            .font(.headline)
                                            .foregroundColor(Color("TextPrimary"))
                                    }
                                    .padding(.vertical, 8)
                                    
                                    if enableReminder {
                                        DatePicker("Reminder Time", selection: Binding(
                                            get: { reminderTime ?? dueDate },
                                            set: { reminderTime = $0 }
                                        ))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color("CardBackground"))
                                        )
                                    }
                                }
                                
                                Button(action: {
                                    showingNLPInput = true
                                    loadAISuggestions()
                                }) {
                                    HStack {
                                        Image(systemName: "wand.and.stars")
                                        Text("Switch to AI Input")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Primary").opacity(0.2))
                                    .foregroundColor(Color("Primary"))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Error message
                if let errorMessage = aiViewModel.errorMessage {
                    VStack {
                        Spacer()
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.8))
                            )
                            .padding()
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingPromptSheet) {
                CustomSheetView(isPresented: $showingPromptSheet, title: "AI Prompt Templates") {
                    PromptSheetContent(promptInput: $promptInput, onSubmit: { prompt in
                        nlpInput = prompt
                        showingPromptSheet = false
                    })
                }
            }
            .onAppear {
                // Request notification permissions if needed
                if enableReminder {
                    NotificationManager.shared.requestAuthorization { _ in }
                }
            }
        }
    }
    
    private func saveTask() {
        let task = Task(
            title: title,
            description: description,
            category: category,
            priority: priority,
            dueDate: dueDate,
            reminderTime: enableReminder ? reminderTime : nil
        )
        
        taskViewModel.addTask(task)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func processNLPInput() {
        guard !nlpInput.isEmpty else { return }
        
        isProcessingNLP = true
        
        aiViewModel.processNaturalLanguageInput(nlpInput)
            .receive(on: DispatchQueue.main)
            .sink { task in
                self.isProcessingNLP = false
                
                if let task = task {
                    self.title = task.title
                    self.category = task.category
                    self.priority = task.priority
                    self.dueDate = task.dueDate
                    
                    self.showingNLPInput = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadAISuggestions() {
        // Predefined task prompt suggestions
        aiSuggestions = [
            "Schedule a team meeting for tomorrow at 2pm",
            "Remind me to pay rent next week",
            "Doctor appointment on Friday at 10am",
            "Buy groceries today",
            "Call mom this weekend",
            "Finish project report by next Tuesday"
        ]
    }
}

struct PromptSheetContent: View {
    @Binding var promptInput: String
    let onSubmit: (String) -> Void
    
    @State private var selectedPrompt: String = ""
    
    let promptTemplates = [
        "Schedule a meeting with [person] on [date] at [time]",
        "Remind me to [action] on [date]",
        "Call [person] on [date]",
        "Pay [bill] by [date]",
        "Submit [document] for [project] by [deadline]",
        "Buy [items] from [store]",
        "Prepare [meal] for [occasion]",
        "Exercise for [duration] minutes on [date]"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select a template or write your own prompt")
                .font(.subheadline)
                .foregroundColor(Color("TextPrimary").opacity(0.7))
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(promptTemplates, id: \.self) { template in
                        Button(action: {
                            selectedPrompt = template
                            promptInput = template
                        }) {
                            Text(template)
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedPrompt == template ?
                                              Color("Primary").opacity(0.2) :
                                              Color("CardBackground"))
                                )
                                .foregroundColor(selectedPrompt == template ?
                                                 Color("Primary") :
                                                 Color("TextPrimary"))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Prompt")
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))
                
                TextEditor(text: $promptInput)
                    .frame(height: 100)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("CardBackground"))
                    )
            }
            .padding(.horizontal)
            
            Button(action: {
                onSubmit(promptInput)
            }) {
                Text("Use This Prompt")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Primary"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(promptInput.isEmpty)
        }
        .padding(.bottom, 20)
    }
}

struct CategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color.opacity(0.2) : Color("CardBackground"))
            )
            .foregroundColor(isSelected ? category.color : Color("TextPrimary"))
        }
    }
}

struct PriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(priority.rawValue)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? priority.color.opacity(0.2) : Color("CardBackground"))
                )
                .foregroundColor(isSelected ? priority.color : Color("TextPrimary"))
        }
    }
}

