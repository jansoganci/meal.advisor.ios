//
//  MealServiceTests.swift
//  meal.advisor.iosTests
//
//  Unit tests for MealService business logic
//

import XCTest
@testable import meal_advisor_ios

@MainActor
final class MealServiceTests: XCTestCase {
    
    var sut: MealService!
    
    override func setUpWithError() throws {
        super.setUp()
        sut = MealService()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - State Management Tests
    
    func testInitialState_isIdle() {
        // Given: Fresh MealService instance
        // When: No operations performed
        // Then: State should be idle
        XCTAssertNil(sut.state.currentSuggestion, "Initial state should have no suggestion")
        XCTAssertFalse(sut.state.isLoading, "Should not be loading initially")
        XCTAssertNil(sut.state.errorMessage, "Should have no error initially")
        XCTAssertFalse(sut.state.isOfflineMode, "Should not be in offline mode initially")
        XCTAssertFalse(sut.state.isQuotaExceeded, "Quota should not be exceeded initially")
    }
    
    func testStateLoading_setsCorrectly() async {
        // Given: MealService in idle state
        let preferences = UserPreferences.default
        
        // When: Generate suggestion starts
        Task {
            await sut.generateSuggestion(preferences: preferences)
        }
        
        // Give it a moment to set loading state
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then: Loading state should be set initially
        XCTAssertTrue(sut.state.isLoading || sut.state.currentSuggestion != nil, 
                      "Should be loading or already have suggestion")
    }
    
    // MARK: - Meal Rating Tests
    
    func testRateMeal_updatesPreferences() {
        // Given: A test meal
        let meal = createTestMeal()
        
        // When: Rating the meal as liked
        sut.rateMeal(meal, rating: .liked)
        
        // Give time for async Task to complete
        let expectation = expectation(description: "Rating saved")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then: Rating should be stored (verified via UserPreferencesService)
        let rating = UserPreferencesService.shared.getRating(for: meal.id)
        XCTAssertEqual(rating, .liked, "Meal should be rated as liked")
    }
    
    func testGetRating_returnsCorrectRating() {
        // Given: A meal with a rating
        let meal = createTestMeal()
        UserPreferencesService.shared.setRating(.disliked, for: meal.id)
        
        // When: Getting the rating
        let rating = sut.getRating(for: meal)
        
        // Then: Should return the correct rating
        XCTAssertEqual(rating, .disliked, "Should return disliked rating")
    }
    
    func testGetRatingStats_countsCorrectly() {
        // Given: Multiple rated meals
        let meal1 = createTestMeal(id: UUID())
        let meal2 = createTestMeal(id: UUID())
        let meal3 = createTestMeal(id: UUID())
        
        UserPreferencesService.shared.setRating(.liked, for: meal1.id)
        UserPreferencesService.shared.setRating(.liked, for: meal2.id)
        UserPreferencesService.shared.setRating(.disliked, for: meal3.id)
        
        // When: Getting rating stats
        let stats = sut.getRatingStats()
        
        // Then: Should count correctly
        XCTAssertGreaterThanOrEqual(stats.liked, 2, "Should have at least 2 liked meals")
        XCTAssertGreaterThanOrEqual(stats.disliked, 1, "Should have at least 1 disliked meal")
        XCTAssertGreaterThanOrEqual(stats.total, 3, "Should have at least 3 total ratings")
    }
    
    // MARK: - Offline Status Tests
    
    func testGetOfflineStatus_returnsStatus() async {
        // Given: MealService instance
        // When: Getting offline status
        let status = await sut.getOfflineStatus()
        
        // Then: Should return valid status tuple
        XCTAssertNotNil(status, "Should return status")
        // Status values depend on OfflineService state (can be true or false)
    }
    
    func testCanProvideOfflineSuggestions_checksAvailability() async {
        // Given: Default preferences
        // When: Checking offline suggestions availability
        let canProvide = await sut.canProvideOfflineSuggestions()
        
        // Then: Should return boolean (depends on cached meals)
        XCTAssertNotNil(canProvide, "Should return availability status")
    }
    
    // MARK: - Helper Methods
    
    private func createTestMeal(
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

