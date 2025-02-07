//
//  LaunchScreenView.swift
//  Cogito
//
//  Created by Prince Yadav on 29/11/24.
//


import SwiftUI

struct LaunchScreenView: View {
    @State private var navigateToOnboarding = true
    @State private var animationProgress: CGFloat = 0
    @State private var logoScale: CGFloat = 1.0
    @State private var logoRotation: Double = 0
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: backgroundGradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animationProgress)
                
                // Blurred Background Elements.
                backgroundElements(in: geometry)
                
                // Full Screen Content
                VStack(spacing: geometry.size.height * 0.05) {
                    Spacer()
                    
                    // Animated Brain Icon with Pulsing and Rotation
                    brainIcon(in: geometry)
                    
                    // App Title with Subtle Animation
                    appTitle
                    
                    // Subtitle
                    subtitleText
                    
                    Spacer()
                    
                    // Loading Indicator with Custom Style
                    loadingIndicator
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(fullScreenBackground)
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            // Start animations
            animationProgress = 1.0
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                logoScale = 1.1
                logoRotation = 10
            }
            
            // Redirect to onboarding after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                navigateToOnboarding = true
            }
        }
        .background(
            NavigationLink(
                destination: OnboardingView()
                    .navigationBarHidden(true), // Optional: Hide navigation bar
                isActive: $navigateToOnboarding
            ) {
                EmptyView()
            }
        )
    }
    
    // Dynamic Gradient Colors
    private var backgroundGradientColors: [Color] {
        colorScheme == .dark ? [
            Color.blue.opacity(0.6),
            Color.purple.opacity(0.6),
            Color.blue.opacity(0.6)
        ] : [
            Color(hex: "667eea").opacity(0.7),
            Color(hex: "764ba2").opacity(0.7),
            Color(hex: "667eea").opacity(0.7)
        ]
    }
    
    // Brain Icon with Responsive Sizing and Animation
    private func brainIcon(in geometry: GeometryProxy) -> some View {
        Image(systemName: "brain")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(iconColor)
            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
            .shadow(color: shadowColor.opacity(0.5), radius: 20)
            .scaleEffect(logoScale)
            .rotationEffect(Angle(degrees: logoRotation))
    }
    
    // Dynamic Icon Color
    private var iconColor: Color {
        .white
    }
    
    // Dynamic Shadow Color
    private var shadowColor: Color {
        colorScheme == .dark ? Color.blue : Color(hex: "5f63ff")
    }
    
    // Animated App Title with Responsive Sizing
    private var appTitle: some View {
        Text("Cogito")
            .font(.system(size: UIScreen.main.bounds.width * 0.15, weight: .bold))
            .foregroundColor(.white)
            .shadow(color: shadowColor.opacity(0.5), radius: 10)
    }
    
    // Subtitle Text with Responsive Sizing
    private var subtitleText: some View {
        Text("Intelligent Task Management")
            .font(.system(size: UIScreen.main.bounds.width * 0.05))
            .foregroundColor(subtitleColor)
            .shadow(color: Color.black.opacity(0.2), radius: 5)
    }
    
    // Dynamic Subtitle Color
    private var subtitleColor: Color {
        .white.opacity(0.8)
    }
    
    // Enhanced Loading Indicator
    private var loadingIndicator: some View {
        VStack {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(
                        tint: .white.opacity(0.8)
                    )
                )
                .scaleEffect(1.5)
            
            Text("Preparing your workspace")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 10)
        }
        .padding()
    }
    
    // Full Screen Background
    private var fullScreenBackground: some View {
        Color.clear
            .background(
                Color.white
                    .opacity(colorScheme == .dark ? 0.1 : 0.2)
                    .blur(radius: 10)
            )
    }
    
    // Background Elements with Floating Circles
    private func backgroundElements(in geometry: GeometryProxy) -> some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: backgroundCircleColors1),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.2)
                .blur(radius: 50)
                .animation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                    .delay(0.5),
                    value: animationProgress
                )
            
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: backgroundCircleColors2),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.8)
                .blur(radius: 50)
                .animation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                    .delay(1),
                    value: animationProgress
                )
        }
    }
    
    // Dynamic Background Circle Colors
    private var backgroundCircleColors1: [Color] {
        colorScheme == .dark ? [
            Color.purple.opacity(0.3),
            Color.blue.opacity(0.3)
        ] : [
            Color(hex: "8E2DE2").opacity(0.3),
            Color(hex: "4A00E0").opacity(0.3)
        ]
    }
    
    // Dynamic Background Circle Colors
    private var backgroundCircleColors2: [Color] {
        colorScheme == .dark ? [
            Color.pink.opacity(0.3),
            Color.orange.opacity(0.3)
        ] : [
            Color(hex: "FF6A88").opacity(0.3),
            Color(hex: "FF6A88").opacity(0.3)
        ]
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default preview
            LaunchScreenView()
                .previewDisplayName("Launch Screen")
            
            // Dark mode preview
            LaunchScreenView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Launch Screen - Dark Mode")
        }
    }
}
