# 🚀 iOS Supabase Authentication Fix Roadmap

**Project:** Meal Advisor iOS App  
**Issue:** Apple Sign-In "Unacceptable audience" + Google OAuth redirect failures  
**Goal:** Production-ready authentication with proper Supabase native mobile standards  

---

## 📋 **OVERVIEW**

This roadmap addresses two critical authentication issues in your iOS app:

1. **Apple Sign-In:** "Unacceptable audience in id_token" error
2. **Google OAuth:** Safari opens but fails to redirect back to app

**Root Cause:** Architectural mismatch between current implementation and Supabase's recommended native mobile authentication patterns.

---

## 🎯 **PHASE 1: GOOGLE OAUTH FIX**
*Web-based OAuth flow with proper redirect handling*

### **Current Problem Analysis**
- Google OAuth opens Safari but fails to redirect back to app
- Missing URL scheme validation in Swift code
- Incomplete deep link handling in SwiftUI
- Potential Supabase dashboard configuration issues

### **Architecture Decision**
- **Use:** `signInWithOAuth()` (web-based flow)
- **Why:** Google OAuth works best with web-based redirect flow
- **Flow:** App → Safari → Google → Redirect to app → Session exchange

---

### **Step 1: Apple Developer Console Configuration**

**Tasks:**
- [ ] Verify custom URL scheme registration
- [ ] Check app bundle ID consistency

**Required Actions:**
1. Open Apple Developer Console
2. Navigate to your app's App ID
3. Verify bundle ID: `com.umursoganci.mealadvisor` (or your actual bundle ID)
4. Ensure Sign In with Apple capability is enabled (if using Apple Sign-In later)
5. Note the exact bundle ID for Supabase configuration

**Verification:**
- Bundle ID matches across Apple Developer Console and Xcode project
- App ID has required capabilities enabled

---

### **Step 2: Google Cloud Console Configuration**

**Tasks:**
- [ ] Create/verify OAuth 2.0 credentials
- [ ] Configure redirect URIs
- [ ] Set up both web and iOS client IDs

**Required Actions:**
1. Open Google Cloud Console
2. Navigate to APIs & Services > Credentials
3. Create/verify OAuth 2.0 Client IDs:
   - **Web Application Client ID** (for Supabase backend)
   - **iOS Client ID** (for native app integration)
4. Configure authorized redirect URIs:
   - `https://lsgkepyywqsruelusrku.supabase.co/auth/v1/callback`
   - `mealadvisor://auth/callback`
5. Configure authorized JavaScript origins:
   - `https://lsgkepyywqsruelusrku.supabase.co`

**Verification:**
- Both web and iOS client IDs exist
- Redirect URIs include Supabase callback URL
- Client IDs are ready for Supabase dashboard configuration

---

### **Step 3: Supabase Dashboard Configuration**

**Tasks:**
- [ ] Update Google provider settings
- [ ] Configure redirect URLs
- [ ] Set up dual client ID configuration

**Required Actions:**
1. Open Supabase Dashboard
2. Navigate to Authentication > Providers
3. Configure Google provider:
   - **Client ID:** `[Web Client ID],[iOS Client ID]` (comma-separated)
   - **Client Secret:** [Your Google Web Client Secret]
   - **Redirect URL:** `mealadvisor://auth/callback`
4. Update Site URL and redirect URLs:
   - **Site URL:** `mealadvisor://`
   - **Additional Redirect URLs:**
     - `mealadvisor://auth/callback`
     - `https://lsgkepyywqsruelusrku.supabase.co/auth/v1/callback`

**Verification:**
- Google provider is enabled
- Dual client ID configuration is set
- Redirect URLs match your app's URL scheme

---

### **Step 4: Xcode Project Configuration**

**Files to Update:**
- `meal-advisor-ios-Info.plist`
- `meal.advisor.ios.entitlements` (if exists)

**Tasks:**
- [ ] Verify URL scheme registration
- [ ] Check app permissions

**Required Actions:**
1. Open `meal-advisor-ios-Info.plist`
2. Verify URL scheme configuration:
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
   ```
3. Ensure app has proper permissions for URL handling

**Verification:**
- URL scheme `mealadvisor` is registered
- Info.plist syntax is correct
- App can handle incoming URLs

---

### **Step 5: Swift Code Implementation**

**Files to Update:**
- `meal.advisor.ios/Services/AuthService.swift`
- `meal.advisor.ios/meal_advisor_iosApp.swift`

**Tasks:**
- [ ] Fix Google OAuth implementation
- [ ] Add URL scheme validation
- [ ] Improve error handling
- [ ] Implement proper deep link handling

**Required Actions:**
1. **Update AuthService.swift:**
   - Fix `signInWithGoogle()` method
   - Add proper URL scheme validation with `canOpenURL`
   - Remove early `isLoading = false` that breaks callback handling
   - Improve error handling and logging

2. **Update meal_advisor_iosApp.swift:**
   - Enhance `onOpenURL` handler
   - Add better URL parsing and validation
   - Implement robust session exchange logic
   - Add comprehensive error handling

3. **Key Methods to Use:**
   - `supabase.auth.signInWithOAuth()` for Google OAuth initiation
   - `supabase.auth.session(from: url)` for callback processing
   - `UIApplication.shared.canOpenURL()` for URL validation

**Verification:**
- Google OAuth method calls correct Supabase SDK methods
- URL validation prevents crashes
- Deep link handling processes all callback scenarios

---

### **Step 6: Testing and Verification**

**Test Scenarios:**
- [ ] Google OAuth initiation opens Safari
- [ ] Google authentication completes successfully
- [ ] Safari redirects back to app
- [ ] App processes callback and creates session
- [ ] User is authenticated and redirected to main app

**Verification Steps:**
1. **Basic Flow Test:**
   - Tap "Sign in with Google" button
   - Verify Safari opens with Google login
   - Complete Google authentication
   - Verify app returns from Safari
   - Check user is authenticated

2. **Error Handling Test:**
   - Test with poor network connection
   - Test with invalid credentials
   - Verify proper error messages displayed

3. **Deep Link Test:**
   - Test callback URL handling
   - Verify session creation
   - Check authentication state persistence

**Success Criteria:**
- Google OAuth completes without errors
- User successfully authenticated
- No crashes or silent failures
- Proper error handling for edge cases

---

## 🍎 **PHASE 2: APPLE SIGN-IN FIX**
*Native ID token exchange flow*

### **Current Problem Analysis**
- "Unacceptable audience in id_token" error
- Using wrong authentication flow (web-based instead of native)
- Missing dual client ID configuration in Supabase
- Inconsistent Apple Sign-In implementations

### **Architecture Decision**
- **Use:** `signInWithIdToken()` (native flow)
- **Why:** Apple Sign-In requires native AuthenticationServices for proper audience handling
- **Flow:** App → Native Apple UI → ID Token + Nonce → Supabase validation

---

### **Step 1: Apple Developer Console Configuration**

**Tasks:**
- [ ] Verify App ID configuration
- [ ] Create/verify Service ID
- [ ] Generate authentication key
- [ ] Configure Sign In with Apple capability

**Required Actions:**
1. **App ID Configuration:**
   - Open Apple Developer Console
   - Navigate to your App ID
   - Verify bundle ID: `com.umursoganci.mealadvisor`
   - Enable "Sign In with Apple" capability
   - Note the exact App ID for Supabase configuration

2. **Service ID Configuration:**
   - Create Service ID: `com.umursoganci.mealadvisor.service`
   - Configure Sign In with Apple
   - Set primary App ID to your main app
   - Configure domains and redirect URLs (if needed)
   - Note the Service ID for Supabase configuration

3. **Authentication Key:**
   - Generate new authentication key
   - Download .p8 key file
   - Note Key ID and Team ID
   - Configure key for Sign In with Apple

**Verification:**
- App ID has Sign In with Apple enabled
- Service ID is properly configured
- Authentication key is generated and downloadable
- All IDs are ready for Supabase configuration

---

### **Step 2: Supabase Dashboard Configuration**

**Tasks:**
- [ ] Configure Apple provider with dual client IDs
- [ ] Set up authentication key
- [ ] Configure redirect URLs

**Required Actions:**
1. **Apple Provider Configuration:**
   - Navigate to Authentication > Providers > Apple
   - **Service ID:** `com.umursoganci.mealadvisor.service`
   - **Secret Key:** [Generated authentication key content]
   - **Authorized Client IDs:** `com.umursoganci.mealadvisor,com.umursoganci.mealadvisor.service`
   - **Redirect URI:** `mealadvisor://auth/callback`

2. **Key Configuration:**
   - Upload the .p8 authentication key
   - Set correct Key ID and Team ID
   - Verify key is active and valid

**Critical Note:** The dual client ID configuration (comma-separated) is essential for resolving the audience mismatch error.

**Verification:**
- Apple provider is enabled
- Dual client ID configuration is set
- Authentication key is properly configured
- Service ID matches Apple Developer Console

---

### **Step 3: Swift Code Implementation**

**Files to Update:**
- `meal.advisor.ios/Services/AuthService.swift`
- `meal.advisor.ios/Views/Components/AppleSignInButton.swift`

**Tasks:**
- [ ] Remove web-based Apple Sign-In implementation
- [ ] Implement native AuthenticationServices flow
- [ ] Add proper nonce generation and validation
- [ ] Update AppleSignInButton to use native flow

**Required Actions:**
1. **Update AuthService.swift:**
   - Remove `signInWithAppleWeb()` method
   - Keep and improve `signInWithApple()` method
   - Implement `signInWithAppleIdToken()` method
   - Add proper nonce generation with `randomNonceString()`
   - Add SHA256 hashing for nonce
   - Implement `ASAuthorizationControllerDelegate`

2. **Update AppleSignInButton.swift:**
   - Change from `signInWithAppleWeb()` to `signInWithApple()`
   - Add proper loading states
   - Implement error handling
   - Add success callbacks

3. **Key Methods to Use:**
   - `ASAuthorizationAppleIDProvider()` for native authentication
   - `signInWithIdToken()` for Supabase session creation
   - `OpenIDConnectCredentials` for token exchange

**Verification:**
- Apple Sign-In uses native AuthenticationServices
- Proper nonce generation and validation
- ID token exchange with Supabase works
- Error handling covers all scenarios

---

### **Step 4: Xcode Project Configuration**

**Files to Update:**
- `meal.advisor.ios.entitlements`
- `meal-advisor-ios-Info.plist`

**Tasks:**
- [ ] Enable Sign In with Apple capability
- [ ] Verify URL scheme configuration
- [ ] Check app permissions

**Required Actions:**
1. **Entitlements Configuration:**
   - Open `meal.advisor.ios.entitlements`
   - Add Sign In with Apple capability:
   ```xml
   <key>com.apple.developer.applesignin</key>
   <array>
       <string>Default</string>
   </array>
   ```

2. **Info.plist Verification:**
   - Ensure URL scheme is still properly configured
   - Verify app can handle Apple Sign-In callbacks

**Verification:**
- Sign In with Apple capability is enabled
- Entitlements file is properly configured
- URL scheme still works for callbacks

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

## 🔄 **PHASE 3: INTEGRATION AND FINAL TESTING**

### **Cross-Provider Testing**

**Tasks:**
- [ ] Test both Google and Apple authentication flows
- [ ] Verify no conflicts between implementations
- [ ] Test authentication state management
- [ ] Verify proper sign-out functionality

**Required Actions:**
1. **Integration Testing:**
   - Test Google OAuth after Apple Sign-In implementation
   - Test Apple Sign-In after Google OAuth implementation
   - Verify both flows work independently
   - Check authentication state consistency

2. **State Management Testing:**
   - Test sign-out from both providers
   - Verify session cleanup
   - Test re-authentication flows
   - Check user data persistence

**Success Criteria:**
- Both authentication methods work independently
- No conflicts between implementations
- Proper state management across providers
- Clean sign-out functionality

---

## 📊 **PROGRESS TRACKING**

### **Phase 1: Google OAuth Fix**
- [ ] Step 1: Apple Developer Console Configuration
- [ ] Step 2: Google Cloud Console Configuration  
- [ ] Step 3: Supabase Dashboard Configuration
- [ ] Step 4: Xcode Project Configuration
- [ ] Step 5: Swift Code Implementation
- [ ] Step 6: Testing and Verification

### **Phase 2: Apple Sign-In Fix**
- [ ] Step 1: Apple Developer Console Configuration
- [ ] Step 2: Supabase Dashboard Configuration
- [ ] Step 3: Swift Code Implementation
- [ ] Step 4: Xcode Project Configuration
- [ ] Step 5: Testing and Verification

### **Phase 3: Integration and Final Testing**
- [ ] Cross-Provider Testing
- [ ] State Management Testing
- [ ] Final Verification

---

## 🎯 **SUCCESS METRICS**

**Google OAuth Success:**
- ✅ Safari opens and Google authentication completes
- ✅ App successfully receives callback from Safari
- ✅ User is authenticated and redirected to main app
- ✅ No crashes or silent failures

**Apple Sign-In Success:**
- ✅ Native Apple authentication UI appears
- ✅ No "Unacceptable audience in id_token" errors
- ✅ ID token exchange with Supabase succeeds
- ✅ User is authenticated and session is created

**Overall Success:**
- ✅ Both authentication methods work reliably
- ✅ Proper error handling and user feedback
- ✅ Clean, maintainable code architecture
- ✅ Production-ready authentication system

---

## 📝 **NOTES**

- **Priority Order:** Complete Google OAuth fix first, then Apple Sign-In
- **Testing:** Test each phase thoroughly before moving to the next
- **Documentation:** Update any relevant documentation after implementation
- **Backup:** Keep current implementation as backup until new system is verified

---

**Created:** [Current Date]  
**Status:** Planning Phase  
**Next Action:** Begin Phase 1, Step 1 (Apple Developer Console Configuration)
