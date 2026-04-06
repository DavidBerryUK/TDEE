//
//  SectionValidation.swift
//  SimpleTest
//
//  Created by David Berry on 06/04/2026.
//

import SwiftUI

struct SectionValidation: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        VStack {
            if model.hasError {
                VStack(alignment: .leading, spacing: 10) {
                    
                    // Header (no icon – cleaner)
                    Text("Please complete the required fields")
                        .font(.headline)
                    
                    // Validation rows
                    VStack(alignment: .leading, spacing: 6) {
                        
                        if model.weight == 0 {
                            ValidationRow(text: "Weight is required")
                                .transition(rowTransition)
                        }
                        
                        if model.height == 0 {
                            ValidationRow(text: "Height is required")
                                .transition(rowTransition)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 1.0, green: 0.96, blue: 0.96))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.15), lineWidth: 1)
                )
                .transition(.opacity)
            }
        }
        // Match your form layout padding
        .padding(.horizontal, 16)
        
        // Animate section + row changes
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: model.hasError)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: model.weight)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: model.height)
    }
    
    private var rowTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .opacity
        )
    }
}

// MARK: - Row

private struct ValidationRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 12))
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Previews

#Preview("Error - weight") {
    let model = ProfileInputViewModel()
    model.weight = 0
    model.height = 100
    return SectionValidation(model: model)
}

#Preview("Error - Height") {
    let model = ProfileInputViewModel()
    model.weight = 100
    model.height = 0
    return SectionValidation(model: model)
}

#Preview("Error - Both") {
    let model = ProfileInputViewModel()
    model.weight = 0
    model.height = 0
    return SectionValidation(model: model)
}

#Preview("Valid") {
    let model = ProfileInputViewModel()
    model.age = 21
    model.weight = 74
    model.height = 70
    return SectionValidation(model: model)
}
