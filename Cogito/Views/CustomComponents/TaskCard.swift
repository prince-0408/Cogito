import SwiftUI

struct TaskCard: View {
    let task: Task
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onComplete: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    init(
        task: Task,
        onTap: @escaping () -> Void,
        onEdit: @escaping () -> Void = {},
        onDelete: @escaping () -> Void = {},
        onComplete: @escaping () -> Void = {}
    ) {
        self.task = task
        self.onTap = onTap
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Header with title and status
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(task.title)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.callout)
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                StatusBadge(status: task.status, style: .compact)
            }
            
            // Priority and metadata
            HStack(spacing: DesignTokens.Spacing.md) {
                PriorityIndicator(priority: task.priority, size: .small)
                
                if let dueDate = task.dueDate {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.textSecondary)
                        
                        Text(formatDate(dueDate))
                            .font(.caption)
                            .foregroundColor(Color.textSecondary)
                    }
                }
                
                Spacer()
                
                // Progress indicator for in-progress tasks
                if task.status == .inProgress {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        ProgressView(value: Double(task.completedSubtasks), total: Double(task.totalSubtasks))
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.inProgressTask))
                            .frame(width: 40)
                        
                        Text("\(task.completedSubtasks)/\(task.totalSubtasks)")
                            .font(.caption2)
                            .foregroundColor(Color.textTertiary)
                    }
                }
            }
            
            // Tags
            if !task.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        ForEach(task.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, DesignTokens.Spacing.sm)
                                .padding(.vertical, DesignTokens.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(Color.surfaceSelected)
                                )
                                .foregroundColor(Color.primaryColor)
                        }
                        
                        if task.tags.count > 3 {
                            Text("+\(task.tags.count - 3)")
                                .font(.caption2)
                                .foregroundColor(Color.textTertiary)
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                }
            }
            
            // Action buttons
            HStack(spacing: DesignTokens.Spacing.sm) {
                if task.status != .completed {
                    CustomButton(
                        title: "Complete",
                        icon: "checkmark",
                        style: .outline,
                        size: .small
                    ) {
                        onComplete()
                        let impactFeedback = UIImpactFeedbackGenerator(style: .success)
                        impactFeedback.impactOccurred()
                    }
                }
                
                CustomButton(
                    title: "Edit",
                    icon: "pencil",
                    style: .ghost,
                    size: .small
                ) {
                    onEdit()
                }
                
                Spacer()
                
                CustomButton(
                    title: "",
                    icon: "trash",
                    style: .ghost,
                    size: .small
                ) {
                    onDelete()
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                }
                .foregroundColor(Color.error)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                .fill(Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                        .stroke(
                            task.status == .completed ? Color.completedTask.opacity(0.3) : Color.divider,
                            lineWidth: task.status == .completed ? 2 : 1
                        )
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .opacity(task.status == .completed ? 0.8 : 1.0)
        .strikethrough(task.status == .completed, color: Color.textTertiary)
        .cardShadow()
        .animation(DesignTokens.Animation.quick, value: isPressed)
        .animation(DesignTokens.Animation.quick, value: isHovered)
        .animation(DesignTokens.Animation.smooth, value: task.status)
        .onTapGesture {
            onTap()
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Compact Task Card
struct CompactTaskCard: View {
    let task: Task
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Checkbox
            Button(action: onTap) {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(task.status == .completed ? Color.completedTask : Color.textTertiary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task info
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color.textPrimary)
                    .strikethrough(task.status == .completed, color: Color.textTertiary)
                    .lineLimit(1)
                
                HStack(spacing: DesignTokens.Spacing.sm) {
                    PriorityIndicator(priority: task.priority, size: .small)
                    
                    if let dueDate = task.dueDate {
                        Text(formatDate(dueDate))
                            .font(.caption2)
                            .foregroundColor(Color.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            StatusBadge(status: task.status, style: .iconOnly)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                .fill(Color.surface)
        )
        .opacity(task.status == .completed ? 0.7 : 1.0)
        .animation(DesignTokens.Animation.quick, value: task.status)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    VStack(spacing: DesignTokens.Spacing.md) {
        TaskCard(
            task: Task(
                id: UUID(),
                title: "Complete project documentation",
                description: "Write comprehensive documentation for the new feature including API endpoints and usage examples.",
                priority: .high,
                status: .inProgress,
                dueDate: Date(),
                tags: ["Documentation", "API"],
                completedSubtasks: 3,
                totalSubtasks: 5
            ),
            onTap: {},
            onEdit: {},
            onDelete: {},
            onComplete: {}
        )
        
        CompactTaskCard(
            task: Task(
                id: UUID(),
                title: "Review pull requests",
                description: "",
                priority: .medium,
                status: .pending,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                tags: ["Code Review"],
                completedSubtasks: 0,
                totalSubtasks: 1
            ),
            onTap: {}
        )
    }
    .padding()
}
