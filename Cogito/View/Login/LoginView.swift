//
//  LoginView.swift
//  Cogito
//
//  Created by Prince Yadav on 08/12/24.
//


import SwiftUI
import CoreGraphics


struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isOTPViewPresented = false
    @State private var animationProgress: Double = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark
                    ? [Color.black, Color.purple.opacity(0.7), Color.black]
                    : [Color.white, Color.blue.opacity(0.2), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Blurred Background Elements
            backgroundElements

            // Main Content
            VStack(spacing: 20) {
                headerSection
                socialLoginButtons
                dividerSection
                phoneLoginSection
            }
            .padding()
            .background(glassMorphicBackground)
            .cornerRadius(20)
            .padding()
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .scaleEffect(1 + (animationProgress * 0.05))
            .opacity(1 - (animationProgress * 0.2))
            .rotation3DEffect(
                .degrees(animationProgress * 10),
                axis: (x: 1.0, y: 0.0, z: 0.0)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: true)) {
                    animationProgress = 0.15
                }
            }
        }
    }

    // Header Section
    private var headerSection: some View {
        VStack {
            Image("cogito_logo") // Replace with your app logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .cornerRadius(20)
                .shadow(radius: 10)

            Text("Welcome to Cogito")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .padding()
    }

    // Social Login Buttons
    private var socialLoginButtons: some View {
        VStack(spacing: 15) {
            socialLoginButton(
                icon: "applelogo",
                title: "Sign in with Apple",
                backgroundColor: colorScheme == .dark ? .white.opacity(0.2) : .black,
                textColor: colorScheme == .dark ? .white : .white,
                action: viewModel.signInWithApple
            )

            socialLoginButton(
                icon: "google_logo",
                title: "Sign in with Google",
                backgroundColor: .red,
                textColor: .white,
                action: viewModel.signInWithGoogle
            )
        }
    }

    // Social Login Button Helper
    private func socialLoginButton(
        icon: String,
        title: String,
        backgroundColor: Color,
        textColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(10)
        }
    }

    // Divider Section
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 1)
            
            Text("OR")
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 1)
        }
        .padding(.vertical)
    }

    // Phone Login Section
    private var phoneLoginSection: some View {
        VStack(spacing: 15) {
            TextField("Phone Number", text: $viewModel.phoneNumber)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .keyboardType(.phonePad)
                .foregroundColor(colorScheme == .dark ? .white : .black)

            Button(action: {
                viewModel.requestOTP()
                isOTPViewPresented = true
            }) {
                Text("Request OTP")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    // Glassmorphic Background
    private var glassMorphicBackground: some View {
        Color.white
            .opacity(colorScheme == .dark ? 0.1 : 0.7)
            .background(
                Color.white
                    .opacity(colorScheme == .dark ? 0.05 : 0.5)
                    .blur(radius: 10)
            )
    }

    // Background Elements
    private var backgroundElements: some View {
        GeometryReader { geometry in
            ZStack {
                // Floating Circles
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.3),
                            Color.blue.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.2)
                    .blur(radius: 50)

                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.pink.opacity(0.3),
                            Color.orange.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 150, height: 150)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.8)
                    .blur(radius: 50)
            }
        }
        .ignoresSafeArea()
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .preferredColorScheme(.light)
            
            LoginView()
                .preferredColorScheme(.dark)
        }
    }
}
