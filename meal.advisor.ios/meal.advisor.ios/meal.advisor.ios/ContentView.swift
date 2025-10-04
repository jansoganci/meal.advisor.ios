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
        Group {
            if appState.isAuthenticated {
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
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                SignInPromptView(context: .firstSuggestion)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
        .onAppear {
            print("🏠 [ContentView] Appeared with auth status: \(appState.isAuthenticated)")
        }
        .onChange(of: appState.isAuthenticated) { isAuth in
            print("🏠 [ContentView] Auth status changed to: \(isAuth)")
        }
    }
}

#Preview {
    ContentView()
}
