//
//  FeaturesList.swift
//  meal.advisor.ios
//
//  Premium features list component for paywall
//

import SwiftUI

struct FeaturesList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(
                icon: "heart.fill",
                iconColor: .red,
                title: "Unlimited Favorites",
                description: "Save as many recipes as you want"
            )
            
            FeatureRow(
                icon: "arrow.triangle.2.circlepath",
                iconColor: .blue,
                title: "Unlimited Suggestions",
                description: "No daily limit on meal recommendations"
            )
            
            FeatureRow(
                icon: "wifi.slash",
                iconColor: .orange,
                title: "Offline Access",
                description: "Access saved recipes anytime, anywhere"
            )
            
            FeatureRow(
                icon: "sparkles",
                iconColor: .yellow,
                title: "Priority Support",
                description: "Get help when you need it"
            )
            
            FeatureRow(
                icon: "lock.open.fill",
                iconColor: .green,
                title: "Future Features",
                description: "Get all new premium features for free"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Premium features list")
    }
}

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())
                .accessibilityHidden(true)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(description)")
    }
}

#Preview {
    VStack {
        FeaturesList()
            .padding()
    }
}
