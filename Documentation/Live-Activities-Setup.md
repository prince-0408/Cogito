# Live Activities Setup Instructions

The Live Activity files have been created in the `LiveActivities` folder. Live Activities display real-time task countdowns on the Dynamic Island and Lock Screen.

## Steps to Enable Live Activities

1. **Add Widget Extension Target** (if not already added)
   - Live Activities require a Widget Extension target
   - Follow the Widget Extension setup instructions in `Widgets/README.md`
   - The Live Activity widget will be part of the same extension

2. **Add Live Activity Widget to Widget Extension**
   - In your Widget Extension target (CogitoWidgets), add the following files:
     - TaskActivityAttributes.swift
     - TaskActivityWidget.swift
     - LiveActivityManager.swift
   - Make sure these files are added to the Widget Extension target

3. **Update Widget Bundle**
   - In your Widget Extension's main file (e.g., TaskWidget.swift), update the bundle to include the Live Activity widget:
   ```swift
   @main
   struct TaskWidgetBundle: WidgetBundle {
       var body: some Widget {
           TaskWidget()
           TaskWidgetSmall()
           TaskActivityWidget() // Add this line
       }
   }
   ```

4. **Enable Live Activities in Info.plist**
   - In your main app's Info.plist, add:
   ```xml
   <key>NSSupportsLiveActivities</key>
   <true/>
   <key>NSSupportsLiveActivitiesFrequentUpdates</key>
   <true/>
   ```

5. **Update Deployment Target**
   - Set the minimum deployment target to iOS 16.1 or later for Live Activities support
   - Both main app and Widget Extension should have this target

6. **Test Live Activities**
   - Build and run the app on an iPhone 14 Pro or later (for Dynamic Island)
   - Create a new task with a due date
   - The Live Activity should appear in the Dynamic Island and Lock Screen
   - Complete the task to see the Live Activity update and dismiss

## Live Activity Features

### Dynamic Island
- **Compact**: Shows category icon and time remaining
- **Minimal**: Shows completion status
- **Expanded**: Shows full task details, time remaining, and complete button

### Lock Screen
- Shows task title, category, due time, and countdown
- Beautiful gradient background
- Tappable to open the task in the app

### Automatic Updates
- Starts when a task is created
- Updates in real-time with countdown
- Shows completion status when marked done
- Automatically dismisses after completion
- Ends when task is deleted

## Customization

### Modify Appearance
Edit `TaskActivityWidget.swift` to customize:
- Colors and gradients
- Layout and spacing
- Icons and text
- Animation behavior

### Change Behavior
Edit `LiveActivityManager.swift` to:
- Change when activities start/end
- Modify update frequency
- Add custom actions
- Implement push notifications for updates

## Deep Linking

Live Activities support deep linking to open specific tasks:
```swift
.widgetURL(URL(string: "cogito://task/\(context.attributes.taskId)"))
```

To handle deep links, add URL scheme support in your app:
1. In Info.plist, add URL Types
2. Handle URL in SceneDelegate or App struct:
```swift
.onOpenURL { url in
    if url.scheme == "cogito" {
        // Parse task ID and open task detail
    }
}
```

## Best Practices

1. **Limit Active Activities**: Only show Live Activities for urgent or high-priority tasks
2. **Battery Efficiency**: Update activities efficiently to preserve battery
3. **User Control**: Allow users to disable Live Activities in settings
4. **Relevance**: End activities promptly when no longer relevant
5. **Testing**: Test on both Dynamic Island and Lock Screen

## Troubleshooting

### Live Activity not appearing
- Check that NSSupportsLiveActivities is enabled in Info.plist
- Verify deployment target is iOS 16.1+
- Ensure Widget Extension is properly configured
- Check that ActivityAuthorizationInfo returns true

### Updates not working
- Verify updateTask is called with correct task ID
- Check that timeRemaining is calculated correctly
- Ensure Activity objects are not being deallocated

### Build errors
- Make sure all Live Activity files are added to Widget Extension target
- Verify iOS deployment target matches across all targets
- Check that ActivityKit is imported in all necessary files

## Next Steps

- Add user settings to enable/disable Live Activities
- Implement push notifications for remote updates
- Add custom actions in expanded Dynamic Island
- Create different Live Activity layouts for different task types
- Add haptic feedback when tapping Live Activity
- Implement Live Activity grouping for multiple tasks
