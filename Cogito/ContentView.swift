//
//  ContentView.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var promptText = ""
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // AI Prompt Input
                    HStack {
                        TextField("Enter task prompt...", text: $promptText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button(action: {
//                            Task {
//                                await viewModel.generateTask(from: promptText)
//                                promptText = "hi"
//                            }
                        }) {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(promptText.isEmpty)
                        .padding(.trailing)
                    }
                    
                    // Task List
                    List {
                        ForEach(viewModel.tasks) { task in
                            TaskRowView(task: task) {
                                viewModel.toggleTaskCompletion(task)
                            }
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .background(Color.white.opacity(0.8))
                }
            }
            .navigationTitle("Cogito 🧠")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                        
                        NavigationView {
                            Enhanced3DTaskListView(viewModel: viewModel)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
