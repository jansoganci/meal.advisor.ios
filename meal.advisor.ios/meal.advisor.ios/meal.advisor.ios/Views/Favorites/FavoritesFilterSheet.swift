//
//  FavoritesFilterSheet.swift
//  meal.advisor.ios
//
//  Filter sheet for favorites view
//

import SwiftUI

struct FavoritesFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCuisine: Meal.Cuisine?
    @Binding var selectedDiet: Meal.DietType?
    let onClearAll: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Cuisine", selection: $selectedCuisine) {
                        Text("All Cuisines").tag(nil as Meal.Cuisine?)
                        ForEach(Meal.Cuisine.allCases, id: \.self) { cuisine in
                            Text(cuisine.rawValue).tag(cuisine as Meal.Cuisine?)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Cuisine Type")
                } footer: {
                    if selectedCuisine != nil {
                        Text("Showing only \(selectedCuisine!.rawValue) recipes")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
                
                Section {
                    Picker("Diet", selection: $selectedDiet) {
                        Text("All Diets").tag(nil as Meal.DietType?)
                        ForEach(Meal.DietType.allCases, id: \.self) { diet in
                            Text(diet.rawValue).tag(diet as Meal.DietType?)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Dietary Preference")
                } footer: {
                    if selectedDiet != nil {
                        Text("Showing only \(selectedDiet!.rawValue) recipes")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
                
                if hasActiveFilters {
                    Section {
                        Button(role: .destructive) {
                            onClearAll()
                            
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Clear All Filters")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            })
        }
    }
    
    private var hasActiveFilters: Bool {
        selectedCuisine != nil || selectedDiet != nil
    }
}

#Preview {
    FavoritesFilterSheet(
        selectedCuisine: .constant(.italian),
        selectedDiet: .constant(.vegetarian),
        onClearAll: {}
    )
}
