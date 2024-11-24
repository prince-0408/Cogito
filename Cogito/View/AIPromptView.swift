//
//  AIPromptView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//
import SwiftUI

struct AIPromptView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var promptText = ""
    @State private var isShowingPromptHistory = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Enter task prompt...", text: $promptText)
                    .textFieldStyle(CustomTextFieldStyle())
                    .submitLabel(.done)
                
                Button(action: {
//                    Task {
//                        await viewModel.generateTask(from: promptText)
//                        promptText = ""
//                    }
                }) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            promptText.isEmpty ? Color.gray : Color.blue
                        )
                        .cornerRadius(22)
                        .shadow(radius: 3)
                }
                .disabled(promptText.isEmpty)
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Generating task...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}
