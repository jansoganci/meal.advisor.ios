//
//  InstructionsView.swift
//  meal.advisor.ios
//
//  Clean, minimal step-by-step instructions component for cooking
//

import SwiftUI

struct InstructionsView: View {
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text("Instructions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(instructions.count) steps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 16)
            
            // Instructions List
            VStack(spacing: 16) {
                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                    InstructionStep(
                        stepNumber: index + 1,
                        instruction: instruction,
                        isLastStep: index == instructions.count - 1
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
    }
}

struct InstructionStep: View {
    let stepNumber: Int
    let instruction: String
    let isLastStep: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step Number Circle
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 32, height: 32)
                
                Text("\(stepNumber)")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .accessibilityLabel("Step \(stepNumber)")
            
            // Instruction Text
            VStack(alignment: .leading, spacing: 0) {
                Text(instruction)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                
                // Add some bottom spacing except for last step
                if !isLastStep {
                    Spacer()
                        .frame(height: 8)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleInstructions = [
            "Preheat your oven to 425°F (220°C) and line a baking sheet with parchment paper.",
            "Season chicken breasts with salt and pepper on both sides.",
            "Heat olive oil in a large oven-safe skillet over medium-high heat.",
            "Sear chicken breasts for 2-3 minutes per side until golden brown.",
            "Transfer skillet to preheated oven and bake for 15-20 minutes until internal temperature reaches 165°F.",
            "Let rest for 5 minutes before slicing and serving."
        ]
        
        ScrollView {
            InstructionsView(instructions: sampleInstructions)
        }
        .previewDisplayName("Instructions View")
        
        InstructionStep(
            stepNumber: 1,
            instruction: "Preheat your oven to 425°F and line a baking sheet with parchment paper.",
            isLastStep: false
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Single Step")
    }
}
