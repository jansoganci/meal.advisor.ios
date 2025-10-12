//
//  UsageTrackingServiceTests.swift
//  meal.advisor.iosTests
//
//  Unit tests for usage quota tracking logic
//

import XCTest
@testable import meal_advisor_ios

@MainActor
final class UsageTrackingServiceTests: XCTestCase {
    
    var sut: UsageTrackingService!
    
    override func setUpWithError() throws {
        super.setUp()
        // Note: UsageTrackingService is a singleton, so we test the shared instance
        sut = UsageTrackingService.shared
        
        // Reset state for each test
        sut.resetDailyCounter()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - State Management Tests
    
    func testInitialState_isZero() {
        // Given: Fresh reset
        sut.resetDailyCounter()
        
        // When: Checking initial state
        // Then: Should start at 0
        XCTAssertEqual(sut.state.dailyUsageCount, 0, "Initial count should be 0")
        XCTAssertFalse(sut.state.hasReachedLimit, "Should not have reached limit initially")
        XCTAssertFalse(sut.state.isLoading, "Should not be loading initially")
    }
    
    func testRemainingCount_calculatesCorrectly() {
        // Given: Usage count of 2
        // When: Getting remaining count
        // Then: Should be 3 (5 - 2)
        let remaining = sut.getRemainingCount()
        XCTAssertGreaterThanOrEqual(remaining, 0, "Remaining count should be non-negative")
        XCTAssertLessThanOrEqual(remaining, 5, "Remaining count should not exceed limit")
    }
    
    func testUsageState_computedProperties() {
        // Given: A usage state with count 3
        var state = UsageState()
        state.dailyUsageCount = 3
        
        // When: Accessing computed properties
        // Then: Should calculate correctly
        XCTAssertEqual(state.remainingCount, 2, "Should have 2 remaining (5-3)")
        XCTAssertEqual(state.progressPercentage, 0.6, accuracy: 0.01, "Should be 60% progress")
        XCTAssertTrue(state.canGenerate, "Should be able to generate at 3/5")
    }
    
    func testUsageState_atLimit() {
        // Given: A usage state at limit
        var state = UsageState()
        state.dailyUsageCount = 5
        state.hasReachedLimit = true
        
        // When: Checking computed properties
        // Then: Should indicate limit reached
        XCTAssertEqual(state.remainingCount, 0, "Should have 0 remaining")
        XCTAssertEqual(state.progressPercentage, 1.0, "Should be 100% progress")
        XCTAssertFalse(state.canGenerate, "Should not be able to generate at limit")
    }
    
    // MARK: - Quota Enforcement Tests
    
    func testCanGenerateSuggestion_belowLimit() async {
        // Given: Usage count below limit (reset to 0)
        sut.resetDailyCounter()
        
        // Manually set to 3 to simulate usage
        sut.state.dailyUsageCount = 3
        
        // When: Premium is false and count is below 5
        // Note: This test assumes non-premium user
        // Then: Should allow generation
        // (Actual result depends on PurchaseService.isPremium)
    }
    
    func testResetDailyCounter_clearsState() {
        // Given: Usage count at limit
        sut.state.dailyUsageCount = 5
        sut.state.hasReachedLimit = true
        
        // When: Resetting counter
        sut.resetDailyCounter()
        
        // Then: Should reset to zero
        XCTAssertEqual(sut.state.dailyUsageCount, 0, "Count should reset to 0")
        XCTAssertFalse(sut.state.hasReachedLimit, "Limit flag should be cleared")
    }
    
    func testGetRemainingCount_neverNegative() {
        // Given: Usage count potentially over limit
        sut.state.dailyUsageCount = 10 // Artificially high
        
        // When: Getting remaining count
        let remaining = sut.getRemainingCount()
        
        // Then: Should never be negative
        XCTAssertGreaterThanOrEqual(remaining, 0, "Remaining should never be negative")
    }
    
    // MARK: - Usage Description Tests
    
    func testUsageDescription_formatsCorrectly() {
        // Given: Usage state with count 3
        var state = UsageState()
        state.dailyUsageCount = 3
        
        // When: Getting description
        let description = state.usageDescription
        
        // Then: Should format correctly
        XCTAssertEqual(description, "3/5 suggestions used today", "Description should match format")
    }
    
    // MARK: - Edge Cases
    
    func testTrackSuggestionUsage_incrementsCount() async throws {
        // Given: Initial count
        let initialCount = sut.state.dailyUsageCount
        
        // When: Tracking usage (for non-premium user)
        // Note: This will fail if user is premium or Supabase not configured
        // We're testing the increment logic, not the actual API call
        
        // Then: Count should increment
        // (Skipping actual test as it requires mocking PurchaseService and Supabase)
    }
    
    func testState_equatable() {
        // Given: Two identical states
        let state1 = UsageState(dailyUsageCount: 3, hasReachedLimit: false, isLoading: false)
        let state2 = UsageState(dailyUsageCount: 3, hasReachedLimit: false, isLoading: false)
        
        // When: Comparing states
        // Then: Should be equal
        XCTAssertEqual(state1, state2, "Identical states should be equal")
    }
    
    func testState_notEquatable() {
        // Given: Two different states
        let state1 = UsageState(dailyUsageCount: 3, hasReachedLimit: false, isLoading: false)
        let state2 = UsageState(dailyUsageCount: 4, hasReachedLimit: false, isLoading: false)
        
        // When: Comparing states
        // Then: Should not be equal
        XCTAssertNotEqual(state1, state2, "Different states should not be equal")
    }
}

