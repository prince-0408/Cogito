//
//  ViewTransitions.swift
//  Cogito
//
//  Created by Prince Yadav on 24/11/24.
//

import SwiftUI

extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .slide.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
    }
}
