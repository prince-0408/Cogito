//
//  TaskFilter.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//
import SwiftUI

struct TaskFilter {
    var searchText: String = ""
//    var priority: Priority
    var status: TaskStatus = .all
    var sortBy: SortOption = .dueDate
    
    enum TaskStatus {
        case all, pending, completed
    }
    
    enum SortOption {
        case dueDate, priority, title
    }
}
