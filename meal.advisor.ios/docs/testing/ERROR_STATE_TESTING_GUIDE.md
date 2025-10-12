# 🧪 Error State Testing - Comprehensive Guide

**Task**: #13 - Error State Testing  
**Priority**: HIGH (Most critical for launch)  
**Estimated Time**: 45 minutes  
**Goal**: Verify app handles all failure scenarios gracefully

---

## 📋 TESTING CHECKLIST

### ✅ = Tested & Passed | ❌ = Failed | ⏳ = Not Tested

---

## 🌐 SECTION 1: NETWORK ERROR STATES (20 min)

### **Test 1.1: Airplane Mode (Offline)**

**Setup**: Enable airplane mode in simulator/device

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Launch app in airplane mode | App opens successfully, no crash | ⏳ |
| 2 | Tap "Show Another" | Shows offline banner "No internet connection" | ⏳ |
| 3 | Check if cached meals display | If cached meals exist, one should appear | ⏳ |
| 4 | Verify offline indicator | Top-right corner shows offline indicator | ⏳ |
| 5 | Navigate to Favorites | Shows appropriate message or cached data | ⏳ |
| 6 | Navigate to Settings | Settings screen loads normally | ⏳ |
| 7 | Try to sign in | Shows "No internet" error, doesn't crash | ⏳ |
| 8 | Disable airplane mode | Offline indicator disappears, app reconnects | ⏳ |
| 9 | Tap "Show Another" again | New suggestion loads from network | ⏳ |

**Expected Behaviors**:
- ✅ No crashes or freezes
- ✅ Clear offline messaging
- ✅ Cached meals work as fallback
- ✅ Graceful reconnection when online

---

### **Test 1.2: Slow Network (3G Speed)**

**Setup**: Settings → Developer → Network Link Conditioner → 3G

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Enable 3G simulation | - | ⏳ |
| 2 | Tap "Show Another" | Loading spinner appears | ⏳ |
| 3 | Wait for suggestion | Loads within 10s (or timeout message) | ⏳ |
| 4 | Check image loading | Shimmer shows, image loads gradually | ⏳ |
| 5 | Rapid tap "Show Another" 3x | App doesn't freeze or crash | ⏳ |

**Expected Behaviors**:
- ✅ Loading states visible during slow requests
- ✅ No UI freezing
- ✅ Images load progressively with placeholder

---

### **Test 1.3: API Timeout**

**Setup**: Slow network OR Supabase Edge Function delay

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Simulate very slow network | - | ⏳ |
| 2 | Tap "Show Another" | Loading state appears | ⏳ |
| 3 | Wait 15+ seconds | Timeout error OR fallback meal | ⏳ |
| 4 | Check error message | User-friendly message (not technical) | ⏳ |
| 5 | Tap "Try Again" | Retry works correctly | ⏳ |

**Expected Behaviors**:
- ✅ Timeout handled gracefully (no infinite loading)
- ✅ Fallback to cached meals if available
- ✅ Clear error message + retry option

---

### **Test 1.4: Supabase API Failure**

**Setup**: Invalid API key OR Supabase service down

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Temporarily break Supabase URL | Edit Config.xcconfig with invalid URL | ⏳ |
| 2 | Rebuild and run app | App launches (doesn't crash on init) | ⏳ |
| 3 | Tap "Show Another" | Shows error OR uses offline fallback | ⏳ |
| 4 | Check error message | "Unable to connect to servers" (not "401 Unauthorized") | ⏳ |
| 5 | Restore correct URL | Fix Config.xcconfig | ⏳ |
| 6 | Rebuild, tap "Show Another" | Works normally again | ⏳ |

**Expected Behaviors**:
- ✅ App doesn't crash on Supabase errors
- ✅ User-friendly error messages
- ✅ Offline fallback works

---

## 📦 SECTION 2: EMPTY STATE SCENARIOS (10 min)

### **Test 2.1: First Launch (No Data)**

**Setup**: Fresh install OR delete app and reinstall

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Delete and reinstall app | - | ⏳ |
| 2 | Launch app first time | Shows welcome/empty state | ⏳ |
| 3 | Home screen | Shows "No Suggestions Yet" placeholder | ⏳ |
| 4 | Tap "Get New Suggestion" | Loads first meal successfully | ⏳ |
| 5 | Navigate to Favorites | Shows "Sign In to Save Favorites" | ⏳ |
| 6 | Navigate to Settings | Shows default preferences | ⏳ |

**Expected Behaviors**:
- ✅ No crashes on fresh install
- ✅ Clear empty state messaging
- ✅ CTA buttons guide user

---

### **Test 2.2: No Cached Meals + Offline**

**Setup**: Clear app data, then go offline

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Clear app data (Settings → Reset) | - | ⏳ |
| 2 | Enable airplane mode | - | ⏳ |
| 3 | Tap "Show Another" | Shows "No internet + no cached meals" error | ⏳ |
| 4 | Error is user-friendly | Not technical jargon | ⏳ |
| 5 | Provides guidance | "Connect to internet to get suggestions" | ⏳ |

**Expected Behaviors**:
- ✅ Clear explanation of problem
- ✅ Actionable guidance
- ✅ No crash

---

### **Test 2.3: Zero Favorites**

**Setup**: Premium user with no favorites yet

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Sign in + have premium | - | ⏳ |
| 2 | Navigate to Favorites tab | Shows empty state with illustration | ⏳ |
| 3 | Empty state message | "No favorites yet. Save meals you love!" | ⏳ |
| 4 | CTA visible | Encourages user to explore and save | ⏳ |

**Expected Behaviors**:
- ✅ Beautiful empty state (not just blank screen)
- ✅ Encourages user action

---

## 🚫 SECTION 3: QUOTA & PREMIUM ERRORS (10 min)

### **Test 3.1: Free User Hits 5/5 Limit**

**Setup**: Use 5 suggestions as free user

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Generate 5 suggestions | Counter shows 5/5 | ⏳ |
| 2 | Tap "Show Another" (6th time) | Paywall appears, NOT error | ⏳ |
| 3 | Tap "Maybe Later" | Returns to home, can't generate | ⏳ |
| 4 | Counter shows 5/5 | Badge shows 0 remaining | ⏳ |
| 5 | Error message clear | "Daily limit reached. Upgrade for unlimited" | ⏳ |

**Expected Behaviors**:
- ✅ Quota enforced correctly
- ✅ Paywall shown (not generic error)
- ✅ Clear messaging about premium benefit

---

### **Test 3.2: Premium User After Subscription Expires**

**Setup**: Cancel subscription, wait for expiration (or simulate)

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Premium expires mid-session | App doesn't crash | ⏳ |
| 2 | Try to save favorite | Shows paywall OR sign-in prompt | ⏳ |
| 3 | Usage quota reinstated | Free tier limit (5/day) applies | ⏳ |
| 4 | Previously saved favorites | Should still be accessible (view only) | ⏳ |

**Expected Behaviors**:
- ✅ Graceful premium → free downgrade
- ✅ No data loss
- ✅ Clear messaging

---

### **Test 3.3: Favorites Access (Non-Premium)**

**Setup**: Free user tries to access favorites

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Navigate to Favorites tab | Shows premium required message | ⏳ |
| 2 | Tap "Upgrade to Premium" | Paywall opens | ⏳ |
| 3 | Try to save favorite from home | Shows premium gate OR sign-in first | ⏳ |

**Expected Behaviors**:
- ✅ Premium features properly gated
- ✅ Clear upgrade path

---

## 🖼️ SECTION 4: IMAGE LOADING ERRORS (5 min)

### **Test 4.1: Unsplash API Failure**

**Setup**: Invalid Unsplash API key OR rate limit hit

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Break Unsplash API key (temporarily) | - | ⏳ |
| 2 | Tap "Show Another" | Meal still appears (without image) | ⏳ |
| 3 | Image area shows | Shimmer OR placeholder icon | ⏳ |
| 4 | No error message | Image failure is silent (non-critical) | ⏳ |
| 5 | Meal is usable | Can view recipe, save, rate | ⏳ |

**Expected Behaviors**:
- ✅ Meal displays even without image
- ✅ Graceful degradation (shimmer/placeholder)
- ✅ No user-facing error

---

### **Test 4.2: Image Load Timeout**

**Setup**: Very slow network for images

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Enable slow network | - | ⏳ |
| 2 | Generate suggestion | Meal appears with shimmer | ⏳ |
| 3 | Wait for image | Image eventually loads OR times out gracefully | ⏳ |
| 4 | Navigate away during load | No crash when changing screens | ⏳ |

**Expected Behaviors**:
- ✅ Meal usable before image loads
- ✅ Navigation doesn't break image loading
- ✅ No memory leaks from cancelled loads

---

## 🔐 SECTION 5: AUTHENTICATION ERRORS (5 min)

### **Test 5.1: Sign In with Apple Cancellation**

**Setup**: Start sign-in flow, then cancel

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Tap "Sign In with Apple" | Apple sign-in sheet appears | ⏳ |
| 2 | Tap "Cancel" | Sheet dismisses, no error shown | ⏳ |
| 3 | App state | Returns to previous screen normally | ⏳ |
| 4 | No error message | Cancellation is silent (expected behavior) | ⏳ |

**Expected Behaviors**:
- ✅ Cancellation handled gracefully
- ✅ No error message for user-initiated cancel
- ✅ App remains functional

---

### **Test 5.2: Sign In Failure**

**Setup**: Invalid credentials OR network error during auth

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Try to sign in (email) | - | ⏳ |
| 2 | Enter invalid password | Shows "Invalid credentials" error | ⏳ |
| 3 | Error message | User-friendly, not technical | ⏳ |
| 4 | Can retry | Sign-in form still accessible | ⏳ |

**Expected Behaviors**:
- ✅ Clear error messaging
- ✅ User can retry
- ✅ No crash on auth failure

---

## 💾 SECTION 6: DATA PERSISTENCE ERRORS (5 min)

### **Test 6.1: Storage Full / Write Failure**

**Setup**: Simulate disk full (hard to test, but check error handling)

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Save preferences repeatedly | Should work normally | ⏳ |
| 2 | Check console for errors | Logs any storage errors | ⏳ |
| 3 | App continues working | Doesn't crash on save failure | ⏳ |

**Expected Behaviors**:
- ✅ Graceful handling of storage errors
- ✅ App doesn't crash
- ✅ Errors logged for debugging

---

### **Test 6.2: Corrupted Cache Data**

**Setup**: Manually corrupt cached meal file

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Generate some suggestions (cache meals) | - | ⏳ |
| 2 | Force quit app | - | ⏳ |
| 3 | Corrupt cache file manually (if possible) | - | ⏳ |
| 4 | Relaunch app | App launches, ignores corrupt cache | ⏳ |
| 5 | Tap "Show Another" | Fetches fresh from network | ⏳ |

**Expected Behaviors**:
- ✅ Corrupted cache doesn't crash app
- ✅ Fallback to network fetch
- ✅ Logs error but continues

---

## 🔄 SECTION 7: STATE TRANSITION ERRORS (10 min)

### **Test 7.1: Background App During Suggestion Load**

**Setup**: Generate suggestion, immediately background app

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Tap "Show Another" | Loading starts | ⏳ |
| 2 | Immediately press Home (background app) | - | ⏳ |
| 3 | Wait 5 seconds | - | ⏳ |
| 4 | Return to app | Shows meal OR shows error (not stuck loading) | ⏳ |
| 5 | Loading state cleared | Not stuck in loading state | ⏳ |

**Expected Behaviors**:
- ✅ Background doesn't break loading
- ✅ State resolves properly
- ✅ No stuck loading spinners

---

### **Test 7.2: Force Quit During Network Call**

**Setup**: Generate suggestion, force quit immediately

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Tap "Show Another" | Loading starts | ⏳ |
| 2 | Force quit app (swipe up in app switcher) | - | ⏳ |
| 3 | Relaunch app | App opens normally, shows last successful suggestion | ⏳ |
| 4 | No stuck state | Not stuck in loading state | ⏳ |
| 5 | Can generate new suggestion | Works normally | ⏳ |

**Expected Behaviors**:
- ✅ Clean state restoration
- ✅ No corrupted state
- ✅ App functional after force quit

---

### **Test 7.3: Rapid Tapping "Show Another"**

**Setup**: Normal network

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Tap "Show Another" 10 times rapidly | - | ⏳ |
| 2 | App behavior | Handles gracefully (queues or shows latest) | ⏳ |
| 3 | No duplicate meals | Each tap shows different meal | ⏳ |
| 4 | No crash or freeze | App stays responsive | ⏳ |
| 5 | Quota counted correctly | Usage doesn't overcoun (check counter) | ⏳ |

**Expected Behaviors**:
- ✅ Race condition prevented (already fixed in code)
- ✅ No crashes
- ✅ Quota accurate

---

## 🎯 SECTION 8: QUOTA EDGE CASES (5 min)

### **Test 8.1: Exactly at 5/5 Limit**

**Setup**: Use exactly 5 suggestions

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Generate 4 suggestions | Counter: 4/5 | ⏳ |
| 2 | Generate 5th suggestion | Counter: 5/5, meal shown | ⏳ |
| 3 | Tap "Show Another" (6th) | Paywall appears | ⏳ |
| 4 | Dismiss paywall | Can't generate more suggestions | ⏳ |
| 5 | Wait until midnight | Counter resets to 0/5 | ⏳ |

**Expected Behaviors**:
- ✅ Limit enforced at exactly 5
- ✅ Paywall triggers correctly
- ✅ Midnight reset works

---

### **Test 8.2: Counter Sync After Reinstall**

**Setup**: Use 3 suggestions, delete app, reinstall

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Generate 3 suggestions (signed in) | Counter: 3/5 | ⏳ |
| 2 | Delete app | - | ⏳ |
| 3 | Reinstall app | - | ⏳ |
| 4 | Sign in again | - | ⏳ |
| 5 | Check counter | Should show 3/5 (synced from server) | ⏳ |

**Expected Behaviors**:
- ✅ Server sync works
- ✅ Counter persists after reinstall (for signed-in users)
- ✅ Anonymous users start fresh (0/5)

---

## 🎨 SECTION 9: UI ERROR STATES (5 min)

### **Test 9.1: Preferences with No Matching Meals**

**Setup**: Set impossible preferences (e.g., Vegan + High Protein + 5 min prep)

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Set strict preferences | Example: Vegan + No Carbs + 10 min | ⏳ |
| 2 | Tap "Show Another" | Shows "No meals match your preferences" | ⏳ |
| 3 | Error message | Suggests adjusting settings | ⏳ |
| 4 | Provides action | "Adjust Settings" button | ⏳ |

**Expected Behaviors**:
- ✅ Handles no-match scenario
- ✅ Helpful guidance
- ✅ Easy to adjust preferences

---

### **Test 9.2: Recipe Detail Loading Failure**

**Setup**: Open recipe detail for meal

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Tap "See Recipe" | Recipe detail opens | ⏳ |
| 2 | All data displays | Ingredients, instructions, nutrition | ⏳ |
| 3 | Image missing | Shows placeholder gracefully | ⏳ |

**Expected Behaviors**:
- ✅ Recipe readable without image
- ✅ All text content displays

---

## ⚙️ SECTION 10: SUBSCRIPTION ERRORS (5 min)

### **Test 10.1: Purchase Failure**

**Setup**: Attempt purchase with issues

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Open paywall | Shows subscription options | ⏳ |
| 2 | Select plan, tap Subscribe | StoreKit sheet appears | ⏳ |
| 3 | Cancel purchase | Returns to paywall, shows no error | ⏳ |
| 4 | Try with airplane mode | Shows "No internet" error | ⏳ |

**Expected Behaviors**:
- ✅ Purchase cancellation handled gracefully
- ✅ Network errors shown clearly
- ✅ User can retry

---

### **Test 10.2: Restore Purchases (Nothing to Restore)**

**Setup**: Tap "Restore Purchases" with no previous purchases

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Open paywall | - | ⏳ |
| 2 | Tap "Restore Purchases" | Loading indicator | ⏳ |
| 3 | Wait for response | Shows "No previous purchases found" | ⏳ |
| 4 | Message is clear | Not technical error | ⏳ |

**Expected Behaviors**:
- ✅ Clear messaging
- ✅ No crash
- ✅ User can try purchasing instead

---

## 📱 SECTION 11: APP LIFECYCLE ERRORS (5 min)

### **Test 11.1: App Launch After iOS Update**

**Setup**: Simulate app update OR iOS version change

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Launch app | Opens successfully | ⏳ |
| 2 | Check preferences | All settings preserved | ⏳ |
| 3 | Check favorites | All favorites intact | ⏳ |
| 4 | Generate suggestion | Works normally | ⏳ |

**Expected Behaviors**:
- ✅ Data migrations handle version changes
- ✅ No data loss
- ✅ Backward compatibility

---

### **Test 11.2: Memory Warning Handling**

**Setup**: Run app with other memory-heavy apps

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Open 5-10 other apps | Fill device memory | ⏳ |
| 2 | Return to MealAdvisor | App still responsive | ⏳ |
| 3 | Generate suggestion | Works (may reload from background) | ⏳ |
| 4 | Check for crash | No crash or data loss | ⏳ |

**Expected Behaviors**:
- ✅ Handles memory pressure
- ✅ Clears caches if needed
- ✅ No crash

---

## 🔍 SECTION 12: EDGE CASES (5 min)

### **Test 12.1: Date Change (Midnight)**

**Setup**: Change device time to cross midnight

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Use 3 suggestions (counter: 3/5) | - | ⏳ |
| 2 | Change device time to next day | Settings → General → Date & Time | ⏳ |
| 3 | Return to app | - | ⏳ |
| 4 | Check counter | Should reset to 0/5 | ⏳ |
| 5 | Generate suggestion | Counter increments from 0 | ⏳ |

**Expected Behaviors**:
- ✅ Midnight reset works
- ✅ Counter resets correctly
- ✅ Date change detected

---

### **Test 12.2: Conflicting Preferences**

**Setup**: Set preferences that conflict

| Step | Action | Expected Result | Status |
|------|--------|-----------------|--------|
| 1 | Select all cuisines | - | ⏳ |
| 2 | Set "No Pork" restriction | - | ⏳ |
| 3 | Set 10-minute max cooking time | - | ⏳ |
| 4 | Generate suggestion | Shows meal matching all criteria OR helpful error | ⏳ |

**Expected Behaviors**:
- ✅ Backend handles conflicts intelligently
- ✅ OR shows "Too restrictive" message

---

## 📊 TESTING RESULTS TEMPLATE

```
===========================================
ERROR STATE TESTING - RESULTS
===========================================

Test Date: _______________
Tester: _______________
Device: _______________ (iPhone 15, iOS 18.0)

SECTION 1: Network Errors
[ ] 1.1 Airplane Mode - PASS/FAIL
[ ] 1.2 Slow Network - PASS/FAIL  
[ ] 1.3 API Timeout - PASS/FAIL
[ ] 1.4 Supabase Failure - PASS/FAIL

SECTION 2: Empty States
[ ] 2.1 First Launch - PASS/FAIL
[ ] 2.2 No Cache + Offline - PASS/FAIL
[ ] 2.3 Zero Favorites - PASS/FAIL

SECTION 3: Quota Errors
[ ] 3.1 Hit 5/5 Limit - PASS/FAIL
[ ] 3.2 Premium Expires - PASS/FAIL
[ ] 3.3 Favorites Access - PASS/FAIL

SECTION 4: Image Errors
[ ] 4.1 Unsplash Failure - PASS/FAIL
[ ] 4.2 Image Timeout - PASS/FAIL

SECTION 5: Auth Errors
[ ] 5.1 Sign-In Cancel - PASS/FAIL
[ ] 5.2 Sign-In Failure - PASS/FAIL

SECTION 6: Data Errors
[ ] 6.1 Storage Full - PASS/FAIL
[ ] 6.2 Corrupt Cache - PASS/FAIL

SECTION 7: State Transitions
[ ] 7.1 Background During Load - PASS/FAIL
[ ] 7.2 Force Quit - PASS/FAIL
[ ] 7.3 Rapid Tapping - PASS/FAIL

SECTION 8: Quota Edge Cases
[ ] 8.1 Exactly 5/5 - PASS/FAIL
[ ] 8.2 Counter Sync - PASS/FAIL

SECTION 9: UI Errors
[ ] 9.1 No Matching Meals - PASS/FAIL
[ ] 9.2 Recipe Load Fail - PASS/FAIL

SECTION 10: Subscription
[ ] 10.1 Purchase Failure - PASS/FAIL
[ ] 10.2 Restore (Nothing) - PASS/FAIL

SECTION 11: Lifecycle
[ ] 11.1 After iOS Update - PASS/FAIL
[ ] 11.2 Memory Warning - PASS/FAIL

SECTION 12: Edge Cases
[ ] 12.1 Midnight Reset - PASS/FAIL
[ ] 12.2 Conflicting Prefs - PASS/FAIL

===========================================
TOTAL: ___/31 PASSED
CRITICAL FAILURES: ___
MINOR ISSUES: ___
===========================================

NOTES:
_________________________________________
_________________________________________
```

---

## 🚨 CRITICAL VS. MINOR FAILURES

### **CRITICAL** (Must Fix Before Launch):
- ❌ App crashes
- ❌ Infinite loading states
- ❌ Data loss
- ❌ Security issues
- ❌ Payment processing broken

### **MINOR** (Can Ship With):
- ⚠️ Suboptimal error messages
- ⚠️ Missing empty states
- ⚠️ Slow performance in edge cases
- ⚠️ UI glitches (non-blocking)

---

## 🎯 QUICK TEST MODE (15 Minutes)

If you're short on time, test these **critical scenarios only**:

```
✅ MUST TEST (15 min):
1. [ ] Airplane mode → Tap "Show Another" (offline handling)
2. [ ] Use 5 suggestions → Tap 6th time (quota enforcement)
3. [ ] Force quit during loading → Reopen (state recovery)
4. [ ] Delete & reinstall → First launch (fresh install)
5. [ ] Background during load → Return (background handling)
6. [ ] Rapid tap 10 times (race conditions)
7. [ ] Cancel Sign-In with Apple (cancellation handling)
```

These 7 tests cover 80% of potential issues.

---

## 🛠️ TESTING TOOLS

### **Enable Offline Mode**:
```
Simulator: Airplane mode toggle
Device: Control Center → Airplane mode
```

### **Network Link Conditioner** (Slow Network):
```
Settings → Developer → Network Link Conditioner → 3G
(May need to enable Developer mode first)
```

### **Force Quit**:
```
Swipe up from bottom → Swipe app up
```

### **Check Console Logs**:
```
Xcode → View → Debug Area → Show Debug Area (⌘⇧Y)
Filter for: 🍽️, ⚠️, ❌ (emoji prefixes in your logs)
```

### **Memory Testing**:
```
Xcode → Debug Navigator → Memory
Watch for spikes during error scenarios
```

---

## 📝 HOW TO USE THIS GUIDE

### **Option 1: Full Test** (45 min)
- Go through all 31 tests
- Document results
- Fix any failures

### **Option 2: Quick Test** (15 min)
- Run "MUST TEST" scenarios (7 tests)
- Fix critical issues only

### **Option 3: Automated** (Future)
- Convert to XCUITests
- Run in CI/CD

---

## ✅ AFTER TESTING

Once all tests pass:

1. Mark task #13 as **✅ Complete** in checklist
2. Document any issues found (and fixed)
3. Ready for App Store submission!

---

## 🎯 EXPECTED RESULT

**Goal**: 100% of tests should PASS

Your code quality is high based on today's work:
- ✅ Thread-safe operations
- ✅ Graceful error handling already implemented
- ✅ Offline fallbacks in place
- ✅ State management solid

**Prediction**: You'll pass 28-30/31 tests on first try! 🎉

---

**Ready to start testing?** Follow the checklist section by section and report any failures! 🚀

