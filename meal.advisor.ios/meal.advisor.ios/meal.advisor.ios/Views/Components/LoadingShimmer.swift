//
//  LoadingShimmer.swift
//  meal.advisor.ios
//
//  Simple skeleton shimmer placeholder
//

import SwiftUI

struct LoadingShimmer: View {
    @State private var animate = false

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray5))
            .overlay(
                GeometryReader { proxy in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.35),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: proxy.size.width / 2)
                    .offset(x: animate ? proxy.size.width : -proxy.size.width)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
    }
}

#Preview {
    LoadingShimmer()
        .frame(height: 160)
        .padding()
}

