import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var aiViewModel: AIViewModel
    @State private var showingNewTaskSheet = false
    @State private var showingTaskDetail: Task?
    @State private var selectedCategory: TaskCategory?
    @State private var animateTasks = false
    @State private var isEditMode = false
    @State private var showCelebration = false
    @State private var currentAchievement: AchievementType = .firstTask
    
    private var displayedTasks: [Task] {
        taskViewModel.filteredTasks.filter {
            selectedCategory == nil || $0.category == selectedCategory
        }
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
                                    .font(.title2)
                                    .foregroundColor(Color("TextPrimary"))
                                
                                Text("What's on your mind today?")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
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
                                        .font(.subheadline)
                                        .fontWeight(.medium)
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
                                .accessibilityLabel("Create new task")
                                .accessibilityHint("Opens the task creation screen")
                                .accessibilityAddTraits(.isButton)
                            }
                        }
                        .padding(.horizontal)
                        
                        // AI Suggestions
                        if aiViewModel.isEnabled && !aiViewModel.taskSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("AI Suggestions")
                                    .font(.headline)
                                    .foregroundColor(Color("TextPrimary"))
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(aiViewModel.taskSuggestions) { suggestion in
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
                        
                        // Tasks List
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Today's Tasks")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                                .padding(.horizontal)
                            
                            if taskViewModel.filteredTasks.isEmpty {
                                EmptyTaskView()
                            } else {
                                List {
                                    ForEach(displayedTasks) { task in
                                        taskRow(for: task)
                                    }
                                    .onMove { source, destination in
                                        taskViewModel.moveTask(from: source, to: destination)
                                    }
                                }
                                .listStyle(.plain)
                                .scrollContentBackground(.hidden)
                                .environment(\.editMode, isEditMode ? .constant(.active) : .constant(.inactive))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
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
        TaskCard(task: task)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .onTapGesture {
                showingTaskDetail = task
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    withAnimation {
                        taskViewModel.deleteTask(id: task.id)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button {
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
                } label: {
                    Label(task.isCompleted ? "Mark Incomplete" : "Complete", systemImage: task.isCompleted ? "circle" : "checkmark.circle")
                }
                .tint(task.isCompleted ? .orange : .green)
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
                    .font(.caption)
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Text("\(Int(suggestion.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(Color("TextPrimary").opacity(0.7))
            }
            
            Text(suggestion.title)
                .font(.headline)
                .foregroundColor(Color("Foreground"))
                .lineLimit(2)
            
            HStack {
                Text(suggestion.priority.rawValue)
                    .font(.caption)
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
                        .font(.caption)
                        .fontWeight(.medium)
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
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
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
    
    var body: some View {
        HStack {
            // Priority indicator
            Rectangle()
                .fill(task.priority.color)
                .frame(width: 4)
                .cornerRadius(2)
            
            // Task content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(task.isCompleted ? Color("TextPrimary").opacity(0.6) : Color("Foreground"))
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    Image(systemName: task.category.icon)
                        .foregroundColor(task.category.color)
                }
                
                HStack {
                    Text(task.formattedDueDate)
                        .font(.caption)
                        .foregroundColor(Color("TextPrimary").opacity(0.8))
                    
                    Spacer()
                    
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(task.priority.color.opacity(0.2))
                        .foregroundColor(task.priority.color)
                        .cornerRadius(4)
                }
            }
            .padding(.leading, 8)
            
            // Completion checkbox
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? Color("Primary") : Color("TextPrimary").opacity(0.6))
                    .font(.title3)
            }
            .accessibilityLabel(task.isCompleted ? "Task completed" : "Mark task as completed")
            .accessibilityHint("Double tap to toggle completion status")
            .accessibilityAddTraits(.isButton)
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
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            Text("Tap the + button to add a new task")
                .font(.subheadline)
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
