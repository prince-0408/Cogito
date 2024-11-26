//
//  SignUpView.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//
import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
//    @StateObject private var userAuth = UserAuth()
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var confirmPassword = ""
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
//                if !userAuth.errorMessage.isEmpty {
//                    Section {
//                        Text(userAuth.errorMessage)
//                            .foregroundColor(.red)
//                    }
                }
                
                Section {
//                    Button(action: {
//                        if password == confirmPassword {
//                            userAuth.signUp(email: email, password: password, username: username)
//                        }
//                    })
                    {
                        Text("Create Account")
                    }()
                    .disabled(password != confirmPassword || password.isEmpty || email.isEmpty || username.isEmpty)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
