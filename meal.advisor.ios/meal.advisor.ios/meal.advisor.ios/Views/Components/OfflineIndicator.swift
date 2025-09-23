//
//  OfflineIndicator.swift
//  meal.advisor.ios
//
//  Offline status indicator component
//

import SwiftUI

struct OfflineIndicator: View {
    let isOffline: Bool
    let hasOfflineContent: Bool
    let message: String?
    
    init(isOffline: Bool, hasOfflineContent: Bool, message: String? = nil) {
        self.isOffline = isOffline
        self.hasOfflineContent = hasOfflineContent
        self.message = message
    }
    
    var body: some View {
        if isOffline {
            HStack(spacing: 8) {
                Image(systemName: hasOfflineContent ? "wifi.slash" : "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundColor(hasOfflineContent ? .orange : .red)
                
                Text(message ?? statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .cornerRadius(8)
            .accessibilityLabel("Network status: \(accessibilityMessage)")
        }
    }
    
    private var statusMessage: String {
        if hasOfflineContent {
            return "Offline mode - cached suggestions available"
        } else {
            return "No internet connection"
        }
    }
    
    private var backgroundColor: Color {
        if hasOfflineContent {
            return Color.orange.opacity(0.1)
        } else {
            return Color.red.opacity(0.1)
        }
    }
    
    private var accessibilityMessage: String {
        if hasOfflineContent {
            return "Offline mode with cached content available"
        } else {
            return "No internet connection and no cached content"
        }
    }
}

// MARK: - Compact Offline Indicator

struct CompactOfflineIndicator: View {
    let isOffline: Bool
    let hasOfflineContent: Bool
    
    var body: some View {
        if isOffline {
            HStack(spacing: 4) {
                Image(systemName: hasOfflineContent ? "wifi.slash" : "exclamationmark.triangle")
                    .font(.caption2)
                    .foregroundColor(hasOfflineContent ? .orange : .red)
                
                Text(hasOfflineContent ? "Offline" : "No Connection")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .cornerRadius(4)
            .accessibilityLabel("Network status: \(hasOfflineContent ? "Offline with cached content" : "No connection")")
        }
    }
    
    private var backgroundColor: Color {
        if hasOfflineContent {
            return Color.orange.opacity(0.1)
        } else {
            return Color.red.opacity(0.1)
        }
    }
}

// MARK: - Offline Banner

struct OfflineBanner: View {
    let isOffline: Bool
    let hasOfflineContent: Bool
    let onRetry: (() -> Void)?
    
    init(isOffline: Bool, hasOfflineContent: Bool, onRetry: (() -> Void)? = nil) {
        self.isOffline = isOffline
        self.hasOfflineContent = hasOfflineContent
        self.onRetry = onRetry
    }
    
    var body: some View {
        if isOffline {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: hasOfflineContent ? "wifi.slash" : "exclamationmark.triangle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(hasOfflineContent ? .orange : .red)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hasOfflineContent ? "Offline Mode" : "No Internet Connection")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(bannerMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let onRetry = onRetry {
                        Button("Retry") {
                            onRetry()
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Network status: \(accessibilityMessage)")
        }
    }
    
    private var bannerMessage: String {
        if hasOfflineContent {
            return "Showing cached suggestions. Some features may be limited."
        } else {
            return "Please check your internet connection and try again."
        }
    }
    
    private var backgroundColor: Color {
        if hasOfflineContent {
            return Color.orange.opacity(0.1)
        } else {
            return Color.red.opacity(0.1)
        }
    }
    
    private var accessibilityMessage: String {
        if hasOfflineContent {
            return "Offline mode with cached content available"
        } else {
            return "No internet connection and no cached content available"
        }
    }
}

#Preview("Offline with Content") {
    VStack(spacing: 16) {
        OfflineIndicator(isOffline: true, hasOfflineContent: true)
        CompactOfflineIndicator(isOffline: true, hasOfflineContent: true)
        OfflineBanner(isOffline: true, hasOfflineContent: true) {
            print("Retry tapped")
        }
    }
    .padding()
}

#Preview("Offline without Content") {
    VStack(spacing: 16) {
        OfflineIndicator(isOffline: true, hasOfflineContent: false)
        CompactOfflineIndicator(isOffline: true, hasOfflineContent: false)
        OfflineBanner(isOffline: true, hasOfflineContent: false) {
            print("Retry tapped")
        }
    }
    .padding()
}

#Preview("Online") {
    VStack(spacing: 16) {
        OfflineIndicator(isOffline: false, hasOfflineContent: true)
        CompactOfflineIndicator(isOffline: false, hasOfflineContent: true)
        OfflineBanner(isOffline: false, hasOfflineContent: true)
    }
    .padding()
}
