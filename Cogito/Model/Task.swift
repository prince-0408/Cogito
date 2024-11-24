//
//  Task.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import Foundation
import CoreData

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var isCompleted: Bool
    var dueDate: Date
    var priority: TaskPriority
    var aiGenerated: Bool
    var categories: [String]
    var createdAt: Date
    
    enum TaskPriority: String, Codable {
        case low, medium, high
    }
}
