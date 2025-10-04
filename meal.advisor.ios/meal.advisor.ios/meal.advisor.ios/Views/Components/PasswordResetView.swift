//
//  PasswordResetView.swift
//  meal.advisor.ios
//
//  Password reset form component
//

import SwiftUI

struct PasswordResetView: View {
    @StateObject private var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var isEmailSent = false
    @State private var showSignIn = false
    
    private var isEmailValid: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: isEmailSent ? "checkmark.circle.fill" : "key.horizontal")
                        .font(.system(size: 60))
                        .foregroundColor(isEmailSent ? .green : .orange)
                    
                    Text(isEmailSent ? "Email Sent!" : "Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isEmailSent ? 
                         "Check your email for password reset instructions" : 
                         "Enter your email to receive reset instructions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                if !isEmailSent {
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
                    
                    // Send reset email button
                    Button {
                        Task {
                            do {
                                try await authService.resetPassword(email: email)
                                isEmailSent = true
                            } catch {
                                // Error already handled in AuthService
                                print("Password reset failed: \(error)")
                            }
                        }
                    } label: {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "paperplane")
                            }
                            Text(authService.isLoading ? "Sending..." : "Send Reset Email")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: isEmailValid ? [.orange, .orange.opacity(0.8)] : [.gray, .gray.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(authService.isLoading || !isEmailValid)
                    .opacity(authService.isLoading ? 0.7 : 1.0)
                    .padding(.horizontal, 24)
                } else {
                    // Success state
                    VStack(spacing: 16) {
                        Text("We've sent password reset instructions to:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(email)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        Text("Please check your email and follow the instructions to reset your password.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                
                // Additional options
                VStack(spacing: 12) {
                    if !isEmailSent {
                        // Sign in link
                        HStack {
                            Text("Remember your password?")
                                .foregroundColor(.secondary)
                            Button("Sign In") {
                                showSignIn = true
                            }
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        }
                        .font(.subheadline)
                    } else {
                        // Try again button
                        Button("Send to Different Email") {
                            isEmailSent = false
                            email = ""
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            })
        }
        .sheet(isPresented: $showSignIn) {
            EmailSignInView()
        }
    }
}

#Preview {
    PasswordResetView()
}

