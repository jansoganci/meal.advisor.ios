//
//  PremiumBadge.swift
//  meal.advisor.ios
//
//  Premium badge component for indicating premium features
//

import SwiftUI

struct PremiumBadge: View {
    let style: BadgeStyle
    
    enum BadgeStyle {
        case icon
        case iconText
        case compact
        case full
        
        var showIcon: Bool {
            switch self {
            case .icon, .iconText, .full:
                return true
            case .compact:
                return false
            }
        }
        
        var showText: Bool {
            switch self {
            case .iconText, .compact, .full:
                return true
            case .icon:
                return false
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if style.showIcon {
                Image(systemName: "crown.fill")
                    .font(style == .full ? .body : .caption)
                    .foregroundStyle(.yellow.gradient)
            }
            
            if style.showText {
                Text("Premium")
                    .font(style == .full ? .subheadline : .caption)
                    .fontWeight(.semibold)
                    .foregroundColor(style == .full ? .primary : .secondary)
            }
        }
        .padding(.horizontal, style == .full ? 12 : 6)
        .padding(.vertical, style == .full ? 6 : 3)
        .background(style == .full ? Color.yellow.opacity(0.15) : Color.clear)
        .clipShape(Capsule())
        .accessibilityLabel("Premium feature")
    }
}

struct PremiumFeatureIndicator: View {
    let title: String
    let description: String
    let isLocked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if isLocked {
                        PremiumBadge(style: .iconText)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .opacity(isLocked ? 0.6 : 1.0)
        .accessibilityLabel("\(title), \(isLocked ? "Premium feature, locked" : "Available")")
    }
}

#Preview("Badge Styles") {
    VStack(alignment: .leading, spacing: 16) {
        PremiumBadge(style: .icon)
        PremiumBadge(style: .iconText)
        PremiumBadge(style: .compact)
        PremiumBadge(style: .full)
    }
    .padding()
}

#Preview("Feature Indicator") {
    VStack(spacing: 12) {
        PremiumFeatureIndicator(
            title: "Unlimited Favorites",
            description: "Save as many recipes as you want",
            isLocked: true
        )
        
        PremiumFeatureIndicator(
            title: "Basic Suggestions",
            description: "Get meal recommendations",
            isLocked: false
        )
    }
    .padding()
}
