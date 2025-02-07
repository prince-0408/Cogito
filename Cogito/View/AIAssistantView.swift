//
//  AIAssistantView.swift
//  Cogito
//
//  Created by Prince Yadav on 12/12/24.
//


import SwiftUI

struct AIAssistantView: View {
    @State private var userMessage = ""
    @State private var messages: [AIMessage] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Messages list
                ScrollView {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                
                // Input area
                HStack {
                    TextField("Ask AI Assistant", text: $userMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .padding()
            }
            .navigationTitle("AI Assistant")
        }
    }
    
    private func sendMessage() {
        guard !userMessage.isEmpty else { return }
        
        // Add user message
        let userAIMessage = AIMessage(
            content: userMessage,
            sender: .user
        )
        messages.append(userAIMessage)
        
        // Simulate AI response
        let aiResponse = AIMessage(
            content: "I'm processing your request...",
            sender: .ai
        )
        messages.append(aiResponse)
        
        // Clear input
        userMessage = ""
    }
}

struct AIMessage: Identifiable {
    let id = UUID()
    let content: String
    let sender: Sender
    
    enum Sender {
        case user
        case ai
    }
}

struct MessageBubble: View {
    let message: AIMessage
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}