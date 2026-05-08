# Widget Extension Setup Instructions

The widget files have been created in the `Widgets` folder. To add the widget extension to your Xcode project:

## Steps to Add Widget Extension

1. **Add Widget Extension Target**
   - In Xcode, go to File > New > Target
   - Select "Widget Extension" from the Application Extension section
   - Name it "CogitoWidgets"
   - Make sure "Include Configuration Intent" is unchecked (we're using static configuration)
   - Click Finish

2. **Add Files to Widget Extension**
   - In the newly created CogitoWidgets folder, delete all auto-generated files
   - Add the following files from the `Cogito/Widgets` folder:
     - TaskWidget.swift
     - TaskProvider.swift
     - TaskWidgetView.swift
     - TaskModel.swift
   - Replace the Info.plist with the one from the Widgets folder

3. **Configure Widget Target**
   - Select the CogitoWidgets target in project settings
   - In "Build Settings", set:
     - iOS Deployment Target: iOS 16.0 or later
   - In "General", set:
     - Bundle Identifier: com.yourbundle.CogitoWidgets
     - Team: Your development team

4. **Enable App Groups (for data sharing)**
   - In main app target (Cogito), go to "Signing & Capabilities"
   - Click "+ Capability" and add "App Groups"
   - Create a new group: group.com.yourbundle.Cogito
   - Do the same for the CogitoWidgets target

5. **Add Widget Color Assets**
   - Add a color named "WidgetBackground" to your asset catalog
   - This will be used as the widget background

6. **Build and Run**
   - Build the project (Cmd+B)
   - The widget should now be available in the widget gallery

## Data Sharing

To share task data between the main app and widget:

1. **Update TaskProvider.swift** to read from UserDefaults with App Groups:
```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.yourbundle.Cogito")
if let taskData = sharedDefaults?.data(forKey: "tasks"),
   let tasks = try? JSONDecoder().decode([Task].self, from: taskData) {
    // Use tasks from shared storage
}
```

2. **Update TaskViewModel** to save tasks to shared UserDefaults:
```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.yourbundle.Cogito")
if let encoded = try? JSONEncoder().encode(tasks) {
    sharedDefaults?.set(encoded, forKey: "tasks")
}
```

## Widget Features

- **Small Widget**: Shows task count and first task
- **Medium Widget**: Shows task count and top 3 tasks
- **Large Widget**: Shows task count, priority breakdown, and top 5 tasks
- Updates hourly automatically
- Supports all iOS widget sizes
- Beautiful, consistent design with main app

## Next Steps

- Implement App Groups for real data sharing
- Add deep linking to open specific tasks from widget
- Add configuration intent for customizable widget options
- Add Lock Screen widget support (iOS 16+)
- Add StandBy mode widget support (iOS 17+)
