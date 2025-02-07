//
//  TabTransition.swift
//  Cogito
//
//  Created by Prince Yadav on 27/11/24.
//

import SwiftUI

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
