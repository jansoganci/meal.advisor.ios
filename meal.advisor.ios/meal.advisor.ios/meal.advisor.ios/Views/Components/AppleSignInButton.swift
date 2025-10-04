//
//  AppleSignInButton.swift
//  meal.advisor.ios
//
//  Apple Sign-In button component with proper styling and error handling
//

import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    @StateObject private var authService = AuthService.shared
    @State private var isSigningIn = false
    
    let onSuccess: (() -> Void)?
    let onError: ((String) -> Void)?
    
    init(onSuccess: (() -> Void)? = nil, onError: ((String) -> Void)? = nil) {
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Apple Sign-In Button
            Button(action: {
                performAppleSignIn()
            }) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.system(size: 18, weight: .medium))
                    Text("Continue with Apple")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.black)
                .cornerRadius(8)
            }
            .disabled(isSigningIn)
            .opacity(isSigningIn ? 0.6 : 1.0)
            
            // Loading indicator
            if isSigningIn {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Signing in with Apple...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Apple Sign-In Handling
    
    private func performAppleSignIn() {
        print("🍎 [AppleAuth Step 1] Apple Sign-In button tapped")
        print("🍎 [AppleAuth Step 1] Using native Apple Sign-In flow")
        
        isSigningIn = true
        
        // Use native Apple Sign-In flow
        authService.signInWithApple()
        
        // Handle success/error callbacks after a delay to allow for async processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isSigningIn = false
            if self.authService.isAuthenticated {
                self.onSuccess?()
            } else if let error = self.authService.errorMessage {
                self.onError?(error)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        AppleSignInButton(
            onSuccess: {
                print("Preview: Apple Sign-In successful")
            },
            onError: { error in
                print("Preview: Apple Sign-In error: \(error)")
            }
        )
        .padding()
    }
    .padding()
}
