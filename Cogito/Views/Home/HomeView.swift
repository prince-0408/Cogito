import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var aiViewModel: AIViewModel
    @EnvironmentObject private var tutorialManager: TutorialManager
    @State private var showingNewTaskSheet = false
    @State private var showingTaskDetail: Task?
    @State private var selectedCategory: TaskCategory?
    @State private var animateTasks = false
    @State private var isEditMode = false
    @State private var showCelebration = false
    @State private var currentAchievement: AchievementType = .firstTask
    @State private var spotlightRects: [String: CGRect] = [:]
    
    private var displayedTasks: [Task] {
        let tasks = taskViewModel.filteredTasks.filter {
            selectedCategory == nil || $0.category == selectedCategory
        }
        if tasks.isEmpty && tutorialManager.isTutorialActive {
            return [
                Task(
                    title: "🎯 Complete Cogito Interactive Feature Tour",
                    category: .education,
                    priority: .urgent,
                    dueDate: Date()
                )
            ]
        }
        return tasks
    }
    
    private var displayedSuggestions: [AITaskSuggestion] {
        if aiViewModel.taskSuggestions.isEmpty && tutorialManager.isTutorialActive {
            return [
                AITaskSuggestion(
                    title: "Organize desk for deep focus session",
                    category: .work,
                    priority: .medium,
                    dueDate: Date(),
                    confidence: 0.95
                )
            ]
        }
        return aiViewModel.taskSuggestions
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                   
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hello,")
                                    .font(.satoshi(.title2, weight: .regular))
                                    .foregroundColor(Color("TextPrimary"))
                                
                                Text("What's on your mind today?")
                                    .font(.satoshi(.largeTitle, weight: .bold))
                                    .foregroundColor(Color("Foreground"))
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    isEditMode.toggle()
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }) {
                                    Text(isEditMode ? "Done" : "Edit")
                                        .font(.satoshi(.subheadline, weight: .medium))
                                        .foregroundColor(Color("Primary"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color("Primary").opacity(0.2))
                                        )
                                }
                                .accessibilityLabel(isEditMode ? "Done editing" : "Edit tasks")
                                .accessibilityHint(isEditMode ? "Exit edit mode" : "Enter edit mode to reorder tasks")
                                .accessibilityAddTraits(.isButton)
                                
                                Button(action: {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    showingNewTaskSheet = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundColor(Color("Primary"))
                                        .padding()
                                        .background(
                                            Circle()
                                                .fill(Color("Primary").opacity(0.2))
                                        )
                                }
                                .spotlight(id: "create_button")
                                .accessibilityLabel("Create new task")
                                .accessibilityHint("Opens the task creation screen")
                                .accessibilityAddTraits(.isButton)
                            }
                        }
                        .padding(.horizontal)
                        
                        // AI Suggestions
                        if (aiViewModel.isEnabled && !aiViewModel.taskSuggestions.isEmpty) || tutorialManager.isTutorialActive {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("AI Suggestions")
                                    .font(.satoshi(.headline, weight: .bold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(displayedSuggestions) { suggestion in
                                            SuggestionCard(suggestion: suggestion) {
                                                let task = Task(
                                                    title: suggestion.title,
                                                    category: suggestion.category,
                                                    priority: suggestion.priority,
                                                    dueDate: suggestion.dueDate
                                                )
                                                taskViewModel.addTask(task)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .spotlight(id: "ai_suggestions")
                        }
                        
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                CategoryFilterButton(
                                    title: "All",
                                    isSelected: selectedCategory == nil,
                                    color: Color.gray
                                ) {
                                    selectedCategory = nil
                                }
                                
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category,
                                        color: category.color
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .spotlight(id: "category_filters")
                        
                        // Tasks List
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Today's Tasks")
                                .font(.satoshi(.headline, weight: .bold))
                                .foregroundColor(Color("TextPrimary"))
                                .padding(.horizontal)
                            
                            if displayedTasks.isEmpty {
                                EmptyTaskView()
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(displayedTasks) { task in
                                        taskRow(for: task)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .spotlight(id: "task_list")
                    }
                    .padding(.vertical)
                }
                
                // Tutorial Spotlight Overlay
                if tutorialManager.isTutorialActive, let currentStep = tutorialManager.currentStep {
                    let rect = spotlightRects[currentStep.id] ?? .zero
                    
                    ZStack(alignment: .topLeading) {
                        // Dimmed overlay background with dynamic Even-Odd spotlight mask cutout
                        Color.black.opacity(0.65)
                            .mask(
                                SpotlightMask(rect: rect, cornerRadius: 16)
                                    .fill(style: FillStyle(eoFill: true))
                            )
                            .ignoresSafeArea()
                            .onTapGesture {
                                // Tap outside target to proceed
                                tutorialManager.nextStep()
                            }
                        
                        // Highlight overlay helper to allow interactions or outlines
                        if rect != .zero {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.8), lineWidth: 2.5)
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                                .ignoresSafeArea()
                            
                            // Popover tooltip card positioned exactly relative to target center using absolute coordinates
                            TutorialTooltipView(step: currentStep, spotlightRect: rect)
                                .transition(.opacity.combined(with: .scale(scale: 0.94)))
                                .position(x: calculateTooltipCenterX(rect: rect), y: calculateTooltipCenterY(rect: rect, step: currentStep))
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: tutorialManager.currentStepIndex)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(200)
                    .transition(.opacity)
                }
            }
            .onPreferenceChange(SpotlightPreferenceKey.self) { rects in
                self.spotlightRects = rects
            }
            .overlay(
                CelebrationView(isPresented: $showCelebration, achievementType: currentAchievement)
            )
            .navigationBarHidden(true)
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskView()
                    .environmentObject(taskViewModel)
                    .environmentObject(aiViewModel)
            }
            .sheet(item: $showingTaskDetail) { task in
                TaskDetailView(task: task)
                    .environmentObject(taskViewModel)
            }
            .onAppear {
                aiViewModel.generateTaskSuggestions(basedOn: taskViewModel.tasks)
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateTasks = true
                }
            }
            .onChange(of: taskViewModel.tasks) { _ in
                checkAchievements()
            }
        }
    }
    
    private func checkAchievements() {
        let completedTasks = taskViewModel.tasks.filter { $0.isCompleted }
        let totalTasks = taskViewModel.tasks.count
        
        // Check for achievements
        if completedTasks.count == 1 && totalTasks >= 1 {
            currentAchievement = .firstTask
            showCelebration = true
        } else if completedTasks.count == 5 {
            currentAchievement = .fiveTasks
            showCelebration = true
        } else if totalTasks > 0 && completedTasks.count == totalTasks {
            currentAchievement = .allTasks
            showCelebration = true
        }
    }
    
    @ViewBuilder
    private func taskRow(for task: Task) -> some View {
        TaskCard(
            task: task,
            isEditMode: isEditMode,
            onToggleCompletion: {
                withAnimation {
                    if task.isCompleted {
                        var updatedTask = task
                        updatedTask.isCompleted = false
                        updatedTask.completedDate = nil
                        taskViewModel.updateTask(updatedTask)
                    } else {
                        taskViewModel.markTaskAsCompleted(task)
                    }
                }
            },
            onDelete: {
                withAnimation {
                    taskViewModel.deleteTask(id: task.id)
                }
            }
        )
        .onTapGesture {
            if !isEditMode {
                showingTaskDetail = task
            }
        }
    }
    
    // Tooltip horizontal centering coordinate mathematics using absolute positioning
    private func calculateTooltipCenterX(rect: CGRect) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let tooltipWidth: CGFloat = 300
        
        let targetX = rect.midX
        let proposedTooltipX = targetX - (tooltipWidth / 2)
        
        let margin: CGFloat = 16
        return max(margin, min(screenWidth - tooltipWidth - margin, proposedTooltipX)) + (tooltipWidth / 2)
    }
    
    // Tooltip vertical alignment coordinate mathematics using absolute positioning
    private func calculateTooltipCenterY(rect: CGRect, step: TutorialStep) -> CGFloat {
        let caretPadding: CGFloat = 12
        let tooltipHeightEstimate: CGFloat = 185
        
        if step.arrowDirection == .up {
            // Below target: tooltip center Y is target bottom + half of tooltip height + padding
            return rect.maxY + (tooltipHeightEstimate / 2) + caretPadding
        } else {
            // Above target: tooltip center Y is target top - half of tooltip height - padding
            return rect.minY - (tooltipHeightEstimate / 2) - caretPadding
        }
    }
}

struct SuggestionCard: View {
    let suggestion: AITaskSuggestion
    let onAccept: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: suggestion.category.icon)
                    .foregroundColor(suggestion.category.color)
                
                Text(suggestion.category.rawValue)
                    .font(.satoshi(.caption, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Text("\(Int(suggestion.confidence * 100))%")
                    .font(.satoshi(.caption, weight: .regular))
                    .foregroundColor(Color("TextPrimary").opacity(0.7))
            }
            
            Text(suggestion.title)
                .font(.satoshi(.headline, weight: .bold))
                .foregroundColor(Color("Foreground"))
                .lineLimit(2)
            
            HStack {
                Text(suggestion.priority.rawValue)
                    .font(.satoshi(.caption, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(suggestion.priority.color.opacity(0.2))
                    .foregroundColor(suggestion.priority.color)
                    .cornerRadius(4)
                
                Spacer()
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onAccept()
                }) {
                    Text("Add")
                        .font(.satoshi(.caption, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("Primary"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityLabel("Add suggested task")
                .accessibilityHint("Add \(suggestion.title) to your tasks")
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding()
        .frame(width: 200, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("AI suggested task: \(suggestion.title)")
        .accessibilityHint("\(suggestion.category.rawValue) category, \(suggestion.priority.rawValue) priority, \(Int(suggestion.confidence * 100))% confidence")
        .accessibilityAddTraits(.isButton)
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.satoshi(.subheadline, weight: isSelected ? .bold : .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color.opacity(0.2) : Color("CardBackground"))
                )
                .foregroundColor(isSelected ? color : Color("TextPrimary"))
        }
        .accessibilityLabel("Filter by \(title)")
        .accessibilityHint(isSelected ? "Selected filter" : "Tap to filter by \(title)")
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

struct TaskCard: View {
    let task: Task
    var isEditMode: Bool = false
    let onToggleCompletion: () -> Void
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            if isEditMode {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onDelete?()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            // Priority indicator
            Rectangle()
                .fill(task.priority.color)
                .frame(width: 4)
                .cornerRadius(2)
            
            // Task content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(task.title)
                        .font(.satoshi(.headline, weight: .bold))
                        .foregroundColor(task.isCompleted ? Color("TextPrimary").opacity(0.6) : Color("Foreground"))
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    Image(systemName: task.category.icon)
                        .foregroundColor(task.category.color)
                }
                
                HStack {
                    Text(task.formattedDueDate)
                        .font(.satoshi(.caption, weight: .regular))
                        .foregroundColor(Color("TextPrimary").opacity(0.8))
                    
                    Spacer()
                    
                    Text(task.priority.rawValue)
                        .font(.satoshi(.caption, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(task.priority.color.opacity(0.2))
                        .foregroundColor(task.priority.color)
                        .cornerRadius(4)
                }
            }
            .padding(.leading, 8)
            
            if !isEditMode {
                // Completion checkbox
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onToggleCompletion()
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? Color("Primary") : Color("TextPrimary").opacity(0.6))
                        .font(.title3)
                }
                .accessibilityLabel(task.isCompleted ? "Task completed" : "Mark task as completed")
                .accessibilityHint("Double tap to toggle completion status")
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(task.category.rawValue) category, \(task.priority.rawValue) priority")
        .accessibilityHint("Due \(task.formattedDueDate). Double tap to view details")
        .accessibilityAddTraits(task.isCompleted ? [.isButton, .isSelected] : .isButton)
    }
}

struct EmptyTaskView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(Color("Primary").opacity(0.7))
            
            Text("No tasks for today!")
                .font(.satoshi(.headline, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text("Tap the + button to add a new task")
                .font(.satoshi(.subheadline, weight: .regular))
                .foregroundColor(Color("TextPrimary").opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(TaskViewModel())
        .environmentObject(AIViewModel())
        .preferredColorScheme(.dark)
}
