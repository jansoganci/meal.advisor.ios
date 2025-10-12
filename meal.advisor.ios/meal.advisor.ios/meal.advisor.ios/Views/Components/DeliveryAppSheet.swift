//
//  DeliveryAppSheet.swift
//  meal.advisor.ios
//
//  Bottom sheet for selecting a delivery app
//

import SwiftUI

struct DeliveryAppSheet: View {
    let mealTitle: String
    let onSelectApp: (DeliveryApp) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "bag.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.primaryOrange)
                        .padding(.top, 24)
                    
                    Text("Order Delivery")
                        .font(.title2.weight(.bold))
                    
                    Text("Choose your delivery service")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 16)
                }
                
                Divider()
                
                // Delivery app list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(DeliveryApp.allCases) { app in
                            DeliveryAppRow(app: app) {
                                onSelectApp(app)
                                dismiss()
                            }
                            
                            if app != DeliveryApp.allCases.last {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Divider()
                
                // Cancel button
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.body.weight(.medium))
                        .foregroundColor(.primaryOrange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct DeliveryAppRow: View {
    let app: DeliveryApp
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // App icon
                Image(systemName: app.iconName)
                    .font(.title2)
                    .foregroundColor(.primaryOrange)
                    .frame(width: 32, height: 32)
                
                // App name
                Text(app.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Order from \(app.displayName)")
    }
}

#Preview {
    DeliveryAppSheet(
        mealTitle: "Chicken Tikka Masala",
        onSelectApp: { app in
            print("Selected: \(app.displayName)")
        }
    )
}

