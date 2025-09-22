//
//  ToastView.swift
//  meal.advisor.ios
//
//  Lightweight bottom toast for transient messages.
//

import SwiftUI

struct ToastView: View {
    let text: String
    let background: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(background.opacity(0.9))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

