import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var aiViewModel: AIViewModel
    @State private var showingNewTaskSheet = false
    @State private var showingTaskDetail: Task?
    @State private var selectedCategory: TaskCategory?
    
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
                            
                            Button(action: {
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
                                ForEach(taskViewModel.filteredTasks.filter { 
                                    selectedCategory == nil || $0.category == selectedCategory
                                }) { task in
                                    TaskCard(task: task)
                                        .onTapGesture {
                                            showingTaskDetail = task
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
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
            }
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
                
                Button(action: onAccept) {
                    Text("Add")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("Primary"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .frame(width: 200, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
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
            Button(action: {}) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? Color("Primary") : Color("TextPrimary").opacity(0.6))
                    .font(.title3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
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
