# Siri Shortcuts Setup Instructions

The Siri Shortcuts files have been created in the `Shortcuts` folder. To enable Siri Shortcuts in your app:

## Steps to Enable Siri Shortcuts

1. **Add App Groups Capability**
   - In Xcode, select your main app target (Cogito)
   - Go to "Signing & Capabilities"
   - Click "+ Capability" and add "App Groups"
   - Create a new group: `group.com.yourbundle.Cogito`
   - Do the same for any widget extension target

2. **Add Siri Capability**
   - In the same "Signing & Capabilities" section
   - Click "+ Capability" and add "Siri"
   - This enables Siri to interact with your app

3. **Update Bundle Identifier**
   - Replace `com.yourbundle.Cogito` with your actual bundle identifier in:
     - CreateTaskIntent.swift (UserDefaults suite name)
     - Widget README.md
     - Any other files referencing the bundle ID

4. **Add Shortcuts Files to Project**
   - Add the following files from the `Shortcuts` folder to your Xcode project:
     - CreateTaskIntent.swift
     - CompleteTaskIntent.swift
     - CogitoAppShortcuts.swift
   - Make sure these files are added to your main app target

5. **Test Siri Shortcuts**
   - Build and run the app
   - Go to Settings > Siri & Search > Cogito
   - You should see the available shortcuts
   - Try saying "Hey Siri, create a task in Cogito"

## Available Shortcuts

### Create Task
- **Phrases**: "Create a task in Cogito", "Add a task to Cogito"
- **Parameters**: 
  - Task Title (required)
  - Task Description (optional)
  - Category (optional: Work, Personal, Health, Finance, Education, Other)
  - Priority (optional: Low, Medium, High, Urgent)
  - Due Date (optional)

### Create Work Task
- **Phrases**: "Create a work task in Cogito"
- **Parameters**: Same as Create Task, but defaults category to Work

### Create Urgent Task
- **Phrases**: "Create a high priority task in Cogito"
- **Parameters**: Same as Create Task, but defaults priority to High

### Complete Task
- **Phrases**: "Complete a task in Cogito", "Mark task done in Cogito"
- **Note**: Currently shows task selection UI (to be implemented)

## Customizing Shortcuts

### Adding New Shortcuts
Add new shortcuts in `CogitoAppShortcuts.swift`:

```swift
AppShortcut(
    intent: YourCustomIntent(),
    phrases: [
        "Your phrase here",
        "Another phrase"
    ],
    shortTitle: "Your Title",
    systemImageName: "icon.name"
)
```

### Modifying Existing Shortcuts
Edit the intent files in the Shortcuts folder to change behavior or add parameters.

## Data Sharing

To share data between Siri Shortcuts and the main app:

1. **Use App Groups UserDefaults**:
```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.yourbundle.Cogito")
```

2. **Save tasks to shared storage**:
```swift
if let encoded = try? JSONEncoder().encode(task) {
    sharedDefaults?.set(encoded, forKey: "task_\(task.id)")
}
```

3. **Read from shared storage**:
```swift
if let data = sharedDefaults?.data(forKey: "task_\(taskId)"),
   let task = try? JSONDecoder().decode(Task.self, from: data) {
    // Use the task
}
```

## Next Steps

- Implement task selection UI for Complete Task shortcut
- Add more shortcut phrases for better Siri recognition
- Add shortcut suggestions in the app UI
- Implement deep linking to open specific tasks from shortcuts
- Add Siri suggestions based on user behavior
- Create custom intent UI for parameter input
- Add voice feedback for shortcut completion
