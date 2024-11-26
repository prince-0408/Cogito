//
//  GlassmorphicBackground.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI

struct GlassmorphicBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.5),
                        Color.white.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct TabTransition: ViewModifier {
    let position: CGFloat
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(position * 30),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(1 - abs(position) * 0.5)
            .offset(x: position * 100)
    }
}
