//
//  TimeGreeting.swift
//  meal.advisor.ios
//
//  Shows a time-aware greeting and meal period prompt.
//

import SwiftUI

struct TimeGreeting: View {
    let date: Date

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5...10: return "Good morning!"
        case 11...16: return "Good afternoon!"
        default: return "Good evening!"
        }
    }

    private var mealPeriod: String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5...10: return "breakfast"
        case 11...15: return "lunch"
        default: return "dinner"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primaryText)
            Text("What’s for \(mealPeriod)?")
                .font(.headline)
                .foregroundColor(.secondaryText)
                .accessibilityLabel("What's for \(mealPeriod)?")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        TimeGreeting(date: Date(timeIntervalSince1970: 60*60*8)) // morning
        TimeGreeting(date: Date(timeIntervalSince1970: 60*60*13)) // afternoon
        TimeGreeting(date: Date(timeIntervalSince1970: 60*60*20)) // evening
    }
    .padding()
}

