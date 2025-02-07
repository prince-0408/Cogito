//
//  HomeView.swift
//  Cogito
//
//  Created by Prince Yadav on 09/12/24.
//

import SwiftUI

struct HomeView: View {
//    @ObservedObject var taskViewModel: TaskViewModel
//    @State private var upcomingTasks: [Task] = []
    @State private var welcomeMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome Section
                    HStack {
                        VStack(alignment: .leading) {
                            Text(welcomeMessage)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Let's make today productive!")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    // Quick Stats
//                    QuickStatsView()
                    
                    // Upcoming Tasks
//                    UpcomingTasksSection()
                    
                    // AI Suggestions
                    AIProductivitySuggestionView()
                }
            }
            .navigationTitle("Cogito")
            .onAppear {
                updateWelcomeMessage()
//                fetchUpcomingTasks()
            }
        }
    }
    
    private func updateWelcomeMessage() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            welcomeMessage = "Good Morning!"
        case 12..<17:
            welcomeMessage = "Good Afternoon!"
        case 17..<22:
            welcomeMessage = "Good Evening!"
        default:
            welcomeMessage = "Welcome!"
        }
    }
    
//    private func fetchUpcomingTasks() {
//        upcomingTasks = taskViewModel.tasks
//            .filter { !$0.isCompleted }
//            .sorted { $0.dueDate < $1.dueDate }
//            .prefix(3)
//            .map { $0 }
//    }
}




