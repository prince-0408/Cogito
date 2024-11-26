//
//  TaskRowView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import SwiftUI

struct TaskRowView: View {
    var task: Task
    let onToggle: () -> Void
    @ObservedObject var viewModel: TaskViewModel

    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(task.categories, id: \.self) { category in
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
    }
    private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
}
