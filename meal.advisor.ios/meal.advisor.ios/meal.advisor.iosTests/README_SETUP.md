# 🧪 Unit Tests - Setup Guide

## 📁 Test Files Created

✅ **ServiceTests/MealServiceTests.swift** (8 tests)  
✅ **ServiceTests/UsageTrackingServiceTests.swift** (11 tests)  
✅ **ServiceTests/PurchaseServiceTests.swift** (9 tests)

**Total**: 28 unit tests covering critical business logic

---

## 🚀 How to Add to Xcode (2 Minutes)

### **Step 1: Create Test Target in Xcode**

1. Open `meal.advisor.ios.xcodeproj` in Xcode
2. Select project in Navigator (top blue icon)
3. Click **"+"** at bottom of target list
4. Choose **"iOS Unit Testing Bundle"**
5. Name it: `meal.advisor.iosTests`
6. Click **Finish**

### **Step 2: Add Test Files to Target**

1. In Xcode, **File → Add Files to "meal.advisor.ios"**
2. Navigate to `meal.advisor.iosTests/` folder
3. Select all `.swift` files
4. ✅ Check **"Copy items if needed"**
5. ✅ Check **"meal.advisor.iosTests"** target
6. Click **Add**

### **Step 3: Configure Test Target**

1. Select `meal.advisor.iosTests` target
2. **Build Settings** → Search for "Test Host"
3. Set **Test Host**: `$(BUILT_PRODUCTS_DIR)/meal.advisor.ios.app/meal.advisor.ios`
4. **Build Phases** → **Link Binary With Libraries**
5. Add `XCTest.framework` if not already present

### **Step 4: Run Tests**

```bash
# In Xcode:
⌘ + U  (Run all tests)

# Or use Test Navigator:
⌘ + 6  → Click ▶️ next to test file
```

---

## 🧪 What Gets Tested

### **MealService** (8 tests):
- ✅ Initial state is idle
- ✅ Loading state sets correctly
- ✅ Meal rating updates preferences
- ✅ Get rating returns correct value
- ✅ Rating stats count correctly
- ✅ Offline status returns valid data
- ✅ Offline suggestions check availability

### **UsageTrackingService** (11 tests):
- ✅ Initial state is zero
- ✅ Remaining count calculates correctly
- ✅ Computed properties work (progress, canGenerate)
- ✅ State at limit behaves correctly
- ✅ Reset counter clears state
- ✅ Remaining count never negative
- ✅ Usage description formats correctly
- ✅ State equality works

### **PurchaseService** (9 tests):
- ✅ Subscription status isPremium logic
- ✅ Initial state is defined
- ✅ Product IDs are correct
- ✅ Get product by ID works
- ✅ Purchase tracking works
- ✅ Active subscription returns product
- ✅ Expiration date logic

---

## ⚡ Quick Start (Terminal)

If Xcode test target already configured:

```bash
cd meal.advisor.ios

# Run all tests
xcodebuild test \
  -project meal.advisor.ios.xcodeproj \
  -scheme meal.advisor.ios \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test
xcodebuild test \
  -project meal.advisor.ios.xcodeproj \
  -scheme meal.advisor.ios \
  -only-testing:meal.advisor.iosTests/MealServiceTests
```

---

## 📊 Expected Results

**First Run**: Some tests may fail if:
- ❌ Supabase not configured (network tests)
- ❌ StoreKit not configured (purchase tests)
- ⚠️ Test target not properly linked

**After Setup**: Most tests should pass
- ✅ State management tests (always pass)
- ✅ Rating tests (always pass)
- ✅ Computed property tests (always pass)
- ⚠️ Network tests (may fail without API keys)

---

## 🎯 Next Steps

1. Add tests to Xcode (2 min)
2. Run tests with ⌘+U
3. Fix any failing tests
4. Add more tests as needed
5. Aim for 60%+ code coverage

**Target Coverage**: 60-70% for critical services ✅

---

## 💡 Tips

- Tests run in simulator (no real device needed)
- Use breakpoints in tests for debugging
- Check Test Navigator (⌘+6) for results
- Green ✅ = Pass, Red ❌ = Fail
- Code coverage: Editor → Show Code Coverage

Ready to test! 🚀

