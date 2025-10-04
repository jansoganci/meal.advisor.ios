//
//  EmailSignUpView.swift
//  meal.advisor.ios
//
//  Email sign-up form component
//

import SwiftUI

struct EmailSignUpView: View {
    @StateObject private var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showSignIn = false
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        password == confirmPassword &&
        password.count >= 6
    }
    
    private var passwordMatchError: String? {
        if !confirmPassword.isEmpty && password != confirmPassword {
            return "Passwords don't match"
        }
        return nil
    }
    
    private var passwordLengthError: String? {
        if !password.isEmpty && password.count < 6 {
            return "Password must be at least 6 characters"
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Create Account")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Sign up with your email to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        SecureField("Create a password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = passwordLengthError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirm password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = passwordMatchError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Error message
                if let errorMessage = authService.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Sign up button
                Button {
                    Task {
                        do {
                            try await authService.signUpWithEmail(email: email, password: password)
                        } catch {
                            // Error already handled in AuthService
                            print("Email sign-up failed: \(error)")
                        }
                    }
                } label: {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "person.badge.plus")
                        }
                        Text(authService.isLoading ? "Creating Account..." : "Create Account")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: isFormValid ? [.green, .green.opacity(0.8)] : [.gray, .gray.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(authService.isLoading || !isFormValid)
                .opacity(authService.isLoading ? 0.7 : 1.0)
                .padding(.horizontal, 24)
                
                // Additional options
                VStack(spacing: 12) {
                    // Sign in link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign In") {
                            showSignIn = true
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
        .sheet(isPresented: $showSignIn) {
            EmailSignInView()
        }
        .onChange(of: authService.isAuthenticated) { isAuth in
            if isAuth {
                // Dismiss after successful sign-up
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    EmailSignUpView()
}

