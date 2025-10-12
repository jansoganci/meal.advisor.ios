//
//  PaywallView.swift
//  meal.advisor.ios
//
//  Premium paywall modal with subscription options
//

import SwiftUI

struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    let source: PaywallSource
    
    enum PaywallSource {
        case favorites
        case suggestionLimit
        case settings
        case onboarding
        
        var title: String {
            switch self {
            case .favorites:
                return "Save Unlimited Favorites"
            case .suggestionLimit:
                return "Unlimited Suggestions"
            case .settings, .onboarding:
                return "Unlock Premium Features"
            }
        }
        
        var subtitle: String {
            switch self {
            case .favorites:
                return "Keep all your favorite recipes in one place"
            case .suggestionLimit:
                return "Get meal suggestions whenever you need them"
            case .settings, .onboarding:
                return "Get the most out of MealAdvisor"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.yellow.gradient)
                            .accessibilityHidden(true)
                        
                        Text(source.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(source.subtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Features List
                    FeaturesList()
                        .padding(.horizontal, 20)
                    
                    // Pricing Cards
                    VStack(spacing: 12) {
                        if let weekly = viewModel.weeklyProduct {
                            PricingCard(
                                product: weekly,
                                isSelected: viewModel.selectedProduct?.id == weekly.id,
                                badge: "Popular"
                            ) {
                                viewModel.selectProduct(weekly)
                            }
                        }
                        
                        if let annual = viewModel.annualProduct {
                            PricingCard(
                                product: annual,
                                isSelected: viewModel.selectedProduct?.id == annual.id,
                                badge: viewModel.savingsText
                            ) {
                                viewModel.selectProduct(annual)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Purchase Button
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.purchase()
                        }) {
                            HStack {
                                if viewModel.isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(purchaseButtonTitle)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primaryOrange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isPurchasing || viewModel.selectedProduct == nil)
                        .accessibilityLabel(purchaseButtonTitle)
                        .accessibilityHint("Tap to purchase selected subscription")
                        
                        // Error message
                        if let error = viewModel.purchaseError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Restore Purchases
                        Button("Restore Purchases") {
                            viewModel.restorePurchases()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .disabled(viewModel.isPurchasing)
                    }
                    .padding(.horizontal, 20)
                    
                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("Subscription automatically renews unless cancelled")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 16) {
                            Button("Terms of Service") {
                                if let url = URL(string: "https://jansoganci.github.io/meal.advisor.ios/terms.html") {
                                    openURL(url)
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(.blue)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Button("Privacy Policy") {
                                if let url = URL(string: "https://jansoganci.github.io/meal.advisor.ios/privacy-policy.html") {
                                    openURL(url)
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: Button("Maybe Later") {
                dismiss()
            }.foregroundColor(.secondary))
        }
        .onChange(of: viewModel.purchaseSuccess) { success in
            if success {
                // Dismiss paywall after successful purchase
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
        .alert("Purchase Successful! 🎉", isPresented: $viewModel.purchaseSuccess) {
            Button("Start Using Premium") {
                dismiss()
            }
        } message: {
            Text("You now have access to all premium features. Enjoy!")
        }
        .onAppear {
            viewModel.trackPaywallView(source: sourceString)
        }
    }
    
    private var sourceString: String {
        switch source {
        case .favorites: return "favorites"
        case .suggestionLimit: return "suggestion_limit"
        case .settings: return "settings"
        case .onboarding: return "onboarding"
        }
    }
    
    private var purchaseButtonTitle: String {
        if viewModel.isPurchasing {
            return "Processing..."
        }
        
        guard let product = viewModel.selectedProduct else {
            return "Select a Plan"
        }
        
        if let introOffer = product.subscription?.introductoryOffer,
           introOffer.paymentMode == .freeTrial {
            return "Start Free Trial"
        }
        
        return "Subscribe"
    }
}

#Preview("Favorites Source") {
    PaywallView(source: .favorites)
}

#Preview("Suggestion Limit Source") {
    PaywallView(source: .suggestionLimit)
}

#Preview("Settings Source") {
    PaywallView(source: .settings)
}
