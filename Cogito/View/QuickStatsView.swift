//
//  QuickStatsView.swift
//  Cogito
//
//  Created by Prince Yadav on 12/12/24.
//

import SwiftUI
// Supporting Views for Home Screen
//struct QuickStatsView: View {
////    @ObservedObject var taskViewModel: TaskViewModel
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            StatCard(
//                title: "Total Tasks",
//                value: "\(taskViewModel.tasks.count)",
//                color: .blue
//            )
//            
//            StatCard(
//                title: "Completed",
//                value: "\(taskViewModel.tasks.filter { $0.isCompleted }.count)",
//                color: .green
//            )
//            
//            StatCard(
//                title: "Pending",
//                value: "\(taskViewModel.tasks.filter { !$0.isCompleted }.count)",
//                color: .orange
//            )
//        }
//        .padding(.horizontal)
//    }
//}
//
//struct StatCard: View {
//    let title: String
//    let value: String
//    let color: Color
//    
//    var body: some View {
//        VStack {
//            Text(value)
//                .font(.title2)
//                .fontWeight(.bold)
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(color.opacity(0.1))
//        .cornerRadius(12)
//    }
//}
