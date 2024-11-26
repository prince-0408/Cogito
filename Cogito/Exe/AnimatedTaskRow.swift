//
//  AnimatedTaskRow.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import SwiftUI

struct AnimatedTaskRow: View {
    let task: Task
    let onToggle: () -> Void
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        TaskRowView(task: task, onToggle: onToggle, viewModel: TaskViewModel())
            .offset(x: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    offset = 0
                    opacity = 1
                }
            }
            .onDisappear {
                withAnimation(.easeOut(duration: 0.2)) {
                    offset = -50
                    opacity = 0
                }
            }
    }
}
