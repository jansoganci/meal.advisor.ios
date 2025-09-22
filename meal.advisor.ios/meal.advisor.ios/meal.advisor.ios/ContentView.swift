//
//  ContentView.swift
//  meal.advisor.ios
//
//  Created by Can Soğancı on 21.09.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(String(localized: "home"))
                }

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text(String(localized: "favorites"))
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(String(localized: "settings"))
                }
        }
        .tint(.primaryOrange)
    }
}

#Preview {
    ContentView()
}
