//
//  PremiumUnlockAnimation.swift
//  meal.advisor.ios
//
//  Premium feature unlock animation
//

import SwiftUI

struct PremiumUnlockAnimation: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
            
            // Unlock animation
            VStack(spacing: 24) {
                ZStack {
                    // Glowing circle background
                    Circle()
                        .fill(.yellow.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                    
                    // Crown icon
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow.gradient)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(scale)
                }
                
                VStack(spacing: 8) {
                    Text("Premium Unlocked!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Enjoy all premium features")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Entrance animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Rotation animation
        withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
            rotation = 360
        }
        
        // Exit animation and complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
                scale = 1.2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
}

// MARK: - Feature Unlock Transition

struct FeatureUnlockTransition: ViewModifier {
    let isUnlocked: Bool
    @State private var showAnimation = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if showAnimation {
                        PremiumUnlockAnimation {
                            showAnimation = false
                        }
                    }
                }
            )
            .onChange(of: isUnlocked) { unlocked in
                if unlocked {
                    showAnimation = true
                    
                    // Haptic feedback
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                }
            }
    }
}

extension View {
    func premiumUnlockAnimation(isUnlocked: Bool) -> some View {
        modifier(FeatureUnlockTransition(isUnlocked: isUnlocked))
    }
}

#Preview {
    PremiumUnlockAnimation {
        print("Animation completed")
    }
}
