//
//  SignInPromptView.swift
//  meal.advisor.ios
//
//  Just-In-Time sign-in prompt bottom sheet
//

import SwiftUI
import AuthenticationServices

struct SignInPromptView: View {
    @StateObject private var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showEmailSignIn = false
    
    let context: SignInContext
    
    enum SignInContext {
        case firstSuggestion
        case savingFavorite
        case premiumFeature
        
        var title: String {
            switch self {
            case .firstSuggestion:
                return "Save your preferences?"
            case .savingFavorite:
                return "Sign in to save favorites"
            case .premiumFeature:
                return "Sign in to continue"
            }
        }
        
        var description: String {
            switch self {
            case .firstSuggestion:
                return "Sign in to get better suggestions and access your favorites on all devices."
            case .savingFavorite:
                return "Keep your favorite recipes synced across all your devices."
            case .premiumFeature:
                return "Access premium features and sync your data across devices."
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            // Icon
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
                .accessibilityHidden(true)
            
            // Content
            VStack(spacing: 12) {
                Text(context.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(context.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            
            // Benefits
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(icon: "checkmark.circle.fill", text: "Sync across devices")
                BenefitRow(icon: "checkmark.circle.fill", text: "Never lose your favorites")
                BenefitRow(icon: "checkmark.circle.fill", text: "Better personalization")
            }
            .padding(.horizontal, 32)
            
            // Sign in Buttons
            VStack(spacing: 12) {
                // Apple Sign-In Button - Using proper AppleSignInButton component
                AppleSignInButton(
                    onSuccess: {
                        print("🍎 [SignInPrompt] Apple Sign-In successful")
                    },
                    onError: { error in
                        print("🍎 [SignInPrompt] Apple Sign-In error: \(error)")
                    }
                )
                
                // Sign in with Google Button
                Button {
                    Task {
                        do {
                            try await authService.signInWithGoogle()
                        } catch {
                            // Error already handled in AuthService
                            print("Google sign-in failed: \(error)")
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.title3)
                        Text("Sign in with Google")
                            .font(.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.26, green: 0.52, blue: 0.96), Color(red: 0.22, green: 0.45, blue: 0.82)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(authService.isLoading)
                .opacity(authService.isLoading ? 0.6 : 1.0)
                .accessibilityLabel("Sign in with Google")
                
                // Sign in with Email Button
                Button {
                    showEmailSignIn = true
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                            .font(.title3)
                        Text("Sign in with Email")
                            .font(.body.weight(.semibold))
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
                .disabled(authService.isLoading)
                .opacity(authService.isLoading ? 0.6 : 1.0)
                .accessibilityLabel("Sign in with Email")
                
                // Maybe Later Button
                Button("Maybe Later") {
                    dismiss()
                }
                .font(.body)
                .foregroundColor(.secondary)
                .accessibilityLabel("Maybe later, continue without signing in")
                .disabled(authService.isLoading)
            }
            .padding(.horizontal, 20)
            
            // Error message
            if let error = authService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Privacy Note
            Text("We respect your privacy. See our Privacy Policy for details.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onChange(of: authService.isAuthenticated) { isAuth in
            if isAuth {
                // Dismiss after successful sign-in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView()
        }
    }
}

// MARK: - Benefit Row

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.body)
                .accessibilityHidden(true)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

#Preview("First Suggestion Context") {
    SignInPromptView(context: .firstSuggestion)
}

#Preview("Saving Favorite Context") {
    SignInPromptView(context: .savingFavorite)
}

#Preview("Premium Feature Context") {
    SignInPromptView(context: .premiumFeature)
}
