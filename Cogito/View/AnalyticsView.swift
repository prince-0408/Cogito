//
//  AnalyticsView.swift
//  Cogito
//
//  Created by Prince Yadav on 12/12/24.
//


import SwiftUI
import Charts

//struct AnalyticsView: View {
////    @ObservedObject var taskViewModel: TaskViewModel
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    // Task Completion Rate Chart
//                    Chart() { item in
//                        BarMark(
//                            x: .value("Status", item.status),
//                            y: .value("Count", item.count)
//                        )
//                        .foregroundStyle(item.status == "Completed" ? .green : .red)
//                    }
//                    .frame(height: 250)
//                    .padding()
//                    
//                    // Priority Distribution Chart
//                    Chart() { item in
//                        SectorMark(
//                            angle: .value("Count", item.count),
//                            innerRadius: .ratio(0.6),
//                            outerRadius: .ratio(1.0)
//                        )
//                        .foregroundStyle(by: .value("Priority", item.priority))
//                    }
//                    .frame(height: 250)
//                    .padding()
//                }
//            }
//            .navigationTitle("Analytics")
//        }
//    }
//}
