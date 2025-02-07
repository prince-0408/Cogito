//
//  ProfileViewModel.swift
//  Cogito
//
//  Created by Prince Yadav on 12/12/24.
//


import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var isDarkModeEnabled = false
    @Published var selectedLanguage = "English"
    let languages = ["English", "Spanish", "French"]
    
    func logout() {
        // Implement logout logic
        print("Logging out...")
        // Clear user defaults, reset authentication state, etc.
    }
}