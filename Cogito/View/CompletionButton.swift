//
//  CompletionButton.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import SwiftUI
struct CompletionButton: View {
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                action()
            }
        }) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.clear)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .stroke(isCompleted ? Color.green : Color.gray, lineWidth: 2)
                    .frame(width: 30, height: 30)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                }
            }
        }
    }
}
