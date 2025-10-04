//
//  PurchaseService.swift
//  meal.advisor.ios
//
//  StoreKit 2 service for in-app purchases and subscriptions
//

import Foundation
import StoreKit

@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    // Subscription Product IDs
    static let weeklySubscriptionID = "mealadvisor.weekly"
    static let annualSubscriptionID = "mealadvisor.annual"
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var subscriptionStatus: SubscriptionStatus = .notSubscribed
    @Published var isLoading = false
    
    private var updateListenerTask: Task<Void, Error>?
    
    enum SubscriptionStatus {
        case notSubscribed
        case subscribed(productID: String, expirationDate: Date?)
        case expired
        case inGracePeriod
        
        var isPremium: Bool {
            switch self {
            case .subscribed, .inGracePeriod:
                return true
            case .notSubscribed, .expired:
                return false
            }
        }
    }
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIDs = [
                PurchaseService.weeklySubscriptionID,
                PurchaseService.annualSubscriptionID
            ]
            
            let loadedProducts = try await Product.products(for: productIDs)
            products = loadedProducts.sorted { product1, product2 in
                // Sort: weekly first, then annual
                if product1.id == PurchaseService.weeklySubscriptionID {
                    return true
                }
                return false
            }
            
            print("💳 [PurchaseService] Loaded \(products.count) products")
            for product in products {
                print("💳 [PurchaseService] - \(product.displayName): \(product.displayPrice)")
            }
        } catch {
            print("💳 [PurchaseService] Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase Flow
    
    /// Purchase a subscription product
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        defer { isLoading = false }
        
        print("💳 [PurchaseService] Attempting to purchase: \(product.displayName)")
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Update subscription status
            await updateSubscriptionStatus()
            
            // Finish the transaction
            await transaction.finish()
            
            print("💳 [PurchaseService] Purchase successful: \(product.displayName)")
            return transaction
            
        case .userCancelled:
            print("💳 [PurchaseService] User cancelled purchase")
            return nil
            
        case .pending:
            print("💳 [PurchaseService] Purchase pending (awaiting approval)")
            return nil
            
        @unknown default:
            print("💳 [PurchaseService] Unknown purchase result")
            return nil
        }
    }
    
    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        print("💳 [PurchaseService] Restoring purchases...")
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            print("💳 [PurchaseService] Purchases restored successfully")
        } catch {
            print("💳 [PurchaseService] Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Subscription Status
    
    /// Update current subscription status
    func updateSubscriptionStatus() async {
        var activeSubscription: Product.SubscriptionInfo.Status?
        var latestTransaction: Transaction?
        
        // Check all subscription groups
        for product in products {
            guard let subscription = product.subscription else { continue }
            
            let statuses = try? await subscription.status
            
            // Find active subscription
            if let status = statuses?.first(where: { $0.state == .subscribed || $0.state == .inGracePeriod }) {
                activeSubscription = status
                latestTransaction = try? checkVerified(status.transaction)
                break
            }
        }
        
        // Update subscription status
        if let status = activeSubscription, let transaction = latestTransaction {
            purchasedProductIDs.insert(transaction.productID)
            
            if status.state == .subscribed {
                subscriptionStatus = .subscribed(
                    productID: transaction.productID,
                    expirationDate: nil  // StoreKit 2 manages expiration automatically
                )
                print("💳 [PurchaseService] Active subscription: \(transaction.productID)")
            } else if status.state == .inGracePeriod {
                subscriptionStatus = .inGracePeriod
                print("💳 [PurchaseService] Subscription in grace period")
            }
        } else {
            // Check if subscription expired
            let hasExpiredSubscription = await checkForExpiredSubscription()
            if hasExpiredSubscription {
                subscriptionStatus = .expired
                print("💳 [PurchaseService] Subscription expired")
            } else {
                subscriptionStatus = .notSubscribed
                purchasedProductIDs.removeAll()
                print("💳 [PurchaseService] No active subscription")
            }
        }
    }
    
    /// Check if user had a subscription that expired
    private func checkForExpiredSubscription() async -> Bool {
        do {
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                
                // Check if it's one of our subscription products
                if transaction.productID == PurchaseService.weeklySubscriptionID ||
                   transaction.productID == PurchaseService.annualSubscriptionID {
                    
                    // If we found a transaction but no active subscription, it expired
                    return true
                }
            }
        } catch {
            print("💳 [PurchaseService] Error checking expired subscriptions: \(error)")
        }
        
        return false
    }
    
    // MARK: - Transaction Verification
    
    /// Verify a transaction is legitimate
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Updates
    
    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { @MainActor in
            // Listen for transaction updates
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Update subscription status
                    await self.updateSubscriptionStatus()
                    
                    // Finish the transaction
                    await transaction.finish()
                    
                    print("💳 [PurchaseService] Transaction updated: \(transaction.productID)")
                } catch {
                    print("💳 [PurchaseService] Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get product by ID
    func product(for productID: String) -> Product? {
        return products.first { $0.id == productID }
    }
    
    /// Check if a specific product is purchased
    func isPurchased(_ productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
    
    /// Get active subscription product
    func getActiveSubscription() -> Product? {
        switch subscriptionStatus {
        case .subscribed(let productID, _):
            return product(for: productID)
        default:
            return nil
        }
    }
    
    /// Get subscription expiration date
    func getSubscriptionExpirationDate() -> Date? {
        switch subscriptionStatus {
        case .subscribed(_, let expirationDate):
            return expirationDate
        default:
            return nil
        }
    }
}

// MARK: - Purchase Errors

enum PurchaseError: LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed
    case restoreFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Failed to verify purchase. Please try again."
        case .productNotFound:
            return "Subscription not found. Please check your internet connection."
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .restoreFailed:
            return "Failed to restore purchases. Please try again."
        }
    }
}
