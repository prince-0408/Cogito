import SwiftUI

struct TaskDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var taskViewModel: TaskViewModel
    
    @State private var editedTask: Task
    @State private var isEditing = false
    
    init(task: Task) {
        _editedTask = State(initialValue: task)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header with category and priority
                        HStack {
                            Label(editedTask.category.rawValue, systemImage: editedTask.category.icon)
                                .font(.headline)
                                .foregroundColor(editedTask.category.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(editedTask.category.color.opacity(0.2))
                                )
                            
                            Spacer()
                            
                            Text(editedTask.priority.rawValue)
                                .font(.headline)
                                .foregroundColor(editedTask.priority.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(editedTask.priority.color.opacity(0.2))
                                )
                        }
                        
                        // Title
                        if isEditing {
                            TextField("Task title", text: $editedTask.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("CardBackground"))
                                )
                        } else {
                            Text(editedTask.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Foreground"))
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            if isEditing {
                                TextEditor(text: $editedTask.description)
                                    .frame(minHeight: 100)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("CardBackground"))
                                    )
                            } else {
                                Text(editedTask.description.isEmpty ? "No description provided" : editedTask.description)
                                    .foregroundColor(editedTask.description.isEmpty ? Color("TextPrimary").opacity(0.5) : Color("TextPrimary"))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("CardBackground"))
                                    )
                            }
                        }
                        
                        // Due Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Date")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            if isEditing {
                                DatePicker("", selection: $editedTask.dueDate)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("CardBackground"))
                                    )
                            } else {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color("Primary"))
                                    
                                    Text(editedTask.formattedDueDate)
                                        .foregroundColor(Color("TextPrimary"))
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("CardBackground"))
                                )
                            }
                        }
                        
                        // Status
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            HStack {
                                Image(systemName: editedTask.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(editedTask.isCompleted ? Color("Primary") : Color("TextPrimary").opacity(0.6))
                                
                                Text(editedTask.isCompleted ? "Completed" : "Pending")
                                    .foregroundColor(editedTask.isCompleted ? Color("Primary") : Color("TextPrimary"))
                                
                                if editedTask.isCompleted, let completedDate = editedTask.completedDate {
                                    Spacer()
                                    
                                    Text("Completed on \(formattedDate(completedDate))")
                                        .font(.caption)
                                        .foregroundColor(Color("TextPrimary").opacity(0.7))
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("CardBackground"))
                            )
                        }
                        
                        // Action Buttons
                        if !isEditing {
                            HStack(spacing: 15) {
                                Button(action: {
                                    toggleTaskCompletion()
                                }) {
                                    Label(
                                        editedTask.isCompleted ? "Mark as Incomplete" : "Mark as Complete",
                                        systemImage: editedTask.isCompleted ? "xmark.circle" : "checkmark.circle"
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Primary"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    deleteTask()
                                }) {
                                    Label("Delete", systemImage: "trash")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isEditing = false
                            // Reset to original task
                            if let originalTask = taskViewModel.tasks.first(where: { $0.id == editedTask.id }) {
                                editedTask = originalTask
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func toggleTaskCompletion() {
        editedTask.isCompleted.toggle()
        if editedTask.isCompleted {
            editedTask.completedDate = Date()
        } else {
            editedTask.completedDate = nil
        }
        saveChanges()
    }
    
    private func saveChanges() {
        taskViewModel.updateTask(editedTask)
        isEditing = false
    }
    
    private func deleteTask() {
        taskViewModel.deleteTask(id: editedTask.id)
        presentationMode.wrappedValue.dismiss()
    }
}

