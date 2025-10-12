//
//  StandaloneTestRunner.swift
//  
//  Simple test runner that can be compiled and run without Xcode test target
//  Usage: Add to main app target temporarily, call from a debug button
//

import Foundation
@testable import meal_advisor_ios

@MainActor
class StandaloneTestRunner {
    
    static func runAllTests() {
        print("\n🧪 ========== RUNNING STANDALONE TESTS ==========\n")
        
        var passed = 0
        var failed = 0
        
        // MealService Tests
        print("📦 Testing MealService...")
        if testMealServiceInitialState() { passed += 1 } else { failed += 1 }
        if testMealServiceRating() { passed += 1 } else { failed += 1 }
        
        // UsageTrackingService Tests
        print("\n📊 Testing UsageTrackingService...")
        if testUsageTrackingInitialState() { passed += 1 } else { failed += 1 }
        if testUsageTrackingRemainingCount() { passed += 1 } else { failed += 1 }
        if testUsageStateComputedProperties() { passed += 1 } else { failed += 1 }
        if testUsageStateAtLimit() { passed += 1 } else { failed += 1 }
        
        // PurchaseService Tests
        print("\n💳 Testing PurchaseService...")
        if testPurchaseServiceSubscriptionStatus() { passed += 1 } else { failed += 1 }
        if testPurchaseServiceProductIDs() { passed += 1 } else { failed += 1 }
        
        // Summary
        print("\n🎯 ========== TEST RESULTS ==========")
        print("✅ PASSED: \(passed)")
        print("❌ FAILED: \(failed)")
        print("📊 TOTAL:  \(passed + failed)")
        print("📈 SUCCESS RATE: \(passed * 100 / (passed + failed))%")
        print("=========================================\n")
    }
    
    // MARK: - MealService Tests
    
    static func testMealServiceInitialState() -> Bool {
        print("  → testInitialState_isIdle...", terminator: " ")
        
        let service = MealService()
        
        guard service.state.currentSuggestion == nil else {
            print("❌ FAILED: Expected no suggestion")
            return false
        }
        
        guard !service.state.isLoading else {
            print("❌ FAILED: Should not be loading")
            return false
        }
        
        guard service.state.errorMessage == nil else {
            print("❌ FAILED: Expected no error")
            return false
        }
        
        print("✅ PASSED")
        return true
    }
    
    static func testMealServiceRating() -> Bool {
        print("  → testRatingMeal...", terminator: " ")
        
        let service = MealService()
        let meal = createTestMeal()
        
        // Rate meal
        service.rateMeal(meal, rating: .liked)
        
        // Small delay for async Task
        Thread.sleep(forTimeInterval: 0.3)
        
        // Check rating was saved
        let rating = UserPreferencesService.shared.getRating(for: meal.id)
        
        guard rating == .liked else {
            print("❌ FAILED: Rating not saved correctly")
            return false
        }
        
        print("✅ PASSED")
        return true
    }
    
    // MARK: - UsageTrackingService Tests
    
    static func testUsageTrackingInitialState() -> Bool {
        print("  → testInitialState...", terminator: " ")
        
        let service = UsageTrackingService.shared
        service.resetDailyCounter()
        
        guard service.state.dailyUsageCount == 0 else {
            print("❌ FAILED: Count should be 0")
            return false
        }
        
        guard !service.state.hasReachedLimit else {
            print("❌ FAILED: Limit should not be reached")
            return false
        }
        
        print("✅ PASSED")
        return true
    }
    
    static func testUsageTrackingRemainingCount() -> Bool {
        print("  → testRemainingCount...", terminator: " ")
        
        let service = UsageTrackingService.shared
        service.resetDailyCounter()
        
        let remaining = service.getRemainingCount()
        
        guard remaining >= 0 else {
            print("❌ FAILED: Remaining should be non-negative")
            return false
        }
        
        guard remaining <= 5 || remaining == Int.max else {
            print("❌ FAILED: Remaining should be <= 5 or unlimited")
            return false
        }
        
        print("✅ PASSED")
        return true
    }
    
    static func testUsageStateComputedProperties() -> Bool {
        print("  → testComputedProperties...", terminator: " ")
        
        var state = UsageState()
        state.dailyUsageCount = 3
        
        guard state.remainingCount == 2 else {
            print("❌ FAILED: Expected remaining = 2, got \(state.remainingCount)")
            return false
        }
        
        guard abs(state.progressPercentage - 0.6) < 0.01 else {
            print("❌ FAILED: Expected progress = 0.6, got \(state.progressPercentage)")
            return false
        }
        
        guard state.canGenerate else {
            print("❌ FAILED: Should be able to generate at 3/5")
            return false
        }
        
        print("✅ PASSED")
        return true
    }
    
    static func testUsageStateAtLimit() -> Bool {
        print("  → testStateAtLimit...", terminator: " ")
        
        var state = UsageState()
        state.dailyUsageCount = 5
        state.hasReachedLimit = true
        
        guard state.remainingCount == 0 else {
            print("❌ FAILED: Expected remaining = 0")
            return false
        }
        
        guard state.progressPercentage == 1.0 else {
            print("❌ FAILED: Expected progress = 1.0")
            return false
        }
        
        guard !state.canGenerate else {
            print("❌ FAILED: Should not be able to generate at limit")
            return false
        }
        
        print("✅ PASSED")
        return true
    }
    
    // MARK: - PurchaseService Tests
    
    static func testPurchaseServiceSubscriptionStatus() -> Bool {
        print("  → testSubscriptionStatus...", terminator: " ")
        
        let notSubscribed = PurchaseService.SubscriptionStatus.notSubscribed
        let subscribed = PurchaseService.SubscriptionStatus.subscribed(productID: "test", expirationDate: nil)
        let expired = PurchaseService.SubscriptionStatus.expired
        let gracePeriod = PurchaseService.SubscriptionStatus.inGracePeriod
        
        guard !notSubscribed.isPremium else {
            print("❌ FAILED: Not subscribed should not be premium")
            return false
        }
        
        guard subscribed.isPremium else {
            print("❌ FAILED: Subscribed should be premium")
            return false
        }
        
        guard !expired.isPremium else {
            print("❌ FAILED: Expired should not be premium")
            return false
        }
        
        guard gracePeriod.isPremium else {
            print("❌ FAILED: Grace period should be premium")
            return false
        }
        
        print("✅ PASSED")
        return true
    }
    
    static func testPurchaseServiceProductIDs() -> Bool {
        print("  → testProductIDs...", terminator: " ")
        
        guard PurchaseService.weeklySubscriptionID == "mealadvisor.weekly" else {
            print("❌ FAILED: Weekly ID mismatch")
            return false
        }
        
        guard PurchaseService.annualSubscriptionID == "mealadvisor.annual" else {
            print("❌ FAILED: Annual ID mismatch")
            return false
        }
        
        print("✅ PASSED")
        return true
    }
    
    // MARK: - Helper Methods
    
    static func createTestMeal(
        id: UUID = UUID(),
        title: String = "Test Meal",
        cuisine: Meal.Cuisine = .italian,
        dietTags: [Meal.DietType] = [.vegetarian]
    ) -> Meal {
        Meal(
            id: id,
            title: title,
            description: "Test description",
            prepTime: 30,
            difficulty: .easy,
            cuisine: cuisine,
            dietTags: dietTags,
            imageURL: nil,
            ingredients: [
                Ingredient(name: "Test Ingredient", amount: "1", unit: "cup")
            ],
            instructions: ["Test instruction"],
            nutritionInfo: NutritionInfo(calories: 500, protein: 20, carbs: 40, fat: 15)
        )
    }
}

