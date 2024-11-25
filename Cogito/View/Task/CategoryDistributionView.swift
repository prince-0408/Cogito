//
//  CategoryDistributionView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import SwiftUI

struct CategoryDistributionView: View {
    @ObservedObject var viewModel: TaskViewModel
    
    var categoryDistribution: [(String, Int)] {
        let categories = Array(Set(viewModel.tasks.flatMap { $0.categories }))
        return categories.map { category in
            (category, viewModel.tasks.filter { $0.categories.contains(category) }.count)
        }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Category Distribution")
                .font(.headline)
                .padding(.bottom)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 15) {
                    ForEach(categoryDistribution, id: \.0) { category, count in
                        VStack {
                            Text("\(count)")
                                .font(.caption)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: 30, height: CGFloat(count * 15 + 20))
                                .animation(.spring(), value: count)
                            
                            Text(category)
                                .font(.caption)
                                .rotationEffect(.degrees(-45))
                                .offset(y: 10)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
