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
    var priority: Priority
    var aiGenerated: Bool
    var categories: [String]
    var createdAt: Date
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
}
