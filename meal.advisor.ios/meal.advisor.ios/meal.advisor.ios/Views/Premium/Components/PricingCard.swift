//
//  PricingCard.swift
//  meal.advisor.ios
//
//  Pricing card component for subscription options
//

import SwiftUI
import StoreKit

struct PricingCard: View {
    let product: Product
    let isSelected: Bool
    let badge: String?
    let onTap: () -> Void
    
    init(
        product: Product,
        isSelected: Bool,
        badge: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.product = product
        self.isSelected = isSelected
        self.badge = badge
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Badge (if provided)
                if let badge = badge {
                    HStack {
                        Spacer()
                        Text(badge)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.primaryOrange)
                            .clipShape(Capsule())
                    }
                }
                
                // Title
                Text(product.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Price
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(product.displayPrice)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(priceDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Trial info (if applicable)
                if let introOffer = product.subscription?.introductoryOffer,
                   introOffer.paymentMode == .freeTrial {
                    Text("3-day free trial, then \(product.displayPrice)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else if product.id.contains("weekly") {
                    Text("Billed weekly")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Billed annually")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
            )
            .cornerRadius(16)
            .shadow(color: isSelected ? Color.primaryOrange.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Tap to select this subscription plan")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    private var priceDescription: String {
        if product.id.contains("weekly") {
            return "per week"
        } else if product.id.contains("annual") {
            return "per year"
        }
        return ""
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.primaryOrange.opacity(0.1)
        } else {
            return Color(.secondarySystemBackground)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color.primaryOrange
        } else {
            return Color(.separator)
        }
    }
    
    private var accessibilityLabel: String {
        var label = "\(product.displayName), \(product.displayPrice) \(priceDescription)"
        if let badge = badge {
            label = "\(badge). " + label
        }
        if let introOffer = product.subscription?.introductoryOffer,
           introOffer.paymentMode == .freeTrial {
            label += ", includes 3-day free trial"
        } else if product.id.contains("weekly") {
            label += ", billed weekly"
        } else {
            label += ", billed annually"
        }
        if isSelected {
            label += ", selected"
        }
        return label
    }
}

// MARK: - Compact Pricing Card

struct CompactPricingCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let introOffer = product.subscription?.introductoryOffer,
                       introOffer.paymentMode == .freeTrial {
                        Text("3-day free trial")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else if product.id.contains("weekly") {
                        Text("No trial")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .primaryOrange : .primary)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .primaryOrange : .secondary)
                    .font(.title3)
            }
            .padding(16)
            .background(isSelected ? Color.primaryOrange.opacity(0.1) : Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryOrange : Color(.separator), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Pricing Cards") {
    VStack(spacing: 16) {
        // Mock weekly product
        Text("Weekly - Selected")
        // Mock annual product  
        Text("Annual - Not Selected")
    }
    .padding()
}
