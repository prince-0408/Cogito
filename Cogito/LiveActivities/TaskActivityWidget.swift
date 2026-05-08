import SwiftUI
import WidgetKit
import ActivityKit

struct TaskActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TaskActivityAttributes.self) { context in
            // Lock screen / banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: context.attributes.taskCategory == "Work" ? "briefcase.fill" : 
                                      context.attributes.taskCategory == "Personal" ? "person.fill" :
                                      context.attributes.taskCategory == "Health" ? "heart.fill" :
                                      context.attributes.taskCategory == "Finance" ? "dollarsign.circle.fill" :
                                      context.attributes.taskCategory == "Education" ? "book.fill" : "ellipsis.circle.fill")
                            .foregroundColor(.white)
                        Text(context.state.taskTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timeRemainingString(from: context.state.timeRemaining))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if context.state.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("Due: \(formatDate(context.attributes.dueDate))")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Button {
                            // Complete task action
                        } label: {
                            Text("Complete")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(20)
                        }
                    }
                    .transition(.opacity)
                }
            } compactLeading: {
                // Compact leading
                Image(systemName: context.attributes.taskCategory == "Work" ? "briefcase.fill" : 
                              context.attributes.taskCategory == "Personal" ? "person.fill" :
                              context.attributes.taskCategory == "Health" ? "heart.fill" :
                              context.attributes.taskCategory == "Finance" ? "dollarsign.circle.fill" :
                              context.attributes.taskCategory == "Education" ? "book.fill" : "ellipsis.circle.fill")
                    .foregroundColor(.white)
            } compactTrailing: {
                // Compact trailing
                Text(timeRemainingString(from: context.state.timeRemaining))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } minimal: {
                // Minimal
                Image(systemName: context.state.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(context.state.isCompleted ? .green : .white)
            }
            .widgetURL(URL(string: "cogito://task/\(context.attributes.taskId)"))
        }
    }
    
    private func timeRemainingString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TaskActivityAttributes>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.taskTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(context.attributes.taskCategory)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(timeRemainingString(from: context.state.timeRemaining))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(formatDate(context.attributes.dueDate))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    private func timeRemainingString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
