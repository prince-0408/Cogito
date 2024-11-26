//
//  MainTabView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//
import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var taskViewModel = TaskViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(Tab.home)
                
                CalendarView(viewModel: TaskViewModel())
                    .tag(Tab.calendar)
                
//                AddTaskView()
//                    .tag(Tab.add)
                
                StatsView()
                    .tag(Tab.stats)
                
                ProfileView()
                    .tag(Tab.profile)
            }
            
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal)
                .padding(.bottom, getSafeArea().bottom == 0 ? 20 : 0)
        }
        .ignoresSafeArea(.keyboard)
    }
}
