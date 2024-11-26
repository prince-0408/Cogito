//
//  Task3DCardView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//


import SwiftUI

struct Task3DCardView: View {
    let task: Task
    let onToggle: () -> Void
    
    @State private var rotation: Double = 0
    @State private var isFlipped: Bool = false
    @State private var dragOffset: CGSize = .zero
    @GestureState private var dragState: CGSize = .zero
    
    // Card dimensions
    let cardWidth: CGFloat = UIScreen.main.bounds.width - 40
    let cardHeight: CGFloat = 200
    
    var body: some View {
        ZStack {
            // Front of card
            frontCard
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            
            // Back of card
            backCard
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(rotation + 180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
        }
        .frame(width: cardWidth, height: cardHeight)
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .updating($dragState) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        let threshold: CGFloat = 50
                        if abs(value.translation.width) > threshold {
                            // Swipe right to complete, left to delete
                            if value.translation.width > 0 {
                                onToggle()
                            }
                            dragOffset = .zero
                        } else {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .gesture(
            TapGesture()
                .onEnded {
                    withAnimation(.spring()) {
                        rotation += 180
                        isFlipped.toggle()
                    }
                }
        )
        .shadow(
            color: Color.black.opacity(0.2),
            radius: 10,
            x: 0,
            y: 5
        )
    }
    
    var frontCard: some View {
        VStack(spacing: 0) {
            // Priority indicator
            priorityBar
            
            // Main content
            VStack(alignment: .leading, spacing: 12) {
                titleSection
                descriptionSection
                bottomSection
            }
            .padding()
            .background(cardBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    var backCard: some View {
        VStack(spacing: 16) {
            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(task.categories, id: \.self) { category in
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            
            // Due date
            VStack(spacing: 8) {
                Text("Due Date")
                    .font(.headline)
                Text(task.dueDate, style: .date)
                    .font(.subheadline)
            }
            
            // Created date
            VStack(spacing: 8) {
                Text("Created")
                    .font(.headline)
                Text(task.createdAt, style: .date)
                    .font(.subheadline)
            }
            
            if task.aiGenerated {
                Image(systemName: "wand.and.stars")
                    .font(.title)
                    .foregroundColor(.purple)
                Text("AI Generated")
                    .font(.caption)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    var priorityBar: some View {
        Rectangle()
            .fill(priorityColor)
            .frame(height: 8)
    }
    
    var titleSection: some View {
        HStack {
            Text(task.title)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
            
            Spacer()
            
            CompletionButton(isCompleted: task.isCompleted) {
                onToggle()
            }
        }
    }
    
    var descriptionSection: some View {
        Text(task.description)
            .font(.subheadline)
            .foregroundColor(.gray)
            .lineLimit(2)
    }
    
    var bottomSection: some View {
        HStack {
            // Due date indicator
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                Text(task.dueDate, style: .date)
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            Spacer()
            
            // Flip indicator
            Image(systemName: "arrow.2.squarepath")
                .foregroundColor(.blue)
                .font(.caption)
        }
    }
    
    var cardBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.95)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var priorityColor: Color {
        switch task.priority {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

// Preview Provider
struct Task3DCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTask = Task(
            id: UUID(),
            title: "Sample Task",
            description: "This is a sample task description that might be a bit longer to see how it looks.",
            isCompleted: false,
            dueDate: Date().addingTimeInterval(86400),
            priority: .medium,
            aiGenerated: true,
            categories: ["Work", "Important"],
            createdAt: Date()
        )
        
        return Task3DCardView(task: sampleTask) {}
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

