//
//  CuisinePreferencesView.swift
//  meal.advisor.ios
//

import SwiftUI

struct CuisinePreferencesView: View {
    @StateObject private var prefsService = UserPreferencesService.shared

    var body: some View {
        List {
            ForEach(Meal.Cuisine.allCases, id: \.self) { cuisine in
                Toggle(isOn: Binding(
                    get: { prefsService.preferences.cuisinePreferences.contains(cuisine) },
                    set: { isOn in
                        if isOn {
                            prefsService.preferences.cuisinePreferences.insert(cuisine)
                        } else {
                            prefsService.preferences.cuisinePreferences.remove(cuisine)
                        }
                    }
                )) {
                    Text(cuisine.rawValue)
                }
            }
        }
        .navigationTitle(String(localized: "cuisine_preferences"))
    }
}

