//
//  OTPView.swift
//  Cogito
//
//  Created by Prince Yadav on 08/12/24.
//

import SwiftUI

struct OTPView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var animationProgress: Double = 0.0
    @State private var shakeOffset: CGFloat = 0
    @FocusState private var isOTPFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Gradient (Matching LoginView)
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark
                        ? [Color.black, Color.purple.opacity(0.7), Color.black]
                        : [Color.white, Color.blue.opacity(0.2), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Blurred Background Elements (Similar to LoginView)
                backgroundElements

                // Main Content
                mainContentView
            }
            .ignoresSafeArea()
        }
    }
    
    // Background Elements (Matching LoginView)
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
    
    // Main Content View (Rest of the existing implementation remains the same)
    private var mainContentView: some View {
        VStack(spacing: 20) {
            // Header Section
            headerSection
            
            // OTP Input Section
            otpInputSection
            
            // Verify Button
            verifyButton
            
            // Resend OTP
            resendOTPSection
        }
        .padding()
        .background(glassMorphicBackground)
        .cornerRadius(25)
        .padding()
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
        .offset(x: shakeOffset)
        .animation(.spring(), value: shakeOffset)
        .scaleEffect(1 + (animationProgress * 0.05))
        .opacity(1 - (animationProgress * 0.2))
        .onAppear(perform: startAnimation)
    }
    
    // Header Section
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .shadow(color: .blue.opacity(0.5), radius: 10)
            
            Text("Verify OTP")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Enter the 6-digit code sent to \(viewModel.phoneNumber)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // OTP Input Section
    private var otpInputSection: some View {
        HStack(spacing: 15) {
            ForEach(0..<6, id: \.self) { index in
                otpTextField(for: index)
            }
        }
        .padding()
    }

    // OTP Text Field
    private func otpTextField(for index: Int) -> some View {
        TextField("", text: Binding(
            get: {
                index < viewModel.otp.count ?
                String(viewModel.otp[viewModel.otp.index(viewModel.otp.startIndex, offsetBy: index)]) :
                ""
            },
            set: { newValue in
                if newValue.count == 1 {
                    if viewModel.otp.count < 6 {
                        viewModel.otp += newValue
                    }
                }
            }
        ))
        .frame(width: 40, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
        )
        .multilineTextAlignment(.center)
        .keyboardType(.numberPad)
        .focused($isOTPFocused)
    }
    
    private var verifyButton: some View {
        Button(action: {
            if viewModel.otp.count == 6 {
                viewModel.verifyOTP()
            } else {
                // Shake animation for invalid OTP
                withAnimation(.default) {
                    shakeOffset = -20
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        shakeOffset = 20
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            shakeOffset = 0
                        }
                    }
                }
            }
        }) {
            Text("Verify OTP")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(viewModel.otp.count < 6)
        .opacity(viewModel.otp.count == 6 ? 1.0 : 0.5)
    }
    
    private var resendOTPSection: some View {
        HStack {
            Text("Didn't receive the code?")
                .foregroundColor(.secondary)
            
            Button("Resend OTP") {
                viewModel.requestOTP()
            }
            .foregroundColor(.blue)
        }
    }
    
    // Glassmorphic Background (Existing implementation)
    private var glassMorphicBackground: some View {
        ZStack {
            // Base background with adaptive opacity
            Color(colorScheme == .dark ? .black : .white)
                .opacity(colorScheme == .dark ? 0.2 : 0.3)
            
            // Blurred overlay with adaptive opacity
            Color(colorScheme == .dark ? .gray : .white)
                .opacity(colorScheme == .dark ? 0.1 : 0.4)
                .blur(radius: 10)
            
            // Material effect with adaptive background
            Rectangle()
                .fill(colorScheme == .dark ?
                      Color.gray.opacity(0.2) :
                        Color.white.opacity(0.5)
                )
                .background(
                    colorScheme == .dark ?
                        .ultraThinMaterial :
                            .regularMaterial
                )
        }
        .cornerRadius(15)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 10)
    }
    
    // Background Animated Elements
    private func backgroundAnimation(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Floating Circles
            animatedCircle(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                width: 200,
                height: 200,
                x: geometry.size.width * 0.2,
                y: geometry.size.height * 0.2,
                duration: 3
            )
            
            animatedCircle(
                colors: [Color.pink.opacity(0.3), Color.orange.opacity(0.3)],
                width: 150,
                height: 150,
                x: geometry.size.width * 0.8,
                y: geometry.size.height * 0.8,
                duration: 4
            )
        }
    }
    
    // Animated Circle Helper
    private func animatedCircle(
        colors: [Color],
        width: CGFloat,
        height: CGFloat,
        x: CGFloat,
        y: CGFloat,
        duration: Double
    ) -> some View {
        Circle()
            .fill(LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(width: width, height: height)
            .position(x: x, y: y)
            .blur(radius: 50)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true), value: x)
    }
    
    // Animation Methods
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.8)
            .repeatForever(autoreverses: true)) {
                animationProgress = 0.15
            }
    }
    
}

// Preview
struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OTPView(viewModel: LoginViewModel())
            .preferredColorScheme(.dark)
        
        OTPView(viewModel: LoginViewModel())
            .preferredColorScheme(.light)
        
    }
}
