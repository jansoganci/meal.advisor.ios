//
//  EmailSignInView.swift
//  meal.advisor.ios
//
//  Email sign-in form component
//

import SwiftUI

struct EmailSignInView: View {
    @StateObject private var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showPasswordReset = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Sign In with Email")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your email and password to continue")
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
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
                
                // Sign in button
                Button {
                    Task {
                        do {
                            try await authService.signInWithEmail(email: email, password: password)
                        } catch {
                            // Error already handled in AuthService
                            print("Email sign-in failed: \(error)")
                        }
                    }
                } label: {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "envelope")
                        }
                        Text(authService.isLoading ? "Signing In..." : "Sign In")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                .opacity(authService.isLoading ? 0.7 : 1.0)
                .padding(.horizontal, 24)
                
                // Additional options
                VStack(spacing: 12) {
                    // Forgot password
                    Button("Forgot Password?") {
                        showPasswordReset = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    
                    // Sign up link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign Up") {
                            showSignUp = true
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
        .sheet(isPresented: $showSignUp) {
            EmailSignUpView()
        }
        .sheet(isPresented: $showPasswordReset) {
            PasswordResetView()
        }
        .onChange(of: authService.isAuthenticated) { isAuth in
            if isAuth {
                // Dismiss after successful sign-in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    EmailSignInView()
}

