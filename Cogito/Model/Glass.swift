//
//  Glass.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI
// Glass.swift - Creates a glass morphism effect
struct Glass: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .blur(radius: 10)
            .opacity(0.9)
    }
}
