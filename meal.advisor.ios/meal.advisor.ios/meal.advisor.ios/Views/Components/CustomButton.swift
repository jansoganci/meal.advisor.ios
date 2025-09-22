//
//  CustomButton.swift
//  meal.advisor.ios
//
//  Brand-styled buttons (Primary, Secondary, Text)
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(Color.primaryOrange)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.medium))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundColor(.primaryOrange)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryOrange, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}

struct TextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.medium))
                .foregroundColor(.primaryOrange)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}

#Preview("Buttons") {
    VStack(spacing: 16) {
        PrimaryButton(title: "Primary", action: {})
        SecondaryButton(title: "Secondary", action: {})
        TextButton(title: "Text Button", action: {})
    }
    .padding()
}

