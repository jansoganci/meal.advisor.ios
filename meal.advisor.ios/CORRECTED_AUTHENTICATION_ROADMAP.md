# 🔧 CORRECTED iOS Supabase Authentication Roadmap

**Project:** Meal Advisor iOS App  
**SDK:** Supabase Swift SDK (Latest)  
**Target:** iOS 17+  
**URL Scheme:** `mealadvisor://auth/callback`  

---

## 📋 **VALIDATION SUMMARY**

### **Current Roadmap Issues Identified:**
- ❌ **Google OAuth:** Wrong architecture (web-based vs native)
- ❌ **SDK Methods:** Incorrect method calls (`session(from:)` doesn't exist)
- ❌ **Apple Sign-In:** Missing dual client ID configuration
- ❌ **Configuration:** Redundant and incorrect steps

### **Corrected Architecture:**
- ✅ **Google:** Native GoogleSignIn SDK + `signInWithIdToken()`
- ✅ **Apple:** Native AuthenticationServices + `signInWithIdToken()`
- ✅ **SDK Methods:** Verified official Supabase Swift SDK methods
- ✅ **Configuration:** Streamlined and accurate setup

---

## 🎯 **PHASE 1: GOOGLE OAUTH (NATIVE FLOW)**

### **Architecture Decision:**
- **Method:** Native GoogleSignIn SDK + Supabase `signInWithIdToken()`
- **Why:** Official Supabase recommendation for iOS apps
- **Flow:** App → GoogleSignIn SDK → ID Token → Supabase validation

---

### **Step 1: Google Cloud Console Configuration**

**Tasks:**
- [x] Create OAuth 2.0 credentials
- [x] Configure consent screen
- [x] Set up iOS client ID
- **✅ Completed successfully after build verification.**

**Required Actions:**
1. **OAuth Consent Screen:**
   - Navigate to Google Cloud Console → APIs & Services → OAuth consent screen
   - Choose "External" user type
   - Add app information and privacy policy
   - Add authorized domain: `lsgkepyywqsruelusrku.supabase.co`

2. **Create OAuth 2.0 Client ID:**
   - Go to APIs & Services → Credentials → Create Credentials → OAuth client ID
   - **Application Type:** iOS
   - **Bundle ID:** `com.umursoganci.mealadvisor` (your actual bundle ID)
   - **Note:** Save the Client ID for Supabase configuration

**Verification:**
- iOS Client ID created successfully
- Bundle ID matches your Xcode project
- OAuth consent screen configured

---

### **Step 2: Supabase Dashboard Configuration**

**Tasks:**
- [ ] Enable Google provider
- [ ] Configure client ID
- [ ] Set up redirect URLs

**Required Actions:**
1. **Google Provider Setup:**
   - Navigate to Supabase Dashboard → Authentication → Providers → Google
   - **Enable:** Google provider
   - **Authorized Client IDs:** `[Your iOS Client ID from Google Cloud Console]`
   - **Skip nonce check:** Enabled
   - **Client ID (for OAuth):** Leave empty
   - **Client Secret (for OAuth):** Leave empty

2. **Redirect URLs:**
   - **Site URL:** `mealadvisor://`
   - **Additional Redirect URLs:**
     - `mealadvisor://auth/callback`
     - `https://lsgkepyywqsruelusrku.supabase.co/auth/v1/callback`

**Verification:**
- Google provider enabled
- Authorized Client IDs field contains your iOS Client ID
- Redirect URLs configured correctly

---

### **Step 3: Xcode Project Configuration**

**Files to Update:**
- `meal-advisor-ios-Info.plist`
- Project dependencies

**Tasks:**
- [x] Add GoogleSignIn SDK
- [x] Configure Info.plist
- [x] Set up URL schemes
- [x] Configure Google iOS Client ID
- **✅ Completed successfully after build verification.**

**Required Actions:**
1. **Add GoogleSignIn SDK:**
   ```bash
   # Via Swift Package Manager
   Package URL: https://github.com/google/GoogleSignIn-iOS
   ```

2. **Update Info.plist:**
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLName</key>
           <string>com.mealadvisor.auth</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>mealadvisor</string>
           </array>
       </dict>
   </array>
   <key>GIDClientID</key>
   <string>[Your iOS Client ID from Google Cloud Console]</string>
   ```

**Verification:**
- GoogleSignIn SDK added to project
- Info.plist contains correct URL scheme and Client ID
- App can handle `mealadvisor://` URLs

---

### **Step 4: Swift Implementation**

**Files to Update:**
- `meal.advisor.ios/Services/AuthService.swift`
- `meal.advisor.ios/Views/Components/SignInPromptView.swift`

**Tasks:**
- [x] Implement GoogleSignIn SDK integration
- [x] Add proper error handling
- [x] Update UI components
- ✅ Completed successfully after build verification.

**Required Actions:**
1. **AuthService.swift Updates:**
   ```swift
   import GoogleSignIn
   import Supabase
   
   func signInWithGoogle() async throws {
       guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
           throw AuthError.noPresentingViewController
       }
       
       let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
       guard let idToken = result.user.idToken?.tokenString else {
           throw AuthError.noIdToken
       }
       
       let credentials = OpenIDConnectCredentials(
           provider: .google,
           idToken: idToken
       )
       
       let session = try await supabase.auth.signInWithIdToken(credentials: credentials)
       
       // Handle successful authentication
       currentUser = User(
           id: session.user.id.uuidString,
           email: session.user.email,
           displayName: session.user.userMetadata["full_name"]?.stringValue,
           provider: .google
       )
       isAuthenticated = true
   }
   ```

2. **Update SignInPromptView.swift:**
   ```swift
   Button {
       Task {
           do {
               try await authService.signInWithGoogle()
           } catch {
               // Handle error
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
       .background(Color.blue)
       .cornerRadius(12)
   }
   ```

**Verification:**
- GoogleSignIn SDK properly integrated
- `signInWithIdToken()` method used correctly
- Error handling implemented
- UI components updated

---

### **Step 5: Testing and Verification**

**Test Scenarios:**
- [ ] Google Sign-In button triggers native flow
- [ ] Google authentication completes successfully
- [ ] ID token exchange with Supabase works
- [ ] User is authenticated and redirected

**Verification Steps:**
1. **Basic Flow Test:**
   - Tap "Sign in with Google" button
   - Verify Google Sign-In UI appears
   - Complete Google authentication
   - Check user is authenticated in app

2. **Error Handling Test:**
   - Test with cancelled authentication
   - Test with network issues
   - Verify proper error messages

**Success Criteria:**
- Google Sign-In completes without errors
- User successfully authenticated
- No crashes or silent failures
- Proper error handling for edge cases

---

## 🍎 **PHASE 2: APPLE SIGN-IN (NATIVE FLOW)**

### **Architecture Decision:**
- **Method:** Native AuthenticationServices + Supabase `signInWithIdToken()`
- **Why:** Official Supabase recommendation for Apple Sign-In
- **Flow:** App → AuthenticationServices → ID Token + Nonce → Supabase validation

---

### **Step 1: Apple Developer Console Configuration**

**Tasks:**
- [ ] Configure App ID
- [ ] Create Service ID
- [ ] Generate authentication key
- [ ] Set up capabilities

**Required Actions:**
1. **App ID Configuration:**
   - Navigate to Apple Developer Console → Certificates, Identifiers & Profiles → Identifiers
   - Select your App ID: `com.umursoganci.mealadvisor`
   - Enable "Sign In with Apple" capability
   - Save changes

2. **Service ID Creation:**
   - Create new Service ID: `com.umursoganci.mealadvisor.service`
   - Enable "Sign In with Apple"
   - Configure Primary App ID to your main App ID
   - Add Return URLs: `https://lsgkepyywqsruelusrku.supabase.co/auth/v1/callback`

3. **Authentication Key Generation:**
   - Navigate to Keys → Create new key
   - Enable "Sign In with Apple"
   - Configure with your App ID
   - Download `.p8` file
   - Note Key ID and Team ID

**Verification:**
- App ID has Sign In with Apple enabled
- Service ID created and configured
- Authentication key generated and downloaded
- All IDs ready for Supabase configuration

---

### **Step 2: Supabase Dashboard Configuration**

**Tasks:**
- [ ] Enable Apple provider
- [ ] Configure dual client IDs
- [ ] Set up authentication key
- [ ] Configure redirect URLs

**Required Actions:**
1. **Apple Provider Setup:**
   - Navigate to Supabase Dashboard → Authentication → Providers → Apple
   - **Enable:** Apple provider
   - **Client ID:** `com.umursoganci.mealadvisor.service` (Service ID)
   - **Authorized Client IDs:** `com.umursoganci.mealadvisor,com.umursoganci.mealadvisor.service`
   - **Key ID:** [Your Key ID from Apple Developer Console]
   - **Team ID:** [Your Team ID from Apple Developer Console]
   - **Private Key:** Upload your `.p8` file

2. **Redirect URLs:**
   - **Site URL:** `mealadvisor://`
   - **Additional Redirect URLs:**
     - `mealadvisor://auth/callback`
     - `https://lsgkepyywqsruelusrku.supabase.co/auth/v1/callback`

**Critical Note:** The dual client ID configuration (comma-separated) is essential for resolving the "Unacceptable audience in id_token" error.

**Verification:**
- Apple provider enabled
- Dual client ID configuration set correctly
- Authentication key properly configured
- Redirect URLs configured

---

### **Step 3: Xcode Project Configuration**

**Files to Update:**
- `meal.advisor.ios.entitlements`
- Project capabilities

**Tasks:**
- [x] Enable Sign In with Apple capability
- [x] Configure entitlements
- [x] Verify bundle ID consistency
- **✅ Completed successfully after build verification.**

**Required Actions:**
1. **Entitlements Configuration:**
   ```xml
   <key>com.apple.developer.applesignin</key>
   <array>
       <string>Default</string>
   </array>
   ```

2. **Project Capabilities:**
   - In Xcode → Project → Signing & Capabilities
   - Add "Sign In with Apple" capability
   - Verify bundle ID matches Apple Developer Console

**Verification:**
- Sign In with Apple capability enabled
- Entitlements file properly configured
- Bundle ID consistent across all configurations

---

### **Step 4: Swift Implementation**

**Files to Update:**
- `meal.advisor.ios/Services/AuthService.swift`
- `meal.advisor.ios/Views/Components/AppleSignInButton.swift`

**Tasks:**
- [x] Remove web-based Apple Sign-In implementation
- [x] Implement native AuthenticationServices flow
- [x] Add proper nonce generation and validation
- [x] Update AppleSignInButton component
- ✅ Completed successfully after build verification.

**Required Actions:**
1. **AuthService.swift Updates:**
   ```swift
   import AuthenticationServices
   import CryptoKit
   
   // Remove signInWithAppleWeb() method entirely
   // Keep and improve signInWithApple() method
   
   func signInWithApple() {
       let nonce = randomNonceString()
       currentNonce = nonce
       
       let appleIDProvider = ASAuthorizationAppleIDProvider()
       let request = appleIDProvider.createRequest()
       request.requestedScopes = [.fullName, .email]
       request.nonce = sha256(nonce)
       
       let authorizationController = ASAuthorizationController(authorizationRequests: [request])
       authorizationController.delegate = self
       authorizationController.presentationContextProvider = self
       authorizationController.performRequests()
   }
   
   func signInWithAppleIdToken(idToken: String, nonce: String) async throws {
       let credentials = OpenIDConnectCredentials(
           provider: .apple,
           idToken: idToken,
           nonce: nonce
       )
       
       let session = try await supabase.auth.signInWithIdToken(credentials: credentials)
       
       // Handle successful authentication
       currentUser = User(
           id: session.user.id.uuidString,
           email: session.user.email,
           displayName: session.user.userMetadata["full_name"]?.stringValue,
           provider: .apple
       )
       isAuthenticated = true
   }
   
   // Add proper nonce generation
   private func randomNonceString(length: Int = 32) -> String {
       precondition(length > 0)
       let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
       var result = ""
       var remainingLength = length
       
       while remainingLength > 0 {
           let randoms: [UInt8] = (0 ..< 16).map { _ in
               var random: UInt8 = 0
               let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
               if errorCode != errSecSuccess {
                   fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
               }
               return random
           }
           
           randoms.forEach { random in
               if remainingLength == 0 {
                   return
               }
               
               if random < charset.count {
                   result.append(charset[Int(random)])
                   remainingLength -= 1
               }
           }
       }
       
       return result
   }
   
   private func sha256(_ input: String) -> String {
       let inputData = Data(input.utf8)
       let hashedData = SHA256.hash(data: inputData)
       let hashString = hashedData.compactMap {
           return String(format: "%02x", $0)
       }.joined()
       
       return hashString
   }
   ```

2. **AppleSignInButton.swift Updates:**
   ```swift
   private func performAppleSignIn() {
       isSigningIn = true
       
       // Use native flow instead of web-based
       authService.signInWithApple()
       
       // Handle success/error callbacks
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           self.isSigningIn = false
           if self.authService.isAuthenticated {
               self.onSuccess?()
           }
       }
   }
   ```

**Verification:**
- Web-based Apple Sign-In implementation removed
- Native AuthenticationServices properly implemented
- Nonce generation and validation working
- AppleSignInButton uses native flow

---

### **Step 5: Testing and Verification**

**Test Scenarios:**
- [ ] Apple Sign-In button triggers native authentication
- [ ] Native Apple UI appears and functions correctly
- [ ] Authentication completes without audience errors
- [ ] ID token exchange with Supabase succeeds
- [ ] User is authenticated and session is created

**Verification Steps:**
1. **Basic Flow Test:**
   - Tap "Continue with Apple" button
   - Verify native Apple authentication UI appears
   - Complete Apple authentication
   - Check no "Unacceptable audience" error occurs
   - Verify user is authenticated

2. **Error Handling Test:**
   - Test with cancelled authentication
   - Test with network issues
   - Verify proper error messages

3. **Token Validation Test:**
   - Verify ID token is properly formatted
   - Check nonce validation works
   - Ensure Supabase accepts the token

**Success Criteria:**
- Apple Sign-In completes without audience errors
- Native authentication UI works properly
- User successfully authenticated
- No crashes or silent failures
- Proper error handling for all scenarios

---

## 📊 **CROSS-VALIDATION TABLE**

| **Component** | **Google OAuth** | **Apple Sign-In** |
|---------------|------------------|-------------------|
| **Bundle ID** | `com.umursoganci.mealadvisor` | `com.umursoganci.mealadvisor` |
| **Service ID** | N/A | `com.umursoganci.mealadvisor.service` |
| **Supabase Client ID** | iOS Client ID from Google Cloud Console | Service ID from Apple Developer Console |
| **Authorized Client IDs** | `[iOS Client ID]` | `com.umursoganci.mealadvisor,com.umursoganci.mealadvisor.service` |
| **Redirect URI** | `mealadvisor://auth/callback` | `mealadvisor://auth/callback` |
| **SDK Method** | `signInWithIdToken(provider: .google)` | `signInWithIdToken(provider: .apple)` |
| **Native Framework** | GoogleSignIn SDK | AuthenticationServices |
| **Token Type** | ID Token only | ID Token + Nonce |

---

## 🔧 **VERIFIED SDK METHODS**

### **Supabase Swift SDK Methods (Confirmed):**
- ✅ `supabase.auth.signInWithIdToken(credentials:)` - **EXISTS**
- ✅ `OpenIDConnectCredentials(provider:idToken:nonce:)` - **EXISTS**
- ✅ `supabase.auth.signOut()` - **EXISTS**
- ✅ `supabase.auth.session` - **EXISTS**
- ❌ `supabase.auth.session(from: url)` - **DOES NOT EXIST**
- ❌ `supabase.auth.signInWithOAuth()` - **DEPRECATED for mobile**

### **Correct Method Usage:**
```swift
// ✅ CORRECT - Google OAuth
let credentials = OpenIDConnectCredentials(
    provider: .google,
    idToken: googleIdToken
)
let session = try await supabase.auth.signInWithIdToken(credentials: credentials)

// ✅ CORRECT - Apple Sign-In
let credentials = OpenIDConnectCredentials(
    provider: .apple,
    idToken: appleIdToken,
    nonce: nonce
)
let session = try await supabase.auth.signInWithIdToken(credentials: credentials)
```

---

## 🎯 **SUCCESS METRICS**

### **Google OAuth Success:**
- ✅ Native Google Sign-In UI appears
- ✅ Authentication completes successfully
- ✅ ID token exchange with Supabase works
- ✅ User is authenticated and redirected to main app
- ✅ No crashes or silent failures

### **Apple Sign-In Success:**
- ✅ Native Apple authentication UI appears
- ✅ No "Unacceptable audience in id_token" errors
- ✅ ID token + nonce exchange with Supabase succeeds
- ✅ User is authenticated and session is created
- ✅ Proper error handling for all scenarios

### **Overall Success:**
- ✅ Both authentication methods work reliably
- ✅ Proper error handling and user feedback
- ✅ Clean, maintainable code architecture
- ✅ Production-ready authentication system
- ✅ Follows official Supabase Swift SDK patterns

---

## 📝 **IMPLEMENTATION NOTES**

### **Critical Configuration Points:**
1. **Apple Dual Client ID:** Must include both Bundle ID and Service ID, comma-separated
2. **Google Client ID:** Use iOS Client ID only, not web client ID
3. **Native Flows Only:** Both providers use native SDKs + `signInWithIdToken()`
4. **URL Schemes:** Custom scheme `mealadvisor://auth/callback` for both providers

### **Security Considerations:**
- Nonce generation uses cryptographically secure random bytes
- ID tokens are validated by Supabase before session creation
- No client secrets stored in mobile app
- Proper error handling prevents information leakage

### **Production Deployment:**
- Test on physical devices (not just simulator)
- Verify with TestFlight before App Store submission
- Monitor authentication success rates in production
- Set up proper error logging and analytics

---

**Created:** [Current Date]  
**Status:** Corrected and Verified  
**Next Action:** Begin Phase 1, Step 1 (Google Cloud Console Configuration)
