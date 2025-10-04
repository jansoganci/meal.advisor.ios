//
//  PaywallViewModel.swift
//  meal.advisor.ios
//
//  Paywall screen logic and purchase handling
//

import Foundation
import StoreKit

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var selectedProduct: Product?
    @Published var isPurchasing = false
    @Published var purchaseError: String?
    @Published var purchaseSuccess = false
    
    private let purchaseService = PurchaseService.shared
    private let appState = AppState.shared
    private let analyticsService = AnalyticsService.shared
    
    init() {
        loadProducts()
    }
    
    func trackPaywallView(source: String) {
        analyticsService.trackPaywallView(source: source)
    }
    
    // MARK: - Product Loading
    
    func loadProducts() {
        products = purchaseService.products
        
        // Default to weekly subscription
        if products.isEmpty {
            Task {
                await purchaseService.loadProducts()
                products = purchaseService.products
                selectedProduct = products.first
            }
        } else {
            selectedProduct = products.first
        }
    }
    
    // MARK: - Purchase Flow
    
    func purchase() {
        guard let product = selectedProduct else {
            purchaseError = "Please select a subscription plan"
            return
        }
        
        isPurchasing = true
        purchaseError = nil
        
        Task {
            do {
                let transaction = try await purchaseService.purchase(product)
                
                if transaction != nil {
                    // Purchase successful
                    purchaseSuccess = true
                    await appState.refreshSubscriptionStatus()
                    
                    // Track successful purchase
                    analyticsService.trackPurchase(
                        productID: product.id,
                        price: product.price,
                        success: true
                    )
                    
                    // Haptic feedback
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                    
                    print("💳 [PaywallViewModel] Purchase completed successfully")
                } else {
                    // User cancelled or pending
                    print("💳 [PaywallViewModel] Purchase cancelled or pending")
                }
                
                isPurchasing = false
            } catch {
                isPurchasing = false
                purchaseError = error.localizedDescription
                
                // Track failed purchase
                analyticsService.trackPurchase(
                    productID: product.id,
                    price: product.price,
                    success: false
                )
                
                // Haptic feedback for error
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.error)
                
                print("💳 [PaywallViewModel] Purchase failed: \(error)")
            }
        }
    }
    
    func restorePurchases() {
        isPurchasing = true
        purchaseError = nil
        
        Task {
            await purchaseService.restorePurchases()
            await appState.refreshSubscriptionStatus()
            
            if appState.isPremium {
                purchaseSuccess = true
                
                // Haptic feedback
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                
                print("💳 [PaywallViewModel] Purchases restored successfully")
            } else {
                purchaseError = "No previous purchases found"
                print("💳 [PaywallViewModel] No purchases to restore")
            }
            
            isPurchasing = false
        }
    }
    
    // MARK: - Helper Methods
    
    func selectProduct(_ product: Product) {
        selectedProduct = product
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    var weeklyProduct: Product? {
        products.first { $0.id == PurchaseService.weeklySubscriptionID }
    }
    
    var annualProduct: Product? {
        products.first { $0.id == PurchaseService.annualSubscriptionID }
    }
    
    var selectedProductIsWeekly: Bool {
        selectedProduct?.id == PurchaseService.weeklySubscriptionID
    }
    
    var savingsText: String {
        guard let weekly = weeklyProduct,
              let annual = annualProduct else {
            return "Save 30%"
        }
        
        // Calculate yearly cost of weekly subscription
        let weeklyYearlyCost = (weekly.price as Decimal) * 52
        let annualCost = annual.price as Decimal
        
        // Calculate savings
        let savings = weeklyYearlyCost - annualCost
        let savingsPercentage = (savings / weeklyYearlyCost) * 100
        let savingsInt = NSDecimalNumber(decimal: savingsPercentage).intValue
        
        return "Save \(savingsInt)%"
    }
}
