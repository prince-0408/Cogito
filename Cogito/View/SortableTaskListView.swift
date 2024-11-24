//
//  SortableTaskListView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import SwiftUI

struct SortableTaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var sortOption: SortOption = .dueDate
    @State private var sortOrder: SortOrder = .ascending
    
    enum SortOption {
        case dueDate, priority, title, createdAt
    }
    
    enum SortOrder {
        case ascending, descending
    }
    
    var sortedTasks: [Task] {
        viewModel.tasks.sorted { task1, task2 in
            let comparison: Bool
            switch sortOption {
            case .dueDate:
                comparison = task1.dueDate < task2.dueDate
            case .priority:
                comparison = task1.priority.rawValue < task2.priority.rawValue
            case .title:
                comparison = task1.title < task2.title
            case .createdAt:
                comparison = task1.createdAt < task2.createdAt
            }
            return sortOrder == .ascending ? comparison : !comparison
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        Text("Due Date").tag(SortOption.dueDate)
                        Text("Priority").tag(SortOption.priority)
                        Text("Title").tag(SortOption.title)
                        Text("Created").tag(SortOption.createdAt)
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                
                Button(action: {
                    withAnimation {
                        sortOrder = sortOrder == .ascending ? .descending : .ascending
                    }
                }) {
                    Image(systemName: sortOrder == .ascending ? "arrow.up" : "arrow.down")
                }
            }
            .padding()
            
            List {
                ForEach(sortedTasks) { task in
                    AnimatedTaskRow(task: task) {
                        withAnimation {
                            viewModel.toggleTaskCompletion(task)
                        }
                    }
                }
            }
        }
    }
}

#Preview() {
    SortableTaskListView(viewModel: TaskViewModel())
}
