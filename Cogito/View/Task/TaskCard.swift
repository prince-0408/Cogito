//
//  TaskCard.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//
import SwiftUI

struct TaskCard: View {
    let task: Task
    let style: CardStyle
    
    enum CardStyle {
        case glass, neumorphic, gradient
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.title)
                    .font(.headline)
                Spacer()
                PriorityBadge(priority: task.priority)
            }
            
            Text(task.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(task.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .modifier(
//            style == .glass ? GlassCard() :
//            style == .neumorphic ? NeumorphicCard() :
            GradientCard(priority: task.priority)
        )
    }
}

struct PriorityBadge: View {
    let priority: Task.Priority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priority.color)
            .cornerRadius(8)
    }
}


// MARK: - Card Stack/Carousel
struct TaskCardStack: View {
    let tasks: [Task]
    @State private var currentIndex = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                TaskCard(task: task, style: .gradient)
                    .offset(x: getOffset(for: index))
                    .scaleEffect(getScale(for: index))
                    .zIndex(Double(tasks.count - index))
                    .opacity(getOpacity(for: index))
            }
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width > threshold {
                        withAnimation {
                            currentIndex = max(0, currentIndex - 1)
                        }
                    } else if value.translation.width < -threshold {
                        withAnimation {
                            currentIndex = min(tasks.count - 1, currentIndex + 1)
                        }
                    }
                }
        )
    }
    
    private func getOffset(for index: Int) -> CGFloat {
        let difference = CGFloat(index - currentIndex)
        let baseOffset: CGFloat = 20
        let maxVisibleCards = 3
        
        if abs(difference) >= CGFloat(maxVisibleCards) {
            return difference > 0 ? 300 : -300
        }
        
        return baseOffset * difference + dragOffset
    }
    
    private func getScale(for index: Int) -> CGFloat {
        let difference = CGFloat(index - currentIndex)
        let scale = 1.0 - (abs(difference) * 0.1)
        return max(scale, 0.8)
    }
    
    private func getOpacity(for index: Int) -> Double {
        let difference = abs(CGFloat(index - currentIndex))
        return difference >= 2 ? 0 : 1.0 - (difference * 0.3)
    }
}

//// MARK: - Preview Provider
//struct TaskCardPreview: PreviewProvider {
//    static var sampleTasks: [Task] = [
//        Task(id: "Design App UI", title: "Create wireframes and mockups", description: .high, isCompleted: Date(), dueDate: false),
//        Task(id: "Implement API", title: "Connect to backend services", description: .medium, isCompleted: Date().addingTimeInterval(86400), dueDate: true),
//        Task(title: "Write Documentation", description: "Document code and features", isCompleted: .low, dueDate: Date().addingTimeInterval(172800), priority: false)
//    ]
//    
//    static var previews: some View {
//        VStack(spacing: 20) {
//            TaskCard(task: sampleTasks[0], style: .glass)
//            TaskCard(task: sampleTasks[1], style: .neumorphic)
//            TaskCard(task: sampleTasks[2], style: .gradient)
//        }
//        .padding()
//        
//        TaskCardStack(tasks: sampleTasks)
//            .padding()
//    }
//}
