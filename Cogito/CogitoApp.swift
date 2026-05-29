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
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var tutorialManager = TutorialManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    init() {
        // Register custom fonts dynamically from Assets catalog
        FontLoader.registerFonts()
        
        // Setup dependencies
        let (taskVM, aiVM) = setupDependencies()
        
        // Pre-assign the StateObjects
        _taskViewModel = StateObject(wrappedValue: taskVM)
        _aiViewModel = StateObject(wrappedValue: aiVM)
        _themeManager = StateObject(wrappedValue: ThemeManager())
        _tutorialManager = StateObject(wrappedValue: TutorialManager())
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(taskViewModel)
                    .environmentObject(aiViewModel)
                    .environmentObject(themeManager)
                    .environmentObject(tutorialManager)
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                    .accentColor(themeManager.currentTheme.color)
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
                    .environmentObject(themeManager)
                    .environmentObject(tutorialManager)
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                    .accentColor(themeManager.currentTheme.color)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var aiViewModel: AIViewModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad layout with sidebar
                NavigationSplitView {
                    SidebarView(selectedTab: $selectedTab)
                } detail: {
                    switch selectedTab {
                    case 0:
                        HomeView()
                    case 1:
                        HeatmapCalendarView(taskViewModel: taskViewModel)
                    case 2:
                        InsightsView()
                    case 3:
                        SettingsView()
                    default:
                        HomeView()
                    }
                }
            } else {
                // iPhone layout with standard native system tab bar
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    HeatmapCalendarView(taskViewModel: taskViewModel)
                        .tabItem {
                            Label("Heatmap", systemImage: "calendar")
                        }
                        .tag(1)
                    
                    InsightsView()
                        .tabItem {
                            Label("Insights", systemImage: "chart.bar.fill")
                        }
                        .tag(2)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(3)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToHomeTab"))) { _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                selectedTab = 0
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
