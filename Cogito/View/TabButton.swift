//
//  TabButton.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//
import SwiftUI
import CloudKit

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .matchedGeometryEffect(id: "TAB", in: namespace)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

//#Preview {
//    TabButton(title: String(), isSelected: Bool(), namespace: ID, action: () -> voidprint("Hello, World!"))
//}
