//
//  AppleSignInTestView.swift
//  meal.advisor.ios
//
//  Test view for Apple Sign-In functionality with detailed logging
//

import SwiftUI

struct AppleSignInTestView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "applelogo")
                    .font(.system(size: 50))
                    .foregroundColor(.primary)
                
                Text("Apple Sign-In Test")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Test the complete Apple Sign-In flow with Supabase")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Apple Sign-In Button
            AppleSignInButton(
                onSuccess: {
                    print("🍎 [TestView] Apple Sign-In successful!")
                    alertMessage = "Apple Sign-In successful!\nUser: \(authService.currentUser?.email ?? "Unknown")"
                    showingAlert = true
                },
                onError: { error in
                    print("🍎 [TestView] Apple Sign-In error: \(error)")
                    alertMessage = "Apple Sign-In failed:\n\(error)"
                    showingAlert = true
                }
            )
            .padding(.horizontal, 40)
            
            // Auth Status
            VStack(spacing: 12) {
                HStack {
                    Circle()
                        .fill(authService.isAuthenticated ? .green : .red)
                        .frame(width: 12, height: 12)
                    
                    Text(authService.isAuthenticated ? "Authenticated" : "Not Authenticated")
                        .font(.headline)
                        .foregroundColor(authService.isAuthenticated ? .green : .red)
                }
                
                if let user = authService.currentUser {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("User ID: \(user.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let email = user.email {
                            Text("Email: \(email)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let displayName = user.displayName {
                            Text("Name: \(displayName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Provider: \(user.provider.rawValue.capitalized)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Instructions:")
                    .font(.headline)
                
                Text("1. Tap the Apple Sign-In button above")
                Text("2. Complete Apple authentication")
                Text("3. Check console logs for detailed flow")
                Text("4. Verify Supabase authentication")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .alert("Apple Sign-In Result", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            print("🍎 [TestView] Apple Sign-In test view appeared")
            print("🍎 [TestView] Current auth status: \(authService.isAuthenticated)")
            print("🍎 [TestView] Current user: \(authService.currentUser?.email ?? "none")")
        }
    }
}

#Preview {
    AppleSignInTestView()
}
