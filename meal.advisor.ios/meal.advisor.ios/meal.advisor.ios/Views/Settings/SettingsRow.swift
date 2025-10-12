//
//  SettingsRow.swift
//  meal.advisor.ios
//
//  Reusable settings row component for consistent list styling
//

import SwiftUI

struct SettingsRow: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color?
    let action: (() -> Void)?
    let destination: AnyView?
    let accessory: SettingsRowAccessory?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        action: (() -> Void)? = nil,
        destination: AnyView? = nil,
        accessory: SettingsRowAccessory? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
        self.destination = destination
        self.accessory = accessory
    }
    
    var body: some View {
        Group {
            if let destination = destination {
                // Navigation row - wrap in NavigationLink
                NavigationLink(destination: destination) {
                    rowContent
                }
            } else {
                // Action row or info row - use tap gesture
                rowContent
                    .contentShape(Rectangle())
                    .onTapGesture {
                        action?()
                    }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
    }
    
    // MARK: - Row Content
    
    private var rowContent: some View {
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
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Accessory (NavigationLink adds its own chevron, so only show for action rows)
            if let accessory = accessory {
                accessory
            }
        }
        .padding(.vertical, 4)
    }
    
    private var accessibilityLabel: String {
        var label = title
        if let subtitle = subtitle {
            label += ", \(subtitle)"
        }
        return label
    }
    
    private var accessibilityHint: String? {
        if destination != nil {
            return "Navigates to \(title) settings"
        } else if action != nil {
            return "Taps to perform action"
        }
        return nil
    }
}

// MARK: - Settings Row Accessory Types

enum SettingsRowAccessory {
    case toggle(Binding<Bool>)
    case badge(String)
    case value(String)
    case chevron
    case none
}

extension SettingsRowAccessory: View {
    var body: some View {
        switch self {
        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
                .accessibilityLabel("Toggle setting")
        case .badge(let text):
            Text(text)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
        case .value(let text):
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Convenience Initializers

extension SettingsRow {
    /// Navigation row with destination
    static func navigation(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        destination: AnyView
    ) -> SettingsRow {
        SettingsRow(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            destination: destination
        )
    }
    
    /// Action row with tap handler
    static func action(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        action: @escaping () -> Void
    ) -> SettingsRow {
        SettingsRow(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            action: action
        )
    }
    
    /// Toggle row with switch
    static func toggle(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        isOn: Binding<Bool>,
        action: (() -> Void)? = nil
    ) -> SettingsRow {
        SettingsRow(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            action: action,
            accessory: .toggle(isOn)
        )
    }
    
    /// Info row with value display
    static func info(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil
    ) -> SettingsRow {
        SettingsRow(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            accessory: .value(value)
        )
    }
}

#Preview("Navigation Row") {
    List {
        SettingsRow.navigation(
            title: "Serving Size",
            subtitle: "Number of people",
            icon: "person.2",
            iconColor: .blue,
            destination: AnyView(Text("Serving Size View"))
        )
    }
}

#Preview("Action Row") {
    List {
        SettingsRow.action(
            title: "Sign Out",
            icon: "arrow.right.square",
            iconColor: .red,
            action: {}
        )
    }
}

#Preview("Toggle Row") {
    List {
        SettingsRow.toggle(
            title: "Notifications",
            subtitle: "Get meal reminders",
            icon: "bell",
            iconColor: .orange,
            isOn: .constant(true)
        )
    }
}

#Preview("Info Row") {
    List {
        SettingsRow.info(
            title: "Premium Status",
            value: "Premium ✅",
            subtitle: "Active subscription",
            icon: "crown.fill",
            iconColor: .yellow
        )
    }
}
