//
//  TaskListView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//
//import SwiftUI
//
//struct TaskListView: View {
//    @StateObject var viewModel: TaskViewModel
//        @State private var showingFilters = false
//        @State private var selectedPriority: Task.Priority?
//        @State private var selectedCategories: Set<String> = []
//        @State private var showCompleted = true
//    
//    init(viewModel: TaskViewModel = TaskViewModel()) {
//            _viewModel = StateObject(wrappedValue: viewModel)
//    }
//    
//    var filteredTasks: [Task] {
//        viewModel.tasks.filter { task in
//            let priorityMatch = selectedPriority == nil || task.priority == selectedPriority
//            let categoryMatch = selectedCategories.isEmpty || 
//                              !Set(task.categories).isDisjoint(with: selectedCategories)
//            let completionMatch = showCompleted || !task.isCompleted
//            return priorityMatch && categoryMatch && completionMatch
//        }
//    }
//    
//    var body: some View {
//        List {
//            ForEach(filteredTasks) { task in
//                TaskRowView(task: task) {
//                    viewModel.toggleTaskCompletion(task)
//                }
//                .swipeActions(edge: .trailing) {
//                    Button(role: .destructive) {
////                        $viewModel.deleteTask(task)
//                    } label: {
//                        Label("Delete", systemImage: "trash")
//                    }
//                }
//                .swipeActions(edge: .leading) {
//                    Button {
//                        viewModel.toggleTaskCompletion(task)
//                    } label: {
//                        Label(
//                            task.isCompleted ? "Mark Incomplete" : "Mark Complete",
//                            systemImage: task.isCompleted ? "xmark.circle" : "checkmark.circle"
//                        )
//                    }
//                    .tint(task.isCompleted ? .orange : .green)
//                }
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: { showingFilters = true }) {
//                    Image(systemName: "line.3.horizontal.decrease.circle")
//                }
//            }
//        }
//        .sheet(isPresented: $showingFilters) {
//            NavigationView {
//                TaskFilterView(
//                    selectedPriority: $selectedPriority,
//                    selectedCategories: $selectedCategories,
//                    showCompleted: $showCompleted,
//                    availableCategories: viewModel.getAllCategories()
//                )
//                .navigationTitle("Filters")
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button("Done") {
//                            showingFilters = false
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct Enhanced3DTaskListView: View {
//    @ObservedObject var viewModel: TaskViewModel
//    @State private var selectedTask: Task?
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 20) {
//                ForEach(viewModel.tasks) { task in
//                    Task3DCardView(task: task) {
//                        viewModel.toggleTaskCompletion(task)
//                    }
//                    .transition(.asymmetric(
//                        insertion: .scale.combined(with: .opacity),
//                        removal: .slide.combined(with: .opacity)
//                    ))
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Tasks")
//    }
//}
//
//#Preview {
////    TaskListView()  // Uses default TaskViewModel
////    // or
//    TaskListView(viewModel: TaskViewModel())  // Provides specific viewModel
//}
