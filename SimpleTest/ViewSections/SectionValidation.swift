//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 06/04/2026.
//

import SwiftUI

import SwiftUI

struct SectionValidation: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        VStack {
            if model.hasError {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Header
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                        Text("Please complete the required fields")
                            .font(.headline)
                    }
                    
                    // Bullet list
                    VStack(alignment: .leading, spacing: 8) {
                        if model.weight == 0 {
                            ValidationRow(text: "Weight is required")
                        }
                        if model.height == 0 {
                            ValidationRow(text: "Height is required")
                        }
                    }
                }
                .padding()
                .background(Color(red: 1.0, green: 0.92, blue: 0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 3)
                )
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: model.hasError)
    }
}

private struct ValidationRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
            Text(text)
                .font(.subheadline)
        }
    }
}


#Preview("Error - weight") {
    let model = ProfileInputViewModel()
    model.weight = 0
    model.height =  100
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
