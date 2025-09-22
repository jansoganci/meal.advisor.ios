//
//  CookingTimeView.swift
//  meal.advisor.ios
//

import SwiftUI

struct CookingTimeView: View {
    @StateObject private var prefsService = UserPreferencesService.shared
    @State private var value: Double = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(String(localized: "cooking_time_available"))
                .font(.headline)
            HStack {
                Text("\(Int(value)) min")
                    .font(.title2.weight(.semibold))
                Spacer()
            }
            Slider(value: $value, in: 10...120, step: 5)
                .tint(.primaryOrange)
            Spacer()
        }
        .padding(16)
        .onAppear { value = Double(prefsService.preferences.maxCookingTime) }
        .onChange(of: value) { _, newValue in
            prefsService.preferences.maxCookingTime = Int(newValue)
        }
        .navigationTitle(String(localized: "cooking_time"))
    }
}

