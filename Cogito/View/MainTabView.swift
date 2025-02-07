//
//  MainTabView.swift
//  Cogito
//
//  Created by Prince Yadav on 12/12/24.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Task Management Tab
//            TaskDashboardView(viewModel: taskViewModel)
//                .tabItem {
//                    Label("Tasks", systemImage: "checklist")
//                }
//                .tag(1)
            
            // AI Assistant Tab
            AIAssistantView()
                .tabItem {
                    Label("AI Assistant", systemImage: "brain")
                }
                .tag(2)
            
            // Analytics Tab
//            AnalyticsView()
//                .tabItem {
//                    Label("Analytics", systemImage: "chart.bar")
//                }
//                .tag(3)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(4)
        }
    }
}
