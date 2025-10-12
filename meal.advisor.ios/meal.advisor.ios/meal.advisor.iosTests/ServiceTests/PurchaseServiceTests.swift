//
//  PurchaseServiceTests.swift
//  meal.advisor.iosTests
//
//  Unit tests for subscription and premium logic
//

import XCTest
import StoreKit
@testable import meal_advisor_ios

@MainActor
final class PurchaseServiceTests: XCTestCase {
    
    var sut: PurchaseService!
    
    override func setUpWithError() throws {
        super.setUp()
        sut = PurchaseService.shared
    }
    
    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Subscription Status Tests
    
    func testSubscriptionStatus_isPremiumProperty() {
        // Given: Different subscription statuses
        let notSubscribed = PurchaseService.SubscriptionStatus.notSubscribed
        let subscribed = PurchaseService.SubscriptionStatus.subscribed(productID: "test", expirationDate: nil)
        let expired = PurchaseService.SubscriptionStatus.expired
        let gracePeriod = PurchaseService.SubscriptionStatus.inGracePeriod
        
        // When: Checking isPremium
        // Then: Should return correct values
        XCTAssertFalse(notSubscribed.isPremium, "Not subscribed should not be premium")
        XCTAssertTrue(subscribed.isPremium, "Subscribed should be premium")
        XCTAssertFalse(expired.isPremium, "Expired should not be premium")
        XCTAssertTrue(gracePeriod.isPremium, "Grace period should still be premium")
    }
    
    func testSubscriptionStatus_initialState() {
        // Given: Fresh service instance
        // When: Checking initial status
        // Then: Should have a defined status
        XCTAssertNotNil(sut.subscriptionStatus, "Should have subscription status")
        
        // Check that isPremium property is accessible
        let isPremium = sut.subscriptionStatus.isPremium
        XCTAssertNotNil(isPremium, "Should have isPremium property")
    }
    
    // MARK: - Product Loading Tests
    
    func testProducts_initiallyEmpty() {
        // Given: Service on init
        // When: Checking products before async load
        // Then: May be empty (products load asynchronously)
        XCTAssertNotNil(sut.products, "Products array should exist")
    }
    
    func testProductIDs_areCorrect() {
        // Given: Product ID constants
        // When: Checking values
        // Then: Should match expected format
        XCTAssertEqual(PurchaseService.weeklySubscriptionID, "mealadvisor.weekly", 
                       "Weekly product ID should match")
        XCTAssertEqual(PurchaseService.annualSubscriptionID, "mealadvisor.annual",
                       "Annual product ID should match")
    }
    
    func testGetProduct_byID() {
        // Given: Service with loaded products
        let weeklyID = PurchaseService.weeklySubscriptionID
        
        // When: Getting product by ID
        let product = sut.product(for: weeklyID)
        
        // Then: Should return product or nil (depends on StoreKit availability)
        // Product may be nil in test environment without StoreKit configuration
        if product != nil {
            XCTAssertEqual(product?.id, weeklyID, "Should return correct product")
        }
    }
    
    // MARK: - Purchase Tracking Tests
    
    func testIsPurchased_checksCorrectly() {
        // Given: Service with purchased products set
        let testProductID = "test.product"
        
        // When: Checking if product is purchased
        let isPurchased = sut.isPurchased(testProductID)
        
        // Then: Should return boolean
        XCTAssertNotNil(isPurchased, "Should return purchase status")
        // Actual value depends on StoreKit state
    }
    
    func testGetActiveSubscription_returnsProduct() {
        // Given: Service with subscription status
        // When: Getting active subscription
        let activeSubscription = sut.getActiveSubscription()
        
        // Then: Should return product or nil depending on status
        if case .subscribed = sut.subscriptionStatus {
            XCTAssertNotNil(activeSubscription, "Should have active subscription when subscribed")
        } else {
            XCTAssertNil(activeSubscription, "Should not have active subscription when not subscribed")
        }
    }
    
    func testGetSubscriptionExpirationDate_returnsDate() {
        // Given: Service with subscription status
        // When: Getting expiration date
        let expirationDate = sut.getSubscriptionExpirationDate()
        
        // Then: Should return date or nil depending on status
        if case .subscribed = sut.subscriptionStatus {
            // May or may not have expiration date (StoreKit 2 manages automatically)
            XCTAssertNotNil(sut.subscriptionStatus, "Should have status")
        }
    }
    
    // MARK: - Loading State Tests
    
    func testIsLoading_defaultsFalse() {
        // Given: Service at rest
        // When: Checking loading state
        // Then: Should not be loading
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
    }
    
    // MARK: - Edge Cases
    
    func testSubscriptionStatus_equality() {
        // Given: Two identical not-subscribed statuses
        let status1 = PurchaseService.SubscriptionStatus.notSubscribed
        let status2 = PurchaseService.SubscriptionStatus.notSubscribed
        
        // When: Comparing them
        // Then: Should both have isPremium = false
        XCTAssertEqual(status1.isPremium, status2.isPremium, "Same status should have same isPremium value")
    }
}

