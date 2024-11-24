//
//  TaskFilterView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//
import SwiftUI

struct TaskFilterView: View {
    @Binding var selectedPriority: Task.TaskPriority?
    @Binding var selectedCategories: Set<String>
    @Binding var showCompleted: Bool
    let availableCategories: [String]
    
    var body: some View {
        Form {
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $selectedPriority) {
                    Text("All").tag(nil as Task.TaskPriority?)
                    Text("Low").tag(Task.TaskPriority.low as Task.TaskPriority?)
                    Text("Medium").tag(Task.TaskPriority.medium as Task.TaskPriority?)
                    Text("High").tag(Task.TaskPriority.high as Task.TaskPriority?)
                }
            }
            
            Section(header: Text("Categories")) {
                ForEach(availableCategories, id: \.self) { category in
                    Toggle(category, isOn: Binding(
                        get: { selectedCategories.contains(category) },
                        set: { isSelected in
                            if isSelected {
                                selectedCategories.insert(category)
                            } else {
                                selectedCategories.remove(category)
                            }
                        }
                    ))
                }
            }
            
            Section(header: Text("Status")) {
                Toggle("Show Completed Tasks", isOn: $showCompleted)
            }
        }
    }
}
