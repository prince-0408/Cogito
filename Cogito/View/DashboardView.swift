//
//  DashboardView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//


import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedTimeFrame: TimeFrame = .week
    
    enum TimeFrame {
        case day, week, month
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Frame Selector
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    Text("Day").tag(TimeFrame.day)
                    Text("Week").tag(TimeFrame.week)
                    Text("Month").tag(TimeFrame.month)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Statistics Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Completion Rate",
                        value: viewModel.completionRate(for: selectedTimeFrame),
                        format: "%.1f%%",
                        icon: "chart.pie.fill",
                        color: .blue
                    )
                    .transition(.scale.combined(with: .opacity))
                    
                    StatCard(
                        title: "Tasks Created",
                        value: Double(viewModel.tasksCreated(for: selectedTimeFrame)),
                        format: "%.0f",
                        icon: "plus.circle.fill",
                        color: .green
                    )
                    .transition(.scale.combined(with: .opacity))
                    
                    StatCard(
                        title: "AI Generated",
                        value: Double(viewModel.aiGeneratedTasks(for: selectedTimeFrame)),
                        format: "%.0f",
                        icon: "wand.and.stars",
                        color: .purple
                    )
                    .transition(.scale.combined(with: .opacity))
                    
                    StatCard(
                        title: "Overdue",
                        value: Double(viewModel.overdueTasks()),
                        format: "%.0f",
                        icon: "exclamationmark.circle.fill",
                        color: .red
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                .padding()
                
                // Priority Distribution
                PriorityDistributionChart(viewModel: viewModel)
                    .frame(height: 200)
                    .padding()
                
                // Category Distribution
                CategoryDistributionView(viewModel: viewModel)
                    .frame(height: 200)
                    .padding()
            }
        }
        .navigationTitle("Dashboard")
    }
}