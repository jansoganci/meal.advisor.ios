//
//  ServingSizeView.swift
//  meal.advisor.ios
//
//  Settings screen for selecting serving size (number of people)
//

import SwiftUI

struct ServingSizeView: View {
    @StateObject private var prefsService = UserPreferencesService.shared
    @State private var servingSize: Double = 2
    
    private let servingSizeRange = 1.0...8.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Serving Size")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("How many people are you cooking for? We'll adjust ingredient amounts automatically.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            // Current Value Display
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(Int(servingSize))")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    
                    Text(Int(servingSize) == 1 ? "person" : "people")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Visual representation
                HStack(spacing: 4) {
                    ForEach(1...Int(servingSize), id: \.self) { _ in
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                    
                    ForEach(Int(servingSize)+1...8, id: \.self) { _ in
                        Image(systemName: "person")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.3))
                    }
                }
                .padding(.top, 4)
            }
            
            // Slider
            VStack(alignment: .leading, spacing: 8) {
                Slider(
                    value: $servingSize,
                    in: servingSizeRange,
                    step: 1
                ) {
                    Text("Serving Size")
                } minimumValueLabel: {
                    Text("1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("8")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .tint(.accentColor)
                
                // Helper text
                Text(servingSizeHelpText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .navigationTitle("Serving Size")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            servingSize = Double(prefsService.preferences.servingSize)
        }
        .onChange(of: servingSize) { newValue in
            prefsService.preferences.servingSize = Int(newValue)
        }
    }
    
    private var servingSizeHelpText: String {
        switch Int(servingSize) {
        case 1:
            return "Perfect for solo cooking. Ingredients will be scaled down for single portions."
        case 2:
            return "Great for couples or small households. Standard recipe portions."
        case 3...4:
            return "Ideal for small families or dinner parties."
        case 5...6:
            return "Perfect for larger families or entertaining guests."
        case 7...8:
            return "Great for big gatherings or meal prep for the week."
        default:
            return "Ingredients will be automatically adjusted for your group size."
        }
    }
}

// MARK: - Preview
struct ServingSizeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ServingSizeView()
        }
        .previewDisplayName("Serving Size Settings")
    }
}
