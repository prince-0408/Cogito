//
//  ProfileView.swift
//  Cogito
//
//  Created by Prince Yadav on 09/12/24.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                // User Profile Section
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $viewModel.name)
                    TextField("Email", text: $viewModel.email)
                }
                
                // App Settings
                Section(header: Text("App Settings")) {
                    Toggle("Dark Mode", isOn: $viewModel.isDarkModeEnabled)
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.languages, id: \.self) { language in
                            Text(language)
                        }
                    }
                }
                
                // Subscription and Account
                Section {
                    NavigationLink("Upgrade to Pro", destination: UpgradeView())
                    Button("Logout") {
                        viewModel.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
