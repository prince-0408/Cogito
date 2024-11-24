//
//  MainTabView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//
import SwiftUI

struct MainTabView: View {
    @StateObject var viewModel = TaskViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                SortableTaskListView(viewModel: viewModel)
                    .navigationTitle("Tasks")
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            
            NavigationView {
                DashboardView(viewModel: viewModel)
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
        }
    }
}

#Preview {
    MainTabView(viewModel: TaskViewModel())
}
