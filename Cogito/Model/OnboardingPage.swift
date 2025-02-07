//
//  OnboardingPage.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI
import Combine

// MARK: - Model
struct OnboardingPageModel: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let iconName: String
    let backgroundColor: Color
}
