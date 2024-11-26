//
//  PriorityDistributionChart.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//
import SwiftUI

struct PriorityDistributionChart: View {
    @ObservedObject var viewModel: TaskViewModel
    
    var priorityDistribution: [(Task.Priority, Int)] {
        let priorities = [Task.Priority.low, .medium, .high]
        return priorities.map { priority in
            (priority, viewModel.tasks.filter { $0.priority == priority }.count)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Priority Distribution")
                .font(.headline)
                .padding(.bottom)
            
            HStack(alignment: .bottom, spacing: 20) {
                ForEach(priorityDistribution, id: \.0) { priority, count in
                    VStack {
                        Text("\(count)")
                            .font(.caption)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(priorityColor(priority))
                            .frame(width: 40, height: CGFloat(count * 20 + 20))
                            .animation(.spring(), value: count)
                        
                        Text(priority.rawValue.capitalized)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    func priorityColor(_ priority: Task.Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    PriorityDistributionChart(viewModel: TaskViewModel())
}
