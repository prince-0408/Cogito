//
//  Task.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import Foundation
import CoreData
import SwiftUICore

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
        
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
            }
        }
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct NeumorphicCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            )
    }
}

struct GradientCard: ViewModifier {
    let priority: Task.Priority
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [priority.color.opacity(0.5), priority.color.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
    }
}

//struct PriorityBadge: View {
//    let priority = Priority()
//    
//    var body: some View {
//        Text(priority.rawValue)
//            .font(.caption)
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .background(priorityColor.opacity(0.2))
//            .foregroundColor(priorityColor)
//            .clipShape(Capsule())
//    }
//    
//    var priorityColor: Color {
//        switch priority {
//        case .low: return .green
//        case .medium: return .orange
//        case .high: return .red
//        }
//    }
//}
