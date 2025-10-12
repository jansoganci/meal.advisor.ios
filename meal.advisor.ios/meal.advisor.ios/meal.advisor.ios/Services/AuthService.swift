//
//  AuthService.swift
//  meal.advisor.ios
//
//  Authentication service with Sign in with Apple and Supabase integration
//

import Foundation
import AuthenticationServices
import GoogleSignIn
#if canImport(Supabase)
import Supabase
#endif

@MainActor
final class AuthService: NSObject, ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var currentNonce: String?
    private let defaults = UserDefaults.standard
    private let deviceIDKey = "device_install_id"
    private let supabaseClient = SupabaseClientManager.shared
    
    override init() {
        super.init()
        configureGoogleSignIn()
        checkAuthenticationStatus()
        generateDeviceID()
    }
    
    private func configureGoogleSignIn() {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["GIDClientID"] as? String else {
            print("❌ [GoogleSignIn] GIDClientID not found in Info.plist")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        print("✅ [GoogleSignIn] Configuration completed with client ID: \(clientID)")
    }
    
    struct User {
        let id: String
        let email: String?
        let displayName: String?
        let provider: AuthProvider
    }
    
    enum AuthProvider: String {
        case apple = "apple"
        case google = "google"
        case email = "email"
        case anonymous = "anonymous"
    }
    
    
    // MARK: - Device ID Management
    
    /// Get or create device install ID for anonymous usage
    var deviceID: String {
        if let existingID = defaults.string(forKey: deviceIDKey) {
            return existingID
        }
        
        let newID = UUID().uuidString
        defaults.set(newID, forKey: deviceIDKey)
        print("🔐 [AuthService] Generated new device ID: \(newID)")
        return newID
    }
    
    private func generateDeviceID() {
        _ = deviceID // Generate if needed
    }
    
    // MARK: - Sign in with Apple
    
    /// Start Sign in with Apple flow
    func signInWithApple() {
        print("🍎 [AppleAuth Step 1] Starting Sign in with Apple flow")
        isLoading = true
        errorMessage = nil
        
        let nonce = randomNonceString()
        currentNonce = nonce
        print("🍎 [AppleAuth Step 1] Generated nonce: \(nonce)")
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        print("🍎 [AppleAuth Step 1] Apple Sign-In request configured with scopes: fullName, email")
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        print("🍎 [AppleAuth Step 1] Apple Sign-In authorization controller started")
    }
    
    /// Sign in with Apple using ID token (called from AppleSignInButton)
    func signInWithAppleIdToken(
        idToken: String,
        nonce: String,
        appleIDCredential: ASAuthorizationAppleIDCredential
    ) async throws {
        print("🍎 [AppleAuth Step 4] Starting Supabase authentication with Apple ID token")
        print("🍎 [AppleAuth Step 4] ID Token length: \(idToken.count) characters")
        print("🍎 [AppleAuth Step 4] Nonce: \(nonce)")
        print("🍎 [AppleAuth Step 4] Apple User ID: \(appleIDCredential.user)")
        
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("❌ [AppleAuth Step 4] Supabase not configured")
            throw AuthError.supabaseNotConfigured
        }
        
        print("✅ [AppleAuth Step 4] Supabase client is configured")
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🍎 [AppleAuth Step 4] Calling Supabase auth.signInWithIdToken")
            print("🍎 [AppleAuth Step 4] Provider: apple")
            print("🍎 [AppleAuth Step 4] ID Token: \(idToken.prefix(50))...")
            print("🍎 [AppleAuth Step 4] Nonce: \(nonce)")
            
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )
            
            print("✅ [AppleAuth Step 4] Supabase authentication successful")
            print("✅ [AppleAuth Step 4] Session user ID: \(session.user.id.uuidString)")
            print("✅ [AppleAuth Step 4] Session user email: \(session.user.email ?? "none")")
            print("✅ [AppleAuth Step 4] Session access token: \(session.accessToken.prefix(20))...")
            
            // Extract user info from Apple credential and Supabase session
            let fullName = appleIDCredential.fullName
            let displayName = [fullName?.givenName, fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            print("🍎 [AppleAuth Step 5] Processing user information")
            print("🍎 [AppleAuth Step 5] Apple email: \(appleIDCredential.email ?? "not provided")")
            print("🍎 [AppleAuth Step 5] Apple full name: \(displayName.isEmpty ? "not provided" : displayName)")
            print("🍎 [AppleAuth Step 5] Supabase email: \(session.user.email ?? "none")")
            print("🍎 [AppleAuth Step 5] Supabase metadata: \(session.user.userMetadata)")
            
            // Update auth state
            currentUser = User(
                id: session.user.id.uuidString,
                email: session.user.email ?? appleIDCredential.email,
                displayName: displayName.isEmpty ? nil : displayName,
                provider: .apple
            )
            isAuthenticated = true
            
            print("✅ [AppleAuth Step 5] User state updated successfully")
            print("✅ [AppleAuth Step 5] User ID: \(currentUser?.id ?? "none")")
            print("✅ [AppleAuth Step 5] User email: \(currentUser?.email ?? "unknown")")
            print("✅ [AppleAuth Step 5] User display name: \(currentUser?.displayName ?? "none")")
            print("✅ [AppleAuth Step 5] User provider: \(currentUser?.provider.rawValue ?? "none")")
            print("✅ [AppleAuth Step 5] Authentication status: \(isAuthenticated)")
            
            // Notify AppState of auth status change FIRST
            print("🔔 [AuthService] Posting AuthStatusChanged notification")
            NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
            
            // Data migration in background (non-blocking)
            Task {
                print("🍎 [AppleAuth Step 6] Starting data migration...")
                await migrateLocalDataToAccount()
                print("✅ [AppleAuth Step 6] Data migration completed")
            }
            
            // Haptic feedback
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            print("🍎 [AppleAuth Step 7] Apple Sign-In flow completed successfully")
            
        } catch {
            print("❌ [AppleAuth Step 4] Supabase authentication failed")
            print("❌ [AppleAuth Step 4] Error type: \(type(of: error))")
            print("❌ [AppleAuth Step 4] Error description: \(error.localizedDescription)")
            print("❌ [AppleAuth Step 4] Full error: \(error)")
            
            errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    
    // MARK: - Sign in with Google
    
    /// Start Sign in with Google flow using Supabase OAuth
    func signInWithGoogle() async throws {
        print("🔐 [GoogleSignIn] Starting native Google Sign-In flow")
        
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("❌ [GoogleSignIn] Supabase not configured")
            throw AuthError.supabaseNotConfigured
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Start native Google Sign-In
            print("🔐 [GoogleSignIn] Starting native Google Sign-In...")
            guard let presentingViewController = await MainActor.run(body: {
                return UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }?.rootViewController
            }) else {
                throw AuthError.noPresentingViewController
            }
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let user = result.user
            let idToken = user.idToken?.tokenString
            
            guard let idToken = idToken else {
                print("❌ [GoogleSignIn] No ID token received")
                throw AuthError.noIdToken
            }
            
            print("✅ [GoogleSignIn] ID token received successfully")
            print("✅ [GoogleSignIn] User email: \(user.profile?.email ?? "unknown")")
            
            // Sign in to Supabase with the ID token
            print("🔐 [GoogleSignIn] Signing in to Supabase with ID token...")
            let session = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    nonce: nil
                )
            )
            
            print("✅ [GoogleSignIn] Supabase authentication successful")
            
            // Update authentication state
            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = User(
                    id: session.user.id.uuidString,
                    email: session.user.email,
                    displayName: user.profile?.name,
                    provider: .google
                )
                self.isLoading = false
                self.errorMessage = nil
                
                // Notify AppState of auth status change
                NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
            }
            
            print("✅ [GoogleSignIn] Authentication completed successfully")
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Google sign-in failed: \(error.localizedDescription)"
            }
            
            print("❌ [GoogleSignIn] Sign-in failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Email/Password Authentication
    
    /// Sign up with email and password
    func signUpWithEmail(email: String, password: String) async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("❌ [AuthService] Supabase not configured")
            throw AuthError.supabaseNotConfigured
        }
        
        isLoading = true
        errorMessage = nil
        
        print("🔐 [AuthService] Starting email sign-up for: \(email)")
        
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            if let session = response.session {
                // User is immediately signed in
                currentUser = User(
                    id: session.user.id.uuidString,
                    email: session.user.email,
                    displayName: session.user.userMetadata["full_name"]?.stringValue,
                    provider: .email
                )
                isAuthenticated = true
                
                // Notify AppState of auth status change
                NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
                
                print("🔐 [AuthService] Email sign-up successful")
                print("🔐 [AuthService] User: \(session.user.email ?? "unknown")")
                
                // Migrate local data
                await migrateLocalDataToAccount()
                
                // Haptic feedback
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
            } else {
                // User needs to verify email
                print("🔐 [AuthService] Email verification required")
                errorMessage = "Please check your email to verify your account"
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Sign up failed: \(error.localizedDescription)"
            print("❌ [AuthService] Email sign-up error: \(error)")
            throw error
        }
    }
    
    /// Sign in with email and password
    func signInWithEmail(email: String, password: String) async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("❌ [AuthService] Supabase not configured")
            throw AuthError.supabaseNotConfigured
        }
        
        isLoading = true
        errorMessage = nil
        
        print("🔐 [AuthService] Starting email sign-in for: \(email)")
        
        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )
            
            currentUser = User(
                id: response.user.id.uuidString,
                email: response.user.email,
                displayName: response.user.userMetadata["full_name"]?.stringValue,
                provider: .email
            )
            isAuthenticated = true
            
            // Notify AppState of auth status change
            NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
            
            print("🔐 [AuthService] Email sign-in successful")
            print("🔐 [AuthService] User: \(response.user.email ?? "unknown")")
            
            // Migrate local data
            await migrateLocalDataToAccount()
            
            // Haptic feedback
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            print("❌ [AuthService] Email sign-in error: \(error)")
            throw error
        }
    }
    
    /// Reset password
    func resetPassword(email: String) async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("❌ [AuthService] Supabase not configured")
            throw AuthError.supabaseNotConfigured
        }
        
        print("🔐 [AuthService] Sending password reset email to: \(email)")
        
        do {
            try await client.auth.resetPasswordForEmail(email)
            print("✅ [AuthService] Password reset email sent successfully")
        } catch {
            print("❌ [AuthService] Password reset failed: \(error)")
            throw error
        }
    }
    
    /// Handle OAuth callback session
    func handleOAuthCallback(session: Session) async {
        print("🔐 [OAuth Callback Handler Step 1] Handling OAuth callback")
        print("🔐 [OAuth Callback Handler Step 1] Session user ID: \(session.user.id)")
        print("🔐 [OAuth Callback Handler Step 1] Session user email: \(session.user.email ?? "none")")
        print("🔐 [OAuth Callback Handler Step 1] Session access token: \(session.accessToken.prefix(20))...")
        print("🔐 [OAuth Callback Handler Step 1] Session refresh token: \(session.refreshToken.prefix(20))...")
        
        // Extract user info from session
        let providerString = session.user.appMetadata["provider"]?.stringValue ?? "google"
        let provider = AuthProvider(rawValue: providerString) ?? .google
        
        print("🔐 [OAuth Callback Handler Step 2] Provider: \(providerString)")
        print("🔐 [OAuth Callback Handler Step 2] User metadata: \(session.user.userMetadata)")
        print("🔐 [OAuth Callback Handler Step 2] App metadata: \(session.user.appMetadata)")
        
        currentUser = User(
            id: session.user.id.uuidString,
            email: session.user.email,
            displayName: session.user.userMetadata["full_name"]?.stringValue,
            provider: provider
        )
        isAuthenticated = true
        
        // Notify AppState of auth status change
        NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
        
        print("✅ [OAuth Callback Handler Step 3] OAuth callback processed successfully")
        print("✅ [OAuth Callback Handler Step 3] User ID: \(currentUser?.id ?? "none")")
        print("✅ [OAuth Callback Handler Step 3] User email: \(currentUser?.email ?? "unknown")")
        print("✅ [OAuth Callback Handler Step 3] User display name: \(currentUser?.displayName ?? "none")")
        print("✅ [OAuth Callback Handler Step 3] User provider: \(currentUser?.provider.rawValue ?? "none")")
        print("✅ [OAuth Callback Handler Step 3] Authentication status: \(isAuthenticated)")
        
        print("🔐 [OAuth Callback Handler Step 4] Starting data migration...")
        // Migrate local data
        await migrateLocalDataToAccount()
        print("✅ [OAuth Callback Handler Step 4] Data migration completed")
        
        // Haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        print("✅ [OAuth Callback Handler Step 5] OAuth callback handling completed successfully")
    }
    
    /// Sign out current user
    func signOut() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Sign out from Supabase
                if supabaseClient.isConfigured {
                    try await supabaseClient.signOut()
                }
                
                // Clear local auth state
                currentUser = nil
                isAuthenticated = false
                
                // Notify AppState of auth status change
                NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
                
                print("🔐 [AuthService] User signed out successfully")
            } catch {
                errorMessage = "Failed to sign out: \(error.localizedDescription)"
                print("🔐 [AuthService] Sign out error: \(error)")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Authentication Status
    
    /// Check if user is currently authenticated
    private func checkAuthenticationStatus() {
        Task {
            // Check Supabase session if configured
            if supabaseClient.isConfigured {
                if let session = await supabaseClient.currentSession {
                    // User has active session
                    let fullName = session.user.userMetadata["full_name"]?.stringValue
                    let providerString = session.user.appMetadata["provider"]?.stringValue ?? "email"
                    currentUser = User(
                        id: session.user.id.uuidString,
                        email: session.user.email,
                        displayName: fullName,
                        provider: AuthProvider(rawValue: providerString) ?? .email
                    )
                    isAuthenticated = true
                    print("🔐 [AuthService] Found existing session for user: \(session.user.id.uuidString)")
                } else {
                    isAuthenticated = false
                    print("🔐 [AuthService] No existing session found")
                }
            } else {
                isAuthenticated = false
            }
        }
    }
    
    /// Refresh authentication session
    func refreshSession() async {
        guard supabaseClient.isConfigured else {
            print("🔐 [AuthService] Supabase not configured, skipping refresh")
            return
        }
        
        do {
            try await supabaseClient.refreshSession()
            print("🔐 [AuthService] Session refreshed successfully")
        } catch {
            print("🔐 [AuthService] Failed to refresh session: \(error)")
        }
    }
    
    // MARK: - Data Migration
    
    /// Migrate local data to user account after sign-in
    func migrateLocalDataToAccount() async {
        guard isAuthenticated, let user = currentUser else { return }
        
        print("🔐 [AuthService] Starting data migration for user: \(user.id)")
        
        // Sync favorites to Supabase
        do {
            try await FavoritesSyncService.shared.syncAll()
            print("✅ [AuthService] Favorites synced successfully")
        } catch {
            print("❌ [AuthService] Failed to sync favorites: \(error)")
        }
        
        // Sync preferences and ratings to Supabase
        do {
            try await PreferencesSyncService.shared.syncAll()
            print("✅ [AuthService] Preferences and ratings synced successfully")
        } catch {
            print("❌ [AuthService] Failed to sync preferences: \(error)")
        }
        
        // ✅ NEW: Migrate usage tracking from device to user account
        await UsageTrackingService.shared.migrateDeviceUsageToUser()
        
        print("🔐 [AuthService] Data migration completed")
    }
    
    // MARK: - Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("🍎 [AppleAuth Step 2] Apple authorization completed")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ [AppleAuth Step 2] Invalid Apple ID credential")
            errorMessage = "Invalid Apple credentials"
            isLoading = false
            return
        }
        
        print("✅ [AppleAuth Step 2] Apple ID credential extracted successfully")
        print("🍎 [AppleAuth Step 2] User ID: \(appleIDCredential.user)")
        print("🍎 [AppleAuth Step 2] Email: \(appleIDCredential.email ?? "not provided")")
        print("🍎 [AppleAuth Step 2] Full name: \(appleIDCredential.fullName?.givenName ?? "not provided") \(appleIDCredential.fullName?.familyName ?? "")")
        
        guard let nonce = currentNonce else {
            print("❌ [AppleAuth Step 2] No nonce found in current state")
            errorMessage = "Invalid authentication state"
            isLoading = false
            return
        }
        
        print("✅ [AppleAuth Step 2] Nonce found: \(nonce)")
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("❌ [AppleAuth Step 2] Failed to extract identity token")
            errorMessage = "Unable to fetch Apple identity token"
            isLoading = false
            return
        }
        
        print("✅ [AppleAuth Step 2] Identity token extracted successfully")
        print("🍎 [AppleAuth Step 2] Token length: \(idTokenString.count) characters")
        
        // Extract user info
        let userID = appleIDCredential.user
        let email = appleIDCredential.email
        let fullName = appleIDCredential.fullName
        let displayName = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        print("🍎 [AppleAuth Step 3] Processing Apple user information")
        print("🍎 [AppleAuth Step 3] User ID: \(userID)")
        print("🍎 [AppleAuth Step 3] Email: \(email ?? "not provided")")
        print("🍎 [AppleAuth Step 3] Display name: \(displayName.isEmpty ? "not provided" : displayName)")
        
        Task {
            do {
                // Sign in to Supabase with Apple ID token
                if supabaseClient.isConfigured, let client = supabaseClient.client {
                    print("🍎 [AppleAuth Step 4] Starting Supabase authentication")
                    print("🍎 [AppleAuth Step 4] Provider: apple")
                    print("🍎 [AppleAuth Step 4] ID Token: \(idTokenString.prefix(50))...")
                    print("🍎 [AppleAuth Step 4] Nonce: \(nonce)")
                    
                    let session = try await client.auth.signInWithIdToken(
                        credentials: OpenIDConnectCredentials(
                            provider: .apple,
                            idToken: idTokenString,
                            nonce: nonce
                        )
                    )
                    
                    print("✅ [AppleAuth Step 4] Supabase authentication successful")
                    print("✅ [AppleAuth Step 4] Session user ID: \(session.user.id.uuidString)")
                    print("✅ [AppleAuth Step 4] Session user email: \(session.user.email ?? "none")")
                    
                    // Update auth state from Supabase session
                    currentUser = User(
                        id: session.user.id.uuidString,
                        email: session.user.email ?? email,
                        displayName: displayName.isEmpty ? nil : displayName,
                        provider: .apple
                    )
                    isAuthenticated = true
                    
                    print("✅ [AppleAuth Step 5] User state updated successfully")
                    print("✅ [AppleAuth Step 5] Authentication status: \(isAuthenticated)")
                } else {
                    print("⚠️ [AppleAuth Step 4] Supabase not configured, using local authentication")
                    // Fallback to local authentication if Supabase not configured
                    currentUser = User(
                        id: userID,
                        email: email,
                        displayName: displayName.isEmpty ? nil : displayName,
                        provider: .apple
                    )
                    isAuthenticated = true
                    print("✅ [AppleAuth Step 4] Local authentication completed")
                }
                
                // Notify AppState of auth status change FIRST
                print("🔔 [AuthService] Posting AuthStatusChanged notification")
                NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
                
                // Data migration in background (non-blocking)
                Task {
                    print("🍎 [AppleAuth Step 6] Starting data migration...")
                    await migrateLocalDataToAccount()
                    print("✅ [AppleAuth Step 6] Data migration completed")
                }
                
                // Haptic feedback
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                
                print("🍎 [AppleAuth Step 7] Apple Sign-In flow completed successfully")
            } catch {
                print("❌ [AppleAuth Step 4] Supabase authentication failed")
                print("❌ [AppleAuth Step 4] Error type: \(type(of: error))")
                print("❌ [AppleAuth Step 4] Error description: \(error.localizedDescription)")
                errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ [AppleAuth Step 2] Apple authorization failed")
        
        let authError = error as NSError
        
        // User cancelled
        if authError.code == ASAuthorizationError.canceled.rawValue {
            print("🍎 [AppleAuth Error] User cancelled Apple Sign-In")
            // Don't show error for user cancellation
        } else {
            print("❌ [AppleAuth Error] Apple Sign-In error: \(error.localizedDescription)")
            print("❌ [AppleAuth Error] Error code: \(authError.code)")
            errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Get the key window for presenting the Sign in with Apple UI
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}

// MARK: - SHA256 Helper

import CryptoKit

extension AuthService {
    private struct SHA256 {
        static func hash(data: Data) -> Data {
            let hashed = CryptoKit.SHA256.hash(data: data)
            return Data(hashed)
        }
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case supabaseNotConfigured
    case invalidCredentials
    case sessionExpired
    case networkError
    case noPresentingViewController
    case noIdToken
    
    var errorDescription: String? {
        switch self {
        case .supabaseNotConfigured:
            return "Authentication service is not configured. Please check your internet connection."
        case .invalidCredentials:
            return "Invalid credentials. Please try again."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .networkError:
            return "Network error. Please check your internet connection and try again."
        case .noPresentingViewController:
            return "Unable to present sign-in interface. Please try again."
        case .noIdToken:
            return "Failed to receive authentication token. Please try again."
        }
    }
}
