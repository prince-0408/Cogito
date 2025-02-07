//
//  LoginViewModel.swift
//  Cogito
//
//  Created by Prince Yadav on 08/12/24.
//
import SwiftUI


class LoginViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var otp = "" // Add this line
    
    func signInWithApple() {
        // Implement Apple sign-in logic
    }
    
    func signInWithGoogle() {
        // Implement Google sign-in logic
    }
    
    func requestOTP() {
        // Implement OTP request logic
    }
    
    func verifyOTP() {
        // Implement OTP verification logic
        print("Verifying OTP: \(otp)")
        // Add your authentication logic here
    }
}
