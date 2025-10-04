//
//  PreferenceToggle.swift
//  meal.advisor.ios
//
//  Specialized toggle component for user preferences
//

import SwiftUI
import UserNotifications

struct PreferenceToggle: View {
    let title: String
    let description: String?
    let icon: String?
    let iconColor: Color?
    @Binding var isOn: Bool
    let onToggle: ((Bool) -> Void)?
    
    init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColor = iconColor
        self._isOn = isOn
        self.onToggle = onToggle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon (if provided)
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor ?? .primary)
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let description = description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) { newValue in
                    onToggle?(newValue)
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                .accessibilityLabel("Toggle \(title)")
                .accessibilityValue(isOn ? "On" : "Off")
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        var label = title
        if let description = description {
            label += ", \(description)"
        }
        label += ", \(isOn ? "On" : "Off")"
        return label
    }
}

// MARK: - Specialized Preference Toggles

struct NotificationToggle: View {
    @Binding var isEnabled: Bool
    let onToggle: (() -> Void)?
    
    init(isEnabled: Binding<Bool>, onToggle: (() -> Void)? = nil) {
        self._isEnabled = isEnabled
        self.onToggle = onToggle
    }
    
    var body: some View {
        PreferenceToggle(
            title: "Meal Reminders",
            description: "Get notified when it's time to eat",
            icon: "bell.fill",
            iconColor: .orange,
            isOn: $isEnabled,
            onToggle: { newValue in
                onToggle?()
            }
        )
    }
}

struct PremiumToggle: View {
    @Binding var isEnabled: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        PreferenceToggle(
            title: "Premium Features",
            description: "Unlock unlimited favorites and advanced features",
            icon: "crown.fill",
            iconColor: .yellow,
            isOn: $isEnabled,
            onToggle: { newValue in
                if newValue && !isEnabled {
                    onUpgrade()
                    isEnabled = false // Reset if upgrade was cancelled
                }
            }
        )
    }
}

struct PrivacyToggle: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        PreferenceToggle(
            title: "Analytics",
            description: "Help improve the app with anonymous usage data",
            icon: "chart.bar.fill",
            iconColor: .blue,
            isOn: $isEnabled
        )
    }
}

// MARK: - Preview Helpers

#Preview("Basic Toggle") {
    List {
        PreferenceToggle(
            title: "Dark Mode",
            description: "Use dark appearance",
            icon: "moon.fill",
            iconColor: .purple,
            isOn: .constant(true)
        )
    }
}

#Preview("Notification Toggle") {
    List {
        NotificationToggle(isEnabled: .constant(false))
    }
}

#Preview("Premium Toggle") {
    List {
        PremiumToggle(isEnabled: .constant(false)) {
            print("Show premium upgrade")
        }
    }
}

#Preview("Privacy Toggle") {
    List {
        PrivacyToggle(isEnabled: .constant(true))
    }
}
