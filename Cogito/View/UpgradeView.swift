//
//  UpgradeView.swift
//  Cogito
//
//  Created by Prince Yadav on 12/12/24.
//


import SwiftUI

struct UpgradeView: View {
    var body: some View {
        VStack {
            Text("Upgrade to Pro")
                .font(.title)
            
            Text("Unlock additional features and boost your productivity!")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Upgrade") {
                // Implement upgrade logic
            }
            .buttonStyle(.borderedProminent)
        }
    }
}