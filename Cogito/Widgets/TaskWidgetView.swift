import SwiftUI
import WidgetKit

struct TaskWidgetView: View {
    var entry: TaskProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            TaskWidgetSmallView(entry: entry)
        case .systemMedium:
            TaskWidgetMediumView(entry: entry)
        case .systemLarge:
            TaskWidgetLargeView(entry: entry)
        default:
            TaskWidgetMediumView(entry: entry)
        }
    }
}

struct TaskWidgetSmallView: View {
    var entry: TaskProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("\(entry.completedCount)/\(entry.totalCount)")
                    .font(.satoshi(.headline, weight: .bold))
                Spacer()
            }
            
            Text("Today's Tasks")
                .font(.satoshi(.caption, weight: .regular))
                .foregroundColor(.secondary)
            
            if let firstTask = entry.tasks.first {
                HStack {
                    Circle()
                        .fill(priorityColor(firstTask.priority))
                        .frame(width: 6, height: 6)
                    Text(firstTask.title)
                        .font(.satoshi(.caption2, weight: .regular))
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color("WidgetBackground")
        }
    }
}

struct TaskWidgetMediumView: View {
    var entry: TaskProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.satoshi(.caption, weight: .regular))
                        .foregroundColor(.secondary)
                    Text("\(entry.completedCount)/\(entry.totalCount) done")
                        .font(.satoshi(.title3, weight: .bold))
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            Divider()
            
            VStack(spacing: 8) {
                ForEach(Array(entry.tasks.prefix(3))) { task in
                    TaskRow(task: task)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color("WidgetBackground")
        }
    }
}

struct TaskWidgetLargeView: View {
    var entry: TaskProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Tasks")
                        .font(.satoshi(.caption, weight: .regular))
                        .foregroundColor(.secondary)
                    Text("\(entry.completedCount)/\(entry.totalCount) completed")
                        .font(.satoshi(.title2, weight: .bold))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Label("\(entry.tasks.filter { $0.priority == "High" }.count)", systemImage: "exclamationmark.circle.fill")
                        .font(.satoshi(.caption, weight: .bold))
                        .foregroundColor(.red)
                    Label("\(entry.tasks.filter { $0.priority == "Medium" }.count)", systemImage: "minus.circle.fill")
                        .font(.satoshi(.caption, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
            
            VStack(spacing: 8) {
                ForEach(Array(entry.tasks.prefix(5))) { task in
                    TaskRow(task: task)
                }
                
                if entry.tasks.count > 5 {
                    Text("+ \(entry.tasks.count - 5) more tasks")
                        .font(.satoshi(.caption, weight: .regular))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color("WidgetBackground")
        }
    }
}

struct TaskRow: View {
    let task: WidgetTask

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(priorityColor(task.priority))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.satoshi(.caption, weight: .medium))
                    .lineLimit(1)
                
                Text(formatDate(task.dueDate))
                    .font(.satoshi(.caption2, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: categoryIcon(task.category))
                .font(.caption)
                .foregroundColor(categoryColor(task.category))
        }
        .padding(.vertical, 4)
    }
}

// Helper functions
fileprivate func priorityColor(_ priority: String) -> Color {
    switch priority {
    case "High", "Urgent": return .red
    case "Medium": return .orange
    case "Low": return .green
    default: return .gray
    }
}

fileprivate func categoryIcon(_ category: String) -> String {
    switch category {
    case "Work": return "briefcase.fill"
    case "Personal": return "person.fill"
    case "Health": return "heart.fill"
    case "Finance": return "dollarsign.circle.fill"
    case "Education": return "book.fill"
    default: return "ellipsis.circle.fill"
    }
}

fileprivate func categoryColor(_ category: String) -> Color {
    switch category {
    case "Work": return .blue
    case "Personal": return .purple
    case "Health": return .green
    case "Finance": return .yellow
    case "Education": return .orange
    default: return .gray
    }
}

fileprivate func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter.string(from: date)
}
