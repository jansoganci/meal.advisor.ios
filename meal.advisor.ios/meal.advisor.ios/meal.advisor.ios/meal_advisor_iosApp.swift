//
//  meal_advisor_iosApp.swift
//  meal.advisor.ios
//
//  Created by Can Soğancı on 21.09.2025.
//

import SwiftUI

@main
struct meal_advisor_iosApp: App {
    init() {
        // Setup notification categories on app launch
        NotificationService.shared.setupNotificationCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
