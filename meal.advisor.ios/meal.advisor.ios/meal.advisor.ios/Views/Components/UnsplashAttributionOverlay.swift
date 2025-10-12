//
//  UnsplashAttributionOverlay.swift
//  meal.advisor.ios
//
//  Attribution overlay for Unsplash photos (required by TOS)
//  Displays photographer credit and Unsplash link
//

import SwiftUI

struct UnsplashAttributionOverlay: View {
    let attribution: UnsplashAttribution
    
    var body: some View {
        HStack(spacing: 3) {
            Text("Photo by")
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
            
            Link(attribution.photographerName, destination: attribution.photographerURL)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text("on")
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
            
            Link("Unsplash", destination: attribution.unsplashURL)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.5))
        )
        .lineLimit(1)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        // Sample food image background
        Color.gray
        
        VStack {
            Spacer()
            UnsplashAttributionOverlay(
                attribution: UnsplashAttribution(
                    photographerName: "Wenhao Ruan",
                    photographerUsername: "wenhaoruan",
                    photographerURL: URL(string: "https://unsplash.com/@wenhaoruan?utm_source=meal_advisor&utm_medium=referral")!,
                    unsplashURL: URL(string: "https://unsplash.com/?utm_source=meal_advisor&utm_medium=referral")!,
                    photoID: "RhiTquS8jbI"
                )
            )
            .padding()
        }
    }
    .frame(width: 300, height: 200)
}

