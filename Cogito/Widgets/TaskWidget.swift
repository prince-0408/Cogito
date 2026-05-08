import WidgetKit
import SwiftUI

struct TaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        TaskWidget()
        TaskWidgetSmall()
    }
}

struct TaskWidget: Widget {
    let kind: String = "TaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskProvider()) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks")
        .description("View and manage your tasks for today")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct TaskWidgetSmall: Widget {
    let kind: String = "TaskWidgetSmall"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskProvider()) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Quick Tasks")
        .description("See your top priority tasks at a glance")
        .supportedFamilies([.systemSmall])
    }
}
