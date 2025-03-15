//
//  CogitoApp.swift
//  Cogito
//
//  Created by Prince Yadav on 04/03/25.
//

import SwiftUI

@main
struct CogitoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var aiViewModel = AIViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("appTheme") private var appTheme: String = "blue"
    
    init() {
        // Setup dependencies
        let (taskVM, aiVM) = setupDependencies()
        
        // Pre-assign the StateObjects
        _taskViewModel = StateObject(wrappedValue: taskVM)
        _aiViewModel = StateObject(wrappedValue: aiVM)
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(taskViewModel)
                    .environmentObject(aiViewModel)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .accentColor(getThemeColor())
                    .onAppear {
                        // Request notification permissions when app launches
                        NotificationManager.shared.requestAuthorization { _ in }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenTaskDetail"))) { notification in
                        if let taskId = notification.userInfo?["taskId"] as? UUID {
                            // Handle opening task detail
                            if let task = taskViewModel.tasks.first(where: { $0.id == taskId }) {
                                // Logic to open task detail would go here
                                print("Opening task: \(task.title)")
                            }
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CompleteTask"))) { notification in
                        if let taskId = notification.userInfo?["taskId"] as? UUID {
                            // Handle completing task
                            if let task = taskViewModel.tasks.first(where: { $0.id == taskId }) {
                                taskViewModel.markTaskAsCompleted(task)
                            }
                        }
                    }
            } else {
                OnboardingView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .accentColor(getThemeColor())
            }
        }
    }
    
    func getThemeColor() -> Color {
        switch appTheme {
        case "blue":
            return .blue
        case "green":
            return .green
        case "purple":
            return .purple
        case "orange":
            return .orange
        default:
            return .blue
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var aiViewModel: AIViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                HeatmapCalendarView(taskViewModel: TaskViewModel())
                    .tag(1)
                
                InsightsView()
                    .tag(2)
                
                SettingsView()
                    .tag(3)
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom) // Ensures tab bar floats nicely
    }
}
