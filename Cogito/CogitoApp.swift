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
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TaskCreatedFromSiri"))) { notification in
                        // Handle task created from Siri
                        if let task = notification.object as? Task {
                            taskViewModel.addTask(task)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CompleteTaskFromSiri"))) { _ in
                        // Handle task completion from Siri
                        // In a real implementation, this would show a task selection UI
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
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad layout with sidebar
            NavigationSplitView {
                SidebarView(selectedTab: $selectedTab)
            } detail: {
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
                .navigationSplitViewColumnWidth(min: 300, ideal: 400)
            }
        } else {
            // iPhone layout with tab bar
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                HeatmapCalendarView(taskViewModel: TaskViewModel())
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Heatmap")
                    }
                    .tag(1)
                
                InsightsView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Insights")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag(3)
            }
        }
    }
}

struct SidebarView: View {
    @Binding var selectedTab: Int
    
    private var selectionBinding: Binding<Int?> {
        Binding<Int?>(
            get: { selectedTab },
            set: { if let newValue = $0 { selectedTab = newValue } }
        )
    }
    
    var body: some View {
        List(selection: selectionBinding) {
            Label("Home", systemImage: "house.fill")
                .tag(0)
            
            Label("Heatmap", systemImage: "calendar")
                .tag(1)
            
            Label("Insights", systemImage: "chart.bar.fill")
                .tag(2)
            
            Label("Settings", systemImage: "gearshape.fill")
                .tag(3)
        }
        .navigationTitle("Cogito")
        .listStyle(.sidebar)
    }
}
