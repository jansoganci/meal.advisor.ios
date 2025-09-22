//
//  FavoritesView.swift
//  meal.advisor.ios
//
//  Scaffolding: Favorites screen placeholder
//

import SwiftUI

struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text(String(localized: "no_favorites_yet"))
                    .font(.headline)
                Text(String(localized: "favorites_empty_hint"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .navigationTitle(String(localized: "favorites"))
        }
    }
}

#Preview {
    FavoritesView()
}
