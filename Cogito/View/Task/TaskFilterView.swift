//
//  TaskFilterView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//
import SwiftUI

struct TaskFilterView: View {
    @Binding var selectedPriority: Task.Priority?
    @Binding var selectedCategories: Set<String>
    @Binding var showCompleted: Bool
    let availableCategories: [String]
    
    var body: some View {
        Form {
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $selectedPriority) {
                    Text("All").tag(nil as Task.Priority?)
                    Text("Low").tag(Task.Priority.low as Task.Priority?)
                    Text("Medium").tag(Task.Priority.medium as Task.Priority?)
                    Text("High").tag(Task.Priority.high as Task.Priority?)
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
