//
//  LoginView.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//
import SwiftUI

struct LoginView: View {
//    @StateObject private var userAuth = UserAuth()
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
//                    .foregroundColor(themeManager.currentTheme.primaryColor)
                
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .bold()
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
//                if !userAuth.errorMessage.isEmpty {
//                    Text(userAuth.errorMessage)
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
                
//                Button(action: {
//                    userAuth.signIn(email: email, password: password)
//                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
//                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button("Create Account") {
                    showingSignUp = true
                }
//                .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .padding()
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
        }
    }
//}
