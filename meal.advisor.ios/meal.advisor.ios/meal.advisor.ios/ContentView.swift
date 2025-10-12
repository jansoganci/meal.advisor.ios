//
//  ContentView.swift
//  meal.advisor.ios
//
//  Created by Can Soğancı on 21.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        // ✅ ALWAYS show TabView - no auth gate
        // Authentication is optional and contextual (JIT prompts)
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
        .onAppear {
            print("🏠 [ContentView] App launched - Auth status: \(appState.isAuthenticated)")
            print("🏠 [ContentView] Using device ID: \(AuthService.shared.deviceID)")
        }
    }
}

#Preview {
    ContentView()
}
