//
//  DietaryRestrictionsView.swift
//  meal.advisor.ios
//

import SwiftUI

struct DietaryRestrictionsView: View {
    @StateObject private var prefsService = UserPreferencesService.shared

    var body: some View {
        List {
            ForEach(Meal.DietType.allCases, id: \.self) { diet in
                Toggle(isOn: Binding(
                    get: { prefsService.preferences.dietaryRestrictions.contains(diet) },
                    set: { isOn in
                        if isOn {
                            prefsService.preferences.dietaryRestrictions.insert(diet)
                        } else {
                            prefsService.preferences.dietaryRestrictions.remove(diet)
                        }
                    }
                )) {
                    Text(diet.rawValue)
                }
            }
        }
        .navigationTitle(String(localized: "dietary_restrictions"))
    }
}

