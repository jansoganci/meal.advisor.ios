//
//  UsageCounterBadge.swift
//  meal.advisor.ios
//
//  Displays remaining daily suggestions for free users
//  iOS HIG compliant design with subtle animations
//

import SwiftUI

struct UsageCounterBadge: View {
    let remaining: Int
    let total: Int = 5
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.caption.weight(.medium))
                .foregroundColor(iconColor)
            
            Text(displayText)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color(.secondaryLabel))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: remaining)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }
    
    // MARK: - Computed Properties
    
    private var displayText: String {
        if remaining == 0 {
            return "Daily limit reached"
        } else if remaining == 1 {
            return "1 suggestion remaining"
        } else {
            return "\(remaining) suggestions remaining today"
        }
    }
    
    private var accessibilityText: String {
        if remaining == 0 {
            return "You have reached your daily limit of \(total) suggestions. Upgrade to Premium for unlimited suggestions."
        } else if remaining == 1 {
            return "You have 1 suggestion remaining today out of \(total). Upgrade to Premium for unlimited suggestions."
        } else {
            return "You have \(remaining) suggestions remaining today out of \(total). Upgrade to Premium for unlimited suggestions."
        }
    }
    
    // MARK: - Visual States
    
    private var iconName: String {
        switch remaining {
        case 0:
            return "exclamationmark.circle.fill"
        case 1:
            return "exclamationmark.triangle.fill"
        default:
            return "sparkles"
        }
    }
    
    private var iconColor: Color {
        switch remaining {
        case 0:
            return .red
        case 1:
            return .orange
        default:
            return Color("PrimaryOrange")
        }
    }
    
    private var backgroundColor: Color {
        switch remaining {
        case 0:
            return Color(.systemRed).opacity(0.1)
        case 1:
            return Color(.systemOrange).opacity(0.1)
        default:
            return Color(.systemGray6)
        }
    }
    
    private var borderColor: Color {
        switch remaining {
        case 0:
            return Color(.systemRed).opacity(0.3)
        case 1:
            return Color(.systemOrange).opacity(0.3)
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        remaining <= 1 ? 1.5 : 0
    }
    
    private var shadowColor: Color {
        Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05)
    }
    
    private var shadowRadius: CGFloat {
        remaining <= 1 ? 4 : 2
    }
}

// MARK: - Preview Provider

#Preview("5 Remaining") {
    VStack(spacing: 20) {
        UsageCounterBadge(remaining: 5)
        UsageCounterBadge(remaining: 3)
        UsageCounterBadge(remaining: 1)
        UsageCounterBadge(remaining: 0)
    }
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Dark Mode") {
    VStack(spacing: 20) {
        UsageCounterBadge(remaining: 5)
        UsageCounterBadge(remaining: 3)
        UsageCounterBadge(remaining: 1)
        UsageCounterBadge(remaining: 0)
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

